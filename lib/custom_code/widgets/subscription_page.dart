import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pocket_mates_app/services/iap_service.dart';

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
  bool _isYearly = false;
  late AnimationController _shimmerController;

  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'free',
      'name': 'Free Mate',
      'tagline': 'English Practice with Community Ads',
      'monthlyPrice': 0,
      'yearlyPrice': 0,
      'trialPrice': 0,
      'color': const Color(0xFF6B7280),
      'gradientColors': [Color(0xFF374151), Color(0xFF1F2937)],
      'icon': Icons.public_rounded,
      'popular': false,
      'features': [
        {'text': '1-on-1 English Voice & Video Calls (Ad-Supported)', 'included': true},
        {'text': 'Daily AI English Practice (15 mins)', 'included': true},
        {'text': 'Built-in Useful Daily & Media Tools', 'included': true},
        {'text': '100% Ad-Free Experience', 'included': false},
        {'text': 'Priority Instant Matchmaking', 'included': false},
        {'text': 'AI Grammar & Fluency Reports', 'included': false},
        {'text': 'Gender & Country Partner Filters', 'included': false},
        {'text': 'Golden Mate VIP Badge & Halo', 'included': false},
      ],
    },
    {
      'id': 'pro',
      'name': 'Pocket VIP Fluency Pass',
      'tagline': '₹199/mo • 90-Day Binge Pass + AI Coach',
      'monthlyPrice': 199,
      'yearlyPrice': 1499,
      'trialPrice': 199,
      'color': const Color(0xFFFFD700),
      'gradientColors': [Color(0xFFFFD700), Color(0xFFF59E0B)],
      'icon': Icons.workspace_premium_rounded,
      'popular': true,
      'features': [
        {'text': '⚡ 90-Day Fast-Track (No 24-Hour Wait Locks)', 'included': true},
        {'text': '🛡️ Citadel Shield & Streak Freeze Insurance', 'included': true},
        {'text': '🚫 100% Ad-Free Experience Everywhere', 'included': true},
        {'text': '🎙️ AI Pronunciation & Spoken English Coach', 'included': true},
        {'text': '🐉 Exclusive 24K Gold Dragon & Phoenix Skins', 'included': true},
        {'text': '🏎️ Sovereign Phantom VIP Limousine Motorcade', 'included': true},
        {'text': '📜 Cryptographic Verified Day 90 Diploma', 'included': true},
        {'text': 'Priority Instant Peer Matchmaking Routing', 'included': true},
      ],
    },
    {
      'id': 'business',
      'name': 'Pocket Master VIP (Yearly)',
      'tagline': '₹1,499/year • Full Year Mastery + Resume Diploma',
      'monthlyPrice': 1499,
      'yearlyPrice': 1499,
      'trialPrice': 1499,
      'color': const Color(0xFFEC4899),
      'gradientColors': [Color(0xFFDB2777), Color(0xFF9D174D)],
      'icon': Icons.stars_rounded,
      'popular': false,
      'features': [
        {'text': 'Full Year 100% Ad-Free VIP Pass', 'included': true},
        {'text': 'All Pocket VIP Pro Features Included', 'included': true},
        {'text': 'IELTS & Job Interview Speaking Simulators', 'included': true},
        {'text': 'Unlimited AI Pronunciation Scoring', 'included': true},
        {'text': 'Exclusive Diamond Mate Crown Profile', 'included': true},
        {'text': 'Official Presidential Verified Diploma', 'included': true},
        {'text': 'Full Access to All 90 Days Without Limits', 'included': true},
        {'text': '24/7 Priority Support & Streak Protector', 'included': true},
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
            const SnackBar(
              content: Text('🎉 Poket VIP Successfully Activated via Google Play!'),
              backgroundColor: Color(0xFF10B981),
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
    setState(() {
      _currentPlan = prefs.getString('handskill_plan') ?? 'free';
    });
  }

  Future<void> _selectPlan(String planId) async {
    if (planId == _currentPlan) return;

    final plan = _plans.firstWhere((p) => p['id'] == planId);
    final price = _isYearly ? plan['yearlyPrice'] : plan['monthlyPrice'];

    if (price == 0) {
      // Downgrade to free
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('handskill_plan', 'free');
      await prefs.setBool('is_vip', false);
      setState(() => _currentPlan = 'free');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downgraded to Free plan')),
        );
      }
      return;
    }

    if (!mounted) return;

    // Duolingo-style Payment Selector (Google Play / Apple In-App Purchase + Direct UPI)
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
                  final initiated = await IAPService().buyVipSubscription(isYearly: _isYearly);
                  if (!initiated && mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Store billing loading... You can also use Direct UPI below.'),
                        backgroundColor: Color(0xFF1E293B),
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
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shop_two_rounded, color: Color(0xFFFFD700), size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Google Play Billing ⚡',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '1-Tap Secure Payment • Official Store Checkout',
                              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Option 2: Direct Indian UPI (GPay / PhonePe / Paytm)
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(0xFF131722),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                          color: const Color(0xFF0F9D58).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF0F9D58), size: 26),
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
                              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                      border: Border.all(color: (plan['color'] as Color).withValues(alpha: 0.4)),
                    ),
                    child: Icon(plan['icon'] as IconData, color: plan['color'] as Color, size: 28),
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
                          style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
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
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2333),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_android_rounded, color: Colors.white54, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Enter UPI Number / Phone',
                          hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final val = phoneController.text.trim();
                        if (val.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter phone number or UPI ID')),
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(60, 34),
                      ),
                      child: Text(
                        'Pay',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, color: Color(0xFF10B981), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Direct 100% Encrypted UPI • NPCI & Bank Secured',
                    style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
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
                color: textColor == Colors.black ? const Color(0xFFFFFC00) : Colors.white,
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
    _showPaymentConfirmationTimerDialog(appName: appName, price: price, plan: plan);
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
                side: BorderSide(color: const Color(0xFFFFFC00).withValues(alpha: 0.4), width: 1.5),
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
                        border: Border.all(color: const Color(0xFFFFFC00), width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.hourglass_top_rounded, color: Color(0xFFFFFC00), size: 34),
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
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 14),

                    // Countdown Clock
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2333),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, color: Color(0xFFFFFC00), size: 16),
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
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Optional: Enter 12-digit UPI UTR / Ref No',
                        hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
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
                          await prefs.setString('handskill_plan', plan['id'] as String);
                          setState(() => _currentPlan = plan['id'] as String);

                          HapticFeedback.heavyImpact();

                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  '🎉 Payment Successful! ${plan['name']} VIP Activated!',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'I Have Completed Payment ✓',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
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
                        style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
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
      backgroundColor: const Color(0xFF0D0D12),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0D0D12),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A0A2E), Color(0xFF0D0D12)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '✦ POKET MATES FLUENT PRO',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Master Spoken English',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '100% Ad-Free calls, AI grammar feedback & global mates',
                      style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Billing Toggle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isYearly = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isYearly ? const Color(0xFFFFD700) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Monthly',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: !_isYearly ? Colors.black : Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isYearly = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isYearly ? const Color(0xFFFFD700) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Yearly',
                                style: GoogleFonts.outfit(
                                  color: _isYearly ? Colors.black : Colors.white54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'SAVE 30%',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Current Plan banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white38, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Current Plan: ',
                      style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13),
                    ),
                    Text(
                      _plans.firstWhere((p) => p['id'] == _currentPlan)['name'] as String,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Plan Cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildPlanCard(_plans[index]),
              childCount: _plans.length,
            ),
          ),

          // Feature comparison note
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),
                  Text(
                    '🔒 Real-time AI encryption • 100% Secure calls\n⚡ Low latency WebRTC voice & video\n🌏 Connect with spoken English learners worldwide',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13, height: 1.8),
                  ),
                  const SizedBox(height: 18),

                  // Duolingo & Apple-compliant Restore Purchases Button
                  TextButton.icon(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Checking store for previous purchases...'),
                          backgroundColor: Color(0xFF1E293B),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      await IAPService().restorePurchases();
                      await _loadCurrentPlan();
                    },
                    icon: const Icon(Icons.restore_rounded, color: Color(0xFFFFD700), size: 18),
                    label: Text(
                      'Restore Purchases',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Apple StoreKit Guideline 3.1.1 Mandatory Legal Links
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
                      const Text('  •  ', style: TextStyle(color: Colors.white24, fontSize: 11)),
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
                  const SizedBox(height: 32),
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
    final color = plan['color'] as Color;
    final price = _isYearly ? plan['yearlyPrice'] as int : plan['monthlyPrice'] as int;
    final features = plan['features'] as List<Map<String, dynamic>>;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: GestureDetector(
        onTap: () => _selectPlan(plan['id'] as String),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A22),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? color : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: (plan['gradientColors'] as List<Color>)
                        .map((c) => c.withValues(alpha: 0.15))
                        .toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(plan['icon'] as IconData, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                plan['name'] as String,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (isPopular) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'POPULAR',
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            plan['tagline'] as String,
                            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price == 0 ? 'FREE' : (plan['trialPrice'] != null && plan['trialPrice'] > 0 ? '₹${plan['trialPrice']}' : '₹$price'),
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        if (price > 0)
                          Text(
                            (plan['trialPrice'] != null && plan['trialPrice'] > 0) ? '1st month' : (_isYearly ? '/year' : '/month'),
                            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Features
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...features.take(6).map((f) => _buildFeatureRow(f, color)),
                    if (features.length > 6)
                      Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Text(
                            'See all features',
                            style: GoogleFonts.outfit(color: color, fontSize: 13),
                          ),
                          iconColor: color,
                          collapsedIconColor: color,
                          children: [
                            ...features.skip(6).map((f) => _buildFeatureRow(f, color)),
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
                              : (isPopular ? color : color.withValues(alpha: 0.15)),
                          foregroundColor: isSelected
                              ? Colors.white54
                              : (isPopular ? Colors.black : color),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: isSelected ? null : () => _selectPlan(plan['id'] as String),
                        child: Text(
                          isSelected
                              ? '✓ Current Plan'
                              : (price == 0 ? 'Downgrade to Free' : 'Get ${plan['name']}'),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(Map<String, dynamic> feature, Color planColor) {
    final included = feature['included'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: included ? planColor : Colors.white12,
          ),
          const SizedBox(width: 10),
          Text(
            feature['text'] as String,
            style: GoogleFonts.outfit(
              color: included ? Colors.white70 : Colors.white24,
              fontSize: 13,
              decoration: included ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}
