import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/tags_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexTagsPage extends ConsumerStatefulWidget {
  const ZoyarexTagsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ZoyarexTagsPage> createState() => _ZoyarexTagsPageState();
}

class _ZoyarexTagsPageState extends ConsumerState<ZoyarexTagsPage> {

  Future<void> _deleteTag(TagModel tag) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${tag.name}?'),
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
            .from('tags')
            .delete()
            .eq('tag_id', tag.id); // Assuming tag_id based on schema
        
        ref.refresh(tagsProvider);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tag deleted')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showForm([TagModel? tag]) {
    final nameCtrl = TextEditingController(text: tag?.name ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(tag == null ? 'Create Tag' : 'Edit Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tag Name', border: OutlineInputBorder()),
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
                  final payload = {'tag_name': nameCtrl.text.trim()};
                  if (tag == null) {
                    await ZoyarexSupabase.client.from('tags').insert(payload);
                  } else {
                    await ZoyarexSupabase.client.from('tags').update(payload).eq('tag_id', tag.id);
                  }
                  ref.refresh(tagsProvider);
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
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: tagsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tags) {
          if (tags.isEmpty) return const Center(child: Text('No Tags Found'));
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(tagsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.label, color: Colors.blue),
                    title: Text(tag.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showForm(tag),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTag(tag),
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
