import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';
import 'package:pocket_mates_app/auth_page/auth_page_widget.dart';
import 'package:pocket_mates_app/main.dart';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_util.dart';
import 'package:pocket_mates_app/auth/supabase_auth/auth_util.dart';

/// 👤 Represents an account saved locally on the device for fast 1-tap switching.
class SavedLoginAccount {
  final String userId;
  final String email;
  final String password;
  final String name;
  final String username;
  final String? profileImageUrl;
  final String lastActive;

  SavedLoginAccount({
    required this.userId,
    required this.email,
    required this.password,
    required this.name,
    required this.username,
    this.profileImageUrl,
    required this.lastActive,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'email': email,
        'password': password,
        'name': name,
        'username': username,
        'profile_image_url': profileImageUrl,
        'last_active': lastActive,
      };

  factory SavedLoginAccount.fromJson(Map<String, dynamic> json) =>
      SavedLoginAccount(
        userId: json['user_id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        password: json['password']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        profileImageUrl: json['profile_image_url']?.toString(),
        lastActive: json['last_active']?.toString() ?? '',
      );

  SavedLoginAccount copyWith({
    String? name,
    String? username,
    String? password,
    String? profileImageUrl,
    String? lastActive,
  }) {
    return SavedLoginAccount(
      userId: userId,
      email: email,
      password: password ?? this.password,
      name: name ?? this.name,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

/// 🔐 Instagram-Style Multi-Account Switcher & Saved Login Info Service.
/// Stores accounts locally on device for seamless 1-tap switching between accounts.
class PocketSavedAccountService {
  static const String _kStorageKey = 'poket_saved_login_info_accounts_v1';

  /// Fetch all accounts saved on this device
  static Future<List<SavedLoginAccount>> getSavedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        return list
            .map((e) => SavedLoginAccount.fromJson(Map<String, dynamic>.from(e)))
            .where((a) => a.userId.isNotEmpty && a.email.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('[SavedAccountService] Error getting saved accounts: $e');
    }
    return [];
  }

  /// Save or update an account in local device storage
  static Future<void> saveOrUpdateAccount(SavedLoginAccount account) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accounts = await getSavedAccounts();
      final index = accounts.indexWhere((a) => a.userId == account.userId);

      if (index >= 0) {
        final existing = accounts[index];
        accounts[index] = account.copyWith(
          password: account.password.isNotEmpty
              ? account.password
              : existing.password,
          profileImageUrl: account.profileImageUrl ?? existing.profileImageUrl,
          name: account.name.isNotEmpty ? account.name : existing.name,
          username: account.username.isNotEmpty
              ? account.username
              : existing.username,
          lastActive: DateTime.now().toIso8601String(),
        );
      } else {
        accounts.add(account);
      }

      await prefs.setString(
        _kStorageKey,
        jsonEncode(accounts.map((a) => a.toJson()).toList()),
      );

      // Also persist password cache for quick access
      if (account.password.isNotEmpty) {
        await prefs.setString(
          'saved_pm_password_${account.email.toLowerCase()}',
          account.password,
        );
      }
    } catch (e) {
      debugPrint('[SavedAccountService] Error saving account: $e');
    }
  }

  /// Automatically ensures current logged-in user is saved/updated in local storage
  static Future<void> saveCurrentLoggedInUser({
    String? password,
    Map<String, dynamic>? profileData,
  }) async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user == null || user.id.isEmpty) return;

      final uid = user.id;
      final email = user.email ?? '';
      if (email.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final cachedPassword = password ??
          prefs.getString('saved_pm_password_${email.toLowerCase()}') ??
          '';

      String name = profileData?['name']?.toString() ?? '';
      String username = profileData?['username']?.toString() ??
          profileData?['shop_name']?.toString() ??
          '';
      String? profileImageUrl =
          profileData?['profile_image_url']?.toString();

      // If profileData not passed, try fetching from profile table
      if (name.isEmpty) {
        try {
          final res = await SupaFlow.client
              .from('profile')
              .select('name, username, shop_name, profile_image_url')
              .eq('user_id', uid)
              .maybeSingle();
          if (res != null) {
            name = res['name']?.toString() ?? '';
            username = res['username']?.toString() ??
                res['shop_name']?.toString() ??
                '';
            profileImageUrl = res['profile_image_url']?.toString();
          }
        } catch (_) {}
      }

      if (name.isEmpty) {
        name = email.split('@').first;
      }
      if (username.isEmpty) {
        username = name.toLowerCase().replaceAll(' ', '');
      }

      final account = SavedLoginAccount(
        userId: uid,
        email: email,
        password: cachedPassword,
        name: name,
        username: username,
        profileImageUrl: profileImageUrl,
        lastActive: DateTime.now().toIso8601String(),
      );

      await saveOrUpdateAccount(account);
    } catch (e) {
      debugPrint('[SavedAccountService] Error saving current user: $e');
    }
  }

