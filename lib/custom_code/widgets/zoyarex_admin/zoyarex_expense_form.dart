import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/expense_provider.dart';

class ZoyarexExpenseForm extends ConsumerStatefulWidget {
  final ExpenseModel? expense;

  const ZoyarexExpenseForm({Key? key, this.expense}) : super(key: key);

  @override
  ConsumerState<ZoyarexExpenseForm> createState() => _ZoyarexExpenseFormState();
}

class _ZoyarexExpenseFormState extends ConsumerState<ZoyarexExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  late TextEditingController _notesCtrl;
  String _typeId = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.expense?.amount.toString() ?? '');
    _notesCtrl = TextEditingController(text: widget.expense?.notes ?? '');
    _typeId = widget.expense?.expenseTypeId ?? '';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'amount': double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
        'notes': _notesCtrl.text.trim(),
        'expense_type_id': _typeId.isEmpty ? null : _typeId,
        'expense_date': DateTime.now().toIso8601String(),
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.expense == null) {
        await ZoyarexSupabase.client.from('expenses').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('expenses').update(payload).eq('id', widget.expense!.id);
      }
      
      ref.refresh(expenseProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved Successfully')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.expense == null ? 'Create Expense' : 'Edit Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _typeId,
              decoration: const InputDecoration(labelText: 'Expense Type ID', border: OutlineInputBorder()),
              onChanged: (v) => _typeId = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}
