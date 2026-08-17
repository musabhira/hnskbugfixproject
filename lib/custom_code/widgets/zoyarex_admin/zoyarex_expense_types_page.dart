import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/expense_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_expense_type_form.dart';

class ZoyarexExpenseTypesPage extends ConsumerWidget {
  const ZoyarexExpenseTypesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typesAsync = ref.watch(expenseTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Types'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexExpenseTypeForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: typesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (types) {
          if (types.isEmpty) {
            return const Center(child: Text('No Expense Types Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(expenseTypeProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: types.length,
              itemBuilder: (context, index) {
                final type = types[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.category, color: Colors.white),
                    ),
                    title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: type.description != null ? Text(type.description!) : null,
                    trailing: const Icon(Icons.edit, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexExpenseTypeForm(typeModel: type)));
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
