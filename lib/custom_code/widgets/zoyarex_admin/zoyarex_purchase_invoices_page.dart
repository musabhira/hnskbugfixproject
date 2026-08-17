import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/purchase_invoice_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_purchase_invoice_form.dart';

class ZoyarexPurchaseInvoicesPage extends ConsumerWidget {
  const ZoyarexPurchaseInvoicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(purchaseInvoicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Invoices'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPurchaseInvoiceForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(child: Text('No Purchase Invoices Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(purchaseInvoicesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                final isPaid = invoice.voucherStatus == 'completed' || invoice.balanceAmount <= 0;
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPaid ? Colors.green : Colors.red,
                      child: Icon(isPaid ? Icons.check : Icons.warning, color: Colors.white),
                    ),
                    title: Text('${invoice.voucherNumber ?? 'Draft'} - ${invoice.partyName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${invoice.voucherDate} | Status: ${invoice.voucherStatus}'),
                        Text('Net: ${invoice.netAmount.toStringAsFixed(2)} | Paid: ${invoice.paidAmount.toStringAsFixed(2)} | Balance: ${invoice.balanceAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexPurchaseInvoiceForm(invoice: invoice)));
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
