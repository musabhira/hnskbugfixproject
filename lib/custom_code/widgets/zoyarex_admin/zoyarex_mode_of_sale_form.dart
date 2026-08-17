import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/mode_of_sale_provider.dart';

class ZoyarexModeOfSaleForm extends ConsumerStatefulWidget {
  final ModeOfSaleModel? mos;

  const ZoyarexModeOfSaleForm({Key? key, this.mos}) : super(key: key);

  @override
  ConsumerState<ZoyarexModeOfSaleForm> createState() => _ZoyarexModeOfSaleFormState();
}

class _ZoyarexModeOfSaleFormState extends ConsumerState<ZoyarexModeOfSaleForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  String _type = 'dine_in';
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.mos?.name ?? '');
    _type = widget.mos?.type ?? 'dine_in';
    _isActive = widget.mos?.isActive ?? true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'name': _nameCtrl.text.trim(),
        'type': _type,
        'is_active': _isActive,
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.mos == null) {
        await ZoyarexSupabase.client.from('modes_of_sale').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('modes_of_sale').update(payload).eq('id', widget.mos!.id);
      }
      
      ref.refresh(modeOfSaleProvider);

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
      appBar: AppBar(title: Text(widget.mos == null ? 'Create Mode of Sale' : 'Edit Mode of Sale')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              items: ['dine_in', 'takeaway', 'delivery', 'custom'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Is Active'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
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
