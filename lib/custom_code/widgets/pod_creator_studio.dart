import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'pod_2d_preview_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/custom_code/widgets/subscription_page.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class PodCreatorState {
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic>? selectedProduct;
  final String? designLocalPath;
  final String? designUploadedUrl;
  final double posX;
  final double posY;
  final double posZ;
  final double scale;
  final double rot;
  final bool isUploading;
  final bool isPublishing;
  final bool b2bAvailable;
  final String? errorMessage;

  const PodCreatorState({
    this.products = const [],
    this.selectedProduct,
    this.designLocalPath,
    this.designUploadedUrl,
    this.posX = 0.5,
    this.posY = 0.4,
    this.posZ = 0.5,
    this.scale = 0.45,
    this.rot = 0,
    this.isUploading = false,
    this.isPublishing = false,
    this.b2bAvailable = false,
    this.errorMessage,
  });

  PodCreatorState copyWith({
    List<Map<String, dynamic>>? products,
    Map<String, dynamic>? selectedProduct,
    String? designLocalPath,
    String? designUploadedUrl,
    double? posX,
    double? posY,
    double? posZ,
    double? scale,
    double? rot,
    bool? isUploading,
    bool? isPublishing,
    bool? b2bAvailable,
    String? errorMessage,
  }) =>
      PodCreatorState(
        products: products ?? this.products,
        selectedProduct: selectedProduct ?? this.selectedProduct,
        designLocalPath: designLocalPath ?? this.designLocalPath,
        designUploadedUrl: designUploadedUrl ?? this.designUploadedUrl,
        posX: posX ?? this.posX,
        posY: posY ?? this.posY,
        posZ: posZ ?? this.posZ,
        scale: scale ?? this.scale,
        rot: rot ?? this.rot,
        isUploading: isUploading ?? this.isUploading,
        isPublishing: isPublishing ?? this.isPublishing,
        b2bAvailable: b2bAvailable ?? this.b2bAvailable,
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
    } catch (e) {
      debugPrint('[POD-CREATOR] Error loading products: $e');
    }
  }

  void selectProduct(Map<String, dynamic> product) =>
      state = state.copyWith(selectedProduct: product);

  void updateCoordinates(double x, double y, double z, double s, double r) {
    state = state.copyWith(posX: x, posY: y, posZ: z, scale: s, rot: r);
  }

  void toggleB2B(bool val) => state = state.copyWith(b2bAvailable: val);

  void centerDesign() {
    state = state.copyWith(posX: 0.5, posY: 0.4, scale: 0.45, rot: 0);
  }

  void rotateDesign(double deltaRad) {
    state = state.copyWith(rot: state.rot + deltaRad);
  }

  Future<String?> uploadDesign(String localPath, String userId) async {
    state = state.copyWith(isUploading: true, errorMessage: null);
    try {
      final ext = localPath.contains('.')
          ? '.${localPath.split('.').last.toLowerCase()}'
          : '.png';
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}$ext';
      final bytes = await File(localPath).readAsBytes();
      await _db.storage.from('pod-design-uploads').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: ext == '.png' ? 'image/png' : 'image/jpeg',
              upsert: true,
            ),
          );
      final url =
          _db.storage.from('pod-design-uploads').getPublicUrl(fileName);
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
    final product = state.selectedProduct;
    final designUrl = state.designUploadedUrl;
    final userId = _db.auth.currentUser?.id;
    if (product == null || designUrl == null || userId == null) return false;

    state = state.copyWith(isPublishing: true, errorMessage: null);
    try {
      await _db.from('pod_designs').insert({
        'artist_id': userId,
        'product_id': product['id'],
        'title': title,
        'description': description,
        'design_image_url': designUrl,
        'sale_price': price,
        'royalty_pct': royaltyPct,
        'tags': tags,
        'status': 'published',
        'b2b_available': state.b2bAvailable,
        'design_pos_x': state.posX,
        'design_pos_y': state.posY,
        'design_pos_z': state.posZ,
        'design_scale': state.scale,
        'design_rot': state.rot,
      });
      state = state.copyWith(isPublishing: false);
      return true;
    } catch (e) {
      state = state.copyWith(isPublishing: false, errorMessage: e.toString());
      return false;
    }
  }
}

final podCreatorProvider =
    NotifierProvider.autoDispose<PodCreatorNotifier, PodCreatorState>(
  PodCreatorNotifier.new,
);

// ─── Widget ───────────────────────────────────────────────────────────────────

