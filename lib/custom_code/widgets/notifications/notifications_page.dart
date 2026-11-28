import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_citadel_fight_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_fight_dialog.dart';
import 'package:pocket_mates_app/custom_code/widgets/main_profile_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Instagram-style Minimal Notifications & Requests Screen
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  SupabaseClient get _supabase => SupaFlow.client;
  bool _isLoading = true;
  int _selectedFilter = 0; // 0: All, 1: Requests, 2: Activity

  List<Map<String, dynamic>> _connectionRequests = [];
  List<Map<String, dynamic>> _activityAlerts = [];
  List<CitadelFightChallenge> _pendingFights = [];

  static const Set<String> _actionableRequestTypes = {
    'mate_request',
    'pocket_talk',
    'poket_talk',
    'couple_spend_invite',
    'follow_request',
    'friend_request',
    'citadel_fight',
  };

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<Map<String, dynamic>?> _fetchSenderProfile(String senderId) async {
    if (senderId.isEmpty || PocketRobotService.isRobotId(senderId)) {
      return null;
    }
    try {
      final prof = await _supabase
          .from('profile')
          .select(
              'name, display_name, profile_image_url, is_vip, is_premium, verified, avatar_config, learning_stage, stage')
          .or('user_id.eq.$senderId,id.eq.$senderId')
          .maybeSingle();
      if (prof != null) return Map<String, dynamic>.from(prof);
    } catch (_) {}
    try {
      final u = await _supabase
          .from('users')
          .select('display_name, name, username, photo_url, avatar_url, is_vip')
          .eq('id', senderId)
          .maybeSingle();
      if (u != null) return Map<String, dynamic>.from(u);
    } catch (_) {}
    return null;
  }

  Future<void> _loadNotifications() async {
    if (mounted) setState(() => _isLoading = true);
    String? myId;
    try {
      myId = _supabase.auth.currentUser?.id;
    } catch (_) {
      myId = null;
    }
    if (myId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      await PocketRobotService.ensureIncomingRobotRequests(myId, 1);

      final dbReqs = await PocketMateService.getPendingRequests(myId);
      final List<Map<String, dynamic>> requests = [];

      for (final r in dbReqs) {
        final sId =
            r['sender_id']?.toString() ?? r['source_id']?.toString() ?? '';
        String sName = r['sender_name']?.toString() ?? '';
        String? sImg = r['avatar_url']?.toString() ??
            r['sender_profile_image']?.toString();
        bool isVip = false;
        dynamic avatarConfig = r['avatar_config'];
        int stage = (r['stage'] as num?)?.toInt() ?? 1;

        if (sId.isNotEmpty && !PocketRobotService.isRobotId(sId)) {
          if (sName.isEmpty ||
              sName == 'Pocket Mate' ||
              sName == 'Poket Mate' ||
              sImg == null ||
              sImg.isEmpty) {
            final prof = await _fetchSenderProfile(sId);
            if (prof != null) {
              final d =
                  prof['display_name'] ?? prof['name'] ?? prof['username'];
              if (d != null && d.toString().trim().isNotEmpty) {
                sName = d.toString().trim();
              }
              sImg ??= (prof['profile_image_url'] ??
                      prof['photo_url'] ??
                      prof['avatar_url'])
                  ?.toString();
              isVip = prof['is_vip'] == true ||
                  prof['is_premium'] == true ||
                  prof['verified'] == true;
              avatarConfig ??= prof['avatar_config'];
              stage =
                  ((prof['learning_stage'] ?? prof['stage']) as num?)?.toInt() ??
                      stage;
            }
          }
        }
        if (sName.isEmpty) sName = 'Poket Mate';

        final rawType = r['type']?.toString() ?? 'mate_request';
        final createdAtStr =
            r['created_at']?.toString() ?? DateTime.now().toIso8601String();
        requests.add({
          'id': r['id'],
          'senderId': sId,
          'senderName': sName,
          'stage': stage,
          'message': r['message'] ??
              (rawType == 'couple_spend_invite'
                  ? 'Invited you to Poket Couple Mode'
                  : 'Sent you a request'),
          'time': createdAtStr,
          'createdAt': DateTime.tryParse(createdAtStr) ?? DateTime.now(),
          'isRobot': r['is_robot'] == true || PocketRobotService.isRobotId(sId),
          'isVip': isVip,
          'archetype': r['archetype'],
          'type': rawType,
          'avatarUrl': sImg,
          'avatarConfig': avatarConfig,
        });
      }

      // Direct query fallback for couple_spend_invite in case not merged yet
      try {
        final coupleInvites = await _supabase
            .from('notifications')
            .select('id, sender_id, source_id, type, message, status, created_at')
            .eq('user_id', myId)
            .eq('type', 'couple_spend_invite')
            .order('created_at', ascending: false)
            .limit(10);
        for (final ci in (coupleInvites as List)) {
          final sId =
              (ci['sender_id'] ?? ci['source_id'])?.toString() ?? '';
          if (sId.isEmpty) continue;
          if (requests.any(
              (x) => x['senderId'] == sId && x['type'] == 'couple_spend_invite')) {
            continue;
          }
          String sName = 'Partner';
          String? sImg;
          int stage = 1;
          final prof = await _fetchSenderProfile(sId);
          if (prof != null) {
            final d = prof['display_name'] ?? prof['name'] ?? prof['username'];
            if (d != null && d.toString().trim().isNotEmpty) {
              sName = d.toString().trim();
            }
            sImg = (prof['profile_image_url'] ??
                    prof['photo_url'] ??
                    prof['avatar_url'])
                ?.toString();
            stage =
                ((prof['learning_stage'] ?? prof['stage']) as num?)?.toInt() ??
                    1;
          }
          final createdAtStr =
              ci['created_at']?.toString() ?? DateTime.now().toIso8601String();
          requests.add({
            'id': ci['id'],
            'senderId': sId,
            'senderName': sName,
            'stage': stage,
            'message': ci['message']?.toString() ??
                'Invited you to Poket Couple Mode!',
            'time': createdAtStr,
            'createdAt': DateTime.tryParse(createdAtStr) ?? DateTime.now(),
            'isRobot': false,
            'isVip': false,
            'type': 'couple_spend_invite',
            'avatarUrl': sImg,
          });
        }
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      final reqStr = prefs.getString('pending_pocket_requests_$myId');
      if (reqStr != null && reqStr.isNotEmpty) {
        try {
          final localReqs = List<Map<String, dynamic>>.from(jsonDecode(reqStr));
          for (final lr in localReqs) {
            if (!requests.any((x) => x['id'] == lr['id'])) {
              lr['createdAt'] =
                  DateTime.tryParse(lr['time']?.toString() ?? '') ??
                      DateTime.now();
              requests.add(lr);
            }
          }
        } catch (_) {}
      }

      // Sort requests newest first (with Couple Invites & recent items at top)
      requests.sort((a, b) {
        final aDt = (a['createdAt'] as DateTime?) ?? DateTime(2000);
        final bDt = (b['createdAt'] as DateTime?) ?? DateTime(2000);
        return bDt.compareTo(aDt);
      });

      // Fetch non-request activity alerts from Supabase
      final List<Map<String, dynamic>> alerts = [];
      final List<String> viewedActivityNotifIds = [];

      try {
        final notifsRes = await _supabase
            .from('notifications')
            .select('id, user_id, sender_id, source_id, type, message, status, created_at')
            .eq('user_id', myId)
            .order('created_at', ascending: false)
            .limit(80);

        for (final n in (notifsRes as List)) {
          final rawType = n['type']?.toString() ?? 'alert';
          final type = rawType.toLowerCase();
          final status = n['status']?.toString().toLowerCase() ?? 'unread';

          // Pending requests stay in the Requests section at top until acted on
          if (_actionableRequestTypes.contains(type) &&
              (status == 'pending' || status == 'unread' || status.isEmpty)) {
            continue;
          }

          final idStr = n['id']?.toString() ?? '';
          if (idStr.isNotEmpty) {
            viewedActivityNotifIds.add(idStr);
          }

          final sId = (n['sender_id'] ?? n['source_id'])?.toString() ?? '';
          String icon = '🔔';
          String defaultTitle = 'Activity';
          bool isPresident = false;

          if (type.contains('citadel') ||
              type.contains('raid') ||
              type.contains('attack') ||
              type.contains('fortress')) {
            icon = '⚔️';
            defaultTitle = 'Citadel Raid';
          } else if (type.contains('pocket_talk_accepted') ||
              type.contains('poket_talk_accepted')) {
            icon = '🤝';
            defaultTitle = 'Poket Talk Accepted';
          } else if (type.contains('language_warning') ||
              type.contains('presidential')) {
            icon = '🏛️';
            defaultTitle = 'The President';
            isPresident = true;
          } else if (type.contains('trophy')) {
            icon = '🏆';
            defaultTitle = 'Trophy Earned';
          } else if (type.contains('mate_accepted')) {
            icon = '✨';
            defaultTitle = 'New Poket Mate';
          } else if (type.contains('couple_spend_accepted')) {
            icon = '💑';
            defaultTitle = 'Poket Couple Connected';
          } else if (type.contains('couple_spend_removed')) {
            icon = '💔';
            defaultTitle = 'Poket Couple Updated';
          } else if (type.contains('vibe_like')) {
            icon = '❤️';
            defaultTitle = 'Liked your vibe';
          } else if (type.contains('vibe_reply')) {
            icon = '💬';
            defaultTitle = 'Replied to your vibe';
          } else if (type.contains('score') ||
              type.contains('streak') ||
              type.contains('level')) {
            icon = '🔥';
            defaultTitle = 'Milestone';
          }

          String? senderImg;
          if (sId.isNotEmpty &&
              !isPresident &&
              !PocketRobotService.isRobotId(sId)) {
            final p = await _fetchSenderProfile(sId);
            senderImg = (p?['profile_image_url'] ?? p?['photo_url'])?.toString();
            final dn = p?['display_name'] ?? p?['name'];
            if (dn != null && dn.toString().trim().isNotEmpty) {
              defaultTitle = dn.toString().trim();
            }
          }

          final createdAt = DateTime.tryParse(n['created_at']?.toString() ?? '') ??
              DateTime.now();

          alerts.add({
            'id': idStr,
            'type': type,
            'sourceId': n['source_id']?.toString() ?? '',
            'senderId': sId,
            'icon': icon,
            'title': defaultTitle,
            'body': n['message']?.toString() ?? 'New activity',
            'time': timeago.format(createdAt, locale: 'en_short'),
            'createdAt': createdAt,
            'avatarUrl': senderImg,
            'isPresident': isPresident,
          });
        }
      } catch (e) {
        debugPrint('Error fetching DB notifications: $e');
      }

      // Include unseen Presidential Announcements as compact minimal tiles
      final seenAnnouncements =
          (prefs.getStringList('seen_announcement_ids_$myId') ?? []).toSet();
      final List<String> newlySeenAnnouncementIds = [];
      try {
        final annRes = await _supabase
            .from('announcements')
            .select('id, title, content, message, created_at')
            .order('created_at', ascending: false)
            .limit(10);

        for (final a in (annRes as List)) {
          final aId = a['id']?.toString() ?? '';
          if (aId.isEmpty || seenAnnouncements.contains(aId)) continue;
          newlySeenAnnouncementIds.add(aId);
          final createdAt =
              DateTime.tryParse(a['created_at']?.toString() ?? '') ??
                  DateTime.now();
          alerts.add({
            'id': 'ann_$aId',
            'type': 'presidential_announcement',
            'icon': '🏛️',
            'title': a['title']?.toString() ?? 'The President',
            'body': a['content']?.toString() ??
                a['message']?.toString() ??
                'Official update from The President.',
            'time': timeago.format(createdAt, locale: 'en_short'),
            'createdAt': createdAt,
            'isPresident': true,
          });
        }
      } catch (_) {}

      // Sort all activity alerts newest-first (latest always at top)
      alerts.sort((a, b) {
        final aDt = (a['createdAt'] as DateTime?) ?? DateTime(2000);
        final bDt = (b['createdAt'] as DateTime?) ?? DateTime(2000);
        return bDt.compareTo(aDt);
      });

      final fights = await PocketCitadelFightService.getPendingChallenges(myId);

      await prefs.setInt('unread_notifs_count_$myId', 0);

      if (mounted) {
        setState(() {
          _connectionRequests = requests;
          _activityAlerts = alerts;
          _pendingFights = fights;
          _isLoading = false;
        });
      }

      // Auto-delete viewed informational notifications from server & persist seen announcements
      // after displaying them in this session so subsequent opens stay clean.
      unawaited(() async {
        if (viewedActivityNotifIds.isNotEmpty) {
          try {
            await _supabase
                .from('notifications')
                .delete()
                .inFilter('id', viewedActivityNotifIds);
          } catch (_) {
            try {
              await _supabase
                  .from('notifications')
                  .update({'status': 'read'})
                  .inFilter('id', viewedActivityNotifIds);
            } catch (_) {}
          }
        }
        if (newlySeenAnnouncementIds.isNotEmpty) {
          final merged = {...seenAnnouncements, ...newlySeenAnnouncementIds};
          await prefs.setStringList(
              'seen_announcement_ids_$myId', merged.toList());
        }
      }());
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleAlertTap(Map<String, dynamic> alert) {
    HapticFeedback.selectionClick();
    final type = alert['type']?.toString().toLowerCase() ?? '';
    final senderId = alert['senderId']?.toString() ?? '';
    final sourceId = alert['sourceId']?.toString() ?? '';
    final targetUid = senderId.isNotEmpty ? senderId : sourceId;

    if (alert['isPresident'] == true ||
        type.contains('presidential') ||
        type.contains('language_warning') ||
        type.contains('announcement')) {
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF121212),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Text('🏛️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert['title']?.toString() ?? 'The President',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      alert['time']?.toString() ?? '',
                      style: GoogleFonts.inter(
                          color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  alert['body']?.toString() ?? '',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WhatsAppGroupChat(
                            groupId: 'pocket_president',
                            groupName: 'The President',
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Open President Chat',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    if (type.contains('citadel') ||
        type.contains('raid') ||
        type.contains('attack') ||
        type.contains('fortress')) {
      if (targetUid.isNotEmpty) {
        PocketCitadelAttackPage.openForUser(
          context,
          userId: targetUid,
          targetName: alert['title']?.toString() ?? 'Fortress',
          attackerDay: 1,
        );
      }
    } else if (type.contains('couple_spend_accepted') ||
        type.contains('pocket_talk') ||
        type.contains('poket_talk') ||
        type.contains('pact')) {
      if (targetUid.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WhatsAppGroupChat(
              groupId: 'p:$targetUid',
              groupName: alert['title']?.toString() ?? 'Chat',
            ),
          ),
        );
      }
    } else if (type.contains('trophy') ||
        type.contains('score') ||
        type.contains('streak') ||
        type.contains('level')) {
      final myId = _supabase.auth.currentUser?.id ?? '';
      if (myId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MainProfileWidget(userId: myId),
          ),
        );
      }
    } else if (targetUid.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WhatsAppGroupChat(
            groupId: 'p:$targetUid',
            groupName: alert['title']?.toString() ?? 'Poket Mate',
          ),
        ),
      );
    }
  }

  Future<void> _acceptRequest(Map<String, dynamic> req) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return;

    HapticFeedback.mediumImpact();
    final senderId = req['senderId']?.toString() ?? '';
    final notifId = req['id']?.toString() ?? '';

    if (req['type'] == 'couple_spend_invite') {
      final prefs = await SharedPreferences.getInstance();
      final senderName = req['senderName']?.toString() ?? 'Partner';
      final senderAvatar = req['avatarUrl']?.toString();

      // Check if user is already in an active Poket Couple with someone else
      final existingCoupleGroups = <String>[];
      String? existingPartnerId;
      try {
        final myGroups = await _supabase
            .from('group_members')
            .select('group_id, groups(id, name)')
            .eq('user_id', myId)
            .eq('is_active', true);
        for (final mg in (myGroups as List)) {
          final g = mg['groups'];
          final gName = (g is Map ? g['name']?.toString() : null) ?? '';
          final gId = mg['group_id']?.toString() ?? '';
          if (gId.isNotEmpty &&
              (gName.startsWith('💑') ||
                  gName.toLowerCase().contains('poket couple') ||
                  gName.toLowerCase().contains('pocket couple'))) {
            existingCoupleGroups.add(gId);
            final others = await _supabase
                .from('group_members')
                .select('user_id')
                .eq('group_id', gId)
                .neq('user_id', myId)
                .eq('is_active', true)
                .limit(1);
            if ((others as List).isNotEmpty) {
              existingPartnerId ??= others.first['user_id']?.toString();
            }
          }
        }
      } catch (_) {}

      if (existingPartnerId != null &&
          existingPartnerId.isNotEmpty &&
          existingPartnerId != senderId) {
        if (!mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF141824),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
            ),
            title: Text(
              'Already in a Poket Couple 💑',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            content: Text(
              'Joining $senderName will leave your current Poket Couple relation and move you to this new couple group. Continue?',
              style: GoogleFonts.inter(
                  color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Leave Old & Join',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }

      // Deactivate any previous Poket Couple groups for this user so only ONE Poket Couple exists
      if (existingCoupleGroups.isNotEmpty) {
        try {
          await _supabase
              .from('group_members')
              .update({'is_active': false})
              .inFilter('group_id', existingCoupleGroups);
          if (existingPartnerId != null && existingPartnerId.isNotEmpty) {
            await _supabase.from('notifications').insert({
              'user_id': existingPartnerId,
              'sender_id': myId,
              'source_id': myId,
              'type': 'couple_spend_removed',
              'message': 'Your partner moved to a new Poket Couple.',
              'status': 'unread',
            });
          }
        } catch (_) {}
      }

      await prefs.setString('pocket_spend_partner_id_$myId', senderId);
      await prefs.setString('pocket_spend_partner_name_$myId', senderName);
      if (senderAvatar != null && senderAvatar.isNotEmpty) {
        await prefs.setString(
            'pocket_spend_partner_avatar_$myId', senderAvatar);
      }

      String myName = 'Partner';
      String? coupleGroupId;
      try {
        final prof = await _supabase
            .from('profile')
            .select('display_name, name')
            .eq('user_id', myId)
            .maybeSingle();
        if (prof != null) {
          final cand = prof['display_name'] ?? prof['name'];
          if (cand != null && cand.toString().trim().isNotEmpty) {
            myName = cand.toString().trim();
          }
        }
        try {
          final groupRes = await _supabase
              .from('groups')
              .insert({
                'name': '💑 $myName & $senderName',
                'description': 'Private Poket Couple Space',
                'created_by': myId,
              })
              .select('id')
              .single();
          coupleGroupId = groupRes['id'].toString();
          await _supabase.from('group_members').insert([
            {
              'group_id': coupleGroupId,
              'user_id': myId,
              'role': 'admin',
              'is_active': true,
            },
            {
              'group_id': coupleGroupId,
              'user_id': senderId,
              'role': 'admin',
              'is_active': true,
            },
          ]);
          await prefs.setString(
              'pocket_spend_couple_group_$myId', coupleGroupId);
        } catch (e) {
          debugPrint('Error creating Poket Couple group: $e');
        }

        await _supabase.from('notifications').insert({
          'user_id': senderId,
          'sender_id': myId,
          'source_id': myId,
          'type': 'couple_spend_accepted',
          'message': '$myName accepted your Poket Couple Mode invite!',
          'status': 'unread',
        });
        if (notifId.isNotEmpty) {
          await _supabase.from('notifications').delete().eq('id', notifId);
        }
      } catch (e) {
        debugPrint('Error accepting Poket Couple invite: $e');
      }

      _connectionRequests.removeWhere((r) => r['id'] == req['id']);
      await prefs.setString(
          'pending_pocket_requests_$myId', jsonEncode(_connectionRequests));
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '💑 Connected with $senderName in Poket Couple!',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700, color: Colors.white),
            ),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    await PocketMateService.acceptMateRequest(
      notificationId: notifId,
      myId: myId,
      senderId: senderId,
    );

    final isPocketTalkReq = req['type'] == 'pocket_talk' ||
        req['type'] == 'poket_talk' ||
        req['message']?.toString().contains('Spoken English Pact') == true ||
        req['message']?.toString().contains('Pocket Talk') == true ||
        req['message']?.toString().contains('Poket Talk') == true;
    if (isPocketTalkReq) {
      await PocketTrophyService.acceptPact(
        myId: myId,
        otherUserId: senderId,
      );
    }

    _connectionRequests.removeWhere((r) => r['id'] == req['id']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'pending_pocket_requests_$myId', jsonEncode(_connectionRequests));

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✨ Connected with ${req['senderName']}!',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: Colors.white),
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

    if (req['type'] == 'couple_spend_invite') {
      if (notifId.isNotEmpty) {
        try {
          await _supabase.from('notifications').delete().eq('id', notifId);
        } catch (_) {}
      }
    } else {
      await PocketMateService.declineMateRequest(
        notificationId: notifId,
        myId: myId,
        senderId: senderId,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    _connectionRequests.removeWhere((r) => r['id'] == req['id']);
    await prefs.setString(
        'pending_pocket_requests_$myId', jsonEncode(_connectionRequests));

    if (mounted) setState(() {});
  }

  Future<void> _clearAllNotifications() async {
    final myId = _supabase.auth.currentUser?.id;
    setState(() {
      _activityAlerts.clear();
    });
    if (myId != null) {
      try {
        await _supabase.from('notifications').delete().eq('user_id', myId);
      } catch (e) {
        debugPrint('Error clearing notifications: $e');
      }
    }
  }

  Widget _buildSafeAvatar({
    String? url,
    int stage = 1,
    VectorAvatarConfig? config,
    String fallbackEmoji = '🔔',
    double size = 42,
  }) {
    if (url != null && url.startsWith('http')) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: size,
            height: size,
            color: Colors.white10,
          ),
          errorWidget: (_, __, ___) => VectorAvatarWidget(
            config:
                config ?? VectorAvatarConfig.getEvolutionAvatarForStage(stage),
            size: size,
          ),
        ),
      );
    }
    if (config != null) {
      return ClipOval(
        child: VectorAvatarWidget(config: config, size: size),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(fallbackEmoji, style: TextStyle(fontSize: size * 0.45)),
    );
  }

  Widget _buildMinimalRequestTile(Map<String, dynamic> req) {
    final stageNum = ((req['stage'] as num?)?.toInt() ?? 1).clamp(1, 90);
    final isCouple = req['type'] == 'couple_spend_invite';
    final isPocketTalk = req['type'] == 'pocket_talk' ||
        req['type'] == 'poket_talk' ||
        req['message']?.toString().contains('Talk') == true;
    final rawAvatarUrl = req['avatarUrl']?.toString();

    VectorAvatarConfig? avatarConfig;
    if (req['avatarConfig'] is Map) {
      try {
        avatarConfig = VectorAvatarConfig.fromMap(
            Map<String, dynamic>.from(req['avatarConfig']));
      } catch (_) {}
    } else if (req['isRobot'] == true ||
        rawAvatarUrl == null ||
        !rawAvatarUrl.startsWith('http')) {
      avatarConfig = VectorAvatarConfig.getEvolutionAvatarForStage(stageNum);
    }

    final timeDt = (req['createdAt'] as DateTime?) ?? DateTime.now();
    final shortTime = timeago.format(timeDt, locale: 'en_short');

    final badgeColor = isCouple
        ? const Color(0xFFE11D48)
        : (isPocketTalk ? const Color(0xFFFFD700) : const Color(0xFF0095F6));

    final subtitleText = isCouple
        ? 'Invited you to Poket Couple'
        : (isPocketTalk
            ? 'Sent a Poket Talk pact'
            : (req['message']?.toString() ?? 'Wants to connect'));

    return InkWell(
      onTap: () {
        final sId = req['senderId']?.toString() ?? '';
        if (sId.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MainProfileWidget(userId: sId),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _buildSafeAvatar(
              url: rawAvatarUrl,
              stage: stageNum,
              config: avatarConfig,
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                  children: [
                    TextSpan(
                      text: '${req['senderName'] ?? 'Poket Mate'} ',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: '$subtitleText  ',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    TextSpan(
                      text: shortTime,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _acceptRequest(req),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Accept',
                  style: GoogleFonts.outfit(
                    color: isPocketTalk ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: Colors.white38, size: 18),
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              padding: EdgeInsets.zero,
              onPressed: () => _declineRequest(req),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalFightTile(CitadelFightChallenge fight) {
    return InkWell(
      onTap: () async {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => PocketCitadelFightArenaDialog(
            challenge: fight,
            opponentDay: 30,
            questionCount: fight.questionCount,
            isOpponentRun: true,
          ),
        );
        _loadNotifications();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _buildSafeAvatar(
              url: fight.challengerAvatar,
              fallbackEmoji:
                  fight.challengerAvatar.isNotEmpty &&
                          !fight.challengerAvatar.startsWith('http')
                      ? fight.challengerAvatar
                      : '🥊',
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                  children: [
                    TextSpan(
                      text: '${fight.challengerName} ',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text:
                          'challenged you in ${fight.gameTitle} (${fight.challengerSeconds}s)',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Duel',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalActivityTile(Map<String, dynamic> alert) {
    final isPresident = alert['isPresident'] == true;
    final thumbnail = alert['thumbnail']?.toString();
    return InkWell(
      onTap: () => _handleAlertTap(alert),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _buildSafeAvatar(
              url: alert['avatarUrl']?.toString(),
              fallbackEmoji: alert['icon']?.toString() ?? '🔔',
              size: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                  children: [
                    TextSpan(
                      text: '${alert['title'] ?? 'Update'} ',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        color: isPresident
                            ? const Color(0xFFFFD700)
                            : Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: '${alert['body'] ?? ''}  ',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    TextSpan(
                      text: alert['time']?.toString() ?? '',
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            if (thumbnail != null && thumbnail.startsWith('http')) ...[
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: thumbnail,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ] else ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white24, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showRequests = _selectedFilter == 0 || _selectedFilter == 1;
    final showActivity = _selectedFilter == 0 || _selectedFilter == 2;
    final hasAnyRequests =
        _connectionRequests.isNotEmpty || _pendingFights.isNotEmpty;
    final hasAnyVisible = (showRequests && hasAnyRequests) ||
        (showActivity && _activityAlerts.isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 21,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (_activityAlerts.isNotEmpty)
            TextButton(
              onPressed: _clearAllNotifications,
              child: Text(
                'Clear',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Shimmer.fromColors(
              baseColor: const Color(0xFF171717),
              highlightColor: const Color(0xFF262626),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: 8,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                          radius: 21, backgroundColor: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 140,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              color: const Color(0xFFFFFC00),
              backgroundColor: const Color(0xFF161616),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Row(
                      children: [
                        _buildFilterChip(0, 'All'),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          1,
                          hasAnyRequests
                              ? 'Requests (${_connectionRequests.length + _pendingFights.length})'
                              : 'Requests',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(2, 'Activity'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: !hasAnyVisible
                        ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.55,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.notifications_none_rounded,
                                        size: 48,
                                        color: Colors.white24,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No notifications yet',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white70,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Requests and new updates appear here.',
                                        style: GoogleFonts.inter(
                                          color: Colors.white38,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              if (showRequests && hasAnyRequests) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 4, 16, 4),
                                  child: Text(
                                    'Requests',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                ..._connectionRequests
                                    .map(_buildMinimalRequestTile),
                                ..._pendingFights.map(_buildMinimalFightTile),
                                if (showActivity &&
                                    _activityAlerts.isNotEmpty)
                                  Divider(
                                    height: 18,
                                    thickness: 0.6,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                              ],
                              if (showActivity && _activityAlerts.isNotEmpty) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 4, 16, 4),
                                  child: Text(
                                    'New',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                ..._activityAlerts
                                    .map(_buildMinimalActivityTile),
                              ],
                              const SizedBox(height: 24),
                            ],
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
