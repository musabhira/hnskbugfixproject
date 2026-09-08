import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import '../avatar/avatar_game_perk.dart';
import 'pocket_world_street_page.dart';

/// 🎩 President of Pocket World's Official Decree & Anti-Cheat Verdict
class PresidentVerdict {
  final bool isApproved;
  final bool isWarning;
  final bool isBanThreat;
  final String title;
  final String feedback;
  final String sealIcon;

  const PresidentVerdict({
    required this.isApproved,
    required this.isWarning,
    required this.isBanThreat,
    required this.title,
    required this.feedback,
    required this.sealIcon,
  });

  factory PresidentVerdict.approved() => const PresidentVerdict(
        isApproved: true,
        isWarning: false,
        isBanThreat: false,
        title: 'PRESIDENTIAL SEAL OF AUTHENTICITY',
        feedback: 'Verified authentic English educational question. Approved for World Street defense.',
        sealIcon: '🏅',
      );

  factory PresidentVerdict.warning(String reason) => PresidentVerdict(
        isApproved: false,
        isWarning: true,
        isBanThreat: false,
        title: 'PRESIDENTIAL ADVISORY WARNING',
        feedback: reason,
        sealIcon: '⚠️',
      );

  factory PresidentVerdict.threat(String reason) => PresidentVerdict(
        isApproved: false,
        isWarning: false,
        isBanThreat: true,
        title: 'PRESIDENTIAL CITATION & BAN RISK',
        feedback: reason,
        sealIcon: '🚨',
      );
}

/// 🎮 Defense Game Formats available for House Shields
class DefenseGameFormat {
  static const String mcq = 'mcq';
  static const String wordScramble = 'word_scramble';
  static const String sentenceJigsaw = 'sentence_jigsaw';
  static const String spotError = 'spot_error';
  static const String listeningWhisper = 'listening_whisper';

  static const List<Map<String, String>> allFormats = [
    {
      'id': mcq,
      'title': 'Quiz (MCQ)',
      'icon': '🎯',
      'desc': '4-choice English puzzle',
    },
    {
      'id': wordScramble,
      'title': 'Word Scramble',
      'icon': '🔠',
      'desc': 'Unscramble letters from clue',
    },
    {
      'id': sentenceJigsaw,
      'title': 'Sentence Jigsaw',
      'icon': '🧩',
      'desc': 'Reassemble syntax tiles',
    },
    {
      'id': spotError,
      'title': 'Spot Error',
      'icon': '💣',
      'desc': 'Defuse grammatical error',
    },
    {
      'id': listeningWhisper,
      'title': 'Audio Whisper',
      'icon': '👂',
      'desc': 'Listen to speech & fill blank',
    },
  ];

  static String getTitle(String formatId) {
    final item = allFormats.firstWhere((f) => f['id'] == formatId, orElse: () => allFormats.first);
    return item['title']!;
  }

  static String getIcon(String formatId) {
    final item = allFormats.firstWhere((f) => f['id'] == formatId, orElse: () => allFormats.first);
    return item['icon']!;
  }
}

/// 🛡️ Model for a Custom House Shield Question
class HouseShieldQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category; // 'vocab', 'grammar', 'idiom', 'comprehension', 'tense', 'syntax'
  final String trapType; // 'vocab_gate', 'grammar_sentry', 'tense_fortress', 'idiom_maze', 'syntax_wall'
  final String gameFormat; // 'mcq', 'word_scramble', 'sentence_jigsaw', 'spot_error', 'listening_whisper'
  final bool isPresidentApproved;

  const HouseShieldQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.category = 'vocab',
    this.trapType = 'vocab_gate',
    this.gameFormat = 'mcq',
    this.isPresidentApproved = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'category': category,
        'trapType': trapType,
        'gameFormat': gameFormat,
        'isPresidentApproved': isPresidentApproved,
      };

  factory HouseShieldQuestion.fromJson(Map<String, dynamic> json) => HouseShieldQuestion(
        id: json['id'] ?? '',
        question: json['question'] ?? '',
        options: List<String>.from(json['options'] ?? []),
        correctIndex: json['correctIndex'] ?? 0,
        explanation: json['explanation'] ?? '',
        category: json['category'] ?? 'vocab',
        trapType: json['trapType'] ??
            (json['category'] == 'grammar'
                ? 'grammar_sentry'
                : (json['category'] == 'idiom'
                    ? 'idiom_maze'
                    : (json['category'] == 'tense'
                        ? 'tense_fortress'
                        : (json['category'] == 'syntax' ? 'syntax_wall' : 'vocab_gate')))),
        gameFormat: json['gameFormat'] ?? 'mcq',
        isPresidentApproved: json['isPresidentApproved'] ?? true,
      );
}

/// 🛡️ The 5 Configurable English Defense Challenge Templates
class DefenseTrapTemplate {
  final String id;
  final String title;
  final String titleMalayalam;
  final String icon;
  final String description;
  final String category;
  final Color themeColor;

  const DefenseTrapTemplate({
    required this.id,
    required this.title,
    required this.titleMalayalam,
    required this.icon,
    required this.description,
    required this.category,
    required this.themeColor,
  });
}

const List<DefenseTrapTemplate> kDefenseTrapTemplates = [
  DefenseTrapTemplate(
    id: 'vocab_gate',
    title: 'Vocab Gate',
    titleMalayalam: 'Vocabulary Bastion',
    icon: '🎯',
    description: 'Rapid vocabulary, synonyms & antonym definitions challenge.',
    category: 'vocab',
    themeColor: Color(0xFF0284C7),
  ),
  DefenseTrapTemplate(
    id: 'grammar_sentry',
    title: 'Grammar Sentry',
    titleMalayalam: 'Grammar Sentry',
    icon: '💣',
    description: 'Spot tricky grammatical flaws before bombs detonate.',
    category: 'grammar',
    themeColor: Color(0xFFE11D48),
  ),
  DefenseTrapTemplate(
    id: 'tense_fortress',
    title: 'Tense Fortress',
    titleMalayalam: 'Tense Citadel',
    icon: '🏹',
    description: 'Past, present, future and conditional tense precision shots.',
    category: 'tense',
    themeColor: Color(0xFF8B5CF6),
  ),
  DefenseTrapTemplate(
    id: 'idiom_maze',
    title: 'Idiom Maze',
    titleMalayalam: 'Idiom Labyrinth',
    icon: '⚡',
    description: 'Match native colloquial idioms and contextual expressions.',
    category: 'idiom',
    themeColor: Color(0xFFF59E0B),
  ),
  DefenseTrapTemplate(
    id: 'syntax_wall',
    title: 'Sentence Wall',
    titleMalayalam: 'Syntax Bulwark',
    icon: '🧩',
    description: 'Master inverted syntax, word order, and clause links.',
    category: 'syntax',
    themeColor: Color(0xFF10B981),
  ),
  DefenseTrapTemplate(
    id: 'whisper_phantom',
    title: 'Whisper Phantom',
    titleMalayalam: 'Acoustic Keep',
    icon: '👂',
    description: 'Missing spoken words and live audio-text context deduction.',
    category: 'listening',
    themeColor: Color(0xFF6366F1),
  ),
  DefenseTrapTemplate(
    id: 'collocation_ram',
    title: 'Collocation Ram',
    titleMalayalam: 'Phrasal Battering Ram',
    icon: '🔨',
    description: 'Natural English collocations, prepositions & phrasal verbs.',
    category: 'collocation',
    themeColor: Color(0xFFEC4899),
  ),
  DefenseTrapTemplate(
    id: 'riddle_sphinx',
    title: 'Riddle Sphinx',
    titleMalayalam: 'Riddle Sphinx',
    icon: '🔮',
    description: 'Clever deduction riddles dealing massive mind-breach defense.',
    category: 'riddle',
    themeColor: Color(0xFF14B8A6),
  ),
  DefenseTrapTemplate(
    id: 'phonetic_thunder',
    title: 'Phonetic Thunder',
    titleMalayalam: 'Phonetic Portal',
    icon: '🎙️',
    description: 'IPA syllable stress, pronunciation, and homophone guards.',
    category: 'phonetics',
    themeColor: Color(0xFFFFD700),
  ),
];

/// 🛡️ Active Defender Trap Live State during Attacker Raids
class DefenderShieldTrapData {
  final DefenseTrapTemplate template;
  final List<HouseShieldQuestion> questions;
  int currentHp;
  final int maxHp;

  DefenderShieldTrapData({
    required this.template,
    required this.questions,
    this.currentHp = 100,
    this.maxHp = 100,
  });

  bool get isDestroyed => currentHp <= 0;
  double get hpPercent => (currentHp / maxHp).clamp(0.0, 1.0);
}

/// 🚨 Consistency / Focus Loss Result
class ConsistencyCheckResult {
  final bool didDowngrade;
  final int previousDay;
  final int newDay;
  final String title;
  final String message;
  final String messageMalayalam;

  const ConsistencyCheckResult({
    required this.didDowngrade,
    required this.previousDay,
    required this.newDay,
    required this.title,
    required this.message,
    required this.messageMalayalam,
  });

  factory ConsistencyCheckResult.none() => const ConsistencyCheckResult(
        didDowngrade: false,
        previousDay: 0,
        newDay: 0,
        title: '',
        message: '',
        messageMalayalam: '',
      );
}

/// 🏆 Day 90 Master Card & VIP Fleet Credential
class Day90MasterCardData {
  final String cardId;
  final String title;
  final String rank;
  final String limousineName;
  final String escortSquad;
  final String issuedDate;
  final String presidentSignature;
  final String serialNumber;

  const Day90MasterCardData({
    required this.cardId,
    required this.title,
    required this.rank,
    required this.limousineName,
    required this.escortSquad,
    required this.issuedDate,
    required this.presidentSignature,
    required this.serialNumber,
  });
}

/// 📜 Raid Log Entry (Tracking attackers on user's citadel)
class CitadelRaidLogEntry {
  final String id;
  final String attackerId;
  final String attackerName;
  final String attackerAvatar;
  final String attackerWeapon; // ⚔️ Avatar Combat Weapon / Tool (Audio directive: Cannons, Blasters, Shields)
  final DateTime timestamp;
  final bool breached;
  final int coinsLooted;
  final bool ironDomeBlocked;

