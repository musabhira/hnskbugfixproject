import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/outlet_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_outlet_form.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexOutletsPage extends ConsumerWidget {
  const ZoyarexOutletsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outletsAsync = ref.watch(outletsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Outlets (Branches)'),
        actions: [
          if (ZoyarexSupabase.currentUserRole == 'superadmin')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexOutletFormPage()));
              },
              tooltip: 'Create Outlet',
            ),
        ],
      ),
      body: outletsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (outlets) {
          if (outlets.isEmpty) {
            return const Center(child: Text('No Outlets Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(outletsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: outlets.length,
              itemBuilder: (context, index) {
                final outlet = outlets[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: outlet.isOpen ? Colors.green : Colors.grey,
                      child: const Icon(Icons.store, color: Colors.white),
                    ),
                    title: Text(outlet.branchName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${outlet.branchCode} • ${outlet.address}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexOutletFormPage(outlet: outlet)));
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
