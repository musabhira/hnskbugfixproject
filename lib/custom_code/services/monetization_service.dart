import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';

class HousePromoCampaign {
  final String id;
  final String title;
  final String subtitle;
  final String discountBadge;
  final String ctaText;
  final String webCheckoutUrl;
  final int inAppMonthlyPrice;
  final int inAppYearlyPrice;
  final String upiId;
  final String targetPlatform; // 'all', 'ios', 'android'
  final bool isActive;

  const HousePromoCampaign({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.discountBadge,
    required this.ctaText,
    required this.webCheckoutUrl,
    required this.inAppMonthlyPrice,
    required this.inAppYearlyPrice,
    required this.upiId,
    required this.targetPlatform,
    required this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'discount_badge': discountBadge,
        'cta_text': ctaText,
        'web_checkout_url': webCheckoutUrl,
        'monthly_price': inAppMonthlyPrice,
        'yearly_price': inAppYearlyPrice,
        'upi_id': upiId,
        'target_platform': targetPlatform,
        'is_active': isActive,
      };

  factory HousePromoCampaign.fromJson(Map<String, dynamic> json) {
    return HousePromoCampaign(
      id: json['id']?.toString() ?? 'default_pro',
      title: json['title']?.toString() ?? 'Upgrade to Pocket Mates Pro ✨',
      subtitle: json['subtitle']?.toString() ??
          '100% Ad-Free • Unlimited AI • 1000+ Free Classics & Pro Tools',
      discountBadge: json['discount_badge']?.toString() ?? 'LIMITED OFFER: 50% OFF',
      ctaText: json['cta_text']?.toString() ?? 'Claim Pro Offer',
      webCheckoutUrl: json['web_checkout_url']?.toString() ??
          'https://pocketmates.app/premium?ref=app_promo',
      inAppMonthlyPrice: int.tryParse(json['monthly_price']?.toString() ?? '199') ?? 199,
      inAppYearlyPrice: int.tryParse(json['yearly_price']?.toString() ?? '1799') ?? 1799,
      upiId: json['upi_id']?.toString() ?? 'pocketmates@upi',
      targetPlatform: json['target_platform']?.toString() ?? 'all',
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == 'true',
    );
  }
}

class MonetizationService {
  static final MonetizationService _instance = MonetizationService._internal();
  factory MonetizationService() => _instance;
  MonetizationService._internal();

  static const String _localCampaignKey = 'pocket_house_promo_campaign';
  static const String _houseAdsEnabledKey = 'pocket_house_ads_enabled';

  HousePromoCampaign _cachedCampaign = const HousePromoCampaign(
    id: 'default_pro',
    title: 'Unlock Pocket Mates VIP Pro 🚀',
    subtitle: 'Zero Ads • Unlimited AI • 70k+ Books • 4K Poster Studio & Offline Tools',
    discountBadge: 'SPECIAL DEAL • 50% OFF',
    ctaText: 'Upgrade Now',
    webCheckoutUrl: 'https://pocketmates.app/premium',
    inAppMonthlyPrice: 199,
    inAppYearlyPrice: 1799,
    upiId: 'pocketmates@upi',
    targetPlatform: 'all',
    isActive: true,
  );

  /// Load campaign from cache or Supabase
  Future<HousePromoCampaign> getActiveCampaign() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_localCampaignKey);
      if (cachedJson != null) {
        _cachedCampaign = HousePromoCampaign.fromJson(jsonDecode(cachedJson));
      }

