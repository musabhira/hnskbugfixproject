import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';

/// 🏆 Model representing an active or completed PocketTalk 4-Day Spoken Pact
class PocketTalkPact {
  final String pactId;
  final String user1Id;
  final String user2Id;
  final DateTime startedAt;
  final int streakDays; // 0 to 4
  final String lastSpokenDate; // 'YYYY-MM-DD'
  final bool isCompleted; // True when 4 days achieved & trophy minted
  final bool isMatesNow; // True when officially unlocked as mutual Pocket Mates
  final int trophiesEarned;

  const PocketTalkPact({
    required this.pactId,
    required this.user1Id,
    required this.user2Id,
    required this.startedAt,
    required this.streakDays,
    required this.lastSpokenDate,
    required this.isCompleted,
    required this.isMatesNow,
    this.trophiesEarned = 0,
  });

  Map<String, dynamic> toMap() => {
        'pactId': pactId,
        'user1Id': user1Id,
        'user2Id': user2Id,
        'startedAt': startedAt.toIso8601String(),
        'streakDays': streakDays,
        'lastSpokenDate': lastSpokenDate,
        'isCompleted': isCompleted,
        'isMatesNow': isMatesNow,
        'trophiesEarned': trophiesEarned,
      };

  factory PocketTalkPact.fromMap(Map<String, dynamic> map) {
    return PocketTalkPact(
      pactId: map['pactId']?.toString() ?? '',
      user1Id: map['user1Id']?.toString() ?? '',
      user2Id: map['user2Id']?.toString() ?? '',
      startedAt: map['startedAt'] != null
          ? DateTime.tryParse(map['startedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      streakDays: (map['streakDays'] as num?)?.toInt() ?? 0,
      lastSpokenDate: map['lastSpokenDate']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true,
      isMatesNow: map['isMatesNow'] == true,
      trophiesEarned: (map['trophiesEarned'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 🏛️ Central Service Managing:
/// 1. 4-Day PocketTalk Spoken Pacts
/// 2. Trophy accumulation towards the 150-Trophy 90-Day Master Graduation
/// 3. English Guard Real-time Verification & Penalty system
/// 4. Private Profile gating until 4-day pact completion
class PocketTrophyService {
  static final PocketTrophyService _instance = PocketTrophyService._internal();
  factory PocketTrophyService() => _instance;
  PocketTrophyService._internal();

  static final _supabase = SupaFlow.client;

  // Key Constants
  static const int kPactRequiredDays = 4;
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

  /// Check whether two users have an active or completed 4-day pact
  static Future<PocketTalkPact?> getPact(String myId, String otherUserId) async {
    if (myId.isEmpty || otherUserId.isEmpty) return null;
    final pactId = _generatePactId(myId, otherUserId);
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString('$kPrefsPactPrefix$pactId');
      if (str != null && str.isNotEmpty) {
        final decoded = Map<String, dynamic>.from(
            Map<String, dynamic>.from(Uri.splitQueryString(str)));
        // Custom decode or simple key-value parser
        return PocketTalkPact(
          pactId: pactId,
          user1Id: decoded['user1Id'] ?? myId,
          user2Id: decoded['user2Id'] ?? otherUserId,
          startedAt: DateTime.tryParse(decoded['startedAt'] ?? '') ?? DateTime.now(),
          streakDays: int.tryParse(decoded['streakDays'] ?? '1') ?? 1,
          lastSpokenDate: decoded['lastSpokenDate'] ?? '',
          isCompleted: decoded['isCompleted'] == 'true',
          isMatesNow: decoded['isMatesNow'] == 'true',
          trophiesEarned: int.tryParse(decoded['trophiesEarned'] ?? '0') ?? 0,
        );
      }
    } catch (_) {}

    // Default pact template if active personal chat exists
    return null;
  }

  /// Ensure or start a 4-Day Spoken Pact between two users
  static Future<PocketTalkPact> ensurePact({
    required String myId,
    required String otherUserId,
  }) async {
    final existing = await getPact(myId, otherUserId);
    if (existing != null) return existing;

    final today = _getTodayDateString();
    final pactId = _generatePactId(myId, otherUserId);
    final newPact = PocketTalkPact(
      pactId: pactId,
      user1Id: myId,
      user2Id: otherUserId,
      startedAt: DateTime.now(),
      streakDays: 1,
      lastSpokenDate: today,
      isCompleted: false,
      isMatesNow: false,
      trophiesEarned: 0,
    );

    await _savePact(newPact);
    return newPact;
  }

  /// Record daily conversation interaction between the two users
  /// Returns updated pact, and [didUnlockTrophy] as true if Day 4 was reached today!
  static Future<({PocketTalkPact pact, bool didUnlockTrophy})> recordDailySpokenInteraction({
    required String myId,
    required String otherUserId,
  }) async {
    final pact = await ensurePact(myId: myId, otherUserId: otherUserId);
    final today = _getTodayDateString();

    // If already spoken today, no streak increment needed
    if (pact.lastSpokenDate == today) {
      return (pact: pact, didUnlockTrophy: false);
    }

    final newStreak = pact.streakDays + 1;
    final didComplete = newStreak >= kPactRequiredDays;

    final updated = PocketTalkPact(
      pactId: pact.pactId,
      user1Id: pact.user1Id,
      user2Id: pact.user2Id,
      startedAt: pact.startedAt,
      streakDays: newStreak,
      lastSpokenDate: today,
      isCompleted: didComplete,
      isMatesNow: didComplete,
      trophiesEarned: didComplete ? pact.trophiesEarned + 1 : pact.trophiesEarned,
    );

    await _savePact(updated);

    if (didComplete && !pact.isCompleted) {
      // 🏆 MINT TROPHY FOR BOTH USERS!
      await _incrementTrophyCount(myId);
      await _incrementTrophyCount(otherUserId);
      return (pact: updated, didUnlockTrophy: true);
    }

    return (pact: updated, didUnlockTrophy: false);
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
        // Apply penalty in local & DB
        final pactId = _generatePactId(reporterId, violatorId);
        final currentPact = await getPact(reporterId, violatorId);

        if (currentPact != null) {
          // Reset streak to Day 1
          final penalizedPact = PocketTalkPact(
            pactId: pactId,
            user1Id: currentPact.user1Id,
            user2Id: currentPact.user2Id,
            startedAt: currentPact.startedAt,
            streakDays: 1, // Streak broken!
            lastSpokenDate: _getTodayDateString(),
            isCompleted: false,
            isMatesNow: false,
            trophiesEarned: currentPact.trophiesEarned,
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

  // --- Internal Helpers ---

  static String _generatePactId(String u1, String u2) {
    final sorted = [u1, u2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  static String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<void> _savePact(PocketTalkPact pact) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'pactId': pact.pactId,
      'user1Id': pact.user1Id,
      'user2Id': pact.user2Id,
      'startedAt': pact.startedAt.toIso8601String(),
      'streakDays': pact.streakDays.toString(),
      'lastSpokenDate': pact.lastSpokenDate,
      'isCompleted': pact.isCompleted.toString(),
      'isMatesNow': pact.isMatesNow.toString(),
      'trophiesEarned': pact.trophiesEarned.toString(),
    };
    final encoded = Uri(queryParameters: map).query;
    await prefs.setString('$kPrefsPactPrefix${pact.pactId}', encoded);
  }

  static Future<void> _incrementTrophyCount(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt('$kPrefsTrophiesCountKey$userId') ?? 0;
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

    // Check for common transliterated words if desired
    final manglish = ['enthoke', 'sugano', 'njan', 'evideya', 'chechi', 'chetta', 'mone'];
    final lower = text.toLowerCase();
    for (final word in manglish) {
      if (lower.contains(word)) return true;
    }
    return false;
  }
}
