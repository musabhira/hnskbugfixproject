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
///
/// Features:
/// - Full-fidelity estate render (Cosmic sky, scenic landscape, house, atmosphere)
/// - Scrapbook / craft card borders & washi-tape aesthetic
/// - Player stats overlay: Name, Level, Rank badge, Pocket Score
/// - Official PoketMates branding: "PoketMates • Speak English Every Day"
/// - 3 aspect ratio modes: Story (9:16), Portrait (4:5), Square (1:1)
/// - High-resolution capture (3.0x pixel ratio)
/// - Direct Download & Native OS Share Sheet integration
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
  bool _isExporting = false;

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
      final fileName = 'PoketMates_Citadel_${safeName}_Day${widget.level}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      debugPrint('Story card capture error: $e');
      return null;
    }
  }

  Future<void> _downloadCard() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
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
                  'Citadel Story Card saved to Documents! 📸',
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

  Future<void> _shareCard() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
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
          content: Text('Failed to share card: $e', style: GoogleFonts.outfit(color: Colors.white)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B132B),
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🏷️ Aspect Ratio Selector Pills (Story 9:16, Portrait 4:5, Square 1:1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
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
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
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
                                size: 14,
                                color: isSelected ? Colors.white : Colors.white60,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                format.label,
                                style: GoogleFonts.outfit(
                                  fontSize: 11.5,
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

            // 🖼️ Central Card Viewport
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: AspectRatio(
                    aspectRatio: _selectedFormat.ratio,
                    child: RepaintBoundary(
                      key: _cardKey,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _selectedFormat.designWidth,
                          height: _selectedFormat.designHeight,
                          child: _buildAestheticCard(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ⚡ Bottom Action Bar (Download & Share Buttons)
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  /// 🎨 Complete Story Card with Atmosphere, House, Overlay Pods & Brand Tagline
  Widget _buildAestheticCard() {
    final isPresident = widget.neighbor.isPresident;
    final isDay90 = widget.level >= 90 || isPresident;
    final int defRank = widget.globalRank ?? 0;
    final rankTheme = PocketTopRankTheme.getThemeForRank(defRank);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🌌 1. Celestial Infinite Ocean & Sky Backdrop
            CustomPaint(
              painter: CitadelInfiniteOceanSkyBackdropPainter(
                isNight: widget.isNight,
                ambientProg: 0.5,
                planetCode: widget.neighbor.effectivePlanetCode,
              ),
            ),

            // 🏔️ 2. Virtual World Landscape & House
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

            // 🌫️ 3. Readability Vignette Gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.20, 0.60, 1.0],
                  ),
                ),
              ),
            ),

            // 🏷️ 4. Scrapbook Paper Tape Accents (Top corners like user's mood board)
            Positioned(
              top: -6,
              left: 20,
              child: Transform.rotate(
                angle: -0.06,
                child: Container(
                  width: 54,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE047).withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -6,
              right: 20,
              child: Transform.rotate(
                angle: 0.06,
                child: Container(
                  width: 54,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF472B6).withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 🏰 5. Top Header Badges
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isPresident
                              ? '👑 SOVEREIGN CITADEL'
                              : '🏰 LEVEL ${widget.level} CITADEL',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFFD700),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪐 ', style: TextStyle(fontSize: 11)),
                        Text(
                          widget.neighbor.effectivePlanetCode.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 👑 6. Bottom Info Overlay Pod + Official Brand Tagline
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Player Pod
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: rankTheme != null
                          ? rankTheme.dominantBg.withValues(alpha: 0.92)
                          : const Color(0xFF0F172A).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: rankTheme != null
                            ? rankTheme.borderColor.withValues(alpha: 0.8)
                            : const Color(0xFFFFD700).withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isPresident
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFFA78BFA),
                              width: 1.5,
                            ),
                          ),
                          child: ClipOval(
                            child: isPresident
                                ? const PresidentAvatarWidget(size: 36, showGlow: false)
                                : VectorAvatarWidget(
                                    config: VectorAvatarConfig.getEvolutionAvatarForStage(widget.neighbor.day),
                                    size: 36,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Name and Rank
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.neighbor.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
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
                                    _buildRankBadge(),
                                    const SizedBox(width: 6),
                                    Text(
                                      '• Day ${widget.level}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Score Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF60A5FA),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.pocketScore}',
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'PS',
                                style: GoogleFonts.outfit(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFFFD700),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 7),

                  // 🏷️ Official PoketMates Branding Footer
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            'assets/images/pocket_mates_logo.png',
                            width: 16,
                            height: 16,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.chat_bubble_rounded,
                              size: 15,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PoketMates',
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          ' • Speak English Every Day',
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.75),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    final isRobot = (widget.neighbor.isPocketRobo ||
            PocketRobotService.isRobotId(widget.neighbor.id)) &&
        !widget.neighbor.isPresident;
    final rank = widget.globalRank;
    final rankText = isRobot
        ? '🤖 Robot Rank #${rank ?? widget.level.clamp(1, 90)}'
        : (widget.neighbor.isPresident
            ? '👑 Global Rank #1'
            : (rank != null && rank > 0
                ? '🏆 Global Rank #$rank'
                : '🏆 Global Challenger'));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Text(
        rankText,
        style: GoogleFonts.outfit(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFFFD700),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 📥 Download Card Button
          Expanded(
            child: GestureDetector(
              onTap: _isExporting ? null : _downloadCard,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Download',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 🚀 Share to Instagram / Social Story Button
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _isExporting ? null : _shareCard,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF8B5CF6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Share Story',
                            style: GoogleFonts.outfit(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
