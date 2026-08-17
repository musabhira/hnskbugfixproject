import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/sale_invoice_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_sale_invoice_form.dart';

class ZoyarexSaleInvoicesPage extends ConsumerWidget {
  const ZoyarexSaleInvoicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(saleInvoicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Invoices'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexSaleInvoiceForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (invoices) {
          if (invoices.isEmpty) {
            return const Center(child: Text('No Sale Invoices Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(saleInvoicesProvider);
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
                      backgroundColor: isPaid ? Colors.green : Colors.orange,
                      child: Icon(isPaid ? Icons.check : Icons.pending, color: Colors.white),
                    ),
                    title: Text('${invoice.voucherNumber ?? 'Draft'} - ${invoice.partyName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Branch: ${invoice.branchName}'),
                          Text('Date: ${invoice.voucherDate} | Status: ${invoice.voucherStatus}'),
                          Text('Net: ${invoice.netAmount.toStringAsFixed(2)} | Paid: ${invoice.paidAmount.toStringAsFixed(2)} | Balance: ${invoice.balanceAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexSaleInvoiceForm(invoice: invoice)));
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
