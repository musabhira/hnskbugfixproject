import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_audience_network/easy_audience_network.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pocket_admob_service.dart';

/// 📘 Official Meta Audience Network (Facebook Ads) Integration for Pocket Mates
class PocketMetaAdsService {
  static final PocketMetaAdsService instance = PocketMetaAdsService._internal();
  factory PocketMetaAdsService() => instance;
  PocketMetaAdsService._internal();

  /// Meta App ID
  static const String appId = '1618397890087770';

  // 1. Banner (320x50)
  static const String androidBannerPlacementId = '1618397890087770_1618398040087755';
  static const String iosBannerPlacementId = '1618397890087770_1618398056754420';

  // 2. Interstitial (Full Screen)
  static const String androidInterstitialPlacementId = '1618397890087770_1618398063421086';
  static const String iosInterstitialPlacementId = '1618397890087770_1618398060087753';

  // 3. Medium Rectangle (MREC 300x250)
  static const String androidMrecPlacementId = '1618397890087770_1618398066754419';
  static const String iosMrecPlacementId = '1618397890087770_1618398070087752';

  // 4. Native Ads (Social / Feed Cards)
  static const String androidNativePlacementId = '1618397890087770_1618398073421085';
  static const String iosNativePlacementId = '1618397890087770_1618398043421088';

  // 5. Native Banner (Compact 100 height)
  static const String androidNativeBannerPlacementId = '1618397890087770_1618398036754422';
  static const String iosNativeBannerPlacementId = '1618397890087770_1618398053421087';

  // 6. Rewarded Interstitial
  static const String androidRewardedPlacementId = '1618397890087770_1618398046754421';
  static const String iosRewardedPlacementId = '1618397890087770_1618398050087754';

  bool _isInitialized = false;
  bool _isTestMode = kDebugMode;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoaded = false;

  /// Get platform-specific placement ID for Banner
  static String get bannerPlacementId =>
      Platform.isIOS ? iosBannerPlacementId : androidBannerPlacementId;

  /// Get platform-specific placement ID for Interstitial
  static String get interstitialPlacementId =>
      Platform.isIOS ? iosInterstitialPlacementId : androidInterstitialPlacementId;

  /// Get platform-specific placement ID for Medium Rectangle (MREC)
  static String get mrecPlacementId =>
      Platform.isIOS ? iosMrecPlacementId : androidMrecPlacementId;

  /// Get platform-specific placement ID for Native
  static String get nativePlacementId =>
      Platform.isIOS ? iosNativePlacementId : androidNativePlacementId;

  /// Get platform-specific placement ID for Native Banner
  static String get nativeBannerPlacementId =>
      Platform.isIOS ? iosNativeBannerPlacementId : androidNativeBannerPlacementId;

  /// Get platform-specific placement ID for Rewarded
  static String get rewardedPlacementId =>
      Platform.isIOS ? iosRewardedPlacementId : androidRewardedPlacementId;

  /// 🚀 Initialize Meta Audience Network
  Future<void> initialize({bool? testMode}) async {
    if (_isInitialized) return;
    _isTestMode = testMode ?? kDebugMode;

    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        return;
      }

      await EasyAudienceNetwork.init(
        testMode: _isTestMode,
        iOSAdvertiserTrackingEnabled: true,
      );
      _isInitialized = true;
      if (kDebugMode) {
        print('✅ Meta Audience Network initialized successfully (testMode: $_isTestMode)');
      }

