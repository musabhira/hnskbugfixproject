import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_allocation_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'poket_cosmos_models.dart';

/// 🏝️ Aerial Top-Down Island View Widget with:
/// - 10 Distinct Scalable Architectural Island Shapes (Crescent, S-Curve, Star, Dual-Islet,
///   Ring Atoll, Hook, Heart, Clover, Fortress, and President's Grand Golden Citadel).
/// - Ample Green Spacing & Buffer (Houses NEVER touch the ocean or beach reef).
/// - Level of Detail (LOD): Subtle minimal glowing dots when viewed from a distance,
///   expanding into crisp 90-day habit houses with pools, terracotta tiles, and gardens on deep zoom.
/// - Fixed Infinite Ocean Integration (Never breaks into a square box).
class IslandAerialViewWidget extends StatefulWidget {
  final PoketCountryMap island;
  final bool isInteractive;
  final double zoomScale;
  final List<CitizenPlot> plots;
  final ValueChanged<CitizenPlot>? onPlotTapped;
  final int? selectedPlotNumber;
  final String? planetName;
  final Map<int, NeighborReservationPass>? initialReservations;

  const IslandAerialViewWidget({
    super.key,
    required this.island,
    this.isInteractive = false,
    this.zoomScale = 1.0,
    this.plots = const [],
    this.onPlotTapped,
    this.selectedPlotNumber,
    this.planetName,
    this.initialReservations,
  });

  @override
  State<IslandAerialViewWidget> createState() => _IslandAerialViewWidgetState();
}

