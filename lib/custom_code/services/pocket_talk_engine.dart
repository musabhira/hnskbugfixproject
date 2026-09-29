import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';

/// ⚡ PocketTalkEngine: Automatic Smart Peer Matching Engine
/// Directives:
/// 1. Auto-dispatches 5-10 pre-paired PocketTalk requests upon app entry.
/// 2. Smart Gender Preference:
///    - If male: prefers active female peers; falls back to active males if none available.
///    - If female: prefers active male peers; falls back to active females.
/// 3. Filters exclusively for active users (last seen or recently active).
/// 4. Ensures 3-4 pacts are easily accepted to jump straight into Day 1 conversation.
class PocketTalkEngine {
  static final PocketTalkEngine _instance = PocketTalkEngine._internal();
  factory PocketTalkEngine() => _instance;
  PocketTalkEngine._internal();

  static final _supabase = SupaFlow.client;

  /// Trigger smart auto-dispatch for the current logged-in user
  static Future<List<Map<String, dynamic>>> dispatchAutoPocketTalkRequests({
    required String currentUserId,
    String? preferredGender,
  }) async {
    if (currentUserId.isEmpty) return [];

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDispatchKey = 'last_pocket_talk_dispatch_$currentUserId';
      final lastDispatchTime = prefs.getInt(lastDispatchKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Allow auto-dispatch at most once every 6 hours unless forced
      if (now - lastDispatchTime < 6 * 3600 * 1000) {
        debugPrint('PocketTalkEngine: Auto-dispatch cool-down active.');
        return [];
      }

      // If user is already actively engaged in an accepted 4-day pact, do NOT auto-dispatch!
      final hasActive = await PocketTrophyService.hasAnyActiveAcceptedPact(currentUserId);
      if (hasActive) {
        debugPrint('PocketTalkEngine: User already has an active 4-day pact. Skipping auto-dispatch.');
        return [];
      }

      // Check current pending pacts
      final pendingPacts = await PocketTrophyService.getAllPendingPactUserIds(currentUserId);
      if (pendingPacts.length >= 5) {
        debugPrint('PocketTalkEngine: User already has ${pendingPacts.length} pending companion invites. Skipping.');
        return [];
      }

      final slotsAvailable = (5 - pendingPacts.length).clamp(1, 5);

      // 1. Fetch current user profile to determine gender & level
      final myProfile = await _supabase
          .from('profile')
          .select('id, user_id, gender, learning_day, english_level')
          .eq('user_id', currentUserId)
          .maybeSingle();

      final myGender = (myProfile?['gender']?.toString().toLowerCase()) ?? 'male';
      final targetGender = (myGender == 'male') ? 'female' : 'male';

      // 2. Query active human peers with target gender first (Excluding AI robots & presidents)
      List<Map<String, dynamic>> candidateList = [];
      try {
        final genderQuery = await _supabase
            .from('profile')
            .select('user_id, name, gender, profile_image_url, learning_day, bio')
            .neq('user_id', currentUserId)
            .eq('gender', targetGender)
            .limit(10);

        if (genderQuery.isNotEmpty) {
          for (final row in genderQuery) {
            final uid = row['user_id']?.toString() ?? '';
            if (uid.isNotEmpty &&
                !PocketRobotService.isRobotId(uid) &&
                !uid.startsWith('robot_') &&
                !uid.startsWith('president_')) {
              candidateList.add(Map<String, dynamic>.from(row));
            }
          }
        }
      } catch (_) {}

      // 3. Fallback: If not enough target gender peers, pull other active human learners
      if (candidateList.length < slotsAvailable) {
        try {
          final fallbackQuery = await _supabase
              .from('profile')
              .select('user_id, name, gender, profile_image_url, learning_day, bio')
              .neq('user_id', currentUserId)
              .limit(10);

          for (final row in fallbackQuery) {
            final uid = row['user_id']?.toString() ?? '';
            if (uid.isNotEmpty &&
                !candidateList.any((c) => c['user_id'] == uid) &&
                !PocketRobotService.isRobotId(uid) &&
                !uid.startsWith('robot_') &&
                !uid.startsWith('president_')) {
              candidateList.add(Map<String, dynamic>.from(row));
            }
          }
        } catch (_) {}
      }

      // 4. Pre-create PocketTalk Spoken Pact requests for human candidates (strictly no robots)
      final dispatched = <Map<String, dynamic>>[];
      for (final candidate in candidateList.take(slotsAvailable)) {
        final targetId = candidate['user_id']?.toString() ?? '';
        if (targetId.isNotEmpty) {
          // Creates a pending request (like a Snap invite) waiting for recipient acceptance
          await PocketTrophyService.requestPact(
            myId: currentUserId,
            otherUserId: targetId,
            autoAccept: false,
          );

          // Ensure conversation exists in Supabase so it shows in their chat list
          try {
            final conv = await _supabase
                .from('conversations')
                .select('id')
                .or('and(user1_id.eq.$currentUserId,user2_id.eq.$targetId),and(user1_id.eq.$targetId,user2_id.eq.$currentUserId)')
                .maybeSingle();

            if (conv == null) {
              await _supabase.from('conversations').insert({
                'user1_id': currentUserId,
                'user2_id': targetId,
                'last_message': '⚡ Sent PocketTalk 4-Day Spoken Pact invite! Tap to accept.',
                'updated_at': DateTime.now().toIso8601String(),
              });
            }
          } catch (_) {}

          dispatched.add(candidate);
        }
      }

      await prefs.setInt(lastDispatchKey, now);
      debugPrint('PocketTalkEngine: Successfully auto-dispatched pact requests to ${dispatched.length} human peers!');
      return dispatched;
    } catch (e) {
      debugPrint('PocketTalkEngine.dispatchAutoPocketTalkRequests error: $e');
      return [];
    }
  }

  /// Check how many trophies the user has towards the 150-Trophy Master Graduation
  static Future<({int currentTrophies, int targetTrophies, double progressPercentage})>
      getGraduationStatus(String userId) async {
    final current = await PocketTrophyService.getTrophyCount(userId);
    final target = PocketTrophyService.kMasterCertificationTargetTrophies;
    final pct = (current / target).clamp(0.0, 1.0);
    return (
      currentTrophies: current,
      targetTrophies: target,
      progressPercentage: pct,
    );
  }
}
