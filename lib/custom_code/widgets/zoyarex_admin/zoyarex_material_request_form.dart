import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/material_request_provider.dart';

class ZoyarexMaterialRequestForm extends ConsumerStatefulWidget {
  final MaterialRequestModel? request;

  const ZoyarexMaterialRequestForm({Key? key, this.request}) : super(key: key);

  @override
  ConsumerState<ZoyarexMaterialRequestForm> createState() => _ZoyarexMaterialRequestFormState();
}

class _ZoyarexMaterialRequestFormState extends ConsumerState<ZoyarexMaterialRequestForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesCtrl;
  String _targetWarehouse = '';
  String _status = 'pending';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController();
    _targetWarehouse = widget.request?.targetWarehouse ?? '';
    _status = widget.request?.status ?? 'pending';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'notes': _notesCtrl.text.trim(),
        'warehouse_id': _targetWarehouse,
        'status': _status,
        'request_date': DateTime.now().toIso8601String(),
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.request == null) {
        await ZoyarexSupabase.client.from('material_requests').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('material_requests').update(payload).eq('id', widget.request!.requestId);
      }

      ref.refresh(materialRequestProvider);

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
      appBar: AppBar(title: Text(widget.request == null ? 'Create Material Request' : 'Edit Request')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _targetWarehouse,
              decoration: const InputDecoration(labelText: 'Warehouse ID', border: OutlineInputBorder()),
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
              items: ['pending', 'approved', 'rejected', 'fulfilled'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
