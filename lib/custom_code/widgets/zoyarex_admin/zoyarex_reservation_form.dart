import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/reservation_provider.dart';

class ZoyarexReservationForm extends ConsumerStatefulWidget {
  final ReservationModel? reservation;

  const ZoyarexReservationForm({Key? key, this.reservation}) : super(key: key);

  @override
  ConsumerState<ZoyarexReservationForm> createState() => _ZoyarexReservationFormState();
}

class _ZoyarexReservationFormState extends ConsumerState<ZoyarexReservationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _paxCtrl;
  late TextEditingController _notesCtrl;
  String _status = 'pending';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.reservation?.customerName ?? '');
    _phoneCtrl = TextEditingController(text: widget.reservation?.customerPhone ?? '');
    _paxCtrl = TextEditingController(text: widget.reservation?.numberOfGuests?.toString() ?? '');
    _notesCtrl = TextEditingController(text: widget.reservation?.notes ?? '');
    _status = widget.reservation?.status ?? 'pending';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'customer_name': _nameCtrl.text.trim(),
        'customer_phone': _phoneCtrl.text.trim(),
        'number_of_guests': int.tryParse(_paxCtrl.text.trim()) ?? 1,
        'notes': _notesCtrl.text.trim(),
        'status': _status,
        'reservation_time': DateTime.now().toIso8601String(),
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.reservation == null) {
        await ZoyarexSupabase.client.from('reservations').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('reservations').update(payload).eq('id', widget.reservation!.id);
      }
      
      ref.refresh(reservationProvider);

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
      appBar: AppBar(title: Text(widget.reservation == null ? 'Create Reservation' : 'Edit Reservation')),
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
              decoration: const InputDecoration(labelText: 'Number of Guests', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: ['pending', 'confirmed', 'cancelled', 'completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
