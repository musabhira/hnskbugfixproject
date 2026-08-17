import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/tenant_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_superadmin_tenant_form.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_superadmin_tenant_dashboard.dart';

class ZoyarexSuperadminTenantsPage extends ConsumerStatefulWidget {
  const ZoyarexSuperadminTenantsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ZoyarexSuperadminTenantsPage> createState() => _ZoyarexSuperadminTenantsPageState();
}

class _ZoyarexSuperadminTenantsPageState extends ConsumerState<ZoyarexSuperadminTenantsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tenantsAsync = ref.watch(tenantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Organizations'),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Demo'),
            Tab(text: 'Inactive'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexSuperadminTenantForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: tenantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tenants) {
          // In Zoyarex Angular ERP, demo tenants are those whose tenant_code does NOT start with 'T-'
          // Active tenants have status == 'Enabled'
          // Inactive tenants have status == 'Disabled' or anything else
          final activeTenants = tenants.where((t) => (t.tenantCode).startsWith('T-') && (t.status == 'Enabled' || t.status == 'active')).toList();
          final demoTenants = tenants.where((t) => !(t.tenantCode).startsWith('T-')).toList();
          final inactiveTenants = tenants.where((t) => (t.tenantCode).startsWith('T-') && (t.status != 'Enabled' && t.status != 'active')).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTenantList(activeTenants, 'No Active Organizations Found'),
              _buildTenantList(demoTenants, 'No Demo Organizations Found'),
              _buildTenantList(inactiveTenants, 'No Inactive Organizations Found'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTenantList(List<TenantModel> tenantList, String emptyMessage) {
    if (tenantList.isEmpty) {
      return Center(child: Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(tenantProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: tenantList.length,
        itemBuilder: (context, index) {
          final tenant = tenantList[index];
          final bool isDemo = !(tenant.tenantCode).startsWith('T-');
          final bool isActive = tenant.status == 'Enabled' || tenant.status == 'active';
          
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isDemo ? Colors.blue : (isActive ? Colors.green : Colors.red),
                child: Icon(isDemo ? Icons.science : (isActive ? Icons.check : Icons.close), color: Colors.white),
              ),
              title: Text(tenant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Code: ${tenant.tenantCode}'),
                  Text('Domain: ${tenant.domain}'),
                  Text('Email: ${tenant.email}'),
                  Text('Status: ${tenant.status}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexSuperadminTenantForm(tenant: tenant)));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.purple),
                    tooltip: 'View Details',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ZoyarexSuperadminTenantDashboard(
                            tenantId: tenant.id,
                            tenantName: tenant.name,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ZoyarexSuperadminTenantDashboard(
                      tenantId: tenant.id,
                      tenantName: tenant.name,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
