import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/payment_mode_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_payment_mode_form.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexPaymentModesPage extends ConsumerWidget {
  const ZoyarexPaymentModesPage({Key? key}) : super(key: key);

  Future<void> _deleteMode(BuildContext context, WidgetRef ref, PaymentModeModel mode) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${mode.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ZoyarexSupabase.client
            .from('payment_modes')
            .update({'status': 'Deleted'})
            .eq('id', mode.id);
        
        ref.refresh(paymentModesProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Mode deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modesAsync = ref.watch(paymentModesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Modes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPaymentModeFormPage()));
        },
        child: const Icon(Icons.add),
      ),
      body: modesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (modes) {
          if (modes.isEmpty) {
            return const Center(child: Text('No Payment Modes Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(paymentModesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: modes.length,
              itemBuilder: (context, index) {
                final mode = modes[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.payment, color: Colors.white),
                    ),
                    title: Text('${mode.name} (${mode.code})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${mode.type}'),
                        if (mode.description.isNotEmpty) Text(mode.description),
                        Text('Status: ${mode.status}', style: TextStyle(color: mode.status == 'Active' ? Colors.green : Colors.grey)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexPaymentModeFormPage(mode: mode)));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMode(context, ref, mode),
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
