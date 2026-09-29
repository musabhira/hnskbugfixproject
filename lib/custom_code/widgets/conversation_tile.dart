import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async' as async;
import 'package:flutter/material.dart' as material;
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_snap_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';
import 'package:pocket_mates_app/custom_code/services/contacts_name_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pocket_mates_app/custom_code/services/vibes_seen_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/president_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/living_spreading_aura.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/english_hub_level_group_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';

class ConversationTile extends StatefulWidget {
  final ChatConversation conversation;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onStatusTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onSnapCameraTap;
  final VoidCallback? onSnapViewTap;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    this.onStatusTap,
    this.onLongPress,
    this.onSnapCameraTap,
    this.onSnapViewTap,
  });

  @override
  State<ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<ConversationTile> {
  late VectorAvatarConfig _cachedAvatarConfig;
  bool _showRealPhoto = false;
  bool _isPendingSent = false;
  PocketTalkPact? _cachedPact;
  bool _isSendingPocketTalk = false;

  bool get _hasUnwatchedStatus {
    if (!widget.conversation.hasStatus) return false;
    final isWatched = VibesSeenService.isWatched(
      currentUserId: widget.currentUserId,
      userId: widget.conversation.id,
      profileId: widget.conversation.id,
      statuses: widget.conversation.statusData,
    );
    return !isWatched;
  }

  String? _getStoryThumbnailUrl() {
    if (!_hasUnwatchedStatus) return null;
    if (widget.conversation.statusData != null &&
        widget.conversation.statusData!.isNotEmpty) {
      final first = widget.conversation.statusData!.first;
      final url = (first['media_url'] ??
              first['content'] ??
              first['file_url'] ??
              first['imageUrl'] ??
              first['url'])
          ?.toString();
      if (url != null && url.isNotEmpty) return url;
    }
    if (widget.conversation.snapMediaUrl != null &&
        widget.conversation.snapMediaUrl!.isNotEmpty) {
      return widget.conversation.snapMediaUrl;
    }
    return null;
  }

  VectorAvatarConfig _getAvatarConfig() {
    // 0. If it's the President of Pocket World, use Level 90 Supreme Grandmaster Sovereign avatar
    if (PocketPresidentService.isPresidentId(widget.conversation.id)) {
      return VectorAvatarConfig.getEvolutionAvatarForStage(90);
    }

    // 1. If it's a Pocket Robot, always use their exact dynamic looped level evolution avatar
    if (PocketRobotService.isRobotId(widget.conversation.id)) {
      final robot = PocketRobotService.getRobotById(widget.conversation.id) ??
          PocketRobotService.getRobotByLevel(1);
      final dynLvl = PocketRobotService.getDynamicLevel(robot);
      return VectorAvatarConfig.getEvolutionAvatarForStage(dynLvl);
    }

    // 2. Check if avatarConfig map contains an explicit stage or evolution avatar
    if (widget.conversation.avatarConfig != null) {
      final cfg = widget.conversation.avatarConfig!;
      final stage =
          cfg['stage'] ?? cfg['learning_day'] ?? cfg['day'] ?? cfg['level'];
      if (stage != null && stage is num && stage > 0) {
        return VectorAvatarConfig.getEvolutionAvatarForStage(stage.toInt());
      }
      try {
        return VectorAvatarConfig.fromMap(cfg);
      } catch (_) {}
    }

    // 3. Fallback to stage based on teamData or clean default (Stage 1 Genesis)
    int stage = 1;
    if (widget.conversation.teamData != null) {
      final tStage = widget.conversation.teamData!['learning_day'] ??
          widget.conversation.teamData!['stage'] ??
          widget.conversation.teamData!['learning_stage'];
      if (tStage != null && tStage is num && tStage > 0) {
        stage = tStage.toInt();
      }
    }

    return VectorAvatarConfig.getEvolutionAvatarForStage(stage);
  }

  @override
  void initState() {
    super.initState();
    _cachedAvatarConfig = _getAvatarConfig();
    VibesSeenService.seenEpochNotifier.addListener(_onVibesSeenChanged);
    _checkPendingSent();
    _loadPocketTalkPact();
  }

  void _checkPendingSent() {
    if (!widget.conversation.isGroup &&
        !widget.conversation.isTool &&
        !widget.conversation.isNotification &&
        widget.currentUserId.isNotEmpty &&
        widget.conversation.id.isNotEmpty) {
      PocketMateService.hasPendingSentRequest(
        widget.currentUserId,
        widget.conversation.id,
      ).then((val) {
        if (mounted && val != _isPendingSent) {
          setState(() => _isPendingSent = val);
        }
      });
    }
  }

  void _loadPocketTalkPact() {
    if (!widget.conversation.isGroup &&
        !widget.conversation.isTool &&
        !widget.conversation.isNotification &&
        !widget.conversation.isActiveTimer &&
        !PocketRobotService.isRobotId(widget.conversation.id) &&
        !PocketPresidentService.isPresidentId(widget.conversation.id) &&
        widget.currentUserId.isNotEmpty &&
        widget.conversation.id.isNotEmpty) {
      PocketTrophyService.getPact(
        widget.currentUserId,
        widget.conversation.id,
      ).then((pact) {
        if (mounted && pact != _cachedPact) {
          setState(() => _cachedPact = pact);
        }
      });
    }
  }

  Future<void> _sendPocketTalkRequest() async {
    if (_isSendingPocketTalk) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSendingPocketTalk = true);
    try {
      final pact = await PocketTrophyService.requestPact(
        myId: widget.currentUserId,
        otherUserId: widget.conversation.id,
        autoAccept: false,
      );

      try {
        await PocketMateService.sendMateRequest(
          senderId: widget.currentUserId,
          receiverId: widget.conversation.id,
          message: '⚡ Sent PocketTalk 4-Day Spoken Pact invite! Tap to accept.',
          contextType: 'pocket_talk',
        );
      } catch (_) {}

      if (mounted) {
        setState(() {
          _cachedPact = pact;
          _isSendingPocketTalk = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF00E5FF), width: 1),
            ),
            content: Row(
              children: [
                const Icon(material.Icons.record_voice_over_rounded,
                    color: Color(0xFF00E5FF), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pocket Talk request sent! 🤝',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isSendingPocketTalk = false);
    }
  }

  Future<void> _acceptPocketTalkRequest() async {
    HapticFeedback.mediumImpact();
    try {
      final accepted = await PocketTrophyService.acceptPact(
        myId: widget.currentUserId,
        otherUserId: widget.conversation.id,
      );
      if (mounted && accepted != null) {
        setState(() => _cachedPact = accepted);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF10B981), width: 1),
            ),
            content: Row(
              children: [
                const Icon(material.Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🤝 Pocket Talk Accepted! Day 1 starts now.',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant ConversationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversation.id != widget.conversation.id ||
        oldWidget.conversation.avatarConfig != widget.conversation.avatarConfig ||
        oldWidget.conversation.teamData != widget.conversation.teamData) {
      _cachedAvatarConfig = _getAvatarConfig();
    }
    if (oldWidget.conversation.id != widget.conversation.id) {
      _checkPendingSent();
      _loadPocketTalkPact();
    }
  }

  @override
  void dispose() {
    VibesSeenService.seenEpochNotifier.removeListener(_onVibesSeenChanged);
    super.dispose();
  }

  void _onVibesSeenChanged() {
    if (mounted) setState(() {});
  }

  material.IconData _getIconData() {
    if (widget.conversation.isActiveTimer) return material.Icons.timer_outlined;
    if (widget.conversation.isTool) {
      switch (widget.conversation.toolTitle) {
        case 'English Learning Tasks':
        case '90-Day English Tasks':
        case 'English Tasks':
        case '90-Day Tasks':
          return material.Icons.track_changes_rounded;
        case '1-on-1 English Match':
        case 'Stage Match':
          return material.Icons.record_voice_over_rounded;
        case 'Voice Speaking Sprint':
        case 'English Hub':
          return material.Icons.mic_rounded;
        case 'Pocket Library':
          return material.Icons.auto_stories_rounded;
        case 'Avatar Studio & NFT':
        case 'Avatar Studio':
          return material.Icons.face_retouching_natural_rounded;
        case 'Avatar Network':
          return material.Icons.public_rounded;
        case 'Drawing Tool':
        case 'Drawing Studio':
          return material.Icons.palette_rounded;
        case 'Poster Maker':
          return material.Icons.photo_library_rounded;
        case 'Chess Match':
        case 'Chess Club':
          return material.Icons.casino_rounded;
        case 'Poki Games':
          return material.Icons.videogame_asset_rounded;
        case 'Crazy Games':
          return material.Icons.sports_esports_rounded;
        case 'Bulk Sender':
          return material.Icons.rocket_launch_rounded;
        case 'Travel Radar':
          return material.Icons.radar_rounded;
        case 'Password Pro':
          return material.Icons.lock_person_rounded;
        case 'Dual Recorder':
          return material.Icons.videocam_rounded;
        case 'Schedule':
          return material.Icons.calendar_month_rounded;
        case 'Tasks':
        case 'Daily Tasks':
          return material.Icons.task_alt_rounded;
        case 'Habit Tracker':
        case 'Challenges':
          return material.Icons.emoji_events_rounded;
        case 'Diagrams':
          return material.Icons.schema_rounded;
        case 'Teams':
          return material.Icons.diversity_3_rounded;
        case 'POS Tool':
        case 'POS & Billing':
          return material.Icons.admin_panel_settings_rounded;
        case 'AI Tools':
          return material.Icons.smart_toy_rounded;
        case 'WhatsApp Web':
          return material.Icons.chat_rounded;
        case 'QR & Barcode':
          return material.Icons.qr_code_scanner_rounded;
        case 'World Clock':
          return material.Icons.schedule_rounded;
        case 'Dynamic Web App':
        case 'Web Search':
          return material.Icons.travel_explore_rounded;
        default:
          return material.Icons.auto_awesome_rounded;
      }
    }
    if (widget.conversation.isNotification) return material.Icons.info_outline;
    if (widget.conversation.isGroup) return material.Icons.group;
    return material.Icons.person;
  }

  Color _getIconColor(bool isDark) {
    if (widget.conversation.isActiveTimer) return material.Colors.greenAccent;
    if (widget.conversation.isTool) {
      switch (widget.conversation.toolTitle) {
        case 'English Learning Tasks':
        case '90-Day English Tasks':
        case 'English Tasks':
        case '90-Day Tasks':
          return const Color(0xFF10B981);
        case '1-on-1 English Match':
        case 'Stage Match':
          return const Color(0xFF38BDF8);
        case 'Voice Speaking Sprint':
        case 'English Hub':
          return const Color(0xFF06B6D4);
        case 'Pocket Library':
          return const Color(0xFFFFFC00);
        case 'Avatar Studio & NFT':
        case 'Avatar Studio':
          return const Color(0xFFFFD700);
        case 'Avatar Network':
          return const Color(0xFF00E5FF);
        case 'Drawing Tool':
        case 'Drawing Studio':
          return const Color(0xFFFF007A);
        case 'Poster Maker':
          return const Color(0xFFFF5722);
        case 'Chess Match':
        case 'Chess Club':
          return const Color(0xFFFFB700);
        case 'Poki Games':
          return const Color(0xFF00E5FF);
        case 'Crazy Games':
          return const Color(0xFF8B5CF6);
        case 'Bulk Sender':
          return const Color(0xFF10B981);
        case 'Travel Radar':
          return const Color(0xFF06B6D4);
        case 'Password Pro':
          return const Color(0xFF64748B);
        case 'Dual Recorder':
          return const Color(0xFFEF4444);
        case 'Schedule':
          return const Color(0xFF3B82F6);
        case 'Tasks':
        case 'Daily Tasks':
          return const Color(0xFF14B8A6);
        case 'Habit Tracker':
        case 'Challenges':
          return const Color(0xFFF59E0B);
        case 'Diagrams':
          return const Color(0xFF8B5CF6);
        case 'Teams':
          return const Color(0xFFEC4899);
        case 'POS Tool':
        case 'POS & Billing':
          return const Color(0xFF2563EB);
        case 'AI Tools':
          return const Color(0xFF6366F1);
        case 'WhatsApp Web':
          return const Color(0xFF22C55E);
        case 'QR & Barcode':
          return const Color(0xFF64748B);
        case 'World Clock':
          return const Color(0xFFF97316);
        case 'Dynamic Web App':
        case 'Web Search':
          return const Color(0xFFEAB308);
        default:
          return isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00);
      }
    }
    if (widget.conversation.isNotification) {
      return isDark ? const Color(0xFFFFD600) : const Color(0xFFFFF500);
    }
    return isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.45);
  }

  Widget _buildAvatar(bool isDark) {
    // 1. Stories / Vibes Thumbnail
    if (_getStoryThumbnailUrl() != null) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFFFFC00),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: _getStoryThumbnailUrl()!,
            width: 50,
            height: 50,
            memCacheWidth: 120,
            memCacheHeight: 120,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 50,
              height: 50,
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              child: const Center(
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Color(0xFFFFFC00),
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, err) => VectorAvatarWidget(
              config: _cachedAvatarConfig,
              size: 48,
              showAura: false,
            ),
          ),
        ),
      );
    }

    // 2. English Hub Level Group
    if (widget.conversation.name.toLowerCase().contains('english hub') ||
        widget.conversation.toolTitle == 'English Hub') {
      final hubConfig = EnglishHubLevelGroupService.getEnglishHubAvatarConfig(widget.conversation.name);
      final hubColor = VectorAvatarConfig.parseHex(hubConfig.outfitAccentColor, fallback: const Color(0xFFFFFC00));
      return LivingSpreadingAura(
        color: hubColor,
        size: 50,
        child: ClipOval(
          child: VectorAvatarWidget(
            config: hubConfig,
            size: 48,
            showAura: true,
          ),
        ),
      );
    }

    // 3. President Avatar with Sovereign Gold Aura Spread
    if (PocketPresidentService.isPresidentId(widget.conversation.id)) {
      return const LivingSpreadingAura(
        color: Color(0xFFFFD700),
        size: 50,
        child: PresidentAvatarWidget(size: 48, showGlow: false),
      );
    }

    // 4. Tools with Minimal, Calm Background Aura Spread
    if (widget.conversation.isTool) {
      final toolColor = _getIconColor(isDark);
      return LivingSpreadingAura(
        color: toolColor,
        size: 50,
        speed: 0.35, // Calm, slow, peaceful speed
        maxParticles: 4, // Minimal particle count (subtle motes)
        intensity: 0.45, // Soft, gentle ambient glow
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Solid opaque backdrop so aura and particles emerge ONLY from behind the edges!
            color: isDark ? const Color(0xFF131B26) : Colors.white,
            border: Border.all(
              color: toolColor.withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: toolColor.withValues(alpha: 0.20),
                blurRadius: 8,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: toolColor.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Icon(
                  _getIconData(),
                  color: toolColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // 5. Group Chats with Group Blue/Cyan Aura Spread
    if (widget.conversation.isGroup) {
      const groupColor = Color(0xFF38BDF8);
      return LivingSpreadingAura(
        color: groupColor,
        size: 50,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            border: Border.all(
              color: groupColor.withValues(alpha: 0.65),
              width: 1.5,
            ),
            image: widget.conversation.imageUrl != null
                ? DecorationImage(
                    image: CachedNetworkImageProvider(
                      widget.conversation.imageUrl!,
                      maxWidth: 120,
                      maxHeight: 120,
                    ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: widget.conversation.imageUrl == null
              ? const Center(
                  child: Icon(
                    material.Icons.group_rounded,
                    color: groupColor,
                    size: 24,
                  ),
                )
              : null,
        ),
      );
    }

    // 6. Active Timer or Notification
    if (widget.conversation.isActiveTimer || widget.conversation.isNotification) {
      final itemColor = widget.conversation.isActiveTimer
          ? material.Colors.greenAccent
          : _getIconColor(isDark);
      return LivingSpreadingAura(
        color: itemColor,
        size: 50,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: itemColor.withValues(alpha: 0.15),
            border: Border.all(
              color: itemColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              _getIconData(),
              color: itemColor,
              size: 24,
            ),
          ),
        ),
      );
    }

    // 7. Regular Pocket Mate (User toggled real photo)
    final mateColor = VectorAvatarConfig.parseHex(
      _cachedAvatarConfig.outfitAccentColor,
      fallback: const Color(0xFFFFFC00),
    );
    if (_showRealPhoto && widget.conversation.imageUrl != null) {
      return LivingSpreadingAura(
        color: mateColor,
        size: 50,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: mateColor.withValues(alpha: 0.75),
              width: 1.5,
            ),
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                widget.conversation.imageUrl!,
                maxWidth: 120,
                maxHeight: 120,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    // 8. Regular Pocket Mate (Vector Avatar with Living Animated Aura)
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: mateColor.withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 1.5,
          ),
        ],
      ),
      child: VectorAvatarWidget(
        config: _cachedAvatarConfig,
        size: 48,
        showAura: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.05);
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.45);
    final unreadTextColor = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.black.withValues(alpha: 0.85);

    final tileContent = material.Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF131B26).withValues(alpha: 0.75)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: material.InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            final isSnap = !PocketPresidentService.isPresidentId(widget.conversation.id) &&
                (widget.conversation.lastMessage?.contains('Snap') == true ||
                    widget.conversation.lastMessage?.contains('🔥 Pocket Snap') == true ||
                    widget.conversation.lastMessage?.contains('⚡ Pocket Snap') == true);
            if (isSnap &&
                widget.conversation.unreadCount > 0 &&
                widget.onSnapViewTap != null) {
              widget.onSnapViewTap!();
            } else {
              widget.onTap();
            }
          },
          onLongPress: widget.onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_hasUnwatchedStatus && widget.onStatusTap != null) {
                      VibesSeenService.markSeen(
                        currentUserId: widget.currentUserId,
                        userId: widget.conversation.id,
                        profileId: widget.conversation.id,
                        groupId: widget.conversation.isGroup
                            ? widget.conversation.id
                            : null,
                      );
                      setState(() {});
                      widget.onStatusTap!();
                    } else {
                      widget.onTap();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_hasUnwatchedStatus)
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF833AB4), // Purple
                                Color(0xFFF77737), // Orange
                                Color(0xFFFCAF45), // Yellow
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () {
                          if (_hasUnwatchedStatus &&
                              widget.onStatusTap != null) {
                            VibesSeenService.markSeen(
                              currentUserId: widget.currentUserId,
                              userId: widget.conversation.id,
                              profileId: widget.conversation.id,
                              groupId: widget.conversation.isGroup
                                  ? widget.conversation.id
                                  : null,
                            );
                            setState(() {});
                            widget.onStatusTap!();
                          } else if (widget.conversation.imageUrl != null) {
                            setState(() => _showRealPhoto = !_showRealPhoto);
                            HapticFeedback.lightImpact();
                          }
                        },
                        onDoubleTap: () {
                          if (widget.conversation.imageUrl != null) {
                            setState(() => _showRealPhoto = !_showRealPhoto);
                            HapticFeedback.lightImpact();
                          }
                        },
                        onLongPress: () {
                          if (widget.conversation.imageUrl != null) {
                            setState(() => _showRealPhoto = !_showRealPhoto);
                            HapticFeedback.mediumImpact();
                          }
                        },
                        child: _buildAvatar(isDark),
                      ),
                      if (widget.conversation.isOnline &&
                          !widget.conversation.isGroup)
                        Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981), // Emerald
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1A1A1A)
                                    : const Color(0xFFFFFFFF),
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                if (PocketPresidentService.isPresidentId(
                                    widget.conversation.id)) ...[
                                  Text(
                                    'President',
                                    style: GoogleFonts.outfit(
                                      color: primaryTextColor,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                  const SizedBox(width: 4.5),
                                  const Icon(
                                    material.Icons.verified_rounded,
                                    color: Color(0xFFFFD700),
                                    size: 15,
                                  ),
                                ] else ...[
                                  Flexible(
                                    child: Text(
                                      ContactsNameService().getDisplayName(
                                        userId: widget.conversation.id,
                                        fallbackName: widget.conversation.name,
                                      ),
                                      style: GoogleFonts.outfit(
                                        color: primaryTextColor,
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Builder(
                                    builder: (context) {
                                      final isRobot =
                                          PocketRobotService.isRobotId(
                                              widget.conversation.id);
                                      if (isRobot) {
                                        return Container(
                                          margin: const EdgeInsets.only(left: 6),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF06B6D4)
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              color: const Color(0xFF06B6D4)
                                                  .withValues(alpha: 0.4),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(
                                            '🤖 Robot',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF06B6D4),
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
                                if (_isPendingSent)
                                  Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      'Request Sent ⏳',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFFFC00),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ),
                                // 🔥 Snapchat-style Pocket Streak Badge
                                Builder(
                                  builder: (context) {
                                    if (widget.conversation.isGroup ||
                                        widget.conversation.isTool ||
                                        widget.conversation.isNotification ||
                                        PocketRobotService.isRobotId(widget.conversation.id) ||
                                        PocketPresidentService.isPresidentId(widget.conversation.id)) {
                                      return const SizedBox.shrink();
                                    }
                                    final lastTime = widget.conversation.lastMessageTime;
                                    if (lastTime == null) return const SizedBox.shrink();
                                    final diffDays = DateTime.now().difference(lastTime).inDays;
                                    if (diffDays <= 2) {
                                      final streakDays = (widget.conversation.id.hashCode.abs() % 7) + 2;
                                      return Container(
                                        margin: const EdgeInsets.only(left: 6),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: const Color(0xFFFF5722).withValues(alpha: 0.4),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('🔥', style: TextStyle(fontSize: 10)),
                                            const SizedBox(width: 2),
                                            Text(
                                              '$streakDays',
                                              style: GoogleFonts.outfit(
                                                color: const Color(0xFFFF8A65),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                                if (widget.conversation.isPinned) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    material.Icons.push_pin,
                                    size: 14,
                                    color: secondaryTextColor,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (widget.conversation.isActiveTimer)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: material.Colors.green
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'LIVE',
                                style: GoogleFonts.outfit(
                                  color: material.Colors.greenAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (!widget.conversation.isGroup &&
                              !widget.conversation.isActiveTimer &&
                              widget.conversation.lastSenderId ==
                                  widget.currentUserId)
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Icon(
                                widget.conversation.otherUnreadCount == 0
                                    ? material.Icons.done_all_rounded
                                    : material.Icons.check,
                                size: 14,
                                color: widget.conversation.otherUnreadCount == 0
                                    ? material.Colors.blue
                                        .withValues(alpha: 0.8)
                                    : material.Colors.grey
                                        .withValues(alpha: 0.7),
                              ),
                            ),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final isSnap = !PocketPresidentService.isPresidentId(widget.conversation.id) &&
                                    (widget.conversation.lastMessage?.contains('Snap') == true ||
                                        widget.conversation.lastMessage?.contains('🔥 Pocket Snap') == true ||
                                        widget.conversation.lastMessage?.contains('⚡ Pocket Snap') == true);

                                if (isSnap) {
                                  if (widget.conversation.unreadCount > 0) {
                                    return Row(
                                      children: [
                                        Container(
                                          width: 11,
                                          height: 11,
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFEF4444)
                                                    .withValues(alpha: 0.5),
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            'New Snap • Tap to view ⚡',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFFF87171),
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else if (widget.conversation.lastSenderId ==
                                      widget.currentUserId) {
                                    return Row(
                                      children: [
                                        const Icon(
                                            material.Icons.near_me_rounded,
                                            size: 12,
                                            color: Color(0xFFEF4444)),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'Delivered Snap ⚡',
                                            style: GoogleFonts.outfit(
                                              color: secondaryTextColor,
                                              fontSize: 13.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: secondaryTextColor,
                                                width: 1.3),
                                            borderRadius:
                                                BorderRadius.circular(2.5),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            'Opened Snap',
                                            style: GoogleFonts.outfit(
                                              color: secondaryTextColor,
                                              fontSize: 13.5,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                }

                                return Text(
                                  widget.conversation.isActiveTimer
                                      ? (widget.conversation.taskTitle ??
                                          'Active Task')
                                      : (widget.conversation.lastMessage ??
                                          (widget.conversation.isGroup
                                              ? 'No messages yet'
                                              : 'Start chatting')),
                                  style: GoogleFonts.outfit(
                                    color: widget.conversation.unreadCount >
                                                0 ||
                                            widget.conversation.isActiveTimer
                                        ? unreadTextColor
                                        : secondaryTextColor,
                                    fontSize: 13.5,
                                    fontWeight:
                                        widget.conversation.unreadCount > 0 ||
                                                widget
                                                    .conversation.isActiveTimer
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.conversation.isActiveTimer)
                      _TickingTimerBadge(startTime: widget.conversation.timerStartTime)
                    else if (widget.conversation.lastMessageTime != null)
                      Text(
                        timeago.format(widget.conversation.lastMessageTime!,
                            locale: 'en_short'),
                        style: GoogleFonts.outfit(
                          color: widget.conversation.unreadCount > 0
                              ? (isDark
                                  ? const Color(0xFFFFD600)
                                  : const Color(0xFFFFF500))
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.35)
                                  : Colors.black.withValues(alpha: 0.35)),
                          fontSize: 11.5,
                          fontWeight: widget.conversation.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    if (widget.conversation.unreadCount > 0) ...[
                      const SizedBox(height: 5),
                      Container(
                        constraints: const BoxConstraints(minWidth: 19),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFFFFD600)
                              : const Color(0xFFFFF500),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark
                                      ? const Color(0xFFFFD600)
                                      : const Color(0xFFFFF500))
                                  .withValues(alpha: 0.4),
                              blurRadius: 3,
                              spreadRadius: -1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.conversation.unreadCount.toString(),
                            style: GoogleFonts.outfit(
                              color: isDark ? Colors.black : Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                // Snapchat-style Camera / Pocket Talk Action Button on Personal Chats
                if (!widget.conversation.isGroup &&
                    !widget.conversation.isTool &&
                    !widget.conversation.isNotification &&
                    !widget.conversation.isActiveTimer &&
                    !PocketPresidentService.isPresidentId(widget.conversation.id)) ...[
                  const SizedBox(width: 6),
                  _buildTrailingActionButton(isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // Audio Directive: Swiping a chat tile left-to-right opens the Citadel Attack page!
    return Dismissible(
      key: ValueKey('chat_tile_swipe_${widget.conversation.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        PocketCitadelAttackPage.openForUser(
          context,
          userId: widget.conversation.id,
        );
        return false; // Prevent tile removal from list; smoothly spring back
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFFF8A00)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                material.Icons.flash_on_rounded,
                color: Color(0xFFFFFC00),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RAID CITADEL ⚔️',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  'Swipe to attack home',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      child: tileContent,
    );
  }

  Widget _buildTrailingActionButton(bool isDark) {
    // If it's a Robot, show Camera button for sending Snaps to the AI Robot
    final isRobot = PocketRobotService.isRobotId(widget.conversation.id);
    if (isRobot) {
      return material.IconButton(
        icon: const Icon(
          material.Icons.camera_alt_rounded,
          color: Color(0xFFFFFC00),
          size: 20,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        onPressed: _onSnapPressed,
        tooltip: 'Send Snap 🔥',
      );
    }

    // For human Mates:
    // If Pocket Talk Pact is accepted/active -> Prioritize Camera for sending Snaps!
    final isPactAccepted = _cachedPact?.isAccepted == true;
    if (isPactAccepted) {
      return material.IconButton(
        icon: const Icon(
          material.Icons.camera_alt_rounded,
          color: Color(0xFFFFFC00),
          size: 20,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        onPressed: _onSnapPressed,
        tooltip: 'Send Snap 🔥',
      );
    }

    // If I sent a Pocket Talk request and it's waiting for mate's acceptance
    final isPendingByMe = _cachedPact != null &&
        !_cachedPact!.isAccepted &&
        _cachedPact!.initiatorId == widget.currentUserId;
    if (isPendingByMe) {
      return material.IconButton(
        icon: const Icon(
          material.Icons.hourglass_top_rounded,
          color: Color(0xFFFFD600),
          size: 19,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        onPressed: () {
          HapticFeedback.selectionClick();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF0F172A),
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Pocket Talk request pending • Waiting for mate to accept 🤝',
                style: GoogleFonts.outfit(color: Colors.white70),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        tooltip: 'Pocket Talk Pending ⏳',
      );
    }

    // If mate sent me a Pocket Talk request -> Quick Accept
    final isIncomingRequest = _cachedPact != null &&
        !_cachedPact!.isAccepted &&
        _cachedPact!.initiatorId != widget.currentUserId;
    if (isIncomingRequest) {
      return material.IconButton(
        icon: const Icon(
          material.Icons.handshake_rounded,
          color: Color(0xFF00E5FF),
          size: 20,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        onPressed: _acceptPocketTalkRequest,
        tooltip: 'Accept Pocket Talk 🤝',
      );
    }

    // Not yet requested -> Fast Pocket Talk Request Button!
    return material.IconButton(
      icon: _isSendingPocketTalk
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF00E5FF),
              ),
            )
          : const Icon(
              material.Icons.record_voice_over_rounded,
              color: Color(0xFF00E5FF),
              size: 20,
            ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      onPressed: _sendPocketTalkRequest,
      tooltip: 'Request Pocket Talk 🤝',
    );
  }

  void _onSnapPressed() {
    HapticFeedback.lightImpact();
    if (widget.onSnapCameraTap != null) {
      widget.onSnapCameraTap!();
    } else {
      PocketSnapService.launchSnapWorkflow(
        context,
        userId: widget.currentUserId,
        profileId: widget.currentUserId,
        preselectedRecipientId: widget.conversation.id,
      );
    }
  }
}

class _TickingTimerBadge extends StatefulWidget {
  final DateTime? startTime;
  const _TickingTimerBadge({required this.startTime});

  @override
  State<_TickingTimerBadge> createState() => _TickingTimerBadgeState();
}

class _TickingTimerBadgeState extends State<_TickingTimerBadge> {
  async.Timer? _timer;
  String _elapsedString = '';

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = async.Timer.periodic(const Duration(seconds: 1), (_) => _updateElapsed());
  }

  @override
  void didUpdateWidget(covariant _TickingTimerBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startTime != widget.startTime) {
      _updateElapsed();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateElapsed() {
    if (!mounted || widget.startTime == null) return;
    final diff = DateTime.now().difference(widget.startTime!);
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    final text = hours != '00' ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
    if (_elapsedString != text) {
      setState(() {
        _elapsedString = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _elapsedString,
      style: GoogleFonts.outfit(
        color: material.Colors.greenAccent,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
