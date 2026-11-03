import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/local_sync_server.dart';
import 'pocket_language_guard_service.dart';

/// 🌐 Service to schedule and execute delayed background language checks for Personal Chat.
/// Policy: Personal One-to-One Chat is English-only.
/// Flow:
/// 1. Sender sends message immediately.
/// 2. Receiver gets it immediately (0ms delay).
/// 3. Message is queued with scheduled execution ~2-3 minutes later.
/// 4. Background check runs (persisted in DB metadata & SharedPreferences queue).
/// 5. If confidently non-English, updates message metadata in Supabase & LocalSyncServer.
/// 6. Both sender & receiver see the gentle inline warning below that message bubble.
class PocketPersonalChatLanguageService {
  PocketPersonalChatLanguageService._();
  static final PocketPersonalChatLanguageService instance = PocketPersonalChatLanguageService._();

  static const int _delaySeconds = 150; // 2.5 minutes (approx 2-3 mins)
  Timer? _queueWorkerTimer;
  bool _isProcessing = false;

  /// Initialize queue processing timer (runs every 30 seconds to process due checks)
  void startBackgroundWorker() {
    _queueWorkerTimer?.cancel();
    _queueWorkerTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      processPendingQueue();
    });
  }

  /// Schedule a delayed check for a newly sent personal message
  Future<void> scheduleMessageCheck({
    required String messageId,
    required String messageText,
    required String senderId,
    required String receiverId,
    required String chatId,
  }) async {
    // Skip if empty or clearly system/robot/president
    if (messageId.isEmpty || messageText.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getStringList('personal_chat_lang_queue') ?? [];

      final dueTimestamp = DateTime.now().add(const Duration(seconds: _delaySeconds)).millisecondsSinceEpoch;

      final item = {
        'message_id': messageId,
        'message_text': messageText,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'chat_id': chatId,
        'due_timestamp': dueTimestamp.toString(),
      };

      queueJson.add(item.entries.map((e) => '${e.key}=${e.value}').join(';'));
      await prefs.setStringList('personal_chat_lang_queue', queueJson);
    } catch (e) {
      debugPrint('Error scheduling personal chat message language check: $e');
    }
  }

  /// Process any messages whose 2-3 minute delay has elapsed
  Future<void> processPendingQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final queueItems = prefs.getStringList('personal_chat_lang_queue') ?? [];
      if (queueItems.isEmpty) {
        _isProcessing = false;
        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final remaining = <String>[];
      final toProcess = <Map<String, dynamic>>[];

      for (final raw in queueItems) {
        final map = <String, dynamic>{};
        for (final pair in raw.split(';')) {
          final idx = pair.indexOf('=');
          if (idx != -1) {
            map[pair.substring(0, idx)] = pair.substring(idx + 1);
          }
        }
        final due = int.tryParse(map['due_timestamp']?.toString() ?? '0') ?? 0;
        if (now >= due) {
          toProcess.add(map);
        } else {
          remaining.add(raw);
        }
      }

      await prefs.setStringList('personal_chat_lang_queue', remaining);

      for (final task in toProcess) {
        final messageId = task['message_id']?.toString() ?? '';
        final messageText = task['message_text']?.toString() ?? '';
        final senderId = task['sender_id']?.toString() ?? '';
        final receiverId = task['receiver_id']?.toString() ?? '';
        final chatId = task['chat_id']?.toString() ?? '';

        if (messageId.isNotEmpty && messageText.isNotEmpty) {
          await _evaluateAndApplyWarning(
            messageId: messageId,
            messageText: messageText,
            senderId: senderId,
            receiverId: receiverId,
            chatId: chatId,
          );
        }
      }
    } catch (e) {
      debugPrint('Error processing language check queue: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Execute evaluation and persist warning if non-English
  Future<void> _evaluateAndApplyWarning({
    required String messageId,
    required String messageText,
    required String senderId,
    required String receiverId,
    required String chatId,
  }) async {
    final check = PocketLanguageGuardService.checkPersonalChatMessage(messageText);

    // If message is valid English or skipped (short, url, emoji), do nothing
    if (check.isValid) return;

    final detectedLang = check.detectedWord ?? 'Non-English';

    final langWarningData = {
      'has_language_warning': true,
      'detected_language': detectedLang,
      'warning_text': 'Please communicate in English in Personal Chat.',
      'checked_at': DateTime.now().toIso8601String(),
    };

    // 1. Update Supabase 'messages' table metadata so both sender & receiver see it
    try {
      final supabase = SupaFlow.client;
      final existingRes = await supabase
          .from('messages')
          .select('metadata')
          .eq('id', messageId)
          .maybeSingle();

      final currentMeta = Map<String, dynamic>.from(existingRes?['metadata'] as Map? ?? {});
      currentMeta['language_warning'] = langWarningData;

      await supabase.from('messages').update({
        'metadata': currentMeta,
      }).eq('id', messageId);
    } catch (e) {
      debugPrint('Failed to update language warning in Supabase messages: $e');
    }

    // 2. Update local cache for instant zero-latency UI reflection
    final currentUserId = SupaFlow.client.auth.currentUser?.id;
    if (currentUserId != null && chatId.isNotEmpty) {
      try {
        LocalSyncServer().updateCachedMessage(
          userId: currentUserId,
          chatOrGroupId: chatId,
          messageId: messageId,
          updates: {
            'metadata': {
              'language_warning': langWarningData,
            },
          },
        );
      } catch (_) {}
    }
  }
}

