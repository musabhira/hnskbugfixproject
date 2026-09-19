import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/legal_policy_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/index.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/admin_auth_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/president_avatar_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = 'Loading...';
  bool _isProcessing = false;
  bool _canAccessAdmin = false;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final can = await AdminAuthService.canAccessAdmin();
    if (mounted) setState(() => _canAccessAdmin = can);
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${info.version}+${info.buildNumber}';
      });
    }
  }

  Future<void> _handleLogout() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    try {
      // Set a timeout to ensure responsiveness even if network is slow
      await SupaFlow.client.auth.signOut().timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Logout timeout or error: $e');
    } finally {
      if (mounted) {
        // Always navigate even if signOut fails/times out to keep the UI responsive
        context.go('/authPage');
      }
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    if (_isProcessing) return;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title:
            const Text('Delete Account', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isProcessing = true);
      try {
        final userId = SupaFlow.client.auth.currentUser?.id;
        if (userId != null) {
          // Attempt to delete user data via RPC
          try {
            await SupaFlow.client.rpc('delete_user');
          } catch (rpcError) {
            debugPrint('RPC delete_user failed: $rpcError');
            // Continue with sign out even if RPC fails
          }

          // Sign out
          await SupaFlow.client.auth.signOut();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account deleted successfully.')),
            );
            // Go directly to AuthPage and clear navigation stack
            context.go('/authPage');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.black, // Dark theme background
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionHeader(title: 'Appearance'),
              // Dark mode is permanently enforced across all devices. Light mode toggle commented out for future use.
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dark_mode, color: Color(0xFFFFFC00)),
                title: const Text('Theme', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Dark (Default)', style: TextStyle(color: Color(0xFFFFFC00), fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              /*
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark Mode', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                secondary: const Icon(Icons.dark_mode_outlined, color: Colors.white),
                activeColor: const Color(0xFFFFFC00),
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (newValue) async {
                  MyApp.of(context).setThemeMode(newValue ? ThemeMode.dark : ThemeMode.light);
                  setState(() {});
                },
              ),
              */
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Legal'),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage()),
                ),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const TermsOfServicePage()),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Account'),
              _SettingsTile(
                icon: Icons.logout,
                title: 'Log Out',
                onTap: _handleLogout,
                textColor: Color(0xFFFFFC00),
                iconColor: Color(0xFFFFFC00),
              ),
              _SettingsTile(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                onTap: _handleDeleteAccount,
                textColor: Colors.red,
                iconColor: Colors.red,
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'About'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline, color: Colors.white54),
                title: const Text(
                  'App Version',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                trailing: Text(
                  _appVersion,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
              if (_canAccessAdmin) ...[
                const SizedBox(height: 32),
                const _PresidentAndAdminSettingsSection(),
              ],
            ],
          ),
        ),

        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
            ),
          ),
      ],
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    );
  }
}

/// 🏛️ Exclusive Presidential Command Center & Master Admin Panel for musabthonippadam@gmail.com
class _PresidentAndAdminSettingsSection extends StatefulWidget {
  const _PresidentAndAdminSettingsSection();

  @override
  State<_PresidentAndAdminSettingsSection> createState() =>
      _PresidentAndAdminSettingsSectionState();
}

