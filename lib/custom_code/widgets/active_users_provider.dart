import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat/chat_provider.dart'; // sharing supabaseClient provider

part 'active_users_provider.g.dart';

// Data Model
class ActiveUsersData {
  final List<Map<String, dynamic>> activeFriends;
  final Map<String, List<Map<String, dynamic>>> userNotes;

  ActiveUsersData({required this.activeFriends, required this.userNotes});
}

@riverpod
class ActiveUsers extends _$ActiveUsers {
  late SupabaseClient _supabase;
  RealtimeChannel? _friendListChannel;
  RealtimeChannel? _notesChannel;
  late String _currentProfileId;
  Timer? _refreshTimer;

  @override
  FutureOr<ActiveUsersData> build(String profileId) async {
    _currentProfileId = profileId;
    _supabase = ref.watch(supabaseClientProvider);

    // Join logic
    await _joinFriendList();

    // Subscriptions
    _subscribeToFriendList();
    _subscribeToNotes();

    // Periodic Refresh every 30s as requested
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      ref.invalidateSelf();
    });

    // Cleanup
    ref.onDispose(() {
      _friendListChannel?.unsubscribe();
      _notesChannel?.unsubscribe();
      _refreshTimer?.cancel();
    });

    return _fetchData();
  }

  Future<void> _joinFriendList() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('friendlist').upsert({
        'profile_id': _currentProfileId,
        'joined_at': DateTime.now().toIso8601String(),
        'user_id': user.id,
      }, onConflict: 'profile_id');
    } catch (e) {
      debugPrint('Error joining friend list: $e');
    }
  }

  Future<ActiveUsersData> _fetchData() async {
    try {
      // Refresh my own "joined_at" to stay active
      await _joinFriendList();

      final activeFriends = await _fetchActiveFriends();
      final userNotes = await _fetchAllNotes();
      return ActiveUsersData(
          activeFriends: activeFriends, userNotes: userNotes);
    } catch (e) {
      // Return empty on error
      return ActiveUsersData(activeFriends: [], userNotes: {});
    }
  }

  Future<List<Map<String, dynamic>>> _fetchActiveFriends() async {
    // Only fetch friends active in the last 2 minutes to ensure freshness
    final twoMinutesAgo = DateTime.now().subtract(const Duration(minutes: 2));

    final response = await _supabase
        .from('friendlist')
        .select(
            'profile_id, joined_at, profile(profile_image_url, name, id, phone_no, user_id)')
        .neq('profile_id', _currentProfileId)
        .gte('joined_at', twoMinutesAgo.toIso8601String());

    final List<dynamic> data = response as List<dynamic>;
    return data.map((item) {
      final profile = item['profile'] as Map<String, dynamic>? ?? {};
      return {
        'profile_id': item['profile_id'],
        'profile_image_url': profile['profile_image_url'],
        'name': profile['name'] ?? 'Unknown',
        'id': profile['id'],
        'phone_no': profile['phone_no'],
        'user_id': profile['user_id'],
      };
    }).toList();
  }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchAllNotes() async {
    final twentyFourHoursAgo =
        DateTime.now().subtract(const Duration(hours: 24));
    final response = await _supabase
        .from('friend_notes')
        .select('*, profile(name, profile_image_url)')
        .gte('created_at', twentyFourHoursAgo.toIso8601String())
        .order('created_at', ascending: false);

    final Map<String, List<Map<String, dynamic>>> groupedNotes = {};
    for (var note in response as List) {
      final pid = note['profile_id'].toString();
      if (!groupedNotes.containsKey(pid)) {
        groupedNotes[pid] = [];
      }
      groupedNotes[pid]!.add(note as Map<String, dynamic>);
    }
    return groupedNotes;
  }

  void _subscribeToFriendList() {
    _friendListChannel = _supabase
        .channel('friendlist_tracker_$_currentProfileId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friendlist',
          callback: (payload) => ref.invalidateSelf(),
        )
        .subscribe();
  }

  void _subscribeToNotes() {
    _notesChannel = _supabase
        .channel('notes_tracker_$_currentProfileId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'friend_notes',
          callback: (payload) => ref.invalidateSelf(),
        )
        .subscribe();
  }
}
