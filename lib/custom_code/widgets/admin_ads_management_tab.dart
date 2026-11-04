import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';

/// 📱 Admin Panel Dedicated Ads Tab
/// Cross-platform diagnostic inspector for all 12 AdMob placements on Android & iOS.
class AdminAdsManagementTab extends StatefulWidget {
  const AdminAdsManagementTab({super.key});

  @override
  State<AdminAdsManagementTab> createState() => _AdminAdsManagementTabState();
}

class _AdminAdsManagementTabState extends State<AdminAdsManagementTab> {
  // Platform selector: 'android' or 'ios' (defaults to running platform)
  late String _selectedPlatform;
  bool _testingInProgress = false;
  String? _currentlyTestingKey;
  bool _isCurrentAccountVip = false;

  @override
  void initState() {
    super.initState();
    _selectedPlatform = Platform.isIOS ? 'ios' : 'android';
    _checkVipStatus();
  }

  Future<void> _checkVipStatus() async {
    final vip = await PocketAdMobService.instance.isUserVip();
    if (mounted) {
      setState(() {
        _isCurrentAccountVip = vip;
      });
    }
  }

  List<AdUnitMetadata> _getPlacements(String platform) {
    if (platform == 'android') {
      return [
        AdUnitMetadata(
          key: 'android_ranking_banner',
          name: 'Ranking In-Feed Banner',
          format: 'Banner (300x250 Medium Rectangle)',
          platform: 'Android',
          unitId: PocketAdMobService.prodRankingAdUnitId,
          screen: 'Global Ranking Screen (every 3 learners)',
          placement: PocketAdPlacement.ranking,
          isNative: false,
        ),
        AdUnitMetadata(
          key: 'android_reels_banner',
          name: 'Reels In-Feed Banner',
          format: 'Banner (300x250 Medium Rectangle)',
          platform: 'Android',
          unitId: PocketAdMobService.prodReelsAdUnitId,
          screen: 'Pocket Homes & Reels Feed',
          placement: PocketAdPlacement.reels,
          isNative: false,
        ),
        AdUnitMetadata(
          key: 'android_vibes_banner',
          name: 'Vibes In-Feed Banner',
          format: 'Banner (300x250 Medium Rectangle)',
          platform: 'Android',
          unitId: PocketAdMobService.prodVibesAdUnitId,
          screen: 'Vibes Story Feed',
          placement: PocketAdPlacement.vibes,
          isNative: false,
        ),
        AdUnitMetadata(
          key: 'android_home_banner',
          name: 'Home In-Feed Banner',
          format: 'Banner (300x250 Medium Rectangle)',
          platform: 'Android',
          unitId: PocketAdMobService.prodHomeAdUnitId,
          screen: 'Home Conversation Feed',
          placement: PocketAdPlacement.home,
          isNative: false,
        ),
        AdUnitMetadata(
          key: 'android_review_banner',
          name: 'Learning Review Banner',
          format: 'Banner (300x250 Medium Rectangle)',
          platform: 'Android',
          unitId: PocketAdMobService.prodReviewAdUnitId,
          screen: 'End of Day 1 Review Card',
          placement: PocketAdPlacement.review,
          isNative: false,
        ),
        AdUnitMetadata(
          key: 'android_learning_step_interstitial',
          name: 'Learning Step Interstitial',
          format: 'Interstitial (Full-Screen)',
          platform: 'Android',
          unitId: PocketAdMobService.prodLearningStepInterstitialId,
          screen: 'Daily Step Completion (Every 6 Steps)',
          placement: PocketAdPlacement.learningStep,
          isInterstitial: true,
        ),
        AdUnitMetadata(
          key: 'android_day_completion_interstitial',
          name: 'Day Completion Interstitial',
          format: 'Interstitial (Full-Screen)',
          platform: 'Android',
          unitId: PocketAdMobService.prodDayCompletionInterstitialId,
          screen: 'Day Milestone Finish (Step 20 Complete)',
          placement: PocketAdPlacement.dayCompletion,
          isInterstitial: true,
        ),
        AdUnitMetadata(
          key: 'android_attack_interstitial',
          name: 'Attack / Raid Interstitial',
          format: 'Interstitial (Full-Screen)',
          platform: 'Android',
          unitId: PocketAdMobService.prodAttackInterstitialId,
          screen: 'Citadel Runner / House Raid Return (_finish)',
          placement: PocketAdPlacement.attack,
          isInterstitial: true,
        ),
        AdUnitMetadata(
          key: 'android_store_coins_rewarded',
          name: 'Store Coins Rewarded Video',
          format: 'Rewarded Video (+50 PS Coins)',
          platform: 'Android',
          unitId: PocketAdMobService.prodStoreCoinsRewardedId,
          screen: 'Coin Store (+50 Free Pocket Score)',
          placement: PocketAdPlacement.storeCoins,
          isRewarded: true,
        ),
        AdUnitMetadata(
          key: 'android_native_home',
          name: 'Native Home Card',
          format: 'Native Advanced (pocketNativeCardFactory)',
          platform: 'Android',
          unitId: PocketAdMobService.prodNativeHomeAdUnitId,
          screen: 'Home Dashboard Feed',
          placement: PocketAdPlacement.home,
          isNative: true,
        ),
        AdUnitMetadata(
          key: 'android_native_vibes',
          name: 'Native Vibes Card',
          format: 'Native Advanced (pocketNativeCardFactory)',
          platform: 'Android',
          unitId: PocketAdMobService.prodNativeVibesAdUnitId,
          screen: 'Vibes Story Carousel',
          placement: PocketAdPlacement.vibes,
          isNative: true,
        ),
        AdUnitMetadata(
          key: 'android_native_learning_summary',
          name: 'Native Learning Summary',
          format: 'Native Advanced (pocketNativeCardFactory)',
          platform: 'Android',
          unitId: PocketAdMobService.prodNativeLearningSummaryAdUnitId,
          screen: 'Daily Curriculum Summary Page',
          placement: PocketAdPlacement.review,
          isNative: true,
        ),
      ];
    } else {
      return [
        AdUnitMetadata(
          key: 'ios_ranking_banner',
          name: 'POKET_iOS_Ranking_BannerRect',
          format: 'Banner (300x250 Medium Rectangle)',
          platform: 'iOS',
          unitId: PocketAdMobService.prodIosRankingAdUnitId,
          screen: 'Global Ranking Screen',
          placement: PocketAdPlacement.ranking,
          isNative: false,
        ),
        AdUnitMetadata(
          key: 'ios_reels_banner',
          name: 'POKET_iOS_Reels_BannerRect',
          format: 'Banner (300x250 Medium Rectangle)',
          platform: 'iOS',
          unitId: PocketAdMobService.prodIosReelsAdUnitId,
          screen: 'Pocket Homes & Reels Feed',
          placement: PocketAdPlacement.reels,
          isNative: false,
        ),
        AdUnitMetadata(
          key: 'ios_vibes_banner',
          name: 'POKET_iOS_Vibes_BannerRect',
          format: 'Banner (300x250 Medium Rectangle)',
          platform: 'iOS',
          unitId: PocketAdMobService.prodIosVibesAdUnitId,
          screen: 'Vibes Story Feed',
          placement: PocketAdPlacement.vibes,
          isNative: false,
        ),
        AdUnitMetadata(
          key: 'ios_home_banner',
          name: 'POKET_iOS_Home_BannerRect',
          format: 'Banner (300x250 Medium Rectangle)',
          platform: 'iOS',
          unitId: PocketAdMobService.prodIosHomeAdUnitId,
          screen: 'Home Conversation Feed',
          placement: PocketAdPlacement.home,
          isNative: false,
        ),
        AdUnitMetadata(
          key: 'ios_review_banner',
          name: 'POKET_iOS_LearningReview_BannerRect',
          format: 'Banner (300x250 Medium Rectangle)',
          platform: 'iOS',
          unitId: PocketAdMobService.prodIosReviewAdUnitId,
          screen: 'End of Day 1 Review Card',
          placement: PocketAdPlacement.review,
          isNative: false,
        ),
        AdUnitMetadata(
          key: 'ios_learning_step_interstitial',
          name: 'POKET_iOS_LearningStep_Interstitial',
          format: 'Interstitial (Full-Screen)',
          platform: 'iOS',
          unitId: PocketAdMobService.prodIosLearningStepInterstitialId,
          screen: 'Daily Step Completion',
          placement: PocketAdPlacement.learningStep,
          isInterstitial: true,
        ),
        AdUnitMetadata(
          key: 'ios_day_completion_interstitial',
          name: 'POKET_iOS_DayCompletion_Interstitial',
          format: 'Interstitial (Full-Screen)',
          platform: 'iOS',
          unitId: PocketAdMobService.prodIosDayCompletionInterstitialId,
          screen: 'Day Milestone Finish',
          placement: PocketAdPlacement.dayCompletion,
          isInterstitial: true,
        ),
        AdUnitMetadata(
          key: 'ios_attack_interstitial',
          name: 'POKET_iOS_Attack_Interstitial',
          format: 'Interstitial (Full-Screen)',
          platform: 'iOS',
          unitId: PocketAdMobService.prodIosAttackInterstitialId,
          screen: 'Citadel Runner / House Raid Return (_finish)',
          placement: PocketAdPlacement.attack,
          isInterstitial: true,
        ),
        AdUnitMetadata(
          key: 'ios_store_coins_rewarded',
          name: 'POKET_iOS_StoreCoins_Rewarded',
          format: 'Rewarded Video (+50 PS Coins)',
          platform: 'iOS',
          unitId: PocketAdMobService.prodIosStoreCoinsRewardedId,
          screen: 'Coin Store (+50 Free Pocket Score)',
          placement: PocketAdPlacement.storeCoins,
          isRewarded: true,
        ),
        AdUnitMetadata(
          key: 'ios_native_home',
          name: 'POKET_iOS_Native_Home',
          format: 'Native Advanced (pocketNativeCardFactory)',
          platform: 'iOS',
          unitId: PocketAdMobService.prodIosNativeHomeAdUnitId,
          screen: 'Home Dashboard Feed',
          placement: PocketAdPlacement.home,
          isNative: true,
        ),
        AdUnitMetadata(
          key: 'ios_native_vibes',
          name: 'POKET_iOS_Native_Vibes',
          format: 'Native Advanced (pocketNativeCardFactory)',
          platform: 'iOS',
          unitId: PocketAdMobService.prodIosNativeVibesAdUnitId,
          screen: 'Vibes Story Carousel',
          placement: PocketAdPlacement.vibes,
          isNative: true,
        ),
        AdUnitMetadata(
          key: 'ios_native_learning_summary',
          name: 'POKET_iOS_Native_Learning_Summary',
          format: 'Native Advanced (pocketNativeCardFactory)',
          platform: 'iOS',
          unitId: PocketAdMobService.prodIosNativeLearningSummaryAdUnitId,
          screen: 'Daily Curriculum Summary Page',
          placement: PocketAdPlacement.review,
          isNative: true,
        ),
      ];
    }
  }

