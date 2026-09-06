import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../avatar/avatar_game_perk.dart';

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

/// 🛡️ Model for a Custom House Shield Question
class HouseShieldQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category; // 'vocab', 'grammar', 'idiom', 'comprehension', 'tense', 'syntax'
  final String trapType; // 'vocab_gate', 'grammar_sentry', 'tense_fortress', 'idiom_maze', 'syntax_wall'
  final bool isPresidentApproved;

  const HouseShieldQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.category = 'vocab',
    this.trapType = 'vocab_gate',
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
  final bool isBanned;
  final String? banReason;
  final bool isUnderPresidentInspection;
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
    this.isBanned = false,
    this.banReason,
    this.isUnderPresidentInspection = false,
    this.activeShieldTraps = const ['vocab_gate'],
    this.activePerk,
  });

  double get hpPercentage => (currentHp / maxHp.toDouble()).clamp(0.0, 1.0);
}

/// 🛡️ Central Pocket Fortress & Defense Management Service
class PocketFortressDefenseService {
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
  static PresidentVerdict validateQuestion(String question, List<String> options, int correctIdx) {
    final q = question.trim();

    // 1. Minimum length check
    if (q.length < 10) {
      return PresidentVerdict.threat(
        'Question is suspiciously short (${q.length} chars). Trivial spam questions violate Pocket World fair-play and lead to account bans.',
      );
    }

    // 2. Gibberish / keyboard mash detector
    final cleanAlpha = q.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (cleanAlpha.length > 8) {
      final repeatingChars = RegExp(r'(.)\1{3,}');
      if (repeatingChars.hasMatch(cleanAlpha)) {
        return PresidentVerdict.threat(
          'Repetitive keyboard mash detected. The President prohibits fake questions designed to exploit house defense.',
        );
      }
    }

    // 3. Options validation
    if (options.length < 4) {
      return PresidentVerdict.warning('Every defense question must have 4 distinct choices.');
    }

    final trimmedOptions = options.map((e) => e.trim().toLowerCase()).toList();
    final uniqueCount = trimmedOptions.toSet().length;
    if (uniqueCount < 4) {
      return PresidentVerdict.warning('Duplicate answer options detected. Please write 4 unique, educational answers.');
    }

    // 4. Empty option check
    if (trimmedOptions.any((o) => o.isEmpty)) {
      return PresidentVerdict.warning('Options cannot be empty.');
    }

    // 5. Correct index in range
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
    final underInspection = await isUnderPresidentInspection('me');
    final activeTraps = await getActiveShieldTraps(stage);

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
      isBanned: banned,
      banReason: banned ? 'Condemned by Presidential Decree: Reported fake English defenses.' : null,
      isUnderPresidentInspection: underInspection,
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
  static Future<int> recordActivityPoints(String activityType, {int? stage}) async {
    final prefs = await SharedPreferences.getInstance();
    int gain = 10;
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
  static Future<bool> repairHouse({int healAmount = 50, int coinCost = 30, int fdcCost = 40, bool useFdc = false}) async {
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

  /// Upgrade / Purchase Iron Dome (Using Coins or FDC from voice/chat/vibe activities)
  static Future<bool> purchaseIronDome({int tier = 1, int coinCost = 75, int fdcCost = 60, bool useFdc = false}) async {
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

  /// 💥 Process House Breach after attacker victory
  /// Damages defender's house, loots coins from vault, and returns breach report
  static Future<Map<String, dynamic>> processRaidBreach({
    required String defenderHouseId,
    int damageHp = 50,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHp = prefs.getInt(_hpKey) ?? 100;
    final currentCoins = prefs.getInt(_coinsKey) ?? 150;

    final newHp = math.max(0, currentHp - damageHp);
    final lootedCoins = math.max(15, (currentCoins * 0.2).round()); // 20% looted from vault
    final remainingCoins = math.max(0, currentCoins - lootedCoins);

    await prefs.setInt(_hpKey, newHp);
    await prefs.setInt(_coinsKey, remainingCoins);

    return {
      'damageDealt': damageHp,
      'remainingHp': newHp,
      'lootedCoins': lootedCoins,
      'isRubbled': newHp <= 0,
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
