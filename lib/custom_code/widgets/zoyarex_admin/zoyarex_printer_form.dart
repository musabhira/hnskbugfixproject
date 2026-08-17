import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/printer_provider.dart';

class ZoyarexPrinterForm extends ConsumerStatefulWidget {
  final PrinterModel? printer;

  const ZoyarexPrinterForm({Key? key, this.printer}) : super(key: key);

  @override
  ConsumerState<ZoyarexPrinterForm> createState() => _ZoyarexPrinterFormState();
}

class _ZoyarexPrinterFormState extends ConsumerState<ZoyarexPrinterForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _ipCtrl;
  String _type = 'receipt';
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.printer?.name ?? '');
    _ipCtrl = TextEditingController(text: widget.printer?.ipAddress ?? '');
    _type = widget.printer?.type ?? 'receipt';
    _isActive = widget.printer?.isActive ?? true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'name': _nameCtrl.text.trim(),
        'ip_address': _ipCtrl.text.trim(),
        'type': _type,
        'is_active': _isActive,
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.printer == null) {
        await ZoyarexSupabase.client.from('printers').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('printers').update(payload).eq('id', widget.printer!.id);
      }
      
      ref.refresh(printerProvider);

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
      appBar: AppBar(title: Text(widget.printer == null ? 'Create Printer' : 'Edit Printer')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Printer Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ipCtrl,
              decoration: const InputDecoration(labelText: 'IP Address / Mac', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              items: ['receipt', 'kitchen', 'label'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
