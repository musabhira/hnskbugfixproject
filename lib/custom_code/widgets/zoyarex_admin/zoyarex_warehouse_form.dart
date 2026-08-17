import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/warehouse_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/user_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexWarehouseFormPage extends ConsumerStatefulWidget {
  final WarehouseModel? warehouse;

  const ZoyarexWarehouseFormPage({Key? key, this.warehouse}) : super(key: key);

  @override
  ConsumerState<ZoyarexWarehouseFormPage> createState() => _ZoyarexWarehouseFormPageState();
}

class _ZoyarexWarehouseFormPageState extends ConsumerState<ZoyarexWarehouseFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _locationController;
  late TextEditingController _descController;
  
  String? _selectedAdminId;
  String _status = 'Enabled';
  bool _isPrivate = false;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.warehouse?.name ?? '');
    _codeController = TextEditingController(text: widget.warehouse?.code ?? '');
    _locationController = TextEditingController(text: widget.warehouse?.location ?? '');
    _descController = TextEditingController(text: widget.warehouse?.description ?? '');
    _selectedAdminId = widget.warehouse?.adminId;
    if (_selectedAdminId == '') _selectedAdminId = null;
    _status = widget.warehouse?.status ?? 'Enabled';
    _isPrivate = widget.warehouse?.isPrivate ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _locationController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAdminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an Admin')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final payload = {
        'warehouse_name': _nameController.text.trim(),
        'warehouse_code': _codeController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descController.text.trim(),
        'admin_id': _selectedAdminId,
        'status': _status,
        'is_private': _isPrivate,
      };

      if (widget.warehouse == null) {
        await ZoyarexSupabase.client.from('pos_warehouses').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('pos_warehouses').update(payload).eq('id', widget.warehouse!.id);
      }
      
      ref.refresh(warehousesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Warehouse saved successfully')));
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
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.warehouse == null ? 'Create Warehouse' : 'Edit Warehouse'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Warehouse Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Warehouse Code', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              usersAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading admins: $err'),
                data: (users) {
                  if (_selectedAdminId != null && !users.any((u) => u.id == _selectedAdminId)) {
                    _selectedAdminId = null;
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedAdminId,
                    decoration: const InputDecoration(labelText: 'Admin', border: OutlineInputBorder()),
                    items: users.map((u) {
                      return DropdownMenuItem(value: u.id, child: Text('${u.firstName} ${u.lastName}'));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedAdminId = val);
                    },
                    validator: (val) => val == null ? 'Required' : null,
                  );
                }
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: ['Enabled', 'Disabled'].map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Private Warehouse'),
                value: _isPrivate,
                onChanged: (val) => setState(() => _isPrivate = val),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Warehouse'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
