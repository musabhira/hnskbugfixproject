import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/notification_detail_page.dart';

class NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onRefresh;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final type = notification['type'];
    final message = notification['message'];
    final status = notification['status'];

    final isInvite = type == 'project_invite';
    final isTaskAssign = type == 'task_assign';
    final isUnread = status == 'unread';

    // If it's already handled, maybe don't show buttons?
    // Or if handled, don't show at all? Usually notifications stay for history.

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailPage(
              notification: notification,
              onUpdate: onRefresh,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isUnread
                  ? Colors.yellow.withOpacity(0.1)
                  : Colors.transparent,
              width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                      isTaskAssign
                          ? Icons.assignment_ind
                          : Icons.notifications_active,
                      color: Colors.yellow,
                      size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style:
                          GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  if (isUnread)
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.yellow, shape: BoxShape.circle)),
                ],
              ),
              // Buttons removed, moved to detail page.
              if (isInvite && status != 'approved' && status != 'rejected') ...[
                const SizedBox(height: 8),
                Text('Tap to view details',
                    style:
                        GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
              ],
              if (status == 'approved') ...[
                const SizedBox(height: 8),
                Text('Accepted',
                    style:
                        GoogleFonts.outfit(color: Colors.green, fontSize: 12)),
              ],
              if (status == 'rejected') ...[
                const SizedBox(height: 8),
                Text('Declined',
                    style: GoogleFonts.outfit(color: Colors.red, fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
