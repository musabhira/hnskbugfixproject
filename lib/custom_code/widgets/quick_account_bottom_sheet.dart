// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '/pages/home_page/home_page_widget.dart';
import '/auth_page/auth_page_widget.dart';
import 'package:pocket_mates_app/main.dart';

class AutoLoginBottomSheet extends StatefulWidget {
  final double? width;
  final double? height;
  const AutoLoginBottomSheet({
    super.key,
    this.width,
    this.height,
  });

  // Static method to show the bottom sheet from anywhere
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AutoLoginBottomSheet(),
    );
  }

  @override
  State<AutoLoginBottomSheet> createState() => _AutoLoginBottomSheetState();
}

class _AutoLoginBottomSheetState extends State<AutoLoginBottomSheet> {
  final SupabaseClient supabase = SupaFlow.client;
  List<Map<String, dynamic>> autoLoginUsers = [];
  Map<String, dynamic>? currentProfile;
  bool isLoading = true;
  bool showAuth = false;
  bool isCreatingAccount = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  static const String _kLocalQuickAccountsKey = 'poket_quick_switch_accounts';

  @override
  void initState() {
    super.initState();
    _loadAutoLoginUsers();
  }

  /// Helper to get local accounts from SharedPreferences
  Future<List<Map<String, dynamic>>> _getLocalAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLocalQuickAccountsKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('[QuickAccount] Error reading local accounts: $e');
    }
    return [];
  }

  /// Helper to save accounts to SharedPreferences
  Future<void> _saveLocalAccounts(List<Map<String, dynamic>> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocalQuickAccountsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('[QuickAccount] Error saving local accounts: $e');
    }
  }

  /// Load accounts with bidirectional pairing and fast local caching
  Future<void> _loadAutoLoginUsers() async {
    final currentUserId = supabase.auth.currentUser?.id;
    final currentUserEmail = supabase.auth.currentUser?.email;

    // Fetch current user's profile info for top active card
    if (currentUserId != null) {
      try {
        final pRes = await supabase
            .from('profile')
            .select('name, profile_image_url')
            .eq('user_id', currentUserId)
            .maybeSingle();
        if (mounted) {
          setState(() {
            currentProfile = {
              'user_id': currentUserId,
              'email': currentUserEmail ?? '',
              'name': pRes?['name']?.toString() ??
                  currentUserEmail?.split('@').first ??
                  'You',
              'profile_image_url': pRes?['profile_image_url']?.toString(),
            };
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            currentProfile = {
              'user_id': currentUserId,
              'email': currentUserEmail ?? '',
              'name': currentUserEmail?.split('@').first ?? 'You',
              'profile_image_url': null,
            };
          });
        }
      }
    }

    // 1. FAST PATH: Read from SharedPreferences immediately (0ms blank delay)
    final localList = await _getLocalAccounts();
    if (mounted) {
      final filteredLocal = localList.where((acc) {
        final id = acc['user_id']?.toString();
        final email = acc['email']?.toString();
        return id != currentUserId && (currentUserEmail == null || email != currentUserEmail);
      }).toList();

      if (filteredLocal.isNotEmpty) {
        setState(() {
          autoLoginUsers = filteredLocal;
          isLoading = false;
        });
      }
    }

    if (currentUserId == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    // 2. NETWORK PATH: Query Supabase auto_login bidirectionally
    try {
      // Find entries where current user is parent OR current user is linked user
      final response = await supabase.from('auto_login').select('''
            id,
            created_at,
            user_id,
            parent_user_id,
            users!auto_login_user_id_fkey(
              id,
              email,
              password,
              profile!inner(name, profile_image_url)
            )
          ''').or('parent_user_id.eq.$currentUserId,user_id.eq.$currentUserId');

      final List<Map<String, dynamic>> combined = List<Map<String, dynamic>>.from(localList);

      for (final rawItem in response) {
        final row = Map<String, dynamic>.from(rawItem);
        final targetUserId = (row['user_id'] == currentUserId)
            ? row['parent_user_id']?.toString()
            : row['user_id']?.toString();

        if (targetUserId == null || targetUserId == currentUserId) continue;

        // Extract user profile & credentials if joined
        final userInfo = row['users'] as Map<String, dynamic>?;
        final profilesList = userInfo?['profile'] as List<dynamic>?;
        final profile = (profilesList != null && profilesList.isNotEmpty)
            ? profilesList.first as Map<String, dynamic>?
            : null;

        final email = userInfo?['email']?.toString();
        final password = userInfo?['password']?.toString();
        final name = profile?['name']?.toString() ?? email?.split('@').first ?? 'User';
        final profileImageUrl = profile?['profile_image_url']?.toString();

        final existingIdx = combined.indexWhere((item) =>
            item['user_id'] == targetUserId || (email != null && item['email'] == email));

        if (existingIdx >= 0) {
          // Update details
          if (name != 'User') combined[existingIdx]['name'] = name;
          if (profileImageUrl != null) combined[existingIdx]['profile_image_url'] = profileImageUrl;
          if (password != null && password.isNotEmpty) combined[existingIdx]['password'] = password;
          combined[existingIdx]['auto_login_id'] = row['id']?.toString();
        } else {
          combined.add({
            'user_id': targetUserId,
            'email': email ?? '',
            'password': password ?? '',
            'name': name,
            'profile_image_url': profileImageUrl,
            'auto_login_id': row['id']?.toString(),
          });
        }
      }

      await _saveLocalAccounts(combined);

      if (mounted) {
        final displayList = combined.where((acc) {
          final id = acc['user_id']?.toString();
          final email = acc['email']?.toString();
          return id != currentUserId && (currentUserEmail == null || email != currentUserEmail);
        }).toList();

        setState(() {
          autoLoginUsers = displayList;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[QuickAccount] Supabase load error: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// High performance quick switch
  Future<void> _quickLogin(Map<String, dynamic> userData) async {
    setState(() => isLoading = true);

    try {
      final email = userData['email']?.toString() ?? '';
      final password = userData['password']?.toString() ?? '';

      if (email.isEmpty || password.isEmpty) {
        setState(() => isLoading = false);
        _showError('Stored credentials incomplete. Please re-link this account.');
        return;
      }

      // Save current account credentials before switching if available
      final currentUserId = supabase.auth.currentUser?.id;
      final currentUserEmail = supabase.auth.currentUser?.email;
      if (currentUserId != null && currentUserEmail != null) {
        final localList = await _getLocalAccounts();
        final idx = localList.indexWhere((a) => a['user_id'] == currentUserId);
        if (idx >= 0) {
          localList[idx]['last_switched'] = DateTime.now().toIso8601String();
          await _saveLocalAccounts(localList);
        }
      }

      if (!mounted) return;
      GoRouter.of(context).prepareAuthEvent();
      await supabase.auth.signOut();
      if (!mounted) return;
      GoRouter.of(context).clearRedirectLocation();

      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        throw Exception('Failed to authenticate');
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      GoRouter.of(context).clearRedirectLocation();
      context.goNamedAuth(HomePageWidget.routeName, context.mounted);

      try {
        MyApp.of(context).restartApp();
      } catch (_) {}
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      _showError('Switch failed: $e');
    }
  }

  /// Bidirectional account link deletion
  Future<void> _deleteAutoLogin(String targetUserId, String? autoLoginId) async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;

      // 1. Remove from local cache
      final localList = await _getLocalAccounts();
      localList.removeWhere((acc) => acc['user_id'] == targetUserId);
      await _saveLocalAccounts(localList);

      // 2. Remove from Supabase auto_login bidirectionally
      if (autoLoginId != null && autoLoginId.isNotEmpty) {
        await supabase.from('auto_login').delete().eq('id', autoLoginId);
      }
      if (currentUserId != null) {
        await supabase.from('auto_login').delete().match({
          'user_id': targetUserId,
          'parent_user_id': currentUserId,
        });
        await supabase.from('auto_login').delete().match({
          'user_id': currentUserId,
          'parent_user_id': targetUserId,
        });
      }

      _loadAutoLoginUsers();
      _showSuccess('Account unlinked successfully');
    } catch (e) {
      _showError('Failed to remove account: $e');
    }
  }

  /// Create and reciprocally link a sub-account
  Future<void> _createAccount() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => isLoading = true);

    try {
      final currentUserId = supabase.auth.currentUser?.id;
      final currentUserEmail = supabase.auth.currentUser?.email;

      if (currentUserId == null) {
        _showError('No active parent account found');
        setState(() => isLoading = false);
        return;
      }

      // 1. Sign up the new user
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final newUserId = response.user?.id;
      if (newUserId != null) {
        // 2. Ensure credentials saved in users table
        try {
          await supabase.from('users').upsert({
            'email': email,
            'password': password,
          });
        } catch (_) {}

        // 3. Bidirectional pairing in auto_login table
        try {
          await supabase.from('auto_login').insert([
            {
              'user_id': newUserId,
              'parent_user_id': currentUserId,
            },
            {
              'user_id': currentUserId,
              'parent_user_id': newUserId,
            },
          ]);
        } catch (e) {
          debugPrint('[QuickAccount] Error pairing rows: $e');
        }

        // 4. Update local fast cache
        final localList = await _getLocalAccounts();
        localList.removeWhere((acc) => acc['user_id'] == newUserId);
        localList.add({
          'user_id': newUserId,
          'email': email,
          'password': password,
          'name': email.split('@').first,
          'profile_image_url': null,
          'linked_at': DateTime.now().toIso8601String(),
        });
        if (currentUserEmail != null) {
          localList.removeWhere((acc) => acc['user_id'] == currentUserId);
          localList.add({
            'user_id': currentUserId,
            'email': currentUserEmail,
            'name': currentUserEmail.split('@').first,
            'profile_image_url': null,
          });
        }
        await _saveLocalAccounts(localList);

        if (!mounted) return;
        emailController.clear();
        passwordController.clear();
        Navigator.of(context).pop();

        GoRouter.of(context).clearRedirectLocation();
        context.goNamedAuth(HomePageWidget.routeName, context.mounted);

        try {
          MyApp.of(context).restartApp();
        } catch (_) {}

        _showSuccess('Sub-account created and linked!');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Failed to create account: $e');
    }
  }

  /// Log in and reciprocally link an existing account
  Future<void> _loginAccount() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    setState(() => isLoading = true);

    try {
      final currentUserId = supabase.auth.currentUser?.id;
      final currentUserEmail = supabase.auth.currentUser?.email;

      if (currentUserId == null) {
        _showError('No active parent account found');
        setState(() => isLoading = false);
        return;
      }

      // Sign out and sign in with the new account to verify credentials
      await supabase.auth.signOut();

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final newUserId = response.user?.id;
      if (newUserId != null) {
        // Ensure credentials recorded in users table for FK joins
        try {
          await supabase.from('users').upsert({
            'email': email,
            'password': password,
          });
        } catch (_) {}

        // Insert bidirectional pairing in auto_login
        try {
          await supabase.from('auto_login').upsert([
            {
              'user_id': newUserId,
              'parent_user_id': currentUserId,
            },
            {
              'user_id': currentUserId,
              'parent_user_id': newUserId,
            },
          ]);
        } catch (e) {
          debugPrint('[QuickAccount] Pairing insert error: $e');
        }

        // Save both to local fast storage
        final localList = await _getLocalAccounts();
        localList.removeWhere((acc) => acc['user_id'] == newUserId);
        localList.add({
          'user_id': newUserId,
          'email': email,
          'password': password,
          'name': email.split('@').first,
          'profile_image_url': null,
          'linked_at': DateTime.now().toIso8601String(),
        });
        if (currentUserEmail != null) {
          localList.removeWhere((acc) => acc['user_id'] == currentUserId);
          localList.add({
            'user_id': currentUserId,
            'email': currentUserEmail,
            'name': currentUserEmail.split('@').first,
            'profile_image_url': null,
          });
        }
        await _saveLocalAccounts(localList);

        if (!mounted) return;
        emailController.clear();
        passwordController.clear();
        Navigator.of(context).pop();

        GoRouter.of(context).clearRedirectLocation();
        context.goNamedAuth(HomePageWidget.routeName, context.mounted);

        try {
          MyApp.of(context).restartApp();
        } catch (_) {}

        _showSuccess('Account paired successfully!');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Login failed: $e');
    }
  }

  Future<void> _logout() async {
    try {
      if (!mounted) return;
      Navigator.of(context).pop();

      GoRouter.of(context).prepareAuthEvent();
      await supabase.auth.signOut();

      if (!mounted) return;
      GoRouter.of(context).clearRedirectLocation();
      context.pushReplacementNamed(AuthPageWidget.routeName);
      context.goNamedAuth(AuthPageWidget.routeName, context.mounted);
    } catch (e) {
      _showError('Logout failed: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1D), // Dark slate / Pitch Black
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            width: 1.2,
          ),
          left: BorderSide(
            color: const Color(0xFF1E293B).withValues(alpha: 0.8),
            width: 1,
          ),
          right: BorderSide(
            color: const Color(0xFF1E293B).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            height: 4.5,
            width: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFFC00).withValues(alpha: 0.7),
                  const Color(0xFFFF8906).withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFC00), Color(0xFFFF8906)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.switch_account_rounded,
                    color: Colors.black,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Switch Profile',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Instant 1-tap switch between profiles',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF1E293B), height: 1),

          if (showAuth) ...[
            // Auth Form (Link / Create)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCreatingAccount ? 'Create New Sub-Account' : 'Connect Another Account',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCreatingAccount
                          ? 'Set up a fresh profile for instant 1-tap switching anytime.'
                          : 'Log in with your other Pocket Mates account to jump between them without signing out.',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF94A3B8),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Email field
                    Text(
                      'Email Address',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                      cursorColor: const Color(0xFFFFFC00),
                      decoration: InputDecoration(
                        hintText: 'user@example.com',
                        hintStyle: GoogleFonts.outfit(color: const Color(0xFF64748B)),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFFFD700), size: 20),
                        filled: true,
                        fillColor: const Color(0xFF131C2E),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF1E293B)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFFC00), width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    Text(
                      'Password',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                      cursorColor: const Color(0xFFFFFC00),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: GoogleFonts.outfit(color: const Color(0xFF64748B)),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFFFD700), size: 20),
                        filled: true,
                        fillColor: const Color(0xFF131C2E),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF1E293B)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFFC00), width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Primary Action button
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFC00), Color(0xFFFF8906)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: isLoading
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  if (isCreatingAccount) {
                                    _createAccount();
                                  } else {
                                    _loginAccount();
                                  }
                                },
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    isCreatingAccount ? 'Create & Link Profile' : 'Connect & Link Profile',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Switch mode button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() => isCreatingAccount = !isCreatingAccount);
                        },
                        child: Text(
                          isCreatingAccount
                              ? 'Already have an account? Connect it'
                              : 'Don\'t have an account? Create a new sub-profile',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Back button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() => showAuth = false);
                        },
                        child: Text(
                          '← Back to accounts',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Accounts List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // ACTIVE LOGGED-IN ACCOUNT CARD
                  if (currentProfile != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131C2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFFC00), Color(0xFFFF8906)],
                              ),
                              border: Border.all(color: const Color(0xFFFFFC00), width: 1.5),
                              image: (currentProfile!['profile_image_url'] != null &&
                                      currentProfile!['profile_image_url'].toString().isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(currentProfile!['profile_image_url']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (currentProfile!['profile_image_url'] == null ||
                                    currentProfile!['profile_image_url'].toString().isEmpty)
                                ? Center(
                                    child: Text(
                                      (currentProfile!['name']?.toString().isNotEmpty == true)
                                          ? currentProfile!['name'][0].toUpperCase()
                                          : 'U',
                                      style: GoogleFonts.outfit(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentProfile!['name']?.toString() ?? 'You',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (currentProfile!['email'] != null &&
                                    currentProfile!['email'].toString().isNotEmpty)
                                  Text(
                                    currentProfile!['email'].toString(),
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          // Active Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFFFC00).withValues(alpha: 0.6),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFFC00),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ACTIVE',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFFC00),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Section Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, left: 4),
                    child: Row(
                      children: [
                        Text(
                          'OTHER CONNECTED ACCOUNTS',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${autoLoginUsers.length}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isLoading && autoLoginUsers.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
                      ),
                    )
                  else if (autoLoginUsers.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131C2E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFC00).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.group_add_rounded,
                              size: 28,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No Other Accounts Linked',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Connect your second account or create a sub-profile below to switch between them in 1 tap without typing passwords.',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF94A3B8),
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ...autoLoginUsers.map((user) {
                      final targetUserId = user['user_id']?.toString() ?? '';
                      final autoLoginId = user['auto_login_id']?.toString();
                      final profileName = user['name']?.toString() ?? 'User';
                      final userEmail = user['email']?.toString() ?? '';
                      final profileImageUrl = user['profile_image_url']?.toString();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131C2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E293B), width: 1),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E293B),
                              border: Border.all(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                              image: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(profileImageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (profileImageUrl == null || profileImageUrl.isEmpty)
                                ? Center(
                                    child: Text(
                                      profileName.isNotEmpty ? profileName[0].toUpperCase() : 'U',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFFD700),
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            profileName,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (userEmail.isNotEmpty)
                                Text(
                                  userEmail,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.bolt_rounded,
                                    size: 13,
                                    color: Color(0xFFFFFC00),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '1-Tap Switch',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFFD700),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFFC00), Color(0xFFFF8906)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Switch',
                                  style: GoogleFonts.outfit(
                                    color: Colors.black,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _quickLogin(user);
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF131C2E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: const BorderSide(color: Color(0xFF1E293B)),
                                ),
                                title: Text(
                                  'Unlink Account',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Remove "$profileName" from quick switch?\n\nThe account remains safe, but will no longer appear in this list.',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFCBD5E1),
                                    fontSize: 13.5,
                                    height: 1.4,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteAutoLogin(targetUserId, autoLoginId);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF4444),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Unlink',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF1E293B), width: 1),
                ),
              ),
              child: Column(
                children: [
                  // Add Account Button
                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFFC00), Color(0xFFFF8906)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            showAuth = true;
                            isCreatingAccount = false;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_circle_outline_rounded,
                              color: Colors.black,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Connect Another Account',
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFFF87171), size: 17),
                      label: Text(
                        'Log Out',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFF87171),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1E293B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