      // Preload full-screen ads in background
      preloadInterstitial();
      preloadRewarded();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Meta Audience Network init error: $e');
      }
    }
  }

  /// 📥 Preload Interstitial Ad
  void preloadInterstitial() {
    if (PocketAdMobService.instance.isUserVipSync()) return;

    try {
      _interstitialAd?.destroy();
      _isInterstitialLoaded = false;

      final ad = InterstitialAd(interstitialPlacementId);
      ad.listener = InterstitialAdListener(
        onLoaded: () {
          _isInterstitialLoaded = true;
          if (kDebugMode) print('✅ Meta Interstitial Ad loaded');
        },
        onError: (code, message) {
          _isInterstitialLoaded = false;
          if (kDebugMode) print('⚠️ Meta Interstitial Ad error: code=$code, msg=$message');
        },
        onDismissed: () {
          _isInterstitialLoaded = false;
          ad.destroy();
          preloadInterstitial();
        },
      );
      ad.load();
      _interstitialAd = ad;
    } catch (e) {
      if (kDebugMode) print('⚠️ Meta Interstitial preload error: $e');
    }
  }

  /// 🎬 Show Interstitial Ad (returns true if shown, false otherwise)
  Future<bool> showInterstitialAd() async {
    if (await PocketAdMobService.instance.isUserVip()) return false;

    if (_interstitialAd != null && _isInterstitialLoaded) {
      try {
        await _interstitialAd!.show();
        _isInterstitialLoaded = false;
        return true;
      } catch (e) {
        if (kDebugMode) print('⚠️ Error showing Meta Interstitial: $e');
      }
    }
    preloadInterstitial();
    return false;
  }

  /// 📥 Preload Rewarded Video Ad
  void preloadRewarded() {
    if (PocketAdMobService.instance.isUserVipSync()) return;

    try {
      _rewardedAd?.destroy();
      _isRewardedLoaded = false;

      final ad = RewardedAd(rewardedPlacementId);
      ad.listener = RewardedAdListener(
        onLoaded: () {
          _isRewardedLoaded = true;
          if (kDebugMode) print('✅ Meta Rewarded Ad loaded');
        },
        onError: (code, message) {
          _isRewardedLoaded = false;
          if (kDebugMode) print('⚠️ Meta Rewarded Ad error: code=$code, msg=$message');
        },
        onVideoClosed: () {
          _isRewardedLoaded = false;
          ad.destroy();
          preloadRewarded();
        },
      );
      ad.load();
      _rewardedAd = ad;
    } catch (e) {
      if (kDebugMode) print('⚠️ Meta Rewarded preload error: $e');
    }
  }

  /// 🎁 Show Rewarded Ad with Reward Callback
  Future<bool> showRewardedAd({required VoidCallback onUserEarnedReward}) async {
    if (await PocketAdMobService.instance.isUserVip()) return false;

    if (_rewardedAd != null && _isRewardedLoaded) {
      try {
        _rewardedAd!.listener = RewardedAdListener(
          onVideoComplete: () {
            onUserEarnedReward();
          },
          onVideoClosed: () {
            _isRewardedLoaded = false;
            _rewardedAd?.destroy();
            preloadRewarded();
          },
        );
        await _rewardedAd!.show();
        return true;
      } catch (e) {
        if (kDebugMode) print('⚠️ Error showing Meta Rewarded: $e');
      }
    }
    preloadRewarded();
    return false;
  }
}

/// 🎨 Instagram / Reels Style Meta Native Ad Widget
/// Blends seamlessly into Pocket Homes Reels, Thoughts Social Feed, and Explore
class PocketMetaNativeFeedCard extends StatefulWidget {
  final VoidCallback? onAdClosed;
  const PocketMetaNativeFeedCard({super.key, this.onAdClosed});

  @override
  State<PocketMetaNativeFeedCard> createState() => _PocketMetaNativeFeedCardState();
}

