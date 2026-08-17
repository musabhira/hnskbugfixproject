import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/price_list_provider.dart';

class ZoyarexPriceListForm extends ConsumerStatefulWidget {
  final PriceListModel? priceList;

  const ZoyarexPriceListForm({Key? key, this.priceList}) : super(key: key);

  @override
  ConsumerState<ZoyarexPriceListForm> createState() => _ZoyarexPriceListFormState();
}

class _ZoyarexPriceListFormState extends ConsumerState<ZoyarexPriceListForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _typeCtrl;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.priceList?.name ?? '');
    _typeCtrl = TextEditingController();
    _isActive = widget.priceList?.isActive ?? true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final payload = {
        'name': _nameCtrl.text.trim(),
        'type': _typeCtrl.text.trim(),
        'is_active': _isActive,
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.priceList == null) {
        await ZoyarexSupabase.client.from('price_lists').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('price_lists').update(payload).eq('id', widget.priceList!.id);
      }
      
      ref.refresh(priceListProvider);

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
      appBar: AppBar(title: Text(widget.priceList == null ? 'Create Price List' : 'Edit Price List')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Price List Name', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _typeCtrl,
              decoration: const InputDecoration(labelText: 'Type (e.g. standard, premium)', border: OutlineInputBorder()),
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
