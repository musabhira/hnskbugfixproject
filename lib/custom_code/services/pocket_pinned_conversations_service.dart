import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 📌 Service for synchronizing User-Level Pinned Conversations across devices and cloud
class PocketPinnedConversationsService {
  PocketPinnedConversationsService._();
  static final PocketPinnedConversationsService instance =
      PocketPinnedConversationsService._();

  static const String _activitiesTableName = 'group_activities';

  /// Get user's pinned conversation IDs (Cloud first with offline local cache)
  Future<List<String>> getPinnedConversationIds(String userId) async {
    if (userId.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'pinned_conversations_$userId';

    // 1. Try fetching from Supabase cloud (activity_type = 'user_pinned_chats')
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from(_activitiesTableName)
          .select('data')
          .eq('activity_type', 'user_pinned_chats')
          .eq('created_by', userId)
          .maybeSingle();

      if (res != null && res['data'] != null) {
        final data = res['data'];
        List<dynamic> list = [];
        if (data is Map && data['pinned_ids'] is List) {
          list = data['pinned_ids'];
        } else if (data is List) {
          list = data;
        }
        final cloudPins = list.map((e) => e.toString()).toSet().toList();
        await prefs.setStringList(cacheKey, cloudPins);
        return cloudPins;
      }
    } catch (e) {
      debugPrint('PocketPinnedConversationsService fetch error: $e');
    }

    // 2. Fallback to local cache
    return prefs.getStringList(cacheKey) ?? [];
  }

  /// Toggle pin status for a conversation (Cloud sync + local cache)
  Future<bool> togglePinConversation({
    required String userId,
    required String conversationId,
  }) async {
    if (userId.isEmpty || conversationId.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'pinned_conversations_$userId';
    final currentList = prefs.getStringList(cacheKey) ?? [];

    bool isNowPinned;
    if (currentList.contains(conversationId)) {
      currentList.remove(conversationId);
      isNowPinned = false;
    } else {
      currentList.insert(0, conversationId);
      isNowPinned = true;
    }

    // Ensure deduplication
    final uniquePins = currentList.toSet().toList();
    await prefs.setStringList(cacheKey, uniquePins);

    // Sync to Supabase cloud
    try {
      final supabase = Supabase.instance.client;
      await supabase.from(_activitiesTableName).upsert({
        'group_id': null,
        'activity_type': 'user_pinned_chats',
        'title': 'User Pinned Conversations',
        'data': {
          'pinned_ids': uniquePins,
          'updated_at': DateTime.now().toIso8601String(),
        },
        'created_by': userId,
        'is_active': true,
      });
    } catch (e) {
      debugPrint('PocketPinnedConversationsService sync error: $e');
    }

    return isNowPinned;
  }
}

