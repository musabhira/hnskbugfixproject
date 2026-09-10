import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/chat_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart';

/// The "Dart Server" logic - A high-speed local data manager
/// that keeps Supabase and local storage (Hive) in sync.
class LocalSyncServer {
  static final LocalSyncServer _instance = LocalSyncServer._internal();
  factory LocalSyncServer() => _instance;
  LocalSyncServer._internal();

  late Box _conversationBox;
  late Box _messageBox;

  bool _isInitialized = false;
  final SupabaseClient _supabase = SupaFlow.client;

  // Streams for UI to listen to
  final _conversationController =
      StreamController<List<ChatConversation>>.broadcast();
  Stream<List<ChatConversation>> get conversationStream =>
      _conversationController.stream;

  // Ultra-fast live message stream for zero-lag chat updates (Snapchat speed)
  final _liveMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get liveMessageStream =>
      _liveMessageController.stream;

  // In-Memory Fast Cache for instant 0ms access
  final Map<String, List<dynamic>> _memoryMessageCache = {};

  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Open boxes
    _conversationBox = await Hive.openBox('conversations');
    _messageBox = await Hive.openBox('messages');

    _isInitialized = true;
    debugPrint('LocalSyncServer: Initialized');

    // Start listening to real-time changes if user is logged in
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      _setupRealtimeSync(userId);
    }

    // Listen for auth changes to restart sync
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn && session?.user.id != null) {
        _setupRealtimeSync(session!.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _cleanupSync();
      }
    });
  }

  RealtimeChannel? _syncChannel;

  void _setupRealtimeSync(String userId) {
    _cleanupSync();

    _syncChannel = _supabase
        .channel('local_sync_server_global')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) => _handleGlobalMessageUpdate(payload),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_messages',
          callback: (payload) => _handleGroupMessageUpdate(payload),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          callback: (payload) => refreshConversations(userId),
        )
        .subscribe();

    // Initial refresh
    refreshConversations(userId);
  }

  void _cleanupSync() {
    _syncChannel?.unsubscribe();
    _syncChannel = null;
  }

  // --- CONVERSATIONS ---

  Future<void> refreshConversations(String userId) async {
    try {
      debugPrint('LocalSyncServer: Refreshing conversations for $userId');

      // In background, any new conversations appearing in Supabase
      // will be synced to the provider which manages the Hive partition.
      // We log the event here for sync monitoring.
      debugPrint(
          'LocalSyncServer: Syncing conversations for $userId with Supabase...');

      // We'll transform these into ChatConversation models (simplified for storage)
      // Note: Full transformation usually happens in the provider, but we save basic JSON here.
      // For now, we'll let the provider call saveConversations with the full models.
      // But we can trigger a sync event if needed.
    } catch (e) {
      debugPrint('LocalSyncServer error refreshing conversations: $e');
    }
  }

  Future<void> saveConversations(String userId, List<ChatConversation> conversations) async {
    final List<Map<String, dynamic>> jsonList =
        conversations.map((e) => e.toJson()).toList();
    await _conversationBox.put('list_$userId', jsonList);
    _conversationController.add(conversations);
  }

  List<ChatConversation> getCachedConversations(String userId) {
    if (!_isInitialized) return [];
    final List<dynamic>? list = _conversationBox.get('list_$userId');
    if (list == null) return [];
    return list
        .map((e) => ChatConversation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // --- MESSAGES ---

  Future<void> saveMessages(
      String userId, String chatOrGroupId, List<dynamic> messages) async {
    final key = '${userId}_$chatOrGroupId';
    final List<Map<String, dynamic>> jsonList = messages.map((e) {
      if (e is ChatMessage) return e.toJson();
      return Map<String, dynamic>.from(e);
    }).toList();

    // 1. Hot memory cache (0ms immediate latency)
    _memoryMessageCache[key] = jsonList;

    // 2. Persistent storage
    await _messageBox.put(key, jsonList);
  }

  List<dynamic> getCachedMessages(String userId, String chatOrGroupId) {
    final key = '${userId}_$chatOrGroupId';
    // Return from hot memory first
    if (_memoryMessageCache.containsKey(key)) {
      return _memoryMessageCache[key]!;
    }
    if (!_isInitialized) return [];
    final List<dynamic>? list = _messageBox.get(key);
    if (list == null) return [];
    _memoryMessageCache[key] = list;
    return list;
  }

  /// ⚡ Instant message dispatcher for Snapchat-speed chat UI updates
  void dispatchInstantMessage({
    required String userId,
    required String chatOrGroupId,
    required Map<String, dynamic> message,
  }) {
    final key = '${userId}_$chatOrGroupId';
    final current = getCachedMessages(userId, chatOrGroupId);
    final updated = [message, ...current];
    _memoryMessageCache[key] = updated;
    saveMessages(userId, chatOrGroupId, updated);

    // Broadcast instant update
    _liveMessageController.add({
      'chatId': chatOrGroupId,
      'message': message,
      'is_optimistic': true,
    });
  }

  void _handleGlobalMessageUpdate(PostgresChangePayload payload) {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    if (payload.eventType == PostgresChangeEvent.delete) {
      final oldId = payload.oldRecord['id']?.toString();
      if (oldId != null) _removeMessageFromCache(currentUserId, oldId);
      return;
    }

    // Determine which conversation this message belongs to and update Hive
    final newData = payload.newRecord;

    final senderId = newData['sender_id'];
    final receiverId = newData['receiver_id'];

    // Identify who the "other" person is (the chat ID)
    String? chatId;
    if (senderId == currentUserId) {
      chatId = receiverId;
    } else if (receiverId == currentUserId) {
      chatId = senderId;
    }

    if (chatId != null) {
      final List<dynamic> current = getCachedMessages(currentUserId, chatId);
      final String msgId = newData['id'].toString();
      final bool exists = current.any((m) => m['id'].toString() == msgId);

      if (!exists) {
        final List<dynamic> updated = [newData, ...current];
        if (updated.length > 1000) {
          updated.removeLast(); // Keep cache size manageable
        }
        saveMessages(currentUserId, chatId, updated);
      }

      // Live broadcast for 0-latency chat updates
      _liveMessageController.add({
        'chatId': chatId,
        'message': newData,
        'is_remote': true,
      });
    }
  }

  void _handleGroupMessageUpdate(PostgresChangePayload payload) {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    if (payload.eventType == PostgresChangeEvent.delete) {
      final oldId = payload.oldRecord['id']?.toString();
      if (oldId != null) _removeMessageFromCache(currentUserId, oldId);
      return;
    }

    final newData = payload.newRecord;
    final groupId = newData['group_id'];
    if (groupId != null) {
      final List<dynamic> current = getCachedMessages(currentUserId, groupId);
      final String msgId = newData['id'].toString();
      final bool exists = current.any((m) => m['id'].toString() == msgId);
      if (!exists) {
        final List<dynamic> updated = [newData, ...current];
        if (updated.length > 1000) updated.removeLast();
        saveMessages(currentUserId, groupId, updated);
      }
    }
  }

  void _removeMessageFromCache(String userId, String messageId) {
    final keys = _messageBox.keys.where((k) => k.toString().startsWith('${userId}_'));
    for (var key in keys) {
      final List<dynamic>? current = _messageBox.get(key);
      if (current != null) {
        final updated = current.where((m) => m['id'].toString() != messageId).toList();
        if (updated.length < current.length) {
          _messageBox.put(key, updated);
        }
      }
    }
  }

  Future<void> deleteCachedMessage(String userId, String chatId, String messageId) async {
    final List<dynamic> current = getCachedMessages(userId, chatId);
    final updated = current.where((m) => m['id'].toString() != messageId).toList();
    if (updated.length < current.length) {
      await saveMessages(userId, chatId, updated);
    }
  }

  // Speed optimization: Tap inside should be fast
  // This is where we provide the local data instantly
  Future<List<dynamic>> getMessagesForChat(String userId, String chatId,
      {bool isGroup = false}) async {
    return getCachedMessages(userId, chatId);
  }
}
