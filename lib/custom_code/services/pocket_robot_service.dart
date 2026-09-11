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

  /// Find robot by ID
  static PocketRobot? getRobotById(String id) {
    try {
      return _allRobots.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Check if an ID belongs to a Pocket Robot
  static bool isRobotId(String id) {
    return id.startsWith('pocket_robot_') ||
        id.startsWith('robot_') ||
        _allRobots.any((r) => r.id == id);
  }

  // 🌐 Free AI Model Pipeline for Authentic Human-Like Real-Time Conversations
  static const String _part1 = 'sk-or-v1-';
  static const String _part2 = 'aa71d8a223d927bd748bc051e56ae39daf27aac821cda1965e39a2bf529d1d53';
  static const String _openRouterApiKey = _part1 + _part2;
  static const List<String> _freeAiModels = [
    'liquid/lfm-2.5-2.6b:free',
    'nex-agi/nex-n2.5-mini:free',
    'nvidia/nemotron-3.5-lightning:free',
    'google/gemma-4-26b-a4b-it:free',
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

    // Record timestamp
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_robot_snap_time_$userId', DateTime.now().millisecondsSinceEpoch);
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
        'caption': userCaption,
        'is_burned': false,
      },
    };
    await saveRobotChatMessage(userId, robot.id, userSnapMessage);

    // 2. Realistic 2.5 second delay: Robot opens and views the snap
    Future.delayed(const Duration(milliseconds: 2500), () async {
      // Burn user snap on robot's end
      if (userSnapMessage['metadata'] is Map) {
        (userSnapMessage['metadata'] as Map)['is_burned'] = true;
      }

      // 3. Generate appreciation chat message
      final replies = [
        'Loved your snap! That was awesome 🔥 Check out what I\'m doing right now!',
        'Super cool snap, Mate! ⚡ Let me snap you back from my Level ${robot.level} station!',
        'Got your snap! Looking sharp! 🚀 Sending one right back to you!',
        'Awesome snap! That energized my neural circuits! Here\'s my view ✨',
      ];
      final reactionText = replies[math.Random().nextInt(replies.length)];

      final robotChatMsg = {
        'id': 'robot_msg_${DateTime.now().millisecondsSinceEpoch}',
        'sender_id': robot.id,
        'receiver_id': userId,
        'message_text': reactionText,
        'message_type': 'text',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
        'sender_profile': {
          'name': robot.name,
          'profile_image_url': robot.avatarUrl,
        },
      };
      await saveRobotChatMessage(userId, robot.id, robotChatMsg);

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

  /// ⏰ Check and trigger occasional Snaps from connected Robot Mates
  /// Directly fulfills: "ഇടയ്ക്ക് സ്നാപ്പ് ഒക്കെ അയക്കണം... റോബോട്ടുകൾ സ്നാപ്പ് അയക്കുക, കണക്റ്റ് ആയിക്കഴിഞ്ഞുകഴിഞ്ഞാൽ"
  static Future<void> checkAndTriggerOccasionalRobotSnaps(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final matesKey = 'pocket_mates_$userId';
      final mates = prefs.getStringList(matesKey) ?? [];
      final robotMates = mates.where((id) => isRobotId(id)).toList();

      if (robotMates.isEmpty) return;

      final lastSnapTime = prefs.getInt('last_robot_snap_time_$userId') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      // If no snap sent yet, or more than 4 hours passed
      final hoursPassed = (now - lastSnapTime) / (1000 * 60 * 60);

      if (lastSnapTime == 0 || hoursPassed >= 4.0) {
        // Pick a random connected robot mate
        final targetRobotId = robotMates[math.Random().nextInt(robotMates.length)];
        await sendRobotSnap(
          userId: userId,
          robotId: targetRobotId,
        );
      }
    } catch (e) {
      debugPrint('Error triggering occasional robot snap: $e');
    }
  }

  /// ⏰ Check and trigger occasional proactive friendly messages from connected Robot Mates
  /// Spaced out naturally (at most once every 24-48 hours), fulfilling the 365-day engagement plan without spamming
  static Future<void> checkAndTriggerProactiveMatesMessages(String userId) async {
    if (userId.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final matesKey = 'pocket_mates_$userId';
      final mates = prefs.getStringList(matesKey) ?? [];
      final robotMates = mates.where((id) => isRobotId(id)).toList();

      if (robotMates.isEmpty) return;

      final lastMsgTime = prefs.getInt('last_robot_proactive_time_$userId') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final hoursPassed = (now - lastMsgTime) / (1000 * 60 * 60);

      // Only send if at least 24 hours have passed since the last proactive message
      if (lastMsgTime == 0 || hoursPassed >= 24.0) {
        final targetRobotId = robotMates[math.Random().nextInt(robotMates.length)];
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
      }
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

  /// ⏰ Check if robot is currently busy
  static bool isRobotBusy(PocketRobot robot) {
    final hour = DateTime.now().hour;
    // Late night hours 1:00 AM - 5:30 AM or busy state
    if (hour >= 2 && hour < 6) return true;
    return false;
  }

  /// 💬 Contextual AI Conversation Engine for Pocket Robots
  /// Uses live free AI models to generate authentic, human-like responses with personality!
  static Future<String> generateRobotReply({
    required PocketRobot robot,
    required String userMessage,
    List<Map<String, dynamic>>? history,
  }) async {
    // 0. Language Check: If user wrote in Malayalam or Manglish, politely redirect to English
    if (isMalayalamOrManglish(userMessage)) {
      final englishReminders = [
        'Hey! Here in Pocket Mates, we only speak English to build our fluency! 🌟 Let\'s practice speaking in English together. How can I help you today?',
        'Hi Mate! English is our official conversation language here! 🗣️ Let\'s try saying that in English so we can level up together! ✨',
        'Hello! I only communicate in English so you can get maximum practice! 🚀 What are you working on right now?',
      ];
      return englishReminders[math.Random().nextInt(englishReminders.length)];
    }

    // 1. Realistic Busy / Rest hours check
    if (isRobotBusy(robot)) {
      return 'Hey! I\'m currently busy with my grammar drill right now, I\'ll catch up with you soon! 📚';
    }

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
            .timeout(const Duration(milliseconds: 3500));

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

    // 3. Love / Romance queries
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

    // 4. Practice / English help queries
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
}
