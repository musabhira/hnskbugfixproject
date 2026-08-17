import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/menu_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_menu_form.dart';

class ZoyarexMenusPage extends ConsumerWidget {
  const ZoyarexMenusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menusAsync = ref.watch(menusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menus (Sub-Categories)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexMenuFormPage()));
            },
            tooltip: 'Create Menu',
          ),
        ],
      ),
      body: menusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (menus) {
          if (menus.isEmpty) {
            return const Center(child: Text('No Menus Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(menusProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final menu = menus[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.restaurant_menu, color: Colors.white),
                    ),
                    title: Text(menu.menuName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Category: ${menu.categoryName}\nCode: ${menu.menuCode}\n${menu.description}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexMenuFormPage(menu: menu)));
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
