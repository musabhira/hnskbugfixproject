import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/island_aerial_view.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';

/// 🪐 Poket Cosmos Island Inspector Modal & Fullscreen Living Landscape
/// Features:
/// - Exact rectangular landscape viewport as Earth Prime:
///   - Top and bottom touch the screen edges (no void, no black bars)
///   - Horizontally expansive & scrollable (panning left & right across the full island & ocean)
///   - Peak-level zooming (1.0x up to 25.0x) clamped safely at minScale = 1.0
/// - 25 equal partitioned territorial district cells with crisp cartographic boundary lines
/// - 25 plots per island:
///   - Plot #1: Occupied Pioneer Citadel
///   - Plot #2: 5-Hour pre-booked neighbor reservation with live countdown timer
///   - Plots #3 to #25: Vacant parcels with center pulsing `➕` button
/// - Cruising speedboats & yachts with white foaming wake trails on all celestial gradient oceans
/// - Top 10-planet selector chips + Prev/Next chevron buttons
class PoketCosmosIslandInspectorModal extends StatefulWidget {
  final int initialPlanetIndex;

  const PoketCosmosIslandInspectorModal({
    super.key,
    this.initialPlanetIndex = 0,
  });

  static Future<void> show(BuildContext context, {int initialPlanetIndex = 0}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PoketCosmosIslandInspectorModal(
          initialPlanetIndex: initialPlanetIndex,
        ),
      ),
    );
  }

  @override
  State<PoketCosmosIslandInspectorModal> createState() =>
      _PoketCosmosIslandInspectorModalState();
}

