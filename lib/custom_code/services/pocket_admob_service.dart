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
import 'pocket_meta_ads_service.dart';

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
  target, // 🎯 Roadmap target page between gate and next house
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
  // 🚀 User Directive: 100% Real Production Ad Units across TestFlight & Release builds
  // Test Mode completely disabled for live AdMob CPM & Production verification!
  static bool useTestModeInBuild = false;

  bool get _isTestMode {
    if (_overrideTestMode != null) return _overrideTestMode!;
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return true;
    // 🚀 Force 100% Production Ads everywhere on Android & iOS.
    // Absolutely NO Google test banner/interstitial units in release/device builds.
    return false;
  }

  bool? get overrideTestMode => _overrideTestMode;
  void setOverrideTestMode(bool? value) {
    _overrideTestMode = value;
  }

  // 🆔 AdMob App IDs
  static const String androidAppId = 'ca-app-pub-8489571803367790~4762910426';
  static const String iosAppId = 'ca-app-pub-8489571803367790~7234734906';

  // 🎯 Google Official Safe Test Ad Unit IDs (Immediate testing without account bans)
  // Android Test IDs:
  static const String _testBannerIdAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialIdAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testNativeIdAndroid =
      'ca-app-pub-3940256099942544/2247696110';

  // iOS Test IDs:
  static const String _testBannerIdIos =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialIdIos =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedIdIos =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _testNativeIdIos =
      'ca-app-pub-3940256099942544/3986624511';

  static String get testBannerId =>
      Platform.isIOS ? _testBannerIdIos : _testBannerIdAndroid;
  static String get testInterstitialId =>
      Platform.isIOS ? _testInterstitialIdIos : _testInterstitialIdAndroid;
  static String get testRewardedId =>
      Platform.isIOS ? _testRewardedIdIos : _testRewardedIdAndroid;
  static String get testNativeId =>
      Platform.isIOS ? _testNativeIdIos : _testNativeIdAndroid;

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
        case PocketAdPlacement.target:
        case PocketAdPlacement.review:
        case PocketAdPlacement.banner:
          return testBannerId;
        case PocketAdPlacement.learningStep:
        case PocketAdPlacement.dayCompletion:
        case PocketAdPlacement.attack:
          return testInterstitialId;
        case PocketAdPlacement.storeCoins:
          return testRewardedId;
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
        case PocketAdPlacement.target:
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
      case PocketAdPlacement.target:
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
        case PocketAdPlacement.target:
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
      case PocketAdPlacement.target:
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
  final List<Completer<RewardedAd?>> _rewardedCompleters = [];
  DateTime? _lastInterstitialShownTime;
  static const Duration minInterstitialInterval = Duration(minutes: 3);

  // 🛡️ Legal Google AdMob & Meta Ads Compliance & Rate Limiting for Rewarded Ads
  static const int kMaxRewardedAdsPerDay =
      10; // Expanded to 10 daily rewarded video unlocks per user directive
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
    final uid = SupaFlow.client.auth.currentUser?.id;

    int currentScore = 0;
    if (uid != null && uid.isNotEmpty) {
      currentScore = prefs.getInt('user_pocket_score_$uid') ??
          prefs.getInt('user_pocket_score') ??
          prefs.getInt('pocket_score') ??
          150;
    } else {
      currentScore = prefs.getInt('user_pocket_score') ??
          prefs.getInt('pocket_score') ??
          150;
    }

    final newScore = currentScore + 30;

    // 1. Persist to universal and user-scoped keys so UI updates instantly everywhere
    await prefs.setInt('user_pocket_score', newScore);
    await prefs.setInt('pocket_score', newScore);

    if (uid != null && uid.isNotEmpty) {
      await prefs.setInt('user_pocket_score_$uid', newScore);
      await prefs.setInt('learning_points_$uid', newScore);

      // 2. Persist to Supabase users, profile, and homes tables
      try {
        await SupaFlow.client
            .from('users')
            .update({'pocket_score': newScore}).eq('id', uid);
      } catch (_) {}
      try {
        await SupaFlow.client.from('profile').update({
          'pocket_score': newScore,
          'learning_points': newScore,
          'xp': newScore,
        }).eq('user_id', uid);
      } catch (_) {}
      try {
        await SupaFlow.client.from('pocket_homes').update({
          'points': newScore,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', uid);
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

      // 🔄 Real-time Account Switch & Logout Listener:
      // Instantly resets and recalculates VIP entitlement so switching between Premium and Free accounts
      // on the same device shows/hides ads with 100% precision!
      try {
        SupaFlow.client.auth.onAuthStateChange.listen((data) {
          final user = data.session?.user;
          if (user != null) {
            onAccountSwitched(user.id);
          } else {
            onUserSignedOut();
          }
        });
      } catch (_) {}
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

  // ⚡ User-Scoped In-memory instant VIP cache for 0ms latency ad loading
  String? _cachedVipUid;
  bool? _cachedIsVip;

  /// ⚡ Synchronous VIP status check matching the current logged-in user
  bool isUserVipSync() {
    if (_adminAdPreviewOverride) return false;
    final currentUid = SupaFlow.client.auth.currentUser?.id;
    if (currentUid == null || currentUid.isEmpty) return false;
    if (_cachedVipUid == currentUid && _cachedIsVip != null) {
      return _cachedIsVip!;
    }
    return false;
  }

  void updateCachedVipStatus(bool isVip) {
    _cachedVipUid = SupaFlow.client.auth.currentUser?.id;
    _cachedIsVip = isVip;
  }

  /// 🔄 Called when an account is switched or signed in
  void onAccountSwitched(String? newUid) {
    _cachedVipUid = null;
    _cachedIsVip = null;
    isUserVip();
  }

  /// 🚪 Called when user signs out
  void onUserSignedOut() {
    _cachedVipUid = null;
    _cachedIsVip = false;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('is_vip', false);
      prefs.setBool('is_premium', false);
      prefs.setBool('remove_ads', false);
      prefs.setString('handskill_plan', 'free');
    }).catchError((_) {});
  }

  /// 🛡️ Check if the current user is a VIP / Premium Member
  /// VIP Rule: Never show any ads to VIPs!
  Future<bool> isUserVip() async {
    // If admin enabled live test previewing in Admin Panel, temporarily allow ads to show for verification
    if (_adminAdPreviewOverride) {
      _cachedIsVip = false;
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. First check user's profile in Supabase to sync real-time database status
      final user = SupaFlow.client.auth.currentUser;
      final uid = user?.id;

      // Guest / Not logged in: Show ads
      if (uid == null || uid.isEmpty) {
        _cachedVipUid = null;
        _cachedIsVip = false;
        return false;
      }

      try {
        dynamic profile;
        try {
          profile = await SupaFlow.client
              .from('profiles')
              .select(
                  'is_vip, is_premium, is_subscribed, subscription_tier, role, verified')
              .eq('id', uid)
              .maybeSingle();
        } catch (_) {}
        if (profile == null) {
          try {
            profile = await SupaFlow.client
                .from('profile')
                .select(
                    'is_vip, is_premium, is_subscribed, subscription_tier, role, verified')
                .or('user_id.eq.$uid,id.eq.$uid')
                .maybeSingle();
          } catch (_) {}
        }

        if (profile != null) {
          final role = profile['role']?.toString().toLowerCase().trim();
          final tier =
              profile['subscription_tier']?.toString().toLowerCase().trim();
          final bool hasActivePaidTier = tier != null &&
              tier.isNotEmpty &&
              tier != 'free' &&
              tier != 'none' &&
              tier != 'null';

          // Option B Single Source of Truth:
          // A user is ONLY VIP if they have an active paid subscription tier
          // (monthly, quarterly, yearly, vip_gold, etc.) OR role is admin/vip!
          final bool isTrueVip = hasActivePaidTier ||
              role == 'vip' ||
              role == 'admin' ||
              profile['is_vip'] == true ||
              profile['is_subscribed'] == true;

          debugPrint('🔍 [PocketAdMob] Genuine DB Check VIP for UID $uid:');
          debugPrint(
              '   -> DB Profile: subscription_tier=$tier, role=$role, hasActivePaidTier=$hasActivePaidTier => isTrueVip=$isTrueVip');

          if (isTrueVip) {
            debugPrint(
                '   👑 [PocketAdMob] Result: USER IS VIP. All Ads Suppressed.');
            await prefs.setBool('is_vip_$uid', true);
            await prefs.setString('subscription_tier_$uid', tier ?? 'monthly');

            // Clear un-scoped global device flags to prevent cross-account leaks
            await prefs.setBool('is_vip', false);
            await prefs.setBool('is_premium', false);
            await prefs.setBool('remove_ads', false);
            await prefs.setString('handskill_plan', 'free');

            _cachedVipUid = uid;
            _cachedIsVip = true;
            return true;
          } else {
            debugPrint(
                '   🟢 [PocketAdMob] Result: USER IS FREE. Ads Allowed. Cleared device VIP flags.');
            await prefs.setBool('is_vip_$uid', false);
            await prefs.setString('subscription_tier_$uid', 'free');

            // Clear un-scoped global device flags so stale VIP never blocks free account ads
            await prefs.setBool('is_vip', false);
            await prefs.setBool('is_premium', false);
            await prefs.setBool('remove_ads', false);
            await prefs.setString('handskill_plan', 'free');

            _cachedVipUid = uid;
            _cachedIsVip = false;
            return false;
          }
        }
      } catch (e) {
        debugPrint('[PocketAdMob] Error checking user profile VIP: $e');
      }

      // 2. Fallback to user-scoped local preferences if network is offline
      final userScopedTier = prefs.getString('subscription_tier_$uid');
      if (userScopedTier != null && userScopedTier.isNotEmpty) {
        final isVip = userScopedTier != 'free' && userScopedTier != 'none';
        _cachedVipUid = uid;
        _cachedIsVip = isVip;
        return isVip;
      }

      // 3. User is FREE by default! (never assume VIP)
      _cachedVipUid = uid;
      _cachedIsVip = false;
      return false;
    } catch (_) {}

    _cachedVipUid = SupaFlow.client.auth.currentUser?.id;
    _cachedIsVip = false;
    return false;
  }

  /// Preload Interstitial and Rewarded Ads in background
  void preloadAds() {
    isUserVip().then((vip) {
      if (vip) return;
      _loadInterstitialAd();
      _loadRewardedAd();
      // 🚀 Proactively preload Native/Banner ads for Home, Vibes, Target and Ranking so they appear instantly!
      PocketAdPreloadManager.instance
          .preloadForPlacement(PocketAdPlacement.home);
      PocketAdPreloadManager.instance
          .preloadForPlacement(PocketAdPlacement.vibes);
      PocketAdPreloadManager.instance
          .preloadForPlacement(PocketAdPlacement.target);
      PocketAdPreloadManager.instance
          .preloadForPlacement(PocketAdPlacement.ranking);
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

  void _flushRewardedCompleters(RewardedAd? ad) {
    for (final c in _rewardedCompleters) {
      if (!c.isCompleted) c.complete(ad);
    }
    _rewardedCompleters.clear();
  }

  void _loadRewardedAd(
      {bool isFallback = false, Completer<RewardedAd?>? completer}) {
    if (completer != null) {
      if (_rewardedAd != null) {
        if (!completer.isCompleted) completer.complete(_rewardedAd);
        return;
      }
      _rewardedCompleters.add(completer);
    }

    if (_isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;
    _recordAdRequest('rewarded_coins');

    final targetUnitId = rewardedAdUnitId;
    debugPrint(
        '🎬 [PocketAdMob] Loading rewarded ad unit: $targetUnitId (fallback: $isFallback)');

    RewardedAd.load(
      adUnitId: targetUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _recordAdLoaded('rewarded_coins');
          debugPrint('🎬 [PocketAdMob] Rewarded ad loaded successfully');
          _flushRewardedCompleters(_rewardedAd);
        },
        onAdFailedToLoad: (error) {
          _recordAdFailed('rewarded_coins', error);
          debugPrint(
              '🎬 [PocketAdMob] Rewarded ad failed to load: ${error.code} - ${error.message}');
          _isRewardedLoading = false;
          _rewardedAd = null;
          _flushRewardedCompleters(null);
        },
      ),
    );
  }

  /// 🎬 Show Rewarded Video Ad (e.g. after completing a day or to claim bonus rewards)
  /// Enforces Google AdMob legal frequency caps (max 5/day, 60s cooldown) to protect publisher account from invalid activity.
  /// If user is VIP, skips ad completely and immediately executes onUserEarnedReward!
  Future<void> showRewardedAd({
    required BuildContext context,
    required void Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
    bool forceShowForTesting = false,
  }) async {
    final vip = await isUserVip();
    debugPrint(
        '🎬 [PocketAdMob] showRewardedAd requested. User is VIP: $vip, forceShowForTesting: $forceShowForTesting');

    // 👑 VIP Direct Reward Bypass: VIP users NEVER watch ads!
    if (vip && !forceShowForTesting) {
      debugPrint(
          '👑 [PocketAdMob] VIP user bypassed rewarded ad, granting bonus directly.');
      onUserEarnedReward(RewardItem(30, 'PocketScore'));
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
          onUserEarnedReward(RewardItem(30, 'bonus_pocket_score'));
        }
      }
      onAdClosed?.call();
      return;
    }

    // 🎯 10 Daily Rewarded Videos: 5 Google AdMob + 5 Meta Audience Network
    final currentRewardedCount = await getRewardedDailyCount();
    final bool preferMeta = (currentRewardedCount % 2 == 1);

    if (preferMeta) {
      debugPrint(
          '🎬 [DualRewarded] Prioritizing Meta Rewarded Video (slot ${currentRewardedCount + 1}/10, Meta slot ${(currentRewardedCount ~/ 2) + 1}/5)');
      final metaShown = await PocketMetaAdsService.instance.showRewardedAd(
        onUserEarnedReward: () async {
          await _recordRewardedAdCompletion();
          onUserEarnedReward(RewardItem(30, 'bonus_pocket_score'));
        },
      );
      if (metaShown) {
        onAdClosed?.call();
        return;
      }
      debugPrint(
          '⚠️ [DualRewarded] Meta Rewarded Video not ready, seamlessly falling back to Google AdMob.');
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
      return;
    }

    // ⚡ If not loaded yet, do NOT grant free score without the video!
    // Instead, show a brief loading dialog and wait for it to load on-demand.
    await _showRewardedAdWithLoadingDialog(
      context: context,
      onUserEarnedReward: onUserEarnedReward,
      onAdClosed: onAdClosed,
    );
  }

  /// 🎬 On-demand Rewarded Video loader with graceful loading modal
  Future<void> _showRewardedAdWithLoadingDialog({
    required BuildContext context,
    required void Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) async {
    if (!context.mounted) {
      onAdClosed?.call();
      return;
    }

    bool dialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Text(
                    'Loading sponsor video...\nPlease wait a moment 🎬',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => dialogOpen = false);

    final completer = Completer<RewardedAd?>();
    _loadRewardedAd(completer: completer);
    final deadline = DateTime.now().add(const Duration(seconds: 10));

    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (_rewardedAd != null) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete(_rewardedAd);
      } else if (DateTime.now().isAfter(deadline) ||
          (!_isRewardedLoading &&
              _rewardedAd == null &&
              _rewardedCompleters.isEmpty)) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete(null);
      }
    });

    final ad = await completer.future;

    if (dialogOpen && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      dialogOpen = false;
    }

    if (ad != null) {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (_) {
          _recordAdImpression('rewarded_coins');
        },
        onAdDismissedFullScreenContent: (dispAd) {
          dispAd.dispose();
          _rewardedAd = null;
          _loadRewardedAd();
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (dispAd, err) {
          dispAd.dispose();
          _rewardedAd = null;
          _loadRewardedAd();
          onAdClosed?.call();
        },
      );
      ad.show(onUserEarnedReward: (_, reward) async {
        await _recordRewardedAdCompletion();
        onUserEarnedReward(reward);
      });
    } else {
      // 🚀 Dual-Network Fallback: Try Meta Audience Network Rewarded Ad!
      final metaShown = await PocketMetaAdsService.instance.showRewardedAd(
        onUserEarnedReward: () async {
          await _recordRewardedAdCompletion();
          onUserEarnedReward(RewardItem(30, 'bonus_pocket_score'));
        },
      );
      if (metaShown) {
        onAdClosed?.call();
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFFFFB300), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Sponsor video is not ready yet. Please check your connection and try again!',
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      onAdClosed?.call();
      _loadRewardedAd();
    }
  }

  /// 📺 Show Interstitial Ad (e.g. after completing major Day milestones or finishing an attack)
  Future<void> showInterstitialAd({
    BuildContext? context,
    PocketAdPlacement placement = PocketAdPlacement.dayCompletion,
    VoidCallback? onDismissed,
    bool forceShowForTesting = false,
  }) async {
    final vip = await isUserVip();
    debugPrint(
        '📱 [PocketAdMob] showInterstitialAd requested. User is VIP: $vip, forceShowForTesting: $forceShowForTesting');
    if (vip && !forceShowForTesting) {
      debugPrint('👑 [PocketAdMob] VIP user: Interstitial skipped.');
      onDismissed?.call();
      return;
    }

    // ⏱️ Policy Safeguard: Enforce minimum interval between interstitials
    final minInterval = (placement == PocketAdPlacement.attack)
        ? const Duration(seconds: 20)
        : minInterstitialInterval;

    if (!forceShowForTesting &&
        _lastInterstitialShownTime != null &&
        DateTime.now().difference(_lastInterstitialShownTime!) < minInterval) {
      debugPrint(
          '⏱️ [PocketAdMob] Interstitial cooldown active (${minInterval.inSeconds}s). Skipping.');
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
      final completer = Completer<void>();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          _recordAdImpression(placement.name);
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          onDismissed?.call();
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
          onDismissed?.call();
          if (!completer.isCompleted) completer.complete();
        },
      );
      _interstitialAd!.show();
      await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          onDismissed?.call();
        },
      );
    } else {
      // If cached interstitial is null or placement needs a direct one-shot load
      final targetUnitId = getUnitIdForPlacement(placement);
      _recordAdRequest(placement.name);
      final completer = Completer<void>();
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
                if (!completer.isCompleted) completer.complete();
              },
              onAdFailedToShowFullScreenContent: (a, err) {
                a.dispose();
                onDismissed?.call();
                if (!completer.isCompleted) completer.complete();
              },
            );
            ad.show();
          },
          onAdFailedToLoad: (err) async {
            _recordAdFailed(placement.name, err);
            // 🚀 Dual-Network Fallback: Try Meta Interstitial Ad!
            final metaShown =
                await PocketMetaAdsService.instance.showInterstitialAd();
            if (metaShown) {
              _lastInterstitialShownTime = DateTime.now();
            }
            onDismissed?.call();
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
      await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          onDismissed?.call();
        },
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

  // 🛡️ Persistent Reusable Ad Pool: Keeps loaded ads alive across scroll gaps and page navigation
  // Prevents ads from wiping away when user scrolls or navigates between pages!
  final Map<PocketAdPlacement, List<BannerAd>> _reusableAdsPool = {};
  final Map<BannerAd, DateTime> _adCreatedAt = {};
  final Set<BannerAd> _activeMountedBanners = {};

  /// Acquires an active reusable BannerAd or a preloaded BannerAd for this placement.
  /// If available and currently unmounted, it attaches instantly with 0ms delay!
  BannerAd? acquireAd(PocketAdPlacement placement) {
    // 1. Check existing reusable ad in pool for this placement
    final pool = _reusableAdsPool[placement];
    if (pool != null && pool.isNotEmpty) {
      final now = DateTime.now();
      // Remove any ads older than 5 minutes (AdMob impression freshness window)
      pool.removeWhere((ad) {
        final created = _adCreatedAt[ad];
        if (created != null &&
            now.difference(created) > const Duration(minutes: 5)) {
          if (!_activeMountedBanners.contains(ad)) {
            ad.dispose();
            _adCreatedAt.remove(ad);
            return true;
          }
        }
        return false;
      });

      // Find first unmounted ad
      for (final ad in pool) {
        if (!_activeMountedBanners.contains(ad)) {
          _activeMountedBanners.add(ad);
          return ad;
        }
      }
    }

    // 2. Consume preloaded banner if ready
    final preloaded = _preloadedBanners.remove(placement);
    if (preloaded != null) {
      _reusableAdsPool.putIfAbsent(placement, () => []).add(preloaded);
      _adCreatedAt[preloaded] = DateTime.now();
      _activeMountedBanners.add(preloaded);
      // Trigger background refill for subsequent slots
      preloadForPlacement(placement);
      return preloaded;
    }

    // Trigger preload for future gaps
    preloadForPlacement(placement);
    return null;
  }

  /// Backward-compatible alias for preloaded consumption
  BannerAd? consumePreloadedAd(PocketAdPlacement placement) =>
      acquireAd(placement);

  /// Releases the ad when its widget unmounts (e.g. scrolled past).
  /// Instead of disposing it immediately, preserves it in the pool so the next gap
  /// or page can render it immediately without disappearing!
  void releaseAd(PocketAdPlacement placement, BannerAd? ad) {
    if (ad == null) return;
    _activeMountedBanners.remove(ad);

    final created = _adCreatedAt[ad];
    if (created != null &&
        DateTime.now().difference(created) > const Duration(minutes: 5)) {
      ad.dispose();
      _reusableAdsPool[placement]?.remove(ad);
      _adCreatedAt.remove(ad);
    }
  }

  /// Registers a newly loaded BannerAd into the persistent reusable pool
  void registerLoadedAd(PocketAdPlacement placement, BannerAd ad) {
    _activeMountedBanners.add(ad);
    _adCreatedAt[ad] = DateTime.now();
    final pool = _reusableAdsPool.putIfAbsent(placement, () => []);
    if (!pool.contains(ad)) {
      pool.add(ad);
    }
    // Cap pool to max 3 ads per placement to save memory
    if (pool.length > 3) {
      final oldest = pool.firstWhere(
        (a) => !_activeMountedBanners.contains(a),
        orElse: () => pool.first,
      );
      if (!_activeMountedBanners.contains(oldest)) {
        pool.remove(oldest);
        oldest.dispose();
        _adCreatedAt.remove(oldest);
      }
    }
  }

  /// Preload an ad for a specific placement ahead of time
  Future<void> preloadForPlacement(PocketAdPlacement placement) async {
    if (PocketAdMobService.instance.isUserVipSync()) return;
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
                ? (Platform.isIOS
                    ? PocketAdMobService.prodIosStandardBannerAdUnitId
                    : PocketAdMobService.prodStandardBannerAdUnitId)
                : (Platform.isIOS
                    ? PocketAdMobService.prodIosRankingAdUnitId
                    : PocketAdMobService.prodRankingAdUnitId);
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
    return _preloadedBanners.containsKey(placement) ||
        (_reusableAdsPool[placement]?.isNotEmpty ?? false);
  }
}

