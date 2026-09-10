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

      // Default activity alerts
      final alerts = [
        {
          'id': 'alert_1',
          'icon': '🎯',
          'title': 'Daily English Practice Reminder',
          'body': 'Complete your 90-minute English speaking & chat drill to protect your streak!',
          'time': '1 hour ago',
        },
        {
          'id': 'alert_2',
          'icon': '🔥',
          'title': 'Streak Milestone Active',
          'body': 'You are currently on a learning streak! Keep practicing to unlock Day 15 Royalty Badge.',
          'time': 'Yesterday',
        },
        {
          'id': 'alert_3',
          'icon': '🛡️',
          'title': 'Inactivity Decay Shield',
          'body': 'Your Pocket Score is safe today. Missing a day reduces 20 XP and resets active streaks.',
          'time': '2 days ago',
        },
      ];

      if (mounted) {
        setState(() {
          _connectionRequests = requests;
          _activityAlerts = alerts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) setState(() => _isLoading = false);
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
                  '✨ Connected with ${req['senderName']}! Added to your Pocket Mates chat list.',
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
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // Pocket Mate Requests Header
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
                    VectorAvatarConfig? avatarConfig;
                    if (req['avatarConfig'] != null) {
                      try {
                        avatarConfig = VectorAvatarConfig.fromMap(Map<String, dynamic>.from(req['avatarConfig']));
                      } catch (_) {}
                    }
                    avatarConfig ??= const VectorAvatarConfig();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141724),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              VectorAvatarWidget(config: avatarConfig, size: 42),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          req['senderName'] ?? 'English Mate',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        if (req['isRobot'] == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: const Color(0xFF06B6D4)),
                                            ),
                                            child: Text(
                                              '🤖 ROBOT',
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
                                    'Accept Mate',
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

                // Activity & Learning Alerts Header
                Text(
                  '📢 LEARNING & ACTIVITY ALERTS',
                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                ..._activityAlerts.map((alert) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111420),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(alert['icon'] ?? '🔔', style: const TextStyle(fontSize: 20)),
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
                                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                alert['body'] ?? '',
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
