import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

part 'whats_app_groups_provider.g.dart';

// Models
class ChatConversation {
  final String id;
  final String name;
  final String? imageUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isGroup;
  final String? lastSenderId;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatConversation({
    required this.id,
    required this.name,
    this.imageUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.isGroup,
    this.lastSenderId,
    this.isOnline = false,
    this.lastSeen,
  });

  factory ChatConversation.fromGroupJson(Map<String, dynamic> json) {
    // This expects the 'groups' join result from group_members select
    final groupData = json['groups'] ?? json;
    return ChatConversation(
      id: groupData['id'] ?? '',
      name: groupData['name'] ?? 'Unnamed Group',
      imageUrl: groupData['group_image_url'],
      lastMessage: groupData['last_message'],
      lastMessageTime: groupData['last_message_time'] != null
          ? DateTime.parse(groupData['last_message_time'])
          : null,
      unreadCount: 0, // Fetched dynamically
      isGroup: true,
    );
  }

  factory ChatConversation.fromPersonalJson(Map<String, dynamic> json,
      {required String currentUserId,
      required Map<String, dynamic>? otherProfile}) {
    // This expects a row from the 'conversations' table
    return ChatConversation(
      id: otherProfile?['user_id'] ?? '',
      name: otherProfile?['name'] ?? 'Unknown',
      imageUrl: otherProfile?['profile_image_url'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'])
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      unreadCount: json['unread_count'] ?? 0,
      isGroup: false,
      lastSenderId: json['last_sender_id'] as String?,
    );
  }
}

// Provider for Supabase Client
@riverpod
SupabaseClient supabaseClient(Ref ref) => SupaFlow.client;

// Provider for Current User ID
@riverpod
String currentUserId(Ref ref) {
  return ref.watch(supabaseClientProvider).auth.currentUser?.id ?? '';
}

@riverpod
Future<String?> currentProfileId(Ref ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId.isEmpty) return null;

  final supabase = ref.watch(supabaseClientProvider);
  try {
    final response = await supabase
        .from('profile')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    return response?['id'] as String?;
  } catch (e) {
    return null;
  }
}

// Combined Conversations Provider
@riverpod
class Conversations extends _$Conversations {
  late SupabaseClient _supabase;
  RealtimeChannel? _combinedChannel;
  Timer? _debounceTimer;

  @override
  FutureOr<List<ChatConversation>> build() async {
    _supabase = ref.watch(supabaseClientProvider);
    final userId = ref.watch(currentUserIdProvider);

    if (userId.isEmpty) return [];

    // Setup real-time subscriptions
    _setupRealtimeSubscriptions(userId);

    // Cleanup on dispose
    ref.onDispose(() {
      _combinedChannel?.unsubscribe();
      _debounceTimer?.cancel();
    });

    // Fetch initial data
    final profileId = await ref.watch(currentProfileIdProvider.future);
    return _fetchConversations(userId, profileId);
  }