  /// Remove an account from saved login info on this device
  static Future<void> removeAccount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accounts = await getSavedAccounts();
      final target = accounts.firstWhere(
        (a) => a.userId == userId,
        orElse: () => SavedLoginAccount(
          userId: '',
          email: '',
          password: '',
          name: '',
          username: '',
          lastActive: '',
        ),
      );

      accounts.removeWhere((a) => a.userId == userId);
      await prefs.setString(
        _kStorageKey,
        jsonEncode(accounts.map((a) => a.toJson()).toList()),
      );

      if (target.email.isNotEmpty) {
        await prefs.remove('saved_pm_password_${target.email.toLowerCase()}');
      }
    } catch (e) {
      debugPrint('[SavedAccountService] Error removing account: $e');
    }
  }

  /// 🔄 Seamlessly switch to another saved account
  static Future<bool> switchToAccount(
    BuildContext context,
    SavedLoginAccount targetAccount,
  ) async {
    try {
      // 1. First ensure current account is saved with latest active timestamp
      await saveCurrentLoggedInUser();

      final currentUid = SupaFlow.client.auth.currentUser?.id;
      if (currentUid == targetAccount.userId) {
        // Already on this account
        if (context.mounted) Navigator.of(context).pop();
        return true;
      }

      // Check if password exists
      String pwd = targetAccount.password;
      if (pwd.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        pwd = prefs.getString(
                'saved_pm_password_${targetAccount.email.toLowerCase()}') ??
            '';
      }

      if (pwd.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Password required for ${targetAccount.name}. Please log in again.',
                style: GoogleFonts.outfit(),
              ),
              backgroundColor: const Color(0xFF1E293B),
            ),
          );
        }
        return false;
      }

      // Show quick loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFFFFFC00),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Switching to ${targetAccount.name}...',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // 2. Sign out of current account
      GoRouter.of(context).prepareAuthEvent();
      await SupaFlow.client.auth.signOut();
      GoRouter.of(context).clearRedirectLocation();

      // 3. Sign into target account via authManager to synchronize FlutterFlow state
      final authUser = await authManager.signInWithEmail(
        context,
        targetAccount.email,
        pwd,
      );

      final uid = authUser?.uid ?? SupaFlow.client.auth.currentUser?.id;
      if (uid == null || uid.isEmpty) {
        throw Exception('Authentication failed for ${targetAccount.email}');
      }

      // 4. Update Kids vs Adult mode & AdMob
      try {
        await PocketKidsService.syncAndVerifyUserAccountType(uid);
      } catch (_) {}
      PocketAdMobService.instance.onAccountSwitched(uid);
      await PocketAdMobService.instance.isUserVip(forceRefresh: true);

      // Update target account last active in saved list
      await saveOrUpdateAccount(
        targetAccount.copyWith(
          password: pwd,
          lastActive: DateTime.now().toIso8601String(),
        ),
      );

      if (context.mounted) {
        // Pop dialog and bottom sheet
        Navigator.of(context, rootNavigator: true).pop();
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        context.goNamedAuth(HomePageWidget.routeName, context.mounted);

        try {
          MyApp.of(context).restartApp();
        } catch (_) {}
      }

      return true;
    } catch (e) {
      debugPrint('[SavedAccountService] Switch error: $e');
      if (context.mounted) {
        // Pop progress dialog if open
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to switch account: $e',
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }

  /// 📱 Open Instagram-style Saved Login Info Bottom Sheet
  static void showLoginInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _SavedAccountBottomSheetContent(),
    );
  }
}

class _SavedAccountBottomSheetContent extends StatefulWidget {
  const _SavedAccountBottomSheetContent();

  @override
  State<_SavedAccountBottomSheetContent> createState() =>
      _SavedAccountBottomSheetContentState();
}

