import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── B2B Pricing Tiers ───────────────────────────────────────────────────────

class _B2BTier {
  final String range;
  final String discount;
  final String label;
  final IconData icon;
  final bool featured;

  const _B2BTier({
    required this.range,
    required this.discount,
    required this.label,
    required this.icon,
    this.featured = false,
  });
}

const _tiers = [
  _B2BTier(
    range: '10 – 49 pcs',
    discount: '15% OFF',
    label: 'Starter',
    icon: Icons.local_shipping_outlined,
  ),
  _B2BTier(
    range: '50 – 99 pcs',
    discount: '25% OFF',
    label: 'Business',
    icon: Icons.storefront_outlined,
    featured: true,
  ),
  _B2BTier(
    range: '100+ pcs',
    discount: '35% OFF\n+ Free Shipping',
    label: 'Enterprise',
    icon: Icons.domain_outlined,
  ),
];

// ─── Main B2B Portal Page ─────────────────────────────────────────────────────

class PodB2BPortal extends StatefulWidget {
  /// Pre-selected design (optional — e.g. tapping "Order Bulk" from a card).
  final Map<String, dynamic>? preSelectedDesign;

  const PodB2BPortal({super.key, this.preSelectedDesign});

  @override
  State<PodB2BPortal> createState() => _PodB2BPortalState();
}

class _PodB2BPortalState extends State<PodB2BPortal>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  static const _amber = Color(0xFFFFFC00);
  static const _bg = Color(0xFF0A0A0A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            backgroundColor: _bg,
            elevation: 0,
            pinned: true,
            expandedHeight: 200,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _heroBanner(),
              collapseMode: CollapseMode.parallax,
            ),
            bottom: TabBar(
              controller: _tab,
              indicatorColor: _amber,
              indicatorWeight: 3,
              labelColor: _amber,
              unselectedLabelColor: Colors.white38,
              labelStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'DESIGNS'),
                Tab(text: 'MY ORDERS'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _DesignsTab(preSelectedDesign: widget.preSelectedDesign),
            const _MyB2BOrdersTab(),
          ],
        ),
      ),
    );
  }

  Widget _heroBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1500),
            const Color(0xFF0A0A0A),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _amber.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.business_center_outlined,
                    color: _amber, size: 13),
                const SizedBox(width: 5),
                Text('B2B Print-on-Demand',
                    style: GoogleFonts.inter(
                        color: _amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
              ]),
            ),
            const SizedBox(height: 10),
            Text('Bulk Printing\nfor Businesses',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2)),
            const SizedBox(height: 6),
            Text('Minimum 10 pcs · Custom sizes · WhatsApp coordination',
                style: GoogleFonts.inter(
                    color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ─── Designs Tab ──────────────────────────────────────────────────────────────

class _DesignsTab extends StatefulWidget {
  final Map<String, dynamic>? preSelectedDesign;
  const _DesignsTab({this.preSelectedDesign});

  @override
  State<_DesignsTab> createState() => _DesignsTabState();
}

class _DesignsTabState extends State<_DesignsTab> {
  List<Map<String, dynamic>> _designs = [];
  bool _loading = true;

  static const _amber = Color(0xFFFFFC00);
  static const _surface = Color(0xFF141414);

  @override
  void initState() {
    super.initState();
    _loadDesigns();
    if (widget.preSelectedDesign != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showEnquiryForm(widget.preSelectedDesign!);
      });
    }
  }

  Future<void> _loadDesigns() async {
    try {
      final res = await Supabase.instance.client
          .from('pod_designs')
          .select(
              '*, pod_products(name, slug, category), profile(display_name, profile_image_url)')
          .eq('status', 'published')
          .eq('b2b_available', true)
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _designs = List<Map<String, dynamic>>.from(res);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Pricing tiers ──────────────────────────────────────────────
        SliverToBoxAdapter(child: _pricingTiers()),

        // ── "Get Custom Quote" CTA ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: GestureDetector(
              onTap: () => _showEnquiryForm(null),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: _amber.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.request_quote_outlined,
                          color: _amber, size: 18),
                      const SizedBox(width: 8),
                      Text('Get a Custom Quote',
                          style: GoogleFonts.inter(
                              color: _amber,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ]),
              ),
            ),
          ),
        ),

        // ── Section header ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text('Browse B2B Designs',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ),

        // ── Designs grid ───────────────────────────────────────────────
        if (_loading)
          SliverToBoxAdapter(child: _skeleton())
        else if (_designs.isEmpty)
          SliverToBoxAdapter(child: _empty())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
            sliver: SliverGrid(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => _B2BDesignCard(
                  design: _designs[i],
                  onOrderBulk: () => _showEnquiryForm(_designs[i]),
                ),
                childCount: _designs.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _pricingTiers() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      child: Row(
        children: _tiers.map((t) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  right: t == _tiers.last ? 0 : 8),
              child: _TierCard(tier: t),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _skeleton() => Shimmer.fromColors(
        baseColor: const Color(0xFF161616),
        highlightColor: const Color(0xFF222222),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => Container(
              decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16))),
        ),
      );

  Widget _empty() => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.business_outlined,
                size: 60, color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 16),
            Text('No B2B designs yet',
                style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Artists can enable B2B when publishing.',
                style: GoogleFonts.inter(
                    color: Colors.white24, fontSize: 12)),
          ]),
        ),
      );

  void _showEnquiryForm(Map<String, dynamic>? design) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EnquiryFormSheet(
        designs: _designs,
        preSelectedDesign: design,
      ),
    ).then((_) {
      // Optionally refresh orders tab after submitting
    });
  }
}