  const CitadelRaidLogEntry({
    required this.id,
    this.attackerId = '',
    required this.attackerName,
    required this.attackerAvatar,
    this.attackerWeapon = '💥 Heavy Cannon',
    required this.timestamp,
    required this.breached,
    required this.coinsLooted,
    this.ironDomeBlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'attackerId': attackerId,
        'attackerName': attackerName,
        'attackerAvatar': attackerAvatar,
        'attackerWeapon': attackerWeapon,
        'timestamp': timestamp.toIso8601String(),
        'breached': breached,
        'coinsLooted': coinsLooted,
        'ironDomeBlocked': ironDomeBlocked,
      };

  factory CitadelRaidLogEntry.fromJson(Map<String, dynamic> json) => CitadelRaidLogEntry(
        id: json['id'] ?? '',
        attackerId: json['attackerId'] ?? json['attacker_id'] ?? '',
        attackerName: json['attackerName'] ?? json['attacker_name'] ?? 'Rival Raider',
        attackerAvatar: json['attackerAvatar'] ?? json['attacker_avatar'] ?? '⚔️',
        attackerWeapon: json['attackerWeapon'] ?? json['attacker_weapon'] ?? '💥 Heavy Cannon',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
            : (json['created_at'] != null ? DateTime.tryParse(json['created_at']) ?? DateTime.now() : DateTime.now()),
        breached: json['breached'] ?? false,
        coinsLooted: (json['coinsLooted'] ?? json['coins_looted'] as num?)?.toInt() ?? 0,
        ironDomeBlocked: json['ironDomeBlocked'] ?? json['iron_dome_blocked'] ?? false,
      );
}

/// 🏰 House Defense & Fortress Status
class HouseDefenseStatus {
  final int currentHp;
  final int maxHp;
  final bool isDamaged;
  final int armyKnightsCount;
  final bool hasIronDome;
  final int ironDomeTier; // 1: Bronze, 2: Silver, 3: Obsidian Core
  final bool hasArmedEscorts; // Dual armed escort bikes/patrols
  final int totalCoins;
  final int activityPoints; // ⚡ Fortress Defense Credits (FDC) from voice calls, chats, vibes
  final int lifelinesCount; // 💖 Combat Lifelines for high-level raids
  final bool isBanned;
  final String? banReason;
  final bool isUnderPresidentInspection;
  final bool isJailed; // ⛓️ Serving Presidential Jail Sentence for fake defenses
  final int jailDaysRemaining;
  final String? jailReason;
  final String? presidentNotice; // 📜 Official warning decree from President of Pocket World
  final List<String> activeShieldTraps; // 1 up to 9 active defense gates
  final AvatarGamePerk? activePerk;

  const HouseDefenseStatus({
    this.currentHp = 100,
    this.maxHp = 100,
    this.isDamaged = false,
    this.armyKnightsCount = 0,
    this.hasIronDome = false,
    this.ironDomeTier = 0,
    this.hasArmedEscorts = false,
    this.totalCoins = 150,
    this.activityPoints = 80,
    this.lifelinesCount = 0,
    this.isBanned = false,
    this.banReason,
    this.isUnderPresidentInspection = false,
    this.isJailed = false,
    this.jailDaysRemaining = 0,
    this.jailReason,
    this.presidentNotice,
    this.activeShieldTraps = const ['vocab_gate'],
    this.activePerk,
  });

  double get hpPercentage => (currentHp / maxHp.toDouble()).clamp(0.0, 1.0);
}

/// 🛡️ Central Pocket Fortress & Defense Management Service
class PocketFortressDefenseService {
  static const int kRaidBreachLootCoins = 45; // ⚔️ Breaching citadel loots exactly 45 coins (Audio Directive)
  static const String _trapsKey = 'user_custom_defense_traps_v2';
  static const String _activeTrapsKey = 'user_house_active_shield_traps_v2';
  static const String _hpKey = 'user_house_hp';
  static const String _ironDomeKey = 'user_house_iron_dome';
  static const String _armyKey = 'user_house_army_knights';
  static const String _escortsKey = 'user_house_armed_escorts';
  static const String _coinsKey = 'user_pocket_coins';
  static const String _activityPointsKey = 'user_house_activity_points';
  static const String _banKey = 'user_pocket_banned';
  static const String _lastActiveKey = 'user_pocket_last_active_date';
  static const String _day90FleetKey = 'user_pocket_day90_vip_fleet';
  static const String _lifelinesKey = 'user_combat_lifelines_count';
  static const String _raidLogKey = 'user_citadel_raid_logs_v2';
  static const String _targetCooldownKey = 'user_target_attack_cooldown_';
  static const String _presidentNoticeKey = 'user_house_president_notice';
  static const String _jailedKey = 'user_house_is_jailed';
  static const String _jailUntilKey = 'user_house_jail_until';
  static const String _jailReasonKey = 'user_house_jail_reason';
  static const String _jailedHousesListKey = 'pocket_jailed_houses_list';

  /// 🛡️ Unlocked Defense Gates based on Challenge Stage:
  /// Gate 1: Days 1–10 (Up to 10 questions)
  /// Gate 2: Days 11–20 (Up to 20 questions across 2 gates)
  /// ...
  /// Gate 5: Days 41–50 (Up to 50 questions across 5 gates)
  /// Gate 9: Days 81–90 (Up to 90 questions across 9 gates - The Ultimate Citadel!)
  static int getUnlockedGamesCountForStage(int stage) {
    final day = stage.clamp(1, 90);
    return ((day - 1) ~/ 10) + 1;
  }

  /// 📐 Maximum capacity per gate
  static int getQuestionsPerGameForStage(int stage) {
    return 10;
  }

  /// 📐 Total question slots rule: EXACTLY 1 Day/Challenge = 1 Defense Question Slot!
  /// - Day 1: 1 defense question slot
  /// - Day 10: 10 defense question slots
  /// - Day 50: 50 defense question slots
  /// - Day 90: 90 defense question slots
  static int getMaxQuestionsForStage(int stage) {
    return stage.clamp(1, 90);
  }

  /// 💖 Attacker Lifelines for Raiding High-Level Citadels (User Audio Request)
  /// When an attacker sieges a well-fortified neighbor house:
  /// - Level 1–24: 0 Lifelines
  /// - Level 25–49: 1 Lifeline (forgiving 1 mistake or timeout, resetting timer)
  /// - Level 50–79: 2 Lifelines
  /// - Level 80–90: 3 Lifelines
  static int getAttackerLifelinesForNeighborDay(int neighborDay) {
    if (neighborDay >= 80) return 3;
    if (neighborDay >= 50) return 2;
    if (neighborDay >= 25) return 1;
    return 0;
  }

  /// ⚔️ Raid Opponent Target Level Matchmaking Rule (User Audio Directive):
  /// "Oraale attack cheyyumbol same levelil ulla aalukare attack cheyyaruthu.
  ///  Same levelil ulla aalukare attack cheyyalokke oru 20-nu shesham.
  ///  20-nu munpu higher level aayirikkanam (e.g. Lvl 5 faces Lvl 9 or 10)."
  ///
  /// - Before Level 20 (Days 1–19): Users MUST NOT attack same-level peers.
  ///   They must attack higher-level / tougher citadels (+4 to +5 levels higher)
  ///   e.g. Day 1 -> Day 5, Day 5 -> Day 9, Day 12 -> Day 16, Day 14 -> Day 18.
  ///   This forces rapid English learning and vocabulary application under pressure.
  /// - Level 20+ (Days 20–90): Users have demonstrated proven mastery and can attack
  ///   same-level peers or freely select targets.
  /// ⚔️ Check if the user is high enough level to launch direct attacks
  /// Attack unlocks starting at Level 4 (Malayalam Audio Directive):
  /// "ഒരു നാലാമത്തെ ലെവൽ ഒക്കെ ആകുമ്പോൾ നമുക്ക് അറ്റാക്ക് സ്റ്റാർട്ട് ചെയ്യാം...
  ///  ഡയറക്റ്റ് അറ്റാക്ക് ചെയ്യാൻ വരണം... നാലാമത്തെ ആണെന്നുണ്ടെങ്കിൽ അഞ്ചോ ആറോ ആ ഒരു ലെവലിൽ ഉള്ള വീടുകൾ ആക്രമിക്കാം."
  static bool canUserAttack(int userDay) {
    return userDay >= 4;
  }

  /// ⚔️ Raid Opponent Target Level Matchmaking Rule:
  /// - Under Level 4: Attacks locked until Level 4.
  /// - Level 4: Matches with Level 5 or 6 houses (+1 or +2 Lvls higher).
  /// - Level 5–19: Matches with higher-level citadels (+1 to +3 Lvls higher) to push rapid English growth.
  /// - Level 20+ (Days 20–90): Users have proven mastery and can challenge same-level peers or choose freely.
  static int getRaidTargetDay(int userDay) {
    final day = userDay.clamp(1, 90);
    if (day < 4) {
      return 5;
    }
    if (day < 20) {
      if (day == 4) {
        return math.Random().nextBool() ? 5 : 6;
      }
      return math.min(90, day + 4);
    } else {
      return day;
    }
  }

  /// Check whether an attack target is valid for user's level
  static bool isRaidTargetValid(int userDay, int targetDay) {
    if (userDay < 4) return false;
    if (userDay < 20) {
      return targetDay > userDay; // Under Level 20: Target must be higher level (e.g. Lvl 4 attacks Lvl 5 or 6)
    }
    return true; // Level 20+: Can attack anyone
  }

  static String getRivalNameForDay(int day) {
    const names = {
      1: 'Novice Duelist Lvl 1',
      2: 'Habit Sentinel Lvl 2',
      3: 'Cathedral Guardian Lvl 3',
      4: 'Town Council Envoy Lvl 4',
      5: 'Citadel Sea Vanguard Lvl 5',
      6: 'Alveron Syndicate Lvl 6',
      7: 'Lysander Academician Lvl 7',
      8: 'Geneva Ethicist Lvl 8',
      9: 'Oxford Dialectician Lvl 9',
      10: 'Hague High Chancellor Lvl 10',
      11: 'Aegean Philosopher Lvl 11',
      12: 'Union Master Rowan Lvl 12',
      13: 'Cambridge Epistemist Lvl 13',
      14: 'Geneva Treaty Envoy Lvl 14',
      15: 'Knight Commander Lvl 15',
      16: 'Highland Warlord Lvl 16',
      17: 'Bastion Tactician Lvl 17',
      18: 'Citadel Archon Lvl 18',
      19: 'Imperial Aegis Lvl 19',
      20: 'Citadel Sovereign Lvl 20',
    };
    return names[day] ?? 'Citadel Guardian Lvl $day';
  }

