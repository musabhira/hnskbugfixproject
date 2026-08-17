import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/tax_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_tax_form.dart';

class ZoyarexTaxesPage extends ConsumerWidget {
  const ZoyarexTaxesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxesAsync = ref.watch(taxesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Registration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexTaxFormPage()));
            },
            tooltip: 'Create Tax',
          ),
        ],
      ),
      body: taxesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (taxes) {
          if (taxes.isEmpty) {
            return const Center(child: Text('No Taxes Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(taxesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: taxes.length,
              itemBuilder: (context, index) {
                final tax = taxes[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.receipt_long, color: Colors.white),
                    ),
                    title: Text('${tax.taxName} (${tax.taxRate}%)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Type: ${tax.taxMode} | Branch: ${tax.branchName}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tax.coreAmountFlag) const Icon(Icons.star, color: Colors.amber, size: 20),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexTaxFormPage(tax: tax)));
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
