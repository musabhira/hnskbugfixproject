import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/backend/supabase/supabase.dart';

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
  bool _isTestMode = true; // Set to false once production unit IDs are live

  // 🆔 AdMob App IDs
  static const String androidAppId = 'ca-app-pub-8489571803367790~4762910426';

  // 🎯 Google Official Safe Test Ad Unit IDs (Immediate testing without account bans)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testNativeId = 'ca-app-pub-3940256099942544/2247696110';

  // 🚀 Production Ad Unit IDs (Can be updated as user generates them in AdMob console)
  static String prodNativeAdUnitId = '';
  static String prodRewardedAdUnitId = '';
  static String prodInterstitialAdUnitId = '';
  static String prodBannerAdUnitId = '';

  String get nativeAdUnitId =>
      (!_isTestMode && prodNativeAdUnitId.isNotEmpty) ? prodNativeAdUnitId : _testNativeId;
  String get rewardedAdUnitId =>
      (!_isTestMode && prodRewardedAdUnitId.isNotEmpty) ? prodRewardedAdUnitId : _testRewardedId;
  String get interstitialAdUnitId =>
      (!_isTestMode && prodInterstitialAdUnitId.isNotEmpty) ? prodInterstitialAdUnitId : _testInterstitialId;
  String get bannerAdUnitId =>
      (!_isTestMode && prodBannerAdUnitId.isNotEmpty) ? prodBannerAdUnitId : _testBannerId;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  /// ⚡ Initialize Google Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;
      await MobileAds.instance.initialize();
      _isInitialized = true;
      preloadAds();
    } catch (e) {
      if (kDebugMode) print('PocketAdMobService initialize error: $e');
    }
  }

  /// 🛡️ Check if the current user is a VIP / Premium Member
  /// VIP Rule: Never show any ads to VIPs!
  Future<bool> isUserVip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('is_vip') == true ||
          prefs.getBool('has_vip_pass') == true ||
          prefs.getBool('is_premium') == true ||
          prefs.getBool('verified') == true ||
          prefs.getBool('is_subscribed') == true ||
          prefs.getBool('remove_ads') == true) {
        return true;
      }
      final uid = SupaFlow.client.auth.currentUser?.id;
      if (uid != null) {
        final email = SupaFlow.client.auth.currentUser?.email;
        if (email != null &&
            (email.contains('musab') || email.contains('thonippadam') || email.contains('mussabira'))) {
          return true;
        }
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
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  void _loadRewardedAd() {
    if (_isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
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
  Future<void> showInterstitialAd({BuildContext? context, VoidCallback? onDismissed}) async {
    final vip = await isUserVip();
    if (vip) {
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
                const Text(
                  'Full-screen Interstitial Ad triggered for Non-VIP player.\n\nOn mobile (Android/iOS), this shows the full Google AdMob ad overlay.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
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
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
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
      onDismissed?.call();
      _loadInterstitialAd();
    }
  }

  /// Toggle test mode
  void setTestMode(bool isTest) {
    _isTestMode = isTest;
  }
}

/// 🎨 Aesthetic Instagram-Style Native Ad Banner Widget
/// Automatically checks VIP status and suppresses itself for VIPs!
class PocketNativeAdCard extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  const PocketNativeAdCard({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

    _bannerAd = BannerAd(
      adUnitId: PocketAdMobService.instance.bannerAdUnitId,
      size: AdSize.mediumRectangle, // 300x250 Instagram feed style
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _bannerAd = null;
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
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Go Ad-Free with VIP 👑',
                style: TextStyle(color: const Color(0xFFFFD700).withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w600),
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
          const SizedBox(height: 10),
        ],
      ),
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
                  const Text(
                    'Remove ads with VIP 👑',
                    style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold),
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
