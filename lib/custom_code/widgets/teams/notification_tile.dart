import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/teams_service.dart';

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
    final sourceId = notification['source_id']; // Team ID
    final status = notification['status'];
    final teamsService = TeamsService();

    final isInvite = type == 'project_invite';
    final isUnread = status == 'unread';

    // If it's already handled, maybe don't show buttons?
    // Or if handled, don't show at all? Usually notifications stay for history.

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color:
                isUnread ? Colors.yellow.withOpacity(0.1) : Colors.transparent,
            width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active,
                    color: Colors.yellow, size: 20),
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
            if (isInvite && isUnread) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      await teamsService.declineInvite(sourceId);
                      // Update notification status locally or assume stream updates
                      // Mark notification read/declined
                      // (Implementation requires update logic for notification table too)
                      onRefresh();
                    },
                    child: const Text('Decline',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await teamsService.acceptInvite(sourceId);
                      // Mark notification
                      onRefresh();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