  static PocketNeighbor generateRivalForUser(int userDay, {int userStreak = 1}) {
    final targetDay = getRaidTargetDay(userDay);
    final name = getRivalNameForDay(targetDay);
    final rank = targetDay >= 70
        ? 'Imperial Palace Citadel'
        : (targetDay >= 50
            ? 'High-Level Citadel'
            : (targetDay >= 25
                ? 'Fortified Manor'
                : (targetDay >= 10 ? 'Fortress Keep' : 'Rival House')));
    final palette = targetDay >= 70
        ? 'mirror_glass'
        : (targetDay >= 20
            ? 'royal_gold'
            : (targetDay >= 10 ? 'regal_amethyst' : 'midnight_emerald'));

    return PocketNeighbor(
      id: 'rival_citadel_lvl_$targetDay',
      name: name,
      day: targetDay,
      streak: targetDay + 2,
      rank: rank,
      paletteId: palette,
      statusMessage: userDay < 20
          ? '⚔️ Growth Target! Level $userDay warrior raiding Level $targetDay gates (+${targetDay - userDay} Lvls)!'
          : 'Can your English breach my Level $targetDay defense gates?',
      hasActiveShield: true,
    );
  }

  /// 🤖 Generate Pocket Robo defender when no real neighbor is available in level bracket (Audio 16 directive)
  static PocketNeighbor generatePocketRoboDefender(int targetStage) {
    final roboNames = [
      'Pocket Robo 🤖 Alpha',
      'Pocket Robo 🤖 Titan',
      'Pocket Robo 🤖 Apex',
      'Pocket Robo 🤖 Sentinel',
      'Pocket Robo 🤖 Nexus',
      'Pocket Robo 🤖 Zenith',
    ];
    final name = roboNames[(targetStage + 3) % roboNames.length];
    final palette = targetStage >= 70
        ? 'mirror_glass'
        : (targetStage >= 45 ? 'cyber_yellow' : (targetStage >= 20 ? 'royal_gold' : 'emerald'));

    return PocketNeighbor(
      id: 'pocket_robo_$targetStage',
      name: name,
      day: targetStage,
      streak: targetStage,
      rank: 'Robo Home Guardian (Lvl $targetStage)',
      paletteId: palette,
      isMe: false,
      hasActiveShield: true,
      statusMessage: '🤖 Autonomous AI English Defender ready for battle!',
      isPocketRobo: true,
    );
  }

  /// 🚨 Inactivity / Consistency Check (Daily Focus Protection)
  /// If user skips a day, stage downgrades (e.g. Day 6 -> Day 5) with a focus warning!
  static Future<ConsistencyCheckResult> checkDailyConsistency(int currentDay, int streak) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastActiveStr = prefs.getString(_lastActiveKey);

    if (lastActiveStr == null) {
      await prefs.setString(_lastActiveKey, todayStr);
      return ConsistencyCheckResult.none();
    }

    if (lastActiveStr == todayStr) {
      return ConsistencyCheckResult.none();
    }

    try {
      final lastDate = DateTime.parse(lastActiveStr);
      final differenceInDays = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;

      // If missed at least 1 full day (difference >= 2)
      if (differenceInDays >= 2 && currentDay > 1) {
        final downgradedDay = currentDay - 1;
        await prefs.setString(_lastActiveKey, todayStr);
        // Also apply small house wear & tear penalty on missed days
        final currentHp = prefs.getInt(_hpKey) ?? 100;
        await prefs.setInt(_hpKey, math.max(20, currentHp - 15));

        return ConsistencyCheckResult(
          didDowngrade: true,
          previousDay: currentDay,
          newDay: downgradedDay,
          title: '⚠️ CONSISTENCY DROPPED • FOCUS LOST',
          message: 'You missed a day of English practice! Your journey was downgraded from Day $currentDay to Day $downgradedDay. Reclaim your focus and practice today!',
          messageMalayalam: 'Consistency dropped from Day $currentDay to Day $downgradedDay! Practice today to rebuild momentum.',
        );
      }
    } catch (_) {}

    await prefs.setString(_lastActiveKey, todayStr);
    return ConsistencyCheckResult.none();
  }

