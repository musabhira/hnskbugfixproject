import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/cash_session_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_cash_session_form.dart';

class ZoyarexCashSessionsPage extends ConsumerWidget {
  const ZoyarexCashSessionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(cashSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Sessions'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexCashSessionForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('No Cash Sessions Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(cashSessionProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: session.status == 'open' ? Colors.green : Colors.grey,
                      child: const Icon(Icons.point_of_sale, color: Colors.white),
                    ),
                    title: Text('Session User: ${session.userId.substring(0, 5)}...', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${session.sessionDate.split('T')[0]} | Status: ${session.status.toUpperCase()}'),
                        Text('Opening: ₹${session.openingBalance} | Closing: ${session.closingBalance != null ? '₹${session.closingBalance}' : 'N/A'}'),
                      ],
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexCashSessionForm(session: session)));
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
