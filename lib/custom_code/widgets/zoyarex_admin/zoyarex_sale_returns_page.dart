import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/sale_return_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_sale_return_form.dart';

class ZoyarexSaleReturnsPage extends ConsumerWidget {
  const ZoyarexSaleReturnsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returnsAsync = ref.watch(saleReturnProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Returns (GT-V3)'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexSaleReturnForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: returnsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (returns) {
          if (returns.isEmpty) {
            return const Center(child: Text('No Sale Returns Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(saleReturnProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: returns.length,
              itemBuilder: (context, index) {
                final ret = returns[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ret.status == 'completed' ? Colors.green : Colors.orange,
                      child: const Icon(Icons.keyboard_return, color: Colors.white),
                    ),
                    title: Text(ret.voucherNumber ?? 'Ret-${ret.voucherId.substring(0, 5)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${ret.voucherDate.split('T')[0]}'),
                        if (ret.customerName != null) Text('Customer: ${ret.customerName}'),
                        Text('Status: ${ret.status}'),
                      ],
                    ),
                    trailing: Text(
                      '₹${ret.netAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexSaleReturnForm(returnModel: ret)));
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
