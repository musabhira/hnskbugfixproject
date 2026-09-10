import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/whatsapp_group_chat.dart';
import 'package:pocket_mates_app/custom_code/widgets/chat/english_hub_level_group_service.dart';
import 'package:google_fonts/google_fonts.dart'; 

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

  // Tools Visibility
  List<Map<String, dynamic>> allToolConfigs = [];
  bool isLoadingToolConfigs = false;
  String toolUserSearchQuery = "";

  // E-Learning State
  List<Map<String, dynamic>> allCourses = [];
  bool isLoadingCourses = false;
  Map<String, dynamic>? selectedCourseForCurriculum;
  bool _showCourseRequests = false;
  List<Map<String, dynamic>> courseRequests = [];
  bool isLoadingCourseRequests = false;
  List<Map<String, dynamic>> courseLessons = [];
  bool isLoadingLessons = false;

  // English Hub Level Groups Management State
  List<EnglishHubLevelGroup> _englishHubLevelGroups = [];
  Map<String, int> _hubGroupMemberCounts = {};
  bool _isLoadingHubGroups = false;
  EnglishHubLevelGroup? _selectedHubGroupForAdminChat;
  String _hubGroupSearchQuery = '';
  int _hubStudioSubTab = 0; // 0 = Brackets, 1 = Learner Allocations
  List<Map<String, dynamic>> _hubLearners = [];
  bool _isLoadingHubLearners = false;
  String _hubLearnerSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
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
              backgroundColor: Color(0xFFFFFC00),
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
      _loadGlobalToolConfigs(),
      _loadCourses(),
      _loadEnglishHubLevelGroups(),
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
          .select('id, user_id, name, shop_name, profile_image_url, verified')
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
          labelColor: Color(0xFFFFFC00),
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          indicatorColor: Color(0xFFFFFC00),
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'Insight'),
            Tab(icon: Icon(Icons.people_outline), text: 'Users'),
            Tab(icon: Icon(Icons.school_outlined), text: 'Requests'),
            Tab(icon: Icon(Icons.report_problem_outlined), text: 'Reports'),
            Tab(icon: Icon(Icons.security_outlined), text: 'Auth'),
            Tab(icon: Icon(Icons.system_update_outlined), text: 'Update'),
            Tab(icon: Icon(Icons.build_circle_outlined), text: 'Tools'),
            Tab(icon: Icon(Icons.collections_bookmark_outlined), text: 'E-Learning'),
            Tab(icon: Icon(Icons.forum_outlined), text: 'English Hub'),
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
          _buildToolsTab(),
          _buildELearningTab(),
          _buildEnglishHubTab(),
        ],
      ),
    );
  }

  // Tools Tab Logic
  String? selectedUserIdForTools;
  List<String> restrictedToolsForSelectedUser = [];
  bool isLoadingPermissions = false;

  final List<String> allToolNames = [
    'Admin Panel',
    'Zoyarex POS Admin',
    'Zoyarex Super Admin',
    'Drawing Tool',
    'Schedule',
    'Tasks',
    'Challenges',
    'Diagrams',
    'Teams',
    'Poster Maker',
    'Bulk Sender',
    'Poki Games',
    'Crazy Games',
    'Dynamic Web App',
    'Chess Match',
    'Travel Radar',
    'Password Pro',
    'QR & Barcode',
    'World Clock',
    'WhatsApp Web',
    'Web Search',
    'Courses',
    'Test Feature',
    'Dual Recorder',
  ];

  bool _elearningUnlocked = false;
  bool _printingUnlocked = false;

  Future<void> _loadGlobalToolConfigs() async {
    setState(() => isLoadingToolConfigs = true);
    try {
      final res = await supabase.from('app_tool_configs').select('*');
      final elearningConfig = res.firstWhere(
        (c) => c['tool_name'] == 'elearning_unlocked',
        orElse: () => {'tool_name': 'elearning_unlocked', 'android_active': false, 'ios_active': false}
      );
      final printingConfig = res.firstWhere(
        (c) => c['tool_name'] == 'printing_unlocked',
        orElse: () => {'tool_name': 'printing_unlocked', 'android_active': false, 'ios_active': false}
      );
      if (mounted) {
        setState(() {
          allToolConfigs = List<Map<String, dynamic>>.from(res);
          _elearningUnlocked = elearningConfig['android_active'] == true;
          _printingUnlocked = printingConfig['android_active'] == true;
          isLoadingToolConfigs = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading tool configs: $e');
      if (mounted) setState(() => isLoadingToolConfigs = false);
    }
  }

  Future<void> _toggleElearningUnlock(bool val) async {
    setState(() => _elearningUnlocked = val);
    try {
      await supabase.from('app_tool_configs').upsert({
        'tool_name': 'elearning_unlocked',
        'android_active': val,
        'ios_active': val,
      }, onConflict: 'tool_name');
      
      _loadGlobalToolConfigs();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(val ? 'E-Learning Academy Unlocked!' : 'E-Learning set to Coming Soon'),
            backgroundColor: val ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling elearning unlock: $e');
      setState(() => _elearningUnlocked = !val); // Revert
    }
  }

  Future<void> _togglePrintingUnlock(bool val) async {
    setState(() => _printingUnlocked = val);
    try {
      await supabase.from('app_tool_configs').upsert({
        'tool_name': 'printing_unlocked',
        'android_active': val,
        'ios_active': val,
      }, onConflict: 'tool_name');
      
      _loadGlobalToolConfigs();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(val ? 'T-Shirt Printing Shop Unlocked!' : 'Printing Shop set to Coming Soon'),
            backgroundColor: val ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling printing unlock: $e');
      setState(() => _printingUnlocked = !val); // Revert
    }
  }

  Future<void> _toggleGlobalToolVisibility(String toolName, String column, bool value) async {
    try {
      await supabase.from('app_tool_configs').upsert({
        'tool_name': toolName,
        column: value,
      }, onConflict: 'tool_name');
      _loadGlobalToolConfigs();
    } catch (e) {
      debugPrint('Error toggling global tool visibility: $e');
    }
  }

  Future<void> _loadUserPermissions(String userId) async {
    setState(() {
      selectedUserIdForTools = userId;
      isLoadingPermissions = true;
      restrictedToolsForSelectedUser = [];
      grantedPrivateAccessTools = [];
    });

    try {
      final res = await supabase
          .from('user_tool_permissions')
          .select('tool_name, is_blocked, has_private_access')
          .eq('user_id', userId);

      if (mounted) {
        setState(() {
          final list = res as List;
          restrictedToolsForSelectedUser = list
              .where((e) => e['is_blocked'] == true)
              .map((e) => e['tool_name'] as String)
              .toList();
          grantedPrivateAccessTools = list
              .where((e) => e['has_private_access'] == true)
              .map((e) => e['tool_name'] as String)
              .toList();
          isLoadingPermissions = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user permissions: $e');
      if (mounted) setState(() => isLoadingPermissions = false);
    }
  }

  List<String> grantedPrivateAccessTools = [];

  Future<void> _toggleToolPermission(String toolName, {bool? block, bool? privateAccess}) async {
    if (selectedUserIdForTools == null) return;

    final Map<String, dynamic> update = {
      'user_id': selectedUserIdForTools,
      'tool_name': toolName,
    };
    if (block != null) update['is_blocked'] = block;
    if (privateAccess != null) update['has_private_access'] = privateAccess;

    try {
      await supabase.from('user_tool_permissions').upsert(update, onConflict: 'user_id, tool_name');

      if (mounted) {
        setState(() {
          if (block != null) {
            if (block) {
              if (!restrictedToolsForSelectedUser.contains(toolName)) restrictedToolsForSelectedUser.add(toolName);
            } else {
              restrictedToolsForSelectedUser.remove(toolName);
            }
          }
          if (privateAccess != null) {
            if (privateAccess) {
              if (!grantedPrivateAccessTools.contains(toolName)) grantedPrivateAccessTools.add(toolName);
            } else {
              grantedPrivateAccessTools.remove(toolName);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error toggling tool permission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating permission: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildToolsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Color(0xFFFFFC00),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFFFC00),
            tabs: [
              Tab(text: "Global Status"),
              Tab(text: "User Access"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildGlobalToolsTab(),
                _buildUserToolsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalToolsTab() {
    return isLoadingToolConfigs 
      ? const Center(child: CircularProgressIndicator())
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allToolNames.length,
          itemBuilder: (context, index) {
            final toolName = allToolNames[index];
            final config = allToolConfigs.firstWhere(
              (c) => c['tool_name'] == toolName, 
              orElse: () => {'tool_name': toolName, 'android_active': true, 'ios_active': true}
            );
            final androidActive = config['android_active'] ?? true;
            final iosActive = config['ios_active'] ?? true;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: ExpansionTile(
                iconColor: Color(0xFFFFFC00),
                collapsedIconColor: Colors.white54,
                title: Text(toolName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Android: ${androidActive ? "ON" : "OFF"} | iOS: ${iosActive ? "ON" : "OFF"}',
                  style: TextStyle(color: (androidActive || iosActive) ? Colors.green : Colors.red, fontSize: 11),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _buildGlobalToggleRow('Public Android', Icons.android, androidActive, (v) => _toggleGlobalToolVisibility(toolName, 'android_active', v)),
                        const Divider(color: Colors.white10),
                        _buildGlobalToggleRow('Public iOS', Icons.apple, iosActive, (v) => _toggleGlobalToolVisibility(toolName, 'ios_active', v)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
  }

  Widget _buildGlobalToggleRow(String label, IconData icon, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Icon(icon, size: 18, color: value ? Colors.blue : Colors.grey),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const Spacer(),
          Switch(
            activeThumbColor: Colors.blue,
            value: value,
            onChanged: onChanged,
          ),
      ],
    );
  }

  void _showUserSearchDialog() {
    String searchQuery = "";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final filtered = allProfiles.where((p) {
            final name = p['name']?.toString().toLowerCase() ?? "";
            final shop = p['shop_name']?.toString().toLowerCase() ?? "";
            return name.contains(searchQuery.toLowerCase()) || 
                   shop.contains(searchQuery.toLowerCase());
          }).toList();

          return AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Find User', style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    onChanged: (v) => setDialogState(() => searchQuery = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        return ListTile(
                          title: Text(p['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                          subtitle: Text(p['shop_name'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          onTap: () {
                            Navigator.pop(context);
                            _loadUserPermissions(p['user_id']?.toString() ?? p['id'].toString());
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildUserToolsTab() {
    final selectedUser = selectedUserIdForTools == null 
        ? null 
        : allProfiles.firstWhere((p) => (p['user_id']?.toString() ?? p['id'].toString()) == selectedUserIdForTools, orElse: () => {});

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: _showUserSearchDialog,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFFFFC00).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_search, color: Color(0xFFFFFC00)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedUser?['name'] ?? 'Select User to Manage',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        if (selectedUser != null)
                          Text(selectedUser['shop_name'] ?? 'No shop info', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white54),
                ],
              ),
            ),
          ),
        ),
        if (selectedUserIdForTools != null)
          Expanded(
            child: isLoadingPermissions
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allToolNames.length,
                  itemBuilder: (context, index) {
                    final toolName = allToolNames[index];
                    final isBlocked = restrictedToolsForSelectedUser.contains(toolName);
                    final hasPrivate = grantedPrivateAccessTools.contains(toolName);
                    
                    final config = allToolConfigs.firstWhere(
                      (c) => c['tool_name'] == toolName, 
                      orElse: () => {'tool_name': toolName, 'android_active': true, 'ios_active': true}
                    );
                    final androidActive = config['android_active'] ?? true;
                    final iosActive = config['ios_active'] ?? true;
                    final toolIsPublic = androidActive || iosActive;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isBlocked ? Colors.red.withValues(alpha: 0.3) : Colors.white10,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(toolName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              toolIsPublic 
                                ? (isBlocked ? 'ACCESS BLOCKED' : 'Public Access')
                                : (hasPrivate ? 'PRIVATE ACCESS GRANTED' : 'Access Restricted'),
                              style: TextStyle(
                                color: (toolIsPublic && !isBlocked) || (!toolIsPublic && hasPrivate) 
                                  ? Colors.green 
                                  : Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Block Toggle (only useful if public)
                                Row(
                                  children: [
                                    const Text('Block', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Switch(
                                      activeThumbColor: Colors.red,
                                      value: isBlocked,
                                      onChanged: (val) => _toggleToolPermission(toolName, block: val),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                // Private Access Toggle
                                Row(
                                  children: [
                                    const Text('Private', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Switch(
                                      activeThumbColor: Colors.blue,
                                      value: hasPrivate,
                                      onChanged: (val) => _toggleToolPermission(toolName, privateAccess: val),
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
          )
        else
          const Expanded(
            child: Center(
              child: Text('Click the search button above to find a user.', 
                style: TextStyle(color: Colors.grey)),
            ),
          ),
      ],
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
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
                            if (isVerified) const Icon(Icons.verified, color: Color(0xFFFFFC00), size: 16),
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
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
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
                      Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
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
                                            size: 18, color: Color(0xFFFFFC00)),
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
                                backgroundColor: Color(0xFFFFFC00).withValues(alpha: 0.1),
                                child: const Icon(Icons.lock_person,
                                    color: Color(0xFFFFFC00)),
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
                backgroundColor: Color(0xFFFFFC00),
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

  // E-Learning Course and Lesson management helper methods

  Future<void> _loadCourseRequests() async {
    setState(() => isLoadingCourseRequests = true);
    try {
      final response = await supabase
          .from('course_publish_requests')
          .select('*, users!inner(display_name)')
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          courseRequests = List<Map<String, dynamic>>.from(response);
          isLoadingCourseRequests = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading course requests: $e');
      if (mounted) {
        setState(() => isLoadingCourseRequests = false);
        // Table might not exist yet if they haven't run the SQL
      }
    }
  }

  Future<void> _updateCourseRequestStatus(String requestId, String status) async {
    try {
      await supabase
          .from('course_publish_requests')
          .update({'status': status})
          .eq('id', requestId);
      _loadCourseRequests(); // Refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request marked as $status')));
      }
    } catch (e) {
      debugPrint('Error updating request status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _loadCourses() async {
    if (!mounted) return;
    setState(() => isLoadingCourses = true);
    try {
      final res = await supabase.from('courses').select().order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          allCourses = List<Map<String, dynamic>>.from(res);
          isLoadingCourses = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading courses: $e');
      if (mounted) setState(() => isLoadingCourses = false);
    }
  }

  Future<void> _loadLessons(String courseId) async {
    if (!mounted) return;
    setState(() => isLoadingLessons = true);
    try {
      final res = await supabase.from('lessons').select().eq('course_id', courseId).order('created_at', ascending: true);
      if (mounted) {
        setState(() {
          courseLessons = List<Map<String, dynamic>>.from(res);
          isLoadingLessons = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading lessons: $e');
      if (mounted) setState(() => isLoadingLessons = false);
    }
  }

  // Upload helper using FilePicker.pickFiles
  Future<String?> _uploadFile({required String bucketName, required FileType fileType}) async {
    try {
      final result = await FilePicker.pickFiles(type: fileType);
      if (result == null || result.files.isEmpty || result.files.single.path == null) {
        return null;
      }
      
      final path = result.files.single.path!;
      final file = File(path);
      final name = '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '_')}';
      
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Color(0xFFFFFC00), strokeWidth: 2),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Uploading file to $bucketName...',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black87,
          duration: const Duration(minutes: 5), // Keep open during upload
        ),
      );

      // Perform upload
      await supabase.storage.from(bucketName).upload(name, file);
      
      // Get URL
      final url = supabase.storage.from(bucketName).getPublicUrl(name);
      
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful!'), backgroundColor: Colors.green),
        );
      }
      return url;
    } catch (e) {
      debugPrint('File upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
      return null;
    }
  }

  // Delete Course
  Future<void> _deleteCourse(String courseId) async {
    try {
      // Show confirmation dialog first
      bool confirm = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Course?', style: TextStyle(color: Colors.white)),
          content: const Text('This will delete the course permanently. Lessons associated with this course might also fail or remain orphaned. Are you sure?',
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ?? false;

      if (!confirm) return;

      setState(() => isLoadingCourses = true);
      await supabase.from('courses').delete().eq('id', courseId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted successfully!'), backgroundColor: Colors.green),
        );
      }
      _loadCourses();
    } catch (e) {
      debugPrint('Error deleting course: $e');
      if (mounted) {
        setState(() => isLoadingCourses = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete course: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Delete Lesson
  Future<void> _deleteLesson(String lessonId, String courseId) async {
    try {
      bool confirm = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Lesson?', style: TextStyle(color: Colors.white)),
          content: const Text('This will delete the lesson permanently. Are you sure?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ?? false;

      if (!confirm) return;

      setState(() => isLoadingLessons = true);
      await supabase.from('lessons').delete().eq('id', lessonId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lesson deleted successfully!'), backgroundColor: Colors.green),
        );
      }
      _loadLessons(courseId);
    } catch (e) {
      debugPrint('Error deleting lesson: $e');
      if (mounted) {
        setState(() => isLoadingLessons = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete lesson: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Dialog to Create or Edit Course
  void _showCourseDialog({Map<String, dynamic>? course}) {
    final isEdit = course != null;
    final titleController = TextEditingController(text: course?['title'] ?? '');
    final descController = TextEditingController(text: course?['description'] ?? '');
    final thumbController = TextEditingController(text: course?['thumbnail'] ?? '');
    final priceController = TextEditingController(text: course?['price']?.toString() ?? '0');
    final retailPriceController = TextEditingController(text: course?['retail_price']?.toString() ?? '0');
    final languageController = TextEditingController(text: course?['language'] ?? 'Malayalam');
    final androidIdController = TextEditingController(text: course?['product_id_android'] ?? '');
    final iosIdController = TextEditingController(text: course?['product_id_ios'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Course' : 'Create New Course',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(ctx),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                _buildModalTextField('Course Title', titleController, icon: Icons.title),
                const SizedBox(height: 12),
                _buildModalTextField('Description', descController, maxLines: 3, icon: Icons.description),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModalTextField('Thumbnail URL', thumbController, icon: Icons.image),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFFC00),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final url = await _uploadFile(bucketName: 'course-thumbnails', fileType: FileType.image);
                        if (url != null) {
                          setModalState(() {
                            thumbController.text = url;
                          });
                        }
                      },
                      child: const Icon(Icons.upload_file, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModalTextField('Selling Price (INR)', priceController, keyboardType: TextInputType.number, icon: Icons.currency_rupee),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModalTextField('Retail Price (INR)', retailPriceController, keyboardType: TextInputType.number, icon: Icons.money_off),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildModalTextField('Language', languageController, icon: Icons.language),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModalTextField('Android Product ID', androidIdController, icon: Icons.android),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModalTextField('iOS Product ID', iosIdController, icon: Icons.apple),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFFC00),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Course title cannot be empty'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    
                    final data = {
                      'title': titleController.text.trim(),
                      'description': descController.text.trim(),
                      'thumbnail': thumbController.text.trim(),
                      'price': priceController.text.trim(),
                      'retail_price': retailPriceController.text.trim(),
                      'language': languageController.text.trim(),
                      'product_id_android': androidIdController.text.trim(),
                      'product_id_ios': iosIdController.text.trim(),
                    };

                    try {
                      if (isEdit) {
                        await supabase.from('courses').update(data).eq('id', course['id']);
                      } else {
                        await supabase.from('courses').insert(data);
                      }
                      if (!ctx.mounted || !context.mounted) return;
                      Navigator.pop(ctx);
                      _loadCourses();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEdit ? 'Course updated successfully!' : 'Course created successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save course: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: Text(
                    isEdit ? 'Save Changes' : 'Create Course',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dialog to Create or Edit Lesson
  void _showLessonDialog(String courseId, {Map<String, dynamic>? lesson}) {
    final isEdit = lesson != null;
    final titleController = TextEditingController(text: lesson?['title'] ?? '');
    final contentController = TextEditingController(text: lesson?['content'] ?? '');
    final videoUrlController = TextEditingController(text: lesson?['video_url'] ?? '');
    final thumbUrlController = TextEditingController(text: lesson?['thamnail_url'] ?? ''); // Note spelling thamnail_url

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Lesson' : 'Add New Lesson',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(ctx),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                _buildModalTextField('Lesson Title', titleController, icon: Icons.title),
                const SizedBox(height: 12),
                _buildModalTextField('Content / Subtext', contentController, maxLines: 3, icon: Icons.description),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModalTextField('Video URL (MP4)', videoUrlController, icon: Icons.video_library),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFFC00),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        // Upload to lesson_vedios
                        final url = await _uploadFile(bucketName: 'lesson_vedios', fileType: FileType.video);
                        if (url != null) {
                          setModalState(() {
                            videoUrlController.text = url;
                          });
                        }
                      },
                      child: const Icon(Icons.upload_file, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModalTextField('Lesson Thumbnail URL', thumbUrlController, icon: Icons.image),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFFC00),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        // Upload to thumbnails or course-thumbnails
                        final url = await _uploadFile(bucketName: 'thumbnails', fileType: FileType.image);
                        if (url != null) {
                          setModalState(() {
                            thumbUrlController.text = url;
                          });
                        }
                      },
                      child: const Icon(Icons.upload_file, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFFC00),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lesson title cannot be empty'), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    
                    final data = {
                      'course_id': courseId,
                      'title': titleController.text.trim(),
                      'content': contentController.text.trim(),
                      'video_url': videoUrlController.text.trim(),
                      'thamnail_url': thumbUrlController.text.trim(), // Note spelling
                    };

                    try {
                      if (isEdit) {
                        await supabase.from('lessons').update(data).eq('id', lesson['id']);
                      } else {
                        await supabase.from('lessons').insert(data);
                      }
                      if (!ctx.mounted || !context.mounted) return;
                      Navigator.pop(ctx);
                      _loadLessons(courseId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEdit ? 'Lesson updated successfully!' : 'Lesson added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save lesson: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: Text(
                    isEdit ? 'Save Changes' : 'Add Lesson',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType, IconData? icon}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: icon != null ? Icon(icon, color: Color(0xFFFFFC00), size: 20) : null,
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  // --- English Hub Level Groups Management Studio ---
  Future<void> _loadEnglishHubLevelGroups() async {
    if (!mounted) return;
    setState(() => _isLoadingHubGroups = true);
    try {
      final groups = await EnglishHubLevelGroupService.getLevelGroups(activeOnly: false);
      final counts = <String, int>{};
      for (final g in groups) {
        final c = await EnglishHubLevelGroupService.getGroupMemberCount(g.groupId);
        counts[g.groupId] = c;
      }
      final learners = await EnglishHubLevelGroupService.getLearnersWithHubGroups(
        searchQuery: _hubLearnerSearchQuery,
      );
      if (mounted) {
        setState(() {
          _englishHubLevelGroups = groups;
          _hubGroupMemberCounts = counts;
          _hubLearners = learners;
          _isLoadingHubGroups = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading English Hub groups in admin: $e');
      if (mounted) setState(() => _isLoadingHubGroups = false);
    }
  }

  Future<void> _loadHubLearners() async {
    if (!mounted) return;
    setState(() => _isLoadingHubLearners = true);
    try {
      final list = await EnglishHubLevelGroupService.getLearnersWithHubGroups(
        searchQuery: _hubLearnerSearchQuery,
      );
      if (mounted) {
        setState(() {
          _hubLearners = list;
          _isLoadingHubLearners = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading hub learners in admin: $e');
      if (mounted) setState(() => _isLoadingHubLearners = false);
    }
  }

  Widget _buildEnglishHubTab() {
    // 1. Live Admin Chat View
    if (_selectedHubGroupForAdminChat != null) {
      final group = _selectedHubGroupForAdminChat!;
      return Scaffold(
        backgroundColor: const Color(0xFF070B0D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121B22),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFC00)),
            onPressed: () {
              setState(() => _selectedHubGroupForAdminChat = null);
              _loadEnglishHubLevelGroups();
            },
          ),
          title: Row(
            children: [
              Text(group.iconEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.groupName,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Admin Moderation • Lvl ${group.minLevel} - ${group.maxLevel} • ${group.stageTitle}',
                      style: const TextStyle(color: Color(0xFFFFFC00), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white70),
              tooltip: 'Cohort Info',
              onPressed: () => _showGroupMembersSheet(group),
            ),
          ],
        ),
        body: WhatsAppGroupChat(
          groupId: group.groupId,
          groupName: group.groupName,
          isAdminView: true,
          showBackButton: false,
        ),
      );
    }

    // 2. English Hub Studio Overview
    final filteredGroups = _englishHubLevelGroups.where((g) {
      if (_hubGroupSearchQuery.trim().isEmpty) return true;
      final q = _hubGroupSearchQuery.toLowerCase().trim();
      return g.groupName.toLowerCase().contains(q) ||
          g.stageTitle.toLowerCase().contains(q) ||
          g.tagBadge.toLowerCase().contains(q) ||
          '${g.minLevel}'.contains(q) ||
          '${g.maxLevel}'.contains(q);
    }).toList();

    final totalLearners = _hubGroupMemberCounts.values.fold(0, (a, b) => a + b);
    final activeCount = _englishHubLevelGroups.where((g) => g.isActive).length;

    return RefreshIndicator(
      color: const Color(0xFFFFFC00),
      onRefresh: _loadEnglishHubLevelGroups,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Studio Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.35), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🌐', style: TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'English Hub Level Groups Studio',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Scale groups by user volume & level cohorts',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStudioStatChip(
                          label: 'Brackets',
                          value: '${_englishHubLevelGroups.length}',
                          icon: Icons.layers_outlined,
                          color: const Color(0xFFFFFC00),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStudioStatChip(
                          label: 'Active',
                          value: '$activeCount',
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStudioStatChip(
                          label: 'Enrolled',
                          value: '$totalLearners',
                          icon: Icons.people_outline,
                          color: const Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.add_circle, size: 18, color: Colors.black),
                          label: const Text(
                            'Add Custom Bracket',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          onPressed: _showCreateCustomGroupDialog,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.restore, size: 16, color: Color(0xFFFFFC00)),
                        label: const Text('Reset Defaults', style: TextStyle(fontSize: 12)),
                        onPressed: _confirmSeedDefaults,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 12),

                  // User Voice Directive: Instant Re-Partition Presets
                  Row(
                    children: [
                      const Text('⚡ Quick Partitioning:', style: TextStyle(color: Color(0xFFFFFC00), fontSize: 12, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.tune, color: Color(0xFFFFFC00), size: 14),
                        label: const Text('Custom Builder...', style: TextStyle(color: Color(0xFFFFFC00), fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: _showCustomPartitionBuilderDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPresetChip(
                          label: '1 Mega Group (1 - 90)',
                          emoji: '🌟',
                          subtitle: 'All in 1 Group',
                          onTap: () => _confirmApplyPartitionPlan(
                            name: 'Single Unified Hub (1 - 90)',
                            plan: EnglishHubLevelGroupService.kPresetSingleUnifiedHub,
                            description: 'Merges all levels 1 to 90 into a single English Hub group. All learners will be moved here and leave old groups.',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: '2 Cohorts (1-35 & 36-90)',
                          emoji: '🌱',
                          subtitle: 'Rookie + Master',
                          onTap: () => _confirmApplyPartitionPlan(
                            name: '2 Mega Cohorts (Lvl 1 - 35 & 36 - 90)',
                            plan: EnglishHubLevelGroupService.kPresetTwoMegaCohorts,
                            description: 'Splits app into 2 groups: Level 1-35 (Foundations) and Level 36-90 (Mastery). Learners auto-migrate to their respective half.',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: '3 Cohorts (1-30, 31-60, 61-90)',
                          emoji: '🏆',
                          subtitle: 'Tri-Stage Slices',
                          onTap: () => _confirmApplyPartitionPlan(
                            name: '3 Cohorts (1-30, 31-60, 61-90)',
                            plan: EnglishHubLevelGroupService.kPresetThreeCohorts,
                            description: 'Divides learners into Beginner (1-30), Intermediate (31-60), and Master (61-90) groups.',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: 'Standard 16 Cohorts',
                          emoji: '⚙️',
                          subtitle: '5-Level Granular',
                          onTap: () => _confirmApplyPartitionPlan(
                            name: 'Standard 16 Level Cohorts',
                            plan: EnglishHubLevelGroupService.kDefaultBrackets,
                            description: 'Restores the 16 standard cohorts in 5-level increments with 71-80 and 81-90 summits.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Sub-Tab Switcher: Brackets vs Learner Allocations
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E242B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _hubStudioSubTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _hubStudioSubTab == 0
                              ? const Color(0xFFFFFC00)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '🌐 Level Brackets (${_englishHubLevelGroups.length})',
                            style: TextStyle(
                              color: _hubStudioSubTab == 0 ? Colors.black : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _hubStudioSubTab = 1);
                        if (_hubLearners.isEmpty) _loadHubLearners();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _hubStudioSubTab == 1
                              ? const Color(0xFFFFFC00)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '👥 Learner Allocation (${_hubLearners.length})',
                            style: TextStyle(
                              color: _hubStudioSubTab == 1 ? Colors.black : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_hubStudioSubTab == 1)
              _buildLearnerAllocationsView()
            else ...[
              // Search Filter & Section Header
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search bracket or level (e.g. 1, 6, Rookie)...',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFFFFC00), size: 18),
                        filled: true,
                        fillColor: const Color(0xFF1E242B),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFFFC00), width: 1.5),
                        ),
                      ),
                      onChanged: (val) => setState(() => _hubGroupSearchQuery = val),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFFFFFC00)),
                    tooltip: 'Reload Groups',
                    onPressed: _loadEnglishHubLevelGroups,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Loading / Groups List
              if (_isLoadingHubGroups)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
                  ),
                )
              else if (filteredGroups.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Text('📭', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        const Text(
                          'No level groups match your query.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: _confirmSeedDefaults,
                          child: const Text('Provision Default Brackets'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final g = filteredGroups[index];
                    final memberCount = _hubGroupMemberCounts[g.groupId] ?? 0;
                    return _buildLevelGroupCard(g, memberCount);
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStudioStatChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required String emoji,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF11171D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ⚡ Confirm & Apply Partition Plan
  void _confirmApplyPartitionPlan({
    required String name,
    required List<Map<String, dynamic>> plan,
    required String description,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E242B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Apply $name?',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF11171D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resulting Active Groups (${plan.length}):',
                    style: const TextStyle(color: Color(0xFFFFFC00), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  ...plan.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text(p['emoji']?.toString() ?? '💬', style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${p['name']} (Lvl ${p['min']} - ${p['max']})',
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
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
              backgroundColor: const Color(0xFFFFFC00),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final ok = await EnglishHubLevelGroupService.applyCohortPartitionPlan(plan);
              if (ok) {
                _loadEnglishHubLevelGroups();
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Successfully re-partitioned learners into ${plan.length} cohorts!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Apply & Migrate All', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// 🛠️ Custom Partition Plan Builder Dialog
  void _showCustomPartitionBuilderDialog() {
    List<Map<String, dynamic>> customSlices = [
      {
        'min': 1,
        'max': 10,
        'name': 'English Hub (Lvl 1 - 10)',
        'title': 'Foundations Stage',
        'tag': 'Beginner',
        'emoji': '🌱',
      },
      {
        'min': 11,
        'max': 16,
        'name': 'English Hub (Lvl 11 - 16)',
        'title': 'Conversational Stage',
        'tag': 'Intermediate',
        'emoji': '⚡',
      },
      {
        'min': 17,
        'max': 90,
        'name': 'English Hub (Lvl 17 - 90)',
        'title': 'Fluency & Mastery',
        'tag': 'Mastery',
        'emoji': '👑',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E242B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Text('🛠️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom Partition Builder',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Slice Levels 1 to 90 into custom groups',
                      style: TextStyle(color: Color(0xFFFFFC00), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Define custom level ranges. When applied, existing English Hub groups are updated and all learners are automatically transferred to their matching slice.',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(customSlices.length, (idx) {
                    final s = customSlices[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF11171D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(s['emoji'] as String, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s['name'] as String,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (customSlices.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                                  onPressed: () {
                                    setDialogState(() => customSlices.removeAt(idx));
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: '${s['min']}',
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  decoration: InputDecoration(
                                    labelText: 'Min Lvl',
                                    labelStyle: const TextStyle(color: Colors.white60, fontSize: 10),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.all(8),
                                    filled: true,
                                    fillColor: const Color(0xFF1E242B),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (val) {
                                    final n = int.tryParse(val);
                                    if (n != null) {
                                      s['min'] = n;
                                      s['name'] = 'English Hub (Lvl ${s['min']} - ${s['max']})';
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  initialValue: '${s['max']}',
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  decoration: InputDecoration(
                                    labelText: 'Max Lvl',
                                    labelStyle: const TextStyle(color: Colors.white60, fontSize: 10),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.all(8),
                                    filled: true,
                                    fillColor: const Color(0xFF1E242B),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onChanged: (val) {
                                    final n = int.tryParse(val);
                                    if (n != null) {
                                      s['max'] = n;
                                      s['name'] = 'English Hub (Lvl ${s['min']} - ${s['max']})';
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFFC00),
                      side: const BorderSide(color: Color(0xFFFFFC00)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Next Level Slice', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      final lastMax = customSlices.isNotEmpty ? (customSlices.last['max'] as int) : 0;
                      final nextMin = lastMax + 1;
                      final nextMax = (nextMin + 10) <= 90 ? (nextMin + 10) : 90;
                      setDialogState(() {
                        customSlices.add({
                          'min': nextMin,
                          'max': nextMax,
                          'name': 'English Hub (Lvl $nextMin - $nextMax)',
                          'title': 'Custom Cohort',
                          'tag': 'Custom',
                          'emoji': '💬',
                          'order': customSlices.length + 1,
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                if (customSlices.isEmpty) return;
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                final ok = await EnglishHubLevelGroupService.applyCohortPartitionPlan(customSlices);
                if (ok) {
                  _loadEnglishHubLevelGroups();
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Applied custom plan with ${customSlices.length} cohorts!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save & Apply Plan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  /// 👥 Learner Allocation Management View
  Widget _buildLearnerAllocationsView() {
    final manualOverridesCount = _hubLearners.where((l) => l['is_manual'] == true).length;
    final autoAllocatedCount = _hubLearners.length - manualOverridesCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-Stats Bar
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E242B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on, color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$autoAllocatedCount',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        const Text('Auto-Routed', style: TextStyle(color: Colors.white60, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E242B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, color: Color(0xFFFFFC00), size: 18),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$manualOverridesCount',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        const Text('Manual Overrides', style: TextStyle(color: Colors.white60, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Search Bar
        Row(
          children: [
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search learner by name...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFFFFC00), size: 18),
                  filled: true,
                  fillColor: const Color(0xFF1E242B),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFFC00), width: 1.5),
                  ),
                ),
                onSubmitted: (val) {
                  _hubLearnerSearchQuery = val;
                  _loadHubLearners();
                },
                onChanged: (val) {
                  _hubLearnerSearchQuery = val;
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFFFFFC00)),
              tooltip: 'Reload Learners',
              onPressed: _loadHubLearners,
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (_isLoadingHubLearners)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
            ),
          )
        else if (_hubLearners.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Text('👤', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  const Text('No learners found.', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _hubLearners.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _hubLearners[index];
              final profile = item['profile'] as Map<String, dynamic>?;
              final name = profile?['name']?.toString() ?? 'Learner';
              final photo = profile?['profile_image_url']?.toString();
              final day = profile?['learning_day']?.toString() ?? '1';
              final isManual = item['is_manual'] == true;
              final assignedGroup = item['assigned_group'] as EnglishHubLevelGroup?;
              final currentGroup = item['current_group'] as EnglishHubLevelGroup?;
              final activeGroup = assignedGroup ?? currentGroup;
              final userId = item['user_id']?.toString() ?? '';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E242B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isManual
                        ? const Color(0xFFFFFC00).withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.08),
                    width: isManual ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                          backgroundImage: (photo != null && photo.isNotEmpty)
                              ? CachedNetworkImageProvider(photo)
                              : null,
                          child: (photo == null || photo.isEmpty)
                              ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Color(0xFFFFFC00)))
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Learning Level $day',
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        // Badge: Manual vs Auto
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isManual
                                ? const Color(0xFFFFFC00).withValues(alpha: 0.2)
                                : const Color(0xFF10B981).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isManual ? const Color(0xFFFFFC00) : const Color(0xFF10B981),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isManual ? '👑 Manual Override' : '⚡ Auto-Assigned',
                            style: TextStyle(
                              color: isManual ? const Color(0xFFFFFC00) : const Color(0xFF10B981),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121B22),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(activeGroup?.iconEmoji ?? '💬', style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              activeGroup != null
                                  ? '${activeGroup.groupName} (Lvl ${activeGroup.minLevel}-${activeGroup.maxLevel})'
                                  : 'Not yet joined any group',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFC00),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.swap_horiz, size: 16, color: Colors.black),
                            label: const Text(
                              'Move to Another Group',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            onPressed: () => _showMoveUserDialog(
                              userId: userId,
                              userName: name,
                              currentGroupName: activeGroup?.groupName,
                              currentGroupId: activeGroup?.groupId,
                            ),
                          ),
                        ),
                        if (isManual) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.restore, color: Colors.orangeAccent, size: 20),
                            tooltip: 'Reset to Auto Level Routing',
                            onPressed: () async {
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              final ok = await EnglishHubLevelGroupService.resetUserToAutoLevelRouting(userId);
                              if (ok) {
                                _loadEnglishHubLevelGroups();
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Reset $name to automatic level routing'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  /// 👑 Dialog: Move/Assign Learner to Any Group (Manual Admin Override)
  void _showMoveUserDialog({
    required String userId,
    required String userName,
    String? currentGroupName,
    String? currentGroupId,
  }) {
    EnglishHubLevelGroup? selectedGroup;
    if (_englishHubLevelGroups.isNotEmpty) {
      selectedGroup = _englishHubLevelGroups.firstWhere(
        (g) => g.groupId == currentGroupId,
        orElse: () => _englishHubLevelGroups.first,
      );
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E242B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Text('👑', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Move Learner',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(color: Color(0xFFFFFC00), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentGroupName != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white60, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Current: $currentGroupName',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Text(
                  'Select target English Hub cohort. The user will be automatically removed from their previous group so they remain in ONE group only.',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF11171D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.4)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<EnglishHubLevelGroup>(
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E242B),
                      value: selectedGroup,
                      items: _englishHubLevelGroups.map((g) {
                        return DropdownMenuItem<EnglishHubLevelGroup>(
                          value: g,
                          child: Row(
                            children: [
                              Text(g.iconEmoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  g.groupName,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Lvl ${g.minLevel}-${g.maxLevel}',
                                  style: const TextStyle(color: Color(0xFFFFFC00), fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedGroup = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orangeAccent,
                side: const BorderSide(color: Colors.orangeAccent),
              ),
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                final ok = await EnglishHubLevelGroupService.resetUserToAutoLevelRouting(userId);
                if (ok) {
                  _loadEnglishHubLevelGroups();
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text('Reset $userName to automatic level routing'), backgroundColor: Colors.orange),
                    );
                  }
                }
              },
              child: const Text('Reset to Auto', style: TextStyle(fontSize: 11)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                if (selectedGroup == null) return;
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                final ok = await EnglishHubLevelGroupService.assignUserToGroup(
                  userId: userId,
                  targetGroupId: selectedGroup!.groupId,
                  notes: 'Manually assigned via Admin Studio',
                );
                if (ok) {
                  _loadEnglishHubLevelGroups();
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Transferred $userName to ${selectedGroup!.groupName}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text('Confirm Move', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelGroupCard(EnglishHubLevelGroup g, int memberCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E242B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: g.isActive
              ? const Color(0xFFFFFC00).withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.4)),
                ),
                alignment: Alignment.center,
                child: Text(g.iconEmoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            g.groupName,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Level Range Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFC00),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Lvl ${g.minLevel} - ${g.maxLevel}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          g.stageTitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            g.tagBadge,
                            style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Metadata & Controls Row
          Row(
            children: [
              // Member count indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people, size: 13, color: Color(0xFFFFFC00)),
                    const SizedBox(width: 4),
                    Text(
                      '$memberCount active learners',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Active toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    g.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: g.isActive ? const Color(0xFF10B981) : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: g.isActive,
                      activeThumbColor: const Color(0xFFFFFC00),
                      onChanged: (val) async {
                        await EnglishHubLevelGroupService.updateLevelGroup(
                          id: g.id,
                          groupId: g.groupId,
                          groupName: g.groupName,
                          minLevel: g.minLevel,
                          maxLevel: g.maxLevel,
                          stageTitle: g.stageTitle,
                          tagBadge: g.tagBadge,
                          iconEmoji: g.iconEmoji,
                          isActive: val,
                        );
                        _loadEnglishHubLevelGroups();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFC00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 15, color: Colors.black),
                  label: const Text(
                    'Open Chat (Admin)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                  ),
                  onPressed: () {
                    setState(() => _selectedHubGroupForAdminChat = g);
                  },
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.tune, size: 14, color: Color(0xFFFFFC00)),
                label: const Text('Edit Range', style: TextStyle(fontSize: 11)),
                onPressed: () => _showEditGroupDialog(g),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.people_outline, color: Colors.white70, size: 18),
                tooltip: 'View Members',
                onPressed: () => _showGroupMembersSheet(g),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                tooltip: 'Delete Group',
                onPressed: () => _confirmDeleteGroup(g),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ➕ Dialog: Create Custom Bracket
  void _showCreateCustomGroupDialog() {
    final nameCtrl = TextEditingController(text: 'English Hub (Lvl )');
    final minCtrl = TextEditingController(text: '1');
    final maxCtrl = TextEditingController(text: '5');
    final titleCtrl = TextEditingController(text: 'Custom Focus Cohort');
    final tagCtrl = TextEditingController(text: 'Special Stage');
    final emojiCtrl = TextEditingController(text: '💬');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E242B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('➕', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Add Custom Level Bracket',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create custom level ranges to sub-divide cohorts as user volume grows.',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  labelStyle: TextStyle(color: Color(0xFFFFFC00)),
                  filled: true,
                  fillColor: Color(0xFF11171D),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Min Level',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF11171D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: maxCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Max Level',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF11171D),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Stage Subtitle / Description',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF11171D),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: tagCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Tag / Badge',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF11171D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: emojiCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Emoji',
                        labelStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Color(0xFF11171D),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFFC00),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final min = int.tryParse(minCtrl.text.trim()) ?? 1;
              final max = int.tryParse(maxCtrl.text.trim()) ?? 5;
              final name = nameCtrl.text.trim();
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              if (name.isEmpty || min > max) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Invalid level range or empty name'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(context);
              final res = await EnglishHubLevelGroupService.createCustomLevelGroup(
                groupName: name,
                minLevel: min,
                maxLevel: max,
                stageTitle: titleCtrl.text.trim(),
                tagBadge: tagCtrl.text.trim(),
                iconEmoji: emojiCtrl.text.trim().isNotEmpty ? emojiCtrl.text.trim() : '💬',
              );
              if (res != null) {
                _loadEnglishHubLevelGroups();
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Created: ${res.groupName}'), backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: const Text('Create Bracket', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// ✏️ Dialog: Edit Group Range / Info
  void _showEditGroupDialog(EnglishHubLevelGroup g) {
    final nameCtrl = TextEditingController(text: g.groupName);
    final minCtrl = TextEditingController(text: '${g.minLevel}');
    final maxCtrl = TextEditingController(text: '${g.maxLevel}');
    final titleCtrl = TextEditingController(text: g.stageTitle);
    final tagCtrl = TextEditingController(text: g.tagBadge);
    final emojiCtrl = TextEditingController(text: g.iconEmoji);
    bool isActive = g.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E242B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Text(g.iconEmoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Edit Level Bracket',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    labelStyle: TextStyle(color: Color(0xFFFFFC00)),
                    filled: true,
                    fillColor: Color(0xFF11171D),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Min Level',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF11171D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: maxCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Max Level',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF11171D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Stage Title',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Color(0xFF11171D),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: tagCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Tag / Badge',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF11171D),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: emojiCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Emoji',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF11171D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Active Bracket', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: isActive,
                  activeThumbColor: const Color(0xFFFFFC00),
                  onChanged: (val) => setDialogState(() => isActive = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFC00),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final min = int.tryParse(minCtrl.text.trim()) ?? g.minLevel;
                final max = int.tryParse(maxCtrl.text.trim()) ?? g.maxLevel;
                final name = nameCtrl.text.trim();
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                if (name.isEmpty || min > max) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Invalid range'), backgroundColor: Colors.red),
                  );
                  return;
                }
                Navigator.pop(context);
                final ok = await EnglishHubLevelGroupService.updateLevelGroup(
                  id: g.id,
                  groupId: g.groupId,
                  groupName: name,
                  minLevel: min,
                  maxLevel: max,
                  stageTitle: titleCtrl.text.trim(),
                  tagBadge: tagCtrl.text.trim(),
                  iconEmoji: emojiCtrl.text.trim().isNotEmpty ? emojiCtrl.text.trim() : g.iconEmoji,
                  isActive: isActive,
                );
                if (ok) {
                  _loadEnglishHubLevelGroups();
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Bracket updated successfully!'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  /// 👥 Sheet: Show Active Members
  void _showGroupMembersSheet(EnglishHubLevelGroup g) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E242B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollCtrl) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: EnglishHubLevelGroupService.getGroupMembersWithLevel(g.groupId),
              builder: (context, snapshot) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(g.iconEmoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  g.groupName,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Level ${g.minLevel} - ${g.maxLevel} Active Cohort Members',
                                  style: const TextStyle(color: Color(0xFFFFFC00), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    Expanded(
                      child: snapshot.connectionState == ConnectionState.waiting
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFC00)))
                          : (snapshot.data == null || snapshot.data!.isEmpty)
                              ? const Center(
                                  child: Text('No active members currently in this level bracket.',
                                      style: TextStyle(color: Colors.white60)),
                                )
                              : ListView.separated(
                                  controller: scrollCtrl,
                                  itemCount: snapshot.data!.length,
                                  separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                                  itemBuilder: (context, index) {
                                    final m = snapshot.data![index];
                                    final profile = m['profile'] as Map<String, dynamic>?;
                                    final name = profile?['name']?.toString() ?? 'Learner';
                                    final photo = profile?['profile_image_url']?.toString();
                                    final learningDay = profile?['learning_day']?.toString() ?? '1';
                                    final role = m['role']?.toString() ?? 'member';

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                                        backgroundImage: (photo != null && photo.isNotEmpty)
                                            ? CachedNetworkImageProvider(photo)
                                            : null,
                                        child: (photo == null || photo.isEmpty)
                                            ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                                style: const TextStyle(color: Color(0xFFFFFC00)))
                                            : null,
                                      ),
                                      title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                      subtitle: Text(
                                        'Day $learningDay • Role: $role',
                                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Lvl $learningDay',
                                              style: const TextStyle(
                                                color: Color(0xFFFFFC00),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: const Icon(Icons.swap_horiz, color: Color(0xFFFFFC00), size: 18),
                                            tooltip: 'Move to another group',
                                            onPressed: () {
                                              final userId = m['user_id']?.toString() ?? '';
                                              _showMoveUserDialog(
                                                userId: userId,
                                                userName: name,
                                                currentGroupName: g.groupName,
                                                currentGroupId: g.groupId,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// 🗑️ Confirm Delete Bracket
  void _confirmDeleteGroup(EnglishHubLevelGroup g) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E242B),
        title: const Text('Delete Level Bracket?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${g.groupName}" (Lvl ${g.minLevel} - ${g.maxLevel})? '
          'Existing messages in the group will be archived.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final ok = await EnglishHubLevelGroupService.deleteLevelGroup(
                id: g.id,
                groupId: g.groupId,
              );
              if (ok) {
                _loadEnglishHubLevelGroups();
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Deleted ${g.groupName}'), backgroundColor: Colors.orange),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 🔄 Confirm Seed Defaults
  void _confirmSeedDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E242B),
        title: const Text('Provision Default Brackets?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will ensure all standard cohorts (Level 1-6, Level 6-11, and 5-level increments up to Day 90) '
          'exist in the system. Custom groups will not be overwritten.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFFC00), foregroundColor: Colors.black),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              await EnglishHubLevelGroupService.seedDefaultLevelGroups();
              _loadEnglishHubLevelGroups();
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Default level brackets provisioned!'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Provision', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildELearningTab() {
    if (_showCourseRequests) {
      return _buildCourseRequestsView();
    }
    if (selectedCourseForCurriculum != null) {
      return _buildCurriculumView();
    }
    return _buildCourseListView();
  }

  // Course List View
  Widget _buildCourseListView() {
    return Column(
      children: [
        // View Course Requests Button
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B2B2B),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.inbox, color: Colors.blue),
            label: const Text('View Publisher Requests', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              setState(() => _showCourseRequests = true);
              _loadCourseRequests();
            },
          ),
        ),
        // E-Learning Unlock Toggle Card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFFFFC00).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.school, color: Color(0xFFFFFC00)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unlock E-Learning Academy',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _elearningUnlocked 
                        ? 'Unlocked (Academy is publicly available)' 
                        : 'Locked (Shows "Coming Soon" alert to users)',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _elearningUnlocked,
                activeTrackColor: Color(0xFFFFFC00).withOpacity(0.3),
                activeColor: Color(0xFFFFFC00),
                onChanged: (val) => _toggleElearningUnlock(val),
              ),
            ],
          ),
        ),
        // T-Shirt Printing Unlock Toggle Card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFFFFC00).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.checkroom, color: Color(0xFFFFFC00)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unlock T-Shirt Printing Shop',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _printingUnlocked 
                        ? 'Unlocked (Print Shop is publicly available)' 
                        : 'Locked (Shows "Coming Soon" alert to users)',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _printingUnlocked,
                activeTrackColor: Color(0xFFFFFC00).withOpacity(0.3),
                activeColor: Color(0xFFFFFC00),
                onChanged: (val) => _togglePrintingUnlock(val),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Course Catalog',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${allCourses.length} Courses available',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFFC00),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add, color: Colors.black, size: 20),
                label: const Text(
                  'Add Course',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _showCourseDialog(),
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoadingCourses
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFC00)))
              : allCourses.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.school_outlined,
                      title: 'No Courses Found',
                      subtitle: 'Get started by creating your very first e-learning course.',
                      actionText: 'Create Course',
                      onAction: () => _showCourseDialog(),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: allCourses.length,
                      itemBuilder: (context, index) {
                        final course = allCourses[index];
                        final thumbnail = course['thumbnail'] ?? '';
                        final price = course['price'] ?? '0';
                        final retail = course['retail_price'] ?? '0';
                        final language = course['language'] ?? 'Malayalam';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: thumbnail.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: thumbnail,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[800],
                                          child: const Center(child: CircularProgressIndicator(color: Color(0xFFFFFC00))),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[800],
                                        width: 90,
                                        height: 90,
                                        child: const Icon(Icons.image, color: Colors.grey),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      course['title'] ?? 'Untitled Course',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      course['description'] ?? 'No description provided.',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFFFC00).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '₹$price',
                                            style: const TextStyle(color: Color(0xFFFFFC00), fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        if (retail != '0' && retail != price)
                                          Text(
                                            '₹$retail',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            language,
                                            style: const TextStyle(color: Colors.blue, fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          icon: const Icon(Icons.list_alt, size: 16, color: Color(0xFFFFFC00)),
                                          label: const Text('Curriculum', style: TextStyle(color: Color(0xFFFFFC00), fontSize: 12)),
                                          onPressed: () {
                                            setState(() {
                                              selectedCourseForCurriculum = course;
                                            });
                                            _loadLessons(course['id']);
                                          },
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                                          label: const Text('Edit', style: TextStyle(color: Colors.blue, fontSize: 12)),
                                          onPressed: () => _showCourseDialog(course: course),
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                          label: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
                                          onPressed: () => _deleteCourse(course['id']),
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
        ),
      ],
    );
  }

  // Curriculum View (Lesson list inside a course)
  Widget _buildCurriculumView() {
    final course = selectedCourseForCurriculum!;
    final courseId = course['id'];

    return Column(
      children: [
        // Back Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[900]?.withOpacity(0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFC00)),
                label: const Text('Back to Courses', style: TextStyle(color: Color(0xFFFFFC00))),
                onPressed: () {
                  setState(() {
                    selectedCourseForCurriculum = null;
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['title'] ?? 'Course Curriculum',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Drag, add, edit, or delete video lessons below.',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFFC00),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add, color: Colors.black, size: 18),
                    label: const Text('Add Lesson', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () => _showLessonDialog(courseId),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: isLoadingLessons
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFC00)))
              : courseLessons.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.video_library_outlined,
                      title: 'No Lessons Added',
                      subtitle: 'Add educational video lessons to complete your curriculum.',
                      actionText: 'Add Lesson',
                      onAction: () => _showLessonDialog(courseId),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: courseLessons.length,
                      itemBuilder: (context, index) {
                        final lesson = courseLessons[index];
                        final thumb = lesson['thamnail_url'] ?? ''; // Note database spelling
                        final video = lesson['video_url'] ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFC00).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Color(0xFFFFFC00), fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lesson['title'] ?? 'Untitled Lesson',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    if (lesson['content'] != null && lesson['content'].toString().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        lesson['content'],
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.videocam, color: Colors.grey, size: 14),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            video.isNotEmpty ? 'Video linked' : 'No video link',
                                            style: TextStyle(color: video.isNotEmpty ? Colors.green : Colors.red, fontSize: 11),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          icon: const Icon(Icons.edit, size: 14, color: Colors.blue),
                                          label: const Text('Edit', style: TextStyle(color: Colors.blue, fontSize: 11)),
                                          onPressed: () => _showLessonDialog(courseId, lesson: lesson),
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                                          label: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 11)),
                                          onPressed: () => _deleteLesson(lesson['id'], courseId),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (thumb.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: thumb,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // Course Requests View
  Widget _buildCourseRequestsView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[900]?.withOpacity(0.5),
          child: Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFC00)),
                label: const Text('Back', style: TextStyle(color: Color(0xFFFFFC00))),
                onPressed: () => setState(() => _showCourseRequests = false),
              ),
              const SizedBox(width: 16),
              const Text('Publisher Requests', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: isLoadingCourseRequests
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFC00)))
              : courseRequests.isEmpty
                  ? const Center(child: Text('No publish requests yet.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: courseRequests.length,
                      itemBuilder: (context, index) {
                        final req = courseRequests[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(req['creator_name'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: req['status'] == 'pending' ? Colors.orange.withOpacity(0.2) :
                                             req['status'] == 'approved' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      (req['status'] ?? 'pending').toString().toUpperCase(),
                                      style: TextStyle(
                                        color: req['status'] == 'pending' ? Colors.orange :
                                               req['status'] == 'approved' ? Colors.green : Colors.red,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Course Title: ${req['course_title']}', style: const TextStyle(color: Color(0xFFFFFC00), fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(req['course_description'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (req['status'] == 'pending') ...[
                                    TextButton.icon(
                                      icon: const Icon(Icons.close, color: Colors.red, size: 16),
                                      label: const Text('Reject', style: TextStyle(color: Colors.red)),
                                      onPressed: () => _updateCourseRequestStatus(req['id'], 'rejected'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      icon: const Icon(Icons.check, color: Colors.white, size: 16),
                                      label: const Text('Approve', style: TextStyle(color: Colors.white)),
                                      onPressed: () => _updateCourseRequestStatus(req['id'], 'approved'),
                                    ),
                                  ]
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFFC00),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onAction,
              child: Text(actionText, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

/*
[KEY.PROPERTIES BACKUP - SECURE STORAGE]
storePassword=pocket123
keyPassword=pocket123
keyAlias=upload
storeFile=upload-keystore.jks
*/

