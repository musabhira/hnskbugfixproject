import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

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
  final String category; // 'vocab', 'grammar', 'idiom', 'comprehension'
  final bool isPresidentApproved;

  const HouseShieldQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.category = 'vocab',
    this.isPresidentApproved = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'category': category,
        'isPresidentApproved': isPresidentApproved,
      };

  factory HouseShieldQuestion.fromJson(Map<String, dynamic> json) => HouseShieldQuestion(
        id: json['id'] ?? '',
        question: json['question'] ?? '',
        options: List<String>.from(json['options'] ?? []),
        correctIndex: json['correctIndex'] ?? 0,
        explanation: json['explanation'] ?? '',
        category: json['category'] ?? 'vocab',
        isPresidentApproved: json['isPresidentApproved'] ?? true,
      );
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
  final bool isBanned;
  final String? banReason;

  const HouseDefenseStatus({
    this.currentHp = 100,
    this.maxHp = 100,
    this.isDamaged = false,
    this.armyKnightsCount = 0,
    this.hasIronDome = false,
    this.ironDomeTier = 0,
    this.hasArmedEscorts = false,
    this.totalCoins = 150,
    this.isBanned = false,
    this.banReason,
  });

  double get hpPercentage => (currentHp / maxHp.toDouble()).clamp(0.0, 1.0);
}

/// 🛡️ Central Pocket Fortress & Defense Management Service
class PocketFortressDefenseService {
  static const String _trapsKey = 'user_custom_defense_traps_v2';
  static const String _hpKey = 'user_house_hp';
  static const String _ironDomeKey = 'user_house_iron_dome';
  static const String _armyKey = 'user_house_army_knights';
  static const String _escortsKey = 'user_house_armed_escorts';
  static const String _coinsKey = 'user_pocket_coins';
  static const String _banKey = 'user_pocket_banned';
  static const String _lastActiveKey = 'user_pocket_last_active_date';
  static const String _day90FleetKey = 'user_pocket_day90_vip_fleet';

