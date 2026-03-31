import 'package:fluent_ui/fluent_ui.dart';
import 'dart:async' as async;
import 'package:flutter/material.dart' as material;
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart';

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
      _elapsedString = hours != '00' ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
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
    if (widget.conversation.isNotification) return FluentIcons.info;
    if (widget.conversation.isGroup) return FluentIcons.group;
    return FluentIcons.contact;
  }

  Color _getIconColor() {
    if (widget.conversation.isActiveTimer) return material.Colors.greenAccent;
    if (widget.conversation.isTool) {
      switch (widget.conversation.toolTitle) {
        case 'Drawing Tool':
          return material.Colors.purpleAccent;
        case 'Schedule':
          return material.Colors.blueAccent;
        case 'Tasks':
          return material.Colors.greenAccent;
        case 'Challenges':
          return material.Colors.orangeAccent;
        case 'Diagrams':
          return material.Colors.tealAccent;
        case 'Teams':
          return material.Colors.pinkAccent;
        case 'AI Tools':
          return material.Colors.cyanAccent;
        case 'Poster Maker':
          return material.Colors.orangeAccent;
        case 'Bulk Sender':
          return material.Colors.greenAccent;
        case 'Poki Games':
          return material.Colors.redAccent;
        case 'Travel Radar':
          return material.Colors.cyanAccent;
        default:
          return material.Colors.yellow;
      }
    }
    if (widget.conversation.isNotification) return Colors.yellow;
    return Colors.white.withValues(alpha: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    return material.Material(
      color: Colors.transparent,
      child: material.InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF000000), // Pure black for flat look
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.conversation.hasStatus ? widget.onStatusTap : widget.onTap,
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
                            : const Color(0xFF262626),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.conversation.isActiveTimer
                              ? material.Colors.greenAccent.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.1),
                          width: 1.5,
                        ),
                        image: widget.conversation.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(widget.conversation.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.conversation.imageUrl == null
                          ? Center(
                              child: Icon(
                                _getIconData(),
                                color: _getIconColor(),
                                size: 26,
                              ),
                            )
                          : null,
                    ),
                    if (widget.conversation.isOnline && !widget.conversation.isGroup)
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
                              color: const Color(0xFF1A1A1A),
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
                          child: Text(
                            widget.conversation.name,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.conversation.isActiveTimer)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: material.Colors.green.withValues(alpha: 0.2),
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
                            widget.conversation.lastSenderId == widget.currentUserId)
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
                                ? (widget.conversation.taskTitle ?? 'Active Task')
                                : (widget.conversation.lastMessage ??
                                    (widget.conversation.isGroup
                                        ? 'No messages yet'
                                        : 'Start chatting')),
                            style: GoogleFonts.outfit(
                              color: widget.conversation.unreadCount > 0 || widget.conversation.isActiveTimer
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.white.withValues(alpha: 0.4),
                              fontSize: 14,
                              fontWeight: widget.conversation.unreadCount > 0 || widget.conversation.isActiveTimer
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
                            ? Colors.yellow
                            : Colors.white.withValues(alpha: 0.35),
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
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.conversation.unreadCount.toString(),
                          style: GoogleFonts.outfit(
                            color: Colors.black,
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
