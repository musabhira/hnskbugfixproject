import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_score_level_engine.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';

/// 🏆 Model for a Ranked User in World or Mates Leaderboards
class PocketRankedUser {
  final String userId;
  final String name;
  final String? profileImageUrl;
  final int pocketScore;
  final int level;
  final int globalRank;
  final int? matesRank;
  final VectorAvatarConfig avatarConfig;
  final bool isCurrentUser;
  final bool isRobot;
  final bool isPrestigeSovereign;
  final int prestigeStars;

  const PocketRankedUser({
    required this.userId,
    required this.name,
    this.profileImageUrl,
    required this.pocketScore,
    required this.level,
    required this.globalRank,
    this.matesRank,
    required this.avatarConfig,
    this.isCurrentUser = false,
    this.isRobot = false,
    this.isPrestigeSovereign = false,
    this.prestigeStars = 0,
  });

  /// Helper to check if this user is Rank 1 in the current context
  bool get isChampion => (matesRank ?? globalRank) == 1;
}

/// 🌟 Central Service for Global App-Wide Rankings & Mates Leaderboard
class PocketRankingService {
  static final _supabase = SupaFlow.client;

  // Cached state for instant rendering
  static List<PocketRankedUser> _cachedGlobalTop = [];
  static DateTime? _lastGlobalFetchTime;
  static int? _cachedMyGlobalRank;

  /// Clear ranking caches (e.g. after a citadel attack or score update)
  static void invalidateCache() {
    _cachedGlobalTop.clear();
    _lastGlobalFetchTime = null;
    _cachedMyGlobalRank = null;
  }

