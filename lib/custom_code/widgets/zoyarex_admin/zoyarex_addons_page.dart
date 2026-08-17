import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/addon_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_addon_form.dart';

class ZoyarexAddonsPage extends ConsumerWidget {
  const ZoyarexAddonsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addonsAsync = ref.watch(addonsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Add-ons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexAddonFormPage()));
            },
            tooltip: 'Create Add-on',
          ),
        ],
      ),
      body: addonsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (addons) {
          if (addons.isEmpty) {
            return const Center(child: Text('No Add-ons Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(addonsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: addons.length,
              itemBuilder: (context, index) {
                final addon = addons[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.add_circle, color: Colors.white),
                    ),
                    title: Text(addon.addOnName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${addon.description}\nPrice: ₹${addon.addOnPrice}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexAddonFormPage(addon: addon)));
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
