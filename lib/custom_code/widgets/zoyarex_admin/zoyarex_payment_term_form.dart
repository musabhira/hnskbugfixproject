import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/payment_term_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexPaymentTermFormPage extends ConsumerStatefulWidget {
  final PaymentTermModel? term;

  const ZoyarexPaymentTermFormPage({Key? key, this.term}) : super(key: key);

  @override
  ConsumerState<ZoyarexPaymentTermFormPage> createState() => _ZoyarexPaymentTermFormPageState();
}

class _ZoyarexPaymentTermFormPageState extends ConsumerState<ZoyarexPaymentTermFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _daysController;
  late TextEditingController _discountDaysController;
  late TextEditingController _discountPercentController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.term?.name ?? '');
    _daysController = TextEditingController(text: widget.term?.days.toString() ?? '0');
    _discountDaysController = TextEditingController(text: widget.term?.discountDays.toString() ?? '0');
    _discountPercentController = TextEditingController(text: widget.term?.discountPercent.toString() ?? '0.0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _daysController.dispose();
    _discountDaysController.dispose();
    _discountPercentController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final payload = {
        'name': _nameController.text.trim(),
        'days': int.tryParse(_daysController.text) ?? 0,
        'discount_days': int.tryParse(_discountDaysController.text) ?? 0,
        'discount_percent': double.tryParse(_discountPercentController.text) ?? 0.0,
      };

      if (widget.term == null) {
        await ZoyarexSupabase.client.from('gt_payment_terms').insert(payload);
      } else {
        await ZoyarexSupabase.client
            .from('gt_payment_terms')
            .update(payload)
            .eq('id', widget.term!.id); // or gt_payment_term_id depending on exact schema
      }
      
      ref.refresh(paymentTermsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.term == null ? 'Payment Term created successfully' : 'Payment Term updated successfully'),
        ));
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
    final isEditing = widget.term != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Payment Term' : 'Create Payment Term'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Payment Term Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _daysController,
                decoration: const InputDecoration(labelText: 'Days', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountDaysController,
                decoration: const InputDecoration(labelText: 'Discount Days', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountPercentController,
                decoration: const InputDecoration(labelText: 'Discount Percent (%)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEditing ? 'Update Term' : 'Create Term'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
