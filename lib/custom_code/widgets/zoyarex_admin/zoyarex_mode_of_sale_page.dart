import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/mode_of_sale_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_mode_of_sale_form.dart';

class ZoyarexModeOfSalePage extends ConsumerWidget {
  const ZoyarexModeOfSalePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modesAsync = ref.watch(modeOfSaleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode of Sale'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexModeOfSaleForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: modesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (modes) {
          if (modes.isEmpty) {
            return const Center(child: Text('No Modes of Sale Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(modeOfSaleProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: modes.length,
              itemBuilder: (context, index) {
                final mos = modes[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: mos.isActive ? Colors.indigo : Colors.grey,
                      child: Icon(mos.type == 'delivery' ? Icons.delivery_dining : (mos.type == 'takeaway' ? Icons.takeout_dining : Icons.restaurant), color: Colors.white),
                    ),
                    title: Text(mos.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(mos.type ?? 'Standard'),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexModeOfSaleForm(mos: mos)));
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
