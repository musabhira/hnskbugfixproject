import 'package:fluent_ui/fluent_ui.dart';
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

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              FluentPageRoute(
                builder: (context) => NotificationDetailPage(
                  notification: notification,
                  onUpdate: onRefresh,
                ),
              ),
            );
          },
          child: Card(
            padding: const EdgeInsets.all(12),
            backgroundColor: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(12),
            borderColor:
                isUnread ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isTaskAssign ? FluentIcons.assign : FluentIcons.info,
                      color: Colors.yellow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                if (isInvite &&
                    status != 'approved' &&
                    status != 'rejected') ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap to view details',
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
                  ),
                ],
                if (status == 'approved') ...[
                  const SizedBox(height: 8),
                  Text(
                    'Accepted',
                    style:
                        GoogleFonts.outfit(color: Colors.green, fontSize: 12),
                  ),
                ],
                if (status == 'rejected') ...[
                  const SizedBox(height: 8),
                  Text(
                    'Declined',
                    style: GoogleFonts.outfit(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ));
  }
}
