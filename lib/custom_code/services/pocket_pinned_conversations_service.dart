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
  static const int maxPinnedChats = 5;

  /// Get user's pinned conversation IDs (Cloud first with offline local cache)
  Future<List<String>> getPinnedConversationIds(String userId) async {
    if (userId.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'pinned_conversations_$userId';

    // 1. Try fetching from Supabase cloud (activity_type = 'user_pinned_chats')
    try {
      final supabase = Supabase.instance.client;
      final rows = await supabase
          .from(_activitiesTableName)
          .select('data')
          .eq('activity_type', 'user_pinned_chats')
          .eq('created_by', userId)
          .order('created_at', ascending: false)
          .limit(1);

      if ((rows as List).isNotEmpty && rows.first['data'] != null) {
        final data = rows.first['data'];
        List<dynamic> list = [];
        if (data is Map && data['pinned_ids'] is List) {
          list = data['pinned_ids'];
        } else if (data is List) {
          list = data;
        }
        final cloudPins = list
            .map((e) => e.toString())
            .toSet()
            .take(maxPinnedChats)
            .toList();
        await prefs.setStringList(cacheKey, cloudPins);
        return cloudPins;
      }
    } catch (e) {
      debugPrint('PocketPinnedConversationsService fetch error: $e');
    }

    // 2. Fallback to local cache
    return prefs.getStringList(cacheKey) ?? [];
  }

  /// Toggle pin status for a conversation (Cloud sync + local cache, max 5 pinned)
  Future<bool> togglePinConversation({
    required String userId,
    required String conversationId,
  }) async {
    if (userId.isEmpty || conversationId.isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'pinned_conversations_$userId';
    final currentList = List<String>.from(prefs.getStringList(cacheKey) ?? []);

    bool isNowPinned;
    if (currentList.contains(conversationId)) {
      currentList.remove(conversationId);
      isNowPinned = false;
    } else {
      if (currentList.length >= maxPinnedChats) {
        return false;
      }
      currentList.insert(0, conversationId);
      isNowPinned = true;
    }

    // Ensure deduplication & keep order
    final uniquePins = currentList.toSet().toList();
    await prefs.setStringList(cacheKey, uniquePins);

    // Sync to Supabase cloud (update latest row or insert if none)
    try {
      final supabase = Supabase.instance.client;
      final existing = await supabase
          .from(_activitiesTableName)
          .select('id')
          .eq('activity_type', 'user_pinned_chats')
          .eq('created_by', userId)
          .order('created_at', ascending: false)
          .limit(1);
      final payload = {
        'pinned_ids': uniquePins,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if ((existing as List).isNotEmpty) {
        await supabase
            .from(_activitiesTableName)
            .update({'data': payload, 'is_active': true})
            .eq('id', existing.first['id']);
      } else {
        await supabase.from(_activitiesTableName).insert({
          'group_id': null,
          'activity_type': 'user_pinned_chats',
          'title': 'User Pinned Conversations',
          'data': payload,
          'created_by': userId,
          'is_active': true,
        });
      }
    } catch (e) {
      debugPrint('PocketPinnedConversationsService sync error: $e');
    }

    return isNowPinned;
  }
}

