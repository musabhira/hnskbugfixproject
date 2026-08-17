import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_superadmin_tenant_form.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_tenant_plan_assignment_form.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/providers/tenant_provider.dart';
import 'package:pocket_mates_app/custom_code/widgets/zoyarex_admin/zoyarex_dashboard_page.dart';
import 'package:go_router/go_router.dart';

class ZoyarexSuperadminTenantDashboard extends ConsumerStatefulWidget {
  final String tenantId;
  final String tenantName;

  const ZoyarexSuperadminTenantDashboard({
    Key? key,
    required this.tenantId,
    required this.tenantName,
  }) : super(key: key);

  @override
  ConsumerState<ZoyarexSuperadminTenantDashboard> createState() => _ZoyarexSuperadminTenantDashboardState();
}

class _ZoyarexSuperadminTenantDashboardState extends ConsumerState<ZoyarexSuperadminTenantDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _tenantDetails;
  Map<String, dynamic>? _subscription;
  Map<String, int> _stats = {};
  List<dynamic> _usersList = [];
  List<dynamic> _rolesList = [];
  List<dynamic> _groupsList = [];
  List<dynamic> _outletsList = [];
  List<dynamic> _warehousesList = [];
  List<dynamic> _devicesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _loadTenantData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTenantData() async {
    setState(() => _isLoading = true);
    try {
      // Load tenant details
      final tenantRes = await ZoyarexSupabase.client
          .from('tenants')
          .select('*')
          .eq('id', widget.tenantId)
          .maybeSingle();
      
      // Load subscription
      final subRes = await ZoyarexSupabase.client
          .from('tenant_subscriptions')
          .select('*, plans(name, price, billing_cycle)')
          .eq('tenant_id', widget.tenantId)
          .maybeSingle();

      // Load tenant stats
      final outlets = await ZoyarexSupabase.client.from('branches').select('*').eq('tenant_id', widget.tenantId);
      final users = await ZoyarexSupabase.client.from('users').select('*').eq('tenant_id', widget.tenantId);
      final roles = await ZoyarexSupabase.client.from('roles').select('*').eq('tenant_id', widget.tenantId);
      final groups = await ZoyarexSupabase.client.from('shops').select('*').eq('tenant_id', widget.tenantId);
      final warehouses = await ZoyarexSupabase.client.from('warehouses').select('*').eq('tenant_id', widget.tenantId);
      final products = await ZoyarexSupabase.client.from('products').select('id').eq('tenant_id', widget.tenantId);
      final orders = await ZoyarexSupabase.client.from('orders').select('id').eq('tenant_id', widget.tenantId);
      // Devices might be under another table, handling it as empty for now to prevent errors
      final devices = [];

      if (mounted) {
        setState(() {
          _tenantDetails = tenantRes;
          _subscription = subRes;
          _usersList = users as List<dynamic>;
          _rolesList = roles as List<dynamic>;
          _groupsList = groups as List<dynamic>;
          _outletsList = outlets as List<dynamic>;
          _warehousesList = warehouses as List<dynamic>;
          _devicesList = devices;
          _stats = {
            'outlets': _outletsList.length,
            'users': _usersList.length,
            'roles': _rolesList.length,
            'products': (products as List).length,
            'orders': (orders as List).length,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTenantStatus() async {
    if (_tenantDetails == null) return;
    final currentStatus = _tenantDetails!['status']?.toString() ?? 'active';
    final newStatus = currentStatus == 'active' ? 'suspended' : 'active';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${newStatus == 'active' ? 'Activate' : 'Suspend'} Tenant?'),
        content: Text('Set ${widget.tenantName} to $newStatus?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: newStatus == 'active' ? Colors.green : Colors.red, foregroundColor: Colors.white),
            child: Text(newStatus == 'active' ? 'Activate' : 'Suspend'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ZoyarexSupabase.client.from('tenants').update({'status': newStatus}).eq('id', widget.tenantId);
        ref.refresh(tenantProvider);
        await _loadTenantData();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tenant $newStatus')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _connectToTenant() {
    ZoyarexSupabase.connectToTenant(widget.tenantId);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ZoyarexDashboardPage()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Connected to ${widget.tenantName}')));
  }

  @override
  Widget build(BuildContext context) {
    final status = _tenantDetails?['status']?.toString() ?? 'unknown';
    final isActive = status == 'Enabled' || status == 'active';

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage: ${widget.tenantName}'),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Groups'),
            Tab(text: 'Outlets'),
            Tab(text: 'Warehouses'),
            Tab(text: 'Users'),
            Tab(text: 'Roles'),
            Tab(text: 'Devices'),
            Tab(text: 'Documents'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _connectToTenant,
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text('Connect', style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Tenant',
            onPressed: _tenantDetails == null ? null : () async {
              final tenantsAsync = ref.read(tenantProvider);
              tenantsAsync.whenData((tenants) {
                final matches = tenants.where((t) => t.id == widget.tenantId).toList();
                if (matches.isEmpty) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexSuperadminTenantForm(tenant: matches.first)));
              });
            },
          ),
          IconButton(
            icon: Icon(isActive ? Icons.block : Icons.check_circle, color: isActive ? Colors.red.shade200 : Colors.green.shade200),
            tooltip: isActive ? 'Suspend Tenant' : 'Activate Tenant',
            onPressed: _toggleTenantStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(isActive, status),
                _buildGroupsTab(),
                _buildOutletsTab(),
                _buildWarehousesTab(),
                _buildUsersTab(),
                _buildRolesTab(),
                _buildDevicesTab(),
                _buildDocumentsTab(),
              ],
            ),
    );
  }

  Widget _buildDetailsTab(bool isActive, String status) {
    return RefreshIndicator(
      onRefresh: _loadTenantData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isActive ? Colors.green : Colors.red),
              ),
              child: Row(
                children: [
                  Icon(isActive ? Icons.check_circle : Icons.cancel, color: isActive ? Colors.green : Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    'Tenant Status: ${status.toUpperCase()}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.green.shade800 : Colors.red.shade800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subscription Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subscription', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        TextButton.icon(
                          icon: const Icon(Icons.assignment),
                          label: Text(_subscription == null ? 'Assign Plan' : 'Change Plan'),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ZoyarexTenantPlanAssignmentForm(
                              tenantId: widget.tenantId,
                              tenantName: widget.tenantName,
                              existingSubscription: _subscription,
                            ))).then((_) => _loadTenantData());
                          },
                        ),
                      ],
                    ),
                    if (_subscription != null) ...[
                      const Divider(),
                      _infoRow('Plan', _subscription!['plans']?['name']?.toString() ?? 'N/A'),
                      _infoRow('Price', '\$${_subscription!['plans']?['price']} / ${_subscription!['plans']?['billing_cycle']}'),
                      _infoRow('Sub Status', _subscription!['status']?.toString() ?? 'N/A'),
                      _infoRow('Start Date', _subscription!['start_date']?.toString().split('T')[0] ?? 'N/A'),
                    ] else
                      const Text('No active subscription', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats Grid
            const Text('Tenant Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              children: [
                _statCard('Outlets', _stats['outlets'] ?? 0, Icons.store, Colors.blue),
                _statCard('Users', _stats['users'] ?? 0, Icons.people, Colors.orange),
                _statCard('Products', _stats['products'] ?? 0, Icons.inventory, Colors.green),
                _statCard('Orders', _stats['orders'] ?? 0, Icons.receipt_long, Colors.purple),
              ],
            ),
            const SizedBox(height: 16),

            // Tenant Details
            if (_tenantDetails != null) ...[
              const Text('Tenant Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _infoRow('Name', _tenantDetails!['name']?.toString() ?? ''),
                      _infoRow('Domain', _tenantDetails!['domain']?.toString() ?? ''),
                      _infoRow('Email', _tenantDetails!['email']?.toString() ?? ''),
                      _infoRow('Phone', _tenantDetails!['phone']?.toString() ?? ''),
                      _infoRow('Country', _tenantDetails!['country']?.toString() ?? ''),
                      _infoRow('Currency', _tenantDetails!['currency']?.toString() ?? ''),
                      _infoRow('Timezone', _tenantDetails!['timezone']?.toString() ?? ''),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_usersList.isEmpty) {
      return const Center(child: Text('No Users Found for this Organization.'));
    }
    return ListView.builder(
      itemCount: _usersList.length,
      itemBuilder: (context, index) {
        final user = _usersList[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(user['email'] ?? 'Unknown Email'),
          subtitle: Text('Role ID: ${user['role_id'] ?? 'N/A'}'),
          trailing: Text(user['status'] ?? 'N/A'),
        );
      },
    );
  }

  Widget _buildRolesTab() {
    if (_rolesList.isEmpty) {
      return const Center(child: Text('No Roles Found for this Organization.'));
    }
    return ListView.builder(
      itemCount: _rolesList.length,
      itemBuilder: (context, index) {
        final role = _rolesList[index];
        return ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.security, color: Colors.white)),
          title: Text(role['name'] ?? 'Unknown Role'),
          subtitle: Text(role['description'] ?? 'No description'),
        );
      },
    );
  }

  Widget _buildDocumentsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No Documents Uploaded', style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: null, // Placeholder for upload functionality
            child: Text('Upload Document'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    if (_groupsList.isEmpty) {
      return const Center(child: Text('No Groups Found for this Organization.'));
    }
    return ListView.builder(
      itemCount: _groupsList.length,
      itemBuilder: (context, index) {
        final group = _groupsList[index];
        return ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.group_work, color: Colors.white)),
          title: Text(group['shop_name'] ?? group['name'] ?? 'Unknown Group'),
          subtitle: Text('Status: ${group['status'] ?? 'N/A'}'),
        );
      },
    );
  }

  Widget _buildOutletsTab() {
    if (_outletsList.isEmpty) {
      return const Center(child: Text('No Outlets Found for this Organization.'));
    }
    return ListView.builder(
      itemCount: _outletsList.length,
      itemBuilder: (context, index) {
        final outlet = _outletsList[index];
        return ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.storefront, color: Colors.white)),
          title: Text(outlet['branch_name'] ?? outlet['name'] ?? 'Unknown Outlet'),
          subtitle: Text('Location: ${outlet['location'] ?? 'N/A'} | Status: ${outlet['status'] ?? 'N/A'}'),
        );
      },
    );
  }

  Widget _buildWarehousesTab() {
    if (_warehousesList.isEmpty) {
      return const Center(child: Text('No Warehouses Found for this Organization.'));
    }
    return ListView.builder(
      itemCount: _warehousesList.length,
      itemBuilder: (context, index) {
        final wh = _warehousesList[index];
        return ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.warehouse, color: Colors.white)),
          title: Text(wh['name'] ?? 'Unknown Warehouse'),
          subtitle: Text('Code: ${wh['code'] ?? 'N/A'}'),
        );
      },
    );
  }

  Widget _buildDevicesTab() {
    if (_devicesList.isEmpty) {
      return const Center(child: Text('No Devices Found for this Organization.'));
    }
    return ListView.builder(
      itemCount: _devicesList.length,
      itemBuilder: (context, index) {
        final device = _devicesList[index];
        return ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.deepPurple, child: Icon(Icons.devices, color: Colors.white)),
          title: Text(device['device_name'] ?? 'Unknown Device'),
          subtitle: Text('Serial: ${device['serial'] ?? 'N/A'}'),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
