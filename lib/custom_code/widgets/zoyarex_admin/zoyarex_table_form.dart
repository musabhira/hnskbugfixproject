import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/table_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/outlet_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/floor_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexTableFormPage extends ConsumerStatefulWidget {
  final TableModel? table;

  const ZoyarexTableFormPage({Key? key, this.table}) : super(key: key);

  @override
  ConsumerState<ZoyarexTableFormPage> createState() => _ZoyarexTableFormPageState();
}

class _ZoyarexTableFormPageState extends ConsumerState<ZoyarexTableFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _numberController;
  late TextEditingController _capacityController;
  
  String? _selectedBranchId;
  String? _selectedFloorId;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.table?.tableNumber ?? '');
    _capacityController = TextEditingController(text: widget.table?.capacity ?? '');
    _selectedBranchId = widget.table?.branchId;
    if (_selectedBranchId == '') _selectedBranchId = null;
    _selectedFloorId = widget.table?.floorId;
    if (_selectedFloorId == '') _selectedFloorId = null;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranchId == null || _selectedFloorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select branch and floor')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final payload = {
        'table_number': _numberController.text.trim(),
        'capacity': _capacityController.text.trim(),
        'branch_id': _selectedBranchId,
        'floor_id': _selectedFloorId,
        'tenant_id': ZoyarexSupabase.currentTenantId
      };

      if (widget.table == null) {
        await ZoyarexSupabase.client.from('pos_tables').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('pos_tables').update(payload).eq('id', widget.table!.id);
      }
      
      ref.refresh(tablesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Table saved successfully')));
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
    final floorsAsync = ref.watch(floorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.table == null ? 'Create Table' : 'Edit Table'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Table Number/Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacity (e.g. 1-2, 3-4)', border: OutlineInputBorder()),
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
                      setState(() {
                         _selectedBranchId = val;
                         _selectedFloorId = null; // reset floor on branch change
                      });
                    },
                    validator: (val) => val == null ? 'Required' : null,
                  );
                }
              ),
              const SizedBox(height: 16),
              floorsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading floors: $err'),
                data: (floors) {
                  // Filter floors by selected branch
                  final branchFloors = floors.where((f) => f.branchId == _selectedBranchId).toList();
                  if (_selectedFloorId != null && !branchFloors.any((f) => f.id == _selectedFloorId)) {
                    _selectedFloorId = null;
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedFloorId,
                    decoration: const InputDecoration(labelText: 'Floor', border: OutlineInputBorder()),
                    items: branchFloors.map((floor) {
                      return DropdownMenuItem(value: floor.id, child: Text(floor.floorName));
                    }).toList(),
                    onChanged: _selectedBranchId == null ? null : (val) {
                      setState(() => _selectedFloorId = val);
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
                      : const Text('Save Table'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
