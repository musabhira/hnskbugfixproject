import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/raw_material_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_raw_material_form.dart';

class ZoyarexRawMaterialsPage extends ConsumerWidget {
  const ZoyarexRawMaterialsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawMaterialsAsync = ref.watch(rawMaterialsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Recipes (Raw Materials)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexRawMaterialFormPage()));
            },
            tooltip: 'Create Recipe',
          ),
        ],
      ),
      body: rawMaterialsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(child: Text('No Recipes Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(rawMaterialsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.brown,
                      child: Icon(Icons.blender, color: Colors.white),
                    ),
                    title: Text(recipe.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${recipe.rawMaterials.length} ingredients mapped'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexRawMaterialFormPage(recipe: recipe)));
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
