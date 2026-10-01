import 'dart:async';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:flutter/foundation.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_guard_service.dart';

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
  final bool
      isForfeited; // True if pact failed/breached due to missed daily quota
  final bool
      hasBothSpoken; // True when both users have sent at least one message / interacted
  final int user1Days; // Distinct calendar days user1 sent messages (0 to 4)
  final int user2Days; // Distinct calendar days user2 sent messages (0 to 4)

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
    this.user1Days = 0,
    this.user2Days = 0,
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
        'user1Days': user1Days,
        'user2Days': user2Days,
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
      hasBothSpoken:
          map['hasBothSpoken'] == true || map['hasBothSpoken'] == 'true',
      user1Days: (map['user1Days'] as num?)?.toInt() ?? 0,
      user2Days: (map['user2Days'] as num?)?.toInt() ?? 0,
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
  static const int kMaxActivePacts = 4; // Target cap: 4 active speaking pairs (Audio Directive)
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
            .update({'trophies_count': newCount}).eq('user_id', userId);
      } catch (_) {}
      return newCount;
    } catch (_) {
      return 0;
    }
  }

  /// Check whether two users have an active, requested, or completed 4-day pact
  static Future<PocketTalkPact?> getPact(
      String myId, String otherUserId) async {
    if (myId.isEmpty || otherUserId.isEmpty) return null;
    // 🤖 Pocket Talk is strictly between human learners; robots are excluded
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
          startedAt:
              DateTime.tryParse(decoded['startedAt'] ?? '') ?? DateTime.now(),
          streakDays: int.tryParse(decoded['streakDays'] ?? '1') ?? 1,
          lastSpokenDate: decoded['lastSpokenDate'] ?? '',
          dailyMinutesToday:
              int.tryParse(decoded['dailyMinutesToday'] ?? '0') ?? 0,
          isAccepted: decoded['isAccepted'] == 'true',
          isCompleted: decoded['isCompleted'] == 'true',
          isMatesNow: decoded['isMatesNow'] == 'true',
          trophiesEarned: int.tryParse(decoded['trophiesEarned'] ?? '0') ?? 0,
          isForfeited: decoded['isForfeited'] == 'true',
          hasBothSpoken: decoded['hasBothSpoken'] == 'true',
          user1Days: int.tryParse(decoded['user1Days'] ?? '0') ?? 0,
          user2Days: int.tryParse(decoded['user2Days'] ?? '0') ?? 0,
        );
      }
    } catch (_) {}

    return null;
  }

  /// Whether the user is eligible to initiate a new Pocket Talk request.
  /// Returns false once the user reaches 4 active agreements (kMaxActivePacts).
  static Future<bool> canInitiateNewPact(String userId) async {
    if (userId.isEmpty) return false;
    final activeIds = await getAllActiveAcceptedPactUserIds(userId);
    return activeIds.length < kMaxActivePacts;
  }

  /// Request or start a 4-Day Spoken Pact between two users (human or robot)
  static Future<PocketTalkPact?> requestPact({
    required String myId,
    required String otherUserId,
    bool autoAccept = false,
  }) async {
    if (myId.isEmpty || otherUserId.isEmpty || myId == otherUserId) return null;

    // 🤖 Pocket Talk is strictly between human learners! Robots do not participate.
    if (PocketRobotService.isRobotId(otherUserId) ||
        PocketPresidentService.isPresidentId(otherUserId) ||
        PocketRobotService.isRobotId(myId) ||
        PocketPresidentService.isPresidentId(myId)) {
      debugPrint('PocketTalk is strictly for human learners. Excluded robot/president.');
      return null;
    }

    // 🔒 4-Agreement Cap: If user already has 4 active agreements, block new pact creation!
    final canStart = await canInitiateNewPact(myId);
    if (!canStart) {
      debugPrint('User $myId has reached max active pacts ($kMaxActivePacts). Cannot request more.');
      return null;
    }

    final existing = await getPact(myId, otherUserId);
    if (existing != null) {
      return existing;
    }

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
  }) =>
      requestPact(myId: myId, otherUserId: otherUserId, autoAccept: autoAccept);

  /// Accept an incoming PocketTalk Spoken Pact request
  static Future<PocketTalkPact?> acceptPact({
    required String myId,
    required String otherUserId,
  }) async {
    var pact = await getPact(myId, otherUserId);
    if (pact == null) {
      final pactId = _generatePactId(myId, otherUserId);
      pact = PocketTalkPact(
        pactId: pactId,
        user1Id: otherUserId,
        user2Id: myId,
        initiatorId: otherUserId,
        startedAt: DateTime.now(),
        streakDays: 1,
        lastSpokenDate: _getTodayDateString(),
        dailyMinutesToday: 0,
        isAccepted: true,
        isCompleted: false,
        isMatesNow: false,
        trophiesEarned: 0,
        isForfeited: false,
      );
      await _savePact(pact);
      return pact;
    }

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

    // 🔒 SMART ACTIVE-CAP:
    // Only cancel extra pending pacts once user has reached the 3-pact target cap!
    // This guarantees each user can have up to 3 active speaking pairs as requested.
    final myActive = await getAllActiveAcceptedPactUserIds(myId);
    if (myActive.length >= kMaxActivePacts) {
      await cancelOtherPendingPacts(myId, exceptPeerId: otherUserId);
    }
    final otherActive = await getAllActiveAcceptedPactUserIds(otherUserId);
    if (otherActive.length >= kMaxActivePacts) {
      await cancelOtherPendingPacts(otherUserId, exceptPeerId: myId);
    }

    return accepted;
  }

  /// Cancel/Freeze all other pending pact requests for this user, ensuring single-focus on 1 partner
  static Future<void> cancelOtherPendingPacts(String userId,
      {required String exceptPeerId}) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys =
          prefs.getKeys().where((k) => k.startsWith(kPrefsPactPrefix)).toList();
      for (final k in keys) {
        final val = prefs.getString(k);
        if (val != null && val.contains(userId)) {
          final decoded = Uri.splitQueryString(val);
          final u1 = decoded['user1Id'] ?? '';
          final u2 = decoded['user2Id'] ?? '';
          final peerId = (u1 == userId) ? u2 : u1;
          final isAccepted = decoded['isAccepted'] == 'true';

          // If pending and not the accepted partner, cancel it
          if (!isAccepted && peerId != exceptPeerId && peerId.isNotEmpty) {
            await prefs.remove(k);
          }
        }
      }
    } catch (e) {
      debugPrint('Error canceling other pending pacts: $e');
    }
  }

  /// Graduate a completed 4-day Pocket Talk pact into permanent Pocket Mates
  static Future<bool> graduatePactToMates({
    required String myId,
    required String otherUserId,
  }) async {
    if (myId.isEmpty || otherUserId.isEmpty) return false;
    try {
      final pact = await getPact(myId, otherUserId);
      if (pact != null) {
        final graduated = PocketTalkPact(
          pactId: pact.pactId,
          user1Id: pact.user1Id,
          user2Id: pact.user2Id,
          initiatorId: pact.initiatorId,
          startedAt: pact.startedAt,
          streakDays: pact.streakDays,
          lastSpokenDate: pact.lastSpokenDate,
          dailyMinutesToday: pact.dailyMinutesToday,
          isAccepted: true,
          isCompleted: true,
          isMatesNow: true,
          trophiesEarned: pact.trophiesEarned,
          isForfeited: false,
          hasBothSpoken: pact.hasBothSpoken,
        );
        await _savePact(graduated);
      }

      // Add to local mates list for both
      await PocketMateService.addMateLocally(myId, otherUserId);
      await PocketMateService.addMateLocally(otherUserId, myId);

      // Persist mutual follow in Supabase if not robot
      if (!PocketRobotService.isRobotId(otherUserId) &&
          !otherUserId.startsWith('robot_')) {
        try {
          await _supabase.from('follows').upsert([
            {
              'follower_id': myId,
              'followed_id': otherUserId,
              'created_at': DateTime.now().toIso8601String(),
            },
            {
              'follower_id': otherUserId,
              'followed_id': myId,
              'created_at': DateTime.now().toIso8601String(),
            }
          ]);
        } catch (_) {}
      }
      return true;
    } catch (e) {
      debugPrint('Error graduating pact to mates: $e');
      return false;
    }
  }

  /// Natural expiration or dismissal of a completed/expired pact
  static Future<void> expirePact({
    required String myId,
    required String otherUserId,
  }) async {
    final pactId = _generatePactId(myId, otherUserId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$kPrefsPactPrefix$pactId');
    } catch (_) {}
  }

  /// 🔄 Day 1 Grace Period & Polite Partner Swap:
  /// Allows either partner to swap or decline during Day 1 with ZERO penalty.
  /// Automatically clears this pact and refills with a fresh companion!
  static Future<bool> swapOrDeclinePartner({
    required String myId,
    required String otherUserId,
    String reason = 'vibe_mismatch',
  }) async {
    if (myId.isEmpty || otherUserId.isEmpty) return false;
    try {
      final pactId = _generatePactId(myId, otherUserId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$kPrefsPactPrefix$pactId');
      return true;
    } catch (e) {
      debugPrint('Error swapping partner: $e');
      return false;
    }
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

    // 🛡️ Asymmetric Protection: Never penalize an active user whose partner is inactive!
    final prefs = await SharedPreferences.getInstance();
    final myDates =
        prefs.getStringList('pocket_pact_user_dates_${pact.pactId}_$myId') ?? [];
    if (myDates.isNotEmpty) {
      return PactEvaluationResult(pact: pact);
    }

    final daysDiff = _daysBetween(pact.lastSpokenDate, today);

    // If 1 day difference (i.e. yesterday):
    if (daysDiff == 1) {
      if (pact.dailyMinutesToday >= kDailyRequiredMinutes) {
        // Yesterday's session was accomplished! Advance to next day's session
        final nextStreak = pact.streakDays < kPactRequiredDays
            ? pact.streakDays + 1
            : pact.streakDays;
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
      }
    }

    return PactEvaluationResult(pact: pact);
  }

  /// 📅 Record daily chat/spoken activity for a specific user in a 4-day pact.
  /// When sender sends any message (text or voice) on a calendar day:
  /// 1. Adds today's date (YYYY-MM-DD) to that user's completed dates for this pact.
  /// 2. Immune to Supabase message deletion (12-24 hr cleanup) because dates are recorded in persistent state.
  /// 3. Independent: User A reaches 4 days -> User A gets Trophy 🏆, even if User B never replied!
  /// 4. User B only receives a trophy when User B also reaches 4 days.
  static Future<({bool didCompleteDay, bool didUnlockTrophy, int currentDays})>
      recordUserDailyChatActivity({
    required String senderId,
    required String receiverId,
  }) async {
    if (senderId.isEmpty || receiverId.isEmpty) {
      return (didCompleteDay: false, didUnlockTrophy: false, currentDays: 0);
    }
    if (PocketRobotService.isRobotId(senderId) ||
        PocketRobotService.isRobotId(receiverId) ||
        PocketPresidentService.isPresidentId(senderId) ||
        PocketPresidentService.isPresidentId(receiverId)) {
      return (didCompleteDay: false, didUnlockTrophy: false, currentDays: 0);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final pactId = _generatePactId(senderId, receiverId);
      final today = _getTodayDateString();

      final datesKey = 'pocket_pact_user_dates_${pactId}_$senderId';
      final completedDates = (prefs.getStringList(datesKey) ?? []).toSet();
      final isNewDay = !completedDates.contains(today);

      if (isNewDay) {
        completedDates.add(today);
        await prefs.setStringList(datesKey, completedDates.toList());
      }

      // Check trophy award status for sender
      final trophyAwardedKey = 'pocket_pact_trophy_awarded_${pactId}_$senderId';
      final alreadyAwarded = prefs.getBool(trophyAwardedKey) ?? false;
      bool didUnlock = false;

      if (completedDates.length >= kPactRequiredDays && !alreadyAwarded) {
        await prefs.setBool(trophyAwardedKey, true);
        await _incrementTrophyCount(senderId);
        didUnlock = true;

        // If the other user also completed 4 days, graduate to mutual Pocket Mates!
        final otherDatesKey = 'pocket_pact_user_dates_${pactId}_$receiverId';
        final otherDates = prefs.getStringList(otherDatesKey) ?? [];
        if (otherDates.length >= kPactRequiredDays) {
          await graduatePactToMates(myId: senderId, otherUserId: receiverId);
        }
      }

      // Keep pact model synced in memory / local store
      var pact = await getPact(senderId, receiverId);
      if (pact != null) {
        final otherDatesKey = 'pocket_pact_user_dates_${pactId}_$receiverId';
        final otherDates = prefs.getStringList(otherDatesKey) ?? [];
        final bothSpoken = completedDates.isNotEmpty && otherDates.isNotEmpty;

        final u1Days = (pact.user1Id == senderId) ? completedDates.length : otherDates.length;
        final u2Days = (pact.user2Id == senderId) ? completedDates.length : otherDates.length;

        final updated = PocketTalkPact(
          pactId: pact.pactId,
          user1Id: pact.user1Id,
          user2Id: pact.user2Id,
          initiatorId: pact.initiatorId,
          startedAt: pact.startedAt,
          streakDays: math.max(u1Days, u2Days).clamp(1, kPactRequiredDays),
          lastSpokenDate: today,
          dailyMinutesToday: pact.dailyMinutesToday + 1,
          isAccepted: true,
          isCompleted: alreadyAwarded || didUnlock,
          isMatesNow: pact.isMatesNow || (completedDates.length >= kPactRequiredDays && otherDates.length >= kPactRequiredDays),
          trophiesEarned: didUnlock ? pact.trophiesEarned + 1 : pact.trophiesEarned,
          isForfeited: false,
          hasBothSpoken: bothSpoken,
          user1Days: u1Days,
          user2Days: u2Days,
        );
        await _savePact(updated);
      }

      return (
        didCompleteDay: isNewDay,
        didUnlockTrophy: didUnlock,
        currentDays: completedDates.length,
      );
    } catch (e) {
      debugPrint('Error recording user daily chat activity: $e');
      return (didCompleteDay: false, didUnlockTrophy: false, currentDays: 0);
    }
  }

  /// Get how many days a specific user has completed in this pact (0 to 4)
  static Future<int> getUserCompletedPactDays({
    required String userId,
    required String otherUserId,
  }) async {
    if (userId.isEmpty || otherUserId.isEmpty) return 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      final pactId = _generatePactId(userId, otherUserId);
      final dates = prefs.getStringList('pocket_pact_user_dates_${pactId}_$userId');
      return dates?.length ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Accumulate active chat minutes today towards the daily threshold
  static Future<
      ({
        PocketTalkPact? pact,
        bool didCompleteDayQuota,
        bool didUnlockTrophy,
      })> recordActiveChatMinutes({
    required String myId,
    required String otherUserId,
    int minutesToAdd = 1,
  }) async {
    final act = await recordUserDailyChatActivity(
      senderId: myId,
      receiverId: otherUserId,
    );
    final pact = await getPact(myId, otherUserId);
    return (
      pact: pact,
      didCompleteDayQuota: act.didCompleteDay,
      didUnlockTrophy: act.didUnlockTrophy,
    );
  }

  /// Legacy compatibility wrapper
  static Future<({PocketTalkPact? pact, bool didUnlockTrophy})>
      recordDailySpokenInteraction({
    required String myId,
    required String otherUserId,
  }) async {
    final res = await recordActiveChatMinutes(
        myId: myId, otherUserId: otherUserId, minutesToAdd: 1);
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
    if (PocketRobotService.isRobotId(otherUserId)) {
      return true; // Robots always public
    }

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
          if (!val.contains('isCompleted=true') &&
              !val.contains('isForfeited=true')) {
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
  static Future<bool> hasActiveOrPendingPact(
      String myId, String otherUserId) async {
    final pact = await getPact(myId, otherUserId);
    if (pact == null) return false;
    return !pact.isForfeited && !pact.isCompleted;
  }

  /// Check whether the user currently has ANY active accepted 4-day pact
  static Future<bool> hasAnyActiveAcceptedPact(String userId) async {
    if (userId.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(kPrefsPactPrefix));
      for (final k in keys) {
        final val = prefs.getString(k);
        if (val != null && val.contains(userId)) {
          final decoded = Uri.splitQueryString(val);
          final isAccepted = decoded['isAccepted'] == 'true';
          final isForfeited = decoded['isForfeited'] == 'true';
          final isCompleted = decoded['isCompleted'] == 'true';
          if (isAccepted && !isForfeited && !isCompleted) {
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  /// Get all user IDs who have an active accepted 4-day pact with this user
  static Future<Set<String>> getAllActiveAcceptedPactUserIds(
      String userId) async {
    final result = <String>{};
    if (userId.isEmpty) return result;
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(kPrefsPactPrefix));
      for (final k in keys) {
        final val = prefs.getString(k);
        if (val != null && val.contains(userId)) {
          final decoded = Uri.splitQueryString(val);
          final isAccepted = decoded['isAccepted'] == 'true';
          final isForfeited = decoded['isForfeited'] == 'true';
          final isCompleted = decoded['isCompleted'] == 'true';
          if (isAccepted && !isForfeited && !isCompleted) {
            final u1 = decoded['user1Id'];
            final u2 = decoded['user2Id'];
            if (u1 != null &&
                u1 != userId &&
                !PocketRobotService.isRobotId(u1) &&
                !PocketPresidentService.isPresidentId(u1)) {
              result.add(u1);
            }
            if (u2 != null &&
                u2 != userId &&
                !PocketRobotService.isRobotId(u2) &&
                !PocketPresidentService.isPresidentId(u2)) {
              result.add(u2);
            }
          }
        }
      }
    } catch (_) {}
    return result;
  }

  /// Get all user IDs who have a pending (unaccepted) pact invite with this user
  static Future<Set<String>> getAllPendingPactUserIds(String userId) async {
    final result = <String>{};
    if (userId.isEmpty) return result;
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(kPrefsPactPrefix));
      for (final k in keys) {
        final val = prefs.getString(k);
        if (val != null && val.contains(userId)) {
          final decoded = Uri.splitQueryString(val);
          final isAccepted = decoded['isAccepted'] == 'true';
          final isForfeited = decoded['isForfeited'] == 'true';
          final isCompleted = decoded['isCompleted'] == 'true';
          if (!isAccepted && !isForfeited && !isCompleted) {
            final u1 = decoded['user1Id'];
            final u2 = decoded['user2Id'];
            if (u1 != null &&
                u1 != userId &&
                !PocketRobotService.isRobotId(u1) &&
                !PocketPresidentService.isPresidentId(u1)) {
              result.add(u1);
            }
            if (u2 != null &&
                u2 != userId &&
                !PocketRobotService.isRobotId(u2) &&
                !PocketPresidentService.isPresidentId(u2)) {
              result.add(u2);
            }
          }
        }
      }
    } catch (_) {}
    return result;
  }

  /// Get all other user IDs who have an active or pending pact with this user
  static Future<Set<String>> getAllActiveOrPendingPactUserIds(
      String userId) async {
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

  /// Record user message engagement to record daily activity and unlock streak protection
  static Future<void> markUserEngagement({
    required String myId,
    required String otherUserId,
  }) async {
    await recordUserDailyChatActivity(senderId: myId, receiverId: otherUserId);
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
      'user1Days': pact.user1Days.toString(),
      'user2Days': pact.user2Days.toString(),
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
            .update({'trophies_count': newCount}).eq('user_id', userId);
      } catch (_) {}
    } catch (_) {}
  }

  /// AI / regex detector for non-English letters (delegated to PocketLanguageGuardService)
  static bool _detectNonEnglishText(String text) {
    if (text.isEmpty) return false;
    final check = PocketLanguageGuardService.checkMessage(text);
    return !check.isValid;
  }
}

/// ⚡ PocketTalkPactService alias for PocketTrophyService
typedef PocketTalkPactService = PocketTrophyService;
