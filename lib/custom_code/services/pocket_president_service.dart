import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pocket_mates_app/custom_code/services/contacts_name_service.dart';
import 'package:pocket_mates_app/custom_code/services/local_sync_server.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_release_service.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/services/push_notification_service.dart';
import 'package:pocket_mates_app/custom_code/services/in_app_notification_service.dart';
import 'package:pocket_mates_app/flutter_flow/nav/nav.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';

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
      'Welcome to Poket Mates! 🏛️🌟 I am the President of Poket World. You are officially an honored member of our global English Club!\n\n'
      '📌 Official Community Channels:\n\n'
      '💬 Official WhatsApp Community (Join for daily syllabus updates, tips & club announcements):\n'
      '👉 https://chat.whatsapp.com/HqRgqeHEQVm6LoZ7L8dO6r\n\n'
      '📸 Official Instagram (Follow for daily reels, learning tips & direct DM support/doubts):\n'
      '👉 https://www.instagram.com/poketmates.app?vrfl=NTc2MWhma2p1NzF2&utm_source=qr\n\n'
      'If you have any doubts, feedback, questions, or need assistance, message me here anytime. You are under 24/7 presidential care!';

  // SharedPreferences Keys
  static const String _kPresidentChatPrefix = 'president_chat_';
  static const String _kPresidentInquiriesMasterKey =
      'president_inquiries_master';
  static const String _kPresidentVibesKey = 'president_vibes_store';
  static const String _kPresidentAnnouncementsKey =
      'president_announcements_store';

  static bool isPresidentId(String id) {
    final lower = id.toLowerCase().trim();
    return lower == presidentId ||
        lower == 'pocket_president' ||
        lower == 'president' ||
        lower == 'president_of_pocket_world' ||
        lower == 'pres_official';
  }

  /// Persist President chat messages across both SharedPreferences and LocalSyncServer
  static Future<void> savePresidentChatMessages(
      String userId, List<dynamic> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_kPresidentChatPrefix$userId';
      final List<Map<String, dynamic>> cleanList = [];
      for (final m in messages) {
        if (m is Map) {
          final map = Map<String, dynamic>.from(m);
          if (map['created_at'] is DateTime) {
            map['created_at'] =
                (map['created_at'] as DateTime).toIso8601String();
          }
          cleanList.add(map);
        }
      }
      await prefs.setString(key, jsonEncode(cleanList));

      // Also persist to LocalSyncServer both with and without prefix
      unawaited(
          LocalSyncServer().saveMessages(userId, 'p:$presidentId', cleanList));
      unawaited(LocalSyncServer().saveMessages(userId, presidentId, cleanList));
    } catch (e) {
      debugPrint('Error saving President chat messages: $e');
    }
  }

  /// Fetch full chat history for a specific user with The President
  static Future<List<Map<String, dynamic>>> getPresidentChatHistory(
      String userId) async {
    List<Map<String, dynamic>> historyList = [];
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kPresidentChatPrefix$userId';

    try {
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        try {
          final List<dynamic> decoded = jsonDecode(raw);
          historyList = decoded.map((e) {
            final m = Map<String, dynamic>.from(e);
            if (m['created_at'] is DateTime) {
              m['created_at'] = (m['created_at'] as DateTime).toIso8601String();
            }
            return m;
          }).toList();
        } catch (_) {}
      }

      // Also recover any messages saved in LocalSyncServer (fail-safe)
      try {
        final cachedFromSync =
            LocalSyncServer().getCachedMessages(userId, 'p:$presidentId');
        for (final item in cachedFromSync) {
          Map<String, dynamic>? map;
          if (item is Map) {
            map = Map<String, dynamic>.from(item);
          } else {
            try {
              map = Map<String, dynamic>.from((item as dynamic).toJson());
            } catch (_) {}
          }
          if (map == null) continue;
          final mid = map['id']?.toString() ?? '';
          if (mid.isNotEmpty && !historyList.any((h) => h['id'] == mid)) {
            if (map['created_at'] is DateTime) {
              map['created_at'] =
                  (map['created_at'] as DateTime).toIso8601String();
            }
            historyList.add(map);
          }
        }
      } catch (_) {}

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
          final Map<String, dynamic> extra =
              jsonDecode(reportRow['additional_info'].toString());
          if (extra['messages'] is List) {
            final List<dynamic> remoteMsgs = extra['messages'];
            bool addedRemote = false;
            for (var rm in remoteMsgs) {
              final mid = rm['id']?.toString() ?? '';
              if (mid.isNotEmpty && !historyList.any((h) => h['id'] == mid)) {
                final isPres = rm['is_president'] == true ||
                    rm['sender_id'] == presidentId;
                historyList.add({
                  'id': mid,
                  'sender_id': isPres ? presidentId : userId,
                  'receiver_id': isPres ? userId : presidentId,
                  'message_text': rm['text'] ?? rm['message_text'] ?? '',
                  'message_type': rm['message_type'] ?? 'text',
                  'file_url': rm['file_url'],
                  'created_at':
                      rm['created_at'] ?? DateTime.now().toIso8601String(),
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
              historyList.sort((a, b) {
                final tA =
                    DateTime.tryParse(a['created_at']?.toString() ?? '') ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                final tB =
                    DateTime.tryParse(b['created_at']?.toString() ?? '') ??
                        DateTime.fromMillisecondsSinceEpoch(0);
                return tB.compareTo(tA);
              });
              await prefs.setString(key, jsonEncode(historyList));
            }
          }
        }
      } catch (e) {
        debugPrint('Error syncing President chat messages from Supabase: $e');
      }

      // Merge any broadcast announcements into user's chat history safely
      try {
        final rawAnn = prefs.getString(_kPresidentAnnouncementsKey);
        if (rawAnn != null && rawAnn.isNotEmpty) {
          final List<dynamic> annList = jsonDecode(rawAnn);
          bool addedNew = false;
          for (var ann in annList) {
            final annId = ann['id']?.toString() ?? '';
            final alreadyInChat =
                historyList.any((m) => m['id'] == 'pres_broadcast_$annId');
            if (!alreadyInChat) {
              final mediaUrl = ann['media_url']?.toString();
              final hasMedia = mediaUrl != null && mediaUrl.isNotEmpty;
              historyList.add({
                'id': 'pres_broadcast_$annId',
                'sender_id': presidentId,
                'receiver_id': userId,
                'message_text':
                    '🏛️ [PRESIDENTIAL BROADCAST: ${ann['title']}]\n\n${ann['content']}',
                'message_type': hasMedia ? 'image' : 'text',
                'file_url': mediaUrl,
                'created_at':
                    ann['created_at'] ?? DateTime.now().toIso8601String(),
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
            historyList.sort((a, b) {
              final tA = DateTime.tryParse(a['created_at']?.toString() ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              final tB = DateTime.tryParse(b['created_at']?.toString() ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0);
              return tB.compareTo(tA);
            });
            await prefs.setString(key, jsonEncode(historyList));
          }
        }
      } catch (_) {}

      if (historyList.isEmpty) {
        final welcomeMsg = {
          'id': 'pres_welcome_$userId',
          'sender_id': presidentId,
          'receiver_id': userId,
          'message_text': defaultWelcomeMessage,
          'message_type': 'text',
          'created_at': DateTime.now()
              .subtract(const Duration(minutes: 5))
              .toIso8601String(),
          'is_read': false,
          'metadata': {
            'is_official': true,
            'is_president': true,
            'golden_tick': true,
          }
        };
        historyList = [welcomeMsg];
        await prefs.setString(key, jsonEncode(historyList));
      } else {
        // Guarantee sorted descending by timestamp
        historyList.sort((a, b) {
          final tA = DateTime.tryParse(a['created_at']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final tB = DateTime.tryParse(b['created_at']?.toString() ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return tB.compareTo(tA);
        });
      }

      return historyList;
    } catch (e) {
      debugPrint('Error getting President chat history: $e');
      return historyList.isNotEmpty ? historyList : [];
    }
  }

  /// Get the last message preview for the conversation tile
  static Future<Map<String, dynamic>> getLastPresidentMessage(
      String userId) async {
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
    final hasUnread =
        lastMsg['sender_id'] == presidentId && lastMsg['is_read'] == false;
    final unreadCount = history
        .where((m) => m['sender_id'] == presidentId && m['is_read'] == false)
        .length;

    return {
      'message_text':
          lastMsg['message_text']?.toString() ?? defaultWelcomeMessage,
      'created_at':
          DateTime.tryParse(lastMsg['created_at'].toString()) ?? DateTime.now(),
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
    String? existingMessageId,
  }) async {
    final now = DateTime.now();
    final messageId =
        existingMessageId ?? 'pres_msg_${now.millisecondsSinceEpoch}';

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

    // 1. Save locally in user's chat history across both SharedPreferences & LocalSyncServer
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kPresidentChatPrefix$userId';
    final history = await getPresidentChatHistory(userId);
    final existingIdx = history.indexWhere((m) => m['id'] == messageId);
    final List<Map<String, dynamic>> updatedHistory;
    if (existingIdx != -1) {
      updatedHistory = List<Map<String, dynamic>>.from(history);
      updatedHistory[existingIdx] = message;
    } else {
      updatedHistory = [message, ...history];
    }
    await prefs.setString(key, jsonEncode(updatedHistory));
    unawaited(LocalSyncServer()
        .saveMessages(userId, 'p:$presidentId', updatedHistory));
    unawaited(
        LocalSyncServer().saveMessages(userId, presidentId, updatedHistory));

    // 2. Fetch sender profile details & auth credentials to enrich report metadata
    String userName =
        ContactsNameService().getDisplayName(userId: userId, fallbackName: '');
    String? userAvatar;
    int learningDay = 1;
    String userEmail = '';
    String userPhone = '';
    String planet = 'Earth';
    String plot = '';

    try {
      final prof = await SupaFlow.client
          .from('profile')
          .select('*')
          .or('user_id.eq.$userId,id.eq.$userId')
          .maybeSingle();
      if (prof != null) {
        final n = (prof['name'] ?? prof['shop_name'] ?? '').toString().trim();
        if (n.isNotEmpty) userName = n;
        userAvatar = prof['profile_image_url']?.toString();
        if (prof['day'] != null) {
          learningDay = (prof['day'] as num).toInt();
        }
        final c = (prof['country'] ?? '').toString().trim();
        if (c.isNotEmpty) planet = c;
        final pNo = (prof['phone_no'] ?? '').toString().trim();
        if (pNo.isNotEmpty) userPhone = pNo;
        final b = (prof['bio'] ?? '').toString().trim();
        if (b.contains('Plot')) plot = b;
      }
    } catch (_) {}

    try {
      final userRow = await SupaFlow.client
          .from('users')
          .select('id, email')
          .eq('id', userId)
          .maybeSingle();
      if (userRow != null && userRow['email'] != null) {
        userEmail = userRow['email'].toString().trim();
      }
    } catch (_) {}

    if (userName.isEmpty || userName == 'User' || userName == 'Citizen') {
      if (userEmail.isNotEmpty) {
        userName =
            userEmail.contains('@') ? userEmail.split('@').first : userEmail;
      } else if (userId.length > 6) {
        userName = 'Learner ${userId.substring(0, 6)}';
      } else {
        userName = 'Learner';
      }
    }

    // 3. Register inquiry in Master Inquiries List for Admin Panel
    await _recordMasterInquiry(
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      learningDay: learningDay,
      lastMessage: messageText,
      timestamp: now,
    );

    // 4. Sync to Supabase reports table for cross-device Admin Panel support
    try {
      final supabase = SupaFlow.client;

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
          final oldExtra =
              jsonDecode(existingReport['additional_info'].toString());
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
        'user_email': userEmail,
        'user_phone': userPhone,
        'planet': planet,
        'plot': plot,
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
          'report_type':
              'other', // President inquiries use 'other' — matches reports_report_type_check constraint
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
  /// Admin sends a manual or automated response to a user as The President
  static Future<Map<String, dynamic>> sendPresidentReplyToUser({
    required String targetUserId,
    required String replyText,
    String messageType = 'text',
    String? fileUrl,
    String? adminName,
    String? existingMessageId,
  }) async {
    final now = DateTime.now();
    final messageId =
        existingMessageId ?? 'pres_reply_${now.millisecondsSinceEpoch}';

    final reply = {
      'id': messageId,
      'sender_id': presidentId,
      'receiver_id': targetUserId,
      'message_text': replyText,
      'message_type': messageType,
      'file_url': fileUrl,
      'created_at': now.toIso8601String(),
      'is_read': false,
      'metadata': {
        'is_official': true,
        'is_president': true,
        'golden_tick': true,
        'admin_author': adminName ?? 'Super Admin',
        if (fileUrl != null) 'file_url': fileUrl,
      },
    };

    // 1. Save in user's chat history locally across both SharedPreferences & LocalSyncServer
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kPresidentChatPrefix$targetUserId';
    final history = await getPresidentChatHistory(targetUserId);
    final existingIdx = history.indexWhere((m) => m['id'] == messageId);
    final List<Map<String, dynamic>> updated;
    if (existingIdx != -1) {
      updated = List<Map<String, dynamic>>.from(history);
      updated[existingIdx] = reply;
    } else {
      updated = [reply, ...history];
    }
    await prefs.setString(key, jsonEncode(updated));
    unawaited(LocalSyncServer()
        .saveMessages(targetUserId, 'p:$presidentId', updated));
    unawaited(
        LocalSyncServer().saveMessages(targetUserId, presidentId, updated));

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
          'message_type': messageType,
          'file_url': fileUrl,
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

    // 4. Dispatch in-app notification & push notification
    try {
      InAppNotificationService.show(
        title: '🏛️ The President of Pocket World',
        message: messageType == 'image'
            ? 'Sent you an educational card 📜'
            : replyText,
      );
    } catch (_) {}

    try {
      final supabase = SupaFlow.client;
      await supabase.functions.invoke('send-push-notification', body: {
        'action': 'individual',
        'user_id': targetUserId,
        'title': '🏛️ Presidential Office Message',
        'body': replyText.length > 100
            ? '${replyText.substring(0, 97)}...'
            : replyText,
      });
    } catch (_) {}

    return reply;
  }

  /// Automated Citadel 6-Hour Police Protection Alert
  static Future<void> notifyPresidentialProtection(
    String targetUserId, {
    int hours = 6,
    String? reason,
  }) async {
    final protectionMessage = '👮‍♂️ POLICE PROTECTION NOTICE:\n'
        'Following recent combat activity, your house is officially sheltered under Police Protection for the next $hours hours!\n\n'
        '• Raids & Attacks: BLOCKED\n'
        '• Status: Active Police Protection\n'
        '• Security: APPLIED 🚨\n\n'
        'Use this time safely to practice your English tasks and fortify your defenses!';

    await sendPresidentReplyToUser(
      targetUserId: targetUserId,
      replyText: protectionMessage,
      adminName: 'Presidential Automated Defense',
    );
  }

  /// 📢 Send Official President App Update Announcement to an individual citizen's 1-on-1 President chat
  /// Checks for duplicate dispatch prevention using unique platform & release key
  static Future<void> sendPresidentUpdateMessage({
    required String targetUserId,
    required String platform, // 'Android' or 'iOS'
    required String version,
    required String title,
    required String description,
    List<String> features = const [],
    String? storeUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final releaseKey =
        'pres_app_update_sent_${platform.toLowerCase()}_${version.replaceAll('.', '_')}_$targetUserId';
    if (prefs.getBool(releaseKey) == true) {
      return; // Deduplication: already sent to this user!
    }

    final buffer = StringBuffer();
    buffer.writeln('🏛️ President – POKET Update Announcement');
    buffer.writeln();
    buffer.writeln('Hello!');
    buffer.writeln();
    buffer.writeln('A new POKET update is now available for $platform.');
    buffer.writeln();
    buffer.writeln(
        '📌 Version $version – ${title.isNotEmpty ? title : "What\'s New"}');
    buffer.writeln();
    if (description.isNotEmpty) {
      buffer.writeln(description);
      buffer.writeln();
    }
    if (features.isNotEmpty) {
      buffer.writeln('What\'s New:');
      for (int i = 0; i < features.length; i++) {
        buffer.writeln('${i + 1}. ${features[i]}');
      }
      buffer.writeln();
    }
    buffer.writeln(
        'Thank you for being part of POKET! Speak with confidence every single day! 🌟');

    await sendPresidentReplyToUser(
      targetUserId: targetUserId,
      replyText: buffer.toString().trim(),
      adminName: 'Presidential Office',
    );

    await prefs.setBool(releaseKey, true);
  }

  /// 🚀 Automatically delivers release notes & community links for current installed build
  /// into user's 1-on-1 President chat upon first launch of that version!
  static Future<void> checkAndDeliverInstalledReleaseNotes(
      String userId) async {
    try {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
      final platform = Platform.isIOS ? 'iOS' : 'Android';

      final prefs = await SharedPreferences.getInstance();
      final deliveredKey =
          'pres_release_delivered_v_${currentVersion}_${currentBuild}_$userId';
      if (prefs.getBool(deliveredKey) == true) {
        return; // Already delivered for this installed build!
      }

      // Fetch active production release or remote release notes
      final activeRelease =
          await PocketReleaseService.fetchActiveProductionRelease(
              platform.toLowerCase());

      final buffer = StringBuffer();
      buffer.writeln(
          '🏛️ Official Presidential Briefing – What\'s New in $platform v$currentVersion');
      buffer.writeln();
      buffer.writeln(
          'Greetings, citizen! 🌟 The Presidential Office is proud to announce our latest update:');
      buffer.writeln();

      if (activeRelease != null &&
          activeRelease.releaseNotes.trim().isNotEmpty) {
        buffer.writeln(activeRelease.releaseNotes.trim());
      } else {
        buffer.writeln(
            '• Daily syllabus updates and interactive learning journey enhancements.\n'
            '• Citadel homestead optimizations and real-time multiplayer connections.\n'
            '• AdMob performance tuning, smoother native ads, and full-screen reel experiences.');
      }

      buffer.writeln();
      buffer.writeln(
          '👥 Stay connected with our official English Club Community:');
      buffer.writeln();
      buffer.writeln(
          '💬 Official WhatsApp Community (Daily tips & syllabus updates):');
      buffer.writeln('👉 https://chat.whatsapp.com/HqRgqeHEQVm6LoZ7L8dO6r');
      buffer.writeln();
      buffer.writeln(
          '📸 Official Instagram (Follow for reels, daily tips & DM support):');
      buffer.writeln(
          '👉 https://www.instagram.com/poketmates.app?vrfl=NTc2MWhma2p1NzF2&utm_source=qr');
      buffer.writeln();
      buffer.writeln(
          'If you have any doubts, questions, or suggestions, message me here anytime. Speak with confidence!');

      await sendPresidentReplyToUser(
        targetUserId: userId,
        replyText: buffer.toString().trim(),
        adminName: 'Presidential Office',
      );

      await prefs.setBool(deliveredKey, true);
      debugPrint(
          'PocketPresidentService: Delivered v$currentVersion ($currentBuild) release notes to user $userId');
    } catch (e) {
      debugPrint(
          'PocketPresidentService: Error delivering installed release notes: $e');
    }
  }

  /// 🤖 Autonomous Robot / AI Presidential Response Generator
  /// Formulates deeply thankful, supportive, gentle English replies
  /// ensuring users feel valued, safe, and encouraged in their English journey.
  static Future<String> generatePresidentRobotReply({
    required String userMessage,
    String? userName,
    String? currentUserId,
  }) async {
    final clean = userMessage.trim().toLowerCase();
    final citizen =
        (userName != null && userName.isNotEmpty && userName != 'Citizen')
            ? userName
            : 'Citizen';

    // 1. Who are you / ആരാണ് താങ്കൾ? / Who is the President?
    if (clean.contains('who are you') ||
        clean.contains('who is president') ||
        clean.contains('identity') ||
        clean.contains('who r u') ||
        userMessage.contains('ആരാണ്')) {
      return "Thank you so much for asking, dear $citizen! 🌟 I am the President of Pocket World, but above all, I am your friend and your biggest supporter! Our entire team is here to stand by you, encourage you, and make sure you feel happy and confident speaking English every day. You are never alone here—we are one supportive team! How can I help you today? 💛";
    }

    // 2. What is your purpose / എന്താണ് ലക്ഷ്യം?
    if (clean.contains('purpose') ||
        clean.contains('what is your purpose') ||
        clean.contains('why president') ||
        clean.contains('what do you do') ||
        clean.contains('aim') ||
        userMessage.contains('ലക്ഷ്യം')) {
      return "Thank you for asking such a wonderful question, $citizen! 🌸 Our purpose is heartfelt and simple: to support you and cheer you on in your daily English speaking journey! We want you to speak without any fear or hesitation, celebrate your daily progress, protect your Citadel, and share helpful vocabulary cards with you. Our whole team is always here for you!";
    }

    // 3. Rules / പ്രസിഡന്റ് റൂൾസ് എന്തൊക്കെയാണ്?
    if (clean.contains('rule') ||
        clean.contains('rules') ||
        clean.contains('law') ||
        clean.contains('regulation') ||
        userMessage.contains('റൂൾ')) {
      return "Thank you for wanting to follow our community spirit, $citizen! 🤝 Here in Pocket World, our guidelines are based on kindness and courage:\n\n"
          "1. 🗣️ Speak with courage: Try speaking English every day—mistakes are just proof you are learning!\n"
          "2. 🛡️ Fair Citadel play: Protect your home with real, helpful English questions.\n"
          "3. 💛 Support each other: Be kind and encouraging to all fellow mates.\n"
          "4. 🌟 Daily joy: Enjoy your streak and be proud of every step you take!";
    }

    // 4. Citadel Attacks, Defense & Presidential Protection
    if (clean.contains('attack') ||
        clean.contains('citadel') ||
        clean.contains('shield') ||
        clean.contains('gate') ||
        clean.contains('defense') ||
        clean.contains('protect') ||
        userMessage.contains('അറ്റാക്ക്') ||
        userMessage.contains('പ്രൊട്ടക്ഷൻ')) {
      return "Thank you for checking in, dear $citizen! 🛡️ Don't worry at all—you are always safe with us! Every day of completed English learning strengthens your Citadel. And whenever an attack occurs, our Presidential Protection automatically shields your home for 6 hours so you can rest peacefully without stress. We've got your back! 🌟";
    }

    // 5. Complaints & Reports
    if (clean.contains('complaint') ||
        clean.contains('cheat') ||
        clean.contains('fake question') ||
        clean.contains('report') ||
        clean.contains('bug') ||
        clean.contains('issue') ||
        clean.contains('hacker')) {
      return "Thank you so much for bringing this to our attention, dear $citizen! 💛 Your feedback helps us make Pocket World better for everyone. Our support team is looking into this with the utmost care right now, and we promise to keep everything fair, safe, and pleasant for you!";
    }

    // 6. App doubts & How to use
    if (clean.contains('how to') ||
        clean.contains('doubt') ||
        clean.contains('what is') ||
        clean.contains('help') ||
        clean.contains('guide')) {
      if (clean.contains('level') ||
          clean.contains('score') ||
          clean.contains('points') ||
          clean.contains('rank')) {
        return "Thank you for asking, $citizen! 🌟 Your Pocket Score and level grow naturally each day as you practice speaking, defend your Citadel, and complete your daily missions. Take it one day at a time—you are doing wonderfully!";
      }
      if (clean.contains('mate') ||
          clean.contains('friend') ||
          clean.contains('chat')) {
        return "Thank you for reaching out, $citizen! 🤝 As the President, I am always connected with you right here. You can also chat with friendly mates in the English Hub or practice voice speaking anytime. We are all here supporting you!";
      }
      return "Thank you so much for asking, $citizen! 💛 Pocket World is designed to make speaking English natural, fun, and relaxing. Never worry about making mistakes—every sentence you try is a victory! Feel free to ask me anything anytime.";
    }

    // 7. Greetings
    if (clean.contains('hi') ||
        clean.contains('hello') ||
        clean.contains('hey') ||
        clean.contains('morning') ||
        clean.contains('evening') ||
        userMessage.contains('നമസ്കാരം')) {
      return "Hello and a warm welcome, dear $citizen! 🌸 Thank you so much for saying hi! How is your day going? Our team is so grateful to have you with us. How can I support your English practice today?";
    }

    // 8. Thanks & Appreciation
    if (clean.contains('thank') ||
        clean.contains('thx') ||
        clean.contains('super') ||
        clean.contains('great')) {
      return "Thank YOU so much, dear $citizen! 🌟 Having you in Pocket World brings us so much happiness. Keep smiling and speaking with confidence every day—our entire team is always cheering for you! 💛";
    }

    // 9. General encouraging reply
    return "Thank you so much for your message, dear $citizen! 🌸 Every single word you speak in English today brings you closer to your dreams. Remember, our whole team is right here with you, cheering you on every step of the way! Feel free to share your thoughts anytime.";
  }

  /// Log a reported defense question directly to the President Desk registry
  static Future<void> recordQuestionReportToPresident({
    required String reporterId,
    required String reporterName,
    required String houseId,
    required String houseOwnerName,
    required String questionText,
    required String reason,
    String? aiVerdictSummary,
  }) async {
    final now = DateTime.now();
    final reportSummary =
        '🚨 CITADEL DEFENSE QUESTION REPORT: "$questionText" from $houseOwnerName\'s Citadel ($houseId). Reason: $reason. ${aiVerdictSummary ?? ''}';

    await _recordMasterInquiry(
      userId: reporterId,
      userName: reporterName,
      lastMessage: reportSummary,
      timestamp: now,
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
        if (meta['is_president'] == true ||
            row['user_id']?.toString() == presidentId) {
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

    // Automatically append daily language-tailored English learning tips based on user's native language
    final lang = PocketLanguageService.currentLanguage.toLowerCase();
    String vocabTip;
    if (lang.contains('hindi')) {
      vocabTip =
          '🌟 President\'s Spoken English Tip 🏛️\n\nWord: "Persevere" (डटे रहना / लगातार प्रयास करना)\nMeaning: Keep going despite challenges.\nExample: "If you persevere with daily Poket Talk pacts, fluency comes naturally!" 👑';
    } else if (lang.contains('tamil')) {
      vocabTip =
          '🌟 President\'s Spoken English Tip 🏛️\n\nWord: "Persevere" (விடாமுயற்சி செய்)\nMeaning: Keep going despite challenges.\nExample: "If you persevere with daily Poket Talk pacts, fluency comes naturally!" 👑';
    } else {
      vocabTip =
          '🌟 President\'s Spoken English Tip 🏛️\n\nWord: "Persevere" (തുടർന്നുപ്രയത്നിക്കുക / വിട്ടുപിരിയാതിരിക്കുക)\nMeaning: Keep going despite challenges.\nExample: "If you persevere with daily Poket Talk pacts, fluency comes naturally!" 👑';
    }

    final dailyVibe = {
      'id': 'pres_daily_vocab_vibe',
      'user_id': presidentId,
      'profile_id': presidentId,
      'media_type': 'text',
      'media_url': '',
      'caption': vocabTip,
      'duration': 10,
      'created_at': DateTime.now()
          .subtract(const Duration(minutes: 30))
          .toIso8601String(),
      'expires_at':
          DateTime.now().add(const Duration(hours: 23)).toIso8601String(),
      'is_active': true,
      'views_count': 234,
      'profile': {
        'id': presidentId,
        'name': presidentName,
        'profile_image_url': presidentAvatarUrl,
        'is_president': true,
        'golden_tick': true,
      },
    };

    if (!allVibes.any((v) => v['caption'] == vocabTip)) {
      allVibes.insert(0, dailyVibe);
    }

    // 🏛️ Presidential App Feedback & Quality Improvement Story
    try {
      final prefs = await SharedPreferences.getInstance();
      String myUid = '';
      try {
        myUid = SupaFlow.client.auth.currentUser?.id ?? '';
      } catch (_) {}
      final lastFeedbackTs =
          prefs.getInt('president_last_feedback_ts_$myUid') ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      // Show feedback vibe periodically (if no feedback yet or at least 3 days since last feedback)
      final hasRecentFeedback =
          (nowMs - lastFeedbackTs < 3 * 24 * 60 * 60 * 1000);
      if (!hasRecentFeedback) {
        final feedbackVibe = {
          'id': 'pres_vibe_feedback_prompt',
          'user_id': presidentId,
          'profile_id': presidentId,
          'media_type': 'text',
          'media_url': '',
          'caption':
              '🏛️ Presidential Public Survey: Help Us Improve Poket Mates! 🌟\n\nHow can we improve the app quality and your English learning experience? Tap below or type your suggestions to share your feedback directly with The President! ✍️',
          'duration': 12,
          'created_at': DateTime.now()
              .subtract(const Duration(minutes: 15))
              .toIso8601String(),
          'expires_at':
              DateTime.now().add(const Duration(hours: 48)).toIso8601String(),
          'is_active': true,
          'views_count': 382,
          'is_feedback_vibe': true,
          'profile': {
            'id': presidentId,
            'name': presidentName,
            'profile_image_url': presidentAvatarUrl,
            'is_president': true,
            'golden_tick': true,
          },
        };
        if (!allVibes.any((v) => v['id'] == 'pres_vibe_feedback_prompt')) {
          allVibes.insert(0, feedbackVibe);
        }
      }
    } catch (_) {}

    if (allVibes.isEmpty) {
      return [
        dailyVibe,
        {
          'id': 'pres_initial_vibe',
          'user_id': presidentId,
          'profile_id': presidentId,
          'media_type': 'text',
          'media_url': '',
          'caption':
              '🏛️ Poket World State Address:\n"English is your passport to the world. Speak with confidence every single day!" — The President 🌟',
          'duration': 8,
          'created_at': DateTime.now()
              .subtract(const Duration(hours: 1))
              .toIso8601String(),
          'expires_at':
              DateTime.now().add(const Duration(hours: 23)).toIso8601String(),
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

  /// 📝 Submit citizen feedback & suggestions directly to the President
  static Future<void> submitCitizenFeedback({
    required String userId,
    required String feedback,
  }) async {
    final clean = feedback.trim();
    if (clean.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('president_feedback_given_$userId', true);
    await prefs.setInt('president_last_feedback_ts_$userId',
        DateTime.now().millisecondsSinceEpoch);

    // Save to Supabase feedback or citizen_reports table if available
    try {
      await SupaFlow.client.from('feedback').insert({
        'user_id': userId,
        'message': clean,
        'category': 'english_learning_quality',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}

    // Save user's feedback into President chat
    final userMsgId = 'pres_feedback_${DateTime.now().millisecondsSinceEpoch}';
    await sendUserMessageToPresident(
      userId: userId,
      messageText: '📝 [CITIZEN FEEDBACK & SUGGESTIONS]:\n$clean',
      messageType: 'text',
      existingMessageId: userMsgId,
      metadata: {
        'is_feedback': true,
        'feedback_text': clean,
      },
    );

    // Automatically send official presidential appreciation message back
    Future.delayed(const Duration(milliseconds: 900), () async {
      await sendPresidentReplyToUser(
        targetUserId: userId,
        replyText:
            'Thank you, Citizen! 🏛️ Your valuable feedback and suggestions have been officially registered at the Presidential Desk. Together, we are elevating Pocket World\'s English learning experience! 🌟✍️',
        adminName: 'Presidential Oversight',
      );
    });
  }

  /// 📩 If the citizen hasn't submitted feedback, gently drop a periodic check-in in their chat
  static Future<void> checkAndDeliverFeedbackPrompt(String userId) async {
    try {
      if (userId.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      final hasGivenFeedback =
          prefs.getBool('president_feedback_given_$userId') ?? false;
      if (hasGivenFeedback) return;

      final lastPromptTime =
          prefs.getInt('president_feedback_prompt_ts_$userId') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      // Send at most once every 3 days
      if (now - lastPromptTime < 3 * 24 * 60 * 60 * 1000) return;

      await prefs.setInt('president_feedback_prompt_ts_$userId', now);

      await sendPresidentReplyToUser(
        targetUserId: userId,
        replyText:
            'Greetings Citizen! 🏛️ The President\'s Office is dedicated to giving you the best English learning experience. How has your journey in Pocket World been so far? We would love to hear your thoughts or suggestions on app quality and English learning! ✍️🌟',
        adminName: 'Presidential Office',
      );
    } catch (e) {
      debugPrint('Error checking feedback prompt: $e');
    }
  }

  /// 🎂 User Birthday Celebration & Presidential Proclamation
  /// If today matches citizen's Date of Birth:
  /// 1. The President sends a personalized royal birthday greeting in President Chat.
  /// 2. The President broadcasts an official public Birthday Vibe for the citizen.
  /// 3. Sends instant celebratory push & in-app notification to the citizen.
  /// 4. Notifies citizen's contacts on Pocket Mates that it is their friend's birthday!
  static Future<void> checkAndDeliverBirthdayWish(String userId) async {
    try {
      if (userId.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Only wish once per calendar year
      final alreadyWishedYear =
          prefs.getInt('president_birthday_wish_year_$userId');
      if (alreadyWishedYear == now.year) return;

      int? bDay;
      int? bMonth;
      String userName = 'Citizen';

      // 1. Try local cached DOB (pm_dob_$userId)
      final cachedDobStr = prefs.getString('pm_dob_$userId');
      if (cachedDobStr != null && cachedDobStr.isNotEmpty) {
        final parsed = DateTime.tryParse(cachedDobStr);
        if (parsed != null) {
          bDay = parsed.day;
          bMonth = parsed.month;
        }
      }

      // 2. Query Supabase profile table for day, month, year, and name
      try {
        final profile = await SupaFlow.client
            .from('profile')
            .select('day, month, year, name')
            .or('id.eq.$userId,user_id.eq.$userId')
            .maybeSingle();

        if (profile != null) {
          if (profile['day'] != null && profile['month'] != null) {
            bDay = int.tryParse(profile['day'].toString());
            bMonth = int.tryParse(profile['month'].toString());
          }
          final pName = profile['name']?.toString().trim();
          if (pName != null && pName.isNotEmpty && pName != 'Pocket Mate') {
            userName = pName;
          }
        }
      } catch (e) {
        debugPrint('PocketPresidentService birthday check profile error: $e');
      }

      // Fallback name from ContactsNameService
      if (userName == 'Citizen') {
        final contactName = ContactsNameService().getDisplayName(
          userId: userId,
          fallbackName: 'Citizen',
        );
        if (contactName != 'Pocket Mate' && contactName != 'Citizen') {
          userName = contactName;
        }
      }

      // If citizen has not configured their DOB, return safely
      if (bDay == null || bMonth == null) return;

      // Check if today matches citizen's birthday (day & month)
      if (bDay != now.day || bMonth != now.month) return;

      // Mark this year as wished immediately to prevent duplicate dispatches
      await prefs.setInt('president_birthday_wish_year_$userId', now.year);
      await prefs.setString('president_birthday_wish_date_$userId',
          '${now.year}-${now.month}-${now.day}');

      // A. Royal Birthday Message in President 1-on-1 Chat
      final birthdayMessage = '🎂 Royal Birthday Greetings, $userName! 🌟🎉\n\n'
          'On this auspicious day, the President and the entire nation of Pocket World celebrate you! 👑✨\n\n'
          'May your year ahead be blessed with boundless English fluency, great friendships, courage in every Citadel battle, and abundant prosperity. Have a joyous and blessed birthday! 🎁🎈';

      await sendPresidentReplyToUser(
        targetUserId: userId,
        replyText: birthdayMessage,
        adminName: 'Presidential Office',
      );

      // B. Public Birthday Vibe Proclamation (Visible to all citizens in Vibes)
      final vibeCaption = '👑 Presidential Proclamation 🎂🎉\n\n'
          'Join the President in wishing a magnificent Happy Birthday to our esteemed citizen $userName! 🌟✨\n'
          'Let us all celebrate their journey in Pocket World! Send them your warmest wishes! 🎁🥳';

      await postPresidentVibe(
        caption: vibeCaption,
        mediaType: 'text',
      );

      // C. Instant Celebratory Notification to the User
      PushNotificationService.showInstantNotification(
        id: 99901,
        title: '🎂 Happy Birthday from The President! 🎉',
        body:
            'The President and Pocket World wish you a marvelous birthday! Tap to see your royal message.',
        payload: 'chat_p:$presidentId',
      );

      // In-App floating banner
      InAppNotificationService.show(
        title: '🎂 Happy Birthday, $userName! 🎉',
        message:
            'The President has officially proclaimed your birthday across Pocket World! Tap to view.',
        badgeText: 'BIRTHDAY',
        badgeColor: const Color(0xFFFFD700),
        onTap: () {
          final context = appNavigatorKey.currentContext;
          if (context != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WhatsAppGroupChat(
                  groupId: 'p:$presidentId',
                  groupName: 'The President 🏛️',
                  showBackButton: true,
                ),
              ),
            );
          }
        },
      );

      // D. Broadcast Birthday Notification to citizen's contacts on Pocket Mates
      try {
        final contactUserIds = ContactsNameService().allSyncedContactUserIds;
        for (final friendUid in contactUserIds) {
          if (friendUid == userId) continue;
          PushNotificationService.dispatchChatMessagePushNotification(
            senderId: presidentId,
            senderName: 'The President 🏛️',
            messageText:
                '🎉 Today is $userName\'s Birthday! Tap to send warm wishes!',
            receiverId: friendUid,
          );
        }
      } catch (e) {
        debugPrint('Birthday contacts notification error: $e');
      }
    } catch (e) {
      debugPrint('Error in checkAndDeliverBirthdayWish: $e');
    }
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

    // 3. Dispatch Push Notification via Supabase Edge Function to all citizens!
    try {
      final supabase = SupaFlow.client;
      await supabase.functions.invoke('send-push-notification', body: {
        'action': 'broadcast',
        'title': title,
        'body':
            content.length > 120 ? '${content.substring(0, 117)}...' : content,
      });
      debugPrint('Presidential Broadcast Push Notification dispatched!');
    } catch (pushErr) {
      debugPrint('Error triggering broadcast push notification: $pushErr');
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

      // Collect all reporter IDs to batch fetch real citizen profiles & credentials
      final List<String> reporterIds = [];
      for (var row in res) {
        final rId = (row['reporter_id'] ?? row['user_id'] ?? '').toString();
        if (rId.isNotEmpty) reporterIds.add(rId);
      }

      Map<String, Map<String, dynamic>> profileMap = {};
      Map<String, Map<String, dynamic>> userAuthMap = {};
      if (reporterIds.isNotEmpty) {
        final uniqueIds = reporterIds.toSet().toList();
        try {
          final profs1 = await supabase
              .from('profile')
              .select('*')
              .inFilter('user_id', uniqueIds);
          for (var p in profs1) {
            if (p['user_id'] != null) profileMap[p['user_id'].toString()] = p;
            if (p['id'] != null) profileMap[p['id'].toString()] = p;
          }
          final profs2 = await supabase
              .from('profile')
              .select('*')
              .inFilter('id', uniqueIds);
          for (var p in profs2) {
            if (p['user_id'] != null) profileMap[p['user_id'].toString()] = p;
            if (p['id'] != null) profileMap[p['id'].toString()] = p;
          }
        } catch (e) {
          debugPrint('Error batch-fetching citizen profiles: $e');
        }

        try {
          final usersRes = await supabase
              .from('users')
              .select('id, email')
              .inFilter('id', uniqueIds);
          for (var u in usersRes) {
            if (u['id'] != null) userAuthMap[u['id'].toString()] = u;
          }
        } catch (e) {
          debugPrint('Error batch-fetching users auth credentials: $e');
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
        final reporterId =
            (row['reporter_id'] ?? row['user_id'] ?? '').toString();
        final prof = profileMap[reporterId];
        final userAuth = userAuthMap[reporterId];

        String realName = '';
        if (prof != null) {
          final n = (prof['display_name'] ??
                  prof['name'] ??
                  prof['username'] ??
                  prof['first_name'] ??
                  '')
              .toString()
              .trim();
          if (n.isNotEmpty && n != 'Citizen' && n != 'User') realName = n;
        }
        if (realName.isEmpty) {
          final en = (extra['user_name'] ?? '').toString().trim();
          if (en.isNotEmpty && en != 'Citizen' && en != 'User') realName = en;
        }
        if (realName.isEmpty && userAuth?['email'] != null) {
          final em = userAuth!['email'].toString();
          realName = em.contains('@') ? em.split('@').first : em;
        }
        if (realName.isEmpty ||
            realName == 'Citizen' ||
            realName.startsWith('Citizen (')) {
          final contactName = ContactsNameService()
              .getDisplayName(userId: reporterId, fallbackName: 'Learner');
          if (contactName.isNotEmpty &&
              contactName != 'User' &&
              contactName != 'Citizen') {
            realName = contactName;
          } else {
            realName = reporterId.length > 5
                ? 'Citizen ${reporterId.substring(0, 5)}'
                : 'Citizen';
          }
        }

        final email =
            (userAuth?['email'] ?? extra['email'] ?? '').toString().trim();
        final phone =
            (prof?['phone_no'] ?? userAuth?['phone_no'] ?? extra['phone'] ?? '')
                .toString()
                .trim();
        final planet =
            (prof?['country'] ?? extra['planet'] ?? 'Earth').toString().trim();
        final city = (prof?['city'] ?? extra['city'] ?? '').toString().trim();
        final bio = (prof?['bio'] ?? '').toString();
        String plot = '';
        if (bio.isNotEmpty) {
          final plotMatch =
              RegExp(r'Plot\s*[:#]?\s*(\d+)', caseSensitive: false)
                  .firstMatch(bio);
          if (plotMatch != null) plot = 'Plot #${plotMatch.group(1)}';
        }

        final avatarUrl = prof?['profile_image_url'] ?? extra['user_avatar'];
        final day =
            prof?['learning_day'] ?? prof?['day'] ?? extra['learning_day'] ?? 1;
        final messages = (extra['messages'] is List)
            ? List<Map<String, dynamic>>.from(
                extra['messages'].map((m) => Map<String, dynamic>.from(m)))
            : <Map<String, dynamic>>[];

        inquiries.add({
          'id': row['id']?.toString(),
          'user_id': reporterId,
          'user_name': realName,
          'user_email': email,
          'user_phone': phone,
          'planet': planet.isNotEmpty ? planet : 'Earth',
          'city': city,
          'plot': plot,
          'user_avatar': avatarUrl,
          'learning_day': day,
          'english_level': prof?['english_level'],
          'last_message': isGeneralReport
              ? '⚠️ [REPORT: ${row['report_type'] ?? 'Citizen Report'}] $desc'
              : desc,
          'report_type': row['report_type'] ??
              (isGeneralReport ? 'citizen_report' : 'doubt'),
          'status': row['status'] ?? 'pending',
          'created_at': row['created_at'],
          'is_general_report': isGeneralReport,
          'messages': messages,
          'report_id': row['id']?.toString(),
        });
      }
    } catch (e) {
      debugPrint(
          'Error fetching President inquiries/reports from Supabase: $e');
    }

    // 1.5 Fetch direct citizen chat messages sent to The President from Supabase messages table
    try {
      final supabase = SupaFlow.client;
      final directMsgs = await supabase
          .from('messages')
          .select(
              'id, sender_id, receiver_id, message_text, created_at, metadata')
          .or('receiver_id.eq.pocket_president,receiver_id.eq.president,receiver_id.eq.president_of_pocket_world')
          .order('created_at', ascending: false)
          .limit(100);

      final Map<String, Map<String, dynamic>> latestDirectMsgBySender = {};
      for (var m in directMsgs) {
        final sId = m['sender_id']?.toString() ?? '';
        if (sId.isNotEmpty && !latestDirectMsgBySender.containsKey(sId)) {
          latestDirectMsgBySender[sId] = m;
        }
      }

      if (latestDirectMsgBySender.isNotEmpty) {
        final missingUserIds = latestDirectMsgBySender.keys.toList();
        Map<String, Map<String, dynamic>> directProfMap = {};
        Map<String, Map<String, dynamic>> directUserMap = {};
        try {
          final profs1 = await supabase
              .from('profile')
              .select(
                  'id, user_id, name, display_name, first_name, username, profile_image_url, learning_day, day, english_level, country, city, bio, phone_no')
              .inFilter('user_id', missingUserIds);
          for (var p in profs1) {
            if (p['user_id'] != null)
              directProfMap[p['user_id'].toString()] = p;
            if (p['id'] != null) directProfMap[p['id'].toString()] = p;
          }
          final profs2 = await supabase
              .from('profile')
              .select(
                  'id, user_id, name, display_name, first_name, username, profile_image_url, learning_day, day, english_level, country, city, bio, phone_no')
              .inFilter('id', missingUserIds);
          for (var p in profs2) {
            if (p['user_id'] != null)
              directProfMap[p['user_id'].toString()] = p;
            if (p['id'] != null) directProfMap[p['id'].toString()] = p;
          }
        } catch (_) {}

        try {
          final uRows = await supabase
              .from('users')
              .select('id, email, phone_no, role')
              .inFilter('id', missingUserIds);
          for (var u in uRows) {
            if (u['id'] != null) directUserMap[u['id'].toString()] = u;
          }
        } catch (_) {}

        latestDirectMsgBySender.forEach((sId, msgRow) {
          final existingIdx = inquiries.indexWhere((q) => q['user_id'] == sId);
          final prof = directProfMap[sId];
          final userAuth = directUserMap[sId];

          String displayName = '';
          if (prof != null) {
            final n = (prof['display_name'] ??
                    prof['name'] ??
                    prof['username'] ??
                    prof['first_name'] ??
                    '')
                .toString()
                .trim();
            if (n.isNotEmpty && n != 'Citizen' && n != 'User') displayName = n;
          }
          if (displayName.isEmpty && userAuth?['email'] != null) {
            final em = userAuth!['email'].toString();
            displayName = em.contains('@') ? em.split('@').first : em;
          }
          if (displayName.isEmpty) {
            final cName = ContactsNameService()
                .getDisplayName(userId: sId, fallbackName: 'Learner');
            displayName =
                (cName.isNotEmpty && cName != 'User' && cName != 'Citizen')
                    ? cName
                    : (sId.length > 5
                        ? 'Citizen ${sId.substring(0, 5)}'
                        : 'Citizen');
          }

          final email = (userAuth?['email'] ?? '').toString().trim();
          final phone = (prof?['phone_no'] ?? userAuth?['phone_no'] ?? '')
              .toString()
              .trim();
          final planet = (prof?['country'] ?? 'Earth').toString().trim();
          final city = (prof?['city'] ?? '').toString().trim();
          final bio = (prof?['bio'] ?? '').toString();
          String plot = '';
          if (bio.isNotEmpty) {
            final plotMatch =
                RegExp(r'Plot\s*[:#]?\s*(\d+)', caseSensitive: false)
                    .firstMatch(bio);
            if (plotMatch != null) plot = 'Plot #${plotMatch.group(1)}';
          }

          final avatarUrl = prof?['profile_image_url'];
          final day = prof?['learning_day'] ?? prof?['day'] ?? 1;
          final text = msgRow['message_text']?.toString() ?? '';

          if (existingIdx != -1) {
            inquiries[existingIdx]['last_message'] = text;
            inquiries[existingIdx]['created_at'] = msgRow['created_at'];
            if (email.isNotEmpty) inquiries[existingIdx]['user_email'] = email;
            if (phone.isNotEmpty) inquiries[existingIdx]['user_phone'] = phone;
            if (planet.isNotEmpty) inquiries[existingIdx]['planet'] = planet;
            if (city.isNotEmpty) inquiries[existingIdx]['city'] = city;
            if (plot.isNotEmpty) inquiries[existingIdx]['plot'] = plot;
          } else {
            inquiries.add({
              'id': msgRow['id']?.toString(),
              'user_id': sId,
              'user_name': displayName,
              'user_email': email,
              'user_phone': phone,
              'planet': planet.isNotEmpty ? planet : 'Earth',
              'city': city,
              'plot': plot,
              'user_avatar': avatarUrl,
              'learning_day': day,
              'english_level': prof?['english_level'],
              'last_message': text,
              'report_type': 'citizen_direct_message',
              'status': 'pending',
              'created_at': msgRow['created_at'],
              'is_general_report': false,
              'messages': [
                {
                  'id': msgRow['id']?.toString(),
                  'sender_id': sId,
                  'sender_name': displayName,
                  'sender_avatar': avatarUrl,
                  'is_president': false,
                  'text': text,
                  'created_at': msgRow['created_at'],
                }
              ],
            });
          }
        });
      }
    } catch (directMsgErr) {
      debugPrint(
          'Error fetching direct citizen messages for President Desk: $directMsgErr');
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
    String? userName,
    String? userAvatar,
    int? learningDay,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPresidentInquiriesMasterKey);
      List<dynamic> list = raw != null && raw.isNotEmpty ? jsonDecode(raw) : [];

      final existingIndex = list.indexWhere((i) => i['user_id'] == userId);
      final resolvedContact = ContactsNameService()
          .getDisplayName(userId: userId, fallbackName: 'Learner');
      final finalName = (userName != null &&
              userName.isNotEmpty &&
              userName != 'Citizen' &&
              userName != 'User')
          ? userName
          : (resolvedContact.isNotEmpty && resolvedContact != 'User'
              ? resolvedContact
              : (userId.length > 5
                  ? 'Learner ${userId.substring(0, 5)}'
                  : 'Learner'));
      final inquiryData = {
        'user_id': userId,
        'user_name': finalName,
        'user_avatar': userAvatar,
        'learning_day': learningDay ?? 1,
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

  static Future<void> _markMasterInquiryReplied(
      String userId, String reply) async {
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
    if (lower.contains('complaint') ||
        lower.contains('cheat') ||
        lower.contains('report') ||
        lower.contains('bug') ||
        lower.contains('issue')) {
      return 'complaint';
    }
    if (lower.contains('doubt') ||
        lower.contains('question') ||
        lower.contains('how to') ||
        lower.contains('meaning')) {
      return 'doubt';
    }
    if (lower.contains('attack') ||
        lower.contains('citadel') ||
        lower.contains('protect') ||
        lower.contains('shield')) {
      return 'citadel_protection';
    }
    return 'general';
  }

  static const String _kPresidentCitadelConqueredPrefix =
      'presidential_citadel_conquered_';

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
