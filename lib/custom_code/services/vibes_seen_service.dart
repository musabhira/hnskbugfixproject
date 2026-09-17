import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized service to track and synchronize watched/seen status
/// for Vibes & Stories across the top story carousel and conversation tiles.
class VibesSeenService {
  static final Set<String> _seenEntityIds = {};
  static final Set<String> _seenStatusIds = {};
  static final ValueNotifier<int> seenEpochNotifier = ValueNotifier<int>(0);
  static bool _initialized = false;
  static bool get isInitialized => _initialized;
  static String _activeUserId = '';

  /// Initialize and load seen cache from SharedPreferences & Supabase
  static Future<void> init(String currentUserId) async {
    if (currentUserId.isEmpty) return;
    _activeUserId = currentUserId;
    try {
      final prefs = await SharedPreferences.getInstance();
      final seenGroups = prefs.getStringList('seen_story_groups_$currentUserId') ?? [];
      final seenStatuses = prefs.getStringList('seen_status_ids_$currentUserId') ?? [];

      _seenEntityIds.addAll(seenGroups);
      _seenStatusIds.addAll(seenStatuses);
      _initialized = true;

      // Background sync with Supabase status_views
      _syncFromSupabase(currentUserId);
    } catch (e) {
      debugPrint('Error initializing VibesSeenService: $e');
    }
  }

  static Future<void> _syncFromSupabase(String currentUserId) async {
    try {
      final client = Supabase.instance.client;
      final viewsRes = await client
          .from('status_views')
          .select('status_id')
          .eq('viewer_user_id', currentUserId);

      for (final v in (viewsRes as List)) {
        final sid = v['status_id']?.toString();
        if (sid != null && sid.isNotEmpty) {
          _seenStatusIds.add(sid);
        }
      }
    } catch (_) {}
  }

  /// Mark a group, user, robot, or set of statuses as seen
  static Future<void> markSeen({
    required String currentUserId,
    String? userId,
    String? profileId,
    String? groupId,
    List<String>? statusIds,
  }) async {
    final effectiveUserId = currentUserId.isNotEmpty ? currentUserId : _activeUserId;
    bool changed = false;

    if (userId != null && userId.isNotEmpty) {
      if (_seenEntityIds.add(userId)) changed = true;
    }
    if (profileId != null && profileId.isNotEmpty) {
      if (_seenEntityIds.add(profileId)) changed = true;
    }
    if (groupId != null && groupId.isNotEmpty) {
      if (_seenEntityIds.add(groupId)) changed = true;
    }
    if (statusIds != null && statusIds.isNotEmpty) {
      for (final sid in statusIds) {
        if (_seenStatusIds.add(sid)) changed = true;
      }
    }

    if (changed) {
      seenEpochNotifier.value++;
      if (effectiveUserId.isNotEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList('seen_story_groups_$effectiveUserId', _seenEntityIds.toList());
          if (_seenStatusIds.isNotEmpty) {
            await prefs.setStringList('seen_status_ids_$effectiveUserId', _seenStatusIds.toList());
          }
        } catch (e) {
          debugPrint('Error persisting seen vibes: $e');
        }
      }
    }
  }

  /// Check if a user, robot, group, or story status list has already been watched
  static bool isWatched({
    required String currentUserId,
    String? userId,
    String? profileId,
    String? groupId,
    List<Map<String, dynamic>>? statuses,
  }) {
    if (userId != null && userId.isNotEmpty && _seenEntityIds.contains(userId)) {
      return true;
    }
    if (profileId != null && profileId.isNotEmpty && _seenEntityIds.contains(profileId)) {
      return true;
    }
    if (groupId != null && groupId.isNotEmpty && _seenEntityIds.contains(groupId)) {
      return true;
    }

    // Check individual statuses: if ALL statuses are in _seenStatusIds, considered watched
    if (statuses != null && statuses.isNotEmpty) {
      bool allSeen = true;
      for (final s in statuses) {
        final sid = s['id']?.toString();
        if (sid == null || !_seenStatusIds.contains(sid)) {
          allSeen = false;
          break;
        }
      }
      if (allSeen) return true;
    }

    return false;
  }
}
