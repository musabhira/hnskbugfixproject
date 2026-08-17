import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/payment_term_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_payment_term_form.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexPaymentTermsPage extends ConsumerWidget {
  const ZoyarexPaymentTermsPage({Key? key}) : super(key: key);

  Future<void> _deleteTerm(BuildContext context, WidgetRef ref, PaymentTermModel term) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${term.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ZoyarexSupabase.client
            .from('gt_payment_terms')
            .delete()
            .eq('id', term.id); // Or gt_payment_term_id depending on exact schema
        
        ref.refresh(paymentTermsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Term deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(paymentTermsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Terms'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexPaymentTermFormPage()));
        },
        child: const Icon(Icons.add),
      ),
      body: termsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (terms) {
          if (terms.isEmpty) {
            return const Center(child: Text('No Payment Terms Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(paymentTermsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: terms.length,
              itemBuilder: (context, index) {
                final term = terms[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.request_quote, color: Colors.white),
                    ),
                    title: Text(term.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Days: ${term.days} | Discount Days: ${term.discountDays} | Discount: ${term.discountPercent}%'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexPaymentTermFormPage(term: term)));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTerm(context, ref, term),
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
