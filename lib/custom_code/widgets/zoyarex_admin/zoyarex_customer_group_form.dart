import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/customer_group_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexCustomerGroupFormPage extends ConsumerStatefulWidget {
  final CustomerGroupModel? group;

  const ZoyarexCustomerGroupFormPage({Key? key, this.group}) : super(key: key);

  @override
  ConsumerState<ZoyarexCustomerGroupFormPage> createState() => _ZoyarexCustomerGroupFormPageState();
}

class _ZoyarexCustomerGroupFormPageState extends ConsumerState<ZoyarexCustomerGroupFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name ?? '');
    _descriptionController = TextEditingController(text: widget.group?.description ?? '');
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
        'customer_group_name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': widget.group?.status ?? 'Active',
      };

      if (widget.group == null) {
        await ZoyarexSupabase.client.from('customer_groups').insert(payload);
      } else {
        await ZoyarexSupabase.client
            .from('customer_groups')
            .update(payload)
            .eq('id', widget.group!.id);
      }
      
      ref.refresh(customerGroupsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.group == null ? 'Customer Group created successfully' : 'Customer Group updated successfully'),
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
    final isEditing = widget.group != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer Group' : 'Create Customer Group'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Customer Group Name', border: OutlineInputBorder()),
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
                      : Text(isEditing ? 'Update Group' : 'Create Group'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
