import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_login_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/tenant_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_superadmin_tenant_form.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_superadmin_tenant_dashboard.dart';

class ZoyarexSuperadminDashboardPage extends ConsumerStatefulWidget {
  const ZoyarexSuperadminDashboardPage({super.key});

  @override
  ConsumerState<ZoyarexSuperadminDashboardPage> createState() => _ZoyarexSuperadminDashboardPageState();
}

class _ZoyarexSuperadminDashboardPageState extends ConsumerState<ZoyarexSuperadminDashboardPage> {
  int _selectedIndex = 0; // 0: Dashboard, 1: Active, 2: Demo, 3: Inactive

  Future<void> _logout(BuildContext context) async {
    await ZoyarexSupabase.client.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ZoyarexLoginPage()),
      );
    }
  }

  void _onMenuTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    final user = ZoyarexSupabase.client.auth.currentUser;
    final tenantsAsync = ref.watch(tenantProvider);

    final String title = _selectedIndex == 0
        ? 'Super Admin Dashboard'
        : _selectedIndex == 1
            ? 'Organizations'
            : _selectedIndex == 2
                ? 'Demo Organizations'
                : 'Deactive Organizations';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple,
        elevation: 0,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, color: Colors.purple, size: 40),
              ),
              accountName: const Text('Zoyarex Super Admin', style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(user?.email ?? ""),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.purple),
              title: const Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () => _onMenuTapped(0),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.business, color: Colors.green),
              title: const Text('Organization'),
              selected: _selectedIndex == 1,
              onTap: () => _onMenuTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.science, color: Colors.blue),
              title: const Text('Demo Organization'),
              selected: _selectedIndex == 2,
              onTap: () => _onMenuTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Deactive Organization'),
              selected: _selectedIndex == 3,
              onTap: () => _onMenuTapped(3),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.grey),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        tooltip: 'Create Organization',
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ZoyarexSuperadminTenantForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: tenantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (tenants) {
          final activeTenants = tenants.where((t) => (t.tenantCode).startsWith('T-') && (t.status == 'Enabled' || t.status == 'active')).toList();
          final demoTenants = tenants.where((t) => !(t.tenantCode).startsWith('T-')).toList();
          final inactiveTenants = tenants.where((t) => (t.tenantCode).startsWith('T-') && (t.status != 'Enabled' && t.status != 'active')).toList();

          if (_selectedIndex == 0) {
            return _buildDashboardView(activeTenants.length, demoTenants.length, inactiveTenants.length);
          } else if (_selectedIndex == 1) {
            return _buildTenantList(activeTenants, 'No Organizations Found');
          } else if (_selectedIndex == 2) {
            return _buildTenantList(demoTenants, 'No Demo Organizations Found');
          } else {
            return _buildTenantList(inactiveTenants, 'No Deactive Organizations Found');
          }
        },
      ),
    );
  }

  Widget _buildDashboardView(int activeCount, int demoCount, int inactiveCount) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 600;
              return GridView.count(
                crossAxisCount: isDesktop ? 3 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isDesktop ? 1.5 : 2.5,
                children: [
                  _buildStatCard('Organization', activeCount, Icons.business, Colors.green, 1),
                  _buildStatCard('Demo Organization', demoCount, Icons.science, Colors.blue, 2),
                  _buildStatCard('Deactive Organization', inactiveCount, Icons.block, Colors.red, 3),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color, int targetIndex) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = targetIndex;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    count.toString(),
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Icon(icon, size: 48, color: Colors.white.withOpacity(0.5)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTenantList(List<TenantModel> tenantList, String emptyMessage) {
    if (tenantList.isEmpty) {
      return Center(child: Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(tenantProvider);
        await Future.delayed(const Duration(milliseconds: 50));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: tenantList.length,
        itemBuilder: (context, index) {
          final tenant = tenantList[index];
          final bool isDemo = !(tenant.tenantCode).startsWith('T-');
          final bool isActive = tenant.status == 'Enabled' || tenant.status == 'active';
          
          return Card(
            elevation: 3,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: isDemo ? Colors.blue.withOpacity(0.2) : (isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                child: Icon(isDemo ? Icons.science : (isActive ? Icons.business : Icons.block), color: isDemo ? Colors.blue : (isActive ? Colors.green : Colors.red)),
              ),
              title: Text(tenant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Code: ${tenant.tenantCode}', style: const TextStyle(color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text('Domain: ${tenant.domain}', style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('Email: ${tenant.email}', style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Status: ${tenant.status}',
                        style: TextStyle(color: isActive ? Colors.green : Colors.red, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit Organization',
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
