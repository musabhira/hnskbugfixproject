import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/painters/citadel_scenic_landscape_painter.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/flame_english_house_game.dart';

/// 🏡 Poket Cosmos "This is Your Home" Planetary Atmosphere Inspector Modal
/// Features:
/// - Previews the "THIS IS YOUR HOME" (Day 1 Starter Homestead) across all 10 celestial bodies:
///   Earth Prime, Mars, Jupiter, Saturn, Moon, Europa, Venus, Titan, Pluto, Neptune.
/// - Earth is 100% untouched and matches the original baseline perfectly.
/// - Other planets adapt atmospheric shaders (sky gradient, mountains, turf, river)
///   while preserving all structural elements: Day 1 house, rotating Dutch windmill,
///   curving valley river, stone footbridge, cascading waterfall, and swimming swans.
/// - Top 10-planet selector chips + Prev/Next chevron buttons with haptics.
class PoketCosmosHomeInspectorModal extends StatefulWidget {
  final int initialPlanetIndex;

  const PoketCosmosHomeInspectorModal({
    super.key,
    this.initialPlanetIndex = 0,
  });

  static Future<void> show(BuildContext context, {int initialPlanetIndex = 0}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PoketCosmosHomeInspectorModal(
          initialPlanetIndex: initialPlanetIndex,
        ),
      ),
    );
  }

  @override
  State<PoketCosmosHomeInspectorModal> createState() =>
      _PoketCosmosHomeInspectorModalState();
}

