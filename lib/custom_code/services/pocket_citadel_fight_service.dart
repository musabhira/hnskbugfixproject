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
  final String status; // 'pending', 'accepted', 'completed', 'declined'
  final String? winnerId;
  final int challengerScore;
  final int opponentScore;
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
    this.opponentScore = 0,
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
        'opponent_score': opponentScore,
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
      opponentScore: (json['opponent_score'] as num?)?.toInt() ?? 0,
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

  /// 📜 Get pending fight challenges for a user
  static Future<List<CitadelFightChallenge>> getPendingChallenges(String userId) async {
    final list = await getAllChallenges(userId);
    return list.where((f) => f.opponentId == userId && f.status == 'pending').toList();
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
        opponentScore: opponentScore,
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
