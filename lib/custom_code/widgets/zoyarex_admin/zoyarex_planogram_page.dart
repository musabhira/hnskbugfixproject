import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/planogram_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_planogram_form.dart';

class ZoyarexPlanogramPage extends ConsumerWidget {
  const ZoyarexPlanogramPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(planogramProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planogram (Product Assignments)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPlanogramFormPage()));
            },
            tooltip: 'Assign Product Location',
          ),
        ],
      ),
      body: assignmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (assignments) {
          if (assignments.isEmpty) {
            return const Center(child: Text('No Product Assignments Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(planogramProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.shelves, color: Colors.white),
                    ),
                    title: Text(assignment.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Floor: ${assignment.floorId} | Rack: ${assignment.rackId} | Shelf: ${assignment.shelfId}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexPlanogramFormPage(assignment: assignment)));
                      },
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
