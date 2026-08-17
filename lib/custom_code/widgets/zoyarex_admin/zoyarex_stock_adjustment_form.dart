import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

// Assuming there's a StockAdjustmentProvider elsewhere; for now we just handle form saving
class ZoyarexStockAdjustmentForm extends ConsumerStatefulWidget {
  final dynamic adjustment;

  const ZoyarexStockAdjustmentForm({Key? key, this.adjustment}) : super(key: key);

  @override
  ConsumerState<ZoyarexStockAdjustmentForm> createState() => _ZoyarexStockAdjustmentFormState();
}

class _ZoyarexStockAdjustmentFormState extends ConsumerState<ZoyarexStockAdjustmentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesCtrl;
  late TextEditingController _amountCtrl;
  String _status = 'pending';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.adjustment?['notes'] ?? '');
    _amountCtrl = TextEditingController(text: widget.adjustment?['total_amount']?.toString() ?? '');
    _status = widget.adjustment?['status'] ?? 'pending';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'notes': _notesCtrl.text.trim(),
        'total_amount': double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
        'status': _status,
        'adjustment_date': DateTime.now().toIso8601String(),
        'tenant_id': ZoyarexSupabase.currentTenantId // Fallback
      };

      if (widget.adjustment == null) {
        await ZoyarexSupabase.client.from('stock_adjustments').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('stock_adjustments').update(payload).eq('id', widget.adjustment['id']);
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
      appBar: AppBar(title: Text(widget.adjustment == null ? 'Create Stock Adj.' : 'Edit Stock Adj.')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Total Value Change', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes/Reason', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: ['pending', 'completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
