import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_challenge_generator.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';

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
  }) async {
    final fightId = 'fight_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(9999)}';
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
        },
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}

    return updated;
  }

  /// 🥊 Settle Opponent's fight run and determine the winner!
  static Future<CitadelFightChallenge> resolveOpponentFightRun({
    required CitadelFightChallenge challenge,
    required int opponentScore,
    required int opponentSeconds,
  }) async {
    // Determine winner:
    // 1. Higher score wins.
    // 2. If equal score, faster speed (fewer seconds) wins!
    String winnerId;
    if (opponentScore > challenge.challengerScore) {
      winnerId = challenge.opponentId;
    } else if (opponentScore < challenge.challengerScore) {
      winnerId = challenge.challengerId;
    } else {
      if (opponentSeconds <= challenge.challengerSeconds) {
        winnerId = challenge.opponentId;
      } else {
        winnerId = challenge.challengerId;
      }
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

    // Send Completion Notification & Chat message
    final winnerName = winnerId == challenge.opponentId ? challenge.opponentName : challenge.challengerName;
    try {
      for (final uid in [challenge.challengerId, challenge.opponentId]) {
        await SupaFlow.client.from('notifications').insert({
          'user_id': uid,
          'sender_id': winnerId,
          'type': 'citadel_fight_result',
          'title': '🏆 Fight Duel Settled!',
          'message': '⚔️ $winnerName won the speed duel! (${challenge.challengerName}: ${challenge.challengerSeconds}s vs ${challenge.opponentName}: ${opponentSeconds}s). +1 Trophy awarded!',
          'status': 'completed',
        });
      }
    } catch (_) {}

    try {
      await SupaFlow.client.from('messages').insert({
        'sender_id': challenge.opponentId,
        'receiver_id': challenge.challengerId,
        'message_text': '🏆 FIGHT DUEL SETTLED!\n$winnerName won the speed duel!\n• ${challenge.challengerName}: ${challenge.challengerSeconds}s (${challenge.challengerScore} pts)\n• ${challenge.opponentName}: ${opponentSeconds}s ($opponentScore pts)\n+1 Trophy awarded! 🌟',
        'message_type': 'citadel_fight_result',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}

    return updated;
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
