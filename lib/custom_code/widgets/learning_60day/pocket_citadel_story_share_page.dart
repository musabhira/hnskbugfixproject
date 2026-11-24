import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'pocket_world_street_page.dart';
import 'flame_english_house_game.dart';
import 'painters/citadel_scenic_landscape_painter.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_top_rank_theme.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_citadel_video_export_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/president_avatar_widget.dart';
import '../avatar/vector_avatar_config.dart';
import '../avatar/vector_avatar_widget.dart';

/// 📐 Three Social Aspect Ratios with exact 1080p target scales
enum CitadelStoryAspectRatio {
  story9x16(9 / 16, 360.0, 640.0, 'Story (9:16)', Icons.stay_current_portrait_rounded),
  feedPortrait4x5(4 / 5, 360.0, 450.0, 'Portrait (4:5)', Icons.crop_portrait_rounded),
  square1x1(1 / 1, 360.0, 360.0, 'Square (1:1)', Icons.crop_square_rounded);

  final double ratio;
  final double designWidth;
  final double designHeight;
  final String label;
  final IconData icon;

  const CitadelStoryAspectRatio(
    this.ratio,
    this.designWidth,
    this.designHeight,
    this.label,
    this.icon,
  );
}

/// 📸 High-Aesthetic Full-Screen Citadel Story Card Preview & Sharing Page
/// Features:
/// - 3 Aspect Ratios: Story (9:16), Portrait (4:5), Square (1:1)
/// - 3 Swipeable Design Styles:
///   1. "Scrapbook Desk Poster" (Warm kraft paper, torn paper header, washi tape, box card, stickers)
///   2. "Vintage Polaroid Keepsake" (White polaroid card, craft tape, handwritten text, stamp)
///   3. "Cinematic Showcase" (Edge-to-edge landscape with pinned warm paper tag)
/// - Background Music (BGM) playback with mute/unmute control
/// - 15-second Video Export & Image Download
/// - Native OS Share Sheet integration
class PocketCitadelStorySharePage extends StatefulWidget {
  final PocketNeighbor neighbor;
  final int level;
  final int pocketScore;
  final int? globalRank;
  final bool isNight;

  const PocketCitadelStorySharePage({
    super.key,
    required this.neighbor,
    required this.level,
    required this.pocketScore,
    this.globalRank,
    this.isNight = false,
  });

  @override
  State<PocketCitadelStorySharePage> createState() => _PocketCitadelStorySharePageState();
}

class _PocketCitadelStorySharePageState extends State<PocketCitadelStorySharePage> {
  final GlobalKey _cardKey = GlobalKey();
  CitadelStoryAspectRatio _selectedFormat = CitadelStoryAspectRatio.story9x16;
  int _currentTemplateIndex = 0;
  late final PageController _pageController;

  bool _isExporting = false;
  String _exportStatusText = '';
  bool _isBgmMuted = false;

  final List<String> _templateTitles = [
    'Scrapbook Desk Poster',
    'Vintage Polaroid',
    'Cinematic Showcase',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initAudio();
  }

  void _initAudio() {
    try {
      PocketGameAudioService.instance.playAmbientBgm();
      _isBgmMuted = PocketGameAudioService.instance.isMutedNotifier.value;
    } catch (_) {}
  }

  void _toggleBgm() {
    HapticFeedback.lightImpact();
    setState(() {
      _isBgmMuted = !_isBgmMuted;
      PocketGameAudioService.instance.isMutedNotifier.value = _isBgmMuted;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<File?> _captureCardImage() async {
    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final safeName = widget.neighbor.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final fileName = 'PoketMates_${_templateTitles[_currentTemplateIndex].replaceAll(' ', '')}_${safeName}_Day${widget.level}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes, flush: true);
      return file;
    } catch (e) {
      debugPrint('Story card capture error: $e');
      return null;
    }
  }

  Future<void> _downloadImage() async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
      _exportStatusText = 'Saving Card Image...';
    });
    HapticFeedback.mediumImpact();