class _SavedAccountBottomSheetContentState
    extends State<_SavedAccountBottomSheetContent> {
  List<SavedLoginAccount> _accounts = [];
  bool _isLoading = true;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final user = SupaFlow.client.auth.currentUser;
    _currentUserId = user?.id ?? '';

    // Ensure current user is saved in list
    await PocketSavedAccountService.saveCurrentLoggedInUser();

    final list = await PocketSavedAccountService.getSavedAccounts();
    if (mounted) {
      setState(() {
        _accounts = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRemoveAccount(SavedLoginAccount acc) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor:
            isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove Account?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Remove "${acc.name}" from saved login info on this device? You can log back in anytime with your password.',
          style: GoogleFonts.outfit(
            fontSize: 13.5,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(dCtx, true),
            child: Text(
              'Remove',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PocketSavedAccountService.removeAccount(acc.userId);
      await _loadAccounts();
    }
  }

  void _handleAddAccount() async {
    Navigator.pop(context);
    // Ensure current user is saved before navigating to login
    await PocketSavedAccountService.saveCurrentLoggedInUser();

    // Prepare auth sign out to allow logging into next account
    GoRouter.of(context).prepareAuthEvent();
    await SupaFlow.client.auth.signOut();
    GoRouter.of(context).clearRedirectLocation();

    if (mounted) {
      context.goNamedAuth(AuthPageWidget.routeName, context.mounted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentAcc = _accounts.firstWhere(
      (a) => a.userId == _currentUserId,
      orElse: () => SavedLoginAccount(
        userId: _currentUserId,
        email: SupaFlow.client.auth.currentUser?.email ?? '',
        password: '',
        name: 'You',
        username: '',
        lastActive: '',
      ),
    );

    final otherAccounts =
        _accounts.where((a) => a.userId != _currentUserId).toList();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2129) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab Handle
              Center(
                child: Container(
                  width: 42,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFC00).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.manage_accounts_rounded,
                      color: Color(0xFFFFB300),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Switch Accounts',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Saved Login Info on this device',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
                  ),
                )
              else ...[
                // Section: Current Active Account
                if (_currentUserId.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'CURRENT ACCOUNT',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: const Color(0xFFFFFC00),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF262C38)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: currentAcc.profileImageUrl !=
                                          null &&
                                      currentAcc.profileImageUrl!.isNotEmpty
                                  ? NetworkImage(currentAcc.profileImageUrl!)
                                  : null,
                              backgroundColor: const Color(0xFFFFFC00),
                              child: currentAcc.profileImageUrl == null ||
                                      currentAcc.profileImageUrl!.isEmpty
                                  ? Text(
                                      currentAcc.name.isNotEmpty
                                          ? currentAcc.name[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF262C38)
                                        : Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentAcc.name,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                currentAcc.username.isNotEmpty
                                    ? '@${currentAcc.username}'
                                    : currentAcc.email,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color:
                                      isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF22C55E).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF22C55E),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Active',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF22C55E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Section: Other Saved Accounts
                if (otherAccounts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'SAVED ACCOUNTS (${otherAccounts.length})',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: otherAccounts.length,
                      itemBuilder: (context, index) {
                        final acc = otherAccounts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF262C38)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white10
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundImage: acc.profileImageUrl != null &&
                                      acc.profileImageUrl!.isNotEmpty
                                  ? NetworkImage(acc.profileImageUrl!)
                                  : null,
                              backgroundColor: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                              child: acc.profileImageUrl == null ||
                                      acc.profileImageUrl!.isEmpty
                                  ? Text(
                                      acc.name.isNotEmpty
                                          ? acc.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              acc.name,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              acc.username.isNotEmpty
                                  ? '@${acc.username}'
                                  : acc.email,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color:
                                    isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFC00),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    PocketSavedAccountService.switchToAccount(
                                      context,
                                      acc,
                                    );
                                  },
                                  child: Text(
                                    'Switch',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                    size: 18,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onSelected: (val) {
                                    if (val == 'remove') {
                                      _handleRemoveAccount(acc);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    PopupMenuItem(
                                      value: 'remove',
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Remove from device',
                                            style: GoogleFonts.outfit(
                                              color: Colors.redAccent,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Action: Add / Login to another account
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      color: isDark ? Colors.white : Colors.black87,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Add Account',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Log into an existing account or create a new one',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey,
                  ),
                  onTap: _handleAddAccount,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
