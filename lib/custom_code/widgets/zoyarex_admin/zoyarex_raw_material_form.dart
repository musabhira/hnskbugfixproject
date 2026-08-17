import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/raw_material_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/product_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexRawMaterialFormPage extends ConsumerStatefulWidget {
  final ProductRawMaterialModel? recipe;

  const ZoyarexRawMaterialFormPage({Key? key, this.recipe}) : super(key: key);

  @override
  ConsumerState<ZoyarexRawMaterialFormPage> createState() => _ZoyarexRawMaterialFormPageState();
}

class _ZoyarexRawMaterialFormPageState extends ConsumerState<ZoyarexRawMaterialFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedProductId;
  List<Map<String, dynamic>> _ingredients = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.recipe?.productId;
    if (widget.recipe != null) {
      for (var item in widget.recipe!.rawMaterials) {
        if (item is Map) {
          _ingredients.add({
            'raw_material_id': item['raw_material_id']?.toString() ?? '',
            'quantity': item['quantity']?.toString() ?? '1',
            'uom_id': item['uom_id']?.toString() ?? '',
          });
        }
      }
    }
    if (_ingredients.isEmpty) {
      _addIngredientRow();
    }
  }

  void _addIngredientRow() {
    setState(() {
      _ingredients.add({'raw_material_id': '', 'quantity': '1', 'uom_id': ''});
    });
  }

  void _removeIngredientRow(int index) {
    setState(() {
      _ingredients.removeAt(index);
      if (_ingredients.isEmpty) _addIngredientRow();
    });
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
        'raw_materials': _ingredients.map((i) => {
          'raw_material_id': i['raw_material_id'],
          'quantity': double.tryParse(i['quantity'].toString()) ?? 1.0,
          'uom_id': i['uom_id'],
        }).toList(),
      };

      if (widget.recipe == null) {
        await ZoyarexSupabase.client.from('pos_product_raw_materials').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('pos_product_raw_materials').update(payload).eq('id', widget.recipe!.id);
      }
      
      ref.refresh(rawMaterialsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe saved successfully')));
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
        title: Text(widget.recipe == null ? 'Create Recipe' : 'Edit Recipe'),
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
                  // Ensure selectedProductId exists in the list to avoid dropdown crash
                  if (_selectedProductId != null && !products.any((p) => p.id == _selectedProductId)) {
                    _selectedProductId = null;
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedProductId,
                    decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder()),
                    items: products.map((prod) {
                      return DropdownMenuItem(value: prod.id, child: Text(prod.productName));
                    }).toList(),
                    onChanged: widget.recipe == null ? (val) {
                      setState(() => _selectedProductId = val);
                    } : null, // Disable changing product if editing
                    validator: (val) => val == null ? 'Required' : null,
                  );
                }
              ),
              const SizedBox(height: 24),
              const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: _ingredients[index]['raw_material_id'],
                              decoration: const InputDecoration(labelText: 'Raw Material ID / Name', isDense: true),
                              onChanged: (val) => _ingredients[index]['raw_material_id'] = val,
                              validator: (val) => val == null || val.isEmpty ? 'Req' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: _ingredients[index]['quantity'],
                              decoration: const InputDecoration(labelText: 'Qty', isDense: true),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (val) => _ingredients[index]['quantity'] = val,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: _ingredients[index]['uom_id'],
                              decoration: const InputDecoration(labelText: 'UOM', isDense: true),
                              onChanged: (val) => _ingredients[index]['uom_id'] = val,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeIngredientRow(index),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              TextButton.icon(
                onPressed: _addIngredientRow, 
                icon: const Icon(Icons.add), 
                label: const Text('Add Ingredient')
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Recipe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
