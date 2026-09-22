import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

/// 🏛️ Official President of Pocket World & Pocket Mates Service
/// Handles the official Presidential Desk, user inquiries, 24-hour protection alerts,
/// and presidential vibes/announcements with Golden Verified Tick verification.
class PocketPresidentService {
  static const String presidentId = 'pocket_president';
  static const String presidentName = 'President';
  static const String presidentBadge = 'Poket Mates';
  static const String presidentRole = 'Head of Poket World';

  // High-resolution royal seal avatar representing the President of Poket World
  static const String presidentAvatarUrl =
      'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=300&auto=format&fit=crop&q=80';

  static const String defaultWelcomeMessage =
      'Welcome to Poket Mates! 🌟 I am the President of Poket World. If you have any questions, doubts, complaints, or need assistance on your learning journey, message me here anytime. You are under presidential care!';

  // SharedPreferences Keys
  static const String _kPresidentChatPrefix = 'president_chat_';
  static const String _kPresidentInquiriesMasterKey = 'president_inquiries_master';
  static const String _kPresidentVibesKey = 'president_vibes_store';
  static const String _kPresidentAnnouncementsKey = 'president_announcements_store';

  static bool isPresidentId(String id) => id == presidentId;

  /// Fetch full chat history for a specific user with The President
  static Future<List<Map<String, dynamic>>> getPresidentChatHistory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_kPresidentChatPrefix$userId';
      final raw = prefs.getString(key);