// ─── Pricing Tier Card ────────────────────────────────────────────────────────

class _TierCard extends StatelessWidget {
  final _B2BTier tier;
  const _TierCard({required this.tier});

  static const _amber = Color(0xFFFFFC00);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tier.featured
            ? _amber.withValues(alpha: 0.08)
            : const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: tier.featured
                ? _amber.withValues(alpha: 0.4)
                : const Color(0xFF2A2A2A),
            width: tier.featured ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tier.featured)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: _amber,
                  borderRadius: BorderRadius.circular(6)),
              child: Text('POPULAR',
                  style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
            ),
          Icon(tier.icon,
              color: tier.featured ? _amber : Colors.white38, size: 20),
          const SizedBox(height: 6),
          Text(tier.label,
              style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(tier.range,
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(tier.discount,
              style: GoogleFonts.inter(
                  color: tier.featured ? _amber : Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  height: 1.3)),
        ],
      ),
    );
  }
}

// ─── B2B Design Card ──────────────────────────────────────────────────────────

class _B2BDesignCard extends StatelessWidget {
  final Map<String, dynamic> design;
  final VoidCallback onOrderBulk;
  const _B2BDesignCard({required this.design, required this.onOrderBulk});

  static const _amber = Color(0xFFFFFC00);

  @override
  Widget build(BuildContext context) {
    final title = design['title'] as String? ?? 'Untitled';
    final price = (design['sale_price'] as num?)?.toDouble() ?? 0;
    final imgUrl = (design['design_image_url'] as String?) ?? '';
    final profile = design['profile'] as Map<String, dynamic>?;
    final artistName = profile?['display_name'] as String? ?? 'Artist';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image
        Expanded(
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(fit: StackFit.expand, children: [
              imgUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder())
                  : _placeholder(),
              // Gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5)
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // B2B badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _amber.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('B2B',
                      style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ),
              ),
              // Price
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('₹${price.toStringAsFixed(0)}/pc',
                      style: GoogleFonts.inter(
                          color: _amber,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),
        ),
        // Info + button
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text('by $artistName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        color: Colors.white38, fontSize: 10)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: onOrderBulk,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: _amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('Order Bulk',
                            style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              ]),
        ),
      ]),
    );
  }

  Widget _placeholder() => Container(
      color: const Color(0xFF1A1A1A),
      child: const Center(
          child: Icon(Icons.checkroom_outlined,
              color: Colors.white12, size: 36)));
}

// ─── Enquiry Form Bottom Sheet ────────────────────────────────────────────────

class _EnquiryFormSheet extends StatefulWidget {
  final List<Map<String, dynamic>> designs;
  final Map<String, dynamic>? preSelectedDesign;
  const _EnquiryFormSheet({required this.designs, this.preSelectedDesign});

  @override
  State<_EnquiryFormSheet> createState() => _EnquiryFormSheetState();
}