  /// Record active practice today
  static Future<void> markActiveToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await prefs.setString(_lastActiveKey, todayStr);
  }

  /// 🎩 President of Pocket World AI Question Validator
  static PresidentVerdict validateQuestion(
    String question,
    List<String> options,
    int correctIdx, {
    String gameFormat = 'mcq',
    List<HouseShieldQuestion>? existingQuestions,
    String? currentQuestionId,
  }) {
    final q = question.trim();

    // 1. Anti-duplicate check across all user's armed defense traps
    final normQ = q.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (existingQuestions != null && normQ.isNotEmpty) {
      for (final eq in existingQuestions) {
        if (currentQuestionId != null && eq.id == currentQuestionId) continue;
        final normEq = eq.question.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        if (normQ == normEq) {
          return PresidentVerdict.threat(
            'Duplicate question detected! Every defense trap must be a unique English challenge. Identical questions violate fair-play and are blocked by Presidential Decree.',
          );
        }
      }
    }

    // 2. Minimum length check
    if (q.length < 8) {
      return PresidentVerdict.threat(
        'Question is suspiciously short (${q.length} chars). Trivial spam questions violate Pocket World fair-play and lead to account bans.',
      );
    }

    // 3. Gibberish / keyboard mash detector
    final cleanAlpha = q.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (cleanAlpha.length > 8) {
      final repeatingChars = RegExp(r'(.)\1{3,}');
      if (repeatingChars.hasMatch(cleanAlpha)) {
        return PresidentVerdict.threat(
          'Repetitive keyboard mash detected. The President prohibits fake questions designed to exploit house defense.',
        );
      }
    }

    // 4. Format-specific validation
    if (gameFormat == 'word_scramble') {
      if (options.isEmpty || options[0].trim().length < 3) {
        return PresidentVerdict.warning(
          'Word Scramble requires a target word of at least 3 letters in the Answer Word field.',
        );
      }
      final target = options[0].trim();
      if (RegExp(r'[^a-zA-Z]').hasMatch(target)) {
        return PresidentVerdict.warning('Target scramble word must contain only English letters.');
      }
      return PresidentVerdict.approved();
    }

    if (gameFormat == 'sentence_jigsaw') {
      final words = q.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (words.length < 3) {
        return PresidentVerdict.warning(
          'Sentence Jigsaw requires a sentence with at least 3 words to reassemble.',
        );
      }
      return PresidentVerdict.approved();
    }

    if (gameFormat == 'spot_error') {
      if (options.length < 2) {
        return PresidentVerdict.warning(
          'Spot the Error requires dividing the sentence into at least 2 or 4 segments.',
        );
      }
      if (options.any((o) => o.trim().isEmpty)) {
        return PresidentVerdict.warning('All sentence segments must be filled.');
      }
      if (correctIdx < 0 || correctIdx >= options.length) {
        return PresidentVerdict.warning('Select the segment that contains the grammatical error.');
      }
      return PresidentVerdict.approved();
    }

    // 5. Options validation for standard 4-choice MCQ & Listening Whisper
    if (options.length < 4) {
      return PresidentVerdict.warning('Every defense question must have 4 distinct choices.');
    }

    final trimmedOptions = options.map((e) => e.trim().toLowerCase()).toList();
    final uniqueCount = trimmedOptions.toSet().length;
    if (uniqueCount < 4) {
      return PresidentVerdict.warning('Duplicate answer options detected. Please write 4 unique, educational answers.');
    }

    // 6. Empty option check
    if (trimmedOptions.any((o) => o.isEmpty)) {
      return PresidentVerdict.warning('Options cannot be empty.');
    }

    // 7. Correct index in range
    if (correctIdx < 0 || correctIdx >= options.length) {
      return PresidentVerdict.warning('Select a valid correct answer option.');
    }

    // Passed Presidential inspection!
    return PresidentVerdict.approved();
  }

  /// Fetch House Status
  static Future<HouseDefenseStatus> getHouseStatus([int stage = 1]) async {
    final prefs = await SharedPreferences.getInstance();
    final hp = prefs.getInt(_hpKey) ?? 100;
    final hasDome = prefs.getBool(_ironDomeKey) ?? false;
    final domeTier = prefs.getInt('${_ironDomeKey}_tier') ?? (hasDome ? 1 : 0);
    final knights = prefs.getInt(_armyKey) ?? 2;
    final hasEscorts = prefs.getBool(_escortsKey) ?? false;
    final coins = prefs.getInt(_coinsKey) ?? 150;
    final fdc = prefs.getInt(_activityPointsKey) ?? 80;
    final banned = prefs.getBool(_banKey) ?? false;
    final lifelines = prefs.getInt(_lifelinesKey) ?? 1;
    final underInspection = await isUnderPresidentInspection('me');
    final activeTraps = await getActiveShieldTraps(stage);
    final presidentNotice = prefs.getString(_presidentNoticeKey);
    final isJailed = await isHouseJailed('me');
    final jailReason = prefs.getString(_jailReasonKey);
    final jailUntilStr = prefs.getString(_jailUntilKey);
    int jailDays = 0;
    if (jailUntilStr != null) {
      final until = DateTime.tryParse(jailUntilStr);
      if (until != null) {
        jailDays = math.max(0, until.difference(DateTime.now()).inDays + 1);
      }
    }

    // ⚡ Calculate active companion avatar perk buffs
    final perk = AvatarGamePerk.forDay(stage);
    final effectiveHasDome = hasDome || (perk.perkType == PerkType.ironDome);
    final effectiveDomeTier = math.max(domeTier, (perk.perkType == PerkType.ironDome ? perk.bonusValue : 0));
    final effectiveKnights = knights + (perk.perkType == PerkType.armyKnights ? perk.bonusValue : 0);
    final bonusHp = (perk.perkType == PerkType.fortressShield ? perk.bonusValue : 0);
    final effectiveMaxHp = 100 + bonusHp;

    return HouseDefenseStatus(
      currentHp: math.min(hp + bonusHp, effectiveMaxHp),
      maxHp: effectiveMaxHp,
      isDamaged: hp < effectiveMaxHp,
      armyKnightsCount: effectiveKnights,
      hasIronDome: effectiveHasDome,
      ironDomeTier: effectiveDomeTier,
      hasArmedEscorts: hasEscorts,
      totalCoins: coins,
      activityPoints: fdc,
      lifelinesCount: lifelines,
      isBanned: banned,
      banReason: banned ? 'Condemned by Presidential Decree: Reported fake English defenses.' : null,
      isUnderPresidentInspection: underInspection,
      isJailed: isJailed,
      jailDaysRemaining: jailDays,
      jailReason: jailReason,
      presidentNotice: presidentNotice,
      activeShieldTraps: activeTraps,
      activePerk: perk,
    );
  }

  /// Get active armed shield traps for user (capped by unlocked games count)
  static Future<List<String>> getActiveShieldTraps(int stage) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedCount = getUnlockedGamesCountForStage(stage);
    final stored = prefs.getStringList(_activeTrapsKey);
    if (stored != null && stored.isNotEmpty) {
      return stored.take(unlockedCount).toList();
    }
    // Default unlocked trap IDs
    final defaultIds = kDefenseTrapTemplates.map((t) => t.id).take(unlockedCount).toList();
    return defaultIds;
  }

  /// Save active armed shield traps
  static Future<void> setActiveShieldTraps(List<String> traps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_activeTrapsKey, traps);
  }

  /// 🛡️ Load all active shield traps and their questions for battle raid
  static Future<List<DefenderShieldTrapData>> loadDefenderActiveShieldTraps(int stage, {bool isNeighbor = false}) async {
    final activeTrapIds = await getActiveShieldTraps(stage);
    final allCustomQuestions = await loadShieldQuestions(stage, isNeighbor: isNeighbor);
    final qPerTrap = getQuestionsPerGameForStage(stage);

    final List<DefenderShieldTrapData> result = [];

    for (final trapId in activeTrapIds) {
      final template = kDefenseTrapTemplates.firstWhere(
        (t) => t.id == trapId,
        orElse: () => kDefenseTrapTemplates[0],
      );

      // Match custom questions by trapType or category
      final matched = allCustomQuestions.where((q) {
        return q.trapType == trapId || q.category == template.category;
      }).toList();

      // For neighbor raids, fill with curated challenges if neighbor has not armed all slots
      if (isNeighbor && matched.length < qPerTrap) {
        final curated = getCuratedQuestionsForTrap(trapId);
        for (final cq in curated) {
          if (matched.length >= qPerTrap) break;
          if (!matched.any((m) => m.question == cq.question)) {
            matched.add(cq);
          }
        }
      }

      result.add(
        DefenderShieldTrapData(
          template: template,
          questions: matched.take(qPerTrap).toList(),
          currentHp: 100,
          maxHp: 100,
        ),
      );
    }

    return result;
  }

  /// 9 Diverse English Game Datasets for all 9 Defense Challenge Gates
  static List<HouseShieldQuestion> getCuratedQuestionsForTrap(String trapType) {
    switch (trapType) {
      case 'vocab_gate':
        return const [
          HouseShieldQuestion(
            id: 'cur_vg_1',
            question: 'What is the exact synonym for "Ephemeral"?',
            options: ['Lasting for a very short time', 'Permanent & Eternal', 'Ancient & Heavy', 'Violent'],
            correctIndex: 0,
            explanation: '"Ephemeral" means lasting for a very short time.',
            category: 'vocab',
            trapType: 'vocab_gate',
          ),
          HouseShieldQuestion(
            id: 'cur_vg_2',
            question: 'What is the direct antonym of "Meticulous"?',
            options: ['Careless & Hasty', 'Precise & Thorough', 'Cautious', 'Polite'],
            correctIndex: 0,
            explanation: '"Careless" is the direct opposite of "Meticulous".',
            category: 'vocab',
            trapType: 'vocab_gate',
          ),
          HouseShieldQuestion(
            id: 'cur_vg_3',
            question: 'Which word describes someone who recovers quickly from hardship?',
            options: ['Resilient', 'Fragile', 'Vulnerable', 'Hesitant'],
            correctIndex: 0,
            explanation: '"Resilient" signifies being tough, adaptive, and quick to bounce back.',
            category: 'vocab',
            trapType: 'vocab_gate',
          ),
          HouseShieldQuestion(
            id: 'cur_vg_4',
            question: 'What is the precise meaning of "Pragmatic"?',
            options: ['Dealing with matters sensibly and realistically based on practical conditions', 'Obsessed with wild fantasies', 'Emotionally fragile', 'Careless and hasty'],
            correctIndex: 0,
            explanation: '"Pragmatic" refers to prioritizing practical, workable results over theoretical ideals.',
            category: 'vocab',
            trapType: 'vocab_gate',
          ),
          HouseShieldQuestion(
            id: 'cur_vg_5',
            question: 'Select the exact definition of "Quintessential":',
            options: ['Representing the most perfect or typical example of a quality or class', 'Second-best alternative', 'Ancient and deteriorated', 'Fictional'],
            correctIndex: 0,
            explanation: '"Quintessential" means the absolute embodiment or purest model of something.',
            category: 'vocab',
            trapType: 'vocab_gate',
          ),
          HouseShieldQuestion(
            id: 'cur_vg_6',
            question: 'What does "Sagacious" signify in executive statesmanship?',
            options: ['Having keen mental discernment and good judgment; wise', 'Reckless and impulsive', 'Weak and indecisive', 'Hostile'],
            correctIndex: 0,
            explanation: '"Sagacious" means acutely insightful and deeply wise.',
            category: 'vocab',
            trapType: 'vocab_gate',
          ),
        ];
      case 'grammar_sentry':
        return const [
          HouseShieldQuestion(
            id: 'cur_gs_1',
            question: 'Spot the grammatical error: "Neither of the boys were ready for the duel."',
            options: [
              '"were" should be "was"',
              '"Neither" should be "Either"',
              '"boys" should be "boy"',
              'The sentence is already correct'
            ],
            correctIndex: 0,
            explanation: '"Neither of" takes a singular verb ("was").',
            category: 'grammar',
            trapType: 'grammar_sentry',
          ),
          HouseShieldQuestion(
            id: 'cur_gs_2',
            question: 'Select the correct pronoun: "The general with his knights _____ defending the fortress."',
            options: ['is', 'are', 'were', 'have been'],
            correctIndex: 0,
            explanation: 'Intervening prepositional phrases do not change singular subject ("The general is").',
            category: 'grammar',
            trapType: 'grammar_sentry',
          ),
          HouseShieldQuestion(
            id: 'cur_gs_3',
            question: 'Choose the correct subjunctive mood formulation:',
            options: [
              'The commander demanded that he be present.',
              'The commander demanded that he was present.',
              'The commander demanded that he is present.',
              'The commander demanded that he been present.'
            ],
            correctIndex: 0,
            explanation: 'Subjunctive mood takes the base form "be" after verbs of demand.',
            category: 'grammar',
            trapType: 'grammar_sentry',
          ),
          HouseShieldQuestion(
            id: 'cur_gs_4',
            question: 'Spot the relative pronoun error: "It was the envoy which unified the sovereign delegations."',
            options: [
              '"which" should be "who"',
              '"was" should be "were"',
              '"envoy" should be "envoys"',
              'The sentence is grammatically flawless'
            ],
            correctIndex: 0,
            explanation: '"Who" (not "which") must be used to refer to persons.',
            category: 'grammar',
            trapType: 'grammar_sentry',
          ),
          HouseShieldQuestion(
            id: 'cur_gs_5',
            question: 'Identify the structural parallelism defect: "A true leader excels at clear vision, listening with empathy, and to act decisively."',
            options: [
              '"to act decisively" should be "acting decisively"',
              '"clear vision" should be "to see clearly"',
              '"listening with empathy" should be "listening empathetic"',
              'No error present'
            ],
            correctIndex: 0,
            explanation: 'Elements in a series must share matching grammatical forms (gerund: "acting decisively").',
            category: 'grammar',
            trapType: 'grammar_sentry',
          ),
        ];
      case 'tense_fortress':
        return const [
          HouseShieldQuestion(
            id: 'cur_tf_1',
            question: 'Complete the third conditional: "If the attacker _____ earlier, the gate wouldn\'t have fallen."',
            options: ['had arrived', 'arrived', 'would arrive', 'has arrived'],
            correctIndex: 0,
            explanation: 'Third conditional requires "If + past perfect" with "would have + past participle".',
            category: 'tense',
            trapType: 'tense_fortress',
          ),
          HouseShieldQuestion(
            id: 'cur_tf_2',
            question: 'Identify the future perfect tense:',
            options: [
              'By next week, the clan will have conquered the territory.',
              'By next week, the clan will conquer the territory.',
              'By next week, the clan is conquering the territory.',
              'By next week, the clan would conquer the territory.'
            ],
            correctIndex: 0,
            explanation: '"will have conquered" expresses an action completed before a specific future time.',
            category: 'tense',
            trapType: 'tense_fortress',
          ),
          HouseShieldQuestion(
            id: 'cur_tf_3',
            question: 'Convert to passive voice: "The blacksmith forged the iron gate yesterday."',
            options: [
              'The iron gate was forged by the blacksmith yesterday.',
              'The iron gate had been forged yesterday.',
              'The iron gate is forged by the blacksmith.',
              'The iron gate was forging yesterday.'
            ],
            correctIndex: 0,
            explanation: 'Simple past passive is "was/were + past participle (forged)".',
            category: 'tense',
            trapType: 'tense_fortress',
          ),
          HouseShieldQuestion(
            id: 'cur_tf_4',
            question: 'Select the correct Mixed Conditional (Past Action -> Present Reality):',
            options: [
              'If the founders had fortified the citadel walls, we would live in peace today.',
              'If the founders fortified the citadel walls, we will live in peace today.',
              'If the founders had fortified the walls, we would have lived in peace today.',
              'If the founders would have fortified walls, we live in peace today.'
            ],
            correctIndex: 0,
            explanation: 'Past cause ("had fortified") yielding present state ("would live today") requires a Mixed Conditional.',
            category: 'tense',
            trapType: 'tense_fortress',
          ),
        ];
      case 'idiom_maze':
        return const [
          HouseShieldQuestion(
            id: 'cur_im_1',
            question: 'What does the idiom "Bite the bullet" mean?',
            options: [
              'Face a difficult or painful situation with courage',
              'Eat metal ammunition',
              'Run away from danger',
              'Argue without any proof'
            ],
            correctIndex: 0,
            explanation: '"Bite the bullet" means enduring an inevitable grim situation bravely.',
            category: 'idiom',
            trapType: 'idiom_maze',
          ),
          HouseShieldQuestion(
            id: 'cur_im_2',
            question: 'What does "Barking up the wrong tree" mean?',
            options: [
              'Pursuing a mistaken line of thought or course of action',
              'Training hunting dogs in a forest',
              'Cutting down old trees',
              'Shouting loudly in frustration'
            ],
            correctIndex: 0,
            explanation: '"Barking up the wrong tree" means following a completely false lead.',
            category: 'idiom',
            trapType: 'idiom_maze',
          ),
        ];
      case 'syntax_wall':
        return const [
          HouseShieldQuestion(
            id: 'cur_sw_1',
            question: 'Select the sentence with correct inverted syntax:',
            options: [
              'Rarely have I seen such an impregnable defense.',
              'Rarely I have seen such an impregnable defense.',
              'I rarely have seen such defense impregnable.',
              'Have I seen rarely such defense.'
            ],
            correctIndex: 0,
            explanation: 'Negative adverbs like "Rarely" at the start invert auxiliary verb and subject.',
            category: 'syntax',
            trapType: 'syntax_wall',
          ),
          HouseShieldQuestion(
            id: 'cur_sw_2',
            question: 'Which sentence has the correct correlative conjunction pairing?',
            options: [
              'Not only was the shield shattered, but the treasury was also looted.',
              'Not only was the shield shattered, and the treasury was looted.',
              'Both was the shield shattered, nor the treasury was looted.',
              'Either the shield shattered, but the treasury looted.'
            ],
            correctIndex: 0,
            explanation: '"Not only... but also" is the correct correlative conjunction.',
            category: 'syntax',
            trapType: 'syntax_wall',
          ),
          HouseShieldQuestion(
            id: 'cur_sw_3',
            question: 'Select the sentence with correct Wh-Cleft dramatic focus:',
            options: [
              'What impressed the assembly most was her unwavering integrity.',
              'That impressed the assembly most was her unwavering integrity.',
              'What did impress the assembly was her unwavering integrity that was.',
              'Which impressed the assembly most was her integrity.'
            ],
            correctIndex: 0,
            explanation: 'A wh-cleft sentence ("What [clause] was [focus]") delivers elegant rhetorical emphasis.',
            category: 'syntax',
            trapType: 'syntax_wall',
          ),
          HouseShieldQuestion(
            id: 'cur_sw_4',
            question: 'Identify the correct Rhetorical Fronting structure:',
            options: [
              'Exhausted though the envoys were, reach a historic consensus they did.',
              'Though exhausted were the envoys, reach a historic consensus they did.',
              'Exhausted though were the envoys, reached a historic consensus they did.',
              'Were the envoys exhausted though, reach consensus they did.'
            ],
            correctIndex: 0,
            explanation: 'Rhetorical fronting: [Adjective] + though + [Subject] + [Verb], followed by emphatic inversion.',
            category: 'syntax',
            trapType: 'syntax_wall',
          ),
        ];
      case 'whisper_phantom':
        return const [
          HouseShieldQuestion(
            id: 'cur_wp_1',
            question: 'Fill in the missing spoken connector: "The fortress fell, _______ the defenders fought valiantly."',
            options: ['yet', 'because', 'so', 'despite'],
            correctIndex: 0,
            explanation: '"Yet" expresses contrast between two independent clauses.',
            category: 'listening',
            trapType: 'whisper_phantom',
          ),
          HouseShieldQuestion(
            id: 'cur_wp_2',
            question: 'Which word completes the spoken passage: "He spoke with such _______ that everyone believed him."',
            options: ['conviction', 'confusion', 'hesitation', 'reluctance'],
            correctIndex: 0,
            explanation: '"Conviction" means firmly held belief or persuasive certainty.',
            category: 'listening',
            trapType: 'whisper_phantom',
          ),
        ];
      case 'collocation_ram':
        return const [
          HouseShieldQuestion(
            id: 'cur_cr_1',
            question: 'Complete the collocation: "We must _______ our differences aside and unite."',
            options: ['put', 'drop', 'throw', 'keep'],
            correctIndex: 0,
            explanation: 'The natural English collocation is "put differences aside".',
            category: 'collocation',
            trapType: 'collocation_ram',
          ),
          HouseShieldQuestion(
            id: 'cur_cr_2',
            question: 'Which verb collocates with "a conclusion"?',
            options: ['draw', 'take', 'do', 'bring'],
            correctIndex: 0,
            explanation: 'In standard English we "draw a conclusion" (or reach a conclusion).',
            category: 'collocation',
            trapType: 'collocation_ram',
          ),
        ];
      case 'riddle_sphinx':
        return const [
          HouseShieldQuestion(
            id: 'cur_rs_1',
            question: 'Riddle: "I speak without a mouth and hear without ears. I have no body, but I come alive with wind. What am I?"',
            options: ['An Echo', 'A Cloud', 'A Shadow', 'A River'],
            correctIndex: 0,
            explanation: 'An echo repeats sound without having physical mouth or ears.',
            category: 'riddle',
            trapType: 'riddle_sphinx',
          ),
          HouseShieldQuestion(
            id: 'cur_rs_2',
            question: 'Riddle: "The more of this there is in a dark dungeon, the less you can see. What is it?"',
            options: ['Darkness', 'Light', 'Fog', 'Silence'],
            correctIndex: 0,
            explanation: 'The more darkness there is, the less you can see.',
            category: 'riddle',
            trapType: 'riddle_sphinx',
          ),
        ];
      case 'phonetic_thunder':
        return const [
          HouseShieldQuestion(
            id: 'cur_pt_1',
            question: 'Which word has the primary syllable stress on the second syllable?',
            options: ['pho-TOG-ra-phy', 'PHO-to-graph', 'COM-fort-a-ble', 'DI-ction-ar-y'],
            correctIndex: 0,
            explanation: '"Photography" stresses the second syllable (pho-TOG-ra-phy).',
            category: 'phonetics',
            trapType: 'phonetic_thunder',
          ),
          HouseShieldQuestion(
            id: 'cur_pt_2',
            question: 'Identify the silent letter in "RECEIPT":',
            options: ['P', 'C', 'T', 'I'],
            correctIndex: 0,
            explanation: 'The letter "P" is silent in "receipt" (/rɪˈsiːt/).',
            category: 'phonetics',
            trapType: 'phonetic_thunder',
          ),
        ];
      default:
        return const [];
    }
  }

  /// 🚗 Check / Unlock Day 90 VIP Fleet & Dual Escort Squad
  static Future<bool> isDay90FleetUnlocked(int currentDay) async {
    if (currentDay >= 90) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_day90FleetKey) ?? false;
  }

  /// 🏆 Generate Day 90 Master English Victory NFT Card
  static Day90MasterCardData generateDay90MasterCard() {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    final serial = 'MATE-90-${now.millisecondsSinceEpoch.toString().substring(7)}';

    return Day90MasterCardData(
      cardId: 'DAY90_NFT_SOVEREIGN_PHANTOM',
      title: '👑 SUPREME ENGLISH CONQUEROR',
      rank: 'Level 90 Imperial Citadel Master',
      limousineName: 'Sovereign Phantom VIP Limousine',
      escortSquad: 'Dual Armed Tactical Patrol Escorts (Alpha & Bravo)',
      issuedDate: dateStr,
      presidentSignature: 'President of Pocket World',
      serialNumber: serial,
    );
  }

  /// Enlist Dual Armed Escort Patrol Vehicles/Bikes
  static Future<bool> purchaseArmedEscorts({int coinCost = 120}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt(_coinsKey) ?? 150;
    if (currentCoins < coinCost) return false;

    await prefs.setInt(_coinsKey, currentCoins - coinCost);
    await prefs.setBool(_escortsKey, true);
    await prefs.setBool(_day90FleetKey, true);
    return true;
  }

  /// ⚡ Activity-Powered Defense Credits (FDC)
  /// Earned via Anonymous English Voice Calls, Group Chats, Vibe Posts, and Daily Missions.
  static Future<int> getActivityPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_activityPointsKey) ?? 80;
  }

  /// 🎙️ Record activity and award Fortress Defense Credits (FDC) with optional companion avatar boost
  static Future<int> recordActivityPoints(String activityType, {int? stage, int? customPoints}) async {
    final prefs = await SharedPreferences.getInstance();
    int gain = customPoints ?? 10;
    if (customPoints == null) {
      switch (activityType) {
        case 'voice_talk':
          gain = 20; // Anonymous English Voice Calls
          break;
        case 'group_chat':
          gain = 10; // Group English chats
          break;
        case 'vibe_post':
          gain = 15; // English Vibes posting
          break;
        case 'daily_mission':
          gain = 30; // Completing daily challenges
          break;
        default:
          gain = 10;
      }
    }

    // Apply companion avatar FDC boost perk if stage is provided
    if (stage != null && stage > 0) {
      final perk = AvatarGamePerk.forDay(stage);
      if (perk.perkType == PerkType.fdcBoost) {
        gain += perk.bonusValue;
      }
    }

    final current = prefs.getInt(_activityPointsKey) ?? 80;
    final updated = current + gain;
    await prefs.setInt(_activityPointsKey, updated);
    return updated;
  }

  /// Repair Damaged House (Using Coins or Activity Credits)
  static Future<bool> repairHouse({int healAmount = 50, int coinCost = 20, int fdcCost = 40, bool useFdc = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (useFdc) {
      final currentFdc = prefs.getInt(_activityPointsKey) ?? 80;
      if (currentFdc < fdcCost) return false;
      await prefs.setInt(_activityPointsKey, currentFdc - fdcCost);
    } else {
      final currentCoins = prefs.getInt(_coinsKey) ?? 150;
      if (currentCoins < coinCost) return false;
      await prefs.setInt(_coinsKey, currentCoins - coinCost);
    }

    final currentHp = prefs.getInt(_hpKey) ?? 100;
    final newHp = math.min(100, currentHp + healAmount);
    await prefs.setInt(_hpKey, newHp);
    return true;
  }

  /// Upgrade / Purchase Iron Dome (Using 50 Coins or 60 FDC from activities)
  /// As specified in audio: Daily mission awards 50 bonus coins, which can be spent in the Store on Iron Dome!
  static Future<bool> purchaseIronDome({int tier = 1, int coinCost = 50, int fdcCost = 60, bool useFdc = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (useFdc) {
      final currentFdc = prefs.getInt(_activityPointsKey) ?? 80;
      if (currentFdc < fdcCost) return false;
      await prefs.setInt(_activityPointsKey, currentFdc - fdcCost);
    } else {
      final currentCoins = prefs.getInt(_coinsKey) ?? 150;
      if (currentCoins < coinCost) return false;
      await prefs.setInt(_coinsKey, currentCoins - coinCost);
    }

    await prefs.setBool(_ironDomeKey, true);
    await prefs.setInt('${_ironDomeKey}_tier', tier);
    return true;
  }

  /// Enlist Army Knights (Using Coins or FDC from voice/chat/vibe activities)
  static Future<bool> enlistArmyKnights({int count = 2, int coinCost = 40, int fdcCost = 35, bool useFdc = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (useFdc) {
      final currentFdc = prefs.getInt(_activityPointsKey) ?? 80;
      if (currentFdc < fdcCost) return false;
      await prefs.setInt(_activityPointsKey, currentFdc - fdcCost);
    } else {
      final currentCoins = prefs.getInt(_coinsKey) ?? 150;
      if (currentCoins < coinCost) return false;
      await prefs.setInt(_coinsKey, currentCoins - coinCost);
    }

    final currentKnights = prefs.getInt(_armyKey) ?? 0;
    await prefs.setInt(_armyKey, math.min(10, currentKnights + count));
    return true;
  }

  /// 💖 Combat Lifelines (Audio Directive):
  /// Purchased in Store with coins, used during high-level citadel raids (Level 15+).
  static Future<int> getLifelinesCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lifelinesKey) ?? 1;
  }

  static Future<bool> purchaseLifeline({int coinCost = 30}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt(_coinsKey) ?? 150;
    if (currentCoins < coinCost) return false;
    await prefs.setInt(_coinsKey, currentCoins - coinCost);
    final count = prefs.getInt(_lifelinesKey) ?? 1;
    await prefs.setInt(_lifelinesKey, count + 1);
    return true;
  }

  static Future<bool> consumeLifeline() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_lifelinesKey) ?? 1;
    if (count <= 0) return false;
    await prefs.setInt(_lifelinesKey, count - 1);
    return true;
  }

  /// ⏳ Target Attack Cooldown / Peace Treaty (Audio Directive):
  /// "Oraale attack cheythu kazhinjal pinne aa userine thanne pinne attack cheyyaan pattilla."
  static Future<bool> isTargetInCooldown(String targetId) async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString('$_targetCooldownKey$targetId');
    if (timeStr == null) return false;
    final last = DateTime.tryParse(timeStr);
    if (last == null) return false;
    final diff = DateTime.now().difference(last);
    return diff.inHours < 24; // 24h peace treaty
  }

  static Future<void> recordTargetAttacked(String targetId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_targetCooldownKey$targetId', DateTime.now().toIso8601String());
  }

  /// ⚔️ Daily Attack Limit (Audio 15 Directive: "ഡെയിലി ഒരാൾക്ക് 1 അല്ലെങ്കിൽ 2 അറ്റാക്ക് ആണ് ലിമിറ്റ്")
  static const int kDailyMaxAttacks = 2;

  static String _safeCurrentUserId([String? fallback]) {
    try {
      final authUser = SupaFlow.client.auth.currentUser;
      if (authUser?.id != null) return authUser!.id;
    } catch (_) {}
    return fallback ?? 'me';
  }

  static Future<int> getDailyAttacksUsedToday([String? userId]) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final uid = _safeCurrentUserId(userId);
    final key = 'daily_raids_count_${uid}_${now.year}_${now.month}_${now.day}';
    return prefs.getInt(key) ?? 0;
  }

  static Future<bool> canLaunchAttackToday([String? userId]) async {
    final used = await getDailyAttacksUsedToday(userId);
    return used < kDailyMaxAttacks;
  }

  static Future<void> recordAttackLaunchedToday([String? userId]) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final uid = _safeCurrentUserId(userId);
    final key = 'daily_raids_count_${uid}_${now.year}_${now.month}_${now.day}';
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  /// 📜 Save Citadel Raid Log & Sync to Supabase
  static Future<void> recordRaidLog(CitadelRaidLogEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getRecentRaids();
    final updated = [entry, ...existing.where((e) => e.id != entry.id)].take(30).toList();
    await prefs.setString(_raidLogKey, jsonEncode(updated.map((e) => e.toJson()).toList()));

    try {
      final myId = SupaFlow.client.auth.currentUser?.id;
      if (myId != null) {
        await SupaFlow.client.from('citadel_raids').insert({
          'defender_id': myId,
          if (entry.attackerId.isNotEmpty) 'attacker_id': entry.attackerId,
          'attacker_name': entry.attackerName,
          'attacker_avatar': entry.attackerAvatar,
          'attacker_weapon': entry.attackerWeapon,
          'breached': entry.breached,
          'coins_looted': entry.coinsLooted,
          'iron_dome_blocked': entry.ironDomeBlocked,
          'created_at': entry.timestamp.toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Supabase raid log sync: $e');
    }
  }

  /// 📜 Retrieve Recent Citadel Raid Logs (Supabase + Local Cache)
  static Future<List<CitadelRaidLogEntry>> getRecentRaids() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Try Supabase
    try {
      final myId = SupaFlow.client.auth.currentUser?.id;
      if (myId != null) {
        final res = await SupaFlow.client
            .from('citadel_raids')
            .select()
            .eq('defender_id', myId)
            .order('created_at', ascending: false)
            .limit(20);
        if (res.isNotEmpty) {
          final entries = res.map((r) => CitadelRaidLogEntry(
            id: r['id']?.toString() ?? '',
            attackerId: r['attacker_id']?.toString() ?? '',
            attackerName: r['attacker_name'] ?? 'Rival Raider',
            attackerAvatar: r['attacker_avatar'] ?? '⚔️',
            attackerWeapon: r['attacker_weapon'] ?? '💥 Heavy Cannon',
            timestamp: r['created_at'] != null ? DateTime.tryParse(r['created_at']) ?? DateTime.now() : DateTime.now(),
            breached: r['breached'] ?? false,
            coinsLooted: (r['coins_looted'] as num?)?.toInt() ?? 0,
            ironDomeBlocked: r['iron_dome_blocked'] ?? false,
          )).toList();
          await prefs.setString(_raidLogKey, jsonEncode(entries.map((e) => e.toJson()).toList()));
          return entries;
        }
      }
    } catch (_) {}

    // 2. Local cache
    final raw = prefs.getString(_raidLogKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = (jsonDecode(raw) as List).map((e) => CitadelRaidLogEntry.fromJson(e)).toList();
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }

    // No dummy seed data per user directive: "സൂപ്പർബേസ് ആയിട്ട് ബാക്ക് എൻഡ് വേണം, ഡമ്മി പറ്റൂല്ല"
    return [];
  }

  /// 💥 Process House Breach after attacker victory
  /// User Audio Rule:
  /// - If defender has active Iron Dome: breach absorbed completely! (0 HP loss, 0 coins looted, dome consumed)
  /// - Else: Breached! Deals 60 HP damage, loots exactly 45 coins from vault.
  static Future<Map<String, dynamic>> processRaidBreach({
    required String defenderHouseId,
    String attackerId = '',
    int damageHp = 60,
    String attackerName = 'Rival Raider',
    String attackerAvatar = '⚔️',
    String attackerWeapon = '💥 Heavy Cannon',
    bool defenderHasIronDome = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHp = prefs.getInt(_hpKey) ?? 100;
    final currentCoins = prefs.getInt(_coinsKey) ?? 150;
    final isSelfDefender = defenderHouseId == 'me';
    final hasDome = isSelfDefender ? (prefs.getBool(_ironDomeKey) ?? false) : defenderHasIronDome;

    if (hasDome) {
      if (isSelfDefender) {
        await prefs.setBool(_ironDomeKey, false);
        await prefs.setInt('${_ironDomeKey}_tier', 0);
      }

      final entry = CitadelRaidLogEntry(
        id: 'raid_${DateTime.now().millisecondsSinceEpoch}',
        attackerId: attackerId,
        attackerName: attackerName,
        attackerAvatar: attackerAvatar,
        attackerWeapon: attackerWeapon,
        timestamp: DateTime.now(),
        breached: false,
        coinsLooted: 0,
        ironDomeBlocked: true,
      );
      await recordRaidLog(entry);

      return {
        'damageDealt': 0,
        'remainingHp': currentHp,
        'lootedCoins': 0,
        'ironDomeBlocked': true,
        'isRubbled': false,
      };
    }

    // Breached: Loot exactly 45 coins
    const lootedCoins = kRaidBreachLootCoins;
    final newHp = math.max(0, currentHp - damageHp);
    final remainingCoins = math.max(0, currentCoins - lootedCoins);

    if (isSelfDefender) {
      await prefs.setInt(_hpKey, newHp);
      await prefs.setInt(_coinsKey, remainingCoins);
    }

    final entry = CitadelRaidLogEntry(
      id: 'raid_${DateTime.now().millisecondsSinceEpoch}',
      attackerId: attackerId,
      attackerName: attackerName,
      attackerAvatar: attackerAvatar,
      attackerWeapon: attackerWeapon,
      timestamp: DateTime.now(),
      breached: true,
      coinsLooted: lootedCoins,
      ironDomeBlocked: false,
    );
    await recordRaidLog(entry);

    // 👮‍♂️ Place breached house under 48-Hour Presidential Police Protection (Audio 16 directive)
    await placeUnderPresidentialProtection(defenderHouseId);

    return {
      'damageDealt': damageHp,
      'remainingHp': newHp,
      'lootedCoins': lootedCoins,
      'ironDomeBlocked': false,
      'isRubbled': newHp <= 0,
      'underPresidentialProtection': true,
      'protectionHours': kPresidentialProtectionHours,
    };
  }

  // ============================================================
  // 👮‍♂️ 48-HOUR PRESIDENTIAL POLICE PROTECTION SYSTEM (Audio 16)
  // "പിന്നെ ഒരു രണ്ടു ദിവസം സമയം കൊടുക്കണം. അതിനുള്ളിൽ ഇവര് റിക്കവർ ചെയ്യാൻ വേണ്ടിയിട്ട്
  // 'പ്രസിഡൻഷ്യൽ പ്രൊട്ടക്ഷൻ' കൊടുക്കും. കാവൽക്കാർ പ്രസിഡൻസിന്റെ പോലീസ് കാവലുകള്
  // വന്നിട്ട് നിൽക്കും എന്നിട്ട് പ്രൊട്ടക്ട് ചെയ്യും. രണ്ടു ദിവസം പ്രൊട്ടക്ട് ചെയ്യും."
  // ============================================================
  static const String _presidentialProtectionPrefix = 'pocket_pres_protection_';
  static const int kPresidentialProtectionHours = 48;

  /// Place a breached house under 48-hour Presidential Police Protection
  static Future<void> placeUnderPresidentialProtection(
    String houseId, {
    int hours = kPresidentialProtectionHours,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(Duration(hours: hours)).millisecondsSinceEpoch;
    await prefs.setInt('$_presidentialProtectionPrefix$houseId', expiry);
  }

  /// Check if house is actively guarded by Presidential Police
  static Future<bool> isUnderPresidentialProtection(String houseId) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt('$_presidentialProtectionPrefix$houseId');
    if (expiry == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expiry;
  }

  /// Get minutes remaining in 48-hour Presidential Police Protection
  static Future<int> getPresidentialProtectionMinutesRemaining(String houseId) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt('$_presidentialProtectionPrefix$houseId');
    if (expiry == null) return 0;
    final diff = expiry - DateTime.now().millisecondsSinceEpoch;
    return diff > 0 ? (diff / (1000 * 60)).ceil() : 0;
  }

  /// Lift protection early when house is repaired/rebuilt
  static Future<void> liftPresidentialProtection(String houseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_presidentialProtectionPrefix$houseId');
  }

  /// 🤖 Pocket Robo Matchmaker Profile Generator (Audio 16 directive)
  static Map<String, dynamic> generatePocketRoboProfile(int targetDay) {
    final roboNames = [
      'Pocket Robo 🤖 Alpha',
      'Pocket Robo 🤖 Titan',
      'Pocket Robo 🤖 Apex',
      'Pocket Robo 🤖 Sentinel',
      'Pocket Robo 🤖 Nexus',
      'Pocket Robo 🤖 Zenith',
    ];
    final name = roboNames[(targetDay + 3) % roboNames.length];
    return {
      'id': 'pocket_robo_$targetDay',
      'name': name,
      'day': targetDay,
      'streak': targetDay,
      'rank': 'Robo Home Guardian (Lvl $targetDay)',
      'isPocketRobo': true,
      'statusMessage': '🤖 Autonomous AI English Defender ready for battle!',
    };
  }

  /// Apply damage after a raid
  static Future<void> applyRaidDamage(int damage) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHp = prefs.getInt(_hpKey) ?? 100;
    final newHp = math.max(0, currentHp - damage);
    await prefs.setInt(_hpKey, newHp);
  }

  /// Award coins after a successful raid
  static Future<void> awardRaidLoot(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt(_coinsKey) ?? 150;
    await prefs.setInt(_coinsKey, currentCoins + coins);
  }

  /// Load custom shield questions
  /// Note: As per user specification, we DO NOT pre-fill fake questions for the player.
  /// The player is solely responsible for crafting their own defense questions!
  /// For neighbor raids, curated questions are provided as fallback if empty.
  static Future<List<HouseShieldQuestion>> loadShieldQuestions(int stage, {bool isNeighbor = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_trapsKey);
    final maxAllowed = getMaxQuestionsForStage(stage);

    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List).map((e) => HouseShieldQuestion.fromJson(e)).toList();
        if (list.isNotEmpty) {
          return list.take(maxAllowed).toList();
        }
      } catch (_) {}
    }

    if (!isNeighbor) {
      return []; // Self-built defense: User begins with empty unlocked slots!
    }

    // Default curated questions only for neighbor houses
    return _getDefaultQuestions(maxAllowed);
  }

  /// Save custom shield questions
  static Future<void> saveShieldQuestions(List<HouseShieldQuestion> questions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(questions.map((q) => q.toJson()).toList());
    await prefs.setString(_trapsKey, jsonStr);
  }

  /// Starter default questions (Used strictly for neighbor raids)
  static List<HouseShieldQuestion> _getDefaultQuestions(int count) {
    final List<HouseShieldQuestion> allCurated = [];
    for (final template in kDefenseTrapTemplates) {
      allCurated.addAll(getCuratedQuestionsForTrap(template.id));
    }

    if (allCurated.isEmpty) {
      allCurated.add(
        const HouseShieldQuestion(
          id: 'q_default_1',
          question: 'What is the exact synonym for "Ephemeral"?',
          options: ['Short-lived', 'Permanent', 'Ancient', 'Violent'],
          correctIndex: 0,
          explanation: '"Ephemeral" means lasting for a very short time.',
        ),
      );
    }

    final List<HouseShieldQuestion> result = [];
    int index = 0;
    while (result.length < count) {
      final base = allCurated[index % allCurated.length];
      result.add(
        HouseShieldQuestion(
          id: 'def_${result.length + 1}_${base.id}',
          question: base.question,
          options: base.options,
          correctIndex: base.correctIndex,
          explanation: base.explanation,
          category: base.category,
          trapType: base.trapType,
        ),
      );
      index++;
    }
    return result;
  }

  // ============================================================
  // 🚩 FAIR PLAY & ANTI-CHEAT REPORTING & ADMIN BAN SYSTEM
  // ============================================================
  static const String _reportsKey = 'pocket_defense_reports_list_v1';
  static const String _bannedHousesKey = 'pocket_banned_houses_set_v1';

  /// 🚩 File a Defense Question Violation Report against a house
  static Future<DefenseQuestionReport> fileDefenseReport({
    required String houseId,
    required String houseOwnerName,
    required String questionId,
    required String questionText,
    required List<String> options,
    required int correctIndex,
    required String reporterId,
    required String reporterName,
    required String reason,
    required String details,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final report = DefenseQuestionReport(
      reportId: 'rep_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(999)}',
      houseId: houseId,
      houseOwnerName: houseOwnerName,
      questionId: questionId,
      questionText: questionText,
      options: options,
      correctIndex: correctIndex,
      reporterId: reporterId,
      reporterName: reporterName,
      reason: reason,
      details: details,
      reportedAt: DateTime.now(),
      status: 'pending',
    );

    // Save locally
    final rawList = prefs.getStringList(_reportsKey) ?? [];
    rawList.insert(0, jsonEncode(report.toJson()));
    await prefs.setStringList(_reportsKey, rawList);

    // Auto-ban if house receives 3+ pending reports
    final allReports = await getDefenseReports();
    final houseReports = allReports.where((r) => r.houseId == houseId && r.status == 'pending').length;
    if (houseReports >= 3) {
      await banHouse(houseId, reason: 'Multiple attacking players verified fake/nonsense English defense traps.');
    }

    return report;
  }

  /// 📜 Retrieve all reports for Admin Review
  static Future<List<DefenseQuestionReport>> getDefenseReports() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_reportsKey);

    // If first time, seed with initial sample reports for testing the admin queue
    if (rawList == null || rawList.isEmpty) {
      final sampleReports = [
        DefenseQuestionReport(
          reportId: 'rep_seed_1',
          houseId: 'neighbor_troll',
          houseOwnerName: 'SpamMaster_X',
          questionId: 'q_fake_1',
          questionText: 'asdfghjkl zxcvbnm qwertyuiop ????',
          options: const ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
          correctIndex: 0,
          reporterId: 'scout_alex',
          reporterName: 'Alex Hunter',
          reason: 'fake_gibberish',
          details: 'Keyboard mash question with no English educational value to cheat defense.',
          reportedAt: DateTime.now().subtract(const Duration(hours: 3)),
          status: 'pending',
        ),
        DefenseQuestionReport(
          reportId: 'rep_seed_2',
          houseId: 'neighbor_cheat',
          houseOwnerName: 'ShadowKing_07',
          questionId: 'q_fake_2',
          questionText: 'Which animal flies in the sky?',
          options: const ['Fish', 'Stone', 'Elephant', 'Tree'],
          correctIndex: 1,
          reporterId: 'scout_sarah',
          reporterName: 'Sarah Jenkins',
          reason: 'wrong_answer',
          details: 'Owner intentionally marked "Stone" as correct answer to make defense invincible.',
          reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
          status: 'pending',
        ),
      ];
      final jsonStrings = sampleReports.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_reportsKey, jsonStrings);
      return sampleReports;
    }

    final List<DefenseQuestionReport> list = [];
    for (final raw in rawList) {
      try {
        list.add(DefenseQuestionReport.fromJson(jsonDecode(raw)));
      } catch (_) {}
    }
    return list;
  }

  /// 🚫 Admin Action: Ban House for Fake Questions
  static Future<void> banHouse(String houseId, {required String reason}) async {
    final prefs = await SharedPreferences.getInstance();
    final bannedSet = (prefs.getStringList(_bannedHousesKey) ?? []).toSet();
    bannedSet.add(houseId);
    await prefs.setStringList(_bannedHousesKey, bannedSet.toList());

    if (houseId == 'me') {
      await prefs.setBool(_banKey, true);
    }

    // Update report status to banned
    final reports = await getDefenseReports();
    final updated = reports.map((r) {
      if (r.houseId == houseId) {
        return DefenseQuestionReport(
          reportId: r.reportId,
          houseId: r.houseId,
          houseOwnerName: r.houseOwnerName,
          questionId: r.questionId,
          questionText: r.questionText,
          options: r.options,
          correctIndex: r.correctIndex,
          reporterId: r.reporterId,
          reporterName: r.reporterName,
          reason: r.reason,
          details: r.details,
          reportedAt: r.reportedAt,
          status: 'banned',
        );
      }
      return r;
    }).toList();

    await prefs.setStringList(_reportsKey, updated.map((r) => jsonEncode(r.toJson())).toList());
  }

  /// 🔓 Admin Action: Unban House
  static Future<void> unbanHouse(String houseId) async {
    final prefs = await SharedPreferences.getInstance();
    final bannedSet = (prefs.getStringList(_bannedHousesKey) ?? []).toSet();
    bannedSet.remove(houseId);
    await prefs.setStringList(_bannedHousesKey, bannedSet.toList());

    if (houseId == 'me') {
      await prefs.setBool(_banKey, false);
    }
  }

  /// ❌ Admin Action: Dismiss Report
  static Future<void> dismissReport(String reportId) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = await getDefenseReports();
    final updated = reports.map((r) {
      if (r.reportId == reportId) {
        return DefenseQuestionReport(
          reportId: r.reportId,
          houseId: r.houseId,
          houseOwnerName: r.houseOwnerName,
          questionId: r.questionId,
          questionText: r.questionText,
          options: r.options,
          correctIndex: r.correctIndex,
          reporterId: r.reporterId,
          reporterName: r.reporterName,
          reason: r.reason,
          details: r.details,
          reportedAt: r.reportedAt,
          status: 'dismissed',
        );
      }
      return r;
    }).toList();

    await prefs.setStringList(_reportsKey, updated.map((r) => jsonEncode(r.toJson())).toList());
  }

  /// 🛡️ Check if any house is currently banned
  static Future<bool> isHouseBanned(String houseId) async {
    final prefs = await SharedPreferences.getInstance();
    if (houseId == 'me') {
      return prefs.getBool(_banKey) ?? false;
    }
    final bannedSet = (prefs.getStringList(_bannedHousesKey) ?? []).toSet();
    return bannedSet.contains(houseId);
  }

  /// ⚖️ Check if a house is under active Presidential inspection (unresolved President Call)
  static Future<bool> isUnderPresidentInspection(String houseId) async {
    final reports = await getDefenseReports();
    return reports.any((r) => r.houseId == houseId && r.status == 'pending');
  }

  /// 🔨 Rebuild House from Scratch after a Presidential Ban/Condemnation
  /// As specified by user: "ബാൻ ആക്കിക്കഴിഞ്ഞു കഴിഞ്ഞാൽ അവർക്ക് ആ വീട് യൂസ് ചെയ്യാൻ പറ്റില്ല, പിന്നെ ഫസ്റ്റ്ട്ട് തുടങ്ങണം"
  static Future<void> rebuildHouseFromScratch(String houseId) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Remove ban status
    await unbanHouse(houseId);

    // 2. If player's own house, wipe all defense questions and restore full health
    if (houseId == 'me') {
      await saveShieldQuestions([]);
      await prefs.setInt(_hpKey, 100);
      await prefs.setBool(_banKey, false);
    }

    // 3. Clear/dismiss pending reports for this house
    final reports = await getDefenseReports();
    final updated = reports.map((r) {
      if (r.houseId == houseId) {
        return DefenseQuestionReport(
          reportId: r.reportId,
          houseId: r.houseId,
          houseOwnerName: r.houseOwnerName,
          questionId: r.questionId,
          questionText: r.questionText,
          options: r.options,
          correctIndex: r.correctIndex,
          reporterId: r.reporterId,
          reporterName: r.reporterName,
          reason: r.reason,
          details: r.details,
          reportedAt: r.reportedAt,
          status: 'dismissed',
        );
      }
      return r;
    }).toList();
    await prefs.setStringList(_reportsKey, updated.map((r) => jsonEncode(r.toJson())).toList());
  }

  /// 📜 Presidential Notice: Issue official warning decree to a house
  static Future<void> issuePresidentNotice(String houseId, {required String reason}) async {
    final prefs = await SharedPreferences.getInstance();
    if (houseId == 'me') {
      await prefs.setString(_presidentNoticeKey, reason);
    } else {
      await prefs.setString('${_presidentNoticeKey}_$houseId', reason);
    }
  }

  /// Dismiss/Acknowledge Presidential Notice
  static Future<void> dismissPresidentNotice(String houseId) async {
    final prefs = await SharedPreferences.getInstance();
    if (houseId == 'me') {
      await prefs.remove(_presidentNoticeKey);
    } else {
      await prefs.remove('${_presidentNoticeKey}_$houseId');
    }
  }

  /// ⛓️ Sentence House to Jail (Audio directive: "ജയിൽ ആണെങ്കിൽ ആ വീടിനെ മൊത്തം ജയിൽ പോലെ ഒരു സെറ്റപ്പ് ഡെവലപ്പ് ചെയ്യണം... ഇത്ര ദിവസം ജയിലിൽ കിടക്കേണ്ടി വരും")
  static Future<void> sentenceToJail(String houseId, {int days = 3, required String reason}) async {
    final prefs = await SharedPreferences.getInstance();
    final releaseTime = DateTime.now().add(Duration(days: days));
    if (houseId == 'me') {
      await prefs.setBool(_jailedKey, true);
      await prefs.setString(_jailUntilKey, releaseTime.toIso8601String());
      await prefs.setString(_jailReasonKey, reason);
    }
    final jailedList = (prefs.getStringList(_jailedHousesListKey) ?? []).toSet();
    jailedList.add(houseId);
    await prefs.setStringList(_jailedHousesListKey, jailedList.toList());
    await prefs.setString('${_jailUntilKey}_$houseId', releaseTime.toIso8601String());
    await prefs.setString('${_jailReasonKey}_$houseId', reason);
  }

  static Future<bool> isHouseJailed(String houseId) async {
    final prefs = await SharedPreferences.getInstance();
    String? untilStr;
    if (houseId == 'me') {
      if (!(prefs.getBool(_jailedKey) ?? false)) return false;
      untilStr = prefs.getString(_jailUntilKey);
    } else {
      final list = prefs.getStringList(_jailedHousesListKey) ?? [];
      if (!list.contains(houseId)) return false;
      untilStr = prefs.getString('${_jailUntilKey}_$houseId');
    }
    if (untilStr == null) return false;
    final until = DateTime.tryParse(untilStr);
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      // Jail sentence expired
      await releaseFromJail(houseId);
      return false;
    }
    return true;
  }

  static Future<void> releaseFromJail(String houseId) async {
    final prefs = await SharedPreferences.getInstance();
    if (houseId == 'me') {
      await prefs.setBool(_jailedKey, false);
      await prefs.remove(_jailUntilKey);
      await prefs.remove(_jailReasonKey);
    }
    final jailedList = (prefs.getStringList(_jailedHousesListKey) ?? []).toSet();
    jailedList.remove(houseId);
    await prefs.setStringList(_jailedHousesListKey, jailedList.toList());
    await prefs.remove('${_jailUntilKey}_$houseId');
    await prefs.remove('${_jailReasonKey}_$houseId');
  }

  /// 📉 Demote House Level (Audio directive: "രണ്ടു മൂന്ന് ലെവൽ ബാക്കിലോട്ട് ഇടാം")
  static Future<int> demoteHouseLevel(String houseId, {int levels = 2}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentLastCompleted = prefs.getInt('learning_last_completed_day') ?? 1;
    final newDay = math.max(1, currentLastCompleted - levels);
    await prefs.setInt('learning_last_completed_day', newDay);
    return newDay;
  }

  /// 🚫 Ban House & Confiscate Coins (Audio directive: "ഫസ്റ്റിലോട്ട് തുടങ്ങണം, ഇവരുടെ കോയിൻസ് എല്ലാം ഗവൺമെന്റ് മേടിച്ചെടുക്കും")
  static Future<void> banHouseWithAssetConfiscation(String houseId, {required String reason}) async {
    final prefs = await SharedPreferences.getInstance();
    await banHouse(houseId, reason: reason);
    if (houseId == 'me') {
      // Confiscate coins to government treasury
      await prefs.setInt(_coinsKey, 0);
      // Reset progression to Day 1
      await prefs.setInt('learning_last_completed_day', 0);
      // Wipe fake defense questions
      await saveShieldQuestions([]);
    }
  }
}

