import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '/backend/supabase/supabase.dart';

/// 🚀 Clean, Minimalist In-App Version & Remote Update Service
///
/// Directives:
/// - Strictly active on Android and iOS ONLY. Never show on Windows desktop, macOS, Linux, or Web!
/// - Triggers ONLY when an update is actively enabled in Supabase/Admin Panel and the app version is older.
/// - Apple / Instagram level clean, minimal, non-cluttered design.
/// - 1st launch: dismissible with sleek close button / 'Later'.
/// - 2nd launch onwards: force update mode (cannot bypass without updating).
class PocketAppUpdateService {
  static final PocketAppUpdateService instance = PocketAppUpdateService._internal();
  factory PocketAppUpdateService() => instance;
  PocketAppUpdateService._internal();

  static const String defaultAndroidPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.poketmates.app&pcampaignid=web_share';
  static const String defaultIosStoreUrl = '';

  static const String _kPromptCountPrefix = 'update_prompt_count_v_';

  /// Check for update on app startup (Mobile ONLY)
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      // 🛡️ CRITICAL GUARD: Only run on real mobile devices (Android & iOS).
      // Never show on Windows desktop, macOS, Linux, or Web!
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "1.0.139"
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

      // 1. Fetch remote update data from Supabase `app_updates` (row id = 1)
      final updateInfo = await _fetchRemoteVersionInfo();
      if (updateInfo.isEmpty) return; // Not enabled or no remote update published

      final String remoteVersion = updateInfo['latest_version'] ?? currentVersion;
      final int remoteBuild = int.tryParse(updateInfo['latest_build']?.toString() ?? '0') ?? currentBuild;
      final String releaseNotes = updateInfo['release_notes'] ?? '';
      final bool forceUpdateFromRemote = updateInfo['force_update'] == true;
      final String storeUrl = (Platform.isIOS)
          ? (updateInfo['ios_url'] ?? defaultIosStoreUrl)
          : (updateInfo['android_url'] ?? defaultAndroidPlayStoreUrl);

      // 2. Strict version comparison
      final bool hasNewerVersion = _isVersionOutdated(
        currentVersion: currentVersion,
        currentBuild: currentBuild,
        remoteVersion: remoteVersion,
        remoteBuild: remoteBuild,
      );

      if (!hasNewerVersion) {
        return; // Already up to date! Never show dialog.
      }

      // 3. Prompt history counter
      final prefs = await SharedPreferences.getInstance();
      final promptKey = '$_kPromptCountPrefix$remoteVersion';
      final promptCount = prefs.getInt(promptKey) ?? 0;

      // 1st time has dismiss button; 2nd launch onwards becomes mandatory force update
      final bool isMandatory = forceUpdateFromRemote || (promptCount >= 1);

      await prefs.setInt(promptKey, promptCount + 1);

      if (!context.mounted) return;

      // 4. Show the minimal, sleek Update Dialog
      await showDialog(
        context: context,
        barrierDismissible: !isMandatory,
        builder: (dlgCtx) => PopScope(
          canPop: !isMandatory,
          child: _MinimalUpdateDialog(
            currentVersion: currentVersion,
            latestVersion: remoteVersion,
            releaseNotes: releaseNotes,
            storeUrl: storeUrl,
            isMandatory: isMandatory,
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) print('PocketAppUpdateService checkForUpdate error: $e');
    }
  }

  /// Version comparison helper
  static bool _isVersionOutdated({
    required String currentVersion,
    required int currentBuild,
    required String remoteVersion,
    required int remoteBuild,
  }) {
    if (remoteVersion.isEmpty || remoteVersion == currentVersion) return false;

    if (remoteBuild > currentBuild && currentBuild > 0) return true;

    final currParts = currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final remParts = remoteVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final curr = (i < currParts.length) ? currParts[i] : 0;
      final rem = (i < remParts.length) ? remParts[i] : 0;
      if (rem > curr) return true;
      if (rem < curr) return false;
    }
    return false;
  }

  /// Fetch version info from Supabase `app_updates` table (row id = 1)
  static Future<Map<String, dynamic>> _fetchRemoteVersionInfo() async {
    try {
      final res = await SupaFlow.client
          .from('app_updates')
          .select('*')
          .eq('id', 1)
          .maybeSingle();

      if (res != null) {
        final isIos = Platform.isIOS;
        final bool isActive = isIos
            ? (res['ios_active'] == true)
            : (res['android_active'] == true);

        // If admin hasn't activated it, return empty so no update dialog appears
        if (!isActive) return {};

        final remoteVer = isIos
            ? (res['ios_version']?.toString().trim() ?? '')
            : (res['android_version']?.toString().trim() ?? '');

        if (remoteVer.isEmpty) return {};

        final rawStoreLink = isIos ? res['ios_link'] : res['android_link'];
        final storeLink = (rawStoreLink != null && rawStoreLink.toString().trim().isNotEmpty)
            ? rawStoreLink.toString().trim()
            : (isIos ? defaultIosStoreUrl : defaultAndroidPlayStoreUrl);

        final desc = res['description']?.toString().trim() ?? '';
        final featuresList = res['features'];
        String formattedNotes = desc;
        if (featuresList is List && featuresList.isNotEmpty) {
          final items = featuresList.map((f) => '• $f').join('\n');
          formattedNotes = formattedNotes.isNotEmpty ? '$formattedNotes\n\n$items' : items;
        }

        return {
          'latest_version': remoteVer,
          'latest_build': 0,
          'release_notes': formattedNotes.isNotEmpty
              ? formattedNotes
              : 'Bug fixes, performance improvements, and new features.',
          'force_update': res['is_mandatory'] == true,
          'android_url': storeLink,
          'ios_url': isIos ? storeLink : defaultIosStoreUrl,
        };
      }
    } catch (_) {}

    return {}; // If offline or table not configured, do not show any dialog!
  }
}

/// 🎨 Ultra-Minimal, Sleek Standard In-App Update Dialog (Instagram / iOS Standard)
class _MinimalUpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;
  final String storeUrl;
  final bool isMandatory;

  const _MinimalUpdateDialog({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseNotes,
    required this.storeUrl,
    required this.isMandatory,
  });

  Future<void> _launchStore() async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse(storeUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: const Color(0xFF141720),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Tag Pill & Close Icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFC00).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
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
                        const SizedBox(width: 6),
                        Text(
                          'UPDATE AVAILABLE',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFFC00),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!isMandatory)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white54,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Title & Subtitle
              Text(
                'Version $latestVersion is here',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Please update to keep enjoying a smooth and bug-free experience.',
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Minimal Release Notes Card
              if (releaseNotes.trim().isNotEmpty) ...[
                Container(
                  constraints: const BoxConstraints(maxHeight: 160),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1F2A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      releaseNotes,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.5,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Primary Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFFC00),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _launchStore,
                  child: Text(
                    'Update App Now',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              // Optional Later Button
              if (!isMandatory) ...[
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Not Now',
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