class _PoketCosmosIslandInspectorModalState
    extends State<PoketCosmosIslandInspectorModal>
    with SingleTickerProviderStateMixin {
  late ScrollController _chipScrollController;
  late AnimationController _waveAnimController;
  final TransformationController _transformController = TransformationController();

  int _currentIndex = 0;
  bool _transformInitialized = false;
  final List<CelestialColonyInfo> _colonies = PoketCosmosAllocationService.colonies;

  late PoketCountryMap _currentIsland;
  List<CitizenPlot> _currentPlots = [];
  Map<int, NeighborReservationPass> _currentReservations = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPlanetIndex.clamp(0, _colonies.length - 1);
    _chipScrollController = ScrollController();
    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _loadColonyData(_currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToChip(_currentIndex);
    });
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    _waveAnimController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _loadColonyData(int index) {
    final colony = _colonies[index];
    _currentIsland = PoketCountryMap(
      id: colony.planetId * 100 + 1,
      name: colony.islandName,
      tag: '${colony.planetName} Living Colony',
      landColor: colony.landColor,
      waterColor: colony.waterColor,
      totalSlots: PoketCosmosAllocationService.maxPlotsPerIsland,
      filledSlots: 5,
      climate: colony.climate,
      climateIcon: Icons.travel_explore_rounded,
      shapeSeed: 42 + index * 19,
      shapeStyle: colony.shapeStyle,
    );

    // Plot #2: Pre-booked Neighbor Reservation with active 5-hour countdown timer
    const reservationPlotNum = 2;
    final pass = NeighborReservationPass(
      code: 'PKT-W01-${colony.code}-I01-P02',
      cosmosPin: 'PKT-W01-${colony.code}-I01-P02',
      planetName: colony.planetName,
      islandId: _currentIsland.id,
      islandName: colony.islandName,
      streetName: colony.streetName,
      plotNumber: reservationPlotNum,
      hostUserName: 'Cosmic Pioneer',
      createdAt: DateTime.now().subtract(const Duration(minutes: 28)),
      expiresAt: DateTime.now().add(const Duration(hours: 4, minutes: 32)),
    );

    _currentReservations = {reservationPlotNum: pass};
    _transformInitialized = false; // Reset view centering for new planet

    // Load real database users & permanent colony pioneers
    PoketCosmosAllocationService.instance
        .getOccupiedPlotsForColony(colony)
        .then((occupiedPlots) {
      if (!mounted || _currentIndex != index) return;
      setState(() {
        _currentPlots = occupiedPlots;
        _currentIsland = _currentIsland.copyWith(
          filledSlots: occupiedPlots.length,
        );
      });
    });
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
      _loadColonyData(index);
    });
    _scrollToChip(index);
  }

  void _goToPrevPlanet() {
    if (_currentIndex > 0) {
      _onPlanetSelected(_currentIndex - 1);
    } else {
      _onPlanetSelected(_colonies.length - 1); // Wrap around
    }
  }

  void _goToNextPlanet() {
    if (_currentIndex < _colonies.length - 1) {
      _onPlanetSelected(_currentIndex + 1);
    } else {
      _onPlanetSelected(0); // Wrap around
    }
  }

  @override
  Widget build(BuildContext context) {
    final colony = _colonies[_currentIndex];

    return Scaffold(
      backgroundColor: _currentIsland.waterColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Expansive Rectangular Landscape Interactive Viewer (Top & Bottom touch screen edges)
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final screenHeight = constraints.maxHeight;
              final worldHeight = screenHeight;
              final worldWidth = math.max(screenWidth * 2.6, screenHeight * 1.8);
              const minScale = 1.0;
              const maxScale = 25.0;
              final focusX = (screenWidth - worldWidth) / 2;
              const focusY = 0.0;

              if (!_transformInitialized) {
                _transformInitialized = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _transformController.value =
                        Matrix4.translationValues(focusX, focusY, 0.0)
                          ..scaleByDouble(1.0, 1.0, 1.0, 1.0);
                  }
                });
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Full-bleed Interactive Island Canvas (boundaryMargin: EdgeInsets.zero prevents void & jumps!)
                  Positioned.fill(
                    child: InteractiveViewer(
                      transformationController: _transformController,
                      constrained: false,
                      boundaryMargin: EdgeInsets.zero, // Zero boundary margin: Locks edges cleanly, no black void!
                      minScale: minScale, // Locked to 1.0: top & bottom touch screen edges!
                      maxScale: maxScale, // Peak level zoom down to individual house & pool
                      clipBehavior: Clip.hardEdge,
                      panEnabled: true,
                      scaleEnabled: true,
                      child: SizedBox(
                        width: worldWidth,
                        height: worldHeight,
                        child: IslandAerialViewWidget(
                          island: _currentIsland,
                          isInteractive: true,
                          planetName: colony.planetName,
                          plots: _currentPlots,
                          initialReservations: _currentReservations,
                          onPlotTapped: (plot) {
                            HapticFeedback.mediumImpact();
                            PocketCitadelAttackPage.openForUser(
                              context,
                              userId: plot.userId,
                              targetName: plot.userName,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
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
            child: _buildTopHeaderAndCarousel(context, colony),
          ),

          // 5. Bottom Glassmorphic Colony Information Pill
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _buildBottomColonyCard(context, colony),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeaderAndCarousel(BuildContext context, CelestialColonyInfo colony) {
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
                          Text(
                            'PLANETARY ISLANDS',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF38BDF8), width: 0.8),
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
                      Text(
                        '${colony.planetName} • ${colony.islandName}',
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

          // Horizontal 10-Colony Chip Carousel
          SizedBox(
            height: 44,
            child: ListView.separated(
              controller: _chipScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _colonies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final col = _colonies[idx];
                final isSelected = idx == _currentIndex;

                return InkWell(
                  onTap: () => _onPlanetSelected(idx),
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? col.landColor.withValues(alpha: 0.35)
                          : const Color(0xFF1E293B).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isSelected ? col.landColor : Colors.white12,
                        width: isSelected ? 1.6 : 0.8,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: col.landColor.withValues(alpha: 0.40),
                                blurRadius: 12,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          col.planetName.split(' ').last,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          col.planetName.split(' ').first,
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            col.code,
                            style: GoogleFonts.jetBrainsMono(
                              color: isSelected ? const Color(0xFF86EFAC) : Colors.white54,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildBottomColonyCard(BuildContext context, CelestialColonyInfo colony) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colony.landColor.withValues(alpha: 0.60), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colony.landColor.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Colors.black54,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Island & Street Identity
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colony.landColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colony.landColor, width: 1.2),
                ),
                child: const Text('🏝️', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      colony.islandName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '🛣️ ${colony.streetName} • Wave #1',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981), width: 1.0),
                ),
                child: Text(
                  '25 PLOTS',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF86EFAC),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Biome & Climate Badge + Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFBBF24), size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    colony.climate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '25 Plots • Tap ➕ to Pre-Book',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF38BDF8),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
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
