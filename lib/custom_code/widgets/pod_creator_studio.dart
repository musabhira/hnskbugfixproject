import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'pod_3d_preview_widget.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class PodCreatorState {
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic>? selectedProduct;
  final String? designLocalPath;
  final String? designUploadedUrl;
  final bool isUploading;
  final bool isPublishing;
  final String? errorMessage;

  const PodCreatorState({
    this.products = const [],
    this.selectedProduct,
    this.designLocalPath,
    this.designUploadedUrl,
    this.isUploading = false,
    this.isPublishing = false,
    this.errorMessage,
  });

  PodCreatorState copyWith({
    List<Map<String, dynamic>>? products,
    Map<String, dynamic>? selectedProduct,
    String? designLocalPath,
    String? designUploadedUrl,
    bool? isUploading,
    bool? isPublishing,
    String? errorMessage,
  }) => PodCreatorState(
    products: products ?? this.products,
    selectedProduct: selectedProduct ?? this.selectedProduct,
    designLocalPath: designLocalPath ?? this.designLocalPath,
    designUploadedUrl: designUploadedUrl ?? this.designUploadedUrl,
    isUploading: isUploading ?? this.isUploading,
    isPublishing: isPublishing ?? this.isPublishing,
    errorMessage: errorMessage,
  );
}

class PodCreatorNotifier extends Notifier<PodCreatorState> {
  @override
  PodCreatorState build() {
    _loadProducts();
    return const PodCreatorState();
  }

  final _db = Supabase.instance.client;

  Future<void> _loadProducts() async {
    try {
      final res = await _db
          .from('pod_products')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      state = state.copyWith(products: List<Map<String, dynamic>>.from(res));
    } catch (_) {}
  }

  void selectProduct(Map<String, dynamic> product) =>
      state = state.copyWith(selectedProduct: product);

  Future<String?> uploadDesign(String localPath, String userId) async {
    state = state.copyWith(isUploading: true, errorMessage: null);
    try {
      final ext = localPath.contains('.') ? '.${localPath.split('.').last.toLowerCase()}' : '.png';
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}$ext';
      final bytes = await File(localPath).readAsBytes();
      await _db.storage.from('pod-design-uploads').uploadBinary(
        fileName, bytes,
        fileOptions: FileOptions(
          contentType: ext == '.png' ? 'image/png' : 'image/jpeg',
          upsert: true,
        ),
      );
      final url = _db.storage.from('pod-design-uploads').getPublicUrl(fileName);
      state = state.copyWith(
        designLocalPath: localPath,
        designUploadedUrl: url,
        isUploading: false,
      );
      return url;
    } catch (e) {
      state = state.copyWith(isUploading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> publishDesign({
    required String title,
    required String description,
    required double price,
    required double royaltyPct,
    required List<String> tags,
  }) async {
    final product  = state.selectedProduct;
    final designUrl = state.designUploadedUrl;
    final userId   = _db.auth.currentUser?.id;
    if (product == null || designUrl == null || userId == null) return false;

    state = state.copyWith(isPublishing: true, errorMessage: null);
    try {
      await _db.from('pod_designs').insert({
        'artist_id':        userId,
        'product_id':       product['id'],
        'title':            title,
        'description':      description,
        'design_image_url': designUrl,
        'sale_price':       price,
        'royalty_pct':      royaltyPct,
        'tags':             tags,
        'status':           'published',
      });
      state = state.copyWith(isPublishing: false);
      return true;
    } catch (e) {
      state = state.copyWith(isPublishing: false, errorMessage: e.toString());
      return false;
    }
  }
}

final podCreatorProvider = NotifierProvider.autoDispose<PodCreatorNotifier, PodCreatorState>(
  PodCreatorNotifier.new,
);

// ─── Widget ───────────────────────────────────────────────────────────────────

class PodCreatorStudio extends ConsumerStatefulWidget {
  const PodCreatorStudio({super.key});

  @override
  ConsumerState<PodCreatorStudio> createState() => _PodCreatorStudioState();
}

class _PodCreatorStudioState extends ConsumerState<PodCreatorStudio> {
  final _titleCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _priceCtrl   = TextEditingController(text: '499');
  final _tagsCtrl    = TextEditingController();
  final _previewKey  = GlobalKey<Pod3DPreviewWidgetState>();
  double _royaltyPct = 20;
  int _step          = 0;

  static const _amber   = Color(0xFFFFA000);
  static const _bg      = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF161616);
  static const _border  = Color(0xFF2A2A2A);

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _priceCtrl.dispose(); _tagsCtrl.dispose();
    super.dispose();
  }

