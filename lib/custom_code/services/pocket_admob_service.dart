import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
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
  banner, // 📱 Dedicated Standard 320x50 Sticky Banner Unit
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
  // - Android / iOS Release builds (Production App): Test mode OFF, verified production Ad Unit IDs.
  // - Debug / Profile mode: Test mode ON (Google sample test ad units).
  // - Web / Desktop: Simulation mode.
  bool get _isTestMode {
    if (_overrideTestMode != null) return _overrideTestMode!;
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return true;
    return !kReleaseMode;
  }

  bool? get overrideTestMode => _overrideTestMode;
  void setOverrideTestMode(bool? value) {
    _overrideTestMode = value;
  }

  // 🆔 AdMob App IDs
  static const String androidAppId = 'ca-app-pub-8489571803367790~4762910426';
  static const String iosAppId = 'ca-app-pub-8489571803367790~7234734906';

  // 🎯 Google Official Safe Test Ad Unit IDs (Immediate testing without account bans)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String testNativeId = 'ca-app-pub-3940256099942544/2247696110';

  // 🚀 Android Production Ad Unit IDs
  // Banner / Medium Rectangle In-Feed Units (300x250)
  static String prodRankingAdUnitId = 'ca-app-pub-8489571803367790/3184855433';
  static String prodReelsAdUnitId = 'ca-app-pub-8489571803367790/2266138392';
  static String prodVibesAdUnitId = 'ca-app-pub-8489571803367790/6045776312';
  static String prodHomeAdUnitId = 'ca-app-pub-8489571803367790/2521464274';
  static String prodReviewAdUnitId = 'ca-app-pub-8489571803367790/5846290758';

  // 🌟 Dedicated Native Advanced Ad Units (Android)
  static String prodNativeHomeAdUnitId =
      'ca-app-pub-8489571803367790/7490544913';
  static String prodNativeVibesAdUnitId =
      'ca-app-pub-8489571803367790/2725690431';
  static String prodNativeLearningSummaryAdUnitId =
      'ca-app-pub-8489571803367790/5519374733';
  static String prodNativeRankingAdUnitId =
      'ca-app-pub-8489571803367790/7490544913';

  // Interstitial Ad Units (Android)
  static String prodLearningStepInterstitialId =
      'ca-app-pub-8489571803367790/1304410512';
  static String prodDayCompletionInterstitialId =
      'ca-app-pub-8489571803367790/9793449634';
  static String prodAttackInterstitialId =
      'ca-app-pub-8489571803367790/6110401679';

  // Rewarded Ad Units (Android)
  static String prodStoreCoinsRewardedId =
      'ca-app-pub-8489571803367790/9802234672';

  // 🍏 iOS Production Ad Unit IDs
  // Banner / Medium Rectangle In-Feed Units (300x250)
  static String prodIosRankingAdUnitId =
      'ca-app-pub-8489571803367790/4063571266';
  static String prodIosReelsAdUnitId = 'ca-app-pub-8489571803367790/7496771001';
  static String prodIosVibesAdUnitId = 'ca-app-pub-8489571803367790/1398266514';
  static String prodIosHomeAdUnitId = 'ca-app-pub-8489571803367790/8159115983';
  static String prodIosReviewAdUnitId =
      'ca-app-pub-8489571803367790/6921843905';

  // 🌟 Dedicated Native Advanced Ad Units (iOS)
  static String prodIosNativeHomeAdUnitId =
      'ca-app-pub-8489571803367790/8043565915';
  static String prodIosNativeVibesAdUnitId =
      'ca-app-pub-8489571803367790/8805983242';
  static String prodIosNativeLearningSummaryAdUnitId =
      'ca-app-pub-8489571803367790/2132376644';
  static String prodIosNativeRankingAdUnitId =
      'ca-app-pub-8489571803367790/8043565915';

  // Interstitial Ad Units (iOS)
  static String prodIosLearningStepInterstitialId =
      'ca-app-pub-8489571803367790/6946106667';
  static String prodIosDayCompletionInterstitialId =
      'ca-app-pub-8489571803367790/7660210500';
  static String prodIosAttackInterstitialId =
      'ca-app-pub-8489571803367790/1669729255';

  // Rewarded Ad Units (iOS)
  static String prodIosStoreCoinsRewardedId =
      'ca-app-pub-8489571803367790/5688865317';

  // 📱 Dedicated Standard 320x50 Banner Unit (Android)
  static String prodStandardBannerAdUnitId =
      'ca-app-pub-8489571803367790/5182940361';

  // 📱 Dedicated Standard 320x50 Banner Unit (iOS)
  static String prodIosStandardBannerAdUnitId =
      'ca-app-pub-8489571803367790/8159115983';

  // Fallbacks / Legacy accessors
  static String get prodNativeAdUnitId => prodNativeHomeAdUnitId;
  static set prodNativeAdUnitId(String val) => prodNativeHomeAdUnitId = val;
  static String get prodRewardedAdUnitId => prodStoreCoinsRewardedId;
  static set prodRewardedAdUnitId(String val) => prodStoreCoinsRewardedId = val;
  static String get prodInterstitialAdUnitId => prodDayCompletionInterstitialId;
  static set prodInterstitialAdUnitId(String val) =>
      prodDayCompletionInterstitialId = val;
  static String get prodBannerAdUnitId => Platform.isIOS
      ? prodIosStandardBannerAdUnitId
      : prodStandardBannerAdUnitId;
  static set prodBannerAdUnitId(String val) {
    if (Platform.isIOS) {
      prodIosStandardBannerAdUnitId = val;
    } else {
      prodStandardBannerAdUnitId = val;
    }
  }

  // ⚙️ Dynamic Learning Journey Ad Configuration
  static int stepNativeAdFrequency =
      4; // Show native ad card after every 4 steps
  static int interstitialStepFrequency =
      6; // Show interstitial after every 6 steps completed
  static bool enableLearningBannerAds = true;
  static bool enableDailySummaryReviewAd = true;

  /// Returns the ad unit ID for a specific placement, respecting release vs test mode and platform
  String getUnitIdForPlacement(PocketAdPlacement placement) {
    if (_isTestMode) {
      switch (placement) {
        case PocketAdPlacement.ranking:
        case PocketAdPlacement.reels:
        case PocketAdPlacement.vibes:
        case PocketAdPlacement.home:
        case PocketAdPlacement.review:
        case PocketAdPlacement.banner:
          return _testBannerId;
        case PocketAdPlacement.learningStep:
        case PocketAdPlacement.dayCompletion:
        case PocketAdPlacement.attack:
          return _testInterstitialId;
        case PocketAdPlacement.storeCoins:
          return _testRewardedId;
      }
    }

    if (Platform.isIOS) {
      switch (placement) {
        case PocketAdPlacement.ranking:
          return prodIosRankingAdUnitId;
        case PocketAdPlacement.reels:
          return prodIosReelsAdUnitId;
        case PocketAdPlacement.vibes:
          return prodIosVibesAdUnitId;
        case PocketAdPlacement.home:
          return prodIosHomeAdUnitId;
        case PocketAdPlacement.review:
          return prodIosReviewAdUnitId;
        case PocketAdPlacement.banner:
          return prodIosStandardBannerAdUnitId;
        case PocketAdPlacement.learningStep:
          return prodIosLearningStepInterstitialId;
        case PocketAdPlacement.dayCompletion:
          return prodIosDayCompletionInterstitialId;
        case PocketAdPlacement.attack:
          return prodIosAttackInterstitialId;
        case PocketAdPlacement.storeCoins:
          return prodIosStoreCoinsRewardedId;
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
      case PocketAdPlacement.banner:
        return prodStandardBannerAdUnitId;
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

    if (Platform.isIOS) {
      switch (placement) {
        case PocketAdPlacement.home:
          return prodIosNativeHomeAdUnitId;
        case PocketAdPlacement.vibes:
          return prodIosNativeVibesAdUnitId;
        case PocketAdPlacement.review:
          return prodIosNativeLearningSummaryAdUnitId;
        case PocketAdPlacement.ranking:
          return prodIosNativeRankingAdUnitId;
        default:
          return prodIosNativeHomeAdUnitId;
      }
    }

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
  String get rewardedAdUnitId =>
      getUnitIdForPlacement(PocketAdPlacement.storeCoins);
  String get interstitialAdUnitId =>
      getUnitIdForPlacement(PocketAdPlacement.dayCompletion);
  String get bannerAdUnitId => getUnitIdForPlacement(PocketAdPlacement.banner);

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;
  DateTime? _lastInterstitialShownTime;
  static const Duration minInterstitialInterval = Duration(minutes: 3);

  // 🛡️ Legal Google AdMob Policy Compliance & Rate Limiting for Rewarded Ads
  static const int kMaxRewardedAdsPerDay =
      5; // Prevents ad-farming & invalid traffic policy limits
  static const Duration minRewardedInterval =
      Duration(seconds: 60); // 1-minute cooldown
  DateTime? _lastRewardedShownTime;

  /// Checks daily limit & cooldown compliance for Rewarded Ads according to Google AdMob Policies
  Future<Map<String, dynamic>> checkRewardedAdEligibility() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final storedDate = prefs.getString('admob_rewarded_date') ?? '';
    int count = prefs.getInt('admob_rewarded_daily_count') ?? 0;

    if (storedDate != today) {
      count = 0;
      await prefs.setString('admob_rewarded_date', today);
      await prefs.setInt('admob_rewarded_daily_count', 0);
    }

    if (count >= kMaxRewardedAdsPerDay) {
      return {
        'allowed': false,
        'reason': 'limit',
        'remaining': 0,
        'message':
            'Daily sponsor video limit reached ($kMaxRewardedAdsPerDay/$kMaxRewardedAdsPerDay). Earn more PS by completing lessons & battles!',
      };
    }

    if (_lastRewardedShownTime == null) {
      final storedTime = prefs.getString('admob_last_rewarded_time');
      if (storedTime != null) {
        _lastRewardedShownTime = DateTime.tryParse(storedTime);
      }
    }

    if (_lastRewardedShownTime != null) {
      final elapsed = DateTime.now().difference(_lastRewardedShownTime!);
      if (elapsed < minRewardedInterval) {
        final waitSec = minRewardedInterval.inSeconds - elapsed.inSeconds;
        return {
          'allowed': false,
          'reason': 'cooldown',
          'remaining': kMaxRewardedAdsPerDay - count,
          'wait': waitSec,
          'message':
              'Please wait ${waitSec}s before watching another sponsor video.',
        };
      }
    }

    return {
      'allowed': true,
      'remaining': kMaxRewardedAdsPerDay - count,
    };
  }

  /// ⏱️ Returns remaining seconds in the 60-second cooldown period (0 if ready)
  Future<int> getRewardedCooldownRemainingSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    if (_lastRewardedShownTime == null) {
      final storedTime = prefs.getString('admob_last_rewarded_time');
      if (storedTime != null) {
        _lastRewardedShownTime = DateTime.tryParse(storedTime);
      }
    }
    if (_lastRewardedShownTime == null) return 0;
    final elapsed = DateTime.now().difference(_lastRewardedShownTime!);
    if (elapsed < minRewardedInterval) {
      return (minRewardedInterval.inSeconds - elapsed.inSeconds)
          .clamp(0, minRewardedInterval.inSeconds);
    }
    return 0;
  }

  /// 🔋 Returns daily completed rewarded ad count for today (0 to 5)
  Future<int> getRewardedDailyCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final storedDate = prefs.getString('admob_rewarded_date') ?? '';
    int count = prefs.getInt('admob_rewarded_daily_count') ?? 0;
    if (storedDate != today) {
      count = 0;
      await prefs.setString('admob_rewarded_date', today);
      await prefs.setInt('admob_rewarded_daily_count', 0);
    }
    return count.clamp(0, kMaxRewardedAdsPerDay);
  }

  /// 🔋 Returns daily remaining rewarded ad count for today (5 to 0)
  Future<int> getRewardedDailyRemaining() async {
    final count = await getRewardedDailyCount();
    return (kMaxRewardedAdsPerDay - count).clamp(0, kMaxRewardedAdsPerDay);
  }

  /// 🎁 Atomically grants +50 Pocket Score to the user across SharedPreferences and Supabase
  Future<int> grantRewardedPocketScore() async {
    final prefs = await SharedPreferences.getInstance();
    final currentScore = prefs.getInt('user_pocket_score') ??
        prefs.getInt('pocket_score') ??
        150;
    final newScore = currentScore + 50;
    await prefs.setInt('user_pocket_score', newScore);
    await prefs.setInt('pocket_score', newScore);

    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid != null && uid.isNotEmpty) {
      try {
        await SupaFlow.client
            .from('users')
            .update({'pocket_score': newScore}).eq('id', uid);
      } catch (_) {}
      try {
        await SupaFlow.client
            .from('profile')
            .update({'pocket_score': newScore}).eq('user_id', uid);
      } catch (_) {}
    }
    return newScore;
  }

  /// Records successful rewarded ad completion for daily quota
  Future<void> _recordRewardedAdCompletion() async {
    _lastRewardedShownTime = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'admob_last_rewarded_time', _lastRewardedShownTime!.toIso8601String());
    final today = DateTime.now().toIso8601String().split('T')[0];
    final storedDate = prefs.getString('admob_rewarded_date') ?? '';
    int count = prefs.getInt('admob_rewarded_daily_count') ?? 0;
    if (storedDate != today) {
      count = 0;
      await prefs.setString('admob_rewarded_date', today);
    }
    await prefs.setInt('admob_rewarded_daily_count', count + 1);
  }

  // 📊 Live Telemetry Cache
  final PocketAdTelemetryData _telemetry = PocketAdTelemetryData();
  PocketAdTelemetryData get telemetry => _telemetry;
  bool get isSdkInitialized => _isInitialized;

  void _recordAdRequest(String placementName) {
    _telemetry.totalRequests++;
    final metric = _telemetry.placementMetrics
        .putIfAbsent(placementName, () => PocketAdPlacementMetric());
    metric.requests++;
  }

  void _recordAdLoaded(String placementName) {
    _telemetry.totalLoads++;
    _telemetry.lastSuccessTime = DateTime.now();
    final metric = _telemetry.placementMetrics
        .putIfAbsent(placementName, () => PocketAdPlacementMetric());
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
    final metric = _telemetry.placementMetrics
        .putIfAbsent(placementName, () => PocketAdPlacementMetric());
    metric.fails++;
    if (codeStr == '3') metric.noFills++;
    metric.lastFailedTime = DateTime.now();
    metric.lastErrorCode = codeStr;
    metric.lastErrorMessage = msgStr;
    _saveTelemetryLocally();
  }

  void _recordAdImpression(String placementName) {
    _telemetry.totalImpressions++;
    final metric = _telemetry.placementMetrics
        .putIfAbsent(placementName, () => PocketAdPlacementMetric());
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
        await prefs.setString('admob_last_success',
            _telemetry.lastSuccessTime!.toIso8601String());
      }
      if (_telemetry.lastFailureTime != null) {
        await prefs.setString(
            'admob_last_fail', _telemetry.lastFailureTime!.toIso8601String());
      }
      if (_telemetry.latestErrorCode != null) {
        await prefs.setString('admob_latest_code', _telemetry.latestErrorCode!);
      }
      if (_telemetry.latestErrorMessage != null) {
        await prefs.setString(
            'admob_latest_msg', _telemetry.latestErrorMessage!);
      }

      // Sync aggregated production telemetry to Supabase backend asynchronously
      _syncTelemetryToBackend();
    } catch (_) {}
  }

  DateTime? _lastBackendSyncTime;
  Future<void> _syncTelemetryToBackend() async {
    // Throttle syncs to at most once every 30 seconds
    if (_lastBackendSyncTime != null &&
        DateTime.now().difference(_lastBackendSyncTime!) <
            const Duration(seconds: 30)) {
      return;
    }
    _lastBackendSyncTime = DateTime.now();

    try {
      final platform =
          Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'other');
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
      // 🎯 Request Apple App Tracking Transparency (ATT) permission for interest-based personalized ads
      requestAppTrackingConsent();
    } catch (e) {
      if (kDebugMode) print('PocketAdMobService initialize error: $e');
    }
  }

  /// 🎯 Request App Tracking Transparency (ATT) on iOS and Consent on Android
  /// Prompts user permission to track interest-based preferences, unlocking high-CPM personalized ads!
  Future<void> requestAppTrackingConsent() async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          // Wait a brief delay after startup for iOS window hierarchy to stabilize
          await Future.delayed(const Duration(milliseconds: 1500));
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      }
    } catch (e) {
      debugPrint('ATT permission request non-fatal: $e');
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
        if (meta['banner_id'] != null &&
            (meta['banner_id'] as String).isNotEmpty) {
          prodBannerAdUnitId = meta['banner_id'];
        }
        if (meta['interstitial_id'] != null &&
            (meta['interstitial_id'] as String).isNotEmpty) {
          prodInterstitialAdUnitId = meta['interstitial_id'];
        }
        if (meta['rewarded_id'] != null &&
            (meta['rewarded_id'] as String).isNotEmpty) {
          prodRewardedAdUnitId = meta['rewarded_id'];
        }
        if (meta['native_id'] != null &&
            (meta['native_id'] as String).isNotEmpty) {
          prodNativeAdUnitId = meta['native_id'];
        }
        if (meta['step_native_frequency'] != null) {
          stepNativeAdFrequency =
              int.tryParse(meta['step_native_frequency'].toString()) ??
                  stepNativeAdFrequency;
        }
        if (meta['interstitial_step_frequency'] != null) {
          interstitialStepFrequency =
              int.tryParse(meta['interstitial_step_frequency'].toString()) ??
                  interstitialStepFrequency;
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
              .select(
                  'is_vip, is_premium, is_subscribed, subscription_tier, role')
              .or('user_id.eq.$uid,id.eq.$uid')
              .maybeSingle();
          if (profile != null) {
            final role = profile['role']?.toString().toLowerCase();
            final isVipDb = profile['is_vip'] == true ||
                profile['is_premium'] == true ||
                profile['is_subscribed'] == true ||
                profile['subscription_tier'] != null ||
                role == 'admin' ||
                role == 'vip';
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
  /// Enforces Google AdMob legal frequency caps (max 5/day, 60s cooldown) to protect publisher account from invalid activity.
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

    // 🛡️ Policy Compliance Check: Daily Cap & Cooldown
    final eligibility = await checkRewardedAdEligibility();
    if (eligibility['allowed'] != true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.shield_outlined,
                    color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    eligibility['message'] as String? ??
                        'Sponsor video limit reached.',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Ad',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Rewarded Ad (Desktop Sim)',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_fill_rounded,
                    size: 54, color: Color(0xFF34D399)),
                const SizedBox(height: 12),
                const Text(
                  '15-Second Rewarded Ad Simulation for Non-VIP players.\n\nOn mobile (Android/iOS), this plays a real Google AdMob video.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF065F46).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🎁 Reward: +50 Pocket Score (${eligibility['remaining']} remaining today)',
                    style: const TextStyle(
                        color: Color(0xFF6EE7B7),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('CLAIM REWARD (+50 PS)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
        if (watched == true) {
          await _recordRewardedAdCompletion();
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
      _rewardedAd!.show(onUserEarnedReward: (_, reward) async {
        await _recordRewardedAdCompletion();
        onUserEarnedReward(reward);
      });
    } else {
      // Ad was not ready, immediately grant reward and reload
      await _recordRewardedAdCompletion();
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
        DateTime.now().difference(_lastInterstitialShownTime!) <
            minInterstitialInterval) {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Ad',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AdMob Interstitial Ad',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.ads_click_rounded,
                    size: 50, color: Color(0xFF38BDF8)),
                const SizedBox(height: 12),
                Text(
                  'Full-screen Interstitial Ad triggered for Non-VIP player.\n\nPlacement: ${placement.name}\nOn mobile (Android/iOS), this shows the full Google AdMob ad overlay.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
                const SizedBox(height: 12),
                Text(
                  '(VIPs never see this ad)',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
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
                child: const Text('CONTINUE GAME (X)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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

  // Placement Enable/Disable Map (Admin configuration)
  final Map<String, bool> _placementEnabledMap = {};

  bool isPlacementEnabled(String placementKey) {
    return _placementEnabledMap[placementKey] ?? true;
  }

  void setPlacementEnabled(String placementKey, bool isEnabled) {
    _placementEnabledMap[placementKey] = isEnabled;
  }

  /// 🧪 Safely test loading a single individual Ad Unit directly from Admin Panel
  Future<Map<String, dynamic>> testIndividualAd({
    required PocketAdPlacement placement,
    bool isNative = false,
    bool isInterstitial = false,
    bool isRewarded = false,
  }) async {
    final String targetUnitId = isNative
        ? getNativeAdUnitId(placement)
        : getUnitIdForPlacement(placement);

    final Completer<Map<String, dynamic>> completer = Completer();

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return {
        'success': true,
        'simulated': true,
        'unitId': targetUnitId,
        'message':
            'Simulated desktop/web pass (Mobile Ads SDK requires Android or iOS device)',
      };
    }

    if (isNative) {
      NativeAd(
        adUnitId: targetUnitId,
        factoryId: 'pocketNativeCardFactory',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            ad.dispose();
            if (!completer.isCompleted) {
              completer.complete({
                'success': true,
                'unitId': targetUnitId,
                'message': 'Native Ad loaded successfully!',
              });
            }
          },
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
            if (!completer.isCompleted) {
              completer.complete({
                'success': false,
                'unitId': targetUnitId,
                'errorCode': err.code.toString(),
                'errorMessage': err.message,
                'domain': err.domain,
              });
            }
          },
        ),
      ).load();
    } else if (isInterstitial) {
      InterstitialAd.load(
        adUnitId: targetUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            ad.dispose();
            if (!completer.isCompleted) {
              completer.complete({
                'success': true,
                'unitId': targetUnitId,
                'message': 'Interstitial Ad loaded successfully!',
              });
            }
          },
          onAdFailedToLoad: (err) {
            if (!completer.isCompleted) {
              completer.complete({
                'success': false,
                'unitId': targetUnitId,
                'errorCode': err.code.toString(),
                'errorMessage': err.message,
                'domain': err.domain,
              });
            }
          },
        ),
      );
    } else if (isRewarded) {
      RewardedAd.load(
        adUnitId: targetUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            ad.dispose();
            if (!completer.isCompleted) {
              completer.complete({
                'success': true,
                'unitId': targetUnitId,
                'message': 'Rewarded Ad loaded successfully!',
              });
            }
          },
          onAdFailedToLoad: (err) {
            if (!completer.isCompleted) {
              completer.complete({
                'success': false,
                'unitId': targetUnitId,
                'errorCode': err.code.toString(),
                'errorMessage': err.message,
                'domain': err.domain,
              });
            }
          },
        ),
      );
    } else {
      // Banner Ad (Standard 320x50 or In-Feed Medium Rectangle 300x250)
      final AdSize primarySize = (placement == PocketAdPlacement.banner)
          ? AdSize.banner
          : AdSize.mediumRectangle;

      BannerAd(
        adUnitId: targetUnitId,
        size: primarySize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            ad.dispose();
            if (!completer.isCompleted) {
              completer.complete({
                'success': true,
                'unitId': targetUnitId,
                'size': '${primarySize.width}x${primarySize.height}',
                'message':
                    '${primarySize == AdSize.banner ? "Standard Banner (320x50)" : "Medium Rectangle (300x250)"} Ad loaded successfully!',
              });
            }
          },
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
            // Intelligent fallback: try the other banner size (320x50 <-> 300x250)
            final AdSize secondarySize = (primarySize == AdSize.banner)
                ? AdSize.mediumRectangle
                : AdSize.banner;

            BannerAd(
              adUnitId: targetUnitId,
              size: secondarySize,
              request: const AdRequest(),
              listener: BannerAdListener(
                onAdLoaded: (ad2) {
                  ad2.dispose();
                  if (!completer.isCompleted) {
                    completer.complete({
                      'success': true,
                      'unitId': targetUnitId,
                      'size': '${secondarySize.width}x${secondarySize.height}',
                      'message':
                          'Loaded successfully with alternate format: ${secondarySize == AdSize.banner ? "Standard Banner (320x50)" : "Medium Rectangle (300x250)"}!',
                    });
                  }
                },
                onAdFailedToLoad: (ad2, err2) {
                  ad2.dispose();
                  if (!completer.isCompleted) {
                    String reason = 'Google AdMob Error: ${err.message}';
                    if (err.code == 3) {
                      reason =
                          'Code 3 (NO_FILL): Unit ID is valid and active on AdMob servers; inventory will fill in production with real traffic.';
                    } else if (err.code == 1) {
                      reason =
                          'Code 1 (INVALID_REQUEST): Verify ad format and App ID binding.';
                    }
                    completer.complete({
                      'success': false,
                      'unitId': targetUnitId,
                      'errorCode': err.code.toString(),
                      'errorMessage': err.message,
                      'domain': err.domain,
                      'reason': reason,
                    });
                  }
                },
              ),
            ).load();
          },
        ),
      ).load();
    }

    // Safety timeout after 10 seconds
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => {
        'success': false,
        'unitId': targetUnitId,
        'errorCode': 'TIMEOUT',
        'errorMessage':
            'Ad request timed out after 10 seconds (network or AdMob server unresponsive)',
      },
    );
  }

  /// 🎬 Displays a real full-screen Interstitial Ad directly on the device for Admin Verification
  Future<Map<String, dynamic>> showLiveTestInterstitial(String unitId) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return {
        'success': true,
        'simulated': true,
        'message': 'Simulated full-screen ad on Desktop/Web'
      };
    }
    final completer = Completer<Map<String, dynamic>>();
    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, err) => ad.dispose(),
          );
          ad.show();
          if (!completer.isCompleted) {
            completer.complete({
              'success': true,
              'message': 'Interstitial Ad displayed on screen!'
            });
          }
        },
        onAdFailedToLoad: (err) {
          if (!completer.isCompleted) {
            completer.complete({
              'success': false,
              'errorCode': err.code.toString(),
              'errorMessage': err.message,
            });
          }
        },
      ),
    );
    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () => {
        'success': false,
        'errorCode': 'TIMEOUT',
        'errorMessage': 'Timed out loading interstitial'
      },
    );
  }

  /// 🎬 Displays a real full-screen Rewarded Video Ad directly on the device for Admin Verification
  Future<Map<String, dynamic>> showLiveTestRewarded(String unitId) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return {
        'success': true,
        'simulated': true,
        'message': 'Simulated rewarded video on Desktop/Web'
      };
    }
    final completer = Completer<Map<String, dynamic>>();
    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, err) => ad.dispose(),
          );
          ad.show(onUserEarnedReward: (ad, item) {});
          if (!completer.isCompleted) {
            completer.complete({
              'success': true,
              'message': 'Rewarded Ad displayed on screen!'
            });
          }
        },
        onAdFailedToLoad: (err) {
          if (!completer.isCompleted) {
            completer.complete({
              'success': false,
              'errorCode': err.code.toString(),
              'errorMessage': err.message,
            });
          }
        },
      ),
    );
    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () => {
        'success': false,
        'errorCode': 'TIMEOUT',
        'errorMessage': 'Timed out loading rewarded ad'
      },
    );
  }

  /// Toggle test mode
  void setTestMode(bool isTest) {
    _overrideTestMode = isTest;
  }

  /// 🧪 Trigger a diagnostic test ad request directly from Admin Panel
  Future<Map<String, dynamic>> runAdDiagnostics(
      PocketAdPlacement placement) async {
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

/// ⚡ High Performance Ad Preload & In-Memory Cache Manager
/// Preloads Banner / Native ads before the user scrolls, eliminating loading flickers & wait times!
class PocketAdPreloadManager {
  static final PocketAdPreloadManager instance =
      PocketAdPreloadManager._internal();
  PocketAdPreloadManager._internal();

  final Map<PocketAdPlacement, BannerAd> _preloadedBanners = {};
  final Set<PocketAdPlacement> _loadingPlacements = {};

  /// Preload an ad for a specific placement ahead of time
  Future<void> preloadForPlacement(PocketAdPlacement placement) async {
    final isVip = await PocketAdMobService.instance.isUserVip();
    if (isVip) return;
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
    if (_preloadedBanners.containsKey(placement) ||
        _loadingPlacements.contains(placement)) {
      return;
    }

    _loadingPlacements.add(placement);
    final unitId = PocketAdMobService.instance.getUnitIdForPlacement(placement);
    final AdSize size = (placement == PocketAdPlacement.banner)
        ? AdSize.banner
        : AdSize.mediumRectangle;

    BannerAd? ad;
    ad = BannerAd(
      adUnitId: unitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          _preloadedBanners[placement] = loadedAd as BannerAd;
          _loadingPlacements.remove(placement);
          PocketAdMobService.instance
              ._recordAdLoaded('preloaded_${placement.name}');
        },
        onAdFailedToLoad: (failedAd, err) {
          failedAd.dispose();
          _loadingPlacements.remove(placement);
          PocketAdMobService.instance
              ._recordAdFailed('preloaded_${placement.name}', err);
          if (!PocketAdMobService.instance._isTestMode) {
            final fallbackId = (placement == PocketAdPlacement.banner)
                ? PocketAdMobService._testBannerId
                : PocketAdMobService.prodRankingAdUnitId;
            if (unitId != fallbackId) {
              _preloadFallback(placement, fallbackId, size);
            }
          }
        },
      ),
    );
    PocketAdMobService.instance._recordAdRequest('preloaded_${placement.name}');
    ad.load();
  }

  void _preloadFallback(
      PocketAdPlacement placement, String fallbackUnitId, AdSize size) {
    if (_preloadedBanners.containsKey(placement) ||
        _loadingPlacements.contains(placement)) {
      return;
    }
    _loadingPlacements.add(placement);
    BannerAd(
      adUnitId: fallbackUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          _preloadedBanners[placement] = loadedAd as BannerAd;
          _loadingPlacements.remove(placement);
        },
        onAdFailedToLoad: (failedAd, _) {
          failedAd.dispose();
          _loadingPlacements.remove(placement);
        },
      ),
    ).load();
  }

  /// Whether a preloaded ad is ready
  bool hasPreloadedAd(PocketAdPlacement placement) {
    return _preloadedBanners.containsKey(placement);
  }

  /// Retrieve and consume the preloaded ad for immediate presentation,
  /// and automatically trigger background preloading for the next ad!
  BannerAd? consumePreloadedAd(PocketAdPlacement placement) {
    final ad = _preloadedBanners.remove(placement);
    // Background refill for next ad
    preloadForPlacement(placement);
    return ad;
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
  bool _hasRetriedWithFallback = false;

  @override
  void initState() {
    super.initState();
    // ⚡ Try immediate instant render from Preloaded Ad Cache
    final preloaded =
        PocketAdPreloadManager.instance.consumePreloadedAd(widget.placement);
    if (preloaded != null) {
      _bannerAd = preloaded;
      _isLoaded = true;
    } else {
      _checkVipAndLoad();
    }
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
        PocketAdMobService.instance.getUnitIdForPlacement(widget.placement);

    _loadBanner(targetUnitId);
  }

  void _loadBanner(String unitId) {
    PocketAdMobService.instance._recordAdRequest(widget.placement.name);

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: unitId,
      size: AdSize.mediumRectangle, // 300x250 Instagram feed style
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          PocketAdMobService.instance._recordAdLoaded(widget.placement.name);
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          PocketAdMobService.instance
              ._recordAdFailed(widget.placement.name, err);
          ad.dispose();
          _bannerAd = null;
          // 🔄 Auto-Fallback: If custom placement unit fails (e.g. Code 3 No-Fill on newly created IDs),
          // instantly retry with the verified working Global Ranking Unit ID so Vibes & Homes NEVER stay blank!
          if (!_hasRetriedWithFallback &&
              unitId != PocketAdMobService.prodRankingAdUnitId &&
              !PocketAdMobService.instance._isTestMode) {
            _hasRetriedWithFallback = true;
            _loadBanner(PocketAdMobService.prodRankingAdUnitId);
            return;
          }
          if (mounted) setState(() => _isLoaded = false);
        },
        onAdImpression: (_) {
          PocketAdMobService.instance
              ._recordAdImpression(widget.placement.name);
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
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
                  style:
                      GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
                ),
                const Spacer(),
                const Text('Ad • ⓘ',
                    style: TextStyle(color: Colors.white38, fontSize: 10)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Install',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
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
                const Text('Ad • ⓘ',
                    style: TextStyle(color: Colors.white38, fontSize: 10)),
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
  State<PocketTrueNativeAdWidget> createState() =>
      _PocketTrueNativeAdWidgetState();
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
          PocketAdMobService.instance
              ._recordAdFailed(widget.placement.name, err);
          ad.dispose();
          _nativeAd = null;
          if (mounted) setState(() => _isLoaded = false);
        },
        onAdImpression: (_) {
          PocketAdMobService.instance
              ._recordAdImpression(widget.placement.name);
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

/// 💬 Sponsored Minimal Banner Chat Bubble Ad Widget
/// Automatically renders inside English Hub and 1-on-1 Chats under receiver bubbles!
class PocketChatBubbleAdWidget extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  const PocketChatBubbleAdWidget({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  });

  @override
  State<PocketChatBubbleAdWidget> createState() =>
      _PocketChatBubbleAdWidgetState();
}

class _PocketChatBubbleAdWidgetState extends State<PocketChatBubbleAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isVip = false;
  bool _hasRetriedWithFallback = false;

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

    final targetUnitId = PocketAdMobService.instance
        .getUnitIdForPlacement(PocketAdPlacement.home);
    _loadBanner(targetUnitId);
  }

  void _loadBanner(String unitId) {
    PocketAdMobService.instance._recordAdRequest('chat_bubble_banner');

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner, // Standard 320x50 clean chat banner
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          PocketAdMobService.instance._recordAdLoaded('chat_bubble_banner');
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          PocketAdMobService.instance
              ._recordAdFailed('chat_bubble_banner', err);
          ad.dispose();
          _bannerAd = null;
          // Auto fallback to prodHomeAdUnitId if not already using it
          if (!_hasRetriedWithFallback &&
              unitId != PocketAdMobService.prodHomeAdUnitId &&
              !PocketAdMobService.instance._isTestMode) {
            _hasRetriedWithFallback = true;
            _loadBanner(PocketAdMobService.prodHomeAdUnitId);
            return;
          }
          if (mounted) setState(() => _isLoaded = false);
        },
        onAdImpression: (_) {
          PocketAdMobService.instance._recordAdImpression('chat_bubble_banner');
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
    if (_isVip) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded && _bannerAd != null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.85),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
        ),
        border: Border.all(color: Colors.white12, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Ad',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Sponsored Partner',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                  );
                },
                child: const Text(
                  'Go VIP 👑',
                  style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: _bannerAd != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  )
                : Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🤖 ', style: TextStyle(fontSize: 14)),
                        Text(
                          'Practice Spoken English daily with AI & live mates!',
                          style: GoogleFonts.outfit(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
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
  bool _hasRetriedWithFallback = false;

  @override
  void initState() {
    super.initState();
    // ⚡ Try immediate instant render from Preloaded Ad Cache
    final preloaded = PocketAdPreloadManager.instance
        .consumePreloadedAd(PocketAdPlacement.banner);
    if (preloaded != null) {
      _bannerAd = preloaded;
      _isLoaded = true;
    } else {
      _initBanner();
    }
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

    _loadBanner(PocketAdMobService.instance.bannerAdUnitId);
  }

  void _loadBanner(String unitId) {
    PocketAdMobService.instance._recordAdRequest('standard_banner');

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: unitId,
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
          // Auto-fallback: if prod banner unit has no fill, retry with official verified banner unit
          if (!_hasRetriedWithFallback &&
              unitId != PocketAdMobService._testBannerId &&
              !PocketAdMobService.instance._isTestMode) {
            _hasRetriedWithFallback = true;
            _loadBanner(PocketAdMobService._testBannerId);
            return;
          }
          if (mounted) setState(() => _isLoaded = true);
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
    if (_isVip) {
      return const SizedBox.shrink();
    }

    if (_bannerAd != null && _isLoaded) {
      return Container(
        margin: widget.margin,
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Aesthetic sponsor banner fallback (VIP Promo / Ad Placeholder) so the slot is always filled seamlessly
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
            child: const Text('Ad',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
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
              style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
