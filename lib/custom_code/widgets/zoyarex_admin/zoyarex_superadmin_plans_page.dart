import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/plan_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexSuperadminPlansPage extends ConsumerStatefulWidget {
  const ZoyarexSuperadminPlansPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ZoyarexSuperadminPlansPage> createState() => _ZoyarexSuperadminPlansPageState();
}

class _ZoyarexSuperadminPlansPageState extends ConsumerState<ZoyarexSuperadminPlansPage> {

  Future<void> _deletePlan(PlanModel plan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${plan.name}?'),
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
        await ZoyarexSupabase.client.from('plans').delete().eq('id', plan.id);
        ref.refresh(planProvider);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan deleted')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showForm([PlanModel? plan]) {
    final nameCtrl = TextEditingController(text: plan?.name ?? '');
    final descCtrl = TextEditingController(text: plan?.description ?? '');
    final priceCtrl = TextEditingController(text: plan?.price.toString() ?? '');
    String cycle = plan?.billingCycle ?? 'monthly';
    bool isActive = plan?.isActive ?? true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(plan == null ? 'Create Plan' : 'Edit Plan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Plan Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 2),
                const SizedBox(height: 12),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: cycle,
                  decoration: const InputDecoration(labelText: 'Billing Cycle', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                  ],
                  onChanged: (val) { if (val != null) setState(() => cycle = val); },
                ),
                SwitchListTile(title: const Text('Is Active'), value: isActive, onChanged: (val) => setState(() => isActive = val)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (nameCtrl.text.trim().isEmpty) return;
                setState(() => isLoading = true);
                try {
                  final payload = {
                    'name': nameCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'price': double.tryParse(priceCtrl.text) ?? 0.0,
                    'billing_cycle': cycle,
                    'is_active': isActive,
                  };
                  if (plan == null) {
                    await ZoyarexSupabase.client.from('plans').insert(payload);
                  } else {
                    await ZoyarexSupabase.client.from('plans').update(payload).eq('id', plan.id);
                  }
                  ref.refresh(planProvider);
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
    final plansAsync = ref.watch(planProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Plans'), backgroundColor: Colors.purple),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (plans) {
          if (plans.isEmpty) return const Center(child: Text('No Plans Found'));
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(planProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.card_membership, color: Colors.purple),
                    title: Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${plan.billingCycle.toUpperCase()} - \$${plan.price}\n${plan.description}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showForm(plan)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deletePlan(plan)),
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
