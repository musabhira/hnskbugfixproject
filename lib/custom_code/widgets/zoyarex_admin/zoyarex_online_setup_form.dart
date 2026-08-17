import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/online_setup_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexOnlineSetupFormPage extends ConsumerStatefulWidget {
  final OnlineSetupModel setup;

  const ZoyarexOnlineSetupFormPage({Key? key, required this.setup}) : super(key: key);

  @override
  ConsumerState<ZoyarexOnlineSetupFormPage> createState() => _ZoyarexOnlineSetupFormPageState();
}

class _ZoyarexOnlineSetupFormPageState extends ConsumerState<ZoyarexOnlineSetupFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _radiusController;
  late TextEditingController _minOrderController;
  late TextEditingController _deliveryFeeController;
  bool _isOnlineEnabled = false;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isOnlineEnabled = widget.setup.isOnlineEnabled;
    _radiusController = TextEditingController(text: widget.setup.deliveryRadius.toString());
    _minOrderController = TextEditingController(text: widget.setup.minOrderValue.toString());
    _deliveryFeeController = TextEditingController(text: widget.setup.deliveryFee.toString());
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _minOrderController.dispose();
    _deliveryFeeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final payload = {
        'is_online_enabled': _isOnlineEnabled,
        'delivery_radius': double.tryParse(_radiusController.text) ?? 0.0,
        'min_order_value': double.tryParse(_minOrderController.text) ?? 0.0,
        'delivery_fee': double.tryParse(_deliveryFeeController.text) ?? 0.0,
      };

      await ZoyarexSupabase.client
          .from('branches')
          .update(payload)
          .eq('gt_branch_id', widget.setup.branchId);
      
      ref.refresh(onlineSetupProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Online Settings saved successfully')));
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
        title: Text('Online Setup: ${widget.setup.branchName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Enable Online Ordering for this Branch'),
                value: _isOnlineEnabled,
                onChanged: (val) => setState(() => _isOnlineEnabled = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _radiusController,
                decoration: const InputDecoration(labelText: 'Delivery Radius (km)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minOrderController,
                decoration: const InputDecoration(labelText: 'Minimum Order Value (₹)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deliveryFeeController,
                decoration: const InputDecoration(labelText: 'Delivery Fee (₹)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
