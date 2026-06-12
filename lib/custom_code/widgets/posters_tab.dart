import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart' as material;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pocket_mates_app/flutter_flow/flutter_flow_theme.dart';

class PosterConfig {
  final String layoutType;
  final Color bgStartColor;
  final Color bgEndColor;
  final Color accentColor;
  final Color textColor;
  final String? mainImageUrl;
  final List<String> extraImageUrls;
  final String title;
  final String subtitle;
  final String bodyText;
  final String ctaText;

  PosterConfig({
    required this.layoutType,
    required this.bgStartColor,
    required this.bgEndColor,
    required this.accentColor,
    required this.textColor,
    this.mainImageUrl,
    this.extraImageUrls = const [],
    required this.title,
    required this.subtitle,
    required this.bodyText,
    required this.ctaText,
  });
}

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
  late final List<GlobalKey> _boundaryKeys = List.generate(35, (_) => GlobalKey());

  final List<List<Color>> _gradients = [
    [const Color(0xFF1E1E24), const Color(0xFF0F0F12)], // Dark Luxury
    [const Color(0xFFB8860B), const Color(0xFF8B6508)], // Luxury Gold
    [const Color(0xFF4A148C), const Color(0xFF1A237E)], // Royal Purple
    [const Color(0xFFE65100), const Color(0xFFDD2C00)], // Vibrant Red-Orange
    [const Color(0xFF004D40), const Color(0xFF006064)], // Teal Green
    [const Color(0xFF1A237E), const Color(0xFF0D47A1)], // Indigo Blue
    [const Color(0xFFFF6F00), const Color(0xFFFF3D00)], // Sunset Amber
    [const Color(0xFF880E4F), const Color(0xFF4A148C)], // Rose Velvet
    [const Color(0xFF0D324D), const Color(0xFF7F5A83)], // Cosmic Purple
    [const Color(0xFF114B5F), const Color(0xFF1A936F)], // Emerald Night
  ];

  final List<String> _fallbackQuotes = [
    "Quality is not an act, it is a habit.",
    "Believing in handcrafted excellence.",
    "Your business is our passion.",
    "Creativity is intelligence having fun.",
    "Crafting unique experiences daily.",
    "Design is thinking made visual.",
    "Supporting local, building global.",
    "Every piece tells a story.",
    "Innovative solutions for your needs.",
    "Tradition meets modern craftsmanship.",
    "Empowering talent, showcasing art.",
    "Excellence in every detail.",
  ];

  List<PosterConfig> _generateConfigs() {
    final List<PosterConfig> configs = [];
    final name = widget.profileData?['shop_name'] ?? widget.profileData?['name'] ?? 'Entrepreneur';
    final bio = widget.profileData?['bio'] ?? 'Premium handcrafted services and products.';
    final slug = widget.profileData?['slug'] ?? '';
    final profileImg = widget.profileData?['profile_image_url'] ?? '';

    final gallery = widget.galleryItems;
    final services = widget.services ?? [];
    final thoughts = widget.thoughts ?? [];

    final defaultImages = [
      'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1542744094-3a31f103e35f?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=600&q=80',
    ];

    String getGalleryImg(int index) {
      if (gallery.isEmpty) return defaultImages[index % defaultImages.length];
      final item = gallery[index % gallery.length];
      return item['gallery_image_url'] ?? item['image_url'] ?? defaultImages[index % defaultImages.length];
    }

    String getGalleryTitle(int index) {
      if (gallery.isEmpty) return 'Exquisite Design';
      return gallery[index % gallery.length]['gallery_title'] ?? gallery[index % gallery.length]['title'] ?? 'Exquisite Design';
    }

    String getServiceTitle(int index) {
      if (services.isEmpty) return 'Consultation';
      return services[index % services.length]['service_title'] ?? services[index % services.length]['service_name'] ?? 'Premium Service';
    }

    String getServiceDesc(int index) {
      if (services.isEmpty) return 'Tailored solutions designed precisely for your business and personal growth.';
      return services[index % services.length]['service_description'] ?? services[index % services.length]['description'] ?? 'High quality customized service.';
    }

    String getServicePrice(int index) {
      if (services.isEmpty) return '499';
      return (services[index % services.length]['service_price'] ?? services[index % services.length]['price'] ?? '499').toString();
    }

    String getThoughtText(int index) {
      if (thoughts.isEmpty) return _fallbackQuotes[index % _fallbackQuotes.length];
      return thoughts[index % thoughts.length]['content'] ?? _fallbackQuotes[index % _fallbackQuotes.length];
    }

    final layouts = ['showcase', 'spotlight', 'service', 'quote', 'grid', 'minimalist', 'business_card', 'coupon'];

    for (int i = 0; i < 35; i++) {
      final gradIndex = i % _gradients.length;
      final bgStart = _gradients[gradIndex][0];
      final bgEnd = _gradients[gradIndex][1];
      final layout = layouts[i % layouts.length];

      String title = '';
      String subtitle = '';
      String bodyText = '';
      String ctaText = 'Enquire Now';
      String? mainImage;
      List<String> extraImages = [];

      if (layout == 'showcase') {
        mainImage = getGalleryImg(i);
        title = getGalleryTitle(i);
        subtitle = 'FEATURED PRODUCT';
        bodyText = 'Discovered in our creative collection. Order yours today.';
        ctaText = 'Buy / Order';
      } else if (layout == 'spotlight') {
        mainImage = profileImg.isNotEmpty ? profileImg : getGalleryImg(i);
        title = name;
        subtitle = 'VERIFIED PARTNER';
        bodyText = bio;
        ctaText = 'Book Appointment';
      } else if (layout == 'service') {
        mainImage = getGalleryImg(i);
        title = getServiceTitle(i);
        subtitle = 'PROFESSIONAL SERVICE';
        bodyText = getServiceDesc(i);
        ctaText = 'Book for ₹${getServicePrice(i)}';
      } else if (layout == 'quote') {
        title = 'WORDS OF WISDOM';
        subtitle = name;
        bodyText = getThoughtText(i);
        ctaText = 'Read Slogans';
      } else if (layout == 'grid') {
        title = name;
        subtitle = 'CREATIVE SHOWCASE';
        bodyText = 'Explore our portfolio catalog.';
        extraImages = [
          getGalleryImg(i),
          getGalleryImg(i + 1),
          getGalleryImg(i + 2),
          getGalleryImg(i + 3),
        ];
      } else if (layout == 'minimalist') {
        mainImage = getGalleryImg(i);
        title = name;
        subtitle = 'DESIGN STUDIO';
        bodyText = getGalleryTitle(i);
        ctaText = 'View Work';
      } else if (layout == 'business_card') {
        mainImage = profileImg.isNotEmpty ? profileImg : getGalleryImg(i);
        title = name;
        subtitle = 'DIGITAL PROFILE';
        bodyText = bio;
        ctaText = 'Connect Now';
      } else if (layout == 'coupon') {
        mainImage = getGalleryImg(i);
        title = 'SPECIAL INVITATION';
        subtitle = 'EXCLUSIVE PARTNER';
        bodyText = 'Use link handskillapp.web.app/$slug for verified orders.';
        ctaText = 'Claim Deal';
      }

      configs.add(
        PosterConfig(
          layoutType: layout,
          bgStartColor: bgStart,
          bgEndColor: bgEnd,
          accentColor: const Color(0xFFFFD600),
          textColor: Colors.white,
          mainImageUrl: mainImage,
          extraImageUrls: extraImages,
          title: title,
          subtitle: subtitle,
          bodyText: bodyText,
          ctaText: ctaText,
        ),
      );
    }
    return configs;
  }

  Future<void> _sharePoster(int index) async {
    try {
      RenderRepaintBoundary boundary = _boundaryKeys[index]
          .currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/poster_$index.png').create();
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Check out my profile on Handskill App!',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing poster: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final configs = _generateConfigs();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Marketing Posters',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dynamic branding flyers created automatically using your products, thoughts, and services.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: configs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: _buildPosterItem(index, _buildPosterFromConfig(configs[index])),
              );
            },
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildPosterItem(int index, Widget posterLayout) {
    return Column(
      children: [
        RepaintBoundary(
          key: _boundaryKeys[index],
          child: posterLayout,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _sharePoster(index),
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share / Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD600),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPosterFromConfig(PosterConfig config) {
    switch (config.layoutType) {
      case 'showcase':
        return _buildShowcasePoster(config);
      case 'spotlight':
        return _buildSpotlightPoster(config);
      case 'service':
        return _buildServicePoster(config);
      case 'quote':
        return _buildQuotePoster(config);
      case 'grid':
        return _buildGridPoster(config);
      case 'minimalist':
        return _buildMinimalistPoster(config);
      case 'business_card':
        return _buildBusinessCardPoster(config);
      case 'coupon':
        return _buildCouponPoster(config);
      default:
        return _buildShowcasePoster(config);
    }
  }

  Widget _buildShowcasePoster(PosterConfig config) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        color: config.bgEndColor,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (config.mainImageUrl != null)
            CachedNetworkImage(
              imageUrl: config.mainImageUrl!,
              width: 400,
              height: 400,
              fit: BoxFit.cover,
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.95),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: config.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  config.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  config.bodyText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: config.accentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    config.ctaText.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightPoster(PosterConfig config) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [config.bgStartColor, config.bgEndColor],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [config.accentColor, Colors.orange],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: config.mainImageUrl != null && config.mainImageUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(config.mainImageUrl!)
                        : null,
                    child: config.mainImageUrl == null || config.mainImageUrl!.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      config.title,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: Colors.blue, size: 20),
                  ],
                ),
                Text(
                  config.subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: config.accentColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  config.bodyText,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    config.ctaText,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicePoster(PosterConfig config) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [config.bgStartColor, config.bgEndColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  config.subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: config.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.star, color: Colors.amber, size: 18),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            config.title,
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            config.bodyText,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXCLUSIVE SERVICE',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  Text(
                    'handskillapp.web.app',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: config.accentColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  config.ctaText,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuotePoster(PosterConfig config) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [config.bgStartColor, config.bgEndColor],
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Opacity(
              opacity: 0.1,
              child: Text(
                '“',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 140,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 0.8,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  config.bodyText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 40,
                  height: 2,
                  color: config.accentColor,
                ),
                const SizedBox(height: 12),
                Text(
                  config.subtitle.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: config.accentColor,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Opacity(
              opacity: 0.2,
              child: Text(
                'HANDSKILL',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridPoster(PosterConfig config) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        color: config.bgEndColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            config.subtitle,
            style: GoogleFonts.outfit(
              fontSize: 10,
              letterSpacing: 3,
              color: config.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            config.title.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: config.extraImageUrls.length.clamp(0, 4),
              itemBuilder: (context, idx) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: config.extraImageUrls[idx],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Explore full portfolio on Handskill App',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistPoster(PosterConfig config) {
    return Container(
      width: 400,
      height: 400,
      color: const Color(0xFF0F0F11),
      child: Row(
        children: [
          Expanded(
            flex: 45,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CREATIVE',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: config.accentColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    config.title.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 20,
                    height: 2,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    config.bodyText,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    'HANDSKILL',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.3),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 55,
            child: config.mainImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: config.mainImageUrl!,
                    fit: BoxFit.cover,
                    height: 400,
                  )
                : Container(color: Colors.grey[900]),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCardPoster(PosterConfig config) {
    final isDark = config.bgEndColor.computeLuminance() < 0.2;
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [config.bgStartColor, config.bgEndColor],
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DIGITAL PORTFOLIO',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: config.accentColor,
                ),
              ),
              const Icon(Icons.qr_code, color: Colors.white, size: 24),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withOpacity(0.1),
                backgroundImage: config.mainImageUrl != null && config.mainImageUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(config.mainImageUrl!)
                    : null,
                child: config.mainImageUrl == null || config.mainImageUrl!.isEmpty
                    ? const Icon(Icons.person, size: 30, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.title,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      config.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            config.bodyText,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'handskillapp.web.app/${widget.profileData?['slug'] ?? ''}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: config.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  config.ctaText.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponPoster(PosterConfig config) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        color: config.bgEndColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config.accentColor.withOpacity(0.4), width: 3),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.stars, color: config.accentColor, size: 48),
          const SizedBox(height: 12),
          Text(
            config.subtitle,
            style: GoogleFonts.outfit(
              fontSize: 11,
              letterSpacing: 4,
              color: config.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            config.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              config.bodyText,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              config.ctaText.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
