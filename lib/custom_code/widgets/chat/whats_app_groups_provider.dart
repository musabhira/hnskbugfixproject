import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';
import 'package:pocket_mates_app/custom_code/services/local_sync_server.dart';

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
    this.isNotification = false,
    this.notificationType,
    this.sourceId,
    this.hasStatus = false,
    this.statusData,
    this.isTool = false,
    this.toolTitle,
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

  factory ChatConversation.fromPersonalJson(
    Map<String, dynamic> json, {
    required String currentUserId,
    required Map<String, dynamic>? otherProfile,
    bool hasStatus = false,
    List<Map<String, dynamic>>? statusData,
  }) {
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
      unreadCount: (json['last_sender_id'] == currentUserId)
          ? 0
          : (json['unread_count'] ?? 0),
      isGroup: false,
      lastSenderId: json['last_sender_id'] as String?,
      hasStatus: hasStatus,
      statusData: statusData,
    );
  }
  factory ChatConversation.fromNotification(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      name: 'Notification',
      lastMessage: json['message'],
      lastMessageTime: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      unreadCount: 1,
      isGroup: false,
      isNotification: true,
      notificationType: json['type'],
      sourceId: json['source_id'],
    );
  }

  final bool isNotification;
  final String? notificationType;
  final String? sourceId;
  final bool hasStatus;
  final List<Map<String, dynamic>>? statusData;
  final bool isTool;
  final String? toolTitle;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'lastSenderId': lastSenderId,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'isNotification': isNotification,
      'notificationType': notificationType,
      'sourceId': sourceId,
      'hasStatus': hasStatus,
      'statusData': statusData,
      'isTool': isTool,
      'toolTitle': toolTitle,
    };
  }

  factory ChatConversation.fromJson(Map<dynamic, dynamic> jsonMap) {
    final json = Map<String, dynamic>.from(jsonMap);
    return ChatConversation(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isGroup: json['isGroup'] ?? false,
      lastSenderId: json['lastSenderId'],
      isOnline: json['isOnline'] ?? false,
      lastSeen:
          json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      isNotification: json['isNotification'] ?? false,
      notificationType: json['notificationType'],
      sourceId: json['sourceId'],
      hasStatus: json['hasStatus'] ?? false,
      statusData: json['statusData'] != null
          ? (json['statusData'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : null,
      isTool: json['isTool'] ?? false,
      toolTitle: json['toolTitle'],
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

    try {
      // Fetch initial data
      final profileId = await ref.watch(currentProfileIdProvider.future);

      // Try to load from cache first for instant display
      List<ChatConversation> cached = [];
      try {
        cached = await _loadFromCache(userId);
      } catch (e) {
        debugPrint('Cache load failed: $e');
      }

      if (cached.isNotEmpty) {
        // Fetch fresh data in background
        _fetchConversations(userId, profileId).then((fresh) {
          if (ref.mounted) {
            state = AsyncValue.data(fresh);
          }
        }).catchError((e) {
          debugPrint('Error fetching background conversations: $e');
        });
        return cached;
      }

      return await _fetchConversations(userId, profileId);
    } catch (e) {
      debugPrint('Unhandled error in Conversations build: $e');
      // If everything fails, return empty list instead of breaking UI
      return [];
    }
  }

  Future<List<ChatConversation>> _loadFromCache(String userId) async {
    return LocalSyncServer().getCachedConversations();
  }

  Future<void> _saveToCache(String userId, List<ChatConversation> list) async {
    await LocalSyncServer().saveConversations(list);
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
          table: 'statuses',
          callback: (payload) => _debouncedRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications', // Listen to notifications table
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
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (ref.mounted) {
        // Manually refresh instead of invalidating to prevent loading flash
        final userId = ref.read(currentUserIdProvider);
        if (userId.isEmpty) return;

        try {
          final profileId = await ref.read(currentProfileIdProvider.future);
          final fresh = await _fetchConversations(userId, profileId);
          state = AsyncValue.data(fresh);
        } catch (e) {
          debugPrint('Error refreshing conversations: $e');
        }
      }
    });
  }

  Future<List<ChatConversation>> _fetchConversations(
      String userId, String? profileId) async {
    try {
      debugPrint('Fetching conversations for user: $userId');
      // Fetch groups and personal chats in parallel
      final groupsFuture = _fetchGroups(userId, profileId);
      final personalFuture = _fetchPersonalChats(userId);
      final notificationsFuture =
          _fetchNotifications(userId); // Fetch notifications

      final results = await Future.wait(
          [groupsFuture, personalFuture, notificationsFuture]);

      final groups = results[0];
      final personal = results[1];
      final notifications = results[2];

      debugPrint(
          'Fetched ${groups.length} groups, ${personal.length} personal chats, ${notifications.length} notifications');

      // Load Favorited Tools
      final prefs = await SharedPreferences.getInstance();
      final favoritedToolsJson =
          prefs.getString('favorited_tools_$userId') ?? '[]';
      final favoritedTools = jsonDecode(favoritedToolsJson) as List;
      final toolChats = favoritedTools.map((t) {
        return ChatConversation(
          id: 'tool_${t['title']}',
          name: t['title'] ?? 'Tool',
          lastMessage: 'Tap to open your favorited tool',
          lastMessageTime: DateTime(2000), // Always keep at bottom of list
          unreadCount: 0,
          isGroup: false,
          isTool: true,
          toolTitle: t['title'],
        );
      }).toList();

      // Combine and sort by last message time
      final combined = [...notifications, ...groups, ...personal, ...toolChats];
      combined.sort((a, b) {
        // Notifications might want to be always on top? Or mixed in by time.
        // Let's mix by time for now as requested "normal chat list like".
        final aTime = a.lastMessageTime;
        final bTime = b.lastMessageTime;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      // Save to cache
      _saveToCache(userId, combined);

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

      final groupList = (response as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      // Fetch all unread counts in parallel for all groups
      final List<Future<ChatConversation?>> conversationFutures =
          groupList.map((item) async {
        final groupData = _safeGet(item['groups']);
        if (groupData == null) return null;

        // Fetch unread count and statuses in parallel
        final results = await Future.wait([
          _getGroupUnreadCount(groupData['id'], userId),
          _getGroupStatuses(groupData['id']),
        ]);

        final unreadCount = results[0] as int;
        final statusList = results[1] as List<Map<String, dynamic>>;

        return ChatConversation(
          id: groupData['id'],
          name: groupData['name'] ?? 'Unnamed Group',
          imageUrl: groupData['group_image_url'],
          lastMessage: groupData['last_message'],
          lastMessageTime: groupData['last_message_time'] != null
              ? DateTime.parse(groupData['last_message_time'])
              : null,
          unreadCount: unreadCount,
          isGroup: true,
          hasStatus: statusList.isNotEmpty,
          statusData: statusList,
        );
      }).toList();

      final List<ChatConversation?> conversations =
          await Future.wait(conversationFutures);
      return conversations.whereType<ChatConversation>().toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getGroupStatuses(String groupId) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('statuses')
          .select('*, profile:profile_id(*)')
          .eq('mentioned_group_id', groupId)
          .eq('is_active', true)
          .gt('expires_at', now)
          .order('created_at', ascending: true);
      return (response as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
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
          .select('id, user_id, name, profile_image_url')
          .inFilter('user_id', userIds.toList());

      final profileMap = <String, Map<String, dynamic>>{};
      for (final profile in profilesResponse) {
        profileMap[profile['user_id']] = Map<String, dynamic>.from(profile);
      }

      // Fetch statuses for these profiles
      final profileIds = profileMap.values
          .map((p) => p['id']?.toString())
          .whereType<String>()
          .toList();

      final statusMap = <String, List<Map<String, dynamic>>>{};
      if (profileIds.isNotEmpty) {
        final now = DateTime.now().toIso8601String();
        final statusesResponse = await _supabase
            .from('statuses')
            .select('*, profile:profile_id(*)')
            .inFilter('profile_id', profileIds)
            .eq('is_active', true)
            .gt('expires_at', now)
            .order('created_at', ascending: true);

        for (final status in statusesResponse) {
          final pid = status['profile_id'].toString();
          statusMap
              .putIfAbsent(pid, () => [])
              .add(Map<String, dynamic>.from(status));
        }
      }

      final chats = <ChatConversation>[];
      for (var item in response) {
        final otherUserId =
            item['user1_id'] == userId ? item['user2_id'] : item['user1_id'];
        final otherProfile = profileMap[otherUserId];
        final otherProfileId = otherProfile?['id']?.toString();

        final userStatusData =
            otherProfileId != null ? statusMap[otherProfileId] : null;

        chats.add(ChatConversation.fromPersonalJson(
          Map<String, dynamic>.from(item),
          currentUserId: userId,
          otherProfile: otherProfile,
          hasStatus: userStatusData?.isNotEmpty ?? false,
          statusData: userStatusData,
        ));
      }

      return chats;
    } catch (e) {
      return [];
    }
  }

  Future<List<ChatConversation>> _fetchNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data
          .map((json) => ChatConversation.fromNotification(
              Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> _getGroupUnreadCount(String groupId, String userId) async {
    try {
      final response = await _supabase
          .from('group_members')
          .select('last_read_at')
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      final lastRead =
          response != null ? Map<String, dynamic>.from(response) : null;

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

  Future<void> dismissNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);
      ref.invalidateSelf();
    } catch (e) {
      print('Error dismissing notification: $e');
    }
  }

  // Helper for safe data extraction from Supabase joins
  Map<String, dynamic>? _safeGet(dynamic input) {
    if (input == null) return null;
    if (input is Map) return Map<String, dynamic>.from(input);
    if (input is List && input.isNotEmpty) {
      if (input.first is Map) return Map<String, dynamic>.from(input.first);
    }
    return null;
  }
}
