import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/stock_transfer_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_stock_transfer_form.dart';

class ZoyarexStockTransfersPage extends ConsumerWidget {
  const ZoyarexStockTransfersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfersAsync = ref.watch(stockTransfersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Transfers'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexStockTransferForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: transfersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (transfers) {
          if (transfers.isEmpty) {
            return const Center(child: Text('No Stock Transfers Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(stockTransfersProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final transfer = transfers[index];
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.sync_alt, color: Colors.white),
                    ),
                    title: Text('${transfer.voucherNumber ?? 'Draft'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${transfer.voucherDate} | Status: ${transfer.voucherStatus}'),
                        Text('Branch: ${transfer.branchName}'),
                      ],
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexStockTransferForm(transfer: transfer)));
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
