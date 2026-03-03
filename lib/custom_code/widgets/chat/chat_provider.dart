import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/local_sync_server.dart';

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
  late SupabaseClient _supabase;
  RealtimeChannel? _subscription;

  // Performance optimizations
  static const int _pageSize = 50; // Load 50 messages at a time
  int _currentPage = 0;
  bool _hasMoreMessages = true;
  Timer? _debounceTimer;
  Timer? _pollingTimer;
  final List<ChatMessage> _optimisticMessages = [];

  @override
  FutureOr<List<ChatMessage>> build(String groupId) async {
    _supabase = ref.watch(supabaseClientProvider);

    // Subscribe to changes with debouncing
    _setupSubscription();

    // Cleanup on dispose
    ref.onDispose(() {
      _subscription?.unsubscribe();
      _debounceTimer?.cancel();
      _pollingTimer?.cancel();
    });

    // Start polling
    _startPolling();

    // Cache-First Strategy
    final cached = await _loadFromCache();
    final freshFuture = _fetchMessages(isInitial: true);

    if (cached.isNotEmpty) {
      freshFuture.then((fresh) {
        if (state.hasValue) {
          state = AsyncValue.data(fresh);
          _saveToCache(fresh); // Update cache with fresh data
        }
      }).catchError((e) {
        debugPrint('Background fetch failed: $e');
      });
      return cached;
    }

    return freshFuture;
  }

  void _setupSubscription() {
    final isPersonal = groupId.startsWith('p:');
    final actualId = isPersonal ? groupId.substring(2) : groupId;

    _subscription = _supabase
        .channel('chat_messages_$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: isPersonal ? 'messages' : 'group_messages',
          filter: isPersonal
              ? PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'receiver_id',
                  value: actualId,
                )
              : PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'group_id',
                  value: actualId,
                ),
          callback: (payload) {
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 300), () {
              _handleRealtimeUpdate(payload);
            });
          },
        )
        .subscribe();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        // Fetch latest messages (Page 0)
        final latestMessages = await _fetchMessages(forceLatest: true);

        // Merge with current state to preserve pagination/scroll history
        state.whenData((currentMessages) {
          if (latestMessages.isEmpty) return;

          final Map<String, ChatMessage> combinedMap = {
            for (var m in currentMessages) m.id: m,
            for (var m in latestMessages) m.id: m,
          };

          final combinedList = combinedMap.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Only update state if content is different
          if (combinedList.length != currentMessages.length ||
              combinedList.first.id != latestMessages.first.id) {
            state = AsyncValue.data(combinedList);
            _saveToCache(combinedList); // Keep cache in sync with polling
          }
        });
      } catch (e) {
        // Ignore polling errors
      }
    });
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
            _saveToCache(updatedMessages);
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
        _saveToCache(updatedMessages);
      });
    }
  }

  Future<List<ChatMessage>> _fetchMessages({
    bool isInitial = false,
    bool forceLatest = false,
  }) async {
    if (isInitial) {
      _currentPage = 0;
      _hasMoreMessages = true;
    }

    final isPersonal = groupId.startsWith('p:');
    final actualId = isPersonal ? groupId.substring(2) : groupId;
    final uid = ref.read(currentUserIdProvider);

    // If forcing latest (polling), we temporarily look at page 0 without resetting main pagination state
    final int pageToFetch = forceLatest ? 0 : _currentPage;

    try {
      final offset = pageToFetch * _pageSize;

      final query =
          _supabase.from(isPersonal ? 'messages' : 'group_messages').select('''
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
        ),
          gallery:gallery_id(
            *,
            user:users!user_id(
              profile:profile!user_id(name, profile_image_url)
            )
          ),
          thought:thought_id(
            *,
            user:users!user_id(
              profile:profile!user_id(name, profile_image_url)
            )
          )
        ''');

      final response = await (isPersonal
              ? query.or(
                  'and(sender_id.eq.$uid,receiver_id.eq.$actualId),and(sender_id.eq.$actualId,receiver_id.eq.$uid)')
              : query.eq('group_id', actualId))
          .order('created_at', ascending: false)
          .range(offset, offset + _pageSize - 1);

      final List<dynamic> responseList = response as List;
      final remoteMessages = responseList.map((data) {
        final sender = _safeGet(data['sender']);
        final senderProfile = _safeGet(sender?['profile']);
        final replyTo = _safeGet(data['reply_to']);

        return ChatMessage.fromJson({
          ...data,
          'sender_profile': senderProfile,
          'reply_to': replyTo,
          'gallery': _safeGet(data['gallery']),
          'thought': _safeGet(data['thought']),
        });
      }).toList();

      final List<ChatMessage> cachedMessages = await _loadFromCache();

      // Combine unique messages (favor remote/fresh data)
      final Map<String, ChatMessage> combinedMap = {
        for (var m in cachedMessages) m.id: m,
        for (var m in remoteMessages) m.id: m,
      };

      final combined = combinedMap.values.toList();
      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (isInitial) {
        _saveToCache(combined);
      }

      return combined;
    } catch (e) {
      if (isInitial) {
        final cached = await _loadFromCache();
        if (cached.isNotEmpty) return cached;
      }
      rethrow;
    }
  }

  Future<void> cleanupOldMessages() async {
    final isPersonal = groupId.startsWith('p:');
    final actualId = isPersonal ? groupId.substring(2) : groupId;
    try {
      // Delete from Supabase messages older than 34 hours
      final cutoffTime = DateTime.now().subtract(const Duration(hours: 34));

      await _supabase
          .from(isPersonal ? 'messages' : 'group_messages')
          .delete()
          .eq(isPersonal ? 'receiver_id' : 'group_id', actualId)
          .lt('created_at', cutoffTime.toIso8601String());

      debugPrint('Supabase 34h cleanup completed for: $groupId');
    } catch (e) {
      debugPrint('Error during database cleanup: $e');
    }
  }

  Future<void> editMessage(String messageId, String newText) async {
    final isPersonal = groupId.startsWith('p:');
    try {
      await _supabase.from(isPersonal ? 'messages' : 'group_messages').update({
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
          _saveToCache(updatedList);
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
      _saveToCache(moreMessages); // Cache the extended history
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
    String? galleryId,
    String? thoughtId,
    Map<String, dynamic>? metadata,
  }) async {
    final uid = ref.read(currentUserIdProvider);
    if (uid.isEmpty) return;

    final isPersonal = groupId.startsWith('p:');
    final actualId = isPersonal ? groupId.substring(2) : groupId;

    // Create optimistic message
    final optimisticMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      groupId: isPersonal ? null : actualId,
      receiverId: isPersonal ? actualId : null,
      senderId: uid,
      messageText: text,
      messageType: messageType,
      fileUrl: fileUrl,
      voiceDuration: voiceDuration,
      replyToMessageId: replyToId,
      createdAt: DateTime.now(),
      isOptimistic: true,
      metadata: metadata,
    );

    // Add optimistically to UI immediately
    _optimisticMessages.add(optimisticMessage);
    state.whenData((messages) {
      state = AsyncData([optimisticMessage, ...messages]);
    });

    final messageData = {
      if (!isPersonal) 'group_id': actualId else 'receiver_id': actualId,
      'sender_id': uid,
      'message_text': text,
      'message_type': messageType,
      'file_url': fileUrl,
      'voice_duration': voiceDuration,
      'reply_to_message_id': replyToId,
      'gallery_id': galleryId,
      'thought_id': thoughtId,
      'metadata': metadata,
    };

    try {
      final response = await _supabase
          .from(isPersonal ? 'messages' : 'group_messages')
          .insert(messageData)
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
            ),
            gallery:gallery_id(
              *,
              user:users!user_id(
                profile:profile!user_id(name, profile_image_url)
              )
            ),
            thought:thought_id(
              *,
              user:users!user_id(
                profile:profile!user_id(name, profile_image_url)
              )
            )
          ''').single();

      final sender = _safeGet(response['sender']);
      final senderProfile = _safeGet(sender?['profile']);
      final replyTo = _safeGet(response['reply_to']);

      final fullMessage = ChatMessage.fromJson({
        ...response,
        'sender_profile': senderProfile,
        'reply_to': replyTo,
        'gallery': _safeGet(response['gallery']),
        'thought': _safeGet(response['thought']),
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
        _saveToCache(updatedList);
      });

      // Update relevant metadata for the chat list
      try {
        if (isPersonal) {
          // Update conversations table
          await _supabase.from('conversations').update({
            'last_message': text,
            'last_message_time': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'last_sender_id': uid,
          }).or(
              'and(user_id.eq.$uid,other_user_id.eq.$actualId),and(user_id.eq.$actualId,other_user_id.eq.$uid)');
        } else {
          await _supabase.from('groups').update({
            'last_message': text,
            'last_message_time': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', actualId);
        }
      } catch (metaError) {
        debugPrint('Error updating metadata: $metaError');
      }
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
    final isPersonal = groupId.startsWith('p:');
    // Optimistically remove from UI
    state.whenData((messages) {
      state = AsyncData(messages.where((m) => m.id != messageId).toList());
    });

    try {
      await _supabase
          .from(isPersonal ? 'messages' : 'group_messages')
          .delete()
          .eq('id', messageId);
      // Real-time listener confirms deletion
    } catch (e) {
      // Revert on error - refresh from server
      ref.invalidateSelf();
      rethrow;
    }
  }

  // Cache Logic: Persist messages locally for 34h+ history
  Future<List<ChatMessage>> _loadFromCache() async {
    final cachedData = LocalSyncServer().getCachedMessages(groupId);
    return cachedData
        .map((m) => ChatMessage.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> _saveToCache(List<ChatMessage> messages) async {
    await LocalSyncServer().saveMessages(groupId, messages);
  }

  Future<ChatMessage?> _fetchMessageById(String id) async {
    final isPersonal = groupId.startsWith('p:');
    try {
      final response = await _supabase
          .from(isPersonal ? 'messages' : 'group_messages')
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
        ),
        gallery:gallery_id(
          *,
          user:users!user_id(
            profile:profile!user_id(name, profile_image_url)
          )
        ),
        thought:thought_id(
          *,
          user:users!user_id(
            profile:profile!user_id(name, profile_image_url)
          )
        )
      ''')
          .eq('id', id)
          .single();

      final sender = _safeGet(response['sender']);
      final senderProfile = _safeGet(sender?['profile']);
      final replyTo = _safeGet(response['reply_to']);

      return ChatMessage.fromJson({
        ...response,
        'sender_profile': senderProfile,
        'reply_to': replyTo,
        'gallery': _safeGet(response['gallery']),
        'thought': _safeGet(response['thought']),
      });
    } catch (e) {
      debugPrint('Error fetching message by id: $e');
      return null;
    }
  }

  // Helper to safely extract Map from potential List (Supabase Joins)
  Map<String, dynamic>? _safeGet(dynamic input) {
    if (input == null) return null;
    if (input is Map) return Map<String, dynamic>.from(input);
    if (input is List && input.isNotEmpty) {
      final first = input.first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }
    return null;
  }
}
