import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Shared storage helper for PocketGang & Pocket Couple tools:
/// - Solo / 1-member groups (or unpaired `pocket_couple_default`): Local SharedPreferences ONLY.
/// - Shared groups (2+ members): Local SharedPreferences cache + Supabase `group_activities` sync.
class PocketGangToolStorage {
  static const int freeItemLimit = 7;

  /// Returns true if the user can add another item (VIP or under [freeItemLimit]),
  /// otherwise shows a ₹99 Poket VIP upgrade dialog and returns false.
  static Future<bool> checkFreeLimitOrPromptVip({
    required BuildContext context,
    required int currentCount,
    required String itemLabel,
  }) async {
    if (currentCount < freeItemLimit) return true;
    bool isVip = false;
    try {
      isVip = await PocketAdMobService.instance.isUserVip();
    } catch (_) {}
    if (isVip) return true;
    if (!context.mounted) return false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Unlock Unlimited $itemLabel',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Free plan includes up to $freeItemLimit $itemLabel. Upgrade to Poket VIP (₹99) to add unlimited $itemLabel in Poket Couple & Poket Gang!',
          style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionPage()),
              );
            },
            child: const Text('Upgrade ₹99', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    return false;
  }
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
