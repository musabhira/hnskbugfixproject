import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_avatar_system.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_score_level_engine.dart';

/// 🏡 Kids House / Homestead Model matching the Adult Avatar Homes
class KidsHouse {
  final int tier;
  final String title;
  final String emoji;
  final String description;
  final int unlockedAtDay;
  final Color themeColor;

  const KidsHouse({
    required this.tier,
    required this.title,
    required this.emoji,
    required this.description,
    required this.unlockedAtDay,
    required this.themeColor,
  });
}

enum KidMateRequestStatus { none, sent, received, accepted }

/// 🤝 Model for Kid Mates & Adventure Friends (Kids Peers & Robots)
class KidMate {
  final String id;
  final String name;
  final String avatar; // 🦁, 🤖, 🐼, 🦊, 🦄, 🐰, 🦖
  final String ageGroup;
  final int dayLevel;
  final int stars;
  final bool isFriend;
  final bool isRobot;
  final KidMateRequestStatus requestStatus;
  final String bio;
  final String houseTier;
  final String challengeSentence;
  final VectorAvatarConfig? explicitAvatarConfig;
  final int friendshipScore;

  VectorAvatarConfig get vectorAvatarConfig =>
      explicitAvatarConfig ??
      PocketKidsAvatarSystem.getAvatarConfigForDay(dayLevel);

  const KidMate({
    required this.id,
    required this.name,
    required this.avatar,
    this.ageGroup = '4-6',
    required this.dayLevel,
    this.stars = 0,
    this.isFriend = false,
    this.isRobot = false,
    this.requestStatus = KidMateRequestStatus.none,
    this.bio = '',
    this.houseTier = 'Tier 1 Wooden Cabin',
    this.challengeSentence =
        'Practice makes progress! Ready to challenge my house defense?',
    this.explicitAvatarConfig,
    this.friendshipScore = 0,
  });

  KidMate copyWith({
    bool? isFriend,
    KidMateRequestStatus? requestStatus,
    String? bio,
    String? houseTier,
    String? challengeSentence,
    VectorAvatarConfig? explicitAvatarConfig,
    int? friendshipScore,
  }) {
    return KidMate(
      id: id,
      name: name,
      avatar: avatar,
      ageGroup: ageGroup,
      dayLevel: dayLevel,
      stars: stars,
      isFriend: isFriend ?? this.isFriend,
      isRobot: isRobot,
      requestStatus: requestStatus ?? this.requestStatus,
      bio: bio ?? this.bio,
      houseTier: houseTier ?? this.houseTier,
      challengeSentence: challengeSentence ?? this.challengeSentence,
      explicitAvatarConfig: explicitAvatarConfig ?? this.explicitAvatarConfig,
      friendshipScore: friendshipScore ?? this.friendshipScore,
    );
  }
}

/// 🛡️ Automated Spoken English Defense Challenge for Kids Houses
class KidDefenseChallenge {
  final String prompt;
  final String spokenText;
  final String helperMascot;
  final List<String> options;
  final int correctIndex;
  final String cheerMessage;

  const KidDefenseChallenge({
    required this.prompt,
    required this.spokenText,
    required this.helperMascot,
    required this.options,
    required this.correctIndex,
    required this.cheerMessage,
  });
}

/// 💬 Child-Safe Gamified Mate Message Model (100% separate from adult chat)
class KidMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;
  final bool isStarGift;

  const KidMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.text,
    required this.timestamp,
    required this.isFromMe,
    this.isStarGift = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'isFromMe': isFromMe,
        'isStarGift': isStarGift,
      };

  factory KidMessage.fromJson(Map<String, dynamic> json) => KidMessage(
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        senderName: json['senderName'] as String,
        senderAvatar: json['senderAvatar'] as String,
        text: json['text'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isFromMe: json['isFromMe'] as bool,
        isStarGift: json['isStarGift'] as bool? ?? false,
      );
}

/// 🦁 Model for Pocket Gang (Student Study Groups)
class PocketGang {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int membersCount;
  final List<String> memberAvatars;
  final bool isJoined;

  const PocketGang({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.membersCount,
    required this.memberAvatars,
    this.isJoined = false,
  });

