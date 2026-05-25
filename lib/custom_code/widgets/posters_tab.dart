import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart' as material;
import 'package:flutter/rendering.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '/flutter_flow/flutter_flow_theme.dart';

class PostersTab extends StatefulWidget {
  final Map<String, dynamic>? profileData;
  final List<Map<String, dynamic>> galleryItems;

  const PostersTab({
    super.key,
    required this.profileData,
    required this.galleryItems,
  });

  @override
  State<PostersTab> createState() => _PostersTabState();
}

class _PostersTabState extends State<PostersTab> {
  final List<GlobalKey> _boundaryKeys = List.generate(5, (_) => GlobalKey());

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
    if (widget.galleryItems.isEmpty) {
      return Center(
        child: Text(
          'Add items to your gallery to create posters!',
          style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText),
        ),
      );
    }

    return material.SingleChildScrollView(
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
            'Professionally designed posters using your gallery items.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          _buildPosterItem(0, _buildDesign1()),
          const SizedBox(height: 32),
          _buildPosterItem(1, _buildDesign2()),
          const SizedBox(height: 32),
          _buildPosterItem(2, _buildDesign3()),
          const SizedBox(height: 32),
          _buildPosterItem(3, _buildDesign4()),
          const SizedBox(height: 32),
          _buildPosterItem(4, _buildDesign5()),
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
            material.ElevatedButton.icon(
              onPressed: () => _sharePoster(index),
              icon: const Icon(material.Icons.share, size: 18),
              label: const Text('Share / Save'),
              style: material.ElevatedButton.styleFrom(
                backgroundColor: material.Colors.yellow,
                foregroundColor: material.Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Design 1: Premium Feature - Large single image with overlay
  Widget _buildDesign1() {
    final name = widget.profileData?['shop_name'] ??
        widget.profileData?['name'] ??
        'Handskill Artist';
    final imageUrl = widget.galleryItems.isNotEmpty
        ? widget.galleryItems[0]['gallery_image_url']
        : '';

    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        color: material.Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
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
                  material.Colors.transparent,
                  material.Colors.black.withValues(alpha: 0.8),
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
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: material.Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(material.Icons.verified,
                        color: material.Colors.blue, size: 24),
                  ],
                ),
                Text(
                  'HANDSKILL PREMIUM ARTIST',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    letterSpacing: 2,
                    color: material.Colors.yellow,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.profileData?['bio'] ??
                      'Expert craftsmanship and unique designs.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: material.Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Design 2: Grid Portfolio
  Widget _buildDesign2() {
    final name = widget.profileData?['name'] ?? 'Handskill Artist';
    final items = widget.galleryItems.take(4).toList();

    return Container(
      width: 400,
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(material.Icons.auto_awesome,
                  color: material.Colors.yellow, size: 24),
              const SizedBox(width: 12),
              Text(
                'COLLECTION BY',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  letterSpacing: 3,
                  color: material.Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(width: 36),
              Text(
                name.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: material.Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: material.GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const material.SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: items[index]['gallery_image_url'] ?? '',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'handskillapp.web.app/${widget.profileData?['slug'] ?? ''}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: material.Colors.yellow.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Design 3: Spotlight - Circular profile focus
  Widget _buildDesign3() {
    final name = widget.profileData?['shop_name'] ??
        widget.profileData?['name'] ??
        'Artist';
    final profileImg = widget.profileData?['profile_image_url'] ?? '';

    return Container(
      width: 400,
      height: 400,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [material.Colors.yellow, material.Colors.orange],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: material.Colors.grey[200],
                    backgroundImage: (profileImg.isNotEmpty) 
                        ? CachedNetworkImageProvider(profileImg) 
                        : null,
                    child: profileImg.isEmpty 
                        ? const Icon(material.Icons.person, size: 50, color: material.Colors.grey) 
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: material.Colors.white,
                    shadows: [
                      const Shadow(
                          blurRadius: 10, color: material.Colors.black26),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: material.Colors.yellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'BOOK NOW',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: material.Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/images/logo.png',
                  width: 100,
                  errorBuilder: (c, e, s) => const Text('HANDSKILL',
                      style: TextStyle(color: material.Colors.white))),
            ),
          ),
        ],
      ),
    );
  }

  // Design 4: Modern Minimalist
  Widget _buildDesign4() {
    final mainImage = widget.galleryItems.length > 1
        ? widget.galleryItems[1]['gallery_image_url']
        : widget.galleryItems[0]['gallery_image_url'];

    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            flex: 55,
            child: CachedNetworkImage(
              imageUrl: mainImage ?? '',
              fit: BoxFit.cover,
              height: 400,
            ),
          ),
          Expanded(
            flex: 45,
            child: Container(
              color: const Color(0xFF131313),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: material.Colors.yellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: material.Colors.yellow.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'MODERN ARTISAN',
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        color: material.Colors.yellow,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CREATIVE',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      color: material.Colors.white,
                      letterSpacing: 1,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'STUDIO',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: material.Colors.white,
                      letterSpacing: 0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 30,
                    height: 3,
                    decoration: BoxDecoration(
                      color: material.Colors.yellow,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.profileData?['shop_name'] ??
                        widget.profileData?['name'] ??
                        'Craftsmanship',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: material.Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Unique Handcrafted Designs',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: material.Colors.grey[400],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(material.Icons.language, size: 12, color: material.Colors.yellow),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'handskillapp.web.app/${widget.profileData?['slug'] ?? ''}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: material.Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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

  // Design 5: The Handskill Card
  Widget _buildDesign5() {
    return Container(
      width: 400,
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(
            color: material.Colors.yellow.withValues(alpha: 0.3), width: 8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(material.Icons.verified_user,
              color: material.Colors.yellow, size: 64),
          const SizedBox(height: 24),
          Text(
            'VERIFIED PARTNER',
            style: GoogleFonts.outfit(
              fontSize: 14,
              letterSpacing: 5,
              color: material.Colors.yellow,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.profileData?['name'] ?? 'Artist',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: material.Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.profileData?['shop_name'] ?? '',
            style: GoogleFonts.outfit(
              fontSize: 18,
              color: material.Colors.grey,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: material.Colors.white),
            ),
            child: Text(
              'handskillapp.web.app/${widget.profileData?['slug'] ?? ''}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: material.Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
