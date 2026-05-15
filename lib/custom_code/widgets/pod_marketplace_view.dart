import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pod_3d_preview_widget.dart';
import 'pod_creator_studio.dart';

// ─── State ─────────────────────────────────────────────────────────────────────

class PodMarketState {
  final List<Map<String, dynamic>> designs;
  final bool isLoading;
  final bool hasMore;
  final int offset;

  const PodMarketState({
    this.designs = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.offset = 0,
  });

  PodMarketState copyWith({
    List<Map<String, dynamic>>? designs,
    bool? isLoading,
    bool? hasMore,
    int? offset,
  }) => PodMarketState(
    designs: designs ?? this.designs,
    isLoading: isLoading ?? this.isLoading,
    hasMore: hasMore ?? this.hasMore,
    offset: offset ?? this.offset,
  );
}

class PodMarketNotifier extends Notifier<PodMarketState> {
  static const _pageSize = 20;

  @override
  PodMarketState build() {
    load();
    return const PodMarketState();
  }

  Future<void> load({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    final offset = refresh ? 0 : state.offset;
    state = state.copyWith(isLoading: true);

    try {
      final res = await Supabase.instance.client
          .from('pod_designs')
          .select('*, pod_products(name, slug, category), profile(display_name, profile_image_url)')
          .eq('status', 'published')
          .order('created_at', ascending: false)
          .range(offset, offset + _pageSize - 1);

      final fetched = List<Map<String, dynamic>>.from(res);
      state = state.copyWith(
        designs: refresh ? fetched : [...state.designs, ...fetched],
        isLoading: false,
        hasMore: fetched.length == _pageSize,
        offset: offset + fetched.length,
      );
    } catch (e) {
      debugPrint('[POD-MARKET] Error loading designs: $e');
      state = state.copyWith(isLoading: false);
    }
  }
}

final podMarketProvider = NotifierProvider.autoDispose<PodMarketNotifier, PodMarketState>(
  PodMarketNotifier.new,
);

// ─── Marketplace View ──────────────────────────────────────────────────────────

class PodMarketplaceView extends ConsumerWidget {
  const PodMarketplaceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(podMarketProvider);

    // Debug print to see if we have data
    debugPrint('[POD-MARKET] Designs: ${s.designs.length}, Loading: ${s.isLoading}');

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      floatingActionButton: _fab(context),
      body: RefreshIndicator(
        color: const Color(0xFFFFA000),
        backgroundColor: const Color(0xFF161616),
        onRefresh: () => ref.read(podMarketProvider.notifier).load(refresh: true),
        child: s.isLoading && s.designs.isEmpty
          ? _skeleton()
          : s.designs.isEmpty
            ? _empty(context)
            : NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n is ScrollEndNotification && n.metrics.extentAfter < 400) {
                    ref.read(podMarketProvider.notifier).load();
                  }
                  return false;
                },
                child: CustomScrollView(slivers: [
                  SliverToBoxAdapter(child: _header()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 0.72,
                        crossAxisSpacing: 10, mainAxisSpacing: 10,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          if (i >= s.designs.length) return const _ShimmerCard();
                          return _PodDesignCard(design: s.designs[i]);
                        },
                        childCount: s.designs.length +
                            (s.isLoading && s.designs.isNotEmpty ? 2 : 0),
                      ),
                    ),
                  ),
                ]),
              ),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Print', style: GoogleFonts.inter(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text('Custom designs on demand', style: GoogleFonts.inter(
          color: Colors.white38, fontSize: 12)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFA000).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFA000).withValues(alpha: 0.25))),
        child: Row(children: [
          const Icon(Icons.local_shipping_outlined, color: Color(0xFFFFA000), size: 14),
          const SizedBox(width: 5),
          Text('Manual Delivery', style: GoogleFonts.inter(
            color: const Color(0xFFFFA000), fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      ),
    ]),
  );

  Widget _fab(BuildContext context) => FloatingActionButton.extended(
    backgroundColor: const Color(0xFFFFA000), foregroundColor: Colors.black,
    onPressed: () => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const PodCreatorStudio())),
    icon: const Icon(Icons.add, size: 20),
    label: Text('Create', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
  );

  Widget _empty(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.checkroom_outlined, size: 72, color: Colors.white.withValues(alpha: 0.06)),
      const SizedBox(height: 20),
      Text('No designs yet', style: GoogleFonts.inter(
        color: Colors.white38, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Text('Be the first to publish!', style: GoogleFonts.inter(
        color: Colors.white24, fontSize: 13)),
      const SizedBox(height: 28),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFA000), foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const PodCreatorStudio())),
        icon: const Icon(Icons.add, size: 18),
        label: Text('Create Your First Design', style: GoogleFonts.inter(
          fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    ]),
  ));

  Widget _skeleton() => Shimmer.fromColors(
    baseColor: const Color(0xFF161616), highlightColor: const Color(0xFF222222),
    child: GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.72,
        crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: 6,
      itemBuilder: (_, __) => const _ShimmerCard(),
    ),
  );
}

