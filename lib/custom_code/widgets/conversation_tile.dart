import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pocket_mates_app/custom_code/widgets/chat/whats_app_groups_provider.dart';

class ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final String currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ConversationTile({
    Key? key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2C34), // Dark background
        borderRadius: BorderRadius.circular(12),
        border: (conversation.unreadCount > 0 || conversation.isNotification)
            ? Border.all(color: Colors.yellow.withOpacity(0.3), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        onLongPress: onLongPress,
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[800],
              backgroundImage: conversation.imageUrl != null
                  ? NetworkImage(conversation.imageUrl!)
                  : null,
              child: conversation.imageUrl == null
                  ? Icon(
                      conversation.isNotification
                          ? Icons.notifications_active
                          : (conversation.isGroup ? Icons.group : Icons.person),
                      color: conversation.isNotification
                          ? Colors.yellow
                          : Colors.white70,
                    )
                  : null,
            ),
            if (conversation.isOnline && !conversation.isGroup)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1F2C34),
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          conversation.name,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            if (!conversation.isGroup &&
                conversation.lastSenderId == currentUserId)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.done_all,
                  size: 16,
                  color: Colors.blue, // Or check read status if available
                ),
              ),
            Expanded(
              child: Text(
                conversation.lastMessage ??
                    (conversation.isGroup
                        ? 'No messages yet'
                        : 'Start chatting'),
                style: GoogleFonts.inter(
                  color: conversation.unreadCount > 0
                      ? Colors.white
                      : Colors.white60,
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
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (conversation.lastMessageTime != null)
              Text(
                timeago.format(conversation.lastMessageTime!),
                style: GoogleFonts.inter(
                  color: conversation.unreadCount > 0
                      ? Colors.yellow
                      : Colors.white54,
                  fontSize: 12,
                  fontWeight: conversation.unreadCount > 0
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            if (conversation.unreadCount > 0) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