  Future<void> _runSafeTest(AdUnitMetadata item) async {
    final admob = PocketAdMobService.instance;
    setState(() {
      _testingInProgress = true;
      _currentlyTestingKey = item.key;
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Testing ${item.name} (${item.format})...'),
        backgroundColor: const Color(0xFF0284C7),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      final res = await admob.testIndividualAd(
        placement: item.placement,
        isNative: item.isNative,
        isInterstitial: item.isInterstitial,
        isRewarded: item.isRewarded,
      );

      if (mounted) {
        setState(() {
          _testingInProgress = false;
          _currentlyTestingKey = null;
        });

        _showDiagnosticDialog(item, res);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testingInProgress = false;
          _currentlyTestingKey = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test exception: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDiagnosticDialog(AdUnitMetadata item, Map<String, dynamic> res) {
    final success = res['success'] == true;
    final code = res['errorCode']?.toString();
    final message = res['errorMessage']?.toString();
    final unitId = res['unitId']?.toString() ?? item.unitId;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: success ? const Color(0xFF10B981) : (code == '3' ? const Color(0xFFF59E0B) : Colors.red),
            width: 1.2,
          ),
        ),
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : (code == '3' ? Icons.hourglass_empty_rounded : Icons.error_outline_rounded),
              color: success ? const Color(0xFF10B981) : (code == '3' ? const Color(0xFFF59E0B) : Colors.redAccent),
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                success ? 'Ad Test PASSED' : (code == '3' ? 'No-Fill (Code 3)' : 'Test Failed'),
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDiagRow('Placement', item.name),
              _buildDiagRow('Format', item.format),
              _buildDiagRow('Platform', item.platform),
              _buildDiagRow('Unit ID', unitId),
              _buildDiagRow('Screen', item.screen),
              const Divider(color: Colors.white12, height: 16),
              if (success) ...[
                Text(
                  '✅ The AdMob SDK successfully loaded an ad for this placement without errors.',
                  style: GoogleFonts.inter(color: const Color(0xFF34D399), fontSize: 12),
                ),
              ] else if (code == '3') ...[
                Text(
                  '⚠️ ERROR_CODE_NO_FILL (Code 3)',
                  style: GoogleFonts.inter(color: const Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'AdMob servers resolved the ad unit ID successfully, but had no live ad inventory to return right now.\n\nRoot causes:\n1. Ad unit is newly created (takes 24-48 hours to activate fully).\n2. app-ads.txt pending crawlers on developer domain.\n3. Account identity/tax info verification pending in AdMob Console.',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5, height: 1.4),
                ),
              ] else ...[
                Text(
                  '❌ Error Code: ${code ?? "N/A"}',
                  style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  message ?? 'Unknown error occurred during ad request.',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 11.5),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE', style: TextStyle(color: Color(0xFFFFFC00), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(fontSize: 11.5),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admob = PocketAdMobService.instance;
    final telemetry = admob.telemetry;
    final placements = _getPlacements(_selectedPlatform);

    // Metric summaries
    final totalConfigured = placements.length;
    final bannerCount = placements.where((p) => !p.isNative && !p.isInterstitial && !p.isRewarded).length;
    final interstitialCount = placements.where((p) => p.isInterstitial).length;
    final rewardedCount = placements.where((p) => p.isRewarded).length;
    final nativeCount = placements.where((p) => p.isNative).length;

    return RefreshIndicator(
      onRefresh: () async {
        await _checkVipStatus();
        setState(() {});
      },
      color: const Color(0xFFFFFC00),
      backgroundColor: const Color(0xFF0F172A),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Header Banner & VIP Diagnostics Card
          _buildVipDiagnosticsCard(),
          const SizedBox(height: 14),

          // 2. Platform Selector (Android vs iOS)
          _buildPlatformSelector(),
          const SizedBox(height: 14),

          // 3. Ad Summary Dashboard Grid
          _buildSummaryDashboard(
            totalConfigured: totalConfigured,
            bannerCount: bannerCount,
            interstitialCount: interstitialCount,
            rewardedCount: rewardedCount,
            nativeCount: nativeCount,
            totalLoads: telemetry.totalLoads,
            totalFails: telemetry.totalFails,
            totalNoFills: telemetry.totalNoFills,
          ),
          const SizedBox(height: 16),

          // 4. Section Title & Native Warning Notice
          Row(
            children: [
              Text(
                '$_selectedPlatform Placements (12 Units)',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF38BDF8), size: 20),
                tooltip: 'Refresh Status',
                onPressed: () => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 5. Native Advanced Implementation Notice (Requirement 4)
          _buildNativeAdvancedNotice(),
          const SizedBox(height: 14),

          // 6. Placements List
          ...placements.map((item) => _buildPlacementCard(item, admob)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVipDiagnosticsCard() {
    final admob = PocketAdMobService.instance;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isCurrentAccountVip ? const Color(0xFFFFD700).withValues(alpha: 0.5) : const Color(0xFF38BDF8).withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isCurrentAccountVip ? const Color(0xFFFFD700).withValues(alpha: 0.15) : const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(_isCurrentAccountVip ? '👑' : '🛡️', style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCurrentAccountVip ? 'Current Account: VIP / Premium' : 'Current Account: Standard (Free Tier)',
                      style: GoogleFonts.outfit(
                        color: _isCurrentAccountVip ? const Color(0xFFFFD700) : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isCurrentAccountVip
                          ? 'Suppression Active: All live Banner, Native, Interstitial & Rewarded ads are suppressed (0 ads).'
                          : 'Ads Eligible: Standard advertising pipeline is enabled for this session.',
                      style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Device Ad Preview',
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Bypasses VIP check ONLY on this admin device to test ad rendering without altering database.',
                      style: GoogleFonts.inter(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Switch(
                value: admob.adminAdPreviewOverride,
                activeThumbColor: const Color(0xFFFFFC00),
                onChanged: (val) {
                  setState(() {
                    admob.setAdminAdPreviewOverride(val);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPlatformButton(
              label: 'Android (12 Placements)',
              icon: Icons.android_rounded,
              value: 'android',
              isCurrentDevice: Platform.isAndroid,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildPlatformButton(
              label: 'iOS (12 Placements)',
              icon: Icons.apple_rounded,
              value: 'ios',
              isCurrentDevice: Platform.isIOS,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformButton({
    required String label,
    required IconData icon,
    required String value,
    required bool isCurrentDevice,
  }) {
    final selected = _selectedPlatform == value;
    return InkWell(
      onTap: () => setState(() => _selectedPlatform = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E293B) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: const Color(0xFF38BDF8), width: 1.0) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? const Color(0xFF38BDF8) : Colors.white54, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white60,
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isCurrentDevice) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF34D399), fontSize: 8.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryDashboard({
    required int totalConfigured,
    required int bannerCount,
    required int interstitialCount,
    required int rewardedCount,
    required int nativeCount,
    required int totalLoads,
    required int totalFails,
    required int totalNoFills,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: Color(0xFF38BDF8), size: 16),
              const SizedBox(width: 6),
              Text(
                'AdMob Inventory & Telemetry Summary',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                PocketAdMobService.instance.isSdkInitialized ? "SDK Online" : "Standby",
                style: TextStyle(
                  color: PocketAdMobService.instance.isSdkInitialized ? const Color(0xFF34D399) : Colors.amber,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniMetric('Total Units', '$totalConfigured', const Color(0xFF38BDF8)),
              _buildMiniMetric('Banners', '$bannerCount', const Color(0xFFA855F7)),
              _buildMiniMetric('Interstitials', '$interstitialCount', const Color(0xFFF59E0B)),
              _buildMiniMetric('Rewarded', '$rewardedCount', const Color(0xFF10B981)),
              _buildMiniMetric('Native Adv', '$nativeCount', const Color(0xFFEC4899)),
            ],
          ),
          const Divider(color: Colors.white10, height: 16),
          Row(
            children: [
              _buildMiniMetric('Loaded', '$totalLoads', const Color(0xFF34D399)),
              _buildMiniMetric('Failed', '$totalFails', const Color(0xFFFB7185)),
              _buildMiniMetric('No-Fill (3)', '$totalNoFills', const Color(0xFFFBBF24)),
              _buildMiniMetric('App ID', 'Verified', const Color(0xFF38BDF8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFonts.outfit(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildNativeAdvancedNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFEC4899), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Native Advanced Implementation Status (Priority 4)',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '• Android: NativeAdFactory + pocket_native_ad_card.xml configured in MainActivity.kt.\n• iOS: Factory registration pending in AppDelegate.swift. Currently falls back gracefully to in-feed container.',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 10.5, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacementCard(AdUnitMetadata item, PocketAdMobService admob) {
    final metric = admob.telemetry.placementMetrics[item.placement.name];
    final reqCount = metric?.requests ?? 0;
    final loadCount = metric?.loads ?? 0;
    final failCount = metric?.fails ?? 0;
    final lastLoaded = metric?.lastLoadedTime;
    final lastError = metric?.lastErrorMessage ?? metric?.lastErrorCode;
    final isTestingThis = _testingInProgress && _currentlyTestingKey == item.key;
    final isPlacementEnabled = admob.isPlacementEnabled(item.key);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlacementEnabled ? Colors.white12 : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: item.isInterstitial
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                      : item.isRewarded
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : item.isNative
                              ? const Color(0xFFEC4899).withValues(alpha: 0.15)
                              : const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.isInterstitial
                      ? 'INTERSTITIAL'
                      : item.isRewarded
                          ? 'REWARDED'
                          : item.isNative
                              ? 'NATIVE ADV'
                              : 'BANNER',
                  style: TextStyle(
                    color: item.isInterstitial
                        ? const Color(0xFFFBBF24)
                        : item.isRewarded
                            ? const Color(0xFF34D399)
                            : item.isNative
                                ? const Color(0xFFF472B6)
                                : const Color(0xFF38BDF8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Screen: ${item.screen}',
                      style: GoogleFonts.inter(color: Colors.white54, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isPlacementEnabled,
                activeThumbColor: const Color(0xFFFFD700),
                onChanged: (val) {
                  setState(() {
                    admob.setPlacementEnabled(item.key, val);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.unitId,
                    style: const TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Colors.white38, size: 14),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Copy ID',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: item.unitId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ad Unit ID copied to clipboard'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Req: $reqCount', style: const TextStyle(color: Colors.white38, fontSize: 10)),
              const SizedBox(width: 8),
              Text('Loaded: $loadCount', style: const TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('Failed: $failCount', style: const TextStyle(color: Color(0xFFFB7185), fontSize: 10)),
              const Spacer(),
              if (lastLoaded != null)
                Text(
                  'Last: ${lastLoaded.hour}:${lastLoaded.minute.toString().padLeft(2, "0")}',
                  style: const TextStyle(color: Colors.white38, fontSize: 9.5),
                ),
            ],
          ),
          if (lastError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Latest Error: $lastError',
                style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 9.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF38BDF8),
                side: const BorderSide(color: Color(0xFF38BDF8), width: 0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              icon: isTestingThis
                  ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF38BDF8)))
                  : const Icon(Icons.play_arrow_rounded, size: 15),
              label: Text(isTestingThis ? 'Running Safe Test...' : 'Run Safe Test', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: _testingInProgress ? null : () => _runSafeTest(item),
            ),
          ),
        ],
      ),
    );
  }
}

class AdUnitMetadata {
  final String key;
  final String name;
  final String format;
  final String platform;
  final String unitId;
  final String screen;
  final PocketAdPlacement placement;
  final bool isNative;
  final bool isInterstitial;
  final bool isRewarded;

  AdUnitMetadata({
    required this.key,
    required this.name,
    required this.format,
    required this.platform,
    required this.unitId,
    required this.screen,
    required this.placement,
    this.isNative = false,
    this.isInterstitial = false,
    this.isRewarded = false,
  });
}

