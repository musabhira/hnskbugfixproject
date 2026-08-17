import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/addon_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexAddonFormPage extends ConsumerStatefulWidget {
  final AddonModel? addon;

  const ZoyarexAddonFormPage({Key? key, this.addon}) : super(key: key);

  @override
  ConsumerState<ZoyarexAddonFormPage> createState() => _ZoyarexAddonFormPageState();
}

class _ZoyarexAddonFormPageState extends ConsumerState<ZoyarexAddonFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  
  bool _isDynamicPrice = false;
  bool _isPriceWithProduct = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.addon?.addOnName ?? '');
    _priceController = TextEditingController(text: widget.addon?.addOnPrice.toString() ?? '');
    _descController = TextEditingController(text: widget.addon?.description ?? '');
    _isDynamicPrice = widget.addon?.isDynamicPrice ?? false;
    _isPriceWithProduct = widget.addon?.isPriceWithProduct ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final payload = {
        'add_on_name': _nameController.text.trim(),
        'add_on_price': double.tryParse(_priceController.text.trim()) ?? 0,
        'description': _descController.text.trim(),
        'is_dynamic_price': _isDynamicPrice,
        'is_total_up_with_products': _isPriceWithProduct,
      };

      if (widget.addon == null) {
        await ZoyarexSupabase.client.from('pos_addons').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('pos_addons').update(payload).eq('id', widget.addon!.id);
      }
      
      ref.refresh(addonsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add-on saved successfully')));
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.addon == null ? 'Create Add-on' : 'Edit Add-on'),
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
                decoration: const InputDecoration(labelText: 'Add-on Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Dynamic Price'),
                subtitle: const Text('Allow price override'),
                value: _isDynamicPrice,
                onChanged: (val) => setState(() => _isDynamicPrice = val),
              ),
              SwitchListTile(
                title: const Text('Total Up With Products'),
                subtitle: const Text('Include in base product price calculation'),
                value: _isPriceWithProduct,
                onChanged: (val) => setState(() => _isPriceWithProduct = val),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Add-on'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