  void _setupRealtimeSubscriptions(String userId) {
    // Single robust channel for all conversation-related updates
    _combinedChannel = _supabase
        .channel('public:conversations_updates')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'groups',
          callback: (payload) => _debouncedRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          callback: (payload) => _debouncedRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) => _debouncedRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_messages',
          callback: (payload) => _debouncedRefresh(),
        )
        .subscribe();
  }

  void _debouncedRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });
  }

  Future<List<ChatConversation>> _fetchConversations(
      String userId, String? profileId) async {
    try {
      // Fetch groups and personal chats in parallel
      final groupsFuture = _fetchGroups(userId, profileId);
      final personalFuture = _fetchPersonalChats(userId);

      final results = await Future.wait([groupsFuture, personalFuture]);

      final groups = results[0] as List<ChatConversation>;
      final personal = results[1] as List<ChatConversation>;

      // Combine and sort by last message time
      final combined = [...groups, ...personal];
      combined.sort((a, b) {
        final aTime = a.lastMessageTime;
        final bTime = b.lastMessageTime;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      return combined;
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  Future<List<ChatConversation>> _fetchGroups(
      String userId, String? profileId) async {
    try {
      // Get groups where user is a member
      var query = _supabase.from('group_members').select('''
            group_id,
            groups!inner (
              id,
              name,
              group_image_url,
              last_message,
              last_message_time,
              updated_at
            )
          ''');

      if (profileId != null) {
        query = query.or('user_id.eq.$userId,profile_id.eq.$profileId');
      } else {
        query = query.eq('user_id', userId);
      }

      final response = await query.eq('is_active', true).order(
          'last_message_time',
          referencedTable: 'groups',
          ascending: false);

      final groups = <ChatConversation>[];

      for (var item in response) {
        final groupData = item['groups'];
        if (groupData != null) {
          final unreadCount =
              await _getGroupUnreadCount(groupData['id'], userId);

          groups.add(ChatConversation(
            id: groupData['id'],
            name: groupData['name'] ?? 'Unnamed Group',
            imageUrl: groupData['group_image_url'],
            lastMessage: groupData['last_message'],
            lastMessageTime: groupData['last_message_time'] != null
                ? DateTime.parse(groupData['last_message_time'])
                : null,
            unreadCount: unreadCount,
            isGroup: true,
          ));
        }
      }

      return groups;
    } catch (e) {
      return [];
    }
  }

  Future<List<ChatConversation>> _fetchPersonalChats(String userId) async {
    try {
      // Get conversations from conversations table
      final response = await _supabase
          .from('conversations')
          .select('*')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .order('updated_at', ascending: false);

      if (response.isEmpty) return [];

      final userIds = <String>{};
      for (final conv in response) {
        userIds.add(conv['user1_id']);
        userIds.add(conv['user2_id']);
      }

      // Fetch user profiles for all participants
      final profilesResponse = await _supabase
          .from('profile')
          .select('user_id, name, profile_image_url')
          .inFilter('user_id', userIds.toList());

      final profileMap = <String, Map<String, dynamic>>{};
      for (final profile in profilesResponse) {
        profileMap[profile['user_id']] = profile;
      }

      final chats = <ChatConversation>[];
      for (var item in response) {
        final otherUserId =
            item['user1_id'] == userId ? item['user2_id'] : item['user1_id'];
        final otherProfile = profileMap[otherUserId];

        chats.add(ChatConversation.fromPersonalJson(
          item,
          currentUserId: userId,
          otherProfile: otherProfile,
        ));
      }

      return chats;
    } catch (e) {
      return [];
    }
  }

  Future<int> _getGroupUnreadCount(String groupId, String userId) async {
    try {
      final lastRead = await _supabase
          .from('group_members')
          .select('last_read_at')
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      if (lastRead == null) return 0;

      final lastReadTime = lastRead['last_read_at'];

      var query = _supabase
          .from('group_messages')
          .select('*')
          .eq('group_id', groupId)
          .neq('sender_id', userId);

      if (lastReadTime != null) {
        query = query.gt('created_at', lastReadTime);
      }

      final countResponse = await query.count(CountOption.exact);
      return countResponse.count;
    } catch (e) {
      return 0;
    }
  }

  // Mark conversation as read
  Future<void> markAsRead(String conversationId, bool isGroup) async {
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId.isEmpty) return;

      if (isGroup) {
        await _supabase
            .from('group_members')
            .update({'last_read_at': DateTime.now().toIso8601String()})
            .eq('group_id', conversationId)
            .eq('user_id', userId);
      } else {
        // Update messages read status
        await _supabase
            .from('messages')
            .update({'is_read': true})
            .eq('sender_id', conversationId)
            .eq('receiver_id', userId)
            .eq('is_read', false);

        // Reset unread count in conversations table
        // We try both combinations since we don't know who is user1 and who is user2
        await _supabase
            .from('conversations')
            .update({'unread_count': 0})
            .eq('user1_id', userId)
            .eq('user2_id', conversationId);

        await _supabase
            .from('conversations')
            .update({'unread_count': 0})
            .eq('user1_id', conversationId)
            .eq('user2_id', userId);
      }

      ref.invalidateSelf();
    } catch (e) {
      // Handle error
    }
  }
}