/// 🎨 Aesthetic Instagram-Style Native Ad Banner Widget
/// Automatically checks VIP status and suppresses itself for VIPs!
class PocketNativeAdCard extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  final PocketAdPlacement placement;
  final String? customAdUnitId;
  final bool? isCompact;
  final bool forceFreeMode;
  final void Function(String status, String? details)? onStatusChange;

  const PocketNativeAdCard({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.placement = PocketAdPlacement.home,
    this.customAdUnitId,
    this.isCompact,
    this.forceFreeMode = false,
    this.onStatusChange,
  });

  @override
  State<PocketNativeAdCard> createState() => _PocketNativeAdCardState();
}

class _PocketNativeAdCardState extends State<PocketNativeAdCard>
    with AutomaticKeepAliveClientMixin {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isVip = false;
  bool _hasRetriedWithAlternateSize = false;
  bool _hasRetriedWithFallback = false;

  @override
  bool get wantKeepAlive => true;

  bool get _isCompact =>
      widget.isCompact ?? (widget.placement == PocketAdPlacement.banner);

  @override
  void initState() {
    super.initState();
    // 👑 Synchronous VIP check: if already confirmed VIP, skip immediately
    if (!widget.forceFreeMode && PocketAdMobService.instance.isUserVipSync()) {
      _isVip = true;
      widget.onStatusChange?.call('VIP_BLOCKED', 'User is VIP in local cache');
      return;
    }

    // ⚡ Try immediate instant render from Persistent Reusable / Preloaded Cache
    final reusable =
        PocketAdPreloadManager.instance.acquireAd(widget.placement);
    if (reusable != null && !widget.forceFreeMode) {
      _bannerAd = reusable;
      _isLoaded = true;
      widget.onStatusChange?.call('LOADED',
          'From Persistent Cache (${reusable.size.width}x${reusable.size.height})');
    } else {
      _checkVipAndLoad();
    }
  }

  Future<void> _checkVipAndLoad() async {
    if (!widget.forceFreeMode) {
      final vip = await PocketAdMobService.instance.isUserVip();
      if (vip) {
        if (mounted) setState(() => _isVip = true);
        widget.onStatusChange
            ?.call('VIP_BLOCKED', 'User is VIP (Supabase/Prefs)');
        return;
      }
    }

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      if (mounted) setState(() => _isLoaded = true);
      widget.onStatusChange?.call('SIMULATED', 'Desktop / Web environment');
      return;
    }

    final targetUnitId = widget.customAdUnitId ??
        PocketAdMobService.instance.getUnitIdForPlacement(widget.placement);

    _loadBanner(targetUnitId);
  }

  void _loadBanner(String unitId, {AdSize? sizeOverride}) {
    PocketAdMobService.instance._recordAdRequest(widget.placement.name);

    _bannerAd?.dispose();
    final AdSize requestedSize =
        sizeOverride ?? ((_isCompact) ? AdSize.banner : AdSize.mediumRectangle);

    widget.onStatusChange?.call('REQUESTING',
        'Unit: $unitId (${requestedSize.width}x${requestedSize.height})');

    _bannerAd = BannerAd(
      adUnitId: unitId,
      size: requestedSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          PocketAdMobService.instance._recordAdLoaded(widget.placement.name);
          if (_bannerAd != null) {
            PocketAdPreloadManager.instance
                .registerLoadedAd(widget.placement, _bannerAd!);
          }
          if (mounted) setState(() => _isLoaded = true);
          widget.onStatusChange?.call('LOADED',
              'Ad loaded: ${requestedSize.width}x${requestedSize.height}');
        },
        onAdFailedToLoad: (ad, err) {
          PocketAdMobService.instance
              ._recordAdFailed(widget.placement.name, err);
          ad.dispose();
          _bannerAd = null;
          widget.onStatusChange
              ?.call('FAILED', 'Code ${err.code}: ${err.message}');

          // 🔄 Tier 1 Fallback: If 300x250 medium rectangle failed, retry with 320x50 banner
          // in case the ad unit ID was created as a standard banner in Google AdMob Console!
          if (!_hasRetriedWithAlternateSize &&
              requestedSize == AdSize.mediumRectangle &&
              !_isCompact) {
            _hasRetriedWithAlternateSize = true;
            widget.onStatusChange
                ?.call('RETRYING_BANNER', 'Retrying with 320x50 banner size');
            _loadBanner(unitId, sizeOverride: AdSize.banner);
            return;
          }

          // 🔄 Tier 2 Fallback: If placement unit fails (e.g. Code 3 No-Fill in UAE/regions),
          // instantly retry with the verified working Global Ranking Unit ID (matching platform)!
          final fallbackUnitId = Platform.isIOS
              ? PocketAdMobService.prodIosRankingAdUnitId
              : PocketAdMobService.prodRankingAdUnitId;

          if (!_hasRetriedWithFallback &&
              unitId != fallbackUnitId &&
              !PocketAdMobService.instance._isTestMode) {
            _hasRetriedWithFallback = true;
            widget.onStatusChange?.call('RETRYING_FALLBACK_UNIT',
                'Retrying with verified Ranking Unit: $fallbackUnitId');
            _loadBanner(fallbackUnitId, sizeOverride: AdSize.mediumRectangle);
            return;
          }

          if (mounted) setState(() => _isLoaded = false);
        },
        onAdImpression: (_) {
          PocketAdMobService.instance
              ._recordAdImpression(widget.placement.name);
          widget.onStatusChange?.call('IMPRESSION', 'Ad impression recorded');
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    PocketAdPreloadManager.instance.releaseAd(widget.placement, _bannerAd);
    super.dispose();
  }

  void _showAdInfoSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sponsored advertisement. Upgrade to Poket VIP to remove all ads.',
          style: GoogleFonts.outfit(fontSize: 12),
        ),
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Go VIP',
          textColor: const Color(0xFFFFD700),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionPage()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 👑 VIP users never see any ads (unless forceFreeMode active)
    if (_isVip && !widget.forceFreeMode) {
      return const SizedBox.shrink();
    }

    // ⚡ Real AdMob ad only! If not loaded or null, cleanly collapse (no dummy card!)
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    // ⚡ Preloaded Minimal Mode (For standard banner or compact requests)
    if (_isCompact) {
      return _buildCompactCard(context);
    }

    // 📱 Standard Instagram Feed-Style Native Ad Card
    return _buildStandardCard(context);
  }

  /// 🌟 Sleek, Compact Minimal Native Ad Card
  Widget _buildCompactCard(BuildContext context) {
    if (_bannerAd == null || !_isLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: const Color(0xFF131B26).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 📸 Compact Header (32x32 Avatar + Title + Verified Badge + Sponsored)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 6),
            child: Row(
              children: [
                // 32x32 Glowing Avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF131B26),
                    border: Border.all(
                      color: const Color(0xFFFFFC00),
                      width: 1.2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/pocket_mates_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFFFFFC00),
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Poket Mates Ads',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFFFFFC00),
                            size: 13,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Sponsored',
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text('•',
                              style: TextStyle(
                                  color: Colors.white30, fontSize: 9)),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 0.5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(3),
                              border:
                                  Border.all(color: Colors.white24, width: 0.5),
                            ),
                            child: Text(
                              'Ad',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz_rounded,
                      color: Colors.white38, size: 18),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 26, minHeight: 26),
                  splashRadius: 14,
                  onPressed: () => _showAdInfoSnackbar(context),
                ),
              ],
            ),
          ),

          // 🖼️ Ad Content Frame (Live AdMob Banner)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black26,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
          ),

          // 👑 Minimal Golden VIP Upgrade Pill (Height 32px)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFB300),
                      Color(0xFFFFFC00),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: Colors.black, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'Go VIP & Remove All Ads',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                      size: 13,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📱 Standard Full-Size Native Ad Card
  Widget _buildStandardCard(BuildContext context) {
    if (_bannerAd == null || !_isLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: const Color(0xFF131B26).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 📸 Instagram Feed-Style Header matching ConversationTile
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                // 50x50 Avatar with Glowing Aura Ring matching ConversationTile exactly
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF131B26),
                    border: Border.all(
                      color: const Color(0xFFFFFC00),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.25),
                        blurRadius: 10,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/pocket_mates_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF131B26),
                        alignment: Alignment.center,
                        child: const Icon(Icons.bolt_rounded,
                            color: Color(0xFFFFFC00), size: 26),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Brand Name + Golden Verified Badge + Sponsored Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Poket Mates Ads',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Golden Verified Tick Badge
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFFFFFC00),
                            size: 15,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Sponsored',
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '•',
                            style:
                                TextStyle(color: Colors.white30, fontSize: 10),
                          ),
                          const SizedBox(width: 6),
                          // AdMob Mandatory Ad Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.white24,
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              'Ad',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 3-dots options menu
                IconButton(
                  icon: const Icon(Icons.more_horiz_rounded,
                      color: Colors.white38, size: 20),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  splashRadius: 18,
                  tooltip: 'Sponsored Ad by Google AdMob',
                  onPressed: () => _showAdInfoSnackbar(context),
                ),
              ],
            ),
          ),

          // 🖼️ Ad Creative Canvas (Instagram Post Media Frame)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.0,
                ),
                color: Colors.black26,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
          ),

          // 👑 Minimal Golden VIP Button (Matching Random / Pocket Talk gradient)
          _buildVipUpgradeBar(context),
        ],
      ),
    );
  }

  /// 👑 Minimal Yellow Gradient VIP Button matching Random & Pocket Talk buttons
  Widget _buildVipUpgradeBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionPage()),
              );
            },
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: double.infinity,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFB300),
                    Color(0xFFFFFC00),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      color: Colors.black, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Go VIP & Remove All Ads',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.black,
                    size: 16,
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

