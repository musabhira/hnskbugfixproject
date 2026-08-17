import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/floor_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/outlet_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexFloorFormPage extends ConsumerStatefulWidget {
  final FloorModel? floor;

  const ZoyarexFloorFormPage({Key? key, this.floor}) : super(key: key);

  @override
  ConsumerState<ZoyarexFloorFormPage> createState() => _ZoyarexFloorFormPageState();
}

class _ZoyarexFloorFormPageState extends ConsumerState<ZoyarexFloorFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  String? _selectedBranchId;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.floor?.floorName ?? '');
    _selectedBranchId = widget.floor?.branchId;
    if (_selectedBranchId == '') _selectedBranchId = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a branch')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final payload = {
        'floor_name': _nameController.text.trim(),
        'branch_id': _selectedBranchId,
        'tenant_id': ZoyarexSupabase.currentTenantId // fallback matching Angular
      };

      if (widget.floor == null) {
        await ZoyarexSupabase.client.from('pos_floors').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('pos_floors').update(payload).eq('id', widget.floor!.id);
      }
      
      ref.refresh(floorsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Floor saved successfully')));
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
    final outletsAsync = ref.watch(outletsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.floor == null ? 'Create Floor' : 'Edit Floor'),
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
                decoration: const InputDecoration(labelText: 'Floor Name/Number', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              outletsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading branches: $err'),
                data: (branches) {
                  if (_selectedBranchId != null && !branches.any((b) => b.id == _selectedBranchId)) {
                    _selectedBranchId = null;
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedBranchId,
                    decoration: const InputDecoration(labelText: 'Branch/Outlet', border: OutlineInputBorder()),
                    items: branches.map((branch) {
                      return DropdownMenuItem(value: branch.id, child: Text(branch.branchName));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedBranchId = val);
                    },
                    validator: (val) => val == null ? 'Required' : null,
                  );
                }
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Floor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
