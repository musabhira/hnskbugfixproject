import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';

/// 🏆 Model representing an active, requested, or completed PocketTalk 4-Day Spoken Pact
class PocketTalkPact {
  final String pactId;
  final String user1Id;
  final String user2Id;
  final String initiatorId; // User who initiated the PocketTalk request
  final DateTime startedAt;
  final int streakDays; // 1 to 4
  final String lastSpokenDate; // 'YYYY-MM-DD'
  final int dailyMinutesToday; // Minutes spoken today (Target: 15 mins/day)
  final bool isAccepted; // True when recipient accepts the pact
  final bool isCompleted; // True when 4 days of 15m achieved & trophy minted
  final bool isMatesNow; // True when officially unlocked as mutual Pocket Mates
  final int trophiesEarned;
  final bool isForfeited; // True if pact failed/breached due to missed daily quota
  final bool hasBothSpoken; // True when both users have sent at least one message / interacted

  const PocketTalkPact({
    required this.pactId,
    required this.user1Id,
    required this.user2Id,
    this.initiatorId = '',
    required this.startedAt,
    required this.streakDays,
    required this.lastSpokenDate,
    this.dailyMinutesToday = 0,
    this.isAccepted = false,
    required this.isCompleted,
    required this.isMatesNow,
    this.trophiesEarned = 0,
    this.isForfeited = false,
    this.hasBothSpoken = false,
  });

  Map<String, dynamic> toMap() => {
        'pactId': pactId,
        'user1Id': user1Id,
        'user2Id': user2Id,
        'initiatorId': initiatorId,
        'startedAt': startedAt.toIso8601String(),
        'streakDays': streakDays,
        'lastSpokenDate': lastSpokenDate,
        'dailyMinutesToday': dailyMinutesToday,
        'isAccepted': isAccepted,
        'isCompleted': isCompleted,
        'isMatesNow': isMatesNow,
        'trophiesEarned': trophiesEarned,
        'isForfeited': isForfeited,
        'hasBothSpoken': hasBothSpoken,
      };

  factory PocketTalkPact.fromMap(Map<String, dynamic> map) {
    return PocketTalkPact(
      pactId: map['pactId']?.toString() ?? '',
      user1Id: map['user1Id']?.toString() ?? '',
      user2Id: map['user2Id']?.toString() ?? '',
      initiatorId: map['initiatorId']?.toString() ?? '',
      startedAt: map['startedAt'] != null
          ? DateTime.tryParse(map['startedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 1,
      lastSpokenDate: map['lastSpokenDate']?.toString() ?? '',
      dailyMinutesToday: (map['dailyMinutesToday'] as num?)?.toInt() ?? 0,
      isAccepted: map['isAccepted'] == true || map['isAccepted'] == 'true',
      isCompleted: map['isCompleted'] == true || map['isCompleted'] == 'true',
      isMatesNow: map['isMatesNow'] == true || map['isMatesNow'] == 'true',
      trophiesEarned: (map['trophiesEarned'] as num?)?.toInt() ?? 0,
      isForfeited: map['isForfeited'] == true || map['isForfeited'] == 'true',
      hasBothSpoken: map['hasBothSpoken'] == true || map['hasBothSpoken'] == 'true',
    );
  }
}

/// Result of evaluating pact status (checks for missed days or quota breaches)
class PactEvaluationResult {
  final PocketTalkPact pact;
  final bool didBreach;
  final bool deductedTrophy;
  final String message;

  const PactEvaluationResult({
    required this.pact,
    this.didBreach = false,
    this.deductedTrophy = false,
    this.message = '',
  });
}

/// 🏛️ Central Service Managing:
/// 1. 4-Day PocketTalk Spoken Pacts (15 minutes/day x 4 days = 60 minutes / 1 hour total)
/// 2. Loss Aversion: Trophy penalty deduction if agreement is broken/missed
/// 3. Trophy accumulation towards the 150-Trophy 90-Day Master Graduation
/// 4. English Guard Real-time Verification & Penalty system
/// 5. Private Profile gating until 4-day pact completion
class PocketTrophyService {
  static final PocketTrophyService _instance = PocketTrophyService._internal();
  factory PocketTrophyService() => _instance;
  PocketTrophyService._internal();

  static final _supabase = SupaFlow.client;

  // Key Constants
  static const int kDailyRequiredMinutes = 15; // 15 mins per day
  static const int kPactRequiredDays = 4; // 4 consecutive days = 1 hour total
  static const int kMasterCertificationTargetTrophies = 150;
  static const String kPrefsTrophiesCountKey = 'pocket_talk_trophies_count_';
  static const String kPrefsPactPrefix = 'pocket_talk_pact_';

  /// Get current user's total trophy count (used for profile badges & graduation check)
  static Future<int> getTrophyCount(String userId) async {
    if (userId.isEmpty) return 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getInt('$kPrefsTrophiesCountKey$userId');
      if (local != null) return local;

      // Try reading from profile table in Supabase
      final res = await _supabase
          .from('profile')
          .select('trophies_count')
          .eq('user_id', userId)
          .maybeSingle();

      if (res != null && res['trophies_count'] != null) {
        final count = (res['trophies_count'] as num).toInt();
        await prefs.setInt('$kPrefsTrophiesCountKey$userId', count);
        return count;
      }
    } catch (_) {}
    return 0;
  }

  /// Deduct 1 Trophy from user as penalty for breaking agreement/inactivity
  static Future<int> deductTrophyPenalty(String userId) async {
    if (userId.isEmpty) return 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await getTrophyCount(userId);
      final newCount = (current > 0) ? current - 1 : 0;
      await prefs.setInt('$kPrefsTrophiesCountKey$userId', newCount);

      try {
        await _supabase
            .from('profile')
            .update({'trophies_count': newCount})
            .eq('user_id', userId);
      } catch (_) {}
      return newCount;
    } catch (_) {
      return 0;
    }
  }

