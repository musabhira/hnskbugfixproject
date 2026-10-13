import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart'
    as groups_provider;
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

typedef ChatConversation = groups_provider.ChatConversation;

/// 🦁 Dedicated Supabase Provider for Kids & Students Chat
/// Strictly queries isolated tables:
/// - kids_conversations
/// - kids_groups
/// - kids_group_members
/// - kids_group_messages
/// - kids_messages
/// Zero overlap with adult chat tables!
final kidsConversationsProvider =
    AsyncNotifierProvider<KidsConversationsNotifier, List<ChatConversation>>(
  KidsConversationsNotifier.new,
);

class KidsConversationsNotifier extends AsyncNotifier<List<ChatConversation>> {
  late SupabaseClient _supabase;
  RealtimeChannel? _realtimeChannel;
  Timer? _debounceTimer;

  static const String animalMentorId = 'mentor_animal_king_lion';
  static const String animalMentorName = 'King';

  @override
  FutureOr<List<ChatConversation>> build() async {
    _supabase = SupaFlow.client;
    final user = _supabase.auth.currentUser;
    final userId = user?.id ?? '';

    if (userId.isEmpty) return [];

    _setupRealtime(userId);

    ref.onDispose(() {
      _realtimeChannel?.unsubscribe();
      _debounceTimer?.cancel();
    });

    return await _fetchKidsConversations(userId);
  }

  void _setupRealtime(String userId) {
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = _supabase
        .channel('public:kids_chat_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'kids_conversations',
          callback: (_) => _debouncedRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'kids_groups',
          callback: (_) => _debouncedRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'kids_group_messages',
          callback: (_) => _debouncedRefresh(),
        )
        .subscribe();
  }

