import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_president_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_island_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_street_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/island_aerial_view.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_navigator_page.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_island_group_service.dart';

/// 🏝️ Fullscreen Resident Island Map for Main Profile PageView
/// Shows the citizen's actual island with:
/// - Real citizen houses on occupied plots
/// - ⏳ Animated rotating countdown timer rings on 4-hour pre-booked parcels
/// - ➕ Glowing Plus buttons on vacant parcels
/// - Edge-to-edge ocean with zero broken bottom/top
/// - Bottom "FOCUS MY HOUSE 🏡" and "COSMOS EXPLORER 🪐" floating FABs
class PoketCosmosResidentIslandView extends StatefulWidget {
  final String? userId;
  final String? userName;
  final String? userAvatar;
  final String? targetPlanetCode; // 'EP', 'MAR', 'JUP', 'SAT', 'LUN', etc.
  final int? targetPlotNumber; // Unique global plot number or local slot
  final int? targetWave; // 1, 2, ... infinite loop
  final bool isPresidential; // Dedicated Presidential Citadel Island on Earth
  final VoidCallback? onBack;

  const PoketCosmosResidentIslandView({
    super.key,
    this.userId,
    this.userName,
    this.userAvatar,
    this.targetPlanetCode,
    this.targetPlotNumber,
    this.targetWave,
    this.isPresidential = false,
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

    final bool isPres = widget.isPresidential ||
        (widget.userId != null &&
            PocketPresidentService.isPresidentId(widget.userId!)) ||
        widget.userId == 'pocket_president';

    if (isPres) {
      final colony =
          PoketCosmosAllocationService.instance.getColonyByCode('EP');
      final plot = CitizenPlot(
        plotNumber: 1,
        userId: widget.userId ?? 'pocket_president',
        userName: widget.userName ?? "Mus'ab (President)",
        userAvatar: widget.userAvatar ?? '👑',
        day: 100,
        pocketScore: 99999,
        streetName: "The King's Coastal Apex Highway",
        postOffice: 'Presidential Citadel',
        countryName: 'Presidential Citadel',
        planetName: colony.planetName,
        postalPinCode: 'PKT-W01-EP-PRES-01',
        coordinates: Offset.zero,
        isVip: true,
        isPresident: true,
        tier: PlotDeedTier.presidential,
        status: PlotStatus.occupied,
      );

      _colony = colony;
      _myPlot = plot;
      _island = const PoketCountryMap(
        id: 300,
        name: 'The Presidential Citadel 👑',
        tag: 'Crown Sovereign Sanctuary • Earth Prime 🌍',
        landColor: Color(0xFF16A34A),
        waterColor: Color(0xFF0284C7),
        totalSlots: 1,
        filledSlots: 1,
        climate: 'Sovereign Coastal Sanctuary 👑',
        climateIcon: Icons.shield_rounded,
        isPresidential: true,
        shapeStyle: IslandShapeStyle.citadelApex,
      );
      _islandPlots = [plot];
      _reservations = {};
      setState(() => _isLoading = false);
      return;
    }

    final CelestialColonyInfo colony;
    final CitizenPlot plot;
    final int wave = math.max(1, widget.targetWave ?? 1);

    // Direct planet colony & plot routing (fixes bug where all plots showed the same default island)
    if (widget.targetPlanetCode != null &&
        widget.targetPlanetCode!.isNotEmpty) {
      colony = PoketCosmosAllocationService.instance
          .getColonyByCode(widget.targetPlanetCode!);
      final int rawPlot = widget.targetPlotNumber ?? 1;
      final int gNum;
      final int lNum;
      if (rawPlot > PoketCosmosAllocationService.maxPlotsPerIsland) {
        gNum = rawPlot;
        final parsed = PoketCosmosAllocationService.parseGlobalPlotNumber(gNum);
        lNum = parsed['localPlotNumber'] as int;
      } else {
        lNum = rawPlot.clamp(1, PoketCosmosAllocationService.maxPlotsPerIsland);
        gNum = PoketCosmosAllocationService.calculateGlobalPlotNumber(
          wave: wave,
          planetCode: colony.code,
          localPlotNumber: lNum,
        );
      }
      final String effectiveIslandName = (wave == 1)
          ? colony.islandName
          : PoketCosmosAllocationService.generateInfiniteIslandName(
              colony.code, wave, wave);
      final String effectiveStreetName =
          (wave == 1) ? colony.streetName : 'Wave $wave ${colony.streetName}';

      plot = CitizenPlot(
        plotNumber: gNum,
        userId: widget.userId ?? 'plot_citizen_$gNum',
        userName: widget.userName ?? 'Citizen #$gNum',
        userAvatar: widget.userAvatar ?? '🏡',
        day: 1,
        pocketScore: 100,
        streetName: effectiveStreetName,
        postOffice: effectiveIslandName,
        countryName: effectiveIslandName,
        planetName: colony.planetName,
        postalPinCode:
            'PKT-W${wave.toString().padLeft(2, '0')}-${colony.code}-I${wave.toString().padLeft(2, '0')}-P${gNum.toString().padLeft(3, '0')}',
        coordinates: Offset.zero,
        isVip: false,
        isPresident: false,
        tier: (lNum <= 6 ? PlotDeedTier.beachfront : PlotDeedTier.standard),
        status: PlotStatus.occupied,
      );
    } else {
      // Load user-specific permanent plot
      final effectiveUid = (widget.userId != null && widget.userId!.isNotEmpty)
          ? widget.userId!
          : (SupaFlow.client.auth.currentUser?.id ?? 'guest_user');

      plot = await PoketCosmosAllocationService.instance.getUserPlot(
        userId: effectiveUid,
        fallbackName: widget.userName ?? 'Citizen',
        fallbackAvatar: widget.userAvatar ?? '🦁',
      );

      colony = PoketCosmosAllocationService.instance
          .getColonyByPlanetName(plot.planetName);
    }

    // 3. Build Island Model with subtle procedural variation per wave using Loop System
    final island = PoketCosmosAllocationService.generateProceduralIsland(
      colony: colony,
      wave: wave,
    );

    // 4. Compute plot coordinates
    final int lNum = (plot.plotNumber >
            PoketCosmosAllocationService.maxPlotsPerIsland)
        ? (PoketCosmosAllocationService.parseGlobalPlotNumber(plot.plotNumber)[
            'localPlotNumber'] as int)
        : plot.plotNumber;
    final coords = IslandAerialPainter.get35PlotCoordinates(island.shapeStyle);
    final targetPos = (lNum >= 1 && lNum <= coords.length)
        ? coords[lNum - 1]
        : Offset.zero;

    final updatedPlot = plot.copyWith(coordinates: targetPos);

    // 5. Load active 4-hour reservations for this island
    final reservationsMap = await PoketCosmosAllocationService.instance
        .getActiveReservationsMap(island.id);

    // 6. Island occupied plots (current citizen + real database neighbors & pioneers)
    final colonyOccupied = await PoketCosmosAllocationService.instance
        .getOccupiedPlotsForColony(colony, wave: wave);
    final Map<int, CitizenPlot> plotsMap = {
      for (final p in colonyOccupied) p.plotNumber: p,
    };

    // If user's plot is on this island, preserve real database details and update coordinates
    if (plotsMap.containsKey(updatedPlot.plotNumber)) {
      final existing = plotsMap[updatedPlot.plotNumber]!;
      plotsMap[updatedPlot.plotNumber] = existing.copyWith(
        coordinates: targetPos,
        userName: (widget.userName != null && widget.userName!.isNotEmpty)
            ? widget.userName
            : existing.userName,
        userAvatar: (widget.userAvatar != null && widget.userAvatar!.isNotEmpty)
            ? widget.userAvatar
            : existing.userAvatar,
      );
    } else {
      plotsMap[updatedPlot.plotNumber] = updatedPlot;
    }

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
    final targetWorldY =
        worldHeight / 2 + _myPlot.coordinates.dy * painterScale;

    final minTx = sW - (worldWidth * targetScale);
    final minTy = sH - (worldHeight * targetScale);
    final dx = (-(targetWorldX * targetScale - sW / 2)).clamp(minTx, 0.0);
    final dy = (-(targetWorldY * targetScale - sH / 2)).clamp(minTy, 0.0);

    _transformController.value = Matrix4.translationValues(dx, dy, 0.0)
      ..scaleByDouble(targetScale, targetScale, 1.0, 1.0);
  }

  String _plotFilter = 'all'; // 'all', 'occupied', 'vacant'

  String _getColonyEmoji(CelestialColonyInfo c) {
    if (c.planetName.contains('Earth')) return '🌍';
    if (c.planetName.contains('Mars')) return '🔴';
    if (c.planetName.contains('Jupiter')) return '🟠';
    if (c.planetName.contains('Saturn')) return '🪐';
    if (c.planetName.contains('Moon')) return '🌕';
    if (c.planetName.contains('Europa')) return '🧊';
    if (c.planetName.contains('Venus')) return '🟡';
    if (c.planetName.contains('Titan')) return '🪐';
    if (c.planetName.contains('Pluto')) return '❄️';
    if (c.planetName.contains('Neptune')) return '🌊';
    if (c.planetName.contains('Mercury')) return '⚪';
    if (c.planetName.contains('Ganymede')) return '🛰️';
    if (c.planetName.contains('Uranus')) return '💎';
    if (c.planetName.contains('Triton')) return '🌀';
    if (c.planetName.contains('Kepler')) return '🌌';
    return '🪐';
  }

  void _showPlanetSearchSheet() {
    HapticFeedback.mediumImpact();
    final allColonies = PoketCosmosAllocationService.colonies;
    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final filtered = allColonies.where((c) {
            if (searchQuery.trim().isEmpty) return true;
            final q = searchQuery.toLowerCase().trim();
            return c.planetName.toLowerCase().contains(q) ||
                c.islandName.toLowerCase().contains(q) ||
                c.code.toLowerCase().contains(q) ||
                c.streetName.toLowerCase().contains(q);
          }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.78,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
              boxShadow: [
                BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 24,
                    offset: Offset(0, -6)),
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
                  'Explore all 15 celestial colonies and their 25-plot island archipelagos.',
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 12),
                // 🔍 Live Search Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          color: Color(0xFF38BDF8), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white, fontSize: 13.5),
                          decoration: const InputDecoration(
                            hintText: 'Search 15 Planets, Islands, or Codes...',
                            hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (val) {
                            setModalState(() {
                              searchQuery = val;
                            });
                          },
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              searchQuery = '';
                            });
                          },
                          child: const Icon(Icons.cancel_rounded,
                              color: Colors.white54, size: 18),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No celestial colony found matching "$searchQuery"',
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final c = filtered[idx];
                            final isCurrent = c.code == _colony.code;
                            final int currentWave = _island.wave;
                            final planetIdx = allColonies.indexOf(c);
                            final startPlot = ((currentWave - 1) * 375) + (planetIdx * 25) + 1;
                            final endPlot = startPlot + 24;

