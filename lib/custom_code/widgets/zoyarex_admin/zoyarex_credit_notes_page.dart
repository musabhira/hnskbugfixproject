import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/credit_note_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_credit_note_form.dart';

class ZoyarexCreditNotesPage extends ConsumerWidget {
  const ZoyarexCreditNotesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(creditNotesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Notes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexCreditNoteForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(child: Text('No Credit Notes Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(creditNotesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final isPaid = note.voucherStatus == 'completed' || note.balanceAmount <= 0;
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPaid ? Colors.green : Colors.orange,
                      child: Icon(isPaid ? Icons.check : Icons.pending, color: Colors.white),
                    ),
                    title: Text('${note.voucherNumber ?? 'Draft'} - ${note.partyName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${note.voucherDate} | Status: ${note.voucherStatus}'),
                        Text('Net: ${note.netAmount.toStringAsFixed(2)} | Paid: ${note.paidAmount.toStringAsFixed(2)} | Balance: ${note.balanceAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexCreditNoteForm(note: note)));
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
