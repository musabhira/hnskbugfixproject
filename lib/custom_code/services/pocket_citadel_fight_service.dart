import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_challenge_generator.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';

/// 🥊 Model for a Citadel Fight Challenge / Duel
class CitadelFightChallenge {
  final String id;
  final String challengerId;
  final String challengerName;
  final String challengerAvatar;
  final String opponentId;
  final String opponentName;
  final String opponentAvatar;
  final String gameFormat;
  final String gameTitle;
  final String scheduledTime;
  final String status; // 'pending', 'pending_opponent', 'accepted', 'completed', 'declined'
  final String? winnerId;
  final int challengerScore;
  final int challengerSeconds;
  final int opponentScore;
  final int opponentSeconds;
  final int questionCount;
  final int duelSeed;
  final int challengerCorrect;
  final int opponentCorrect;
  final double challengerTimeSeconds;
  final double opponentTimeSeconds;
  final DateTime createdAt;

  const CitadelFightChallenge({
    required this.id,
    required this.challengerId,
    required this.challengerName,
    required this.challengerAvatar,
    required this.opponentId,
    required this.opponentName,
    required this.opponentAvatar,
    required this.gameFormat,
    required this.gameTitle,
    required this.scheduledTime,
    this.status = 'pending',
    this.winnerId,
    this.challengerScore = 0,
    this.challengerSeconds = 0,
    this.opponentScore = 0,
    this.opponentSeconds = 0,
    this.questionCount = 20,
    this.duelSeed = 20240607,
    this.challengerCorrect = 0,
    this.opponentCorrect = 0,
    this.challengerTimeSeconds = 0.0,
    this.opponentTimeSeconds = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'challenger_id': challengerId,
        'challenger_name': challengerName,
        'challenger_avatar': challengerAvatar,
        'opponent_id': opponentId,
        'opponent_name': opponentName,
        'opponent_avatar': opponentAvatar,
        'game_format': gameFormat,
        'game_title': gameTitle,
        'scheduled_time': scheduledTime,
        'status': status,
        'winner_id': winnerId,
        'challenger_score': challengerScore,
        'challenger_seconds': challengerSeconds,
        'opponent_score': opponentScore,
        'opponent_seconds': opponentSeconds,
        'question_count': questionCount,
        'duel_seed': duelSeed,
        'challenger_correct': challengerCorrect,
        'opponent_correct': opponentCorrect,
        'challenger_time_seconds': challengerTimeSeconds,
        'opponent_time_seconds': opponentTimeSeconds,
        'created_at': createdAt.toIso8601String(),
      };

  factory CitadelFightChallenge.fromJson(Map<String, dynamic> json) {
    return CitadelFightChallenge(
      id: json['id']?.toString() ?? '',
      challengerId: json['challenger_id']?.toString() ?? '',
      challengerName: json['challenger_name']?.toString() ?? 'Challenger',
      challengerAvatar: json['challenger_avatar']?.toString() ?? '⚔️',
      opponentId: json['opponent_id']?.toString() ?? '',
      opponentName: json['opponent_name']?.toString() ?? 'Opponent',
      opponentAvatar: json['opponent_avatar']?.toString() ?? '🛡️',
      gameFormat: json['game_format']?.toString() ?? 'sentence_builder',
      gameTitle: json['game_title']?.toString() ?? 'Sentence Builder Battle',
      scheduledTime: json['scheduled_time']?.toString() ?? 'Instant (Now)',
      status: json['status']?.toString() ?? 'pending',
      winnerId: json['winner_id']?.toString(),
      challengerScore: (json['challenger_score'] as num?)?.toInt() ?? 0,
      challengerSeconds: (json['challenger_seconds'] as num?)?.toInt() ?? 0,
      opponentScore: (json['opponent_score'] as num?)?.toInt() ?? 0,
      opponentSeconds: (json['opponent_seconds'] as num?)?.toInt() ?? 0,
      questionCount: (json['question_count'] as num?)?.toInt() ?? 20,
      duelSeed: (json['duel_seed'] as num?)?.toInt() ?? 20240607,
      challengerCorrect: (json['challenger_correct'] as num?)?.toInt() ?? 0,
      opponentCorrect: (json['opponent_correct'] as num?)?.toInt() ?? 0,
      challengerTimeSeconds: (json['challenger_time_seconds'] as num?)?.toDouble() ??
          ((json['challenger_seconds'] as num?)?.toDouble() ?? 0.0),
      opponentTimeSeconds: (json['opponent_time_seconds'] as num?)?.toDouble() ??
          ((json['opponent_seconds'] as num?)?.toDouble() ?? 0.0),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// 🥊 Central Service for English Citadel Fights & Speed Duels
class PocketCitadelFightService {
  static const String _kPrefsFightsPrefix = 'pocket_citadel_fights_';

  /// 🎮 Returns available speed game modes for Fight challenges
  static List<DefenseGameTypeInfo> getAvailableFightGames() {
    return PocketCitadelChallengeGenerator.availableGameTypes;
  }

  /// ⏰ Predefined schedule timing options for fight invitations
  static const List<String> scheduleTimeOptions = [
    '⚡ Instant (Now)',
    '⏰ In 15 Minutes',
    '⏰ In 30 Minutes',
    '⏰ In 1 Hour',
    '🌙 Tonight at 8:00 PM',
  ];

  /// 🚀 Create and send a new Fight Challenge
  static Future<CitadelFightChallenge> sendFightChallenge({
    required String challengerId,
    required String challengerName,
    required String challengerAvatar,
    required String opponentId,
    required String opponentName,
    required String opponentAvatar,
    required String gameFormat,
    required String gameTitle,
    required String scheduledTime,
    int questionCount = 20,
    int? duelSeed,
  }) async {
    final fightId = 'fight_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(9999)}';
    final seed = duelSeed ?? ((DateTime.now().microsecondsSinceEpoch ^ math.Random().nextInt(99999999)) & 0x7FFFFFFF);
    final challenge = CitadelFightChallenge(
      id: fightId,
      challengerId: challengerId,
      challengerName: challengerName,
      challengerAvatar: challengerAvatar,
      opponentId: opponentId,
      opponentName: opponentName,
      opponentAvatar: opponentAvatar,
      gameFormat: gameFormat,
      gameTitle: gameTitle,
      scheduledTime: scheduledTime,
      questionCount: questionCount,
      duelSeed: seed,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    await _saveChallenge(challenge);

    // Sync to Supabase citadel_fights if table exists
    try {
      await SupaFlow.client.from('citadel_fights').insert(challenge.toJson());
    } catch (_) {}

    return challenge;
  }

  /// 🥊 Record Challenger's initial fight run ("ഞാൻ ഫൈറ്റ് ചെയ്തിട്ടു")
  static Future<CitadelFightChallenge> recordChallengerFightRun({
    required CitadelFightChallenge challenge,
    required int score,
    required int seconds,
    int? challengerCorrect,
    double? challengerTimeSeconds,
    int? duelSeed,
  }) async {
    final updated = CitadelFightChallenge(
      id: challenge.id,
      challengerId: challenge.challengerId,
      challengerName: challenge.challengerName,
      challengerAvatar: challenge.challengerAvatar,
      opponentId: challenge.opponentId,
      opponentName: challenge.opponentName,
      opponentAvatar: challenge.opponentAvatar,
      gameFormat: challenge.gameFormat,
      gameTitle: challenge.gameTitle,
      scheduledTime: challenge.scheduledTime,
      status: 'pending_opponent',
      challengerScore: score,
      challengerSeconds: seconds,
      challengerCorrect: challengerCorrect ?? (score / 180).round().clamp(0, challenge.questionCount),
      challengerTimeSeconds: challengerTimeSeconds ?? seconds.toDouble(),
      duelSeed: duelSeed ?? challenge.duelSeed,
      questionCount: challenge.questionCount,
      createdAt: challenge.createdAt,
    );

    await _saveChallenge(updated);

    // Send In-App & Supabase Notification to Opponent
    try {
      await SupaFlow.client.from('notifications').insert({
        'user_id': challenge.opponentId,
        'sender_id': challenge.challengerId,
        'type': 'citadel_fight',
        'title': '🥊 Citadel Fight Challenge!',
        'message': '⚔️ ${challenge.challengerName} completed a Fight challenge in ${seconds}s ($score pts)! Can you beat their time? Tap to Fight Back!',
        'status': 'pending',
        'data': {
          'fight_id': challenge.id,
          'challenger_name': challenge.challengerName,
          'challenger_seconds': seconds,
          'challenger_score': score,
          'question_count': challenge.questionCount,
          'duel_seed': updated.duelSeed,
          'challenger_correct': updated.challengerCorrect,
          'challenger_time_seconds': updated.challengerTimeSeconds,
        },
      });
    } catch (_) {}

    // Send Chat Message to Opponent
    try {
      await SupaFlow.client.from('messages').insert({
        'sender_id': challenge.challengerId,
        'receiver_id': challenge.opponentId,
        'message_text': '🥊 CITADEL FIGHT CHALLENGE!\nI finished the speed duel in ${seconds}s with $score pts! Can you beat my time? Tap to FIGHT BACK! ⚔️',
        'message_type': 'citadel_fight',
        'metadata': {
          'fight_id': challenge.id,
          'challenger_name': challenge.challengerName,
          'challenger_seconds': seconds,
          'challenger_score': score,
          'question_count': challenge.questionCount,
          'duel_seed': updated.duelSeed,
          'challenger_correct': updated.challengerCorrect,
          'challenger_time_seconds': updated.challengerTimeSeconds,
        },
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}

    // If opponent is a Robot, trigger realistic asynchronous robot fight-back after 5s
    if (PocketRobotService.isRobotId(challenge.opponentId) ||
        challenge.opponentId.startsWith('robot_')) {
      _simulateRobotFightBack(updated);
    }

    return updated;
  }

  /// 🥊 Settle Opponent's fight run and determine the winner!
  static Future<CitadelFightChallenge> resolveOpponentFightRun({
    required CitadelFightChallenge challenge,
    required int opponentScore,
    required int opponentSeconds,
    int? opponentCorrect,
    double? opponentTimeSeconds,
  }) async {
    // Determine winner:
    // 1. More correct answers wins unconditionally!
    // 2. If equal correct answers, faster speed (fewer seconds) wins as tie-breaker!
    final aC = challenge.challengerCorrect;
    final bC = opponentCorrect ?? (opponentScore / 180).round().clamp(0, challenge.questionCount);
    final aT = challenge.challengerTimeSeconds > 0
        ? challenge.challengerTimeSeconds
        : challenge.challengerSeconds.toDouble();
    final bT = opponentTimeSeconds ?? opponentSeconds.toDouble();

    String winnerId;
    if (bC != aC) {
      winnerId = bC > aC ? challenge.opponentId : challenge.challengerId;
    } else if ((bT - aT).abs() > 0.0005) {
      winnerId = bT < aT ? challenge.opponentId : challenge.challengerId;
    } else {
      winnerId = 'draw';
    }

    final updated = CitadelFightChallenge(
      id: challenge.id,
      challengerId: challenge.challengerId,
      challengerName: challenge.challengerName,
      challengerAvatar: challenge.challengerAvatar,
      opponentId: challenge.opponentId,
      opponentName: challenge.opponentName,
      opponentAvatar: challenge.opponentAvatar,
      gameFormat: challenge.gameFormat,
      gameTitle: challenge.gameTitle,
      scheduledTime: challenge.scheduledTime,
      status: 'completed',
      winnerId: winnerId,
      challengerScore: challenge.challengerScore,
      challengerSeconds: challenge.challengerSeconds,
      opponentScore: opponentScore,
      opponentSeconds: opponentSeconds,
      questionCount: challenge.questionCount,
      duelSeed: challenge.duelSeed,
      challengerCorrect: aC,
      opponentCorrect: bC,
      challengerTimeSeconds: aT,
      opponentTimeSeconds: bT,
      createdAt: challenge.createdAt,
    );

    await _saveChallenge(updated);

    // Award Trophy to winner:
    // English Citadel / 60-Day -> 🏆 Gold Trophy!
    // Pocket Talk -> 🥈 Silver Trophy!
    final isPocketTalk = challenge.gameFormat.toLowerCase().contains('talk') || challenge.gameFormat.toLowerCase().contains('spoken');
    if (isPocketTalk) {
      await PocketTrophyService.awardSilverTrophy(winnerId, 1);
    } else {
      await PocketTrophyService.awardGoldTrophy(winnerId, 1);
    }

    // Award Pocket Score to winner
    try {
      await SupaFlow.client.rpc('increment_pocket_score', params: {
        'user_id': winnerId,
        'amount': 250,
      });
    } catch (_) {}

    // Send Completion Notification & Chat message with clear accuracy breakdown
    final isDraw = winnerId == 'draw';
    final isChallengerWinner = winnerId == challenge.challengerId;
    final winnerName = isDraw ? 'Draw' : (isChallengerWinner ? challenge.challengerName : challenge.opponentName);
    final winScore = isChallengerWinner ? challenge.challengerScore : opponentScore;
    final winCorrect = isChallengerWinner ? aC : bC;
    final winTime = (isChallengerWinner ? aT : bT).toStringAsFixed(1);
    final loserName = isChallengerWinner ? challenge.opponentName : challenge.challengerName;
    final loserScore = isChallengerWinner ? opponentScore : challenge.challengerScore;
    final loserCorrect = isChallengerWinner ? bC : aC;
    final loserTime = (isChallengerWinner ? bT : aT).toStringAsFixed(1);

    final String resultHeadline = isDraw
        ? '🤝 Legendary Draw! Both scored $aC/${challenge.questionCount} correct!'
        : bC != aC
            ? '🏆 $winnerName won on accuracy! ($winCorrect/${challenge.questionCount} correct in ${winTime}s vs $loserCorrect/${challenge.questionCount} in ${loserTime}s)'
            : '⚡ $winnerName won on speed tie-breaker! (Both $aC/${challenge.questionCount} correct • ${winTime}s vs ${loserTime}s)';

    try {
      for (final uid in [challenge.challengerId, challenge.opponentId]) {
        await SupaFlow.client.from('notifications').insert({
          'user_id': uid,
          'sender_id': winnerId,
          'type': 'citadel_fight_result',
          'title': '🏆 Fight Duel Settled!',
          'message': resultHeadline,
          'status': 'completed',
        });
      }
    } catch (_) {}

    try {
      await SupaFlow.client.from('messages').insert({
        'sender_id': challenge.opponentId,
        'receiver_id': challenge.challengerId,
        'message_text': '🏆 FIGHT DUEL SETTLED!\n$resultHeadline\n• $winnerName: $winCorrect/${challenge.questionCount} correct in ${winTime}s ($winScore pts)\n• $loserName: $loserCorrect/${challenge.questionCount} correct in ${loserTime}s ($loserScore pts)\n+1 Trophy awarded! 🌟',
        'message_type': 'citadel_fight_result',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}

    // Clear pending fight notification in Supabase
    try {
      await SupaFlow.client
          .from('notifications')
          .update({'status': 'resolved'})
          .eq('type', 'citadel_fight')
          .filter('data->>fight_id', 'eq', challenge.id);
    } catch (_) {}

    return updated;
  }

  /// 🤖 Asynchronous robot fight-back simulation (fires ~5s after user finishes duel)
  static void _simulateRobotFightBack(CitadelFightChallenge challenge) {
    Future<void>.delayed(const Duration(seconds: 5), () async {
      try {
        final r = math.Random();
        final qCount = challenge.questionCount > 0 ? challenge.questionCount : 20;
        final userCorrect = challenge.challengerCorrect;
        final userTime = challenge.challengerTimeSeconds > 0
            ? challenge.challengerTimeSeconds
            : (challenge.challengerSeconds > 0 ? challenge.challengerSeconds.toDouble() : 45.0);

        // Robot plays realistically:
        // ACCURACY IS THE DECISIVE FACTOR:
        final robotWins = r.nextDouble() < 0.45;

        int robotCorrect;
        double robotTime;

        if (robotWins) {
          // Robot wins by having HIGHER accuracy (or equal accuracy with faster time)
          if (userCorrect < qCount) {
            robotCorrect = math.min(qCount, userCorrect + (1 + r.nextInt(2)));
            robotTime = math.max(12.0, userTime * (0.85 + r.nextDouble() * 0.25));
          } else {
            robotCorrect = qCount;
            robotTime = math.max(10.0, userTime - (1.5 + r.nextDouble() * 3.0));
          }
        } else {
          // Robot loses: Robot gets FEWER correct answers than user (or equal with slower time)
          if (userCorrect > 0) {
            robotCorrect = math.max(0, userCorrect - (1 + r.nextInt(3)));
            // Even if robot took less time, user wins on accuracy!
            robotTime = userTime * (0.8 + r.nextDouble() * 0.4);
          } else {
            robotCorrect = 0;
            robotTime = userTime + (3.0 + r.nextDouble() * 5.0);
          }
        }

        final robotScore = (robotCorrect * 110 + (qCount * 10 / math.max(1.0, robotTime / 10)).round()).clamp(50, 3000);

        await resolveOpponentFightRun(
          challenge: challenge,
          opponentScore: robotScore,
          opponentSeconds: robotTime.round(),
          opponentCorrect: robotCorrect,
          opponentTimeSeconds: robotTime,
        );
      } catch (_) {}
    });
  }

  /// 📜 Get pending fight challenges for a user
  static Future<List<CitadelFightChallenge>> getPendingChallenges(String userId) async {
    final list = await getAllChallenges(userId);
    return list.where((f) => f.opponentId == userId && (f.status == 'pending' || f.status == 'pending_opponent')).toList();
  }

  /// 📜 Get all fight challenges involving a user
  static Future<List<CitadelFightChallenge>> getAllChallenges(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_kPrefsFightsPrefix$userId');
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => CitadelFightChallenge.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  /// 🤝 Accept a fight challenge
  static Future<void> acceptFightChallenge(String fightId, String userId) async {
    final list = await getAllChallenges(userId);
    final idx = list.indexWhere((c) => c.id == fightId);
    if (idx != -1) {
      final updated = CitadelFightChallenge(
        id: list[idx].id,
        challengerId: list[idx].challengerId,
        challengerName: list[idx].challengerName,
        challengerAvatar: list[idx].challengerAvatar,
        opponentId: list[idx].opponentId,
        opponentName: list[idx].opponentName,
        opponentAvatar: list[idx].opponentAvatar,
        gameFormat: list[idx].gameFormat,
        gameTitle: list[idx].gameTitle,
        scheduledTime: list[idx].scheduledTime,
        questionCount: list[idx].questionCount,
        status: 'accepted',
        challengerScore: list[idx].challengerScore,
        challengerSeconds: list[idx].challengerSeconds,
        opponentScore: list[idx].opponentScore,
        opponentSeconds: list[idx].opponentSeconds,
        createdAt: list[idx].createdAt,
      );
      await _saveChallenge(updated);
    }
  }

  /// 🚫 Decline a fight challenge
  static Future<void> declineFightChallenge(String fightId, String userId) async {
    final list = await getAllChallenges(userId);
    final idx = list.indexWhere((c) => c.id == fightId);
    if (idx != -1) {
      final updated = CitadelFightChallenge(
        id: list[idx].id,
        challengerId: list[idx].challengerId,
        challengerName: list[idx].challengerName,
        challengerAvatar: list[idx].challengerAvatar,
        opponentId: list[idx].opponentId,
        opponentName: list[idx].opponentName,
        opponentAvatar: list[idx].opponentAvatar,
        gameFormat: list[idx].gameFormat,
        gameTitle: list[idx].gameTitle,
        scheduledTime: list[idx].scheduledTime,
        questionCount: list[idx].questionCount,
        status: 'declined',
        challengerScore: list[idx].challengerScore,
        challengerSeconds: list[idx].challengerSeconds,
        opponentScore: list[idx].opponentScore,
        opponentSeconds: list[idx].opponentSeconds,
        createdAt: list[idx].createdAt,
      );
      await _saveChallenge(updated);
    }
  }

  /// 🏆 Complete a fight and award a Gold Trophy 🏆 to the winner
  static Future<void> completeFight({
    required String fightId,
    required String winnerId,
    required int challengerScore,
    required int opponentScore,
  }) async {
    final myId = SupaFlow.client.auth.currentUser?.id ?? 'me';
    final list = await getAllChallenges(myId);
    final idx = list.indexWhere((c) => c.id == fightId);
    if (idx != -1) {
      final updated = CitadelFightChallenge(
        id: list[idx].id,
        challengerId: list[idx].challengerId,
        challengerName: list[idx].challengerName,
        challengerAvatar: list[idx].challengerAvatar,
        opponentId: list[idx].opponentId,
        opponentName: list[idx].opponentName,
        opponentAvatar: list[idx].opponentAvatar,
        gameFormat: list[idx].gameFormat,
        gameTitle: list[idx].gameTitle,
        scheduledTime: list[idx].scheduledTime,
        questionCount: list[idx].questionCount,
        status: 'completed',
        winnerId: winnerId,
        challengerScore: challengerScore,
        challengerSeconds: list[idx].challengerSeconds,
        opponentScore: opponentScore,
        opponentSeconds: list[idx].opponentSeconds,
        createdAt: list[idx].createdAt,
      );
      await _saveChallenge(updated);
    }

    // Award Gold Trophy 🏆 to the winner!
    if (winnerId.isNotEmpty) {
      await PocketTrophyService.awardGoldTrophy(winnerId, 1);
    }
  }

  static Future<void> _saveChallenge(CitadelFightChallenge challenge) async {
    final prefs = await SharedPreferences.getInstance();
    for (final uid in [challenge.challengerId, challenge.opponentId]) {
      if (uid.isEmpty) continue;
      final existing = await getAllChallenges(uid);
      final idx = existing.indexWhere((c) => c.id == challenge.id);
      if (idx != -1) {
        existing[idx] = challenge;
      } else {
        existing.insert(0, challenge);
      }
      await prefs.setString(
        '$_kPrefsFightsPrefix$uid',
        jsonEncode(existing.map((e) => e.toJson()).toList()),
      );
    }
  }
}