class _PresidentAndAdminSettingsSectionState
    extends State<_PresidentAndAdminSettingsSection> {
  List<Map<String, dynamic>> _inquiries = [];
  bool _isLoadingInquiries = true;

  @override
  void initState() {
    super.initState();
    _fetchInquiries();
  }

  Future<void> _fetchInquiries() async {
    if (!mounted) return;
    setState(() => _isLoadingInquiries = true);
    try {
      final list = await PocketPresidentService.getAdminInquiriesList();
      if (mounted) {
        setState(() {
          _inquiries = list;
          _isLoadingInquiries = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching president inquiries: $e');
      if (mounted) setState(() => _isLoadingInquiries = false);
    }
  }

  void _showReplyModal(Map<String, dynamic> inquiry) {
    final replyController = TextEditingController();
    final targetUserId = inquiry['user_id']?.toString() ?? '';
    final citizenName = inquiry['user_name']?.toString() ?? 'Citizen';
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: bottomInset + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const PresidentAvatarWidget(size: 34, showGlow: false),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reply as The President',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'To: $citizenName',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(bContext),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Citizen Inquiry:',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFC00),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        inquiry['last_message']?.toString() ?? '(Empty message)',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: replyController,
                  maxLines: 3,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type your official Presidential response in English...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isSending
                        ? null
                        : () async {
                            final text = replyController.text.trim();
                            if (text.isEmpty) return;
                            setModalState(() => isSending = true);
                            await PocketPresidentService.sendPresidentReplyToUser(
                              targetUserId: targetUserId,
                              replyText: text,
                              adminName: 'President Mus\'ab',
                            );
                            if (mounted) {
                              Navigator.pop(bContext);
                              _fetchInquiries();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✨ Presidential reply sent successfully!'),
                                  backgroundColor: Color(0xFF0F172A),
                                ),
                              );
                            }
                          },
                    child: isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'Send Official Reply',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPostVibeDialog() {
    final captionCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1),
        ),
        title: Row(
          children: [
            const PresidentAvatarWidget(size: 28, showGlow: false),
            const SizedBox(width: 10),
            Text(
              'Post President Vibe',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: captionCtrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter presidential state address or inspiration...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final text = captionCtrl.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(dCtx);
              await PocketPresidentService.postPresidentVibe(caption: text);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('👑 Presidential Vibe posted with Golden Aura!'),
                    backgroundColor: Color(0xFF0F172A),
                  ),
                );
              }
            },
            child: const Text('Publish Vibe'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.1),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              const PresidentAvatarWidget(size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'PRESIDENTIAL DESK',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFFFFD700),
                          size: 15,
                        ),
                      ],
                    ),
                    Text(
                      'Super Admin Control • musabthonippadam@gmail.com',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 10.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFFD700), size: 20),
                onPressed: _fetchInquiries,
                tooltip: 'Refresh citizen inquiries',
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),

          // 📨 Live Citizen Messages (Front and Center)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CITIZEN INQUIRIES & MESSAGES',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFFC00),
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_inquiries.length} Messages',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_isLoadingInquiries)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ),
            )
          else if (_inquiries.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.mark_email_read_rounded, color: Colors.white38, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No pending citizen messages. Messages sent to The President will appear here in real-time.',
                      style: TextStyle(color: Colors.white54, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: math.min(5, _inquiries.length),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final inq = _inquiries[index];
                final name = inq['user_name'] ?? 'Citizen';
                final msg = inq['last_message'] ?? '';
                final status = inq['status'] ?? 'pending';
                final isPending = status == 'pending';

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPending
                          ? const Color(0xFFFF8906).withValues(alpha: 0.3)
                          : Colors.white10,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF0F172A),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isPending
                                        ? Colors.orange.withValues(alpha: 0.2)
                                        : Colors.green.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isPending ? 'PENDING' : 'REPLIED',
                                    style: TextStyle(
                                      color: isPending
                                          ? Colors.orangeAccent
                                          : Colors.greenAccent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          backgroundColor: const Color(0xFFFFD700).withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _showReplyModal(inq),
                        child: Text(
                          'Reply',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 18),

          // 🚀 1-Tap Direct Launch to Full Admin Dashboard (No PIN needed for Mus'ab!)
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => AdminAuthService.openAdminPanelDirectly(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFF9100),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open Master Admin Dashboard',
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Curriculum, Users, Cohorts, Robot Ecosystem & Revenue',
                          style: GoogleFonts.inter(
                            color: Colors.black87,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Quick Action: Post President Vibe
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 18),
              label: Text(
                'Post Official President Vibe',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _showPostVibeDialog,
            ),
          ),
        ],
      ),
    );
  }
}


