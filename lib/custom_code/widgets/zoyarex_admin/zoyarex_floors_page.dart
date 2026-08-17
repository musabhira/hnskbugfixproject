import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/floor_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_floor_form.dart';

class ZoyarexFloorsPage extends ConsumerWidget {
  const ZoyarexFloorsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final floorsAsync = ref.watch(floorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Floors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexFloorFormPage()));
            },
            tooltip: 'Create Floor',
          ),
        ],
      ),
      body: floorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (floors) {
          if (floors.isEmpty) {
            return const Center(child: Text('No Floors Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(floorsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: floors.length,
              itemBuilder: (context, index) {
                final floor = floors[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.layers, color: Colors.white),
                    ),
                    title: Text(floor.floorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Branch: ${floor.branchName}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexFloorFormPage(floor: floor)));
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
