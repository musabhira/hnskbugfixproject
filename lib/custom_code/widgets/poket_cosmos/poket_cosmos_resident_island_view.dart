import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/island_aerial_view.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_navigator_page.dart';

/// 🏝️ Fullscreen Resident Island Map for Main Profile PageView
/// Shows the citizen's actual island with:
/// - Real citizen houses on occupied plots
/// - ⏳ Animated rotating countdown timer rings on 5-hour pre-booked parcels
/// - ➕ Glowing Plus buttons on vacant parcels
/// - Edge-to-edge ocean with zero broken bottom/top
/// - Bottom "FOCUS MY HOUSE 🏡" and "COSMOS EXPLORER 🪐" floating FABs
class PoketCosmosResidentIslandView extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userAvatar;
  final VoidCallback? onBack;

  const PoketCosmosResidentIslandView({
    super.key,
    this.userId,
    this.userName,
    this.userAvatar,
    this.onBack,
  });

  @override
  State<PoketCosmosResidentIslandView> createState() =>
      _PoketCosmosResidentIslandViewState();
}

class _PoketCosmosResidentIslandViewState
    extends State<PoketCosmosResidentIslandView>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();
  bool _isLoading = true;
  bool _transformInitialized = false;

  late CitizenPlot _myPlot;
  late PoketCountryMap _island;
  late CelestialColonyInfo _colony;
  List<CitizenPlot> _islandPlots = [];
  Map<int, NeighborReservationPass> _reservations = {};

  @override
  void initState() {
    super.initState();
    _loadResidentIsland();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _loadResidentIsland() async {
    setState(() => _isLoading = true);

    // 1. Load or allocate user birthplace
    final plot =
        await PoketCosmosAllocationService.instance.allocateUserBirthplace(
      userName: widget.userName ?? 'Citizen',
      avatar: widget.userAvatar ?? '🦁',
    );

    // 2. Identify celestial colony
    final colony = PoketCosmosAllocationService.instance
        .getColonyByPlanetName(plot.planetName);

    // 3. Build Island Model
    final island = PoketCountryMap(
      id: colony.planetId * 100 + 1,
      name: plot.countryName,
      tag: '${colony.planetName} Living Colony',
      landColor: colony.landColor,
      waterColor: colony.waterColor,
      totalSlots: PoketCosmosAllocationService.maxPlotsPerIsland,
      filledSlots: 1,
      climate: colony.climate,
      climateIcon: Icons.water_drop_rounded,
      shapeSeed: plot.plotNumber * 13,
      shapeStyle: colony.shapeStyle,
    );

    // 4. Compute plot coordinates
    final coords = IslandAerialPainter.get35PlotCoordinates(island.shapeStyle);
    final targetPos = (plot.plotNumber >= 1 && plot.plotNumber <= coords.length)
        ? coords[plot.plotNumber - 1]
        : Offset.zero;

    final updatedPlot = plot.copyWith(coordinates: targetPos);

    // 5. Load active 5-hour reservations for this island
    final reservationsMap = await PoketCosmosAllocationService.instance
        .getActiveReservationsMap(island.id);

    // 6. Island occupied plots (current citizen + real database neighbors & pioneers)
    final colonyOccupied = await PoketCosmosAllocationService.instance
        .getOccupiedPlotsForColony(colony);
    final Map<int, CitizenPlot> plotsMap = {
      for (final p in colonyOccupied) p.plotNumber: p,
    };
    plotsMap[updatedPlot.plotNumber] = updatedPlot;

    final plotsList = plotsMap.values.toList()
      ..sort((a, b) => a.plotNumber.compareTo(b.plotNumber));

    final updatedIsland = island.copyWith(filledSlots: plotsList.length);

    if (mounted) {
      setState(() {
        _myPlot = updatedPlot;
        _island = updatedIsland;
        _colony = colony;
        _islandPlots = plotsList;
        _reservations = reservationsMap;
        _isLoading = false;
        _transformInitialized = false;
      });
    }
  }

  void _centerOnUserPlot(Size screenSize) {
    final sW = screenSize.width;
    final sH = screenSize.height;
    final worldHeight = sH;
    final worldWidth = math.max(sW * 2.6, sH * 1.8);
    const targetScale = 2.4;

    final painterScale = ((worldHeight / 850.0) * 1.15).clamp(0.95, 1.50);
    final targetWorldX = worldWidth / 2 + _myPlot.coordinates.dx * painterScale;
    final targetWorldY = worldHeight / 2 + _myPlot.coordinates.dy * painterScale;

    final minTx = sW - (worldWidth * targetScale);
    final minTy = sH - (worldHeight * targetScale);
    final dx = (-(targetWorldX * targetScale - sW / 2)).clamp(minTx, 0.0);
    final dy = (-(targetWorldY * targetScale - sH / 2)).clamp(minTy, 0.0);

    _transformController.value = Matrix4.translationValues(dx, dy, 0.0)
      ..scaleByDouble(targetScale, targetScale, 1.0, 1.0);
  }

  String _plotFilter = 'all'; // 'all', 'occupied', 'vacant'

  Future<void> _switchToColony(CelestialColonyInfo newColony) async {
    setState(() => _isLoading = true);

    final island = PoketCountryMap(
      id: newColony.planetId * 100 + 1,
      name: newColony.islandName,
      tag: '${newColony.planetName} Living Colony',
      landColor: newColony.landColor,
      waterColor: newColony.waterColor,
      totalSlots: PoketCosmosAllocationService.maxPlotsPerIsland,
      filledSlots: 1,
      climate: newColony.climate,
      climateIcon: Icons.water_drop_rounded,
      shapeSeed: newColony.planetId * 17,
      shapeStyle: newColony.shapeStyle,
    );

    final reservationsMap = await PoketCosmosAllocationService.instance
        .getActiveReservationsMap(island.id);
    final colonyOccupied = await PoketCosmosAllocationService.instance
        .getOccupiedPlotsForColony(newColony);

    if (mounted) {
      setState(() {
        _island = island.copyWith(filledSlots: colonyOccupied.length);
        _colony = newColony;
        _islandPlots = colonyOccupied;
        _reservations = reservationsMap;
        _isLoading = false;
        _transformInitialized = false;
      });
    }
  }

  void _showPlanetSearchSheet() {
    HapticFeedback.mediumImpact();
    final allColonies = PoketCosmosAllocationService.colonies;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.72,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
          boxShadow: [
            BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, -6)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF475569),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Row(
              children: [
                const Text('🪐', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text(
                  'COSMOS ISLAND EXPLORER',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Select any of the 10 celestial colonies to inspect its 20-plot island, landscape, and registered community members.',
              style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 12),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: allColonies.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final c = allColonies[idx];
                  final isCurrent = c.code == _colony.code;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _switchToColony(c);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF0284C7).withValues(alpha: 0.22)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF334155),
                          width: isCurrent ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [c.waterColor, c.landColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                c.planetName.contains('Earth')
                                    ? '🌍'
                                    : c.planetName.contains('Mars')
                                        ? '🔴'
                                        : c.planetName.contains('Moon')
                                            ? '🌕'
                                            : c.planetName.contains('Jupiter')
                                                ? '🟠'
                                                : c.planetName.contains('Saturn')
                                                    ? '🪐'
                                                    : c.planetName.contains('Europa')
                                                        ? '🧊'
                                                        : c.planetName.contains('Venus')
                                                            ? '✨'
                                                            : c.planetName.contains('Titan')
                                                                ? '🟢'
                                                                : c.planetName.contains('Neptune')
                                                                    ? '🔵'
                                                                    : '🟣',
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      c.planetName,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF16A34A),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'YOUR RESIDENCE',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${c.islandName} • 20 Parcels',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Color(0xFF38BDF8), size: 14),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Color(0xFF4ADE80), width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'PARCEL DISPLAY FILTER',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 14),
            _buildFilterOption(
              ctx,
              id: 'all',
              title: 'All 20 Island Parcels',
              subtitle: 'Show all houses, pre-booked countdowns, and vacant plots',
              icon: Icons.grid_view_rounded,
            ),
            _buildFilterOption(
              ctx,
              id: 'occupied',
              title: 'Occupied Citizens Only',
              subtitle: 'Focus on settled community homes and architectural compounds',
              icon: Icons.home_rounded,
            ),
            _buildFilterOption(
              ctx,
              id: 'vacant',
              title: 'Available for Pre-booking',
              subtitle: 'Highlight open plots and active 5-hour reservations',
              icon: Icons.add_circle_outline_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext ctx, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSel = _plotFilter == id;
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        setState(() => _plotFilter = id);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF16A34A).withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel ? const Color(0xFF4ADE80) : const Color(0xFF334155),
            width: isSel ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSel ? const Color(0xFF4ADE80) : const Color(0xFF94A3B8), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: isSel ? Colors.white : const Color(0xFFE2E8F0),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isSel)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: const Color(0xFF030712),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0284C7),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🏝️ Fullscreen Edge-to-Edge Island Map with Clamped Ocean Bounds
          LayoutBuilder(
            builder: (context, constraints) {
              final sW = constraints.maxWidth;
              final sH = constraints.maxHeight;
              final worldHeight = sH;
              final worldWidth = math.max(sW * 2.6, sH * 1.8);

              if (!_transformInitialized) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_transformInitialized) {
                    _centerOnUserPlot(Size(sW, sH));
                    _transformInitialized = true;
                  }
                });
              }

              return InteractiveViewer(
                transformationController: _transformController,
                minScale: 1.0,
                maxScale: 6.5,
                boundaryMargin: EdgeInsets.zero,
                constrained: false,
                child: SizedBox(
                  width: worldWidth,
                  height: worldHeight,
                  child: IslandAerialViewWidget(
                    island: _island,
                    isInteractive: true,
                    zoomScale: 2.4,
                    plots: _islandPlots,
                    selectedPlotNumber: _myPlot.plotNumber,
                    planetName: _colony.planetName,
                    initialReservations: _reservations,
                    onPlotTapped: (tappedPlot) {
                      HapticFeedback.mediumImpact();
                      PocketCitadelAttackPage.openForUser(
                        context,
                        userId: tappedPlot.userId,
                        targetName: tappedPlot.userName,
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // 🌟 Top Floating Header Capsule (Island Name, Planet & Born PIN)
          Positioned(
            top: topPad + 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.45),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 🔙 iOS-Style Sleek Back Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🏝️', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _island.name,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_colony.planetName} • ${_myPlot.postalPinCode}',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFF38BDF8),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 📋 Copy PIN Button
                  IconButton(
                    icon: const Icon(Icons.copy_rounded,
                        color: Color(0xFF38BDF8), size: 18),
                    tooltip: 'Copy Born Address PIN',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: _myPlot.postalPinCode));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Born Address PIN ${_myPlot.postalPinCode} copied!'),
                          backgroundColor: const Color(0xFF16A34A),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  // 🔍 Planet / Cosmos Island Search & Switch Button
                  IconButton(
                    icon: const Icon(Icons.travel_explore_rounded,
                        color: Color(0xFFFACC15), size: 20),
                    tooltip: 'Search & Switch Cosmic Islands',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: _showPlanetSearchSheet,
                  ),
                  const SizedBox(width: 4),
                  // ⚙️ Parcel Filter Button
                  IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      color: _plotFilter == 'all'
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF4ADE80),
                      size: 20,
                    ),
                    tooltip: 'Filter Parcels',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: _showFilterSheet,
                  ),
                ],
              ),
            ),
          ),

          // 🎯 Bottom Floating Actions: "FOCUS MY HOUSE 🏡" & "COSMOS EXPLORER 🪐"
          Positioned(
            bottom: bottomPad + 18,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _centerOnUserPlot(MediaQuery.of(context).size);
                    },
                    icon: const Text('🏡', style: TextStyle(fontSize: 16)),
                    label: Text(
                      'FOCUS MY PLOT (#${_myPlot.plotNumber})',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                            color: Color(0xFF4ADE80), width: 1.2),
                      ),
                      elevation: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PoketCosmosNavigatorPage(),
                        ),
                      );
                    },
                    icon: const Text('🪐', style: TextStyle(fontSize: 16)),
                    label: Text(
                      'EXPLORE',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: const Color(0xFF38BDF8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                            color: Color(0xFF38BDF8), width: 1.2),
                      ),
                      elevation: 6,
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
}

