import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/payment_mode_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexPaymentModeFormPage extends ConsumerStatefulWidget {
  final PaymentModeModel? mode;

  const ZoyarexPaymentModeFormPage({Key? key, this.mode}) : super(key: key);

  @override
  ConsumerState<ZoyarexPaymentModeFormPage> createState() => _ZoyarexPaymentModeFormPageState();
}

class _ZoyarexPaymentModeFormPageState extends ConsumerState<ZoyarexPaymentModeFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _typeController;
  late TextEditingController _descriptionController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mode?.name ?? '');
    _codeController = TextEditingController(text: widget.mode?.code ?? '');
    _typeController = TextEditingController(text: widget.mode?.type ?? '');
    _descriptionController = TextEditingController(text: widget.mode?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final payload = {
        'name': _nameController.text.trim(),
        'code': _codeController.text.trim(),
        'type': _typeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': widget.mode?.status ?? 'Active',
      };

      if (widget.mode == null) {
        await ZoyarexSupabase.client.from('payment_modes').insert(payload);
      } else {
        await ZoyarexSupabase.client
            .from('payment_modes')
            .update(payload)
            .eq('id', widget.mode!.id);
      }
      
      ref.refresh(paymentModesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.mode == null ? 'Payment Mode created successfully' : 'Payment Mode updated successfully'),
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
    final isEditing = widget.mode != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Payment Mode' : 'Create Payment Mode'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Payment Mode Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Code', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type (e.g., Cash, Card, Online)', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEditing ? 'Update Mode' : 'Create Mode'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