class _PoketCosmosHomeInspectorModalState
    extends State<PoketCosmosHomeInspectorModal>
    with SingleTickerProviderStateMixin {
  late ScrollController _chipScrollController;
  late AnimationController _ambientController;
  final TransformationController _transformController = TransformationController();

  int _currentIndex = 0;
  bool _transformInitialized = false;
  final List<CelestialColonyInfo> _colonies = PoketCosmosAllocationService.colonies;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPlanetIndex.clamp(0, _colonies.length - 1);
    _chipScrollController = ScrollController();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToChip(_currentIndex);
    });
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    _ambientController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _scrollToChip(int index) {
    if (!_chipScrollController.hasClients) return;
    final targetOffset = (index * 130.0) - 80.0;
    _chipScrollController.animateTo(
      targetOffset.clamp(0.0, _chipScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPlanetSelected(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
    _scrollToChip(index);
  }

  void _goToPrevPlanet() {
    if (_currentIndex > 0) {
      _onPlanetSelected(_currentIndex - 1);
    } else {
      _onPlanetSelected(_colonies.length - 1);
    }
  }

  void _goToNextPlanet() {
    if (_currentIndex < _colonies.length - 1) {
      _onPlanetSelected(_currentIndex + 1);
    } else {
      _onPlanetSelected(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colony = _colonies[_currentIndex];
    final userPlot = PoketCosmosAllocationService.instance.currentBirthPlot;
    final isUserHomePlanet = userPlot != null &&
        colony.planetName.toLowerCase().contains(userPlot.planetName.toLowerCase().split(' ').first);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Living Panoramic Scenery Viewport (CitadelScenicLandscapePainter + House)
          LayoutBuilder(
            builder: (context, constraints) {
              final screenW = constraints.maxWidth;
              final screenH = constraints.maxHeight;

              const worldW = 1200.0;
              const worldH = 1000.0;
              const groundY = 700.0;

              // House Dimensions & Center Placement
              const houseW = 180.0;
              const houseH = 160.0;
              final houseLeft = (worldW - houseW) / 2;
              final houseTop = groundY - houseH + 20.0;

              // Camera Centering
              final minScale = math.max(screenW / worldW, screenH / worldH) * 1.05;
              final maxScale = minScale * 4.0;

              if (!_transformInitialized) {
                _transformInitialized = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    final targetX = (screenW - (worldW * minScale)) / 2;
                    final targetY = (screenH - (worldH * minScale)) / 2;
                    final initialMatrix = Matrix4.identity();
                    initialMatrix.setEntry(0, 0, minScale);
                    initialMatrix.setEntry(1, 1, minScale);
                    initialMatrix.setEntry(0, 3, targetX);
                    initialMatrix.setEntry(1, 3, targetY);
                    _transformController.value = initialMatrix;
                  }
                });
              }

              return InteractiveViewer(
                transformationController: _transformController,
                minScale: minScale,
                maxScale: maxScale,
                boundaryMargin: EdgeInsets.zero,
                constrained: false,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: worldW,
                  height: worldH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Adaptive Planetary Scenic Landscape Painter
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _ambientController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: CitadelScenicLandscapePainter(
                                isDamaged: false,
                                groundBaseY: groundY,
                                isNight: false,
                                isDay90: false,
                                ambientProg: _ambientController.value,
                                isPresident: false,
                                planetCode: colony.code,
                              ),
                            );
                          },
                        ),
                      ),

                      // 2. Day 1 Starter House in the Exact Center
                      Positioned(
                        left: houseLeft,
                        top: houseTop,
                        width: houseW,
                        height: houseH,
                        child: IgnorePointer(
                          child: RepaintBoundary(
                            child: FlameEnglishHouseWidget(
                              currentDay: 1,
                              streak: 1,
                              isDamaged: false,
                              houseId: 'inspector_starter_home_${colony.code}',
                              showTestingControls: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Left Chevron Button: Previous Planet
          Positioned(
            left: 12,
            top: MediaQuery.of(context).size.height / 2 - 26,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _goToPrevPlanet,
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),

          // 3. Right Chevron Button: Next Planet
          Positioned(
            right: 12,
            top: MediaQuery.of(context).size.height / 2 - 26,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _goToNextPlanet,
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 1.2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),

          // 4. Top Header & Planet Carousel Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopHeaderAndCarousel(context, colony, isUserHomePlanet),
          ),

          // 5. Bottom Planetary Atmosphere Description Card
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _buildBottomAtmosphereCard(context, colony),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeaderAndCarousel(
    BuildContext context,
    CelestialColonyInfo colony,
    bool isUserHomePlanet,
  ) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPadding + 6, bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF020617).withValues(alpha: 0.94),
            const Color(0xFF0F172A).withValues(alpha: 0.85),
            Colors.transparent,
          ],
          stops: const [0.0, 0.70, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Title Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUserHomePlanet
                                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                  : const Color(0xFF0284C7).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isUserHomePlanet ? const Color(0xFF34D399) : const Color(0xFF38BDF8),
                                width: 0.9,
                              ),
                            ),
                            child: Text(
                              isUserHomePlanet ? '🏡 YOUR HOME PLANET' : 'PLANETARY HOMESTEAD',
                              style: GoogleFonts.outfit(
                                color: isUserHomePlanet ? const Color(0xFF6EE7B7) : const Color(0xFF38BDF8),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white24, width: 0.8),
                            ),
                            child: Text(
                              '${_currentIndex + 1}/10',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'THIS IS YOUR HOME',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                      Text(
                        'Day 1 Starter Homestead • ${colony.planetName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.10),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Horizontal 10-Planet Selector Carousel
          SizedBox(
            height: 42,
            child: ListView.builder(
              controller: _chipScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _colonies.length,
              itemBuilder: (context, i) {
                final col = _colonies[i];
                final isSelected = i == _currentIndex;

                return GestureDetector(
                  onTap: () => _onPlanetSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? col.landColor.withValues(alpha: 0.35)
                          : const Color(0xFF1E293B).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? col.landColor : Colors.white12,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: col.landColor.withValues(alpha: 0.40),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          col.planetName,
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAtmosphereCard(BuildContext context, CelestialColonyInfo colony) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colony.landColor.withValues(alpha: 0.65), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colony.landColor.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colony.landColor.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colony.landColor, width: 1.2),
                ),
                child: Text(
                  colony.planetName.split(' ').last,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${colony.planetName} Homestead Atmosphere',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      colony.climate,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFFFD700),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: Text(
                  'PKT-W01-${colony.code}-I01-P01',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF38BDF8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
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
