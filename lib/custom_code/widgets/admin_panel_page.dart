import 'package:flutter/material.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:pocket_mates_app/flutter_flow/flutter_flow_theme.dart';
// import 'package:pocket_mates_app/flutter_flow/flutter_flow_util.dart';
// import 'index.dart'; 

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  final supabase = SupaFlow.client;
  late TabController _tabController;
  final String adminPin = '944797';
  bool isAuthenticated = false;

  // Stats
  int totalUsers = 0;
  int verifiedUsers = 0;
  int pendingCourseAccess = 0;
  bool isLoadingStats = true;

  // Filter and Search
  String userSearchQuery = "";
  List<Map<String, dynamic>> allProfiles = [];
  List<Map<String, dynamic>> pendingAccessList = [];
  bool isLoadingUsers = false;
  bool isLoadingAccess = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPasswordDialog();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPasswordDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Admin Access Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter the administrative PIN to unlock this section.', 
              style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                labelText: 'PIN CODE',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Pop dialog
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (passwordController.text == adminPin) {
                Navigator.of(context).pop();
                setState(() => isAuthenticated = true);
                _loadInitialData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid PIN Code'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Unlock', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((_) {
      if (!isAuthenticated && mounted) {
        Navigator.pop(context); // Pop page if cancelled
      }
    });
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadStats(),
      _loadProfiles(),
      _loadPendingAccess(),
    ]);
  }

  Future<void> _loadStats() async {
    setState(() => isLoadingStats = true);
    try {
      final usersRes = await supabase.from('profile').select('id, verified');
      final accessRes = await supabase.from('user_course_access').select('id').eq('has_paid', false);
      
      if (mounted) {
        setState(() {
          totalUsers = usersRes.length;
          verifiedUsers = usersRes.where((u) => u['verified'] == true).length;
          pendingCourseAccess = accessRes.length;
          isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) setState(() => isLoadingStats = false);
    }
  }

  Future<void> _loadProfiles() async {
    setState(() => isLoadingUsers = true);
    try {
      final res = await supabase
          .from('profile')
          .select('id, name, shop_name, profile_image_url, verified, email')
          .order('name');
      if (mounted) {
        setState(() {
          allProfiles = List<Map<String, dynamic>>.from(res);
          isLoadingUsers = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profiles: $e');
      if (mounted) setState(() => isLoadingUsers = false);
    }
  }

  Future<void> _loadPendingAccess() async {
    setState(() => isLoadingAccess = true);
    try {
      final res = await supabase.from('user_course_access').select('''
        id, 
        has_paid,
        user_id,
        course_id,
        created_at,
        profile (id, name, shop_name, phone_no),
        courses (id, title)
      ''').eq('has_paid', false).order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          pendingAccessList = List<Map<String, dynamic>>.from(res);
          isLoadingAccess = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading access requests: $e');
      if (mounted) setState(() => isLoadingAccess = false);
    }
  }

  Future<void> _toggleUserVerification(String userId, bool currentStatus) async {
    try {
      await supabase.from('profile').update({'verified': !currentStatus}).eq('id', userId);
      _loadProfiles(); // Refresh
      _loadStats(); // Update stats
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ${!currentStatus ? "Verified" : "Unverified"} successfully!'), 
        backgroundColor: !currentStatus ? Colors.green : Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating verification: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _approveCourseAccess(String accessId) async {
    try {
      await supabase.from('user_course_access').update({'has_paid': true}).eq('id', accessId);
      _loadPendingAccess();
      _loadStats();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course access granted!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error granting access: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) return const Scaffold(backgroundColor: Colors.white);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Professional light grey background
      appBar: AppBar(
        title: const Text('Admin Dashboard', 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Insight'),
            Tab(icon: Icon(Icons.people_outline), text: 'Users'),
            Tab(icon: Icon(Icons.school_outlined), text: 'Requests'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInsightTab(),
          _buildUserTab(),
          _buildRequestsTab(),
        ],
      ),
    );
  }

  Widget _buildInsightTab() {
    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Platform Statistics', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatCard('Total Users', totalUsers.toString(), Icons.group, Colors.blue),
              const SizedBox(width: 15),
              _buildStatCard('Verified', verifiedUsers.toString(), Icons.verified_user, Colors.green),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatCard('Course Requests', pendingCourseAccess.toString(), Icons.pending_actions, Colors.orange),
              const SizedBox(width: 15),
              _buildStatCard('Active Now', '...', Icons.bolt, Colors.purple),
            ],
          ),
          const SizedBox(height: 30),
          const Text('Quick Actions', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 15),
          _buildQuickActionCard('Broadcast Message', 'Send a notification to all users', Icons.campaign_outlined, Colors.blue),
          _buildQuickActionCard('Manage Subscriptions', 'View and edit user plans', Icons.subscriptions_outlined, Colors.indigo),
          _buildQuickActionCard('Support Tickets', 'Resolve user complaints', Icons.support_agent_outlined, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildUserTab() {
    final filteredUsers = allProfiles.where((u) {
      final name = u['name']?.toString().toLowerCase() ?? "";
      final shop = u['shop_name']?.toString().toLowerCase() ?? "";
      return name.contains(userSearchQuery.toLowerCase()) || shop.contains(userSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => userSearchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search users or shops...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadProfiles,
            child: isLoadingUsers 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: filteredUsers.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final isVerified = user['verified'] == true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: (user['profile_image_url'] != null)
                             ? CachedNetworkImageProvider(user['profile_image_url'])
                             : null,
                          backgroundColor: Colors.blue[100],
                          child: (user['profile_image_url'] == null) 
                            ? Text(user['name']?[0] ?? "?", style: const TextStyle(fontWeight: FontWeight.bold))
                            : null,
                        ),
                        title: Row(
                          children: [
                            Text(user['name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (isVerified) const SizedBox(width: 4),
                            if (isVerified) const Icon(Icons.verified, color: Colors.blue, size: 16),
                          ],
                        ),
                        subtitle: Text(user['shop_name'] ?? 'No shop name', style: const TextStyle(fontSize: 12)),
                        trailing: Switch(
                          value: isVerified,
                          activeColor: Colors.blue,
                          onChanged: (v) => _toggleUserVerification(user['id'], isVerified),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: _loadPendingAccess,
      child: isLoadingAccess
        ? const Center(child: CircularProgressIndicator())
        : (pendingAccessList.isEmpty)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('All clear!', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const Text('No pending requests currently.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingAccessList.length,
              itemBuilder: (context, index) {
                final req = pendingAccessList[index];
                final profile = req['profile'] ?? {};
                final course = req['courses'] ?? {};
                final date = DateTime.parse(req['created_at']);
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.05)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.school, color: Colors.orange, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(course['title'] ?? 'Unknown Course', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text('Request by: ${profile['name'] ?? "User"}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                ],
                              ),
                            ),
                            Text('${date.day}/${date.month}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.phone_android, size: 14, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text(profile['phone_no'] ?? "No Phone", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            const Spacer(),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                              ),
                              onPressed: () => _approveCourseAccess(req['id']),
                              child: const Text('Grant Access', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
