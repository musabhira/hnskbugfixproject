import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'chat/whats_app_groups_provider.dart';
import 'teams/teams_service.dart';

class NotificationsListPage extends ConsumerWidget {
  const NotificationsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [const Color(0xFF121218), const Color(0xFF000000)]
        : [const Color(0xFFF4F4F9), const Color(0xFFFFFFFF)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: isDark ? material.Colors.white : material.Colors.black87,
              fontSize: 24,
            ),
          ),
          leading: material.IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.pop(context),
            color: isDark ? material.Colors.white : material.Colors.black87,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: conversationsAsync.when(
          data: (conversations) {
            final notifications =
                conversations.where((c) => c.isNotification).toList();

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark
                            ? material.Colors.white.withValues(alpha: 0.03)
                            : material.Colors.black.withValues(alpha: 0.03),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        size: 64,
                        color: isDark
                            ? material.Colors.white.withValues(alpha: 0.1)
                            : material.Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'All caught up!',
                      style: GoogleFonts.outfit(
                        color: isDark ? material.Colors.white : material.Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No new notifications to show.',
                      style: GoogleFonts.inter(
                        color: isDark
                            ? material.Colors.white.withValues(alpha: 0.4)
                            : material.Colors.black.withValues(alpha: 0.45),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(context, ref, notification);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: material.Colors.red))),
      ),
    ),
  );
}

  Widget _buildNotificationItem(
      BuildContext context, WidgetRef ref, ChatConversation notification) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInvite = notification.notificationType == 'project_invite';
    final isTask = notification.notificationType == 'task_assign';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? material.Colors.white.withValues(alpha: 0.02) : material.Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? material.Colors.white.withValues(alpha: 0.05) : material.Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: material.Material(
        color: material.Colors.transparent,
        child: material.InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {}, // Could show details
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getIconColor(isDark, notification.notificationType)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForType(notification.notificationType),
                        color: _getIconColor(isDark, notification.notificationType),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: material.CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.lastMessage ?? 'New Notification',
                            style: GoogleFonts.outfit(
                              color: isDark ? material.Colors.white : material.Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            timeago.format(
                                notification.lastMessageTime ?? DateTime.now()),
                            style: GoogleFonts.inter(
                              color: isDark
                                  ? material.Colors.white.withValues(alpha: 0.3)
                                  : material.Colors.black.withValues(alpha: 0.35),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isInvite || isTask) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              _handleAccept(context, ref, notification),
                          style: FilledButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFFFFD600) : const Color(0xFFFFB300),
                            foregroundColor: isDark ? material.Colors.black : material.Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            isInvite ? 'Accept Invite' : 'View Task',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (isInvite)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _handleReject(context, ref, notification),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? material.Colors.white : material.Colors.black87,
                              side: BorderSide(color: isDark ? material.Colors.white24 : material.Colors.black26),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Decline'),
                          ),
                        )
                      else
                        material.IconButton(
                          onPressed: () async {
                            await ref
                                .read(conversationsProvider.notifier)
                                .dismissNotification(notification.id);
                          },
                          icon: Icon(Icons.delete, size: 14, color: isDark ? material.Colors.white70 : material.Colors.black54),
                        ),
                    ],
                  ),
                ] else ...[
                  // Single dismiss button for generic notifications
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: material.TextButton(
                      onPressed: () async {
                        await ref
                            .read(conversationsProvider.notifier)
                            .dismissNotification(notification.id);
                      },
                      style: material.TextButton.styleFrom(
                        foregroundColor: isDark ? const Color(0xFFFFD600) : const Color(0xFFFFB300),
                      ),
                      child: const Text('Dismiss'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'project_invite':
        return Icons.folder_shared;
      case 'task_assign':
        return Icons.assignment;
      case 'group_request':
        return Icons.group;
      default:
        return Icons.info;
    }
  }

  Color _getIconColor(bool isDark, String? type) {
    switch (type) {
      case 'project_invite':
        return material.Colors.blue;
      case 'task_assign':
        return material.Colors.green;
      case 'group_request':
        return material.Colors.orange;
      default:
        return isDark ? const Color(0xFFFFD600) : const Color(0xFFFFB300);
    }
  }

  Future<void> _handleAccept(BuildContext context, WidgetRef ref,
      ChatConversation notification) async {
    final teamsService = TeamsService();

    if (notification.notificationType == 'project_invite' &&
        notification.sourceId != null) {
      try {
        await teamsService.acceptInvite(notification.sourceId!);
        // Dismiss notification after accepting
        await ref
            .read(conversationsProvider.notifier)
            .dismissNotification(notification.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have successfully joined the project.'),
              backgroundColor: material.Colors.green,
            ),
          );
        }
      } catch (e) {
        _showError(context, e.toString());
      }
    } else if (notification.notificationType == 'task_assign') {
      // Just mark as read/dismiss for now
      await ref
          .read(conversationsProvider.notifier)
          .dismissNotification(notification.id);
      // navigation to task detail could be added here
    } else {
      await ref
          .read(conversationsProvider.notifier)
          .dismissNotification(notification.id);
    }
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref,
      ChatConversation notification) async {
    final teamsService = TeamsService();

    if (notification.notificationType == 'project_invite' &&
        notification.sourceId != null) {
      try {
        await teamsService.declineInvite(notification.sourceId!);
        await ref
            .read(conversationsProvider.notifier)
            .dismissNotification(notification.id);
      } catch (e) {
        _showError(context, e.toString());
      }
    }
  }

  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: material.Colors.red,
        ),
      );
    }
  }
}
