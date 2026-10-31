import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_score_level_engine.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';

/// 🏆 Model representing a ranked user across Pocket Mates
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
  final bool isVerified;
  final bool isVip;

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
    this.isVerified = false,
    this.isVip = false,
  });

  /// Helper to check if this user is Rank 1 in the current context
  bool get isChampion => (matesRank ?? globalRank) == 1;

  /// Golden Verification Tick strictly for paid VIPs, verified users, and admin (User audio directive)
  /// Top 10 rank or reaching level 10 NEVER grants a golden tick!
  bool get hasGoldenTick {
    final lowerName = name.toLowerCase();
    final lowerId = userId.toLowerCase();
    if (lowerName.contains('musab') ||
        lowerName.contains('thonippadam') ||
        lowerName.contains('mussabira') ||
        lowerId.contains('musab') ||
        lowerName.contains('pocket president') ||
        lowerName == 'president') {
      return true;
    }
    return isVerified || isVip;
  }

  /// Formatted score with decimal precision for transparent tie-breaking (Audio directive)
  String get preciseScoreText {
    final micro = (userId.hashCode.abs() % 10);
    return '$pocketScore.$micro PTS';
  }

  PocketRankedUser copyWith({
    String? userId,
    String? name,
    String? profileImageUrl,
    int? pocketScore,
    int? level,
    int? globalRank,
    int? matesRank,
    VectorAvatarConfig? avatarConfig,
    bool? isCurrentUser,
    bool? isRobot,
    bool? isPrestigeSovereign,
    int? prestigeStars,
    bool? isVerified,
    bool? isVip,
  }) {
    return PocketRankedUser(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      pocketScore: pocketScore ?? this.pocketScore,
      level: level ?? this.level,
      globalRank: globalRank ?? this.globalRank,
      matesRank: matesRank ?? this.matesRank,
      avatarConfig: avatarConfig ?? this.avatarConfig,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isRobot: isRobot ?? this.isRobot,
      isPrestigeSovereign: isPrestigeSovereign ?? this.isPrestigeSovereign,
      prestigeStars: prestigeStars ?? this.prestigeStars,
      isVerified: isVerified ?? this.isVerified,
      isVip: isVip ?? this.isVip,
    );
  }
}

/// 🌟 Central Service for Global App-Wide Rankings & Mates Leaderboard
/// Pure 100% Real Human Competition (Robots excluded per user directive)
class PocketRankingService {
  static final _supabase = SupaFlow.client;

  // Cached state for instant rendering
  static List<PocketRankedUser> _cachedGlobalTop = [];
  static DateTime? _lastGlobalFetchTime;
  static int? _cachedMyGlobalRank;
  static bool? _cachedIsUnder17;
  static bool? _cachedIncludeRobots;

  static const String _kWorldRankingIncludeRobotsKey = 'world_ranking_include_robots';
  static const String _kHiddenRankingUserIdsKey = 'hidden_ranking_user_ids';
  static Set<String> _cachedHiddenIds = {};

