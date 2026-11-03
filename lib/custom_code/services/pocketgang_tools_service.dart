import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/chat/english_hub_level_group_service.dart';

/// 🛠️ Group-Wide Tool Configuration & Synchronization Service for PocketGang
class PocketGangToolsService {
  PocketGangToolsService._();
  static final PocketGangToolsService instance = PocketGangToolsService._();

  static const String _toolsTableName = 'group_tools';
  static const String _activitiesTableName = 'group_activities';

  /// Standard Default Tools for PocketGang Friends & Team
  static const List<String> defaultTools = ['team_mgmt'];

  /// Check whether a group is eligible for PocketGang Workspace & Tools.
  /// STRICT: English Hub groups and 1-on-1 personal chats are strictly EXCLUDED!
  static bool isEligibleForPocketGangTools({
    required String? groupId,
    String? groupName,
  }) {
    if (groupId == null || groupId.isEmpty) return false;
    // 1-on-1 personal chat prefix
    if (groupId.startsWith('p:')) return false;

    // Check English Hub classification (IDs and standard naming rules)
    if (EnglishHubLevelGroupService.isEnglishHub(groupId, groupName: groupName)) {
      return false;
    }

    final lowerId = groupId.toLowerCase();
    final lowerName = (groupName ?? '').toLowerCase();

    if (lowerId.contains('english') ||
        lowerId.contains('hub') ||
        lowerName.contains('english hub') ||
        lowerName.contains('english learning') ||
        lowerName.contains('english practice')) {
      return false;
    }

    return true;
  }

  /// Fetch installed tools for a specific Gang from Supabase with SharedPreferences fallback
  Future<List<String>> getInstalledTools(String groupId) async {
    if (groupId.isEmpty) return defaultTools;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'pocketgang_tools_$groupId';

    try {
      final supabase = Supabase.instance.client;

      // 1. Try group_tools table
      try {
        final res = await supabase
            .from(_toolsTableName)
            .select('tool_key, is_enabled')
            .eq('group_id', groupId)
            .eq('is_enabled', true)
            .order('display_order', ascending: true);

        if (res.isNotEmpty) {
          final tools = res.map((r) => r['tool_key']?.toString() ?? '').where((k) => k.isNotEmpty).toList();
          await prefs.setString(cacheKey, jsonEncode(tools));
          return tools;
        }
      } catch (_) {}

      // 2. Fallback to group_activities table (activity_type = 'gang_installed_tools')
      try {
        final act = await supabase
            .from(_activitiesTableName)
            .select('data')
            .eq('group_id', groupId)
            .eq('activity_type', 'gang_installed_tools')
            .maybeSingle();

        if (act != null && act['data'] != null) {
          final data = act['data'];
          List<dynamic> list = [];
          if (data is Map && data['tools'] is List) {
            list = data['tools'];
          } else if (data is List) {
            list = data;
          }
          final tools = list.map((e) => e.toString()).toList();
          if (tools.isNotEmpty) {
            await prefs.setString(cacheKey, jsonEncode(tools));
            return tools;
          }
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('PocketGangToolsService fetch error: $e');
    }

    // 3. Fallback to local cached list
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final list = (jsonDecode(cached) as List).map((e) => e.toString()).toList();
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }

    return List<String>.from(defaultTools);
  }

  /// Install or update tools for the entire Gang (Group-Level)
  Future<void> updateInstalledTools({
    required String groupId,
    required List<String> toolKeys,
    required String userId,
  }) async {
    if (groupId.isEmpty) return;

    // Cache immediately locally
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'pocketgang_tools_$groupId';
    await prefs.setString(cacheKey, jsonEncode(toolKeys));

    try {
      final supabase = Supabase.instance.client;

      // Attempt 1: Sync to group_tools table
      try {
        // Upsert tool rows
        for (int i = 0; i < toolKeys.length; i++) {
          await supabase.from(_toolsTableName).upsert({
            'group_id': groupId,
            'tool_key': toolKeys[i],
            'is_enabled': true,
            'display_order': i,
            'installed_by': userId,
          });
        }
      } catch (_) {}

      // Attempt 2: Always save into group_activities for guaranteed real-time broadcasting
      try {
        await supabase.from(_activitiesTableName).upsert({
          'group_id': groupId,
          'activity_type': 'gang_installed_tools',
          'title': 'PocketGang Tools',
          'data': {'tools': toolKeys, 'updated_by': userId, 'timestamp': DateTime.now().toIso8601String()},
          'created_by': userId,
          'is_active': true,
        });
      } catch (_) {}
    } catch (e) {
      debugPrint('Error syncing tools to group: $e');
    }
  }

  /// Subscribe to group tool changes in real-time
  RealtimeChannel? subscribeToTools({
    required String groupId,
    required VoidCallback onToolsChanged,
  }) {
    if (groupId.isEmpty) return null;
    try {
      final supabase = Supabase.instance.client;
      final channel = supabase.channel('gang_tools_$groupId');
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: _activitiesTableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'group_id',
              value: groupId,
            ),
            callback: (payload) {
              if (payload.newRecord['activity_type'] == 'gang_installed_tools') {
                onToolsChanged();
              }
            },
          )
          .subscribe();
      return channel;
    } catch (e) {
      debugPrint('Error subscribing to tools channel: $e');
      return null;
    }
  }
}

