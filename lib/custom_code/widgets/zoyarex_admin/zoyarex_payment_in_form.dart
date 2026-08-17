import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexPaymentInForm extends ConsumerStatefulWidget {
  final dynamic payment;

  const ZoyarexPaymentInForm({Key? key, this.payment}) : super(key: key);

  @override
  ConsumerState<ZoyarexPaymentInForm> createState() => _ZoyarexPaymentInFormState();
}

class _ZoyarexPaymentInFormState extends ConsumerState<ZoyarexPaymentInForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  late TextEditingController _partyCtrl;
  late TextEditingController _notesCtrl;
  String _mode = 'cash';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.payment?['amount']?.toString() ?? '');
    _partyCtrl = TextEditingController(text: widget.payment?['party_name'] ?? '');
    _notesCtrl = TextEditingController(text: widget.payment?['notes'] ?? '');
    _mode = widget.payment?['payment_mode'] ?? 'cash';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'amount': double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
        'party_name': _partyCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
        'payment_mode': _mode,
        'payment_date': DateTime.now().toIso8601String(),
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.payment == null) {
        await ZoyarexSupabase.client.from('payment_ins').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('payment_ins').update(payload).eq('id', widget.payment['id']);
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
      appBar: AppBar(title: Text(widget.payment == null ? 'Create Payment In' : 'Edit Payment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _partyCtrl,
              decoration: const InputDecoration(labelText: 'Party / Customer Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Amount Received', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _mode,
              decoration: const InputDecoration(labelText: 'Payment Mode', border: OutlineInputBorder()),
              items: ['cash', 'card', 'bank_transfer', 'upi'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _mode = v!),
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
