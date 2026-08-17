import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/warehouse_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_warehouse_form.dart';

class ZoyarexWarehousesPage extends ConsumerWidget {
  const ZoyarexWarehousesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warehousesAsync = ref.watch(warehousesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexWarehouseFormPage()));
            },
            tooltip: 'Create Warehouse',
          ),
        ],
      ),
      body: warehousesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (warehouses) {
          if (warehouses.isEmpty) {
            return const Center(child: Text('No Warehouses Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(warehousesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: warehouses.length,
              itemBuilder: (context, index) {
                final warehouse = warehouses[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.brown,
                      child: Icon(Icons.warehouse, color: Colors.white),
                    ),
                    title: Text('${warehouse.name} (${warehouse.code})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Location: ${warehouse.location} | Status: ${warehouse.status}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (warehouse.isPrivate) const Icon(Icons.lock, color: Colors.grey, size: 20),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexWarehouseFormPage(warehouse: warehouse)));
                          },
                        ),
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
