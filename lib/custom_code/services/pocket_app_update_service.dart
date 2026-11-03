import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_release_service.dart';

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
      final currentVersion = packageInfo.version; // e.g. "1.0.155"
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
      final platform = Platform.isIOS ? 'ios' : 'android';

      // 1. Fetch active production release for current platform from PocketReleaseService
      final activeRelease = await PocketReleaseService.fetchActiveProductionRelease(platform);
      if (activeRelease == null) return; // No active release configured

      final String remoteVersion = activeRelease.version;
      final int remoteBuild = activeRelease.buildNumber;
      final bool forceUpdateFromRemote = activeRelease.isMandatory;
      final String storeUrl = (activeRelease.storeUrl != null && activeRelease.storeUrl!.trim().isNotEmpty)
          ? activeRelease.storeUrl!.trim()
          : (Platform.isIOS ? defaultIosStoreUrl : defaultAndroidPlayStoreUrl);

      // 2. Strict version comparison
      final bool hasNewerVersion = PocketReleaseService.isInstalledBuildOutdated(
        currentVersion: currentVersion,
        currentBuild: currentBuild,
        targetVersion: remoteVersion,
        targetBuild: remoteBuild,
      );

      if (!hasNewerVersion) {
        return; // Installed version is equal to or newer than target production! Never prompt.
      }

      // 3. Prompt history counter
      final prefs = await SharedPreferences.getInstance();
      final promptKey = '$_kPromptCountPrefix${remoteVersion}_$remoteBuild';
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
            releaseRecord: activeRelease,
            storeUrl: storeUrl,
            isMandatory: isMandatory,
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) print('PocketAppUpdateService checkForUpdate error: $e');
    }
  }

  /// Version comparison helper (Legacy proxy)
  static bool isVersionOutdated({
    required String currentVersion,
    required int currentBuild,
    required String remoteVersion,
    required int remoteBuild,
  }) {
    return PocketReleaseService.isInstalledBuildOutdated(
      currentVersion: currentVersion,
      currentBuild: currentBuild,
      targetVersion: remoteVersion,
      targetBuild: remoteBuild,
    );
  }
}

/// 🎨 Ultra-Minimal, Sleek Standard In-App Update Dialog (Instagram / iOS Standard)
class _MinimalUpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final AppReleaseRecord releaseRecord;
  final String storeUrl;
  final bool isMandatory;

  const _MinimalUpdateDialog({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseRecord,
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
    final title = releaseRecord.releaseTitle.isNotEmpty
        ? releaseRecord.releaseTitle
        : 'Version $latestVersion is here';
    final notes = releaseRecord.releaseNotes.trim();
    final hasFeatures = releaseRecord.features.isNotEmpty;
    final hasImprovements = releaseRecord.improvements.isNotEmpty;
    final hasBugFixes = releaseRecord.bugFixes.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
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
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version $latestVersion (${releaseRecord.buildNumber}) is now ready on the store.',
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Minimal Release Notes & Highlights Card
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notes.isNotEmpty) ...[
                          Text(
                            notes,
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12.5,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (hasFeatures) ...[
                          Text(
                            '✨ NEW FEATURES',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFFC00),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...releaseRecord.features.map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  Expanded(
                                    child: Text(
                                      f,
                                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (hasImprovements) ...[
                          Text(
                            '⚡ IMPROVEMENTS',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF00FFC2),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...releaseRecord.improvements.map(
                            (imp) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  Expanded(
                                    child: Text(
                                      imp,
                                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (hasBugFixes) ...[
                          Text(
                            '🛠️ BUG FIXES',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...releaseRecord.bugFixes.map(
                            (fix) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  Expanded(
                                    child: Text(
                                      fix,
                                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

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