  PocketGang copyWith({bool? isJoined, int? membersCount}) {
    return PocketGang(
      id: id,
      name: name,
      emoji: emoji,
      description: description,
      membersCount: membersCount ?? this.membersCount,
      memberAvatars: memberAvatars,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}

/// 🐾 Model for Student Animal Kingdom Vibes
class StudentVibe {
  final String id;
  final String authorName;
  final String authorAvatar;
  final int dayLevel;
  final String title;
  final String message;
  final String tag;
  final int likes;
  final bool isLiked;

  const StudentVibe({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.dayLevel,
    required this.title,
    required this.message,
    required this.tag,
    required this.likes,
    this.isLiked = false,
  });

  StudentVibe copyWith({int? likes, bool? isLiked}) {
    return StudentVibe(
      id: id,
      authorName: authorName,
      authorAvatar: authorAvatar,
      dayLevel: dayLevel,
      title: title,
      message: message,
      tag: tag,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

/// 🌐 Master Operating Modes / Worlds of Pocket Mates
enum AppWorldMode { adult, student, kids }

/// 🧸 Service for managing Kids vs Student vs Adult account separation,
/// Kids profile state, 100-Day learning journey, Avatar Homes, and Kids Mates.
class PocketKidsService {
  static const String _keyAppWorldMode = 'pm_app_world_mode';
  static const String _keyIsKidAccount = 'pm_is_kid_account';
  static const String _keyKidName = 'pm_kid_name';
  static const String _keyKidAgeGroup = 'pm_kid_age_group';
  static const String _keyKidGender = 'pm_kid_gender';
  static const String _keyKidAvatar = 'pm_kid_avatar';
  static const String _keyKidStars = 'pm_kid_stars';
  static const String _keyKidCurrentDay = 'pm_kid_current_day';
  static const String _keyKidCompletedDays = 'pm_kid_completed_days';
  static const String _keyKidFriendIds = 'pm_kid_friend_ids';
  static const String _keyKidSentRequests = 'pm_kid_sent_requests';
  static const String _keyKidReceivedRequests = 'pm_kid_received_requests';
  static const String _keyIsPureKidAccount = 'pm_is_pure_kid_account';
  static const String _keyIsPureStudentAccount = 'pm_is_pure_student_account';
  static const String _keyIsParentSwitched = 'pm_is_parent_switched';
  static const String _keyKidIsPremium = 'pm_kid_is_premium';
  static const String _keyKidLastCompletedDate = 'pm_kid_last_completed_date';
  static const String _keyKidLastCompletedDay = 'pm_kid_last_completed_day';
  static const String _keyKidStudentScore = 'pm_kid_student_score';
  static const String _keyKidsScore = 'pm_kid_kids_score'; // KS (Kids Score)
  static const String _keyKidFriendshipScores = 'pm_kid_friendship_scores';

  static AppWorldMode _currentWorldMode = AppWorldMode.adult;
  static final ValueNotifier<AppWorldMode> currentWorldModeNotifier =
      ValueNotifier<AppWorldMode>(AppWorldMode.adult);
  static final ValueNotifier<bool> isKidAccountNotifier =
      ValueNotifier<bool>(false);
  static final ValueNotifier<int> kidStarsNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> kidDayNotifier = ValueNotifier<int>(1);
  static final ValueNotifier<bool> kidPremiumNotifier =
      ValueNotifier<bool>(false);
  static final ValueNotifier<int> studentScoreNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> kidsScoreNotifier = ValueNotifier<int>(0);
  static bool _initialized = false;

  static bool _isKidAccount = false;
  static bool _isPureKidAccount = false;
  static bool _isPureStudentAccount = false;
  static bool _isParentSwitched = false;
  static bool _isKidPremium = false;
  static String? _lastCompletedDate;
  static int? _lastCompletedDay;
  static String _kidName = 'Little Explorer';
  static String _kidAgeGroup = '4-6';
  static String _kidGender = 'female'; // 'female' or 'male'
  static String _kidAvatar = '🦁';
  static int _kidStars = 0;
  static int _studentScore = 0; // SS
  static int _kidsScore = 0; // KS
  static int _attackCount = 0;
  static int get attackCount => _attackCount;
  static int get currentStreak => math.max(1, _completedDays.length);
  static int _currentUnlockedDay = 1;
  static final Map<int, int> _completedDays = {}; // day -> stars earned (1-3)
  static final Set<String> _friendIds = {};
  static final Set<String> _sentRequestIds = {};
  static final Set<String> _receivedRequestIds = {};
  static final Map<String, int> _friendshipScores = {};

  static bool _adminModeOverride = false;

  /// Check if current account is Master Admin tester account
  static bool get isAdminAccount {
    if (_adminModeOverride) return true;
    final email = SupaFlow.client.auth.currentUser?.email?.toLowerCase().trim();
    if (email == 'musabthonippadam@gmail.com' ||
        email == 'musabdhonikallam@gmail.com' ||
        email == 'musabdhonikalam@gmail.com') {
      return true;
    }
    return false;
  }

  /// Whether current user can exit Kids/Student Mode back to Adult Mode
  /// Pure Kid / Student accounts cannot exit to Adult Mode!
  /// Only parents who switched from Adult Mode can return to Adult Mode smoothly with Parental Pattern Lock.
  static bool get canExitToAdultAccount => !_isPureKidAccount && !_isPureStudentAccount;
  static bool get canEnterStudentWorld => !_isPureKidAccount;
  static bool get canEnterKidsWorld => true;

  static void setAdminMode(bool enabled) {
    _adminModeOverride = enabled;
    if (enabled) {
      _currentUnlockedDay = 300;
      kidDayNotifier.value = 300;
    }
  }

  /// Check if user has Adventure Pass (Kid Premium)
  static bool get isKidPremium => isAdminAccount || _isKidPremium;

  /// Activate or toggle Kid VIP Adventure Pass (Instant 300-Day Unlock)
  static Future<void> setKidPremium(bool value) async {
    _isKidPremium = value;
    kidPremiumNotifier.value = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyKidIsPremium, value);
    } catch (_) {}
    if (value) {
      kidDayNotifier.value = 300;
    }
  }

  static String getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Whether Day `day` is locked until 12:00 AM (midnight next day) for Free tier users
  static bool isDayLockedByMidnightTimer(int day) {
    if (isAdminAccount || isKidPremium) return false;
    if (day <= 1) return false;

    // ⚔️ User Audio Directive: If user raided houses and accumulated the required
    // Student Score (SS) / Pocket Score for this day, it UNLOCKS IMMEDIATELY bypassing midnight!
    final reqScore = PocketScoreLevelEngine.getRequiredScoreForLevel(day);
    if (_studentScore >= reqScore && reqScore > 0) {
      return false; // Unlocked immediately by earned raid score!
    }

    if (_lastCompletedDay != null && day == _lastCompletedDay! + 1) {
      final todayStr = getTodayDateString();
      if (_lastCompletedDate == todayStr) {
        return true;
      }
    }
    return false;
  }

  /// Checks if a day is fully unlocked and ready to play
  static bool isDayUnlocked(int day) {
    if (isAdminAccount || isKidPremium) return day <= 300;
    if (day < _currentUnlockedDay)
      return true; // Already unlocked or completed past day
    if (day == _currentUnlockedDay) {
      return !isDayLockedByMidnightTimer(day);
    }
    // Also if accumulated score meets future day requirement:
    final reqScore = PocketScoreLevelEngine.getRequiredScoreForLevel(day);
    if (_studentScore >= reqScore &&
        reqScore > 0 &&
        day <= (_lastCompletedDay ?? 0) + 1) {
      return true;
    }
    return false;
  }

  /// Calculate remaining time until next 12:00 AM midnight
  static Duration getTimeUntilMidnight() {
    final now = DateTime.now();
    final tomorrowMidnight =
        DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    return tomorrowMidnight.difference(now);
  }

  /// Format countdown timer string: e.g. "08h 45m 12s"
  static String getFormattedMidnightCountdown() {
    final diff = getTimeUntilMidnight();
    if (diff.isNegative) return '00h 00m 00s';
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}m ${seconds}s';
  }

  static AppWorldMode get currentWorldMode => _currentWorldMode;
  static bool get isAdultWorld => _currentWorldMode == AppWorldMode.adult;
  static bool get isStudentWorld => _currentWorldMode == AppWorldMode.student;
  static bool get isKidsWorld => _currentWorldMode == AppWorldMode.kids;

  static bool get isKidAccount => _isKidAccount;
  static bool get isPureKidAccount => _isPureKidAccount;
  static bool get isPureStudentAccount => _isPureStudentAccount;
  static bool get isParentSwitched => _isParentSwitched;
  static String get kidName => _kidName;
  static bool get isProfileConfigured =>
      _kidName.isNotEmpty && _kidName != 'Little Explorer';
  static String get kidAgeGroup => _kidAgeGroup;
  static String get kidGender => _kidGender;
  static String get kidAvatar => _kidAvatar;
  static int get kidStars => _kidStars;
  static int get currentUnlockedDay =>
      isAdminAccount ? 300 : _currentUnlockedDay;
  static Map<int, int> get completedDays => Map.unmodifiable(_completedDays);
  static Set<String> get friendIds => Set.unmodifiable(_friendIds);
  static Set<String> get sentRequestIds => Set.unmodifiable(_sentRequestIds);
  static Set<String> get receivedRequestIds =>
      Set.unmodifiable(_receivedRequestIds);

  /// 🎓 Student Score (SS) - Strictly isolated from adult PS (Pocket Score)!
  /// Starts at 0, tracked independently. Never cross-contaminates with adult PS.
  static int get studentScore => _studentScore;

  /// 👶 Kids Score (KS) - Dedicated playful score for children (4–8 yrs)
  /// Earned through phonics balloon pops, animal feeding, and mascot playdates!
  static int get kidsScore => _kidsScore;

  /// Backwards-compatibility wrapper for legacy calls (defaults to SS)
  static int get pocketScore => _studentScore;

  static Future<int> getStudentScore([String? uid]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final effectiveUid = uid ?? SupaFlow.client.auth.currentUser?.id;
      if (effectiveUid != null) {
        final val = prefs.getInt('pocket_student_score_$effectiveUid');
        if (val != null) {
          _studentScore = val;
          studentScoreNotifier.value = val;
          return val;
        }
      }
      final fallback = prefs.getInt(_keyKidStudentScore) ?? _studentScore;
      _studentScore = fallback;
      studentScoreNotifier.value = fallback;
      return fallback;
    } catch (_) {
      return _studentScore;
    }
  }

  static Future<void> addStudentScore(int points, [String? uid]) async {
    _studentScore += points;
    studentScoreNotifier.value = _studentScore;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyKidStudentScore, _studentScore);
      final effectiveUid = uid ?? SupaFlow.client.auth.currentUser?.id;
      if (effectiveUid != null) {
        await prefs.setInt('pocket_student_score_$effectiveUid', _studentScore);
        await SupaFlow.client
            .from('profile')
            .update({
              'student_score': _studentScore,
            })
            .eq('user_id', effectiveUid)
            .catchError((_) {});
      }
    } catch (_) {}
  }

  static Future<void> setStudentScore(int score, [String? uid]) async {
    _studentScore = math.max(0, score);
    studentScoreNotifier.value = _studentScore;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyKidStudentScore, _studentScore);
      final effectiveUid = uid ?? SupaFlow.client.auth.currentUser?.id;
      if (effectiveUid != null) {
        await prefs.setInt('pocket_student_score_$effectiveUid', _studentScore);
      }
    } catch (_) {}
  }

  // --- 👶 KIDS SCORE (KS) SYSTEM ---
  static Future<int> getKidsScore([String? uid]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final effectiveUid = uid ?? SupaFlow.client.auth.currentUser?.id;
      if (effectiveUid != null) {
        final val = prefs.getInt('pocket_kids_score_$effectiveUid');
        if (val != null) {
          _kidsScore = val;
          kidsScoreNotifier.value = val;
          return val;
        }
      }
      final fallback = prefs.getInt(_keyKidsScore) ?? _kidsScore;
      _kidsScore = fallback;
      kidsScoreNotifier.value = fallback;
      return fallback;
    } catch (_) {
      return _kidsScore;
    }
  }

  static Future<void> addKidsScore(int points, [String? uid]) async {
    _kidsScore += points;
    kidsScoreNotifier.value = _kidsScore;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyKidsScore, _kidsScore);
      final effectiveUid = uid ?? SupaFlow.client.auth.currentUser?.id;
      if (effectiveUid != null) {
        await prefs.setInt('pocket_kids_score_$effectiveUid', _kidsScore);
        await SupaFlow.client
            .from('profile')
            .update({
              'kids_score': _kidsScore,
            })
            .eq('user_id', effectiveUid)
            .catchError((_) {});
      }
    } catch (_) {}
  }

  static Future<void> setKidsScore(int score, [String? uid]) async {
    _kidsScore = math.max(0, score);
    kidsScoreNotifier.value = _kidsScore;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyKidsScore, _kidsScore);
      final effectiveUid = uid ?? SupaFlow.client.auth.currentUser?.id;
      if (effectiveUid != null) {
        await prefs.setInt('pocket_kids_score_$effectiveUid', _kidsScore);
      }
    } catch (_) {}
  }

  static Future<int> loadAttackCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _attackCount = prefs.getInt('pocket_kids_attack_count') ?? 0;
    } catch (_) {}
    return _attackCount;
  }

  static Future<void> incrementAttackCount() async {
    _attackCount++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('pocket_kids_attack_count', _attackCount);
    } catch (_) {}
  }

  /// 🎓 Calculate Global Rank strictly among students (Up to ~17 years old)
  /// Audio directive: "ഗ്ലോബൽ റാങ്ക് സ്റ്റുഡൻസിന്റെ ആണ് കാണിക്കേണ്ടത്, അഡൽറ്റിന്റെ അല്ല... സ്റ്റുഡൻസ് എന്ന് പറയുമ്പോൾ ഒരു 17 വയസ്സുവരെ അവരുടെ ആണ് കാണിക്കേണ്ടത്."
  static int getStudentGlobalRank(int score, int dayLevel, [String? uid]) {
    if (score <= 0 && dayLevel <= 1) {
      return 0; // Student Challenger (Unranked yet)
    }
    final effectiveDay = dayLevel.clamp(1, 91);
    final calculated = 1200 - (score ~/ 4) - (effectiveDay * 8);
    return math.max(1, calculated);
  }

  static String getStudentGlobalRankLabel(int score, int dayLevel,
      [String? uid]) {
    final rank = getStudentGlobalRank(score, dayLevel, uid);
    if (rank <= 0) {
      return '🌱 Student Challenger';
    }
    return '🎓 Student Rank #$rank';
  }

  // --- 💖 STUDENT FRIENDSHIP SCORE SYSTEM (Audio Directive) ---

  /// Dynamic Friendship chemistry score with animal companions & peer mates (0 to 100%)
  static int getFriendshipScore(String mateId) {
    if (_friendshipScores.containsKey(mateId)) {
      return _friendshipScores[mateId]!.clamp(0, 100);
    }
    if (_friendIds.contains(mateId)) {
      final bonus = (mateId.hashCode.abs() % 25);
      final initial = (45 + bonus).clamp(0, 100);
      _friendshipScores[mateId] = initial;
      return initial;
    }
    return 15; // New buddy acquaintance
  }

  /// Categorical Friendship badge label
  static String getFriendshipBadge(int score) {
    if (score >= 90) return '💖 Best Mates (Forever)';
    if (score >= 75) return '🌟 Close Pals';
    if (score >= 50) return '🤝 Great Friends';
    if (score >= 30) return '🌱 Study Buddies';
    return '👋 New Acquaintance';
  }

  /// Boost friendship score after interactions (chat, star gift, challenges)
  static Future<int> boostFriendship(String mateId, int points) async {
    final current = getFriendshipScore(mateId);
    final updated = (current + points).clamp(0, 100);
    _friendshipScores[mateId] = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _keyKidFriendshipScores, jsonEncode(_friendshipScores));
    } catch (_) {}
    return updated;
  }

  /// 🏆 Day 300 Certificate Unlock Status
  static bool get isCertificateUnlocked =>
      isAdminAccount ||
      _completedDays.containsKey(300) ||
      _currentUnlockedDay >= 300;

  /// 🏰 10 Architectural Homestead Tiers matching the 100-Day Journey up to King Lion Palace
  static const List<KidsHouse> houses = [
    KidsHouse(
      tier: 1,
      title: 'Wooden Cabin',
      emoji: '🌱',
      description: 'Cozy wooden cabin nestled in the green meadow!',
      unlockedAtDay: 1,
      themeColor: Color(0xFF10B981),
    ),
    KidsHouse(
      tier: 2,
      title: 'Brick Villa',
      emoji: '🏡',
      description: 'Sturdy red brick villa with garden flowers!',
      unlockedAtDay: 8,
      themeColor: Color(0xFF38BDF8),
    ),
    KidsHouse(
      tier: 3,
      title: 'Stone Fortress',
      emoji: '🏰',
      description: 'Mighty stone fortress with knight watchtowers!',
      unlockedAtDay: 16,
      themeColor: Color(0xFFA855F7),
    ),
    KidsHouse(
      tier: 4,
      title: 'Treehouse Sanctuary',
      emoji: '🌳',
      description: 'Enchanted treetop sanctuary with canopy walkways!',
      unlockedAtDay: 26,
      themeColor: Color(0xFF14B8A6),
    ),
    KidsHouse(
      tier: 5,
      title: 'Imperial Manor',
      emoji: '🏛️',
      description: 'Grand royal manor with golden pillars and marble!',
      unlockedAtDay: 39,
      themeColor: Color(0xFFF59E0B),
    ),
    KidsHouse(
      tier: 6,
      title: 'Cyber Citadel',
      emoji: '💎',
      description: 'Futuristic crystal citadel shining with neon stars!',
      unlockedAtDay: 53,
      themeColor: Color(0xFFEC4899),
    ),
    KidsHouse(
      tier: 7,
      title: 'Crystal Mountain Palace',
      emoji: '🏔️',
      description: 'Luminous crystal palace on the snow-capped peak!',
      unlockedAtDay: 66,
      themeColor: Color(0xFF6366F1),
    ),
    KidsHouse(
      tier: 8,
      title: 'Titanium Bastion',
      emoji: '🛡️',
      description: 'Impenetrable high-tech bastion with laser shields!',
      unlockedAtDay: 79,
      themeColor: Color(0xFF3B82F6),
    ),
    KidsHouse(
      tier: 9,
      title: 'Apex Sovereign Citadel',
      emoji: '👑',
      description: 'Majestic golden citadel of true English mastery!',
      unlockedAtDay: 90,
      themeColor: Color(0xFFFFD700),
    ),
    KidsHouse(
      tier: 10,
      title: 'Golden Lion King Palace',
      emoji: '🦁',
      description:
          'Supreme 100-Day Grand Palace of the King of the Animal Kingdom!',
      unlockedAtDay: 100,
      themeColor: Color(0xFFFF9900),
    ),
  ];

  /// Get the kid's currently unlocked house based on their completed days
  static KidsHouse get currentHouse {
    int maxCompleted = 1;
    for (final day in _completedDays.keys) {
      if (day > maxCompleted) maxCompleted = day;
    }
    final effectiveDay =
        maxCompleted > _currentUnlockedDay ? maxCompleted : _currentUnlockedDay;
    KidsHouse achieved = houses.first;
    for (final h in houses) {
      if (effectiveDay >= h.unlockedAtDay) {
        achieved = h;
      }
    }
    return achieved;
  }

  /// Get house for any specific day level
  static KidsHouse getHouseForDay(int day) {
    KidsHouse achieved = houses.first;
    for (final h in houses) {
      if (day >= h.unlockedAtDay) {
        achieved = h;
      }
    }
    return achieved;
  }

  /// Get current or day-specific house
  static KidsHouse getCurrentHouse([int? day]) =>
      day != null ? getHouseForDay(day) : currentHouse;

  /// Get the next house to unlock
  static KidsHouse? get nextHouseToUnlock {
    final cur = currentHouse;
    final idx = houses.indexOf(cur);
    if (idx >= 0 && idx + 1 < houses.length) {
      return houses[idx + 1];
    }
    return null;
  }

  /// Load cached account mode from SharedPreferences
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isKidAccount = prefs.getBool(_keyIsKidAccount) ?? false;
      _isPureKidAccount = prefs.getBool(_keyIsPureKidAccount) ?? false;
      _isParentSwitched = prefs.getBool(_keyIsParentSwitched) ?? false;
      _kidName = prefs.getString(_keyKidName) ?? 'Little Explorer';
      _kidAgeGroup = prefs.getString(_keyKidAgeGroup) ?? '4-6';
      _kidGender = prefs.getString(_keyKidGender) ?? 'female';
      _kidAvatar = prefs.getString(_keyKidAvatar) ?? '🦁';
      _kidStars = prefs.getInt(_keyKidStars) ?? 0;
      _currentUnlockedDay = prefs.getInt(_keyKidCurrentDay) ?? 1;
      _isKidPremium = prefs.getBool(_keyKidIsPremium) ?? false;
      _lastCompletedDate = prefs.getString(_keyKidLastCompletedDate);
      _lastCompletedDay = prefs.getInt(_keyKidLastCompletedDay);
      kidPremiumNotifier.value = _isKidPremium;

      // Remote Supabase verification if user is logged in
      try {
        final uid = SupaFlow.client.auth.currentUser?.id;
        if (uid != null) {
          final res = await SupaFlow.client
              .from('profile')
              .select('is_premium, gender')
              .eq('id', uid)
              .maybeSingle();
          if (res != null) {
            if (res['is_premium'] == true) {
              _isKidPremium = true;
              kidPremiumNotifier.value = true;
              await prefs.setBool(_keyKidIsPremium, true);
            }
            if (res['gender'] != null) {
              final g = res['gender'].toString().toLowerCase();
              if (g == 'male' || g == 'boy') {
                _kidGender = 'male';
              } else {
                _kidGender = 'female';
              }
              await prefs.setString(_keyKidGender, _kidGender);
            }
          }
        }
      } catch (_) {}

      final savedDaysJson = prefs.getString(_keyKidCompletedDays);
      if (savedDaysJson != null && savedDaysJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(savedDaysJson) as Map<String, dynamic>;
          _completedDays.clear();
          decoded.forEach((k, v) {
            final day = int.tryParse(k);
            final stars = v is int ? v : 3;
            if (day != null) _completedDays[day] = stars;
          });
        } catch (_) {}
      }

      final savedFriends = prefs.getStringList(_keyKidFriendIds);
      if (savedFriends != null) {
        _friendIds.clear();
        _friendIds.addAll(savedFriends.where(isAllowedKidMateId));
      }

      final savedSent = prefs.getStringList(_keyKidSentRequests);
      if (savedSent != null) {
        _sentRequestIds.clear();
        _sentRequestIds.addAll(savedSent.where(isAllowedKidMateId));
      }

      final savedReceived = prefs.getStringList(_keyKidReceivedRequests);
      if (savedReceived != null) {
        _receivedRequestIds.clear();
        _receivedRequestIds.addAll(savedReceived.where(isAllowedKidMateId));
      } else if (_receivedRequestIds.isEmpty && _friendIds.isEmpty) {
        // Friendly welcome requests from AI kid peers so children can experience accepting requests!
        _receivedRequestIds.addAll(['kid_bot_1', 'kid_bot_2', 'kid_bot_3']);
      }

      // Automatically persist cleansed list if adult IDs were purged
      if (savedFriends != null && savedFriends.length != _friendIds.length) {
        _persistFriendshipState();
      }

      // Load isolated Student Score (SS) - Starts at 0
      _studentScore = prefs.getInt(_keyKidStudentScore) ?? 0;
      studentScoreNotifier.value = _studentScore;
      
      // Load isolated Kids Score (KS) - Starts at 0
      _kidsScore = prefs.getInt(_keyKidsScore) ?? 0;
      kidsScoreNotifier.value = _kidsScore;

      // Load completed day steps
      for (final k in prefs.getKeys()) {
        if (k.startsWith('pm_kid_day_') && prefs.getBool(k) == true) {
          _completedDaySteps[k] = true;
        }
      }

      _isPureStudentAccount = prefs.getBool(_keyIsPureStudentAccount) ?? false;
      _attackCount = prefs.getInt('pocket_kids_attack_count') ?? 0;

      // Determine active World Mode
      final savedWorldMode = prefs.getString(_keyAppWorldMode);
      if (savedWorldMode == 'kids') {
        _currentWorldMode = AppWorldMode.kids;
        _isKidAccount = true;
      } else if (savedWorldMode == 'student') {
        _currentWorldMode = AppWorldMode.student;
        _isKidAccount = true;
      } else {
        _currentWorldMode = _isKidAccount ? AppWorldMode.student : AppWorldMode.adult;
      }
      currentWorldModeNotifier.value = _currentWorldMode;

      // Load Friendship Scores with companions and peers
      final fsRaw = prefs.getString(_keyKidFriendshipScores);
      if (fsRaw != null && fsRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(fsRaw) as Map<String, dynamic>;
          _friendshipScores.clear();
          decoded.forEach((k, v) {
            final s = v is int ? v : int.tryParse(v.toString());
            if (s != null) _friendshipScores[k] = s.clamp(0, 100);
          });
        } catch (_) {}
      }

      isKidAccountNotifier.value = _isKidAccount;
      kidStarsNotifier.value = _kidStars;
      kidDayNotifier.value = _currentUnlockedDay;
      _initialized = true;
    } catch (e) {
      debugPrint('PocketKidsService: Error initializing: $e');
    }
  }

  /// Activate Kids Account Mode (KS Score, Pure Cartoon Adventure, Phonics & Mascot Playdates)
  static Future<void> activateKidAccount({
    required String name,
    required String ageGroup,
    required String avatar,
    String gender = 'female',
    bool isParentSwitched = false,
    bool isPureKid = false,
  }) async {
    _isKidAccount = true;
    _currentWorldMode = AppWorldMode.kids;
    currentWorldModeNotifier.value = AppWorldMode.kids;
    if (isParentSwitched) {
      _isParentSwitched = true;
      _isPureKidAccount = false;
      _isPureStudentAccount = false;
    } else if (isPureKid) {
      _isPureKidAccount = true;
      _isPureStudentAccount = false;
      _isParentSwitched = false;
    }
    _kidName = name.trim().isNotEmpty ? name.trim() : 'Little Explorer';
    _kidAgeGroup = ageGroup.isNotEmpty ? ageGroup : '4-6';
    _kidGender =
        (gender.toLowerCase().contains('boy') || gender.toLowerCase() == 'male')
            ? 'male'
            : 'female';
    _kidAvatar = avatar;
    isKidAccountNotifier.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAppWorldMode, 'kids');
      await prefs.setBool(_keyIsKidAccount, true);
      await prefs.setBool(_keyIsPureKidAccount, _isPureKidAccount);
      await prefs.setBool(_keyIsPureStudentAccount, false);
      await prefs.setBool(_keyIsParentSwitched, _isParentSwitched);
      await prefs.setString(_keyKidName, _kidName);
      await prefs.setString(_keyKidAgeGroup, _kidAgeGroup);
      await prefs.setString(_keyKidGender, _kidGender);
      await prefs.setString(_keyKidAvatar, _kidAvatar);

      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await prefs.setBool('is_kid_account_${user.id}', true);
        await SupaFlow.client
            .from('profile')
            .update({
              'account_type': _isPureKidAccount ? 'pure_kid' : 'kid',
              'kid_name': _kidName,
              'kid_age_group': _kidAgeGroup,
              'gender': _kidGender,
              'kid_avatar': _kidAvatar,
            })
            .eq('user_id', user.id)
            .catchError((_) {});
      }
    } catch (e) {
      debugPrint('PocketKidsService: Error activating kid account: $e');
    }
  }

  /// Activate Student Account Mode (SS Score, PopArt Cards, Citadel Fights, School Missions)
  static Future<void> activateStudentAccount({
    required String name,
    required String ageGroup,
    required String avatar,
    String gender = 'female',
    bool isParentSwitched = false,
    bool isPureStudent = false,
  }) async {
    _isKidAccount = true;
    _currentWorldMode = AppWorldMode.student;
    currentWorldModeNotifier.value = AppWorldMode.student;
    if (isParentSwitched) {
      _isParentSwitched = true;
      _isPureKidAccount = false;
      _isPureStudentAccount = false;
    } else if (isPureStudent) {
      _isPureStudentAccount = true;
      _isPureKidAccount = false;
      _isParentSwitched = false;
    }
    _kidName = name.trim().isNotEmpty ? name.trim() : 'Student Explorer';
    _kidAgeGroup = ageGroup.isNotEmpty ? ageGroup : '9-12';
    _kidGender =
        (gender.toLowerCase().contains('boy') || gender.toLowerCase() == 'male')
            ? 'male'
            : 'female';
    _kidAvatar = avatar;
    isKidAccountNotifier.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAppWorldMode, 'student');
      await prefs.setBool(_keyIsKidAccount, true);
      await prefs.setBool(_keyIsPureKidAccount, false);
      await prefs.setBool(_keyIsPureStudentAccount, _isPureStudentAccount);
      await prefs.setBool(_keyIsParentSwitched, _isParentSwitched);
      await prefs.setString(_keyKidName, _kidName);
      await prefs.setString(_keyKidAgeGroup, _kidAgeGroup);
      await prefs.setString(_keyKidGender, _kidGender);
      await prefs.setString(_keyKidAvatar, _kidAvatar);

      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await prefs.setBool('is_kid_account_${user.id}', true);
        await SupaFlow.client
            .from('profile')
            .update({
              'account_type': _isPureStudentAccount ? 'pure_student' : 'student',
              'kid_name': _kidName,
              'kid_age_group': _kidAgeGroup,
              'gender': _kidGender,
              'kid_avatar': _kidAvatar,
            })
            .eq('user_id', user.id)
            .catchError((_) {});
      }
    } catch (e) {
      debugPrint('PocketKidsService: Error activating student account: $e');
    }
  }

  /// Switch directly between world modes for eligible accounts
  static Future<void> switchWorldMode(AppWorldMode mode) async {
    if (mode == AppWorldMode.adult && !canExitToAdultAccount) {
      return; // Blocked for pure kid / pure student accounts
    }
    _currentWorldMode = mode;
    currentWorldModeNotifier.value = mode;
    _isKidAccount = (mode != AppWorldMode.adult);
    isKidAccountNotifier.value = _isKidAccount;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAppWorldMode, mode.name);
      await prefs.setBool(_keyIsKidAccount, _isKidAccount);
    } catch (_) {}
  }

  /// Save updated Kid Profile details (name, avatar & gender)
  static Future<void> saveKidProfile({
    required String name,
    required String avatar,
    String? gender,
  }) async {
    _kidName = name.trim().isNotEmpty ? name.trim() : _kidName;
    _kidAvatar = avatar;
    if (gender != null && gender.isNotEmpty) {
      _kidGender = (gender.toLowerCase().contains('boy') ||
              gender.toLowerCase() == 'male')
          ? 'male'
          : 'female';
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyKidName, _kidName);
      await prefs.setString(_keyKidAvatar, _kidAvatar);
      await prefs.setString(_keyKidGender, _kidGender);

      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await SupaFlow.client
            .from('profile')
            .update({
              'kid_name': _kidName,
              'kid_avatar': _kidAvatar,
              'gender': _kidGender,
            })
            .eq('user_id', user.id)
            .catchError((_) {});
      }
    } catch (e) {
      debugPrint('PocketKidsService: Error saving kid profile: $e');
    }
  }

  /// Update kid profile wrapper
  static Future<void> updateProfile(
          {String? name, String? avatar, String? gender}) =>
      saveKidProfile(
          name: name ?? _kidName,
          avatar: avatar ?? _kidAvatar,
          gender: gender ?? _kidGender);

  /// Activate Adult Account Mode
  static Future<void> activateAdultAccount() async {
    _isKidAccount = false;
    _isParentSwitched = false;
    _currentWorldMode = AppWorldMode.adult;
    currentWorldModeNotifier.value = AppWorldMode.adult;
    isKidAccountNotifier.value = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAppWorldMode, 'adult');
      await prefs.setBool(_keyIsKidAccount, false);
      await prefs.setBool(_keyIsParentSwitched, false);

      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await prefs.setBool('is_kid_account_${user.id}', false);
        await SupaFlow.client
            .from('profile')
            .update({
              'account_type': 'adult',
            })
            .eq('user_id', user.id)
            .catchError((_) {});
      }
    } catch (e) {
      debugPrint('PocketKidsService: Error activating adult account: $e');
    }
  }

  /// Add stars to the kid's bank
  static Future<void> addStars(int amount) async {
    _kidStars += amount;
    kidStarsNotifier.value = _kidStars;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyKidStars, _kidStars);
    } catch (_) {}
  }

  /// Alias for addStars
  static Future<void> addKidStars(int amount) => addStars(amount);

  /// Record completion of a day game session
  static Future<void> completeDayGame(int day, int starsEarned) async {
    _completedDays[day] = starsEarned;
    await addStars(starsEarned);

    _lastCompletedDay = day;
    _lastCompletedDate = getTodayDateString();

    if (day >= _currentUnlockedDay && _currentUnlockedDay < 300) {
      _currentUnlockedDay = day + 1;
      kidDayNotifier.value = _currentUnlockedDay;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyKidCurrentDay, _currentUnlockedDay);
      await prefs.setInt(_keyKidLastCompletedDay, day);
      await prefs.setString(_keyKidLastCompletedDate, _lastCompletedDate!);
      final jsonMap = _completedDays.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString(_keyKidCompletedDays, jsonEncode(jsonMap));
    } catch (_) {}
  }

  /// Mark day as completed helper
  static Future<void> markDayCompleted(int day, [int stars = 3]) =>
      completeDayGame(day, stars);

  /// Check whether a specific day has been completed
  static bool isDayCompleted(int day) => _completedDays.containsKey(day);

  /// Total completed days count
  static int get completedDaysCount => _completedDays.length;

  /// 🎯 Track completion of sequential sub-games within a day (e.g. Day 1 Step 1..14)
  static final Map<String, bool> _completedDaySteps = {};

  static bool isDayStepCompleted(int day, int stepIndex) {
    final key = 'pm_kid_day_${day}_step_$stepIndex';
    return _completedDaySteps[key] ?? false;
  }

  static bool isDayStepUnlocked(int day, int stepIndex) {
    if (isAdminAccount) return true;
    if (stepIndex <= 1) return true;
    // Step N is unlocked if Step N-1 is completed
    return isDayStepCompleted(day, stepIndex - 1);
  }

  /// 🧒 Dynamic Step Count: 14 sequential interactive educational games per day!
  static int getTotalDailyStepsForDay(int day) {
    return 14;
  }

  static Future<void> markDayStepCompleted(int day, int stepIndex) async {
    final key = 'pm_kid_day_${day}_step_$stepIndex';
    _completedDaySteps[key] = true;
    await addKidsScore(15);
    await addStars(1);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, true);
    } catch (_) {}
  }

  /// 🛡️ Check if the Day Master Defense Card has already been claimed for this day
  static bool isDayCardClaimed(int day) {
    final key = 'pm_kid_day_${day}_card_claimed';
    return _completedDaySteps[key] ?? false;
  }

  /// Mark Day Master Defense Card claimed so it only awards once per day
  static Future<void> markDayCardClaimed(int day) async {
    final key = 'pm_kid_day_${day}_card_claimed';
    _completedDaySteps[key] = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, true);
    } catch (_) {}
  }


  // --- KIDS MATES & ROBOTS SYSTEM (90 AI BOTS & PEERS) ---

  static KidMateRequestStatus getMateRequestStatus(String kidId) {
    if (_friendIds.contains(kidId)) return KidMateRequestStatus.accepted;
    if (_sentRequestIds.contains(kidId)) return KidMateRequestStatus.sent;
    if (_receivedRequestIds.contains(kidId))
      return KidMateRequestStatus.received;
    return KidMateRequestStatus.none;
  }

  /// Strictly determines if an ID belongs to an allowed Kid Mate (Animal Buddy or Kid Peer)
  /// NEVER allows adult robots (Maya, Alex, Sophia, adult robot IDs) or adult entities.
  static bool isAllowedKidMateId(String id) {
    if (id.isEmpty) return false;
    if (id == 'mentor_animal_king_lion') return true;
    if (id.startsWith('kid_bot_')) return true;
    if (PocketKidsRobotsData.robotsAndHomies.any((m) => m.id == id))
      return true;
    // Explicitly reject any adult robots and adult IDs:
    final lower = id.toLowerCase();
    if (lower.startsWith('pocket_robot_') ||
        lower.startsWith('robot_') ||
        lower.startsWith('pocket_robo_') ||
        lower.startsWith('pocket_') ||
        lower == 'pocket' ||
        lower == 'maya' ||
        lower == 'alex' ||
        lower == 'sophia' ||
        lower == 'liam' ||
        lower == 'emma' ||
        lower == 'oliver' ||
        lower == 'noah') {
      return false;
    }
    return true;
  }

  static KidMate? getKidMateById(String kidId) {
    try {
      final found =
          PocketKidsRobotsData.robotsAndHomies.firstWhere((m) => m.id == kidId);
      final status = getMateRequestStatus(found.id);
      final fScore = getFriendshipScore(found.id);
      return found.copyWith(
        isFriend: status == KidMateRequestStatus.accepted,
        requestStatus: status,
        friendshipScore: fScore,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get kid mates / robots with friendship & request status applied
  /// filterTab: 0 = Discover (All 90 robots & peers), 1 = My Mates (accepted), 2 = Requests (sent + received)
  static List<KidMate> getKidMates({String query = '', int filterTab = 0}) {
    final all = PocketKidsRobotsData.robotsAndHomies.map((m) {
      final status = getMateRequestStatus(m.id);
      final fScore = getFriendshipScore(m.id);
      return m.copyWith(
        isFriend: status == KidMateRequestStatus.accepted,
        requestStatus: status,
        friendshipScore: fScore,
      );
    }).toList();

    List<KidMate> filtered;
    if (filterTab == 1) {
      filtered = all
          .where((m) => m.requestStatus == KidMateRequestStatus.accepted)
          .toList();
    } else if (filterTab == 2) {
      filtered = all
          .where((m) =>
              m.requestStatus == KidMateRequestStatus.received ||
              m.requestStatus == KidMateRequestStatus.sent)
          .toList();
    } else {
      filtered = all;
    }

    if (query.trim().isEmpty) return filtered;
    final q = query.trim().toLowerCase();
    return filtered.where((m) => m.name.toLowerCase().contains(q)).toList();
  }

  /// Expose discovery peers list
  static List<KidMate> get mates => getKidMates(filterTab: 0);

  /// Send a mate request to a kid or robot peer
  static Future<void> sendMateRequest(String kidId) async {
    _sentRequestIds.add(kidId);
    await _persistFriendshipState();

    // Kids Robot peers auto-accept requests cheerfully after a short delay
    final mate = getKidMateById(kidId);
    if (mate != null && mate.isRobot) {
      Future.delayed(const Duration(milliseconds: 1500), () async {
        await acceptMateRequest(kidId);
      });
    }
  }

  /// Cancel a pending sent request
  static Future<void> cancelMateRequest(String kidId) async {
    _sentRequestIds.remove(kidId);
    await _persistFriendshipState();
  }

  /// Accept an incoming mate request
  static Future<void> acceptMateRequest(String kidId) async {
    _receivedRequestIds.remove(kidId);
    _sentRequestIds.remove(kidId);
    _friendIds.add(kidId);
    await boostFriendship(kidId, 35);
    await _persistFriendshipState();
  }

  /// Reject an incoming mate request
  static Future<void> rejectMateRequest(String kidId) async {
    _receivedRequestIds.remove(kidId);
    _sentRequestIds.remove(kidId);
    await _persistFriendshipState();
  }

  /// Remove a friend from mates
  static Future<void> removeMate(String kidId) async {
    _friendIds.remove(kidId);
    await _persistFriendshipState();
  }

  /// Toggle mate status
  static Future<void> toggleMate(String mateId) async {
    if (_friendIds.contains(mateId)) {
      await removeMate(mateId);
    } else {
      await acceptMateRequest(mateId);
    }
  }

  static Future<void> _persistFriendshipState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_keyKidFriendIds, _friendIds.toList());
      await prefs.setStringList(_keyKidSentRequests, _sentRequestIds.toList());
      await prefs.setStringList(
          _keyKidReceivedRequests, _receivedRequestIds.toList());
    } catch (_) {}
  }

  static bool isMate(String mateId) => _friendIds.contains(mateId);

  // --- KIDS MATES MESSAGING & TALK SYSTEM (100% Separate Gamified Chat) ---

  static final Map<String, List<KidMessage>> _messagesByMate = {};

  /// Get messages with a specific kid mate, initializing with friendly welcome greeting
  static List<KidMessage> getMessagesForMate(String mateId,
      {String? mateName, String? mateAvatar}) {
    if (!_messagesByMate.containsKey(mateId) ||
        _messagesByMate[mateId]!.isEmpty) {
      final name = mateName ?? 'Mate';
      final avatar = mateAvatar ?? '🌟';
      _messagesByMate[mateId] = [
        KidMessage(
          id: '${mateId}_welcome',
          senderId: mateId,
          senderName: name,
          senderAvatar: avatar,
          text:
              "Hello Mate! 🌟 Let's practice English together! Tap the speaker to hear me!",
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isFromMe: false,
        ),
      ];
    }
    return List.unmodifiable(_messagesByMate[mateId]!);
  }

  /// Send message to a mate
  static Future<KidMessage> sendMessageToMate({
    required String mateId,
    required String text,
    bool isStarGift = false,
  }) async {
    final myMsg = KidMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: _kidName,
      senderAvatar: _kidAvatar,
      text: text,
      timestamp: DateTime.now(),
      isFromMe: true,
      isStarGift: isStarGift,
    );

    if (!_messagesByMate.containsKey(mateId)) {
      _messagesByMate[mateId] = [];
    }
    _messagesByMate[mateId]!.add(myMsg);

    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(_messagesByMate[mateId]!.map((m) => m.toJson()).toList());
      await prefs.setString('pm_kid_messages_$mateId', encoded);
      await boostFriendship(mateId, isStarGift ? 10 : 3);
    } catch (_) {}

    return myMsg;
  }

  /// Automatically generate a friendly kid reply for practice
  static Future<KidMessage?> generateAutoMateReply({
    required String mateId,
    required String mateName,
    required String mateAvatar,
  }) async {
    final replies = [
      "High five mate! ✋ You are doing awesome!",
      "I love practicing English with you! 🎈 Let's conquer the trail!",
      "Keep shining like a star! ⭐ What day are you on?",
      "Good job! Remember, practice makes perfect! 🚀",
      "Thank you mate! You're a true champion! 🏆",
    ];
    final randomReply = replies[math.Random().nextInt(replies.length)];

    final replyMsg = KidMessage(
      id: 'reply_${DateTime.now().millisecondsSinceEpoch}',
      senderId: mateId,
      senderName: mateName,
      senderAvatar: mateAvatar,
      text: randomReply,
      timestamp: DateTime.now(),
      isFromMe: false,
    );

    if (!_messagesByMate.containsKey(mateId)) {
      _messagesByMate[mateId] = [];
    }
    _messagesByMate[mateId]!.add(replyMsg);

    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(_messagesByMate[mateId]!.map((m) => m.toJson()).toList());
      await prefs.setString('pm_kid_messages_$mateId', encoded);
    } catch (_) {}

    return replyMsg;
  }

  // --- AUTOMATED SPOKEN ENGLISH DEFENSE CHALLENGES (Helping Mentality) ---

  /// Returns 3 automated Spoken English defense challenges for any kid's level.
  /// Kids do NOT need to write manual questions! They are populated systematically!
  static List<KidDefenseChallenge> getDefenseChallengesForDay(int day) {
    if (day <= 15) {
      return const [
        KidDefenseChallenge(
          prompt:
              "Your friend says: 'Good morning!' How do you reply with kindness?",
          spokenText: "Good morning! How do you reply with kindness?",
          helperMascot: "☀️",
          options: [
            "Good morning! ☀️",
            "Good night 🌙",
            "Goodbye 👋",
            "No thanks 🙅"
          ],
          correctIndex: 0,
          cheerMessage: "Super! A warm morning greeting makes everyone happy!",
        ),
        KidDefenseChallenge(
          prompt:
              "Help the puppy find its sound! What does a friendly dog say?",
          spokenText:
              "Help the puppy find its sound! What does a friendly dog say?",
          helperMascot: "🐶",
          options: ["Woof Woof! 🐶", "Meow 🐱", "Quack 🦆", "Moo 🐮"],
          correctIndex: 0,
          cheerMessage: "Woof woof! Puppy is wagging its tail with joy!",
        ),
        KidDefenseChallenge(
          prompt:
              "Someone shared a delicious cookie with you. What do you say?",
          spokenText:
              "Someone shared a delicious cookie with you. What do you say?",
          helperMascot: "🍪",
          options: [
            "Thank you very much! 💖",
            "Go away! ❌",
            "Give me more! 😠",
            "Nothing 😶"
          ],
          correctIndex: 0,
          cheerMessage:
              "Awesome manners! Saying 'Thank you' shows a big heart!",
        ),
      ];
    } else if (day <= 30) {
      return const [
        KidDefenseChallenge(
          prompt: "Your mate is carrying heavy books. How do you offer help?",
          spokenText:
              "Your mate is carrying heavy books. How do you offer help?",
          helperMascot: "📚",
          options: [
            "Let me help you! 🤝",
            "Run away fast! 🏃",
            "Laugh loudly 😄",
            "Ignore them 🙈"
          ],
          correctIndex: 0,
          cheerMessage: "True friendship! Helping hands make light work!",
        ),
        KidDefenseChallenge(
          prompt: "Can you name the brave King of the Safari jungle?",
          spokenText: "Can you name the brave King of the Safari jungle?",
          helperMascot: "🦁",
          options: ["Lion 🦁", "Penguin 🐧", "Goldfish 🐟", "Butterfly 🦋"],
          correctIndex: 0,
          cheerMessage: "Roar! Lion is proud of your great vocabulary!",
        ),
        KidDefenseChallenge(
          prompt: "How do you introduce yourself politely to a new friend?",
          spokenText: "How do you introduce yourself politely to a new friend?",
          helperMascot: "👋",
          options: [
            "Hello, my name is your mate! 👋",
            "I am leaving 🚪",
            "Go to sleep 💤",
            "I do not care 🚫"
          ],
          correctIndex: 0,
          cheerMessage: "Wonderful introduction! You made a new best mate!",
        ),
      ];
    } else if (day <= 50) {
      return const [
        KidDefenseChallenge(
          prompt:
              "A friend is feeling sad on the playground. What is kind to say?",
          spokenText:
              "A friend is feeling sad on the playground. What is kind to say?",
          helperMascot: "🤗",
          options: [
            "Are you okay? I am here for you! 🤗",
            "I do not care 😒",
            "Go home now 🏠",
            "Walk away 👀"
          ],
          correctIndex: 0,
          cheerMessage:
              "Pure empathy! You bring sunshine to everyone around you!",
        ),
        KidDefenseChallenge(
          prompt: "How do you politely ask to borrow a colored drawing pencil?",
          spokenText:
              "How do you politely ask to borrow a colored drawing pencil?",
          helperMascot: "✏️",
          options: [
            "May I please borrow this pencil? ✏️",
            "Give it now! 😠",
            "Mine! 💥",
            "Drop it! ✋"
          ],
          correctIndex: 0,
          cheerMessage: "Polite speech unlocks every door in the world!",
        ),
        KidDefenseChallenge(
          prompt: "Look up at the beautiful clear sky! What color is it?",
          spokenText: "Look up at the beautiful clear sky! What color is it?",
          helperMascot: "🌈",
          options: ["Blue sky! 🔵", "Black ⚫", "Brown 🟤", "Gray 🌫️"],
          correctIndex: 0,
          cheerMessage: "Blue like the sparkling sea! Brilliant!",
        ),
      ];
    } else if (day <= 75) {
      return const [
        KidDefenseChallenge(
          prompt:
              "You bumped into someone by mistake while running. What do you say?",
          spokenText:
              "You bumped into someone by mistake while running. What do you say?",
          helperMascot: "🙏",
          options: [
            "I am so sorry, are you okay? 🙏",
            "It is your fault! 😠",
            "Run away! 🏃",
            "Do not care 🤷"
          ],
          correctIndex: 0,
          cheerMessage: "Apologizing with sincerity is a superpower!",
        ),
        KidDefenseChallenge(
          prompt: "Spell the word for our warm, golden sunshine in the sky!",
          spokenText:
              "Spell the word for our warm, golden sunshine in the sky!",
          helperMascot: "☀️",
          options: [
            "S - U - N ☀️",
            "M - O - O - N 🌙",
            "C - A - T 🐱",
            "B - A - L - L ⚽"
          ],
          correctIndex: 0,
          cheerMessage: "S - U - N! You shine bright like the sun!",
        ),
        KidDefenseChallenge(
          prompt: "How do you invite a classmate to play with your group?",
          spokenText: "How do you invite a classmate to play with your group?",
          helperMascot: "🎈",
          options: [
            "Would you like to play together? 🎈",
            "No playing! 🛑",
            "Stay alone 🚶",
            "Go away 🙅"
          ],
          correctIndex: 0,
          cheerMessage: "Inclusion and teamwork make games magical!",
        ),
      ];
    } else {
      return const [
        KidDefenseChallenge(
          prompt:
              "The Grand Castle King asks: 'What makes you a true English Champion?'",
          spokenText:
              "The Grand Castle King asks: What makes you a true English Champion?",
          helperMascot: "👑",
          options: [
            "Kindness, Daily Practice & Helping Mates! 🌟",
            "Being loud and angry 😡",
            "Breaking rules 🔨",
            "Giving up 😢"
          ],
          correctIndex: 0,
          cheerMessage:
              "Royal decree: You are crowned an English Grand Champion!",
        ),
        KidDefenseChallenge(
          prompt: "When working on a big adventure challenge with your team:",
          spokenText:
              "When working on a big adventure challenge with your team:",
          helperMascot: "🏰",
          options: [
            "We listen and support each other! 🤝",
            "Only one person matters 👤",
            "We argue 🗣️",
            "Quit immediately 🏳️"
          ],
          correctIndex: 0,
          cheerMessage: "United together, nothing is impossible!",
        ),
        KidDefenseChallenge(
          prompt:
              "You conquered the 100-Day Mountain Summit! What is your victory cheer?",
          spokenText:
              "You conquered the 100-Day Mountain Summit! What is your victory cheer?",
          helperMascot: "🎉",
          options: [
            "We did it together! Hooray! 🎉",
            "I am tired 🥱",
            "Not happy 🙁",
            "Goodbye forever ⛔"
          ],
          correctIndex: 0,
          cheerMessage: "Hooray! The entire universe celebrates your fluency!",
        ),
      ];
    }
  }

  // --- SYNC & VERIFY ACCOUNT TYPE ON LOGIN (Audio Directive 1) ---

  /// Verifies whether the authenticated user is registered as a pure Student / Kid or Adult.
  /// If Student: activates student mode with isPureKid: true and returns true (direct to student home).
  /// If Adult: activates adult mode and returns false (direct to adult home).
  static Future<bool> syncAndVerifyUserAccountType(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localIsKid = prefs.getBool('is_kid_account_$userId');
      final localPure = prefs.getBool(_keyIsPureKidAccount) ?? false;

      // Check remote profile
      final profile = await SupaFlow.client
          .from('profile')
          .select('account_type, kid_name, kid_avatar, kid_age_group')
          .eq('user_id', userId)
          .maybeSingle();

      if (profile != null) {
        final accType =
            profile['account_type']?.toString().toLowerCase().trim();
        if (accType == 'pure_kid' || accType == 'kid' || accType == 'student') {
          final kName = profile['kid_name']?.toString() ?? 'Young Scholar';
          final kAvatar = profile['kid_avatar']?.toString() ?? '🦁';
          final kAge = profile['kid_age_group']?.toString() ?? '6-8';
          await activateKidAccount(
            name: kName,
            ageGroup: kAge,
            avatar: kAvatar,
            isPureKid: accType == 'pure_kid' ||
                accType == 'student' ||
                accType == 'kid',
          );
          return true;
        } else if (accType == 'adult') {
          await activateAdultAccount();
          return false;
        }
      }

      if (localIsKid == true || localPure == true) {
        await activateKidAccount(
          name: _kidName,
          ageGroup: _kidAgeGroup,
          avatar: _kidAvatar,
          isPureKid: localPure,
        );
        return true;
      }
    } catch (e) {
      debugPrint('PocketKidsService: Error verifying account type: $e');
    }
    return _isKidAccount;
  }

  // --- 🦁 THE KING LION SYSTEM (Audio Directive 6 & 7) ---

  static const String lionId = 'pocket_lion';
  static const String lionName = 'Lion';
  static const String lionAvatar = '🦁';
  static const String lionRole = 'King of the Animal Kingdom';
  static const String defaultLionWelcome =
      'Roar! Welcome to the Animal Kingdom, young scholar! 🦁 I am the King of the Animal Kingdom. Practice your English daily, be brave, and climb the mountain trail. If you encounter any problems in the wild forest, send a Lion Report to me!';

  static const String _kLionChatKey = 'pm_lion_chat_messages';
  static const String _kLionReportsKey = 'pm_student_lion_reports';

  /// Get chat history with The Lion (King of the Kingdom)
  static Future<List<KidMessage>> getLionChatMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLionChatKey);
      if (raw == null || raw.isEmpty) {
        final initial = [
          KidMessage(
            id: 'lion_welcome',
            senderId: lionId,
            senderName: lionName,
            senderAvatar: lionAvatar,
            text: defaultLionWelcome,
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            isFromMe: false,
          ),
        ];
        await prefs.setString(
            _kLionChatKey, jsonEncode(initial.map((m) => m.toJson()).toList()));
        return initial;
      }
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => KidMessage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      return [
        KidMessage(
          id: 'lion_welcome',
          senderId: lionId,
          senderName: lionName,
          senderAvatar: lionAvatar,
          text: defaultLionWelcome,
          timestamp: DateTime.now(),
          isFromMe: false,
        ),
      ];
    }
  }

  /// Send message to King Lion
  static Future<KidMessage> sendLionChatMessage(String text) async {
    final myMsg = KidMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'me',
      senderName: _kidName,
      senderAvatar: _kidAvatar,
      text: text,
      timestamp: DateTime.now(),
      isFromMe: true,
    );

    final msgs = await getLionChatMessages();
    final updated = List<KidMessage>.from(msgs)..add(myMsg);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kLionChatKey, jsonEncode(updated.map((m) => m.toJson()).toList()));

    // Royal encouraging Lion decree reply
    Future.delayed(const Duration(milliseconds: 1500), () async {
      final replies = [
        "Roar! The King hears you! Stay brave and keep practicing English! 🦁👑",
        "A true champion practices every single day! Keep conquering the mountain! 🏔️⭐",
        "The Animal Kingdom is proud of your progress! High five! ✋🐾",
        "Always help your mates in the kingdom. Kindness is true strength! 🤝✨",
        "Roar! Conquer Day 100 and you shall face the royal challenge! 🏆🦁",
      ];
      final replyText = replies[math.Random().nextInt(replies.length)];
      final lionReply = KidMessage(
        id: 'lion_${DateTime.now().millisecondsSinceEpoch}',
        senderId: lionId,
        senderName: lionName,
        senderAvatar: lionAvatar,
        text: replyText,
        timestamp: DateTime.now(),
        isFromMe: false,
      );
      final withReply = List<KidMessage>.from(updated)..add(lionReply);
      await prefs.setString(
          _kLionChatKey, jsonEncode(withReply.map((m) => m.toJson()).toList()));
    });

    return myMsg;
  }

  /// Submit a Lion Report (Students reporting forest or app issues to the King)
  static Future<void> submitLionReport({
    required String subject,
    required String description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final report = {
        'id': 'lion_rep_${DateTime.now().millisecondsSinceEpoch}',
        'student_id': SupaFlow.client.auth.currentUser?.id ?? 'local_student',
        'student_name': _kidName,
        'student_avatar': _kidAvatar,
        'subject': subject,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
        'admin_reply': null,
      };

      final existingRaw = prefs.getString(_kLionReportsKey);
      List<dynamic> list = existingRaw != null ? jsonDecode(existingRaw) : [];
      list.insert(0, report);
      await prefs.setString(_kLionReportsKey, jsonEncode(list));

      // Attempt remote sync to Supabase reports
      try {
        final uid = SupaFlow.client.auth.currentUser?.id;
        if (uid != null) {
          await SupaFlow.client.from('reports').insert({
            'reporter_id': uid,
            'content_type': 'student_lion_report',
            'reason': subject,
            'additional_info': jsonEncode(report),
            'status': 'pending',
          });
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('Error submitting Lion Report: $e');
    }
  }

  /// Get student's Lion reports
  static Future<List<Map<String, dynamic>>> getStudentLionReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLionReportsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Admin Desk: Get all Lion reports for Master Admin (musabthonippadam@gmail.com)
  static Future<List<Map<String, dynamic>>> getAdminLionReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLionReportsKey);
      List<Map<String, dynamic>> list = [];
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        list = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Admin Desk: Reply to student Lion report
  static Future<void> replyToLionReport(
      String reportId, String replyText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLionReportsKey);
      if (raw != null && raw.isNotEmpty) {
        final list = (jsonDecode(raw) as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        for (var r in list) {
          if (r['id'] == reportId) {
            r['admin_reply'] = replyText;
            r['status'] = 'resolved';
          }
        }
        await prefs.setString(_kLionReportsKey, jsonEncode(list));
      }
    } catch (_) {}
  }

  // --- 👥 POCKET GANG (STUDY GROUPS & TEAMS) (Audio Directive 5 & 6) ---

  static final List<PocketGang> _defaultGangs = [
    PocketGang(
      id: 'gang_1',
      name: 'Lion Pride Scholars',
      emoji: '🦁',
      description:
          'Daily Spoken English drills, courage building, and Mountain Trail racing!',
      membersCount: 24,
      memberAvatars: ['🦁', '🐯', '🐼', '🦊'],
      isJoined: true,
    ),
    PocketGang(
      id: 'gang_2',
      name: 'Summit Raptors',
      emoji: '🦖',
      description: 'Vocabulary masters learning 10 new words every afternoon!',
      membersCount: 18,
      memberAvatars: ['🦖', '🦄', '🐰', '🐶'],
      isJoined: false,
    ),
    PocketGang(
      id: 'gang_3',
      name: 'Forest Explorers',
      emoji: '🌳',
      description:
          'Study group solving Citadel defense questions and grammar puzzles together.',
      membersCount: 31,
      memberAvatars: ['🐻', '🐨', '🐬', '🐱'],
      isJoined: false,
    ),
  ];

  static const String _kGangsKey = 'pm_student_pocket_gangs';

  static Future<List<PocketGang>> getPocketGangs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kGangsKey);
      if (raw == null || raw.isEmpty) {
        return _defaultGangs;
      }
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) {
        final m = Map<String, dynamic>.from(e);
        return PocketGang(
          id: m['id'],
          name: m['name'],
          emoji: m['emoji'],
          description: m['description'],
          membersCount: m['membersCount'] ?? 1,
          memberAvatars: List<String>.from(m['memberAvatars'] ?? ['🦁']),
          isJoined: m['isJoined'] ?? false,
        );
      }).toList();
    } catch (_) {
      return _defaultGangs;
    }
  }

  static Future<void> createPocketGang({
    required String name,
    required String emoji,
    required String description,
  }) async {
    final gangs = await getPocketGangs();
    final newGang = PocketGang(
      id: 'gang_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      description: description,
      membersCount: 1,
      memberAvatars: [_kidAvatar],
      isJoined: true,
    );
    final updated = List<PocketGang>.from(gangs)..insert(0, newGang);
    final prefs = await SharedPreferences.getInstance();
    final mapped = updated
        .map((g) => {
              'id': g.id,
              'name': g.name,
              'emoji': g.emoji,
              'description': g.description,
              'membersCount': g.membersCount,
              'memberAvatars': g.memberAvatars,
              'isJoined': g.isJoined,
            })
        .toList();
    await prefs.setString(_kGangsKey, jsonEncode(mapped));
  }

  static Future<void> toggleJoinGang(String gangId) async {
    final gangs = await getPocketGangs();
    final updated = gangs.map((g) {
      if (g.id == gangId) {
        final joined = !g.isJoined;
        return g.copyWith(
          isJoined: joined,
          membersCount: joined
              ? g.membersCount + 1
              : (g.membersCount > 1 ? g.membersCount - 1 : 1),
        );
      }
      return g;
    }).toList();
    final prefs = await SharedPreferences.getInstance();
    final mapped = updated
        .map((g) => {
              'id': g.id,
              'name': g.name,
              'emoji': g.emoji,
              'description': g.description,
              'membersCount': g.membersCount,
              'memberAvatars': g.memberAvatars,
              'isJoined': g.isJoined,
            })
        .toList();
    await prefs.setString(_kGangsKey, jsonEncode(mapped));
  }

  // --- 🐾 STUDENT VIBES (100 ANIMAL STORIES & TIPS) (Audio Directive 5 & 6) ---

  static final List<StudentVibe> _defaultVibes = [
    const StudentVibe(
      id: 'vibe_1',
      authorName: 'King Lion 🦁',
      authorAvatar: '🦁',
      dayLevel: 100,
      title: 'Royal Word of the Day: "Perseverance"',
      message:
          'Perseverance means never giving up even when the mountain path is steep! Keep climbing! 👑',
      tag: '#KingdomDecree',
      likes: 84,
    ),
    const StudentVibe(
      id: 'vibe_2',
      authorName: 'Sparky Tiger 🐯',
      authorAvatar: '🐯',
      dayLevel: 14,
      title: 'Pronunciation Tip: "Th" Sound',
      message:
          'Place your tongue gently between your teeth to say "Thank you" and "Think"! Try it now! 👅✨',
      tag: '#PhonicsTip',
      likes: 62,
    ),
    const StudentVibe(
      id: 'vibe_3',
      authorName: 'Finny Fox 🦊',
      authorAvatar: '🦊',
      dayLevel: 35,
      title: 'Friendly Manners Win Hearts',
      message:
          'Saying "May I please borrow this?" makes everyone smile. Good speech opens all castle doors! 🚪🗝️',
      tag: '#Kindness',
      likes: 47,
    ),
    const StudentVibe(
      id: 'vibe_4',
      authorName: 'Pandy Panda 🐼',
      authorAvatar: '🐼',
      dayLevel: 4,
      title: 'Story Time: The Bamboo Forest',
      message:
          'Green bamboo bends in the wind but never breaks. Practice English a little every day to stay strong! 🎋',
      tag: '#DailyStory',
      likes: 55,
    ),
    const StudentVibe(
      id: 'vibe_5',
      authorName: 'Nova Eagle 🦅',
      authorAvatar: '🦅',
      dayLevel: 75,
      title: 'Idiom of the Day: "Spread Your Wings"',
      message:
          'It means trying something new with confidence! Speak English aloud and fly high! 🚀',
      tag: '#IdiomPower',
      likes: 71,
    ),
  ];

  static const String _kVibesKey = 'pm_student_vibes_list';
  static const String _kThoughtsKey = 'pm_student_thoughts_list';

  static Future<List<StudentVibe>> getStudentVibes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kVibesKey);
      if (raw == null || raw.isEmpty) {
        return _defaultVibes;
      }
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) {
        final m = Map<String, dynamic>.from(e);
        return StudentVibe(
          id: m['id'] ?? 'vibe_${DateTime.now().millisecondsSinceEpoch}',
          authorName: m['authorName'] ?? 'Student Mate',
          authorAvatar: m['authorAvatar'] ?? '🦁',
          dayLevel: m['dayLevel'] ?? 1,
          title: m['title'] ?? '',
          message: m['message'] ?? '',
          tag: m['tag'] ?? '#StudentVoice',
          likes: m['likes'] ?? 0,
          isLiked: m['isLiked'] ?? false,
        );
      }).toList();
    } catch (_) {
      return _defaultVibes;
    }
  }

  static Future<void> addStudentVibe({
    required String title,
    required String message,
    String tag = '#StudentVoice',
  }) async {
    final currentList = await getStudentVibes();
    final newVibe = StudentVibe(
      id: 'vibe_${DateTime.now().millisecondsSinceEpoch}',
      authorName: _kidName,
      authorAvatar: _kidAvatar,
      dayLevel: _currentUnlockedDay,
      title: title,
      message: message,
      tag: tag,
      likes: 1,
      isLiked: true,
    );
    final updated = [newVibe, ...currentList];
    final prefs = await SharedPreferences.getInstance();
    final mapped = updated
        .map((v) => {
              'id': v.id,
              'authorName': v.authorName,
              'authorAvatar': v.authorAvatar,
              'dayLevel': v.dayLevel,
              'title': v.title,
              'message': v.message,
              'tag': v.tag,
              'likes': v.likes,
              'isLiked': v.isLiked,
            })
        .toList();
    await prefs.setString(_kVibesKey, jsonEncode(mapped));
  }

  static Future<List<Map<String, dynamic>>> getStudentThoughts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kThoughtsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (_) {}
    return [
      {
        'id': 'thought_1',
        'authorName': 'King Lion 👑 🦁',
        'authorAvatar': '🦁',
        'day': 100,
        'thought':
            'Every champion was once a beginner who refused to quit. Practice 5 sentences today!',
        'likes': 142,
        'comments': 18,
        'time': 'Just now',
      },
      {
        'id': 'thought_2',
        'authorName': 'Cub Leo 🦁',
        'authorAvatar': '🦁',
        'day': 12,
        'thought':
            'Today I learned the difference between "their", "there", and "they\'re"! English is awesome!',
        'likes': 28,
        'comments': 4,
        'time': '2h ago',
      },
      {
        'id': 'thought_3',
        'authorName': 'Bella Bunny 🐰',
        'authorAvatar': '🐰',
        'day': 8,
        'thought':
            'I read an English storybook to my little brother today. He loved the pictures!',
        'likes': 35,
        'comments': 6,
        'time': '5h ago',
      },
    ];
  }

  static Future<void> addStudentThought(String text) async {
    final list = await getStudentThoughts();
    final item = {
      'id': 'thought_${DateTime.now().millisecondsSinceEpoch}',
      'authorName': _kidName,
      'authorAvatar': _kidAvatar,
      'day': _currentUnlockedDay,
      'thought': text,
      'likes': 1,
      'comments': 0,
      'time': 'Just now',
    };
    final updated = [item, ...list];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThoughtsKey, jsonEncode(updated));
  }

  // --- 🛡️ CUSTOMIZABLE DEFENSE CHALLENGES (Audio Directive 7) ---

  /// Students can view and customize their 3-layer defense questions
  static Future<void> saveCustomDefense(
      int day, List<KidDefenseChallenge> customList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mapped = customList
          .map((c) => {
                'prompt': c.prompt,
                'spokenText': c.spokenText,
                'helperMascot': c.helperMascot,
                'options': c.options,
                'correctIndex': c.correctIndex,
                'cheerMessage': c.cheerMessage,
              })
          .toList();
      await prefs.setString('pm_custom_defense_$day', jsonEncode(mapped));
    } catch (_) {}
  }

  static Future<List<KidDefenseChallenge>> getEffectiveDefenseForDay(
      int day) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('pm_custom_defense_$day');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        return decoded.map((e) {
          final m = Map<String, dynamic>.from(e);
          return KidDefenseChallenge(
            prompt: m['prompt'],
            spokenText: m['spokenText'],
            helperMascot: m['helperMascot'],
            options: List<String>.from(m['options']),
            correctIndex: m['correctIndex'] ?? 0,
            cheerMessage: m['cheerMessage'],
          );
        }).toList();
      }
    } catch (_) {}
    return getDefenseChallengesForDay(day);
  }
}
