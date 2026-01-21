import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

import 'chat_models.dart';

part 'chat_provider.g.dart';

// Provider for the Supabase Client
@riverpod
SupabaseClient supabaseClient(Ref ref) => SupaFlow.client;

// Provider for the Current User ID
@riverpod
String currentUserId(Ref ref) {
  return ref.watch(supabaseClientProvider).auth.currentUser?.id ?? '';
}

@riverpod
class ChatMessages extends _$ChatMessages {
  late final SupabaseClient _supabase;
  RealtimeChannel? _subscription;

  // Performance optimizations
  static const int _pageSize = 50; // Load 50 messages at a time
  int _currentPage = 0;
  bool _hasMoreMessages = true;
  Timer? _debounceTimer;
  final List<ChatMessage> _optimisticMessages = [];

  @override
  FutureOr<List<ChatMessage>> build(String groupId) async {
    _supabase = ref.watch(supabaseClientProvider);

    // Subscribe to changes with debouncing
    _setupSubscription(groupId);

    // Cleanup on dispose
    ref.onDispose(() {
      _subscription?.unsubscribe();
      _debounceTimer?.cancel();
    });

    // Initial fetch - load first page only
    return _fetchMessages(isInitial: true);
  }

  void _setupSubscription(String groupId) {
    _subscription = _supabase
        .channel('chat_messages_$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) {
            // Debounce updates to prevent excessive rebuilds
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 300), () {
              _handleRealtimeUpdate(payload);
            });
          },
        )
        .subscribe();
  }

  void _handleRealtimeUpdate(dynamic payload) {
    final eventType = payload.eventType;

    if (eventType == PostgresChangeEvent.insert) {
      final newData = payload.newRecord as Map<String, dynamic>;
      final messageId = newData['id'];

      // Fetch the full message with profiles
      _fetchMessageById(messageId).then((fullMessage) {
        if (fullMessage != null) {
          state.whenData((currentMessages) {
            // Check if already exists to avoid duplicates
            if (currentMessages.any((m) => m.id == fullMessage.id)) return;

            final List<ChatMessage> updatedMessages = [
              fullMessage,
              ...currentMessages
            ];
            state = AsyncData(updatedMessages);
            _saveToCache(groupId, updatedMessages);
          });
        }
      });
    } else if (eventType == PostgresChangeEvent.delete) {
      final oldData = payload.oldRecord as Map<String, dynamic>;
      final deletedId = oldData['id'] as String;

      state.whenData((messages) {
        final updatedMessages =
            messages.where((m) => m.id != deletedId).toList();
        state = AsyncData(updatedMessages);
        _saveToCache(groupId, updatedMessages);
      });
    }
  }

  Future<List<ChatMessage>> _fetchMessages({bool isInitial = false}) async {
    if (isInitial) {
      _currentPage = 0;
      _hasMoreMessages = true;
    }

    try {
      final offset = _currentPage * _pageSize;

      final response = await _supabase
          .from('group_messages')
          .select('''
        *,
        reply_to:reply_to_message_id(
          id,
          message_text,
          message_type,
          file_url,
          sender_id,
          sender:users!sender_id(
            profile:profile!user_id(name, profile_image_url)
          )
        ),
        sender:users!sender_id(
          profile:profile!user_id(name, profile_image_url)
        )
      ''')
          .eq('group_id', groupId)
          .order('created_at', ascending: false)
          .range(offset, offset + _pageSize - 1);

      final messages = (response as List).map((data) {
        // Helper to safely extract Map from potential List
        Map<String, dynamic>? safeGet(dynamic input) {
          if (input is Map) return Map<String, dynamic>.from(input);
          if (input is List && input.isNotEmpty) {
            return Map<String, dynamic>.from(input.first);
          }
          return null;
        }

        // Handle nested sender -> profile
        final sender = safeGet(data['sender']);
        final senderProfile = safeGet(sender?['profile']);

        // Handle reply_to
        final replyTo = safeGet(data['reply_to']);

        return ChatMessage.fromJson({
          ...data,
          'sender_profile': senderProfile,
          'reply_to': replyTo,
        });
      }).toList();

      _hasMoreMessages = messages.length == _pageSize;

      if (isInitial) {
        _saveToCache(groupId, messages);
        return messages;
      } else {
        final currentMessages = state.asData?.value ?? [];
        return [...currentMessages, ...messages];
      }
    } catch (e) {
      if (isInitial) {
        final cached = await _loadFromCache(groupId);
        if (cached.isNotEmpty) return cached;
      }
      rethrow;
    }
  }

  Future<void> cleanupOldMessages() async {
    try {
      final cutoffTime = DateTime.now().subtract(const Duration(days: 30));
      await _supabase
          .from('group_messages')
          .delete()
          .eq('group_id', groupId)
          .lt('created_at', cutoffTime.toIso8601String());

      // Also refresh state
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error during database cleanup: $e');
    }
  }

  Future<void> editMessage(String messageId, String newText) async {
    try {
      await _supabase.from('group_messages').update({
        'message_text': newText,
        'is_edited': true,
      }).eq('id', messageId);

      // Update local state for immediate feedback
      state.whenData((messages) {
        final index = messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          final updated = ChatMessage.fromJson({
            ...messages[index].toJson(),
            'message_text': newText,
            'is_edited': true,
          });
          final updatedList = List<ChatMessage>.from(messages);
          updatedList[index] = updated;
          state = AsyncData(updatedList);
          _saveToCache(groupId, updatedList);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  // Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    if (!_hasMoreMessages || state.isLoading) return;

    _currentPage++;

    try {
      final moreMessages = await _fetchMessages();
      state = AsyncData(moreMessages);
    } catch (e) {
      _currentPage--; // Revert on error
      rethrow;
    }
  }

  Future<void> sendMessage({
    required String text,
    required String messageType,
    String? fileUrl,
    int? voiceDuration,
    String? replyToId,
  }) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid.isEmpty) return;

    // Create optimistic message
    final optimisticMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      groupId: groupId,
      senderId: uid,
      messageText: text,
      messageType: messageType,
      fileUrl: fileUrl,
      voiceDuration: voiceDuration,
      replyToMessageId: replyToId,
      createdAt: DateTime.now(),
      isOptimistic: true,
    );

    // Add optimistically to UI immediately
    _optimisticMessages.add(optimisticMessage);
    state.whenData((messages) {
      state = AsyncData([optimisticMessage, ...messages]);
    });

    final messageData = {
      'group_id': groupId,
      'sender_id': uid,
      'message_text': text,
      'message_type': messageType,
      'file_url': fileUrl,
      'voice_duration': voiceDuration,
      'reply_to_message_id': replyToId,
    };

    try {
      final response =
          await _supabase.from('group_messages').insert(messageData).select('''
            *,
            reply_to:reply_to_message_id(
              id,
              message_text,
              message_type,
              file_url,
              sender_id,
              sender:users!sender_id(
                profile:profile!user_id(name, profile_image_url)
              )
            ),
            sender:users!sender_id(
              profile:profile!user_id(name, profile_image_url)
            )
          ''').single();

      final fullMessage = ChatMessage.fromJson({
        ...response,
        'sender_profile': response['sender']?['profile'],
      });

      // Remove from optimistic list and update state
      _optimisticMessages.remove(optimisticMessage);

      state.whenData((messages) {
        final List<ChatMessage> updatedList = List.from(messages);
        final optIndex =
            updatedList.indexWhere((m) => m.id == optimisticMessage.id);

        if (optIndex != -1) {
          updatedList[optIndex] = fullMessage;
        } else if (!updatedList.any((m) => m.id == fullMessage.id)) {
          updatedList.insert(0, fullMessage);
        }

        state = AsyncData(updatedList);
        _saveToCache(groupId, updatedList);
      });
    } catch (e) {
      // Remove optimistic message on error
      _optimisticMessages.remove(optimisticMessage);
      state.whenData((messages) {
        state = AsyncData(
            messages.where((m) => m.id != optimisticMessage.id).toList());
      });
      rethrow;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    // Optimistically remove from UI
    state.whenData((messages) {
      state = AsyncData(messages.where((m) => m.id != messageId).toList());
    });

    try {
      await _supabase.from('group_messages').delete().eq('id', messageId);
      // Real-time listener confirms deletion
    } catch (e) {
      // Revert on error - refresh from server
      ref.invalidateSelf();
      rethrow;
    }
  }

  // Cache Logic with compression for large message lists
  Future<List<ChatMessage>> _loadFromCache(String groupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_messages_$groupId';
      final jsonStr = prefs.getString(key);
      if (jsonStr != null) {
        final List decoded = jsonDecode(jsonStr);
        // Only cache first page to keep cache size manageable
        return decoded
            .take(_pageSize)
            .map((m) => ChatMessage.fromJson(m))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveToCache(String groupId, List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_messages_$groupId';
      // Only cache first page to keep cache size manageable
      final messagesToCache = messages.take(_pageSize).toList();
      final jsonStr =
          jsonEncode(messagesToCache.map((m) => m.toJson()).toList());
      await prefs.setString(key, jsonStr);
    } catch (_) {}
  }

  Future<ChatMessage?> _fetchMessageById(String id) async {
    try {
      final response = await _supabase.from('group_messages').select('''
        *,
        reply_to:reply_to_message_id(
          id,
          message_text,
          message_type,
          file_url,
          sender_id,
          sender:users!sender_id(
            profile:profile!user_id(name, profile_image_url)
          )
        ),
        sender:users!sender_id(
          profile:profile!user_id(name, profile_image_url)
        )
      ''').eq('id', id).single();

      // Helper to safely extract Map from potential List
      Map<String, dynamic>? safeGet(dynamic input) {
        if (input is Map) return Map<String, dynamic>.from(input);
        if (input is List && input.isNotEmpty) {
          return Map<String, dynamic>.from(input.first);
        }
        return null;
      }

      final sender = safeGet(response['sender']);
      final senderProfile = safeGet(sender?['profile']);
      final replyTo = safeGet(response['reply_to']);

      return ChatMessage.fromJson({
        ...response,
        'sender_profile': senderProfile,
        'reply_to': replyTo,
      });
    } catch (e) {
      print('Error fetching message by id: $e');
      return null;
    }
  }
}
