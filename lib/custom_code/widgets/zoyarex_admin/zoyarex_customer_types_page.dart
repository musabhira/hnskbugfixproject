import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/customer_type_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_customer_type_form.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexCustomerTypesPage extends ConsumerWidget {
  const ZoyarexCustomerTypesPage({Key? key}) : super(key: key);

  Future<void> _deleteType(BuildContext context, WidgetRef ref, CustomerTypeModel type) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${type.name}?'),
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
            .from('customer_types')
            .update({'status': 'Deleted'})
            .eq('id', type.id);
        
        ref.refresh(customerTypesProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer Type deleted')));
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
    final typesAsync = ref.watch(customerTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Types'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexCustomerTypeFormPage()));
        },
        child: const Icon(Icons.add),
      ),
      body: typesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (types) {
          if (types.isEmpty) {
            return const Center(child: Text('No Customer Types Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(customerTypesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: types.length,
              itemBuilder: (context, index) {
                final type = types[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.category, color: Colors.white),
                    ),
                    title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (type.description.isNotEmpty) Text(type.description),
                        Text('Status: ${type.status}', style: TextStyle(color: type.status == 'Active' ? Colors.green : Colors.grey)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexCustomerTypeFormPage(type: type)));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteType(context, ref, type),
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
