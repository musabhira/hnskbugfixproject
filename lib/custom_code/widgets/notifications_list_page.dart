import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
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

    return ScaffoldPage(
      header: PageHeader(
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: material.Colors.white,
            fontSize: 24,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: material.IconButton(
            icon: const Icon(FluentIcons.back, size: 20),
            onPressed: () => Navigator.pop(context),
            color: material.Colors.white,
          ),
        ),
      ),
      content: conversationsAsync.when(
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
                      color: material.Colors.white.withValues(alpha: 0.03),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FluentIcons.ringer,
                      size: 64,
                      color: material.Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'All caught up!',
                    style: GoogleFonts.outfit(
                      color: material.Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No new notifications to show.',
                    style: GoogleFonts.inter(
                      color: material.Colors.white.withValues(alpha: 0.4),
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
        loading: () => const Center(child: ProgressRing()),
        error: (err, stack) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: material.Colors.red))),
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, WidgetRef ref, ChatConversation notification) {
    final isInvite = notification.notificationType == 'project_invite';
    final isTask = notification.notificationType == 'task_assign';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: material.Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: material.Colors.white.withValues(alpha: 0.05),
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
                        color: _getIconColor(notification.notificationType)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForType(notification.notificationType),
                        color: _getIconColor(notification.notificationType),
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
                              color: material.Colors.white,
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
                              color:
                                  material.Colors.white.withValues(alpha: 0.3),
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
                          style: ButtonStyle(
                            backgroundColor:
                                ButtonState.all(material.Colors.yellow),
                            foregroundColor:
                                ButtonState.all(material.Colors.black),
                            padding: ButtonState.all(
                                const EdgeInsets.symmetric(vertical: 8)),
                            shape: ButtonState.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
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
                          child: Button(
                            onPressed: () =>
                                _handleReject(context, ref, notification),
                            style: ButtonStyle(
                              padding: ButtonState.all(
                                  const EdgeInsets.symmetric(vertical: 8)),
                              shape: ButtonState.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                            ),
                            child: const Text('Decline'),
                          ),
                        )
                      else
                        Button(
                          onPressed: () async {
                            await ref
                                .read(conversationsProvider.notifier)
                                .dismissNotification(notification.id);
                          },
                          child: const Icon(FluentIcons.delete, size: 14),
                        ),
                    ],
                  ),
                ] else ...[
                  // Single dismiss button for generic notifications
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Button(
                      onPressed: () async {
                        await ref
                            .read(conversationsProvider.notifier)
                            .dismissNotification(notification.id);
                      },
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
        return FluentIcons.project_collection;
      case 'task_assign':
        return FluentIcons.task_group;
      case 'group_request':
        return FluentIcons.group;
      default:
        return FluentIcons.info;
    }
  }

  material.Color _getIconColor(String? type) {
    switch (type) {
      case 'project_invite':
        return material.Colors.blue;
      case 'task_assign':
        return material.Colors.green;
      case 'group_request':
        return material.Colors.orange;
      default:
        return material.Colors.yellow;
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
          displayInfoBar(context, builder: (context, close) {
            return const InfoBar(
              title: Text('Accepted'),
              content: Text('You have successfully joined the project.'),
              severity: InfoBarSeverity.success,
            );
          });
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
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
          title: const Text('Error'),
          content: Text(message),
          severity: InfoBarSeverity.error,
        );
      });
    }
  }
}