  /// Check whether two users have an active, requested, or completed 4-day pact
  static Future<PocketTalkPact?> getPact(String myId, String otherUserId) async {
    if (myId.isEmpty || otherUserId.isEmpty) return null;
    // 🤖 Robots & Presidents do NOT participate in PocketTalk Pacts / Streaks
    if (PocketRobotService.isRobotId(myId) ||
        PocketRobotService.isRobotId(otherUserId) ||
        PocketPresidentService.isPresidentId(myId) ||
        PocketPresidentService.isPresidentId(otherUserId)) {
      return null;
    }
    final pactId = _generatePactId(myId, otherUserId);
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('$kPrefsPactPrefix$pactId');
      if (str != null && str.isNotEmpty) {
        final decoded = Map<String, dynamic>.from(
            Map<String, dynamic>.from(Uri.splitQueryString(str)));
        return PocketTalkPact(
          pactId: pactId,
          user1Id: decoded['user1Id'] ?? myId,
          user2Id: decoded['user2Id'] ?? otherUserId,
          initiatorId: decoded['initiatorId'] ?? decoded['user1Id'] ?? myId,
          startedAt: DateTime.tryParse(decoded['startedAt'] ?? '') ?? DateTime.now(),
          streakDays: int.tryParse(decoded['streakDays'] ?? '1') ?? 1,
          lastSpokenDate: decoded['lastSpokenDate'] ?? '',
          dailyMinutesToday: int.tryParse(decoded['dailyMinutesToday'] ?? '0') ?? 0,
          isAccepted: decoded['isAccepted'] == 'true',
          isCompleted: decoded['isCompleted'] == 'true',
          isMatesNow: decoded['isMatesNow'] == 'true',
          trophiesEarned: int.tryParse(decoded['trophiesEarned'] ?? '0') ?? 0,
          isForfeited: decoded['isForfeited'] == 'true',
          hasBothSpoken: decoded['hasBothSpoken'] == 'true',
        );
      }
    } catch (_) {}

