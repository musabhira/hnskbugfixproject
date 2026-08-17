import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/expense_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_expense_form.dart';

class ZoyarexExpensesPage extends ConsumerWidget {
  const ZoyarexExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexExpenseForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(child: Text('No Expenses Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(expenseProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final exp = expenses[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.money_off, color: Colors.white),
                    ),
                    title: Text(exp.expenseTypeName ?? 'Expense Type ${exp.expenseTypeId.substring(0, 5)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${exp.date.split('T')[0]}'),
                        if (exp.notes != null) Text('Notes: ${exp.notes}'),
                      ],
                    ),
                    trailing: Text(
                      '₹${exp.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexExpenseForm(expense: exp)));
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
