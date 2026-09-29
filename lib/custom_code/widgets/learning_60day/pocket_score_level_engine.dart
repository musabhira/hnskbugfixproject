import 'dart:math' as math;

/// 🏛️ PocketScoreLevelEngine
/// Core progression, score thresholds, star ratings, and 9-tier English defense gauntlets (Levels 1 to 90).
class PocketScoreLevelEngine {
  /// Base points required for the first level jump (Level 1 -> 2)
  static const int kBasePointsPerLevel = 200;
  /// Incremental point growth per subsequent level to ensure progressive difficulty (Audio Directive)
  static const int kLevelPointsGrowth = 15;
  static const int kMaxLevel = 91;

  /// Precomputed cumulative thresholds for Levels 1 to 91.
  /// Level 1: 0 PTS
  /// Level 2: 200 PTS (Gap: 200)
  /// Level 3: 415 PTS (Gap: 215)
  /// Level 4: 645 PTS (Gap: 230)
  /// ...
  /// Level 91: 78,075 PTS (PALACE RAID: Supreme Sovereign Attack)
  static final List<int> _levelThresholds = () {
    final list = <int>[0]; // index 0 unused
    list.add(0); // Level 1 threshold = 0
    int current = 0;
    for (int lvl = 1; lvl < kMaxLevel; lvl++) {
      final gap = kBasePointsPerLevel + (lvl - 1) * kLevelPointsGrowth;
      current += gap;
      list.add(current);
    }
    return list;
  }();

  /// Returns minimum Pocket Score required to reach a specific level (1 to 91).
  static int getRequiredScoreForLevel(int level) {
    final clampedLevel = level.clamp(1, kMaxLevel);
    return _levelThresholds[clampedLevel];
  }

  /// Calculates the player's level based strictly on their current Pocket Score.
  static int getLevelFromScore(int score) {
    if (score <= 0) return 1;
    for (int lvl = kMaxLevel; lvl >= 1; lvl--) {
      if (score >= _levelThresholds[lvl]) {
        return lvl;
      }
    }
    return 1;
  }

  /// Returns the score progress inside the current level (e.g. 0.0 to 1.0)
  static double getLevelProgress(int score) {
    final currentLevel = getLevelFromScore(score);
    if (currentLevel >= kMaxLevel) return 1.0;

    final currentLevelBase = _levelThresholds[currentLevel];
    final nextLevelBase = _levelThresholds[currentLevel + 1];
    final gap = nextLevelBase - currentLevelBase;
    if (gap <= 0) return 1.0;

    final scoreInLevel = score - currentLevelBase;
    return (scoreInLevel / gap).clamp(0.0, 1.0);
  }

  /// Returns how many points are needed to unlock the next level
  static int getRemainingScoreForNextLevel(int score) {
    final currentLevel = getLevelFromScore(score);
    if (currentLevel >= kMaxLevel) return 0;
    final nextLevelThreshold = _levelThresholds[currentLevel + 1];
    return math.max(0, nextLevelThreshold - score);
  }

  /// 🏆 Returns minimum PocketTalk Spoken Trophies required to unlock a specific level.
  /// User directive:
  /// - Levels 1 to 4: 0 Trophies (Open to start)
  /// - Level 5: 1 Trophy required (1 completed 4-day spoken pact)
  /// - Level 10: 2 Trophies required
  /// - Level 15: 3 Trophies required ...
  /// - Scale progressively up to 150 Trophies by Level 90
  static int getRequiredTrophiesForLevel(int level) {
    if (level < 5) return 0;
    if (level < 10) return 1;
    if (level < 15) return 2;
    if (level < 20) return 3;
    if (level < 30) return 5;
    if (level < 45) return 10;
    if (level < 60) return 20;
    if (level < 75) return 50;
    if (level < 90) return 100;
    return 150; // Capstone Graduation
  }

  /// Verifies whether the player has satisfied BOTH Pocket Score AND Spoken Trophies to unlock a target level
  static ({bool isUnlocked, int missingScore, int missingTrophies, String requirementMessage}) checkLevelUnlockEligibility({
    required int currentScore,
    required int currentTrophies,
    required int targetLevel,
  }) {
    final reqScore = getRequiredScoreForLevel(targetLevel);
    final reqTrophies = getRequiredTrophiesForLevel(targetLevel);

    final missingScore = math.max(0, reqScore - currentScore);
    final missingTrophies = math.max(0, reqTrophies - currentTrophies);

    final isUnlocked = missingScore == 0 && missingTrophies == 0;

    String msg = '';
    if (!isUnlocked) {
      if (missingScore > 0 && missingTrophies > 0) {
        msg = 'Requires $reqScore PTS and 🏆$reqTrophies Spoken Trophies ($missingScore PTS & $missingTrophies Trophies needed)';
      } else if (missingScore > 0) {
        msg = 'Requires $reqScore PTS ($missingScore PTS needed)';
      } else {
        msg = 'Requires 🏆$reqTrophies Spoken Trophies earned via 4-Day PocketTalk chats ($missingTrophies needed)';
      }
    }

    return (
      isUnlocked: isUnlocked,
      missingScore: missingScore,
      missingTrophies: missingTrophies,
      requirementMessage: msg,
    );
  }

  /// Formats progress label for UI (e.g., "150 / 200 PTS • 🏆1/1 Trophy")
  static String getProgressLabel(int score, {int trophies = 0}) {
    final currentLevel = getLevelFromScore(score);
    if (currentLevel >= kMaxLevel) {
      return '$score PTS • 🏆$trophies Trophies • 👑 MAX LEVEL';
    }
    final nextThreshold = _levelThresholds[currentLevel + 1];
    final remaining = nextThreshold - score;
    final nextReqTrophies = getRequiredTrophiesForLevel(currentLevel + 1);

    if (nextReqTrophies > 0) {
      return '🪙 $score / $nextThreshold PTS • 🏆 $trophies/$nextReqTrophies Trophies to Lvl ${currentLevel + 1}';
    }
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
      'formatId': 'collocation_ram',
      'title': 'Collocation Ram',
      'icon': '🔨',
      'desc': 'Pair natural collocations & phrasal verbs',
      'skill': 'Collocations & Phrasals',
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
