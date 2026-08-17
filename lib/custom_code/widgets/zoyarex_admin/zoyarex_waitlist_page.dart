import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/waitlist_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_waitlist_form.dart';

class ZoyarexWaitlistPage extends ConsumerWidget {
  const ZoyarexWaitlistPage({Key? key}) : super(key: key);

  static Color _statusColor(String status) {
    switch (status) {
      case 'seated': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waitlistAsync = ref.watch(waitlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waitlist'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexWaitlistForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: waitlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('Waitlist is Empty'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(waitlistProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(entry.status),
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(entry.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Party Size: ${entry.partySize ?? 1}'),
                        if (entry.customerPhone != null) Text('Phone: ${entry.customerPhone}'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(entry.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                      backgroundColor: _statusColor(entry.status),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexWaitlistForm(entry: entry)));
                    },
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
