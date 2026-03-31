import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/teams/notification_detail_page.dart';

class NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onRefresh;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onRefresh,
  });

  @override
  Widget build(material.BuildContext context) {
    final type = notification['type'];
    final message = notification['message'];
    final status = notification['status'];
    final createdAt = notification['created_at'];

    final isInvite = type == 'project_invite';
    final isTaskAssign = type == 'task_assign';
    final isUnread = status == 'unread';

    return material.Padding(
      padding: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: material.InkWell(
        onTap: () {
          material.Navigator.push(
            context,
            FluentPageRoute(
              builder: (context) => NotificationDetailPage(
                notification: notification,
                onUpdate: onRefresh,
              ),
            ),
          );
        },
        borderRadius: material.BorderRadius.circular(20),
        child: material.Container(
          padding: const material.EdgeInsets.all(16),
          decoration: material.BoxDecoration(
            color: const material.Color(0xFF1E1E1E),
            borderRadius: material.BorderRadius.circular(20),
            border: material.Border.all(
              color: isUnread 
                ? material.Colors.yellow.withValues(alpha: 0.3) 
                : material.Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: [
              if (isUnread)
                material.BoxShadow(
                  color: material.Colors.yellow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
            ],
          ),
          child: material.Row(
            crossAxisAlignment: material.CrossAxisAlignment.start,
            children: [
              material.Container(
                padding: const material.EdgeInsets.all(12),
                decoration: material.BoxDecoration(
                  color: isUnread 
                    ? material.Colors.yellow.withValues(alpha: 0.1) 
                    : material.Colors.white.withValues(alpha: 0.05),
                  borderRadius: material.BorderRadius.circular(14),
                ),
                child: material.Icon(
                  isTaskAssign ? FluentIcons.assign : (isInvite ? FluentIcons.contact_info : FluentIcons.info),
                  color: isUnread ? material.Colors.yellow : material.Colors.grey,
                  size: 20,
                ),
              ),
              const material.SizedBox(width: 16),
              material.Expanded(
                child: material.Column(
                  crossAxisAlignment: material.CrossAxisAlignment.start,
                  children: [
                    material.Row(
                      mainAxisAlignment: material.MainAxisAlignment.spaceBetween,
                      children: [
                        material.Text(
                          isTaskAssign ? 'Task Assigned' : (isInvite ? 'Project Invite' : 'Notification'),
                          style: GoogleFonts.outfit(
                            color: isUnread ? material.Colors.yellow : material.Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        if (createdAt != null)
                          material.Text(
                            _getTimeTag(createdAt),
                            style: GoogleFonts.outfit(
                              color: material.Colors.grey.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    const material.SizedBox(height: 6),
                    material.Text(
                      message,
                      style: GoogleFonts.outfit(
                        color: material.Colors.white.withValues(alpha: isUnread ? 1.0 : 0.7),
                        fontSize: 14,
                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                        height: 1.4,
                      ),
                    ),
                    if (isInvite && status != 'approved' && status != 'rejected') ...[
                      const material.SizedBox(height: 10),
                      material.Container(
                        padding: const material.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: material.BoxDecoration(
                          color: material.Colors.blue.withValues(alpha: 0.1),
                          borderRadius: material.BorderRadius.circular(6),
                        ),
                        child: material.Text(
                          'PENDING ACTION',
                          style: GoogleFonts.outfit(color: material.Colors.blue, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    if (status == 'approved') ...[
                      const material.SizedBox(height: 8),
                      material.Row(
                        children: [
                          const material.Icon(material.Icons.check_circle, color: material.Colors.green, size: 14),
                          const material.SizedBox(width: 4),
                          material.Text(
                            'Accepted',
                            style: GoogleFonts.outfit(color: material.Colors.green, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                    if (status == 'rejected') ...[
                      const material.SizedBox(height: 8),
                      material.Row(
                        children: [
                          const material.Icon(material.Icons.cancel, color: material.Colors.red, size: 14),
                          const material.SizedBox(height: 4),
                          material.Text(
                            'Declined',
                            style: GoogleFonts.outfit(color: material.Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isUnread)
                material.Container(
                  margin: const material.EdgeInsets.only(left: 8, top: 20),
                  width: 6,
                  height: 6,
                  decoration: const material.BoxDecoration(
                    color: material.Colors.yellow,
                    shape: material.BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeTag(dynamic createdAt) {
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return '';
    }
  }
}