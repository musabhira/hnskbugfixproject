import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/kitchen_display_provider.dart';

class ZoyarexKitchenDisplayForm extends ConsumerStatefulWidget {
  final KitchenDisplayModel? kds;

  const ZoyarexKitchenDisplayForm({Key? key, this.kds}) : super(key: key);

  @override
  ConsumerState<ZoyarexKitchenDisplayForm> createState() => _ZoyarexKitchenDisplayFormState();
}

class _ZoyarexKitchenDisplayFormState extends ConsumerState<ZoyarexKitchenDisplayForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _outletCtrl;
  String _type = 'kitchen';
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.kds?.name ?? '');
    _outletCtrl = TextEditingController(text: widget.kds?.outletId ?? '');
    _type = widget.kds?.displayType ?? 'kitchen';
    _isActive = widget.kds?.isActive ?? true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'name': _nameCtrl.text.trim(),
        'outlet_id': _outletCtrl.text.trim(),
        'display_type': _type,
        'is_active': _isActive,
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.kds == null) {
        await ZoyarexSupabase.client.from('kitchen_displays').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('kitchen_displays').update(payload).eq('id', widget.kds!.id);
      }
      
      ref.refresh(kitchenDisplayProvider);

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
      appBar: AppBar(title: Text(widget.kds == null ? 'Create Kitchen Display' : 'Edit Display')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Display Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _outletCtrl,
              decoration: const InputDecoration(labelText: 'Outlet ID', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Display Type', border: OutlineInputBorder()),
              items: ['kitchen', 'expediter', 'bar'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
