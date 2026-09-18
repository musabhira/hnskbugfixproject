import 'dart:math' as math;

/// 🏛️ PocketScoreLevelEngine
/// Core progression, score thresholds, star ratings, and 9-tier English defense gauntlets (Levels 1 to 90).
class PocketScoreLevelEngine {
  /// Base points required per level jump (Audio Directive: 200 PTS per level)
  static const int kPointsPerLevel = 200;
  static const int kMaxLevel = 90;

  /// Returns minimum Pocket Score required to reach a specific level (1 to 90).
  /// Level 1: 0 PTS
  /// Level 2: 200 PTS
  /// Level 3: 400 PTS
  /// Level 10: 1,800 PTS
  /// Level 90: 17,800 PTS
  static int getRequiredScoreForLevel(int level) {
    final clampedLevel = level.clamp(1, kMaxLevel);
    return (clampedLevel - 1) * kPointsPerLevel;
  }

  /// Calculates the player's level based strictly on their current Pocket Score.
  /// Score < 200 => Level 1
  /// Score 200..399 => Level 2
  /// Score 400..599 => Level 3
  static int getLevelFromScore(int score) {
    if (score <= 0) return 1;
    final calculated = (score ~/ kPointsPerLevel) + 1;
    return calculated.clamp(1, kMaxLevel);
  }

  /// Returns the score progress inside the current level (e.g. 0.0 to 1.0)
  static double getLevelProgress(int score) {
    final currentLevel = getLevelFromScore(score);
    if (currentLevel >= kMaxLevel) return 1.0;

    final currentLevelBase = getRequiredScoreForLevel(currentLevel);
    final scoreInLevel = score - currentLevelBase;
    return (scoreInLevel / kPointsPerLevel).clamp(0.0, 1.0);
  }

  /// Returns how many points are needed to unlock the next level
  static int getRemainingScoreForNextLevel(int score) {
    final currentLevel = getLevelFromScore(score);
    if (currentLevel >= kMaxLevel) return 0;
    final nextLevelThreshold = getRequiredScoreForLevel(currentLevel + 1);
    return math.max(0, nextLevelThreshold - score);
  }

  /// Formats progress label for UI (e.g., "150 / 200 PTS (50 to Lvl 2)")
  static String getProgressLabel(int score) {
    final currentLevel = getLevelFromScore(score);
    if (currentLevel >= kMaxLevel) {
      return '$score PTS • 👑 MAX LEVEL';
    }
    final nextThreshold = getRequiredScoreForLevel(currentLevel + 1);
    final remaining = nextThreshold - score;
    return '🪙 $score / $nextThreshold PTS ($remaining PTS to Lvl ${currentLevel + 1})';
  }

  /// Calculate star rewards for level completion (User Audio Directive: 1, 2, or 3 stars)
  /// - 3 Stars (Flawless): 250 - 300 PTS (Includes extra bonus)
  /// - 2 Stars (Good): 150 PTS
  /// - 1 Star (Passed): 100 PTS
  static int calculateStarScoreBonus({
    required int stars,
    int baseScore = 150,
  }) {
    switch (stars) {
      case 3:
        return 280; // Flawless bonus points
      case 2:
        return 160;
      case 1:
      default:
        return 100;
    }
  }

  /// 🛡️ Determine number of defense gates for a given level (1 Gate per 10 Levels, up to 9 Gates)
  /// Level 1-10: 1 Gate
  /// Level 11-20: 2 Gates
  /// Level 21-30: 3 Gates
  /// ...
  /// Level 81-90: 9 Gates
  static int getGatesCountForLevel(int level) {
    final l = level.clamp(1, kMaxLevel);
    return ((l - 1) ~/ 10) + 1;
  }

  /// 🎮 9 Distinct English Defense Game Formats across 90 Levels
  static const List<Map<String, dynamic>> kGateFormats = [
    {
      'gate': 1,
      'levels': 'Levels 1–10',
      'formatId': 'mcq',
      'title': 'Vocab Gate (MCQ)',
      'icon': '🎯',
      'desc': 'Core vocabulary & definitions puzzle',
      'skill': 'Essential Vocabulary',
    },
    {
      'gate': 2,
      'levels': 'Levels 11–20',
      'formatId': 'word_scramble',
      'title': 'Word Scramble',
      'icon': '🔠',
      'desc': 'Unscramble letters from meaning clues',
      'skill': 'Spelling & Phonics',
    },
    {
      'gate': 3,
      'levels': 'Levels 21–30',
      'formatId': 'sentence_jigsaw',
      'title': 'Sentence Jigsaw',
      'icon': '🧩',
      'desc': 'Reassemble syntax tiles in order',
      'skill': 'Sentence Structure',
    },
    {
      'gate': 4,
      'levels': 'Levels 31–40',
      'formatId': 'spot_error',
      'title': 'Grammar Sentry',
      'icon': '💣',
      'desc': 'Defuse the grammatical error',
      'skill': 'Error Detection',
    },
    {
      'gate': 5,
      'levels': 'Levels 41–50',
      'formatId': 'listening_whisper',
      'title': 'Audio Whisper',
      'icon': '👂',
      'desc': 'Listen to spoken English & fill blanks',
      'skill': 'Listening Comprehension',
    },
    {
      'gate': 6,
      'levels': 'Levels 51–60',
      'formatId': 'idiom_maze',
      'title': 'Idiom & Slang Labyrinth',
      'icon': '🎭',
      'desc': 'Decipher conversational idioms & metaphors',
      'skill': 'Colloquial English',
    },
    {
      'gate': 7,
      'levels': 'Levels 61–70',
      'formatId': 'tense_fortress',
      'title': 'Tense & Conditional Fortress',
      'icon': '⏳',
      'desc': 'Master past/perfect/conditional tenses',
      'skill': 'Advanced Grammar',
    },
    {
      'gate': 8,
      'levels': 'Levels 71–80',
      'formatId': 'speed_sentry',
      'title': 'Speed Sentry Trial',
      'icon': '⚡',
      'desc': 'Rapid-fire English fluency drills',
      'skill': 'Fluency & Reflexes',
    },
    {
      'gate': 9,
      'levels': 'Levels 81–90',
      'formatId': 'grandmaster_trial',
      'title': "President's Grandmaster Trial",
      'icon': '👑',
      'desc': 'C1/C2 advanced syntax, debate & rhetoric',
      'skill': 'Master Oratory',
    },
  ];

  /// Get metadata for a specific gate (1 to 9)
  static Map<String, dynamic> getGateInfo(int gateIndex) {
    final idx = (gateIndex - 1).clamp(0, kGateFormats.length - 1);
    return kGateFormats[idx];
  }
}