// ─── Design Card ───────────────────────────────────────────────────────────────

class _PodDesignCard extends StatelessWidget {
  final Map<String, dynamic> design;
  const _PodDesignCard({required this.design});

  @override
  Widget build(BuildContext context) {
    final title       = design['title'] as String? ?? 'Untitled';
    final price       = design['sale_price'];
    final imgUrl      = (design['preview_image_url'] as String?)?.isNotEmpty == true
                          ? design['preview_image_url'] as String
                          : design['design_image_url'] as String? ?? '';
    final profile     = design['profile'] as Map<String, dynamic>?;
    final artistName  = profile?['display_name'] as String? ?? 'Artist';
    final artistImg   = profile?['profile_image_url'] as String?;
    final product     = design['pod_products'] as Map<String, dynamic>?;
    final productName = product?['name'] as String? ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => PodProductDetailPage(design: design))),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(fit: StackFit.expand, children: [
              imgUrl.isNotEmpty
                ? CachedNetworkImage(imageUrl: imgUrl, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _placeholder())
                : _placeholder(),
              Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                  stops: const [0.55, 1.0])))),
              if (price != null) Positioned(bottom: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                  child: Text('₹$price', style: GoogleFonts.inter(
                    color: const Color(0xFFFFA000), fontSize: 12, fontWeight: FontWeight.bold)))),
              Positioned(top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(productName, style: GoogleFonts.inter(
                    color: Colors.white60, fontSize: 9, letterSpacing: 0.5)))),
            ]),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 12,
                  fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(children: [
                CircleAvatar(radius: 9,
                  backgroundImage: artistImg != null ? NetworkImage(artistImg) : null,
                  backgroundColor: const Color(0xFF2A2A2A),
                  child: artistImg == null
                    ? const Icon(Icons.person, size: 9, color: Colors.white38) : null),
                const SizedBox(width: 5),
                Expanded(child: Text(artistName, maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 10))),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(color: const Color(0xFF1A1A1A),
    child: const Center(child: Icon(Icons.checkroom_outlined,
      color: Colors.white12, size: 32)));
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: const Color(0xFF161616),
      borderRadius: BorderRadius.circular(16)));
}

// ─── Product Detail + Order Page ───────────────────────────────────────────────

class PodProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> design;
  const PodProductDetailPage({super.key, required this.design});

  @override
  State<PodProductDetailPage> createState() => _PodProductDetailPageState();
}

class _PodProductDetailPageState extends State<PodProductDetailPage> {
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl    = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _notesCtrl   = TextEditingController();

  String _size   = 'M';
  int    _qty    = 1;
  bool   _saving = false;

  static const _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const _amber = Color(0xFFFFA000);
  static const _bg    = Color(0xFF0A0A0A);

