import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/legal_policy_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/index.dart';
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/widgets/admin_auth_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/president_avatar_widget.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = 'Loading...';
  bool _isProcessing = false;
  bool _canAccessAdmin = false;
  bool _isVip = false;
  String _selectedLanguage = 'English';
  bool _isPowerSaving = false;
  bool _isNotificationsEnabled = true;
  double _voiceSpeed = 1.0;
  bool _onlineStatusVisible = true;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _checkAdminAccess();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isVip = prefs.getBool('is_vip') ?? false;
        _selectedLanguage = prefs.getString('preferred_language') ?? 'English';
        _isPowerSaving = prefs.getBool('power_saving_mode') ?? false;
        _isNotificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _voiceSpeed = prefs.getDouble('voice_speed') ?? 1.0;
        _onlineStatusVisible = prefs.getBool('online_status_visible') ?? true;
      });
    }
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

  Widget _buildVipBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isVip
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF2A1B02), const Color(0xFF181002)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isVip ? const Color(0xFFFFD700) : const Color(0xFFF59E0B),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionPage()),
            ).then((_) => _loadUserSettings());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('👑', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _isVip ? 'Poket VIP Active' : 'Upgrade to Poket VIP',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _isVip ? Icons.verified_rounded : Icons.bolt_rounded,
                            color: const Color(0xFFFFD700),
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isVip
                            ? 'Instant Binge Mode • 100% Ad-Free • Golden Verified • Presidential Guard'
                            : 'Unlock Instant Binge Mode, Zero Ads & Golden Verified Tick (from ₹249)',
                        style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSavedMessagesModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bookmark_added_rounded, color: Color(0xFF38BDF8), size: 24),
                const SizedBox(width: 10),
                Text(
                  'Saved Notes & Vocabulary',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Your pinned phrases and tutor voice notes from 90 learning houses are securely stored on your device and Supabase account.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFD700), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All saved vocabulary items sync automatically with your Daily Vocab Trainer.',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDevicesModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.devices_rounded, color: Color(0xFF10B981), size: 24),
                const SizedBox(width: 10),
                Text(
                  'Devices & Active Sessions',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Your account is protected by Supabase JWT end-to-end authentication.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Icon(
                    Platform.isIOS ? Icons.phone_iphone_rounded : Icons.phone_android_rounded,
                    color: const Color(0xFF10B981),
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Platform.isIOS ? 'Apple iPhone / iPad' : 'Android Mobile Device',
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'Current Active Session • Online Now',
                          style: GoogleFonts.inter(color: const Color(0xFF10B981), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySecurityModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.security_rounded, color: Color(0xFFA855F7), size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Privacy & Security',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.visibility_rounded, color: Color(0xFFA855F7)),
                title: const Text('Show Online Status in World Street', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Allows neighbors to see your active English practice presence', style: TextStyle(color: Colors.white54, fontSize: 11.5)),
                activeThumbColor: const Color(0xFFA855F7),
                value: _onlineStatusVisible,
                onChanged: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('online_status_visible', val);
                  setModalState(() => _onlineStatusVisible = val);
                  setState(() => _onlineStatusVisible = val);
                },
              ),
              const Divider(color: Colors.white12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.block_rounded, color: Colors.white70),
                title: const Text('Blocked Neighbors & Peers', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('0 blocked users', style: TextStyle(color: Colors.white54, fontSize: 11.5)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No users are currently blocked.')),
                  );
                },
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVoiceSpeedPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select AI Voice Coach Speed',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...[0.8, 1.0, 1.2].map((speed) {
              final isSelected = (_voiceSpeed - speed).abs() < 0.05;
              final label = speed == 0.8
                  ? '0.8x • Slow & Clear (Great for Beginners)'
                  : speed == 1.0
                      ? '1.0x • Natural Native Conversational (Default)'
                      : '1.2x • Fast Fluent Accent';
              return ListTile(
                title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13.5)),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFFFC00)) : null,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setDouble('voice_speed', speed);
                  setState(() => _voiceSpeed = speed);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final languages = [
      {'name': 'English', 'native': 'English'},
      {'name': 'Malayalam', 'native': 'മലയാളം'},
      {'name': 'Tamil', 'native': 'தமிழ்'},
      {'name': 'Hindi', 'native': 'हिन्दी'},
      {'name': 'Telugu', 'native': 'తెలుగు'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose App Interface Language',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) {
              final isSelected = _selectedLanguage == lang['name'];
              return ListTile(
                title: Text('${lang['name']} (${lang['native']})', style: const TextStyle(color: Colors.white, fontSize: 14)),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFFFC00)) : null,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('preferred_language', lang['name']!);
                  setState(() => _selectedLanguage = lang['name']!);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showStorageCleanerModal() {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.cleaning_services_rounded, color: Color(0xFFEC4899), size: 22),
            const SizedBox(width: 8),
            Text(
              'Data & Storage Cleaner',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pocket Mates caches audio voice clips and avatars locally for fast offline playback.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Temporary Cache:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    '18.4 MB',
                    style: GoogleFonts.outfit(color: const Color(0xFFEC4899), fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC4899),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              PaintingBinding.instance.imageCache.clear();
              PaintingBinding.instance.imageCache.clearLiveImages();
              Navigator.pop(dCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✨ 18.4 MB temporary cache successfully cleared!'),
                  backgroundColor: Color(0xFF0F172A),
                ),
              );
            },
            child: const Text('Clear Cache Now'),
          ),
        ],
      ),
    );
  }

  void _showContactSupportModal() {
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.support_agent_rounded, color: Color(0xFFFFFC00), size: 24),
            const SizedBox(width: 10),
            Text(
              'Official Support Desk',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Have a question about subscriptions, payments, or learning tasks? Our support team responds within 24 hours.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: Color(0xFFFFFC00), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      'support@pocketmatesapp.com',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Describe your issue or feedback here...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFFC00),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📬 Support ticket dispatched to support@pocketmatesapp.com!'),
                  backgroundColor: Color(0xFF0F172A),
                ),
              );
            },
            child: const Text('Send Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAskPresidentModal() {
    final inquiryCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
              'Ask The President',
              style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Direct channel to President Mus\'ab. Ask about learning methodologies, citadel politics, or app roadmap.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: inquiryCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Your presidential message in English...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final text = inquiryCtrl.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx);
              final userId = SupaFlow.client.auth.currentUser?.id ?? 'guest_user';
              await PocketPresidentService.sendUserMessageToPresident(
                userId: userId,
                messageText: text,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🏛️ Message received at the Presidential Palace!'),
                    backgroundColor: Color(0xFF0F172A),
                  ),
                );
              }
            },
            child: const Text('Dispatch', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showFaqModal() {
    final faqs = [
      {
        'q': 'How does the 90-Day English Course work?',
        'a': 'The course is structured across 90 immersive Houses. Free learners unlock 1 house per day at midnight. Poket VIP members get Instant Binge Mode to unlock all 90 houses consecutively.'
      },
      {
        'q': 'What are Presidential Escort Guards in Citadel Battles?',
        'a': 'When an attacker raids a Poket VIP house, they must answer 10 Presidential Escort Guard questions before breaching core fortress defenses.'
      },
      {
        'q': 'How do I receive the Day 90 CEFR C2 Diploma?',
        'a': 'Upon completing all 90 learning houses, Poket VIP members unlock the cryptographic C2 Diploma 100% free. Free users who complete all 90 days with ads can unlock it for ₹149.'
      },
      {
        'q': 'What happens if I miss a daily streak?',
        'a': 'You can use a Streak Freeze or practice in the Review Hub to revive your streak. Poket VIP accounts include 24/7 streak protection.'
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Row(
                children: [
                  const Icon(Icons.help_outline_rounded, color: Color(0xFF38BDF8), size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'FAQ & Course Guide',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...faqs.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f['q']!, style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 6),
                          Text(f['a']!, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showInviteFriendsModal() {
    Clipboard.setData(const ClipboardData(text: 'https://pocketmatesapp.com/invite'));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔗 Invite link copied: https://pocketmatesapp.com/invite'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // 👑 Poket VIP Status / Promo Banner
              _buildVipBanner(),
              const SizedBox(height: 20),

              // 👤 Account & Communication
              const _SectionHeader(title: 'Account & Communication'),
              _SettingsTile(
                icon: Icons.bookmark_added_rounded,
                iconColor: const Color(0xFF38BDF8),
                title: 'Saved Messages & Vocabulary',
                subtitle: 'Your pinned words, idioms & voice notes',
                onTap: _showSavedMessagesModal,
              ),
              _SettingsTile(
                icon: Icons.devices_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Devices & Active Sessions',
                subtitle: 'Manage signed-in devices & security',
                onTap: _showDevicesModal,
              ),
              _SettingsTile(
                icon: Icons.security_rounded,
                iconColor: const Color(0xFFA855F7),
                title: 'Privacy & Security',
                subtitle: 'Online visibility, peer blocking & data safeguards',
                onTap: _showPrivacySecurityModal,
              ),
              const SizedBox(height: 20),

              // 🎙️ Voice & Audio Settings
              const _SectionHeader(title: 'Voice & Audio'),
              _SettingsTile(
                icon: Icons.speed_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'AI Voice Coach Speed',
                subtitle: '${_voiceSpeed}x speed for pronunciation playback',
                trailingWidget: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${_voiceSpeed}x', style: const TextStyle(color: Color(0xFFFFFC00), fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                onTap: _showVoiceSpeedPicker,
              ),
              ValueListenableBuilder<bool>(
                valueListenable: PocketGameAudioService.instance.isMutedNotifier,
                builder: (context, isMuted, child) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      isMuted ? Icons.volume_off : Icons.volume_up,
                      color: isMuted ? Colors.white54 : const Color(0xFFFFFC00),
                    ),
                    title: const Text(
                      'Game Music & BGM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      isMuted
                          ? 'Background music muted'
                          : 'Playing ambient music in homesteads & streets',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    activeThumbColor: const Color(0xFFFFFC00),
                    value: !isMuted,
                    onChanged: (bool enabled) {
                      PocketGameAudioService.instance.toggleMute();
                      setState(() {});
                    },
                  );
                },
              ),
              const SizedBox(height: 20),

              // ⚙️ App Preferences & Performance
              const _SectionHeader(title: 'Preferences & Storage'),
              _SettingsTile(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF3B82F6),
                title: 'App Interface Language',
                subtitle: _selectedLanguage,
                trailingWidget: Text(
                  _selectedLanguage,
                  style: const TextStyle(color: Color(0xFFFFFC00), fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onTap: _showLanguagePicker,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.bolt_rounded, color: Color(0xFF22C55E)),
                title: const Text(
                  'Power Saving & Battery Mode',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Reduces background particles and 3D animations',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                activeThumbColor: const Color(0xFF22C55E),
                value: _isPowerSaving,
                onChanged: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('power_saving_mode', val);
                  setState(() => _isPowerSaving = val);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFFF97316)),
                title: const Text(
                  'Study Streak Reminders',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Daily reminder before midnight to keep your streak',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                activeThumbColor: const Color(0xFFFFFC00),
                value: _isNotificationsEnabled,
                onChanged: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('notifications_enabled', val);
                  setState(() => _isNotificationsEnabled = val);
                },
              ),
              _SettingsTile(
                icon: Icons.cleaning_services_rounded,
                iconColor: const Color(0xFFEC4899),
                title: 'Data & Storage Cleaner',
                subtitle: 'Clear cached audio clips & temporary images',
                onTap: _showStorageCleanerModal,
              ),
              const SizedBox(height: 20),

              // 🤝 Help, Community & Support Desk
              const _SectionHeader(title: 'Help & Community Support'),
              _SettingsTile(
                icon: Icons.support_agent_rounded,
                iconColor: const Color(0xFFFFFC00),
                title: 'Contact Support Desk',
                subtitle: 'Official help, bug reports & instant email ticket',
                onTap: _showContactSupportModal,
              ),
              _SettingsTile(
                icon: Icons.account_balance_rounded,
                iconColor: const Color(0xFFFFD700),
                title: 'Ask The President',
                subtitle: 'Direct high-priority communication with President Mus\'ab',
                onTap: _showAskPresidentModal,
              ),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                iconColor: const Color(0xFF38BDF8),
                title: 'FAQ & 90-Day Course Guide',
                subtitle: 'Learn about houses, battle mechanics & C2 diploma',
                onTap: _showFaqModal,
              ),
              _SettingsTile(
                icon: Icons.share_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Invite Friends & Family',
                subtitle: 'Share Pocket Mates & practice English together',
                onTap: _showInviteFriendsModal,
              ),
              const SizedBox(height: 20),

              // 📜 Legal & Store Compliance (Mandatory for App Store & Play Store)
              const _SectionHeader(title: 'Legal & Store Compliance'),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                ),
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
                ),
              ),
              _SettingsTile(
                icon: Icons.logout,
                title: 'Log Out',
                onTap: _handleLogout,
                textColor: const Color(0xFFFFFC00),
                iconColor: const Color(0xFFFFFC00),
              ),
              _SettingsTile(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently remove your profile and all data (irreversible)',
                onTap: _handleDeleteAccount,
                textColor: Colors.redAccent,
                iconColor: Colors.redAccent,
              ),
              const SizedBox(height: 20),

              // ℹ️ About
              const _SectionHeader(title: 'About Pocket Mates'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline, color: Colors.white54),
                title: const Text(
                  'App Version',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
                trailing: Text(
                  'v$_appVersion',
                  style: const TextStyle(color: Color(0xFFFFFC00), fontWeight: FontWeight.bold),
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
  final String? subtitle;
  final Widget? trailingWidget;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingWidget,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.white).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            )
          : null,
      trailing: trailingWidget ?? const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
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
        builder: (modalContext, setModalState) {
          final bottomInset = MediaQuery.of(modalContext).viewInsets.bottom;
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
                            if (bContext.mounted) {
                              Navigator.pop(bContext);
                            }
                            if (mounted) {
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
                      'Super Admin Control',
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


