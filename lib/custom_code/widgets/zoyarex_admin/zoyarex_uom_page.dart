import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/uom_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexUomPage extends ConsumerStatefulWidget {
  const ZoyarexUomPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ZoyarexUomPage> createState() => _ZoyarexUomPageState();
}

class _ZoyarexUomPageState extends ConsumerState<ZoyarexUomPage> {

  Future<void> _deleteUom(UomModel uom) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${uom.name}?'),
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
            .from('uom')
            .delete()
            .eq('uom_id', uom.id); // Assuming uom_id based on schema
        
        ref.refresh(uomProvider);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UOM deleted')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showForm([UomModel? uom]) {
    final nameCtrl = TextEditingController(text: uom?.name ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(uom == null ? 'Create UOM' : 'Edit UOM'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'UOM Name (e.g., Kg, Litre)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (nameCtrl.text.trim().isEmpty) return;
                setState(() => isLoading = true);
                try {
                  final payload = {'uom': nameCtrl.text.trim()};
                  if (uom == null) {
                    await ZoyarexSupabase.client.from('uom').insert(payload);
                  } else {
                    await ZoyarexSupabase.client.from('uom').update(payload).eq('uom_id', uom.id);
                  }
                  ref.refresh(uomProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                } finally {
                  if (ctx.mounted) setState(() => isLoading = false);
                }
              },
              child: isLoading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uomAsync = ref.watch(uomProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Unit of Measurement (UOM)')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: uomAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (uoms) {
          if (uoms.isEmpty) return const Center(child: Text('No UOMs Found'));
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(uomProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: uoms.length,
              itemBuilder: (context, index) {
                final uom = uoms[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.square_foot, color: Colors.orange),
                    title: Text(uom.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showForm(uom),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUom(uom),
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
