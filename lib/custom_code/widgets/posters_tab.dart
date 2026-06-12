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
  late final List<GlobalKey> _keys = List.generate(35, (_) => GlobalKey());

  // ── Palette system ──────────────────────────────────────────────────────────

  static const List<List<Color>> _palettes = [
    [Color(0xFF0A0A0F), Color(0xFF1A1230)], // midnight ink
    [Color(0xFF0D1B2A), Color(0xFF1B4332)], // deep forest
    [Color(0xFF1A0A2E), Color(0xFF16213E)], // cosmic grape
    [Color(0xFFFF6B35), Color(0xFFE63946)], // fire coral
    [Color(0xFF2C1654), Color(0xFF6930C3)], // ultraviolet
    [Color(0xFF0F3460), Color(0xFF533483)], // ocean depth
    [Color(0xFF1F1F1F), Color(0xFF3D3D3D)], // graphite
    [Color(0xFF7B2D00), Color(0xFFCC4400)], // ember
    [Color(0xFF00171F), Color(0xFF003459)], // abyss blue
    [Color(0xFF0B3D2E), Color(0xFF145A38)], // malachite
  ];

  static const List<Color> _accents = [
    Color(0xFFFFD60A), // gold
    Color(0xFF00F5D4), // mint
    Color(0xFFFF4D6D), // rose
    Color(0xFFB7E4C7), // sage
    Color(0xFFF8F0E3), // ivory
    Color(0xFF74B9FF), // sky
    Color(0xFFFF9F1C), // amber
    Color(0xFFE9C46A), // wheat
    Color(0xFFCAF0F8), // ice
    Color(0xFFFFB5A7), // blush
  ];

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

    String gImg(int i) {
      if (gallery.isEmpty) return _defaultImages[i % _defaultImages.length];
      final item = gallery[i % gallery.length];
      return item['gallery_image_url'] ??
          item['image_url'] ??
          _defaultImages[i % _defaultImages.length];
    }

    String gTitle(int i) {
      if (gallery.isEmpty) return 'Exquisite Design';
      return gallery[i % gallery.length]['gallery_title'] ??
          gallery[i % gallery.length]['title'] ??
          'Exquisite Design';
    }

    String sTitle(int i) {
      if (services.isEmpty) return 'Bespoke Consultation';
      return services[i % services.length]['service_title'] ??
          services[i % services.length]['service_name'] ??
          'Premium Service';
    }

    String sDesc(int i) {
      if (services.isEmpty) {
        return 'Tailored solutions designed precisely for your unique needs and vision.';
      }
      return services[i % services.length]['service_description'] ??
          services[i % services.length]['description'] ??
          'High quality customized service.';
    }

    String sPrice(int i) {
      if (services.isEmpty) return '499';
      return (services[i % services.length]['service_price'] ??
              services[i % services.length]['price'] ??
              '499')
          .toString();
    }

    String thought(int i) {
      if (thoughts.isEmpty) return _fallbackQuotes[i % _fallbackQuotes.length];
      return thoughts[i % thoughts.length]['content'] ??
          _fallbackQuotes[i % _fallbackQuotes.length];
    }

    // 10 unique layout types
    const layouts = [
      'cinematic',
      'split_edge',
      'neon_frame',
      'manifesto',
      'mosaic',
      'editorial',
      'dark_luxury',
      'stamp',
      'duo_tone',
      'business_card',
    ];

    final configs = <PosterConfig>[];

    for (int i = 0; i < 35; i++) {
      final p = _palettes[i % _palettes.length];
      final acc = _accents[i % _accents.length];
      final layout = layouts[i % layouts.length];
      String? mainImg;
      List<String> extra = [];
      String title = '', subtitle = '', body = '', cta = 'Explore Now';
      String? tagline;

      switch (layout) {
        case 'cinematic':
          mainImg = gImg(i);
          title = gTitle(i);
          subtitle = 'Featured Collection';
          body = bio;
          cta = 'View Gallery';
          tagline = 'by $name';
          break;
        case 'split_edge':
          mainImg = gImg(i);
          title = sTitle(i);
          subtitle = 'Professional Service';
          body = sDesc(i);
          cta = '₹${sPrice(i)} — Book Now';
          tagline = name;
          break;
        case 'neon_frame':
          mainImg = profileImg.isNotEmpty ? profileImg : gImg(i);
          title = name;
          subtitle = 'Verified Partner';
          body = bio;
          cta = 'Connect';
          tagline = 'HANDSKILL APP';
          break;
        case 'manifesto':
          title = thought(i);
          subtitle = name.toUpperCase();
          body = 'handskillapp.web.app/$slug';
          cta = 'Read More';
          tagline = '— Shared by $name';
          break;
        case 'mosaic':
          title = name;
          subtitle = 'Creative Portfolio';
          body = 'A curated showcase of our finest work.';
          cta = 'See All';
          extra = [gImg(i), gImg(i + 1), gImg(i + 2), gImg(i + 3)];
          tagline = 'HANDSKILL';
          break;
        case 'editorial':
          mainImg = gImg(i);
          title = gTitle(i);
          subtitle = 'ISSUE ${(i + 1).toString().padLeft(2, '0')}';
          body = bio;
          cta = 'Enquire';
          tagline = name.toUpperCase();
          break;
        case 'dark_luxury':
          mainImg = gImg(i);
          title = name;
          subtitle = 'Premium Collection';
          body =
              'Discover the art of craftsmanship. Every creation reflects dedication.';
          cta = 'Order Now';
          tagline = 'EXCLUSIVE';
          break;
        case 'stamp':
          title = 'SPECIAL\nOFFER';
          subtitle = 'Exclusive Deal';
          body =
              'Visit handskillapp.web.app/$slug\nfor verified orders and exclusive deals.';
          cta = 'Claim Now';
          tagline = name;
          break;
        case 'duo_tone':
          mainImg = gImg(i);
          title = sTitle(i);
          subtitle = 'Limited Availability';
          body = sDesc(i);
          cta = '₹${sPrice(i)}';
          tagline = name;
          break;
        case 'business_card':
          mainImg = profileImg.isNotEmpty ? profileImg : gImg(i);
          title = name;
          subtitle = 'DIGITAL PROFILE';
          body = bio;
          cta = 'Connect Now';
          tagline = 'handskillapp.web.app/$slug';
          break;
      }

      configs.add(PosterConfig(
        layoutType: layout,
        bgStart: p[0],
        bgEnd: p[1],
        accent: acc,
        mainImageUrl: mainImg,
        extraImageUrls: extra,
        title: title,
        subtitle: subtitle,
        bodyText: body,
        ctaText: cta,
        tagline: tagline,
      ));
    }
    return configs;
  }

  // ── Share / Save ─────────────────────────────────────────────────────────────

  Future<void> _share(int index) async {
    try {
      final boundary = _keys[index].currentContext!.findRenderObject()
          as RenderRepaintBoundary;
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

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final configs = _buildConfigs();
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: configs.length,
            itemBuilder: (ctx, i) => Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: _PosterCard(
                boundaryKey: _keys[i],
                config: configs[i],
                onShare: () => _share(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// POSTER CARD WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

class _PosterCard extends StatelessWidget {
  final GlobalKey boundaryKey;
  final PosterConfig config;
  final VoidCallback onShare;

  const _PosterCard({
    required this.boundaryKey,
    required this.config,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      RepaintBoundary(
        key: boundaryKey,
        child: _buildLayout(config),
      ),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _ShareButton(onTap: onShare),
      ]),
    ]);
  }

  Widget _buildLayout(PosterConfig c) {
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
      default:
        return _CinematicPoster(c: c);
    }
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
        // background image
        if (c.mainImageUrl != null)
          CachedNetworkImage(
              imageUrl: c.mainImageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: c.bgEnd)),
        // vignette
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xDD000000)],
              stops: [0.35, 1.0],
            ),
          ),
        ),
        // top label
        Positioned(
          top: 20,
          left: 20,
          child: _Chip(label: c.tagline ?? 'FEATURED', accent: c.accent),
        ),
        // bottom content
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
                      color: Colors.white,
                      height: 1.15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Text(c.bodyText,
                  style: GoogleFonts.outfit(
                      fontSize: 13, color: Colors.white60, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 18),
              _CtaButton(label: c.ctaText, accent: c.accent),
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
        // background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c.bgStart, c.bgEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // right image with clip
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
        // left text
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
                      color: Colors.white,
                      height: 1.2),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Text(c.bodyText,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.white60, height: 1.6),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 20),
              _CtaButton(label: c.ctaText, accent: c.accent),
              const SizedBox(height: 16),
              Text(c.tagline ?? '',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white30,
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
      color: const Color(0xFF08080D),
      child: Stack(children: [
        // neon glow border
        Positioned.fill(
          child: CustomPaint(painter: _NeonBorderPainter(color: c.accent)),
        ),
        // corner accent dots
        ..._cornerDots(c.accent),
        // center content
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // avatar glow ring
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: c.accent.withOpacity(0.5),
                          blurRadius: 28,
                          spreadRadius: 4)
                    ],
                    border: Border.all(color: c.accent, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.grey[900],
                    backgroundImage:
                        c.mainImageUrl != null && c.mainImageUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(c.mainImageUrl!)
                            : null,
                    child: c.mainImageUrl == null || c.mainImageUrl!.isEmpty
                        ? Icon(Icons.person_outline,
                            size: 48, color: c.accent.withOpacity(0.6))
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
                        color: Colors.white)),
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
                        fontSize: 12, color: Colors.white54, height: 1.6),
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
      ..color = color.withOpacity(0.5)
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
        // big quote mark
        Positioned(
          top: -10,
          left: 14,
          child: Text('"',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 220,
                  color: c.accent.withOpacity(0.07),
                  fontWeight: FontWeight.bold,
                  height: 1)),
        ),
        // accent line top right
        Positioned(
          top: 0,
          right: 0,
          child:
              Container(width: 3, height: 80, color: c.accent.withOpacity(0.7)),
        ),
        // content
        Padding(
          padding: const EdgeInsets.fromLTRB(36, 60, 36, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.title,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
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
                      GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: c.accent.withOpacity(0.12),
                  border: Border.all(color: c.accent.withOpacity(0.4)),
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
        // header
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
                          color: Colors.white),
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
                      color: Colors.black)),
            ),
          ]),
        ),
        // image grid
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
                  // subtle overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.transparent, c.bgEnd.withOpacity(0.3)],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
        // footer
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            c.tagline ?? 'HANDSKILL',
            style: GoogleFonts.outfit(
                fontSize: 10,
                letterSpacing: 4,
                color: Colors.white24,
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
        // full image
        if (c.mainImageUrl != null)
          Positioned.fill(
            child: CachedNetworkImage(
                imageUrl: c.mainImageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: c.bgEnd)),
          ),
        // color-tinted overlay top half
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
                colors: [c.bgStart.withOpacity(0.9), Colors.transparent],
              ),
            ),
          ),
        ),
        // bottom panel
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            decoration: BoxDecoration(color: c.bgEnd.withOpacity(0.95)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(c.subtitle,
                      style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: c.accent.withOpacity(0.3),
                          height: 1)),
                  const SizedBox(width: 14),
                  Container(
                      width: 1, height: 24, color: c.accent.withOpacity(0.5)),
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
                        color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(c.bodyText,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white54, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 14),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.tagline ?? '',
                          style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.white38,
                              fontWeight: FontWeight.bold)),
                      _CtaButton(label: c.ctaText, accent: c.accent),
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
      color: const Color(0xFF080804),
      child: Stack(children: [
        // image half right side
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
                colors: [Colors.transparent, Colors.black],
              ).createShader(bounds),
              child: CachedNetworkImage(
                  imageUrl: c.mainImageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink()),
            ),
          ),
        // text layer
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
                      color: Colors.white,
                      height: 1.25),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              Text(c.bodyText,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.white54, height: 1.7),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis),
              const Spacer(),
              _CtaButton(label: c.ctaText, accent: c.accent),
              const SizedBox(height: 16),
              _GoldDivider(accent: c.accent),
              const SizedBox(height: 10),
              Text(c.tagline ?? '',
                  style: GoogleFonts.inter(
                      fontSize: 9,
                      color: c.accent.withOpacity(0.5),
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
        // big watermark circle
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: c.accent.withOpacity(0.08), width: 40),
            ),
          ),
        ),
        // stamp border
        Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              border: Border.all(color: c.accent.withOpacity(0.7), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.stars_rounded, color: c.accent, size: 40),
              const SizedBox(height: 12),
              Text(c.subtitle.toUpperCase(),
                  style: GoogleFonts.outfit(
                      fontSize: 9,
                      letterSpacing: 4,
                      color: c.accent.withOpacity(0.8),
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(c.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1)),
              const SizedBox(height: 16),
              Container(width: 40, height: 2, color: c.accent),
              const SizedBox(height: 16),
              Text(c.bodyText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.white70, height: 1.6),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(c.ctaText.toUpperCase(),
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2)),
              ),
            ]),
          ),
        ),
        // bottom label
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
                    color: c.accent.withOpacity(0.6))),
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
        // image
        if (c.mainImageUrl != null)
          CachedNetworkImage(
              imageUrl: c.mainImageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: c.bgEnd)),
        // duo-tone color wash
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.bgStart.withOpacity(0.75), c.bgEnd.withOpacity(0.85)],
            ),
          ),
        ),
        // price badge top-right
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
                    color: Colors.black)),
          ),
        ),
        // content bottom
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
                      color: Colors.white,
                      height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Text(c.bodyText,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: Colors.white70, height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),
              Row(children: [
                Container(width: 24, height: 2, color: c.accent),
                const SizedBox(width: 10),
                Text(c.tagline ?? '',
                    style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.white54,
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
          // top bar
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
                  color: c.accent.withOpacity(0.6), size: 22),
            ],
          ),
          const Spacer(),
          // avatar + name
          Row(children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [c.accent, c.bgStart]),
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: Colors.grey[900],
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
                          color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(c.subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.white38)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),
          // bio
          Text(c.bodyText,
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.white60, height: 1.6),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          const Spacer(),
          // footer link bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.accent.withOpacity(0.2)),
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
                          color: Colors.white54)),
                ]),
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
          border: Border.all(color: accent.withOpacity(0.5)),
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
  const _CtaButton({required this.label, required this.accent});
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
                color: Colors.black)),
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
          border: Border.all(color: accent.withOpacity(0.7), width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(label,
            style: GoogleFonts.outfit(
                fontSize: 12, fontWeight: FontWeight.bold, color: accent)),
      );
}

class _ShareButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ShareButton({required this.onTap});
  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.ios_share_rounded, size: 16),
        label: const Text('Share / Save'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD60A),
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
          elevation: 4,
          shadowColor: const Color(0xFFFFD60A).withOpacity(0.4),
          textStyle:
              GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      );
}
