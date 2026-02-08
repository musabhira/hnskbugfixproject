import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart';

class ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onStatusTap;
  final VoidCallback? onLongPress;

  const ConversationTile({
    Key? key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    this.onStatusTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return material.Material(
      color: Colors.transparent,
      child: material.InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF000000), // Pure black for flat look
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: conversation.hasStatus ? onStatusTap : onTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (conversation.hasStatus)
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: conversation.isGroup
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF833AB4), // Purple
                                    Color(0xFFF77737), // Orange
                                    Color(0xFFFCAF45), // Yellow
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                )
                              : null,
                          border: conversation.isGroup
                              ? null
                              : Border.all(
                                  color: Colors.yellow,
                                  width: 2,
                                ),
                        ),
                      ),
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFF262626),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1.5,
                        ),
                        image: conversation.imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(conversation.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: conversation.imageUrl == null
                          ? Center(
                              child: Icon(
                                conversation.isNotification
                                    ? FluentIcons.info
                                    : (conversation.isGroup
                                        ? FluentIcons.group
                                        : FluentIcons.contact),
                                color: conversation.isNotification
                                    ? Colors.yellow
                                    : Colors.white.withOpacity(0.5),
                                size: 26,
                              ),
                            )
                          : null,
                    ),
                    if (conversation.isOnline && !conversation.isGroup)
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
                    Text(
                      conversation.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (!conversation.isGroup &&
                            conversation.lastSenderId == currentUserId)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              FluentIcons.check_mark,
                              size: 14,
                              color: material.Colors.blue.withOpacity(0.7),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            conversation.lastMessage ??
                                (conversation.isGroup
                                    ? 'No messages yet'
                                    : 'Start chatting'),
                            style: GoogleFonts.outfit(
                              color: conversation.unreadCount > 0
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.white.withOpacity(0.4),
                              fontSize: 14,
                              fontWeight: conversation.unreadCount > 0
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
                  if (conversation.lastMessageTime != null)
                    Text(
                      timeago.format(conversation.lastMessageTime!,
                          locale: 'en_short'),
                      style: GoogleFonts.outfit(
                        color: conversation.unreadCount > 0
                            ? Colors.yellow
                            : Colors.white.withOpacity(0.35),
                        fontSize: 12,
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  if (conversation.unreadCount > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.yellow.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          conversation.unreadCount.toString(),
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
