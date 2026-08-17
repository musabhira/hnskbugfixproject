import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/z_report_provider.dart';

class ZoyarexZReportsPage extends ConsumerWidget {
  const ZoyarexZReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(zReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Z-Reports (Closure)'),
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (reports) {
          if (reports.isEmpty) {
            return const Center(child: Text('No Z-Reports Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(zReportsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.summarize, color: Colors.white),
                    ),
                    title: Text('Closure: ${report.punchDate}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Branch: ${report.branchName ?? 'Main Branch'}'),
                        Text('Sales Total: ${report.salesTotal.toStringAsFixed(2)} | Expected Cash: ${report.expectedCash.toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: report.isSynced 
                        ? const Icon(Icons.cloud_done, color: Colors.green) 
                        : const Icon(Icons.cloud_off, color: Colors.red),
                    onTap: () {
                      // View details
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