  Widget _buildProductPicker(PodCreatorState s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text('Choose a Product', style: GoogleFonts.inter(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Text('Pick what you want to print your design on.',
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
        ),
        Expanded(
          child: s.products.isEmpty
            ? const Center(child: CircularProgressIndicator(color: _amber))
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.85,
                  crossAxisSpacing: 12, mainAxisSpacing: 12,
                ),
                itemCount: s.products.length,
                itemBuilder: (_, i) {
                  final product  = s.products[i];
                  final isSoon   = product['coming_soon'] == true;
                  final isSel    = s.selectedProduct?['id'] == product['id'];
                  return _ProductCard(
                    product: product, isSelected: isSel, isSoon: isSoon,
                    onTap: isSoon ? null : () =>
                        ref.read(podCreatorProvider.notifier).selectProduct(product),
                  );
                },
              ),
        ),
        _bottomButton(
          label: 'Next: Upload Design',
          enabled: s.selectedProduct != null,
          onTap: () => setState(() => _step = 1),
        ),
      ],
    );
  }

  Widget _buildDesignStep(PodCreatorState s) {
    final product = s.selectedProduct!;
    final glbUrl  = product['glb_url'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _amber.withValues(alpha: 0.2)),
            ),
            child: Pod3DPreviewWidget(
              key: _previewKey,
              glbUrl: glbUrl,
              designImageUrl: s.designUploadedUrl,
              productSlug: product['slug'] as String? ?? '',
              width: double.infinity,
              height: 320,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: GestureDetector(
              onTap: s.isUploading ? null : () => _pickAndUpload(s),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: s.designUploadedUrl != null
                      ? _amber.withValues(alpha: 0.08) : _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: s.designUploadedUrl != null
                      ? _amber.withValues(alpha: 0.4) : _border),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (s.isUploading)
                    const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: _amber, strokeWidth: 2))
                  else
                    Icon(
                      s.designUploadedUrl != null
                          ? Icons.check_circle_outline : Icons.upload_file_outlined,
                      color: s.designUploadedUrl != null ? _amber : Colors.white54, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    s.isUploading ? 'Uploading...'
                        : s.designUploadedUrl != null ? 'Uploaded ✓  (Tap to change)'
                        : 'Upload Your Design  (PNG / JPG)',
                    style: GoogleFonts.inter(
                      color: s.designUploadedUrl != null ? _amber : Colors.white54,
                      fontSize: 13, fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label('Design Details'), const SizedBox(height: 10),
              _field(_titleCtrl, 'Title', 'e.g. Sunset Waves Tee'),
              const SizedBox(height: 10),
              _field(_descCtrl, 'Description', 'Tell buyers about your design...', maxLines: 3),
              const SizedBox(height: 10),
              _field(_tagsCtrl, 'Tags', 'abstract, nature, minimal'),
              const SizedBox(height: 20),
              _label('Pricing'), const SizedBox(height: 10),
              _field(_priceCtrl, 'Sale Price (₹)', '499', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Your Royalty', style: GoogleFonts.inter(color: Colors.white60, fontSize: 13)),
                Text('${_royaltyPct.round()}%', style: GoogleFonts.inter(
                    color: _amber, fontSize: 14, fontWeight: FontWeight.bold)),
              ]),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: _amber, thumbColor: _amber,
                  overlayColor: _amber.withValues(alpha: 0.15),
                  inactiveTrackColor: _border, trackHeight: 3,
                ),
                child: Slider(
                  value: _royaltyPct, min: 5, max: 40, divisions: 35,
                  onChanged: (v) => setState(() => _royaltyPct = v),
                ),
              ),
              const SizedBox(height: 4),
              _earningsBreakdown(),
            ]),
          ),
          if (s.errorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(s.errorMessage!, style: GoogleFonts.inter(
                  color: Colors.redAccent, fontSize: 12)),
            ),
          const SizedBox(height: 20),
          _bottomButton(
            label: s.isPublishing ? 'Publishing...' : 'Publish to Print Shop',
            enabled: s.designUploadedUrl != null &&
                     _titleCtrl.text.trim().isNotEmpty && !s.isPublishing,
            onTap: () => _publish(s),
            icon: Icons.rocket_launch_outlined,
          ),
        ],
      ),
    );
  }

  Widget _earningsBreakdown() {
    final price   = double.tryParse(_priceCtrl.text) ?? 0;
    final yourCut = price * (_royaltyPct / 100);
    final platCut = price - yourCut;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface,
        borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)),
      child: Row(children: [
        _chip('Your Earnings', '₹${yourCut.toStringAsFixed(0)}', _amber),
        const Spacer(),
        _chip('Platform', '₹${platCut.toStringAsFixed(0)}', Colors.white30),
      ]),
    );
  }

  Widget _chip(String label, String val, Color c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
      const SizedBox(height: 2),
      Text(val, style: GoogleFonts.inter(color: c, fontSize: 16, fontWeight: FontWeight.bold)),
    ],
  );

  Widget _buildSuccess() {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: _amber.withValues(alpha: 0.1),
            border: Border.all(color: _amber.withValues(alpha: 0.4), width: 2)),
          child: const Icon(Icons.check_circle_outline, color: _amber, size: 44),
        ),
        const SizedBox(height: 24),
        Text('Design Published!', style: GoogleFonts.inter(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('Your design is live in the Print Shop.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.white38, fontSize: 14, height: 1.5)),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _amber, foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () => Navigator.pop(context),
          child: Text('Back to Marketplace',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ]),
    ));
  }

  Widget _label(String t) => Text(t, style: GoogleFonts.inter(
    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600));

  Widget _field(TextEditingController ctrl, String label, String hint,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl, maxLines: maxLines, keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        labelStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
        hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
        filled: true, fillColor: _surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _amber)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _bottomButton({
    required String label, required bool enabled,
    required VoidCallback? onTap, IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: enabled ? _amber : _surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled
              ? [BoxShadow(color: _amber.withValues(alpha: 0.3),
                  blurRadius: 16, offset: const Offset(0, 6))] : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[
              Icon(icon, color: enabled ? Colors.black : Colors.white24, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label, style: GoogleFonts.inter(
              color: enabled ? Colors.black : Colors.white24,
              fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(PodCreatorState s) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 95);
    if (picked == null) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final url = await ref.read(podCreatorProvider.notifier).uploadDesign(picked.path, userId);
    if (url != null) _previewKey.currentState?.applyDesign(url);
  }

  Future<void> _publish(PodCreatorState s) async {
    final tags = _tagsCtrl.text.split(',')
        .map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    final ok = await ref.read(podCreatorProvider.notifier).publishDesign(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.tryParse(_priceCtrl.text) ?? 499,
      royaltyPct: _royaltyPct,
      tags: tags,
    );
    if (ok && mounted) setState(() => _step = 2);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(podCreatorProvider);
    final titles = ['Choose Product', 'Upload & Publish', 'Published!'];

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg, elevation: 0,
        leading: _step > 0 && _step < 2
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
              onPressed: () => setState(() => _step--))
          : IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context)),
        title: Text(titles[_step], style: GoogleFonts.inter(
          color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        bottom: _step < 2 ? PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: (_step + 1) / 2,
            backgroundColor: _border, color: _amber,
          ),
        ) : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _step == 0 ? _buildProductPicker(s)
            : _step == 1 ? _buildDesignStep(s)
            : _buildSuccess(),
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isSelected;
  final bool isSoon;
  final VoidCallback? onTap;

  const _ProductCard({
    required this.product, required this.isSelected,
    required this.isSoon, this.onTap,
  });

  IconData _icon(String category) => switch (category) {
    'mug'    => Icons.local_cafe_outlined,
    'bag'    => Icons.shopping_bag_outlined,
    'hoodie' => Icons.dry_cleaning_outlined,
    _        => Icons.checkroom_outlined,
  };

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFFFA000);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected ? amber.withValues(alpha: 0.08) : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? amber : (isSoon ? Colors.white12 : Colors.white.withValues(alpha: 0.08)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: isSelected ? amber.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04)),
                child: Icon(_icon(product['category'] as String? ?? 'tshirt'),
                  color: isSelected ? amber : Colors.white38, size: 30)),
              const SizedBox(height: 12),
              Text(product['name'] as String? ?? '', textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: isSoon ? Colors.white24 : (isSelected ? amber : Colors.white),
                  fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ),
          if (isSoon) Positioned(top: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.white12,
                borderRadius: BorderRadius.circular(20)),
              child: Text('SOON', style: GoogleFonts.inter(
                color: Colors.white38, fontSize: 9, letterSpacing: 1.5)))),
          if (isSelected) const Positioned(top: 10, right: 10,
            child: Icon(Icons.check_circle, color: amber, size: 20)),
        ]),
      ),
    );
  }
}
