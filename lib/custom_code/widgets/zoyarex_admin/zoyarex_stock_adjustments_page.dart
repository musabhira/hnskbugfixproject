import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/stock_adjustment_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_stock_adjustment_form.dart';

class ZoyarexStockAdjustmentsPage extends ConsumerWidget {
  const ZoyarexStockAdjustmentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adjustmentsAsync = ref.watch(stockAdjustmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Adjustments'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexStockAdjustmentForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: adjustmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (adjustments) {
          if (adjustments.isEmpty) {
            return const Center(child: Text('No Stock Adjustments Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(stockAdjustmentsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: adjustments.length,
              itemBuilder: (context, index) {
                final adjustment = adjustments[index];
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.inventory, color: Colors.white),
                    ),
                    title: Text('${adjustment.voucherNumber ?? 'Draft'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${adjustment.voucherDate} | Status: ${adjustment.voucherStatus}'),
                        Text('Branch: ${adjustment.branchName}'),
                      ],
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexStockAdjustmentForm(adjustment: adjustment)));
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
