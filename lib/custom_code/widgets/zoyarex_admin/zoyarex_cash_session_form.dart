import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/cash_session_provider.dart';

class ZoyarexCashSessionForm extends ConsumerStatefulWidget {
  final CashSessionModel? session;

  const ZoyarexCashSessionForm({Key? key, this.session}) : super(key: key);

  @override
  ConsumerState<ZoyarexCashSessionForm> createState() => _ZoyarexCashSessionFormState();
}

class _ZoyarexCashSessionFormState extends ConsumerState<ZoyarexCashSessionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userCtrl;
  late TextEditingController _openingCtrl;
  late TextEditingController _closingCtrl;
  late TextEditingController _notesCtrl;
  String _status = 'open';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userCtrl = TextEditingController(text: widget.session?.userId ?? '');
    _openingCtrl = TextEditingController(text: widget.session?.openingBalance?.toString() ?? '');
    _closingCtrl = TextEditingController(text: widget.session?.closingBalance?.toString() ?? '');
    _notesCtrl = TextEditingController(text: widget.session?.notes ?? '');
    _status = widget.session?.status ?? 'open';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'user_id': _userCtrl.text.trim(),
        'opening_balance': double.tryParse(_openingCtrl.text.trim()) ?? 0.0,
        'closing_balance': double.tryParse(_closingCtrl.text.trim()),
        'notes': _notesCtrl.text.trim(),
        'status': _status,
        'session_date': DateTime.now().toIso8601String(),
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.session == null) {
        await ZoyarexSupabase.client.from('cash_sessions').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('cash_sessions').update(payload).eq('id', widget.session!.id);
      }
      
      ref.refresh(cashSessionProvider);

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
      appBar: AppBar(title: Text(widget.session == null ? 'Create Cash Session' : 'Edit Cash Session')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _userCtrl,
              decoration: const InputDecoration(labelText: 'User ID', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _openingCtrl,
              decoration: const InputDecoration(labelText: 'Opening Balance', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _closingCtrl,
              decoration: const InputDecoration(labelText: 'Closing Balance', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: ['open', 'closed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _status = v!),
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
