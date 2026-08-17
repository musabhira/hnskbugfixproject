import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/tax_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/outlet_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexTaxFormPage extends ConsumerStatefulWidget {
  final TaxModel? tax;

  const ZoyarexTaxFormPage({Key? key, this.tax}) : super(key: key);

  @override
  ConsumerState<ZoyarexTaxFormPage> createState() => _ZoyarexTaxFormPageState();
}

class _ZoyarexTaxFormPageState extends ConsumerState<ZoyarexTaxFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _taxNameController;
  late TextEditingController _taxRateController;
  late TextEditingController _descController;
  
  String _taxMode = 'Inclusive';
  String _calcType = 'CalculateOnTotal';
  String? _selectedBranchId;
  String _status = 'Enabled';
  bool _coreAmountFlag = false;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _taxNameController = TextEditingController(text: widget.tax?.taxName ?? '');
    _taxRateController = TextEditingController(text: widget.tax?.taxRate ?? '0');
    _descController = TextEditingController(text: widget.tax?.description ?? '');
    
    if (widget.tax != null) {
      _taxMode = widget.tax!.taxMode.isNotEmpty ? widget.tax!.taxMode : 'Inclusive';
      _calcType = widget.tax!.calculationType.isNotEmpty ? widget.tax!.calculationType : 'CalculateOnTotal';
      _selectedBranchId = widget.tax!.branchId;
      if (_selectedBranchId == '') _selectedBranchId = null;
      _status = widget.tax!.status;
      _coreAmountFlag = widget.tax!.coreAmountFlag;
    }
  }

  @override
  void dispose() {
    _taxNameController.dispose();
    _taxRateController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Branch')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final payload = {
        'tax_name': _taxNameController.text.trim(),
        'tax_mode': _taxMode,
        'tax_rate': _taxRateController.text.trim(),
        'calculation_type': _calcType,
        'branch_id': _selectedBranchId,
        'status': _status,
        'core_amount_flag': _coreAmountFlag,
        'description': _descController.text.trim(),
      };

      if (widget.tax == null) {
        await ZoyarexSupabase.client.from('pos_taxes').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('pos_taxes').update(payload).eq('id', widget.tax!.id);
      }
      
      ref.refresh(taxesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tax saved successfully')));
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
    final branchesAsync = ref.watch(outletsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tax == null ? 'Create Tax Registration' : 'Edit Tax Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _taxNameController,
                decoration: const InputDecoration(labelText: 'Tax Name (e.g. GST, VAT)', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taxRateController,
                decoration: const InputDecoration(labelText: 'Tax Rate (%)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _taxMode,
                decoration: const InputDecoration(labelText: 'Tax Mode', border: OutlineInputBorder()),
                items: ['Inclusive', 'Exclusive'].map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _taxMode = val);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _calcType,
                decoration: const InputDecoration(labelText: 'Calculation Type', border: OutlineInputBorder()),
                items: ['CalculateOnTotal', 'CalculateOnProduct'].map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _calcType = val);
                },
              ),
              const SizedBox(height: 16),
              branchesAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading branches: $err'),
                data: (branches) {
                  if (_selectedBranchId != null && !branches.any((b) => b.id == _selectedBranchId)) {
                    _selectedBranchId = null;
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedBranchId,
                    decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder()),
                    items: branches.map((b) {
                      return DropdownMenuItem(value: b.id, child: Text('${b.branchName} (${b.shopName})'));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedBranchId = val);
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
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: ['Enabled', 'Disabled'].map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Core Amount'),
                value: _coreAmountFlag,
                onChanged: (val) => setState(() => _coreAmountFlag = val),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Tax'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
