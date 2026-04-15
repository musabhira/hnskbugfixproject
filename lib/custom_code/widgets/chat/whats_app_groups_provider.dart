import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
  final int otherUnreadCount;
  final bool isGroup;
  final String? lastSenderId;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool isNotification;
  final String? notificationType;
  final String? sourceId;
  final bool hasStatus;
  final List<Map<String, dynamic>>? statusData;
  final bool isTool;
  final String? toolTitle;
  final bool isPinned;
  final bool isActiveTimer;
  final String? taskTitle;
  final String? teamName;
  final DateTime? timerStartTime;
  final Map<String, dynamic>? teamData;

  ChatConversation({
    required this.id,
    required this.name,
    this.imageUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.otherUnreadCount = 0,
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
    this.isPinned = false,
    this.isActiveTimer = false,
    this.taskTitle,
    this.teamName,
    this.timerStartTime,
    this.teamData,
  });

  factory ChatConversation.fromActiveTimer(Map<String, dynamic> json) {
    return ChatConversation(
      id: 'timer_${json['id']}',
      name: json['teams']?['name'] ?? 'Task Timer',
      taskTitle: json['title'],
      teamName: json['teams']?['name'],
      timerStartTime: json['timer_started_at'] != null
          ? DateTime.parse(json['timer_started_at']).toLocal()
          : null,
      teamData: json['teams'],
      lastMessage: 'Live Tracking: ${json['title']}',
      lastMessageTime: json['timer_started_at'] != null
          ? DateTime.parse(json['timer_started_at'])
          : DateTime.now(),
      unreadCount: 0,
      isGroup: false,
      isActiveTimer: true,
      isPinned: true, // Show at top
    );
  }

  factory ChatConversation.fromGroupJson(Map<String, dynamic> json,
      {bool isPinned = false}) {
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
      isPinned: isPinned,
    );
  }

  factory ChatConversation.fromPersonalJson(
    Map<String, dynamic> json, {
    required String currentUserId,
    required Map<String, dynamic>? otherProfile,
    bool hasStatus = false,
    List<Map<String, dynamic>>? statusData,
    bool isPinned = false,
  }) {
    // This expects a row from the 'conversations' table
    return ChatConversation(
      id: otherProfile?['user_id'] ??
          (json['user1_id'] == currentUserId
              ? json['user2_id']
              : json['user1_id']) ??
          '',
      name: otherProfile?['name'] ?? 'Unknown User',
      imageUrl: otherProfile?['profile_image_url'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time']).toLocal()
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at']).toLocal()
              : null,
      unreadCount: (json['last_sender_id'] == currentUserId)
          ? 0
          : (json['unread_count'] ?? 0),
      otherUnreadCount: (json['last_sender_id'] == currentUserId)
          ? (json['unread_count'] ?? 0)
          : 0,
      isGroup: false,
      lastSenderId: json['last_sender_id'] as String?,
      hasStatus: hasStatus,
      statusData: statusData,
      isPinned: isPinned,
    );
  }

  factory ChatConversation.fromNotification(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] ?? '',
      name: 'Notification',
      lastMessage: json['message'],
      lastMessageTime: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      unreadCount: 1,
      isGroup: false,
      isNotification: true,
      notificationType: json['type'],
      sourceId: json['source_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
      'otherUnreadCount': otherUnreadCount,
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
      'isPinned': isPinned,
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
      otherUnreadCount: json['otherUnreadCount'] ?? 0,
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
      isPinned: json['isPinned'] ?? false,
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

    List<ChatConversation> cached = [];
    try {
      // Fetch initial data
      final profileId = await ref.watch(currentProfileIdProvider.future);

      // Try to load from cache first for instant display
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
      if (cached.isNotEmpty) return cached;
      return [];
    }
  }

  Future<List<ChatConversation>> _loadFromCache(String userId) async {
    return LocalSyncServer().getCachedConversations(userId);
  }

  Future<void> _saveToCache(String userId, List<ChatConversation> list) async {
    await LocalSyncServer().saveConversations(userId, list);
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
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'team_tasks', // Listen for timer start/stop
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
      final timersFuture = _fetchActiveTimers(userId);

      final results = await Future.wait(
          [groupsFuture, personalFuture, notificationsFuture, timersFuture]);

      final List<ChatConversation> groups = results[0];
      final List<ChatConversation> personal = results[1];
      final List<ChatConversation> notifications = results[2];
      final List<ChatConversation> activeTimers = results[3];

      debugPrint(
          'Fetched ${groups.length} groups, ${personal.length} personal chats, ${notifications.length} notifications');

      final prefs = await SharedPreferences.getInstance();

      // Load Pinned Status
      final pinnedIds =
          prefs.getStringList('pinned_conversations_$userId') ?? [];

      // Load Favorited Tools
      final favoritedToolsJson =
          prefs.getString('favorited_tools_$userId') ?? '[]';
      final favoritedTools = jsonDecode(favoritedToolsJson) as List;
      final toolChats = favoritedTools.map((t) {
        final timeAddedStr = t['timeAdded'];
        final timeAdded = timeAddedStr != null
            ? DateTime.parse(timeAddedStr)
            : DateTime(2000);

        return ChatConversation(
          id: 'tool_${t['title']}',
          name: t['title'] ?? 'Tool',
          lastMessage: 'Tap to open your favorited tool',
          lastMessageTime: timeAdded,
          unreadCount: 0,
          isGroup: false,
          isTool: true,
          toolTitle: t['title'],
          isPinned: pinnedIds.contains('tool_${t['title']}'),
        );
      }).toList();

      // Update isPinned for groups and personal chats
      final List<ChatConversation> updatedGroups = groups.map((c) {
        return ChatConversation(
          id: c.id,
          name: c.name,
          imageUrl: c.imageUrl,
          lastMessage: c.lastMessage,
          lastMessageTime: c.lastMessageTime,
          unreadCount: c.unreadCount,
          isGroup: c.isGroup,
          lastSenderId: c.lastSenderId,
          isOnline: c.isOnline,
          lastSeen: c.lastSeen,
          isNotification: c.isNotification,
          notificationType: c.notificationType,
          sourceId: c.sourceId,
          hasStatus: c.hasStatus,
          statusData: c.statusData,
          isTool: c.isTool,
          toolTitle: c.toolTitle,
          isPinned: pinnedIds.contains(c.id),
        );
      }).toList();

      final List<ChatConversation> updatedPersonal = personal.map((c) {
        return ChatConversation(
          id: c.id,
          name: c.name,
          imageUrl: c.imageUrl,
          lastMessage: c.lastMessage,
          lastMessageTime: c.lastMessageTime,
          unreadCount: c.unreadCount,
          isGroup: c.isGroup,
          lastSenderId: c.lastSenderId,
          isOnline: c.isOnline,
          lastSeen: c.lastSeen,
          isNotification: c.isNotification,
          notificationType: c.notificationType,
          sourceId: c.sourceId,
          hasStatus: c.hasStatus,
          statusData: c.statusData,
          isTool: c.isTool,
          toolTitle: c.toolTitle,
          isPinned: pinnedIds.contains(c.id),
        );
      }).toList();

      // Combine and sort
      final combined = [
        ...notifications,
        ...activeTimers,
        ...updatedGroups,
        ...updatedPersonal,
        ...toolChats
      ];
      combined.sort((a, b) {
        // Pinned status always on top
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;

        // Otherwise by time
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
      rethrow;
    }
  }

  Future<List<ChatConversation>> _fetchGroups(
      String userId, String? profileId) async {
    try {
      // Get groups where user is a member
      var query = _supabase.from('group_members').select('''
            group_id,
            last_read_at,
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

      final response = await query
          .eq('is_active', true)
          .order('last_message_time',
              referencedTable: 'groups', ascending: false);

      final groupList = (response as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (groupList.isEmpty) return [];

      // Fetch statuses for ALL groups in one go
      final groupIds =
          groupList.map((item) => item['group_id'].toString()).toList();
      final allStatuses = await _getAllGroupsStatuses(groupIds);

      final statusMap = <String, List<Map<String, dynamic>>>{};
      for (var status in allStatuses) {
        final gId = status['mentioned_group_id']?.toString();
        if (gId != null) {
          statusMap.putIfAbsent(gId, () => []).add(status);
        }
      }

      // Fetch all unread counts in parallel (still separate, but we removed one query per group)
      final List<Future<ChatConversation?>> conversationFutures =
          groupList.map((item) async {
        final groupData = _safeGet(item['groups']);
        if (groupData == null) return null;

        final gId = groupData['id'];
        final lastReadTime = item['last_read_at'];

        final unreadCount =
            await _getGroupUnreadCountOnly(gId, userId, lastReadTime);
        final statusList = statusMap[gId] ?? [];

        return ChatConversation(
          id: gId,
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
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _getAllGroupsStatuses(
      List<String> groupIds) async {
    if (groupIds.isEmpty) return [];
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('statuses')
          .select('*, profile:profile_id(*)')
          .inFilter('mentioned_group_id', groupIds)
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

  Future<int> _getGroupUnreadCountOnly(
      String groupId, String userId, String? lastReadTime) async {
    try {
      var query = _supabase
          .from('group_messages')
          .select('id')
          .eq('group_id', groupId)
          .neq('sender_id', userId);

      if (lastReadTime != null && lastReadTime.isNotEmpty) {
        query = query.gt('created_at', lastReadTime);
      }

      final res = await query.count(CountOption.exact);
      return res.count;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
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
      rethrow;
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
      rethrow;
    }
  }

  Future<List<ChatConversation>> _fetchActiveTimers(String userId) async {
    try {
      final response = await _supabase
          .from('team_tasks')
          .select('*, teams(id, name)')
          .eq('assigned_to', userId)
          .not('timer_started_at', 'is', null);

      final data = response as List<dynamic>;
      return data
          .map((json) => ChatConversation.fromActiveTimer(
              Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching active timers: $e');
      return [];
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
        // conversationId here is the other user's ID
        // We need to find the specific conversation between the two users
        await _supabase.from('conversations').update({'unread_count': 0}).or(
            'and(user1_id.eq.$userId,user2_id.eq.$conversationId),and(user1_id.eq.$conversationId,user2_id.eq.$userId)');
      }
      _debouncedRefresh();
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> togglePin(String conversationId) async {
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final pinnedIds =
          prefs.getStringList('pinned_conversations_$userId') ?? [];

      if (pinnedIds.contains(conversationId)) {
        pinnedIds.remove(conversationId);
      } else {
        pinnedIds.add(conversationId);
      }

      await prefs.setStringList('pinned_conversations_$userId', pinnedIds);

      // Refresh to update UI
      _debouncedRefresh();
    } catch (e) {
      debugPrint('Error toggling pin: $e');
    }
  }

  Future<void> dismissNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);
      _debouncedRefresh();
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
