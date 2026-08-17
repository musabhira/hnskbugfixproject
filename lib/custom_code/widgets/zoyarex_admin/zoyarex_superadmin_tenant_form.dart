import 'package:flutter/material.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/tenant_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ZoyarexSuperadminTenantForm extends ConsumerStatefulWidget {
  final TenantModel? tenant;

  const ZoyarexSuperadminTenantForm({Key? key, this.tenant}) : super(key: key);

  @override
  ConsumerState<ZoyarexSuperadminTenantForm> createState() => _ZoyarexSuperadminTenantFormState();
}

class _ZoyarexSuperadminTenantFormState extends ConsumerState<ZoyarexSuperadminTenantForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _domainCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  String _status = 'active';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.tenant?.name ?? '');
    _domainCtrl = TextEditingController(text: widget.tenant?.domain ?? '');
    _emailCtrl = TextEditingController(text: widget.tenant?.email ?? '');
    _phoneCtrl = TextEditingController(text: widget.tenant?.phone ?? '');
    _status = widget.tenant?.status ?? 'active';
  }

  Future<void> _saveTenant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = {
      'name': _nameCtrl.text.trim(),
      'domain': _domainCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'status': _status,
    };

    try {
      if (widget.tenant == null) {
        await ZoyarexSupabase.client.from('tenants').insert(payload);
      } else {
        await ZoyarexSupabase.client.from('tenants').update(payload).eq('id', widget.tenant!.id);
      }
      ref.refresh(tenantProvider);
      if (mounted) Navigator.pop(context);
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
        title: Text(widget.tenant == null ? 'Create Tenant' : 'Edit Tenant'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Tenant Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _domainCtrl,
                decoration: const InputDecoration(labelText: 'Domain', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _isLoading ? null : _saveTenant,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Tenant'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
