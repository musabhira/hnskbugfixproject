import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/widgets/subscription_page.dart';

/// Placement types for AdMob units across Pocket Mates
enum PocketAdPlacement {
  ranking,
  reels,
  vibes,
  home,
  review,
  learningStep,
  dayCompletion,
  attack,
  storeCoins,
}

/// 📊 Real-time AdMob Telemetry & Event Model
class PocketAdPlacementMetric {
  int requests = 0;
  int loads = 0;
  int fails = 0;
  int noFills = 0;
  int impressions = 0;
  DateTime? lastLoadedTime;
  DateTime? lastFailedTime;
  String? lastErrorCode;
  String? lastErrorMessage;

  Map<String, dynamic> toJson() => {
        'requests': requests,
        'loads': loads,
        'fails': fails,
        'noFills': noFills,
        'impressions': impressions,
        'lastLoadedTime': lastLoadedTime?.toIso8601String(),
        'lastFailedTime': lastFailedTime?.toIso8601String(),
        'lastErrorCode': lastErrorCode,
        'lastErrorMessage': lastErrorMessage,
      };

  void fromJson(Map<String, dynamic> map) {
    requests = (map['requests'] as num?)?.toInt() ?? 0;
    loads = (map['loads'] as num?)?.toInt() ?? 0;
    fails = (map['fails'] as num?)?.toInt() ?? 0;
    noFills = (map['noFills'] as num?)?.toInt() ?? 0;
    impressions = (map['impressions'] as num?)?.toInt() ?? 0;
    if (map['lastLoadedTime'] != null) {
      lastLoadedTime = DateTime.tryParse(map['lastLoadedTime'].toString());
    }
    if (map['lastFailedTime'] != null) {
      lastFailedTime = DateTime.tryParse(map['lastFailedTime'].toString());
    }
    lastErrorCode = map['lastErrorCode']?.toString();
    lastErrorMessage = map['lastErrorMessage']?.toString();
  }
}

class PocketAdTelemetryData {
  bool sdkInitialized = false;
  DateTime? sdkInitTime;
  int totalRequests = 0;
  int totalLoads = 0;
  int totalFails = 0;
  int totalNoFills = 0;
  int totalImpressions = 0;
  DateTime? lastSuccessTime;
  DateTime? lastFailureTime;
  String? latestErrorCode;
  String? latestErrorMessage;
  String? latestErrorPlacement;
  Map<String, PocketAdPlacementMetric> placementMetrics = {};

  double get fillRatePercent {
    if (totalRequests == 0) return 0.0;
    return (totalLoads / totalRequests) * 100.0;
  }
}

/// 💎 Central Google AdMob Service for Pocket Mates
/// 
/// User Directives:
/// - "ആഡ് എവിടെയൊക്കെ ഇമ്പ്ലിമെന്റ് ചെയ്യാൻ പറ്റുമോ അവിടെയൊക്കെ ഇമ്പ്ലിമെന്റ് ചെയ്യുക."
/// - "നേറ്റീവ് ആഡ് നല്ല രീതിയിൽ പ്ലേസ് ചെയ്യുക (Instagram standard)."
/// - "റിവാർഡ് വീഡിയോസ്: ഓരോ ഡേ കംപ്ലീറ്റ് ചെയ്യുമ്പോൾ ലാസ്റ്റ് കൊടുക്കണം."
/// - "വിഐപി ടിക്കറ്റ് എടുത്ത ആൾക്കാർക്ക് ആപ്പിൽ നിന്ന് ഒരു കാരണവശാലും ആഡ് കാണിക്കരുത്. വിഐപി എടുത്തു കഴിഞ്ഞാൽ ഫുൾ ആഡ് റിമൂവ് ആവണം."
/// - "ഡെമോ എനിക്ക് നോക്കണം, ഫസ്റ്റ് ഡെമോ പാസ്സാക്കുകയും വേണം, എന്നാൽ മാത്രമേ എനിക്ക് ടെസ്റ്റ് ചെയ്തു നോക്കാൻ പറ്റുകയുള്ളൂ."
class PocketAdMobService {
  static final PocketAdMobService instance = PocketAdMobService._internal();
  factory PocketAdMobService() => instance;
  PocketAdMobService._internal();

