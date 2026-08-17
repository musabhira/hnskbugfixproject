import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/expense_provider.dart';

class ZoyarexExpenseTypeForm extends ConsumerStatefulWidget {
  final ExpenseTypeModel? typeModel;

  const ZoyarexExpenseTypeForm({Key? key, this.typeModel}) : super(key: key);

  @override
  ConsumerState<ZoyarexExpenseTypeForm> createState() => _ZoyarexExpenseTypeFormState();
}

class _ZoyarexExpenseTypeFormState extends ConsumerState<ZoyarexExpenseTypeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.typeModel?.name ?? '');
    _descCtrl = TextEditingController(text: widget.typeModel?.description ?? '');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.typeModel == null) {
        await ZoyarexSupabase.client.from('expense_types').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('expense_types').update(payload).eq('id', widget.typeModel!.id);
      }
      
      ref.refresh(expenseTypeProvider);

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
      appBar: AppBar(title: Text(widget.typeModel == null ? 'Create Expense Type' : 'Edit Type')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Type Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
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