  /// 🌐 Fetch Global Leaderboard (App-Wide 1 to N Ranking)
  static Future<List<PocketRankedUser>> fetchGlobalLeaderboard({
    int limit = 100,
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cachedGlobalTop.isNotEmpty &&
        _lastGlobalFetchTime != null &&
        now.difference(_lastGlobalFetchTime!).inMinutes < 2) {
      return _cachedGlobalTop;
    }

    final currentUserId = _supabase.auth.currentUser?.id;
    int myScore = 0;
    if (currentUserId != null && currentUserId.isNotEmpty) {
      myScore = await PocketFortressDefenseService.getUnifiedScore(currentUserId);
    }

    List<PocketRankedUser> rankedList = [];

    try {
      // 1. Fetch top users from Supabase profile table
      final response = await _supabase
          .from('profile')
          .select('user_id, name, profile_image, avatar_url, pocket_score, level, xp, learning_points')
          .order('pocket_score', ascending: false)
          .limit(limit);

      final List<dynamic> data = response as List<dynamic>;

      for (int i = 0; i < data.length; i++) {
        final row = data[i] as Map<String, dynamic>;
        final uid = row['user_id']?.toString() ?? 'user_$i';
        final name = (row['name']?.toString() ?? 'Pocket Mate').trim();
        final rawScore = (row['pocket_score'] as num?)?.toInt() ??
            (row['xp'] as num?)?.toInt() ??
            (row['learning_points'] as num?)?.toInt() ??
            0;
        final rawLevel = (row['level'] as num?)?.toInt() ??
            PocketScoreLevelEngine.getLevelFromScore(rawScore);

        final isMe = uid == currentUserId;
        final effectiveScore = isMe ? math.max(myScore, rawScore) : rawScore;
        final effectiveLevel = isMe
            ? math.max(rawLevel, PocketScoreLevelEngine.getLevelFromScore(effectiveScore))
            : rawLevel;

        final isPrestige = effectiveLevel >= 90 || effectiveScore >= 45000;
        final stars = isPrestige ? math.max(1, (effectiveScore - 45000) ~/ 2000 + 1) : 0;

        rankedList.add(PocketRankedUser(
          userId: uid,
          name: name.isEmpty ? 'Pocket Mate' : name,
          profileImageUrl: row['profile_image'] ?? row['avatar_url'],
          pocketScore: effectiveScore,
          level: effectiveLevel.clamp(1, 99),
          globalRank: i + 1,
          avatarConfig: _resolveAvatarConfig(uid, effectiveLevel),
          isCurrentUser: isMe,
          isRobot: false,
          isPrestigeSovereign: isPrestige,
          prestigeStars: stars,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching global leaderboard: $e');
      }
    }

    // 2. Ensure leaderboards have active high-level AI Mates & Grandmasters
    _injectResidentLegends(rankedList, currentUserId, myScore);

    // 3. Sort by pocketScore descending
    rankedList.sort((a, b) => b.pocketScore.compareTo(a.pocketScore));

    // 4. Re-assign continuous 1-based ranks
    final finalized = <PocketRankedUser>[];
    for (int i = 0; i < rankedList.length; i++) {
      final user = rankedList[i];
      final rank = i + 1;
      if (user.isCurrentUser) {
        _cachedMyGlobalRank = rank;
      }
      finalized.add(PocketRankedUser(
        userId: user.userId,
        name: user.name,
        profileImageUrl: user.profileImageUrl,
        pocketScore: user.pocketScore,
        level: user.level,
        globalRank: rank,
        matesRank: null,
        avatarConfig: user.avatarConfig,
        isCurrentUser: user.isCurrentUser,
        isRobot: user.isRobot,
        isPrestigeSovereign: user.isPrestigeSovereign,
        prestigeStars: user.prestigeStars,
      ));
    }

    // If current user is not in top limit, calculate their exact global rank and append bracket
    if (currentUserId != null &&
        currentUserId.isNotEmpty &&
        !finalized.any((u) => u.isCurrentUser)) {
      final myRank = await fetchUserGlobalRank(currentUserId, myScore);
      final myLevel = PocketScoreLevelEngine.getLevelFromScore(myScore);
      final isPrestige = myLevel >= 90 || myScore >= 45000;
      final stars = isPrestige ? math.max(1, (myScore - 45000) ~/ 2000 + 1) : 0;

      finalized.add(PocketRankedUser(
        userId: currentUserId,
        name: 'You',
        pocketScore: myScore,
        level: myLevel.clamp(1, 99),
        globalRank: myRank,
        avatarConfig: _resolveAvatarConfig(currentUserId, myLevel),
        isCurrentUser: true,
        isRobot: false,
        isPrestigeSovereign: isPrestige,
        prestigeStars: stars,
      ));
    }

    _cachedGlobalTop = finalized;
    _lastGlobalFetchTime = DateTime.now();
    return finalized;
  }

  /// 👥 Fetch Mates Leaderboard (Only Friends Followed by Current User)
  static Future<List<PocketRankedUser>> fetchMatesLeaderboard(String currentUserId) async {
    final myScore = await PocketFortressDefenseService.getUnifiedScore(currentUserId);
    final myLevel = PocketScoreLevelEngine.getLevelFromScore(myScore);
    final myGlobalRank = await fetchUserGlobalRank(currentUserId, myScore);

    final Set<String> mateIds = {currentUserId};
    try {
      // Fetch followed users
      final followsRes = await _supabase
          .from('follows')
          .select('followed_id')
          .eq('follower_id', currentUserId);
      for (final row in followsRes) {
        final fid = row['followed_id']?.toString();
        if (fid != null && fid.isNotEmpty) mateIds.add(fid);
      }
    } catch (_) {}

    // Also include local mate IDs from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final localMates = prefs.getStringList('pocket_mates_$currentUserId') ?? [];
      mateIds.addAll(localMates);
    } catch (_) {}

    final List<PocketRankedUser> matesList = [];

    // Query profiles for all mates
    if (mateIds.length > 1) {
      try {
        final queryIds = mateIds.where((id) => !PocketRobotService.isRobotId(id)).toList();
        if (queryIds.isNotEmpty) {
          final res = await _supabase
              .from('profile')
              .select('user_id, name, profile_image, avatar_url, pocket_score, level, xp')
              .filter('user_id', 'in', queryIds);

          for (final row in res) {
              final uid = row['user_id']?.toString() ?? '';
              if (uid.isEmpty) continue;
              final isMe = uid == currentUserId;
              final rawScore = (row['pocket_score'] as num?)?.toInt() ??
                  (row['xp'] as num?)?.toInt() ??
                  0;
              final effectiveScore = isMe ? math.max(myScore, rawScore) : rawScore;
              final rawLevel = (row['level'] as num?)?.toInt() ??
                  PocketScoreLevelEngine.getLevelFromScore(effectiveScore);
              final effectiveLevel = isMe ? math.max(myLevel, rawLevel) : rawLevel;

              final gRank = isMe ? myGlobalRank : await fetchUserGlobalRank(uid, effectiveScore);
              final isPrestige = effectiveLevel >= 90 || effectiveScore >= 45000;
              final stars = isPrestige ? math.max(1, (effectiveScore - 45000) ~/ 2000 + 1) : 0;

              matesList.add(PocketRankedUser(
                userId: uid,
                name: isMe ? 'You' : (row['name']?.toString() ?? 'Mate'),
                profileImageUrl: row['profile_image'] ?? row['avatar_url'],
                pocketScore: effectiveScore,
                level: effectiveLevel.clamp(1, 99),
                globalRank: gRank,
                avatarConfig: _resolveAvatarConfig(uid, effectiveLevel),
                isCurrentUser: isMe,
                isRobot: false,
                isPrestigeSovereign: isPrestige,
                prestigeStars: stars,
              ));
          }
        }
      } catch (_) {}
    }

    // Ensure Current User is always present
    if (!matesList.any((m) => m.userId == currentUserId)) {
      final isPrestige = myLevel >= 90 || myScore >= 45000;
      final stars = isPrestige ? math.max(1, (myScore - 45000) ~/ 2000 + 1) : 0;
      matesList.add(PocketRankedUser(
        userId: currentUserId,
        name: 'You',
        pocketScore: myScore,
        level: myLevel.clamp(1, 99),
        globalRank: myGlobalRank,
        avatarConfig: _resolveAvatarConfig(currentUserId, myLevel),
        isCurrentUser: true,
        isRobot: false,
        isPrestigeSovereign: isPrestige,
        prestigeStars: stars,
      ));
    }

    // Inject robot mates / President if in friends
    _injectRobotMates(matesList, mateIds, currentUserId);

    // Sort by pocket score descending
    matesList.sort((a, b) => b.pocketScore.compareTo(a.pocketScore));

    // Assign Mates Rank 1..M
    final finalized = <PocketRankedUser>[];
    for (int i = 0; i < matesList.length; i++) {
      final user = matesList[i];
      finalized.add(PocketRankedUser(
        userId: user.userId,
        name: user.name,
        profileImageUrl: user.profileImageUrl,
        pocketScore: user.pocketScore,
        level: user.level,
        globalRank: user.globalRank,
        matesRank: i + 1,
        avatarConfig: user.avatarConfig,
        isCurrentUser: user.isCurrentUser,
        isRobot: user.isRobot,
        isPrestigeSovereign: user.isPrestigeSovereign,
        prestigeStars: user.prestigeStars,
      ));
    }

    return finalized;
  }

  /// 🌐 Calculate exact Global Rank for a specific user
  static Future<int> fetchUserGlobalRank(String userId, [int? userScore]) async {
    if (_cachedMyGlobalRank != null && userId == _supabase.auth.currentUser?.id) {
      return _cachedMyGlobalRank!;
    }

    int score = userScore ?? await PocketFortressDefenseService.getUnifiedScore(userId);

    try {
      final countRes = await _supabase
          .from('profile')
          .count(CountOption.exact)
          .gt('pocket_score', score);

      final rank = countRes + 1;
      if (userId == _supabase.auth.currentUser?.id) {
        _cachedMyGlobalRank = rank;
      }
      return rank;
    } catch (_) {
      // Fallback: estimate rank logarithmically based on score
      if (score >= 50000) return 1;
      if (score >= 35000) return 3;
      if (score >= 20000) return 12;
      if (score >= 10000) return 45;
      if (score >= 5000) return 110;
      if (score >= 1000) return 320;
      return 500;
    }
  }

  /// Injects resident AI characters and Grandmasters into global top
  static void _injectResidentLegends(
    List<PocketRankedUser> list,
    String? currentUserId,
    int myScore,
  ) {
    final legends = [
      {
        'id': 'robot_sophia_mentor',
        'name': 'Grandmaster Sophia',
        'score': 62450,
        'level': 90,
      },
      {
        'id': 'robot_alex_prof',
        'name': 'Professor Alex',
        'score': 48900,
        'level': 88,
      },
      {
        'id': 'robot_nova_explorer',
        'name': 'Nova Starlight',
        'score': 38200,
        'level': 75,
      },
      {
        'id': 'robot_leo_challenger',
        'name': 'Leo Shadowblade',
        'score': 29150,
        'level': 62,
      },
      {
        'id': 'robot_maya_poet',
        'name': 'Maya The Eloquent',
        'score': 19800,
        'level': 48,
      },
    ];

    for (final l in legends) {
      final id = l['id'] as String;
      if (!list.any((u) => u.userId == id)) {
        final score = l['score'] as int;
        final level = l['level'] as int;
        final isPrestige = level >= 90 || score >= 45000;
        final stars = isPrestige ? math.max(1, (score - 45000) ~/ 2000 + 1) : 0;

        list.add(PocketRankedUser(
          userId: id,
          name: l['name'] as String,
          pocketScore: score,
          level: level,
          globalRank: 0, // will be reassigned
          avatarConfig: _resolveAvatarConfig(id, level),
          isCurrentUser: false,
          isRobot: true,
          isPrestigeSovereign: isPrestige,
          prestigeStars: stars,
        ));
      }
    }
  }

  /// Injects connected robots into Mates list
  static void _injectRobotMates(
    List<PocketRankedUser> list,
    Set<String> mateIds,
    String currentUserId,
  ) {
    final connectedRobots = PocketRobotService.getAllRobots().take(4);
    for (final robot in connectedRobots) {
      if (!list.any((u) => u.userId == robot.id)) {
        final score = (robot.level * 450).clamp(500, 42000);
        final level = robot.level.clamp(1, 90);
        final isPrestige = level >= 90 || score >= 45000;
        final stars = isPrestige ? math.max(1, (score - 45000) ~/ 2000 + 1) : 0;
        final estimatedRank = (200 - robot.level * 2).clamp(1, 500);

        list.add(PocketRankedUser(
          userId: robot.id,
          name: robot.name,
          profileImageUrl: robot.avatarUrl,
          pocketScore: score,
          level: level,
          globalRank: estimatedRank,
          avatarConfig: _resolveAvatarConfig(robot.id, level),
          isCurrentUser: false,
          isRobot: true,
          isPrestigeSovereign: isPrestige,
          prestigeStars: stars,
        ));
      }
    }
  }

  static VectorAvatarConfig _resolveAvatarConfig(String userId, int level) {
    if (PocketRobotService.isRobotId(userId)) {
      final robot = PocketRobotService.getRobotById(userId);
      if (robot?.avatarUrl != null && robot!.avatarUrl.isNotEmpty) {
        return VectorAvatarConfig(networkImageUrl: robot.avatarUrl);
      }
    }
    return VectorAvatarConfig.getEvolutionAvatarForStage(level);
  }
}
