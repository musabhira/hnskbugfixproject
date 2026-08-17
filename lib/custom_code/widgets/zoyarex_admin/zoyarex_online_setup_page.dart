import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/online_setup_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_online_setup_form.dart';

class ZoyarexOnlineSetupPage extends ConsumerWidget {
  const ZoyarexOnlineSetupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupAsync = ref.watch(onlineSetupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Setup'),
      ),
      body: setupAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (branches) {
          if (branches.isEmpty) {
            return const Center(child: Text('No Branches Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(onlineSetupProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final setup = branches[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: setup.isOnlineEnabled ? Colors.green : Colors.grey,
                      child: Icon(setup.isOnlineEnabled ? Icons.wifi : Icons.wifi_off, color: Colors.white),
                    ),
                    title: Text(setup.branchName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${setup.isOnlineEnabled ? "Online" : "Offline"}'),
                        Text('Radius: ${setup.deliveryRadius} km | Min Order: ₹${setup.minOrderValue} | Fee: ₹${setup.deliveryFee}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexOnlineSetupFormPage(setup: setup)));
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
