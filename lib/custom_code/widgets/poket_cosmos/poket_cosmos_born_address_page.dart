import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart' hide Matrix4;

import '/flutter_flow/flutter_flow_util.dart';
import 'package:pocket_mates_app/pages/home_page/home_page_widget.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/island_aerial_view.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/flame_solar_system_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_navigator_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/painters/citadel_scenic_landscape_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_pure_kids_home_page.dart';

/// 🌌 Sleek, Minimal, Interactive 4-Stage Pocket Cosmos Born Ceremony
///
/// Features:
/// 1. Strict Viewport Clamping: `fit: StackFit.expand`, `Positioned.fill` on all stages,
///    `boundaryMargin: EdgeInsets.zero`, and `minScale = math.max(w / worldW, h / worldH)`.
///    Guarantees top, bottom, left, and right strictly fill the screen with zero broken bottom and zero black void!
/// 2. Stage 0: THIS IS YOUR PLANET (Flame Solar System zoomed in on Jupiter, minimal green circular Focus FAB)
/// 3. Stage 1: THIS IS YOUR ISLAND (Edge-to-edge island aerial view, calm slow boat speeds, locked top & bottom)
/// 4. Stage 2: THIS IS YOUR PLOT (Smooth 1.8s animated flight zoom into plot coordinates, clean plot without floating badge, CLAIM PLOT button)
/// 5. Stage 3: FULLSCREEN ATTACKING LIVING SCENERY (8s ambient controller for moving clouds & spinning windmill,
///    house focused & zoomed in, minimal compact Born Address badge, gamified green START JOURNEY button)
/// 6. Audio BGM Speaker Toggle on top right on all screens
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

  PoketPlanet? _selectedCosmosPlanet;
  FlameSolarSystemGame? _flameSolarSystemGame;

  // Gentle, calm ambient wave controller for oceanic island (35s relaxed period)
  late AnimationController _islandWaveController;

  // Active 8-second ambient controller for Stage 3 living sky, moving clouds & spinning windmill
  late AnimationController _landscapeAmbientController;

  // Camera flight interpolation controller from Island overview into Plot
  late AnimationController _flightAnimController;
  Matrix4? _flightStartMatrix;
  Matrix4? _flightEndMatrix;

  // Transformation controllers for smooth InteractiveViewer control
  final TransformationController _islandTransformController =
      TransformationController();
  final TransformationController _estateTransformController =
      TransformationController();
  final TransformationController _planetTransformController =
      TransformationController();

  bool _islandTransformInitialized = false;
  bool _estateTransformInitialized = false;
  bool _planetTransformInitialized = false;

  // World dimensions for Adult Attacking Profile Atmosphere
  static const double _worldW = 1200.0;
  static const double _worldH = 1600.0;
  static const double _groundY = 920.0;
  static const double _houseW = 420.0;
  static const double _houseH = 380.0;

  @override
  void initState() {
    super.initState();

    _islandWaveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35),
    )..repeat();

    _landscapeAmbientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _flightAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _flightAnimController.addListener(() {
      if (_flightStartMatrix != null && _flightEndMatrix != null) {
        final t = Curves.easeInOutCubic.transform(_flightAnimController.value);
        _islandTransformController.value =
            _lerpMatrix(_flightStartMatrix!, _flightEndMatrix!, t);
      }
    });

    _initializeBirthplace();
  }

  @override
  void dispose() {
    _islandWaveController.dispose();
    _landscapeAmbientController.dispose();
    _flightAnimController.dispose();
    _islandTransformController.dispose();
    _estateTransformController.dispose();
    _planetTransformController.dispose();
    super.dispose();
  }

  static Matrix4 _lerpMatrix(Matrix4 a, Matrix4 b, double t) {
    final result = Matrix4.zero();
    for (int i = 0; i < 16; i++) {
      result.storage[i] = a.storage[i] + (b.storage[i] - a.storage[i]) * t;
    }
    return result;
  }

  Future<void> _initializeBirthplace() async {
    setState(() => _isLoading = true);

    try {
      PocketGameAudioService.instance.playAmbientAppTheme();
    } catch (_) {}

    final plot =
        await PoketCosmosAllocationService.instance.allocateUserBirthplace(
      inviteCode: widget.initialInviteCode,
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

    // Setup Solar System Game with Camera centered on assigned planet (e.g. Jupiter)
    final allPlanets = PoketCosmosNavigatorPage.buildCosmosPlanets();
    PoketPlanet? matchingPlanet;
    final plotPlanetLower = updatedPlot.planetName.toLowerCase();
    for (final p in allPlanets) {
      final nameLower = p.name.toLowerCase();
      if (nameLower.contains(plotPlanetLower) ||
          plotPlanetLower.contains(nameLower.split(' ').first)) {
        matchingPlanet = p;
        break;
      }
    }
    matchingPlanet ??= allPlanets.firstWhere((p) => p.id == 5, orElse: () => allPlanets.first);
    _selectedCosmosPlanet = matchingPlanet;

    _flameSolarSystemGame = FlameSolarSystemGame(
      planets: allPlanets,
      selectedPlanet: matchingPlanet,
      tiltAngle: 0.42,
      followSelectedPlanet: true, // Focus camera on Jupiter as it orbits!
      onPlanetSelected: (p) {
        setState(() {
          _selectedCosmosPlanet = p;
        });
      },
    );

    _islandTransformInitialized = false;
    _estateTransformInitialized = false;
    _planetTransformInitialized = false;

    if (mounted) {
      setState(() {
        _assignedPlot = updatedPlot;
        _assignedIsland = island;
        _isLoading = false;
      });
    }
  }

  // Smooth cinematic flight into designated plot in Stage 2
  void _animateFlightToPlot(Size screenSize) {
    final sW = screenSize.width;
    final sH = screenSize.height;
    final worldHeight = math.max(sH * 1.5, 1200.0);
    final worldWidth = math.max(sW * 2.8, worldHeight * 1.8);
    const targetScale = 14.0;

    final coords = IslandAerialPainter.get35PlotCoordinates(_assignedIsland.shapeStyle);
    final targetPlotCoord = (_assignedPlot.plotNumber >= 1 && _assignedPlot.plotNumber <= coords.length)
        ? coords[_assignedPlot.plotNumber - 1]
        : Offset.zero;

    final painterScale = ((worldHeight / 850.0) * 1.15).clamp(0.95, 1.50);
    final targetWorldX = worldWidth / 2 + targetPlotCoord.dx * painterScale;
    final targetWorldY = worldHeight / 2 + targetPlotCoord.dy * painterScale;

    final minTx = sW - (worldWidth * targetScale);
    final minTy = sH - (worldHeight * targetScale);
    final dx = (-(targetWorldX * targetScale - sW / 2)).clamp(minTx, 0.0);
    final dy = (-(targetWorldY * targetScale - sH / 2)).clamp(minTy, 0.0);

    final targetMatrix = Matrix4.translationValues(dx, dy, 0.0)
      ..scaleByDouble(targetScale, targetScale, 1.0, 1.0);

    setState(() {
      _currentStage = 2;
    });

    _flightStartMatrix = _islandTransformController.value.clone();
    _flightEndMatrix = targetMatrix;
    _flightAnimController.forward(from: 0.0);
  }

  // Smooth cinematic flight back to full Island overview in Stage 1
  void _animateFlightToOverview(Size screenSize) {
    final sW = screenSize.width;
    final sH = screenSize.height;
    final worldHeight = math.max(sH * 1.5, 1200.0);
    final worldWidth = math.max(sW * 2.8, worldHeight * 1.8);
    final minScale = math.max(sW / worldWidth, sH / worldHeight);
    final focusScale = (minScale * 1.12).clamp(minScale, 3.0);
    final minTx = sW - (worldWidth * focusScale);
    final minTy = sH - (worldHeight * focusScale);
    final focusX = ((sW - worldWidth * focusScale) / 2).clamp(minTx, 0.0);
    final focusY = ((sH - worldHeight * focusScale) / 2).clamp(minTy, 0.0);

    final targetMatrix = Matrix4.translationValues(focusX, focusY, 0.0)
      ..scaleByDouble(focusScale, focusScale, 1.0, 1.0);

    setState(() {
      _currentStage = 1;
    });

    _flightStartMatrix = _islandTransformController.value.clone();
    _flightEndMatrix = targetMatrix;
    _flightAnimController.forward(from: 0.0);
  }

  // Focus and Zoom in closely on the Planet in Stage 0
  void _focusPlanet() {
    HapticFeedback.mediumImpact();
    final size = MediaQuery.of(context).size;
    final sW = size.width;
    final sH = size.height;
    final solarWorldH = math.max(sH * 1.5, 1200.0);
    final solarWorldW = math.max(sW * 2.8, solarWorldH * 1.8);
    final minScale = math.max(sW / solarWorldW, sH / solarWorldH);
    final targetScale = (minScale * 2.2).clamp(minScale, 5.0);

    final minTx = sW - (solarWorldW * targetScale);
    final minTy = sH - (solarWorldH * targetScale);
    final dx = ((sW - solarWorldW * targetScale) / 2).clamp(minTx, 0.0);
    final dy = ((sH - solarWorldH * targetScale) / 2).clamp(minTy, 0.0);

    _planetTransformController.value = Matrix4.translationValues(dx, dy, 0.0)
      ..scaleByDouble(targetScale, targetScale, 1.0, 1.0);
  }

  void _revealGroundAtmosphere() {
    HapticFeedback.heavyImpact();
    try {
      PocketGameAudioService.instance.playVictorySfx();
    } catch (_) {}

    setState(() {
      _currentStage = 3;
      _estateTransformInitialized = false;
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

  void _handleBackNavigation() {
    HapticFeedback.lightImpact();
    if (_currentStage == 3) {
      _animateFlightToPlot(MediaQuery.of(context).size);
    } else if (_currentStage == 2) {
      _animateFlightToOverview(MediaQuery.of(context).size);
    } else if (_currentStage == 1) {
      setState(() => _currentStage = 0);
    } else {
      Navigator.of(context).pop();
    }
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF050B14),
        body: Stack(
          fit: StackFit.expand, // Strictly expands all layers to full screen height & width!
          children: [
            // 🪐 STAGE 0: Moving Solar System with Jupiter centered & zoomed in
            if (_currentStage == 0) Positioned.fill(child: _buildPlanetStageView()),

            // 🏝️ STAGE 1 & 2: Island Aerial Map with smooth flight zoom into plot
            if (_currentStage == 1 || _currentStage == 2)
              Positioned.fill(child: _buildAerialViewport()),

            // 🏡 STAGE 3: Fullscreen Adult Attacking Living Scenery (Locked top & bottom, Day 1 Starter House)
            if (_currentStage == 3)
              Positioned.fill(child: _buildAdultAttackingEstateView()),

            // 🏷️ Top Minimal Navigation Bar with Clean iOS Chevron & Audio Speaker Button
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
      ),
    );
  }

  // =========================================================================
  // 🪐 STAGE 0: THIS IS YOUR PLANET (Solar System with Jupiter centered & zoomed)
  // =========================================================================
  Widget _buildPlanetStageView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sW = constraints.maxWidth;
        final sH = constraints.maxHeight;
        final solarWorldH = math.max(sH * 1.5, 1200.0);
        final solarWorldW = math.max(sW * 2.8, solarWorldH * 1.8);
        final minScale = math.max(sW / solarWorldW, sH / solarWorldH);
        final initialScale = (minScale * 2.2).clamp(minScale, 5.0);

        if (!_planetTransformInitialized && _flameSolarSystemGame != null) {
          _planetTransformInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final minTx = sW - (solarWorldW * initialScale);
              final minTy = sH - (solarWorldH * initialScale);
              final dx = ((sW - solarWorldW * initialScale) / 2).clamp(minTx, 0.0);
              final dy = ((sH - solarWorldH * initialScale) / 2).clamp(minTy, 0.0);
              _planetTransformController.value =
                  Matrix4.translationValues(dx, dy, 0.0)
                    ..scaleByDouble(initialScale, initialScale, 1.0, 1.0);
            }
          });
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Deep space backdrop to eliminate any void
            Positioned.fill(
              child: Container(color: const Color(0xFF0D121D)),
            ),

            // 1. Full-bleed Interactive Solar System Canvas (boundaryMargin: EdgeInsets.zero strictly locks edges!)
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _planetTransformController,
                constrained: false,
                boundaryMargin: EdgeInsets.zero, // Zero boundary margin: Never reveals black void! Locks cleanly at edges!
                minScale: minScale, // Strictly locked so top, bottom, left & right fill screen!
                maxScale: 5.0,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: solarWorldW,
                  height: solarWorldH,
                  child: _flameSolarSystemGame != null
                      ? GameWidget(game: _flameSolarSystemGame!)
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            // 2. Stage 0 Minimal Title Header
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text(
                    'THIS IS YOUR PLANET',
                    style: GoogleFonts.outfit(
                      color: Colors.white60,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    (_selectedCosmosPlanet != null
                            ? _selectedCosmosPlanet!.name.split(' ').first
                            : _assignedPlot.planetName)
                        .toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Minimal Circular Gaming Focus FAB on Right Side
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 82,
              right: 20,
              child: GestureDetector(
                onTap: _focusPlanet,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: const Color(0xFF34D399), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.filter_center_focus_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // 🏝️ STAGE 1 & 2: Island Aerial Map (Strictly locked bounds, zero broken bottom)
  // =========================================================================
  Widget _buildAerialViewport() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final worldHeight = math.max(screenHeight * 1.5, 1200.0);
        final worldWidth = math.max(screenWidth * 2.8, worldHeight * 1.8);
        final minScale = math.max(screenWidth / worldWidth, screenHeight / worldHeight);
        final focusScale = (minScale * 1.12).clamp(minScale, 3.0);
        final minTx = screenWidth - (worldWidth * focusScale);
        final minTy = screenHeight - (worldHeight * focusScale);
        final focusX = ((screenWidth - worldWidth * focusScale) / 2).clamp(minTx, 0.0);
        final focusY = ((screenHeight - worldHeight * focusScale) / 2).clamp(minTy, 0.0);

        if (!_islandTransformInitialized) {
          _islandTransformInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _islandTransformController.value == Matrix4.identity()) {
              _islandTransformController.value =
                  Matrix4.translationValues(focusX, focusY, 0.0)
                    ..scaleByDouble(focusScale, focusScale, 1.0, 1.0);
            }
          });
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Deep water backdrop behind island to guarantee zero black border
            Positioned.fill(
              child: Container(color: _assignedIsland.waterColor),
            ),

            // Interactive Full-bleed Island Canvas (boundaryMargin: EdgeInsets.zero prevents void & jumps!)
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _islandTransformController,
                constrained: false,
                boundaryMargin: EdgeInsets.zero, // Zero boundary margin: Locks edges cleanly, no black void!
                minScale: minScale, // Strictly locked to screen bounds! Zero letterbox bars!
                maxScale: 22.0,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: worldWidth,
                  height: worldHeight,
                  child: CustomPaint(
                    painter: IslandAerialPainter(
                      island: _assignedIsland,
                      isInteractive: true,
                      selectedPlotNumber: _assignedPlot.plotNumber,
                      plots: [_assignedPlot],
                      animation: _islandWaveController,
                    ),
                  ),
                ),
              ),
            ),

            // Top Header: Title
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
                  if (_currentStage == 2) ...[
                    const SizedBox(height: 2),
                    Text(
                      _assignedPlot.streetName,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF38BDF8),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Re-center Plot Button in Stage 2
            if (_currentStage == 2)
              Positioned(
                right: 18,
                top: MediaQuery.of(context).padding.top + 56,
                child: IconButton(
                  onPressed: () => _animateFlightToPlot(Size(screenWidth, screenHeight)),
                  icon: const Icon(Icons.my_location_rounded,
                      color: Color(0xFF22C55E), size: 22),
                  tooltip: 'Re-center plot',
                ),
              ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // 🏡 STAGE 3: Fullscreen Adult Attacking Living Landscape (Locked bounds, zero void)
  // =========================================================================
  Widget _buildAdultAttackingEstateView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sW = constraints.maxWidth;
        final sH = constraints.maxHeight;
        final minScale = math.max(sW / _worldW, sH / _worldH);
        const maxScale = 3.5;
        // Zoomed in nicely on the house like attacking profile
        final houseZoomScale = (sW / (_houseW * 1.05));
        final defaultScale = math.max(minScale, houseZoomScale);

        if (!_estateTransformInitialized) {
          _estateTransformInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final houseCenterX = _worldW / 2;
              final houseCenterY = (_groundY - 14.0 - _houseH) + (_houseH * 0.52);
              final maxTx = 0.0;
              final minTx = sW - (_worldW * defaultScale);
              final tx = ((sW / 2) - (houseCenterX * defaultScale)).clamp(minTx, maxTx);

              final maxTy = 0.0;
              final minTy = sH - (_worldH * defaultScale);
              final targetTy = (sH * 0.44) - (houseCenterY * defaultScale);
              final ty = targetTy.clamp(minTy, maxTy);

              final matrix = Matrix4.identity();
              matrix.setEntry(0, 0, defaultScale);
              matrix.setEntry(1, 1, defaultScale);
              matrix.setEntry(0, 3, tx);
              matrix.setEntry(1, 3, ty);
              _estateTransformController.value = matrix;
            }
          });
        }

        const houseLeft = (_worldW - _houseW) / 2;
        const houseTop = _groundY - 14.0 - _houseH;

        final plotPinCode = 'PKT-${_assignedPlot.plotNumber.toString().padLeft(3, '0')}';
        final bornAddressLine =
            '${widget.userName} • Plot #${_assignedPlot.plotNumber}, ${_assignedPlot.streetName} • PIN: $plotPinCode • ${_assignedPlot.countryName}, ${_assignedPlot.planetName}';

        return Stack(
          fit: StackFit.expand,
          children: [
            // Boundless Ocean & Sky Backdrop behind InteractiveViewer (Guarantees zero black void!)
            Positioned.fill(
              child: CustomPaint(
                painter: CitadelInfiniteOceanSkyBackdropPainter(
                  isNight: false,
                  ambientProg: _landscapeAmbientController.value,
                ),
              ),
            ),

            // 🌄 Fullscreen Interactive Estate with Living Scenery (8s ambient controller for moving clouds & windmill)
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _estateTransformController,
                minScale: minScale, // Strictly locked so top, bottom, left & right fill screen completely!
                maxScale: maxScale,
                boundaryMargin: EdgeInsets.zero, // Zero boundary margin: Never reveals black void! Locks cleanly at edges!
                constrained: false,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _worldW,
                  height: _worldH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Living Scenery Landscape Painter (Lively drifting clouds, flapping birds, rotating windmill sails)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _landscapeAmbientController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: CitadelScenicLandscapePainter(
                                isDamaged: false,
                                groundBaseY: _groundY,
                                isNight: false,
                                isDay90: false,
                                ambientProg: _landscapeAmbientController.value,
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

            // Compact Minimal Gamified Born Address Badge (No bloated cards!)
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 84,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
                      width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.40),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BORN ADDRESS',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF34D399),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            bornAddressLine,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: bornAddressLine));
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📋 Born Address copied!'),
                            duration: Duration(milliseconds: 1200),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Icon(Icons.copy_rounded,
                          color: Color(0xFF34D399), size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================================
  // 🏷️ Top Navigation Bar (Clean iOS Back Chevron & Audio Speaker Button)
  // =========================================================================
  Widget _buildTopNavigationBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // iOS-style Back Chevron Button (Clean icon only)
          GestureDetector(
            onTap: _handleBackNavigation,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          const Spacer(),

          // 🔊 Audio BGM Speaker Toggle Button (Top Right)
          ValueListenableBuilder<bool>(
            valueListenable: PocketGameAudioService.instance.isMutedNotifier,
            builder: (context, isMuted, _) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  PocketGameAudioService.instance.toggleMute();
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: !isMuted ? const Color(0xFF38BDF8) : Colors.white24,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      !isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: !isMuted ? const Color(0xFF38BDF8) : Colors.white60,
                      size: 18,
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

  // =========================================================================
  // 🔘 Minimal Gamified Green Bottom Action Bar
  // =========================================================================
  Widget _buildBottomActionBar() {
    String buttonText = 'NEXT ➔';
    VoidCallback? onTap;

    if (_currentStage == 0) {
      buttonText = 'NEXT ➔';
      onTap = () => _animateFlightToOverview(MediaQuery.of(context).size);
    } else if (_currentStage == 1) {
      buttonText = 'NEXT ➔';
      onTap = () => _animateFlightToPlot(MediaQuery.of(context).size);
    } else if (_currentStage == 2) {
      buttonText = 'CLAIM PLOT ➔';
      onTap = _revealGroundAtmosphere;
    } else {
      buttonText = 'START JOURNEY 🚀';
      onTap = _settleAndBeginJourney;
    }

    // Gaming green button style across all stages
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF34D399), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
      ),
    );
  }
}
