import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';

/// 🤝 PocketMateService: Central service for managing Snapchat-style Mates,
/// connection requests, conversation pinning, and 100% private interactions.
class PocketMateService {
  static final PocketMateService _instance = PocketMateService._internal();
  factory PocketMateService() => _instance;
  PocketMateService._internal();

  static final _supabase = SupaFlow.client;

  /// Check if two users are mutual Mates
  static Future<bool> isMate(String myId, String otherUserId) async {
    if (myId.isEmpty || otherUserId.isEmpty || myId == otherUserId) return true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('pocket_mates_$myId') ?? [];
      if (list.contains(otherUserId)) return true;

      // Check follows / friendships in DB
      final res = await _supabase
          .from('follows')
          .select('id')
          .eq('follower_id', myId)
          .eq('followed_id', otherUserId)
          .maybeSingle();

      if (res != null) {
        list.add(otherUserId);
        await prefs.setStringList('pocket_mates_$myId', list);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Send a Mate Request (writes to Supabase notifications table)
  static Future<bool> sendMateRequest({
    required String senderId,
    required String receiverId,
    String? senderName,
    String? message,
    String? contextType, // 'anonymous_chat', 'gallery_market', 'stranger_match'
  }) async {
    if (senderId.isEmpty || receiverId.isEmpty) return false;
    try {
      // Get sender name if not passed
      String name = senderName ?? 'Pocket Mate';
      if (senderName == null || senderName.isEmpty) {
        final profileRes = await _supabase
            .from('profile')
            .select('name')
            .eq('user_id', senderId)
            .maybeSingle();
        name = profileRes?['name'] ?? 'Pocket Mate';
      }

      final defaultMsg = contextType == 'gallery_market'
          ? 'Inquired about your market item. Wants to connect as your Mate!'
          : 'Matched from Anonymous English Chat! Wants to become your Pocket Mate.';

      await _supabase.from('notifications').insert({
        'user_id': receiverId,
        'sender_id': senderId,
        'source_id': senderId,
        'sender_name': name,
        'type': 'mate_request',
        'message': message ?? defaultMsg,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Also record in SharedPreferences for rapid local sync
      final prefs = await SharedPreferences.getInstance();
      final sentList = prefs.getStringList('sent_mate_requests_$senderId') ?? [];
      if (!sentList.contains(receiverId)) {
        sentList.add(receiverId);
        await prefs.setStringList('sent_mate_requests_$senderId', sentList);
      }

      return true;
    } catch (e) {
      debugPrint('Error sending mate request: $e');
      return false;
    }
  }

  /// Accept a Mate Request:
  /// 1. Updates notification status to 'accepted'
  /// 2. Adds mutual follow in 'follows' table
  /// 3. Ensures conversation exists in 'conversations'
  /// 4. Adds to local Mates lists for 0ms perceptible delay
  static Future<bool> acceptMateRequest({
    required String notificationId,
    required String myId,
    required String senderId,
  }) async {
    try {
      if (PocketRobotService.isRobotId(senderId)) {
        await PocketRobotService.acceptRobotRequest(myId: myId, robotId: senderId);
        return true;
      }

      // 1. Update notification in DB
      if (notificationId.isNotEmpty && !notificationId.startsWith('local_') && !notificationId.startsWith('robot_')) {
        await _supabase
            .from('notifications')
            .update({'status': 'accepted', 'is_read': true})
            .eq('id', notificationId);
      }

      // 2. Add mutual follows in DB
      try {
        await _supabase.from('follows').upsert([
          {
            'follower_id': myId,
            'followed_id': senderId,
            'created_at': DateTime.now().toIso8601String(),
          },
          {
            'follower_id': senderId,
            'followed_id': myId,
            'created_at': DateTime.now().toIso8601String(),
          }
        ]);
      } catch (_) {}

      // 3. Ensure conversation row exists in 'conversations'
      try {
        final existingConv = await _supabase
            .from('conversations')
            .select('id')
            .or('and(user1_id.eq.$myId,user2_id.eq.$senderId),and(user1_id.eq.$senderId,user2_id.eq.$myId)')
            .maybeSingle();

        if (existingConv == null) {
          await _supabase.from('conversations').insert({
            'user1_id': myId,
            'user2_id': senderId,
            'last_message': '🤝 Connected as Pocket Mates! Start snapping & chatting.',
            'last_message_time': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'unread_count': 0,
            'is_group': false,
          });
        }
      } catch (_) {}

      // 4. Update local SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final myMatesKey = 'pocket_mates_$myId';
      final list = prefs.getStringList(myMatesKey) ?? [];
      if (!list.contains(senderId)) {
        list.add(senderId);
        await prefs.setStringList(myMatesKey, list);
      }

      // 5. Notify sender that request was accepted
      try {
        final myProfile = await _supabase
            .from('profile')
            .select('name')
            .eq('user_id', myId)
            .maybeSingle();
        final myName = myProfile?['name'] ?? 'A Mate';

        await _supabase.from('notifications').insert({
          'user_id': senderId,
          'sender_id': myId,
          'source_id': myId,
          'sender_name': myName,
          'type': 'mate_accepted',
          'message': '✨ $myName accepted your Mate Request! You can now snap & chat.',
          'status': 'read',
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('Error accepting mate request: $e');
      return false;
    }
  }

  /// Decline / reject a Mate Request
  static Future<bool> declineMateRequest({
    required String notificationId,
    required String myId,
    String? senderId,
  }) async {
    try {
      if (senderId != null && senderId.startsWith('pocket_robot_')) {
        final prefs = await SharedPreferences.getInstance();
        final key = 'pending_pocket_requests_$myId';
        final existingStr = prefs.getString(key);
        if (existingStr != null) {
          try {
            List<Map<String, dynamic>> reqs =
                List<Map<String, dynamic>>.from(json.decode(existingStr));
            reqs.removeWhere((r) => r['senderId'] == senderId || r['id'] == notificationId);
            await prefs.setString(key, json.encode(reqs));
          } catch (_) {}
        }
        return true;
      }

      if (notificationId.isNotEmpty && !notificationId.startsWith('local_') && !notificationId.startsWith('robot_')) {
        await _supabase
            .from('notifications')
            .update({'status': 'declined', 'is_read': true})
            .eq('id', notificationId);
      }
      return true;
    } catch (e) {
      debugPrint('Error declining mate request: $e');
      return false;
    }
  }

  /// Check if a user ID is a Pocket Robot
  static bool isRobot(String userId) {
    return userId.startsWith('pocket_robot_') || userId.startsWith('robot_');
  }

  /// Fetch all pending connection requests for a user (combining Supabase & Local Robot requests)
  static Future<List<Map<String, dynamic>>> getPendingRequests(String userId) async {
    if (userId.isEmpty) return [];
    try {
      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .eq('type', 'mate_request')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> requests = [];
      for (final item in (response as List)) {
        requests.add(Map<String, dynamic>.from(item));
      }

      // Merge with local robot requests
      final prefs = await SharedPreferences.getInstance();
      final localStr = prefs.getString('pending_pocket_requests_$userId');
      if (localStr != null && localStr.isNotEmpty) {
        try {
          final localReqs = List<Map<String, dynamic>>.from(json.decode(localStr));
          for (final lr in localReqs) {
            if (!requests.any((x) => x['id'] == lr['id'] || (x['sender_id'] == lr['senderId']))) {
              requests.add({
                'id': lr['id'],
                'sender_id': lr['senderId'],
                'sender_name': lr['senderName'],
                'message': lr['message'],
                'created_at': lr['time'] ?? DateTime.now().toIso8601String(),
                'is_robot': lr['isRobot'] ?? true,
                'archetype': lr['archetype'],
              });
            }
          }
        } catch (_) {}
      }

      return requests;
    } catch (e) {
      debugPrint('Error fetching pending requests: $e');
      return [];
    }
  }

  /// Toggle Pinned Conversation status
  static Future<bool> togglePinConversation(String userId, String conversationId) async {
    if (userId.isEmpty || conversationId.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'pinned_conversations_$userId';
      final list = prefs.getStringList(key) ?? [];

      bool isNowPinned;
      if (list.contains(conversationId)) {
        list.remove(conversationId);
        isNowPinned = false;
      } else {
        list.add(conversationId);
        isNowPinned = true;
      }

      await prefs.setStringList(key, list);
      return isNowPinned;
    } catch (e) {
      debugPrint('Error toggling pin: $e');
      return false;
    }
  }

  /// Get list of pinned conversation IDs
  static Future<List<String>> getPinnedConversations(String userId) async {
    if (userId.isEmpty) return [];
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('pinned_conversations_$userId') ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Get list of all local Mate IDs
  static Future<List<String>> getMatesList(String userId) async {
    if (userId.isEmpty) return [];
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('pocket_mates_$userId') ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Add user directly to Mates list
  static Future<void> addMate(String userId, String mateId) async {
    if (userId.isEmpty || mateId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'pocket_mates_$userId';
      final list = prefs.getStringList(key) ?? [];
      if (!list.contains(mateId)) {
        list.add(mateId);
        await prefs.setStringList(key, list);
      }
    } catch (_) {}
  }
}
