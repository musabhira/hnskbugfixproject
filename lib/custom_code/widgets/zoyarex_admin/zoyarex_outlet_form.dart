import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/outlet_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexOutletFormPage extends ConsumerStatefulWidget {
  final OutletModel? outlet; // null if creating, otherwise editing

  const ZoyarexOutletFormPage({Key? key, this.outlet}) : super(key: key);

  @override
  ConsumerState<ZoyarexOutletFormPage> createState() => _ZoyarexOutletFormPageState();
}

class _ZoyarexOutletFormPageState extends ConsumerState<ZoyarexOutletFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _taxRegController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  
  bool _isOpen247 = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.outlet?.branchName ?? '');
    _addressController = TextEditingController(text: widget.outlet?.address ?? '');
    _phoneController = TextEditingController(text: widget.outlet?.phone ?? '');
    _taxRegController = TextEditingController();
    _latController = TextEditingController();
    _lngController = TextEditingController();
    _isOpen247 = widget.outlet?.isOpen ?? false; // Approximation since isOpen != isOpen247, but enough for stub
    
    if (widget.outlet != null) {
      _fetchAdditionalDetails();
    }
  }
  
  Future<void> _fetchAdditionalDetails() async {
    try {
      final data = await ZoyarexSupabase.client
          .from('branches')
          .select('*')
          .eq('id', widget.outlet!.id)
          .single();
          
      setState(() {
        _taxRegController.text = data['branch_tax_registration_number']?.toString() ?? '';
        _latController.text = data['latitude']?.toString() ?? '';
        _lngController.text = data['longitude']?.toString() ?? '';
        _isOpen247 = data['is_open_24_7'] == true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching details: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _taxRegController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final payload = {
        'branch_name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'branch_tax_registration_number': _taxRegController.text.trim(),
        'latitude': _latController.text.trim(),
        'longitude': _lngController.text.trim(),
        'is_open_24_7': _isOpen247,
      };

      if (widget.outlet == null) {
        // Creating
        payload['branch_code'] = 'B-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
        await ZoyarexSupabase.client.from('branches').insert(payload);
      } else {
        // Updating
        await ZoyarexSupabase.client.from('branches').update(payload).eq('id', widget.outlet!.id);
      }
      
      // Refresh the list provider
      ref.refresh(outletsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Outlet saved successfully')));
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
        title: Text(widget.outlet == null ? 'Create Outlet' : 'Edit Outlet'),
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
                decoration: const InputDecoration(labelText: 'Branch Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taxRegController,
                decoration: const InputDecoration(labelText: 'Tax Registration Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Open 24/7'),
                value: _isOpen247,
                onChanged: (val) => setState(() => _isOpen247 = val),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Outlet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
