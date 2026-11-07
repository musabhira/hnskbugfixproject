import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/island_aerial_view.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';

/// 🪐 Poket Cosmos Island Inspector Modal & Fullscreen Carousel
/// Allows the user/tester to test and inspect all 10 Celestial Colonies:
/// - Earth Prime 🌍 (Tropical Emerald Atoll)
/// - Mars 🔴 (Iron Rust Red Rock & Crimson Abyss)
/// - Jupiter 🪐 (Swirling Jovian Amber/Bronze & Cosmic Azure Storm)
/// - Saturn 🪐 (Golden Sandstone & Methane Ring Ocean)
/// - The Moon 🌕 (Silver Regolith Basalt & Starlight Void)
/// - Europa 🧊 (Glacial Polar Ice & Cryogenic Subsurface Ocean)
/// - Venus ☀️ (Sulfuric Volcanic Ochre & Golden Acid Smog)
/// - Titan 🪐 (Emerald Hydrocarbon Dunes & Kraken Mare)
/// - Pluto 🌌 (Cryogenic Nitrogen Glaciers & Lavender/Violet Cosmic Void)
/// - Neptune 🌊 (Supersonic Cobalt Tempest & Deep Oceanic Trench)
///
/// Each island features:
/// - Edge-to-edge gradient oceans with zero broken bottom/top bounds
/// - Real interactive 18 citizen plots with vacant `+` and pre-booked states
/// - Tap handlers for neighbor reservations, deed inspections, and citadel visits
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
    extends State<PoketCosmosIslandInspectorModal> {
  late PageController _pageController;
  late ScrollController _chipScrollController;
  int _currentIndex = 0;
  final List<CelestialColonyInfo> _colonies = PoketCosmosAllocationService.colonies;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPlanetIndex.clamp(0, _colonies.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    _chipScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToChip(_currentIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _chipScrollController.dispose();
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
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
    _scrollToChip(index);
  }

  @override
  Widget build(BuildContext context) {
    final colony = _colonies[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        children: [
          // 1. Horizontal PageView of All 10 Celestial Islands
          PageView.builder(
            controller: _pageController,
            itemCount: _colonies.length,
            onPageChanged: (index) {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = index);
              _scrollToChip(index);
            },
            itemBuilder: (context, index) {
              return _CelestialIslandPageViewItem(
                colony: _colonies[index],
                colonyIndex: index,
              );
            },
          ),

          // 2. Top Header & Planet Carousel Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopHeaderAndCarousel(context, colony),
          ),

          // 3. Bottom Glassmorphic Colony Information Pill
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
                  '18 PLOTS',
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

          // Row 2: Biome & Climate Badge
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
                  'Tap ➕ to Pre-Book',
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

/// 🏝️ Single Island Interactive PageView Item
class _CelestialIslandPageViewItem extends StatefulWidget {
  final CelestialColonyInfo colony;
  final int colonyIndex;

  const _CelestialIslandPageViewItem({
    required this.colony,
    required this.colonyIndex,
  });

  @override
  State<_CelestialIslandPageViewItem> createState() =>
      _CelestialIslandPageViewItemState();
}

class _CelestialIslandPageViewItemState extends State<_CelestialIslandPageViewItem> {
  final TransformationController _transformController = TransformationController();
  late PoketCountryMap _island;
  List<CitizenPlot> _plots = [];
  Map<int, NeighborReservationPass> _reservations = {};

  @override
  void initState() {
    super.initState();
    _initIslandData();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _initIslandData() {
    final colony = widget.colony;
    _island = PoketCountryMap(
      id: colony.planetId * 100 + 1,
      name: colony.islandName,
      tag: '${colony.planetName} Living Colony',
      landColor: colony.landColor,
      waterColor: colony.waterColor,
      totalSlots: PoketCosmosAllocationService.maxPlotsPerIsland,
      filledSlots: 1,
      climate: colony.climate,
      climateIcon: Icons.travel_explore_rounded,
      shapeSeed: 42 + widget.colonyIndex * 19,
      shapeStyle: colony.shapeStyle,
    );

    // Get 35 coordinates
    final coords = IslandAerialPainter.get35PlotCoordinates(_island.shapeStyle);

    // Plot #1: Presidential / Citizen Citadel with "Explorer" (occupied)
    final plot1 = CitizenPlot(
      plotNumber: 1,
      userId: 'inspector_host_${colony.code}',
      userName: 'Cosmic Pioneer',
      userAvatar: '👑',
      day: 75,
      pocketScore: 920,
      streetName: colony.streetName,
      postOffice: colony.islandName,
      countryName: colony.islandName,
      planetName: colony.planetName,
      coordinates: coords.isNotEmpty ? coords[0] : Offset.zero,
      postalPinCode: 'PKT-W01-${colony.code}-I01-P01',
      tier: PlotDeedTier.presidential,
      status: PlotStatus.occupied,
    );

    _plots = [plot1];

    // Plot #2: Pre-booked Neighbor Reservation with active 5-hour countdown timer
    final reservationPlotNum = 2;
    final pass = NeighborReservationPass(
      code: 'PKT-W01-${colony.code}-I01-P02',
      cosmosPin: 'PKT-W01-${colony.code}-I01-P02',
      planetName: colony.planetName,
      islandId: _island.id,
      islandName: colony.islandName,
      streetName: colony.streetName,
      plotNumber: reservationPlotNum,
      hostUserName: 'Cosmic Pioneer',
      createdAt: DateTime.now().subtract(const Duration(minutes: 28)),
      expiresAt: DateTime.now().add(const Duration(hours: 4, minutes: 32)),
    );

    _reservations = {reservationPlotNum: pass};
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          children: [
            // Interactive Aerial Island View with locked zero-letterbox bounds
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 1.0,
                maxScale: 3.5,
                clipBehavior: Clip.none,
                panEnabled: true,
                scaleEnabled: true,
                child: SizedBox(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: IslandAerialViewWidget(
                    island: _island,
                    isInteractive: true,
                    plots: _plots,
                    initialReservations: _reservations,
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
    );
  }
}

