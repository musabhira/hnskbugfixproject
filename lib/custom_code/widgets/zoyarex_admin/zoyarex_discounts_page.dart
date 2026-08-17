import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/discount_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexDiscountsPage extends ConsumerStatefulWidget {
  const ZoyarexDiscountsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ZoyarexDiscountsPage> createState() => _ZoyarexDiscountsPageState();
}

class _ZoyarexDiscountsPageState extends ConsumerState<ZoyarexDiscountsPage> {

  Future<void> _deleteDiscount(DiscountModel discount) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${discount.name}?'),
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
            .from('discounts')
            .delete()
            .eq('id', discount.id);
        
        ref.refresh(discountProvider);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Discount deleted')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showForm([DiscountModel? discount]) {
    final nameCtrl = TextEditingController(text: discount?.name ?? '');
    final valueCtrl = TextEditingController(text: discount?.value.toString() ?? '');
    String type = discount?.type ?? 'percentage';
    bool isActive = discount?.isActive ?? true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(discount == null ? 'Create Discount' : 'Edit Discount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Discount Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valueCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                  DropdownMenuItem(value: 'amount', child: Text('Fixed Amount')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => type = val);
                },
              ),
              SwitchListTile(
                title: const Text('Is Active'),
                value: isActive,
                onChanged: (val) => setState(() => isActive = val),
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
                  final payload = {
                    'name': nameCtrl.text.trim(),
                    'type': type,
                    'value': double.tryParse(valueCtrl.text) ?? 0.0,
                    'is_active': isActive,
                  };
                  if (discount == null) {
                    await ZoyarexSupabase.client.from('discounts').insert(payload);
                  } else {
                    await ZoyarexSupabase.client.from('discounts').update(payload).eq('id', discount.id);
                  }
                  ref.refresh(discountProvider);
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
    final discountsAsync = ref.watch(discountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Discounts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: discountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (discounts) {
          if (discounts.isEmpty) return const Center(child: Text('No Discounts Found'));
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(discountProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: discounts.length,
              itemBuilder: (context, index) {
                final discount = discounts[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.local_offer, color: Colors.blue),
                    title: Text(discount.name),
                    subtitle: Text('${discount.type == 'percentage' ? '%' : '\$'}${discount.value} | ${discount.isActive ? "Active" : "Inactive"}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showForm(discount),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteDiscount(discount),
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
