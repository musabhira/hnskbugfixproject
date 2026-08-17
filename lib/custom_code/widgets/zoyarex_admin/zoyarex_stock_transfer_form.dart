import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexStockTransferForm extends ConsumerStatefulWidget {
  final dynamic transfer;

  const ZoyarexStockTransferForm({Key? key, this.transfer}) : super(key: key);

  @override
  ConsumerState<ZoyarexStockTransferForm> createState() => _ZoyarexStockTransferFormState();
}

class _ZoyarexStockTransferFormState extends ConsumerState<ZoyarexStockTransferForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesCtrl;
  String _sourceWarehouse = '';
  String _targetWarehouse = '';
  String _status = 'pending';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.transfer?['notes'] ?? '');
    _sourceWarehouse = widget.transfer?['source_warehouse_id'] ?? '';
    _targetWarehouse = widget.transfer?['target_warehouse_id'] ?? '';
    _status = widget.transfer?['status'] ?? 'pending';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'notes': _notesCtrl.text.trim(),
        'source_warehouse_id': _sourceWarehouse,
        'target_warehouse_id': _targetWarehouse,
        'status': _status,
        'transfer_date': DateTime.now().toIso8601String(),
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.transfer == null) {
        await ZoyarexSupabase.client.from('stock_transfers').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('stock_transfers').update(payload).eq('id', widget.transfer['id']);
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
      appBar: AppBar(title: Text(widget.transfer == null ? 'Create Transfer' : 'Edit Transfer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _sourceWarehouse,
              decoration: const InputDecoration(labelText: 'Source Warehouse ID', border: OutlineInputBorder()),
              onChanged: (v) => _sourceWarehouse = v,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _targetWarehouse,
              decoration: const InputDecoration(labelText: 'Target Warehouse ID', border: OutlineInputBorder()),
              onChanged: (v) => _targetWarehouse = v,
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
              items: ['pending', 'in_transit', 'completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
