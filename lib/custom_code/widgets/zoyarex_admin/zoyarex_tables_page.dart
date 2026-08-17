import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/table_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_table_form.dart';

class ZoyarexTablesPage extends ConsumerWidget {
  const ZoyarexTablesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tablesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexTableFormPage()));
            },
            tooltip: 'Create Table',
          ),
        ],
      ),
      body: tablesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tables) {
          if (tables.isEmpty) {
            return const Center(child: Text('No Tables Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(tablesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.table_restaurant, color: Colors.white),
                    ),
                    title: Text(table.tableNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Capacity: ${table.capacity} | Floor: ${table.floorName} | Branch: ${table.branchName}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexTableFormPage(table: table)));
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
