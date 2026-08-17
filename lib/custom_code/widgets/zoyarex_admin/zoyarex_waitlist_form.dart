import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/waitlist_provider.dart';

class ZoyarexWaitlistForm extends ConsumerStatefulWidget {
  final WaitlistModel? entry;

  const ZoyarexWaitlistForm({Key? key, this.entry}) : super(key: key);

  @override
  ConsumerState<ZoyarexWaitlistForm> createState() => _ZoyarexWaitlistFormState();
}

class _ZoyarexWaitlistFormState extends ConsumerState<ZoyarexWaitlistForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _paxCtrl;
  late TextEditingController _notesCtrl;
  String _status = 'waiting';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.entry?.customerName ?? '');
    _phoneCtrl = TextEditingController(text: widget.entry?.customerPhone ?? '');
    _paxCtrl = TextEditingController(text: widget.entry?.partySize?.toString() ?? '');
    _notesCtrl = TextEditingController(text: widget.entry?.notes ?? '');
    _status = widget.entry?.status ?? 'waiting';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'customer_name': _nameCtrl.text.trim(),
        'customer_phone': _phoneCtrl.text.trim(),
        'party_size': int.tryParse(_paxCtrl.text.trim()) ?? 1,
        'notes': _notesCtrl.text.trim(),
        'status': _status,
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.entry == null) {
        await ZoyarexSupabase.client.from('waitlist').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('waitlist').update(payload).eq('id', widget.entry!.id);
      }
      
      ref.refresh(waitlistProvider);

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
      appBar: AppBar(title: Text(widget.entry == null ? 'Add to Waitlist' : 'Edit Waitlist')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Customer Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Customer Phone', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paxCtrl,
              decoration: const InputDecoration(labelText: 'Party Size', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: ['waiting', 'seated', 'cancelled'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
