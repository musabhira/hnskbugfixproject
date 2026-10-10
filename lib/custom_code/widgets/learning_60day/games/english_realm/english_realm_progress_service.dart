import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 💾 Persistent Progress & Rewards Service for the English Realm 2D Open World
class EnglishRealmProgressService {
  static const String _kPrefix = 'er_prog_';
  static const String _kTotalXp = 'er_total_xp';
  static const String _kTotalCoins = 'er_total_coins';
  static const String _kLastDay = 'er_last_visited_day';

  static final ValueNotifier<int> totalXpNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> totalCoinsNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> completedGamesNotifier = ValueNotifier<int>(0);

  /// Initializes cached notifiers
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    totalXpNotifier.value = prefs.getInt(_kTotalXp) ?? 0;
    totalCoinsNotifier.value = prefs.getInt(_kTotalCoins) ?? 0;
    completedGamesNotifier.value = await getCompletedGamesCount();
  }

  /// Checks if a specific game (1 or 2) on a given day is completed
  static Future<bool> isGameCompleted(int day, int gameIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_kPrefix}done_${day}_$gameIndex') ?? false;
  }

  /// Checks if BOTH games for a given day are completed
  static Future<bool> isDayCompleted(int day) async {
    final prefs = await SharedPreferences.getInstance();
    final g1 = prefs.getBool('${_kPrefix}done_${day}_1') ?? false;
    final g2 = prefs.getBool('${_kPrefix}done_${day}_2') ?? false;
    return g1 && g2;
  }

  /// Gets the star rating (0 to 3) earned for a game
  static Future<int> getGameStars(int day, int gameIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_kPrefix}stars_${day}_$gameIndex') ?? 0;
  }

  /// Gets the best score for a game
  static Future<int> getGameScore(int day, int gameIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_kPrefix}score_${day}_$gameIndex') ?? 0;
  }

  /// Saves the completion of a game, updates stars, XP, and coins
  static Future<void> saveGameResult({
    required int day,
    required int gameIndex,
    required int score,
    required int stars,
    required int xpEarned,
    required int coinsEarned,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final wasAlreadyCompleted = prefs.getBool('${_kPrefix}done_${day}_$gameIndex') ?? false;

    await prefs.setBool('${_kPrefix}done_${day}_$gameIndex', true);

    final prevScore = prefs.getInt('${_kPrefix}score_${day}_$gameIndex') ?? 0;
    if (score > prevScore) {
      await prefs.setInt('${_kPrefix}score_${day}_$gameIndex', score);
    }

    final prevStars = prefs.getInt('${_kPrefix}stars_${day}_$gameIndex') ?? 0;
    if (stars > prevStars) {
      await prefs.setInt('${_kPrefix}stars_${day}_$gameIndex', stars);
    }

    // Award XP and coins (award full on first win, bonus on replay)
    final awardXp = wasAlreadyCompleted ? (xpEarned ~/ 2) : xpEarned;
    final awardCoins = wasAlreadyCompleted ? (coinsEarned ~/ 2) : coinsEarned;

    final curXp = prefs.getInt(_kTotalXp) ?? 0;
    final curCoins = prefs.getInt(_kTotalCoins) ?? 0;

    await prefs.setInt(_kTotalXp, curXp + awardXp);
    await prefs.setInt(_kTotalCoins, curCoins + awardCoins);

    totalXpNotifier.value = curXp + awardXp;
    totalCoinsNotifier.value = curCoins + awardCoins;
    completedGamesNotifier.value = await getCompletedGamesCount();
  }

  /// Returns total count of completed games (out of 180)
  static Future<int> getCompletedGamesCount() async {
    final prefs = await SharedPreferences.getInstance();
    int count = 0;
    for (int day = 1; day <= 90; day++) {
      if (prefs.getBool('${_kPrefix}done_${day}_1') == true) count++;
      if (prefs.getBool('${_kPrefix}done_${day}_2') == true) count++;
    }
    return count;
  }

  /// Returns total count of completed days (where BOTH games are cleared)
  static Future<int> getCompletedDaysCount() async {
    final prefs = await SharedPreferences.getInstance();
    int count = 0;
    for (int day = 1; day <= 90; day++) {
      final g1 = prefs.getBool('${_kPrefix}done_${day}_1') ?? false;
      final g2 = prefs.getBool('${_kPrefix}done_${day}_2') ?? false;
      if (g1 && g2) count++;
    }
    return count;
  }

  /// Last visited day in the open world
  static Future<int> getLastVisitedDay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kLastDay) ?? 1;
  }

  /// Updates last visited day
  static Future<void> setLastVisitedDay(int day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastDay, day);
  }
}
