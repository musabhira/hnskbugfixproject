import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/activity_log_provider.dart';

class ZoyarexActivityLogPage extends ConsumerWidget {
  const ZoyarexActivityLogPage({Key? key}) : super(key: key);

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'create': return Colors.green;
      case 'update': return Colors.blue;
      case 'delete': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'create': return Icons.add;
      case 'update': return Icons.edit;
      case 'delete': return Icons.delete;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(activityLogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No Activity Logs Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(activityLogProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getActionColor(log.action).withOpacity(0.2),
                      child: Icon(_getActionIcon(log.action), color: _getActionColor(log.action)),
                    ),
                    title: Text('${log.action.toUpperCase()} ${log.entityType} - ${log.entityValue}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('By: ${log.createdByName} | At: ${log.createdAt}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
