import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/island_aerial_view.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/planet_sphere_icon_widget.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/painters/citadel_scenic_landscape_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_pure_kids_home_page.dart';

/// 🌌 Sleek, Minimal, Interactive 4-Stage Pocket Cosmos Born Ceremony
///
/// Features:
/// 1. iOS-style back navigation on all screens
/// 2. Stage 0: THIS IS YOUR PLANET (Steady 3D rotating planet, pinch-to-zoom & spin, minimal text, referral code prompt)
/// 3. Stage 1: THIS IS YOUR ISLAND (Pinch-to-zoom & pan across the full 35-plot island map, steady relaxed speed)
/// 4. Stage 2: THIS IS YOUR PLOT (Deep zoom into the exact plot space with interactive zoom & pulsing green tap badge)
/// 5. Stage 3: FULLSCREEN ATTACKING PROFILE ATMOSPHERE (Open world landscape, Day 1 house, interactive zoom & pan, minimal address)
class PoketCosmosBornAddressPage extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final int? userAge;
  final String? initialInviteCode;

  const PoketCosmosBornAddressPage({
    super.key,
    required this.userName,
    this.userAvatar = '🦁',
    this.userAge,
    this.initialInviteCode,
  });

  static Future<void> launch(
    BuildContext context, {
    required String userName,
    String userAvatar = '🦁',
    int? userAge,
    String? initialInviteCode,
    String? inviteCode,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PoketCosmosBornAddressPage(
          userName: userName,
          userAvatar: userAvatar,
          userAge: userAge,
          initialInviteCode: initialInviteCode ?? inviteCode,
        ),
      ),
    );
  }

  @override
  State<PoketCosmosBornAddressPage> createState() =>
      _PoketCosmosBornAddressPageState();
}

