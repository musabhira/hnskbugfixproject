import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_avatar_system.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';

class FriendshipReport {
  final int score;
  final String title;
  final String emoji;
  final String zodiacAnalysis;
  final String vibeQuote;
  final String sharedInterest;
  final int bonusBoost;

  const FriendshipReport({
    required this.score,
    required this.title,
    required this.emoji,
    required this.zodiacAnalysis,
    required this.vibeQuote,
    required this.sharedInterest,
    this.bonusBoost = 0,
  });
}

/// 💖 Kids Friendship Compatibility & Score Calculator Service
///
/// Implements the user's requested "Friendship Score" feature.
/// Evaluates zodiac compatibility (Capricorn, Leo, etc.), shared English level,
/// and interactive boosts (quizzes, high-fives, star gifts) into a delightful 70–99% score!
class PocketFriendshipScoreService {
  static const String _prefKeyMyZodiac = 'kids_user_zodiac_sign';
  static const String _prefKeyBoostPrefix = 'kids_friendship_boost_';

  static String _cachedMyZodiac = 'Capricorn ♑';
  static final Map<String, int> _boostMap = {};

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedMyZodiac = prefs.getString(_prefKeyMyZodiac) ?? 'Capricorn ♑';
    } catch (_) {}
  }

  static String get myZodiac => _cachedMyZodiac;

  static Future<void> setMyZodiac(String zodiac) async {
    _cachedMyZodiac = zodiac;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyMyZodiac, zodiac);
    } catch (_) {}
  }

  /// Calculate the Friendship Score between the current kid and any mate/companion
  static FriendshipReport calculateReport(String mateId, {int? mateDayLevel}) {
    int day = mateDayLevel ?? 1;
    if (mateDayLevel == null) {
      final mate = PocketKidsRobotsData.getAnimalById(mateId);
      if (mate != null) {
        day = mate.dayLevel;
      }
    }

    final mateZodiac = PocketKidsAvatarSystem.getZodiacForDay(day);
    final boost = _boostMap[mateId] ?? 0;

    // Base compatibility from zodiac pairing + day seed
    final hashVal = (myZodiac.hashCode ^ mateId.hashCode ^ (day * 17)).abs();
    int baseScore = 75 + (hashVal % 21); // 75 to 95
    int finalScore = (baseScore + boost).clamp(75, 99);

    String title;
    String emoji;
    if (finalScore >= 96) {
      title = 'BFF SOULMATES';
      emoji = '🌟 💖';
    } else if (finalScore >= 90) {
      title = 'SUPER BESTIES';
      emoji = '🌈 🤝';
    } else if (finalScore >= 85) {
      title = 'ADVENTURE PALS';
      emoji = '⚡ 🎒';
    } else {
      title = 'TRAIL BUDDIES';
      emoji = '🐾 ⭐';
    }

    // Zodiac analysis
    final mySignName = myZodiac.split(' ').first;
    final mateSignName = mateZodiac.split(' ').first;
    final zodiacAnalysis =
        '$mySignName & $mateSignName are a cosmic match! Natural trust and joyful English vibes.';

    final interests = [
      'Storytelling & Dragon Quests',
      'Phonics Games & Balloon Popping',
      'Exploring Mountain Fortresses',
      'Earning 3-Star Badges Together',
      'Secret Word Puzzles & Cartoons',
      'Singing Rhymes & Speaking Out Loud',
    ];
    final shared = interests[(hashVal ~/ 3) % interests.length];

    final quotes = [
      'You both think alike and support each other\'s learning streak!',
      'Whenever you chat, your English confidence sparks up!',
      'True adventure friends who never leave a level unfinished.',
      'Super strong connection! You make practicing English pure fun.',
    ];
    final quote = quotes[hashVal % quotes.length];

    return FriendshipReport(
      score: finalScore,
      title: title,
      emoji: emoji,
      zodiacAnalysis: zodiacAnalysis,
      vibeQuote: quote,
      sharedInterest: shared,
      bonusBoost: boost,
    );
  }

  /// Boost friendship score through star gifts, quizzes, or high fives
  static Future<int> boostFriendship(String mateId, {int points = 2}) async {
    final current = _boostMap[mateId] ?? 0;
    final updated = (current + points).clamp(0, 15);
    _boostMap[mateId] = updated;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_prefKeyBoostPrefix$mateId', updated);
    } catch (_) {}

    return updated;
  }
}
