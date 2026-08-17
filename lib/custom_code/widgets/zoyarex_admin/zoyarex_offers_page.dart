import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/offer_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_offer_form.dart';

class ZoyarexOffersPage extends ConsumerWidget {
  const ZoyarexOffersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(offerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers & Promos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexOfferForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: offersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (offers) {
          if (offers.isEmpty) {
            return const Center(child: Text('No Offers Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(offerProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: offer.isActive ? Colors.green : Colors.grey,
                      child: const Icon(Icons.local_offer, color: Colors.white),
                    ),
                    title: Text(offer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${offer.discountType == 'percentage' ? '${offer.discountValue}%' : '₹${offer.discountValue}'} Off'),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexOfferForm(offer: offer)));
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