      // Attempt Supabase fetch if online
      try {
        final res = await SupaFlow.client
            .from('app_promo_campaigns')
            .select('*')
            .eq('is_active', true)
            .limit(1);

        if (res.isNotEmpty) {
          final serverCampaign = HousePromoCampaign.fromJson(res.first);
          _cachedCampaign = serverCampaign;
          await prefs.setString(_localCampaignKey, jsonEncode(serverCampaign.toJson()));
        }
      } catch (_) {
        // Fallback to local cached campaign
      }
    } catch (_) {}

    return _cachedCampaign;
  }

  /// Check whether house ads should display on current device
  Future<bool> shouldShowHouseAd() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_houseAdsEnabledKey) ?? true;
      if (!isEnabled) return false;

      // Check if user is already VIP subscriber
      final currentPlan = prefs.getString('handskill_plan') ?? 'free';
      if (currentPlan != 'free') return false;

      final campaign = await getActiveCampaign();
      if (!campaign.isActive) return false;

      if (campaign.targetPlatform == 'all') return true;
      if (campaign.targetPlatform == 'ios' && Platform.isIOS) return true;
      if (campaign.targetPlatform == 'android' && Platform.isAndroid) return true;

      return false;
    } catch (_) {
      return true;
    }
  }

  /// Save campaign from Admin Panel
  Future<bool> saveCampaign(HousePromoCampaign campaign) async {
    try {
      _cachedCampaign = campaign;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localCampaignKey, jsonEncode(campaign.toJson()));

      // Sync to Supabase
      try {
        await SupaFlow.client.from('app_promo_campaigns').upsert(campaign.toJson());
      } catch (_) {}

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Toggle House Ads globally
  Future<void> setHouseAdsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_houseAdsEnabledKey, enabled);
  }

  Future<bool> isHouseAdsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_houseAdsEnabledKey) ?? true;
  }

  /// Platform-Smart Checkout Execution:
  /// - On iOS: Apple anti-steering compliance -> Opens official Web Checkout in external browser.
  /// - On Android: Provides choice between direct UPI sheet and Web Checkout.
  Future<void> launchCheckout(
    BuildContext context, {
    Map<String, dynamic>? customPlan,
  }) async {
    final campaign = await getActiveCampaign();

    if (Platform.isIOS) {
      // iOS Strict Guideline Compliance: Route user to external web checkout portal
      await openWebCheckout(campaign.webCheckoutUrl);
    } else {
      // Android / Other: Show direct in-app checkout option with instant Web fallback
      if (!context.mounted) return;
      _showAndroidCheckoutSheet(context, campaign, customPlan);
    }
  }

  /// Open external Web Checkout portal
  Future<bool> openWebCheckout(String url) async {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  /// Android Direct In-App & Web Checkout Modal Sheet
  void _showAndroidCheckoutSheet(
    BuildContext context,
    HousePromoCampaign campaign,
    Map<String, dynamic>? customPlan,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8906), Color(0xFFFF5722)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.workspace_premium_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              campaign.discountBadge,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF10B981),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  campaign.subtitle,
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 20),

                // Option 1: Direct Instant UPI Payment (Android Fast Flow)
                InkWell(
                  onTap: () async {
                    Navigator.pop(ctx);
                    _launchUpiPayment(context, campaign);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_rounded,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instant UPI / GPay / PhonePe',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '₹${campaign.inAppMonthlyPrice}/mo or ₹${campaign.inAppYearlyPrice}/yr (Instant Activation)',
                                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white70, size: 14),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Option 2: Web Checkout (Card, Net Banking, International)
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    openWebCheckout(campaign.webCheckoutUrl);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.credit_card_rounded, color: Colors.white70, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Web Checkout (Cards, NetBanking)',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Pay securely on official website portal',
                                style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.open_in_new_rounded, color: Colors.white38, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  void _launchUpiPayment(BuildContext context, HousePromoCampaign campaign) async {
    final upiUrl =
        'upi://pay?pa=${campaign.upiId}&pn=PocketMates&am=${campaign.inAppMonthlyPrice}&cu=INR&tn=PocketMates_VIP_Upgrade';
    final uri = Uri.parse(upiUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback to web checkout
        await openWebCheckout(campaign.webCheckoutUrl);
      }
    } catch (_) {
      await openWebCheckout(campaign.webCheckoutUrl);
    }
  }
}