  void _debouncedRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final list = await _fetchKidsConversations(user.id);
        state = AsyncValue.data(list);
      }
    });
  }

  Future<void> refreshNow() async {
    _debounceTimer?.cancel();
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final list = await _fetchKidsConversations(user.id);
      state = AsyncValue.data(list);
    }
  }

  Future<List<ChatConversation>> _fetchKidsConversations(String userId) async {
    try {
      final results = await Future.wait([
        _fetchKidsGroups(userId),
        _fetchKidsPersonalChats(userId),
      ]);

      final List<ChatConversation> groups = results[0];
      final List<ChatConversation> personal = results[1];

      final prefs = await SharedPreferences.getInstance();
      final pinnedIds =
          prefs.getStringList('kids_pinned_conversations_$userId') ?? [];

      final List<ChatConversation> combined = [];

      // Add Animal Mentor (Official mentor for kids)
      combined.add(ChatConversation(
        id: animalMentorId,
        name: animalMentorName,
        imageUrl: null,
        lastMessage:
            '🐾 Roar! Welcome to your Kids Adventure. Climb the mountain and practice English daily!',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        isGroup: false,
        isOnline: true,
        isPinned: true,
      ));

      // Add Pinned and Unpinned Kids Groups
      for (final g in groups) {
        combined.add(ChatConversation(
          id: g.id,
          name: g.name,
          imageUrl: g.imageUrl,
          lastMessage: g.lastMessage,
          lastMessageTime: g.lastMessageTime,
          unreadCount: g.unreadCount,
          isGroup: true,
          isPinned: pinnedIds.contains(g.id),
        ));
      }

      // Add Personal Chats (Filter out any adult robots)
      for (final p in personal) {
        if (!PocketKidsService.isAllowedKidMateId(p.id)) continue;
        combined.add(ChatConversation(
          id: p.id,
          name: p.name,
          imageUrl: p.imageUrl,
          lastMessage: p.lastMessage,
          lastMessageTime: p.lastMessageTime,
          unreadCount: p.unreadCount,
          isGroup: false,
          avatarConfig: p.avatarConfig,
          isPinned: pinnedIds.contains(p.id),
        ));
      }

      // Include accepted animal companions and kid friends from PocketKidsService
      final existingIds = combined.map((c) => c.id).toSet();
      for (final friendId in PocketKidsService.friendIds) {
        if (!PocketKidsService.isAllowedKidMateId(friendId)) continue;
        if (!existingIds.contains(friendId)) {
          final mate = PocketKidsService.getKidMateById(friendId);
          if (mate != null) {
            combined.add(ChatConversation(
              id: mate.id,
              name: '${mate.name} ${mate.avatar}',
              imageUrl: null,
              lastMessage: 'Ready to learn English together!',
              lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
              unreadCount: 0,
              isGroup: false,
              isOnline: true,
              isPinned: false,
            ));
            existingIds.add(mate.id);
          }
        }
      }

      // If empty personal chats, seed top friendly animals for kids to chat with!
      if (personal.isEmpty && PocketKidsService.friendIds.isEmpty) {
        for (final bot in PocketKidsRobotsData.robotsAndHomies.take(5)) {
          combined.add(ChatConversation(
            id: bot.id,
            name: bot.name,
            imageUrl: null,
            lastMessage:
                'Hi! I am your Animal Buddy ${bot.avatar}. Tap to speak with me!',
            lastMessageTime: DateTime.now().subtract(Duration(minutes: bot.dayLevel * 10)),
            unreadCount: 0,
            isGroup: false,
            isOnline: true,
            isPinned: false,
          ));
        }
      }

      // STRICT FILTER: Absolutely no adult robot or disallowed peer can ever enter kids chat list
      combined.removeWhere((c) {
        if (c.id == animalMentorId) return false;
        if (c.id.startsWith('kid_bot_')) return false;
        if (c.isGroup) return false;
        return !PocketKidsService.isAllowedKidMateId(c.id);
      });

      combined.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        final aTime = a.lastMessageTime ?? DateTime(0);
        final bTime = b.lastMessageTime ?? DateTime(0);
        return bTime.compareTo(aTime);
      });

      return combined;
    } catch (e) {
      debugPrint('Error fetching kids conversations: $e');
      return [];
    }
  }

  Future<List<ChatConversation>> _fetchKidsGroups(String userId) async {
    try {
      final response = await _supabase.from('kids_group_members').select('''
            group_id,
            last_read_at,
            kids_groups!inner (
              id,
              name,
              group_image_url,
              last_message,
              last_message_time
            )
          ''').eq('user_id', userId).eq('is_active', true);

      final list = (response as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      return list.map((item) {
        final g = item['kids_groups'] as Map<String, dynamic>? ?? {};
        return ChatConversation(
          id: g['id']?.toString() ?? '',
          name: g['name']?.toString() ?? 'Kids Gang',
          imageUrl: g['group_image_url']?.toString(),
          lastMessage: g['last_message']?.toString(),
          lastMessageTime: g['last_message_time'] != null
              ? DateTime.tryParse(g['last_message_time'].toString())
              : null,
          unreadCount: 0,
          isGroup: true,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching kids groups: $e');
      return [];
    }
  }

  Future<List<ChatConversation>> _fetchKidsPersonalChats(String userId) async {
    try {
      final response = await _supabase
          .from('kids_conversations')
          .select('*')
          .or('user1_id.eq.$userId,user2_id.eq.$userId')
          .order('updated_at', ascending: false)
          .limit(50);

      if (response.isEmpty) return [];

      final otherUserIds = <String>{};
      for (final conv in response) {
        final u1 = conv['user1_id']?.toString();
        final u2 = conv['user2_id']?.toString();
        if (u1 != null && u1 != userId) otherUserIds.add(u1);
        if (u2 != null && u2 != userId) otherUserIds.add(u2);
      }

      if (otherUserIds.isEmpty) return [];

      final profilesResponse = await _supabase
          .from('profile')
          .select('id, user_id, name, profile_image_url, avatar_config')
          .inFilter('user_id', otherUserIds.toList());

      final profileMap = <String, Map<String, dynamic>>{};
      for (final p in profilesResponse) {
        profileMap[p['user_id']] = Map<String, dynamic>.from(p);
      }

      final List<ChatConversation> list = [];
      for (final conv in response) {
        final otherId = conv['user1_id'] == userId
            ? conv['user2_id']?.toString()
            : conv['user1_id']?.toString();
        if (otherId == null) continue;

        final prof = profileMap[otherId];
        list.add(ChatConversation(
          id: otherId,
          name: prof?['name'] ?? 'Pocket Mate',
          imageUrl: prof?['profile_image_url'],
          lastMessage: conv['last_message']?.toString(),
          lastMessageTime: conv['last_message_time'] != null
              ? DateTime.tryParse(conv['last_message_time'].toString())
              : null,
          unreadCount: (conv['last_sender_id'] == userId)
              ? 0
              : (conv['unread_count'] as num?)?.toInt() ?? 0,
          isGroup: false,
          avatarConfig: prof?['avatar_config'] != null
              ? Map<String, dynamic>.from(prof!['avatar_config'])
              : null,
        ));
      }

      return list;
    } catch (e) {
      debugPrint('Error fetching kids personal chats: $e');
      return [];
    }
  }

  void togglePin(String conversationId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'kids_pinned_conversations_${user.id}';
    final current = prefs.getStringList(key) ?? [];
    if (current.contains(conversationId)) {
      current.remove(conversationId);
    } else {
      current.add(conversationId);
    }
    await prefs.setStringList(key, current);
    refreshNow();
  }

  void markAsRead(String conversationId, bool isGroup) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      if (isGroup) {
        await _supabase
            .from('kids_group_members')
            .update({'last_read_at': DateTime.now().toIso8601String()})
            .eq('group_id', conversationId)
            .eq('user_id', user.id);
      } else {
        await _supabase
            .from('kids_conversations')
            .update({'unread_count': 0})
            .or('and(user1_id.eq.${user.id},user2_id.eq.$conversationId),and(user1_id.eq.$conversationId,user2_id.eq.${user.id})');
      }
    } catch (_) {}
  }

  /// Instantly updates the kids conversation tile in-memory when a message is sent or received
  void updateLastMessage({
    required String conversationId,
    required String message,
    required DateTime time,
    required String senderId,
  }) {
    state.whenData((conversations) {
      final updatedList = conversations.map((c) {
        if (c.id == conversationId) {
          return ChatConversation(
            id: c.id,
            name: c.name,
            imageUrl: c.imageUrl,
            lastMessage: message,
            lastMessageTime: time,
            unreadCount: (senderId == c.id) ? (c.unreadCount + 1) : 0,
            otherUnreadCount: (senderId != c.id) ? 1 : 0,
            isGroup: c.isGroup,
            lastSenderId: senderId,
            isOnline: c.isOnline,
            lastSeen: c.lastSeen,
            isNotification: c.isNotification,
            notificationType: c.notificationType,
            sourceId: c.sourceId,
            notificationStatus: c.notificationStatus,
            hasStatus: c.hasStatus,
            statusData: c.statusData,
            isTool: c.isTool,
            toolTitle: c.toolTitle,
            isPinned: c.isPinned,
            isActiveTimer: c.isActiveTimer,
            taskTitle: c.taskTitle,
            teamName: c.teamName,
            timerStartTime: c.timerStartTime,
            teamData: c.teamData,
            avatarConfig: c.avatarConfig,
            snapMediaUrl: c.snapMediaUrl,
            snapCaption: c.snapCaption,
          );
        }
        return c;
      }).toList();

      updatedList.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        final aTime = a.lastMessageTime;
        final bTime = b.lastMessageTime;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      state = AsyncValue.data(updatedList);
    });
  }
}