  bool _isInitialized = false;
  bool? _overrideTestMode;
  // Environment Policy:
  // - Android Release builds (Production APK / Play Store): Test mode OFF, verified production Ad Unit IDs.
  // - Android Debug / Profile mode: Test mode ON (Google sample test ad units).
  // - iOS Simulator / non-Android platforms: Test mode ON (safe test mode to avoid violations).
  bool get _isTestMode {
    if (_overrideTestMode != null) return _overrideTestMode!;
    if (kIsWeb || !Platform.isAndroid) return true;
    return !kReleaseMode;
  }

  // 🆔 AdMob App IDs
  static const String androidAppId = 'ca-app-pub-8489571803367790~4762910426';
  static const String iosAppId = 'ca-app-pub-8489571803367790~4762910426';

  // 🎯 Google Official Safe Test Ad Unit IDs (Immediate testing without account bans)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String testNativeId = 'ca-app-pub-3940256099942544/2247696110';

  // 🚀 Production Ad Unit IDs for publisher pub-8489571803367790
  // Banner / Medium Rectangle In-Feed Units (300x250)
  static String prodRankingAdUnitId = 'ca-app-pub-8489571803367790/3184855433';
  static String prodReelsAdUnitId = 'ca-app-pub-8489571803367790/2266138392';
  static String prodVibesAdUnitId = 'ca-app-pub-8489571803367790/6045776312';
  static String prodHomeAdUnitId = 'ca-app-pub-8489571803367790/2521464274';
  static String prodReviewAdUnitId = 'ca-app-pub-8489571803367790/5846290758';

  // 🌟 Dedicated Native Advanced Ad Units
  static String prodNativeHomeAdUnitId = 'ca-app-pub-8489571803367790/7490544913';
  static String prodNativeVibesAdUnitId = 'ca-app-pub-8489571803367790/2725690431';
  static String prodNativeLearningSummaryAdUnitId = 'ca-app-pub-8489571803367790/5519374733';
  static String prodNativeRankingAdUnitId = 'ca-app-pub-8489571803367790/7490544913';

  // Interstitial Ad Units
  static String prodLearningStepInterstitialId = 'ca-app-pub-8489571803367790/1304410512';
  static String prodDayCompletionInterstitialId = 'ca-app-pub-8489571803367790/9793449634';
  static String prodAttackInterstitialId = 'ca-app-pub-8489571803367790/6110401679';

  // Rewarded Ad Units
  static String prodStoreCoinsRewardedId = 'ca-app-pub-8489571803367790/9802234672';

  // Fallbacks / Legacy accessors
  static String get prodNativeAdUnitId => prodNativeHomeAdUnitId;
  static set prodNativeAdUnitId(String val) => prodNativeHomeAdUnitId = val;
  static String get prodRewardedAdUnitId => prodStoreCoinsRewardedId;
  static set prodRewardedAdUnitId(String val) => prodStoreCoinsRewardedId = val;
  static String get prodInterstitialAdUnitId => prodDayCompletionInterstitialId;
  static set prodInterstitialAdUnitId(String val) => prodDayCompletionInterstitialId = val;
  static String get prodBannerAdUnitId => prodHomeAdUnitId;
  static set prodBannerAdUnitId(String val) => prodHomeAdUnitId = val;

  // ⚙️ Dynamic Learning Journey Ad Configuration
  static int stepNativeAdFrequency = 4; // Show native ad card after every 4 steps
  static int interstitialStepFrequency = 6; // Show interstitial after every 6 steps completed
  static bool enableLearningBannerAds = true;
  static bool enableDailySummaryReviewAd = true;

  /// Returns the ad unit ID for a specific placement, respecting release vs test mode
  String getUnitIdForPlacement(PocketAdPlacement placement) {
    if (_isTestMode) {
      switch (placement) {
        case PocketAdPlacement.ranking:
        case PocketAdPlacement.reels:
        case PocketAdPlacement.vibes:
        case PocketAdPlacement.home:
        case PocketAdPlacement.review:
          return _testBannerId;
        case PocketAdPlacement.learningStep:
        case PocketAdPlacement.dayCompletion:
        case PocketAdPlacement.attack:
          return _testInterstitialId;
        case PocketAdPlacement.storeCoins:
          return _testRewardedId;
      }
    }

    switch (placement) {
      case PocketAdPlacement.ranking:
        return prodRankingAdUnitId;
      case PocketAdPlacement.reels:
        return prodReelsAdUnitId;
      case PocketAdPlacement.vibes:
        return prodVibesAdUnitId;
      case PocketAdPlacement.home:
        return prodHomeAdUnitId;
      case PocketAdPlacement.review:
        return prodReviewAdUnitId;
      case PocketAdPlacement.learningStep:
        return prodLearningStepInterstitialId;
      case PocketAdPlacement.dayCompletion:
        return prodDayCompletionInterstitialId;
      case PocketAdPlacement.attack:
        return prodAttackInterstitialId;
      case PocketAdPlacement.storeCoins:
        return prodStoreCoinsRewardedId;
    }
  }

