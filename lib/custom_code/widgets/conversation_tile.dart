import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async' as async;
import 'package:flutter/material.dart' as material;
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_widget.dart';

class ConversationTile extends StatefulWidget {
  final ChatConversation conversation;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onStatusTap;
  final VoidCallback? onLongPress;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    this.onStatusTap,
    this.onLongPress,
  });

  @override
  State<ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<ConversationTile> {
  async.Timer? _timer;
  String _elapsedString = '';
  bool _showRealPhoto = false;

  VectorAvatarConfig _getAvatarConfig() {
    if (widget.conversation.avatarConfig != null) {
      try {
        return VectorAvatarConfig.fromMap(widget.conversation.avatarConfig!);
      } catch (_) {}
    }
    final nameHash = widget.conversation.name.hashCode.abs();
    final idHash = widget.conversation.id.hashCode.abs();
    final hairs = VectorAvatarPalette.hairStyles;
    final hairColors = VectorAvatarPalette.hairColors;
    final outfits = VectorAvatarPalette.outfitStyles;
    final auras = VectorAvatarPalette.auraStyles;
    final faces = ['oval', 'round', 'sharp', 'square'];

    return VectorAvatarConfig(
      faceShape: faces[(nameHash ~/ 2) % faces.length],
      hairStyle: hairs[nameHash % hairs.length]['id'],
      hairColor: hairColors[(idHash ~/ 3) % hairColors.length],
      outfitStyle: outfits[(nameHash ~/ 5) % outfits.length]['id'],
      auraStyle: auras[(idHash ~/ 7) % auras.length]['id'],
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.conversation.isActiveTimer) {
      _startTicking();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTicking() {
    _updateElapsed();
    _timer = async.Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateElapsed();
    });
  }

  void _updateElapsed() {
    if (!mounted) return;
    final start = widget.conversation.timerStartTime;
    if (start == null) return;

    final diff = DateTime.now().difference(start);
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

    setState(() {
      _elapsedString =
          hours != '00' ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
    });
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
        case 'Zoyarex POS Admin':
        case 'Zoyarex Super Admin':
        case 'POS Tool':
        case 'POS & Billing':
          return material.Icons.admin_panel_settings_rounded;
        case 'Zoyarex AI':
        case 'AI Tools':
          return material.Icons.smart_toy_rounded;
        case 'WhatsApp Web':
          return material.Icons.chat_rounded;
        case 'QR & Barcode':
          return material.Icons.qr_code_scanner_rounded;
        case 'World Clock':
          return material.Icons.schedule_rounded;
        case 'Test Feature':
          return material.Icons.bug_report_rounded;
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
        case 'Zoyarex POS Admin':
        case 'Zoyarex Super Admin':
        case 'POS Tool':
        case 'POS & Billing':
          return const Color(0xFF2563EB);
        case 'Zoyarex AI':
        case 'AI Tools':
          return const Color(0xFF6366F1);
        case 'WhatsApp Web':
          return const Color(0xFF22C55E);
        case 'QR & Barcode':
          return const Color(0xFF64748B);
        case 'World Clock':
          return const Color(0xFFF97316);
        case 'Test Feature':
          return const Color(0xFFE11D48);
        case 'Dynamic Web App':
        case 'Web Search':
          return const Color(0xFFEAB308);
        default:
          return isDark ? const Color(0xFFFFFC00) : const Color(0xFFFFFC00);
      }
    }
    if (widget.conversation.isNotification)
      return isDark ? const Color(0xFFFFD600) : const Color(0xFFFFF500);
    return isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black.withValues(alpha: 0.45);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
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
      child: material.InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.conversation.hasStatus
                    ? widget.onStatusTap
                    : widget.onTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.conversation.hasStatus)
                      Container(
                        width: 66,
                        height: 66,
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
                        if (widget.conversation.hasStatus && widget.onStatusTap != null) {
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
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: widget.conversation.isActiveTimer
                              ? material.Colors.green.withValues(alpha: 0.1)
                              : widget.conversation.isTool
                                  ? _getIconColor(isDark).withValues(alpha: 0.15)
                                  : (isDark
                                      ? const Color(0xFF262626)
                                      : const Color(0xFFE2E8F0)),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.conversation.isActiveTimer
                                ? material.Colors.greenAccent.withValues(alpha: 0.3)
                                : widget.conversation.isTool
                                    ? _getIconColor(isDark).withValues(alpha: 0.45)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black.withValues(alpha: 0.1)),
                            width: widget.conversation.isTool ? 1.8 : 1.5,
                          ),
                          image: (_showRealPhoto && widget.conversation.imageUrl != null)
                              ? DecorationImage(
                                  image: NetworkImage(widget.conversation.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : (widget.conversation.isGroup && widget.conversation.imageUrl != null)
                                  ? DecorationImage(
                                      image: NetworkImage(widget.conversation.imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: (!_showRealPhoto || widget.conversation.imageUrl == null)
                            ? (!widget.conversation.isGroup &&
                                    !widget.conversation.isTool &&
                                    !widget.conversation.isNotification &&
                                    !widget.conversation.isActiveTimer)
                                ? VectorAvatarWidget(
                                    config: _getAvatarConfig(),
                                    size: 56,
                                    showAura: true,
                                  )
                                : (widget.conversation.imageUrl == null
                                    ? Center(
                                        child: Icon(
                                          _getIconData(),
                                          color: _getIconColor(isDark),
                                          size: 26,
                                        ),
                                      )
                                    : null)
                            : null,
                      ),
                    ),
                    if (widget.conversation.isOnline &&
                        !widget.conversation.isGroup)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981), // Emerald
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFFFFFFFF),
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
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
                                  widget.conversation.name,
                                  style: GoogleFonts.outfit(
                                    color: primaryTextColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                              color:
                                  material.Colors.green.withValues(alpha: 0.2),
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (!widget.conversation.isGroup &&
                            !widget.conversation.isActiveTimer &&
                            widget.conversation.lastSenderId ==
                                widget.currentUserId)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              widget.conversation.otherUnreadCount == 0
                                  ? material.Icons.done_all_rounded
                                  : material.Icons.check,
                              size: 16,
                              color: widget.conversation.otherUnreadCount == 0
                                  ? material.Colors.blue.withValues(alpha: 0.8)
                                  : material.Colors.grey.withValues(alpha: 0.7),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            widget.conversation.isActiveTimer
                                ? (widget.conversation.taskTitle ??
                                    'Active Task')
                                : (widget.conversation.lastMessage ??
                                    (widget.conversation.isGroup
                                        ? 'No messages yet'
                                        : 'Start chatting')),
                            style: GoogleFonts.outfit(
                              color: widget.conversation.unreadCount > 0 ||
                                      widget.conversation.isActiveTimer
                                  ? unreadTextColor
                                  : secondaryTextColor,
                              fontSize: 14,
                              fontWeight: widget.conversation.unreadCount > 0 ||
                                      widget.conversation.isActiveTimer
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.conversation.isActiveTimer)
                    Text(
                      _elapsedString,
                      style: GoogleFonts.outfit(
                        color: material.Colors.greenAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    )
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
                        fontSize: 12,
                        fontWeight: widget.conversation.unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  if (widget.conversation.unreadCount > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFFFFD600)
                            : const Color(0xFFFFF500),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isDark
                                    ? const Color(0xFFFFD600)
                                    : const Color(0xFFFFF500))
                                .withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.conversation.unreadCount.toString(),
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.black : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