class PodCreatorStudio extends ConsumerStatefulWidget {
  const PodCreatorStudio({super.key});

  @override
  ConsumerState<PodCreatorStudio> createState() => _PodCreatorStudioState();
}

class _PodCreatorStudioState extends ConsumerState<PodCreatorStudio> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '499');
  final _tagsCtrl = TextEditingController();

  double _royaltyPct = 20;

  /// 0 = pick product, 1 = design canvas, 2 = details & pricing, 3 = success
  int _step = 0;
  String _currentPlan = 'free';

  static const _amber = Color(0xFFFFFC00);
  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF161616);
  static const _border = Color(0xFF2A2A2A);

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() => _currentPlan = prefs.getString('handskill_plan') ?? 'free');
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  // ── Step 0: Product picker ─────────────────────────────────────────────────
  Widget _buildProductPicker(PodCreatorState s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
          child: Text('Choose a Product',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Text('Pick what you want to print your design on.',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
        ),
        Expanded(
          child: s.products.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: _amber))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: s.products.length,
                  itemBuilder: (_, i) {
                    final product = s.products[i];
                    final isSoon = product['coming_soon'] == true;
                    final isSel =
                        s.selectedProduct?['id'] == product['id'];
                    return _ProductCard(
                      product: product,
                      isSelected: isSel,
                      isSoon: isSoon,
                      onTap: isSoon
                          ? null
                          : () => ref
                              .read(podCreatorProvider.notifier)
                              .selectProduct(product),
                    );
                  },
                ),
        ),
        _bottomButton(
          label: 'Next: Design Canvas',
          enabled: s.selectedProduct != null,
          onTap: () => setState(() => _step = 1),
          icon: Icons.brush_outlined,
        ),
      ],
    );
  }

  // ── Step 1: Interactive Design Canvas ─────────────────────────────────────
  Widget _buildDesignCanvas(PodCreatorState s) {
    final product = s.selectedProduct!;
    return Column(
      children: [
        // ── T-shirt preview fills top portion ────────────────────────────
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Pod2DPreviewWidget(
              mockupImageUrl: product['mockup_image_url'] as String?,
              designImageUrl: s.designUploadedUrl,
              productSlug: product['slug'] as String? ?? '',
              width: double.infinity,
              height: double.infinity,
              posX: s.posX,
              posY: s.posY,
              scale: s.scale,
              rot: s.rot,
              isEditing: true,
              onCoordinatesChanged: (x, y, scale, rot) => ref
                  .read(podCreatorProvider.notifier)
                  .updateCoordinates(x, y, s.posZ, scale, rot),
            ),
          ),
        ),

        // ── Canvas Toolbar ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(
              children: [
                // Upload + Center + Rotate row
                Row(
                  children: [
                    _toolBtn(
                      icon: s.designUploadedUrl != null
                          ? Icons.check_circle_outlined
                          : Icons.upload_file_outlined,
                      label: s.isUploading
                          ? 'Uploading…'
                          : s.designUploadedUrl != null
                              ? 'Change'
                              : 'Upload',
                      color: s.designUploadedUrl != null
                          ? _amber
                          : Colors.white54,
                      onTap:
                          s.isUploading ? null : () => _pickAndUpload(s),
                      isLoading: s.isUploading,
                    ),
                    const SizedBox(width: 8),
                    _toolBtn(
                      icon: Icons.center_focus_strong_outlined,
                      label: 'Center',
                      color: Colors.white54,
                      onTap: () => ref
                          .read(podCreatorProvider.notifier)
                          .centerDesign(),
                    ),
                    const SizedBox(width: 8),
                    _toolBtn(
                      icon: Icons.rotate_right_outlined,
                      label: '+15°',
                      color: Colors.white54,
                      onTap: () => ref
                          .read(podCreatorProvider.notifier)
                          .rotateDesign(0.2618), // 15 degrees in radians
                    ),
                    const SizedBox(width: 8),
                    _toolBtn(
                      icon: Icons.refresh_outlined,
                      label: 'Reset',
                      color: Colors.white30,
                      onTap: () {
                        ref
                            .read(podCreatorProvider.notifier)
                            .updateCoordinates(0.5, 0.4, s.posZ, 0.45, 0);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Scale slider
                Row(
                  children: [
                    const Icon(Icons.photo_size_select_small_outlined,
                        color: Colors.white38, size: 16),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: _amber,
                          thumbColor: _amber,
                          overlayColor: _amber.withValues(alpha: 0.12),
                          inactiveTrackColor: _border,
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8),
                        ),
                        child: Slider(
                          value: s.scale.clamp(0.1, 1.2),
                          min: 0.1,
                          max: 1.2,
                          onChanged: (v) {
                            ref
                                .read(podCreatorProvider.notifier)
                                .updateCoordinates(
                                    s.posX, s.posY, s.posZ, v, s.rot);
                          },
                        ),
                      ),
                    ),
                    const Icon(Icons.photo_size_select_large_outlined,
                        color: Colors.white54, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Next button ───────────────────────────────────────────────────
        _bottomButton(
          label: 'Next: Add Details',
          enabled: s.designUploadedUrl != null,
          onTap: () => setState(() => _step = 2),
          icon: Icons.arrow_forward_ios_outlined,
        ),
      ],
    );
  }

  Widget _toolBtn({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color == _amber
                ? _amber.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: color == _amber
                    ? _amber.withValues(alpha: 0.3)
                    : _border),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (isLoading)
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: _amber, strokeWidth: 2))
            else
              Icon(icon, color: color, size: 18),
            const SizedBox(height: 3),
            Text(label,
                style: GoogleFonts.inter(
                    color: color, fontSize: 9, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  // ── Step 2: Details & Pricing ─────────────────────────────────────────────
  Widget _buildDetailsStep(PodCreatorState s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _label('Design Details'),
            const SizedBox(height: 12),
            _field(_titleCtrl, 'Title *', 'e.g. Sunset Waves Tee'),
            const SizedBox(height: 10),
            _field(_descCtrl, 'Description',
                'Tell buyers about your design…',
                maxLines: 3),
            const SizedBox(height: 10),
            _field(_tagsCtrl, 'Tags (comma separated)',
                'abstract, nature, minimal'),
            const SizedBox(height: 24),
            _label('Pricing'),
            const SizedBox(height: 12),
            _field(_priceCtrl, 'Sale Price (₹)', '499',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Your Royalty',
                  style: GoogleFonts.inter(
                      color: Colors.white60, fontSize: 13)),
              Text('${_royaltyPct.round()}%',
                  style: GoogleFonts.inter(
                      color: _amber,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ]),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: _amber,
                thumbColor: _amber,
                overlayColor: _amber.withValues(alpha: 0.15),
                inactiveTrackColor: _border,
                trackHeight: 3,
              ),
              child: Slider(
                value: _royaltyPct,
                min: 5,
                max: 40,
                divisions: 35,
                onChanged: (v) => setState(() => _royaltyPct = v),
              ),
            ),
            _earningsBreakdown(),
            const SizedBox(height: 24),

            // ── B2B Toggle ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: s.b2bAvailable
                    ? _amber.withValues(alpha: 0.06)
                    : _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: s.b2bAvailable
                        ? _amber.withValues(alpha: 0.35)
                        : _border),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: s.b2bAvailable
                        ? _amber.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.business_outlined,
                      color: s.b2bAvailable ? _amber : Colors.white38,
                      size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('List for B2B Bulk Orders',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                            'Businesses can request 10+ units\nof your design at bulk pricing.',
                            style: GoogleFonts.inter(
                                color: Colors.white38,
                                fontSize: 11,
                                height: 1.4)),
                      ]),
                ),
                Switch(
                  value: s.b2bAvailable,
                  onChanged: (v) =>
                      ref.read(podCreatorProvider.notifier).toggleB2B(v),
                  activeThumbColor: _amber,
                  activeTrackColor: _amber.withValues(alpha: 0.3),
                ),
              ]),
            ),

            const SizedBox(height: 16),
            if (s.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(s.errorMessage!,
                    style: GoogleFonts.inter(
                        color: Colors.redAccent, fontSize: 12)),
              ),
            _bottomButton(
              label:
                  s.isPublishing ? 'Publishing…' : 'Publish to Print Shop',
              enabled: _titleCtrl.text.trim().isNotEmpty && !s.isPublishing,
              onTap: () => _publish(s),
              icon: Icons.rocket_launch_outlined,
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 3: Success ───────────────────────────────────────────────────────
  Widget _buildSuccess(PodCreatorState s) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _amber.withValues(alpha: 0.1),
              border:
                  Border.all(color: _amber.withValues(alpha: 0.4), width: 2),
            ),
            child: const Icon(Icons.check_circle_outline,
                color: _amber, size: 48),
          ),
          const SizedBox(height: 28),
          Text('Design Published!',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            'Your design is now live in the Print Shop.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: Colors.white38, fontSize: 14, height: 1.5),
          ),
          if (s.b2bAvailable) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: _amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _amber.withValues(alpha: 0.25))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.business_outlined,
                    color: _amber, size: 14),
                const SizedBox(width: 6),
                Text('B2B bulk orders enabled',
                    style: GoogleFonts.inter(
                        color: _amber,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ]),
            ),
          ],
          const SizedBox(height: 36),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('Back to Marketplace',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ]),
      ),
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────

  Widget _earningsBreakdown() {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final yourCut = price * (_royaltyPct / 100);
    final platCut = price - yourCut;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border)),
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
          Text(label,
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 2),
          Text(val,
              style: GoogleFonts.inter(
                  color: c, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      );

  Widget _label(String t) => Text(t,
      style: GoogleFonts.inter(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600));

  Widget _field(TextEditingController ctrl, String label, String hint,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
        hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _bottomButton({
    required String label,
    required bool enabled,
    required VoidCallback? onTap,
    IconData? icon,
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
                ? [
                    BoxShadow(
                        color: _amber.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ]
                : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[
              Icon(icon, color: enabled ? Colors.black : Colors.white24, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label,
                style: GoogleFonts.inter(
                    color: enabled ? Colors.black : Colors.white24,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  // ── Callbacks ─────────────────────────────────────────────────────────────

  Future<void> _pickAndUpload(PodCreatorState s) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 95);
    if (picked == null) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await ref.read(podCreatorProvider.notifier).uploadDesign(picked.path, userId);
  }

  Future<void> _publish(PodCreatorState s) async {
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final ok = await ref.read(podCreatorProvider.notifier).publishDesign(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          price: double.tryParse(_priceCtrl.text) ?? 499,
          royaltyPct: _royaltyPct,
          tags: tags,
        );
    if (ok && mounted) setState(() => _step = 3);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_currentPlan == 'free') {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context)
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _amber.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront_rounded, size: 80, color: _amber),
                ),
                const SizedBox(height: 32),
                Text(
                  'Premium Print Shop Creator',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Start your own merchandise brand. Design custom products and sell them directly on the marketplace. Exclusive to Premium Entrepreneurs.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage())).then((_) {
                      _loadPlan();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Upgrade to Premium',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final s = ref.watch(podCreatorProvider);
    final titles = [
      'Choose Product',
      'Place Your Design',
      'Details & Pricing',
      'Published! 🎉',
    ];

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: _step > 0 && _step < 3
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 18),
                onPressed: () => setState(() => _step--))
            : IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context)),
        title: Text(titles[_step],
            style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        bottom: _step < 3
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: (_step + 1) / 4,
                  backgroundColor: _border,
                  color: _amber,
                ),
              )
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_step),
          child: _step == 0
              ? _buildProductPicker(s)
              : _step == 1
                  ? _buildDesignCanvas(s)
                  : _step == 2
                      ? _buildDetailsStep(s)
                      : _buildSuccess(s),
        ),
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
    required this.product,
    required this.isSelected,
    required this.isSoon,
    this.onTap,
  });

  IconData _icon(String category) => switch (category) {
        'mug' => Icons.local_cafe_outlined,
        'bag' => Icons.shopping_bag_outlined,
        'hoodie' => Icons.dry_cleaning_outlined,
        _ => Icons.checkroom_outlined,
      };

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFFFFC00);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected
              ? amber.withValues(alpha: 0.08)
              : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? amber
                : (isSoon
                    ? Colors.white12
                    : Colors.white.withValues(alpha: 0.08)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? amber.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04)),
                child: Icon(
                    _icon(product['category'] as String? ?? 'tshirt'),
                    color: isSelected ? amber : Colors.white38,
                    size: 30),
              ),
              const SizedBox(height: 12),
              Text(product['name'] as String? ?? '',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      color: isSoon
                          ? Colors.white24
                          : (isSelected ? amber : Colors.white),
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              if (product['base_price'] != null) ...[
                const SizedBox(height: 4),
                Text('from ₹${product['base_price']}',
                    style: GoogleFonts.inter(
                        color: Colors.white30, fontSize: 11)),
              ]
            ]),
          ),
          if (isSoon)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('SOON',
                    style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 9,
                        letterSpacing: 1.5)),
              ),
            ),
          if (isSelected)
            const Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.check_circle, color: amber, size: 20),
            ),
        ]),
      ),
    );
  }
}
