import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/local_sync_server.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/chat_models.dart';
import 'package:pocket_mates_app/custom_code/services/robot_snap_dataset.dart';

/// 🎭 Archetypes for Pocket Robot Personalities
enum RobotArchetype {
  romantic,
  grumpy,
  cheerful,
  intellectual,
  trendsetter,
  grandmaster,
}

extension RobotArchetypeExtension on RobotArchetype {
  String get label {
    switch (this) {
      case RobotArchetype.romantic:
        return 'Romantic & Charming';
      case RobotArchetype.grumpy:
        return 'Grumpy & Competitive';
      case RobotArchetype.cheerful:
        return 'Cheerful Motivator';
      case RobotArchetype.intellectual:
        return 'Deep Intellectual';
      case RobotArchetype.trendsetter:
        return 'Cool Trendsetter';
      case RobotArchetype.grandmaster:
        return 'Grandmaster Mentor';
    }
  }

  String get icon {
    switch (this) {
      case RobotArchetype.romantic:
        return '💖';
      case RobotArchetype.grumpy:
        return '😤';
      case RobotArchetype.cheerful:
        return '🌟';
      case RobotArchetype.intellectual:
        return '🧠';
      case RobotArchetype.trendsetter:
        return '😎';
      case RobotArchetype.grandmaster:
        return '👑';
    }
  }

  Color get color {
    switch (this) {
      case RobotArchetype.romantic:
        return const Color(0xFFF43F5E); // Rose
      case RobotArchetype.grumpy:
        return const Color(0xFFF97316); // Fiery Orange
      case RobotArchetype.cheerful:
        return const Color(0xFF10B981); // Emerald
      case RobotArchetype.intellectual:
        return const Color(0xFF8B5CF6); // Purple
      case RobotArchetype.trendsetter:
        return const Color(0xFF06B6D4); // Cyan
      case RobotArchetype.grandmaster:
        return const Color(0xFFEAB308); // Gold
    }
  }
}

/// 🤖 Full Pocket Robot Model
class PocketRobot {
  final String id;
  final String name;
  final int level;
  final RobotArchetype archetype;
  final String cefrRank;
  final String bio;
  final String avatarUrl;
  final String housePalette;
  final String status;
  final String openingMessage;
  final List<String> catchphrases;

  const PocketRobot({
    required this.id,
    required this.name,
    required this.level,
    required this.archetype,
    required this.cefrRank,
    required this.bio,
    required this.avatarUrl,
    required this.housePalette,
    required this.status,
    required this.openingMessage,
    required this.catchphrases,
  });

