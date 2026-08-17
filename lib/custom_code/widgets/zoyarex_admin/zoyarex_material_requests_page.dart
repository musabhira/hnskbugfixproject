import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/material_request_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_material_request_form.dart';

class ZoyarexMaterialRequestsPage extends ConsumerWidget {
  const ZoyarexMaterialRequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(materialRequestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Material Requests'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexMaterialRequestForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(child: Text('No Material Requests Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(materialRequestProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: req.status == 'approved' ? Colors.green : (req.status == 'rejected' ? Colors.red : Colors.orange),
                      child: const Icon(Icons.outbox, color: Colors.white),
                    ),
                    title: Text(req.requestNumber ?? 'Req-${req.requestId.substring(0, 5)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${req.requestDate.split('T')[0]}'),
                        if (req.requestedBy != null) Text('Requested By: ${req.requestedBy}'),
                        if (req.sourceWarehouse != null) Text('From: ${req.sourceWarehouse} -> To: ${req.targetWarehouse ?? "Unknown"}'),
                        Text('Status: ${req.status}'),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexMaterialRequestForm(request: req)));
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