class _PoketCosmosBornAddressPageState extends State<PoketCosmosBornAddressPage>
    with TickerProviderStateMixin {
  int _currentStage = 0;
  bool _isLoading = true;

  late CitizenPlot _assignedPlot;
  late PoketCountryMap _assignedIsland;
  String? _activeReferralCode;

  // Gentle, calm ambient breathe controller (8s relaxed period)
  late AnimationController _ambientBreatheController;

  // Transformation controllers for smooth InteractiveViewer control
  final TransformationController _islandTransformController =
      TransformationController();
  final TransformationController _estateTransformController =
      TransformationController();
  final TransformationController _planetTransformController =
      TransformationController();

  final TextEditingController _inviteCodeController = TextEditingController();

  // World dimensions for Adult Attacking Profile Atmosphere
  static const double _worldW = 1200.0;
  static const double _worldH = 1600.0;
  static const double _groundY = 920.0;
  static const double _houseW = 420.0;
  static const double _houseH = 380.0;

  @override
  void initState() {
    super.initState();

    _ambientBreatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _initializeBirthplace();
  }

  @override
  void dispose() {
    _ambientBreatheController.dispose();
    _islandTransformController.dispose();
    _estateTransformController.dispose();
    _planetTransformController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _initializeBirthplace({String? code}) async {
    setState(() => _isLoading = true);

    try {
      PocketGameAudioService.instance.playAmbientAppTheme();
    } catch (_) {}

    final inviteCode = code ?? widget.initialInviteCode;
    _activeReferralCode = inviteCode;

    final plot =
        await PoketCosmosAllocationService.instance.allocateUserBirthplace(
      inviteCode: inviteCode,
      userName: widget.userName,
      avatar: widget.userAvatar,
    );

    final isJupiter = plot.planetName.toLowerCase().contains('jup');
    final island = PoketCountryMap(
      id: isJupiter ? 401 : 301,
      name: plot.countryName,
      tag: isJupiter ? 'Jupiter Living Colony' : 'Premier Habit Colony',
      landColor: isJupiter ? const Color(0xFF059669) : const Color(0xFF16A34A),
      waterColor: isJupiter ? const Color(0xFF0369A1) : const Color(0xFF0284C7),
      totalSlots: 35,
      filledSlots: 31,
      climate: isJupiter
          ? 'Stormy Cosmic Azure 🪐'
          : 'Tropical Azure Breeze 🌊',
      climateIcon: Icons.water_drop_rounded,
      shapeSeed: plot.plotNumber * 13,
      shapeStyle: isJupiter ? IslandShapeStyle.crescentLagoon : IslandShapeStyle.ringAtoll,
    );

    final coords = IslandAerialPainter.get35PlotCoordinates(island.shapeStyle);
    final targetPos = (plot.plotNumber >= 1 && plot.plotNumber <= coords.length)
        ? coords[plot.plotNumber - 1]
        : Offset.zero;

    final updatedPlot = plot.copyWith(coordinates: targetPos);

    if (mounted) {
      setState(() {
        _assignedPlot = updatedPlot;
        _assignedIsland = island;
        _isLoading = false;
      });
    }
  }

  // Focus camera deep into the designated plot in Stage 2
  void _zoomDeepToPlot() {
    final target = _assignedPlot.coordinates;
    const scale = 3.6;

    final matrix = Matrix4.identity();
    matrix.translate(-target.dx * scale + 180, -target.dy * scale + 340);
    matrix.scale(scale, scale);

    setState(() {
      _currentStage = 2;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _islandTransformController.value = matrix;
      }
    });
  }

  // Reset island camera to full overview in Stage 1
  void _resetIslandToOverview() {
    setState(() {
      _currentStage = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _islandTransformController.value = Matrix4.identity();
      }
    });
  }

  void _revealGroundAtmosphere() {
    HapticFeedback.heavyImpact();
    try {
      PocketGameAudioService.instance.playVictorySfx();
    } catch (_) {}

    setState(() => _currentStage = 3);

    // Smoothly initialize camera centered on the Day 1 house in the scenic landscape
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final houseCenterX = _worldW / 2;
        final houseCenterY = (_groundY - 14.0 - _houseH) + (_houseH * 0.52);

        final w = MediaQuery.of(context).size.width;
        final h = MediaQuery.of(context).size.height;
        const defaultScale = 1.05;

        final tx = ((w / 2) - (houseCenterX * defaultScale));
        final ty = ((h * 0.44) - (houseCenterY * defaultScale));

        final matrix = Matrix4.identity();
        matrix.setEntry(0, 0, defaultScale);
        matrix.setEntry(1, 1, defaultScale);
        matrix.setEntry(0, 3, tx);
        matrix.setEntry(1, 3, ty);
        _estateTransformController.value = matrix;
      }
    });
  }

  Future<void> _settleAndBeginJourney() async {
    HapticFeedback.heavyImpact();
    await PoketCosmosAllocationService.instance.saveBirthplace(_assignedPlot);

    if (!mounted) return;

    final age = widget.userAge ?? 20;
    if (age <= 9) {
      PocketPureKidsHomePage.launch(context);
    } else {
      context.goNamedAuth(HomePageWidget.routeName, context.mounted);
    }
  }

  void _showInviteCodeDialog() {
    _inviteCodeController.text = _activeReferralCode ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
        ),
        title: Row(
          children: [
            const Text('🎟️', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Island Referral Code',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'കൂട്ടുകാരന്റെ ഐലൻഡ് കോഡ് ഉണ്ടെങ്കിൽ ഇവിടെ നൽകുക:',
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _inviteCodeController,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.outfit(
                color: const Color(0xFFFDE047),
                fontWeight: FontWeight.bold,
                fontSize: 17,
                letterSpacing: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. PKT-JUPITER',
                hintStyle: GoogleFonts.outfit(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('PKT-JUPITER 🪐',
                      style: TextStyle(fontSize: 11, color: Color(0xFFFDE047))),
                  backgroundColor: const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  onPressed: () => _inviteCodeController.text = 'PKT-JUPITER',
                ),
                ActionChip(
                  label: const Text('PKT-TEST 🌍',
                      style: TextStyle(fontSize: 11, color: Color(0xFF38BDF8))),
                  backgroundColor: const Color(0xFF1E293B),
                  side: const BorderSide(color: Color(0xFF38BDF8)),
                  onPressed: () => _inviteCodeController.text = 'PKT-TEST',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.outfit(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              final code = _inviteCodeController.text.trim();
              Navigator.pop(ctx);
              if (code.isNotEmpty) {
                _initializeBirthplace(code: code);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Color _getPlanetPrimaryColor(String planetName) {
    final p = planetName.toLowerCase();
    if (p.contains('jup')) return const Color(0xFFD97706);
    if (p.contains('sat')) return const Color(0xFFEAB308);
    if (p.contains('mars')) return const Color(0xFFDC2626);
    return const Color(0xFF0284C7);
  }

  Color _getPlanetGlowColor(String planetName) {
    final p = planetName.toLowerCase();
    if (p.contains('jup')) return const Color(0xFFFDE047);
    if (p.contains('sat')) return const Color(0xFFFEF08A);
    if (p.contains('mars')) return const Color(0xFFFCA5A5);
    return const Color(0xFF38BDF8);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF050B14),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF38BDF8),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      body: Stack(
        children: [
          // 🪐 STAGE 0: Steady, Round 3D Rotating Planet (Pinch-to-zoom & Drag-to-spin)
          if (_currentStage == 0) _buildPlanetStageView(),

          // 🏝️ STAGE 1 & 2: Interactive Island Aerial Map (Overview or Deep Plot Zoom)
          if (_currentStage == 1 || _currentStage == 2) _buildAerialViewport(),

          // 🏡 STAGE 3: Fullscreen Adult Attacking Profile Atmosphere (Living Scenery + House)
          if (_currentStage == 3) _buildAdultAttackingEstateView(),

          // 🏷️ Top Minimal Navigation Bar with iOS Back Button
          _buildTopNavigationBar(),

          // 🔘 Minimal Floating Bottom Action Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🪐 STAGE 0: THIS IS YOUR PLANET (Clean, Minimal, Steady 3D Rotation)
  // =========================================================================
  Widget _buildPlanetStageView() {
    final planetName = _assignedPlot.planetName;
    final primaryColor = _getPlanetPrimaryColor(planetName);
    final glowColor = _getPlanetGlowColor(planetName);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF050B14),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 70),

            // Minimal Title
            Text(
              'THIS IS YOUR PLANET',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              planetName.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),

            const Spacer(),

            // Interactive 3D Planet: Steady (No wobbling!), Pinch-to-zoom & Touch-to-spin
            Expanded(
              flex: 5,
              child: Center(
                child: InteractiveViewer(
                  transformationController: _planetTransformController,
                  minScale: 0.8,
                  maxScale: 2.6,
                  boundaryMargin: const EdgeInsets.all(40),
                  child: Center(
                    child: PlanetSphereIconWidget(
                      name: planetName.toLowerCase(),
                      primaryColor: primaryColor,
                      glowColor: glowColor,
                      size: 280.0,
                      enableInteractiveSpin: true,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 🏝️ STAGE 1 & 2: Island Aerial Map (Interactive Pan & Pinch-to-Zoom)
  // =========================================================================
  Widget _buildAerialViewport() {
    final targetPos = _assignedPlot.coordinates;

    return Stack(
      children: [
        // Interactive Island Canvas with Pinch-to-Zoom & Pan
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _islandTransformController,
            minScale: 0.7,
            maxScale: 4.8,
            boundaryMargin: const EdgeInsets.all(200),
            clipBehavior: Clip.none,
            child: SizedBox(
              width: 1000,
              height: 1000,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: IslandAerialPainter(
                        island: _assignedIsland,
                        isInteractive: true,
                        selectedPlotNumber: _assignedPlot.plotNumber,
                        plots: [_assignedPlot],
                        animation: _ambientBreatheController,
                      ),
                    ),
                  ),

                  // In Stage 2 (Deep Zoom): Glowing green target directly over the house
                  if (_currentStage == 2)
                    Positioned(
                      left: targetPos.dx - 45,
                      top: targetPos.dy - 45,
                      child: GestureDetector(
                        onTap: _revealGroundAtmosphere,
                        child: AnimatedBuilder(
                          animation: _ambientBreatheController,
                          builder: (context, _) {
                            final pulse = math.sin(_ambientBreatheController.value * math.pi * 4).abs();
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF052E16)
                                        .withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: const Color(0xFF22C55E),
                                        width: 1.8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF22C55E)
                                            .withValues(alpha: 0.45 * pulse + 0.25),
                                        blurRadius: 18,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🟢',
                                          style: TextStyle(fontSize: 13)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'TAP HERE 🎯',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF86EFAC),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Icon(
                                  Icons.touch_app_rounded,
                                  color: const Color(0xFF22C55E),
                                  size: 28 + 4 * pulse,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Stage 1 & 2 Minimal Title Header
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          left: 20,
          right: 20,
          child: Column(
            children: [
              Text(
                _currentStage == 1
                    ? 'THIS IS YOUR ISLAND'
                    : 'THIS IS YOUR PLOT',
                style: GoogleFonts.outfit(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _currentStage == 1
                    ? _assignedIsland.name.toUpperCase()
                    : 'PLOT #${_assignedPlot.plotNumber}',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),

        // Focus plot button in Stage 2
        if (_currentStage == 2)
          Positioned(
            right: 18,
            top: MediaQuery.of(context).padding.top + 56,
            child: IconButton(
              onPressed: _zoomDeepToPlot,
              icon: const Icon(Icons.my_location_rounded,
                  color: Color(0xFF22C55E), size: 22),
              tooltip: 'Re-center plot',
            ),
          ),
      ],
    );
  }

  // =========================================================================
  // 🏡 STAGE 3: Fullscreen Adult Attacking Profile Atmosphere (House & Scenery)
  // =========================================================================
  Widget _buildAdultAttackingEstateView() {
    const houseLeft = (_worldW - _houseW) / 2;
    const houseTop = _groundY - 14.0 - _houseH;

    return Stack(
      children: [
        // 🌄 Fullscreen Interactive Estate with Pinch-to-Zoom & Pan (from Attacking Profile)
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: _estateTransformController,
            minScale: 0.45,
            maxScale: 3.2,
            boundaryMargin: const EdgeInsets.all(200),
            clipBehavior: Clip.none,
            child: SizedBox(
              width: _worldW,
              height: _worldH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Living Scenery Landscape Painter (Lush hills, clouds, balloon, swans, windmill)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _ambientBreatheController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: CitadelScenicLandscapePainter(
                            isDamaged: false,
                            groundBaseY: _groundY,
                            isNight: false,
                            isDay90: false,
                            ambientProg: _ambientBreatheController.value,
                            isPresident: false,
                          ),
                        );
                      },
                    ),
                  ),

                  // 2. Day 1 Starter House in the Center
                  Positioned(
                    left: houseLeft,
                    top: houseTop,
                    width: _houseW,
                    height: _houseH,
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: FlameEnglishHouseWidget(
                          currentDay: 1,
                          streak: 1,
                          isDamaged: false,
                          houseId: 'starter_home',
                          showTestingControls: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Top Minimal Title
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          left: 20,
          right: 20,
          child: Column(
            children: [
              Text(
                'THIS IS YOUR HOME',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Day 1 Starter Homestead',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Sleek Minimal Address Card floating above the bottom action bar
        Positioned(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + 85,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('🏡', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Plot #${_assignedPlot.plotNumber}, ${_assignedPlot.streetName}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_assignedPlot.countryName} • ${_assignedPlot.planetName}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white60,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
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
  // 🏷️ Top Navigation Bar (iOS-Style Back Button & Minimal Referral Trigger)
  // =========================================================================
  Widget _buildTopNavigationBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // iOS-style Back Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (_currentStage == 2) {
                _resetIslandToOverview();
              } else if (_currentStage > 0) {
                setState(() => _currentStage--);
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24, width: 1.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Back',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Minimal Referral Code Trigger (Only in Stage 0)
          if (_currentStage == 0)
            GestureDetector(
              onTap: _showInviteCodeDialog,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _activeReferralCode != null
                        ? const Color(0xFF10B981)
                        : Colors.white24,
                  ),
                ),
                child: Text(
                  _activeReferralCode != null ? '🤝 Applied' : '🎟️ Referral Code?',
                  style: GoogleFonts.outfit(
                    color: _activeReferralCode != null
                        ? const Color(0xFFA7F3D0)
                        : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🔘 Minimal Floating Bottom Action Bar
  // =========================================================================
  Widget _buildBottomActionBar() {
    String buttonText = 'NEXT ➔';
    VoidCallback? onTap;

    if (_currentStage == 0) {
      buttonText = 'NEXT ➔';
      onTap = _resetIslandToOverview;
    } else if (_currentStage == 1) {
      buttonText = 'NEXT ➔';
      onTap = _zoomDeepToPlot;
    } else if (_currentStage == 2) {
      // In Stage 2, user taps on the glowing green indicator directly over the plot
      return const SizedBox.shrink();
    } else if (_currentStage == 3) {
      buttonText = 'START JOURNEY 🚀';
      onTap = _settleAndBeginJourney;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
