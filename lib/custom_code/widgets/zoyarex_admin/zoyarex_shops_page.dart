import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/shop_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_shop_form.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexShopsPage extends ConsumerWidget {
  const ZoyarexShopsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsync = ref.watch(shopsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Shops (Groups)'),
        actions: [
          if (ZoyarexSupabase.currentUserRole == 'superadmin')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexShopFormPage()));
              },
              tooltip: 'Create Shop',
            ),
        ],
      ),
      body: shopsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (shops) {
          if (shops.isEmpty) {
            return const Center(child: Text('No Groups Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(shopsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.storefront, color: Colors.white),
                    ),
                    title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Contact: +${shop.countryCode} ${shop.mobile} | Email: ${shop.email}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (shop.open) const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        if (shop.featured) const Icon(Icons.star, color: Colors.amber, size: 20),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexShopFormPage(shop: shop)));
                          },
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