  /// Dedicated resolver for Native Advanced ad unit IDs
  String getNativeAdUnitId(PocketAdPlacement placement) {
    if (_isTestMode) return testNativeId;
    switch (placement) {
      case PocketAdPlacement.home:
        return prodNativeHomeAdUnitId;
      case PocketAdPlacement.vibes:
        return prodNativeVibesAdUnitId;
      case PocketAdPlacement.review:
        return prodNativeLearningSummaryAdUnitId;
      case PocketAdPlacement.ranking:
        return prodNativeRankingAdUnitId;
      default:
        return prodNativeHomeAdUnitId;
    }
  }

  String get nativeAdUnitId => getNativeAdUnitId(PocketAdPlacement.home);
  String get rewardedAdUnitId => getUnitIdForPlacement(PocketAdPlacement.storeCoins);
  String get interstitialAdUnitId => getUnitIdForPlacement(PocketAdPlacement.dayCompletion);
  String get bannerAdUnitId => getUnitIdForPlacement(PocketAdPlacement.home);

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;
  DateTime? _lastInterstitialShownTime;
  static const Duration minInterstitialInterval = Duration(minutes: 3);

  // 📊 Live Telemetry Cache
  final PocketAdTelemetryData _telemetry = PocketAdTelemetryData();
  PocketAdTelemetryData get telemetry => _telemetry;
  bool get isSdkInitialized => _isInitialized;

  void _recordAdRequest(String placementName) {
    _telemetry.totalRequests++;
    final metric = _telemetry.placementMetrics.putIfAbsent(
        placementName, () => PocketAdPlacementMetric());
    metric.requests++;
  }

  void _recordAdLoaded(String placementName) {
    _telemetry.totalLoads++;
    _telemetry.lastSuccessTime = DateTime.now();
    final metric = _telemetry.placementMetrics.putIfAbsent(
        placementName, () => PocketAdPlacementMetric());
    metric.loads++;
    metric.lastLoadedTime = DateTime.now();
    _saveTelemetryLocally();
  }

  void _recordAdFailed(String placementName, dynamic error) {
    _telemetry.totalFails++;
    _telemetry.lastFailureTime = DateTime.now();
    final codeStr = error is LoadAdError ? error.code.toString() : 'UNKNOWN';
    final msgStr = error is LoadAdError ? error.message : error.toString();
    _telemetry.latestErrorCode = codeStr;
    _telemetry.latestErrorMessage = msgStr;
    _telemetry.latestErrorPlacement = placementName;
    if (codeStr == '3') {
      _telemetry.totalNoFills++;
    }
    final metric = _telemetry.placementMetrics.putIfAbsent(
        placementName, () => PocketAdPlacementMetric());
    metric.fails++;
    if (codeStr == '3') metric.noFills++;
    metric.lastFailedTime = DateTime.now();
    metric.lastErrorCode = codeStr;
    metric.lastErrorMessage = msgStr;
    _saveTelemetryLocally();
  }

  void _recordAdImpression(String placementName) {
    _telemetry.totalImpressions++;
    final metric = _telemetry.placementMetrics.putIfAbsent(
        placementName, () => PocketAdPlacementMetric());
    metric.impressions++;
    _saveTelemetryLocally();
  }

