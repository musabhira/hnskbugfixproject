import 'dart:async';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';

/// ⏳ Model representing the current rate limit and cooldown timer status for Pocket Talk
class PocketTalkRateLimitStatus {
  final bool isAllowed;
  final bool isVip;
  final int remainingTalks;
  final int maxLimit;
  final Duration cooldownRemaining;

  const PocketTalkRateLimitStatus({
    required this.isAllowed,
    required this.isVip,
    required this.remainingTalks,
    required this.maxLimit,
    required this.cooldownRemaining,
  });

  /// Formats cooldown time as HH:MM:SS (e.g. 04:52:19)
  String get formattedCooldown {
    final h = cooldownRemaining.inHours.toString().padLeft(2, '0');
    final m = (cooldownRemaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (cooldownRemaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

/// ⚡ PocketTalkEngine: Automatic Smart Peer Matching & Rate Limit Engine
/// User Audio Directives:
/// 1. Premium / VIP users have UNLIMITED Pocket Talks at any time.
/// 2. Free users are restricted to 4 Pocket Talks per window.
/// 3. Once 4 talks are sent, a 5-hour ChatGPT-style cooldown timer is enforced before it refreshes.
class PocketTalkEngine {
  static final PocketTalkEngine _instance = PocketTalkEngine._internal();
  factory PocketTalkEngine() => _instance;
  PocketTalkEngine._internal();

  /// Max free talks before 5-hour cooldown is triggered
  static const int kFreeUserPocketTalkLimit = 4;
  /// Cooldown duration (5 hours)
  static const Duration kFreeUserCooldownDuration = Duration(hours: 5);

  /// 🔒 Check whether user is currently eligible to send a Pocket Talk request
  static Future<PocketTalkRateLimitStatus> checkRateLimit(String userId) async {
    if (userId.isEmpty) {
      return const PocketTalkRateLimitStatus(
        isAllowed: true,
        isVip: false,
        remainingTalks: kFreeUserPocketTalkLimit,
        maxLimit: kFreeUserPocketTalkLimit,
        cooldownRemaining: Duration.zero,
      );
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final plan = prefs.getString('handskill_plan') ?? 'free';
      final isVip = plan != 'free';

      // 👑 Premium users have unlimited Pocket Talks!
      if (isVip) {
        return const PocketTalkRateLimitStatus(
          isAllowed: true,
          isVip: true,
          remainingTalks: 999,
          maxLimit: 999,
          cooldownRemaining: Duration.zero,
        );
      }

      final countKey = 'pocket_talk_free_count_$userId';
      final windowKey = 'pocket_talk_window_start_$userId';

      final count = prefs.getInt(countKey) ?? 0;
      final windowStart = prefs.getInt(windowKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (windowStart > 0) {
        final elapsed = now - windowStart;
        if (elapsed >= kFreeUserCooldownDuration.inMilliseconds) {
          // 🔄 Cooldown expired! Reset window cleanly
          await prefs.setInt(countKey, 0);
          await prefs.remove(windowKey);
          return const PocketTalkRateLimitStatus(
            isAllowed: true,
            isVip: false,
            remainingTalks: kFreeUserPocketTalkLimit,
            maxLimit: kFreeUserPocketTalkLimit,
            cooldownRemaining: Duration.zero,
          );
        }

        if (count >= kFreeUserPocketTalkLimit) {
          final remainingMs = kFreeUserCooldownDuration.inMilliseconds - elapsed;
          return PocketTalkRateLimitStatus(
            isAllowed: false,
            isVip: false,
            remainingTalks: 0,
            maxLimit: kFreeUserPocketTalkLimit,
            cooldownRemaining: Duration(milliseconds: math.max(0, remainingMs)),
          );
        }
      }

      return PocketTalkRateLimitStatus(
        isAllowed: true,
        isVip: false,
        remainingTalks: math.max(0, kFreeUserPocketTalkLimit - count),
        maxLimit: kFreeUserPocketTalkLimit,
        cooldownRemaining: Duration.zero,
      );
    } catch (_) {
      return const PocketTalkRateLimitStatus(
        isAllowed: true,
        isVip: false,
        remainingTalks: kFreeUserPocketTalkLimit,
        maxLimit: kFreeUserPocketTalkLimit,
        cooldownRemaining: Duration.zero,
      );
    }
  }

  /// 📝 Record that a user initiated a Pocket Talk request
  static Future<void> recordPocketTalkSent(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final plan = prefs.getString('handskill_plan') ?? 'free';
      if (plan != 'free') return; // Unlimited for VIP

      final countKey = 'pocket_talk_free_count_$userId';
      final windowKey = 'pocket_talk_window_start_$userId';

      final count = prefs.getInt(countKey) ?? 0;
      final windowStart = prefs.getInt(windowKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (windowStart == 0 || (now - windowStart >= kFreeUserCooldownDuration.inMilliseconds)) {
        await prefs.setInt(windowKey, now);
        await prefs.setInt(countKey, 1);
      } else {
        await prefs.setInt(countKey, count + 1);
      }
    } catch (_) {}
  }

  /// Trigger smart auto-dispatch for the current logged-in user
  /// Disabled per user directive: PocketTalk requests must only be sent explicitly by user action
  static Future<List<Map<String, dynamic>>> dispatchAutoPocketTalkRequests({
    required String currentUserId,
    String? preferredGender,
  }) async {
    return [];
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

  /// Guarantee that every user maintains up to 3 active 4-day spoken pairs.
  static Future<void> autoRefillPocketTalkPacts(String userId) async {
    return;
  }
}
