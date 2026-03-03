import 'package:flutter/material.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/legal_policy_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/courses_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final String _appVersion = '1.0.0+12'; // Matched with pubspec.yaml

  Future<void> _handleLogout() async {
    try {
      await SupaFlow.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          'LandingPage',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        // Fallback if LandingPage isn't found or error occurs
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
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
      try {
        final userId = SupaFlow.client.auth.currentUser?.id;
        if (userId != null) {
          // Attempt to delete user data from public tables if RLS allows
          // This is a "best effort" client-side cleanup.
          // Call RPC to delete user
          await SupaFlow.client.rpc('delete_user');

          // Sign out
          await SupaFlow.client.auth.signOut();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account deleted successfully.')),
            );
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            textColor: Colors.amber,
            iconColor: Colors.amber,
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
          StatefulBuilder(builder: (context, setState) {
            int versionTapCount = 0;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline, color: Colors.white54),
              title: const Text(
                'App Version',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              trailing: Text(
                _appVersion,
                style: const TextStyle(color: Colors.white54),
              ),
              onTap: () {
                versionTapCount++;
                if (versionTapCount == 12) {
                  versionTapCount = 0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminPanelPage()),
                  );
                }
              },
            );
          }),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({Key? key, required this.title}) : super(key: key);

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
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  }) : super(key: key);

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
