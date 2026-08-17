import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/role_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexRoleFormPage extends ConsumerStatefulWidget {
  final RoleModel? role;

  const ZoyarexRoleFormPage({Key? key, this.role}) : super(key: key);

  @override
  ConsumerState<ZoyarexRoleFormPage> createState() => _ZoyarexRoleFormPageState();
}

class _ZoyarexRoleFormPageState extends ConsumerState<ZoyarexRoleFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final payload = {
        'name': _nameController.text.trim(),
      };

      if (widget.role == null) {
        await ZoyarexSupabase.client.from('roles').insert(payload);
      } else {
        await ZoyarexSupabase.client
            .from('roles')
            .update(payload)
            .eq('id', widget.role!.id);
      }
      
      ref.refresh(rolesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.role == null ? 'Role created successfully' : 'Role updated successfully'),
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
    final isEditing = widget.role != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Role' : 'Create Role'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Role Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEditing ? 'Update Role' : 'Create Role'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
