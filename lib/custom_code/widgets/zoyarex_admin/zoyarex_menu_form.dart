import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/menu_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/category_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexMenuFormPage extends ConsumerStatefulWidget {
  final MenuModel? menu;

  const ZoyarexMenuFormPage({Key? key, this.menu}) : super(key: key);

  @override
  ConsumerState<ZoyarexMenuFormPage> createState() => _ZoyarexMenuFormPageState();
}

class _ZoyarexMenuFormPageState extends ConsumerState<ZoyarexMenuFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descController;
  
  String? _selectedCategoryId;
  String _status = 'Enabled';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu?.menuName ?? '');
    _codeController = TextEditingController(text: widget.menu?.menuCode ?? '');
    _descController = TextEditingController(text: widget.menu?.description ?? '');
    _selectedCategoryId = widget.menu?.categoryId;
    if (_selectedCategoryId == '') _selectedCategoryId = null;
    _status = widget.menu?.status ?? 'Enabled';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final payload = {
        'sub_category_name': _nameController.text.trim(),
        'sub_category_code': _codeController.text.trim(),
        'description': _descController.text.trim(),
        'category_id': _selectedCategoryId,
        'status': _status,
      };

      if (widget.menu == null) {
        await ZoyarexSupabase.client.from('pos_sub_categories').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('pos_sub_categories').update(payload).eq('id', widget.menu!.id);
      }
      
      ref.refresh(menusProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu saved successfully')));
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
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menu == null ? 'Create Menu' : 'Edit Menu'),
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
                decoration: const InputDecoration(labelText: 'Menu Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Menu Code', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading categories: $err'),
                data: (categories) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat.id, child: Text(cat.categoryName));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategoryId = val);
                    },
                    validator: (val) => val == null ? 'Required' : null,
                  );
                }
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: ['Enabled', 'Disabled'].map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _status = val);
                  }
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Menu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
