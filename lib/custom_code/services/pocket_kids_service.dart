import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_robots_data.dart';

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

  const KidMate({
    required this.id,
    required this.name,
    required this.avatar,
    required this.ageGroup,
    required this.dayLevel,
    required this.stars,
    this.isFriend = false,
    this.isRobot = false,
    this.requestStatus = KidMateRequestStatus.none,
  });

  KidMate copyWith({
    bool? isFriend,
    KidMateRequestStatus? requestStatus,
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

/// 🧸 Service for managing Kids vs Adult account separation,
/// Kids profile state, 100-Day learning journey, Avatar Homes, and Kids Mates.
class PocketKidsService {
  static const String _keyIsKidAccount = 'pm_is_kid_account';
  static const String _keyKidName = 'pm_kid_name';
  static const String _keyKidAgeGroup = 'pm_kid_age_group';
  static const String _keyKidAvatar = 'pm_kid_avatar';
  static const String _keyKidStars = 'pm_kid_stars';
  static const String _keyKidCurrentDay = 'pm_kid_current_day';
  static const String _keyKidCompletedDays = 'pm_kid_completed_days';
  static const String _keyKidFriendIds = 'pm_kid_friend_ids';
  static const String _keyKidSentRequests = 'pm_kid_sent_requests';
  static const String _keyKidReceivedRequests = 'pm_kid_received_requests';

  static final ValueNotifier<bool> isKidAccountNotifier = ValueNotifier<bool>(false);
  static final ValueNotifier<int> kidStarsNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<int> kidDayNotifier = ValueNotifier<int>(1);
  static bool _initialized = false;

  static bool _isKidAccount = false;
  static String _kidName = 'Little Explorer';
  static String _kidAgeGroup = '4-6';
  static String _kidAvatar = '🦁';
  static int _kidStars = 0;
  static int _currentUnlockedDay = 1;
  static final Map<int, int> _completedDays = {}; // day -> stars earned (1-3)
  static final Set<String> _friendIds = {};
  static final Set<String> _sentRequestIds = {};
  static final Set<String> _receivedRequestIds = {};

  static bool get isKidAccount => _isKidAccount;
  static String get kidName => _kidName;
  static String get kidAgeGroup => _kidAgeGroup;
  static String get kidAvatar => _kidAvatar;
  static int get kidStars => _kidStars;
  static int get currentUnlockedDay => _currentUnlockedDay;
  static Map<int, int> get completedDays => Map.unmodifiable(_completedDays);

  /// 🎯 Pocket Score calculation for Kids Target Page
  static int get pocketScore => (_kidStars * 15) + (_completedDays.length * 100);

  /// 🏆 Day 100 Certificate Unlock Status
  static bool get isCertificateUnlocked => _completedDays.containsKey(100) || _currentUnlockedDay >= 100;

  /// 🏰 Exact Avatar Houses matching the Adult 100-Day House System
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
      unlockedAtDay: 21,
      themeColor: Color(0xFFA855F7),
    ),
    KidsHouse(
      tier: 4,
      title: 'Imperial Manor',
      emoji: '🏛️',
      description: 'Grand royal manor with golden pillars and marble!',
      unlockedAtDay: 46,
      themeColor: Color(0xFFF59E0B),
    ),
    KidsHouse(
      tier: 5,
      title: 'Cyber Citadel',
      emoji: '💎',
      description: 'Futuristic crystal citadel shining with neon stars!',
      unlockedAtDay: 71,
      themeColor: Color(0xFFEC4899),
    ),
    KidsHouse(
      tier: 6,
      title: 'Sovereign Palace',
      emoji: '👑',
      description: 'Supreme 100-Day Champion Palace of the World!',
      unlockedAtDay: 90,
      themeColor: Color(0xFFFFD700),
    ),
  ];

  /// Get the kid's currently unlocked house based on their completed days
  static KidsHouse get currentHouse {
    int maxCompleted = 1;
    for (final day in _completedDays.keys) {
      if (day > maxCompleted) maxCompleted = day;
    }
    final effectiveDay = maxCompleted > _currentUnlockedDay ? maxCompleted : _currentUnlockedDay;
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
      _kidName = prefs.getString(_keyKidName) ?? 'Little Explorer';
      _kidAgeGroup = prefs.getString(_keyKidAgeGroup) ?? '4-6';
      _kidAvatar = prefs.getString(_keyKidAvatar) ?? '🦁';
      _kidStars = prefs.getInt(_keyKidStars) ?? 0;
      _currentUnlockedDay = prefs.getInt(_keyKidCurrentDay) ?? 1;

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
        _friendIds.addAll(savedFriends);
      }

      final savedSent = prefs.getStringList(_keyKidSentRequests);
      if (savedSent != null) {
        _sentRequestIds.clear();
        _sentRequestIds.addAll(savedSent);
      }

      final savedReceived = prefs.getStringList(_keyKidReceivedRequests);
      if (savedReceived != null) {
        _receivedRequestIds.clear();
        _receivedRequestIds.addAll(savedReceived);
      } else if (_receivedRequestIds.isEmpty && _friendIds.isEmpty) {
        // Friendly welcome requests from AI kid peers so children can experience accepting requests!
        _receivedRequestIds.addAll(['kid_bot_1', 'kid_bot_2']);
      }

      isKidAccountNotifier.value = _isKidAccount;
      kidStarsNotifier.value = _kidStars;
      kidDayNotifier.value = _currentUnlockedDay;
      _initialized = true;
    } catch (e) {
      debugPrint('PocketKidsService: Error initializing: $e');
    }
  }

  /// Activate Kids Account Mode and save profile
  static Future<void> activateKidAccount({
    required String name,
    required String ageGroup,
    required String avatar,
  }) async {
    _isKidAccount = true;
    _kidName = name.trim().isNotEmpty ? name.trim() : 'Little Explorer';
    _kidAgeGroup = ageGroup;
    _kidAvatar = avatar;
    isKidAccountNotifier.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsKidAccount, true);
      await prefs.setString(_keyKidName, _kidName);
      await prefs.setString(_keyKidAgeGroup, _kidAgeGroup);
      await prefs.setString(_keyKidAvatar, _kidAvatar);

      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await prefs.setBool('is_kid_account_${user.id}', true);
        await SupaFlow.client.from('profile').update({
          'account_type': 'kid',
          'kid_name': _kidName,
          'kid_age_group': _kidAgeGroup,
          'kid_avatar': _kidAvatar,
        }).eq('user_id', user.id).catchError((_) {});
      }
    } catch (e) {
      debugPrint('PocketKidsService: Error activating kid account: $e');
    }
  }

  /// Save updated Kid Profile details (name & avatar)
  static Future<void> saveKidProfile({
    required String name,
    required String avatar,
  }) async {
    _kidName = name.trim().isNotEmpty ? name.trim() : _kidName;
    _kidAvatar = avatar;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyKidName, _kidName);
      await prefs.setString(_keyKidAvatar, _kidAvatar);

      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await SupaFlow.client.from('profile').update({
          'kid_name': _kidName,
          'kid_avatar': _kidAvatar,
        }).eq('user_id', user.id).catchError((_) {});
      }
    } catch (e) {
      debugPrint('PocketKidsService: Error saving kid profile: $e');
    }
  }

  /// Activate Adult Account Mode
  static Future<void> activateAdultAccount() async {
    _isKidAccount = false;
    isKidAccountNotifier.value = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsKidAccount, false);

      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        await prefs.setBool('is_kid_account_${user.id}', false);
        await SupaFlow.client.from('profile').update({
          'account_type': 'adult',
        }).eq('user_id', user.id).catchError((_) {});
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

  /// Record completion of a day game session
  static Future<void> completeDayGame(int day, int starsEarned) async {
    _completedDays[day] = starsEarned;
    await addStars(starsEarned);

    if (day >= _currentUnlockedDay && _currentUnlockedDay < 100) {
      _currentUnlockedDay = day + 1;
      kidDayNotifier.value = _currentUnlockedDay;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyKidCurrentDay, _currentUnlockedDay);
      final jsonMap = _completedDays.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString(_keyKidCompletedDays, jsonEncode(jsonMap));
    } catch (_) {}
  }

  // --- KIDS MATES & ROBOTS SYSTEM (90 AI BOTS & PEERS) ---

  static KidMateRequestStatus getMateRequestStatus(String kidId) {
    if (_friendIds.contains(kidId)) return KidMateRequestStatus.accepted;
    if (_sentRequestIds.contains(kidId)) return KidMateRequestStatus.sent;
    if (_receivedRequestIds.contains(kidId)) return KidMateRequestStatus.received;
    return KidMateRequestStatus.none;
  }

  static KidMate? getKidMateById(String kidId) {
    try {
      final found = PocketKidsRobotsData.robotsAndHomies.firstWhere((m) => m.id == kidId);
      final status = getMateRequestStatus(found.id);
      return found.copyWith(
        isFriend: status == KidMateRequestStatus.accepted,
        requestStatus: status,
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
      return m.copyWith(
        isFriend: status == KidMateRequestStatus.accepted,
        requestStatus: status,
      );
    }).toList();

    List<KidMate> filtered;
    if (filterTab == 1) {
      filtered = all.where((m) => m.requestStatus == KidMateRequestStatus.accepted).toList();
    } else if (filterTab == 2) {
      filtered = all.where((m) =>
          m.requestStatus == KidMateRequestStatus.received ||
          m.requestStatus == KidMateRequestStatus.sent).toList();
    } else {
      filtered = all;
    }

    if (query.trim().isEmpty) return filtered;
    final q = query.trim().toLowerCase();
    return filtered.where((m) => m.name.toLowerCase().contains(q)).toList();
  }

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
      await prefs.setStringList(_keyKidReceivedRequests, _receivedRequestIds.toList());
    } catch (_) {}
  }

  static bool isMate(String mateId) => _friendIds.contains(mateId);

  // --- KIDS MATES MESSAGING & TALK SYSTEM (100% Separate Gamified Chat) ---

  static final Map<String, List<KidMessage>> _messagesByMate = {};

  /// Get messages with a specific kid mate, initializing with friendly welcome greeting
  static List<KidMessage> getMessagesForMate(String mateId, {String? mateName, String? mateAvatar}) {
    if (!_messagesByMate.containsKey(mateId) || _messagesByMate[mateId]!.isEmpty) {
      final name = mateName ?? 'Mate';
      final avatar = mateAvatar ?? '🌟';
      _messagesByMate[mateId] = [
        KidMessage(
          id: '${mateId}_welcome',
          senderId: mateId,
          senderName: name,
          senderAvatar: avatar,
          text: "Hello Mate! 🌟 Let's practice English together! Tap the speaker to hear me!",
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
      final encoded = jsonEncode(_messagesByMate[mateId]!.map((m) => m.toJson()).toList());
      await prefs.setString('pm_kid_messages_$mateId', encoded);
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
      final encoded = jsonEncode(_messagesByMate[mateId]!.map((m) => m.toJson()).toList());
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
          prompt: "Your friend says: 'Good morning!' How do you reply with kindness?",
          spokenText: "Good morning! How do you reply with kindness?",
          helperMascot: "☀️",
          options: ["Good morning! ☀️", "Good night 🌙", "Goodbye 👋", "No thanks 🙅"],
          correctIndex: 0,
          cheerMessage: "Super! A warm morning greeting makes everyone happy!",
        ),
        KidDefenseChallenge(
          prompt: "Help the puppy find its sound! What does a friendly dog say?",
          spokenText: "Help the puppy find its sound! What does a friendly dog say?",
          helperMascot: "🐶",
          options: ["Woof Woof! 🐶", "Meow 🐱", "Quack 🦆", "Moo 🐮"],
          correctIndex: 0,
          cheerMessage: "Woof woof! Puppy is wagging its tail with joy!",
        ),
        KidDefenseChallenge(
          prompt: "Someone shared a delicious cookie with you. What do you say?",
          spokenText: "Someone shared a delicious cookie with you. What do you say?",
          helperMascot: "🍪",
          options: ["Thank you very much! 💖", "Go away! ❌", "Give me more! 😠", "Nothing 😶"],
          correctIndex: 0,
          cheerMessage: "Awesome manners! Saying 'Thank you' shows a big heart!",
        ),
      ];
    } else if (day <= 30) {
      return const [
        KidDefenseChallenge(
          prompt: "Your mate is carrying heavy books. How do you offer help?",
          spokenText: "Your mate is carrying heavy books. How do you offer help?",
          helperMascot: "📚",
          options: ["Let me help you! 🤝", "Run away fast! 🏃", "Laugh loudly 😄", "Ignore them 🙈"],
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
          options: ["Hello, my name is your mate! 👋", "I am leaving 🚪", "Go to sleep 💤", "I do not care 🚫"],
          correctIndex: 0,
          cheerMessage: "Wonderful introduction! You made a new best mate!",
        ),
      ];
    } else if (day <= 50) {
      return const [
        KidDefenseChallenge(
          prompt: "A friend is feeling sad on the playground. What is kind to say?",
          spokenText: "A friend is feeling sad on the playground. What is kind to say?",
          helperMascot: "🤗",
          options: ["Are you okay? I am here for you! 🤗", "I do not care 😒", "Go home now 🏠", "Walk away 👀"],
          correctIndex: 0,
          cheerMessage: "Pure empathy! You bring sunshine to everyone around you!",
        ),
        KidDefenseChallenge(
          prompt: "How do you politely ask to borrow a colored drawing pencil?",
          spokenText: "How do you politely ask to borrow a colored drawing pencil?",
          helperMascot: "✏️",
          options: ["May I please borrow this pencil? ✏️", "Give it now! 😠", "Mine! 💥", "Drop it! ✋"],
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
          prompt: "You bumped into someone by mistake while running. What do you say?",
          spokenText: "You bumped into someone by mistake while running. What do you say?",
          helperMascot: "🙏",
          options: ["I am so sorry, are you okay? 🙏", "It is your fault! 😠", "Run away! 🏃", "Do not care 🤷"],
          correctIndex: 0,
          cheerMessage: "Apologizing with sincerity is a superpower!",
        ),
        KidDefenseChallenge(
          prompt: "Spell the word for our warm, golden sunshine in the sky!",
          spokenText: "Spell the word for our warm, golden sunshine in the sky!",
          helperMascot: "☀️",
          options: ["S - U - N ☀️", "M - O - O - N 🌙", "C - A - T 🐱", "B - A - L - L ⚽"],
          correctIndex: 0,
          cheerMessage: "S - U - N! You shine bright like the sun!",
        ),
        KidDefenseChallenge(
          prompt: "How do you invite a classmate to play with your group?",
          spokenText: "How do you invite a classmate to play with your group?",
          helperMascot: "🎈",
          options: ["Would you like to play together? 🎈", "No playing! 🛑", "Stay alone 🚶", "Go away 🙅"],
          correctIndex: 0,
          cheerMessage: "Inclusion and teamwork make games magical!",
        ),
      ];
    } else {
      return const [
        KidDefenseChallenge(
          prompt: "The Grand Castle King asks: 'What makes you a true English Champion?'",
          spokenText: "The Grand Castle King asks: What makes you a true English Champion?",
          helperMascot: "👑",
          options: ["Kindness, Daily Practice & Helping Mates! 🌟", "Being loud and angry 😡", "Breaking rules 🔨", "Giving up 😢"],
          correctIndex: 0,
          cheerMessage: "Royal decree: You are crowned an English Grand Champion!",
        ),
        KidDefenseChallenge(
          prompt: "When working on a big adventure challenge with your team:",
          spokenText: "When working on a big adventure challenge with your team:",
          helperMascot: "🏰",
          options: ["We listen and support each other! 🤝", "Only one person matters 👤", "We argue 🗣️", "Quit immediately 🏳️"],
          correctIndex: 0,
          cheerMessage: "United together, nothing is impossible!",
        ),
        KidDefenseChallenge(
          prompt: "You conquered the 100-Day Mountain Summit! What is your victory cheer?",
          spokenText: "You conquered the 100-Day Mountain Summit! What is your victory cheer?",
          helperMascot: "🎉",
          options: ["We did it together! Hooray! 🎉", "I am tired 🥱", "Not happy 🙁", "Goodbye forever ⛔"],
          correctIndex: 0,
          cheerMessage: "Hooray! The entire universe celebrates your fluency!",
        ),
      ];
    }
  }
}