                            return InkWell(
                              onTap: () {
                                Navigator.pop(ctx);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PoketCosmosNavigatorPage(
                                      initialPlanetCode: c.code,
                                      initialScreen: 1,
                                    ),
                                  ),
                                );
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
                                          _getColonyEmoji(c),
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
                                                    borderRadius:
                                                        BorderRadius.circular(6),
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
                                            '${c.islandName} • 25 Plots (Wave $currentWave: #$startPlot-#$endPlot)',
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
          );
        },
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
              title: 'All 25 Island Parcels',
              subtitle:
                  'Show all houses, pre-booked countdowns, and vacant plots',
              icon: Icons.grid_view_rounded,
            ),
            _buildFilterOption(
              ctx,
              id: 'occupied',
              title: 'Occupied Citizens Only',
              subtitle:
                  'Focus on settled community homes and architectural compounds',
              icon: Icons.home_rounded,
            ),
            _buildFilterOption(
              ctx,
              id: 'vacant',
              title: 'Available for Pre-booking',
              subtitle: 'Highlight open plots and active 4-hour reservations',
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
          color: isSel
              ? const Color(0xFF16A34A).withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel ? const Color(0xFF4ADE80) : const Color(0xFF334155),
            width: isSel ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color:
                    isSel ? const Color(0xFF4ADE80) : const Color(0xFF94A3B8),
                size: 20),
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
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isSel)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF4ADE80), size: 18),
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
                minScale: 0.55,
                maxScale: 25.0,
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
                    selectedPlotNumber: widget.targetPlotNumber ??
                        ((_colony.planetName == _myPlot.planetName)
                            ? _myPlot.plotNumber
                            : null),
                    planetName: _colony.planetName,
                    initialReservations: _reservations,
                    onPlotPurchased: () => _loadResidentIsland(),
                    onPlotTapped: (tappedPlot) {
                      HapticFeedback.mediumImpact();
                      final plotColony = PoketCosmosAllocationService.instance
                          .getColonyByPlanetName(tappedPlot.planetName);
                      final neighbor = PocketNeighbor(
                        id: tappedPlot.userId,
                        name: tappedPlot.userName,
                        day: tappedPlot.day,
                        streak: tappedPlot.day,
                        rank: 'Cosmic Citizen',
                        paletteId: 'warm_cottage',
                        isMe: false,
                        hasActiveShield: true,
                        statusMessage: tappedPlot.postalPinCode,
                        isPocketRobo: PocketRobotService.isRobotId(tappedPlot.userId),
                        hp: 100,
                        maxHp: 100,
                        planetCode: plotColony.code,
                        planetName: plotColony.planetName,
                        islandName: tappedPlot.countryName,
                        streetName: tappedPlot.streetName,
                        plotNumber: tappedPlot.plotNumber,
                        cosmosPin: tappedPlot.postalPinCode,
                      );
                      PocketCitadelAttackPage.openForUser(
                        context,
                        userId: tappedPlot.userId,
                        targetName: tappedPlot.userName,
                        targetDay: tappedPlot.day,
                        neighbor: neighbor,
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
                          _island.isPresidential
                              ? 'Earth Prime 🌍 • Sovereign Presidential Citadel 👑'
                              : '${_colony.planetName} • Plot #${widget.targetPlotNumber ?? _myPlot.plotNumber}',
                          style: GoogleFonts.jetBrainsMono(
                            color: const Color(0xFF38BDF8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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

          // 💬 Floating Island Neighbors Group Chat Capsule (Only shown on user's own island per privacy requirement)
          if (_colony.planetName == _myPlot.planetName)
            Positioned(
              bottom: bottomPad + 76,
              left: 20,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  PocketIslandGroupService.instance.openIslandGroupChat(
                    context,
                    planetCode: _colony.code,
                    planetName: _colony.planetName,
                    wave: _island.wave,
                    islandName: _island.name,
                  );
                },
                icon: const Text('💬', style: TextStyle(fontSize: 15)),
                label: Text(
                  'NEIGHBORS 💬',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: Color(0xFF38BDF8),
                      width: 1.2,
                    ),
                  ),
                  elevation: 6,
                ),
              ),
            ),

          // ⚔️ Floating Island Attack / Mock Attack Action Capsule
          Positioned(
            bottom: bottomPad + 76,
            right: 20,
            child: Builder(
              builder: (context) {
                final isHomeColony = (_colony.planetName == _myPlot.planetName);
                return ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    PocketIslandAttackPage.launch(
                      context,
                      island: _island,
                      colony: _colony,
                      plots: _islandPlots,
                      isMockAttack: isHomeColony,
                    );
                  },
                  icon: Text(isHomeColony ? '🛡️' : '⚔️',
                      style: const TextStyle(fontSize: 16)),
                  label: Text(
                    isHomeColony ? 'MOCK ATTACK 🛡️' : 'ISLAND ATTACK ⚔️',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHomeColony
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isHomeColony
                            ? const Color(0xFF34D399)
                            : const Color(0xFFF87171),
                        width: 1.2,
                      ),
                    ),
                    elevation: 6,
                  ),
                );
              },
            ),
          ),

          // 🎯 Bottom Floating Actions: "FOCUS TO MY PLOT 🏡" & "COSMOS EXPLORER 🪐"
          Positioned(
            bottom: bottomPad + 18,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // Only show "FOCUS TO MY PLOT" if the user is currently on their home island!
                // Per user directive: "ഫോക്കസ് ടു മൈ പ്ലോട്ട് എന്നുള്ളത് എന്റെ ഐലൻഡിൽ എന്റെ പ്ലോട്ടിൽ മാത്രം ഫോക്കസ് ടു പ്ലോട്ട് ഉള്ളൂ. അല്ലാതെ ആ ബട്ടൺ കാണിക്കേണ്ട ആവശ്യമില്ല."
                if (_colony.planetName == _myPlot.planetName) ...[
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _centerOnUserPlot(MediaQuery.of(context).size);
                      },
                      icon: const Text('🏡', style: TextStyle(fontSize: 16)),
                      label: Text(
                        'FOCUS TO MY PLOT (#${_myPlot.plotNumber})',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: Color(0xFF4ADE80),
                            width: 1.2,
                          ),
                        ),
                        elevation: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
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
