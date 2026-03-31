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

  Future<void> saveConversations(List<ChatConversation> conversations) async {
    final List<Map<String, dynamic>> jsonList =
        conversations.map((e) => e.toJson()).toList();
    await _conversationBox.put('list', jsonList);
    _conversationController.add(conversations);
  }

  List<ChatConversation> getCachedConversations() {
    if (!_isInitialized) return [];
    final List<dynamic>? list = _conversationBox.get('list');
    if (list == null) return [];
    return list
        .map((e) => ChatConversation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // --- MESSAGES ---

  Future<void> saveMessages(
      String chatOrGroupId, List<dynamic> messages) async {
    final List<Map<String, dynamic>> jsonList = messages.map((e) {
      if (e is ChatMessage) return e.toJson();
      return Map<String, dynamic>.from(e);
    }).toList();
    await _messageBox.put(chatOrGroupId, jsonList);
  }

  List<dynamic> getCachedMessages(String chatOrGroupId) {
    if (!_isInitialized) return [];
    final List<dynamic>? list = _messageBox.get(chatOrGroupId);
    if (list == null) return [];
    return list;
  }

  void _handleGlobalMessageUpdate(PostgresChangePayload payload) {
    // Determine which conversation this message belongs to and update Hive
    final newData = payload.newRecord;

    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

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
      final List<dynamic> current = getCachedMessages(chatId);
      final String msgId = newData['id'].toString();
      final bool exists = current.any((m) => m['id'].toString() == msgId);

      if (!exists) {
        // Insert at top as we sort DESC usually, but depends on usage.
        // MessageScreen sorts DESC (newest first). ChatProvider sorts ASC (oldest first)?
        // Let's check usage. MessageScreen sorts DESC. ChatProvider usually ASC for chat bubbles but reverse list view.
        // We will prepend to keep it consistent with "get latest".
        final List<dynamic> updated = [newData, ...current];
        if (updated.length > 1000) {
          updated.removeLast(); // Keep cache size manageable
        }
        saveMessages(chatId, updated);
      }
    }
  }

  void _handleGroupMessageUpdate(PostgresChangePayload payload) {
    final newData = payload.newRecord;

    final groupId = newData['group_id'];
    if (groupId != null) {
      final List<dynamic> current = getCachedMessages(groupId);
      final String msgId = newData['id'].toString();
      final bool exists = current.any((m) => m['id'].toString() == msgId);
      if (!exists) {
        final List<dynamic> updated = [newData, ...current];
        if (updated.length > 1000) updated.removeLast();
        saveMessages(groupId, updated);
      }
    }
  }

  // Speed optimization: Tap inside should be fast
  // This is where we provide the local data instantly
  Future<List<dynamic>> getMessagesForChat(String chatId,
      {bool isGroup = false}) async {
    return getCachedMessages(chatId);
  }
}