class _PocketMetaNativeFeedCardState extends State<PocketMetaNativeFeedCard> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (PocketAdMobService.instance.isUserVipSync() || _hasError) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Sponsored tag
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFD700)),
                      const SizedBox(width: 4),
                      Text(
                        'SPONSORED',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFFD700),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Meta Partner',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),

          // Native Ad Content
          NativeAd(
            placementId: PocketMetaAdsService.nativePlacementId,
            adType: NativeAdType.NATIVE_AD,
            width: double.infinity,
            backgroundColor: const Color(0xFF0F172A),
            titleColor: Colors.white,
            descriptionColor: Colors.white70,
            buttonColor: const Color(0xFF0284C7),
            buttonTitleColor: Colors.white,
            buttonBorderColor: const Color(0xFF38BDF8),
            listener: NativeAdListener(
              onError: (code, message) {
                if (kDebugMode) print('Meta Native Ad error: code=$code, msg=$message');
                if (mounted) setState(() => _hasError = true);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 📱 Compact Meta Native Banner Widget (ideal for Roadmap houses & Leaderboard)
class PocketMetaNativeBannerWidget extends StatefulWidget {
  const PocketMetaNativeBannerWidget({super.key});

  @override
  State<PocketMetaNativeBannerWidget> createState() => _PocketMetaNativeBannerWidgetState();
}

class _PocketMetaNativeBannerWidgetState extends State<PocketMetaNativeBannerWidget> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (PocketAdMobService.instance.isUserVipSync() || _hasError) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1.0),
      ),
      child: NativeAd(
        placementId: PocketMetaAdsService.nativeBannerPlacementId,
        adType: NativeAdType.NATIVE_BANNER_AD,
        bannerAdSize: NativeBannerAdSize.HEIGHT_100,
        width: double.infinity,
        backgroundColor: const Color(0xFF0F172A),
        titleColor: Colors.white,
        descriptionColor: Colors.white70,
        buttonColor: const Color(0xFF10B981),
        buttonTitleColor: Colors.white,
        buttonBorderColor: Colors.transparent,
        listener: NativeAdListener(
          onError: (code, message) {
            if (mounted) setState(() => _hasError = true);
          },
        ),
      ),
    );
  }
}

/// 📐 Meta Medium Rectangle Widget (MREC 300x250)
/// High eCPM unit for Victory screens, Day Reviews, and Quest modals
class PocketMetaMrecWidget extends StatefulWidget {
  const PocketMetaMrecWidget({super.key});

  @override
  State<PocketMetaMrecWidget> createState() => _PocketMetaMrecWidgetState();
}

class _PocketMetaMrecWidgetState extends State<PocketMetaMrecWidget> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (PocketAdMobService.instance.isUserVipSync() || _hasError) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        clipBehavior: Clip.antiAlias,
        child: BannerAd(
          placementId: PocketMetaAdsService.mrecPlacementId,
          bannerSize: BannerSize.MEDIUM_RECTANGLE,
          listener: BannerAdListener(
            onError: (code, msg) {
              if (mounted) setState(() => _hasError = true);
            },
          ),
        ),
      ),
    );
  }
}

/// 📏 Standard Meta Banner Widget (320x50)
class PocketMetaBannerWidget extends StatefulWidget {
  const PocketMetaBannerWidget({super.key});

  @override
  State<PocketMetaBannerWidget> createState() => _PocketMetaBannerWidgetState();
}

class _PocketMetaBannerWidgetState extends State<PocketMetaBannerWidget> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (PocketAdMobService.instance.isUserVipSync() || _hasError) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      color: Colors.transparent,
      child: BannerAd(
        placementId: PocketMetaAdsService.bannerPlacementId,
        bannerSize: BannerSize.STANDARD,
        listener: BannerAdListener(
          onError: (code, msg) {
            if (mounted) setState(() => _hasError = true);
          },
        ),
      ),
    );
  }
}

/// 🔄 Smart Dual Banner (AdMob + Meta Ads Dual Network Rotation)
/// Solves banner non-loading issues: Rotates between Google AdMob and Meta Audience Network!
class PocketSmartDualBannerWidget extends StatefulWidget {
  final PocketAdPlacement placement;
  final EdgeInsetsGeometry margin;
  const PocketSmartDualBannerWidget({
    super.key,
    this.placement = PocketAdPlacement.banner,
    this.margin = const EdgeInsets.symmetric(vertical: 4),
  });

  @override
  State<PocketSmartDualBannerWidget> createState() => _PocketSmartDualBannerWidgetState();
}

class _PocketSmartDualBannerWidgetState extends State<PocketSmartDualBannerWidget> {
  late final bool _showMetaBanner;

  @override
  void initState() {
    super.initState();
    // 50/50 dual network rotation per session / minute
    _showMetaBanner = DateTime.now().second % 2 == 1;
  }

  @override
  Widget build(BuildContext context) {
    if (PocketAdMobService.instance.isUserVipSync()) {
      return const SizedBox.shrink();
    }

    if (_showMetaBanner) {
      return const PocketMetaBannerWidget();
    }

    return PocketBannerAdWidget(
      margin: widget.margin,
    );
  }
}

