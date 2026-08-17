import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/dining_floor_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexDiningFloorFormPage extends ConsumerStatefulWidget {
  final DiningFloorModel? floor;

  const ZoyarexDiningFloorFormPage({Key? key, this.floor}) : super(key: key);

  @override
  ConsumerState<ZoyarexDiningFloorFormPage> createState() => _ZoyarexDiningFloorFormPageState();
}

class _ZoyarexDiningFloorFormPageState extends ConsumerState<ZoyarexDiningFloorFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _sortOrderController;
  bool _isActive = true;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.floor?.name ?? '');
    _descriptionController = TextEditingController(text: widget.floor?.description ?? '');
    _sortOrderController = TextEditingController(text: widget.floor?.sortOrder.toString() ?? '0');
    _isActive = widget.floor?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final payload = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'sort_order': int.tryParse(_sortOrderController.text) ?? 0,
        'is_active': _isActive,
      };

      if (widget.floor == null) {
        await ZoyarexSupabase.client.from('gt_dining_floors').insert(payload);
      } else {
        await ZoyarexSupabase.client
            .from('gt_dining_floors')
            .update(payload)
            .eq('id', widget.floor!.id); // Wait, angular has `gt_dining_floor_id` in code but the provider maps both `id` and `gt_dining_floor_id`. We'll rely on our mapped `id`.
      }
      
      ref.refresh(diningFloorsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.floor == null ? 'Dining Floor created successfully' : 'Dining Floor updated successfully'),
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
    final isEditing = widget.floor != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Dining Floor' : 'Create Dining Floor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Floor Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sortOrderController,
                decoration: const InputDecoration(labelText: 'Sort Order', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEditing ? 'Update Floor' : 'Create Floor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
