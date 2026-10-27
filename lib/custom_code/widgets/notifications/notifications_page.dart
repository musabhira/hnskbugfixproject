import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_models.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/main_profile_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_citadel_fight_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_fight_dialog.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

/// Notifications & Mutual Pocket Mate Connection Requests Screen
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _supabase = SupaFlow.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _connectionRequests = [];
  List<Map<String, dynamic>> _activityAlerts = [];
  List<CitadelFightChallenge> _pendingFights = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // 0. Ensure user has peer robot mate requests active
      await PocketRobotService.ensureIncomingRobotRequests(myId, 1);

      // 1. Fetch real pending mate requests from Supabase via PocketMateService
      final dbReqs = await PocketMateService.getPendingRequests(myId);
      List<Map<String, dynamic>> requests = [];

      for (final r in dbReqs) {
        requests.add({
          'id': r['id'],
          'senderId': r['sender_id'] ?? r['source_id'],
          'senderName': r['sender_name'] ?? 'Pocket Mate',
          'stage': r['stage'] ?? 1,
          'message': r['message'] ?? 'Wants to become your Pocket Mate.',
          'time': r['created_at'] ?? DateTime.now().toIso8601String(),
          'isRobot': r['is_robot'] == true || PocketRobotService.isRobotId(r['sender_id']?.toString() ?? ''),
          'archetype': r['archetype'],
          'type': r['type'] ?? 'mate_request',
          'context_type': r['data'] is Map ? r['data']['context_type'] : r['context_type'],
          'avatarUrl': r['avatar_url'] ?? r['sender_profile_image'],
          'avatarConfig': r['avatar_config'],
          'sender_profile_image': r['sender_profile_image'] ?? r['avatar_url'],
        });
      }

      // Also check local pending requests
      final prefs = await SharedPreferences.getInstance();
      final reqStr = prefs.getString('pending_pocket_requests_$myId');
      if (reqStr != null && reqStr.isNotEmpty) {
        try {
          final localReqs = List<Map<String, dynamic>>.from(jsonDecode(reqStr));
          for (final lr in localReqs) {
            if (!requests.any((x) => x['id'] == lr['id'])) {
              requests.add(lr);
            }
          }
        } catch (_) {}
      }

      // Fetch all activity and community notifications from database
      final List<Map<String, dynamic>> alerts = [];
      try {
        final notifsRes = await _supabase
            .from('notifications')
            .select('*')
            .eq('user_id', myId)
            .order('created_at', ascending: false)
            .limit(100);

        for (final n in (notifsRes as List)) {
          final type = n['type']?.toString().toLowerCase() ?? 'alert';
          String icon = '🔔';
          String defaultTitle = 'Notification';
          if (type.contains('citadel') || type.contains('raid') || type.contains('attack') || type.contains('fortress')) {
            icon = '⚔️';
            defaultTitle = 'Citadel Raid Alert';
          } else if (type.contains('pocket_talk_accepted')) {
            icon = '🤝';
            defaultTitle = 'Pocket Talk Accepted';
          } else if (type.contains('pocket_talk') || type.contains('pact') || type.contains('talk')) {
            icon = '⚡';
            defaultTitle = 'Pocket Talk 4-Day Pact';
          } else if (type.contains('language_warning') || type.contains('presidential')) {
            icon = '🏛️';
            defaultTitle = '🏛️ Presidential Notice';
          } else if (type.contains('trophy')) {
            icon = '🏆';
            defaultTitle = '🏆 Pocket Trophy Awarded';
          } else if (type.contains('mate_accepted')) {
            icon = '✨';
            defaultTitle = 'Mate Connected';
          } else if (type.contains('mate_request')) {
            icon = '🤝';
            defaultTitle = 'Mate Request';
          } else if (type.contains('vibe_reply')) {
            icon = '💬';
            defaultTitle = 'Vibe Reply';
          } else if (type.contains('vibe_like')) {
            icon = '❤️';
            defaultTitle = 'Vibe Liked';
          } else if (type.contains('vibe') || type.contains('status')) {
            icon = '✨';
            defaultTitle = 'Vibe Activity';
          } else if (type.contains('thought') || type.contains('thread')) {
            icon = '💭';
            defaultTitle = 'Thought Activity';
          } else if (type.contains('score') || type.contains('streak') || type.contains('level')) {
            icon = '🔥';
            defaultTitle = 'Streak & Level';
          }

          final data = n['data'] is Map ? n['data'] as Map : null;
          final thumbnail = data?['media_url']?.toString() ?? n['media_url']?.toString();

          alerts.add({
            'id': n['id']?.toString() ?? '',
            'type': type,
            'sourceId': n['source_id']?.toString() ?? '',
            'senderId': n['sender_id']?.toString() ?? '',
            'status': n['status']?.toString() ?? '',
            'icon': icon,
            'title': n['title'] ?? defaultTitle,
            'body': n['message'] ?? n['body'] ?? n['content'] ?? 'New notification received.',
            'time': n['created_at'] != null ? timeago.format(DateTime.tryParse(n['created_at'].toString()) ?? DateTime.now()) : 'Recently',
            'thumbnail': thumbnail,
          });
        }

        // Include robot classmate thought likes
        final robotLikedThreads = prefs.getStringList('robot_liked_threads_$myId') ?? [];
        if (robotLikedThreads.isNotEmpty) {
          alerts.insert(0, {
            'id': 'robot_thought_like',
            'icon': '❤️',
            'title': 'Thought Liked 🤖',
            'body': 'Atlas and your robot classmates liked your shared thoughts!',
            'time': 'Recently',
            'thumbnail': null,
          });
        }
      } catch (e) {
        debugPrint('Error fetching DB notifications: $e');
      }

      // Fetch official Presidential Announcements / decrees
      try {
        final annRes = await _supabase
            .from('announcements')
            .select('*')
            .order('created_at', ascending: false)
            .limit(25);

        for (final a in (annRes as List)) {
          alerts.add({
            'id': a['id']?.toString() ?? '',
            'icon': '🏛️',
            'title': a['title'] ?? '🏛️ Presidential Decree',
            'body': a['content'] ?? a['message'] ?? 'Official update from The President.',
            'time': a['created_at'] != null ? timeago.format(DateTime.tryParse(a['created_at'].toString()) ?? DateTime.now()) : 'Recently',
          });
        }
      } catch (_) {}

      // Ensure rich alerts are present for robot snaps, PocketTalk pacts, mate connections, and level achievements
      final atlasRobot = PocketRobotService.getRobotById('robot_atlas');
      final novaRobot = PocketRobotService.getRobotById('robot_nova');
      final zaraRobot = PocketRobotService.getRobotById('robot_zara');

      final defaultAlerts = [
        {
          'id': 'snap_atlas_moment',
          'icon': '📸',
          'badge': '📸',
          'title': 'Atlas sent you a Snap Moment',
          'body': '📸 "English study & coffee drill at the library! Check it out."',
          'time': '12m ago',
          'avatarUrl': atlasRobot?.avatarUrl,
          'thumbnail': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400&q=80',
        },
        {
          'id': 'pact_nova_invite',
          'icon': '⚡',
          'badge': '⚡',
          'title': 'PocketTalk 4-Day Pact Active',
          'body': 'Nova accepted your 4-Day Spoken English Pact! Day 1 speaking goal starts now.',
          'time': '45m ago',
          'avatarUrl': novaRobot?.avatarUrl,
        },
        {
          'id': 'mate_zara_connected',
          'icon': '🤝',
          'badge': '✨',
          'title': 'Pocket Mate Connected',
          'body': 'You and Zara are now verified Pocket Mates! Start your daily audio drills.',
          'time': '2h ago',
          'avatarUrl': zaraRobot?.avatarUrl,
        },
        {
          'id': 'level_milestone_unlocked',
          'icon': '🏆',
          'badge': '⭐',
          'title': 'Level Milestone: Stage 3 Unlocked',
          'body': 'Congratulations! You advanced to Intermediate Speaker Stage 3. Claim +120 XP reward.',
          'time': 'Today',
        },
        {
          'id': 'streak_consistency_alert',
          'icon': '🔥',
          'badge': '🔥',
          'title': '7-Day Fluency Streak Active',
          'body': 'Outstanding consistency! Practice today to protect your streak against inactivity decay.',
          'time': 'Yesterday',
        },
      ];

      for (final da in defaultAlerts) {
        if (!alerts.any((a) => a['id'] == da['id'])) {
          alerts.add(da);
        }
      }

      // Clear and mark notifications as read in Supabase and SharedPreferences
      try {
        await _supabase
            .from('notifications')
            .update({'is_read': true})
            .eq('user_id', myId);
      } catch (_) {}
      await prefs.setInt('unread_notifs_count_$myId', 0);

      final fights = await PocketCitadelFightService.getPendingChallenges(myId);

      if (mounted) {
        setState(() {
          _connectionRequests = requests;
          _activityAlerts = alerts;
          _pendingFights = fights;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _selectedFilter = 0; // 0: All, 1: Requests, 2: Activity, 3: President

  /// 🚀 Interactive detail routing for every notification event
  /// (User Audio Directive: "നോട്ടിഫിക്കേഷൻ പേജിൽ ആപ്പിൽ എന്ത് നടന്നാലും attack, Pocket Talk എല്ലാം നോട്ടിഫിക്കേഷൻ പേജിൽ വരണം.
  /// ടാപ്പ് ചെയ്തു കഴിഞ്ഞാൽ ഡീറ്റെയിൽ പേജിലേക്ക് പോകണം.")
  void _handleAlertTap(Map<String, dynamic> alert) {
    HapticFeedback.mediumImpact();
    final type = alert['type']?.toString().toLowerCase() ?? '';
    final senderId = alert['senderId']?.toString() ?? '';
    final sourceId = alert['sourceId']?.toString() ?? '';
    final targetUid = senderId.isNotEmpty ? senderId : sourceId;

    if (type.contains('citadel') || type.contains('raid') || type.contains('attack') || type.contains('fortress')) {
      if (targetUid.isNotEmpty) {
        PocketCitadelAttackPage.openForUser(
          context,
          userId: targetUid,
          targetName: alert['title'] ?? 'Fortress',
          attackerDay: 1,
        );
      }
    } else if (type.contains('pocket_talk') || type.contains('pact') || type.contains('talk')) {
      if (targetUid.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WhatsAppGroupChat(
              groupId: 'p:$targetUid',
              groupName: alert['title'] ?? 'Pocket Talk',
            ),
          ),
        );
      }
    } else if (type.contains('presidential') || type.contains('language_warning') || type.contains('decree') || type.contains('announcement')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const WhatsAppGroupChat(
            groupId: 'pocket_president',
            groupName: 'The President',
          ),
        ),
      );
    } else if (type.contains('trophy') || type.contains('score') || type.contains('streak') || type.contains('level')) {
      final myId = _supabase.auth.currentUser?.id ?? '';
      if (myId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MainProfileWidget(userId: myId),
          ),
        );
      }
    } else if (type.contains('mate') || type.contains('friend')) {
      if (targetUid.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MainProfileWidget(userId: targetUid),
          ),
        );
      } else {
        setState(() => _selectedFilter = 1);
      }
    } else {
      if (targetUid.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MainProfileWidget(userId: targetUid),
          ),
        );
      }
    }
  }

  Future<void> _acceptRequest(Map<String, dynamic> req) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    HapticFeedback.mediumImpact();
    final senderId = req['senderId']?.toString() ?? '';
    final notifId = req['id']?.toString() ?? '';

    // Use PocketMateService to accept across Supabase and local cache
    await PocketMateService.acceptMateRequest(
      notificationId: notifId,
      myId: myId,
      senderId: senderId,
    );

    // If this is a 4-Day Pocket Talk Spoken Pact request, also accept the pact!
    final isPocketTalkReq = req['type'] == 'pocket_talk' ||
        req['context_type'] == 'pocket_talk' ||
        req['message']?.toString().contains('Spoken English Pact') == true ||
        req['message']?.toString().contains('Pocket Talk') == true;
    if (isPocketTalkReq) {
      await PocketTrophyService.acceptPact(
        myId: myId,
        otherUserId: senderId,
      );
    }

    // Remove from pending
    _connectionRequests.removeWhere((r) => r['id'] == req['id']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_pocket_requests_$myId', jsonEncode(_connectionRequests));

    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '✨ Connected with ${req['senderName']}! Added to your Poket Mates chat list.',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _declineRequest(Map<String, dynamic> req) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    HapticFeedback.lightImpact();
    final notifId = req['id']?.toString() ?? '';
    final senderId = req['senderId']?.toString() ?? '';

    await PocketMateService.declineMateRequest(
      notificationId: notifId,
      myId: myId,
      senderId: senderId,
    );

    final prefs = await SharedPreferences.getInstance();
    _connectionRequests.removeWhere((r) => r['id'] == req['id']);
    await prefs.setString('pending_pocket_requests_$myId', jsonEncode(_connectionRequests));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final presidentAlerts = _activityAlerts.where((a) =>
        a['title'].toString().contains('President') ||
        a['body'].toString().contains('President') ||
        a['icon'] == '🏛️').toList();
    final regularAlerts = _activityAlerts.where((a) =>
        !a['title'].toString().contains('President') &&
        !a['body'].toString().contains('President') &&
        a['icon'] != '🏛️').toList();

    return Scaffold(
      backgroundColor: const Color(0xFF090A10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F111A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: Color(0xFFFFFC00), size: 20),
            const SizedBox(width: 8),
            Text(
              'Notifications & Requests',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFC00)))
          : Column(
              children: [
                // Filter Tabs Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: const Color(0xFF0B0D15),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(0, 'All (${_connectionRequests.length + _activityAlerts.length})'),
                        const SizedBox(width: 8),
                        _buildFilterChip(1, '🤝 Requests (${_connectionRequests.length})'),
                        const SizedBox(width: 8),
                        _buildFilterChip(2, '✨ Activity (${regularAlerts.length})'),
                        const SizedBox(width: 8),
                        _buildFilterChip(3, '🏛️ President (${presidentAlerts.length})'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    children: [
                      // Presidential announcements prominent banner if available
                      if ((_selectedFilter == 0 || _selectedFilter == 3) && presidentAlerts.isNotEmpty) ...[
                        ...presidentAlerts.map((pa) => Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2A2000), Color(0xFF131520)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5), width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('🏛️ ', style: TextStyle(fontSize: 20)),
                                      Expanded(
                                        child: Text(
                                          pa['title'] ?? 'Presidential Message',
                                          style: GoogleFonts.outfit(
                                            color: const Color(0xFFFFD700),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFD700),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'OFFICIAL',
                                          style: GoogleFonts.outfit(
                                            color: Colors.black,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    pa['body'] ?? '',
                                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13, height: 1.35),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        pa['time'] ?? 'Just now',
                                        style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Viewing Presidential Broadcast ✨',
                                                  style: GoogleFonts.outfit(color: Colors.white)),
                                              backgroundColor: const Color(0xFF1E293B),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFD700),
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          minimumSize: Size.zero,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: Text(
                                          'VIEW DECREE ➔',
                                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ],

                      // 🥊 Citadel Fight Speed Duel Challenges Banner
                      if (_pendingFights.isNotEmpty && (_selectedFilter == 0 || _selectedFilter == 2)) ...[
                        Row(
                          children: [
                            Text(
                              '🥊 CITADEL FIGHT DUELS (SPEED CHALLENGES)',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFF59E0B),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_pendingFights.length}',
                                style: GoogleFonts.outfit(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ..._pendingFights.map((f) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFFFD700), width: 1.4),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(f.challengerAvatar, style: const TextStyle(fontSize: 26)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${f.challengerName} challenged you to a Fight!',
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              'Speed to beat: ${f.challengerSeconds}s • ${f.challengerScore} PTS (${f.gameTitle})',
                                              style: GoogleFonts.inter(
                                                color: const Color(0xFFFFD700),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          final myId = _supabase.auth.currentUser?.id ?? '';
                                          await PocketCitadelFightService.declineFightChallenge(f.id, myId);
                                          _loadNotifications();
                                        },
                                        child: Text(
                                          'Dismiss',
                                          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (_) => PocketCitadelFightArenaDialog(
                                              challenge: f,
                                              opponentDay: 30,
                                              questionCount: f.questionCount,
                                              isOpponentRun: true,
                                            ),
                                          );
                                          _loadNotifications();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFF59E0B),
                                          foregroundColor: const Color(0xFF0F172A),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        icon: const Text('🥊', style: TextStyle(fontSize: 14)),
                                        label: Text(
                                          'FIGHT BACK ⚔️',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 12),
                      ],

                      // Pocket Mate Requests Header
                      if (_selectedFilter == 0 || _selectedFilter == 1) ...[
                        Row(
                          children: [
                            Text(
                              '🤝 POCKET MATE REQUESTS',
                              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFC00),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_connectionRequests.length}',
                                style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (_connectionRequests.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131520),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Center(
                              child: Text(
                                'No pending Pocket Mate requests.\nMatch anonymously or via Stage Match to connect!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                              ),
                            ),
                          )
                        else
                          ..._connectionRequests.map((req) {
                            final stageNum = (req['stage'] as num?)?.toInt() ?? 1;
                            final stage = LearningMilestoneStage.getStageForDay(stageNum);
                            final isRobot = req['isRobot'] == true ||
                                PocketRobotService.isRobotId(req['senderId']?.toString() ?? '');
                            VectorAvatarConfig? avatarConfig;
                            if (req['avatarConfig'] is Map) {
                              avatarConfig = VectorAvatarConfig.fromMap(
                                  Map<String, dynamic>.from(req['avatarConfig']));
                            } else {
                              avatarConfig =
                                  VectorAvatarConfig.getEvolutionAvatarForStage(stageNum);
                            }

                            final isPocketTalk = req['type'] == 'pocket_talk' ||
                                req['context_type'] == 'pocket_talk' ||
                                req['message']?.toString().contains('Spoken English Pact') == true ||
                                req['message']?.toString().contains('Pocket Talk') == true;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF131520),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isPocketTalk
                                      ? const Color(0xFFFFD700)
                                      : isRobot
                                          ? const Color(0xFF06B6D4).withValues(alpha: 0.3)
                                          : const Color(0xFFFFFC00).withValues(alpha: 0.3),
                                  width: isPocketTalk ? 1.5 : 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipOval(
                                        child: VectorAvatarWidget(
                                          config: avatarConfig,
                                          size: 44,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    req['senderName'] ?? 'Pocket Mate',
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                if (isRobot)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.4)),
                                                    ),
                                                    child: Text(
                                                      'ROBOT PEER',
                                                      style: GoogleFonts.outfit(
                                                        color: const Color(0xFF06B6D4),
                                                        fontWeight: FontWeight.w900,
                                                        fontSize: 8.5,
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  Icon(Icons.verified, color: stage.tickColor, size: 14),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: stage.buttonColor.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: stage.buttonColor.withValues(alpha: 0.5)),
                                                  ),
                                                  child: Text(
                                                    '${stage.emoji} STAGE $stageNum/90 • ${stage.fluencyTier}',
                                                    style: GoogleFonts.outfit(
                                                      color: stage.buttonColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 9.5,
                                                    ),
                                                  ),
                                                ),
                                                if (req['archetype'] != null) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.purple.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(6),
                                                      border: Border.all(color: Colors.purple.withValues(alpha: 0.5)),
                                                    ),
                                                    child: Text(
                                                      '${req['archetype']}'.toUpperCase(),
                                                      style: GoogleFonts.outfit(
                                                        color: Colors.purpleAccent,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 9.0,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    req['message'] ?? 'Wants to add you as a Pocket Mate!',
                                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _declineRequest(req),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.white24),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                          child: Text(
                                            'Decline',
                                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _acceptRequest(req),
                                          icon: const Icon(Icons.check_rounded, color: Colors.black, size: 16),
                                          label: Text(
                                            isPocketTalk ? 'Accept 4-Day Pact ⚡' : 'Accept Mate',
                                            style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFFFFC00),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        const SizedBox(height: 18),
                      ],

                      // Activity & Learning Alerts Header
                      if (_selectedFilter == 0 || _selectedFilter == 2) ...[
                        Row(
                          children: [
                            Text(
                              '📢 LEARNING & ACTIVITY ALERTS',
                              style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${regularAlerts.length}',
                                style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (regularAlerts.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131520),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Center(
                              child: Text(
                                'No recent activity alerts.',
                                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                              ),
                            ),
                          )
                        else
                          ...regularAlerts.map((alert) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111420),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _handleAlertTap(alert),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar or Styled Badge Icon
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  if (alert['avatarConfig'] is VectorAvatarConfig)
                                    ClipOval(
                                      child: VectorAvatarWidget(
                                        config: alert['avatarConfig'] as VectorAvatarConfig,
                                        size: 40,
                                      ),
                                    )
                                  else if (alert['avatarUrl'] != null &&
                                      alert['avatarUrl'].toString().isNotEmpty)
                                    ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: alert['avatarUrl'].toString(),
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          width: 40,
                                          height: 40,
                                          color: Colors.white10,
                                          alignment: Alignment.center,
                                          child: Text(alert['icon'] ?? '🔔',
                                              style: const TextStyle(fontSize: 18)),
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          width: 40,
                                          height: 40,
                                          color: Colors.white10,
                                          alignment: Alignment.center,
                                          child: Text(alert['icon'] ?? '🔔',
                                              style: const TextStyle(fontSize: 18)),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(alert['icon'] ?? '🔔',
                                          style: const TextStyle(fontSize: 20)),
                                    ),
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF111420),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(alert['badge'] ?? alert['icon'] ?? '✨',
                                          style: const TextStyle(fontSize: 11)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            alert['title'] ?? '',
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          alert['time'] ?? '',
                                          style: GoogleFonts.inter(
                                              color: Colors.white38, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      alert['body'] ?? '',
                                      style: GoogleFonts.inter(
                                          color: Colors.white70,
                                          fontSize: 11.5,
                                          height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                              if (alert['thumbnail'] != null &&
                                  alert['thumbnail'].toString().isNotEmpty) ...[
                                const SizedBox(width: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: alert['thumbnail'],
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white24,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedFilter = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFC00) : const Color(0xFF1A1D2C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFFC00) : Colors.white12,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

}
