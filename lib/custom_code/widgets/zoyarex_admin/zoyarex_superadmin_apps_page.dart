import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/app_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexSuperadminAppsPage extends ConsumerStatefulWidget {
  const ZoyarexSuperadminAppsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ZoyarexSuperadminAppsPage> createState() => _ZoyarexSuperadminAppsPageState();
}

class _ZoyarexSuperadminAppsPageState extends ConsumerState<ZoyarexSuperadminAppsPage> {

  Future<void> _deleteApp(AppModel app) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${app.name}?'),
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
        await ZoyarexSupabase.client.from('apps').delete().eq('id', app.id);
        ref.refresh(appProvider);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App deleted')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showForm([AppModel? app]) {
    final nameCtrl = TextEditingController(text: app?.name ?? '');
    final descCtrl = TextEditingController(text: app?.description ?? '');
    String status = app?.status ?? 'active';
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(app == null ? 'Create App' : 'Edit App'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'App Name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 2),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (val) { if (val != null) setState(() => status = val); },
                ),
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
                    'status': status,
                  };
                  if (app == null) {
                    await ZoyarexSupabase.client.from('apps').insert(payload);
                  } else {
                    await ZoyarexSupabase.client.from('apps').update(payload).eq('id', app.id);
                  }
                  ref.refresh(appProvider);
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
    final appsAsync = ref.watch(appProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Apps'), backgroundColor: Colors.purple),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: appsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (apps) {
          if (apps.isEmpty) return const Center(child: Text('No Apps Found'));
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(appProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.apps, color: Colors.purple),
                    title: Text(app.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Status: ${app.status}\n${app.description}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showForm(app)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteApp(app)),
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
