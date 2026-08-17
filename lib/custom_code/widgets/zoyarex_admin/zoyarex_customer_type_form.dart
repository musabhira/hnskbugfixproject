import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/customer_type_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexCustomerTypeFormPage extends ConsumerStatefulWidget {
  final CustomerTypeModel? type;

  const ZoyarexCustomerTypeFormPage({Key? key, this.type}) : super(key: key);

  @override
  ConsumerState<ZoyarexCustomerTypeFormPage> createState() => _ZoyarexCustomerTypeFormPageState();
}

class _ZoyarexCustomerTypeFormPageState extends ConsumerState<ZoyarexCustomerTypeFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.type?.name ?? '');
    _descriptionController = TextEditingController(text: widget.type?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final payload = {
        'customer_type_name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': widget.type?.status ?? 'Active',
      };

      if (widget.type == null) {
        await ZoyarexSupabase.client.from('customer_types').insert(payload);
      } else {
        await ZoyarexSupabase.client
            .from('customer_types')
            .update(payload)
            .eq('id', widget.type!.id);
      }
      
      ref.refresh(customerTypesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.type == null ? 'Customer Type created successfully' : 'Customer Type updated successfully'),
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
    final isEditing = widget.type != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer Type' : 'Create Customer Type'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Customer Type Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEditing ? 'Update Type' : 'Create Type'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
