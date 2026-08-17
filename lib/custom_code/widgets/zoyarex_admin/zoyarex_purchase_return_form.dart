import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/purchase_return_provider.dart';

class ZoyarexPurchaseReturnForm extends ConsumerStatefulWidget {
  final PurchaseReturnModel? returnModel;

  const ZoyarexPurchaseReturnForm({Key? key, this.returnModel}) : super(key: key);

  @override
  ConsumerState<ZoyarexPurchaseReturnForm> createState() => _ZoyarexPurchaseReturnFormState();
}

class _ZoyarexPurchaseReturnFormState extends ConsumerState<ZoyarexPurchaseReturnForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _reasonCtrl;
  String _status = 'pending';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController();
    _amountCtrl = TextEditingController(text: widget.returnModel?.netAmount.toString() ?? '');
    _reasonCtrl = TextEditingController();
    _status = widget.returnModel?.status ?? 'pending';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'notes': _notesCtrl.text.trim(),
        'total_amount': double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
        'reason': _reasonCtrl.text.trim(),
        'status': _status,
        'return_date': DateTime.now().toIso8601String(),
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.returnModel == null) {
        await ZoyarexSupabase.client.from('purchase_returns').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('purchase_returns').update(payload).eq('id', widget.returnModel!.voucherId);
      }
      
      ref.refresh(purchaseReturnProvider);

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
      appBar: AppBar(title: Text(widget.returnModel == null ? 'Create Purchase Return' : 'Edit Return')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Total Amount', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonCtrl,
              decoration: const InputDecoration(labelText: 'Reason for Return', border: OutlineInputBorder()),
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
              items: ['pending', 'approved', 'completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