  Future<void> _saveTelemetryLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('admob_total_req', _telemetry.totalRequests);
      await prefs.setInt('admob_total_load', _telemetry.totalLoads);
      await prefs.setInt('admob_total_fail', _telemetry.totalFails);
      await prefs.setInt('admob_total_nofill', _telemetry.totalNoFills);
      await prefs.setInt('admob_total_imp', _telemetry.totalImpressions);
      if (_telemetry.lastSuccessTime != null) {
        await prefs.setString('admob_last_success', _telemetry.lastSuccessTime!.toIso8601String());
      }
      if (_telemetry.lastFailureTime != null) {
        await prefs.setString('admob_last_fail', _telemetry.lastFailureTime!.toIso8601String());
      }
      if (_telemetry.latestErrorCode != null) {
        await prefs.setString('admob_latest_code', _telemetry.latestErrorCode!);
      }
      if (_telemetry.latestErrorMessage != null) {
        await prefs.setString('admob_latest_msg', _telemetry.latestErrorMessage!);
      }

      // Sync aggregated production telemetry to Supabase backend asynchronously
      _syncTelemetryToBackend();
    } catch (_) {}
  }

  DateTime? _lastBackendSyncTime;
  Future<void> _syncTelemetryToBackend() async {
    // Throttle syncs to at most once every 30 seconds
    if (_lastBackendSyncTime != null &&
        DateTime.now().difference(_lastBackendSyncTime!) < const Duration(seconds: 30)) {
      return;
    }
    _lastBackendSyncTime = DateTime.now();

    try {
      final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');
      final syncPayload = {
        'target_platform': 'admob_telemetry_$platform',
        'is_active': true,
        'metadata': {
          'platform': platform,
          'total_requests': _telemetry.totalRequests,
          'total_loads': _telemetry.totalLoads,
          'total_fails': _telemetry.totalFails,
          'total_nofills': _telemetry.totalNoFills,
          'total_impressions': _telemetry.totalImpressions,
          'latest_error_code': _telemetry.latestErrorCode,
          'latest_error_message': _telemetry.latestErrorMessage,
          'latest_placement': _telemetry.latestErrorPlacement,
          'last_sync_time': DateTime.now().toIso8601String(),
          'app_version': '1.0.156+331',
        },
        'updated_at': DateTime.now().toIso8601String(),
      };
      await SupaFlow.client.from('app_promo_campaigns').upsert(syncPayload);
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> fetchBackendTelemetry() async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final res = await SupaFlow.client
          .from('app_promo_campaigns')
          .select('metadata')
          .eq('target_platform', 'admob_telemetry_$platform')
          .maybeSingle();
      if (res != null && res['metadata'] is Map) {
        return Map<String, dynamic>.from(res['metadata'] as Map);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _loadTelemetryLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _telemetry.totalRequests = prefs.getInt('admob_total_req') ?? 0;
      _telemetry.totalLoads = prefs.getInt('admob_total_load') ?? 0;
      _telemetry.totalFails = prefs.getInt('admob_total_fail') ?? 0;
      _telemetry.totalNoFills = prefs.getInt('admob_total_nofill') ?? 0;
      _telemetry.totalImpressions = prefs.getInt('admob_total_imp') ?? 0;
      final succ = prefs.getString('admob_last_success');
      if (succ != null) _telemetry.lastSuccessTime = DateTime.tryParse(succ);
      final fail = prefs.getString('admob_last_fail');
      if (fail != null) _telemetry.lastFailureTime = DateTime.tryParse(fail);
      _telemetry.latestErrorCode = prefs.getString('admob_latest_code');
      _telemetry.latestErrorMessage = prefs.getString('admob_latest_msg');
    } catch (_) {}
  }

  void resetTelemetry() async {
    _telemetry.totalRequests = 0;
    _telemetry.totalLoads = 0;
    _telemetry.totalFails = 0;
    _telemetry.totalNoFills = 0;
    _telemetry.totalImpressions = 0;
    _telemetry.lastSuccessTime = null;
    _telemetry.lastFailureTime = null;
    _telemetry.latestErrorCode = null;
    _telemetry.latestErrorMessage = null;
    _telemetry.latestErrorPlacement = null;
    _telemetry.placementMetrics.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admob_total_req');
      await prefs.remove('admob_total_load');
      await prefs.remove('admob_total_fail');
      await prefs.remove('admob_total_nofill');
      await prefs.remove('admob_total_imp');
      await prefs.remove('admob_last_success');
      await prefs.remove('admob_last_fail');
      await prefs.remove('admob_latest_code');
      await prefs.remove('admob_latest_msg');
    } catch (_) {}
  }

  /// ⚡ Initialize Google Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _loadTelemetryLocally();
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
        _telemetry.sdkInitialized = true;
        _telemetry.sdkInitTime = DateTime.now();
        return;
      }
      await MobileAds.instance.initialize();
      _isInitialized = true;
      _telemetry.sdkInitialized = true;
      _telemetry.sdkInitTime = DateTime.now();
      await _loadRemoteAdConfig();
      preloadAds();
    } catch (e) {
      if (kDebugMode) print('PocketAdMobService initialize error: $e');
    }
  }

  /// Optional remote config fetch to dynamically update ad unit IDs from Supabase
  Future<void> _loadRemoteAdConfig() async {
    try {
      final res = await SupaFlow.client
          .from('app_promo_campaigns')
          .select('metadata')
          .eq('target_platform', 'admob_config')
          .maybeSingle();
      if (res != null && res['metadata'] is Map) {
        final meta = res['metadata'] as Map<String, dynamic>;
        if (meta['banner_id'] != null && (meta['banner_id'] as String).isNotEmpty) {
          prodBannerAdUnitId = meta['banner_id'];
        }
        if (meta['interstitial_id'] != null && (meta['interstitial_id'] as String).isNotEmpty) {
          prodInterstitialAdUnitId = meta['interstitial_id'];
        }
        if (meta['rewarded_id'] != null && (meta['rewarded_id'] as String).isNotEmpty) {
          prodRewardedAdUnitId = meta['rewarded_id'];
        }
        if (meta['native_id'] != null && (meta['native_id'] as String).isNotEmpty) {
          prodNativeAdUnitId = meta['native_id'];
        }
        if (meta['step_native_frequency'] != null) {
          stepNativeAdFrequency = int.tryParse(meta['step_native_frequency'].toString()) ?? stepNativeAdFrequency;
        }
        if (meta['interstitial_step_frequency'] != null) {
          interstitialStepFrequency = int.tryParse(meta['interstitial_step_frequency'].toString()) ?? interstitialStepFrequency;
        }
        if (meta['enable_learning_banners'] != null) {
          enableLearningBannerAds = meta['enable_learning_banners'] == true;
        }
        if (meta['enable_summary_ad'] != null) {
          enableDailySummaryReviewAd = meta['enable_summary_ad'] == true;
        }
      }
    } catch (_) {}
  }

  bool _adminAdPreviewOverride = false;
  bool get adminAdPreviewOverride => _adminAdPreviewOverride;
  void setAdminAdPreviewOverride(bool value) {
    _adminAdPreviewOverride = value;
  }

  /// 🛡️ Check if the current user is a VIP / Premium Member
  /// VIP Rule: Never show any ads to VIPs!
  Future<bool> isUserVip() async {
    // If admin enabled live test previewing in Admin Panel, temporarily allow ads to show for verification
    if (_adminAdPreviewOverride) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('is_vip') == true ||
          prefs.getBool('has_vip_pass') == true ||
          prefs.getBool('is_premium') == true ||
          prefs.getBool('is_subscribed') == true ||
          prefs.getBool('remove_ads') == true ||
          (prefs.getString('handskill_plan') != null &&
              prefs.getString('handskill_plan') != 'free')) {
        return true;
      }

      // Check current user's profile in Supabase to sync real-time database status
      final uid = SupaFlow.client.auth.currentUser?.id;
      if (uid != null) {
        try {
          final profile = await SupaFlow.client
              .from('profile')
              .select('is_vip, is_premium, is_subscribed')
              .eq('user_id', uid)
              .maybeSingle();
          if (profile != null) {
            final isVipDb = profile['is_vip'] == true ||
                profile['is_premium'] == true ||
                profile['is_subscribed'] == true;
            // Synchronize to local SharedPreferences
            await prefs.setBool('is_vip', isVipDb);
            await prefs.setBool('is_premium', isVipDb);
            if (isVipDb) return true;
          }
        } catch (_) {}
      }
    } catch (_) {}
    return false;
  }

  /// Preload Interstitial and Rewarded Ads in background
  void preloadAds() {
    isUserVip().then((vip) {
      if (vip) return;
      _loadInterstitialAd();
      _loadRewardedAd();
    });
  }

  void _loadInterstitialAd() {
    if (_isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;
    _recordAdRequest('interstitial_cached');
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _recordAdLoaded('interstitial_cached');
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          _recordAdFailed('interstitial_cached', error);
        },
      ),
    );
  }

  void _loadRewardedAd() {
    if (_isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;
    _recordAdRequest('rewarded_coins');
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _recordAdLoaded('rewarded_coins');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
          _recordAdFailed('rewarded_coins', error);
        },
      ),
    );
  }

  /// 🎬 Show Rewarded Video Ad (e.g. after completing a day or to claim bonus rewards)
  /// If user is VIP, skips ad and immediately executes onUserEarnedReward!
  Future<void> showRewardedAd({
    required BuildContext context,
    required void Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) async {
    final vip = await isUserVip();
    if (vip) {
      // VIPs get reward instantly without watching any ad
      onUserEarnedReward(RewardItem(50, 'bonus_vip'));
      onAdClosed?.call();
      return;
    }

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      // 💻 Desktop / Windows Ad Simulation
      if (context.mounted) {
        final watched = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Ad',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Rewarded Ad (Desktop Sim)',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_fill_rounded, size: 54, color: Color(0xFF34D399)),
                const SizedBox(height: 12),
                const Text(
                  '15-Second Rewarded Ad Simulation for Non-VIP players.\n\nOn mobile (Android/iOS), this plays a real Google AdMob video.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF065F46).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🎁 Reward: +50 Pocket Score (PS)',
                    style: TextStyle(color: Color(0xFF6EE7B7), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('CLAIM REWARD (+50 PS)', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        if (watched == true) {
          onUserEarnedReward(RewardItem(50, 'bonus_pocket_score'));
        }
      }
      onAdClosed?.call();
      return;
    }

    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _recordAdImpression('rewarded_coins');
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          _loadRewardedAd();
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _rewardedAd = null;
          _loadRewardedAd();
          onAdClosed?.call();
        },
      );
      _rewardedAd!.show(onUserEarnedReward: (_, reward) {
        onUserEarnedReward(reward);
      });
    } else {
      // Ad was not ready, immediately grant reward and reload
      onUserEarnedReward(RewardItem(50, 'fallback'));
      onAdClosed?.call();
      _loadRewardedAd();
    }
  }

  /// 📺 Show Interstitial Ad (e.g. after completing major Day milestones or finishing an attack)
  Future<void> showInterstitialAd({
    BuildContext? context,
    PocketAdPlacement placement = PocketAdPlacement.dayCompletion,
    VoidCallback? onDismissed,
  }) async {
    final vip = await isUserVip();
    if (vip) {
      onDismissed?.call();
      return;
    }

    // ⏱️ Policy Safeguard: Enforce minimum interval between interstitials (3 minutes)
    if (_lastInterstitialShownTime != null &&
        DateTime.now().difference(_lastInterstitialShownTime!) < minInterstitialInterval) {
      onDismissed?.call();
      return;
    }

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      // 💻 Desktop / Windows Ad Simulation
      if (context != null && context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFFBBF24), width: 1.5),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Ad',
                    style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AdMob Interstitial Ad',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.ads_click_rounded, size: 50, color: Color(0xFF38BDF8)),
                const SizedBox(height: 12),
                Text(
                  'Full-screen Interstitial Ad triggered for Non-VIP player.\n\nPlacement: ${placement.name}\nOn mobile (Android/iOS), this shows the full Google AdMob ad overlay.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
                const SizedBox(height: 12),
                Text(
                  '(VIPs never see this ad)',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBBF24),
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('CONTINUE GAME (X)', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
      onDismissed?.call();
      return;
    }

    if (_interstitialAd != null) {
      _lastInterstitialShownTime = DateTime.now();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _recordAdImpression(placement.name);
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          onDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          onDismissed?.call();
        },
      );
      _interstitialAd!.show();
    } else {
      // If cached interstitial is null or placement needs a direct one-shot load
      final targetUnitId = getUnitIdForPlacement(placement);
      _recordAdRequest(placement.name);
      InterstitialAd.load(
        adUnitId: targetUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _recordAdLoaded(placement.name);
            _lastInterstitialShownTime = DateTime.now();
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (a) {
                _recordAdImpression(placement.name);
              },
              onAdDismissedFullScreenContent: (a) {
                a.dispose();
                onDismissed?.call();
              },
              onAdFailedToShowFullScreenContent: (a, err) {
                a.dispose();
                onDismissed?.call();
              },
            );
            ad.show();
          },
          onAdFailedToLoad: (err) {
            _recordAdFailed(placement.name, err);
            onDismissed?.call();
          },
        ),
      );
    }
  }

  /// Toggle test mode
  void setTestMode(bool isTest) {
    _overrideTestMode = isTest;
  }

  /// 🧪 Trigger a diagnostic test ad request directly from Admin Panel
  Future<Map<String, dynamic>> runAdDiagnostics(PocketAdPlacement placement) async {
    final unitId = getUnitIdForPlacement(placement);
    final nativeUnitId = getNativeAdUnitId(placement);
    return {
      'isInitialized': _isInitialized,
      'isTestMode': _isTestMode,
      'appId': androidAppId,
      'placement': placement.name,
      'resolvedBannerUnitId': unitId,
      'resolvedNativeUnitId': nativeUnitId,
      'totalRequests': _telemetry.totalRequests,
      'totalLoads': _telemetry.totalLoads,
      'totalFails': _telemetry.totalFails,
      'totalNoFills': _telemetry.totalNoFills,
      'latestErrorCode': _telemetry.latestErrorCode,
      'latestErrorMessage': _telemetry.latestErrorMessage,
    };
  }
}

