import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/payment_out_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_payment_out_form.dart';

class ZoyarexPaymentOutsPage extends ConsumerWidget {
  const ZoyarexPaymentOutsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentOutsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Outs'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPaymentOutForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(child: Text('No Payment Outs Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(paymentOutsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.arrow_upward, color: Colors.white),
                    ),
                    title: Text('${payment.voucherNumber ?? 'Draft'} - ${payment.partyName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${payment.voucherDate} | Status: ${payment.voucherStatus}'),
                        Text('Amount: ${payment.netAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexPaymentOutForm(payment: payment)));
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