class _EnquiryFormSheetState extends State<_EnquiryFormSheet> {
  final _bizCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '50');
  final _form = GlobalKey<FormState>();

  Map<String, dynamic>? _selectedDesign;
  DateTime? _deadline;
  bool _saving = false;
  bool _success = false;

  static const _amber = Color(0xFFFFFC00);
  static const _surface = Color(0xFF1A1A1A);
  static const _border = Color(0xFF2A2A2A);
  static const _bg = Color(0xFF0F0F0F);

  @override
  void initState() {
    super.initState();
    _selectedDesign = widget.preSelectedDesign;
  }

  @override
  void dispose() {
    _bizCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  int get _qty => int.tryParse(_qtyCtrl.text) ?? 0;

  double _discountPct() {
    if (_qty >= 100) return 35;
    if (_qty >= 50) return 25;
    if (_qty >= 10) return 15;
    return 0;
  }

  String _tierLabel() {
    if (_qty >= 100) return 'Enterprise – 35% OFF + Free Shipping';
    if (_qty >= 50) return 'Business – 25% OFF';
    if (_qty >= 10) return 'Starter – 15% OFF';
    return 'Min. 10 pcs for bulk pricing';
  }

  double _totalWithDiscount() {
    final basePrice =
        (_selectedDesign?['sale_price'] as num?)?.toDouble() ?? 0;
    final discounted = basePrice * (1 - _discountPct() / 100);
    return discounted * _qty;
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_qty < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Minimum order is 10 pieces'),
          backgroundColor: Colors.redAccent));
      return;
    }
    setState(() => _saving = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      await Supabase.instance.client.from('pod_b2b_orders').insert({
        'buyer_id': userId,
        'design_id': _selectedDesign?['id'],
        'business_name': _bizCtrl.text.trim(),
        'contact_person': _contactCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'quantity': _qty,
        'deadline': _deadline?.toIso8601String(),
        'notes': _notesCtrl.text.trim(),
        'status': 'pending',
      });
      if (mounted) setState(() => _success = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _success ? _buildSuccess() : _buildForm(ctrl),
      ),
    );
  }

  Widget _buildSuccess() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _amber.withValues(alpha: 0.1),
                border: Border.all(color: _amber.withValues(alpha: 0.4), width: 2),
              ),
              child: const Icon(Icons.check_circle_outline, color: _amber, size: 44),
            ),
            const SizedBox(height: 24),
            Text('Enquiry Submitted!',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              'We\'ll contact you on WhatsApp within 24 hours\nto confirm details and pricing.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: Colors.white38, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Done',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ]),
        ),
      );

  Widget _buildForm(ScrollController ctrl) {
    return Form(
      key: _form,
      child: ListView(
        controller: ctrl,
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 32),
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text('B2B Bulk Order Enquiry',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Min. 10 pieces · Negotiable pricing · WhatsApp support',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 20),

          // ── Design selector ────────────────────────────────────────
          _sectionLabel('Select Design'),
          const SizedBox(height: 8),
          if (widget.designs.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: _surface, borderRadius: BorderRadius.circular(12)),
              child: Text('No B2B designs available yet.',
                  style: GoogleFonts.inter(
                      color: Colors.white38, fontSize: 13)),
            )
          else
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Map<String, dynamic>>(
                  value: _selectedDesign,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E1E1E),
                  hint: Text('Choose a design (optional)',
                      style: GoogleFonts.inter(
                          color: Colors.white38, fontSize: 13)),
                  items: widget.designs.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(d['title'] as String? ?? 'Untitled',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              color: Colors.white, fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedDesign = v),
                  style:
                      GoogleFonts.inter(color: Colors.white, fontSize: 13),
                  icon: const Icon(Icons.expand_more, color: Colors.white38),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // ── Quantity & discount preview ────────────────────────────
          _sectionLabel('Quantity'),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 2,
              child: _formField(
                controller: _qtyCtrl,
                label: 'Units *',
                hint: '50',
                keyboard: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 10) return 'Min 10 pcs';
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _qty >= 10
                      ? _amber.withValues(alpha: 0.08)
                      : _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _qty >= 10
                          ? _amber.withValues(alpha: 0.3)
                          : _border),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(_tierLabel(),
                      style: GoogleFonts.inter(
                          color: _qty >= 10 ? _amber : Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.3)),
                  if (_selectedDesign != null && _qty >= 10) ...[
                    const SizedBox(height: 4),
                    Text(
                        'Est. ₹${_totalWithDiscount().toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ],
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // ── Business Info ──────────────────────────────────────────
          _sectionLabel('Business Info'),
          const SizedBox(height: 10),
          _formField(
              controller: _bizCtrl,
              label: 'Business / Brand Name *',
              hint: 'ACME Corp',
              validator: (v) => v!.isEmpty ? 'Required' : null),
          _formField(
              controller: _contactCtrl,
              label: 'Contact Person *',
              hint: 'Your name',
              validator: (v) => v!.isEmpty ? 'Required' : null),
          Row(children: [
            Expanded(
              child: _formField(
                  controller: _emailCtrl,
                  label: 'Email *',
                  hint: 'you@company.com',
                  keyboard: TextInputType.emailAddress,
                  validator: (v) =>
                      v!.isEmpty || !v.contains('@') ? 'Valid email required' : null),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _formField(
                  controller: _phoneCtrl,
                  label: 'WhatsApp No. *',
                  hint: '9999999999',
                  keyboard: TextInputType.phone,
                  validator: (v) =>
                      v!.length < 10 ? '10-digit number' : null),
            ),
          ]),
          const SizedBox(height: 4),

          // ── Deadline ───────────────────────────────────────────────
          _sectionLabel('Deadline (optional)'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    DateTime.now().add(const Duration(days: 14)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (ctx, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                        primary: _amber, onPrimary: Colors.black),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _deadline = picked);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.white38, size: 16),
                const SizedBox(width: 10),
                Text(
                    _deadline == null
                        ? 'Pick a deadline date'
                        : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                    style: GoogleFonts.inter(
                        color: _deadline == null
                            ? Colors.white38
                            : Colors.white,
                        fontSize: 13)),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // ── Notes ──────────────────────────────────────────────────
          _formField(
            controller: _notesCtrl,
            label: 'Custom Requirements / Notes',
            hint: 'Size breakdown, special colors, logo placement…',
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // ── Submit ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _amber,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2))
                  : Text('Submit Enquiry',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '📲 We\'ll WhatsApp you within 24 hours to confirm pricing & delivery.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: Colors.white30, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String t) => Text(t,
      style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600));

  Widget _formField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboard,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle:
              GoogleFonts.inter(color: Colors.white38, fontSize: 13),
          hintStyle:
              GoogleFonts.inter(color: Colors.white24, fontSize: 13),
          filled: true,
          fillColor: _surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _amber)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}

// ─── My B2B Orders Tab ────────────────────────────────────────────────────────

class _MyB2BOrdersTab extends StatefulWidget {
  const _MyB2BOrdersTab();

  @override
  State<_MyB2BOrdersTab> createState() => _MyB2BOrdersTabState();
}

class _MyB2BOrdersTabState extends State<_MyB2BOrdersTab> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  static const _amber = Color(0xFFFFFC00);

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _loading = false);
        return;
      }
      final res = await Supabase.instance.client
          .from('pod_b2b_orders')
          .select('*, pod_designs(title, design_image_url)')
          .eq('buyer_id', userId)
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(res);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    return switch (status) {
      'confirmed' => Colors.green,
      'in_production' => Colors.blue,
      'shipped' => _amber,
      'delivered' => Colors.greenAccent,
      'cancelled' => Colors.redAccent,
      _ => Colors.white38,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'confirmed' => '✓ Confirmed',
      'in_production' => '🏭 In Production',
      'shipped' => '🚚 Shipped',
      'delivered' => '✅ Delivered',
      'cancelled' => '✗ Cancelled',
      _ => '⏳ Pending',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: _amber));
    }
    if (_orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.inventory_2_outlined,
                size: 60, color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 16),
            Text('No B2B orders yet',
                style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Your submitted bulk enquiries will appear here.',
                style: GoogleFonts.inter(
                    color: Colors.white24, fontSize: 12)),
          ]),
        ),
      );
    }

    return RefreshIndicator(
      color: _amber,
      backgroundColor: const Color(0xFF161616),
      onRefresh: _loadOrders,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final order = _orders[i];
          final design =
              order['pod_designs'] as Map<String, dynamic>?;
          final status = order['status'] as String? ?? 'pending';
          final qty = order['quantity'] as int? ?? 0;
          final biz = order['business_name'] as String? ?? '';
          final createdAt = order['created_at'] as String?;

          DateTime? date;
          if (createdAt != null) {
            date = DateTime.tryParse(createdAt);
          }

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(children: [
              // Thumb
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFF1E1E1E),
                  child: design?['design_image_url'] != null
                      ? CachedNetworkImage(
                          imageUrl: design!['design_image_url'] as String,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Icon(
                              Icons.checkroom_outlined,
                              color: Colors.white24, size: 22))
                      : const Icon(Icons.checkroom_outlined,
                          color: Colors.white24, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(design?['title'] as String? ?? 'Custom Design',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('$biz · $qty pcs',
                      style: GoogleFonts.inter(
                          color: Colors.white54, fontSize: 11)),
                  if (date != null) ...[
                    const SizedBox(height: 2),
                    Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: GoogleFonts.inter(
                            color: Colors.white24, fontSize: 10)),
                  ],
                ]),
              ),
              const SizedBox(width: 8),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _statusColor(status).withValues(alpha: 0.3)),
                ),
                child: Text(_statusLabel(status),
                    style: GoogleFonts.inter(
                        color: _statusColor(status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ]),
          );
        },
      ),
    );
  }
}
