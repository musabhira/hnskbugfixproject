import 'package:flutter/material.dart';
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
        case 'Drawing Tool':
          return material.Icons.brush;
        case 'Schedule':
          return material.Icons.calendar_today_rounded;
        case 'Tasks':
          return material.Icons.check_circle_outline_rounded;
        case 'Challenges':
          return material.Icons.emoji_events_outlined;
        case 'Diagrams':
          return material.Icons.schema_rounded;
        case 'Teams':
          return material.Icons.groups_rounded;
        case 'AI Tools':
          return material.Icons.auto_awesome;
        case 'Poster Maker':
          return material.Icons.photo_library_rounded;
        case 'Bulk Sender':
          return material.Icons.send_rounded;
        case 'Poki Games':
          return material.Icons.videogame_asset_rounded;
        case 'Travel Radar':
          return material.Icons.radar;
        default:
          return material.Icons.build_circle;
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
        case 'Drawing Tool':
          return isDark ? material.Colors.purpleAccent : material.Colors.purple;
        case 'Schedule':
          return isDark ? material.Colors.blueAccent : material.Colors.blue;
        case 'Tasks':
          return isDark ? material.Colors.greenAccent : material.Colors.green;
        case 'Challenges':
          return isDark ? material.Colors.orangeAccent : material.Colors.orange;
        case 'Diagrams':
          return isDark ? material.Colors.tealAccent : material.Colors.teal;
        case 'Teams':
          return isDark ? material.Colors.pinkAccent : material.Colors.pink;
        case 'AI Tools':
          return isDark ? material.Colors.cyanAccent : material.Colors.cyan;
        case 'Poster Maker':
          return isDark ? material.Colors.orangeAccent : material.Colors.orange;
        case 'Bulk Sender':
          return isDark ? material.Colors.greenAccent : material.Colors.green;
        case 'Poki Games':
          return isDark ? material.Colors.redAccent : material.Colors.red;
        case 'Travel Radar':
          return isDark ? material.Colors.cyanAccent : material.Colors.cyan;
        default:
          return isDark ? const Color(0xFFFFD600) : const Color(0xFFFFF500);
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
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: widget.conversation.isActiveTimer
                            ? material.Colors.green.withValues(alpha: 0.1)
                            : (isDark
                                ? const Color(0xFF262626)
                                : const Color(0xFFE2E8F0)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.conversation.isActiveTimer
                              ? material.Colors.greenAccent
                                  .withValues(alpha: 0.3)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1)),
                          width: 1.5,
                        ),
                        image: widget.conversation.imageUrl != null
                            ? DecorationImage(
                                image:
                                    NetworkImage(widget.conversation.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.conversation.imageUrl == null
                          ? (!widget.conversation.isGroup &&
                                  !widget.conversation.isTool &&
                                  !widget.conversation.isNotification &&
                                  !widget.conversation.isActiveTimer)
                              ? VectorAvatarWidget(
                                  config: VectorAvatarConfig(
                                    hairStyle: VectorAvatarPalette.hairStyles[
                                        (widget.conversation.name.hashCode.abs()) %
                                            VectorAvatarPalette.hairStyles.length]['id'],
                                    hairColor: VectorAvatarPalette.hairColors[
                                        (widget.conversation.id.hashCode.abs() ~/ 3) %
                                            VectorAvatarPalette.hairColors.length],
                                    outfitStyle: VectorAvatarPalette.outfitStyles[
                                        (widget.conversation.name.hashCode.abs() ~/ 5) %
                                            VectorAvatarPalette.outfitStyles.length]['id'],
                                    auraStyle: VectorAvatarPalette.auraStyles[
                                        (widget.conversation.id.hashCode.abs() ~/ 7) %
                                            VectorAvatarPalette.auraStyles.length]['id'],
                                  ),
                                  size: 56,
                                  showAura: true,
                                )
                              : Center(
                                  child: Icon(
                                    _getIconData(),
                                    color: _getIconColor(isDark),
                                    size: 26,
                                  ),
                                )
                          : null,
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