class _IslandAerialViewWidgetState extends State<IslandAerialViewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Map<int, NeighborReservationPass> _activeReservations = {};

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    if (widget.initialReservations != null) {
      _activeReservations = Map.from(widget.initialReservations!);
    }
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final map = await PoketCosmosAllocationService.instance
        .getActiveReservationsMap(widget.island.id);
    if (mounted) {
      setState(() {
        _activeReservations = map;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: widget.isInteractive ? (details) => _handleTap(details, size) : null,
          child: CustomPaint(
            size: size,
            painter: IslandAerialPainter(
              island: widget.island,
              isInteractive: widget.isInteractive,
              zoomScale: widget.zoomScale,
              plots: widget.plots,
              reservations: _activeReservations,
              selectedPlotNumber: widget.selectedPlotNumber,
              animation: _animController,
            ),
          ),
        );
      },
    );
  }

  void _handleTap(TapUpDetails details, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = widget.isInteractive
        ? ((size.height / 850.0) * 1.15).clamp(0.95, 1.50)
        : (math.min(size.width, size.height) / 540.0);

    final islandX = (details.localPosition.dx - cx) / scale;
    final islandY = (details.localPosition.dy - cy) / scale;
    final tapPoint = Offset(islandX, islandY);

    // 1. Check if occupied citizen plot tapped
    CitizenPlot? hitPlot;
    double minDistance = 30.0 * scale;

    for (final plot in widget.plots) {
      final d = (plot.coordinates - tapPoint).distance;
      if (d < minDistance) {
        minDistance = d;
        hitPlot = plot;
      }
    }

    if (hitPlot != null) {
      if (widget.onPlotTapped != null) {
        widget.onPlotTapped!(hitPlot);
      } else {
        HapticFeedback.mediumImpact();
        PocketCitadelAttackPage.openForUser(
          context,
          userId: hitPlot.userId,
          targetName: hitPlot.userName,
        );
      }
      return;
    }

    // 2. Check if a pre-booked or vacant parcel was tapped (1..18 plots)
    final allCoords = IslandAerialPainter.get35PlotCoordinates(widget.island.shapeStyle);
    final maxPlots = math.min(PoketCosmosAllocationService.maxPlotsPerIsland, allCoords.length);

    for (int i = 0; i < maxPlots; i++) {
      final plotNum = i + 1;
      final isOccupied = widget.plots.any((p) => p.plotNumber == plotNum);
      if (isOccupied) continue;

      final d = (allCoords[i] - tapPoint).distance;
      if (d < 30.0) {
        if (_activeReservations.containsKey(plotNum)) {
          // Pre-booked parcel tapped
          _showPreBookedStatusSheet(context, _activeReservations[plotNum]!);
        } else {
          // Vacant parcel tapped with [+] sign
          _showNeighborInviteSheet(context, plotNum);
        }
        return;
      }
    }
  }

  void _showPreBookedStatusSheet(BuildContext context, NeighborReservationPass pass) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 1.8)),
          boxShadow: [
            BoxShadow(color: Color(0x66F59E0B), blurRadius: 24, offset: Offset(0, -6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB45309).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                  ),
                  child: const Text('⏳', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plot #${pass.plotNumber} is Pre-Booked!',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Reserved for a friend',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFF38BDF8), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Time Remaining: ${pass.minutesRemaining} minutes (${pass.minutesRemaining ~/ 60}h ${pass.minutesRemaining % 60}m)',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.key_rounded, color: Color(0xFF38BDF8), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Born PIN: ${pass.cosmosPin}',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFFBAE6FD),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await Share.share(pass.shareMessage);
                      } catch (_) {
                        Clipboard.setData(ClipboardData(text: pass.shareMessage));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.share_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text('Share WhatsApp', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await PoketCosmosAllocationService.instance.cancelReservation(pass.code);
                      await _loadReservations();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF87171),
                      side: const BorderSide(color: Color(0xFFF87171)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text('Cancel Lock', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNeighborInviteSheet(BuildContext context, int plotNumber) {
    HapticFeedback.mediumImpact();
    final colony = PoketCosmosAllocationService.instance.getColonyByPlanetName(widget.planetName ?? widget.island.name);
    const currentWave = 1;
    final waveStr = currentWave.toString().padLeft(2, '0');
    final plotStr = plotNumber.toString().padLeft(2, '0');
    final generatedPin = 'PKT-W$waveStr-${colony.code}-I$waveStr-P$plotStr';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Color(0xFF10B981), width: 1.8)),
          boxShadow: [
            BoxShadow(color: Color(0x6610B981), blurRadius: 24, offset: Offset(0, -6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF10B981), width: 1.2),
                  ),
                  child: const Text('➕', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pre-Book Neighbor Plot #$plotNumber',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.island.name} • ${colony.planetName}',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF34D399),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Lock this plot for 5 hours exclusively for your friend. No other user can claim it during this time!',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Text('🔑', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text('Born PIN: ', style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 12)),
                  Expanded(
                    child: Text(
                      generatedPin,
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF86EFAC),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final pass = await PoketCosmosAllocationService.instance.createNeighborInvitePass(
                  islandId: widget.island.id,
                  islandName: widget.island.name,
                  planetName: colony.planetName,
                  streetName: colony.streetName,
                  plotNumber: plotNumber,
                  hostUserName: 'Neighbor',
                );

                await _loadReservations();

                try {
                  await Share.share(pass.shareMessage);
                } catch (_) {
                  Clipboard.setData(ClipboardData(text: pass.shareMessage));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reservation PIN ${pass.code} copied to clipboard!'),
                        backgroundColor: const Color(0xFF16A34A),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_clock_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'PRE-BOOK FOR 5 HOURS & INVITE',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 🏝️ 5 ROCK-SOLID NATURAL ISLAND ARCHETYPES (Spacious, Organic & 100% Solid)
// Zero thin necks, zero houses falling into the ocean!
// =============================================================================
enum IslandArchetype {
  naturalOval,    // 1. Broad Continental Oval with natural coastal coves
  capePeninsula,  // 2. Wide Northern Mainland tapering to expansive Southern Cape
  horseshoeBay,   // 3. Thick U-shaped Horseshoe Island around calm turquoise bay
  twinSanctuary,  // 4. Two broad circular highlands joined by massive central bridge
  citadelPlateau, // 5. Royal Hexagonal Bastion Citadel
}

IslandArchetype getIslandArchetype(IslandShapeStyle style) {
  switch (style) {
    case IslandShapeStyle.ringAtoll:
    case IslandShapeStyle.cloverBays:
      return IslandArchetype.naturalOval;
    case IslandShapeStyle.hookPeninsula:
    case IslandShapeStyle.heartSanctuary:
      return IslandArchetype.capePeninsula;
    case IslandShapeStyle.crescentLagoon:
    case IslandShapeStyle.starAtoll:
      return IslandArchetype.horseshoeBay;
    case IslandShapeStyle.dualIsletBridge:
    case IslandShapeStyle.sCurveArchipelago:
      return IslandArchetype.twinSanctuary;
    case IslandShapeStyle.fortressPlateau:
    case IslandShapeStyle.citadelApex:
      return IslandArchetype.citadelPlateau;
  }
}

// =============================================================================
// 🪐 10 CELESTIAL COLONY TYPES & AUTHENTIC BIOME MAPPING
// =============================================================================
enum CelestialColonyType {
  earth,
  mars,
  jupiter,
  saturn,
  moon,
  europa,
  venus,
  titan,
  pluto,
  neptune,
}

/// 🎨 Island Aerial CustomPainter with Expansive Green Terrains & Safe In-Land Habit Plots
class IslandAerialPainter extends CustomPainter {
  final PoketCountryMap island;
  final bool isInteractive;
  final double zoomScale;
  final List<CitizenPlot> plots;
  final Map<int, NeighborReservationPass> reservations;
  final int? selectedPlotNumber;
  final Animation<double>? animation;

  IslandAerialPainter({
    required this.island,
    this.isInteractive = false,
    this.zoomScale = 1.0,
    this.plots = const [],
    this.reservations = const {},
    this.selectedPlotNumber,
    this.animation,
  }) : super(repaint: animation);

  double get animProgress => animation?.value ?? 0.0;
  double get timeSeconds => animProgress * 40.0;

  CelestialColonyType get colonyType {
    final text = '${island.name} ${island.tag} ${island.climate}'.toLowerCase();
    if (text.contains('mars') ||
        text.contains('ares') ||
        text.contains('olympus') ||
        text.contains('rusty') ||
        island.shapeStyle == IslandShapeStyle.fortressPlateau) {
      return CelestialColonyType.mars;
    }
    if (text.contains('jupiter') ||
        text.contains('solaria') ||
        text.contains('red spot') ||
        island.shapeStyle == IslandShapeStyle.crescentLagoon) {
      return CelestialColonyType.jupiter;
    }
    if (text.contains('saturn') ||
        text.contains('ringside') ||
        text.contains('ring sanctuary') ||
        island.shapeStyle == IslandShapeStyle.sCurveArchipelago) {
      return CelestialColonyType.saturn;
    }
    if (text.contains('moon') ||
        text.contains('lunar') ||
        text.contains('mare tranqu') ||
        island.shapeStyle == IslandShapeStyle.hookPeninsula) {
      return CelestialColonyType.moon;
    }
    if (text.contains('europa') ||
        text.contains('glacier rift') ||
        text.contains('ice ocean') ||
        island.shapeStyle == IslandShapeStyle.dualIsletBridge) {
      return CelestialColonyType.europa;
    }
    if (text.contains('venus') ||
        text.contains('aphrodite') ||
        text.contains('sulfur') ||
        island.shapeStyle == IslandShapeStyle.starAtoll) {
      return CelestialColonyType.venus;
    }
    if (text.contains('titan') ||
        text.contains('kraken mare') ||
        text.contains('hydrocarbon') ||
        island.shapeStyle == IslandShapeStyle.heartSanctuary) {
      return CelestialColonyType.titan;
    }
    if (text.contains('pluto') ||
        text.contains('tombaugh') ||
        text.contains('cryo') ||
        text.contains('frost') ||
        island.shapeStyle == IslandShapeStyle.cloverBays) {
      return CelestialColonyType.pluto;
    }
    if (text.contains('neptune') ||
        text.contains('triton') ||
        text.contains('tempest') ||
        island.shapeStyle == IslandShapeStyle.citadelApex) {
      return CelestialColonyType.neptune;
    }
    return CelestialColonyType.earth;
  }

  bool get isMoon => colonyType == CelestialColonyType.moon;
  bool get isMars => colonyType == CelestialColonyType.mars;
  bool get isJupiter => colonyType == CelestialColonyType.jupiter;
  bool get isSaturn => colonyType == CelestialColonyType.saturn;
  bool get isEuropa => colonyType == CelestialColonyType.europa;
  bool get isVenus => colonyType == CelestialColonyType.venus;
  bool get isTitan => colonyType == CelestialColonyType.titan;
  bool get isPluto => colonyType == CelestialColonyType.pluto;
  bool get isNeptune => colonyType == CelestialColonyType.neptune;
  bool get isEarth => colonyType == CelestialColonyType.earth;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Vast Unified Living Ocean across the entire world space
    _drawUnifiedWorldOcean(canvas, size);

    final cx = size.width / 2;
    final cy = size.height / 2;
    // Responsive island scale: proportional to screen height in fullscreen mode, scaled to fit in carousel cards
    final double scale = isInteractive
        ? ((size.height / 850.0) * 1.15).clamp(0.95, 1.50)
        : (math.min(size.width, size.height) / 540.0);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    // 2. Satellite Small Islets (for organic archipelago beauty)
    if (!island.isPresidential) {
      _drawSatelliteIslets(canvas);
    }

    // 3. Shallow Cyan Reef Contour & Foamy Surf (Translucent turquoise water hugging the shore)
    _drawShallowCoralReef(canvas);

    // 4. Sandy Golden Shoreline Beach with Wet Sand Margin
    _drawSandyBeach(canvas);

    // 5. Expansive Authentic Planetary Island Terrain (Generous landmass & authentic planetary ground)
    _drawIslandTerrainBody(canvas);

    // 5b. 35 Territorial Districts (State/District Map Partition with Border Lines!)
    // Like US / Indian states on a map, entire island is partitioned into 35 contiguous districts!
    if (!island.isPresidential) {
      _draw35TerritorialDistricts(canvas);
    }

    // 6. Central Lagoon / Resort Swimming Lake
    _drawInteriorWaterBody(canvas);

    // 7. Winding Paved Trails & Roadways Connecting the Island
    _drawRoadways(canvas);

    // 8. Mini Sports Pitch (Football Turf Lawn with White Markings on Earth & Titan)
    if (!island.isPresidential && (isEarth || isTitan)) {
      _drawSportsTurfPitch(canvas);
    }

    // 9. Marine Piers & Cruising Boats across all celestial oceans
    _drawWoodenPierAndBoats(canvas);
    _drawCruisingBoatsWithWakes(canvas);

    // 10. Living Wildlife & Grazing Animals (Peaceful sheep & horses on Earth)
    if (isEarth) {
      _drawGrazingAnimals(canvas);
    }

    // 11. Habit Houses / Plots (Strictly inside the island terrain with safe buffer)
    if (island.isPresidential) {
      _drawPresidentialCitadel(canvas);
    } else {
      _drawCitizenPlots(canvas);
    }

    // 12. Flora / Bio-Domes / Atmospheric Telescopes
    _drawPalmTreeCanopies(canvas);

    // 13. Beach Umbrellas & Sunbed Loungers along the Sand
    if (isEarth || isTitan) {
      _drawBeachUmbrellas(canvas);
    }

    // 14. High-Altitude Atmospheric Drifting Clouds & Soft Shadows
    _drawAtmosphericClouds(canvas);

    // 15. Soaring Seagulls gliding over the azure ocean (Earth only)
    if (isEarth) {
      _drawSoaringSeagulls(canvas);
    }

    canvas.restore();
  }

  // =========================================================================
  // 🌊 UNIFIED LIVING WORLD OCEAN (Edge-to-edge multi-stop gradient celestial ocean)
  // =========================================================================
  void _drawUnifiedWorldOcean(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    List<Color> oceanColors;
    bool hasStars = false;
    bool hasJovianStormSea = false;

    switch (colonyType) {
      case CelestialColonyType.earth:
        oceanColors = const [
          Color(0xFF0284C7), // Vibrant tropical azure
          Color(0xFF0369A1), // Deep maritime blue
          Color(0xFF075985), // Deep ocean blue
          Color(0xFF0C4A6E), // Trench navy
          Color(0xFF020617), // Abyssal black
        ];
        break;
      case CelestialColonyType.mars:
        oceanColors = const [
          Color(0xFFB91C1C), // Molten iron crimson
          Color(0xFF991B1B), // Dark volcanic red
          Color(0xFF7F1D1D), // Deep Ares mahogany
          Color(0xFF450A0A), // Iron oxide abyss
          Color(0xFF180303), // Carbon void
        ];
        break;
      case CelestialColonyType.jupiter:
        hasJovianStormSea = true;
        oceanColors = const [
          Color(0xFF0284C7), // Electric cosmic azure storm
          Color(0xFF1E3A8A), // Deep cobalt vortex
          Color(0xFF78350F), // Jovian amber abyss
          Color(0xFF451A03), // Deep bronze shadow
          Color(0xFF0B0F19), // Space black
        ];
        break;
      case CelestialColonyType.saturn:
        oceanColors = const [
          Color(0xFFD97706), // Luminous amber liquid methane
          Color(0xFFB45309), // Warm bronze sea
          Color(0xFF78350F), // Deep golden ring abyss
          Color(0xFF451A03), // Dark hydrocarbon trench
          Color(0xFF0A0704), // Space black
        ];
        break;
      case CelestialColonyType.moon:
        hasStars = true;
        oceanColors = const [
          Color(0xFF334155), // Slate regolith twilight
          Color(0xFF1E293B), // Deep lunar night
          Color(0xFF0F172A), // Cosmic starlight void
          Color(0xFF090D16), // Deep space
          Color(0xFF020617), // Jet black void
        ];
        break;
      case CelestialColonyType.europa:
        oceanColors = const [
          Color(0xFF38BDF8), // Electric cryogenic cyan
          Color(0xFF0284C7), // Subsurface sapphire
          Color(0xFF0369A1), // Deep glacial ocean
          Color(0xFF0C4A6E), // Deep sub-ice abyss
          Color(0xFF041926), // Pitch black sub-crust ocean
        ];
        break;
      case CelestialColonyType.venus:
        oceanColors = const [
          Color(0xFFF59E0B), // Sulfuric scorched gold
          Color(0xFFD97706), // Volcanic amber sea
          Color(0xFF92400E), // Dense sulfuric smog
          Color(0xFF581C87), // Magmatic dark purple
          Color(0xFF1E0B36), // Deep volcanic void
        ];
        break;
      case CelestialColonyType.titan:
        oceanColors = const [
          Color(0xFF059669), // Emerald liquid methane (Kraken Mare)
          Color(0xFF047857), // Deep hydrocarbon green
          Color(0xFF065F46), // Petroleum teal
          Color(0xFF064E3B), // Deep methane trench
          Color(0xFF021B14), // Pitch black hydrocarbon abyss
        ];
        break;
      case CelestialColonyType.pluto:
        hasStars = true;
        oceanColors = const [
          Color(0xFF6B21A8), // Deep Kuiper Belt violet
          Color(0xFF581C87), // Cosmic purple void
          Color(0xFF3B0764), // Deep ultraviolet shadow
          Color(0xFF1E1B4B), // Distant solar void
          Color(0xFF090514), // Interstellar obsidian
        ];
        break;
      case CelestialColonyType.neptune:
        oceanColors = const [
          Color(0xFF2563EB), // Electric supersonic cobalt
          Color(0xFF1D4ED8), // Tempestuous ultramarine
          Color(0xFF1E3A8A), // Oceanic storm deep blue
          Color(0xFF172554), // Abyssal navy trench
          Color(0xFF030712), // Cosmic storm black
        ];
        break;
    }

    // 1. Vast Celestial Depth Radial Gradient
    final oceanGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.18,
      colors: oceanColors,
      stops: const [0.0, 0.30, 0.58, 0.82, 1.0],
    );

    final oceanPaint = Paint()..shader = oceanGradient.createShader(fullRect);
    canvas.drawRect(fullRect, oceanPaint);

    // 2. Swirling Jovian Storm Currents for Jupiter
    if (hasJovianStormSea) {
      final stormPaint = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24.0;
      for (int b = -2; b <= 2; b++) {
        final yPos = (size.height / 2) + (b * 90.0) + math.sin(timeSeconds * 0.4 + b) * 12.0;
        canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), stormPaint);
      }
    }

    // 3. Cosmic Starlight Glints (For Moon & Pluto)
    if (hasStars) {
      final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
      for (int s = 0; s < 36; s++) {
        final sx = (s * 83.0 + 47.0) % size.width;
        final sy = (s * 127.0 + 19.0) % size.height;
        final twinkle = (math.sin(timeSeconds * 3.0 + s) + 1.0) * 0.5;
        canvas.drawCircle(Offset(sx, sy), 0.7 + 0.8 * twinkle, starPaint);
      }
    }

    // 4. High-Altitude Atmospheric Sheen
    final sunGlintPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.95,
        colors: [
          Colors.white.withValues(alpha: hasStars ? 0.05 : 0.12),
          Colors.white.withValues(alpha: 0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(fullRect);
    canvas.drawRect(fullRect, sunGlintPaint);

    // 5. Living Wave Crest Arcs across the open sea (or atmospheric currents)
    final waveAlpha = (colonyType == CelestialColonyType.moon || colonyType == CelestialColonyType.pluto) ? 0.08 : 0.16;
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: waveAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final faintWave = Paint()
      ..color = Colors.white.withValues(alpha: waveAlpha * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 16; i++) {
      final speed = 2.5 + (i % 3) * 0.8;
      final driftX = (timeSeconds * speed + i * 45.0) % (size.width + 120) - 60;
      final yRow = (i * 0.062 + 0.03) * size.height;
      final arcWidth = 55.0 + (i % 4) * 18.0;
      final arcHeight = 14.0 + (i % 3) * 6.0;

      final waveRect = Rect.fromCenter(
        center: Offset(driftX, yRow),
        width: arcWidth,
        height: arcHeight,
      );

      final p = (i % 2 == 0) ? wavePaint : faintWave;
      canvas.drawArc(waveRect, 0.15 + (i * 0.2), 1.6, false, p);
    }
  }

  // =========================================================================
  // 🏝️ 5 ROCK-SOLID EXPANSIVE NATURAL ISLAND ARCHETYPES (100% Solid & Safe)
  // Replaces narrow/broken S-curves. Seed-based gentle harmonics make each island unique!
  // =========================================================================
  Path _getIslandPath() {
    if (island.isPresidential || island.shapeStyle == IslandShapeStyle.citadelApex) {
      return _buildCitadelPlateauPath(island.id);
    }

    final seed = island.shapeSeed != 0 ? island.shapeSeed : island.id;
    final archetype = getIslandArchetype(island.shapeStyle);

    switch (archetype) {
      case IslandArchetype.naturalOval:
        return _buildNaturalOvalPath(seed);
      case IslandArchetype.capePeninsula:
        return _buildCapePeninsulaPath(seed);
      case IslandArchetype.horseshoeBay:
        return _buildHorseshoeBayPath(seed);
      case IslandArchetype.twinSanctuary:
        return _buildTwinSanctuaryPath(seed);
      case IslandArchetype.citadelPlateau:
        return _buildCitadelPlateauPath(seed);
    }
  }

  // 1. Broad Continental Oval with natural coastal coves
  Path _buildNaturalOvalPath(int seed) {
    final path = Path();
    const count = 36;
    for (int i = 0; i <= count; i++) {
      final a = (i / count) * 2 * math.pi;
      final delta = math.sin(a * 3.0 + seed * 1.5) * 6.5 + math.cos(a * 5.0 + seed * 0.8) * 4.0;
      final rx = 195.0 + delta;
      final ry = 155.0 + delta * 0.8;
      final x = rx * math.cos(a);
      final y = ry * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  // 2. Wide Northern Mainland tapering to expansive Southern Cape
  Path _buildCapePeninsulaPath(int seed) {
    final path = Path();
    const count = 36;
    for (int i = 0; i <= count; i++) {
      final a = (i / count) * 2 * math.pi;
      final taper = (math.sin(a) + 1.0) * 0.5; // 0 north, 1 south
      final baseRx = 188.0 - taper * 52.0; // 188 down to 136px
      final baseRy = 162.0;
      final delta = math.sin(a * 4.0 + seed * 1.2) * 5.5 + math.cos(a * 2.0 + seed * 0.9) * 4.0;
      final x = (baseRx + delta) * math.cos(a);
      final y = (baseRy + delta * 0.7) * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  // 3. Lagoon Atoll: Broad solid rounded island with natural coastal contours
  Path _buildHorseshoeBayPath(int seed) {
    final path = Path();
    const count = 36;
    for (int i = 0; i <= count; i++) {
      final a = (i / count) * 2 * math.pi;
      final delta = math.sin(a * 4.0 + seed * 1.3) * 6.0 + math.cos(a * 2.0 + seed * 0.7) * 4.5;
      final rx = 192.0 + delta;
      final ry = 162.0 + delta * 0.75;
      final x = rx * math.cos(a);
      final y = ry * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  // 4. Emerald Arch Haven: Expansive rounded continental island
  Path _buildTwinSanctuaryPath(int seed) {
    final path = Path();
    const count = 36;
    for (int i = 0; i <= count; i++) {
      final a = (i / count) * 2 * math.pi;
      // Gentle natural coves on 4 corners
      final delta = math.sin(a * 4.0 + seed * 1.1) * 7.0 + math.cos(a * 6.0 + seed * 0.5) * 3.5;
      final rx = 190.0 + delta;
      final ry = 160.0 + delta * 0.8;
      final x = rx * math.cos(a);
      final y = ry * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  // 5. Royal Hexagonal Bastion Citadel
  Path _buildCitadelPlateauPath(int seed) {
    final path = Path();
    const count = 8;
    const r = 168.0;
    for (int i = 0; i < count; i++) {
      final a = (i * math.pi / 4) - math.pi / 8;
      final x = r * math.cos(a);
      final y = r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  // =========================================================================
  // 3. REEF, BEACH & PLANETARY TERRAIN (AUTHENTIC CELESTIAL SHADERS)
  // =========================================================================
  void _drawShallowCoralReef(Canvas canvas) {
    final islandPath = _getIslandPath();

    Color outerReefColor;
    Color innerReefColor;
    Color foamWaveColor;

    switch (colonyType) {
      case CelestialColonyType.earth:
        outerReefColor = const Color(0xFF0284C7).withValues(alpha: 0.35);
        innerReefColor = const Color(0xFF38BDF8).withValues(alpha: 0.65);
        foamWaveColor = Colors.white.withValues(alpha: 0.40);
        break;
      case CelestialColonyType.mars:
        outerReefColor = const Color(0xFF991B1B).withValues(alpha: 0.40);
        innerReefColor = const Color(0xFFF87171).withValues(alpha: 0.60);
        foamWaveColor = const Color(0xFFFECACA).withValues(alpha: 0.30);
        break;
      case CelestialColonyType.jupiter:
        outerReefColor = const Color(0xFFB45309).withValues(alpha: 0.42);
        innerReefColor = const Color(0xFFFDE047).withValues(alpha: 0.68);
        foamWaveColor = const Color(0xFFFEF08A).withValues(alpha: 0.35);
        break;
      case CelestialColonyType.saturn:
        outerReefColor = const Color(0xFF92400E).withValues(alpha: 0.38);
        innerReefColor = const Color(0xFFFCD34D).withValues(alpha: 0.62);
        foamWaveColor = const Color(0xFFFEF9C3).withValues(alpha: 0.30);
        break;
      case CelestialColonyType.moon:
        outerReefColor = const Color(0xFF1E293B).withValues(alpha: 0.35);
        innerReefColor = const Color(0xFF94A3B8).withValues(alpha: 0.55);
        foamWaveColor = const Color(0xFFE2E8F0).withValues(alpha: 0.28);
        break;
      case CelestialColonyType.europa:
        outerReefColor = const Color(0xFF0369A1).withValues(alpha: 0.45);
        innerReefColor = const Color(0xFFBAE6FD).withValues(alpha: 0.72);
        foamWaveColor = Colors.white.withValues(alpha: 0.45);
        break;
      case CelestialColonyType.venus:
        outerReefColor = const Color(0xFFB45309).withValues(alpha: 0.40);
        innerReefColor = const Color(0xFFFEF08A).withValues(alpha: 0.62);
        foamWaveColor = const Color(0xFFFFFBEB).withValues(alpha: 0.30);
        break;
      case CelestialColonyType.titan:
        outerReefColor = const Color(0xFF064E3B).withValues(alpha: 0.42);
        innerReefColor = const Color(0xFF34D399).withValues(alpha: 0.65);
        foamWaveColor = const Color(0xFFA7F3D0).withValues(alpha: 0.30);
        break;
      case CelestialColonyType.pluto:
        outerReefColor = const Color(0xFF581C87).withValues(alpha: 0.42);
        innerReefColor = const Color(0xFFE9D5FF).withValues(alpha: 0.68);
        foamWaveColor = const Color(0xFFFAF5FF).withValues(alpha: 0.32);
        break;
      case CelestialColonyType.neptune:
        outerReefColor = const Color(0xFF1E3A8A).withValues(alpha: 0.45);
        innerReefColor = const Color(0xFF93C5FD).withValues(alpha: 0.68);
        foamWaveColor = Colors.white.withValues(alpha: 0.42);
        break;
    }

    // Outermost translucent planetary reef/halo contour
    final reefPaint = Paint()
      ..color = outerReefColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(islandPath, reefPaint);

    // Inner bright planetary luminescence
    final reefInnerPaint = Paint()
      ..color = innerReefColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(islandPath, reefInnerPaint);

    // Living rhythmic ocean surf tide breathing against the shore
    final tide = math.sin(timeSeconds * 2.2);
    final foamPaint = Paint()
      ..color = foamWaveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 + 0.7 * tide
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(islandPath, foamPaint);
  }

  void _drawSandyBeach(Canvas canvas) {
    final islandPath = _getIslandPath();

    Color beachSandColor;
    Color wetSandColor;

    switch (colonyType) {
      case CelestialColonyType.earth:
        beachSandColor = const Color(0xFFFDE68A); // Tropical golden coral sand
        wetSandColor = const Color(0xFFF59E0B).withValues(alpha: 0.55);
        break;
      case CelestialColonyType.mars:
        beachSandColor = const Color(0xFFFDBA74); // Terracotta copper sand
        wetSandColor = const Color(0xFFEA580C).withValues(alpha: 0.60);
        break;
      case CelestialColonyType.jupiter:
        beachSandColor = const Color(0xFFFDE047); // Golden brass & pyrite shoreline
        wetSandColor = const Color(0xFFD97706).withValues(alpha: 0.60);
        break;
      case CelestialColonyType.saturn:
        beachSandColor = const Color(0xFFFEF08A); // Pale rose-gold ring particle sand
        wetSandColor = const Color(0xFFCA8A04).withValues(alpha: 0.60);
        break;
      case CelestialColonyType.moon:
        beachSandColor = const Color(0xFFCBD5E1); // Fine silver lunar dust
        wetSandColor = const Color(0xFF94A3B8).withValues(alpha: 0.60);
        break;
      case CelestialColonyType.europa:
        beachSandColor = const Color(0xFFF0F9FF); // Glacial pure ice crystal shore
        wetSandColor = const Color(0xFF7DD3FC).withValues(alpha: 0.60);
        break;
      case CelestialColonyType.venus:
        beachSandColor = const Color(0xFFFDE68A); // Volcanic ash & sulfur sand
        wetSandColor = const Color(0xFFD97706).withValues(alpha: 0.60);
        break;
      case CelestialColonyType.titan:
        beachSandColor = const Color(0xFFA7F3D0); // Hydrocarbon dune sand
        wetSandColor = const Color(0xFF059669).withValues(alpha: 0.60);
        break;
      case CelestialColonyType.pluto:
        beachSandColor = const Color(0xFFF5F3FF); // Crystalline nitrogen frost shore (lavender-white)
        wetSandColor = const Color(0xFFC084FC).withValues(alpha: 0.60);
        break;
      case CelestialColonyType.neptune:
        beachSandColor = const Color(0xFFBFDBFE); // Diamond azure shore
        wetSandColor = const Color(0xFF1D4ED8).withValues(alpha: 0.60);
        break;
    }

    // Main sand beach rim
    final sandPaint = Paint()
      ..color = beachSandColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(islandPath, sandPaint);

    // Wet shoreline sand edge meeting the water
    final wetSandPaint = Paint()
      ..color = wetSandColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(islandPath, wetSandPaint);
  }

  void _drawIslandTerrainBody(Canvas canvas) {
    final islandPath = _getIslandPath();

    Color sunlitColor;
    Color coreColor;
    Color deepColor;

    switch (colonyType) {
      case CelestialColonyType.earth:
        sunlitColor = const Color(0xFF4ADE80);
        coreColor = const Color(0xFF16A34A);
        deepColor = const Color(0xFF064E3B);
        break;
      case CelestialColonyType.mars:
        sunlitColor = const Color(0xFFEA580C);
        coreColor = const Color(0xFF9A3412);
        deepColor = const Color(0xFF431407);
        break;
      case CelestialColonyType.jupiter:
        // 🪐 Jovian Swirling Amber & Bronze
        sunlitColor = const Color(0xFFF59E0B);
        coreColor = const Color(0xFFB45309);
        deepColor = const Color(0xFF78350F);
        break;
      case CelestialColonyType.saturn:
        // 🪐 Golden Sandstone & Deep Bronze
        sunlitColor = const Color(0xFFFCD34D);
        coreColor = const Color(0xFFCA8A04);
        deepColor = const Color(0xFF713F12);
        break;
      case CelestialColonyType.moon:
        // 🌕 Authentic Lunar Regolith Slate
        sunlitColor = const Color(0xFF94A3B8);
        coreColor = const Color(0xFF475569);
        deepColor = const Color(0xFF1E293B);
        break;
      case CelestialColonyType.europa:
        // 🧊 Glacial Cyan & Pure White Polar Ice
        sunlitColor = const Color(0xFFFFFFFF);
        coreColor = const Color(0xFF7DD3FC);
        deepColor = const Color(0xFF0284C7);
        break;
      case CelestialColonyType.venus:
        // 🟡 Sulfuric Volcanic Ochre
        sunlitColor = const Color(0xFFFBBF24);
        coreColor = const Color(0xFFB45309);
        deepColor = const Color(0xFF78350F);
        break;
      case CelestialColonyType.titan:
        // 🪐 Emerald Hydrocarbon Dunes
        sunlitColor = const Color(0xFF10B981);
        coreColor = const Color(0xFF047857);
        deepColor = const Color(0xFF064E3B);
        break;
      case CelestialColonyType.pluto:
        // ❄️ Cryogenic Nitrogen Glaciers & Lavender/Cosmic Violet (Strictly non-green!)
        sunlitColor = const Color(0xFFF3E8FF);
        coreColor = const Color(0xFFA855F7);
        deepColor = const Color(0xFF4C1D95);
        break;
      case CelestialColonyType.neptune:
        // 🌊 Supersonic Oceanic Tempest Cobalt
        sunlitColor = const Color(0xFF60A5FA);
        coreColor = const Color(0xFF2563EB);
        deepColor = const Color(0xFF172554);
        break;
    }

    final landGradient = RadialGradient(
      center: const Alignment(-0.15, -0.22),
      radius: 0.98,
      colors: [sunlitColor, coreColor, deepColor],
      stops: const [0.0, 0.52, 1.0],
    );

    final landPaint = Paint()
      ..shader = landGradient.createShader(Rect.fromCircle(center: Offset.zero, radius: 230))
      ..style = PaintingStyle.fill;

    canvas.drawPath(islandPath, landPaint);

    // Planet-Specific Authentic Geological Surface Features:
    switch (colonyType) {
      case CelestialColonyType.moon:
        _drawLunarCraters(canvas, islandPath);
        break;
      case CelestialColonyType.mars:
        _drawMartianFissures(canvas, islandPath);
        break;
      case CelestialColonyType.jupiter:
        _drawJovianStormSwirls(canvas, islandPath);
        break;
      case CelestialColonyType.saturn:
        _drawSaturnRingShadows(canvas, islandPath);
        break;
      case CelestialColonyType.europa:
        _drawEuropaGlacialLineae(canvas, islandPath);
        break;
      case CelestialColonyType.venus:
        _drawVenusianMagmaVeins(canvas, islandPath);
        break;
      case CelestialColonyType.titan:
        _drawTitanMethaneDunes(canvas, islandPath);
        break;
      case CelestialColonyType.pluto:
        _drawPlutoNitrogenCells(canvas, islandPath);
        break;
      case CelestialColonyType.neptune:
        _drawNeptunianTempestStreaks(canvas, islandPath);
        break;
      case CelestialColonyType.earth:
        break;
    }
  }

  // 🔴 Authentic Martian Canyon Fissures & Fault Lines with Volcanic Glow
  void _drawMartianFissures(Canvas canvas, Path islandPath) {
    canvas.save();
    canvas.clipPath(islandPath);

    final fissurePaint = Paint()
      ..color = const Color(0xFF431407).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const lines = [
      [Offset(-90, -45), Offset(-30, -25), Offset(15, -60)],
      [Offset(-40, 30), Offset(20, 55), Offset(85, 40)],
      [Offset(-110, 60), Offset(-60, 80), Offset(-10, 95)],
    ];

    for (final seg in lines) {
      final p = Path()..moveTo(seg[0].dx, seg[0].dy);
      for (int i = 1; i < seg.length; i++) {
        p.lineTo(seg[i].dx, seg[i].dy);
      }
      canvas.drawPath(p, glowPaint);
      canvas.drawPath(p, fissurePaint);
    }

    canvas.restore();
  }

  // 🪐 Jovian Atmospheric Swirling Cyclone Bands
  void _drawJovianStormSwirls(Canvas canvas, Path islandPath) {
    canvas.save();
    canvas.clipPath(islandPath);

    final stormGold = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final stormDark = Paint()
      ..color = const Color(0xFF78350F).withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    for (int i = -3; i <= 3; i++) {
      final y = i * 36.0;
      final wave = Path();
      wave.moveTo(-220, y);
      for (double x = -220; x <= 220; x += 25) {
        final wy = y + math.sin(x * 0.03 + (timeSeconds * 0.5) + i) * 6.5;
        wave.lineTo(x, wy);
      }
      canvas.drawPath(wave, (i % 2 == 0) ? stormGold : stormDark);
    }

    // Great Red Spot Eye vortex
    final spotCenter = const Offset(65, -35);
    final spotPaint = Paint()..color = const Color(0xFF991B1B).withValues(alpha: 0.45);
    canvas.drawOval(Rect.fromCenter(center: spotCenter, width: 44, height: 26), spotPaint);

    canvas.restore();
  }

  // 🪐 Concentric Golden Saturnian Ring Shadows
  void _drawSaturnRingShadows(Canvas canvas, Path islandPath) {
    canvas.save();
    canvas.clipPath(islandPath);

    final ringShadow = Paint()
      ..color = const Color(0xFF713F12).withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0;

    for (int r = 0; r < 4; r++) {
      final arcRect = Rect.fromCenter(
        center: Offset(0, -180.0 + r * 30.0),
        width: 380,
        height: 180,
      );
      canvas.drawArc(arcRect, 0.2, 2.7, false, ringShadow);
    }

    canvas.restore();
  }

  // 🧊 Cryogenic Europa Glacial Lineae / Ice Cracks
  void _drawEuropaGlacialLineae(Canvas canvas, Path islandPath) {
    canvas.save();
    canvas.clipPath(islandPath);

    final crackPaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final crackGlow = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    const rifts = [
      [Offset(-130, -70), Offset(-40, -10), Offset(60, -50), Offset(130, -20)],
      [Offset(-80, 80), Offset(10, 40), Offset(90, 85)],
      [Offset(-30, -100), Offset(20, -15), Offset(-10, 75)],
    ];

    for (final seg in rifts) {
      final p = Path()..moveTo(seg[0].dx, seg[0].dy);
      for (int i = 1; i < seg.length; i++) {
        p.lineTo(seg[i].dx, seg[i].dy);
      }
      canvas.drawPath(p, crackGlow);
      canvas.drawPath(p, crackPaint);
    }

    canvas.restore();
  }

  // 🟡 Sulfuric Venusian Magma Veins
  void _drawVenusianMagmaVeins(Canvas canvas, Path islandPath) {
    canvas.save();
    canvas.clipPath(islandPath);

    final magmaGlow = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final magmaCore = Paint()
      ..color = const Color(0xFFDC2626).withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int v = 0; v < 3; v++) {
      final p = Path();
      final startY = -60.0 + v * 60.0;
      p.moveTo(-120, startY);
      p.cubicTo(-40, startY - 25, 30, startY + 35, 110, startY - 10);
      canvas.drawPath(p, magmaGlow);
      canvas.drawPath(p, magmaCore);
    }

    canvas.restore();
  }

  // 🪐 Titan Hydrocarbon Dune Ripples
  void _drawTitanMethaneDunes(Canvas canvas, Path islandPath) {
    canvas.save();
    canvas.clipPath(islandPath);

    final dunePaint = Paint()
      ..color = const Color(0xFF047857).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    for (int d = -4; d <= 4; d++) {
      final y = d * 26.0;
      final p = Path()..moveTo(-160, y);
      for (double x = -160; x <= 160; x += 30) {
        p.lineTo(x, y + math.sin(x * 0.04) * 4.0);
      }
      canvas.drawPath(p, dunePaint);
    }

    canvas.restore();
  }

  // ❄️ Pluto Crystalline Nitrogen Ice Convection Cells (Strictly Non-Green)
  void _drawPlutoNitrogenCells(Canvas canvas, Path islandPath) {
    canvas.save();
    canvas.clipPath(islandPath);

    final cellRim = Paint()
      ..color = const Color(0xFFC084FC).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final cellCenter = Paint()
      ..color = const Color(0xFFF3E8FF).withValues(alpha: 0.25);

    const cells = [
      (Offset(-75, -45), 24.0),
      (Offset(-25, -20), 28.0),
      (Offset(35, -40), 22.0),
      (Offset(-65, 35), 26.0),
      (Offset(10, 45), 30.0),
      (Offset(80, 20), 25.0),
    ];

    for (final c in cells) {
      canvas.drawCircle(c.$1, c.$2, cellCenter);
      canvas.drawCircle(c.$1, c.$2, cellRim);
    }

    canvas.restore();
  }

  // 🌊 Neptunian Supersonic Jet Streaks
  void _drawNeptunianTempestStreaks(Canvas canvas, Path islandPath) {
    canvas.save();
    canvas.clipPath(islandPath);

    final streakPaint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    for (int s = -3; s <= 3; s++) {
      final y = s * 34.0;
      final speedX = ((timeSeconds * 40.0 + s * 90.0) % 500.0) - 250.0;
      canvas.drawLine(Offset(speedX - 60, y), Offset(speedX + 60, y), streakPaint);
    }

    canvas.restore();
  }

  // 🌕 Authentic Soft Circular Lunar Impact Craters on the Moon
  void _drawLunarCraters(Canvas canvas, Path islandPath) {
    canvas.save();
    canvas.clipPath(islandPath);

    final craterPaint = Paint()..color = const Color(0xFF1E293B).withValues(alpha: 0.45);
    final craterRim = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const craters = [
      (Offset(-115, -75), 18.0),
      (Offset(125, -60), 22.0),
      (Offset(-85, 85), 16.0),
      (Offset(105, 80), 19.0),
      (Offset(-25, -100), 14.0),
      (Offset(30, 95), 15.0),
    ];

    for (final c in craters) {
      canvas.drawCircle(c.$1, c.$2, craterPaint);
      canvas.drawCircle(c.$1, c.$2, craterRim);
      canvas.drawCircle(c.$1.translate(-1.0, -1.0), c.$2 * 0.28, Paint()..color = const Color(0xFF64748B));
    }

    canvas.restore();
  }

  void _drawInteriorWaterBody(Canvas canvas) {
    if (island.isPresidential) return;

    final archetype = getIslandArchetype(island.shapeStyle);

    Color lagoonColor;
    Color sandColor;

    switch (colonyType) {
      case CelestialColonyType.earth:
        lagoonColor = const Color(0xFF06B6D4).withValues(alpha: 0.90);
        sandColor = const Color(0xFFFDE68A);
        break;
      case CelestialColonyType.mars:
        lagoonColor = const Color(0xFF991B1B).withValues(alpha: 0.85);
        sandColor = const Color(0xFFFDBA74);
        break;
      case CelestialColonyType.jupiter:
        lagoonColor = const Color(0xFFD97706).withValues(alpha: 0.88);
        sandColor = const Color(0xFFFDE047);
        break;
      case CelestialColonyType.saturn:
        lagoonColor = const Color(0xFFB45309).withValues(alpha: 0.88);
        sandColor = const Color(0xFFFEF08A);
        break;
      case CelestialColonyType.moon:
        lagoonColor = const Color(0xFF1E293B).withValues(alpha: 0.90);
        sandColor = const Color(0xFFCBD5E1);
        break;
      case CelestialColonyType.europa:
        lagoonColor = const Color(0xFF0284C7).withValues(alpha: 0.90);
        sandColor = const Color(0xFFF0F9FF);
        break;
      case CelestialColonyType.venus:
        lagoonColor = const Color(0xFFB45309).withValues(alpha: 0.88);
        sandColor = const Color(0xFFFDE68A);
        break;
      case CelestialColonyType.titan:
        lagoonColor = const Color(0xFF047857).withValues(alpha: 0.88);
        sandColor = const Color(0xFFA7F3D0);
        break;
      case CelestialColonyType.pluto:
        lagoonColor = const Color(0xFFA855F7).withValues(alpha: 0.88);
        sandColor = const Color(0xFFF5F3FF);
        break;
      case CelestialColonyType.neptune:
        lagoonColor = const Color(0xFF1E3A8A).withValues(alpha: 0.90);
        sandColor = const Color(0xFFBFDBFE);
        break;
    }

    final lagoonPaint = Paint()
      ..color = lagoonColor
      ..style = PaintingStyle.fill;

    final lagoonSandRim = Paint()
      ..color = sandColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;

    final lagoonFoam = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final lagoonPath = Path();
    if (archetype == IslandArchetype.naturalOval) {
      lagoonPath.addOval(Rect.fromCenter(center: Offset.zero, width: 75, height: 55));
    } else if (archetype == IslandArchetype.horseshoeBay) {
      lagoonPath.addOval(Rect.fromCenter(center: const Offset(0, 50), width: 85, height: 65));
    } else if (archetype == IslandArchetype.twinSanctuary) {
      lagoonPath.addOval(Rect.fromCenter(center: Offset.zero, width: 50, height: 40));
    }

    if (!lagoonPath.getBounds().isEmpty) {
      canvas.drawPath(lagoonPath, lagoonSandRim);
      canvas.drawPath(lagoonPath, lagoonPaint);
      canvas.drawPath(lagoonPath, lagoonFoam);
    }
  }

  void _drawRoadways(Canvas canvas) {
    final archetype = getIslandArchetype(island.shapeStyle);
    final roadPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.85) // Crisp light pathway
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;

    final roadBorder = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.2
      ..strokeCap = StrokeCap.round;

    final rPath = Path();
    if (island.isPresidential || archetype == IslandArchetype.citadelPlateau) {
      rPath.moveTo(-115, 0);
      rPath.lineTo(115, 0);
      rPath.moveTo(0, -95);
      rPath.lineTo(0, 95);
    } else if (archetype == IslandArchetype.naturalOval) {
      // Loop avenue between inner and outer ring
      rPath.addOval(Rect.fromCenter(center: Offset.zero, width: 205, height: 160));
    } else if (archetype == IslandArchetype.capePeninsula) {
      // North-South spine boulevard with cross avenues
      rPath.moveTo(0, -145);
      rPath.lineTo(0, 135);
      rPath.moveTo(-85, -55);
      rPath.lineTo(85, -55);
      rPath.moveTo(-65, 38);
      rPath.lineTo(65, 38);
    } else if (archetype == IslandArchetype.horseshoeBay) {
      // Curved horseshoe boulevard
      const r = 145.0;
      for (int i = 0; i <= 36; i++) {
        final a = -2.35 + (i / 36.0) * 4.3;
        final x = r * math.cos(a);
        final y = r * math.sin(a) * 0.92;
        if (i == 0) {
          rPath.moveTo(x, y);
        } else {
          rPath.lineTo(x, y);
        }
      }
    } else if (archetype == IslandArchetype.twinSanctuary) {
      // Highway connecting West and East sanctuaries
      rPath.moveTo(-120, -75);
      rPath.lineTo(-120, 45);
      rPath.moveTo(120, -75);
      rPath.lineTo(120, 45);
      rPath.moveTo(-120, -15);
      rPath.lineTo(120, -15); // Land bridge link
    }

    canvas.drawPath(rPath, roadBorder);
    canvas.drawPath(rPath, roadPaint);
  }

  // =========================================================================
  // ⚽ MINI SPORTS TURF PITCH (FOOTBALL TURF WITH WHITE MARKINGS)
  // Strictly on green land! Never inside water bays or lagoons!
  // =========================================================================
  void _drawSportsTurfPitch(Canvas canvas) {
    final archetype = getIslandArchetype(island.shapeStyle);
    Offset pitchCenter;
    switch (archetype) {
      case IslandArchetype.naturalOval:
        pitchCenter = const Offset(0, 85);
        break;
      case IslandArchetype.capePeninsula:
        pitchCenter = const Offset(0, -145);
        break;
      case IslandArchetype.horseshoeBay:
        pitchCenter = const Offset(0, -115);
        break;
      case IslandArchetype.twinSanctuary:
        pitchCenter = const Offset(0, 65);
        break;
      case IslandArchetype.citadelPlateau:
        pitchCenter = const Offset(0, 105);
        break;
    }
    const w = 36.0;
    const h = 22.0;
    final pitchRect = Rect.fromCenter(center: pitchCenter, width: w, height: h);

    // Dark turf green base
    final turfBase = Paint()..color = const Color(0xFF15803D);
    canvas.drawRRect(RRect.fromRectAndRadius(pitchRect, const Radius.circular(3)), turfBase);

    // Subtle turf lawn mowing stripes
    final stripePaint = Paint()..color = const Color(0xFF16A34A).withValues(alpha: 0.55);
    for (int s = 0; s < 5; s++) {
      if (s % 2 == 0) {
        final sx = pitchRect.left + s * (w / 5);
        canvas.drawRect(Rect.fromLTWH(sx, pitchRect.top, w / 5, h), stripePaint);
      }
    }

    // Crisp white field markings
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;

    // Outer boundary
    canvas.drawRect(pitchRect, linePaint);
    // Half-way line
    canvas.drawLine(Offset(pitchCenter.dx, pitchRect.top), Offset(pitchCenter.dx, pitchRect.bottom), linePaint);
    // Center circle
    canvas.drawCircle(pitchCenter, 3.8, linePaint);
    // Center spot
    canvas.drawCircle(pitchCenter, 0.8, Paint()..color = Colors.white);

    // Left Goal Penalty Box
    canvas.drawRect(Rect.fromLTWH(pitchRect.left, pitchCenter.dy - 5.5, 6.0, 11.0), linePaint);
    // Right Goal Penalty Box
    canvas.drawRect(Rect.fromLTWH(pitchRect.right - 6.0, pitchCenter.dy - 5.5, 6.0, 11.0), linePaint);
  }

  // =========================================================================
  // 🚤 CRUISING BOATS WITH V-SHAPED FOAM WAKES (LIVE 60FPS DEEP SEA MOTION)
  // Strictly in deep open ocean! Never touches island shores or beaches!
  // =========================================================================
  void _drawCruisingBoatsWithWakes(Canvas canvas) {
    if (island.isPresidential) return;

    // 1. Moving Offshore Speedboat cruising in wide deep blue waters (gentle, relaxing glide)
    final t1 = (timeSeconds * 0.02) % (2 * math.pi);
    final pos1 = Offset(330.0 * math.cos(t1), 275.0 * math.sin(t1));
    final angle1 = t1 + math.pi / 2;
    _drawBoatWithWake(
      canvas,
      pos: pos1,
      angle: angle1,
      boatLength: 15,
      boatWidth: 6.5,
      wakeLength: 48,
    );

    // 2. Luxury Cruising Yacht traveling along outer southern deep sea
    final t2 = (-timeSeconds * 0.014) % (2 * math.pi);
    final pos2 = Offset(380.0 * math.cos(t2), 320.0 * math.sin(t2));
    final angle2 = t2 - math.pi / 2;
    _drawBoatWithWake(
      canvas,
      pos: pos2,
      angle: angle2,
      boatLength: 17,
      boatWidth: 7.5,
      wakeLength: 55,
    );

    // 3. Open Ocean Horizon Tender Boat
    final t3 = (timeSeconds * 0.016) % (2 * math.pi);
    final pos3 = Offset(-340.0 + math.cos(t3) * 40.0, 260.0 + math.sin(t3) * 30.0);
    _drawBoatWithWake(
      canvas,
      pos: pos3,
      angle: 0.85,
      boatLength: 12,
      boatWidth: 5.5,
      wakeLength: 38,
    );
  }

  void _drawBoatWithWake(
    Canvas canvas, {
    required Offset pos,
    required double angle,
    required double boatLength,
    required double boatWidth,
    required double wakeLength,
  }) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    // Expanding V-Shaped White Wake Trails
    final wakePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final wakeFade = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    // Dual wake plumes
    final wakePath = Path();
    wakePath.moveTo(-boatLength * 0.4, -boatWidth * 0.4);
    wakePath.lineTo(-boatLength * 0.4 - wakeLength, -boatWidth * 1.8);
    wakePath.moveTo(-boatLength * 0.4, boatWidth * 0.4);
    wakePath.lineTo(-boatLength * 0.4 - wakeLength, boatWidth * 1.8);
    canvas.drawPath(wakePath, wakePaint);
    canvas.drawPath(wakePath, wakeFade);

    // Hull (Top-Down boat body)
    final hull = Path();
    hull.moveTo(-boatLength * 0.5, -boatWidth * 0.5);
    hull.lineTo(boatLength * 0.25, -boatWidth * 0.5);
    hull.lineTo(boatLength * 0.5, 0); // Pointed bow
    hull.lineTo(boatLength * 0.25, boatWidth * 0.5);
    hull.lineTo(-boatLength * 0.5, boatWidth * 0.5);
    hull.close();

    // Boat shadow in water
    canvas.drawPath(hull.shift(const Offset(1.5, 2.0)), Paint()..color = Colors.black38);
    // Crisp white boat deck
    canvas.drawPath(hull, Paint()..color = Colors.white);
    // Cockpit windshield
    canvas.drawRect(
      Rect.fromCenter(center: Offset(boatLength * 0.05, 0), width: boatLength * 0.35, height: boatWidth * 0.65),
      Paint()..color = const Color(0xFF0284C7),
    );

    canvas.restore();
  }

  // =========================================================================
  // 🪵 WOODEN PIER, MARINA & TIED BOATS
  // =========================================================================
  void _drawWoodenPierAndBoats(Canvas canvas) {
    final pierPaint = Paint()
      ..color = const Color(0xFF854D0E) // Rich wooden plank tone
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.square;

    final pierDeckLight = Paint()
      ..color = const Color(0xFFA16207)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    if (island.isPresidential) {
      // Royal Pier
      canvas.drawLine(const Offset(-125, 0), const Offset(-185, 0), pierPaint);
      canvas.drawLine(const Offset(-125, 0), const Offset(-185, 0), pierDeckLight);
      canvas.drawLine(const Offset(-185, -30), const Offset(-185, 30), pierPaint);
      _drawYacht(canvas, const Offset(-202, 0), angle: -math.pi / 2, isGold: true);
    } else {
      // East Side Marina Pier extending into clear turquoise water
      canvas.drawLine(const Offset(150, 20), const Offset(218, 20), pierPaint);
      canvas.drawLine(const Offset(150, 20), const Offset(218, 20), pierDeckLight);
      canvas.drawLine(const Offset(218, -14), const Offset(218, 56), pierPaint);
      canvas.drawLine(const Offset(218, -14), const Offset(218, 56), pierDeckLight);

      // Wooden plank cross-lines for boardwalk authenticity
      final plankLine = Paint()..color = const Color(0xFF713F12)..strokeWidth = 1.0;
      for (double px = 155; px <= 215; px += 8) {
        canvas.drawLine(Offset(px, 15), Offset(px, 25), plankLine);
      }

      // Tied boats moored along the marina pier bobbing on gentle ocean swells
      final bob1 = math.sin(timeSeconds * 2.8) * 1.3;
      final bob2 = math.sin(timeSeconds * 2.8 + 1.2) * 1.3;
      _drawYacht(canvas, Offset(230, 0 + bob1), angle: 0);
      _drawYacht(canvas, Offset(230, 42 + bob2), angle: 0);
      _drawYacht(canvas, Offset(186, -32 + bob1 * 0.7), angle: -0.42);
    }
  }

  void _drawYacht(Canvas canvas, Offset pos, {double angle = 0, bool isGold = false}) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    final hullPath = Path();
    hullPath.moveTo(-12, -5.5);
    hullPath.lineTo(6, -5.5);
    hullPath.lineTo(15, 0); // Bow
    hullPath.lineTo(6, 5.5);
    hullPath.lineTo(-12, 5.5);
    hullPath.close();

    // Shadow
    canvas.drawPath(hullPath.shift(const Offset(1.5, 2.0)), Paint()..color = Colors.black38);

    final hullPaint = Paint()..color = isGold ? const Color(0xFFFFD700) : Colors.white;
    canvas.drawPath(hullPath, hullPaint);

    final deckPaint = Paint()..color = isGold ? Colors.black87 : const Color(0xFF0284C7);
    canvas.drawRect(const Rect.fromLTWH(-4.5, -3.2, 9, 6.4), deckPaint);

    canvas.restore();
  }

  // =========================================================================
  // ☁️ HIGH-ALTITUDE DRIFTING ATMOSPHERIC CLOUDS & GROUND SHADOWS
  // =========================================================================
  void _drawAtmosphericClouds(Canvas canvas) {
    final clouds = [
      const _CloudClusterDef(center: Offset(-140, -120), scale: 1.15, speed: 1.2),
      const _CloudClusterDef(center: Offset(130, -90), scale: 1.30, speed: 0.9),
      const _CloudClusterDef(center: Offset(-90, 140), scale: 1.25, speed: 1.4),
      const _CloudClusterDef(center: Offset(150, 110), scale: 1.05, speed: 1.1),
    ];

    for (int i = 0; i < clouds.length; i++) {
      final c = clouds[i];
      final driftX = ((timeSeconds * c.speed * 8.0) + i * 160.0) % 700.0 - 350.0;
      final driftY = math.sin(timeSeconds * 0.25 + i) * 6.0;
      final center = c.center.translate(driftX, driftY);

      // 1. Soft Shadow cast onto the ground/water below (offset by +18, +24)
      _drawCloudPuffs(canvas, center.translate(18, 24), c.scale, isShadow: true);

      // 2. High-Altitude White Volumetric Cloud Cluster
      _drawCloudPuffs(canvas, center, c.scale, isShadow: false);
    }
  }

  void _drawCloudPuffs(Canvas canvas, Offset center, double scale, {required bool isShadow}) {
    final puffOffsets = [
      Offset.zero,
      const Offset(-22, -4),
      const Offset(20, -3),
      const Offset(-11, 8),
      const Offset(13, 7),
      const Offset(0, -11),
    ];

    final puffRadii = [26.0, 19.0, 20.0, 17.0, 19.0, 16.0];

    for (int j = 0; j < puffOffsets.length; j++) {
      final pPos = center + puffOffsets[j] * scale;
      final r = puffRadii[j] * scale;

      final Paint paint = Paint();
      if (isShadow) {
        paint.shader = RadialGradient(
          colors: [
            Colors.black.withValues(alpha: 0.12),
            Colors.black.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(Rect.fromCircle(center: pPos, radius: r * 1.2));
      } else {
        paint.shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.40),
            Colors.white.withValues(alpha: 0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: pPos, radius: r * 1.15));
      }

      canvas.drawCircle(pPos, r * 1.15, paint);
    }
  }

  // =========================================================================
  // 🕊️ SOARING SEAGULLS GLIDING OVER AZURE WATER (LIVE 60FPS MOTION)
  // =========================================================================
  void _drawSoaringSeagulls(Canvas canvas) {
    for (int i = 0; i < 5; i++) {
      final flightAngle = (timeSeconds * 0.16 + i * 1.25) % (2 * math.pi);
      final radiusX = 220.0 + (i % 2 == 0 ? 15 : -15);
      final radiusY = 170.0 + (i % 3 == 0 ? 20 : -10);
      final gx = radiusX * math.cos(flightAngle);
      final gy = radiusY * math.sin(flightAngle);
      final wingFlap = math.sin(timeSeconds * 8.5 + i * 1.5);
      _drawSingleSeagull(canvas, Offset(gx, gy), wingFlap: wingFlap);
    }
  }

  void _drawSingleSeagull(Canvas canvas, Offset pt, {double wingFlap = 0.0}) {
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final gullPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final wingY = pt.dy + wingFlap * 1.8;

    // Shadow
    final sp = Path();
    sp.moveTo(pt.dx - 5.5 + 4, wingY - 1.5 + 6);
    sp.quadraticBezierTo(pt.dx - 2.5 + 4, wingY + 1.8 + 6, pt.dx + 4, pt.dy - 0.5 + 6);
    sp.quadraticBezierTo(pt.dx + 2.5 + 4, wingY + 1.8 + 6, pt.dx + 5.5 + 4, wingY - 1.5 + 6);
    canvas.drawPath(sp, shadowPaint);

    // White wings
    final p = Path();
    p.moveTo(pt.dx - 5.5, wingY - 1.5);
    p.quadraticBezierTo(pt.dx - 2.5, wingY + 1.8, pt.dx, pt.dy - 0.5);
    p.quadraticBezierTo(pt.dx + 2.5, wingY + 1.8, pt.dx + 5.5, wingY - 1.5);
    canvas.drawPath(p, gullPaint);
  }

  // =========================================================================
  // 🐑 LIVING WILDLIFE & GRAZING ANIMALS (Peaceful sheep & horses on meadow belt)
  // =========================================================================
  void _drawGrazingAnimals(Canvas canvas) {
    if (island.isPresidential) return;

    // Peaceful woolly sheep grazing on meadow green spaces near sports turf
    final sheepOffsets = [
      const Offset(-42, 14),
      const Offset(-50, 20),
      const Offset(-36, 24),
      const Offset(46, -18),
      const Offset(54, -10),
    ];

    for (int i = 0; i < sheepOffsets.length; i++) {
      final base = sheepOffsets[i];
      final drift = math.sin(timeSeconds * 0.4 + i * 1.5) * 1.6;
      final pos = base.translate(drift, drift * 0.35);

      // Ground shadow
      canvas.drawOval(
        Rect.fromCenter(center: pos.translate(0.5, 0.7), width: 4.2, height: 2.4),
        Paint()..color = Colors.black26,
      );
      // Fluffy woolly sheep body
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 3.6, height: 2.4),
        Paint()..color = Colors.white.withValues(alpha: 0.95),
      );
      // Dark head & face
      canvas.drawCircle(pos.translate(1.4, -0.4), 0.9, Paint()..color = const Color(0xFF1E293B));
    }

    // Majestic grazing horses on open grass
    final horseOffsets = [
      const Offset(-28, -26),
      const Offset(34, 30),
    ];
    for (int i = 0; i < horseOffsets.length; i++) {
      final base = horseOffsets[i];
      final drift = math.cos(timeSeconds * 0.3 + i * 2.0) * 2.0;
      final pos = base.translate(drift, drift * 0.25);

      // Horse shadow
      canvas.drawOval(
        Rect.fromCenter(center: pos.translate(0.6, 1.0), width: 5.6, height: 2.8),
        Paint()..color = Colors.black26,
      );
      // Horse body (chestnut brown / dark stallion)
      final horseColor = i == 0 ? const Color(0xFF854D0E) : const Color(0xFF1C1917);
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 5.0, height: 2.6),
        Paint()..color = horseColor,
      );
      // Horse neck and head
      canvas.drawCircle(pos.translate(2.3, -0.9), 1.2, Paint()..color = horseColor);
    }
  }

  // =========================================================================
  // 🗺️ 35 TERRITORIAL DISTRICTS / STATE-STYLE PARTITIONS (POLITICAL MAP OF ISLAND)
  // Like Kerala & Tamil Nadu in India or California & Texas in the USA:
  // The entire green island is partitioned into 35 contiguous territorial provinces
  // with curved cartographic district boundary lines (വരകൾ)!
  // =========================================================================
  static final Map<String, List<Path>> _cachedDistrictCells = {};

  void _draw35TerritorialDistricts(Canvas canvas) {
    final islandPath = _getIslandPath();
    final cells = _getOrComputeDistrictCells(island.shapeStyle);

    canvas.save();
    canvas.clipPath(islandPath);

    // 1. Subtle distinct territorial fill per district (harmonized with planetary biome)
    final List<Paint> districtPaints;
    switch (colonyType) {
      case CelestialColonyType.moon:
        districtPaints = [
          Paint()..color = const Color(0xFF475569).withValues(alpha: 0.25),
          Paint()..color = const Color(0xFF64748B).withValues(alpha: 0.20),
          Paint()..color = const Color(0xFF334155).withValues(alpha: 0.30),
        ];
        break;
      case CelestialColonyType.mars:
        districtPaints = [
          Paint()..color = const Color(0xFF9A3412).withValues(alpha: 0.25),
          Paint()..color = const Color(0xFFC2410C).withValues(alpha: 0.20),
          Paint()..color = const Color(0xFF7C2D12).withValues(alpha: 0.30),
        ];
        break;
      case CelestialColonyType.jupiter:
        districtPaints = [
          Paint()..color = const Color(0xFFB45309).withValues(alpha: 0.25),
          Paint()..color = const Color(0xFFD97706).withValues(alpha: 0.20),
          Paint()..color = const Color(0xFF78350F).withValues(alpha: 0.30),
        ];
        break;
      case CelestialColonyType.saturn:
        districtPaints = [
          Paint()..color = const Color(0xFFCA8A04).withValues(alpha: 0.25),
          Paint()..color = const Color(0xFFEAB308).withValues(alpha: 0.20),
          Paint()..color = const Color(0xFF854D0E).withValues(alpha: 0.30),
        ];
        break;
      case CelestialColonyType.europa:
        districtPaints = [
          Paint()..color = const Color(0xFF7DD3FC).withValues(alpha: 0.28),
          Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.22),
          Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.26),
        ];
        break;
      case CelestialColonyType.venus:
        districtPaints = [
          Paint()..color = const Color(0xFFF59E0B).withValues(alpha: 0.26),
          Paint()..color = const Color(0xFFD97706).withValues(alpha: 0.22),
          Paint()..color = const Color(0xFFB45309).withValues(alpha: 0.30),
        ];
        break;
      case CelestialColonyType.titan:
        districtPaints = [
          Paint()..color = const Color(0xFF047857).withValues(alpha: 0.26),
          Paint()..color = const Color(0xFF059669).withValues(alpha: 0.22),
          Paint()..color = const Color(0xFF065F46).withValues(alpha: 0.30),
        ];
        break;
      case CelestialColonyType.pluto:
        districtPaints = [
          Paint()..color = const Color(0xFFA855F7).withValues(alpha: 0.26),
          Paint()..color = const Color(0xFF9333EA).withValues(alpha: 0.20),
          Paint()..color = const Color(0xFF6B21A8).withValues(alpha: 0.30),
        ];
        break;
      case CelestialColonyType.neptune:
        districtPaints = [
          Paint()..color = const Color(0xFF2563EB).withValues(alpha: 0.26),
          Paint()..color = const Color(0xFF1D4ED8).withValues(alpha: 0.22),
          Paint()..color = const Color(0xFF1E40AF).withValues(alpha: 0.30),
        ];
        break;
      case CelestialColonyType.earth:
        districtPaints = [
          Paint()..color = const Color(0xFF15803D).withValues(alpha: 0.28),
          Paint()..color = const Color(0xFF16A34A).withValues(alpha: 0.20),
          Paint()..color = const Color(0xFF047857).withValues(alpha: 0.26),
          Paint()..color = const Color(0xFF166534).withValues(alpha: 0.32),
          Paint()..color = const Color(0xFF0F766E).withValues(alpha: 0.22),
        ];
        break;
    }

    for (int i = 0; i < cells.length; i++) {
      final cellPath = cells[i];
      final paint = districtPaints[i % districtPaints.length];
      canvas.drawPath(cellPath, paint);
    }

    // 2. Official Cartographic District Boundary Lines (മാപ്പിൽ സ്റ്റേറ്റുകൾ തിരിക്കുന്നതുപോലെ വരകൾ)
    final borderPaint = Paint()
      ..color = const Color(0xFFF8FAFC).withValues(alpha: 0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35;

    final borderShadowPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 0; i < cells.length; i++) {
      final cellPath = cells[i];
      canvas.drawPath(cellPath, borderPaint);
      canvas.drawPath(cellPath, borderShadowPaint);
    }

    // 3. Highlight Selected District Territory with Radiant Golden Glow
    if (selectedPlotNumber != null &&
        selectedPlotNumber! >= 1 &&
        selectedPlotNumber! <= cells.length) {
      final selCell = cells[selectedPlotNumber! - 1];
      canvas.drawPath(
        selCell,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.30)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        selCell,
        Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
    }

    canvas.restore();
  }

  static List<Path> _getOrComputeDistrictCells(IslandShapeStyle style) {
    final key = '${style.name}_${PoketCosmosAllocationService.maxPlotsPerIsland}';
    if (_cachedDistrictCells.containsKey(key)) {
      return _cachedDistrictCells[key]!;
    }

    // Generate exactly 25 territorial district cells (or maxPlotsPerIsland)
    final coords = get35PlotCoordinates(style).take(PoketCosmosAllocationService.maxPlotsPerIsland).toList();
    final count = coords.length;
    final List<Path> paths = [];

    // Bounding box covering the island world
    final box = [
      const Offset(-260, -260),
      const Offset(260, -260),
      const Offset(260, 260),
      const Offset(-260, 260),
    ];

    for (int i = 0; i < count; i++) {
      var cell = List<Offset>.from(box);
      for (int j = 0; j < count; j++) {
        if (i == j) continue;
        cell = _clipPolyHalfPlane(cell, coords[i], coords[j]);
      }
      final p = Path();
      if (cell.isNotEmpty) {
        p.moveTo(cell[0].dx, cell[0].dy);
        for (int k = 1; k < cell.length; k++) {
          p.lineTo(cell[k].dx, cell[k].dy);
        }
        p.close();
      }
      paths.add(p);
    }

    _cachedDistrictCells[key] = paths;
    return paths;
  }

  static List<Offset> _clipPolyHalfPlane(List<Offset> poly, Offset p1, Offset p2) {
    final midX = (p1.dx + p2.dx) / 2;
    final midY = (p1.dy + p2.dy) / 2;
    final dirX = p2.dx - p1.dx;
    final dirY = p2.dy - p1.dy;

    bool isInside(Offset p) {
      return (p.dx - midX) * dirX + (p.dy - midY) * dirY <= 0;
    }

    Offset intersection(Offset a, Offset b) {
      final d = (b.dx - a.dx) * dirX + (b.dy - a.dy) * dirY;
      if (d.abs() < 1e-7) return a;
      final t = ((midX - a.dx) * dirX + (midY - a.dy) * dirY) / d;
      return Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
    }

    final out = <Offset>[];
    if (poly.isEmpty) return out;

    for (int i = 0; i < poly.length; i++) {
      final cur = poly[i];
      final prev = poly[(i + poly.length - 1) % poly.length];
      final curIn = isInside(cur);
      final prevIn = isInside(prev);

      if (curIn) {
        if (!prevIn) {
          out.add(intersection(prev, cur));
        }
        out.add(cur);
      } else if (prevIn) {
        out.add(intersection(prev, cur));
      }
    }
    return out;
  }

  // =========================================================================
  // 🏡 35 CITIZEN HABIT PLOTS (CADASTRAL PARCEL WALLS, VILLAS & COURTYARDS)
  // Strictly on green land! Every citizen has their own demarcated boundary wall (ചുറ്റുമതിൽ),
  // private lawn, architectural hipped villa roof, driveway with parked car,
  // swimming pool with deck & beach umbrella, garden gazebo, and 90-day progression!
  // =========================================================================
  // =========================================================================
  // 👥 AUTHENTIC CITIZEN NAMES (NO "#Plot 7", REAL HUMAN NAMES ON SIGNBOARDS)
  // =========================================================================
  static const List<String> fallbackCitizenNames = [
    'Anas', 'Sneha', 'Rahul', 'Fathima', 'Arjun',
    'Diya', 'Nihal', 'Ananya', 'Rohan', 'Meera',
    'Aadithya', 'Farhan', 'Kavya', 'Gokul', 'Hiba',
    'Vishnu', 'Devika', 'Adil', 'Pooja', 'Aswin',
    'Riya', 'Salman', 'Malavika', 'Sanjay', 'Shahana',
    'Akshay', 'Archana', 'Naveen', 'Keerthi', 'Bilal',
    'Gopika', 'Sreerag', 'Amina', 'Midhun', 'Haritha',
  ];

  static String getCitizenDisplayName(CitizenPlot plot) {
    final raw = plot.userName.trim();
    if (raw.isNotEmpty &&
        !raw.toLowerCase().startsWith('plot #') &&
        !raw.toLowerCase().startsWith('empty_') &&
        !raw.toLowerCase().startsWith('vacant_')) {
      return raw;
    }
    final idx = (plot.plotNumber - 1).clamp(0, fallbackCitizenNames.length - 1);
    return fallbackCitizenNames[idx];
  }

  static Offset getHousePlacementOffset(int plotNumber) {
    final int variation = (plotNumber * 7) % 8;
    switch (variation) {
      case 0:
        return Offset.zero; // Natural center
      case 1:
        return const Offset(3.5, -3.0); // North-east nook
      case 2:
        return const Offset(-3.5, 2.5); // South-west nook
      case 3:
        return const Offset(3.5, 1.0); // East side
      case 4:
        return const Offset(-3.5, -1.2); // West side
      case 5:
        return const Offset(-2.5, -3.0); // North-west nook
      case 6:
        return const Offset(2.0, 3.0); // South-east nook
      case 7:
      default:
        return const Offset(-1.5, 2.5); // South nook
    }
  }

  // =========================================================================
  // 11. 18 ARCHITECTURAL CITIZEN PLOTS (OCCUPIED, PRE-BOOKED & VACANT '+')
  // =========================================================================
  void _drawCitizenPlots(Canvas canvas) {
    final List<Offset> positions = get35PlotCoordinates(island.shapeStyle);
    final int count = math.min(PoketCosmosAllocationService.maxPlotsPerIsland, positions.length);

    for (int i = 0; i < count; i++) {
      final pos = positions[i];
      final plotNumber = i + 1;
      final isSel = selectedPlotNumber == plotNumber;

      // 1. Check if occupied by a citizen
      CitizenPlot? citizenPlot;
      for (final p in plots) {
        if (p.plotNumber == plotNumber) {
          citizenPlot = p;
          break;
        }
      }

      // 2. Check if pre-booked for 5 hours
      final reservation = reservations[plotNumber];
      final isPreBooked = reservation != null && !reservation.isExpired;

      final plotRot = getPlotFacingAngle(island.shapeStyle, i);
      final houseOffset = getHousePlacementOffset(plotNumber);
      final housePos = pos + houseOffset;
      final parcelRect = Rect.fromCenter(center: housePos, width: 34.0, height: 28.0);

      if (citizenPlot != null) {
        // 🏡 Render full architectural compound
        final day = citizenPlot.day;
        canvas.save();
        canvas.translate(housePos.dx, housePos.dy);
        canvas.rotate(plotRot);
        canvas.scale(0.28);
        canvas.translate(-housePos.dx, -housePos.dy);

        _drawYardTreeClusters(canvas, parcelRect, plotNumber);
        if (day >= 20) {
          _drawDrivewayAndCar(canvas, parcelRect, day, plotNumber);
        }
        if (day >= 50) {
          _drawSwimmingPoolAndDeck(canvas, parcelRect, day, plotNumber);
        } else if (day >= 12) {
          _drawGardenGazebo(canvas, parcelRect, day);
        }
        _drawWalkwayPaths(canvas, parcelRect, housePos, day);
        _drawArchitecturalRoof(canvas, housePos, day, isSel, plotNumber);
        _drawPrivateYardAnimalsAndItems(canvas, parcelRect, day, plotNumber);
        _drawEstateNameBoard(canvas, parcelRect, citizenPlot, isSel);

        canvas.restore();
      } else if (isPreBooked) {
        // ⏳ Render 5-Hour Animated Rotating Countdown Timer Ring
        _drawPreBookedParcel(canvas, housePos, parcelRect, plotRot, reservation, isSel);
      } else {
        // ➕ Render Vacant Plot with center pulsing Plus (+) icon
        _drawVacantParcelWithPlus(canvas, housePos, parcelRect, plotRot, plotNumber, isSel);
      }

      // Golden Selection Beacon Aura
      if (isSel) {
        canvas.drawCircle(
          housePos,
          10.5,
          Paint()
            ..color = const Color(0xFFFFD700).withValues(alpha: 0.28)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          housePos,
          10.5,
          Paint()
            ..color = const Color(0xFFFFD700)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
      }
    }
  }

  // ➕ Vacant Parcel with Pulsing Center PLUS Button
  void _drawVacantParcelWithPlus(Canvas canvas, Offset housePos, Rect parcelRect, double plotRot, int plotNumber, bool isSel) {
    canvas.save();
    canvas.translate(housePos.dx, housePos.dy);
    canvas.rotate(plotRot);

    // 1. Soft turf base harmonized with the planetary biome
    Color turfColor;
    Color borderColor;

    switch (colonyType) {
      case CelestialColonyType.moon:
        turfColor = const Color(0xFF475569);
        borderColor = const Color(0xFF94A3B8);
        break;
      case CelestialColonyType.mars:
        turfColor = const Color(0xFF9A3412);
        borderColor = const Color(0xFFEA580C);
        break;
      case CelestialColonyType.jupiter:
        turfColor = const Color(0xFFB45309);
        borderColor = const Color(0xFFF59E0B);
        break;
      case CelestialColonyType.saturn:
        turfColor = const Color(0xFFCA8A04);
        borderColor = const Color(0xFFFCD34D);
        break;
      case CelestialColonyType.europa:
        turfColor = const Color(0xFF0284C7);
        borderColor = const Color(0xFF7DD3FC);
        break;
      case CelestialColonyType.venus:
        turfColor = const Color(0xFFB45309);
        borderColor = const Color(0xFFFBBF24);
        break;
      case CelestialColonyType.titan:
        turfColor = const Color(0xFF047857);
        borderColor = const Color(0xFF10B981);
        break;
      case CelestialColonyType.pluto:
        turfColor = const Color(0xFFA855F7);
        borderColor = const Color(0xFFC084FC);
        break;
      case CelestialColonyType.neptune:
        turfColor = const Color(0xFF2563EB);
        borderColor = const Color(0xFF60A5FA);
        break;
      case CelestialColonyType.earth:
        turfColor = const Color(0xFF15803D);
        borderColor = const Color(0xFF4ADE80);
        break;
    }

    final turfRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 28.0, height: 22.0),
      const Radius.circular(5.0),
    );
    final turfPaint = Paint()
      ..color = turfColor.withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(turfRRect, turfPaint);

    final borderPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;
    canvas.drawRRect(turfRRect, borderPaint);

    // 2. Small stone path leading into center
    final pathPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.35)
      ..strokeWidth = 1.6;
    canvas.drawLine(const Offset(0, 11), const Offset(0, 3.5), pathPaint);

    // 3. Center Glowing PLUS Button (Circle with +)
    final pulse = math.sin(timeSeconds * 3.5 + plotNumber) * 0.12 + 1.0;
    final btnRadius = 4.8 * pulse;

    // Glowing aura
    canvas.drawCircle(
      Offset.zero,
      btnRadius + 2.0,
      Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.22),
    );

    // Center button background
    canvas.drawCircle(
      Offset.zero,
      btnRadius,
      Paint()..color = const Color(0xFF059669),
    );

    canvas.drawCircle(
      Offset.zero,
      btnRadius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    // Crisp white Plus (+) icon lines
    final plusPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    const plusSize = 2.4;
    canvas.drawLine(const Offset(-plusSize, 0), const Offset(plusSize, 0), plusPaint);
    canvas.drawLine(const Offset(0, -plusSize), const Offset(0, plusSize), plusPaint);

    // 4. Subtle "PLOT #{plotNumber}" label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'PLOT #$plotNumber',
        style: const TextStyle(
          color: Color(0xFF86EFAC),
          fontSize: 3.2,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -8.5));

    canvas.restore();
  }

  // ⏳ Pre-Booked Parcel with Animated Rotating Countdown Timer Ring
  void _drawPreBookedParcel(Canvas canvas, Offset housePos, Rect parcelRect, double plotRot, NeighborReservationPass pass, bool isSel) {
    canvas.save();
    canvas.translate(housePos.dx, housePos.dy);
    canvas.rotate(plotRot);

    // 1. Gold/Amber reserved parcel base
    final turfRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 28.0, height: 22.0),
      const Radius.circular(5.0),
    );
    final turfPaint = Paint()
      ..color = const Color(0xFFB45309).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(turfRRect, turfPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas.drawRRect(turfRRect, borderPaint);

    // 2. Animated Rotating Countdown Timer Ring
    final ringRadius = 5.8;
    canvas.save();
    canvas.rotate(timeSeconds * 1.8);
    final ringPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: ringRadius),
      0,
      math.pi * 1.25,
      false,
      ringPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: ringRadius),
      math.pi * 1.45,
      math.pi * 0.35,
      false,
      ringPaint..color = const Color(0xFF38BDF8),
    );
    canvas.restore();

    // 3. Center Badge with ⏳ icon and remaining time
    canvas.drawCircle(
      Offset.zero,
      4.2,
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawCircle(
      Offset.zero,
      4.2,
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );

    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '⏳',
        style: TextStyle(fontSize: 4.2),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(canvas, Offset(-iconPainter.width / 2, -iconPainter.height / 2));

    // Remaining time label (e.g. "4h 32m")
    final int mins = pass.minutesRemaining;
    final String timeStr = mins >= 60 ? '${mins ~/ 60}h ${mins % 60}m' : '${mins}m';
    final timePainter = TextPainter(
      text: TextSpan(
        text: timeStr,
        style: const TextStyle(
          color: Color(0xFFFFE082),
          fontSize: 2.9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    timePainter.paint(canvas, Offset(-timePainter.width / 2, 7.5));

    canvas.restore();
  }

  // 5. Private Yard Animals & Outdoor Items (Sheep, horses, pets & garden benches)
  void _drawPrivateYardAnimalsAndItems(Canvas canvas, Rect parcelRect, int day, int plotNumber) {
    // Private Yard Animal (Drifts peacefully in their private garden)
    final animT = timeSeconds * 0.7 + plotNumber;
    final driftX = math.cos(animT) * 1.5;
    final driftY = math.sin(animT) * 1.1;

    if (day >= 65) {
      // 🐑 / 🐴 Grand Meadow Animal: Private Grazing Sheep or Pony
      final isHorse = (plotNumber % 2 == 0);
      final animalCenter = Offset(parcelRect.left + 6.0 + driftX, parcelRect.bottom - 7.0 + driftY);

      // Animal shadow
      canvas.drawOval(
        Rect.fromCenter(center: animalCenter.translate(0.3, 0.5), width: isHorse ? 4.8 : 3.6, height: 2.2),
        Paint()..color = Colors.black26,
      );

      if (isHorse) {
        // Chestnut Brown Pony / Foal
        final horseBody = Paint()..color = const Color(0xFF78350F);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: animalCenter, width: 4.2, height: 2.4),
            const Radius.circular(1.0),
          ),
          horseBody,
        );
        // Head / Neck
        canvas.drawCircle(animalCenter.translate(-1.8, -1.0), 1.1, horseBody);
        // Mane
        canvas.drawCircle(animalCenter.translate(-1.3, -1.2), 0.6, Paint()..color = const Color(0xFF451A03));
      } else {
        // Fluffy White Meadow Sheep
        final sheepWool = Paint()..color = const Color(0xFFF8FAFC);
        canvas.drawCircle(animalCenter, 1.8, sheepWool);
        canvas.drawCircle(animalCenter.translate(-1.2, 0.2), 1.2, sheepWool);
        // Dark head & ears
        canvas.drawCircle(animalCenter.translate(-2.0, -0.4), 0.85, Paint()..color = const Color(0xFF334155));
      }
    } else {
      // 🐕 / 🐈 Friendly Yard Pet: Dog or Cat lounging in lawn
      final petPos = Offset(parcelRect.left + 6.0 + driftX, parcelRect.bottom - 7.0 + driftY);
      final isDog = (plotNumber % 2 == 0);
      final petColor = isDog ? const Color(0xFFD97706) : const Color(0xFFE2E8F0);

      // Pet shadow
      canvas.drawCircle(petPos.translate(0.3, 0.4), 1.3, Paint()..color = Colors.black26);
      // Pet body
      canvas.drawCircle(petPos, 1.2, Paint()..color = petColor);
      // Pet head
      canvas.drawCircle(petPos.translate(0.6, -0.4), 0.8, Paint()..color = petColor);
    }

    // Garden Bench / Patio Dining Table (for day >= 15)
    if (day >= 15) {
      final benchPos = Offset(parcelRect.right - 5.5, parcelRect.top + 5.5);
      final benchRect = Rect.fromCenter(center: benchPos, width: 5.2, height: 2.4);
      canvas.drawRect(benchRect.shift(const Offset(0.3, 0.4)), Paint()..color = Colors.black12);
      canvas.drawRRect(
        RRect.fromRectAndRadius(benchRect, const Radius.circular(0.6)),
        Paint()..color = const Color(0xFFB45309),
      );
    }
  }


  // 2. Driveway & Parked Vehicle (കാർപോർച്ചും വാഹനങ്ങളും - വ്യത്യസ്ത കാറുകൾ)
  void _drawDrivewayAndCar(Canvas canvas, Rect parcelRect, int day, int plotNumber) {
    // Driveway on the left side of parcel
    final drivewayRect = Rect.fromLTWH(parcelRect.left + 2.0, parcelRect.top + 3.0, 9.5, 22.0);

    // Paved cobblestone driveway base
    final drivewayPaint = Paint()..color = const Color(0xFF94A3B8).withValues(alpha: 0.85);
    canvas.drawRRect(RRect.fromRectAndRadius(drivewayRect, const Radius.circular(1.5)), drivewayPaint);

    // Cobblestone / paving joints
    final cobblePaint = Paint()
      ..color = const Color(0xFF64748B).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (double dy = drivewayRect.top + 2.8; dy < drivewayRect.bottom; dy += 2.8) {
      canvas.drawLine(Offset(drivewayRect.left, dy), Offset(drivewayRect.right, dy), cobblePaint);
    }

    // Parked Car on Driveway (For Day >= 25)
    if (day >= 25) {
      final carCenter = Offset(drivewayRect.center.dx, drivewayRect.top + 10.0);

      // Car undercarriage shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: carCenter.translate(0.5, 0.6), width: 6.8, height: 11.2),
          const Radius.circular(1.8),
        ),
        Paint()..color = Colors.black45,
      );

      // Diverse Car Palette (Blue Sedan, Crimson Coupe, Silver Luxury SUV, Emerald Vintage, Gold GT)
      final carPalettes = [
        const Color(0xFF2563EB), // Royal Blue Sedan (Image 2!)
        const Color(0xFFDC2626), // Crimson Sports Coupe
        const Color(0xFFE2E8F0), // Platinum Silver Luxury SUV
        const Color(0xFF059669), // Emerald Vintage Coupe
        const Color(0xFFD97706), // Sovereign Gold GT
      ];
      final Color carColor = day >= 90
          ? const Color(0xFFD97706)
          : carPalettes[(plotNumber * 3 + day) % carPalettes.length];

      // Car Body
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: carCenter, width: 6.0, height: 10.2),
          const Radius.circular(1.6),
        ),
        Paint()..color = carColor,
      );

      // Windshield & Rear Window (Dark glass with blue reflection)
      final glassPaint = Paint()..color = const Color(0xFF0F172A);
      // Front windshield
      canvas.drawRect(Rect.fromCenter(center: carCenter.translate(0, -1.8), width: 4.6, height: 1.4), glassPaint);
      // Rear window
      canvas.drawRect(Rect.fromCenter(center: carCenter.translate(0, 2.2), width: 4.6, height: 1.2), glassPaint);

      // Car Roof Block
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: carCenter.translate(0, 0.2), width: 4.6, height: 3.2),
          const Radius.circular(0.8),
        ),
        Paint()..color = carColor,
      );

      // Side mirrors
      canvas.drawCircle(carCenter.translate(-2.9, -1.8), 0.5, Paint()..color = carColor);
      canvas.drawCircle(carCenter.translate(2.9, -1.8), 0.5, Paint()..color = carColor);

      // Headlights
      final lightPaint = Paint()..color = const Color(0xFFFEF08A);
      canvas.drawCircle(carCenter.translate(-2.0, -4.8), 0.55, lightPaint);
      canvas.drawCircle(carCenter.translate(2.0, -4.8), 0.55, lightPaint);
    }
  }

  // 3. Swimming Pool with Sun Deck & Beach Umbrella (സ്വിമ്മിംഗ് പൂളും ഡെക്കും)
  void _drawSwimmingPoolAndDeck(Canvas canvas, Rect parcelRect, int day, int plotNumber) {
    final poolCenter = Offset(parcelRect.right - 8.5, parcelRect.bottom - 8.5);
    final deckRect = Rect.fromCenter(center: poolCenter, width: 13.5, height: 11.5);

    // Warm sandstone / teak wood sun deck
    final deckColors = [
      const Color(0xFFFDE68A), // Warm sandstone
      const Color(0xFFE2E8F0), // White limestone
      const Color(0xFFD97706).withValues(alpha: 0.75), // Teak timber
    ];
    final deckColor = deckColors[plotNumber % deckColors.length];

    canvas.drawRRect(
      RRect.fromRectAndRadius(deckRect, const Radius.circular(2.2)),
      Paint()..color = deckColor,
    );

    // Pool Basin (Kidney or rounded rectangle)
    final poolRect = Rect.fromCenter(center: poolCenter.translate(-1.8, 0), width: 8.5, height: 7.5);
    // Deep blue bottom gradient
    canvas.drawRRect(
      RRect.fromRectAndRadius(poolRect, const Radius.circular(2.5)),
      Paint()..color = const Color(0xFF0284C7),
    );
    // Azure water surface
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: poolCenter.translate(-1.8, 0), width: 7.5, height: 6.5),
        const Radius.circular(2.0),
      ),
      Paint()..color = const Color(0xFF38BDF8),
    );

    // Water ripple / specular glint
    final ripplePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = 0.65
      ..style = PaintingStyle.stroke;
    canvas.drawLine(poolRect.topLeft.translate(1.8, 2.2), poolRect.topLeft.translate(3.8, 2.2), ripplePaint);

    // 🐟 LIVING SWIMMING KOI FISH (Visible upon Deep Zoom!)
    // Calico orange & golden Koi with tail wiggle, fins, and micro eye dots!
    final poolWaterCenter = poolCenter.translate(-1.8, 0);
    // Fish 1: Calico Orange-White Koi swimming in an elliptical loop
    final fishAngle1 = timeSeconds * 1.8 + plotNumber * 1.5;
    final fish1Pos = poolWaterCenter.translate(
      math.cos(fishAngle1) * 1.8,
      math.sin(fishAngle1) * 1.3,
    );
    _drawDetailedKoiFish(canvas, fish1Pos, fishAngle1 + math.pi / 2, const Color(0xFFEA580C), const Color(0xFFFED7AA));

    // Fish 2: Golden / Platinum Koi swimming in counter-arc (for higher tiers)
    if (day >= 65) {
      final fishAngle2 = -timeSeconds * 1.4 + plotNumber * 2.3;
      final fish2Pos = poolWaterCenter.translate(
        math.cos(fishAngle2) * 1.4,
        math.sin(fishAngle2) * 1.1,
      );
      _drawDetailedKoiFish(canvas, fish2Pos, fishAngle2 - math.pi / 2, const Color(0xFFEAB308), Colors.white);
    }

    // White Sun Loungers (2 side-by-side sunbeds)
    final bedPaint = Paint()..color = Colors.white;
    final bed1 = Rect.fromLTWH(poolCenter.dx + 3.2, poolCenter.dy - 3.8, 1.8, 3.2);
    final bed2 = Rect.fromLTWH(poolCenter.dx + 3.2, poolCenter.dy + 0.6, 1.8, 3.2);
    canvas.drawRRect(RRect.fromRectAndRadius(bed1, const Radius.circular(0.4)), bedPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(bed2, const Radius.circular(0.4)), bedPaint);

    // Striped Beach Umbrella (Red & White, Yellow & White, or Aqua & White segments)
    final umbrellaCenter = Offset(poolCenter.dx + 4.2, poolCenter.dy + 4.4);
    // Umbrella shadow
    canvas.drawCircle(umbrellaCenter.translate(0.5, 0.7), 2.4, Paint()..color = Colors.black26);

    // Alternating stripe colors
    final umbrellaThemes = [
      const Color(0xFFEF4444), // Crimson & White
      const Color(0xFFEAB308), // Gold & White
      const Color(0xFF0284C7), // Azure & White
    ];
    final stripeColor = umbrellaThemes[plotNumber % umbrellaThemes.length];
    final whitePaint = Paint()..color = Colors.white;
    final stripePaint = Paint()..color = stripeColor;

    for (int s = 0; s < 6; s++) {
      final startAngle = s * math.pi / 3;
      canvas.drawArc(
        Rect.fromCircle(center: umbrellaCenter, radius: 2.3),
        startAngle,
        math.pi / 3,
        true,
        s % 2 == 0 ? stripePaint : whitePaint,
      );
    }
    // Umbrella apex finial
    canvas.drawCircle(umbrellaCenter, 0.5, Paint()..color = Colors.white);
  }

  // 🐟 Detailed Animated Swimming Koi Fish with Eyes, Fins & Wagging Tail (Deep Zoom!)
  void _drawDetailedKoiFish(Canvas canvas, Offset pos, double heading, Color primaryColor, Color patternColor) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(heading);

    // Torpedo Body (streamlined carp shape)
    final fishBodyPath = Path();
    fishBodyPath.moveTo(0, -1.2); // snout
    fishBodyPath.cubicTo(0.65, -0.6, 0.65, 0.5, 0.25, 1.1); // right flank
    fishBodyPath.lineTo(-0.25, 1.1); // tail peduncle
    fishBodyPath.cubicTo(-0.65, 0.5, -0.65, -0.6, 0, -1.2); // left flank
    fishBodyPath.close();

    // Body base
    canvas.drawPath(fishBodyPath, Paint()..color = primaryColor);

    // Calico dorsal pattern patch
    canvas.drawCircle(const Offset(0.08, -0.15), 0.35, Paint()..color = patternColor.withValues(alpha: 0.9));

    // Tail fin (gently wagging with high-frequency sine wave)
    final wag = math.sin(timeSeconds * 7.5 + pos.dx * 8.0) * 0.35;
    final tailPath = Path();
    tailPath.moveTo(0, 1.05);
    tailPath.lineTo(-0.45 + wag, 1.75);
    tailPath.quadraticBezierTo(wag, 1.45, 0.45 + wag, 1.75);
    tailPath.close();
    canvas.drawPath(tailPath, Paint()..color = primaryColor.withValues(alpha: 0.8));

    // Pectoral side fins (translucent fans)
    final finPaint = Paint()..color = Colors.white.withValues(alpha: 0.65);
    canvas.drawOval(Rect.fromCenter(center: const Offset(-0.6, -0.2), width: 0.5, height: 0.25), finPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0.6, -0.2), width: 0.5, height: 0.25), finPaint);

    // Micro-detailed Koi Eye Dots (Clearly visible when user pinches to zoom in!)
    final eyeWhite = Paint()..color = Colors.white;
    final eyePupil = Paint()..color = Colors.black;

    // Left eye (sclera + black pupil)
    canvas.drawCircle(const Offset(-0.35, -0.75), 0.18, eyeWhite);
    canvas.drawCircle(const Offset(-0.35, -0.75), 0.10, eyePupil);

    // Right eye (sclera + black pupil)
    canvas.drawCircle(const Offset(0.35, -0.75), 0.18, eyeWhite);
    canvas.drawCircle(const Offset(0.35, -0.75), 0.10, eyePupil);

    canvas.restore();
  }

  // 4. Garden Gazebo (Yellow pitched roof like Image 2)
  void _drawGardenGazebo(Canvas canvas, Rect parcelRect, int day) {
    final gazeboCenter = Offset(parcelRect.right - 6.5, parcelRect.bottom - 6.5);

    // Gazebo shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: gazeboCenter.translate(0.5, 0.6), width: 6.8, height: 6.8),
        const Radius.circular(1.0),
      ),
      Paint()..color = Colors.black38,
    );

    // Yellow pitched roof body (Image 2)
    final gazeboRect = Rect.fromCenter(center: gazeboCenter, width: 6.2, height: 6.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(gazeboRect, const Radius.circular(0.8)),
      Paint()..color = const Color(0xFFEAB308),
    );

    // Pyramid hip ridgelines to center
    final gazRidge = Paint()
      ..color = const Color(0xFFFEF08A)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;
    canvas.drawLine(gazeboRect.topLeft, gazeboRect.bottomRight, gazRidge);
    canvas.drawLine(gazeboRect.topRight, gazeboRect.bottomLeft, gazRidge);
  }

  // 5. Connecting Paved Footpaths (നടപ്പാതകൾ)
  void _drawWalkwayPaths(Canvas canvas, Rect parcelRect, Offset housePos, int day) {
    final pathPaint = Paint()
      ..color = const Color(0xFFFEF08A).withValues(alpha: 0.85) // Warm sandstone path
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Path from driveway to front entrance
    final p1 = Path();
    p1.moveTo(parcelRect.left + 11.5, parcelRect.top + 10.0);
    p1.lineTo(housePos.dx - 3.5, parcelRect.top + 10.0);
    p1.lineTo(housePos.dx - 3.5, housePos.dy);
    canvas.drawPath(p1, pathPaint);

    // Path to pool / garden gazebo
    if (day >= 20) {
      final p2 = Path();
      p2.moveTo(housePos.dx + 2.0, housePos.dy + 4.0);
      p2.lineTo(housePos.dx + 2.0, parcelRect.bottom - 8.5);
      p2.lineTo(parcelRect.right - 14.5, parcelRect.bottom - 8.5);
      canvas.drawPath(p2, pathPaint);
    }
  }

  // 6. Estate Entrance Nameplate Signboard on the side (യൂസർ നെയിം ഒരു സൈഡിൽ കൊണ്ട് ഇടാം)
  void _drawEstateNameBoard(Canvas canvas, Rect parcelRect, CitizenPlot plot, bool isSel) {
    // Placed neatly on the side of the property entrance
    final boardCenter = Offset(parcelRect.left + 6.0, parcelRect.bottom + 1.2);
    final boardRect = Rect.fromCenter(center: boardCenter, width: 22.0, height: 5.6);

    // Signpost wooden/slate legs
    final postPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 0.8;
    canvas.drawLine(Offset(boardRect.left + 2.0, boardRect.bottom), Offset(boardRect.left + 2.0, boardRect.bottom + 2.4), postPaint);
    canvas.drawLine(Offset(boardRect.right - 2.0, boardRect.bottom), Offset(boardRect.right - 2.0, boardRect.bottom + 2.4), postPaint);

    // Signboard shadow & body
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect.translate(0.3, 0.4), const Radius.circular(1.0)),
      Paint()..color = Colors.black38,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(1.0)),
      Paint()..color = isSel ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
    );
    // Gold/White border
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(1.0)),
      Paint()
        ..color = isSel ? const Color(0xFFFFD700) : const Color(0xFF94A3B8).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSel ? 0.9 : 0.55,
    );

    // Real Citizen Name Text on Estate Board (No "#Plot 7", genuine names on signboards)
    final displayName = getCitizenDisplayName(plot);
    final label = displayName.length > 12 ? '${displayName.substring(0, 12)}..' : displayName;
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: isSel ? const Color(0xFFFFD700) : Colors.white,
          fontSize: 3.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(boardCenter.dx - tp.width / 2, boardCenter.dy - tp.height / 2));
  }

  // 1. Clustered Round Trees on Yard Corners (Images 1 & 3)
  void _drawYardTreeClusters(Canvas canvas, Rect parcelRect, int plotNumber) {
    final treePaints = [
      (
        shadow: const Color(0xFF0F3E22).withValues(alpha: 0.35),
        body: const Color(0xFF15803D),
        highlight: const Color(0xFF4ADE80).withValues(alpha: 0.85),
      ),
      (
        shadow: const Color(0xFF064E3B).withValues(alpha: 0.35),
        body: const Color(0xFF047857),
        highlight: const Color(0xFF34D399).withValues(alpha: 0.85),
      ),
      (
        shadow: const Color(0xFF14532D).withValues(alpha: 0.35),
        body: const Color(0xFF16A34A),
        highlight: const Color(0xFF86EFAC).withValues(alpha: 0.85),
      ),
    ];

    // Northeast corner tree cluster
    final neBase = Offset(parcelRect.right - 4.5, parcelRect.top + 4.5);
    final theme1 = treePaints[plotNumber % treePaints.length];
    _drawLayeredTreeCircle(canvas, neBase, 3.2, theme1);
    _drawLayeredTreeCircle(canvas, neBase.translate(-2.2, 1.2), 2.4, theme1);

    // Southwest corner tree cluster (or hedgerow bushes)
    final swBase = Offset(parcelRect.left + 4.0, parcelRect.bottom - 4.0);
    final theme2 = treePaints[(plotNumber + 1) % treePaints.length];
    _drawLayeredTreeCircle(canvas, swBase, 2.8, theme2);
    _drawLayeredTreeCircle(canvas, swBase.translate(1.8, -1.5), 2.2, theme2);
  }

  void _drawLayeredTreeCircle(Canvas canvas, Offset center, double radius, ({Color shadow, Color body, Color highlight}) theme) {
    // Tree drop shadow
    canvas.drawCircle(center.translate(0.6, 0.8), radius, Paint()..color = theme.shadow);
    // Tree canopy body
    canvas.drawCircle(center, radius, Paint()..color = theme.body);
    // Tree sunlit inner highlight circle
    canvas.drawCircle(center.translate(-radius * 0.25, -radius * 0.25), radius * 0.60, Paint()..color = theme.highlight);
  }

  // 8. Architectural Top-Down Villa Roof with 90-Day Progression & Diverse Colors
  void _drawArchitecturalRoof(Canvas canvas, Offset pos, int day, bool isSel, int plotNumber) {
    // 5 Distinct Roof Tile Palettes across the 35 houses so adjacent houses never look identical!
    final colorVariant = (plotNumber * 7 + day) % 5;
    Color roofBase;
    Color ridgeHighlight;

    if (isSel) {
      roofBase = const Color(0xFFFFD700);
      ridgeHighlight = const Color(0xFFFFF9C4);
    } else {
      switch (colorVariant) {
        case 0: // Classic Terracotta Orange (Images 1, 2, 3)
          roofBase = day >= 90 ? const Color(0xFFEA580C) : (day >= 60 ? const Color(0xFFF97316) : const Color(0xFFFB923C));
          ridgeHighlight = const Color(0xFFFFEDD5);
          break;
        case 1: // Coastal Slate Teal
          roofBase = day >= 90 ? const Color(0xFF0F766E) : (day >= 60 ? const Color(0xFF0D9488) : const Color(0xFF14B8A6));
          ridgeHighlight = const Color(0xFFCCFBF1);
          break;
        case 2: // Spanish Burgundy / Crimson
          roofBase = day >= 90 ? const Color(0xFF991B1B) : (day >= 60 ? const Color(0xFFB91C1C) : const Color(0xFFDC2626));
          ridgeHighlight = const Color(0xFFFEE2E2);
          break;
        case 3: // Alpine Cobalt Blue
          roofBase = day >= 90 ? const Color(0xFF1E3A8A) : (day >= 60 ? const Color(0xFF1D4ED8) : const Color(0xFF2563EB));
          ridgeHighlight = const Color(0xFFDBEAFE);
          break;
        case 4: // Amber Gold Manor
        default:
          roofBase = day >= 90 ? const Color(0xFFB45309) : (day >= 60 ? const Color(0xFFD97706) : const Color(0xFFF59E0B));
          ridgeHighlight = const Color(0xFFFEF3C7);
          break;
      }
    }

    if (day <= 10) {
      // -------------------------------------------------------------
      // LEVEL 1 (Day 1 - 10): Compact Starter Cottage (Image 3)
      // -------------------------------------------------------------
      final roofRect = Rect.fromCenter(center: pos, width: 10.0, height: 7.5);
      _drawFacetedHippedRoof(canvas, roofRect, roofBase, ridgeHighlight);

      // Single Chimney with subtle smoke
      _drawChimney(canvas, pos.translate(2.4, -1.8));

    } else if (day <= 25) {
      // -------------------------------------------------------------
      // LEVEL 2 (Day 11 - 25): Suburban Ranch House with Skylight (Image 2)
      // -------------------------------------------------------------
      final roofRect = Rect.fromCenter(center: pos, width: 13.5, height: 9.0);
      _drawFacetedHippedRoof(canvas, roofRect, roofBase, ridgeHighlight);

      // 1 Skylight Window on sunny slope (Image 2)
      _drawSkylight(canvas, pos.translate(-1.0, -2.2));

      // Chimney
      _drawChimney(canvas, pos.translate(3.6, -2.0));

    } else if (day <= 50) {
      // -------------------------------------------------------------
      // LEVEL 3 (Day 26 - 50): L-Shaped Executive Villa (Images 1 & 2 Iconic Shape!)
      // -------------------------------------------------------------
      final isLeftWing = (plotNumber % 2 == 0);
      final mainRect = Rect.fromCenter(center: pos.translate(1.0, -1.5), width: 15.0, height: 8.0);
      final wingRect = Rect.fromCenter(
        center: pos.translate(isLeftWing ? -3.0 : 5.0, 3.2),
        width: 7.0,
        height: 11.0,
      );

      // Draw both wings with 3D faceted hipped roofs
      _drawFacetedHippedRoof(canvas, mainRect, roofBase, ridgeHighlight);
      _drawFacetedHippedRoof(canvas, wingRect, roofBase, ridgeHighlight);

      // 2 Blue Skylight Windows on main roof (Image 2)
      _drawSkylight(canvas, mainRect.center.translate(0.5, -2.0));
      _drawSkylight(canvas, mainRect.center.translate(3.5, -2.0));

      // Chimney
      _drawChimney(canvas, mainRect.center.translate(4.8, 1.8));

    } else if (day <= 85) {
      // -------------------------------------------------------------
      // LEVEL 4 (Day 51 - 85): Luxury Multi-Wing Estate Compound (Images 1 & 2)
      // -------------------------------------------------------------
      final mainRect = Rect.fromCenter(center: pos.translate(0.0, -2.0), width: 17.0, height: 8.5);
      final westWing = Rect.fromCenter(center: pos.translate(-4.5, 3.2), width: 8.0, height: 10.5);
      final eastPorch = Rect.fromCenter(center: pos.translate(5.0, 1.8), width: 6.5, height: 6.5);

      _drawFacetedHippedRoof(canvas, mainRect, roofBase, ridgeHighlight);
      _drawFacetedHippedRoof(canvas, westWing, roofBase, ridgeHighlight);
      _drawFacetedHippedRoof(canvas, eastPorch, roofBase, ridgeHighlight);

      // 3 Blue Skylights (Image 2)
      _drawSkylight(canvas, mainRect.center.translate(-1.5, -2.2));
      _drawSkylight(canvas, mainRect.center.translate(1.8, -2.2));
      _drawSkylight(canvas, mainRect.center.translate(5.0, -2.2));

      // Dual Chimneys
      _drawChimney(canvas, mainRect.center.translate(-5.5, 1.8));
      _drawChimney(canvas, mainRect.center.translate(6.0, 1.8));

    } else {
      // -------------------------------------------------------------
      // LEVEL 5 (Day 86 - 90 / Max Streak): Sovereign Grand Palace Manor (U-Shape)
      // -------------------------------------------------------------
      final centerHall = Rect.fromCenter(center: pos.translate(0, -3.5), width: 19.0, height: 9.0);
      final leftWing = Rect.fromCenter(center: pos.translate(-6.0, 2.5), width: 7.5, height: 12.5);
      final rightWing = Rect.fromCenter(center: pos.translate(6.0, 2.5), width: 7.5, height: 12.5);

      _drawFacetedHippedRoof(canvas, centerHall, roofBase, ridgeHighlight);
      _drawFacetedHippedRoof(canvas, leftWing, roofBase, ridgeHighlight);
      _drawFacetedHippedRoof(canvas, rightWing, roofBase, ridgeHighlight);

      // 4 Cyan Skylights
      _drawSkylight(canvas, centerHall.center.translate(-3.0, -2.2));
      _drawSkylight(canvas, centerHall.center.translate(3.0, -2.2));
      _drawSkylight(canvas, leftWing.center.translate(0, 3.0));
      _drawSkylight(canvas, rightWing.center.translate(0, 3.0));

      // Dual Grand Chimneys
      _drawChimney(canvas, centerHall.center.translate(-6.5, -2.2));
      _drawChimney(canvas, centerHall.center.translate(6.5, -2.2));

      // Golden Sovereign Prestige Crest atop central ridge
      canvas.drawCircle(centerHall.center, 1.2, Paint()..color = const Color(0xFFFFD700));
    }
  }

  /// 🏛️ 3D Faceted Hipped Roof (Replicating Images 1, 2, 3 with True Top-Down Isometric Relief)
  void _drawFacetedHippedRoof(
    Canvas canvas,
    Rect rect,
    Color roofBase,
    Color ridgeHighlight, {
    bool hasPatio = true,
  }) {
    // 1. Warm Sandstone / Buff Paved Terrace Base (Images 1 & 3 under the orange roof)
    if (hasPatio) {
      final patioRect = rect.inflate(2.2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(patioRect, const Radius.circular(1.6)),
        Paint()..color = const Color(0xFFFBE6C2).withValues(alpha: 0.90),
      );
    }

    // 2. Soft Drop Shadow Underneath
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(0.9, 1.1), const Radius.circular(1.2)),
      Paint()..color = Colors.black38,
    );

    // 3. Faceted Slopes & Hip Ridges
    final northSlopeColor = Color.lerp(roofBase, Colors.white, 0.20)!; // Sunlit facet
    final southSlopeColor = Color.lerp(roofBase, Colors.black, 0.20)!; // Shadowed facet
    final eastSlopeColor = Color.lerp(roofBase, Colors.black, 0.10)!;
    final westSlopeColor = roofBase;

    final ridgePaint = Paint()
      ..color = ridgeHighlight
      ..strokeWidth = 0.85
      ..style = PaintingStyle.stroke;

    if (rect.width >= rect.height) {
      // Horizontal Ridge Hipped Roof
      final double ridgeLength = (rect.width - rect.height * 0.70).clamp(1.5, rect.width * 0.75);
      final pLeft = Offset(rect.center.dx - ridgeLength / 2, rect.center.dy);
      final pRight = Offset(rect.center.dx + ridgeLength / 2, rect.center.dy);

      // North Trapezoid Slope (Sunlit)
      final northPath = Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(pRight.dx, pRight.dy)
        ..lineTo(pLeft.dx, pLeft.dy)
        ..close();
      canvas.drawPath(northPath, Paint()..color = northSlopeColor);

      // South Trapezoid Slope (Shadowed)
      final southPath = Path()
        ..moveTo(pLeft.dx, pLeft.dy)
        ..lineTo(pRight.dx, pRight.dy)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.left, rect.bottom)
        ..close();
      canvas.drawPath(southPath, Paint()..color = southSlopeColor);

      // West Triangle Hip (Left)
      final westPath = Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(pLeft.dx, pLeft.dy)
        ..lineTo(rect.left, rect.bottom)
        ..close();
      canvas.drawPath(westPath, Paint()..color = westSlopeColor);

      // East Triangle Hip (Right)
      final eastPath = Path()
        ..moveTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(pRight.dx, pRight.dy)
        ..close();
      canvas.drawPath(eastPath, Paint()..color = eastSlopeColor);

      // Ridge Lines
      canvas.drawLine(rect.topLeft, pLeft, ridgePaint);
      canvas.drawLine(rect.bottomLeft, pLeft, ridgePaint);
      canvas.drawLine(pLeft, pRight, ridgePaint);
      canvas.drawLine(rect.topRight, pRight, ridgePaint);
      canvas.drawLine(rect.bottomRight, pRight, ridgePaint);

    } else {
      // Vertical Ridge Hipped Roof
      final double ridgeLength = (rect.height - rect.width * 0.70).clamp(1.5, rect.height * 0.75);
      final pTop = Offset(rect.center.dx, rect.center.dy - ridgeLength / 2);
      final pBottom = Offset(rect.center.dx, rect.center.dy + ridgeLength / 2);

      // West Slope (Sunlit)
      final westPath = Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(pTop.dx, pTop.dy)
        ..lineTo(pBottom.dx, pBottom.dy)
        ..lineTo(rect.left, rect.bottom)
        ..close();
      canvas.drawPath(westPath, Paint()..color = northSlopeColor);

      // East Slope (Shadowed)
      final eastPath = Path()
        ..moveTo(pTop.dx, pTop.dy)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(pBottom.dx, pBottom.dy)
        ..close();
      canvas.drawPath(eastPath, Paint()..color = southSlopeColor);

      // North Triangle Hip (Top)
      final northPath = Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(pTop.dx, pTop.dy)
        ..close();
      canvas.drawPath(northPath, Paint()..color = westSlopeColor);

      // South Triangle Hip (Bottom)
      final southPath = Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(pBottom.dx, pBottom.dy)
        ..lineTo(rect.right, rect.bottom)
        ..close();
      canvas.drawPath(southPath, Paint()..color = eastSlopeColor);

      // Ridge Lines
      canvas.drawLine(rect.topLeft, pTop, ridgePaint);
      canvas.drawLine(rect.topRight, pTop, ridgePaint);
      canvas.drawLine(pTop, pBottom, ridgePaint);
      canvas.drawLine(rect.bottomLeft, pBottom, ridgePaint);
      canvas.drawLine(rect.bottomRight, pBottom, ridgePaint);
    }
  }

  // Helper: Blue Skylight Window (Cyan Glass with White Frame, Image 2)
  void _drawSkylight(Canvas canvas, Offset center) {
    final lightRect = Rect.fromCenter(center: center, width: 2.6, height: 1.8);
    // White outer frame
    canvas.drawRect(lightRect.inflate(0.3), Paint()..color = Colors.white);
    // Cyan reflective glass
    canvas.drawRect(lightRect, Paint()..color = const Color(0xFF0284C7));
    // Glass glare
    canvas.drawLine(
      lightRect.topLeft.translate(0.4, 0.4),
      lightRect.bottomRight.translate(-0.4, -0.4),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 0.4,
    );
  }

  // Helper: Architectural Chimney
  void _drawChimney(Canvas canvas, Offset center) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 1.8, height: 1.8),
        const Radius.circular(0.3),
      ),
      Paint()..color = const Color(0xFF475569),
    );
    canvas.drawCircle(center, 0.5, Paint()..color = const Color(0xFF0F172A));
  }

  // =========================================================================
  // 👑 PRESIDENTIAL CITADEL (MUS'AB SOVEREIGN APEX)
  // =========================================================================
  void _drawPresidentialCitadel(Canvas canvas) {
    // 1. Water Moat around palace
    final moatPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    canvas.drawCircle(Offset.zero, 80, moatPaint);

    // 2. Marble Quad Courtyard
    final courtyardPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 120, height: 120), const Radius.circular(18)),
      courtyardPaint,
    );

    // 3. Formal Palace Gardens (4 Green Quads)
    final gardenPaint = Paint()..color = const Color(0xFF15803D);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-50, -50, 42, 42), const Radius.circular(8)), gardenPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(8, -50, 42, 42), const Radius.circular(8)), gardenPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-50, 8, 42, 42), const Radius.circular(8)), gardenPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(8, 8, 42, 42), const Radius.circular(8)), gardenPaint);

    // 4. Central Royal Grand Palace with 5 Golden Domes
    final palaceBase = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawCircle(Offset.zero, 36, palaceBase);

    // 4 Corner Golden Domes
    final smallDomePaint = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(const Offset(-18, -18), 9.0, smallDomePaint);
    canvas.drawCircle(const Offset(18, -18), 9.0, smallDomePaint);
    canvas.drawCircle(const Offset(-18, 18), 9.0, smallDomePaint);
    canvas.drawCircle(const Offset(18, 18), 9.0, smallDomePaint);

    // Grand Central Golden Dome
    final grandDome = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset.zero, 19.0, grandDome);
    canvas.drawCircle(const Offset(-4, -4), 6.0, Paint()..color = Colors.white70);

    // 5. Helipad [H] on North Terrace
    final helipadPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawCircle(const Offset(0, -88), 16.0, helipadPaint);
    canvas.drawCircle(const Offset(0, -88), 14.0, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.0);
    final hPainter = TextPainter(
      text: const TextSpan(
        text: 'H',
        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    hPainter.paint(canvas, Offset(-hPainter.width / 2, -88 - hPainter.height / 2));

    // 6. Presidential Crown Crest Badge
    final crownPainter = TextPainter(
      text: const TextSpan(text: '👑', style: TextStyle(fontSize: 22)),
      textDirection: TextDirection.ltr,
    )..layout();
    crownPainter.paint(canvas, Offset(-crownPainter.width / 2, 42));
  }

  // =========================================================================
  // 🌴 CLUSTERED PALM TREE CANOPIES WITH REALISTIC SHADOWS (BENCHMARKS #1, #2, #3)
  // =========================================================================
  void _drawPalmTreeCanopies(Canvas canvas) {
    final List<Offset> trees = island.isPresidential
        ? [
            const Offset(-80, -65), const Offset(80, -65),
            const Offset(-80, 65), const Offset(80, 65),
            const Offset(0, 95), const Offset(-105, 0),
            const Offset(-45, -75), const Offset(45, -75),
          ]
        : [
            // Groves along pathways, shoreline perimeters, and between plots
            const Offset(-155, -55), const Offset(-145, -15), const Offset(-150, 25), const Offset(-140, 65),
            const Offset(-125, -95), const Offset(-115, -60), const Offset(-110, 50), const Offset(-105, 95),
            const Offset(-85, -125), const Offset(-75, -80), const Offset(-80, 75), const Offset(-70, 125),
            const Offset(-45, -145), const Offset(-35, -45), const Offset(-40, 45), const Offset(-30, 135),
            const Offset(-5, -150), const Offset(5, -65), const Offset(0, 70), const Offset(0, 140),
            const Offset(35, -140), const Offset(45, -75), const Offset(40, 60), const Offset(35, 130),
            const Offset(75, -120), const Offset(70, -45), const Offset(75, 45), const Offset(70, 115),
            const Offset(115, -95), const Offset(110, -55), const Offset(115, 55), const Offset(105, 95),
            const Offset(145, -60), const Offset(140, -20), const Offset(135, 20), const Offset(135, 65),
            const Offset(-15, -20), const Offset(-10, 15), const Offset(10, 18), const Offset(48, -12),
          ];

    for (int idx = 0; idx < trees.length; idx++) {
      final pos = trees[idx];
      final treeSize = 8.5 + (idx % 3) * 1.5;

      // 1. Soft drop shadow (angled southeast)
      canvas.drawCircle(
        pos.translate(2.5, 3.2),
        treeSize,
        Paint()..color = Colors.black.withValues(alpha: 0.28),
      );

      if (isEarth) {
        // 🌴 Earth Tropical Palm Canopies
        canvas.drawCircle(pos, treeSize, Paint()..color = const Color(0xFF14532D));
        final leafPaint = Paint()..color = const Color(0xFF16A34A)..strokeWidth = 2.2..strokeCap = StrokeCap.round;
        for (int f = 0; f < 6; f++) {
          final fa = (f * math.pi / 3) + (idx * 0.4);
          final lx = pos.dx + (treeSize * 1.1) * math.cos(fa);
          final ly = pos.dy + (treeSize * 1.1) * math.sin(fa);
          canvas.drawLine(pos, Offset(lx, ly), leafPaint);
        }
        canvas.drawCircle(pos.translate(-0.8, -1.0), treeSize * 0.72, Paint()..color = const Color(0xFF22C55E));
        canvas.drawCircle(pos.translate(-1.4, -1.6), treeSize * 0.38, Paint()..color = const Color(0xFF86EFAC));
      } else if (isTitan) {
        // 🌿 Titan Bioluminescent Alien Ferns
        canvas.drawCircle(pos, treeSize, Paint()..color = const Color(0xFF064E3B));
        canvas.drawCircle(pos.translate(-0.8, -1.0), treeSize * 0.70, Paint()..color = const Color(0xFF059669));
        canvas.drawCircle(pos.translate(-1.4, -1.6), treeSize * 0.35, Paint()..color = const Color(0xFF34D399));
      } else if (isMoon) {
        // 📡 Lunar Solar Arrays & Comms Dishes
        final panelRect = Rect.fromCenter(center: pos, width: treeSize * 1.6, height: treeSize * 0.9);
        canvas.drawRect(panelRect, Paint()..color = const Color(0xFF1E293B));
        canvas.drawRect(panelRect, Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.stroke..strokeWidth = 0.8);
        canvas.drawCircle(pos.translate(1, -1), 1.4, Paint()..color = Colors.white);
      } else if (isMars) {
        // 🔴 Mars Pressurized Bio-Domes
        canvas.drawCircle(pos, treeSize * 0.9, Paint()..color = const Color(0xFF7C2D12));
        canvas.drawCircle(pos.translate(-0.6, -0.8), treeSize * 0.65, Paint()..color = const Color(0xFFEA580C));
        canvas.drawCircle(pos.translate(-1.2, -1.4), treeSize * 0.30, Paint()..color = const Color(0xFFFDBA74));
      } else if (isEuropa) {
        // 🧊 Europa Cryo-Crystal Spires
        canvas.drawCircle(pos, treeSize * 0.85, Paint()..color = const Color(0xFF0284C7));
        canvas.drawCircle(pos.translate(-0.8, -0.8), treeSize * 0.60, Paint()..color = const Color(0xFF7DD3FC));
        canvas.drawCircle(pos.translate(-1.4, -1.4), treeSize * 0.30, Paint()..color = Colors.white);
      } else if (isPluto) {
        // ❄️ Pluto Cryogenic Nitrogen Crystal Pinnacles (Lavender/Violet)
        canvas.drawCircle(pos, treeSize * 0.85, Paint()..color = const Color(0xFF581C87));
        canvas.drawCircle(pos.translate(-0.8, -0.8), treeSize * 0.60, Paint()..color = const Color(0xFFA855F7));
        canvas.drawCircle(pos.translate(-1.4, -1.4), treeSize * 0.30, Paint()..color = const Color(0xFFF3E8FF));
      } else {
        // 🪐 Gas Giant / Volcanic Beacon Stations (Jupiter, Saturn, Venus, Neptune)
        final pylonColor = isJupiter
            ? const Color(0xFFF59E0B)
            : (isSaturn
                ? const Color(0xFFCA8A04)
                : (isVenus ? const Color(0xFFF59E0B) : const Color(0xFF38BDF8)));
        canvas.drawCircle(pos, treeSize * 0.80, Paint()..color = const Color(0xFF0F172A));
        canvas.drawCircle(pos.translate(-0.6, -0.8), treeSize * 0.55, Paint()..color = pylonColor);
        canvas.drawCircle(pos.translate(-1.2, -1.2), treeSize * 0.25, Paint()..color = Colors.white);
      }
    }
  }

  // =========================================================================
  // ⛱️ BEACH PARASOLS & SUNBED LOUNGERS (BENCHMARKS #1, #2, #3)
  // =========================================================================
  void _drawBeachUmbrellas(Canvas canvas) {
    final List<Offset> umbrellas = island.isPresidential
        ? [const Offset(105, -15), const Offset(105, 15)]
        : [
            // Beach umbrellas dotted along the golden sands facing the sea
            const Offset(-175, -85), const Offset(-172, -45), const Offset(-170, 45), const Offset(-165, 95),
            const Offset(-115, -170), const Offset(-65, -185), const Offset(65, -185), const Offset(120, -165),
            const Offset(168, -85), const Offset(165, 80), const Offset(115, 175), const Offset(-65, 190),
          ];

    for (int i = 0; i < umbrellas.length; i++) {
      final pos = umbrellas[i];
      final isRed = i % 2 == 0;

      // 1. Parasol Drop Shadow
      canvas.drawCircle(pos.translate(2.2, 2.5), 5.5, Paint()..color = Colors.black26);

      // 2. White Sunbed Lounger next to Umbrella
      final loungerOffset = pos.translate(7.5, (i % 3 == 0) ? -2.0 : 2.0);
      final loungerRect = Rect.fromCenter(center: loungerOffset, width: 4.2, height: 8.5);
      // Lounger shadow
      canvas.drawRect(loungerRect.shift(const Offset(1.0, 1.2)), Paint()..color = Colors.black12);
      // Lounger mattress
      canvas.drawRRect(
        RRect.fromRectAndRadius(loungerRect, const Radius.circular(1.0)),
        Paint()..color = Colors.white,
      );
      // Pillow crease line
      canvas.drawLine(
        Offset(loungerRect.left, loungerRect.top + 2.5),
        Offset(loungerRect.right, loungerRect.top + 2.5),
        Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 0.8,
      );

      // 3. Striped Parasol Canopy
      final canopyColor = isRed ? const Color(0xFFEF4444) : const Color(0xFF0284C7);
      canvas.drawCircle(pos, 5.8, Paint()..color = canopyColor);

      // Alternating 4 White Radial Stripes (Safe Line Primitives - No Path Tessellation)
      final stripePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(pos.dx - 4.6, pos.dy), Offset(pos.dx + 4.6, pos.dy), stripePaint);
      canvas.drawLine(Offset(pos.dx, pos.dy - 4.6), Offset(pos.dx, pos.dy + 4.6), stripePaint);
      canvas.drawLine(Offset(pos.dx - 3.2, pos.dy - 3.2), Offset(pos.dx + 3.2, pos.dy + 3.2), stripePaint);
      canvas.drawLine(Offset(pos.dx - 3.2, pos.dy + 3.2), Offset(pos.dx + 3.2, pos.dy - 3.2), stripePaint);

      // Center umbrella pole cap
      canvas.drawCircle(pos, 1.4, Paint()..color = Colors.white);
      canvas.drawCircle(pos, 0.7, Paint()..color = Colors.black54);
    }
  }

  void _drawSatelliteIslets(Canvas canvas) {
    final isletPath = Path();
    isletPath.addOval(Rect.fromCenter(center: const Offset(-115, 205), width: 48, height: 26));

    canvas.drawPath(isletPath, Paint()..color = const Color(0xFFFDE68A)..style = PaintingStyle.stroke..strokeWidth = 8);
    canvas.drawPath(isletPath, Paint()..color = const Color(0xFF16A34A)..style = PaintingStyle.fill);
    canvas.drawCircle(const Offset(-115, 205), 8.0, Paint()..color = const Color(0xFF15803D));
  }

  @override
  bool shouldRepaint(covariant IslandAerialPainter oldDelegate) {
    return oldDelegate.island.id != island.id ||
        oldDelegate.selectedPlotNumber != selectedPlotNumber ||
        oldDelegate.zoomScale != zoomScale ||
        oldDelegate.plots != plots;
  }

  // =========================================================================
  // 📍 50 CITIZEN PLOT COORDINATES (100% Strictly Inland on Solid Green Landmass)
  // Houses NEVER touch the ocean or water lagoon! Guaranteed dry inland plots!
  // =========================================================================
  // 📍 35 CITIZEN PLOT COORDINATES (5 Rock-Solid Archetypes, 100% Solid Land)
  // Houses NEVER touch the ocean or beach! Guaranteed dry inland plots!
  // =========================================================================
  static List<Offset> get35PlotCoordinates(IslandShapeStyle style) {
    final archetype = getIslandArchetype(style);
    final List<Offset> coords = [];

    switch (archetype) {
      case IslandArchetype.naturalOval:
        // 5 balanced rows (5 + 7 + 8 + 8 + 7 = 35 plots) for equal, spacious parcel partitioning
        const rowCounts = [5, 7, 8, 8, 7];
        const yPositions = [-105.0, -52.0, 0.0, 52.0, 105.0];
        const rowSpans = [160.0, 220.0, 260.0, 250.0, 190.0];
        for (int r = 0; r < 5; r++) {
          final count = rowCounts[r];
          final span = rowSpans[r];
          final step = count > 1 ? span / (count - 1) : 0.0;
          for (int c = 0; c < count; c++) {
            coords.add(Offset(-span / 2 + c * step, yPositions[r]));
          }
        }
        break;

      case IslandArchetype.capePeninsula:
        // 7 rows of 5 plots = 35 plots (Cadastral suburban grid matching Images 1 & 3)
        const yPositions = [-120.0, -80.0, -40.0, 0.0, 40.0, 80.0, 120.0];
        for (int r = 0; r < 7; r++) {
          for (int c = 0; c < 5; c++) {
            final x = -100.0 + c * 50.0;
            coords.add(Offset(x, yPositions[r]));
          }
        }
        break;

      case IslandArchetype.horseshoeBay:
        // Lagoon Atoll: 2 concentric circular rings (15 inner + 20 outer = 35 plots)
        for (int i = 0; i < 15; i++) {
          final a = (i * 2 * math.pi / 15) - math.pi / 2;
          coords.add(Offset(85.0 * math.cos(a), 68.0 * math.sin(a)));
        }
        for (int i = 0; i < 20; i++) {
          final a = (i * 2 * math.pi / 20) - math.pi / 2;
          coords.add(Offset(138.0 * math.cos(a), 110.0 * math.sin(a)));
        }
        break;

      case IslandArchetype.twinSanctuary:
        // Emerald Arch Haven: 5 balanced rows (6 + 7 + 8 + 7 + 7 = 35 plots)
        const rowCounts = [6, 7, 8, 7, 7];
        const yPositions = [-105.0, -52.0, 0.0, 52.0, 105.0];
        const rowSpans = [180.0, 230.0, 260.0, 230.0, 180.0];
        for (int r = 0; r < 5; r++) {
          final count = rowCounts[r];
          final span = rowSpans[r];
          final step = count > 1 ? span / (count - 1) : 0.0;
          for (int c = 0; c < count; c++) {
            coords.add(Offset(-span / 2 + c * step, yPositions[r]));
          }
        }
        break;

      case IslandArchetype.citadelPlateau:
        // 5 rows of 7 = 35 plots
        for (int i = 0; i < 35; i++) {
          final row = i ~/ 7;
          final col = i % 7;
          coords.add(Offset((col - 3) * 32.0, (row - 2) * 34.0));
        }
        break;
    }

    return coords;
  }

  // 🧭 Natural House Facing Angle (Houses face in various directions, never one flat direction!)
  static double getPlotFacingAngle(IslandShapeStyle style, int index) {
    final archetype = getIslandArchetype(style);
    switch (archetype) {
      case IslandArchetype.naturalOval:
        // Varied natural facing angles across rows
        final row = (index * 5) ~/ 35;
        return row.isEven ? 0.0 : math.pi;

      case IslandArchetype.capePeninsula:
        // Alternating north and south facing rows
        final row = index ~/ 5;
        return row.isEven ? math.pi : 0.0;

      case IslandArchetype.horseshoeBay:
        if (index < 15) {
          return (index * 2 * math.pi / 15) - math.pi / 2;
        } else {
          return ((index - 15) * 2 * math.pi / 20) - math.pi / 2 + math.pi;
        }

      case IslandArchetype.twinSanctuary:
        final row = (index * 5) ~/ 35;
        return row.isEven ? math.pi : 0.0;

      case IslandArchetype.citadelPlateau:
        final row = index ~/ 7;
        final col = index % 7;
        if (row == 0) return math.pi;
        if (row == 4) return 0.0;
        if (col < 3) return math.pi / 2;
        return -math.pi / 2;
    }
  }

  /// Backward-compatible alias
  static List<Offset> get50PlotCoordinates(IslandShapeStyle style) => get35PlotCoordinates(style);
}

class _CloudClusterDef {
  final Offset center;
  final double scale;
  final double speed;
  const _CloudClusterDef({
    required this.center,
    required this.scale,
    required this.speed,
  });
}