/// 🚩 Model for Defense Question Violation Report
class DefenseQuestionReport {
  final String reportId;
  final String houseId;
  final String houseOwnerName;
  final String questionId;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String reporterId;
  final String reporterName;
  final String reason; // 'fake_gibberish' | 'wrong_answer' | 'impossible_trap' | 'offensive_content'
  final String details;
  final DateTime reportedAt;
  final String status; // 'pending' | 'banned' | 'dismissed'

  const DefenseQuestionReport({
    required this.reportId,
    required this.houseId,
    required this.houseOwnerName,
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.reporterId,
    required this.reporterName,
    required this.reason,
    required this.details,
    required this.reportedAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'houseId': houseId,
        'houseOwnerName': houseOwnerName,
        'questionId': questionId,
        'questionText': questionText,
        'options': options,
        'correctIndex': correctIndex,
        'reporterId': reporterId,
        'reporterName': reporterName,
        'reason': reason,
        'details': details,
        'reportedAt': reportedAt.toIso8601String(),
        'status': status,
      };

  factory DefenseQuestionReport.fromJson(Map<String, dynamic> json) => DefenseQuestionReport(
        reportId: json['reportId'] ?? '',
        houseId: json['houseId'] ?? '',
        houseOwnerName: json['houseOwnerName'] ?? 'House Resident',
        questionId: json['questionId'] ?? '',
        questionText: json['questionText'] ?? '',
        options: List<String>.from(json['options'] ?? []),
        correctIndex: json['correctIndex'] ?? 0,
        reporterId: json['reporterId'] ?? '',
        reporterName: json['reporterName'] ?? 'Attacker Scout',
        reason: json['reason'] ?? 'fake_gibberish',
        details: json['details'] ?? '',
        reportedAt: DateTime.tryParse(json['reportedAt'] ?? '') ?? DateTime.now(),
        status: json['status'] ?? 'pending',
      );
}