/// 🎨 Aesthetic Instagram-Style Native Ad Banner Widget
/// Automatically checks VIP status and suppresses itself for VIPs!
class PocketNativeAdCard extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  final PocketAdPlacement placement;
  final String? customAdUnitId;

  const PocketNativeAdCard({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.placement = PocketAdPlacement.home,
    this.customAdUnitId,
  });

  @override
  State<PocketNativeAdCard> createState() => _PocketNativeAdCardState();
}

class _PocketNativeAdCardState extends State<PocketNativeAdCard> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    _checkVipAndLoad();
  }

  Future<void> _checkVipAndLoad() async {
    final vip = await PocketAdMobService.instance.isUserVip();
    if (vip) {
      if (mounted) setState(() => _isVip = true);
      return;
    }

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      if (mounted) setState(() => _isLoaded = true);
      return;
    }

    final targetUnitId = widget.customAdUnitId ??
        (PocketAdMobService.instance._isTestMode
            ? PocketAdMobService.instance.getUnitIdForPlacement(widget.placement)
            : PocketAdMobService.instance.getUnitIdForPlacement(widget.placement));

    PocketAdMobService.instance._recordAdRequest(widget.placement.name);

    _bannerAd = BannerAd(
      adUnitId: targetUnitId,
      size: AdSize.mediumRectangle, // 300x250 Instagram feed style
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          PocketAdMobService.instance._recordAdLoaded(widget.placement.name);
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          PocketAdMobService.instance._recordAdFailed(widget.placement.name, err);
          ad.dispose();
          _bannerAd = null;
        },
        onAdImpression: (_) {
          PocketAdMobService.instance._recordAdImpression(widget.placement.name);
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVip || !_isLoaded) {
      return const SizedBox.shrink();
    }

    if (_bannerAd == null) {
      // 💻 Desktop / Windows Native Ad Simulation Card
      return Container(
        margin: widget.margin,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Ad',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Sponsored · Google AdMob',
                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
                ),
                const Spacer(),
                const Text('Ad • ⓘ', style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Center(
                    child: Text('📱', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pocket AI English Companion',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Boost your vocabulary with daily live battles & AI mates.',
                        style: GoogleFonts.outfit(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Install',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Go VIP – Remove All Ads 👑',
                    style: TextStyle(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.9),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sponsored Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'SPONSORED',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const Spacer(),
                const Text('Ad • ⓘ', style: TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
          // Ad Canvas
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                  );
                },
                child: Text(
                  'Go VIP – Remove All Ads 👑',
                  style: TextStyle(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.9),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 💎 Genuine Native Advanced Ad Widget (Google Mobile Ads NativeAd)
/// Uses Android NativeAdFactory ("pocketNativeCardFactory") and layout XML.
/// Automatically handles VIP suppression, loading state, error fallback, and dispose.
class PocketTrueNativeAdWidget extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  final PocketAdPlacement placement;
  final String? customAdUnitId;

  const PocketTrueNativeAdWidget({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.placement = PocketAdPlacement.home,
    this.customAdUnitId,
  });

  @override
  State<PocketTrueNativeAdWidget> createState() => _PocketTrueNativeAdWidgetState();
}

class _PocketTrueNativeAdWidgetState extends State<PocketTrueNativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    _checkVipAndLoad();
  }

  Future<void> _checkVipAndLoad() async {
    final vip = await PocketAdMobService.instance.isUserVip();
    if (vip) {
      if (mounted) setState(() => _isVip = true);
      return;
    }

    if (kIsWeb || !Platform.isAndroid) {
      if (mounted) setState(() => _isLoaded = true);
      return;
    }

    final targetUnitId = widget.customAdUnitId ??
        (PocketAdMobService.instance._isTestMode
            ? PocketAdMobService.testNativeId
            : PocketAdMobService.instance.getNativeAdUnitId(widget.placement));

    PocketAdMobService.instance._recordAdRequest(widget.placement.name);

    _nativeAd = NativeAd(
      adUnitId: targetUnitId,
      factoryId: 'pocketNativeCardFactory',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          PocketAdMobService.instance._recordAdLoaded(widget.placement.name);
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          PocketAdMobService.instance._recordAdFailed(widget.placement.name, err);
          ad.dispose();
          _nativeAd = null;
          if (mounted) setState(() => _isLoaded = false);
        },
        onAdImpression: (_) {
          PocketAdMobService.instance._recordAdImpression(widget.placement.name);
        },
      ),
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVip) {
      return const SizedBox.shrink();
    }

    if (_nativeAd == null || !_isLoaded) {
      // In web or desktop or while loading, fallback gracefully to in-feed container
      if (kIsWeb || !Platform.isAndroid) {
        return PocketNativeAdCard(
          margin: widget.margin,
          placement: widget.placement,
          customAdUnitId: widget.customAdUnitId,
        );
      }
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      height: 330, // Responsive height for PocketNativeAdFactory view
      child: AdWidget(ad: _nativeAd!),
    );
  }
}

