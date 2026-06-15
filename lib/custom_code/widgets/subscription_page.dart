import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      'name': 'Free',
      'tagline': 'Get Started',
      'monthlyPrice': 0,
      'yearlyPrice': 0,
      'color': const Color(0xFF6B7280),
      'gradientColors': [Color(0xFF374151), Color(0xFF1F2937)],
      'icon': Icons.store_outlined,
      'popular': false,
      'features': [
        {'text': '5 Catalog Items', 'included': true},
        {'text': '10 Invoices/month', 'included': true},
        {'text': 'Basic POS Terminal', 'included': true},
        {'text': 'Walk-in Customer Only', 'included': true},
        {'text': 'PDF Invoice Export', 'included': false},
        {'text': 'WhatsApp Sharing', 'included': false},
        {'text': 'Advanced Analytics', 'included': false},
        {'text': 'Loyalty Points', 'included': false},
        {'text': 'Staff Management', 'included': false},
        {'text': 'GST Report Export', 'included': false},
        {'text': 'AI Business Assistant', 'included': false},
      ],
    },
    {
      'id': 'starter',
      'name': 'Starter',
      'tagline': 'For Solo Businesses',
      'monthlyPrice': 299,
      'yearlyPrice': 2499,
      'color': const Color(0xFF3B82F6),
      'gradientColors': [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      'icon': Icons.rocket_launch_rounded,
      'popular': false,
      'features': [
        {'text': '50 Catalog Items', 'included': true},
        {'text': 'Unlimited Invoices', 'included': true},
        {'text': 'Full POS Terminal', 'included': true},
        {'text': 'CRM — 100 Customers', 'included': true},
        {'text': 'PDF Invoice Export', 'included': true},
        {'text': 'WhatsApp Sharing', 'included': true},
        {'text': 'Basic Analytics', 'included': true},
        {'text': 'Loyalty Points', 'included': false},
        {'text': 'Staff Management', 'included': false},
        {'text': 'GST Report Export', 'included': false},
        {'text': 'AI Business Assistant', 'included': false},
      ],
    },
    {
      'id': 'pro',
      'name': 'Pro',
      'tagline': 'Most Popular',
      'monthlyPrice': 799,
      'yearlyPrice': 6999,
      'color': const Color(0xFFFFD700),
      'gradientColors': [Color(0xFFFFD700), Color(0xFFF59E0B)],
      'icon': Icons.workspace_premium_rounded,
      'popular': true,
      'features': [
        {'text': 'Unlimited Catalog', 'included': true},
        {'text': 'Unlimited Invoices', 'included': true},
        {'text': 'Full POS Terminal', 'included': true},
        {'text': 'Unlimited CRM', 'included': true},
        {'text': 'PDF Invoice Export', 'included': true},
        {'text': 'WhatsApp Sharing', 'included': true},
        {'text': 'Advanced Analytics', 'included': true},
        {'text': 'Loyalty Points', 'included': true},
        {'text': 'Staff (3 users)', 'included': true},
        {'text': 'GST Report Export', 'included': true},
        {'text': 'AI Business Assistant', 'included': false},
      ],
    },
    {
      'id': 'business',
      'name': 'Business',
      'tagline': 'For Teams & Chains',
      'monthlyPrice': 1999,
      'yearlyPrice': 17999,
      'color': const Color(0xFFEC4899),
      'gradientColors': [Color(0xFFDB2777), Color(0xFF9D174D)],
      'icon': Icons.corporate_fare_rounded,
      'popular': false,
      'features': [
        {'text': 'Unlimited Catalog', 'included': true},
        {'text': 'Unlimited Invoices', 'included': true},
        {'text': 'Full POS Terminal', 'included': true},
        {'text': 'Unlimited CRM', 'included': true},
        {'text': 'PDF Invoice Export', 'included': true},
        {'text': 'WhatsApp Sharing', 'included': true},
        {'text': 'Advanced Analytics', 'included': true},
        {'text': 'Loyalty Points', 'included': true},
        {'text': 'Unlimited Staff', 'included': true},
        {'text': 'GST Report Export', 'included': true},
        {'text': 'AI Business Assistant', 'included': true},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadCurrentPlan();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
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
      setState(() => _currentPlan = 'free');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downgraded to Free plan')),
        );
      }
      return;
    }

    // Show payment bottom sheet
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _buildPaymentSheet(plan, price),
    );
  }

  Widget _buildPaymentSheet(Map<String, dynamic> plan, int price) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(plan['icon'] as IconData, color: plan['color'] as Color, size: 48),
          const SizedBox(height: 16),
          Text(
            'Upgrade to ${plan['name']}',
            style: GoogleFonts.outfit(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹$price/${_isYearly ? 'year' : 'month'}',
            style: GoogleFonts.outfit(
              fontSize: 32, fontWeight: FontWeight.w800,
              color: plan['color'] as Color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isYearly
                ? 'Billed annually • Save 30%'
                : 'Billed monthly • Cancel anytime',
            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: plan['color'] as Color,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                // TODO: Integrate Razorpay / in_app_purchase here
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('handskill_plan', plan['id'] as String);
                setState(() => _currentPlan = plan['id'] as String);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 Upgraded to ${plan['name']} plan!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text(
                'Subscribe Now',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Secure payment • Cancel anytime • Instant activation',
            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
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
                        '✦ HANDSKILL PREMIUM',
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
                      'Grow Your Business',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Tools built for serious entrepreneurs',
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
                    '🔒 All plans include end-to-end data encryption\n📱 Works offline • ☁️ Cloud sync included\n🇮🇳 Made in India for Indian businesses',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13, height: 1.8),
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
                          price == 0 ? 'FREE' : '₹$price',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        if (price > 0)
                          Text(
                            _isYearly ? '/year' : '/month',
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
