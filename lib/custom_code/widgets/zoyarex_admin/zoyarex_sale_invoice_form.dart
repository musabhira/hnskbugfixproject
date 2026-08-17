import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexSaleInvoiceForm extends ConsumerStatefulWidget {
  final dynamic invoice;

  const ZoyarexSaleInvoiceForm({Key? key, this.invoice}) : super(key: key);

  @override
  ConsumerState<ZoyarexSaleInvoiceForm> createState() => _ZoyarexSaleInvoiceFormState();
}

class _ZoyarexSaleInvoiceFormState extends ConsumerState<ZoyarexSaleInvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _notesCtrl;
  String _status = 'unpaid';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _customerCtrl = TextEditingController(text: widget.invoice?['customer_name'] ?? '');
    _amountCtrl = TextEditingController(text: widget.invoice?['total_amount']?.toString() ?? '');
    _notesCtrl = TextEditingController(text: widget.invoice?['notes'] ?? '');
    _status = widget.invoice?['status'] ?? 'unpaid';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'customer_name': _customerCtrl.text.trim(),
        'total_amount': double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
        'notes': _notesCtrl.text.trim(),
        'status': _status,
        'invoice_date': DateTime.now().toIso8601String(),
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.invoice == null) {
        await ZoyarexSupabase.client.from('sale_invoices').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('sale_invoices').update(payload).eq('id', widget.invoice['id']);
      }

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
      appBar: AppBar(title: Text(widget.invoice == null ? 'Create Sale Invoice' : 'Edit Invoice')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _customerCtrl,
              decoration: const InputDecoration(labelText: 'Customer Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Total Amount', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: ['unpaid', 'partial', 'paid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _status = v!),
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