    return null;
  }

  /// Request or start a 4-Day Spoken Pact between two human users
  static Future<PocketTalkPact?> requestPact({
    required String myId,
    required String otherUserId,
    bool autoAccept = false,
  }) async {
    if (myId.isEmpty || otherUserId.isEmpty || myId == otherUserId) return null;
    // 🤖 Robots & Presidents do NOT participate in PocketTalk Pacts / Streaks
    if (PocketRobotService.isRobotId(myId) ||
        PocketRobotService.isRobotId(otherUserId) ||
        PocketPresidentService.isPresidentId(myId) ||
        PocketPresidentService.isPresidentId(otherUserId)) {
      return null;
    }

    final existing = await getPact(myId, otherUserId);
    if (existing != null) return existing;

    final today = _getTodayDateString();
    final pactId = _generatePactId(myId, otherUserId);
    final newPact = PocketTalkPact(
      pactId: pactId,
      user1Id: myId,
      user2Id: otherUserId,
      initiatorId: myId,
      startedAt: DateTime.now(),
      streakDays: 1,
      lastSpokenDate: today,
      dailyMinutesToday: 0,
      isAccepted: autoAccept,
      isCompleted: false,
      isMatesNow: false,
      trophiesEarned: 0,
      isForfeited: false,
    );

    await _savePact(newPact);
    return newPact;
  }

  /// Backward-compatible alias for requestPact
  static Future<PocketTalkPact?> ensurePact({
    required String myId,
    required String otherUserId,
    bool autoAccept = false,
  }) => requestPact(myId: myId, otherUserId: otherUserId, autoAccept: autoAccept);

  /// Accept an incoming PocketTalk Spoken Pact request
  static Future<PocketTalkPact?> acceptPact({
    required String myId,
    required String otherUserId,
  }) async {
    final pact = await getPact(myId, otherUserId);
    if (pact == null) return null;

    final accepted = PocketTalkPact(
      pactId: pact.pactId,
      user1Id: pact.user1Id,
      user2Id: pact.user2Id,
      initiatorId: pact.initiatorId,
      startedAt: DateTime.now(),
      streakDays: 1,
      lastSpokenDate: _getTodayDateString(),
      dailyMinutesToday: 0,
      isAccepted: true,
      isCompleted: false,
      isMatesNow: false,
      trophiesEarned: pact.trophiesEarned,
      isForfeited: false,
    );
    await _savePact(accepted);
    return accepted;
  }

  /// Check pact integrity: detects missed days and applies trophy deduction penalty.
  /// Only runs on human-to-human pacts that have already been created and accepted.
  static Future<PactEvaluationResult?> checkAndEvaluatePact({
    required String myId,
    required String otherUserId,
  }) async {
    if (PocketRobotService.isRobotId(myId) ||
        PocketRobotService.isRobotId(otherUserId) ||
        PocketPresidentService.isPresidentId(myId) ||
        PocketPresidentService.isPresidentId(otherUserId)) {
      return null;
    }

    final pact = await getPact(myId, otherUserId);
    if (pact == null) return null;

    // If pending acceptance or both users haven't yet engaged in communication,
    // protect users from unfair penalty (as per audio directive)
    if (!pact.isAccepted || !pact.hasBothSpoken) {
      return PactEvaluationResult(pact: pact);
    }

    if (pact.isCompleted) {
      return PactEvaluationResult(pact: pact);
    }

    final today = _getTodayDateString();
    if (pact.lastSpokenDate == today || pact.lastSpokenDate.isEmpty) {
      return PactEvaluationResult(pact: pact);
    }

    final daysDiff = _daysBetween(pact.lastSpokenDate, today);

    // If 1 day difference (i.e. yesterday):
    if (daysDiff == 1) {
      if (pact.dailyMinutesToday >= kDailyRequiredMinutes) {
        // Yesterday's 15 mins was accomplished! Advance to next day's session
        final nextStreak = pact.streakDays < kPactRequiredDays ? pact.streakDays + 1 : pact.streakDays;
        final rolledOver = PocketTalkPact(
          pactId: pact.pactId,
          user1Id: pact.user1Id,
          user2Id: pact.user2Id,
          initiatorId: pact.initiatorId,
          startedAt: pact.startedAt,
          streakDays: nextStreak,
          lastSpokenDate: today,
          dailyMinutesToday: 0,
          isAccepted: true,
          isCompleted: false,
          isMatesNow: false,
          trophiesEarned: pact.trophiesEarned,
          isForfeited: false,
        );
        await _savePact(rolledOver);
        return PactEvaluationResult(pact: rolledOver);
      } else {
        // Breached! Failed to complete 15 minutes yesterday
        await deductTrophyPenalty(myId);
        final breached = PocketTalkPact(
          pactId: pact.pactId,
          user1Id: pact.user1Id,
          user2Id: pact.user2Id,
          initiatorId: pact.initiatorId,
          startedAt: DateTime.now(),
          streakDays: 1,
          lastSpokenDate: today,
          dailyMinutesToday: 0,
          isAccepted: true,
          isCompleted: false,
          isMatesNow: false,
          trophiesEarned: pact.trophiesEarned,
          isForfeited: true,
        );
        await _savePact(breached);
        return PactEvaluationResult(
          pact: breached,
          didBreach: true,
          deductedTrophy: true,
          message: 'Pact broken! You did not reach 15 minutes yesterday. -1 Trophy deducted 🏆⬇️',
        );
      }
    } else if (daysDiff > 1) {
      // Breached! Inactive for 2 or more days
      await deductTrophyPenalty(myId);
      final breached = PocketTalkPact(
        pactId: pact.pactId,
        user1Id: pact.user1Id,
        user2Id: pact.user2Id,
        initiatorId: pact.initiatorId,
        startedAt: DateTime.now(),
        streakDays: 1,
        lastSpokenDate: today,
        dailyMinutesToday: 0,
        isAccepted: true,
        isCompleted: false,
        isMatesNow: false,
        trophiesEarned: pact.trophiesEarned,
        isForfeited: true,
      );
      await _savePact(breached);
      return PactEvaluationResult(
        pact: breached,
        didBreach: true,
        deductedTrophy: true,
        message: 'Pact broken! Missed daily chat. -1 Trophy deducted from your profile 🏆⬇️',
      );
    }

    return PactEvaluationResult(pact: pact);
  }

  /// Accumulate active chat minutes today towards the 15-minute daily threshold
  static Future<({
    PocketTalkPact? pact,
    bool didCompleteDayQuota,
    bool didUnlockTrophy,
  })> recordActiveChatMinutes({
    required String myId,
    required String otherUserId,
    int minutesToAdd = 1,
  }) async {
    final eval = await checkAndEvaluatePact(myId: myId, otherUserId: otherUserId);
    if (eval == null) {
      return (pact: null, didCompleteDayQuota: false, didUnlockTrophy: false);
    }
    final pact = eval.pact;

    if (!pact.isAccepted || pact.isCompleted) {
      return (pact: pact, didCompleteDayQuota: pact.isCompleted, didUnlockTrophy: false);
    }

    final today = _getTodayDateString();
    final currentMins = (pact.lastSpokenDate == today) ? pact.dailyMinutesToday : 0;
    final newMins = currentMins + minutesToAdd;
    final didJustReachQuota = currentMins < kDailyRequiredMinutes && newMins >= kDailyRequiredMinutes;

    bool didCompletePact = false;
    int finalStreak = pact.streakDays;

    if (didJustReachQuota) {
      // Reached 15 mins for today!
      if (finalStreak >= kPactRequiredDays) {
        didCompletePact = true;
      }
    }

    final updated = PocketTalkPact(
      pactId: pact.pactId,
      user1Id: pact.user1Id,
      user2Id: pact.user2Id,
      initiatorId: pact.initiatorId,
      startedAt: pact.startedAt,
      streakDays: finalStreak,
      lastSpokenDate: today,
      dailyMinutesToday: newMins,
      isAccepted: true,
      isCompleted: didCompletePact,
      isMatesNow: didCompletePact,
      trophiesEarned: didCompletePact ? pact.trophiesEarned + 1 : pact.trophiesEarned,
      isForfeited: false,
    );

    await _savePact(updated);

    if (didCompletePact) {
      // 🏆 MINT TROPHY FOR BOTH USERS!
      await _incrementTrophyCount(myId);
      await _incrementTrophyCount(otherUserId);
      return (pact: updated, didCompleteDayQuota: true, didUnlockTrophy: true);
    }

    return (pact: updated, didCompleteDayQuota: didJustReachQuota, didUnlockTrophy: false);
  }

  /// Legacy compatibility wrapper
  static Future<({PocketTalkPact? pact, bool didUnlockTrophy})> recordDailySpokenInteraction({
    required String myId,
    required String otherUserId,
  }) async {
    final res = await recordActiveChatMinutes(myId: myId, otherUserId: otherUserId, minutesToAdd: 1);
    return (pact: res.pact, didUnlockTrophy: res.didUnlockTrophy);
  }

  /// English Guard: AI spot verification & penalty deduction
  /// If non-English is detected, deducts Pocket Score and breaks streak.
  static Future<bool> reportNonEnglishMessage({
    required String reporterId,
    required String violatorId,
    required String messageText,
  }) async {
    try {
      final isNonEnglish = _detectNonEnglishText(messageText);
      if (isNonEnglish) {
        final pactId = _generatePactId(reporterId, violatorId);
        final currentPact = await getPact(reporterId, violatorId);

        if (currentPact != null) {
          // Reset streak to Day 1 & deduct 1 Trophy from violator
          await deductTrophyPenalty(violatorId);
          final penalizedPact = PocketTalkPact(
            pactId: pactId,
            user1Id: currentPact.user1Id,
            user2Id: currentPact.user2Id,
            startedAt: currentPact.startedAt,
            streakDays: 1, // Streak broken!
            lastSpokenDate: _getTodayDateString(),
            dailyMinutesToday: 0,
            isCompleted: false,
            isMatesNow: false,
            trophiesEarned: currentPact.trophiesEarned,
            isForfeited: true,
          );
          await _savePact(penalizedPact);
        }

        // Deduct 50 Pocket Score
        try {
          await _supabase.rpc('deduct_pocket_score_penalty', params: {
            'user_id': violatorId,
            'penalty_amount': 50,
            'reason': 'Spoke non-English in PocketTalk',
          });
        } catch (_) {}

        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Rule check: is full public profile unlocked?
  /// A public profile is only viewable if user is Me OR they have achieved Mates status via 4-day pact
  static Future<bool> isPublicProfileUnlocked({
    required String myId,
    required String otherUserId,
  }) async {
    if (myId.isEmpty || otherUserId.isEmpty || myId == otherUserId) return true;
    if (PocketRobotService.isRobotId(otherUserId)) return true; // Robots always public

    final pact = await getPact(myId, otherUserId);
    if (pact != null && pact.isMatesNow) return true;

    // Check if legacy mutual follow exists
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('pocket_mates_$myId') ?? [];
    if (list.contains(otherUserId)) return true;

    return false;
  }

  /// Returns count of currently active (non-completed) pacts for this user
  static Future<int> getActivePactsCount(String userId) async {
    if (userId.isEmpty) return 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(kPrefsPactPrefix));
      int count = 0;
      for (final k in keys) {
        final val = prefs.getString(k);
        if (val != null && val.contains(userId)) {
          if (!val.contains('isCompleted=true') && !val.contains('isForfeited=true')) {
            count++;
          }
        }
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  /// Check if two users have an active or pending pact
  static Future<bool> hasActiveOrPendingPact(String myId, String otherUserId) async {
    final pact = await getPact(myId, otherUserId);
    if (pact == null) return false;
    return !pact.isForfeited && !pact.isCompleted;
  }

  /// Get all other user IDs who have an active or pending pact with this user
  static Future<Set<String>> getAllActiveOrPendingPactUserIds(String userId) async {
    final result = <String>{};
    if (userId.isEmpty) return result;
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(kPrefsPactPrefix));
      for (final k in keys) {
        final val = prefs.getString(k);
        if (val != null && val.contains(userId)) {
          final decoded = Uri.splitQueryString(val);
          final isForfeited = decoded['isForfeited'] == 'true';
          if (!isForfeited) {
            final u1 = decoded['user1Id'];
            final u2 = decoded['user2Id'];
            if (u1 != null && u1 != userId) result.add(u1);
            if (u2 != null && u2 != userId) result.add(u2);
          }
        }
      }
    } catch (_) {}
    return result;
  }

  /// Record user message engagement to unlock streak protection guard
  static Future<void> markUserEngagement({
    required String myId,
    required String otherUserId,
  }) async {
    final pact = await getPact(myId, otherUserId);
    if (pact == null || pact.isCompleted || pact.isForfeited) return;
    if (!pact.hasBothSpoken) {
      final updated = PocketTalkPact(
        pactId: pact.pactId,
        user1Id: pact.user1Id,
        user2Id: pact.user2Id,
        initiatorId: pact.initiatorId,
        startedAt: pact.startedAt,
        streakDays: pact.streakDays,
        lastSpokenDate: pact.lastSpokenDate,
        dailyMinutesToday: pact.dailyMinutesToday,
        isAccepted: pact.isAccepted,
        isCompleted: pact.isCompleted,
        isMatesNow: pact.isMatesNow,
        trophiesEarned: pact.trophiesEarned,
        isForfeited: pact.isForfeited,
        hasBothSpoken: true,
      );
      await _savePact(updated);
    }
  }

  // --- Internal Helpers ---

  static String _generatePactId(String u1, String u2) {
    final sorted = [u1, u2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  static String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static int _daysBetween(String dateStr1, String dateStr2) {
    try {
      final p1 = dateStr1.split('-').map(int.parse).toList();
      final p2 = dateStr2.split('-').map(int.parse).toList();
      final d1 = DateTime(p1[0], p1[1], p1[2]);
      final d2 = DateTime(p2[0], p2[1], p2[2]);
      return d2.difference(d1).inDays;
    } catch (_) {
      return 0;
    }
  }

  static Future<void> _savePact(PocketTalkPact pact) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'pactId': pact.pactId,
      'user1Id': pact.user1Id,
      'user2Id': pact.user2Id,
      'initiatorId': pact.initiatorId,
      'startedAt': pact.startedAt.toIso8601String(),
      'streakDays': pact.streakDays.toString(),
      'lastSpokenDate': pact.lastSpokenDate,
      'dailyMinutesToday': pact.dailyMinutesToday.toString(),
      'isAccepted': pact.isAccepted.toString(),
      'isCompleted': pact.isCompleted.toString(),
      'isMatesNow': pact.isMatesNow.toString(),
      'trophiesEarned': pact.trophiesEarned.toString(),
      'isForfeited': pact.isForfeited.toString(),
      'hasBothSpoken': pact.hasBothSpoken.toString(),
    };
    final encoded = Uri(queryParameters: map).query;
    await prefs.setString('$kPrefsPactPrefix${pact.pactId}', encoded);
  }

  static Future<void> _incrementTrophyCount(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await getTrophyCount(userId);
      final newCount = current + 1;
      await prefs.setInt('$kPrefsTrophiesCountKey$userId', newCount);

      // Persist to Supabase profile
      try {
        await _supabase
            .from('profile')
            .update({'trophies_count': newCount})
            .eq('user_id', userId);
      } catch (_) {}
    } catch (_) {}
  }

  /// AI / regex detector for non-English letters (Malayalam Unicode: 0x0D00 to 0x0D7F)
  static bool _detectNonEnglishText(String text) {
    if (text.isEmpty) return false;
    // Check for Malayalam characters
    final malRegex = RegExp(r'[\u0D00-\u0D7F]');
    if (malRegex.hasMatch(text)) return true;

    // Check for common transliterated words
    final manglish = ['enthoke', 'sugano', 'njan', 'evideya', 'chechi', 'chetta', 'mone'];
    final lower = text.toLowerCase();
    for (final word in manglish) {
      if (lower.contains(word)) return true;
    }
    return false;
  }
}