  /// 📐 Calculate max custom questions allowed based on Stage (Day 1 to 90)
  /// - Days 1–2: 2 questions
  /// - Days 3–10: 3–5 questions
  /// - Days 11–30: 8–10 questions
  /// - Days 31–60: 15 questions
  /// - Days 61–90: up to 25 questions!
  static int getMaxQuestionsForStage(int stage) {
    final day = stage.clamp(1, 90);
    if (day <= 2) return 2;
    if (day <= 5) return 3;
    if (day <= 10) return 5;
    if (day <= 20) return 8;
    if (day <= 30) return 10;
    if (day <= 45) return 15;
    if (day <= 60) return 18;
    if (day <= 75) return 22;
    return 25; // Days 76–90: 25 questions!
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
          messageMalayalam: 'നിങ്ങൾ പരിശീലനം മുടക്കിയതിനാൽ നിങ്ങളുടെ സ്റ്റേജ് Day $currentDay-ൽ നിന്ന് Day $downgradedDay-ലേക്ക് ഡൗൺഗ്രേഡ് ആയി! ഫോക്കസ് വീണ്ടെടുക്കാൻ ഇന്നത്തെ മിഷൻ ഉടൻ ചെയ്യുക!',
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
  static Future<HouseDefenseStatus> getHouseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hp = prefs.getInt(_hpKey) ?? 100;
    final hasDome = prefs.getBool(_ironDomeKey) ?? false;
    final domeTier = prefs.getInt('${_ironDomeKey}_tier') ?? (hasDome ? 1 : 0);
    final knights = prefs.getInt(_armyKey) ?? 2;
    final hasEscorts = prefs.getBool(_escortsKey) ?? false;
    final coins = prefs.getInt(_coinsKey) ?? 150;
    final banned = prefs.getBool(_banKey) ?? false;

    return HouseDefenseStatus(
      currentHp: hp,
      maxHp: 100,
      isDamaged: hp < 100,
      armyKnightsCount: knights,
      hasIronDome: hasDome,
      ironDomeTier: domeTier,
      hasArmedEscorts: hasEscorts,
      totalCoins: coins,
      isBanned: banned,
      banReason: banned ? 'Violating Fair Play by publishing fake English questions.' : null,
    );
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

  /// Repair Damaged House
  static Future<bool> repairHouse({int healAmount = 50, int coinCost = 30}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt(_coinsKey) ?? 150;
    if (currentCoins < coinCost) return false;

    final currentHp = prefs.getInt(_hpKey) ?? 100;
    final newHp = math.min(100, currentHp + healAmount);

    await prefs.setInt(_coinsKey, currentCoins - coinCost);
    await prefs.setInt(_hpKey, newHp);
    return true;
  }

  /// Upgrade / Purchase Iron Dome
  static Future<bool> purchaseIronDome({int tier = 1, int coinCost = 75}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt(_coinsKey) ?? 150;
    if (currentCoins < coinCost) return false;

    await prefs.setInt(_coinsKey, currentCoins - coinCost);
    await prefs.setBool(_ironDomeKey, true);
    await prefs.setInt('${_ironDomeKey}_tier', tier);
    return true;
  }

  /// Enlist Army Knights
  static Future<bool> enlistArmyKnights({int count = 2, int coinCost = 40}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCoins = prefs.getInt(_coinsKey) ?? 150;
    if (currentCoins < coinCost) return false;

    final currentKnights = prefs.getInt(_armyKey) ?? 0;
    await prefs.setInt(_coinsKey, currentCoins - coinCost);
    await prefs.setInt(_armyKey, math.min(10, currentKnights + count));
    return true;
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
  static Future<List<HouseShieldQuestion>> loadShieldQuestions(int stage) async {
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

    // Default curated questions if none saved
    return _getDefaultQuestions(maxAllowed);
  }

  /// Save custom shield questions
  static Future<void> saveShieldQuestions(List<HouseShieldQuestion> questions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(questions.map((q) => q.toJson()).toList());
    await prefs.setString(_trapsKey, jsonStr);
  }

  /// Starter default questions
  static List<HouseShieldQuestion> _getDefaultQuestions(int count) {
    final pool = [
      const HouseShieldQuestion(
        id: 'q_1',
        question: 'Choose the most precise synonym for "Pragmatic":',
        options: ['Realistic & Practical', 'Idealistic', 'Impulsive', 'Careless'],
        correctIndex: 0,
        explanation: '"Pragmatic" means dealing with things sensibly and realistically.',
        category: 'vocab',
      ),
      const HouseShieldQuestion(
        id: 'q_2',
        question: 'Identify the grammatically correct sentence:',
        options: [
          'She had finished the report before the manager requested it.',
          'She has finished the report before the manager requested it.',
          'She finishes the report before the manager requested it.',
          'She was finished the report before the manager requested it.'
        ],
        correctIndex: 0,
        explanation: 'Past Perfect ("had finished") is required for an event prior to another past event.',
        category: 'grammar',
      ),
      const HouseShieldQuestion(
        id: 'q_3',
        question: 'What does the native idiom "Cut to the chase" mean?',
        options: [
          'Run after someone in a hurry',
          'Get directly to the main point without wasting time',
          'Chop wood with an axe',
          'End a film before the climax'
        ],
        correctIndex: 1,
        explanation: '"Cut to the chase" means getting straight to the core point.',
        category: 'idiom',
      ),
      const HouseShieldQuestion(
        id: 'q_4',
        question: 'Complete the collocation: "We must _______ our differences aside and work as a team."',
        options: ['put', 'drop', 'throw', 'keep'],
        correctIndex: 0,
        explanation: 'The natural English collocation is "put differences aside".',
        category: 'vocab',
      ),
      const HouseShieldQuestion(
        id: 'q_5',
        question: 'Which word describes someone who recovers quickly from adversity?',
        options: ['Resilient', 'Fragile', 'Vulnerable', 'Hesitant'],
        correctIndex: 0,
        explanation: '"Resilient" signifies being tough, adaptive, and quick to bounce back.',
        category: 'vocab',
      ),
    ];

    return pool.take(count).toList();
  }
}
