import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared storage helper for PocketGang & Pocket Couple tools:
/// - Solo / 1-member groups (or unpaired `pocket_couple_default`): Local SharedPreferences ONLY.
/// - Shared groups (2+ members): Local SharedPreferences cache + Supabase `group_activities` sync.
class PocketGangToolStorage {
  static bool isSharedGroup(String groupId, int memberCount) {
    if (groupId == 'pocket_couple_default') return false;
    return memberCount >= 2;
  }

  static Future<List<Map<String, dynamic>>> loadList({
    required String groupId,
    required String activityType,
    required int memberCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_tool_${activityType}_$groupId';
    List<Map<String, dynamic>> localItems = [];

    final raw = prefs.getString(cacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List;
        localItems =
            decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (_) {}
    }

    if (!isSharedGroup(groupId, memberCount)) {
      return localItems;
    }

    try {
      final res = await Supabase.instance.client
          .from('group_activities')
          .select('data')
          .eq('group_id', groupId)
          .eq('activity_type', activityType)
          .maybeSingle();

      if (res != null && res['data'] is Map && res['data']['items'] is List) {
        final remote = (res['data']['items'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        await prefs.setString(cacheKey, jsonEncode(remote));
        return remote;
      }
    } catch (_) {}

    return localItems;
  }

  static Future<void> saveList({
    required String groupId,
    required String activityType,
    required String title,
    required String userId,
    required int memberCount,
    required List<Map<String, dynamic>> items,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_tool_${activityType}_$groupId';
    await prefs.setString(cacheKey, jsonEncode(items));

    if (!isSharedGroup(groupId, memberCount)) {
      return;
    }

    try {
      await Supabase.instance.client.from('group_activities').upsert({
        'group_id': groupId,
        'activity_type': activityType,
        'title': title,
        'data': {
          'items': items,
          'updated_by': userId,
          'updated_at': DateTime.now().toIso8601String(),
        },
        'created_by': userId,
        'is_active': true,
      });
    } catch (_) {}
  }
}