/// 🏛️ Legacy Native Ad Card from Working Build v1.0.225+427 (commit dc50278)
/// Restored in full fidelity for side-by-side production diagnostics & fallback.
class LegacyDc50278NativeAdCard extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  final PocketAdPlacement placement;
  final String? customAdUnitId;
  final bool forceFreeMode;
  final void Function(String status, String? details)? onStatusChange;

  const LegacyDc50278NativeAdCard({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.placement = PocketAdPlacement.home,
    this.customAdUnitId,
    this.forceFreeMode = false,
    this.onStatusChange,
  });

  @override
  State<LegacyDc50278NativeAdCard> createState() =>
      _LegacyDc50278NativeAdCardState();
}

class _LegacyDc50278NativeAdCardState extends State<LegacyDc50278NativeAdCard>
    with AutomaticKeepAliveClientMixin {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isVip = false;
  bool _hasRetriedWithFallback = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkVipAndLoad();
  }

  Future<void> _checkVipAndLoad() async {
    if (!widget.forceFreeMode) {
      final vip = await PocketAdMobService.instance.isUserVip();
      if (vip) {
        if (mounted) setState(() => _isVip = true);
        widget.onStatusChange?.call('VIP_BLOCKED', 'User is VIP in DB/Cache');
        return;
      }
    }

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      if (mounted) setState(() => _isLoaded = true);
      widget.onStatusChange?.call('SIMULATED', 'Desktop/Web simulation');
      return;
    }

    final targetUnitId = widget.customAdUnitId ??
        PocketAdMobService.instance.getUnitIdForPlacement(widget.placement);

    _loadBanner(targetUnitId);
  }

  void _loadBanner(String unitId) {
    widget.onStatusChange?.call('REQUESTING', 'Unit: $unitId (300x250)');
    PocketAdMobService.instance
        ._recordAdRequest('legacy_${widget.placement.name}');

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: unitId,
      size: AdSize.mediumRectangle, // 300x250 Instagram feed style
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          PocketAdMobService.instance
              ._recordAdLoaded('legacy_${widget.placement.name}');
          if (mounted) setState(() => _isLoaded = true);
          widget.onStatusChange
              ?.call('LOADED', '300x250 MediumRectangle loaded successfully');
        },
        onAdFailedToLoad: (ad, err) {
          PocketAdMobService.instance
              ._recordAdFailed('legacy_${widget.placement.name}', err);
          ad.dispose();
          _bannerAd = null;
          widget.onStatusChange?.call(
              'FAILED', 'Code ${err.code}: ${err.message} (Unit: $unitId)');

          // 🔄 Auto-Fallback from dc50278: If custom placement unit fails,
          // instantly retry with the verified working Global Ranking Unit ID (platform-aware)
          final fallbackUnitId = Platform.isIOS
              ? PocketAdMobService.prodIosRankingAdUnitId
              : PocketAdMobService.prodRankingAdUnitId;

          if (!_hasRetriedWithFallback &&
              unitId != fallbackUnitId &&
              !PocketAdMobService.instance._isTestMode) {
            _hasRetriedWithFallback = true;
            widget.onStatusChange?.call('FALLBACK_RETRY',
                'Retrying with fallback Ranking Unit: $fallbackUnitId');
            _loadBanner(fallbackUnitId);
            return;
          }
          if (mounted) setState(() => _isLoaded = false);
        },
        onAdImpression: (_) {
          PocketAdMobService.instance
              ._recordAdImpression('legacy_${widget.placement.name}');
          widget.onStatusChange?.call('IMPRESSION', 'Ad impression recorded');
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
    super.build(context);
    if ((_isVip && !widget.forceFreeMode) || !_isLoaded) {
      return const SizedBox.shrink();
    }

    if (_bannerAd == null) {
      // 💻 Desktop / Windows / Web Native Ad Simulation (dc50278 Style)
      return Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Instagram-Style Post Header
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/pocket_mates_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF1E293B),
                          alignment: Alignment.center,
                          child: const Icon(Icons.bolt_rounded,
                              color: Color(0xFFF59E0B), size: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Pocket Mates Ads (dc50278)',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFFF59E0B),
                              size: 15,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Sponsored',
                              style: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('•',
                                style: TextStyle(
                                    color: Colors.white30, fontSize: 10)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                'Ad',
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_horiz_rounded,
                      color: Colors.white38, size: 20),
                ],
              ),
            ),
            // Simulated Instagram Content
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Center(
                      child: Text('📱', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 14),
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
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
            ),
            _buildVipUpgradeBar(context),
          ],
        ),
      );
    }

    // 📱 Production Mobile Native Ad (Instagram Feed Post Layout from dc50278)
    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 📸 Instagram-Style Post Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Row(
              children: [
                // Circular Pocket Mates Brand Avatar with subtle gold ring
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/pocket_mates_logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1E293B),
                        alignment: Alignment.center,
                        child: const Icon(Icons.bolt_rounded,
                            color: Color(0xFFF59E0B), size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Pocket Mates Ads',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFFF59E0B),
                            size: 15,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Sponsored',
                            style: GoogleFonts.outfit(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '•',
                            style:
                                TextStyle(color: Colors.white30, fontSize: 10),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Colors.white24,
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              'Ad',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz_rounded,
                      color: Colors.white38, size: 20),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  splashRadius: 18,
                  tooltip: 'Sponsored Ad by Google AdMob',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sponsored advertisement. Upgrade to Pocket VIP to remove all ads.',
                          style: GoogleFonts.outfit(fontSize: 12),
                        ),
                        backgroundColor: const Color(0xFF1E293B),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'Go VIP',
                          textColor: const Color(0xFFFFD700),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SubscriptionPage()),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 🖼️ Ad Creative Canvas (300x250 Medium Rectangle Container)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.0,
                ),
                color: Colors.black26,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
          ),

          // 👑 Sleek Yellow/Golden VIP Upgrade Button
          _buildVipUpgradeBar(context),
        ],
      ),
    );
  }

  Widget _buildVipUpgradeBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionPage()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF59E0B).withValues(alpha: 0.18),
                const Color(0xFFD97706).withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text('👑', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Go VIP – Remove All Ads',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Enjoy 100% ad-free experience & unlimited learning',
                      style: GoogleFonts.outfit(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Color(0xFFFFD700),
              ),
            ],
          ),
        ),
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
      // Fallback gracefully and reliably to PocketNativeAdCard on all platforms
      return PocketNativeAdCard(
        margin: widget.margin,
        placement: widget.placement,
        customAdUnitId: widget.customAdUnitId,
      );
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

    if ((Platform.isAndroid || Platform.isIOS) &&
        (!_isLoaded || _bannerAd == null)) {
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
                'Sponsored Ad',
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
  bool _tryMetaFallback = false;

  @override
  void initState() {
    super.initState();
    // ⚡ Fast synchronous check: if confirmed VIP, suppress immediately
    if (PocketAdMobService.instance.isUserVipSync()) {
      _isVip = true;
      return;
    }

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
          // Auto-fallback in production: retry with alternate production unit (matching platform!)
          if (!_hasRetriedWithFallback &&
              !PocketAdMobService.instance._isTestMode) {
            _hasRetriedWithFallback = true;
            final fallbackProdId = Platform.isIOS
                ? (unitId != PocketAdMobService.prodIosStandardBannerAdUnitId
                    ? PocketAdMobService.prodIosStandardBannerAdUnitId
                    : PocketAdMobService.prodIosRankingAdUnitId)
                : (unitId != PocketAdMobService.prodStandardBannerAdUnitId
                    ? PocketAdMobService.prodStandardBannerAdUnitId
                    : PocketAdMobService.prodRankingAdUnitId);
            _loadBanner(fallbackProdId);
            return;
          }
          // Seamless Tier-2 Fallback to Meta Audience Network Banner
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _tryMetaFallback = true;
            });
          }
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
    PocketAdPreloadManager.instance
        .releaseAd(PocketAdPlacement.banner, _bannerAd);
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

    // 🔄 Seamless Meta Audience Network Banner Fallback when AdMob has no fill
    if (_tryMetaFallback) {
      return PocketMetaBannerWidget();
    }

    // 📢 User Directive: If neither loaded, collapse cleanly without placeholder box.
    return const SizedBox.shrink();
  }
}