      List<Map<String, dynamic>> historyList = [];
      if (raw == null || raw.isEmpty) {
        // Initialize default welcome message if user has no history yet
        final welcomeMsg = {
          'id': 'pres_welcome_$userId',
          'sender_id': presidentId,
          'receiver_id': userId,
          'message_text': defaultWelcomeMessage,
          'message_type': 'text',
          'created_at': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
          'is_read': false,
          'metadata': {
            'is_official': true,
            'is_president': true,
            'golden_tick': true,
          }
        };
        historyList = [welcomeMsg];
      } else {
        final List<dynamic> decoded = jsonDecode(raw);
        historyList = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      // Sync any remote messages or replies from Supabase reports
      try {
        final supabase = SupaFlow.client;
        final reportRow = await supabase
            .from('reports')
            .select('additional_info, status, created_at')
            .eq('reporter_id', userId)
            .eq('content_type', 'president_inquiry')
            .maybeSingle();

        if (reportRow != null && reportRow['additional_info'] != null) {
          final Map<String, dynamic> extra = jsonDecode(reportRow['additional_info'].toString());
          if (extra['messages'] is List) {
            final List<dynamic> remoteMsgs = extra['messages'];
            bool addedRemote = false;
            for (var rm in remoteMsgs) {
              final mid = rm['id']?.toString() ?? '';
              if (mid.isNotEmpty && !historyList.any((h) => h['id'] == mid)) {
                final isPres = rm['is_president'] == true || rm['sender_id'] == presidentId;
                historyList.insert(0, {
                  'id': mid,
                  'sender_id': isPres ? presidentId : userId,
                  'receiver_id': isPres ? userId : presidentId,
                  'message_text': rm['text'] ?? rm['message_text'] ?? '',
                  'message_type': rm['message_type'] ?? 'text',
                  'file_url': rm['file_url'],
                  'created_at': rm['created_at'] ?? DateTime.now().toIso8601String(),
                  'is_read': true,
                  'metadata': {
                    'is_official': isPres,
                    'is_president': isPres,
                    'golden_tick': isPres,
                    'admin_author': rm['admin_author'],
                  }
                });
                addedRemote = true;
              }
            }
            if (addedRemote) {
              await prefs.setString(key, jsonEncode(historyList));
            }
          }
        }
      } catch (e) {
        debugPrint('Error syncing President chat messages from Supabase: $e');
      }

      // Merge any broadcast announcements into user's chat history so all citizens receive presidential broadcasts
      final rawAnn = prefs.getString(_kPresidentAnnouncementsKey);
      if (rawAnn != null && rawAnn.isNotEmpty) {
        final List<dynamic> annList = jsonDecode(rawAnn);
        bool addedNew = false;
        for (var ann in annList) {
          final annId = ann['id']?.toString() ?? '';
          final alreadyInChat = historyList.any((m) => m['id'] == 'pres_broadcast_$annId');
          if (!alreadyInChat) {
            final mediaUrl = ann['media_url']?.toString();
            final hasMedia = mediaUrl != null && mediaUrl.isNotEmpty;
            historyList.insert(0, {
              'id': 'pres_broadcast_$annId',
              'sender_id': presidentId,
              'receiver_id': userId,
              'message_text': '🏛️ [PRESIDENTIAL BROADCAST: ${ann['title']}]\n\n${ann['content']}',
              'message_type': hasMedia ? 'image' : 'text',
              'file_url': mediaUrl,
              'created_at': ann['created_at'] ?? DateTime.now().toIso8601String(),
              'is_read': false,
              'metadata': {
                'is_official': true,
                'is_president': true,
                'golden_tick': true,
                'is_broadcast': true,
                'media_url': mediaUrl,
              }
            });
            addedNew = true;
          }
        }
        if (addedNew) {
          await prefs.setString(key, jsonEncode(historyList));
        }
      }

      return historyList;
    } catch (e) {
      debugPrint('Error getting President chat history: $e');
      return [];
    }
  }

  /// Get the last message preview for the conversation tile
  static Future<Map<String, dynamic>> getLastPresidentMessage(String userId) async {
    final history = await getPresidentChatHistory(userId);
    if (history.isEmpty) {
      return {
        'message_text': defaultWelcomeMessage,
        'created_at': DateTime.now(),
        'unread_count': 1,
        'has_unread': true,
      };
    }

    final lastMsg = history.first; // newest first
    final hasUnread = lastMsg['sender_id'] == presidentId && lastMsg['is_read'] == false;
    final unreadCount = history
        .where((m) => m['sender_id'] == presidentId && m['is_read'] == false)
        .length;

    return {
      'message_text': lastMsg['message_text']?.toString() ?? defaultWelcomeMessage,
      'created_at': DateTime.tryParse(lastMsg['created_at'].toString()) ?? DateTime.now(),
      'unread_count': unreadCount,
      'has_unread': hasUnread,
    };
  }

  /// Mark all messages from President as read for this user
  static Future<void> markPresidentChatAsRead(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_kPresidentChatPrefix$userId';
      final history = await getPresidentChatHistory(userId);

      bool changed = false;
      final updated = history.map((m) {
        if (m['sender_id'] == presidentId && m['is_read'] == false) {
          changed = true;
          return {...m, 'is_read': true};
        }
        return m;
      }).toList();

      if (changed) {
        await prefs.setString(key, jsonEncode(updated));
      }
    } catch (e) {
      debugPrint('Error marking President chat as read: $e');
    }
  }

  /// User sends a message, question, complaint, or feedback to The President
  static Future<Map<String, dynamic>> sendUserMessageToPresident({
    required String userId,
    required String messageText,
    String messageType = 'text',
    String? fileUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final now = DateTime.now();
    final messageId = 'pres_msg_${now.millisecondsSinceEpoch}';

    final message = {
      'id': messageId,
      'sender_id': userId,
      'receiver_id': presidentId,
      'message_text': messageText,
      'message_type': messageType,
      'file_url': fileUrl,
      'created_at': now.toIso8601String(),
      'is_read': true,
      'metadata': metadata ?? {},
    };

    // 1. Save locally in user's chat history
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kPresidentChatPrefix$userId';
    final history = await getPresidentChatHistory(userId);
    final updatedHistory = [message, ...history];
    await prefs.setString(key, jsonEncode(updatedHistory));

    // 2. Register inquiry in Master Inquiries List for Admin Panel
    await _recordMasterInquiry(
      userId: userId,
      lastMessage: messageText,
      timestamp: now,
    );

    // 3. Sync to Supabase reports table for cross-device Admin Panel support
    try {
      final supabase = SupaFlow.client;
      // Fetch user profile info with real name
      String userName = 'Citizen';
      String? userAvatar;
      int learningDay = 1;
      try {
        final prof = await supabase
            .from('profile')
            .select('name, first_name, profile_image_url, learning_day')
            .eq('user_id', userId)
            .maybeSingle();
        if (prof != null) {
          final n = (prof['name'] ?? prof['first_name'] ?? '').toString().trim();
          if (n.isNotEmpty) userName = n;
          userAvatar = prof['profile_image_url']?.toString();
          if (prof['learning_day'] != null) {
            learningDay = (prof['learning_day'] as num).toInt();
          }
        }
      } catch (_) {}

      // Check if report row already exists for this citizen inquiry
      final existingReport = await supabase
          .from('reports')
          .select('id, additional_info')
          .eq('reporter_id', userId)
          .eq('content_type', 'president_inquiry')
          .maybeSingle();

      List<dynamic> messageThread = [];
      if (existingReport != null && existingReport['additional_info'] != null) {
        try {
          final oldExtra = jsonDecode(existingReport['additional_info'].toString());
          if (oldExtra['messages'] is List) {
            messageThread = List.from(oldExtra['messages']);
          }
        } catch (_) {}
      }

      messageThread.add({
        'id': messageId,
        'sender_id': userId,
        'sender_name': userName,
        'sender_avatar': userAvatar,
        'is_president': false,
        'text': messageText,
        'message_type': messageType,
        'file_url': fileUrl,
        'created_at': now.toIso8601String(),
      });

      final additionalData = {
        'user_id': userId,
        'user_name': userName,
        'user_avatar': userAvatar,
        'learning_day': learningDay,
        'message_id': messageId,
        'updated_at': now.toIso8601String(),
        'messages': messageThread,
      };

      if (existingReport != null) {
        await supabase.from('reports').update({
          'description': messageText,
          'additional_info': jsonEncode(additionalData),
          'status': 'pending',
          'updated_at': now.toIso8601String(),
        }).eq('id', existingReport['id']);
      } else {
        await supabase.from('reports').insert({
          'reporter_id': userId,
          'content_type': 'president_inquiry',
          'content_id': messageId,
          'report_type': 'other', // President inquiries use 'other' — matches reports_report_type_check constraint
          'description': messageText,
          'additional_info': jsonEncode(additionalData),
          'status': 'pending',
          'created_at': now.toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error syncing President inquiry to Supabase: $e');
    }

    return message;
  }

  /// Admin sends a manual response to a user as The President
  static Future<Map<String, dynamic>> sendPresidentReplyToUser({
    required String targetUserId,
    required String replyText,
    String? adminName,
  }) async {
    final now = DateTime.now();
    final messageId = 'pres_reply_${now.millisecondsSinceEpoch}';

    final reply = {
      'id': messageId,
      'sender_id': presidentId,
      'receiver_id': targetUserId,
      'message_text': replyText,
      'message_type': 'text',
      'created_at': now.toIso8601String(),
      'is_read': false,
      'metadata': {
        'is_official': true,
        'is_president': true,
        'golden_tick': true,
        'admin_author': adminName ?? 'Super Admin',
      },
    };

    // 1. Save in user's chat history locally (for when running on same device)
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kPresidentChatPrefix$targetUserId';
    final history = await getPresidentChatHistory(targetUserId);
    final updated = [reply, ...history];
    await prefs.setString(key, jsonEncode(updated));

    // 2. Update master inquiries status to replied locally
    await _markMasterInquiryReplied(targetUserId, replyText);

    // 3. Update Supabase reports table so citizen receives it immediately across devices
    try {
      final supabase = SupaFlow.client;
      final existingReport = await supabase
          .from('reports')
          .select('id, additional_info')
          .eq('reporter_id', targetUserId)
          .eq('content_type', 'president_inquiry')
          .maybeSingle();

      if (existingReport != null) {
        List<dynamic> thread = [];
        Map<String, dynamic> extra = {};
        if (existingReport['additional_info'] != null) {
          try {
            extra = jsonDecode(existingReport['additional_info'].toString());
            if (extra['messages'] is List) {
              thread = List.from(extra['messages']);
            }
          } catch (_) {}
        }

        thread.add({
          'id': messageId,
          'sender_id': presidentId,
          'sender_name': 'The President',
          'is_president': true,
          'golden_tick': true,
          'text': replyText,
          'message_type': 'text',
          'created_at': now.toIso8601String(),
          'admin_author': adminName ?? 'Presidential Desk',
        });

        extra['messages'] = thread;
        extra['last_reply'] = replyText;
        extra['last_reply_at'] = now.toIso8601String();

        await supabase.from('reports').update({
          'status': 'resolved',
          'additional_info': jsonEncode(extra),
          'updated_at': now.toIso8601String(),
        }).eq('id', existingReport['id']);
      }
    } catch (e) {
      debugPrint('Error updating inquiry in Supabase: $e');
    }

    return reply;
  }

  /// Automated Citadel 24-Hour Residency Protection Alert
  static Future<void> notifyPresidentialProtection(
    String targetUserId, {
    int hours = 24,
    String? reason,
  }) async {
    final protectionMessage =
        '🛡️ PRESIDENTIAL PROTECTION NOTICE:\n'
        'Following recent combat activity, your Citadel is officially sheltered under the President\'s Residency Guard for the next $hours hours!\n\n'
        '• Raids & Attacks: BLOCKED\n'
        '• Status: Active Residency Protection\n'
        '• Presidential Seal of Security: APPLIED 🏅\n\n'
        'Use this time safely to practice your English tasks and fortify your defenses!';

    await sendPresidentReplyToUser(
      targetUserId: targetUserId,
      replyText: protectionMessage,
      adminName: 'Presidential Automated Defense',
    );
  }

  /// Post an official President Vibe (Status/Story) with Golden Glow
  static Future<Map<String, dynamic>> postPresidentVibe({
    required String caption,
    String? mediaUrl,
    String mediaType = 'text',
    int duration = 10,
  }) async {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 24));
    final vibeId = 'pres_vibe_${now.millisecondsSinceEpoch}';

    final vibe = {
      'id': vibeId,
      'user_id': presidentId,
      'profile_id': presidentId,
      'media_type': mediaType,
      'media_url': mediaUrl ?? '',
      'caption': caption,
      'duration': duration,
      'created_at': now.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_active': true,
      'views_count': 42,
      'profile': {
        'id': presidentId,
        'name': presidentName,
        'profile_image_url': presidentAvatarUrl,
        'is_president': true,
        'golden_tick': true,
      },
    };

    // 1. Local cache
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPresidentVibesKey);
    List<dynamic> list = raw != null && raw.isNotEmpty ? jsonDecode(raw) : [];
    list.insert(0, vibe);
    await prefs.setString(_kPresidentVibesKey, jsonEncode(list));

    // 2. Sync to Supabase statuses table so all users across the world see it in their Vibes feed!
    try {
      final supabase = SupaFlow.client;
      final myUser = supabase.auth.currentUser;
      if (myUser != null) {
        String? profileId;
        try {
          final pRes = await supabase
              .from('profile')
              .select('id')
              .eq('user_id', myUser.id)
              .maybeSingle();
          if (pRes != null) profileId = pRes['id']?.toString();
        } catch (_) {}

        await supabase.from('statuses').insert({
          'user_id': myUser.id,
          'profile_id': profileId ?? myUser.id,
          'media_type': mediaType,
          'media_url': mediaUrl ?? '',
          'caption': caption,
          'duration': duration,
          'expires_at': expiresAt.toIso8601String(),
          'is_active': true,
          'metadata': {
            'is_president': true,
            'golden_tick': true,
            'president_title': 'The President of Pocket World',
            'president_name': presidentName,
          },
        });
      }
    } catch (e) {
      debugPrint('Error inserting President Vibe into Supabase: $e');
    }

    return vibe;
  }

  /// Retrieve active (non-expired) President Vibes
  static Future<List<Map<String, dynamic>>> getActivePresidentVibes() async {
    final List<Map<String, dynamic>> allVibes = [];

    // 1. Fetch from Supabase statuses table
    try {
      final supabase = SupaFlow.client;
      final res = await supabase
          .from('statuses')
          .select('*, profile:profile_id(id, name, profile_image_url)')
          .eq('is_active', true)
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      for (var row in res) {
        final meta = row['metadata'] is Map ? row['metadata'] as Map : {};
        if (meta['is_president'] == true || row['user_id']?.toString() == presidentId) {
          allVibes.add({
            'id': row['id']?.toString(),
            'user_id': presidentId,
            'profile_id': presidentId,
            'media_type': row['media_type'] ?? 'text',
            'media_url': row['media_url'] ?? '',
            'caption': row['caption'] ?? '',
            'duration': row['duration'] ?? 10,
            'created_at': row['created_at'],
            'expires_at': row['expires_at'],
            'is_active': true,
            'views_count': row['views_count'] ?? 100,
            'profile': {
              'id': presidentId,
              'name': presidentName,
              'profile_image_url': presidentAvatarUrl,
              'is_president': true,
              'golden_tick': true,
            },
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting President vibes from Supabase: $e');
    }

    // 2. Merge local vibes
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPresidentVibesKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        final now = DateTime.now();
        for (var v in list) {
          final expStr = v['expires_at']?.toString();
          if (expStr != null) {
            final exp = DateTime.tryParse(expStr);
            if (exp != null && exp.isBefore(now)) continue;
          }
          if (!allVibes.any((ev) => ev['caption'] == v['caption'])) {
            allVibes.add(Map<String, dynamic>.from(v));
          }
        }
      }
    } catch (_) {}

    if (allVibes.isEmpty) {
      return [
        {
          'id': 'pres_initial_vibe',
          'user_id': presidentId,
          'profile_id': presidentId,
          'media_type': 'text',
          'media_url': '',
          'caption':
              '🏛️ Poket World State Address:\n"English is your passport to the world. Speak with confidence every single day!" — The President 🌟',
          'duration': 8,
          'created_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          'expires_at': DateTime.now().add(const Duration(hours: 23)).toIso8601String(),
          'is_active': true,
          'views_count': 158,
          'profile': {
            'id': presidentId,
            'name': presidentName,
            'profile_image_url': presidentAvatarUrl,
            'is_president': true,
            'golden_tick': true,
          },
        }
      ];
    }

    return allVibes;
  }

  /// Broadcast an official Presidential Announcement / House Ad to all citizens
  static Future<void> broadcastAnnouncement({
    required String title,
    required String content,
    String? mediaUrl,
    String? priority = 'high',
  }) async {
    final now = DateTime.now();

    // 1. Store in local announcements
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPresidentAnnouncementsKey);
    List<dynamic> list = raw != null && raw.isNotEmpty ? jsonDecode(raw) : [];
    list.insert(0, {
      'id': 'ann_${now.millisecondsSinceEpoch}',
      'title': title,
      'content': content,
      'media_url': mediaUrl,
      'priority': priority,
      'created_at': now.toIso8601String(),
    });
    await prefs.setString(_kPresidentAnnouncementsKey, jsonEncode(list));

    // 2. Sync to Supabase announcements table
    try {
      final supabase = SupaFlow.client;
      await supabase.from('announcements').insert({
        'title': '🏛️ [Presidential Decree] $title',
        'content': content,
        if (mediaUrl != null && mediaUrl.isNotEmpty) 'media_url': mediaUrl,
        'priority': priority ?? 'high',
        'created_at': now.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error broadcasting announcement to Supabase: $e');
    }
  }

  /// Get all user inquiries for Admin Panel President Desk with real citizen profile details
  static Future<List<Map<String, dynamic>>> getAdminInquiriesList() async {
    final List<Map<String, dynamic>> inquiries = [];

    // 1. Fetch from Supabase reports table (both direct inquiries and all citizen reports)
    try {
      final supabase = SupaFlow.client;
      final res = await supabase
          .from('reports')
          .select('*')
          .order('created_at', ascending: false)
          .limit(100);

      // Collect all reporter IDs to batch fetch real citizen profiles
      final List<String> reporterIds = [];
      for (var row in res) {
        final rId = (row['reporter_id'] ?? '').toString();
        if (rId.isNotEmpty) reporterIds.add(rId);
      }

      Map<String, Map<String, dynamic>> profileMap = {};
      if (reporterIds.isNotEmpty) {
        try {
          final profs = await supabase
              .from('profile')
              .select('user_id, name, first_name, profile_image_url, learning_day, english_level')
              .inFilter('user_id', reporterIds.toSet().toList());
          for (var p in profs) {
            profileMap[p['user_id'].toString()] = p;
          }
        } catch (e) {
          debugPrint('Error batch-fetching citizen profiles: $e');
        }
      }

      for (var row in res) {
        Map<String, dynamic> extra = {};
        if (row['additional_info'] != null) {
          try {
            extra = jsonDecode(row['additional_info'].toString());
          } catch (_) {}
        }

        final isGeneralReport = row['content_type'] != 'president_inquiry';
        final desc = row['description'] ?? row['reason'] ?? '';
        final reporterId = (row['reporter_id'] ?? '').toString();
        final prof = profileMap[reporterId];

        String realName = '';
        if (prof != null) {
          realName = (prof['name'] ?? prof['first_name'] ?? '').toString().trim();
        }
        if (realName.isEmpty) {
          realName = (extra['user_name'] ?? '').toString().trim();
        }
        if (realName.isEmpty || realName == 'Citizen' || realName.startsWith('Citizen (')) {
          realName = reporterId.length > 5 ? 'Citizen ${reporterId.substring(0, 5)}' : 'Citizen';
        }

        final avatarUrl = prof?['profile_image_url'] ?? extra['user_avatar'];
        final day = prof?['learning_day'] ?? extra['learning_day'] ?? 1;
        final messages = (extra['messages'] is List)
            ? List<Map<String, dynamic>>.from(extra['messages'].map((m) => Map<String, dynamic>.from(m)))
            : <Map<String, dynamic>>[];

        inquiries.add({
          'id': row['id']?.toString(),
          'user_id': reporterId,
          'user_name': realName,
          'user_avatar': avatarUrl,
          'learning_day': day,
          'english_level': prof?['english_level'],
          'last_message': isGeneralReport ? '⚠️ [REPORT: ${row['report_type'] ?? 'Citizen Report'}] $desc' : desc,
          'report_type': row['report_type'] ?? (isGeneralReport ? 'citizen_report' : 'doubt'),
          'status': row['status'] ?? 'pending',
          'created_at': row['created_at'],
          'is_general_report': isGeneralReport,
          'messages': messages,
          'report_id': row['id']?.toString(),
        });
      }
    } catch (e) {
      debugPrint('Error fetching President inquiries/reports from Supabase: $e');
    }

    // 2. Fetch local inquiries from SharedPreferences as fallback/merge
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPresidentInquiriesMasterKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> localList = jsonDecode(raw);
        for (var item in localList) {
          final uid = item['user_id'];
          if (!inquiries.any((q) => q['user_id'] == uid)) {
            inquiries.add(Map<String, dynamic>.from(item));
          }
        }
      }
    } catch (_) {}

    return inquiries;
  }

  // --- Internal Helpers ---

  static Future<void> _recordMasterInquiry({
    required String userId,
    required String lastMessage,
    required DateTime timestamp,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPresidentInquiriesMasterKey);
      List<dynamic> list = raw != null && raw.isNotEmpty ? jsonDecode(raw) : [];

      final existingIndex = list.indexWhere((i) => i['user_id'] == userId);
      final inquiryData = {
        'user_id': userId,
        'user_name': 'Citizen ${userId.length > 5 ? userId.substring(0, 5) : userId}',
        'last_message': lastMessage,
        'status': 'pending',
        'created_at': timestamp.toIso8601String(),
        'report_type': _categorizeInquiry(lastMessage),
      };

      if (existingIndex != -1) {
        list[existingIndex] = inquiryData;
      } else {
        list.insert(0, inquiryData);
      }

      await prefs.setString(_kPresidentInquiriesMasterKey, jsonEncode(list));
    } catch (e) {
      debugPrint('Error recording master inquiry: $e');
    }
  }

  static Future<void> _markMasterInquiryReplied(String userId, String reply) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPresidentInquiriesMasterKey);
      if (raw == null || raw.isEmpty) return;

      List<dynamic> list = jsonDecode(raw);
      final index = list.indexWhere((i) => i['user_id'] == userId);
      if (index != -1) {
        list[index]['status'] = 'resolved';
        list[index]['last_reply'] = reply;
        list[index]['replied_at'] = DateTime.now().toIso8601String();
        await prefs.setString(_kPresidentInquiriesMasterKey, jsonEncode(list));
      }
    } catch (_) {}
  }

  static String _categorizeInquiry(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('complaint') || lower.contains('cheat') || lower.contains('report') || lower.contains('bug') || lower.contains('issue')) {
      return 'complaint';
    }
    if (lower.contains('doubt') || lower.contains('question') || lower.contains('how to') || lower.contains('meaning')) {
      return 'doubt';
    }
    if (lower.contains('attack') || lower.contains('citadel') || lower.contains('protect') || lower.contains('shield')) {
      return 'citadel_protection';
    }
    return 'general';
  }

  static const String _kPresidentCitadelConqueredPrefix = 'presidential_citadel_conquered_';

  /// Check if the user has conquered the Level 91 Presidential Palace Citadel
  static Future<bool> hasConqueredPresidentialCitadel([String? userId]) async {
    try {
      final uid = userId ?? (SupaFlow.client.auth.currentUser?.id ?? '');
      if (uid.isEmpty) return false;
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_kPresidentCitadelConqueredPrefix$uid') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Mark Level 91 Presidential Citadel conquered after surviving the gauntlet
  static Future<void> markPresidentialCitadelConquered([String? userId]) async {
    try {
      final uid = userId ?? (SupaFlow.client.auth.currentUser?.id ?? '');
      if (uid.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_kPresidentCitadelConqueredPrefix$uid', true);
    } catch (_) {}
  }
}
