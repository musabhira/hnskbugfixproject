import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/price_list_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_price_list_form.dart';

class ZoyarexPriceListsPage extends ConsumerWidget {
  const ZoyarexPriceListsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(priceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Lists'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPriceListForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (lists) {
          if (lists.isEmpty) {
            return const Center(child: Text('No Price Lists Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(priceListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final pl = lists[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: pl.isActive ? Colors.blueAccent : Colors.grey,
                      child: const Icon(Icons.price_change, color: Colors.white),
                    ),
                    title: Text(pl.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(pl.isActive ? 'Active' : 'Inactive'),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexPriceListForm(priceList: pl)));
                    },
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
