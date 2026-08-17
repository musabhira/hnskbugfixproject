import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexCreditNoteForm extends ConsumerStatefulWidget {
  final dynamic note;

  const ZoyarexCreditNoteForm({Key? key, this.note}) : super(key: key);

  @override
  ConsumerState<ZoyarexCreditNoteForm> createState() => _ZoyarexCreditNoteFormState();
}

class _ZoyarexCreditNoteFormState extends ConsumerState<ZoyarexCreditNoteForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _partyCtrl;
  String _status = 'pending';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.note?['notes'] ?? '');
    _amountCtrl = TextEditingController(text: widget.note?['total_amount']?.toString() ?? '');
    _partyCtrl = TextEditingController(text: widget.note?['party_name'] ?? '');
    _status = widget.note?['status'] ?? 'pending';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'notes': _notesCtrl.text.trim(),
        'total_amount': double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
        'party_name': _partyCtrl.text.trim(),
        'status': _status,
        'note_date': DateTime.now().toIso8601String(),
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.note == null) {
        await ZoyarexSupabase.client.from('credit_notes').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('credit_notes').update(payload).eq('id', widget.note['id']);
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
      appBar: AppBar(title: Text(widget.note == null ? 'Create Credit Note' : 'Edit Note')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _partyCtrl,
              decoration: const InputDecoration(labelText: 'Party / Customer Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Total Amount', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
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
              items: ['pending', 'approved', 'used'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
