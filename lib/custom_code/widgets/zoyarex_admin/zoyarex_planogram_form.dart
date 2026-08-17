import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/planogram_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/product_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexPlanogramFormPage extends ConsumerStatefulWidget {
  final PlanogramAssignmentModel? assignment;

  const ZoyarexPlanogramFormPage({Key? key, this.assignment}) : super(key: key);

  @override
  ConsumerState<ZoyarexPlanogramFormPage> createState() => _ZoyarexPlanogramFormPageState();
}

class _ZoyarexPlanogramFormPageState extends ConsumerState<ZoyarexPlanogramFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedProductId;
  late TextEditingController _floorController;
  late TextEditingController _rackController;
  late TextEditingController _shelfController;
  late TextEditingController _locationController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.assignment?.productId;
    _floorController = TextEditingController(text: widget.assignment?.floorId ?? '');
    _rackController = TextEditingController(text: widget.assignment?.rackId ?? '');
    _shelfController = TextEditingController(text: widget.assignment?.shelfId ?? '');
    _locationController = TextEditingController(text: widget.assignment?.locationId ?? '');
  }

  @override
  void dispose() {
    _floorController.dispose();
    _rackController.dispose();
    _shelfController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a product')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final payload = {
        'product_id': _selectedProductId,
        'floor_id': _floorController.text.trim(),
        'rack_id': _rackController.text.trim(),
        'shelf_id': _shelfController.text.trim(),
        'location_id': _locationController.text.trim(),
      };

      if (widget.assignment == null) {
        await ZoyarexSupabase.client.from('pos_planogram_assignments').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('pos_planogram_assignments').update(payload).eq('id', widget.assignment!.id);
      }
      
      ref.refresh(planogramProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Planogram assigned successfully')));
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
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignment == null ? 'Assign Planogram' : 'Edit Planogram Assignment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              productsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading products: $err'),
                data: (products) {
                  // Ensure selectedProductId exists in the list
                  if (_selectedProductId != null && !products.any((p) => p.id == _selectedProductId)) {
                    _selectedProductId = null;
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedProductId,
                    decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder()),
                    items: products.map((prod) {
                      return DropdownMenuItem(value: prod.id, child: Text(prod.productName));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedProductId = val);
                    },
                    validator: (val) => val == null ? 'Required' : null,
                  );
                }
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _floorController,
                decoration: const InputDecoration(labelText: 'Floor ID / Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rackController,
                decoration: const InputDecoration(labelText: 'Rack ID / Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shelfController,
                decoration: const InputDecoration(labelText: 'Shelf ID / Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Exact Location ID', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Planogram Assignment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