  /// 🔒 Get set of user or bot IDs hidden by Admin
  static Future<Set<String>> getHiddenRankingUserIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kHiddenRankingUserIdsKey) ?? [];
      _cachedHiddenIds = list.toSet();
      return _cachedHiddenIds;
    } catch (_) {
      return _cachedHiddenIds;
    }
  }

  /// 🔒 Admin Action: Hide/Remove user or robot from leaderboard
  static Future<void> hideUserFromRanking(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedHiddenIds.add(userId);
      await prefs.setStringList(_kHiddenRankingUserIdsKey, _cachedHiddenIds.toList());
      invalidateCache();
    } catch (e) {
      if (kDebugMode) print('Error hiding user $userId: $e');
    }
  }

  /// 🔒 Admin Action: Unhide a specific user/robot
  static Future<void> unhideUserFromRanking(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedHiddenIds.remove(userId);
      await prefs.setStringList(_kHiddenRankingUserIdsKey, _cachedHiddenIds.toList());
      invalidateCache();
    } catch (e) {
      if (kDebugMode) print('Error unhiding user $userId: $e');
    }
  }

  /// 🔒 Admin Action: Reset and unhide all removed users
  static Future<void> unhideAllFromRanking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedHiddenIds.clear();
      await prefs.remove(_kHiddenRankingUserIdsKey);
      invalidateCache();
    } catch (e) {
      if (kDebugMode) print('Error unhiding all users: $e');
    }
  }

  static Future<bool> isRobotsEnabledInWorldRanking() async {
    try {
      final res = await _supabase
          .from('app_tool_configs')
          .select('android_active')
          .eq('tool_name', _kWorldRankingIncludeRobotsKey)
          .maybeSingle();
      if (res != null && res['android_active'] != null) {
        final val = res['android_active'] == true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_kWorldRankingIncludeRobotsKey, val);
        return val;
      }
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kWorldRankingIncludeRobotsKey) ?? true;
  }

  static Future<void> setRobotsEnabledInWorldRanking(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kWorldRankingIncludeRobotsKey, enabled);
    try {
      await _supabase.from('app_tool_configs').upsert({
        'tool_name': _kWorldRankingIncludeRobotsKey,
        'android_active': enabled,
        'ios_active': enabled,
      }, onConflict: 'tool_name');
    } catch (_) {}
    invalidateCache();
  }

  /// 🤖 Dynamic Bot Daily Play & Score Simulator (User Audio Directive)
  /// - Real dynamic simulation: scores evolve every day so bots keep playing
  /// - Rotates Rank 1: High-tier bots (Levels 85-90) take turns at #1, #2, #3 each day
  /// - Humans can outscore and overtake bots on the global leaderboard
  static int getSimulatedBotScore({
    required String botId,
    required int baseLevel,
    required bool isUnder17,
  }) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final dayEpoch = now.year * 365 + dayOfYear;
    final idHash = botId.hashCode.abs();

    // Base score from level: Level 1 ~450 pts, Level 90 ~40,500 pts
    final baseScore = baseLevel * 450;

    // Daily sinusoidal activity factor (different phase for every bot)
    final phase = (idHash % 100) / 100.0 * 2 * math.pi;
    final dailyFactor = math.sin((dayEpoch * 0.73) + phase); // -1.0 to +1.0
    final dailyPlayPoints = ((dailyFactor + 1.2) * 380).round(); // ~76 to ~836 pts/day

    // 🏆 Rotating Rank 1 & Top Tier Competition:
    // Rotate top bot surge based on dayEpoch so the leader rotates dynamically!
    // A high-level bot (level 80+) has a dynamic surge (+2,800 to +4,600 pts)
    final surgeSeed = (dayEpoch * 7 + (dayEpoch ~/ 2)) % 10;
    final isSurgingToday = (idHash % 10) == surgeSeed;
    final surgeBonus = (baseLevel >= 75 && isSurgingToday)
        ? (2900 + (idHash % 1600))
        : 0;

    // Small hourly micro-fluctuation to reflect active day/night learning hours
    final hourlyActivity = ((now.hour * 11 + (idHash % 19)) % 65);

    final totalScore = baseScore + dailyPlayPoints + surgeBonus + hourlyActivity + (idHash % 85);
    return math.max(150, totalScore);
  }

  /// Clear ranking caches (e.g. after a citadel attack or score update)
  static void invalidateCache() {
    _cachedGlobalTop.clear();
    _lastGlobalFetchTime = null;
    _cachedMyGlobalRank = null;
    _cachedIsUnder17 = null;
    _cachedIncludeRobots = null;
  }

  /// 🔍 Get cached global rank for any user if available
  static int? getCachedGlobalRank(String userId) {
    if (userId == _supabase.auth.currentUser?.id && _cachedMyGlobalRank != null) {
      return _cachedMyGlobalRank;
    }
    if (_cachedGlobalTop.isEmpty) return null;
    final idx = _cachedGlobalTop.indexWhere((u) => u.userId == userId);
    if (idx != -1) return _cachedGlobalTop[idx].globalRank;
    return null;
  }

  /// 🔍 Get cached ranked user by id
  static PocketRankedUser? getCachedUser(String userId) {
    if (_cachedGlobalTop.isEmpty) return null;
    final idx = _cachedGlobalTop.indexWhere((u) => u.userId == userId);
    if (idx != -1) return _cachedGlobalTop[idx];
    return null;
  }

  /// 👤 Fetch Pure Humans Leaderboard (ALL Users in Supabase profile table, #1 to #N)
  /// User Audio Directive: "എല്ലാ ഹ്യൂമൻസും വേണം... നിലവിലുള്ള യൂസർ ടേബിളിലുള്ള എല്ലാവരും Supabase സഹിതം കാണണം"
  static Future<List<PocketRankedUser>> fetchHumansOnlyLeaderboard({
    int limit = 500,
    bool forceRefresh = false,
    bool isUnder17 = false,
  }) async {
    return fetchGlobalLeaderboard(
      limit: limit,
      forceRefresh: forceRefresh,
      isUnder17: isUnder17,
      includeRobots: false,
    );
  }

  /// 🤖 Fetch Pure Robots Leaderboard (The 90 AI Bots / Animal Companions, #1 to #90)
  /// User Audio Directive: "റോബോട്ടുകളുടെ റാങ്കിങ് വേറെ, ഹ്യൂമൻസിന്റെ റാങ്കിങ് വേറെ... അത് രണ്ടും സെപ്പറേറ്റ് ചെയ്യുക"
  static Future<List<PocketRankedUser>> fetchRobotsOnlyLeaderboard({
    bool forceRefresh = false,
    bool isUnder17 = false,
  }) async {
    final hiddenIds = await getHiddenRankingUserIds();
    final List<PocketRankedUser> botList = [];

    if (isUnder17) {
      final kidBots = PocketKidsRobotsData.robotsAndHomies;
      for (final animal in kidBots) {
        if (hiddenIds.contains(animal.id)) continue;
        final dynLvl = animal.dayLevel;
        final rScore = getSimulatedBotScore(
          botId: animal.id,
          baseLevel: dynLvl,
          isUnder17: true,
        );
        final isPrestige = dynLvl >= 90;
        botList.add(PocketRankedUser(
          userId: animal.id,
          name: animal.name,
          profileImageUrl: null,
          pocketScore: rScore,
          level: dynLvl.clamp(1, 99),
          globalRank: 0,
          avatarConfig: _resolveAvatarConfig(animal.id, dynLvl),
          isCurrentUser: false,
          isRobot: true,
          isPrestigeSovereign: isPrestige,
          prestigeStars: animal.stars,
        ));
      }
    } else {
      final allRobots = PocketRobotService.getAll90Robots();
      for (final robot in allRobots) {
        if (hiddenIds.contains(robot.id)) continue;
        final dynLvl = robot.level;
        final rScore = getSimulatedBotScore(
          botId: robot.id,
          baseLevel: dynLvl,
          isUnder17: false,
        );
        final isPrestige = dynLvl >= 90;
        botList.add(PocketRankedUser(
          userId: robot.id,
          name: robot.name,
          profileImageUrl: robot.avatarUrl,
          pocketScore: rScore,
          level: dynLvl.clamp(1, 99),
          globalRank: 0,
          avatarConfig: _resolveAvatarConfig(robot.id, dynLvl),
          isCurrentUser: false,
          isRobot: true,
          isPrestigeSovereign: isPrestige,
          prestigeStars: robot.trophies,
        ));
      }
    }

    // Sort bots descending by simulated score
    botList.sort((a, b) {
      final diff = b.pocketScore.compareTo(a.pocketScore);
      if (diff != 0) return diff;
      return a.name.compareTo(b.name);
    });

    final List<PocketRankedUser> finalizedBots = [];
    for (int i = 0; i < botList.length; i++) {
      final bot = botList[i];
      finalizedBots.add(PocketRankedUser(
        userId: bot.userId,
        name: bot.name,
        profileImageUrl: bot.profileImageUrl,
        pocketScore: bot.pocketScore,
        level: bot.level,
        globalRank: i + 1,
        avatarConfig: bot.avatarConfig,
        isCurrentUser: false,
        isRobot: true,
        isPrestigeSovereign: bot.isPrestigeSovereign,
        prestigeStars: bot.prestigeStars,
      ));
    }

    return finalizedBots;
  }

  /// 🐾 Fetch Animals Leaderboard (The 100 Animal Companions)
  /// User Audio Directive: "ഹ്യൂമൻസ്, റോബോട്ട്, അനിമൽസ്... അപ്പൊ അനിമൽസിന്റെ ഒരു സെറ്റപ്പ് അഡൽറ്റിൽ ഗ്ലോബൽ റാങ്കിന്റെ അവിടെ ഹ്യൂമൻസ്, റോബോട്ട് അതിന്റെ അപ്പുറത്ത് ആഡ് ചെയ്യുക, 'Animals' എന്ന് പറഞ്ഞിട്ട്."
  /// "കിംഗ് അല്ല പ്രസിഡന്റ് അല്ലേ? പ്രസിഡന്റ് ആണ് നമ്മുടെ അഡൽറ്റിലുള്ള പ്രസിഡന്റ് ആണ്, കിംഗ് ഒഴിവാക്കുക."
  static Future<List<PocketRankedUser>> fetchAnimalsOnlyLeaderboard({
    bool forceRefresh = false,
  }) async {
    final hiddenIds = await getHiddenRankingUserIds();
    final List<PocketRankedUser> animalList = [];
    final animals = PocketKidsRobotsData.robotsAndHomies;

    for (final animal in animals) {
      if (hiddenIds.contains(animal.id)) continue;
      final dynLvl = animal.dayLevel;
      final rScore = getSimulatedBotScore(
        botId: animal.id,
        baseLevel: dynLvl,
        isUnder17: false,
      );
      final isPrestige = dynLvl >= 90;

      // User Audio Directive: Animals do not have President! No President in Animals Leaderboard.
      String displayName = animal.name
          .replaceAll('The President', 'Golden Summit Tiger')
          .replaceAll('President', 'Champion')
          .replaceAll('Supreme Lion King', 'Golden Summit Tiger 🐯')
          .replaceAll('Lion King', 'Golden Hawk 🦅');

      animalList.add(PocketRankedUser(
        userId: animal.id,
        name: displayName,
        profileImageUrl: null,
        pocketScore: rScore,
        level: dynLvl.clamp(1, 99),
        globalRank: 0,
        avatarConfig: _resolveAvatarConfig(animal.id, dynLvl),
        isCurrentUser: false,
        isRobot: true,
        isPrestigeSovereign: isPrestige,
        prestigeStars: animal.stars,
      ));
    }

    // Sort animals descending by simulated score
    animalList.sort((a, b) {
      final diff = b.pocketScore.compareTo(a.pocketScore);
      if (diff != 0) return diff;
      return a.name.compareTo(b.name);
    });

    final List<PocketRankedUser> finalizedAnimals = [];
    for (int i = 0; i < animalList.length; i++) {
      final a = animalList[i];
      finalizedAnimals.add(a.copyWith(globalRank: i + 1));
    }

    return finalizedAnimals;
  }

  /// 🌐 Fetch Global Leaderboard (App-Wide 1 to N Ranking)
  static Future<List<PocketRankedUser>> fetchGlobalLeaderboard({
    int limit = 500,
    bool forceRefresh = false,
    bool isUnder17 = false,
    bool? includeRobots,
  }) async {
    final robotsEnabled = includeRobots ?? await isRobotsEnabledInWorldRanking();
    final now = DateTime.now();
    if (!forceRefresh &&
        _cachedGlobalTop.isNotEmpty &&
        _lastGlobalFetchTime != null &&
        _cachedIsUnder17 == isUnder17 &&
        _cachedIncludeRobots == robotsEnabled &&
        now.difference(_lastGlobalFetchTime!).inMinutes < 2) {
      return _cachedGlobalTop;
    }

    final hiddenIds = await getHiddenRankingUserIds();
    final currentUserId = _supabase.auth.currentUser?.id;
    int myScore = 0;
    if (currentUserId != null && currentUserId.isNotEmpty) {
      myScore = await PocketFortressDefenseService.getUnifiedScore(currentUserId);
    }

    List<PocketRankedUser> rankedList = [];

    try {
      // 1. Fetch real human users from Supabase profile table
      // Query ONLY columns guaranteed to exist in the database!
      // NEVER query non-existent columns (like account_type, kid_name, kid_avatar) which cause PostgREST 400!
      List<dynamic> data = [];
      try {
        final response = await _supabase
            .from('profile')
            .select('user_id, name, display_name, profile_image_url, pocket_score, learning_day, daily_streak, xp, verified, is_premium, level, avatar_config')
            .order('pocket_score', ascending: false, nullsFirst: false)
            .limit(limit);
        data = response as List<dynamic>;
      } catch (err1) {
        if (kDebugMode) print('Primary profile query note: $err1, falling back to basic columns');
        final response2 = await _supabase
            .from('profile')
            .select('user_id, name, display_name, profile_image_url, learning_day, daily_streak, xp, pocket_score')
            .order('pocket_score', ascending: false, nullsFirst: false)
            .limit(limit);
        data = response2 as List<dynamic>;
      }

      for (int i = 0; i < data.length; i++) {
        final row = data[i] as Map<String, dynamic>;
        final uid = row['user_id']?.toString() ?? 'user_$i';
        // Strictly filter out robot IDs from humans list
        if (PocketRobotService.isRobotId(uid)) continue;
        // Filter out admin-hidden IDs
        if (hiddenIds.contains(uid)) continue;

        final rawDispName = row['display_name']?.toString().trim();
        final rawUserName = (row['name']?.toString() ?? 'Pocket Mate').trim();
        final name = (rawDispName != null && rawDispName.isNotEmpty)
            ? rawDispName
            : (rawUserName.isEmpty ? 'Pocket Mate' : rawUserName);

        // 🪙 Accurate Pocket Score (User Audio Directive: strictly reflect actual pocket_score, no fake 0-rank 1 bugs)
        final rawScore = (row['pocket_score'] as num?)?.toInt() ?? 0;
        final rawDay = (row['learning_day'] as num?)?.toInt() ?? 1;

        final isMe = uid == currentUserId;
        final effectiveScore = isMe ? math.max(myScore, rawScore) : rawScore;
        final rawLevel = PocketScoreLevelEngine.getLevelFromScore(effectiveScore);
        final effectiveLevel = math.max(rawLevel, rawDay).clamp(1, 99);

        final isPrestige = effectiveLevel >= 90 || effectiveScore >= 45000;
        final stars = isPrestige ? math.max(1, (effectiveScore - 45000) ~/ 2000 + 1) : 0;
        final isVerified = row['verified'] == true;
        final isVip = row['is_premium'] == true || row['is_vip'] == true || row['is_subscribed'] == true;

        rankedList.add(PocketRankedUser(
          userId: uid,
          name: name.isEmpty ? 'Pocket Mate' : name,
          profileImageUrl: row['profile_image_url']?.toString(),
          pocketScore: effectiveScore,
          level: effectiveLevel,
          globalRank: rankedList.length + 1,
          avatarConfig: _resolveAvatarConfig(uid, effectiveLevel),
          isCurrentUser: isMe,
          isRobot: false,
          isPrestigeSovereign: isPrestige,
          prestigeStars: stars,
          isVerified: isVerified,
          isVip: isVip,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching global leaderboard: $e');
      }
    }

    // 2. Mix in Pocket Robots if enabled
    if (robotsEnabled) {
      try {
        if (isUnder17) {
          final kidBots = PocketKidsRobotsData.robotsAndHomies;
          for (final animal in kidBots) {
            if (hiddenIds.contains(animal.id)) continue;
            final dynLvl = animal.dayLevel;
            final rScore = getSimulatedBotScore(
              botId: animal.id,
              baseLevel: dynLvl,
              isUnder17: true,
            );
            final isPrestige = dynLvl >= 90;
            rankedList.add(PocketRankedUser(
              userId: animal.id,
              name: animal.name,
              profileImageUrl: null,
              pocketScore: rScore,
              level: dynLvl.clamp(1, 99),
              globalRank: 0,
              avatarConfig: _resolveAvatarConfig(animal.id, dynLvl),
              isCurrentUser: false,
              isRobot: true,
              isPrestigeSovereign: isPrestige,
              prestigeStars: animal.stars,
            ));
          }
        } else {
          final allRobots = PocketRobotService.getAll90Robots();
          for (final robot in allRobots) {
            if (hiddenIds.contains(robot.id)) continue;
            final dynLvl = robot.level;
            final rScore = getSimulatedBotScore(
              botId: robot.id,
              baseLevel: dynLvl,
              isUnder17: false,
            );
            final isPrestige = dynLvl >= 90;
            rankedList.add(PocketRankedUser(
              userId: robot.id,
              name: robot.name,
              profileImageUrl: robot.avatarUrl,
              pocketScore: rScore,
              level: dynLvl.clamp(1, 99),
              globalRank: 0,
              avatarConfig: _resolveAvatarConfig(robot.id, dynLvl),
              isCurrentUser: false,
              isRobot: true,
              isPrestigeSovereign: isPrestige,
              prestigeStars: robot.trophies,
            ));
          }
        }
      } catch (e) {
        if (kDebugMode) print('Error mixing in robots: $e');
      }
    }

    // 3. Ensure current user is in the list
    if (currentUserId != null &&
        currentUserId.isNotEmpty &&
        !rankedList.any((u) => u.userId == currentUserId)) {
      final myLvl = PocketScoreLevelEngine.getLevelFromScore(myScore);
      final isPrestige = myLvl >= 90 || myScore >= 45000;
      final stars = isPrestige ? math.max(1, (myScore - 45000) ~/ 2000 + 1) : 0;
      rankedList.add(PocketRankedUser(
        userId: currentUserId,
        name: 'You',
        pocketScore: myScore,
        level: myLvl.clamp(1, 99),
        globalRank: 1,
        avatarConfig: _resolveAvatarConfig(currentUserId, myLvl),
        isCurrentUser: true,
        isRobot: false,
        isPrestigeSovereign: isPrestige,
        prestigeStars: stars,
      ));
    }

    // 4. Sort by pocketScore descending with micro-fraction tie-breaker (Audio requirement)
    rankedList.sort((a, b) {
      final diff = b.pocketScore.compareTo(a.pocketScore);
      if (diff != 0) return diff;
      final tieA = a.userId.hashCode.abs() % 10;
      final tieB = b.userId.hashCode.abs() % 10;
      final tieDiff = tieB.compareTo(tieA);
      if (tieDiff != 0) return tieDiff;
      return a.name.compareTo(b.name);
    });

    // 5. Re-assign continuous 1-based ranks
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
        avatarConfig: user.avatarConfig,
        isCurrentUser: user.isCurrentUser,
        isRobot: user.isRobot,
        isPrestigeSovereign: user.isPrestigeSovereign,
        prestigeStars: user.prestigeStars,
      ));
    }

    _cachedGlobalTop = finalized;
    _lastGlobalFetchTime = DateTime.now();
    _cachedIsUnder17 = isUnder17;
    _cachedIncludeRobots = robotsEnabled;
    return finalized;
  }

  /// 👥 Fetch Mates Leaderboard (Only Real Friends Followed by Current User)
  static Future<List<PocketRankedUser>> fetchMatesLeaderboard(
    String currentUserId, {
    bool isUnder17 = false,
  }) async {
    final myScore = await PocketFortressDefenseService.getUnifiedScore(currentUserId);
    final myLevel = PocketScoreLevelEngine.getLevelFromScore(myScore);
    final myGlobalRank = await fetchUserGlobalRank(currentUserId, myScore, isUnder17);

    final Set<String> mateIds = {currentUserId};
    try {
      final followsRes = await _supabase
          .from('follows')
          .select('followed_id')
          .eq('follower_id', currentUserId);
      for (final row in followsRes) {
        final fid = row['followed_id']?.toString();
        if (fid != null && fid.isNotEmpty && !PocketRobotService.isRobotId(fid)) {
          mateIds.add(fid);
        }
      }
    } catch (_) {}

    try {
      final followersRes = await _supabase
          .from('follows')
          .select('follower_id')
          .eq('followed_id', currentUserId);
      for (final row in followersRes) {
        final fid = row['follower_id']?.toString();
        if (fid != null && fid.isNotEmpty && !PocketRobotService.isRobotId(fid)) {
          mateIds.add(fid);
        }
      }
    } catch (_) {}

    try {
      final flRes1 = await _supabase
          .from('friendlist')
          .select('profile_id')
          .eq('user_id', currentUserId);
      for (final row in flRes1) {
        final fid = row['profile_id']?.toString();
        if (fid != null && fid.isNotEmpty && !PocketRobotService.isRobotId(fid)) {
          mateIds.add(fid);
        }
      }
    } catch (_) {}

    try {
      final flRes2 = await _supabase
          .from('friendlist')
          .select('user_id')
          .eq('profile_id', currentUserId);
      for (final row in flRes2) {
        final fid = row['user_id']?.toString();
        if (fid != null && fid.isNotEmpty && !PocketRobotService.isRobotId(fid)) {
          mateIds.add(fid);
        }
      }
    } catch (_) {}

    try {
      final convRes1 = await _supabase
          .from('conversations')
          .select('user2_id')
          .eq('user1_id', currentUserId);
      for (final row in convRes1) {
        final fid = row['user2_id']?.toString();
        if (fid != null && fid.isNotEmpty && !PocketRobotService.isRobotId(fid)) {
          mateIds.add(fid);
        }
      }
    } catch (_) {}

    try {
      final convRes2 = await _supabase
          .from('conversations')
          .select('user1_id')
          .eq('user2_id', currentUserId);
      for (final row in convRes2) {
        final fid = row['user1_id']?.toString();
        if (fid != null && fid.isNotEmpty && !PocketRobotService.isRobotId(fid)) {
          mateIds.add(fid);
        }
      }
    } catch (_) {}

    try {
      final pactsRes1 = await _supabase
          .from('pocket_talk_pacts')
          .select('user2_id')
          .eq('user1_id', currentUserId);
      for (final row in pactsRes1) {
        final fid = row['user2_id']?.toString();
        if (fid != null && fid.isNotEmpty && !PocketRobotService.isRobotId(fid)) {
          mateIds.add(fid);
        }
      }
    } catch (_) {}

    try {
      final pactsRes2 = await _supabase
          .from('pocket_talk_pacts')
          .select('user1_id')
          .eq('user2_id', currentUserId);
      for (final row in pactsRes2) {
        final fid = row['user1_id']?.toString();
        if (fid != null && fid.isNotEmpty && !PocketRobotService.isRobotId(fid)) {
          mateIds.add(fid);
        }
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final localMates = prefs.getStringList('pocket_mates_$currentUserId') ?? [];
      for (final id in localMates) {
        if (!PocketRobotService.isRobotId(id)) {
          mateIds.add(id);
        }
      }
    } catch (_) {}

    // Fallback: If no mates recorded yet, fetch registered community profiles so leaderboard is never empty
    if (mateIds.length <= 1) {
      try {
        final fallbackRes = await _supabase
            .from('profile')
            .select('user_id')
            .order('pocket_score', ascending: false)
            .limit(30);
        for (final row in fallbackRes) {
          final uid = row['user_id']?.toString();
          if (uid != null && uid.isNotEmpty && !PocketRobotService.isRobotId(uid)) {
            mateIds.add(uid);
          }
        }
      } catch (_) {}
    }

    final List<PocketRankedUser> matesList = [];

    // Query profiles for all real human mates (chunked to ensure no query limits drop mates)
    if (mateIds.length > 1) {
      try {
        final queryIds = mateIds.where((id) => !PocketRobotService.isRobotId(id)).toList();
        if (queryIds.isNotEmpty) {
          final List<Map<String, dynamic>> allProfiles = [];
          for (var i = 0; i < queryIds.length; i += 40) {
            final chunk = queryIds.sublist(i, math.min(i + 40, queryIds.length));
            final res = await _supabase
                .from('profile')
                .select('user_id, name, profile_image_url, pocket_score, account_type, kid_name, verified, is_premium, is_vip, is_subscribed')
                .inFilter('user_id', chunk);
            allProfiles.addAll(List<Map<String, dynamic>>.from(res));
          }

          for (final row in allProfiles) {
            final uid = row['user_id']?.toString() ?? '';
            if (uid.isEmpty || PocketRobotService.isRobotId(uid)) continue;

            if (isUnder17) {
              final accType = row['account_type']?.toString().toLowerCase().trim();
              final hasKidName = row['kid_name'] != null && row['kid_name'].toString().trim().isNotEmpty;
              final isKid = accType == 'kid' || accType == 'pure_kid' || accType == 'student' || hasKidName;
              if (!isKid) continue;
            }
            final isMe = uid == currentUserId;
            final rawScore = (row['pocket_score'] as num?)?.toInt() ?? 0;
            final effectiveScore = isMe ? math.max(myScore, rawScore) : rawScore;
            final rawLevel = PocketScoreLevelEngine.getLevelFromScore(effectiveScore);
            final effectiveLevel = isMe ? math.max(myLevel, rawLevel) : rawLevel;

            final gRank = isMe ? myGlobalRank : await fetchUserGlobalRank(uid, effectiveScore, isUnder17);
            final isPrestige = effectiveLevel >= 90 || effectiveScore >= 45000;
            final stars = isPrestige ? math.max(1, (effectiveScore - 45000) ~/ 2000 + 1) : 0;
            final isVerified = row['verified'] == true;
            final isVip = row['is_premium'] == true || row['is_vip'] == true || row['is_subscribed'] == true;

            matesList.add(PocketRankedUser(
              userId: uid,
              name: isMe ? 'You' : (row['name']?.toString() ?? 'Mate'),
              profileImageUrl: row['profile_image_url']?.toString(),
              pocketScore: effectiveScore,
              level: effectiveLevel.clamp(1, 99),
              globalRank: gRank,
              avatarConfig: _resolveAvatarConfig(uid, effectiveLevel),
              isCurrentUser: isMe,
              isRobot: false,
              isPrestigeSovereign: isPrestige,
              prestigeStars: stars,
              isVerified: isVerified,
              isVip: isVip,
            ));
          }
        }
      } catch (_) {}
    }

    // Ensure Current User is always present
    if (!matesList.any((m) => m.userId == currentUserId)) {
      final isPrestige = myLevel >= 90 || myScore >= 45000;
      final stars = isPrestige ? math.max(1, (myScore - 45000) ~/ 2000 + 1) : 0;
      Map<String, dynamic>? myProfile;
      try {
        myProfile = await _supabase.from('profile').select('verified, is_premium, is_vip, is_subscribed').eq('user_id', currentUserId).maybeSingle();
      } catch (_) {}

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
        isVerified: myProfile?['verified'] == true,
        isVip: myProfile?['is_premium'] == true || myProfile?['is_vip'] == true || myProfile?['is_subscribed'] == true,
      ));
    }

    // Sort by pocket score descending; for ties / zero score, sort alphabetically (Audio Directive)
    matesList.sort((a, b) {
      if (a.pocketScore != b.pocketScore) {
        return b.pocketScore.compareTo(a.pocketScore);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    // Assign Mates Rank 1..M while strictly preserving globalRank!
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
        isRobot: false,
        isPrestigeSovereign: user.isPrestigeSovereign,
        prestigeStars: user.prestigeStars,
        isVerified: user.isVerified,
        isVip: user.isVip,
      ));
    }

    return finalized;
  }

  /// 🌐 Calculate exact Global Rank for a specific real human user
  /// Takes into account ALL humans from database + ALL robots, exactly matching fetchGlobalLeaderboard!
  static Future<int> fetchUserGlobalRank(
    String userId, [
    int? userScore,
    bool isUnder17 = false,
  ]) async {
    // 1. If global leaderboard is already cached, search for the user directly
    if (_cachedGlobalTop.isNotEmpty && _cachedIsUnder17 == isUnder17) {
      final idx = _cachedGlobalTop.indexWhere((u) => u.userId == userId);
      if (idx != -1) {
        final r = _cachedGlobalTop[idx].globalRank;
        if (userId == _supabase.auth.currentUser?.id) {
          _cachedMyGlobalRank = r;
        }
        return r;
      }
    }

    // 2. If cache is empty, load it to synchronize all users accurately
    if (_cachedGlobalTop.isEmpty) {
      try {
        final leaderboard = await fetchGlobalLeaderboard(isUnder17: isUnder17);
        final idx = leaderboard.indexWhere((u) => u.userId == userId);
        if (idx != -1) {
          final r = leaderboard[idx].globalRank;
          if (userId == _supabase.auth.currentUser?.id) {
            _cachedMyGlobalRank = r;
          }
          return r;
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Leaderboard fetch note for rank: $e');
      }
    }

    // 3. Fallback: unified calculation = (humans above) + (robots above) + 1
    int score = userScore ?? await PocketFortressDefenseService.getUnifiedScore(userId);

    final robotsEnabled = await isRobotsEnabledInWorldRanking();
    int robotCountAbove = 0;
    if (robotsEnabled) {
      if (isUnder17) {
        final kidBots = PocketKidsRobotsData.robotsAndHomies;
        for (final animal in kidBots) {
          final dynLvl = animal.dayLevel;
          final rScore = getSimulatedBotScore(
            botId: animal.id,
            baseLevel: dynLvl,
            isUnder17: true,
          );
          if (rScore > score) {
            robotCountAbove++;
          }
        }
      } else {
        final allRobots = PocketRobotService.getAll90Robots();
        for (final robot in allRobots) {
          final dynLvl = robot.level;
          final rScore = getSimulatedBotScore(
            botId: robot.id,
            baseLevel: dynLvl,
            isUnder17: false,
          );
          if (rScore > score) {
            robotCountAbove++;
          }
        }
      }
    }

    try {
      final countRes = await _supabase
          .from('profile')
          .count(CountOption.exact)
          .gt('pocket_score', score);

      final rank = countRes + robotCountAbove + 1;
      if (userId == _supabase.auth.currentUser?.id) {
        _cachedMyGlobalRank = rank;
      }
      return rank;
    } catch (_) {
      return robotCountAbove + 1;
    }
  }

  static VectorAvatarConfig _resolveAvatarConfig(String userId, int level) {
    return VectorAvatarConfig.getEvolutionAvatarForStage(level);
  }
}
