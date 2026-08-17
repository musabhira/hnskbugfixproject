import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/receipt_template_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/outlet_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';

class ZoyarexReceiptTemplateFormPage extends ConsumerStatefulWidget {
  final ReceiptTemplateModel? template;

  const ZoyarexReceiptTemplateFormPage({Key? key, this.template}) : super(key: key);

  @override
  ConsumerState<ZoyarexReceiptTemplateFormPage> createState() => _ZoyarexReceiptTemplateFormPageState();
}

class _ZoyarexReceiptTemplateFormPageState extends ConsumerState<ZoyarexReceiptTemplateFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _templateNameController;
  late TextEditingController _headerTextController;
  late TextEditingController _footerTextController;
  late TextEditingController _termsTextController;
  
  String? _selectedBranchId;
  String _documentType = 'POS_RECEIPT';
  String _paperSize = '80mm';
  bool _isDefault = false;
  
  // Example config toggles
  bool _showLogo = true;
  bool _showGstNumber = true;
  bool _showTaxBreakup = true;
  bool _showTerms = false;
  bool _showSignature = true;
  bool _showReceiptHeader = true;
  bool _showBranchAddress = true;
  bool _showCustomer = true;
  bool _showWaiterName = true;
  bool _showTableNumber = true;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _templateNameController = TextEditingController(text: widget.template?.templateName ?? '');
    
    if (widget.template != null) {
      _selectedBranchId = widget.template!.branchId;
      if (_selectedBranchId == '') _selectedBranchId = null;
      _documentType = widget.template!.documentType.isNotEmpty ? widget.template!.documentType : 'POS_RECEIPT';
      _paperSize = widget.template!.paperSize.isNotEmpty ? widget.template!.paperSize : '80mm';
      _isDefault = widget.template!.isDefault;
      
      final config = widget.template!.configData;
      _headerTextController = TextEditingController(text: config['headerText']?.toString() ?? '');
      _footerTextController = TextEditingController(text: config['footerText']?.toString() ?? '');
      _termsTextController = TextEditingController(text: config['termsText']?.toString() ?? '');
      
      _showLogo = config['showLogo'] == true;
      _showGstNumber = config['showGstNumber'] == true;
      _showTaxBreakup = config['showTaxBreakup'] == true;
      _showTerms = config['showTerms'] == true;
      _showSignature = config['showSignature'] == true;
      _showReceiptHeader = config['showReceiptHeader'] == true;
      _showBranchAddress = config['showBranchAddress'] == true;
      _showCustomer = config['showCustomer'] == true;
      _showWaiterName = config['showWaiterName'] == true;
      _showTableNumber = config['showTableNumber'] == true;
    } else {
      _headerTextController = TextEditingController();
      _footerTextController = TextEditingController();
      _termsTextController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _templateNameController.dispose();
    _headerTextController.dispose();
    _footerTextController.dispose();
    _termsTextController.dispose();
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
      final configData = {
        'showLogo': _showLogo,
        'showGstNumber': _showGstNumber,
        'showTaxBreakup': _showTaxBreakup,
        'showTerms': _showTerms,
        'termsText': _termsTextController.text.trim(),
        'showSignature': _showSignature,
        'showReceiptHeader': _showReceiptHeader,
        'showBranchAddress': _showBranchAddress,
        'showCustomer': _showCustomer,
        'showWaiterName': _showWaiterName,
        'showTableNumber': _showTableNumber,
        'headerText': _headerTextController.text.trim(),
        'footerText': _footerTextController.text.trim(),
      };

      final payload = {
        'template_name': _templateNameController.text.trim(),
        'document_type': _documentType,
        'paper_size': _paperSize,
        'branch_id': _selectedBranchId,
        'is_default': _isDefault,
        'config_data': configData,
      };

      if (widget.template == null) {
        await ZoyarexSupabase.client.from('pos_print_templates').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('pos_print_templates').update(payload).eq('gt_print_template_id', widget.template!.id);
      }
      
      ref.refresh(receiptTemplatesProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template saved successfully')));
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
        title: Text(widget.template == null ? 'Create Receipt Template' : 'Edit Receipt Template'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _templateNameController,
                decoration: const InputDecoration(labelText: 'Template Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _documentType,
                decoration: const InputDecoration(labelText: 'Document Type', border: OutlineInputBorder()),
                items: [
                  'POS_RECEIPT', 'KOT', 'Z_REPORT', 'DAY_REPORT', 
                  'SALE_INVOICE', 'SALE_RETURN', 'PAYMENT_RECEIPT'
                ].map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _documentType = val);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paperSize,
                decoration: const InputDecoration(labelText: 'Paper Size', border: OutlineInputBorder()),
                items: ['80mm', '58mm', 'A4', 'A5'].map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _paperSize = val);
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
              SwitchListTile(
                title: const Text('Set as Default Template'),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const Divider(),
              const Text('Template Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Text Fields
              TextFormField(
                controller: _headerTextController,
                decoration: const InputDecoration(labelText: 'Header Text', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _footerTextController,
                decoration: const InputDecoration(labelText: 'Footer Text', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _termsTextController,
                decoration: const InputDecoration(labelText: 'Terms & Conditions', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              // Toggles
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildToggle('Show Logo', _showLogo, (v) => setState(() => _showLogo = v)),
                  _buildToggle('Show GST #', _showGstNumber, (v) => setState(() => _showGstNumber = v)),
                  _buildToggle('Show Tax Breakup', _showTaxBreakup, (v) => setState(() => _showTaxBreakup = v)),
                  _buildToggle('Show Terms', _showTerms, (v) => setState(() => _showTerms = v)),
                  _buildToggle('Show Signature', _showSignature, (v) => setState(() => _showSignature = v)),
                  _buildToggle('Show Receipt Header', _showReceiptHeader, (v) => setState(() => _showReceiptHeader = v)),
                  _buildToggle('Show Branch Address', _showBranchAddress, (v) => setState(() => _showBranchAddress = v)),
                  _buildToggle('Show Customer Info', _showCustomer, (v) => setState(() => _showCustomer = v)),
                  _buildToggle('Show Waiter Name', _showWaiterName, (v) => setState(() => _showWaiterName = v)),
                  _buildToggle('Show Table Number', _showTableNumber, (v) => setState(() => _showTableNumber = v)),
                ],
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Template'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String title, bool value, ValueChanged<bool> onChanged) {
    return SizedBox(
      width: 200,
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        value: value,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}
