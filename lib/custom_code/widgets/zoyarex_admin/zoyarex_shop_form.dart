import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/shop_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexShopFormPage extends ConsumerStatefulWidget {
  final ShopModel? shop;

  const ZoyarexShopFormPage({Key? key, this.shop}) : super(key: key);

  @override
  ConsumerState<ZoyarexShopFormPage> createState() => _ZoyarexShopFormPageState();
}

class _ZoyarexShopFormPageState extends ConsumerState<ZoyarexShopFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _countryCodeController;
  
  bool _isOpen = false;
  bool _isFeatured = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop?.name ?? '');
    _emailController = TextEditingController(text: widget.shop?.email ?? '');
    _mobileController = TextEditingController(text: widget.shop?.mobile ?? '');
    _countryCodeController = TextEditingController(text: widget.shop?.countryCode ?? '');
    _isOpen = widget.shop?.open ?? false;
    _isFeatured = widget.shop?.featured ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _countryCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final payload = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'country_code': _countryCodeController.text.trim(),
        'open': _isOpen,
        'featured': _isFeatured,
        'tenant_id': ZoyarexSupabase.currentTenantId,
        'is_active': true
      };

      if (widget.shop == null) {
        await ZoyarexSupabase.client.from('shops').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('shops').update(payload).eq('id', widget.shop!.id);
      }
      
      ref.refresh(shopsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group saved successfully')));
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
        title: Text(widget.shop == null ? 'Create Group / Shop' : 'Edit Group / Shop'),
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
                decoration: const InputDecoration(labelText: 'Group Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _countryCodeController,
                      decoration: const InputDecoration(labelText: 'Country Code', border: OutlineInputBorder(), prefixText: '+'),
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.isEmpty ? 'Req' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _mobileController,
                      decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Open'),
                value: _isOpen,
                onChanged: (val) => setState(() => _isOpen = val),
              ),
              SwitchListTile(
                title: const Text('Is Featured'),
                value: _isFeatured,
                onChanged: (val) => setState(() => _isFeatured = val),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Group'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
