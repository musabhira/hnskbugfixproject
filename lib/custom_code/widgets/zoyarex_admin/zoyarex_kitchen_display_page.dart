import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/kitchen_display_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_kitchen_display_form.dart';

class ZoyarexKitchenDisplayPage extends ConsumerWidget {
  const ZoyarexKitchenDisplayPage({Key? key}) : super(key: key);

  static IconData _typeIcon(String type) {
    switch (type) {
      case 'bar': return Icons.local_bar;
      case 'expediter': return Icons.supervisor_account;
      default: return Icons.kitchen;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kdsAsync = ref.watch(kitchenDisplayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Display Systems'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexKitchenDisplayForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: kdsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (displays) {
          if (displays.isEmpty) {
            return const Center(child: Text('No Kitchen Displays Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(kitchenDisplayProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: displays.length,
              itemBuilder: (context, index) {
                final kds = displays[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: kds.isActive ? Colors.deepOrange : Colors.grey,
                      child: Icon(_typeIcon(kds.displayType), color: Colors.white),
                    ),
                    title: Text(kds.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Type: ${kds.displayType.toUpperCase()} | Status: ${kds.isActive ? 'Active' : 'Inactive'}'),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexKitchenDisplayForm(kds: kds)));
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
