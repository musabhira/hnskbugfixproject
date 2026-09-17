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
import 'package:pocket_mates_app/custom_code/services/contacts_name_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_mate_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pocket_mates_app/custom_code/services/vibes_seen_service.dart';

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

    return material.Material(
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
            final isSnap = widget.conversation.lastMessage?.contains('Snap') ==
                    true ||
                widget.conversation.lastMessage?.contains('🔥 Pocket Snap') ==
                    true ||
                widget.conversation.lastMessage?.contains('⚡ Pocket Snap') ==
                    true;
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
                  onTap: _hasUnwatchedStatus
                      ? widget.onStatusTap
                      : widget.onTap,
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
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: widget.conversation.isActiveTimer
                                ? material.Colors.green.withValues(alpha: 0.1)
                                : widget.conversation.isTool
                                    ? _getIconColor(isDark)
                                        .withValues(alpha: 0.15)
                                    : (isDark
                                        ? const Color(0xFF262626)
                                        : const Color(0xFFE2E8F0)),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.conversation.isActiveTimer
                                  ? material.Colors.greenAccent
                                      .withValues(alpha: 0.3)
                                  : widget.conversation.isTool
                                      ? _getIconColor(isDark)
                                          .withValues(alpha: 0.45)
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black
                                              .withValues(alpha: 0.1)),
                              width: widget.conversation.isTool ? 1.5 : 1.2,
                            ),
                            image: (_getStoryThumbnailUrl() != null)
                                ? null
                                : ((_showRealPhoto &&
                                        widget.conversation.imageUrl != null)
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          widget.conversation.imageUrl!,
                                          maxWidth: 120,
                                          maxHeight: 120,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : (widget.conversation.isGroup &&
                                            widget.conversation.imageUrl !=
                                                null)
                                        ? DecorationImage(
                                            image: CachedNetworkImageProvider(
                                              widget.conversation.imageUrl!,
                                              maxWidth: 120,
                                              maxHeight: 120,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null),
                          ),
                          child: _getStoryThumbnailUrl() != null
                              ? ClipOval(
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
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFE2E8F0),
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
                                    errorWidget: (context, url, err) =>
                                        VectorAvatarWidget(
                                      config: _cachedAvatarConfig,
                                      size: 48,
                                      showAura: false,
                                    ),
                                  ),
                                )
                              : ((!_showRealPhoto ||
                                      widget.conversation.imageUrl == null)
                                  ? (!widget.conversation.isGroup &&
                                          !widget.conversation.isTool &&
                                          !widget.conversation.isNotification &&
                                          !widget.conversation.isActiveTimer)
                                      ? VectorAvatarWidget(
                                          config: _cachedAvatarConfig,
                                          size: 48,
                                          showAura: true,
                                        )
                                      : (widget.conversation.imageUrl == null
                                          ? Center(
                                              child: Icon(
                                                _getIconData(),
                                                color: _getIconColor(isDark),
                                                size: 24,
                                              ),
                                            )
                                          : null)
                                  : null),
                        ),
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
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
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
                                        PocketRobotService.isRobotId(widget.conversation.id)) {
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
                                final isSnap = widget.conversation.lastMessage
                                            ?.contains('Snap') ==
                                        true ||
                                    widget.conversation.lastMessage
                                            ?.contains('🔥 Pocket Snap') ==
                                        true ||
                                    widget.conversation.lastMessage
                                            ?.contains('⚡ Pocket Snap') ==
                                        true;

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
                // Snapchat-style Camera Button on Personal Chats
                if (!widget.conversation.isGroup &&
                    !widget.conversation.isTool &&
                    !widget.conversation.isNotification &&
                    !widget.conversation.isActiveTimer) ...[
                  const SizedBox(width: 6),
                  material.IconButton(
                    icon: const Icon(
                      material.Icons.camera_alt_rounded,
                      color: Color(0xFFFFFC00),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 30, minHeight: 30),
                    onPressed: () {
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
                    },
                    tooltip: 'Send Snap',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
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
