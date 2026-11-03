import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/chat/english_hub_level_group_service.dart';

/// 🌐 Group-Wide Allowed Languages Configuration & Verification Service for PocketGang
class PocketGangGroupLanguageService {
  PocketGangGroupLanguageService._();
  static final PocketGangGroupLanguageService instance = PocketGangGroupLanguageService._();

  static const String _activitiesTableName = 'group_activities';
  static const String _groupLanguagesTable = 'group_languages';

  /// Standard Default Languages for new Gangs (English + Malayalam)
  static const List<String> defaultLanguageCodes = ['en', 'ml'];

  /// Check whether a group is eligible for configurable group languages.
  /// Strictly excludes English Hub groups and 1-on-1 personal chats.
  static bool isEligibleForGangLanguages({
    required String? groupId,
    String? groupName,
  }) {
    if (groupId == null || groupId.isEmpty) return false;
    if (groupId.startsWith('p:') || groupId.startsWith('m:')) return false;

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

  /// Get allowed language codes for a given PocketGang group
  Future<List<String>> getAllowedLanguageCodes(String groupId) async {
    if (groupId.isEmpty) return defaultLanguageCodes;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_allowed_languages_$groupId';

    try {
      final supabase = Supabase.instance.client;

      // 1. Try group_languages table
      try {
        final res = await supabase
            .from(_groupLanguagesTable)
            .select('language_code')
            .eq('group_id', groupId);

        if (res.isNotEmpty) {
          final codes = res.map((r) => r['language_code']?.toString() ?? '').where((k) => k.isNotEmpty).toList();
          if (codes.isNotEmpty) {
            await prefs.setString(cacheKey, jsonEncode(codes));
            return codes;
          }
        }
      } catch (_) {}

      // 2. Try group_activities fallback (activity_type = 'gang_allowed_languages')
      try {
        final act = await supabase
            .from(_activitiesTableName)
            .select('data')
            .eq('group_id', groupId)
            .eq('activity_type', 'gang_allowed_languages')
            .maybeSingle();

        if (act != null && act['data'] != null) {
          final data = act['data'];
          List<dynamic> list = [];
          if (data is Map && data['languages'] is List) {
            list = data['languages'];
          } else if (data is List) {
            list = data;
          }
          final codes = list.map((e) => e.toString()).toList();
          if (codes.isNotEmpty) {
            await prefs.setString(cacheKey, jsonEncode(codes));
            return codes;
          }
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('PocketGangGroupLanguageService fetch error: $e');
    }

    // 3. Fallback to local cache
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final list = (jsonDecode(cached) as List).map((e) => e.toString()).toList();
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }

    return List<String>.from(defaultLanguageCodes);
  }

  /// Update allowed languages for the entire Gang (Group-Level)
  Future<void> updateAllowedLanguages({
    required String groupId,
    required List<String> languageCodes,
    required String userId,
  }) async {
    if (groupId.isEmpty || languageCodes.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'gang_allowed_languages_$groupId';
    await prefs.setString(cacheKey, jsonEncode(languageCodes));

    try {
      final supabase = Supabase.instance.client;

      // 1. Sync to group_languages table
      try {
        final langRows = languageCodes.map((code) => {
          'group_id': groupId,
          'language_code': code,
          'language_name': code.toUpperCase(),
          'is_primary': code == languageCodes.first,
        }).toList();

        await supabase.from(_groupLanguagesTable).delete().eq('group_id', groupId);
        await supabase.from(_groupLanguagesTable).insert(langRows);
      } catch (_) {}

      // 2. Sync to group_activities table for real-time broadcast
      try {
        await supabase.from(_activitiesTableName).upsert({
          'group_id': groupId,
          'activity_type': 'gang_allowed_languages',
          'title': 'PocketGang Allowed Languages',
          'data': {
            'languages': languageCodes,
            'updated_by': userId,
            'timestamp': DateTime.now().toIso8601String(),
          },
          'created_by': userId,
          'is_active': true,
        });
      } catch (_) {}
    } catch (e) {
      debugPrint('Error updating gang allowed languages: $e');
    }
  }

  /// Real-time subscription to group language configuration changes
  RealtimeChannel? subscribeToGangLanguages({
    required String groupId,
    required VoidCallback onLanguagesChanged,
  }) {
    if (groupId.isEmpty) return null;
    try {
      final supabase = Supabase.instance.client;
      final channel = supabase.channel('gang_languages_$groupId');
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: _activitiesTableName,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'group_id',
          value: groupId,
        ),
        callback: (payload) {
          if (payload.newRecord['activity_type'] == 'gang_allowed_languages') {
            onLanguagesChanged();
          }
        },
      ).subscribe();
      return channel;
    } catch (_) {
      return null;
    }
  }
}