/// 💬 Sponsored Native Chat Bubble Ad Widget
/// Automatically renders inside English Hub and 1-on-1 Chats like a clean incoming message bubble!
class PocketChatBubbleAdWidget extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  const PocketChatBubbleAdWidget({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PocketAdMobService.instance.isUserVip(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return const SizedBox.shrink(); // Suppressed for VIPs
        }
        return Container(
          margin: margin,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.8),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: Colors.white12, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sponsored Partner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Ad',
                      style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '✨ Practice English 1-on-1 with live AI Speaking Partners. Boost your IELTS / CEFR confidence today!',
                style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.3),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                      );
                    },
                    child: const Text(
                      'Go VIP – Remove All Ads 👑',
                      style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Try Free',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 📱 PocketBannerAdWidget
/// Standard 320x50 / Adaptive Banner Ad with VIP check & safe fallback.
class PocketBannerAdWidget extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  final AdSize adSize;
  const PocketBannerAdWidget({
    super.key,
    this.margin = const EdgeInsets.symmetric(vertical: 6),
    this.adSize = AdSize.banner,
  });

  @override
  State<PocketBannerAdWidget> createState() => _PocketBannerAdWidgetState();
}

class _PocketBannerAdWidgetState extends State<PocketBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isVip = false;

  @override
  void initState() {
    super.initState();
    _initBanner();
  }

  Future<void> _initBanner() async {
    final vip = await PocketAdMobService.instance.isUserVip();
    if (vip) {
      if (mounted) setState(() => _isVip = true);
      return;
    }

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      if (mounted) setState(() => _isLoaded = true);
      return;
    }

    PocketAdMobService.instance._recordAdRequest('standard_banner');

    _bannerAd = BannerAd(
      adUnitId: PocketAdMobService.instance.bannerAdUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          PocketAdMobService.instance._recordAdLoaded('standard_banner');
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          PocketAdMobService.instance._recordAdFailed('standard_banner', err);
          ad.dispose();
          _bannerAd = null;
        },
        onAdImpression: (_) {
          PocketAdMobService.instance._recordAdImpression('standard_banner');
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVip || !_isLoaded) {
      return const SizedBox.shrink();
    }

    if (_bannerAd == null) {
      // Desktop / Web simulation banner
      return Container(
        margin: widget.margin,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Ad', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                );
              },
              child: const Text(
                'POKET VIP • Go VIP – Remove All Ads 👑',
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: widget.margin,
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
