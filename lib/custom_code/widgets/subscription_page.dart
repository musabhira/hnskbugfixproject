import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pocket_mates_app/services/iap_service.dart';
import 'package:pocket_mates_app/custom_code/services/monetization_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';
import '/backend/supabase/supabase.dart';

class SubscriptionPage extends StatefulWidget {
  final double? width;
  final double? height;

  const SubscriptionPage({super.key, this.width, this.height});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with TickerProviderStateMixin {
  String _currentPlan = 'free';
  final bool _isYearly = false;
  late AnimationController _shimmerController;

  final List<Map<String, dynamic>> _vipAllBenefits = const [
    {'icon': '🚫', 'title': '100% Ad-Free Everywhere', 'desc': 'Zero banners, popups, or video interruptions across the entire app'},
    {'icon': '⚡', 'title': 'Instant 90-Day Binge Mode', 'desc': 'Unlock all 90 houses immediately with zero midnight waiting locks'},
    {'icon': '👑', 'title': 'Golden Verified VIP Tick', 'desc': 'Stand out with a Gold Tick in Chats, WhatsApp Groups & Global Ranking'},
    {'icon': '🏛️', 'title': 'Direct VIP Support with President', 'desc': 'Exclusive 2-way chat with the President to clear doubts anytime'},
    {'icon': '📜', 'title': 'Official Day 90 C2 Certificate', 'desc': 'Download your verified C2 Mastery Diploma included at no extra cost'},
    {'icon': '🔋', 'title': 'Instant +50 PS VIP Bonus (5x/Day)', 'desc': 'Tap VIP Bonus to claim +250 Pocket Score daily without watching ads'},
    {'icon': '💬', 'title': 'Unlimited Pocket Talk Pacts', 'desc': 'No 4-talk limit or 5-hour cooldown — connect with mates unlimited'},
    {'icon': '🎙️', 'title': 'Unlimited AI Voice & Pronunciation', 'desc': 'Practice speaking & get instant AI fluency feedback all day'},
    {'icon': '🌍', 'title': 'Unlimited Global Random Calls', 'desc': 'Priority WebRTC voice & video matchmaking with English learners'},
    {'icon': '🛡️', 'title': 'VIP Escort Protection', 'desc': '2 Police Escorts + 10 extra defense questions guarding your house from attackers'},
    {'icon': '⚔️', 'title': 'Unlimited Citadel Raids & Fights', 'desc': 'Challenge any learner or robot without energy restrictions'},
    {'icon': '📖', 'title': 'All 90 Houses & 17 Daily Steps', 'desc': 'Full access to Theory, Vocab, Phonics, Slang, Code English & Exams'},
    {'icon': '💼', 'title': 'IELTS & Job Interview Simulators', 'desc': 'Real-world interview & fluency practice scenarios unlocked'},
    {'icon': '🎮', 'title': 'All English Arcade & Quest Games', 'desc': 'Play every 3D open-world adventure & word factory game freely'},
    {'icon': '🤝', 'title': 'Friendship Score Boost', 'desc': 'Build faster streaks, Silver Trophies & permanent Best Mate status'},
    {'icon': '🔥', 'title': '24/7 Streak Protector', 'desc': 'Keep your learning streak & progress safely backed up in the cloud'},
    {'icon': '🏅', 'title': 'VIP Crown Badge on Leaderboard', 'desc': 'Premium gold styling on your Profile, Vibes & Ranking trail'},
    {'icon': '🎧', 'title': 'Low-Latency HD Audio Calls', 'desc': 'Priority routing for crystal-clear speaking sessions'},
    {'icon': '📚', 'title': 'All Story Cards & Vocab Decks', 'desc': 'Unlock complete idioms, phrases & reading library stories'},
    {'icon': '✨', 'title': 'Smooth, Bug-Free VIP Experience', 'desc': 'Zero ad-loader lag, zero cooldown interruptions, pure learning'},
    {'icon': '🚀', 'title': 'All Future Pro Updates Free', 'desc': 'Automatic access to upcoming AI coaches & VIP expansions'},
    {'icon': '💸', 'title': 'Just ₹3.30/Day — Cancel Anytime', 'desc': 'Unbeatable ₹99/month value; cancel anytime in Play/App Store'},
  ];

  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'monthly',
      'name': 'Poket VIP Monthly',
      'tagline': 'Just ₹3.30/day • All 22+ VIP Benefits Unlocked',
      'monthlyPrice': 99,
      'retailPrice': 499,
      'discountBadge': 'SAVE 80%',
      'periodText': '/month',
      'color': const Color(0xFFFFD700),
      'gradientColors': [Color(0xFFFFD700), Color(0xFFF59E0B)],
      'icon': Icons.flash_on_rounded,
      'popular': false,
      'features': [
        {'text': '🚫 100% Ad-Free Everywhere (Zero Interruptions)', 'included': true},
        {'text': '⚡ Instant 90-Day Binge Mode (No Midnight Locks)', 'included': true},
        {'text': '👑 Golden Verified Tick (Chat, WhatsApp & Ranking)', 'included': true},
        {'text': '🏛️ Direct 2-Way VIP Support Chat with President', 'included': true},
        {'text': '🔋 Instant +250 PS/Day VIP Bonus (No Ads)', 'included': true},
        {'text': '💬 Unlimited Pocket Talk & Global Voice Calls', 'included': true},
        {'text': '📜 Official Day 90 C2 Certificate Included', 'included': true},
        {'text': '🎙️ Unlimited AI Pronunciation & IELTS Simulators', 'included': true},
        {'text': '🛡️ Presidential Escort Guard & 24/7 Streak Protector', 'included': true},
        {'text': '🚀 Smooth Bug-Free Experience + All Future Pro Updates', 'included': true},
      ],
    },
    {
      'id': 'quarterly',
      'name': '90-Day Fluency Pass',
      'tagline': 'Complete 90-Day Mastery • All 90 Houses',
      'monthlyPrice': 249,
      'retailPrice': 1499,
      'discountBadge': 'SAVE 83%',
      'periodText': 'for 3 Months',
      'color': const Color(0xFF38BDF8),
      'gradientColors': [Color(0xFF0284C7), Color(0xFF0369A1)],
      'icon': Icons.workspace_premium_rounded,
      'popular': false,
      'features': [
        {'text': '⚡ Complete 90-Day Fluency Journey (All 90 Houses)', 'included': true},
        {'text': '🚫 100% Zero Ads for the Entire 3 Months', 'included': true},
        {'text': '👑 Golden Verified VIP Tick across Entire App', 'included': true},
        {'text': '🏛️ Direct 2-Way VIP Support Chat with President', 'included': true},
        {'text': '📜 Official Day 90 C2 Mastery Diploma Included', 'included': true},
        {'text': '🔋 Instant +250 PS/Day VIP Bonus (No Ads)', 'included': true},
        {'text': '🎙️ Unlimited AI Voice Practice & Speaking Simulators', 'included': true},
        {'text': '💬 Unlimited Pocket Talk & Community Speaking', 'included': true},
        {'text': '🛡️ Exclusive 24/7 Streak Protector & Cloud Backup', 'included': true},
      ],
    },
    {
      'id': 'yearly',
      'name': 'Poket VIP Annual Master',
      'tagline': 'Full Year Mastery • Maximum Savings',
      'monthlyPrice': 699,
      'retailPrice': 4999,
      'discountBadge': 'SAVE 86%',
      'periodText': '/year',
      'color': const Color(0xFF34D399),
      'gradientColors': [Color(0xFF10B981), Color(0xFF059669)],
      'icon': Icons.stars_rounded,
      'popular': false,
      'features': [
        {'text': '🚫 Full Year 100% Ad-Free VIP Pass', 'included': true},
        {'text': '⚡ All 90-Day Fluency Pass Features Included', 'included': true},
        {'text': '👑 Golden Verified VIP Tick & Elite Crown Profile', 'included': true},
        {'text': '🏛️ Direct 2-Way VIP Support Chat with President', 'included': true},
        {'text': '📜 Official Cryptographic Day 90 C2 Diploma Included', 'included': true},
        {'text': '🎯 IELTS & Job Interview Speaking Simulators', 'included': true},
        {'text': '🚀 Full Access to All Future VIP Expansions', 'included': true},
        {'text': '🛡️ 24/7 Priority Support & Streak Protector', 'included': true},
      ],
    },
  ];

  StreamSubscription<PurchaseDetails>? _iapSubscription;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadCurrentPlan();

    IAPService().initialize();
    _iapSubscription = IAPService().purchaseStream.listen((purchase) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _loadCurrentPlan();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 Poket VIP Successfully Activated!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _iapSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final campaign = await MonetizationService().getActiveCampaign();

    // Sync directly from Supabase profile to ensure local cache matches DB
    String loadedPlan = prefs.getString('handskill_plan') ?? 'free';
    try {
      final supabase = SupaFlow.client;
      final user = supabase.auth.currentUser;
      if (user != null) {
        final profile = await supabase
            .from('profile')
            .select('is_vip, subscription_tier, subscription_status')
            .eq('user_id', user.id)
            .maybeSingle();
        if (profile != null) {
          final isVip = profile['is_vip'] == true &&
              profile['subscription_status'] != 'inactive';
          if (!isVip) {
            loadedPlan = 'free';
            await prefs.setString('handskill_plan', 'free');
            await prefs.setBool('is_vip', false);
          } else {
            final tier = profile['subscription_tier']?.toString();
            if (tier == 'yearly' || tier == 'annual') {
              loadedPlan = 'yearly';
            } else if (tier == 'quarterly' || tier == 'quarterly_90day') {
              loadedPlan = 'quarterly';
            } else {
              loadedPlan = 'monthly';
            }
            await prefs.setString('handskill_plan', loadedPlan);
            await prefs.setBool('is_vip', true);
          }
        }
      }
    } catch (e) {
      debugPrint('Error syncing profile plan in subscription page: $e');
    }

    if (mounted) {
      setState(() {
        _currentPlan = loadedPlan;
        // Dynamically reflect active prices from admin campaign & App Store
        for (final p in _plans) {
          final prod = IAPService().getProduct(p['id'] as String);
          if (prod != null && prod.price.isNotEmpty) {
            p['storeKitPrice'] = prod.price;
          }

          if (p['id'] == 'monthly') {
            p['monthlyPrice'] = campaign.inAppMonthlyPrice;
            p['retailPrice'] = campaign.inAppMonthlyRetailPrice;
            p['tagline'] =
                '₹${campaign.inAppMonthlyPrice}/mo • Ad-Free + Instant 90-Day Binge';
          } else if (p['id'] == 'quarterly') {
            p['monthlyPrice'] = campaign.inAppQuarterlyPrice;
            p['retailPrice'] = campaign.inAppQuarterlyRetailPrice;
            p['tagline'] =
                '₹${campaign.inAppQuarterlyPrice} • Complete 90-Day Mastery';
          } else if (p['id'] == 'yearly') {
            p['monthlyPrice'] = campaign.inAppYearlyPrice;
            p['retailPrice'] = campaign.inAppYearlyRetailPrice;
            p['tagline'] =
                '₹${campaign.inAppYearlyPrice}/yr • Full Year + C2 Diploma';
          }
        }
      });
    }
  }

  static const bool _allowDirectUpi =
      false; // Strictly false for official Google Play & Apple App Store compliance

  Future<void> _selectPlan(String planId) async {
    if (planId == _currentPlan) return;

    final plan =
        _plans.firstWhere((p) => p['id'] == planId, orElse: () => _plans.first);
    final price = plan['monthlyPrice'] as int;

    if (!mounted) return;

    // Google Play & Apple App Store Policy: Must use official In-App Purchases for digital goods
    if (!_allowDirectUpi) {
      final messenger = ScaffoldMessenger.of(context);
      HapticFeedback.mediumImpact();
      final planType = plan['id'] as String? ?? 'monthly';

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  Platform.isIOS
                      ? 'Connecting to App Store In-App Purchases...'
                      : 'Connecting to Google Play In-App Billing...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E293B),
          duration: const Duration(seconds: 3),
        ),
      );

      final initiated = await IAPService().buyVipSubscription(
        isYearly: planType == 'yearly',
        planType: planType,
      );
      if (!initiated && mounted) {
        final errorDetail = IAPService().lastError;
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              Platform.isIOS
                  ? (errorDetail != null
                      ? '⚠️ App Store: $errorDetail'
                      : '⚠️ Connecting to Apple App Store. Subscription will become available as soon as Apple finishes activation.')
                  : '⚠️ Google Play In-App Billing could not be reached. Please check your network connection.',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF1E293B),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Direct UPI mode (only for external non-Play Store builds)
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131722),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Choose Payment Method',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Upgrade to ${plan['name']} (₹$price/${_isYearly ? 'year' : 'month'})',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Option 1: Official Store Billing (Google Play / Apple In-App Purchase)
              InkWell(
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(ctx);
                  HapticFeedback.mediumImpact();
                  final planType = plan['id'] as String? ??
                      (_isYearly ? 'yearly' : 'monthly');
                  final initiated = await IAPService().buyVipSubscription(
                    isYearly: _isYearly,
                    planType: planType,
                  );
                  if (!initiated && mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          Platform.isIOS
                              ? 'Connecting to App Store In-App Purchases...'
                              : 'Google Play Billing loading... You can also use Direct UPI below.',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: const Color(0xFF1E293B),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: const Color(0xFFFFD700), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Platform.isIOS
                              ? Icons.apple_rounded
                              : Icons.shop_two_rounded,
                          color: const Color(0xFFFFD700),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Platform.isIOS
                                  ? 'Apple Pay (App Store) 🍏'
                                  : 'Google Play Billing ⚡',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              Platform.isIOS
                                  ? '1-Tap Apple Touch/Face ID • Official In-App Purchase'
                                  : '1-Tap Secure Payment • Official Store Checkout',
                              style: GoogleFonts.inter(
                                  color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white54, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Option 2: Direct Indian UPI (Android only - hidden on iOS for App Store compliance)
              if (!Platform.isIOS) ...[
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: const Color(0xFF131722),
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      builder: (_) => _buildDirectUpiPaymentSheet(plan, price),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D2B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF0F9D58).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Color(0xFF0F9D58),
                              size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Direct Indian UPI (GPay / PhonePe)',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Pay via any UPI App • Instant activation',
                                style: GoogleFonts.inter(
                                    color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white54, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDirectUpiPaymentSheet(Map<String, dynamic> plan, int price) {
    final finalPrice = (plan['trialPrice'] != null && plan['trialPrice'] > 0)
        ? plan['trialPrice'] as int
        : price;

    final phoneController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header summary
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (plan['color'] as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color:
                              (plan['color'] as Color).withValues(alpha: 0.4)),
                    ),
                    child: Icon(plan['icon'] as IconData,
                        color: plan['color'] as Color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${plan['name']} VIP Subscription',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Instant 100% Ad-Free & Verified VIP',
                          style: GoogleFonts.inter(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹$finalPrice',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFFC00),
                        ),
                      ),
                      Text(
                        _isYearly ? '/year' : '/month',
                        style: GoogleFonts.inter(
                            color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Divider(color: Colors.white12),
              const SizedBox(height: 12),

              Text(
                '⚡ Direct UPI Fast Pay (0% Extra Fee)',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // Fast UPI Options Grid (Google Pay, PhonePe, Paytm, Any UPI)
              Row(
                children: [
                  Expanded(
                    child: _buildUpiAppTile(
                      name: 'Google Pay',
                      emoji: '🟢',
                      color: const Color(0xFF0F9D58),
                      onTap: () => _launchUpiIntentAndStartTimer(
                        appName: 'Google Pay',
                        price: finalPrice,
                        plan: plan,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildUpiAppTile(
                      name: 'PhonePe',
                      emoji: '🟣',
                      color: const Color(0xFF5F259F),
                      onTap: () => _launchUpiIntentAndStartTimer(
                        appName: 'PhonePe',
                        price: finalPrice,
                        plan: plan,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildUpiAppTile(
                      name: 'Paytm UPI',
                      emoji: '🔵',
                      color: const Color(0xFF00BAF2),
                      onTap: () => _launchUpiIntentAndStartTimer(
                        appName: 'Paytm',
                        price: finalPrice,
                        plan: plan,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildUpiAppTile(
                      name: 'Any UPI App',
                      emoji: '⚡',
                      color: const Color(0xFFFFFC00),
                      textColor: Colors.black,
                      onTap: () => _launchUpiIntentAndStartTimer(
                        appName: 'UPI App',
                        price: finalPrice,
                        plan: plan,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Or Pay using Mobile Number / UPI ID
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2333),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_android_rounded,
                        color: Colors.white54, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.inter(
                            color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Enter UPI Number / Phone',
                          hintStyle: GoogleFonts.inter(
                              color: Colors.white38, fontSize: 13),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final val = phoneController.text.trim();
                        if (val.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please enter phone number or UPI ID',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: const Color(0xFF1E293B),
                            ),
                          );
                          return;
                        }
                        _launchUpiIntentAndStartTimer(
                          appName: 'UPI ($val)',
                          price: finalPrice,
                          plan: plan,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFC00),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(60, 34),
                      ),
                      child: Text(
                        'Pay',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded,
                      color: Color(0xFF10B981), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Direct 100% Encrypted UPI • NPCI & Bank Secured',
                    style:
                        GoogleFonts.inter(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpiAppTile({
    required String name,
    required String emoji,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              name,
              style: GoogleFonts.outfit(
                color: textColor == Colors.black
                    ? const Color(0xFFFFFC00)
                    : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Launch UPI Deeplink and Open 5-Minute Confirmation Timer Dialog (Flipkart/IRCTC Style)
  Future<void> _launchUpiIntentAndStartTimer({
    required String appName,
    required int price,
    required Map<String, dynamic> plan,
  }) async {
    Navigator.pop(context); // Close bottom sheet

    // Standard NPCI UPI URI Scheme
    final upiUri = Uri.parse(
      'upi://pay?pa=handskill@okaxis&pn=PoketMates&am=$price&cu=INR&tn=VIP_Plan_${plan['id']}',
    );

    try {
      if (await canLaunchUrl(upiUri)) {
        await launchUrl(upiUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback web / GPay link
        final webFallback = Uri.parse('https://gpay.app.goo.gl/');
        if (await canLaunchUrl(webFallback)) {
          await launchUrl(webFallback, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('UPI launch note: $e');
    }

    if (!mounted) return;

    // Show 5-Minute Railway / Flipkart Confirmation Timer Dialog
    _showPaymentConfirmationTimerDialog(
        appName: appName, price: price, plan: plan);
  }

  /// 5-Minute Awaiting Payment Verification Dialog
  void _showPaymentConfirmationTimerDialog({
    required String appName,
    required int price,
    required Map<String, dynamic> plan,
  }) {
    int secondsLeft = 300; // 5 minutes
    Timer? countdownTimer;
    final utrController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (secondsLeft > 0) {
                setDialogState(() => secondsLeft--);
              } else {
                t.cancel();
              }
            });

            final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
            final seconds = (secondsLeft % 60).toString().padLeft(2, '0');

            return Dialog(
              backgroundColor: const Color(0xFF131722),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                    width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Timer & Animation
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFFFFC00), width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.hourglass_top_rounded,
                            color: Color(0xFFFFFC00), size: 34),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Waiting for UPI Payment',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Please complete payment of ₹$price in $appName and return here.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 14),

                    // Countdown Clock
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2333),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined,
                              color: Color(0xFFFFFC00), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '$minutes:$seconds',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFFC00),
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Optional UTR input for instant manual validation
                    TextField(
                      controller: utrController,
                      keyboardType: TextInputType.number,
                      style:
                          GoogleFonts.inter(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Optional: Enter 12-digit UPI UTR / Ref No',
                        hintStyle: GoogleFonts.inter(
                            color: Colors.white38, fontSize: 11),
                        filled: true,
                        fillColor: const Color(0xFF1A1F2C),
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          countdownTimer?.cancel();
                          Navigator.pop(dialogContext);

                          final messenger = ScaffoldMessenger.of(context);
                          // Instant Activation & Upgrade
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                              'handskill_plan', plan['id'] as String);
                          setState(() => _currentPlan = plan['id'] as String);

                          HapticFeedback.heavyImpact();

                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  '🎉 Payment Successful! ${plan['name']} VIP Activated!',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF10B981),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFC00),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'I Have Completed Payment ✓',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: () {
                        countdownTimer?.cancel();
                        Navigator.pop(dialogContext);
                      },
                      child: Text(
                        'Cancel Payment',
                        style: GoogleFonts.inter(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      countdownTimer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C12),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: _currentPlan == 'free' ? 245 : 190,
            pinned: true,
            backgroundColor: const Color(0xFF090C12),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF141B2D), Color(0xFF090C12)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 36),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          '✦ POKET MATES VIP',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ad-Free English Master',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Zero Ads • Instant 90-Day Binge Mode • Global Mates',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_currentPlan == 'free')
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => _selectPlan('monthly'),
                            icon: const Icon(Icons.bolt_rounded, size: 19),
                            label: Text(
                              'Unlock All 22+ VIP Benefits • ₹99/mo',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Current Plan banner (Shown ONLY when VIP is active)
          if (_currentPlan != 'free' &&
              _plans.any((p) => p['id'] == _currentPlan))
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF141B2D), Color(0xFF0F172A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.45)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          color: Color(0xFFFFD700), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Active Plan: ${_plans.firstWhere((p) => p['id'] == _currentPlan)['name']}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF34D399),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 3 Standard Story-Card Plan Cards (Each with full details & direct Buy button)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildPlanCard(_plans[index]),
              childCount: _plans.length,
            ),
          ),

          // Coming Soon + Complete 22-Point VIP Value Stack + VIP Direct Support + Legal Links
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
              child: Column(
                children: [
                  // 🔥 Complete 22-Point Value Stack Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111726),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '👑 EVERYTHING YOU UNLOCK WITH POKET VIP',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All 22+ premium features included starting at ₹99/month:',
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ..._vipAllBenefits.map(
                          (b) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b['icon']!,
                                    style: const TextStyle(fontSize: 15)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b['title']!,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        b['desc']!,
                                        style: GoogleFonts.inter(
                                          color: Colors.white54,
                                          fontSize: 11.5,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF16132E), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🚀', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'More Exclusive VIP Features Coming Soon!',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Active VIP members automatically receive all upcoming AI voice coaches, priority matchmaking & VIP expansions at zero extra cost!',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 🏛️ VIP Direct Support (Chat with President / Admin)
                  _buildVipDirectSupportCard(),
                  const SizedBox(height: 18),

                  const Divider(color: Colors.white12),
                  const SizedBox(height: 14),
                  Text(
                    '🔒 Real-time AI encryption • 100% Secure calls\n⚡ Low latency WebRTC voice & video\n🌏 Connect with spoken English learners worldwide',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        color: Colors.white38, fontSize: 12.5, height: 1.75),
                  ),
                  const SizedBox(height: 14),

                  TextButton.icon(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Checking store for previous purchases...',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: const Color(0xFF1E293B),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      await IAPService().restorePurchases();
                      await _loadCurrentPlan();
                    },
                    icon: const Icon(Icons.restore_rounded,
                        color: Color(0xFFFFD700), size: 18),
                    label: Text(
                      'Restore Purchases',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => launchUrl(
                          Uri.parse('https://pocketmates.app/terms'),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Text(
                          'Terms of Use',
                          style: GoogleFonts.inter(
                            color: Colors.white38,
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Text('  •  ',
                          style:
                              TextStyle(color: Colors.white24, fontSize: 11)),
                      InkWell(
                        onTap: () => launchUrl(
                          Uri.parse('https://pocketmates.app/privacy'),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Text(
                          'Privacy Policy',
                          style: GoogleFonts.inter(
                            color: Colors.white38,
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final isSelected = _currentPlan == plan['id'];
    final isPopular = plan['popular'] as bool;
    final popularLabel =
        (plan['popularLabel'] as String?) ?? '★ MOST POPULAR';
    final color = plan['color'] as Color;
    final price = plan['monthlyPrice'] as int;
    final features = plan['features'] as List<Map<String, dynamic>>;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111726),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? color
                : (isPopular
                    ? color.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.08)),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.32),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Card Header (Story-Card inspired gradient + responsive Wrap badges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: (plan['gradientColors'] as List<Color>)
                      .map((c) => c.withValues(alpha: 0.14))
                      .toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(21)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPopular || plan['discountBadge'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                popularLabel,
                                style: GoogleFonts.outfit(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          if (plan['discountBadge'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: const Color(0xFF10B981), width: 1),
                              ),
                              child: Text(
                                plan['discountBadge'] as String,
                                style: GoogleFonts.outfit(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF34D399),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(plan['icon'] as IconData,
                            color: color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              plan['name'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              plan['tagline'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: Colors.white60,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (plan['retailPrice'] != null &&
                              (plan['retailPrice'] as int) > 0)
                            Text(
                              '₹${plan['retailPrice']}',
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                color: Colors.white38,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.white38,
                              ),
                            ),
                          Text(
                            (plan['storeKitPrice'] as String?) ??
                                (price == 0 ? 'FREE' : '₹$price'),
                            style: GoogleFonts.outfit(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: color,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (price > 0)
                            Text(
                              plan['periodText'] != null &&
                                      (plan['periodText'] as String).isNotEmpty
                                  ? plan['periodText'] as String
                                  : (_isYearly ? '/year' : '/month'),
                              style: GoogleFonts.outfit(
                                color: Colors.white54,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Features & Per-Card Direct Buy Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...features.take(6).map((f) => _buildFeatureRow(f, color)),
                  if (features.length > 6)
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          'See all features',
                          style: GoogleFonts.outfit(color: color, fontSize: 13),
                        ),
                        iconColor: color,
                        collapsedIconColor: color,
                        children: [
                          ...features
                              .skip(6)
                              .map((f) => _buildFeatureRow(f, color)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Colors.white10
                            : (isPopular
                                ? color
                                : color.withValues(alpha: 0.16)),
                        foregroundColor: isSelected
                            ? Colors.white54
                            : (isPopular ? Colors.black : color),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: isSelected
                          ? null
                          : () => _selectPlan(plan['id'] as String),
                      child: Text(
                        isSelected
                            ? '✓ Active Plan'
                            : 'Get ${plan['name']} • ${(plan['storeKitPrice'] as String?) ?? '₹$price'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(Map<String, dynamic> feature, Color planColor) {
    final included = feature['included'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              included ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 16,
              color: included ? planColor : Colors.white12,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature['text'] as String,
              style: GoogleFonts.outfit(
                color: included ? Colors.white70 : Colors.white24,
                fontSize: 13,
                decoration: included ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipDirectSupportCard() {
    final bool isVip = _currentPlan != 'free';
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (!isVip) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF0F172A),
              behavior: SnackBarBehavior.floating,
              content: Text(
                '🔒 VIP Only: Upgrade to Poket VIP (₹99/mo) to chat directly with the President & clear your doubts!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
          return;
        }
        _openVipPresidentChatSheet();
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isVip
                ? [const Color(0xFF064E3B), const Color(0xFF0F172A)]
                : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isVip
                ? const Color(0xFF10B981)
                : const Color(0xFFFFD700).withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isVip
                        ? const Color(0xFF10B981)
                        : const Color(0xFFFFD700))
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isVip ? Icons.support_agent_rounded : Icons.lock_rounded,
                color: isVip
                    ? const Color(0xFF34D399)
                    : const Color(0xFFFFD700),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'VIP Direct Support • Chat with President',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isVip
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFFFD700))
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isVip ? 'UNLOCKED' : 'VIP ONLY',
                          style: GoogleFonts.outfit(
                            color: isVip
                                ? const Color(0xFF34D399)
                                : const Color(0xFFFFD700),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isVip
                        ? 'Tap to message the President directly & get personal guidance'
                        : 'Unlock 2-way direct chat with Admin & President for ₹99/mo',
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isVip ? const Color(0xFF34D399) : Colors.white38,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openVipPresidentChatSheet() async {
    final uid = SupaFlow.client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) return;

    final controller = TextEditingController();
    List<Map<String, dynamic>> messages =
        await PocketPresidentService.getPresidentChatHistory(uid);
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        bool isSending = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.72,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 14,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 14,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('🏛️', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'VIP Direct Support • President Desk',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Exclusive 2-way support for Poket VIP members',
                                style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white70, size: 20),
                          onPressed: () async {
                            final latest = await PocketPresidentService
                                .getPresidentChatHistory(uid);
                            setSheetState(() => messages = latest);
                          },
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12),
                    Expanded(
                      child: messages.isEmpty
                          ? Center(
                              child: Text(
                                'Ask any English doubt or app question directly to the President! 👑',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : ListView.builder(
                              reverse: true,
                              itemCount: messages.length,
                              itemBuilder: (_, i) {
                                final m = messages[i];
                                final isMe = m['sender_id'] == uid;
                                return Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 9),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(ctx).size.width * 0.75,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? const Color(0xFF0284C7)
                                          : const Color(0xFF1E293B),
                                      borderRadius: BorderRadius.circular(14),
                                      border: isMe
                                          ? null
                                          : Border.all(
                                              color: const Color(0xFFFFD700)
                                                  .withValues(alpha: 0.3),
                                            ),
                                    ),
                                    child: Text(
                                      (m['message_text'] ?? '').toString(),
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Write your message to President...',
                              hintStyle: const TextStyle(
                                  color: Colors.white38, fontSize: 12.5),
                              filled: true,
                              fillColor: const Color(0xFF1E293B),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: isSending
                              ? null
                              : () async {
                                  final text = controller.text.trim();
                                  if (text.isEmpty) return;
                                  setSheetState(() => isSending = true);
                                  controller.clear();
                                  await PocketPresidentService
                                      .sendUserMessageToPresident(
                                    userId: uid,
                                    messageText: text,
                                    metadata: const {
                                      'is_vip_support': true,
                                      'source': 'subscription_page_vip_chat',
                                    },
                                  );
                                  final latest = await PocketPresidentService
                                      .getPresidentChatHistory(uid);
                                  setSheetState(() {
                                    messages = latest;
                                    isSending = false;
                                  });
                                },
                          icon: isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xFFFFD700)),
                                )
                              : const Icon(Icons.send_rounded,
                                  color: Color(0xFFFFD700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
