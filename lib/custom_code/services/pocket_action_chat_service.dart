import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'pocket_citadel_fight_service.dart';
import 'pocket_robot_service.dart';

/// Centralized service to automatically generate system chat messages,
/// update conversations, and track actions across Mates Requests,
/// Fights, Attacks, and PocketTalk Requests.
class PocketActionChatService {
  static final _supabase = SupaFlow.client;

  static const String _kPrefsRecentAttacks = 'pm_recent_attacks_';
  static const String _kPrefsSentAttacks = 'pm_sent_attacks_';

  static bool _isValidUuid(String? id) {
    if (id == null || id.isEmpty) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(id);
  }

  // =========================================================================
  // 1. ATTACK ACTION
  // =========================================================================

  /// Automatically create chat message & conversation entry when User A attacks User B
  static Future<void> sendAttackActionMessage({
    required String attackerId,
    required String defenderId,
    String? attackerName,
    String? attackerAvatar,
    String? defenderName,
    String? defenderAvatar,
    String weapon = '⚡ Laser Strike',
    String damage = '60%',
    int lootedCoins = 15,
    int? attackerDay,
  }) async {
    if (attackerId.isEmpty || defenderId.isEmpty || attackerId == defenderId) {
      return;
    }

    try {
      // 1. Resolve names & avatars if not supplied
      String aName = attackerName ?? 'Attacker';
      String? aAvatar = attackerAvatar;
      if (aName == 'Attacker' || aName == 'You' || aAvatar == null) {
        try {
          final aProf = await _supabase
              .from('profile')
              .select('name, display_name, profile_image_url')
              .eq('user_id', attackerId)
              .maybeSingle();
          if (aProf != null) {
            aName = aProf['display_name'] ?? aProf['name'] ?? aName;
            aAvatar ??= aProf['profile_image_url'];
          }
        } catch (_) {}
      }

      String dName = defenderName ?? 'Defender';
      String? dAvatar = defenderAvatar;
      if (dName == 'Defender' || dAvatar == null) {
        try {
          final dProf = await _supabase
              .from('profile')
              .select('name, display_name, profile_image_url')
              .eq('user_id', defenderId)
              .maybeSingle();
          if (dProf != null) {
            dName = dProf['display_name'] ?? dProf['name'] ?? dName;
            dAvatar ??= dProf['profile_image_url'];
          }
        } catch (_) {}
      }

      final String messageText =
          '⚔️ $aName successfully attacked $dName\'s house!';
      final String displaySummary =
          '⚔️ $aName successfully attacked $dName\'s house!';

      final Map<String, dynamic> metadata = {
        'is_citadel_attack': true,
        'action': 'attack',
        'attacker_id': attackerId,
        'defender_id': defenderId,
        'attacker_name': aName,
        'attacker_avatar': aAvatar,
        'defender_name': dName,
        'defender_avatar': dAvatar,
        'weapon': weapon,
        'damage': damage,
        'coins_looted': lootedCoins,
        'attacker_day': attackerDay ?? 1,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };

      // 2. Persist to Supabase if valid UUIDs
      if (_isValidUuid(attackerId) && _isValidUuid(defenderId)) {
        // Insert message
        try {
          await _supabase.from('messages').insert({
            'sender_id': attackerId,
            'receiver_id': defenderId,
            'message_text': messageText,
            'content': messageText,
            'message_type': 'citadel_attack',
            'metadata': metadata,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
        } catch (e) {
          debugPrint('Error inserting attack message into Supabase: $e');
        }

        // Upsert conversation row
        try {
          final updateRes = await _supabase.from('conversations').update({
            'last_message': displaySummary,
            'last_message_time': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'last_sender_id': attackerId,
          }).or(
            'and(user1_id.eq.$attackerId,user2_id.eq.$defenderId),and(user1_id.eq.$defenderId,user2_id.eq.$attackerId)',
          ).select();

          if (updateRes.isEmpty) {
            await _supabase.from('conversations').insert({
              'user1_id': attackerId,
              'user2_id': defenderId,
              'last_message': displaySummary,
              'last_message_time': DateTime.now().toUtc().toIso8601String(),
              'updated_at': DateTime.now().toUtc().toIso8601String(),
              'last_sender_id': attackerId,
              'unread_count': 1,
              'is_group': false,
            });
          }
        } catch (e) {
          debugPrint('Error updating conversation for attack: $e');
        }

        // Send notification
        try {
          await _supabase.from('notifications').insert({
            'user_id': defenderId,
            'sender_id': attackerId,
            'source_id': attackerId,
            'type': 'citadel_attack',
            'message':
                '⚔️ $aName raided your Citadel defenses with $weapon (-$lootedCoins coins)!',
            'status': 'pending',
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
        } catch (_) {}
      }

      // 3. Handle local saving if interacting with a robot
      if (PocketRobotService.isRobotId(defenderId)) {
        await PocketRobotService.saveRobotChatMessage(
          attackerId,
          defenderId,
          {
            'id': 'atk_${DateTime.now().millisecondsSinceEpoch}',
            'sender_id': attackerId,
            'receiver_id': defenderId,
            'message_text': messageText,
            'content': messageText,
            'message_type': 'citadel_attack',
            'metadata': metadata,
            'created_at': DateTime.now().toIso8601String(),
            'is_read': true,
          },
        );
      }

      // 4. Cache attack in local storage for instant offline / Requests tab view
      await _cacheAttackLocally(
        attackerId: attackerId,
        defenderId: defenderId,
        attackerName: aName,
        attackerAvatar: aAvatar,
        defenderName: dName,
        defenderAvatar: dAvatar,
        metadata: metadata,
      );
    } catch (e) {
      debugPrint('sendAttackActionMessage error: $e');
    }
  }

  // =========================================================================
  // 2. FIGHT ACTION
  // =========================================================================

  /// Automatically create chat message & conversation entry when a Fight challenge is initiated
  static Future<void> sendFightActionMessage({
    required CitadelFightChallenge challenge,
    bool isInitiation = false,
    int? score,
    int? seconds,
    double? timeSec,
    int? correct,
    int duelSeed = 20240607,
  }) async {
    final challengerId = challenge.challengerId;
    final opponentId = challenge.opponentId;
    if (challengerId.isEmpty || opponentId.isEmpty) return;

    try {
      final effSeconds = seconds ?? challenge.challengerSeconds;
      final effScore = score ?? challenge.challengerScore;
      final effCorrect = correct ?? challenge.challengerCorrect;
      final effTimeSec = timeSec ?? challenge.challengerTimeSeconds;

      final String messageText = isInitiation
          ? '🥊 I initiated a Citadel Fight challenge! 10 Questions War Mode. Tap to duel! ⚔️'
          : '🥊 CITADEL FIGHT CHALLENGE!\nI finished the speed duel in ${effSeconds}s with $effScore pts! Can you beat my time? Tap to FIGHT BACK! ⚔️';

      final String displaySummary = isInitiation
          ? '🥊 ${challenge.challengerName} challenged you to a Fight!'
          : '🥊 ${challenge.challengerName} challenged you to a Fight! (${effSeconds}s)';

      final Map<String, dynamic> metadata = {
        'fight_id': challenge.id,
        'challenger_id': challengerId,
        'challenger_name': challenge.challengerName,
        'challenger_avatar': challenge.challengerAvatar,
        'opponent_id': opponentId,
        'opponent_name': challenge.opponentName,
        'opponent_avatar': challenge.opponentAvatar,
        'challenger_seconds': effSeconds,
        'challenger_score': effScore,
        'question_count': challenge.questionCount,
        'duel_seed': duelSeed,
        'challenger_correct': effCorrect,
        'challenger_time_seconds': effTimeSec,
        'is_initiating': isInitiation,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };

      if (_isValidUuid(challengerId) && _isValidUuid(opponentId)) {
        // Insert message
        try {
          await _supabase.from('messages').insert({
            'sender_id': challengerId,
            'receiver_id': opponentId,
            'message_text': messageText,
            'content': messageText,
            'message_type': 'citadel_fight',
            'metadata': metadata,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
        } catch (e) {
          debugPrint('Error inserting fight message into Supabase: $e');
        }

        // Upsert conversation row
        try {
          final updateRes = await _supabase.from('conversations').update({
            'last_message': displaySummary,
            'last_message_time': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'last_sender_id': challengerId,
          }).or(
            'and(user1_id.eq.$challengerId,user2_id.eq.$opponentId),and(user1_id.eq.$opponentId,user2_id.eq.$challengerId)',
          ).select();

          if (updateRes.isEmpty) {
            await _supabase.from('conversations').insert({
              'user1_id': challengerId,
              'user2_id': opponentId,
              'last_message': displaySummary,
              'last_message_time': DateTime.now().toUtc().toIso8601String(),
              'updated_at': DateTime.now().toUtc().toIso8601String(),
              'last_sender_id': challengerId,
              'unread_count': 1,
              'is_group': false,
            });
          }
        } catch (e) {
          debugPrint('Error updating conversation for fight: $e');
        }
      }

      if (PocketRobotService.isRobotId(opponentId)) {
        await PocketRobotService.saveRobotChatMessage(
          challengerId,
          opponentId,
          {
            'id': 'fight_${DateTime.now().millisecondsSinceEpoch}',
            'sender_id': challengerId,
            'receiver_id': opponentId,
            'message_text': messageText,
            'content': messageText,
            'message_type': 'citadel_fight',
            'metadata': metadata,
            'created_at': DateTime.now().toIso8601String(),
            'is_read': true,
          },
        );
      }
    } catch (e) {
      debugPrint('sendFightActionMessage error: $e');
    }
  }

  // =========================================================================
  // 3. MATES REQUEST ACTION
  // =========================================================================

  /// Automatically create chat message & conversation entry when a Mate Request is sent
  static Future<void> sendMateRequestActionMessage({
    required String senderId,
    required String receiverId,
    String? senderName,
    String? senderAvatar,
    String? message,
  }) async {
    if (senderId.isEmpty || receiverId.isEmpty || senderId == receiverId) return;

    try {
      String sName = senderName ?? 'Pocket Mate';
      String? sAvatar = senderAvatar;
      if (sName == 'Pocket Mate' || sAvatar == null) {
        try {
          final prof = await _supabase
              .from('profile')
              .select('name, display_name, profile_image_url')
              .eq('user_id', senderId)
              .maybeSingle();
          if (prof != null) {
            sName = prof['display_name'] ?? prof['name'] ?? sName;
            sAvatar ??= prof['profile_image_url'];
          }
        } catch (_) {}
      }

      final String messageText = message ??
          '🤝 Pocket Mate Request: $sName sent you a Mate connection request!';
      final String displaySummary = '🤝 Sent a Pocket Mate Request';

      final Map<String, dynamic> metadata = {
        'type': 'mate_request',
        'is_mate_request': true,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'sender_name': sName,
        'sender_avatar': sAvatar,
        'status': 'pending',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };

      if (_isValidUuid(senderId) && _isValidUuid(receiverId)) {
        // Insert message
        try {
          await _supabase.from('messages').insert({
            'sender_id': senderId,
            'receiver_id': receiverId,
            'message_text': messageText,
            'content': messageText,
            'message_type': 'mate_request',
            'metadata': metadata,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
        } catch (e) {
          debugPrint('Error inserting mate_request message into Supabase: $e');
        }

        // Upsert conversation row
        try {
          final updateRes = await _supabase.from('conversations').update({
            'last_message': displaySummary,
            'last_message_time': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'last_sender_id': senderId,
          }).or(
            'and(user1_id.eq.$senderId,user2_id.eq.$receiverId),and(user1_id.eq.$receiverId,user2_id.eq.$senderId)',
          ).select();

          if (updateRes.isEmpty) {
            await _supabase.from('conversations').insert({
              'user1_id': senderId,
              'user2_id': receiverId,
              'last_message': displaySummary,
              'last_message_time': DateTime.now().toUtc().toIso8601String(),
              'updated_at': DateTime.now().toUtc().toIso8601String(),
              'last_sender_id': senderId,
              'unread_count': 1,
              'is_group': false,
            });
          }
        } catch (e) {
          debugPrint('Error updating conversation for mate request: $e');
        }
      }

      if (PocketRobotService.isRobotId(receiverId)) {
        await PocketRobotService.saveRobotChatMessage(
          senderId,
          receiverId,
          {
            'id': 'mate_req_${DateTime.now().millisecondsSinceEpoch}',
            'sender_id': senderId,
            'receiver_id': receiverId,
            'message_text': messageText,
            'content': messageText,
            'message_type': 'mate_request',
            'metadata': metadata,
            'created_at': DateTime.now().toIso8601String(),
            'is_read': true,
          },
        );
      }
    } catch (e) {
      debugPrint('sendMateRequestActionMessage error: $e');
    }
  }


  /// Restore or sync missing Mate Request chat message between two users
  /// Ensures historical notifications have a corresponding chat bubble in messages
  static Future<void> syncHistoricalMateRequestMessage({
    required String myId,
    required String otherUserId,
  }) async {
    if (!_isValidUuid(myId) || !_isValidUuid(otherUserId)) return;
    try {
      // 1. Check if a mate_request message already exists between these users
      final existingMsg = await _supabase
          .from('messages')
          .select('id')
          .or('and(sender_id.eq.$myId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$myId)')
          .eq('message_type', 'mate_request')
          .limit(1);

      if ((existingMsg as List).isNotEmpty) {
        return; // Already present, avoid duplication
      }

      // 2. Look for any existing pending or accepted mate_request notification
      final notif = await _supabase
          .from('notifications')
          .select('*')
          .or('and(sender_id.eq.$myId,user_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,user_id.eq.$myId)')
          .eq('type', 'mate_request')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (notif != null) {
        final senderId = notif['sender_id']?.toString() ?? myId;
        final receiverId = notif['user_id']?.toString() ?? otherUserId;
        final notifStatus = notif['status']?.toString() ?? 'pending';
        final createdAt = notif['created_at']?.toString() ?? DateTime.now().toUtc().toIso8601String();

        String sName = 'Pocket Mate';
        try {
          final profileRes = await _supabase
              .from('profile')
              .select('name')
              .eq('user_id', senderId)
              .maybeSingle();
          if (profileRes != null && profileRes['name'] != null) {
            sName = profileRes['name'].toString();
          }
        } catch (_) {}

        final msgText = notif['message']?.toString() ?? '$sName sent you a Mates Request';
        final metadata = {
          'type': 'mate_request',
          'is_mate_request': true,
          'request_id': notif['id']?.toString() ?? '',
          'sender_id': senderId,
          'receiver_id': receiverId,
          'sender_name': sName,
          'status': notifStatus,
          'timestamp': createdAt,
        };

        await _supabase.from('messages').insert({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'message_text': msgText,
          'content': msgText,
          'message_type': 'mate_request',
          'metadata': metadata,
          'created_at': createdAt,
        });
      }
    } catch (e) {
      debugPrint('syncHistoricalMateRequestMessage error: $e');
    }
  }

  // =========================================================================
  // 4. POCKETTALK REQUEST ACTION
  // =========================================================================

  /// Automatically create chat message & conversation entry when a PocketTalk 4-Day Pact is requested
  static Future<void> sendPocketTalkRequestActionMessage({
    required String senderId,
    required String receiverId,
    String? senderName,
    String? senderAvatar,
    String? pactId,
  }) async {
    if (senderId.isEmpty || receiverId.isEmpty || senderId == receiverId) return;

    try {
      String sName = senderName ?? 'Pocket Mate';
      String? sAvatar = senderAvatar;
      if (sName == 'Pocket Mate' || sAvatar == null) {
        try {
          final prof = await _supabase
              .from('profile')
              .select('name, display_name, profile_image_url')
              .eq('user_id', senderId)
              .maybeSingle();
          if (prof != null) {
            sName = prof['display_name'] ?? prof['name'] ?? sName;
            sAvatar ??= prof['profile_image_url'];
          }
        } catch (_) {}
      }

      const String messageText =
          '⚡ Pocket Talk Challenge: Invited you to a 4-Day Spoken English Pact! Tap to accept and start Day 1.';
      const String displaySummary = '⚡ Pocket Talk: 4-Day Spoken Pact Request';

      final Map<String, dynamic> metadata = {
        'is_pocket_talk': true,
        'type': 'pocket_talk_request',
        'pact_id': pactId ?? 'pact_${senderId}_$receiverId',
        'sender_id': senderId,
        'receiver_id': receiverId,
        'sender_name': sName,
        'sender_avatar': sAvatar,
        'status': 'pending',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };

      if (_isValidUuid(senderId) && _isValidUuid(receiverId)) {
        // Insert message
        try {
          await _supabase.from('messages').insert({
            'sender_id': senderId,
            'receiver_id': receiverId,
            'message_text': messageText,
            'content': messageText,
            'message_type': 'pocket_talk_request',
            'metadata': metadata,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
        } catch (e) {
          debugPrint('Error inserting pocket_talk message into Supabase: $e');
        }

        // Upsert conversation row
        try {
          final updateRes = await _supabase.from('conversations').update({
            'last_message': displaySummary,
            'last_message_time': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'last_sender_id': senderId,
          }).or(
            'and(user1_id.eq.$senderId,user2_id.eq.$receiverId),and(user1_id.eq.$receiverId,user2_id.eq.$senderId)',
          ).select();

          if (updateRes.isEmpty) {
            await _supabase.from('conversations').insert({
              'user1_id': senderId,
              'user2_id': receiverId,
              'last_message': displaySummary,
              'last_message_time': DateTime.now().toUtc().toIso8601String(),
              'updated_at': DateTime.now().toUtc().toIso8601String(),
              'last_sender_id': senderId,
              'unread_count': 1,
              'is_group': false,
            });
          }
        } catch (e) {
          debugPrint('Error updating conversation for pocket talk: $e');
        }
      }

      if (PocketRobotService.isRobotId(receiverId)) {
        await PocketRobotService.saveRobotChatMessage(
          senderId,
          receiverId,
          {
            'id': 'pt_${DateTime.now().millisecondsSinceEpoch}',
            'sender_id': senderId,
            'receiver_id': receiverId,
            'message_text': messageText,
            'content': messageText,
            'message_type': 'pocket_talk_request',
            'metadata': metadata,
            'created_at': DateTime.now().toIso8601String(),
            'is_read': true,
          },
        );
      }
    } catch (e) {
      debugPrint('sendPocketTalkRequestActionMessage error: $e');
    }
  }

  // =========================================================================
  // 5. LOCAL ATTACKS QUERYING & CACHING (FOR REQUESTS TAB)
  // =========================================================================

  static Future<void> _cacheAttackLocally({
    required String attackerId,
    required String defenderId,
    required String attackerName,
    String? attackerAvatar,
    required String defenderName,
    String? defenderAvatar,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Record for defender (incoming)
      final incomingKey = '$_kPrefsRecentAttacks$defenderId';
      final inListStr = prefs.getString(incomingKey);
      List<Map<String, dynamic>> inList = [];
      if (inListStr != null && inListStr.isNotEmpty) {
        try {
          inList = List<Map<String, dynamic>>.from(jsonDecode(inListStr));
        } catch (_) {}
      }
      inList.removeWhere((item) => item['attacker_id'] == attackerId);
      inList.insert(0, {
        'id': 'atk_${DateTime.now().millisecondsSinceEpoch}',
        'sender_id': attackerId,
        'receiver_id': defenderId,
        'peer_id': attackerId,
        'peer_name': attackerName,
        'peer_avatar': attackerAvatar,
        'sender_name': attackerName,
        'sender_avatar': attackerAvatar,
        'weapon': metadata['weapon'],
        'damage': metadata['damage'],
        'coins_looted': metadata['coins_looted'],
        'created_at': DateTime.now().toIso8601String(),
        'is_sent': false,
      });
      await prefs.setString(incomingKey, jsonEncode(inList.take(30).toList()));

      // Record for attacker (sent)
      final sentKey = '$_kPrefsSentAttacks$attackerId';
      final sentListStr = prefs.getString(sentKey);
      List<Map<String, dynamic>> sentList = [];
      if (sentListStr != null && sentListStr.isNotEmpty) {
        try {
          sentList = List<Map<String, dynamic>>.from(jsonDecode(sentListStr));
        } catch (_) {}
      }
      sentList.removeWhere((item) => item['defender_id'] == defenderId);
      sentList.insert(0, {
        'id': 'sent_atk_${DateTime.now().millisecondsSinceEpoch}',
        'sender_id': attackerId,
        'receiver_id': defenderId,
        'peer_id': defenderId,
        'peer_name': defenderName,
        'peer_avatar': defenderAvatar,
        'receiver_name': defenderName,
        'receiver_avatar': defenderAvatar,
        'weapon': metadata['weapon'],
        'damage': metadata['damage'],
        'coins_looted': metadata['coins_looted'],
        'created_at': DateTime.now().toIso8601String(),
        'is_sent': true,
      });
      await prefs.setString(sentKey, jsonEncode(sentList.take(30).toList()));
    } catch (_) {}
  }

  /// Get recent incoming attacks for userId
  static Future<List<Map<String, dynamic>>> getPendingAttacks(String userId) async {
    if (userId.isEmpty) return [];
    final List<Map<String, dynamic>> results = [];
    final Set<String> seenAttackers = {};

    // 1. Query Supabase notifications for citadel_attack
    try {
      if (_isValidUuid(userId)) {
        final res = await _supabase
            .from('notifications')
            .select('*')
            .eq('user_id', userId)
            .eq('type', 'citadel_attack')
            .order('created_at', ascending: false)
            .limit(20);

        for (final item in (res as List)) {
          final map = Map<String, dynamic>.from(item);
          final data = map['data'] is Map ? Map<String, dynamic>.from(map['data']) : {};
          final senderId = map['sender_id']?.toString() ?? '';
          if (senderId.isNotEmpty && !seenAttackers.contains(senderId)) {
            seenAttackers.add(senderId);
            results.add({
              'id': map['id']?.toString() ?? UniqueKey().toString(),
              'sender_id': senderId,
              'receiver_id': userId,
              'peer_id': senderId,
              'peer_name': data['attacker_name'] ?? 'Attacker',
              'peer_avatar': data['attacker_avatar'],
              'weapon': data['weapon'] ?? '⚡ Laser Strike',
              'damage': data['damage'] ?? '60%',
              'coins_looted': data['coins_looted'] ?? 15,
              'created_at': map['created_at'] ?? DateTime.now().toIso8601String(),
              'is_sent': false,
            });
          }
        }
      }
    } catch (_) {}

    // 2. Read locally cached attacks
    try {
      final prefs = await SharedPreferences.getInstance();
      final inListStr = prefs.getString('$_kPrefsRecentAttacks$userId');
      if (inListStr != null && inListStr.isNotEmpty) {
        final list = List<Map<String, dynamic>>.from(jsonDecode(inListStr));
        for (final item in list) {
          final sId = item['sender_id']?.toString() ?? '';
          if (sId.isNotEmpty && !seenAttackers.contains(sId)) {
            seenAttackers.add(sId);
            results.add(item);
          }
        }
      }
    } catch (_) {}

    return results;
  }

  /// Get recent sent attacks launched by userId
  static Future<List<Map<String, dynamic>>> getSentAttacks(String userId) async {
    if (userId.isEmpty) return [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final sentListStr = prefs.getString('$_kPrefsSentAttacks$userId');
      if (sentListStr != null && sentListStr.isNotEmpty) {
        return List<Map<String, dynamic>>.from(jsonDecode(sentListStr));
      }
    } catch (_) {}
    return [];
  }
}

