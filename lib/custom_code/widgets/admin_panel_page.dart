import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int totalReports = 0;
  bool isLoadingStats = true;

  // Filter and Search
  String userSearchQuery = "";
  String authSearchQuery = "";
  List<Map<String, dynamic>> allProfiles = [];
  List<Map<String, dynamic>> pendingAccessList = [];
  bool isLoadingUsers = false;
  bool isLoadingAccess = false;
  bool isLoadingAuth = false;
  List<Map<String, dynamic>> allUsers = [];

  // App Update State
  Map<String, dynamic>? appUpdateData;
  bool isLoadingUpdate = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Admin Access Required', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter the administrative PIN to unlock this section.', 
              style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                labelText: 'PIN CODE',
                labelStyle: const TextStyle(color: Colors.grey),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (passwordController.text == adminPin) {
                Navigator.of(context).pop();
                setState(() => isAuthenticated = true);
                _loadInitialData();
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid PIN Code'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Unlock', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
      _loadReports(),
      _loadUsersAuth(),
      _loadAppUpdateData(),
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
      _fetchCounts();
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) setState(() => isLoadingStats = false);
    }
  }

  Future<void> _fetchCounts() async {
    try {
      final countRes = await supabase.from('reports').select('id');
      if (mounted) setState(() => totalReports = countRes.length);
    } catch (e) {
      debugPrint('Error fetching report count: $e');
    }
  }

  Future<void> _loadProfiles() async {
    setState(() => isLoadingUsers = true);
    try {
      final res = await supabase
          .from('profile')
          .select('id, name, shop_name, profile_image_url, verified')
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
      // First, get the pending requests
      final accessRes = await supabase
          .from('user_course_access')
          .select('id, has_paid, user_id, course_id, created_at')
          .eq('has_paid', false)
          .order('created_at', ascending: false);

      if (accessRes.isEmpty) {
        if (mounted) {
          setState(() {
            pendingAccessList = [];
            isLoadingAccess = false;
          });
        }
        return;
      }

      final requests = List<Map<String, dynamic>>.from(accessRes);
      final userIds = requests.map((r) => r['user_id'] as String).toSet().toList();
      final courseIds = requests.map((r) => r['course_id'] as String).toSet().toList();

      // Second, fetch profiles and courses for these IDs
      final profilesRes = await supabase
          .from('profile')
          .select('user_id, name, shop_name, phone_no')
          .inFilter('user_id', userIds);
      
      final coursesRes = await supabase
          .from('courses')
          .select('id, title')
          .inFilter('id', courseIds);

      final profilesMap = {
        for (var p in profilesRes) p['user_id'].toString(): p
      };
      
      final coursesMap = {
        for (var c in coursesRes) c['id'].toString(): c
      };

      // Combine them
      final combined = requests.map((r) {
        return {
          ...r,
          'profile': profilesMap[r['user_id']] ?? {'name': 'Unknown User'},
          'courses': coursesMap[r['course_id']] ?? {'title': 'Unknown Course'}
        };
      }).toList();

      if (mounted) {
        setState(() {
          pendingAccessList = combined;
          isLoadingAccess = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading access requests: $e');
      if (mounted) setState(() => isLoadingAccess = false);
    }
  }

  List<Map<String, dynamic>> reportsList = [];
  bool isLoadingReports = false;

  Future<void> _loadReports() async {
    setState(() => isLoadingReports = true);
    try {
      final res = await supabase.from('reports').select('*').order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          reportsList = List<Map<String, dynamic>>.from(res);
          isLoadingReports = false;
        });
      }
      _fetchCounts();
    } catch (e) {
      debugPrint('Error loading reports: $e');
      if (mounted) setState(() => isLoadingReports = false);
    }
  }

  Future<void> _loadUsersAuth() async {
    setState(() => isLoadingAuth = true);
    try {
      // Fetch users (credentials)
      final usersRes = await supabase
          .from('users')
          .select('id, email, password')
          .order('id');
      
      // Fetch profiles (names)
      final profilesRes = await supabase
          .from('profile')
          .select('user_id, name');

      final profileMap = {
        for (var p in profilesRes) p['user_id'].toString(): p['name']
      };

      if (mounted) {
        setState(() {
          allUsers = usersRes.map((u) {
            return {
              ...u,
              'name': profileMap[u['id']] ?? 'Unknown User'
            };
          }).toList();
          isLoadingAuth = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading auth data: $e');
      if (mounted) setState(() => isLoadingAuth = false);
    }
  }

  Future<void> _updateReportStatus(String reportId, String status) async {
    try {
      await supabase.from('reports').update({'status': status}).eq('id', reportId);
      _loadReports();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report marked as $status'), backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating report: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleUserVerification(String userId, bool currentStatus) async {
    try {
      await supabase.from('profile').update({'verified': !currentStatus}).eq('id', userId);
      _loadProfiles(); // Refresh
      _loadStats(); // Update stats
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ${!currentStatus ? "Verified" : "Unverified"} successfully!'), 
          backgroundColor: !currentStatus ? Colors.green : Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating verification: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _approveCourseAccess(String accessId) async {
    try {
      await supabase.from('user_course_access').update({'has_paid': true}).eq('id', accessId);
      _loadPendingAccess();
      _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course access granted!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error granting access: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) return const Scaffold(backgroundColor: Colors.black);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Admin Dashboard', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          indicatorColor: Colors.amber,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Insight'),
            Tab(icon: Icon(Icons.people_outline), text: 'Users'),
            Tab(icon: Icon(Icons.school_outlined), text: 'Requests'),
            Tab(icon: Icon(Icons.report_problem_outlined), text: 'Reports'),
            Tab(icon: Icon(Icons.security_outlined), text: 'Auth'),
            Tab(icon: Icon(Icons.system_update_outlined), text: 'Update'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInsightTab(),
          _buildUserTab(),
          _buildRequestsTab(),
          _buildReportsTab(),
          _buildAuthTab(),
          _buildUpdateTab(),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
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
              _buildStatCard('Total Reports', totalReports.toString(), Icons.report, Colors.red),
            ],
          ),
          const SizedBox(height: 30),
          const Text('Quick Actions', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 15),
          _buildQuickActionCard('Broadcast Message', 'Send a notification to all users', Icons.campaign_outlined, Colors.blue, () {
            _tabController.animateTo(1); // Go to users
          }),
          _buildQuickActionCard('Manage Subscriptions', 'View and edit user plans', Icons.subscriptions_outlined, Colors.indigo, () {}),
          _buildQuickActionCard('Support Tickets', 'Resolve user complaints', Icons.support_agent_outlined, Colors.teal, () {
            _tabController.animateTo(3); // Go to reports
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search users or shops...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[900],
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
                        color: Colors.grey[900],
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
                            Text(user['name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            if (isVerified) const SizedBox(width: 4),
                            if (isVerified) const Icon(Icons.verified, color: Colors.amber, size: 16),
                          ],
                        ),
                        subtitle: Text(user['shop_name'] ?? 'No shop name', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: Switch(
                          value: isVerified,
                          activeThumbColor: Colors.blue,
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
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.school, color: Colors.orange, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(course['title'] ?? 'Unknown Course', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                  Text('Request by: ${profile['name'] ?? "User"}', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                                ],
                              ),
                            ),
                            Text('${date.day}/${date.month}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Colors.white.withOpacity(0.1)),
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

  Widget _buildReportsTab() {
    return RefreshIndicator(
      onRefresh: _loadReports,
      child: isLoadingReports
          ? const Center(child: CircularProgressIndicator())
          : (reportsList.isEmpty)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('No reports to review!', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reportsList.length,
                  itemBuilder: (context, index) {
                    final report = reportsList[index];
                    final status = report['status'] ?? 'pending';
                    final type = report['report_type'] ?? 'other';
                    final date = DateTime.parse(report['created_at']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                      ),
                      child: ExpansionTile(
                        leading: Icon(
                          status == 'resolved' ? Icons.check_circle : Icons.warning_amber_rounded,
                          color: status == 'resolved' ? Colors.green : Colors.orange,
                        ),
                        title: Text('${type.toString().toUpperCase()} - ${report['content_type']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                        subtitle: Text('Status: $status • ${date.day}/${date.month}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                Text(report['description'] ?? 'No description provided.', style: const TextStyle(color: Colors.white70)),
                                const SizedBox(height: 12),
                                if (status == 'pending' || status == 'reviewed')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => _updateReportStatus(report['id'], 'dismissed'),
                                        child: const Text('Dismiss', style: TextStyle(color: Colors.grey)),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => _updateReportStatus(report['id'], 'resolved'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                        child: const Text('Mark Resolved', style: TextStyle(color: Colors.white)),
                                      ),
                                    ],
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

  Widget _buildAuthTab() {
    final filteredUsers = allUsers.where((u) {
      final name = u['name']?.toString().toLowerCase() ?? "";
      final email = u['email']?.toString().toLowerCase() ?? "";
      return name.contains(authSearchQuery.toLowerCase()) ||
          email.contains(authSearchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => authSearchQuery = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by name or email...',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadUsersAuth,
            child: isLoadingAuth
                ? const Center(child: CircularProgressIndicator())
                : (filteredUsers.isEmpty)
                    ? const Center(
                        child: Text('No auth data found.',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final email = user['email'] ?? "No Email";
                          final password = user['password'] ?? "";
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              title: Text(user['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  // Email Row
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(email,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13)),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy_rounded,
                                            size: 18, color: Colors.blue),
                                        onPressed: () {
                                          Clipboard.setData(
                                              ClipboardData(text: email));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text('Email copied!'),
                                                duration: Duration(seconds: 1)),
                                          );
                                        },
                                        tooltip: 'Copy Email',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Password Row
                                  Row(
                                    children: [
                                      const Icon(Icons.lock_outline,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text('••••••••',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                                letterSpacing: 2)),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.content_copy,
                                            size: 18, color: Colors.amber),
                                        onPressed: () {
                                          Clipboard.setData(
                                              ClipboardData(text: password));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Password copied!'),
                                                duration: Duration(seconds: 1)),
                                          );
                                        },
                                        tooltip: 'Copy Password',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.amber.withValues(alpha: 0.1),
                                child: const Icon(Icons.lock_person,
                                    color: Colors.amber),
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

  Widget _buildUpdateTab() {
    if (isLoadingUpdate) return const Center(child: CircularProgressIndicator());
    if (appUpdateData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load update metadata', style: TextStyle(color: Colors.white)),
            TextButton(onPressed: _loadAppUpdateData, child: const Text('Retry')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Platform Versioning', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          
          _buildUpdateControlCard(
            'Android Deployment',
            Icons.android,
            Colors.green,
            'android_version',
            'android_active',
            appUpdateData!['android_link'] ?? '',
          ),
          
          const SizedBox(height: 20),
          
          _buildUpdateControlCard(
            'iOS Deployment',
            Icons.apple,
            Colors.white,
            'ios_version',
            'ios_active',
            appUpdateData!['ios_link'] ?? '',
          ),
          
          const SizedBox(height: 30),
          
          const Text('Global Update Details', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 15),
          
          _buildTextField('Update Title', 'title'),
          const SizedBox(height: 15),
          _buildTextField('Description', 'description', maxLines: 3),
          const SizedBox(height: 15),
          
          Row(
            children: [
              const Text('Mandatory Update', style: TextStyle(color: Colors.white)),
              const Spacer(),
              Switch(
                value: appUpdateData!['is_mandatory'] ?? false,
                onChanged: (v) => setState(() => appUpdateData!['is_mandatory'] = v),
                activeThumbColor: Colors.red,
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _updateAppVersion,
              child: const Text('Push Global Update Configuration', 
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUpdateControlCard(String title, IconData icon, Color iconColor, String versionKey, String activeKey, String link) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              const Text('Active', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Switch(
                value: appUpdateData![activeKey] ?? false,
                onChanged: (v) => setState(() => appUpdateData![activeKey] = v),
                activeThumbColor: Colors.blue,
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: appUpdateData![versionKey]?.toString() ?? '1.0.0'),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Store Version',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => appUpdateData![versionKey] = v,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Live', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String key, {int maxLines = 1}) {
    return TextField(
      controller: TextEditingController(text: appUpdateData![key]?.toString() ?? ''),
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      onChanged: (v) => appUpdateData![key] = v,
    );
  }

  Future<void> _loadAppUpdateData() async {
    setState(() => isLoadingUpdate = true);
    try {
      final res = await supabase.from('app_updates').select('*').eq('id', 1).maybeSingle();
      if (mounted) {
        setState(() {
          appUpdateData = res;
          isLoadingUpdate = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading app update data: $e');
      if (mounted) setState(() => isLoadingUpdate = false);
    }
  }

  Future<void> _updateAppVersion() async {
    if (appUpdateData == null) return;
    setState(() => isLoadingUpdate = true);
    try {
      await supabase.from('app_updates').update({
        'android_version': appUpdateData!['android_version'],
        'ios_version': appUpdateData!['ios_version'],
        'android_active': appUpdateData!['android_active'],
        'ios_active': appUpdateData!['ios_active'],
        'is_mandatory': appUpdateData!['is_mandatory'],
        'title': appUpdateData!['title'],
        'description': appUpdateData!['description'],
        'features': appUpdateData!['features'],
      }).eq('id', 1);
      
      _loadAppUpdateData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App configuration updated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating app config: $e'), backgroundColor: Colors.red),
        );
      }
      if (mounted) setState(() => isLoadingUpdate = false);
    }
  }
}

/*
[KEY.PROPERTIES BACKUP - SECURE STORAGE]
storePassword=pocket123
keyPassword=pocket123
keyAlias=upload
storeFile=upload-keystore.jks
*/