  double get _total =>
      ((widget.design['sale_price'] as num?)?.toDouble() ?? 0) * _qty;

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _addressCtrl.dispose();
    _cityCtrl.dispose(); _pincodeCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty || _addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all required fields'),
        backgroundColor: Colors.redAccent));
      return;
    }
    setState(() => _saving = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      await Supabase.instance.client.from('pod_orders').insert({
        'buyer_id':    userId,
        'design_id':   widget.design['id'],
        'quantity':    _qty,
        'size':        _size,
        'total_amount': _total,
        'buyer_name':  _nameCtrl.text.trim(),
        'buyer_phone': _phoneCtrl.text.trim(),
        'shipping_address': {
          'address': _addressCtrl.text.trim(),
          'city':    _cityCtrl.text.trim(),
          'pincode': _pincodeCtrl.text.trim(),
        },
        'notes':  _notesCtrl.text.trim(),
        'status': 'pending',
      });
      if (mounted) showDialog(context: context, builder: (_) => _successDialog());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  Widget _successDialog() => AlertDialog(
    backgroundColor: const Color(0xFF161616),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.check_circle_outline, color: _amber, size: 52),
      const SizedBox(height: 16),
      Text('Order Placed!', style: GoogleFonts.inter(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('The artist will contact you on WhatsApp to confirm and ship.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(color: Colors.white54, fontSize: 13, height: 1.5)),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _amber, foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () { Navigator.pop(context); Navigator.pop(context); },
          child: Text('Done', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        )),
    ]),
  );

  Widget _field(TextEditingController ctrl, String label, String hint,
      {TextInputType? type, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl, keyboardType: type, maxLines: maxLines,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label, hintText: hint,
          labelStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
          hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
          filled: true, fillColor: const Color(0xFF161616),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _amber)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final design    = widget.design;
    final title     = design['title'] as String? ?? 'Design';
    final imgUrl    = (design['preview_image_url'] as String?)?.isNotEmpty == true
                        ? design['preview_image_url'] as String
                        : design['design_image_url'] as String? ?? '';
    final glbUrl    = (design['pod_products'] as Map?)?['glb_url'] as String? ?? '';
    final slug      = (design['pod_products'] as Map?)?['slug'] as String? ?? '';
    final profile   = design['profile'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context)),
        title: Text(title, style: GoogleFonts.inter(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(child: Column(children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _amber.withValues(alpha: 0.15))),
          child: Pod3DPreviewWidget(
            glbUrl: glbUrl,
            designImageUrl: imgUrl.isNotEmpty ? imgUrl : null,
            productSlug: slug,
            width: double.infinity,
            height: 280,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(title, style: GoogleFonts.inter(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              Text('₹${design['sale_price']}', style: GoogleFonts.inter(
                color: _amber, fontSize: 20, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 6),
            if (profile != null) Row(children: [
              CircleAvatar(radius: 11,
                backgroundImage: (profile['profile_image_url'] as String?) != null
                  ? NetworkImage(profile['profile_image_url'] as String) : null,
                backgroundColor: const Color(0xFF2A2A2A),
                child: (profile['profile_image_url'] as String?) == null
                  ? const Icon(Icons.person, size: 11, color: Colors.white38) : null),
              const SizedBox(width: 7),
              Text('by ${profile['display_name'] ?? 'Artist'}',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)),
            ]),

            const SizedBox(height: 16),
            Text('Select Size', style: GoogleFonts.inter(
              color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: _sizes.map((s) {
              final sel = s == _size;
              return GestureDetector(
                onTap: () => setState(() => _size = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: sel ? _amber : const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sel ? _amber : const Color(0xFF2A2A2A))),
                  child: Center(child: Text(s, style: GoogleFonts.inter(
                    color: sel ? Colors.black : Colors.white54,
                    fontSize: 12, fontWeight: FontWeight.bold))),
                ),
              );
            }).toList()),

            const SizedBox(height: 16),
            Row(children: [
              Text('Quantity', style: GoogleFonts.inter(
                color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white38),
                onPressed: _qty > 1 ? () => setState(() => _qty--) : null),
              Text('$_qty', style: GoogleFonts.inter(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: _amber),
                onPressed: () => setState(() => _qty++)),
            ]),

            const Divider(color: Color(0xFF2A2A2A), height: 28),
            Text('Delivery Details', style: GoogleFonts.inter(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _field(_nameCtrl, 'Full Name *', 'Your name'),
            _field(_phoneCtrl, 'Phone *', '10-digit number', type: TextInputType.phone),
            _field(_addressCtrl, 'Address *', 'House no, street, area', maxLines: 2),
            Row(children: [
              Expanded(child: _field(_cityCtrl, 'City', 'City')),
              const SizedBox(width: 10),
              Expanded(child: _field(_pincodeCtrl, 'Pincode', '6 digits',
                type: TextInputType.number)),
            ]),
            _field(_notesCtrl, 'Notes', 'Any special instructions...', maxLines: 2),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2A2A2A))),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Total (${_qty}x)', style: GoogleFonts.inter(
                    color: Colors.white54, fontSize: 13)),
                  Text('₹${_total.toStringAsFixed(0)}', style: GoogleFonts.inter(
                    color: _amber, fontSize: 20, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _amber, foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)), elevation: 0),
                    onPressed: _saving ? null : _placeOrder,
                    child: _saving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : Text('Place Order (Manual Payment)', style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 8),
                Text('💬 The artist will contact you on WhatsApp to confirm payment.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white30, fontSize: 11, height: 1.4)),
              ]),
            ),
            const SizedBox(height: 40),
          ]),
        ),
      ])),
    );
  }
}
