import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexLoyaltyPointForm extends ConsumerStatefulWidget {
  final dynamic loyaltyPoint;

  const ZoyarexLoyaltyPointForm({Key? key, this.loyaltyPoint}) : super(key: key);

  @override
  ConsumerState<ZoyarexLoyaltyPointForm> createState() => _ZoyarexLoyaltyPointFormState();
}

class _ZoyarexLoyaltyPointFormState extends ConsumerState<ZoyarexLoyaltyPointForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerCtrl;
  late TextEditingController _pointsCtrl;
  late TextEditingController _notesCtrl;
  String _transactionType = 'earned';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _customerCtrl = TextEditingController(text: widget.loyaltyPoint?['customer_name'] ?? '');
    _pointsCtrl = TextEditingController(text: widget.loyaltyPoint?['points']?.toString() ?? '');
    _notesCtrl = TextEditingController(text: widget.loyaltyPoint?['notes'] ?? '');
    _transactionType = widget.loyaltyPoint?['transaction_type'] ?? 'earned';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'customer_name': _customerCtrl.text.trim(),
        'points': int.tryParse(_pointsCtrl.text.trim()) ?? 0,
        'notes': _notesCtrl.text.trim(),
        'transaction_type': _transactionType,
        'transaction_date': DateTime.now().toIso8601String(),
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.loyaltyPoint == null) {
        await ZoyarexSupabase.client.from('loyalty_points').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('loyalty_points').update(payload).eq('id', widget.loyaltyPoint['id']);
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
      appBar: AppBar(title: Text(widget.loyaltyPoint == null ? 'Add Loyalty Points' : 'Edit Points')),
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
              controller: _pointsCtrl,
              decoration: const InputDecoration(labelText: 'Points', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _transactionType,
              decoration: const InputDecoration(labelText: 'Transaction Type', border: OutlineInputBorder()),
              items: ['earned', 'redeemed', 'expired'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _transactionType = v!),
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