    try {
      final file = await _captureCardImage();
      if (file == null) throw Exception('Could not render image');

      final appDocDir = await getApplicationDocumentsDirectory();
      final permanentPath = '${appDocDir.path}/${file.uri.pathSegments.last}';
      await file.copy(permanentPath);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Citadel Poster saved to Documents! 📸',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          content: Text('Failed to save card: $e', style: GoogleFonts.outfit(color: Colors.white)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _downloadVideo() async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
      _exportStatusText = 'Creating 15s Story Video with Music...';
    });
    HapticFeedback.heavyImpact();

    try {
      final imageFile = await _captureCardImage();
      if (imageFile == null) throw Exception('Could not render image for video');

      final videoFile = await PocketCitadelVideoExportService.generateStoryVideo(
        imageFile: imageFile,
        durationSeconds: 15,
      );

      if (videoFile == null) {
        // Fallback for platforms where FFmpeg native is unavailable: save image instead
        await _downloadImage();
        return;
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      final permanentPath = '${appDocDir.path}/${videoFile.uri.pathSegments.last}';
      await videoFile.copy(permanentPath);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              const Icon(Icons.movie_creation_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '15-Second Citadel Story Video with Music saved! 🎬',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          content: Text('Failed to create video: $e', style: GoogleFonts.outfit(color: Colors.white)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareCard() async {
    if (_isExporting) return;
    setState(() {
      _isExporting = true;
      _exportStatusText = 'Preparing Share Sheet...';
    });
    HapticFeedback.mediumImpact();

    try {
      final file = await _captureCardImage();
      if (file == null) throw Exception('Could not render image');

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: '🏰 Check out my Day ${widget.level} Citadel in PoketMates! Speak English Every Day ✨',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          content: Text('Failed to share: $e', style: GoogleFonts.outfit(color: Colors.white)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181512),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181512),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Citadel Story Card',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isBgmMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _isBgmMuted ? Colors.white38 : const Color(0xFFF59E0B),
              size: 22,
            ),
            tooltip: _isBgmMuted ? 'Unmute BGM' : 'Mute BGM',
            onPressed: _toggleBgm,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🏷️ Aspect Ratio Selector Pills (Story 9:16, Portrait 4:5, Square 1:1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF26211C),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD4A373).withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: CitadelStoryAspectRatio.values.map((format) {
                    final isSelected = _selectedFormat == format;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedFormat = format);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFD95D39) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFD95D39).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                format.icon,
                                size: 13,
                                color: isSelected ? Colors.white : Colors.white60,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                format.label,
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 📑 Template Carousel Indicator Title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_currentTemplateIndex + 1}/3  •  ',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD4A373),
                    ),
                  ),
                  Text(
                    _templateTitles[_currentTemplateIndex],
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.swipe_rounded, size: 14, color: Colors.white38),
                ],
              ),
            ),

            // 🖼️ Central Swipeable Card Viewport (3 Templates)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: AspectRatio(
                    aspectRatio: _selectedFormat.ratio,
                    child: RepaintBoundary(
                      key: _cardKey,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _selectedFormat.designWidth,
                          height: _selectedFormat.designHeight,
                          child: PageView(
                            controller: _pageController,
                            onPageChanged: (idx) {
                              HapticFeedback.selectionClick();
                              setState(() => _currentTemplateIndex = idx);
                            },
                            children: [
                              _buildTemplate1ScrapbookDesk(),
                              _buildTemplate2PolaroidKeepsake(),
                              _buildTemplate3CinematicShowcase(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ⚡ Bottom Action Bar (Save Image, Save Video, Share)
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 🎨 TEMPLATE 1: "Scrapbook Desk Poster" (Exact Match to User's Uploaded Mood Board)
  // Warm Kraft Paper Desk + Torn Paper Header Banner + Boxed Phone Card + Washi Tape + Stickers
  // =========================================================================
  Widget _buildTemplate1ScrapbookDesk() {
    final isCompact = _selectedFormat == CitadelStoryAspectRatio.square1x1;
    final isPortrait = _selectedFormat == CitadelStoryAspectRatio.feedPortrait4x5;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE5D5BA), // Warm Kraft Paper Texture tone
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 📄 Subtle Kraft Paper Flecks & Grain
          CustomPaint(
            painter: _KraftPaperTexturePainter(),
          ),

          // 🔖 1. Top Torn Paper Banner ("Speak English. Meet Your POKETMates.")
          Positioned(
            top: isCompact ? 8 : (isPortrait ? 10 : 14),
            left: 14,
            right: 14,
            child: _buildTornPaperHeader(),
          ),

          // 📱 2. Center "പെട്ടി കാർഡ്" (Boxed Card Frame with Citadel House Scene)
          Positioned(
            top: isCompact ? 68 : (isPortrait ? 86 : 105),
            bottom: isCompact ? 64 : (isPortrait ? 78 : 96),
            left: 20,
            right: 20,
            child: _buildBoxedCitadelCard(),
          ),

          // 📎 3. Cute Scrapbook Accents (Paperclip, Stickers, Handwritten Doodle)
          // Paperclip top left of torn banner
          Positioned(
            top: isCompact ? 4 : (isPortrait ? 6 : 8),
            left: 24,
            child: _buildRealisticPaperclip(),
          ),

          // Pastel Teal Washi Tape on top-left of the Boxed Card
          Positioned(
            top: isCompact ? 58 : (isPortrait ? 76 : 94),
            left: 12,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: 64,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF99F6E4).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pastel Pink Washi Tape on top-right of the Boxed Card
          Positioned(
            top: isCompact ? 58 : (isPortrait ? 76 : 94),
            right: 12,
            child: Transform.rotate(
              angle: 0.12,
              child: Container(
                width: 64,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFFBCFE8).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Handwritten Marker Doodle ("TODAY WAS A LEVEL X")
          Positioned(
            right: 10,
            bottom: isCompact ? 54 : (isPortrait ? 68 : 84),
            child: Transform.rotate(
              angle: -0.08,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  'TODAY WAS A ${widget.level}!',
                  style: GoogleFonts.permanentMarker(
                    fontSize: 12,
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Flower Sticker bottom right
          Positioned(
            bottom: isCompact ? 4 : (isPortrait ? 6 : 10),
            right: 12,
            child: _buildFlowerSticker(),
          ),

          // Gold Star Sticker
          Positioned(
            left: 12,
            bottom: isCompact ? 48 : (isPortrait ? 62 : 78),
            child: const Text('⭐', style: TextStyle(fontSize: 18)),
          ),

          // 🏷️ 4. Bottom Official Tagline Footer ("PoketMates • Speak English Every Day")
          Positioned(
            bottom: isCompact ? 8 : (isPortrait ? 10 : 12),
            left: 16,
            right: 16,
            child: _buildVintageBrandFooter(),
          ),
        ],
      ),
    );
  }

  /// 🔖 Torn Paper Header Strip (Image 1 & 2 Style)
  Widget _buildTornPaperHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Speak English.',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2E1810), // Rich espresso brown
                letterSpacing: -0.2,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Meet Your POKETMates.',
              style: GoogleFonts.outfit(
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFD95D39), // Warm terracotta orange
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            'Chat. Connect. Build your Home.',
            style: GoogleFonts.outfit(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6E5443),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// 📱 Center "പെട്ടി കാർഡ്" (Boxed Card with House & Scenery + Bottom Kraft Pod)
  Widget _buildBoxedCitadelCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // House Virtual World
            _buildCitadelScenicViewport(),

            // Soft Dark Vignette at bottom for text contrast
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

            // 👑 Bottom Kraft Paper Pod (User Name, Rank, PS)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: _buildKraftPlayerPod(),
            ),
          ],
        ),
      ),
    );
  }

  /// 🏷️ Bottom Kraft Paper Player Pod (Terracotta + Espresso + Gold)
  Widget _buildKraftPlayerPod() {
    final isPresident = widget.neighbor.isPresident;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE), // Warm ivory craft paper
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4A373),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isPresident ? const Color(0xFFD95D39) : const Color(0xFF6E5443),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: isPresident
                  ? const PresidentAvatarWidget(size: 34, showGlow: false)
                  : VectorAvatarWidget(
                      config: VectorAvatarConfig.getEvolutionAvatarForStage(widget.neighbor.day),
                      size: 34,
                    ),
            ),
          ),
          const SizedBox(width: 8),

          // Name and Rank
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.neighbor.name,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2E1810),
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Terracotta Rank Badge
                      _buildTerracottaRankBadge(),
                      const SizedBox(width: 5),
                      Text(
                        'Day ${widget.level}',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6E5443),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // PS Gold Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFF59E0B),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.pocketScore}',
                  style: GoogleFonts.outfit(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF92400E),
                  ),
                ),
                Text(
                  'PS',
                  style: GoogleFonts.outfit(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFD97706),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 📷 TEMPLATE 2: "Vintage Polaroid Keepsake"
  // Authentic white Polaroid photo card + craft yellow washi tape + chin details
  // =========================================================================
  Widget _buildTemplate2PolaroidKeepsake() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFDECDB4), // Warm craft desk
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _KraftPaperTexturePainter()),

          // Center Polaroid Card
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Photo area
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AspectRatio(
                        aspectRatio: 1.05,
                        child: _buildCitadelScenicViewport(),
                      ),
                    ),
                  ),

                  // Polaroid Chin with Handwritten milestone & stats
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Day ${widget.level} Citadel • ${widget.neighbor.name}',
                                style: GoogleFonts.caveat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E1810),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text('❤️', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildTerracottaRankBadge(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '🪙 ${widget.pocketScore} PS',
                                style: GoogleFonts.outfit(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Yellow Washi Tape at top center of Polaroid
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.rotate(
                angle: 0.04,
                child: Container(
                  width: 70,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE047).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Tagline
          Positioned(
            bottom: 8,
            left: 16,
            right: 16,
            child: _buildVintageBrandFooter(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🏔️ TEMPLATE 3: "Cinematic Showcase"
  // Edge-to-edge landscape with floating craft paper card at bottom
  // =========================================================================
  Widget _buildTemplate3CinematicShowcase() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Edge-to-edge Virtual World
        _buildCitadelScenicViewport(),

        // Vignette
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.75),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),

        // Minimalist Top Pill
        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2E1810).withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4A373).withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Text(
              '🏰 Day ${widget.level} Citadel',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),

        // Floating Bottom Kraft Paper Card Pinned with Paperclip
        Positioned(
          bottom: 12,
          left: 14,
          right: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildKraftPlayerPod(),
              const SizedBox(height: 6),
              _buildVintageBrandFooter(darkTone: false),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 🏞️ Shared Estate Viewport: Cosmic Sky + Scenic Mountains + Level House
  // =========================================================================
  Widget _buildCitadelScenicViewport() {
    final isPresident = widget.neighbor.isPresident;
    final isDay90 = widget.level >= 90 || isPresident;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 🌌 Cosmic Ocean & Sky
        CustomPaint(
          painter: CitadelInfiniteOceanSkyBackdropPainter(
            isNight: widget.isNight,
            ambientProg: 0.5,
            planetCode: widget.neighbor.effectivePlanetCode,
          ),
        ),

        // 🏔️ Scenic Terrain & House
        FittedBox(
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.15),
          child: SizedBox(
            width: 1200,
            height: 1600,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: CitadelScenicLandscapePainter(
                      isDamaged: false,
                      groundBaseY: 920.0,
                      isNight: widget.isNight,
                      isDay90: isDay90,
                      ambientProg: 0.5,
                      isPresident: isPresident,
                      planetCode: widget.neighbor.effectivePlanetCode,
                    ),
                  ),
                ),
                if (isPresident)
                  Positioned(
                    left: (1200 - 540) / 2,
                    top: 920 - 14 - 380 + (380 - 410),
                    width: 540,
                    height: 410,
                    child: RepaintBoundary(
                      child: FlameEnglishHouseWidget(
                        currentDay: 90,
                        streak: 90,
                        isDamaged: false,
                        houseId: 'pocket_president',
                        paletteId: widget.neighbor.paletteId,
                        isPresident: true,
                        showTestingControls: false,
                      ),
                    ),
                  )
                else
                  Positioned(
                    left: (1200 - 420) / 2,
                    top: 920 - 14 - 380,
                    width: 420,
                    height: 380,
                    child: RepaintBoundary(
                      child: FlameEnglishHouseWidget(
                        currentDay: widget.level,
                        streak: widget.neighbor.streak > 0 ? widget.neighbor.streak : widget.level,
                        isDamaged: false,
                        houseId: widget.neighbor.id,
                        paletteId: widget.neighbor.paletteId,
                        showTestingControls: false,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 🏷️ Shared Badges & Accents
  // =========================================================================
  Widget _buildTerracottaRankBadge() {
    final isRobot = (widget.neighbor.isPocketRobo ||
            PocketRobotService.isRobotId(widget.neighbor.id)) &&
        !widget.neighbor.isPresident;
    final rank = widget.globalRank;
    final rankText = isRobot
        ? '🤖 Robot #${rank ?? widget.level.clamp(1, 90)}'
        : (widget.neighbor.isPresident
            ? '👑 Rank #1'
            : (rank != null && rank > 0 ? '🏆 Rank #$rank' : '🏆 Challenger'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFD95D39), // Terracotta
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        rankText,
        style: GoogleFonts.outfit(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildVintageBrandFooter({bool darkTone = true}) {
    final textColor = darkTone ? const Color(0xFF4A2E1B) : Colors.white;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/images/pocket_mates_logo.png',
              width: 14,
              height: 14,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.chat_bubble_rounded,
                size: 13,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'PoketMates',
            style: GoogleFonts.outfit(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            ' • Speak English Every Day',
            style: GoogleFonts.outfit(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.8),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealisticPaperclip() {
    return Container(
      width: 12,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF94A3B8), width: 2.2),
      ),
    );
  }

  Widget _buildFlowerSticker() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFDE8E8),
      ),
      alignment: Alignment.center,
      child: const Text('🌸', style: TextStyle(fontSize: 14)),
    );
  }

  // =========================================================================
  // ⚡ Bottom Action Bar (Save Image, Save Video, Share)
  // =========================================================================
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF181512),
        border: Border(
          top: BorderSide(
            color: Color(0xFF26211C),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExporting)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD95D39)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _exportStatusText,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD4A373),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              // 📥 Save Image
              Expanded(
                child: GestureDetector(
                  onTap: _isExporting ? null : _downloadImage,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF26211C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4A373).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_outlined, color: Colors.white, size: 17),
                        const SizedBox(width: 6),
                        Text(
                          'Save Image',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 🎬 Save Video (15s MP4 with BGM)
              Expanded(
                child: GestureDetector(
                  onTap: _isExporting ? null : _downloadVideo,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E1A11),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD95D39).withValues(alpha: 0.45),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.movie_creation_outlined, color: Color(0xFFF97316), size: 17),
                        const SizedBox(width: 6),
                        Text(
                          'Save Video',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFDBA74),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 🚀 Share to Social
              Expanded(
                child: GestureDetector(
                  onTap: _isExporting ? null : _shareCard,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD95D39), Color(0xFFB45309)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD95D39).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.share_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Share',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 🎨 Subtle Kraft Paper Textured Background Painter
class _KraftPaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7A5C3D).withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Subtle paper fiber specks
    const spacing = 28.0;
    for (double x = 4; x < size.width; x += spacing) {
      for (double y = 6; y < size.height; y += spacing) {
        final offset = (x * 7 + y * 13) % 9;
        canvas.drawCircle(Offset(x + offset, y + (offset / 2)), 0.7, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