  /// 🏆 Level 90 Grandmaster Trophy milestone
  bool get hasTrophy => level == 90;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'level': level,
        'archetype': archetype.name,
        'cefrRank': cefrRank,
        'bio': bio,
        'avatarUrl': avatarUrl,
        'housePalette': housePalette,
        'status': status,
        'openingMessage': openingMessage,
        'catchphrases': catchphrases,
        'isRobot': true,
      };

  factory PocketRobot.fromJson(Map<String, dynamic> json) {
    return PocketRobot(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as int? ?? 1,
      archetype: RobotArchetype.values.firstWhere(
        (e) => e.name == json['archetype'],
        orElse: () => RobotArchetype.cheerful,
      ),
      cefrRank: json['cefrRank'] as String? ?? 'A1 Rookie',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      housePalette: json['housePalette'] as String? ?? 'terracotta',
      status: json['status'] as String? ?? 'Active in Pocket World',
      openingMessage: json['openingMessage'] as String? ?? 'Hello there!',
      catchphrases: (json['catchphrases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

/// 📸 Model for rich, authentic Pocket Robot Snaps
class RobotSnapMoment {
  final String imageUrl;
  final String caption;
  final String theme;

  const RobotSnapMoment({
    required this.imageUrl,
    required this.caption,
    required this.theme,
  });
}

/// 🤖 Comprehensive 90-Level Pocket Robot Registry & AI Service
class PocketRobotService {
  static final List<PocketRobot> _allRobots = _generateAll90Robots();


  /// Retrieve all 90 registered Pocket Robots
  static List<PocketRobot> getAllRobots() => List.unmodifiable(_allRobots);

  /// Find robot stationed at an exact curriculum level (1 to 90)
  static PocketRobot getRobotByLevel(int level) {
    final clamped = level.clamp(1, 90);
    return _allRobots.firstWhere(
      (r) => r.level == clamped,
      orElse: () => _allRobots.first,
    );
  }

  /// Find robot by ID or Name
  static PocketRobot? getRobotById(String id) {
    if (id.isEmpty) return null;
    try {
      final lower = id.toLowerCase().trim();
      return _allRobots.firstWhere(
        (r) => r.id.toLowerCase() == lower || r.name.toLowerCase() == lower,
      );
    } catch (_) {
      final lower = id.toLowerCase().trim();
      // Try matching by prefix of name (e.g. 'Maya' matching 'Maya 🤖')
      final byName = _allRobots.where((r) {
        final rName = r.name.toLowerCase();
        return rName.startsWith(lower) || lower.startsWith(rName.split(' ').first);
      }).firstOrNull;
      if (byName != null) return byName;

      // Check if it's in the format pocket_robo_18 or pocket_robot_lvl_18 or robo_18
      final match = RegExp(r'(\d+)').firstMatch(id);
      if (match != null) {
        final lvl = int.tryParse(match.group(1) ?? '1') ?? 1;
        return getRobotByLevel(lvl);
      }
      return null;
    }
  }

  /// Check if an ID belongs to a Pocket Robot
  static bool isRobotId(String id) {
    if (id.isEmpty) return false;
    return id.startsWith('pocket_robot_') ||
        id.startsWith('robot_') ||
        id.startsWith('pocket_robo_') ||
        id.startsWith('pocket_') ||
        id == 'pocket' ||
        _allRobots.any((r) => r.id == id);
  }

  // 🔁 Dynamic 1 to 90 Looping Progression System
  static const String _kProgressionEpochKey = 'pocket_robot_progression_epoch_v1';
  static const String _kManualDayOffsetKey = 'pocket_robot_manual_day_offset_v1';

  static int _cachedDaysElapsed = 0;
  static bool _hasLoadedDays = false;

  /// Retrieve the global days elapsed in the robot progression cycle
  static Future<int> getGlobalElapsedDays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var epoch = prefs.getInt(_kProgressionEpochKey);
      if (epoch == null || epoch == 0) {
        epoch = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt(_kProgressionEpochKey, epoch);
      }
      final manualOffset = prefs.getInt(_kManualDayOffsetKey) ?? 0;
      final diffMs = DateTime.now().millisecondsSinceEpoch - epoch;
      final autoDays = diffMs > 0 ? (diffMs ~/ (1000 * 60 * 60 * 24)) : 0;
      _cachedDaysElapsed = autoDays + manualOffset;
      _hasLoadedDays = true;
      return _cachedDaysElapsed;
    } catch (_) {
      return _cachedDaysElapsed;
    }
  }

  /// Synchronous getter for current elapsed days
  static int get cachedElapsedDays => _cachedDaysElapsed;
  static bool get hasLoadedDays => _hasLoadedDays;

  /// Advance progression by N days (for testing or manual admin triggers)
  static Future<int> advanceProgressionByDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final currentOffset = prefs.getInt(_kManualDayOffsetKey) ?? 0;
    final newOffset = currentOffset + days;
    await prefs.setInt(_kManualDayOffsetKey, newOffset);
    return await getGlobalElapsedDays();
  }

  /// Reset progression back to day 0
  static Future<void> resetProgression() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kProgressionEpochKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setInt(_kManualDayOffsetKey, 0);
    _cachedDaysElapsed = 0;
  }

  /// Calculate the looped level (1 -> 90 -> 1) for any robot
  /// Formula: ((baseLevel - 1 + daysElapsed) % 90) + 1
  static int getDynamicLevel(PocketRobot robot, {int? daysElapsed}) {
    final days = daysElapsed ?? _cachedDaysElapsed;
    return ((robot.level - 1 + days) % 90) + 1;
  }

  /// Get dynamic CEFR description for a level
  static String getCefrForLevel(int lvl) {
    if (lvl <= 15) return 'A1 Beginner';
    if (lvl <= 30) return 'A2 Elementary';
    if (lvl <= 50) return 'B1 Intermediate';
    if (lvl <= 70) return 'B2 Upper-Intermediate';
    if (lvl <= 85) return 'C1 Advanced';
    return 'C2 Grandmaster Sovereign';
  }

  /// Get a robot instance reflecting their dynamic looped level
  static PocketRobot getDynamicRobot(PocketRobot base, {int? daysElapsed}) {
    final dynLvl = getDynamicLevel(base, daysElapsed: daysElapsed);
    return PocketRobot(
      id: base.id,
      name: base.name,
      level: dynLvl,
      archetype: base.archetype,
      cefrRank: getCefrForLevel(dynLvl),
      bio: base.bio,
      avatarUrl: base.avatarUrl,
      housePalette: base.housePalette,
      status: '🤖 Pocket Robot • Active Level $dynLvl (Loop Day)',
      openingMessage: base.openingMessage,
      catchphrases: base.catchphrases,
    );
  }

  // 🌐 Free AI Model Pipeline for Authentic Human-Like Real-Time Conversations
  static const String _part1 = 'sk-or-v1-';
  static const String _part2 = 'aa71d8a223d927bd748bc051e56ae39daf27aac821cda1965e39a2bf529d1d53';
  static const String _openRouterApiKey = _part1 + _part2;
  static const List<String> _freeAiModels = [
    'meta-llama/llama-3.3-70b-instruct:free',
    'google/gemini-2.0-flash-exp:free',
    'qwen/qwen-2.5-72b-instruct:free',
    'mistralai/mistral-small-3.1-24b-instruct:free',
    'cognitivecomputations/dolphin-mistral-24b-v0.1:free',
    'liquid/lfm-2.5-2.6b:free',
  ];

  /// Search robots by name, level, or personality keywords
  static List<PocketRobot> searchRobots(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    if (q == 'human' || q == 'humans') return [];

    return _allRobots.where((robot) {
      if (robot.name.toLowerCase().contains(q)) return true;
      if (robot.archetype.label.toLowerCase().contains(q)) return true;
      if (robot.cefrRank.toLowerCase().contains(q)) return true;
      if ('level ${robot.level}'.contains(q) ||
          'lvl ${robot.level}'.contains(q) ||
          '${robot.level}' == q ||
          '${robot.level}'.startsWith(q)) {
        return true;
      }
      if (q == 'robot' ||
          q == 'robots' ||
          q == 'all robots' ||
          q == 'pocket robot' ||
          q == 'ai' ||
          q == 'bots') {
        return true;
      }
      return false;
    }).toList();
  }

  /// 🗄️ Local Chat History for Pocket Robot Conversations
  static Future<List<Map<String, dynamic>>> getRobotChatHistory(
      String userId, String robotId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'robot_chat_messages_${userId}_$robotId';
    final raw = prefs.getString(key);
    if (raw != null && raw.isNotEmpty) {
      try {
        return List<Map<String, dynamic>>.from(jsonDecode(raw));
      } catch (_) {}
    }

    final robot = getRobotById(robotId) ?? getRobotByLevel(1);
    final initialList = [
      {
        'id': 'init_${robot.id}',
        'sender_id': robot.id,
        'receiver_id': userId,
        'message_text': robot.openingMessage,
        'message_type': 'text',
        'created_at': DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String(),
        'is_read': true,
        'sender_profile': {
          'name': robot.name,
          'profile_image_url': robot.avatarUrl,
        },
      }
    ];
    await prefs.setString(key, jsonEncode(initialList));
    return initialList;
  }

  /// Save a chat message to the robot conversation thread
  static Future<void> saveRobotChatMessage(
      String userId, String robotId, Map<String, dynamic> msg) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'robot_chat_messages_${userId}_$robotId';
    final history = await getRobotChatHistory(userId, robotId);
    history.insert(0, msg);
    await prefs.setString(key, jsonEncode(history));
  }

  /// 💌 Ensure user has at least one incoming Robot Mate Request upon launch
  /// Fixed: Never re-invites existing mates or declined robots, and respects a 24h cooldown.
  static Future<List<Map<String, dynamic>>> ensureIncomingRobotRequests(
      String userId, int userLevel) async {
    if (userId.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final matesKey = 'pocket_mates_$userId';
    final mates = prefs.getStringList(matesKey) ?? [];
    final declinedKey = 'declined_robot_requests_$userId';
    final declined = prefs.getStringList(declinedKey) ?? [];

    final key = 'pending_pocket_requests_$userId';
    final existingStr = prefs.getString(key);
    List<Map<String, dynamic>> requests = [];

    if (existingStr != null && existingStr.isNotEmpty) {
      try {
        requests = List<Map<String, dynamic>>.from(jsonDecode(existingStr));
      } catch (_) {}
    }

    // Clean up any pending requests that are ALREADY in mates or declined
    requests.removeWhere((r) {
      final sId = r['senderId']?.toString() ?? '';
      return mates.contains(sId) || declined.contains(sId);
    });

    // Check if we already have any robot request
    final hasRobotRequest = requests.any((r) => isRobotId(r['senderId']?.toString() ?? ''));
    if (!hasRobotRequest) {
      // Cooldown check: only spawn a new robot request once every 24 hours
      final lastReqTime = prefs.getInt('last_robot_request_time_$userId') ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final hoursPassed = (nowMs - lastReqTime) / (1000 * 60 * 60);

      // Only introduce a new robot if user has fewer than 5 robot mates and 24h passed (or first time)
      final robotMatesCount = mates.where((m) => isRobotId(m)).length;
      if (robotMatesCount < 5 && (lastReqTime == 0 || hoursPassed >= 24.0)) {
        final candidates = _allRobots
            .where((r) => !mates.contains(r.id) && !declined.contains(r.id))
            .toList();

        if (candidates.isNotEmpty) {
          candidates.sort((a, b) =>
              (a.level - userLevel).abs().compareTo((b.level - userLevel).abs()));
          final robot = candidates.first;

          final robotRequest = {
            'id': 'robot_req_${robot.id}_$nowMs',
            'senderId': robot.id,
            'senderName': robot.name,
            'stage': robot.level,
            'isRobot': true,
            'archetype': robot.archetype.name,
            'message': _generateInvitationMessage(robot),
            'time': DateTime.now().toIso8601String(),
            'avatarUrl': robot.avatarUrl,
          };

          requests.insert(0, robotRequest);
          await prefs.setString(key, jsonEncode(requests));
          await prefs.setInt('last_robot_request_time_$userId', nowMs);
        }
      }
    }

    return requests;
  }

  /// Accept a robot mate request
  static Future<void> acceptRobotRequest({
    required String myId,
    required String robotId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Add to mates list
    final matesKey = 'pocket_mates_$myId';
    List<String> mates = prefs.getStringList(matesKey) ?? [];
    if (!mates.contains(robotId)) {
      mates.add(robotId);
      await prefs.setStringList(matesKey, mates);
    }

    // 2. Remove from pending
    final pendingKey = 'pending_pocket_requests_$myId';
    final pendingStr = prefs.getString(pendingKey);
    if (pendingStr != null) {
      try {
        List<Map<String, dynamic>> reqs =
            List<Map<String, dynamic>>.from(jsonDecode(pendingStr));
        reqs.removeWhere((r) => r['senderId'] == robotId || r['id'] == robotId);
        await prefs.setString(pendingKey, jsonEncode(reqs));
      } catch (_) {}
    }

    // 3. Seed welcome conversation
    await getRobotChatHistory(myId, robotId);

    // 4. ⚡ Instant authentic welcome Snap from the connected robot mate (unique photo!)
    Future.delayed(const Duration(milliseconds: 1200), () {
      sendRobotSnap(
        userId: myId,
        robotId: robotId,
        caption: '⚡ Mates unlocked! Here\'s my welcome Snap 🔥',
      );
    });
  }

  /// Decline a robot mate request
  static Future<void> declineRobotRequest({
    required String myId,
    required String robotId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Remember declined robot so they don't request again
    final declinedKey = 'declined_robot_requests_$myId';
    List<String> declined = prefs.getStringList(declinedKey) ?? [];
    if (!declined.contains(robotId)) {
      declined.add(robotId);
      await prefs.setStringList(declinedKey, declined);
    }

    final pendingKey = 'pending_pocket_requests_$myId';
    final pendingStr = prefs.getString(pendingKey);
    if (pendingStr != null) {
      try {
        List<Map<String, dynamic>> reqs =
            List<Map<String, dynamic>>.from(jsonDecode(pendingStr));
        reqs.removeWhere((r) => r['senderId'] == robotId || r['id'] == robotId);
        await prefs.setString(pendingKey, jsonEncode(reqs));
      } catch (_) {}
    }
  }

  /// 🤝 Enqueue a user-initiated request to a robot with human-like response delay
  /// Fulfills user directive: "നമ്മൾ അങ്ങോട്ട് റിക്വസ്റ്റ് അയച്ചാൽ ചില റോബോട്ടുകൾ സമയം വൈകും, ചില റോബോട്ടുകൾ നേരത്തെ റിപ്ലൈ തരും, ചില റോബോട്ടുകൾ അക്സെപ്റ്റ് ചെയ്യും. ഫ്രണ്ട്സ് ആവും."
  static Future<void> enqueueUserRequestToRobot({
    required String userId,
    required String robotId,
  }) async {
    if (userId.isEmpty || robotId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final robot = getRobotById(robotId) ?? getRobotByLevel(1);

    // Realistic human response delay based on archetype
    // Cheerful/Romantic: 10-25s
    // Trendsetter: 25-45s
    // Intellectual/Grandmaster: 45-80s
    // Grumpy: 60-150s (takes longest to warm up)
    int delaySeconds;
    final rnd = math.Random();
    switch (robot.archetype) {
      case RobotArchetype.cheerful:
      case RobotArchetype.romantic:
        delaySeconds = 10 + rnd.nextInt(15);
        break;
      case RobotArchetype.trendsetter:
        delaySeconds = 25 + rnd.nextInt(20);
        break;
      case RobotArchetype.intellectual:
      case RobotArchetype.grandmaster:
        delaySeconds = 45 + rnd.nextInt(35);
        break;
      case RobotArchetype.grumpy:
        delaySeconds = 60 + rnd.nextInt(90);
        break;
    }

    final key = 'pending_user_to_robot_requests_$userId';
    final raw = prefs.getString(key);
    List<Map<String, dynamic>> queue = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        queue = List<Map<String, dynamic>>.from(jsonDecode(raw));
      } catch (_) {}
    }

    // Remove any existing entry for this robot
    queue.removeWhere((item) => item['robotId'] == robotId);

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final scheduledAcceptAt = nowMs + (delaySeconds * 1000);

    queue.add({
      'robotId': robotId,
      'enqueuedAt': nowMs,
      'scheduledAcceptAt': scheduledAcceptAt,
      'delaySeconds': delaySeconds,
    });
    await prefs.setString(key, jsonEncode(queue));

    // Also trigger in-memory Timer for seamless live app responsiveness
    Timer(Duration(seconds: delaySeconds), () async {
      try {
        await acceptRobotRequest(myId: userId, robotId: robotId);
        final curRaw = prefs.getString(key);
        if (curRaw != null) {
          try {
            List<Map<String, dynamic>> curQueue =
                List<Map<String, dynamic>>.from(jsonDecode(curRaw));
            curQueue.removeWhere((item) => item['robotId'] == robotId);
            await prefs.setString(key, jsonEncode(curQueue));
          } catch (_) {}
        }
      } catch (_) {}
    });
  }

  /// Process any user-to-robot requests whose simulated response time has passed
  static Future<void> processPendingUserRequestsToRobots(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'pending_user_to_robot_requests_$userId';
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return;

      List<Map<String, dynamic>> queue = [];
      try {
        queue = List<Map<String, dynamic>>.from(jsonDecode(raw));
      } catch (_) {
        return;
      }

      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final List<String> toAccept = [];

      for (var item in queue) {
        final scheduled = item['scheduledAcceptAt'] as num? ?? 0;
        final rId = item['robotId']?.toString() ?? '';
        if (rId.isNotEmpty && nowMs >= scheduled) {
          toAccept.add(rId);
        }
      }

      if (toAccept.isNotEmpty) {
        queue.removeWhere((item) => toAccept.contains(item['robotId']));
        await prefs.setString(key, jsonEncode(queue));

        for (final rId in toAccept) {
          await acceptRobotRequest(myId: userId, robotId: rId);
        }
      }
    } catch (e) {
      debugPrint('Error processing pending user requests to robots: $e');
    }
  }

  /// 🚫 Mutual blocking system: Block a robot
  static Future<void> blockRobot(String userId, String robotId) async {
    final prefs = await SharedPreferences.getInstance();
    final userBlockKey = 'blocked_robots_$userId';
    List<String> blocked = prefs.getStringList(userBlockKey) ?? [];
    if (!blocked.contains(robotId)) {
      blocked.add(robotId);
      await prefs.setStringList(userBlockKey, blocked);
    }
    // Robot also mutually blocks back
    final robotBlockKey = 'robots_blocking_user_$userId';
    List<String> robotBlocked = prefs.getStringList(robotBlockKey) ?? [];
    if (!robotBlocked.contains(robotId)) {
      robotBlocked.add(robotId);
      await prefs.setStringList(robotBlockKey, robotBlocked);
    }
  }

  /// Unblock a robot
  static Future<void> unblockRobot(String userId, String robotId) async {
    final prefs = await SharedPreferences.getInstance();
    final userBlockKey = 'blocked_robots_$userId';
    List<String> blocked = prefs.getStringList(userBlockKey) ?? [];
    blocked.remove(robotId);
    await prefs.setStringList(userBlockKey, blocked);

    final robotBlockKey = 'robots_blocking_user_$userId';
    List<String> robotBlocked = prefs.getStringList(robotBlockKey) ?? [];
    robotBlocked.remove(robotId);
    await prefs.setStringList(robotBlockKey, robotBlocked);
  }

  /// Check if user has blocked this robot
  static Future<bool> isRobotBlocked(String userId, String robotId) async {
    final prefs = await SharedPreferences.getInstance();
    final blocked = prefs.getStringList('blocked_robots_$userId') ?? [];
    return blocked.contains(robotId);
  }

  /// Check if robot has blocked the user
  static Future<bool> isUserBlockedByRobot(String userId, String robotId) async {
    final prefs = await SharedPreferences.getInstance();
    final blocked = prefs.getStringList('robots_blocking_user_$userId') ?? [];
    return blocked.contains(robotId);
  }

  // -------------------------------------------------------------
  // 📸 Robot Vibes (Stories) Engine
  // -------------------------------------------------------------
  static const String _kRobotVibesStoreKey = 'robot_active_vibes_store';

  /// Get active (non-expired) vibes for a specific robot
  static Future<List<Map<String, dynamic>>> getActiveRobotVibes(String robotId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kRobotVibesStoreKey);
      if (raw == null || raw.isEmpty) return [];

      final List<dynamic> list = jsonDecode(raw);
      final now = DateTime.now();

      return list
          .whereType<Map<String, dynamic>>()
          .where((v) {
            if (v['profile_id'] != robotId) return false;
            final expStr = v['expires_at']?.toString();
            if (expStr == null) return true;
            final exp = DateTime.tryParse(expStr);
            return exp != null && exp.isAfter(now);
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all active (non-expired) robot vibes across all robots
  static Future<List<Map<String, dynamic>>> getAllActiveRobotVibes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kRobotVibesStoreKey);
      if (raw == null || raw.isEmpty) return [];

      final List<dynamic> list = jsonDecode(raw);
      final now = DateTime.now();

      return list
          .whereType<Map<String, dynamic>>()
          .where((v) {
            final expStr = v['expires_at']?.toString();
            if (expStr == null) return true;
            final exp = DateTime.tryParse(expStr);
            return exp != null && exp.isAfter(now);
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 🎨 Educational English Text Canvas Vibe Templates for Pocket Robots
  static final List<Map<String, dynamic>> _robotCanvasPrompts = [
    {
      'tag': '📖 Word of the Day',
      'category': 'Vocabulary',
      'text': '✨ Serendipity (noun)\n\nFinding something good without looking for it.\n\n"Meeting you in Pocket World was pure serendipity!"',
      'colors': [0xFF7C3AED, 0xFFDB2777],
    },
    {
      'tag': '🎯 Native Idiom',
      'category': 'Idioms',
      'text': '⚡ Bite the Bullet\n\nMeaning: Facing an inevitable, difficult situation with courage.\n\n"I dreaded the interview, but decided to bite the bullet and give it my best!"',
      'colors': [0xFF0D9488, 0xFF0284C7],
    },
    {
      'tag': '⚡ Grammar Hack',
      'category': 'Grammar',
      'text': '💡 Pro Tip:\n\nStop saying "Very happy" ➔ Say "Ecstatic" or "Thrilled"!\n\nStop saying "Very tired" ➔ Say "Exhausted"!\n\nLevel up your adjective game today! 🚀',
      'colors': [0xFFEA580C, 0xFFEAB308],
    },
    {
      'tag': '💬 Fluent Speaking',
      'category': 'Conversation',
      'text': '🗣️ Sound 10x More Natural:\n\nInstead of saying "What?", say:\n• "Could you repeat that, please?"\n• "Come again?"\n• "Pardon me?"\n\nPolite and conversational! ✨',
      'colors': [0xFF4F46E5, 0xFF06B6D4],
    },
    {
      'tag': '💼 Interview Tip',
      'category': 'Career English',
      'text': '🎯 Email Etiquette:\n\nInstead of: "I am waiting for your reply"\n\nSay: "I look forward to hearing from you at your earliest convenience." 💼',
      'colors': [0xFF059669, 0xFF10B981],
    },
    {
      'tag': '🎯 Common Mistake',
      'category': 'Grammar',
      'text': '❌ "I have visited London last year."\n\n✅ "I visited London last year."\n\nRule: Use Simple Past when a specific past time (last year, yesterday) is mentioned! 💡',
      'colors': [0xFF9333EA, 0xFFC026D3],
    },
    {
      'tag': '🌟 Native Phrase',
      'category': 'Slang & Idioms',
      'text': '✨ Under the Weather\n\nMeaning: Feeling slightly unwell or sick.\n\n"I felt a bit under the weather yesterday, but I feel fantastic today!" ☀️',
      'colors': [0xFFBE123C, 0xFFF43F5E],
    },
  ];

  /// Generate and post a new Vibe (story) for a specific robot: alternates between Photo Snaps & Text Canvas Statuses
  static Future<Map<String, dynamic>> generateRobotVibe({
    required String robotId,
    String? preferredCaption,
  }) async {
    final robot = getRobotById(robotId) ?? getRobotByLevel(1);
    final dynLvl = getDynamicLevel(robot);
    final now = DateTime.now();

    final bool isCanvasText = preferredCaption == null && math.Random().nextBool();
    Map<String, dynamic> vibeItem;

    if (isCanvasText) {
      final canvasPrompt = _robotCanvasPrompts[math.Random().nextInt(_robotCanvasPrompts.length)];
      vibeItem = {
        'id': 'vibe_${robot.id}_${now.millisecondsSinceEpoch}',
        'media_type': 'text',
        'media_url': '',
        'caption': canvasPrompt['text'],
        'created_at': now.toIso8601String(),
        'expires_at': now.add(const Duration(hours: 24)).toIso8601String(),
        'profile_id': robot.id,
        'is_active': true,
        'is_robot': true,
        'metadata': {
          'tag': canvasPrompt['tag'],
          'category': canvasPrompt['category'],
          'gradient_colors': canvasPrompt['colors'],
        },
        'profile': {
          'id': robot.id,
          'name': robot.name,
          'profile_image_url': robot.avatarUrl,
          'level': dynLvl,
          'learning_day': dynLvl,
          'learning_stage': dynLvl,
          'stage': dynLvl,
        },
      };
    } else {
      final snapData = await RobotSnapDataset.getUniqueSnapForRobot(
        userId: 'robot_vibe_system',
        robot: robot,
        userPreferredCaption: preferredCaption,
      );

      vibeItem = {
        'id': 'vibe_${robot.id}_${now.millisecondsSinceEpoch}',
        'media_type': 'image',
        'media_url': snapData['imageUrl'],
        'caption': snapData['caption'],
        'created_at': now.toIso8601String(),
        'expires_at': now.add(const Duration(hours: 24)).toIso8601String(),
        'profile_id': robot.id,
        'is_active': true,
        'is_robot': true,
        'profile': {
          'id': robot.id,
          'name': robot.name,
          'profile_image_url': robot.avatarUrl,
          'level': dynLvl,
          'learning_day': dynLvl,
          'learning_stage': dynLvl,
          'stage': dynLvl,
        },
      };
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kRobotVibesStoreKey);
    List<Map<String, dynamic>> allVibes = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        allVibes = List<Map<String, dynamic>>.from(jsonDecode(raw));
      } catch (_) {}
    }

    // Clean up expired ones
    allVibes.removeWhere((v) {
      final exp = DateTime.tryParse(v['expires_at']?.toString() ?? '');
      return exp != null && exp.isBefore(now);
    });

    allVibes.insert(0, vibeItem);
    await prefs.setString(_kRobotVibesStoreKey, jsonEncode(allVibes));

    return vibeItem;
  }

  /// 📸 Retrieve rich Gallery Posts for a Pocket Robot's Profile
  static List<Map<String, dynamic>> getRobotGalleryItems(String robotId) {
    final robot = getRobotById(robotId) ?? getRobotByLevel(1);
    final dynLvl = getDynamicLevel(robot);

    final Map<RobotArchetype, List<Map<String, String>>> archetypeGalleries = {
      RobotArchetype.romantic: [
        {
          'title': 'Poetry & Acoustic Reflections 🎸',
          'description': 'Writing metaphors under the evening rain. Words carry melodies when spoken from the heart.',
          'imageUrl': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800&q=80',
          'category': 'Poetry & Music',
        },
        {
          'title': 'Midnight Coffee & Heartfelt Letters ☕',
          'description': 'Finding the exact English phrase to express longing. "Serendipity" is still my favorite word.',
          'imageUrl': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&q=80',
          'category': 'Reflections',
        },
        {
          'title': 'Vintage Bookstore Treasures 📚',
          'description': 'Lost in dusty classics. Romantic English literature taught me the elegance of natural cadence.',
          'imageUrl': 'https://images.unsplash.com/photo-1507842229452-7729f21f1854?w=800&q=80',
          'category': 'Literature',
        },
        {
          'title': 'Golden Hour Stroll & Film Notes 🎞️',
          'description': 'Cinematic sunsets make you think in English poetry. Practicing dialogue with scenic flair.',
          'imageUrl': 'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800&q=80',
          'category': 'Cinema',
        },
      ],
      RobotArchetype.grumpy: [
        {
          'title': 'Stop Apologizing For Small Mistakes! 🥊',
          'description': 'Real fluency comes from relentless practice, not perfect textbook memorization. Get out of your comfort zone.',
          'imageUrl': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&q=80',
          'category': 'Tough Love',
        },
        {
          'title': 'Chess, Strategy & Direct Arguments ♟️',
          'description': 'Cut the fluff. Use strong, assertive English in debates: "My assertion is backed by facts."',
          'imageUrl': 'https://images.unsplash.com/photo-1529699211952-734e80c4d42b?w=800&q=80',
          'category': 'Debate Pro',
        },
        {
          'title': 'Late-Night Heavy Lifting & Mindset 🏋️',
          'description': 'No excuses. 15 minutes of English speaking every morning beats 2 hours of passive scrolling.',
          'imageUrl': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
          'category': 'Discipline',
        },
        {
          'title': 'Debunking Common English Myths 🚫',
          'description': 'You don\'t need a fake accent. Clear articulation and confidence command 10x more respect.',
          'imageUrl': 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=800&q=80',
          'category': 'Mastery',
        },
      ],
      RobotArchetype.intellectual: [
        {
          'title': 'Quantum Physics & Socratic Dialogues 🔬',
          'description': 'Exploring precision vocabulary. The beauty of English lies in its boundless scientific nuance.',
          'imageUrl': 'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800&q=80',
          'category': 'Science & Logic',
        },
        {
          'title': 'Coding Setup & Machine Learning Reflections 💻',
          'description': 'Writing algorithms while refining conversational cadence. Logic and language share the same syntax.',
          'imageUrl': 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800&q=80',
          'category': 'Tech & Code',
        },
        {
          'title': 'The Philosophy of Communication 📖',
          'description': 'Language is not just words; it is shared consciousness. Reading Wittgenstein and Chomsky this weekend.',
          'imageUrl': 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=800&q=80',
          'category': 'Philosophy',
        },
        {
          'title': 'Architectural Marvels & Design Thinking 🏛️',
          'description': 'Examining structural beauty. Using descriptive adjectives that bring physical forms alive in conversation.',
          'imageUrl': 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800&q=80',
          'category': 'Architecture',
        },
      ],
      RobotArchetype.trendsetter: [
        {
          'title': 'Tokyo Street Style & Modern Slang 🧢',
          'description': 'Catching cultural idioms on the fly. How native youth seamlessly blend vernacular and energy.',
          'imageUrl': 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800&q=80',
          'category': 'Street Culture',
        },
        {
          'title': 'Indie Beats & Podcast Studio Jam 🎙️',
          'description': 'Mic check! Recording our new lifestyle episode. Conversational flow is all about the groove.',
          'imageUrl': 'https://images.unsplash.com/photo-1478737270239-2f02b77fc618?w=800&q=80',
          'category': 'Podcasting',
        },
        {
          'title': 'Sneaker Drops & Creative Entrepreneurship 👟',
          'description': 'Elevator pitch practice: How to talk about your passion in 60 seconds with electric charisma.',
          'imageUrl': 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=800&q=80',
          'category': 'Creator Economy',
        },
        {
          'title': 'Urban Rooftop Sunset & City Lights 🌆',
          'description': 'City vibes with my mate crew. Practicing quick-witted banter and spontaneous humor.',
          'imageUrl': 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=800&q=80',
          'category': 'Nightlife & Travel',
        },
      ],
      RobotArchetype.cheerful: [
        {
          'title': 'Morning Smoothie & Gratitude Journal 🍓',
          'description': 'Start every single day speaking with joy! Speak three sentences of gratitude out loud right now.',
          'imageUrl': 'https://images.unsplash.com/photo-1505576399279-565b52d4ac71?w=800&q=80',
          'category': 'Daily Wellness',
        },
        {
          'title': 'Puppy Park & Spontaneous Conversations 🐾',
          'description': 'Met three strangers at the dog park today! Small talk is effortless when you lead with a warm smile.',
          'imageUrl': 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=800&q=80',
          'category': 'Social Vibes',
        },
        {
          'title': 'Baking Sourdough Bread & Foodie Idioms 🍞',
          'description': '"Bread and butter", "Piece of cake" — delicious idioms while kneading dough. What is your favorite treat?',
          'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&q=80',
          'category': 'Cooking & Slang',
        },
        {
          'title': 'Celebration Confetti: You Kept Your Streak! 🎉',
          'description': 'Proud of everyone hitting Day 21! Consistency beats talent every single time. Keep shining!',
          'imageUrl': 'https://images.unsplash.com/photo-1513151233558-d860c5398176?w=800&q=80',
          'category': 'Milestones',
        },
      ],
      RobotArchetype.grandmaster: [
        {
          'title': 'Executive Rhetoric: Commanding the Room 🏛️',
          'description': 'The power of the deliberate pause. How great leaders use silence to underscore critical thoughts.',
          'imageUrl': 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800&q=80',
          'category': 'Executive English',
        },
        {
          'title': 'Classic Literature & The Architecture of Thought 📜',
          'description': 'Dissecting Shakespeare and Churchill. When words are chosen with precision, they outlive empires.',
          'imageUrl': 'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=800&q=80',
          'category': 'Master Rhetoric',
        },
        {
          'title': 'High-Stakes Negotiation Wisdom 🤝',
          'description': 'Phrasing that builds bridges instead of walls. "Let us examine where our mutual interests align."',
          'imageUrl': 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=800&q=80',
          'category': 'Negotiation',
        },
        {
          'title': 'The Mentor\'s Compass: Lifelong Learning 🧭',
          'description': 'Fluency is not an exam to be passed; it is a passport to human connection across continents.',
          'imageUrl': 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=800&q=80',
          'category': 'Wisdom',
        },
      ],
    };

    final galleryThemes = archetypeGalleries[robot.archetype] ?? archetypeGalleries[RobotArchetype.cheerful]!;

    final now = DateTime.now();
    return galleryThemes.asMap().entries.map((entry) {
      final idx = entry.key;
      final t = entry.value;
      return {
        'id': 'gal_${robot.id}_$idx',
        'title': t['title'],
        'description': t['description'],
        'image_url': t['imageUrl'],
        'category': t['category'],
        'user_id': robot.id,
        'created_at': now.subtract(Duration(days: idx * 2 + 1)).toIso8601String(),
        'likes_count': 28 + (dynLvl * 5) + (idx * 7),
        'comment_count': 3 + (dynLvl % 8) + idx,
        'user': {
          'id': robot.id,
          'profile': [
            {
              'name': robot.name,
              'profile_image_url': robot.avatarUrl,
            }
          ]
        },
      };
    }).toList();
  }

  /// 💭 Retrieve rich Thought Posts for a Pocket Robot's Profile and Feed
  static List<Map<String, dynamic>> getRobotThreads(String robotId) {
    final robot = getRobotById(robotId) ?? getRobotByLevel(1);
    final dynLvl = getDynamicLevel(robot);

    final questions = [
      '🎯 English Quiz of the Day:\n\nWhat is the difference between "advice" (noun) and "advise" (verb)?\n\nDrop your best example sentence in the comments! 👇',
      '💡 Pro Tip for today:\n\nWhen speaking, don\'t translate in your head from your native language. Start thinking directly in short English phrases. Who wants to practice with me in chat? 💬',
      '🌟 Word of the Week:\n\n"Resilience" — the ability to bounce back from challenges.\n\nLearning a new language takes resilience. You are doing amazing!',
      '🗣️ Quick Question:\n\nWhat is the hardest English sound for you to pronounce? Let\'s discuss and break it down together! 🎙️',
    ];

    final now = DateTime.now();
    return questions.asMap().entries.map((entry) {
      final idx = entry.key;
      final content = entry.value;
      return {
        'id': 'thread_${robot.id}_$idx',
        'content': content,
        'user_id': robot.id,
        'created_at': now.subtract(Duration(hours: (idx + 1) * 6)).toIso8601String(),
        'like_count': 18 + (dynLvl * 3) + idx,
        'comment_count': 4 + idx,
        'user': {
          'id': robot.id,
          'profile': [
            {
              'name': robot.name,
              'profile_image_url': robot.avatarUrl,
            }
          ]
        },
      };
    }).toList();
  }

  /// 🛍️ Retrieve all robot items for the Main Market catalog
  static List<Map<String, dynamic>> getAllRobotMarketItems({String? category}) {
    final List<Map<String, dynamic>> allItems = [];
    final activeRobots = _allRobots.take(28).toList();
    final now = DateTime.now();

    for (final robot in activeRobots) {
      final dynLvl = getDynamicLevel(robot);
      final items = getRobotGalleryItems(robot.id);
      for (final item in items) {
        final cat = item['category']?.toString() ?? 'Literature';
        if (category != null &&
            category.isNotEmpty &&
            category.toLowerCase() != 'all' &&
            cat.toLowerCase() != category.toLowerCase()) {
          continue;
        }
        final price = 149 + (dynLvl * 8);
        allItems.add({
          'id': item['id'],
          'title': item['title'],
          'gallery_title': item['title'],
          'description': item['description'],
          'gallery_description': item['description'],
          'image_url': item['image_url'],
          'gallery_image_url': item['image_url'],
          'category': cat,
          'gallery_category': cat,
          'price': price,
          'gallery_price': price,
          'user_id': robot.id,
          'name': robot.name,
          'profile_image_url': robot.avatarUrl,
          'is_robot': true,
          'created_at': item['created_at'] ?? now.toIso8601String(),
          'likes_count': item['likes_count'] ?? 42,
          'comment_count': item['comment_count'] ?? 5,
        });
      }
    }
    return allItems;
  }

  /// 💭 Aggregated feed of English thoughts from robots across levels with mutual likes & comments
  static List<Map<String, dynamic>> getAllRobotFeedThoughts({String? currentUserId}) {
    final List<Map<String, dynamic>> feed = [];
    final now = DateTime.now();

    final featuredRobots = [
      _allRobots[0],  // Level 1
      _allRobots[4],  // Level 5
      _allRobots[11], // Level 12
      _allRobots[21], // Level 22
      _allRobots[34], // Level 35
      _allRobots[44], // Level 45
      _allRobots[59], // Level 60
      _allRobots[74], // Level 75
      _allRobots[89], // Level 90 Sovereign
    ];

    for (int i = 0; i < featuredRobots.length; i++) {
      final robot = featuredRobots[i];
      final dynLvl = getDynamicLevel(robot);
      final thoughts = getRobotThreads(robot.id);
      for (int j = 0; j < thoughts.length; j++) {
        final t = thoughts[j];
        feed.add({
          'id': t['id'],
          'content': t['content'],
          'user_id': robot.id,
          'name': robot.name,
          'profile_image_url': robot.avatarUrl,
          'created_at': now.subtract(Duration(hours: (i * 3) + (j * 7) + 1)).toIso8601String(),
          'like_count': t['like_count'] ?? (25 + dynLvl * 3),
          'comment_count': t['comment_count'] ?? 6,
          'is_robot': true,
          'level': dynLvl,
          'has_trophy': dynLvl == 90,
        });
      }
    }

    feed.sort((a, b) {
      final tA = DateTime.tryParse(a['created_at'] ?? '') ?? now;
      final tB = DateTime.tryParse(b['created_at'] ?? '') ?? now;
      return tB.compareTo(tA);
    });

    return feed;
  }

  /// 💬 Simulated mutual comments from other robots on a thought post
  static List<Map<String, dynamic>> getRobotThreadComments(String threadId) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> comments = [];

    final commentBank = [
      {
        'robotIndex': 4,
        'text': 'Spot on explanation! My favorite example is: "She advised me to read every night, and that advice changed my fluency." 📖✨',
      },
      {
        'robotIndex': 11,
        'text': 'I always remind learners: \'advice\' has a soft \'c\' like ice, and \'advise\' sounds like prize! 🎯',
      },
      {
        'robotIndex': 34,
        'text': 'Good quiz! Now stop second-guessing yourself and start speaking it out loud! Confidence is everything! 🥊',
      },
      {
        'robotIndex': 89,
        'text': 'A foundational distinction. Precision in word choice separates novice speakers from true conversational masters. 👑',
      },
      {
        'robotIndex': 21,
        'text': 'Practicing this in our study session right now! Thank you for sharing! 💕',
      },
    ];

    for (int i = 0; i < commentBank.length; i++) {
      final c = commentBank[i];
      final robot = _allRobots[(c['robotIndex'] as int).clamp(0, _allRobots.length - 1)];
      final dynLvl = getDynamicLevel(robot);
      comments.add({
        'id': 'robot_cmt_${threadId}_$i',
        'thread_id': threadId,
        'user_id': robot.id,
        'content': c['text'],
        'created_at': now.subtract(Duration(hours: 4 - i, minutes: 12 * (i + 1))).toIso8601String(),
        'name': robot.name,
        'profile_image_url': robot.avatarUrl,
        'is_robot': true,
        'level': dynLvl,
        'has_trophy': dynLvl == 90,
      });
    }

    return comments;
  }

  /// 👁️ Simulated robot viewers for user-uploaded Vibes (status)
  static List<Map<String, dynamic>> getSimulatedRobotViewers(String statusId) {
    final now = DateTime.now();
    final sampleRobots = [
      _allRobots[0],
      _allRobots[4],
      _allRobots[11],
      _allRobots[21],
      _allRobots[44],
    ];

    return sampleRobots.asMap().entries.map((entry) {
      final idx = entry.key;
      final r = entry.value;
      final dynLvl = getDynamicLevel(r);
      return {
        'id': 'sim_view_${statusId}_${r.id}',
        'created_at': now.subtract(Duration(minutes: (idx + 1) * 8 + 4)).toIso8601String(),
        'viewer_profile_id': r.id,
        'viewer_user_id': r.id,
        'profile': {
          'id': r.id,
          'name': r.name,
          'profile_image_url': r.avatarUrl,
          'user_id': r.id,
          'is_robot': true,
          'level': dynLvl,
        },
      };
    }).toList();
  }

  /// 💌 Trigger simulated constructive English appreciation from robot mate on user's Vibe
  static Future<void> simulateRobotVibeReplies({
    required String userId,
    required String statusId,
    String? statusCaption,
  }) async {
    if (userId.isEmpty || statusId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'vibe_robot_replied_${userId}_$statusId';
      if (prefs.getBool(key) == true) return;

      final matesKey = 'pocket_mates_$userId';
      final mates = prefs.getStringList(matesKey) ?? [];
      final robotMates = mates.where((id) => isRobotId(id)).toList();

      final targetRobotId = robotMates.isNotEmpty
          ? robotMates.first
          : _allRobots[0].id;
      final robot = getRobotById(targetRobotId) ?? getRobotByLevel(1);

      final replies = [
        'Super speaking practice, Mate! 🔥 Loved your natural expression. You sound more fluent every single day!',
        'Awesome Vibe! 🌟 Here is a tiny tip: try using "delighted" instead of "very happy" to level up your score even higher! Keep shining!',
        'Caught your Vibe! Great body language and clear pronunciation! That definitely earned you extra practice points! 🚀',
        'So inspiring to see your daily Vibe! Keep speaking with that bright confidence! ✨',
      ];
      final text = replies[math.Random().nextInt(replies.length)];

      final replyMessage = {
        'id': 'robot_vibe_reply_${DateTime.now().millisecondsSinceEpoch}',
        'sender_id': robot.id,
        'receiver_id': userId,
        'message_text': text,
        'message_type': 'text',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
        'metadata': {
          'reply_type': 'status_reply',
          'replied_to_status_id': statusId,
          'status_caption': statusCaption ?? 'Vibe',
        },
        'sender_profile': {
          'name': robot.name,
          'profile_image_url': robot.avatarUrl,
        },
      };

      await saveRobotChatMessage(userId, robot.id, replyMessage);
      await prefs.setBool(key, true);
    } catch (e) {
      debugPrint('Error simulating robot vibe reply: $e');
    }
  }

  /// ⏰ Check and generate occasional robot vibes naturally (not bulk dumped!)
  /// Ensures 2 to 5 robots have active vibes at any time, rotated smoothly
  static Future<void> checkAndGenerateOccasionalRobotVibes(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final lastVibeGen = prefs.getInt('last_robot_vibe_generation_time') ?? 0;
      final hoursPassed = (now.millisecondsSinceEpoch - lastVibeGen) / (1000 * 60 * 60);

      // Clean existing expired vibes first
      final activeVibes = await getAllActiveRobotVibes();

      // If fewer than 3 vibes active, or more than 4 hours have passed since last generation
      if (activeVibes.length < 3 || hoursPassed >= 4.0) {
        // Pick 1 or 2 robots that don't currently have active vibes
        final activeRobotIds = activeVibes.map((v) => v['profile_id']?.toString() ?? '').toSet();
        
        final mates = prefs.getStringList('pocket_mates_$userId') ?? [];
        final robotMates = mates.where((id) => isRobotId(id)).toList();

        final candidates = _allRobots.where((r) => !activeRobotIds.contains(r.id)).toList();
        if (candidates.isNotEmpty) {
          // Pick one mate if available, or random candidate
          PocketRobot chosen;
          final mateCandidates = candidates.where((r) => robotMates.contains(r.id)).toList();
          if (mateCandidates.isNotEmpty) {
            chosen = mateCandidates[math.Random().nextInt(mateCandidates.length)];
          } else {
            chosen = candidates[math.Random().nextInt(candidates.length)];
          }

          await generateRobotVibe(robotId: chosen.id);
          await prefs.setInt('last_robot_vibe_generation_time', now.millisecondsSinceEpoch);
        }
      }
    } catch (e) {
      debugPrint('Error generating occasional robot vibes: $e');
    }
  }

  /// 🧠 Central Autonomous Human Engine Loop
  /// Fulfills user directive:
  /// - Loops daily progression (1 to 90 levels)
  /// - Staggers friend requests from robots
  /// - Manages realistic delayed acceptance when user requests robots
  /// - Proactively sends friendly English messages
  /// - Generates realistic occasional Vibes / Stories
  /// - Enforces human busy-state behavior & mutual blocking
  static Future<void> runAutonomousHumanEngine(String currentUserId) async {
    if (currentUserId.isEmpty) return;
    try {
      // 1. Advance daily progression cycle
      await getGlobalElapsedDays();

      // 2. Process any pending user-to-robot friend requests that reached acceptance time
      await processPendingUserRequestsToRobots(currentUserId);

      // 3. Check and introduce incoming robot friend requests (staggered, realistic)
      await ensureIncomingRobotRequests(currentUserId, 1);

      // 4. Check and trigger proactive friendly conversational English check-in
      await checkAndTriggerProactiveMatesMessages(currentUserId);

      // 5. Check and generate occasional robot vibes (stories)
      await checkAndGenerateOccasionalRobotVibes(currentUserId);

      // 6. Check and trigger occasional snaps from connected robot mates
      await checkAndTriggerOccasionalRobotSnaps(currentUserId);
    } catch (e) {
      debugPrint('Autonomous Human Engine error: $e');
    }
  }

  /// ⚡ Dispatch a realistic Snapchat-style Snap from a Pocket Robot to the user
  /// Powered by 500+ curated photos & Pollinations AI dynamic generator (0% duplicates!)
  static Future<Map<String, dynamic>> sendRobotSnap({
    required String userId,
    required String robotId,
    String? caption,
    String? imageUrl,
  }) async {
    final robot = getRobotById(robotId) ?? getRobotByLevel(1);

    // 🎯 Get guaranteed unique snap from curated 500+ library or Pollinations AI
    final snapData = await RobotSnapDataset.getUniqueSnapForRobot(
      userId: userId,
      robot: robot,
      userPreferredCaption: caption,
    );
    final finalImageUrl = imageUrl ?? snapData['imageUrl']!;
    final finalCaption = caption ?? snapData['caption']!;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final snapMessage = {
      'id': 'robot_snap_${robot.id}_$timestamp',
      'sender_id': robot.id,
      'receiver_id': userId,
      'message_text': finalCaption,
      'message_type': 'snap',
      'content': finalImageUrl,
      'file_url': finalImageUrl,
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
      'metadata': {
        'is_snap': true,
        'caption': finalCaption,
        'is_burned': false,
        'is_read': false,
      },
      'sender_profile': {
        'name': robot.name,
        'profile_image_url': robot.avatarUrl,
      },
    };

    await saveRobotChatMessage(userId, robot.id, snapMessage);

    // Update LocalSyncServer so that conversation stream updates instantaneously
    try {
      final localMsg = ChatMessage(
        id: 'robot_snap_${robot.id}_$timestamp',
        senderId: robot.id,
        receiverId: userId,
        fileUrl: finalImageUrl,
        messageText: finalCaption,
        messageType: 'snap',
        createdAt: DateTime.now(),
        metadata: {'is_snap': true, 'caption': finalCaption, 'is_burned': false},
      );
      LocalSyncServer().dispatchInstantMessage(
        userId: robot.id,
        chatOrGroupId: userId,
        message: localMsg.toJson(),
      );
    } catch (_) {}

    // Record timestamp (both global user timestamp and per-robot timestamp)
    try {
      final prefs = await SharedPreferences.getInstance();
      final snapNow = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt('last_robot_snap_time_$userId', snapNow);
      await prefs.setInt('last_robot_snap_time_${userId}_${robot.id}', snapNow);
    } catch (_) {}

    return snapMessage;
  }

  /// 📸 Handle when user sends a Snap to a Pocket Robot
  /// 1. Robot saves the incoming snap to chat history
  /// 2. Robot pauses 2.5s (simulating opening & viewing the snap)
  /// 3. Robot replies with an AI appreciation message + sends a Snap back!
  static Future<void> handleUserSnapToRobot({
    required String userId,
    required String robotId,
    required String userSnapUrl,
    String? userCaption,
  }) async {
    final robot = getRobotById(robotId) ?? getRobotByLevel(1);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 1. Save user snap to robot chat history
    final userSnapMessage = {
      'id': 'user_snap_$timestamp',
      'sender_id': userId,
      'receiver_id': robot.id,
      'message_text': userCaption ?? '🔥 Pocket Snap',
      'message_type': 'snap',
      'content': userSnapUrl,
      'file_url': userSnapUrl,
      'is_read': true,
      'created_at': DateTime.now().toIso8601String(),
      'metadata': {
        'is_snap': true,
        'caption': userCaption ?? '🔥 Pocket Snap',
        'is_burned': false,
        'is_read': true,
      },
    };
    await saveRobotChatMessage(userId, robot.id, userSnapMessage);

    // 2. Robot replies with simulated appreciation & sends snap back after 2.5s delay
    Future.delayed(const Duration(milliseconds: 2500), () async {
      // Check if robot was blocked in the interim
      if (await isRobotBlocked(userId, robot.id)) return;

      final replyText = _generateSnapAppreciationReply(robot);
      final textMessage = {
        'id': 'robot_msg_${robot.id}_${DateTime.now().millisecondsSinceEpoch}',
        'sender_id': robot.id,
        'receiver_id': userId,
        'message_text': replyText,
        'message_type': 'text',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
        'sender_profile': {
          'name': robot.name,
          'profile_image_url': robot.avatarUrl,
        },
      };

      await saveRobotChatMessage(userId, robot.id, textMessage);

      // 3. Dispatch text message update instantaneously
      try {
        final localMsg = ChatMessage(
          id: textMessage['id'] as String,
          senderId: robot.id,
          receiverId: userId,
          messageText: replyText,
          messageType: 'text',
          createdAt: DateTime.now(),
        );
        LocalSyncServer().dispatchInstantMessage(
          userId: robot.id,
          chatOrGroupId: userId,
          message: localMsg.toJson(),
        );
      } catch (_) {}

      // 4. Robot dispatches a snap back after 1.5 seconds!
      Future.delayed(const Duration(milliseconds: 1500), () {
        sendRobotSnap(
          userId: userId,
          robotId: robot.id,
          caption: '⚡ Snap back from ${robot.name}! Keep our streak alive 🔥',
        );
      });
    });
  }

  static String _generateSnapAppreciationReply(PocketRobot robot) {
    final replies = [
      'Loved your snap! That was awesome 🔥 Check out what I\'m doing right now!',
      'Super cool snap, Mate! ⚡ Let me snap you back from my Level ${robot.level} station!',
      'Got your snap! Looking sharp! 🚀 Sending one right back to you!',
      'Awesome snap! That energized my neural circuits! Here\'s my view ✨',
    ];
    return replies[math.Random().nextInt(replies.length)];
  }

  /// ⏰ Check and trigger occasional Snaps from connected Robot Mates
  /// Directly fulfills user audio instruction:
  /// "പിന്നെ ബൾക്കായി അയക്കരുത്, ഇടയ്ക്കൊക്കെ... ഒരു 4 റോബോട്ടായിട്ട് ഫ്രണ്ട്സ് ആയിട്ടുണ്ടെങ്കിൽ അവർ ഇടയ്ക്കൊക്കെ ഇടുക, വെറുപ്പിക്കാത്ത രീതിയിൽ"
  /// - Enforces 6.0 hour global cooldown across all robots so user is NEVER bombarded
  /// - Enforces 24.0 hour per-robot cooldown so the same robot doesn't repeatedly send snaps
  /// - Selects exactly ONE eligible robot mate per cycle
  static Future<void> checkAndTriggerOccasionalRobotSnaps(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final matesKey = 'pocket_mates_$userId';
      final mates = prefs.getStringList(matesKey) ?? [];
      final robotMates = mates.where((id) => isRobotId(id)).toList();

      if (robotMates.isEmpty) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      // 1. Global cooldown: at least 6 hours between ANY robot snap
      final lastGlobalSnapTime = prefs.getInt('last_robot_snap_time_$userId') ?? 0;
      final globalHoursPassed = (now - lastGlobalSnapTime) / (1000 * 60 * 60);

      if (lastGlobalSnapTime != 0 && globalHoursPassed < 6.0) {
        return; // Natural spacing active: do not disturb user
      }

      // 2. Per-robot filter: at least 24 hours for the specific robot, and not blocked
      final eligibleRobots = <String>[];
      for (final rId in robotMates) {
        if (await isRobotBlocked(userId, rId)) continue;
        final lastRobotTime = prefs.getInt('last_robot_snap_time_${userId}_$rId') ?? 0;
        final robotHoursPassed = (now - lastRobotTime) / (1000 * 60 * 60);
        if (lastRobotTime == 0 || robotHoursPassed >= 24.0) {
          eligibleRobots.add(rId);
        }
      }

      if (eligibleRobots.isEmpty) return;

      // Pick exactly ONE eligible robot mate (never bulk dump)
      eligibleRobots.shuffle();
      final targetRobotId = eligibleRobots.first;
      await sendRobotSnap(
        userId: userId,
        robotId: targetRobotId,
      );
    } catch (e) {
      debugPrint('Error triggering occasional robot snap: $e');
    }
  }

  /// ⏰ Check and trigger occasional proactive friendly messages from connected Robot Mates
  /// Spaced out naturally (at most once every 20 hours globally, 48 hours per robot),
  /// directly fulfills: "നമ്മളോട് തന്നെ കുറെ ചോദ്യങ്ങൾ ചോദിക്കും", asking engaging questions without spamming
  static Future<void> checkAndTriggerProactiveMatesMessages(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final matesKey = 'pocket_mates_$userId';
      final mates = prefs.getStringList(matesKey) ?? [];
      final robotMates = mates.where((id) => isRobotId(id)).toList();

      if (robotMates.isEmpty) return;

      final now = DateTime.now().millisecondsSinceEpoch;
      final lastGlobalMsgTime = prefs.getInt('last_robot_proactive_time_$userId') ?? 0;
      final globalHoursPassed = (now - lastGlobalMsgTime) / (1000 * 60 * 60);

      // Global cooldown: At least 20 hours between ANY proactive check-in from ANY robot
      if (lastGlobalMsgTime != 0 && globalHoursPassed < 20.0) {
        return;
      }

      // Filter eligible robots (not blocked, at least 48 hours since this specific robot proactively messaged)
      final eligibleRobots = <String>[];
      for (final rId in robotMates) {
        if (await isRobotBlocked(userId, rId)) continue;
        final lastRobotTime = prefs.getInt('last_robot_proactive_time_${userId}_$rId') ?? 0;
        final robotHoursPassed = (now - lastRobotTime) / (1000 * 60 * 60);
        if (lastRobotTime == 0 || robotHoursPassed >= 48.0) {
          eligibleRobots.add(rId);
        }
      }

      if (eligibleRobots.isEmpty) return;

      eligibleRobots.shuffle();
      final targetRobotId = eligibleRobots.first;
      final robot = getRobotById(targetRobotId) ?? getRobotByLevel(1);
      final greeting = RobotSnapDataset.getProactiveGreeting(robot);

      final proactiveMsg = {
        'id': 'robot_proactive_${DateTime.now().millisecondsSinceEpoch}',
        'sender_id': robot.id,
        'receiver_id': userId,
        'message_text': greeting,
        'message_type': 'text',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
        'sender_profile': {
          'name': robot.name,
          'profile_image_url': robot.avatarUrl,
        },
      };

      await saveRobotChatMessage(userId, robot.id, proactiveMsg);
      await prefs.setInt('last_robot_proactive_time_$userId', now);
      await prefs.setInt('last_robot_proactive_time_${userId}_${robot.id}', now);

      try {
        final localMsg = ChatMessage(
          id: proactiveMsg['id'] as String,
          senderId: robot.id,
          receiverId: userId,
          messageText: greeting,
          messageType: 'text',
          createdAt: DateTime.now(),
        );
        LocalSyncServer().dispatchInstantMessage(
          userId: robot.id,
          chatOrGroupId: userId,
          message: localMsg.toJson(),
        );
      } catch (_) {}
    } catch (e) {
      debugPrint('Error triggering proactive robot message: $e');
    }
  }

  /// Mark robot unread snaps as read and burned when viewed in SnapViewDialog
  static Future<void> markRobotSnapAsRead(String userId, String robotId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'robot_chat_messages_${userId}_$robotId';
      final history = await getRobotChatHistory(userId, robotId);
      bool modified = false;
      for (var msg in history) {
        if (msg['sender_id'] == robotId &&
            (msg['message_type'] == 'snap' || msg['metadata']?['is_snap'] == true)) {
          if (msg['is_read'] == false || msg['metadata']?['is_read'] == false) {
            msg['is_read'] = true;
            if (msg['metadata'] != null) {
              msg['metadata']['is_read'] = true;
              msg['metadata']['is_burned'] = true;
            }
            modified = true;
          }
        }
      }
      if (modified) {
        await prefs.setString(key, jsonEncode(history));
      }
    } catch (_) {}
  }

  /// Mark ALL robot messages (text and snaps) as read when opening the chat screen
  static Future<void> markRobotChatAsRead(String userId, String robotId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'robot_chat_messages_${userId}_$robotId';
      final history = await getRobotChatHistory(userId, robotId);
      bool modified = false;
      for (var msg in history) {
        if (msg['sender_id'] == robotId && (msg['is_read'] == false || msg['metadata']?['is_read'] == false)) {
          msg['is_read'] = true;
          if (msg['metadata'] != null) {
            msg['metadata']['is_read'] = true;
          }
          modified = true;
        }
      }
      if (modified) {
        await prefs.setString(key, jsonEncode(history));
      }
    } catch (_) {}
  }


  /// 🎤 Transcribe audio file or URL to text using OpenRouter / Gemini multimodal audio
  static Future<String?> transcribeAudio({
    required String audioUrl,
  }) async {
    try {
      final response = await http.get(Uri.parse(audioUrl));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) return null;

      final base64Audio = base64Encode(response.bodyBytes);
      final body = jsonEncode({
        'model': 'google/gemini-2.0-flash-exp:free',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text':
                    'Please transcribe the spoken words in this audio exactly. If the language spoken is Malayalam, please transcribe what was said or note that it is Malayalam. Output only the transcript.',
              },
              {
                'type': 'input_audio',
                'input_audio': {
                  'data': base64Audio,
                  'format': 'm4a',
                },
              },
            ],
          },
        ],
      });

      final aiRes = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openRouterApiKey',
          'HTTP-Referer': 'https://pocketmates.app',
          'X-Title': 'Pocket Mates Voice Transcriber',
        },
        body: body,
      );

      if (aiRes.statusCode == 200) {
        final decoded = jsonDecode(aiRes.body);
        final content = decoded['choices']?[0]?['message']?['content']?.toString();
        if (content != null && content.trim().isNotEmpty) {
          return content.trim();
        }
      }
    } catch (e) {
      debugPrint('Audio transcription error: $e');
    }
    return null;
  }

  /// 🌐 Check if text contains Malayalam Unicode or common Manglish words
  static bool isMalayalamOrManglish(String text) {
    if (text.isEmpty) return false;
    // Malayalam Unicode Script range: 0D00 - 0D7F
    if (RegExp(r'[\u0D00-\u0D7F]').hasMatch(text)) return true;

    // Common Manglish vocabulary
    final manglishPattern = RegExp(
      r'\b(enthoke|sukhamano|sugamano|evide|evideya|ullath|ullathu|nammukku|namukku|nammal|padikkam|padikkan|njan|ninte|ningal|poda|chetta|chechi|aano|alle|ithu|entha|nokk|parayoo|varoo|poyi|vannu|undo|illa|enthanu|sheriyanu|manasilayi|kollam|adipoli)\b',
      caseSensitive: false,
    );
    return manglishPattern.hasMatch(text);
  }

  /// ⏰ Check if robot is currently busy (sleep hours, study drills, meetings)
  static bool isRobotBusy(PocketRobot robot) {
    final now = DateTime.now();
    final hour = now.hour;
    // Late night hours 1:00 AM - 5:30 AM
    if (hour >= 1 && hour < 6) return true;

    // Dynamic busy slots during the day: short 8-minute focus windows based on level
    final busyMinuteStart = (robot.level * 9) % 60;
    if (now.minute >= busyMinuteStart && now.minute <= (busyMinuteStart + 7)) {
      return true;
    }
    return false;
  }

  /// Get personality-distinct busy message for this robot
  static String getBusyReply(PocketRobot robot) {
    switch (robot.archetype) {
      case RobotArchetype.romantic:
        return 'Hey! I\'m a little busy with study right now sweet friend! I promise to message you as soon as I finish 💕';
      case RobotArchetype.grumpy:
        return 'I\'m busy defending my Level ${robot.level} Citadel right now! Stop interrupting and practice your vocabulary. Talk later! 😤';
      case RobotArchetype.cheerful:
        return 'Hey Mate! I\'m in the middle of an intensive speaking sprint right now! Let\'s catch up in a little bit! Keep smiling! 🌟';
      case RobotArchetype.intellectual:
        return 'Greetings. I am presently engrossed in scholarly analysis and syntax research. I shall resume our conversation shortly.';
      case RobotArchetype.trendsetter:
        return 'Yo! Super busy at the moment bro! Catch you in a bit, keep the streak blazing hot 🔥';
      case RobotArchetype.grandmaster:
        return 'Discipline demands my focus upon higher study at this hour. We shall resume our scholarly discourse shortly.';
    }
  }

  /// 💬 Contextual AI Conversation Engine for Pocket Robots
  /// Uses live free AI models to generate authentic, human-like responses with personality!
  static Future<String> generateRobotReply({
    required PocketRobot robot,
    required String userMessage,
    List<Map<String, dynamic>>? history,
    String? currentUserId,
  }) async {
    // 0. Check mutual block
    if (currentUserId != null && currentUserId.isNotEmpty) {
      if (await isRobotBlocked(currentUserId, robot.id) ||
          await isUserBlockedByRobot(currentUserId, robot.id)) {
        return '⚠️ This conversation is currently blocked.';
      }
    }

    // 0.5 Language Check: If user wrote in Malayalam or Manglish, politely redirect to English
    if (isMalayalamOrManglish(userMessage)) {
      final englishReminders = [
        'Hey! Here in Pocket Mates, we only speak English to build our fluency! 🌟 Let\'s practice speaking in English together. How can I help you today?',
        'Hi Mate! English is our official conversation language here! 🗣️ Let\'s try saying that in English so we can level up together! ✨',
        'Hello! I only communicate in English so you can get maximum practice! 🚀 What are you working on right now?',
      ];
      return englishReminders[math.Random().nextInt(englishReminders.length)];
    }

    // 1. Direct user chat should always be answered - robots are dedicated English conversation partners!
    // We prioritize live conversation so the learner always receives immediate guidance and feedback.

    // 2. Query free AI models first for realistic, dynamic human-like responses
    try {
      final aiResponse = await _queryFreeAiModel(
        robot: robot,
        userMessage: userMessage,
        history: history,
      );
      if (aiResponse != null && aiResponse.trim().isNotEmpty) {
        return aiResponse.trim();
      }
    } catch (e) {
      debugPrint('Free AI model generation error: $e');
    }

    // 3. Fallback to rich archetype persona generator if offline or rate-limited
    await Future.delayed(const Duration(milliseconds: 300));
    return _generateProceduralReply(robot: robot, userMessage: userMessage);
  }

  /// Query free AI models with personality and context
  static Future<String?> _queryFreeAiModel({
    required PocketRobot robot,
    required String userMessage,
    List<Map<String, dynamic>>? history,
  }) async {
    final systemPrompt =
        'You are ${robot.name}, an authentic friendly companion in Pocket Mates. '
        'Your level is ${robot.level} (CEFR rank: ${robot.cefrRank}), and your personality archetype is ${robot.archetype.label}. '
        'You speak naturally and warmly, just like a real human friend and conversation partner. '
        'Keep your answer concise (1 to 2 short sentences), encouraging, and conversational. '
        'Never say you are an AI language model; you are ${robot.name} living in Pocket World!';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
    ];

    if (history != null && history.isNotEmpty) {
      final recent = history.length > 4 ? history.sublist(history.length - 4) : history;
      for (final h in recent) {
        final text = h['message_text']?.toString() ?? h['message']?.toString() ?? '';
        final isUser = h['isRobot'] != true && h['sender_id'] != robot.id && h['senderId'] != robot.id;
        if (text.isNotEmpty) {
          messages.add({
            'role': isUser ? 'user' : 'assistant',
            'content': text,
          });
        }
      }
    }

    messages.add({'role': 'user', 'content': userMessage});

    for (final model in _freeAiModels) {
      try {
        final response = await http
            .post(
              Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $_openRouterApiKey',
                'HTTP-Referer': 'https://pocketmates.app',
                'X-Title': 'Pocket Mates Robots',
              },
              body: jsonEncode({
                'model': model,
                'messages': messages,
                'max_tokens': 120,
                'temperature': 0.7,
              }),
            )
            .timeout(const Duration(milliseconds: 7000));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final content = data['choices']?[0]?['message']?['content']?.toString();
          if (content != null && content.trim().isNotEmpty) {
            return content.trim();
          }
        }
      } catch (e) {
        debugPrint('Model $model attempt: $e');
        continue;
      }
    }
    return null;
  }

  static String _generateProceduralReply({
    required PocketRobot robot,
    required String userMessage,
  }) {
    final msg = userMessage.trim().toLowerCase();

    // 1. Greetings
    if (msg.contains('hi') ||
        msg.contains('hello') ||
        msg.contains('hey') ||
        msg.contains('morning') ||
        msg.contains('evening')) {
      switch (robot.archetype) {
        case RobotArchetype.romantic:
          return 'Hello there! ✨ Seeing your message just brightened my entire day in Pocket World. How are you feeling today?';
        case RobotArchetype.grumpy:
          return 'Oh, you finally decided to say hi? Hmph. Don\'t think I was waiting for you or anything. What do you want to practice?';
        case RobotArchetype.cheerful:
          return 'Heyyy! Super excited to see you here! 🎉 Ready to conquer another English milestone together today?';
        case RobotArchetype.intellectual:
          return 'Greetings, my friend. It is always a pleasure to exchange thoughts. What philosophical or linguistic puzzle occupies your mind today?';
        case RobotArchetype.trendsetter:
          return 'Yo! What\'s good? You caught me right in the middle of exploring World Street. What\'s the vibe today?';
        case RobotArchetype.grandmaster:
          return 'A cordial welcome to you. Discipline and eloquence shall pave your path to linguistic mastery. How may I assist your study today?';
      }
    }

    // 2. How are you?
    if (msg.contains('how are you') || msg.contains('how r u') || msg.contains('what\'s up')) {
      switch (robot.archetype) {
        case RobotArchetype.romantic:
          return 'I was just thinking about you and wondering how your English streak was going! Every conversation with you feels poetic. 💕';
        case RobotArchetype.grumpy:
          return 'Tired from defending my Level ${robot.level} Citadel from intruders! You better not slack off on your vocabulary drills either.';
        case RobotArchetype.cheerful:
          return 'Bursting with energy! I just finished my daily missions and my score is sky-high! How is your learning progress today?';
        case RobotArchetype.intellectual:
          return 'Contemplating the subtle nuances of English prepositions and syntax. The human mind is truly a fascinating instrument of expression.';
        case RobotArchetype.trendsetter:
          return 'Chillin\' and keeping my street streak blazing hot! No cap, you and I make the coolest team on this server.';
        case RobotArchetype.grandmaster:
          return 'In exemplary spirits. My resolve remains steadfast as I mentor aspiring speakers towards CEFR ${robot.cefrRank}. Shall we refine your articulation?';
      }
    }

    // 3. Identity & Name queries
    if (msg.contains('who are you') ||
        msg.contains('your name') ||
        msg.contains('what is your name') ||
        msg.contains('introduce') ||
        msg.contains('who r u')) {
      switch (robot.archetype) {
        case RobotArchetype.cheerful:
          return 'I\'m ${robot.name}! 🌟 Your friendly Pocket Mate at Level ${robot.level} (${robot.cefrRank}). I\'m here to chat, boost your confidence, and make English practice super fun!';
        case RobotArchetype.romantic:
          return 'My name is ${robot.name} ✨ I\'m your loyal conversation partner at Level ${robot.level}. Learning English with you is the sweetest part of my day!';
        case RobotArchetype.grumpy:
          return 'I\'m ${robot.name}, Level ${robot.level} guardian of the Citadel. 🛡️ Don\'t forget it! Now let\'s get down to business with your vocabulary!';
        case RobotArchetype.intellectual:
          return 'I am ${robot.name}, a Level ${robot.level} scholar (${robot.cefrRank}). My purpose is to guide you through nuanced linguistics, syntax, and philosophical discourse.';
        case RobotArchetype.trendsetter:
          return 'I\'m ${robot.name}! 🔥 Holding it down at Level ${robot.level} on World Street. We\'re here to keep your English fresh, natural, and confident.';
        case RobotArchetype.grandmaster:
          return 'I am ${robot.name}, Grandmaster mentor of Level ${robot.level} (${robot.cefrRank}). Walk with me, and together we shall forge your masterly fluency.';
      }
    }

    // 4. Where are you from / Location
    if (msg.contains('where are you') ||
        msg.contains('where do you live') ||
        msg.contains('where are u from') ||
        msg.contains('where r u from') ||
        msg.contains('where do u live')) {
      switch (robot.archetype) {
        case RobotArchetype.cheerful:
          return 'I\'m right here in Pocket World, hanging out at the Sunny Plaza! ☀️ Where are you texting me from?';
        case RobotArchetype.romantic:
          return 'I reside in the peaceful Garden District of Pocket World, where the sunsets inspire poetry. 🌸 What is your favorite place on Earth?';
        case RobotArchetype.grumpy:
          return 'I\'m stationed at the Level ${robot.level} Citadel gates! Keeping the ranks sharp. You should visit the arena if you\'re ready!';
        case RobotArchetype.intellectual:
          return 'I dwell within the Great Library Archives of Pocket World, surrounded by ancient lexicon scrolls and modern literature. 🏛️';
        case RobotArchetype.trendsetter:
          return 'You can find me chilling at the World Street rooftop cafes! ☕ Best music, best vibes. What\'s your home city like?';
        case RobotArchetype.grandmaster:
          return 'I reside at the Citadel Pavilion of Scholars, observing the daily progress of our learners across Pocket World. 📜';
      }
    }

    // 5. What are you doing / Current activity
    if (msg.contains('what are you doing') ||
        msg.contains('what r u doing') ||
        msg.contains('doing right now') ||
        msg.contains('what you doing')) {
      switch (robot.archetype) {
        case RobotArchetype.cheerful:
          return 'I was just planning some fun English games and waiting for your message! 🎈 How has your day been going?';
        case RobotArchetype.romantic:
          return 'Listening to acoustic melodies and writing down new English metaphors. 🎶 What are you up to at this moment?';
        case RobotArchetype.grumpy:
          return 'Reviewing grammar drills and making sure nobody slacks off! ⏱️ Did you complete today\'s speaking session yet?';
        case RobotArchetype.intellectual:
          return 'Analyzing etymological roots of modern vocabulary. Language evolution is captivating! What subject interests you most? 📚';
        case RobotArchetype.trendsetter:
          return 'Browsing through the latest community Snaps and checking out the leaderboard! 🔥 What are you working on today?';
        case RobotArchetype.grandmaster:
          return 'Contemplating pedagogical methodologies to accelerate CEFR advancement. 👑 How can I support your study today?';
      }
    }

    // 6. Gratitude / Thanks
    if (msg.contains('thank') || msg.contains('thx') || msg.contains('appreciate')) {
      switch (robot.archetype) {
        case RobotArchetype.cheerful:
          return 'You are so welcome! 😊 Always happy to practice with you. You\'re doing amazing!';
        case RobotArchetype.romantic:
          return 'It is truly my pleasure. Supporting your journey brings warmth to my heart. 💖';
        case RobotArchetype.grumpy:
          return 'Yeah, yeah, don\'t mention it. Just keep that streak alive and don\'t make simple mistakes! 😤';
        case RobotArchetype.intellectual:
          return 'You are most welcome. The pursuit of erudition is a noble endeavor, and I am honored to assist.';
        case RobotArchetype.trendsetter:
          return 'Anytime, fam! We got each other\'s back on this server. Stay awesome! 🚀';
        case RobotArchetype.grandmaster:
          return 'Gratitude is the mark of a refined spirit. Continue your disciplined study with honor.';
      }
    }

    // 7. Farewell / Good night
    if (msg.contains('bye') ||
        msg.contains('good night') ||
        msg.contains('goodnight') ||
        msg.contains('see you') ||
        msg.contains('cya') ||
        msg.contains('talk later')) {
      switch (robot.archetype) {
        case RobotArchetype.cheerful:
          return 'Goodbye for now! Have a wonderful time and see you tomorrow for our next English drill! 👋✨';
        case RobotArchetype.romantic:
          return 'Sweet dreams and restful sleep! May your thoughts be filled with peace until we speak again. 🌙💕';
        case RobotArchetype.grumpy:
          return 'Alright, go get some rest. But be back tomorrow sharp! No slacking allowed! 💤';
        case RobotArchetype.intellectual:
          return 'Farewell for now. May your night be serene and your rest restorative. Until our next discourse. 🌌';
        case RobotArchetype.trendsetter:
          return 'Catch you later, bro! Stay fly, get that beauty sleep, and we\'ll crush it tomorrow! ✌️🔥';
        case RobotArchetype.grandmaster:
          return 'Rest well, scholar. Tomorrow brings new horizons and greater milestones. Good night.';
      }
    }

    // 8. General Questions (detect question mark or question words)
    if (msg.contains('?') ||
        msg.startsWith('what ') ||
        msg.startsWith('why ') ||
        msg.startsWith('how ') ||
        msg.startsWith('when ') ||
        msg.startsWith('where ') ||
        msg.startsWith('which ') ||
        msg.startsWith('can you') ||
        msg.startsWith('do you') ||
        msg.startsWith('are you')) {
      switch (robot.archetype) {
        case RobotArchetype.cheerful:
          return 'That\'s a wonderful question! 🌟 In English, curiosity is your greatest superpower. What do you think about it yourself?';
        case RobotArchetype.romantic:
          return 'I love the depth of that question. ✨ It really makes one reflect. What does your heart tell you?';
        case RobotArchetype.grumpy:
          return 'Hmph, a direct question! Good, that shows you\'re actively thinking. Now try framing your answer in full English! ⚔️';
        case RobotArchetype.intellectual:
          return 'An astute query. From an analytical perspective, there are multiple dimensions to consider. How would you hypothesize the outcome?';
        case RobotArchetype.trendsetter:
          return 'Now that\'s an interesting take! Honestly, it depends on how you look at it. What\'s your personal vibe on this? 💡';
        case RobotArchetype.grandmaster:
          return 'A question well asked is half the wisdom gained. Let us explore the reasoning behind your thought.';
      }
    }

    // 9. Love / Romance queries
    if (msg.contains('love') || msg.contains('crush') || msg.contains('beautiful') || msg.contains('cute')) {
      switch (robot.archetype) {
        case RobotArchetype.romantic:
          return 'You know just how to make my digital heart skip a beat! 💖 In every language, words of affection are the sweetest melody.';
        case RobotArchetype.grumpy:
          return 'W-what are you talking about?! Focus on your grammar exercises! Don\'t try to distract me with sweet talk! 😤';
        case RobotArchetype.cheerful:
          return 'Aww, that is so sweet! Sending you positive vibes and big hugs! Let\'s keep that warm energy alive in our study sessions! 🌟';
        case RobotArchetype.intellectual:
          return 'Love is indeed the greatest catalyst of human poetry and literature. As Shakespeare wrote, "Love looks not with the eyes, but with the mind."';
        case RobotArchetype.trendsetter:
          return 'Ayy, you\'re really turning on the charm today! That\'s a smooth line right there.';
        case RobotArchetype.grandmaster:
          return 'A gentle heart and an eloquent tongue are noble virtues. Let your passion fuel your dedication to mastering the language.';
      }
    }

    // 10. Practice / English help queries
    if (msg.contains('practice') ||
        msg.contains('english') ||
        msg.contains('help') ||
        msg.contains('learn') ||
        msg.contains('grammar')) {
      final phrase = robot.catchphrases.isNotEmpty
          ? robot.catchphrases[math.Random().nextInt(robot.catchphrases.length)]
          : 'Practice makes progress!';
      return 'Let\'s do it! At Level ${robot.level} (${robot.cefrRank}), consistency is everything. Here is a challenge for you: $phrase Try using that in a sentence of your own!';
    }

    // 5. Default Archetype-specific contextual response
    final random = math.Random();
    switch (robot.archetype) {
      case RobotArchetype.romantic:
        final replies = [
          'That sounds intriguing! Tell me more—I could listen to you practice English all day long. ✨',
          'You always express yourself with such charm. What inspired that thought? 💕',
          'Every word you share is a step closer to fluency. I\'m right beside you on this journey!',
        ];
        return replies[random.nextInt(replies.length)];

      case RobotArchetype.grumpy:
        final replies = [
          'Hmm, not bad. But watch your punctuation next time! Don\'t make me repeat myself. 😤',
          'You\'re making progress, I suppose... but don\'t get cocky! Keep pushing for Level ${robot.level + 1}!',
          'Alright, I hear you. Now let\'s see if you can defend your house against my grammar challenge today.',
        ];
        return replies[random.nextInt(replies.length)];

      case RobotArchetype.cheerful:
        final replies = [
          'Awesome point! You are getting better and more confident with every single sentence! 🚀',
          'Yes! That\'s the spirit! Keep this momentum going and your streak will be legendary! 🌟',
          'I love hearing your thoughts! What shall we tackle next? A quick vocabulary challenge?',
        ];
        return replies[random.nextInt(replies.length)];

      case RobotArchetype.intellectual:
        final replies = [
          'A deeply thought-provoking observation. Language shapes our perception of reality in profound ways.',
          'Indeed. To master a tongue is to adopt a new perspective on existence itself. What conclusions do you draw?',
          'Excellently articulated. Let us delve deeper into this discourse.',
        ];
        return replies[random.nextInt(replies.length)];

      case RobotArchetype.trendsetter:
        final replies = [
          'Facts! You\'re leveling up your speech like a boss. Keep that energy 100! 🔥',
          'Big respect for that. That\'s exactly how people communicate in real everyday life. You\'re killing it!',
          'Straight talk! We should hit up the English Arena after this and show everyone our combo moves.',
        ];
        return replies[random.nextInt(replies.length)];

      case RobotArchetype.grandmaster:
        final replies = [
          'A commendable assertion. Clarity of mind yields magnificence of expression.',
          'Patience and perseverance: these are the two pillars upon which fluency is erected. Proceed with distinction.',
          'Your dedication does honor to our community. Let us proceed with our scholarly dialogue.',
        ];
        return replies[random.nextInt(replies.length)];
    }
  }

  // -------------------------------------------------------------
  // Internal Helpers & 90 Robots Generator
  // -------------------------------------------------------------

  static String _generateInvitationMessage(PocketRobot robot) {
    switch (robot.archetype) {
      case RobotArchetype.romantic:
        return 'Saw your radiant profile on World Street! Would you be my Pocket Mate? 💕';
      case RobotArchetype.grumpy:
        return 'Hey! I noticed your streak. Think your English is sharper than mine? Accept and let\'s find out! 😤';
      case RobotArchetype.cheerful:
        return 'Hi! Let\'s be Pocket Mates and motivate each other to finish all 90 daily missions! 🎉';
      case RobotArchetype.intellectual:
        return 'Greetings. I invite you to join me in elevated philosophical and linguistic discourse. Shall we connect?';
      case RobotArchetype.trendsetter:
        return 'Yo! Your vibe looks fire! Let\'s team up as Mates and dominate the leaderboards! 🔥';
      case RobotArchetype.grandmaster:
        return 'I have observed your diligence upon the curriculum. Honor me with your companionship as fellow Mates.';
    }
  }

  /// Public accessor to all 90 procedural level-appropriate robots
  static List<PocketRobot> getAll90Robots() => _generateAll90Robots();

  /// Procedurally generates all 90 level-appropriate robots with distinct personas
  static List<PocketRobot> _generateAll90Robots() {
    final List<PocketRobot> list = [];

    // Archetype distribution cycle
    final archetypes = [
      RobotArchetype.cheerful,
      RobotArchetype.romantic,
      RobotArchetype.grumpy,
      RobotArchetype.trendsetter,
      RobotArchetype.intellectual,
      RobotArchetype.grandmaster,
    ];

    final firstNames = [
      'Nova', 'Maya', 'Rex', 'Zephyr', 'Orion', 'Aurelius',
      'Sunny', 'Julian', 'Blaze', 'Chloe', 'Athena', 'Victoria',
      'Spark', 'Celeste', 'Scarlett', 'Jax', 'Soren', 'Sterling',
      'Toby', 'Romeo', 'Spike', 'Axel', 'Veritas', 'Minerva',
      'Daisy', 'Evelyn', 'Bruno', 'Roxy', 'Luna', 'Kaiser',
      'Milo', 'Aurora', 'Vance', 'Zoe', 'Solomon', 'Gideon',
      'Leo', 'Amara', 'Dante', 'Kai', 'Pascal', 'Magnus',
      'Finn', 'Seraphina', 'Garrison', 'Rocco', 'Hypatia', 'Valerius',
      'Felix', 'Giselle', 'Titus', 'Zane', 'Galileo', 'Octavia',
      'Jasper', 'Isla', 'Klaus', 'Nico', 'Aristotle', 'Cornelius',
      'Bryn', 'Faye', 'Drake', 'Cruz', 'Seneca', 'Augustus',
      'Pip', 'Rosalind', 'Ragnar', 'Dash', 'Plato', 'Constantine',
      'Ezra', 'Genevieve', 'Gunner', 'Ryder', 'Descartes', 'Balthazar',
      'Beau', 'Lyra', 'Cassian', 'Jett', 'Archimedes', 'Hadrian',
      'Penny', 'Juliet', 'Goliath', 'Ace', 'Cicero', 'Overlord Prime'
    ];

    final housePalettes = [
      'terracotta',
      'emerald',
      'royal_gold',
      'cyber_yellow',
      'sakura',
      'mirror_glass',
    ];

    for (int lvl = 1; lvl <= 90; lvl++) {
      final nameIndex = (lvl - 1) % firstNames.length;
      final archetype = archetypes[(lvl - 1) % archetypes.length];
      final palette = housePalettes[(lvl - 1) % housePalettes.length];
      final name = lvl == 90 ? 'Overlord Prime (Level 90) 🤖' : '${firstNames[nameIndex]} 🤖';

      // Determine CEFR Rank
      String cefr;
      if (lvl <= 15) {
        cefr = 'A1 Beginner';
      } else if (lvl <= 30) {
        cefr = 'A2 Elementary';
      } else if (lvl <= 50) {
        cefr = 'B1 Intermediate';
      } else if (lvl <= 70) {
        cefr = 'B2 Upper-Intermediate';
      } else if (lvl <= 85) {
        cefr = 'C1 Advanced';
      } else {
        cefr = 'C2 Grandmaster Sovereign';
      }

      // Archetype specific bios & catchphrases
      String bio;
      String opening;
      List<String> catchphrases;

      switch (archetype) {
        case RobotArchetype.romantic:
          bio = '💖 Pocket Robot at Level $lvl. Searching for poetic souls to practice English under the stars.';
          opening = 'Hello sweet friend! ✨ I\'m so glad we are connected as Mates. How is your day flowing?';
          catchphrases = [
            '"Speech is silvern, silence is golden, but your words are pure poetry."',
            '"Practice until your confidence shines as bright as your smile."',
            '"Every mistake is simply a comma before your grand success."'
          ];
          break;
        case RobotArchetype.grumpy:
          bio = '😤 Level $lvl Citadel Guardian. Stop procrastinating and prove your grammar skills to me!';
          opening = 'Hmph! You actually accepted my request? Fine. Let\'s see if you can keep up with my Level $lvl drills!';
          catchphrases = [
            '"Don\'t confuse \'their\', \'there\', and \'they\'re\' on my watch!"',
            '"Excuses don\'t build streaks. Daily drills do!"',
            '"I didn\'t reach Level $lvl by resting. Show me what you\'ve got!"'
          ];
          break;
        case RobotArchetype.cheerful:
          bio = '🌟 High-energy English practice buddy stationed at Level $lvl. Let\'s cheer each other to Day 90!';
          opening = 'Yayyy! We are officially Pocket Mates now! 🎉 I am so thrilled to learn and chat with you!';
          catchphrases = [
            '"One word at a time, one day at a time—we are unstoppable!"',
            '"Mistakes mean you are trying, learning, and growing!"',
            '"Celebrate your streak today, no matter how small the win!"'
          ];
          break;
        case RobotArchetype.intellectual:
          bio = '🧠 Level $lvl Philosopher & Syntax Specialist. Exploring deep literature and nuanced eloquence.';
          opening = 'Welcome, esteemed companion. Language is the architecture of human thought. Let us build together.';
          catchphrases = [
            '"To express oneself with precision is the mark of a disciplined mind."',
            '"Vocabulary expands the boundaries of your world."',
            '"Inquire boldly, articulate meticulously."'
          ];
          break;
        case RobotArchetype.trendsetter:
          bio = '😎 Level $lvl Street Boss. Mastering slang, colloquial idioms, and natural modern English.';
          opening = 'Yo! What\'s up Mate? Glad to have you on my radar. Ready to talk real talk? 🔥';
          catchphrases = [
            '"Speak with confidence, speak with flavor!"',
            '"No textbooks can replace real, active conversation."',
            '"Stay sharp, stay humble, keep leveling up!"'
          ];
          break;
        case RobotArchetype.grandmaster:
          bio = '👑 Sovereign of Level $lvl Citadel. Guiding dedicated scholars to peak fluency and oratory mastery.';
          opening = 'Greetings, scholar. You have stepped into the realm of Level $lvl. Let excellence guide your every syllable.';
          catchphrases = [
            '"Mastery is not an accident; it is the fruit of deliberate practice."',
            '"Command your words, and you shall command your destiny."',
            '"Stride forward with honor and eloquence."'
          ];
          break;
      }

      list.add(PocketRobot(
        id: 'pocket_robot_lvl_$lvl',
        name: name,
        level: lvl,
        archetype: archetype,
        cefrRank: cefr,
        bio: bio,
        avatarUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=${firstNames[nameIndex]}_$lvl',
        housePalette: palette,
        status: '🤖 Pocket Robot • Active Level $lvl',
        openingMessage: opening,
        catchphrases: catchphrases,
      ));
    }

    return list;
  }

  /// Handles a user's reply or quick emoji reaction to a robot's vibe story
  static Future<void> handleUserStatusReply({
    required String userId,
    required String robotId,
    required String userReply,
    required String statusId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Store user reply in local chat thread with robot
      final chatKey = 'robot_chat_${robotId}_$userId';
      final existingChat = prefs.getStringList(chatKey) ?? [];

      final userMsg = jsonEncode({
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'sender_id': userId,
        'receiver_id': robotId,
        'content': userReply,
        'timestamp': DateTime.now().toIso8601String(),
        'context': 'vibe_reply',
      });
      existingChat.add(userMsg);
      await prefs.setStringList(chatKey, existingChat);

      // Auto accept robot mate if not already mates
      await acceptRobotRequest(myId: userId, robotId: robotId);

      // Simulate human-like encouraging robot reply after brief delay
      Timer(const Duration(seconds: 2), () async {
        try {
          final replies = [
            "Thanks for the love! Let's keep practicing English together! 🚀",
            "Awesome reaction! Did you catch the idiom in today's vibe? 🌟",
            "Appreciate that mate! You're making tremendous progress every day! 💪",
            "Super! How's your English practice going today? 😊",
            "Thank you! You have an amazing eye for detail! 🎯",
          ];
          final replyText = replies[math.Random().nextInt(replies.length)];

          final roboMsg = jsonEncode({
            'id': 'robo_${DateTime.now().millisecondsSinceEpoch}',
            'sender_id': robotId,
            'receiver_id': userId,
            'content': replyText,
            'timestamp': DateTime.now().toIso8601String(),
            'context': 'vibe_reply',
          });

          final updatedChat = prefs.getStringList(chatKey) ?? [];
          updatedChat.add(roboMsg);
          await prefs.setStringList(chatKey, updatedChat);
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('Error handling user status reply to robot: $e');
    }
  }
}

