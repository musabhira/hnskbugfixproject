import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/plan_provider.dart';

// Plan Assignment Form - assigns/updates a plan subscription for a specific tenant
class ZoyarexTenantPlanAssignmentForm extends ConsumerStatefulWidget {
  final String tenantId;
  final String tenantName;
  final Map<String, dynamic>? existingSubscription;

  const ZoyarexTenantPlanAssignmentForm({
    Key? key,
    required this.tenantId,
    required this.tenantName,
    this.existingSubscription,
  }) : super(key: key);

  @override
  ConsumerState<ZoyarexTenantPlanAssignmentForm> createState() => _ZoyarexTenantPlanAssignmentFormState();
}

class _ZoyarexTenantPlanAssignmentFormState extends ConsumerState<ZoyarexTenantPlanAssignmentForm> {
  String? _selectedPlanId;
  String _status = 'active';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPlanId = widget.existingSubscription?['plan_id']?.toString();
    _status = widget.existingSubscription?['status']?.toString() ?? 'active';
  }

  Future<void> _submitForm() async {
    if (_selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a plan')));
      return;
    }
    setState(() => _isLoading = true);

    try {
      final payload = {
        'tenant_id': widget.tenantId,
        'plan_id': _selectedPlanId,
        'status': _status,
        'start_date': DateTime.now().toIso8601String(),
      };

      if (widget.existingSubscription == null) {
        await ZoyarexSupabase.client.from('tenant_subscriptions').insert(payload);
      } else {
        await ZoyarexSupabase.client
            .from('tenant_subscriptions')
            .update(payload)
            .eq('id', widget.existingSubscription!['id']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscription updated successfully')));
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
    final plansAsync = ref.watch(planProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Plan: ${widget.tenantName}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.deepPurple.shade50,
              child: ListTile(
                leading: const Icon(Icons.domain, color: Colors.deepPurple),
                title: Text(widget.tenantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Tenant ID: ${widget.tenantId.substring(0, 8)}...'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Select Subscription Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            plansAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading plans: $err'),
              data: (plans) => Column(
                children: plans.map((plan) => RadioListTile<String>(
                  title: Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('\$${plan.price} / ${plan.billingCycle} — ${plan.description ?? ''}'),
                  value: plan.id,
                  groupValue: _selectedPlanId,
                  onChanged: (val) => setState(() => _selectedPlanId = val),
                  activeColor: Colors.deepPurple,
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Subscription Status', border: OutlineInputBorder()),
              items: ['active', 'suspended', 'cancelled', 'trial'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitForm,
              icon: _isLoading ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
              label: const Text('Save Assignment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
