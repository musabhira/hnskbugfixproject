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

  const PoketCosmosResidentIslandView({
    super.key,
    this.userId,
    this.userName,
    this.userAvatar,
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

    // 6. Island occupied plots (current citizen + any neighbors)
    final List<CitizenPlot> plotsList = [updatedPlot];

    if (mounted) {
      setState(() {
        _myPlot = updatedPlot;
        _island = island;
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
                  IconButton(
                    icon: const Icon(Icons.copy_rounded,
                        color: Color(0xFF38BDF8), size: 18),
                    tooltip: 'Copy Born Address PIN',
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
