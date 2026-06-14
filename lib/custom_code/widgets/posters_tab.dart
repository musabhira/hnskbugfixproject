import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class PosterConfig {
  final String layoutType;
  final Color bgStart;
  final Color bgEnd;
  final Color accent;
  final Color textColor;
  final Color btnTextColor;
  final String? mainImageUrl;
  final List<String> extraImageUrls;
  final String title;
  final String subtitle;
  final String bodyText;
  final String ctaText;
  final String? tagline;

  const PosterConfig({
    required this.layoutType,
    required this.bgStart,
    required this.bgEnd,
    required this.accent,
    this.textColor = Colors.white,
    this.btnTextColor = Colors.black,
    this.mainImageUrl,
    this.extraImageUrls = const [],
    required this.title,
    required this.subtitle,
    required this.bodyText,
    required this.ctaText,
    this.tagline,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class PostersTab extends StatefulWidget {
  final Map<String, dynamic>? profileData;
  final List<Map<String, dynamic>> galleryItems;
  final List<Map<String, dynamic>>? services;
  final List<Map<String, dynamic>>? thoughts;

  const PostersTab({
    super.key,
    required this.profileData,
    required this.galleryItems,
    this.services,
    this.thoughts,
  });

  @override
  State<PostersTab> createState() => _PostersTabState();
}

class _PostersTabState extends State<PostersTab> {
  List<PosterConfig>? _cachedConfigs;

  // ── Fallback data ────────────────────────────────────────────────────────────

  static const List<String> _fallbackQuotes = [
    "Quality is not an act,\nit is a habit.",
    "Crafted with hands,\ndelivered with heart.",
    "Design is intelligence\nmade visible.",
    "Every piece tells\na thousand stories.",
    "Excellence is our\nonly standard.",
    "Passion poured into\nevery product.",
    "Where artistry meets\nprecision.",
    "Your vision, our\ncraftmanship.",
  ];

  static const List<String> _defaultImages = [
    'https://images.unsplash.com/photo-1545239351-cefa43af60f3?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1555099962-4199c345e5dd?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1542744094-3a31f103e35f?auto=format&fit=crop&w=800&q=80',
  ];

  // ── Color parsing helpers ──────────────────────────────────────────────────

  Color _parseHexColor(String? hexCode, Color fallback) {
    if (hexCode == null || hexCode.isEmpty) return fallback;
    try {
      final buffer = StringBuffer();
      String clean = hexCode.replaceAll('#', '').replaceAll('0xFF', '');
      if (clean.length == 6) buffer.write('ff');
      buffer.write(clean);
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  Color _getDarkerShade(Color color) {
    return Color.alphaBlend(Colors.black.withValues(alpha: 0.25), color);
  }

  List<PosterConfig> _getOrBuildConfigs() {
    if (_cachedConfigs != null) return _cachedConfigs!;
    _cachedConfigs = _buildConfigs();
    return _cachedConfigs!;
  }

  // ── Config generator ─────────────────────────────────────────────────────────

  List<PosterConfig> _buildConfigs() {
    final name = widget.profileData?['shop_name'] ??
        widget.profileData?['name'] ??
        'Artisan Studio';
    final bio = widget.profileData?['bio'] ??
        'Premium handcrafted services built with precision and passion.';
    final slug = widget.profileData?['slug'] ?? 'profile';
    final profileImg = widget.profileData?['profile_image_url'] ?? '';

    final gallery = widget.galleryItems;
    final services = widget.services ?? [];
    final thoughts = widget.thoughts ?? [];

    final rawBg = widget.profileData?['bg_color_code'] as String?;
    final rawText = widget.profileData?['bg_text_color'] as String?;
    final rawBtn = widget.profileData?['button_color_code'] as String?;
    final rawBtnText = widget.profileData?['button_text_color'] as String?;

    final bgColor = _parseHexColor(rawBg, const Color(0xFF0F0F12));
    final textColor = _parseHexColor(rawText, Colors.white);
    final btnColor = _parseHexColor(rawBtn, const Color(0xFFFFD60A));
    final btnTextColor = _parseHexColor(rawBtnText, Colors.black);

    final configs = <PosterConfig>[];

    // Helper functions for fallback data
    String gImg(int i) {
      if (gallery.isEmpty) return _defaultImages[i % _defaultImages.length];
      final item = gallery[i % gallery.length];
      return item['gallery_image_url'] ??
          item['image_url'] ??
          _defaultImages[i % _defaultImages.length];
    }

    // 1. Generate Cinematic, Editorial & Dark Luxury Posters for EVERY Gallery Item
    if (gallery.isNotEmpty) {
      for (int i = 0; i < gallery.length; i++) {
        final item = gallery[i];
        final imgUrl = item['gallery_image_url'] ?? item['image_url'] ?? _defaultImages[i % _defaultImages.length];
        final title = item['gallery_title'] ?? item['title'] ?? 'Exquisite Design';
        final desc = item['gallery_description'] ?? item['description'] ?? 'Curated from our creative studio collection.';

        // Cinematic layout for this product
        configs.add(PosterConfig(
          layoutType: 'cinematic',
          bgStart: bgColor,
          bgEnd: _getDarkerShade(bgColor),
          accent: btnColor,
          textColor: textColor,
          btnTextColor: btnTextColor,
          mainImageUrl: imgUrl,
          title: title,
          subtitle: 'Featured Collection',
          bodyText: desc,
          ctaText: 'Enquire / Order',
          tagline: 'by $name',
        ));

        // Editorial layout for this product
        configs.add(PosterConfig(
          layoutType: 'editorial',
          bgStart: bgColor,
          bgEnd: _getDarkerShade(bgColor),
          accent: btnColor,
          textColor: textColor,
          btnTextColor: btnTextColor,
          mainImageUrl: imgUrl,
          title: title,
          subtitle: 'CREATIVE WORKPIECE',
          bodyText: desc,
          ctaText: 'View Details',
          tagline: name.toUpperCase(),
        ));

        // Dark Luxury layout for this product
        configs.add(PosterConfig(
          layoutType: 'dark_luxury',
          bgStart: bgColor,
          bgEnd: _getDarkerShade(bgColor),
          accent: btnColor,
          textColor: textColor,
          btnTextColor: btnTextColor,
          mainImageUrl: imgUrl,
          title: title,
          subtitle: 'Premium Choice',
          bodyText: 'Handcrafted excellence that defines art and quality.',
          ctaText: 'Shop Now',
          tagline: 'EXCLUSIVE',
        ));

        // Glassmorphism layout for this product
        configs.add(PosterConfig(
          layoutType: 'glassmorphism',
          bgStart: bgColor,
          bgEnd: _getDarkerShade(bgColor),
          accent: btnColor,
          textColor: textColor,
          btnTextColor: btnTextColor,
          mainImageUrl: imgUrl,
          title: title,
          subtitle: 'Modern Design',
          bodyText: desc,
          ctaText: 'Discover',
          tagline: name,
        ));
      }
    }

    // 2. Generate Split Edge, Duo Tone & Geometric Minimal Posters for EVERY Service
    if (services.isNotEmpty) {
      for (int i = 0; i < services.length; i++) {
        final service = services[i];
        final title = service['service_title'] ?? service['service_name'] ?? 'Premium Service';
        final desc = service['service_description'] ?? service['description'] ?? 'High quality customized service.';
        final price = (service['service_price'] ?? service['price'] ?? '499').toString();
        final imgUrl = gallery.isNotEmpty ? gImg(i) : _defaultImages[i % _defaultImages.length];

        // Split Edge layout for this service
        configs.add(PosterConfig(
          layoutType: 'split_edge',
          bgStart: bgColor,
          bgEnd: _getDarkerShade(bgColor),
          accent: btnColor,
          textColor: textColor,
          btnTextColor: btnTextColor,
          mainImageUrl: imgUrl,
          title: title,
          subtitle: 'Professional Service',
          bodyText: desc,
          ctaText: '₹$price — Book Now',
          tagline: name,
        ));

        // Duo Tone layout for this service
        configs.add(PosterConfig(
          layoutType: 'duo_tone',
          bgStart: bgColor,
          bgEnd: _getDarkerShade(bgColor),
          accent: btnColor,
          textColor: textColor,
          btnTextColor: btnTextColor,
          mainImageUrl: imgUrl,
          title: title,
          subtitle: 'Limited Slots',
          bodyText: desc,
          ctaText: '₹$price',
          tagline: name,
        ));

        // Geometric Minimal layout for this service
        configs.add(PosterConfig(
          layoutType: 'geometric_minimal',
          bgStart: bgColor,
          bgEnd: _getDarkerShade(bgColor),
          accent: btnColor,
          textColor: textColor,
          btnTextColor: btnTextColor,
          mainImageUrl: imgUrl,
          title: title,
          subtitle: 'Bespoke Experience',
          bodyText: desc,
          ctaText: '₹$price',
          tagline: 'SPECIALIST',
        ));
      }
    }

    // 3. Generate Manifesto & Vintage Craft Posters for EVERY Thought/Thread
    if (thoughts.isNotEmpty) {
      for (int i = 0; i < thoughts.length; i++) {
        final t = thoughts[i];
        final text = t['content'] ?? '';
        if (text.trim().isEmpty) continue;

        configs.add(PosterConfig(
          layoutType: 'manifesto',
          bgStart: bgColor,
          bgEnd: _getDarkerShade(bgColor),
          accent: btnColor,
          textColor: textColor,
          btnTextColor: btnTextColor,
          title: text,
          subtitle: name.toUpperCase(),
          bodyText: 'handskillapp.web.app/$slug',
          ctaText: 'Read More',
          tagline: '— Shared by $name',
        ));

        configs.add(PosterConfig(
          layoutType: 'vintage_craft',
          bgStart: bgColor,
          bgEnd: _getDarkerShade(bgColor),
          accent: btnColor,
          textColor: textColor,
          btnTextColor: btnTextColor,
          title: text,
          subtitle: 'WORDS OF WISDOM',
          bodyText: 'handskillapp.web.app/$slug',
          ctaText: 'Connect',
          tagline: 'by $name',
        ));
      }
    }

    // 4. General Profile Posters (Neon Frame, Mosaic, Business Card, Stamp, Bold Editorial)
    configs.add(PosterConfig(
      layoutType: 'neon_frame',
      bgStart: bgColor,
      bgEnd: _getDarkerShade(bgColor),
      accent: btnColor,
      textColor: textColor,
      btnTextColor: btnTextColor,
      mainImageUrl: profileImg.isNotEmpty ? profileImg : gImg(0),
      title: name,
      subtitle: 'Verified Partner',
      bodyText: bio,
      ctaText: 'Connect',
      tagline: 'HANDSKILL APP',
    ));

    configs.add(PosterConfig(
      layoutType: 'mosaic',
      bgStart: bgColor,
      bgEnd: _getDarkerShade(bgColor),
      accent: btnColor,
      textColor: textColor,
      btnTextColor: btnTextColor,
      title: name,
      subtitle: 'Creative Portfolio',
      bodyText: 'A curated showcase of our finest work.',
      ctaText: 'See All',
      extraImageUrls: [gImg(0), gImg(1), gImg(2), gImg(3)],
      tagline: 'HANDSKILL',
    ));

    configs.add(PosterConfig(
      layoutType: 'business_card',
      bgStart: bgColor,
      bgEnd: _getDarkerShade(bgColor),
      accent: btnColor,
      textColor: textColor,
      btnTextColor: btnTextColor,
      mainImageUrl: profileImg.isNotEmpty ? profileImg : gImg(0),
      title: name,
      subtitle: 'DIGITAL PROFILE',
      bodyText: bio,
      ctaText: 'Connect Now',
      tagline: 'handskillapp.web.app/$slug',
    ));

    configs.add(PosterConfig(
      layoutType: 'stamp',
      bgStart: bgColor,
      bgEnd: _getDarkerShade(bgColor),
      accent: btnColor,
      textColor: textColor,
      btnTextColor: btnTextColor,
      title: 'SPECIAL\nOFFER',
      subtitle: 'Exclusive Deal',
      bodyText: 'Visit handskillapp.web.app/$slug\nfor verified orders and exclusive deals.',
      ctaText: 'Claim Now',
      tagline: name,
    ));

    configs.add(PosterConfig(
      layoutType: 'bold_editorial',
      bgStart: bgColor,
      bgEnd: _getDarkerShade(bgColor),
      accent: btnColor,
      textColor: textColor,
      btnTextColor: btnTextColor,
      title: name,
      subtitle: 'FEATURED CREATOR',
      bodyText: bio,
      ctaText: 'Visit Studio',
      tagline: 'handskillapp.web.app/$slug',
    ));

    return configs;
  }

  // ── Share / Save from Detail ──────────────────────────────────────────────────

  Future<void> _shareFromDetail(BuildContext context, int index, GlobalKey key) async {
    try {
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = bytes!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = await File('${dir.path}/poster_$index.png').create();
      await file.writeAsBytes(pngBytes);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: 'Check out my profile on Handskill App!',
      ));
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  void _openPosterDetail(BuildContext context, int initialIndex, List<PosterConfig> configs) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _PosterDetailScreen(
          configs: configs,
          initialIndex: initialIndex,
          onShare: (idx, key) => _shareFromDetail(context, idx, key),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final configs = _getOrBuildConfigs();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Marketing Posters',
              style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            'Auto-generated branding posters using your products, services & thoughts.',
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 28),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: configs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 400 / 500,
            ),
            itemBuilder: (ctx, i) {
              return GestureDetector(
                onTap: () => _openPosterDetail(context, i, configs),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12, width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AspectRatio(
                    aspectRatio: 400 / 500,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: 400,
                        height: 500,
                        child: IgnorePointer(
                          child: buildPosterLayout(configs[i]),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL VIEW WITH HORIZONTAL PAGE SWIPE
// ─────────────────────────────────────────────────────────────────────────────

class _PosterDetailScreen extends StatefulWidget {
  final List<PosterConfig> configs;
  final int initialIndex;
  final Function(int, GlobalKey) onShare;

  const _PosterDetailScreen({
    required this.configs,
    required this.initialIndex,
    required this.onShare,
  });

  @override
  State<_PosterDetailScreen> createState() => _PosterDetailScreenState();
}

class _PosterDetailScreenState extends State<_PosterDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;
  late final List<GlobalKey> _detailKeys;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _detailKeys = List.generate(widget.configs.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Poster ${_currentIndex + 1} of ${widget.configs.length}',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.configs.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RepaintBoundary(
                            key: _detailKeys[index],
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: SizedBox(
                                  width: 400,
                                  height: 500,
                                  child: buildPosterLayout(widget.configs[index]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Swipe indicator and Share button
          Padding(
            padding: const EdgeInsets.only(bottom: 40, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white54, size: 24),
                      onPressed: _currentIndex > 0
                          ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut)
                          : null,
                    ),
                    const SizedBox(width: 20),
                    _ShareButton(
                      accent: widget.configs[_currentIndex].accent,
                      textColor: widget.configs[_currentIndex].btnTextColor,
                      onTap: () => widget.onShare(_currentIndex, _detailKeys[_currentIndex]),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 24),
                      onPressed: _currentIndex < widget.configs.length - 1
                          ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Swipe left or right to explore layouts',
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildPosterLayout(PosterConfig c) {
  switch (c.layoutType) {
    case 'cinematic':
      return _CinematicPoster(c: c);
    case 'split_edge':
      return _SplitEdgePoster(c: c);
    case 'neon_frame':
      return _NeonFramePoster(c: c);
    case 'manifesto':
      return _ManifestoPoster(c: c);
    case 'mosaic':
      return _MosaicPoster(c: c);
    case 'editorial':
      return _EditorialPoster(c: c);
    case 'dark_luxury':
      return _DarkLuxuryPoster(c: c);
    case 'stamp':
      return _StampPoster(c: c);
    case 'duo_tone':
      return _DuoTonePoster(c: c);
    case 'business_card':
      return _BusinessCardPoster(c: c);
    case 'glassmorphism':
      return _GlassmorphismPoster(c: c);
    case 'geometric_minimal':
      return _GeometricMinimalPoster(c: c);
    case 'vintage_craft':
      return _VintageCraftPoster(c: c);
    case 'bold_editorial':
      return _BoldEditorialPoster(c: c);
    default:
      return _CinematicPoster(c: c);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 1 — CINEMATIC  (full-bleed image + bottom title bar)
// ─────────────────────────────────────────────────────────────────────────────

class _CinematicPoster extends StatelessWidget {
  final PosterConfig c;
  const _CinematicPoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 500,
      child: Stack(fit: StackFit.expand, children: [
        if (c.mainImageUrl != null)
          CachedNetworkImage(
              imageUrl: c.mainImageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: c.bgEnd)),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, c.bgEnd.withValues(alpha: 0.9)],
              stops: const [0.35, 1.0],
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: _Chip(label: c.tagline ?? 'FEATURED', accent: c.accent),
        ),
        Positioned(
          bottom: 28,
          left: 28,
          right: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.subtitle.toUpperCase(),
                  style: GoogleFonts.outfit(
                      fontSize: 10,
                      letterSpacing: 3,
                      color: c.accent,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(c.title,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: c.textColor,
                      height: 1.15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Text(c.bodyText,
                  style: GoogleFonts.outfit(
                      fontSize: 13, color: c.textColor.withValues(alpha: 0.7), height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 18),
              _CtaButton(label: c.ctaText, accent: c.accent, textColor: c.btnTextColor),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 2 — SPLIT EDGE  (left text | right image, sharp diagonal cut)
// ─────────────────────────────────────────────────────────────────────────────

class _SplitEdgePoster extends StatelessWidget {
  final PosterConfig c;
  const _SplitEdgePoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 500,
      child: Stack(fit: StackFit.expand, children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c.bgStart, c.bgEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        ClipPath(
          clipper: _DiagonalClipper(),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 230,
              height: 500,
              child: c.mainImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: c.mainImageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(color: c.bgEnd))
                  : Container(color: c.bgEnd),
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 0,
          bottom: 0,
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 32, height: 3, color: c.accent),
              const SizedBox(height: 14),
              Text(c.subtitle.toUpperCase(),
                  style: GoogleFonts.outfit(
                      fontSize: 9,
                      letterSpacing: 2.5,
                      color: c.accent,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(c.title,
                  style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: c.textColor,
                      height: 1.2),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Text(c.bodyText,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: c.textColor.withValues(alpha: 0.7), height: 1.6),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 20),
              _CtaButton(label: c.ctaText, accent: c.accent, textColor: c.btnTextColor),
              const SizedBox(height: 16),
              Text(c.tagline ?? '',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: c.textColor.withValues(alpha: 0.4),
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ]),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(60, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_DiagonalClipper _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 3 — NEON FRAME  (glowing border, centered profile)
// ─────────────────────────────────────────────────────────────────────────────

class _NeonFramePoster extends StatelessWidget {
  final PosterConfig c;
  const _NeonFramePoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      color: c.bgStart,
      child: Stack(children: [
        Positioned.fill(
          child: CustomPaint(painter: _NeonBorderPainter(color: c.accent)),
        ),
        ..._cornerDots(c.accent),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: c.accent.withValues(alpha: 0.5),
                          blurRadius: 28,
                          spreadRadius: 4)
                    ],
                    border: Border.all(color: c.accent, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: c.bgEnd,
                    backgroundImage:
                        c.mainImageUrl != null && c.mainImageUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(c.mainImageUrl!)
                            : null,
                    child: c.mainImageUrl == null || c.mainImageUrl!.isEmpty
                        ? Icon(Icons.person_outline,
                            size: 48, color: c.accent.withValues(alpha: 0.6))
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(c.subtitle.toUpperCase(),
                    style: GoogleFonts.outfit(
                        fontSize: 9,
                        letterSpacing: 4,
                        color: c.accent,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(c.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: c.textColor)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.verified, color: c.accent, size: 16),
                  const SizedBox(width: 4),
                  Text('Verified Artisan',
                      style: GoogleFonts.outfit(fontSize: 11, color: c.accent)),
                ]),
                const SizedBox(height: 16),
                Text(c.bodyText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: c.textColor.withValues(alpha: 0.7), height: 1.6),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 24),
                _OutlineButton(label: c.ctaText, accent: c.accent),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  List<Widget> _cornerDots(Color accent) {
    const size = 6.0;
    return [
      Positioned(
          top: 20,
          left: 20,
          child: Container(
              width: size,
              height: size,
              decoration:
                  BoxDecoration(color: accent, shape: BoxShape.circle))),
      Positioned(
          top: 20,
          right: 20,
          child: Container(
              width: size,
              height: size,
              decoration:
                  BoxDecoration(color: accent, shape: BoxShape.circle))),
      Positioned(
          bottom: 20,
          left: 20,
          child: Container(
              width: size,
              height: size,
              decoration:
                  BoxDecoration(color: accent, shape: BoxShape.circle))),
      Positioned(
          bottom: 20,
          right: 20,
          child: Container(
              width: size,
              height: size,
              decoration:
                  BoxDecoration(color: accent, shape: BoxShape.circle))),
    ];
  }
}

class _NeonBorderPainter extends CustomPainter {
  final Color color;
  _NeonBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
    final rect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_NeonBorderPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 4 — MANIFESTO  (typographic quote, oversized punctuation)
// ─────────────────────────────────────────────────────────────────────────────

class _ManifestoPoster extends StatelessWidget {
  final PosterConfig c;
  const _ManifestoPoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.bgStart, c.bgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        Positioned(
          top: -10,
          left: 14,
          child: Text('"',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 220,
                  color: c.accent.withValues(alpha: 0.1),
                  fontWeight: FontWeight.bold,
                  height: 1)),
        ),
        Positioned(
          top: 0,
          right: 0,
          child:
              Container(width: 3, height: 80, color: c.accent.withValues(alpha: 0.7)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(36, 60, 36, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.title,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontStyle: FontStyle.italic,
                      color: c.textColor,
                      height: 1.55,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              Row(children: [
                Container(width: 28, height: 2, color: c.accent),
                const SizedBox(width: 12),
                Text(c.subtitle,
                    style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: c.accent)),
              ]),
              const SizedBox(height: 12),
              Text(c.tagline ?? '',
                  style:
                      GoogleFonts.inter(fontSize: 11, color: c.textColor.withValues(alpha: 0.5))),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: c.accent.withValues(alpha: 0.12),
                  border: Border.all(color: c.accent.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(c.bodyText,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: c.accent,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 5 — MOSAIC  (2×2 image grid with title bar)
// ─────────────────────────────────────────────────────────────────────────────

class _MosaicPoster extends StatelessWidget {
  final PosterConfig c;
  const _MosaicPoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      color: c.bgEnd,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          color: c.bgStart,
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.subtitle.toUpperCase(),
                      style: GoogleFonts.outfit(
                          fontSize: 9,
                          letterSpacing: 3,
                          color: c.accent,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(c.title,
                      style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: c.textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: c.accent, borderRadius: BorderRadius.circular(4)),
              child: Text(c.ctaText,
                  style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: c.btnTextColor)),
            ),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: c.extraImageUrls.length.clamp(0, 4),
              itemBuilder: (ctx, idx) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(fit: StackFit.expand, children: [
                  CachedNetworkImage(
                      imageUrl: c.extraImageUrls[idx],
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(color: c.bgStart)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.transparent, c.bgEnd.withValues(alpha: 0.4)],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            c.tagline ?? 'HANDSKILL',
            style: GoogleFonts.outfit(
                fontSize: 10,
                letterSpacing: 4,
                color: c.textColor.withValues(alpha: 0.4),
                fontWeight: FontWeight.bold),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 6 — EDITORIAL  (magazine-style, number + headline)
// ─────────────────────────────────────────────────────────────────────────────

class _EditorialPoster extends StatelessWidget {
  final PosterConfig c;
  const _EditorialPoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 500,
      child: Stack(children: [
        if (c.mainImageUrl != null)
          Positioned.fill(
            child: CachedNetworkImage(
                imageUrl: c.mainImageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: c.bgEnd)),
          ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 200,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [c.bgStart.withValues(alpha: 0.95), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            decoration: BoxDecoration(color: c.bgEnd.withValues(alpha: 0.96)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(c.subtitle,
                      style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: c.accent.withValues(alpha: 0.35),
                          height: 1)),
                  const SizedBox(width: 14),
                  Container(
                      width: 1, height: 24, color: c.accent.withValues(alpha: 0.5)),
                  const SizedBox(width: 14),
                  Text('NEW COLLECTION',
                      style: GoogleFonts.outfit(
                          fontSize: 9,
                          letterSpacing: 3,
                          color: c.accent,
                          fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 8),
                Text(c.title,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: c.textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(c.bodyText,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: c.textColor.withValues(alpha: 0.7), height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 14),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.tagline ?? '',
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: c.textColor.withValues(alpha: 0.5),
                              fontWeight: FontWeight.bold)),
                      _CtaButton(label: c.ctaText, accent: c.accent, textColor: c.btnTextColor),
                    ]),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 7 — DARK LUXURY  (full image, gold foil feel)
// ─────────────────────────────────────────────────────────────────────────────

class _DarkLuxuryPoster extends StatelessWidget {
  final PosterConfig c;
  const _DarkLuxuryPoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      color: c.bgStart,
      child: Stack(children: [
        if (c.mainImageUrl != null)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 200,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.transparent, c.bgEnd],
              ).createShader(bounds),
              child: CachedNetworkImage(
                  imageUrl: c.mainImageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink()),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 48, 180, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GoldDivider(accent: c.accent),
              const SizedBox(height: 20),
              Text(c.subtitle.toUpperCase(),
                  style: GoogleFonts.outfit(
                      fontSize: 9,
                      letterSpacing: 4,
                      color: c.accent,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Text(c.title,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: c.textColor,
                      height: 1.25),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              Text(c.bodyText,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: c.textColor.withValues(alpha: 0.7), height: 1.7),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis),
              const Spacer(),
              _CtaButton(label: c.ctaText, accent: c.accent, textColor: c.btnTextColor),
              const SizedBox(height: 16),
              _GoldDivider(accent: c.accent),
              const SizedBox(height: 10),
              Text(c.tagline ?? '',
                  style: GoogleFonts.inter(
                      fontSize: 9,
                      color: c.accent.withValues(alpha: 0.6),
                      letterSpacing: 2)),
            ],
          ),
        ),
      ]),
    );
  }
}

class _GoldDivider extends StatelessWidget {
  final Color accent;
  const _GoldDivider({required this.accent});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 24, height: 1, color: accent),
        const SizedBox(width: 6),
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Container(width: 24, height: 1, color: accent),
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 8 — STAMP  (rubber-stamp feel, offer/CTA)
// ─────────────────────────────────────────────────────────────────────────────

class _StampPoster extends StatelessWidget {
  final PosterConfig c;
  const _StampPoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [c.bgStart, c.bgEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Stack(children: [
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.accent.withValues(alpha: 0.08), width: 40),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              border: Border.all(color: c.accent.withValues(alpha: 0.7), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.stars_rounded, color: c.accent, size: 40),
              const SizedBox(height: 12),
              Text(c.subtitle.toUpperCase(),
                  style: GoogleFonts.outfit(
                      fontSize: 9,
                      letterSpacing: 4,
                      color: c.accent.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(c.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: c.textColor,
                      height: 1.1)),
              const SizedBox(height: 16),
              Container(width: 40, height: 2, color: c.accent),
              const SizedBox(height: 16),
              Text(c.bodyText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: c.textColor.withValues(alpha: 0.7), height: 1.6),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: c.accent, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(c.ctaText.toUpperCase(),
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: c.accent,
                        letterSpacing: 2)),
              ),
            ]),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Text(c.tagline ?? '',
                style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: c.accent.withValues(alpha: 0.6))),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 9 — DUO TONE  (image with color-wash overlay, bold price badge)
// ─────────────────────────────────────────────────────────────────────────────

class _DuoTonePoster extends StatelessWidget {
  final PosterConfig c;
  const _DuoTonePoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 500,
      child: Stack(fit: StackFit.expand, children: [
        if (c.mainImageUrl != null)
          CachedNetworkImage(
              imageUrl: c.mainImageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: c.bgEnd)),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.bgStart.withValues(alpha: 0.8), c.bgEnd.withValues(alpha: 0.9)],
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: c.accent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(c.ctaText,
                style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: c.btnTextColor)),
          ),
        ),
        Positioned(
          bottom: 28,
          left: 28,
          right: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.subtitle.toUpperCase(),
                  style: GoogleFonts.outfit(
                      fontSize: 9,
                      letterSpacing: 3,
                      color: c.accent,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(c.title,
                  style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: c.textColor,
                      height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Text(c.bodyText,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: c.textColor.withValues(alpha: 0.7), height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),
              Row(children: [
                Container(width: 24, height: 2, color: c.accent),
                const SizedBox(width: 10),
                Text(c.tagline ?? '',
                    style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: c.textColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold)),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 10 — BUSINESS CARD  (horizontal, ultra-clean)
// ─────────────────────────────────────────────────────────────────────────────

class _BusinessCardPoster extends StatelessWidget {
  final PosterConfig c;
  const _BusinessCardPoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.bgStart, c.bgEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DIGITAL PORTFOLIO',
                  style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                      color: c.accent)),
              Icon(Icons.qr_code_2_rounded,
                  color: c.accent.withValues(alpha: 0.6), size: 22),
            ],
          ),
          const Spacer(),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [c.accent, c.bgStart]),
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: c.bgStart,
                backgroundImage:
                    c.mainImageUrl != null && c.mainImageUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(c.mainImageUrl!)
                        : null,
                child: c.mainImageUrl == null || c.mainImageUrl!.isEmpty
                    ? Icon(Icons.person, size: 32, color: c.accent)
                    : null,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title,
                      style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: c.textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(c.subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: c.textColor.withValues(alpha: 0.6))),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Text(c.bodyText,
              style: GoogleFonts.inter(
                  fontSize: 12, color: c.textColor.withValues(alpha: 0.7), height: 1.6),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(c.tagline ?? '',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: c.accent,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 10),
                  Text(c.ctaText.toUpperCase(),
                      style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: c.textColor.withValues(alpha: 0.6))),
                ]),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 11 — GLASSMORPHISM (frosted container, blurred backdrop)
// ─────────────────────────────────────────────────────────────────────────────

class _GlassmorphismPoster extends StatelessWidget {
  final PosterConfig c;
  const _GlassmorphismPoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 500,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (c.mainImageUrl != null)
            CachedNetworkImage(
              imageUrl: c.mainImageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: c.bgEnd),
            )
          else
            Container(color: c.bgEnd),
          ClipRRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 340,
              height: 440,
              decoration: BoxDecoration(
                color: c.bgStart.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        c.subtitle.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: c.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.auto_awesome, color: c.accent, size: 16),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    c.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: c.textColor,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    c.bodyText,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: c.textColor.withValues(alpha: 0.7),
                      height: 1.6,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          c.tagline ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: c.textColor.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _CtaButton(
                        label: c.ctaText,
                        accent: c.accent,
                        textColor: c.btnTextColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 12 — GEOMETRIC MINIMAL (solid blocks, layout lines)
// ─────────────────────────────────────────────────────────────────────────────

class _GeometricMinimalPoster extends StatelessWidget {
  final PosterConfig c;
  const _GeometricMinimalPoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.bgStart, c.bgEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            bottom: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: c.accent.withValues(alpha: 0.1),
                  width: 30,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 24,
            child: Container(
              width: 40,
              height: 4,
              color: c.accent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  c.subtitle.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    letterSpacing: 4,
                    color: c.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  c.title,
                  style: GoogleFonts.outfit(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: c.textColor,
                    height: 1.15,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: c.mainImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: c.mainImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorWidget: (_, __, ___) =>
                                Container(color: c.bgStart),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: c.accent.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.spa_outlined,
                              color: c.accent.withValues(alpha: 0.5),
                              size: 48,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Text(
                  c.bodyText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: c.textColor.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      c.tagline ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: c.textColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _CtaButton(
                      label: c.ctaText,
                      accent: c.accent,
                      textColor: c.btnTextColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 13 — VINTAGE CRAFT (serif fonts, double lines)
// ─────────────────────────────────────────────────────────────────────────────

class _VintageCraftPoster extends StatelessWidget {
  final PosterConfig c;
  const _VintageCraftPoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      color: c.bgStart,
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: c.accent, width: 1.5),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: c.accent, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                c.subtitle.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 8,
                  letterSpacing: 4,
                  color: c.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Icon(Icons.pattern, color: c.accent, size: 24),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Text(
                    c.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: c.textColor,
                      height: 1.5,
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 32,
                height: 1,
                color: c.accent,
              ),
              const SizedBox(height: 16),
              Text(
                c.bodyText,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: c.textColor.withValues(alpha: 0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              _OutlineButton(label: c.ctaText, accent: c.accent),
              const SizedBox(height: 16),
              Text(
                c.tagline ?? '',
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  letterSpacing: 2,
                  color: c.accent.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT 14 — BOLD EDITORIAL (editorial layout, layout overlay text)
// ─────────────────────────────────────────────────────────────────────────────

class _BoldEditorialPoster extends StatelessWidget {
  final PosterConfig c;
  const _BoldEditorialPoster({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      color: c.bgEnd,
      child: Stack(
        children: [
          Positioned(
            left: -20,
            top: 40,
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                'BRAND',
                style: GoogleFonts.outfit(
                  fontSize: 120,
                  fontWeight: FontWeight.w900,
                  color: c.accent.withValues(alpha: 0.05),
                  letterSpacing: 10,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      c.subtitle.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        letterSpacing: 3,
                        color: c.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'EST. 2026',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        color: c.textColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  c.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: c.textColor,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Container(
                  width: 60,
                  height: 3,
                  color: c.accent,
                ),
                const SizedBox(height: 16),
                Text(
                  c.bodyText,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: c.textColor.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CREATIVE STUDIO',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              color: c.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.tagline ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: c.textColor.withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _CtaButton(
                      label: c.ctaText,
                      accent: c.accent,
                      textColor: c.btnTextColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE MICRO-COMPONENTS
// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color accent;
  const _Chip({required this.label, required this.accent});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: accent.withValues(alpha: 0.5)),
        ),
        child: Text(label.toUpperCase(),
            style: GoogleFonts.outfit(
                fontSize: 9,
                letterSpacing: 2,
                color: accent,
                fontWeight: FontWeight.bold)),
      );
}

class _CtaButton extends StatelessWidget {
  final String label;
  final Color accent;
  final Color textColor;
  const _CtaButton({required this.label, required this.accent, this.textColor = Colors.black});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor)),
      );
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final Color accent;
  const _OutlineButton({required this.label, required this.accent});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          border: Border.all(color: accent.withValues(alpha: 0.7), width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(label,
            style: GoogleFonts.outfit(
                fontSize: 12, fontWeight: FontWeight.bold, color: accent)),
      );
}

class _ShareButton extends StatelessWidget {
  final Color accent;
  final Color textColor;
  final VoidCallback onTap;
  const _ShareButton({
    required this.accent,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.ios_share_rounded, size: 16),
        label: const Text('Share / Save'),
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: textColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
          elevation: 4,
          shadowColor: accent.withValues(alpha: 0.4),
          textStyle:
              GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      );
}
