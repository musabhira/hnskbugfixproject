import 'dart:math' as math;
import 'package:flutter/material.dart';
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

  const IslandAerialViewWidget({
    super.key,
    required this.island,
    this.isInteractive = false,
    this.zoomScale = 1.0,
    this.plots = const [],
    this.onPlotTapped,
    this.selectedPlotNumber,
  });

  @override
  State<IslandAerialViewWidget> createState() => _IslandAerialViewWidgetState();
}

class _IslandAerialViewWidgetState extends State<IslandAerialViewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
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
              selectedPlotNumber: widget.selectedPlotNumber,
              animation: _animController,
            ),
          ),
        );
      },
    );
  }

  void _handleTap(TapUpDetails details, Size size) {
    if (widget.onPlotTapped == null || widget.plots.isEmpty) return;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = widget.isInteractive ? 1.0 : (math.min(size.width, size.height) / 540.0);

    final islandX = (details.localPosition.dx - cx) / scale;
    final islandY = (details.localPosition.dy - cy) / scale;
    final tapPoint = Offset(islandX, islandY);

    CitizenPlot? hitPlot;
    double minDistance = 24.0; // Responsive touch hit radius

    for (final plot in widget.plots) {
      final d = (plot.coordinates - tapPoint).distance;
      if (d < minDistance) {
        minDistance = d;
        hitPlot = plot;
      }
    }

    if (hitPlot != null) {
      widget.onPlotTapped!(hitPlot);
    }
  }
}

/// 🎨 Island Aerial CustomPainter with Expansive Green Terrains & Safe In-Land Habit Plots
class IslandAerialPainter extends CustomPainter {
  final PoketCountryMap island;
  final bool isInteractive;
  final double zoomScale;
  final List<CitizenPlot> plots;
  final int? selectedPlotNumber;
  final Animation<double>? animation;

  IslandAerialPainter({
    required this.island,
    this.isInteractive = false,
    this.zoomScale = 1.0,
    this.plots = const [],
    this.selectedPlotNumber,
    this.animation,
  }) : super(repaint: animation);

  double get animProgress => animation?.value ?? 0.0;
  double get timeSeconds => animProgress * 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Ocean (Card mode fills the card; Fullscreen mode uses transparent halo)
    if (!isInteractive) {
      _drawCardOcean(canvas, size);
    } else {
      _drawSoftIslandLagoonAura(canvas, size);
    }

    final cx = size.width / 2;
    final cy = size.height / 2;
    // Vast island canvas scale factor: 1.0 in fullscreen world, scaled to fit in carousel cards
    final double scale = isInteractive ? 1.0 : (math.min(size.width, size.height) / 540.0);

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

    // 5. Expansive Lush Tropical Green Island Body (Generous landmass)
    _drawGreenIslandBody(canvas);

    // 6. Central Lagoon / Resort Swimming Lake
    _drawInteriorWaterBody(canvas);

    // 7. Winding Paved Trails & Roadways Connecting the Island
    _drawRoadways(canvas);

    // 8. Mini Sports Pitch (Football Turf Lawn with White Markings)
    if (!island.isPresidential) {
      _drawSportsTurfPitch(canvas);
    }

    // 9. Wooden Pier with Moored Speedboats & Cruising Boats with Foam Wakes
    _drawWoodenPierAndBoats(canvas);
    _drawCruisingBoatsWithWakes(canvas);

    // 10. Habit Houses / Plots (Strictly inside the green landmass with safe buffer)
    if (island.isPresidential) {
      _drawPresidentialCitadel(canvas);
    } else {
      _draw50HabitHousePlots(canvas);
    }

    // 11. Clustered Palm Tree Canopies with Organic Shadows
    _drawPalmTreeCanopies(canvas);

    // 12. Beach Umbrellas & Sunbed Loungers along the Golden Sand
    _drawBeachUmbrellas(canvas);

    // 13. Drifting Soft Atmospheric Clouds
    _drawAtmosphericClouds(canvas);

    // 14. Soaring Seagulls gliding over the azure ocean
    _drawSoaringSeagulls(canvas);

    canvas.restore();
  }

  // =========================================================================
  // 🌊 CARD MODE OCEAN BACKGROUND (Used only inside Carousel cards)
  // =========================================================================
  void _drawCardOcean(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    final oceanGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.25,
      colors: [
        island.waterColor.withValues(alpha: 0.96),
        Color.lerp(island.waterColor, const Color(0xFF03045E), 0.55) ?? const Color(0xFF0284C7),
        const Color(0xFF022B45),
      ],
      stops: const [0.0, 0.50, 1.0],
    );

    final oceanPaint = Paint()..shader = oceanGradient.createShader(fullRect);
    canvas.drawRect(fullRect, oceanPaint);
  }

  // =========================================================================
  // 🏝️ FULLSCREEN LAGOON AURA (Soft circular aura fading to 100% transparent)
  // ZERO RECTANGULAR BOX BREAKS! Blends invisibly into InfiniteLivingOceanWidget!
  // =========================================================================
  void _drawSoftIslandLagoonAura(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final auraRadius = math.min(size.width, size.height) * 0.46;

    final auraGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        island.waterColor.withValues(alpha: 0.70),
        island.waterColor.withValues(alpha: 0.38),
        island.waterColor.withValues(alpha: 0.10),
        Colors.transparent, // Completely fades to transparent at edges!
      ],
      stops: const [0.0, 0.45, 0.75, 1.0],
    );

    final auraPaint = Paint()..shader = auraGradient.createShader(Rect.fromCircle(center: center, radius: auraRadius));
    canvas.drawCircle(center, auraRadius, auraPaint);
  }

    // Animated gentle drifting wave crest arcs across open waters
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 9; i++) {
      final drift = (timeSeconds * 3.5 + i * 18.0) % 90.0;
      final angle = (i * 0.85);
      final rx = (size.width * (0.15 + (i % 4) * 0.25) + drift) % size.width;
      final ry = size.height * (0.12 + (i ~/ 3) * 0.32);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(rx, ry), width: 75, height: 26),
        angle,
        1.6,
        false,
        wavePaint,
      );
    }
  }

  // =========================================================================
  // 🏝️ EXPANSIVE ISLAND PATH GEOMETRIES (Large Landmass)
  // =========================================================================
  Path _getIslandPath() {
    final path = Path();

    if (island.isPresidential || island.shapeStyle == IslandShapeStyle.citadelApex) {
      // 👑 Symmetrical Imperial Octagonal Island
      const r = 135.0;
      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi / 4) - math.pi / 8;
        final x = r * math.cos(angle);
        final y = r * math.sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      return path;
    }

    switch (island.shapeStyle) {
      case IslandShapeStyle.crescentLagoon:
        // 🌙 Wide C-shaped Crescent wrapping around turquoise lagoon
        path.moveTo(-160, -120);
        path.cubicTo(-90, -210, 115, -200, 180, -90);
        path.cubicTo(225, 15, 190, 140, 110, 185);
        path.cubicTo(65, 205, 15, 160, 45, 115);
        path.cubicTo(95, 45, 100, -45, 30, -90);
        path.cubicTo(-35, -120, -110, -75, -130, -20);
        path.cubicTo(-150, 20, -195, 30, -200, -20);
        path.cubicTo(-210, -80, -190, -110, -160, -120);
        path.close();
        break;

      case IslandShapeStyle.sCurveArchipelago:
        // 🐉 Expansive S-Curve dragon island
        path.moveTo(-130, -185);
        path.cubicTo(-45, -215, 65, -165, 95, -90);
        path.cubicTo(120, -20, 35, 25, -35, 35);
        path.cubicTo(-110, 50, -125, 125, -80, 185);
        path.cubicTo(-35, 230, 80, 215, 140, 165);
        path.cubicTo(185, 120, 205, 180, 155, 215);
        path.cubicTo(90, 260, -80, 260, -145, 185);
        path.cubicTo(-195, 120, -180, 15, -100, -15);
        path.cubicTo(-30, -35, 15, -80, -10, -140);
        path.cubicTo(-25, -185, -95, -200, -130, -185);
        path.close();
        break;

      case IslandShapeStyle.starAtoll:
        // ⭐ Expansive 5-Pointed Tropical Coral Star Island
        const int points = 5;
        const outerR = 185.0;
        const innerR = 100.0;
        for (int i = 0; i < points * 2; i++) {
          final r = i.isEven ? outerR : innerR;
          final angle = (i * math.pi / points) - math.pi / 2;
          final x = r * math.cos(angle);
          final y = r * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.quadraticBezierTo(
              (r * 0.9) * math.cos(angle - 0.2),
              (r * 0.9) * math.sin(angle - 0.2),
              x,
              y,
            );
          }
        }
        path.close();
        break;

      case IslandShapeStyle.dualIsletBridge:
        // 🏝️-🏝️ Two Large Twin Islands linked by arched land bridge
        path.moveTo(-190, -90);
        path.cubicTo(-115, -165, -45, -125, -30, -45);
        path.lineTo(30, -35); // Bridge north
        path.cubicTo(45, -125, 125, -155, 190, -80);
        path.cubicTo(240, -15, 220, 105, 150, 155);
        path.cubicTo(80, 190, 35, 125, 30, 45);
        path.lineTo(-30, 35); // Bridge south
        path.cubicTo(-45, 125, -115, 175, -180, 125);
        path.cubicTo(-240, 75, -240, -30, -190, -90);
        path.close();
        break;

      case IslandShapeStyle.ringAtoll:
        // ⭕ Expansive Circular Ring Atoll with wide green belt
        path.moveTo(-170, -140);
        path.cubicTo(-75, -215, 95, -200, 175, -120);
        path.cubicTo(240, -35, 225, 110, 160, 175);
        path.cubicTo(90, 225, -90, 210, -170, 145);
        path.cubicTo(-235, 75, -235, -65, -170, -140);
        path.close();
        break;

      case IslandShapeStyle.hookPeninsula:
        // 🪝 Broad J-Shaped Hook Peninsula
        path.moveTo(-75, -200);
        path.cubicTo(0, -215, 75, -165, 80, -75);
        path.cubicTo(90, 30, 110, 125, 185, 155);
        path.cubicTo(230, 175, 210, 230, 140, 230);
        path.cubicTo(50, 230, 0, 170, -15, 80);
        path.cubicTo(-30, -15, -40, -90, -110, -120);
        path.cubicTo(-170, -140, -150, -215, -75, -200);
        path.close();
        break;

      case IslandShapeStyle.heartSanctuary:
        // 💖 Spacious Heart-Shaped Tropical Island
        path.moveTo(0, -75);
        path.cubicTo(55, -180, 185, -165, 185, -45);
        path.cubicTo(185, 65, 90, 140, 0, 215);
        path.cubicTo(-90, 140, -185, 65, -185, -45);
        path.cubicTo(-185, -165, -55, -180, 0, -75);
        path.close();
        break;

      case IslandShapeStyle.cloverBays:
        // 🍀 Broad 3-Leaf Clover Island
        path.moveTo(0, -200);
        path.cubicTo(105, -200, 105, -65, 45, -30);
        path.cubicTo(140, 0, 195, 120, 105, 185);
        path.cubicTo(30, 225, 0, 110, 0, 65);
        path.cubicTo(0, 110, -30, 225, -105, 185);
        path.cubicTo(-195, 120, -140, 0, -45, -30);
        path.cubicTo(-105, -65, -105, -200, 0, -200);
        path.close();
        break;

      case IslandShapeStyle.fortressPlateau:
        // 🛡️ Spacious Hexagonal Plateau
        path.moveTo(0, -190);
        path.lineTo(185, -65);
        path.lineTo(165, 110);
        path.lineTo(0, 200);
        path.lineTo(-165, 110);
        path.lineTo(-185, -65);
        path.close();
        break;

      case IslandShapeStyle.citadelApex:
        break;
    }

    return path;
  }

  // =========================================================================
  // 3. REEF, BEACH & GREEN TERRAIN (MATCHING REALISTIC RESORT BENCHMARKS)
  // =========================================================================
  void _drawShallowCoralReef(Canvas canvas) {
    final islandPath = _getIslandPath();

    // Outermost translucent shallow reef contour (Safe GPU stroke)
    final reefPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(islandPath, reefPaint);

    // Inner bright aquamarine shimmer
    final reefInnerPaint = Paint()
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(islandPath, reefInnerPaint);

    // Living rhythmic ocean surf tide breathing against the shore
    final tide = math.sin(timeSeconds * 2.2);
    final foamPaint = Paint()
      ..color = Colors.white.withValues(alpha: (0.42 + 0.16 * tide).clamp(0.15, 0.75))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 + 0.7 * tide
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(islandPath, foamPaint);
  }

  void _drawSandyBeach(Canvas canvas) {
    final islandPath = _getIslandPath();

    // Main golden sand beach rim
    final sandPaint = Paint()
      ..color = const Color(0xFFFDE68A) // Golden tropical sand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(islandPath, sandPaint);

    // Wet shoreline sand edge meeting the water
    final wetSandPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(islandPath, wetSandPaint);
  }

  void _drawGreenIslandBody(Canvas canvas) {
    final islandPath = _getIslandPath();

    final landGradient = RadialGradient(
      center: const Alignment(-0.15, -0.22),
      radius: 0.98,
      colors: [
        const Color(0xFF4ADE80), // Sunlit vibrant lush green
        island.landColor,        // Island signature forest green
        Color.lerp(island.landColor, const Color(0xFF064E3B), 0.52) ?? const Color(0xFF14532D),
      ],
      stops: const [0.0, 0.52, 1.0],
    );

    final landPaint = Paint()
      ..shader = landGradient.createShader(Rect.fromCircle(center: Offset.zero, radius: 230))
      ..style = PaintingStyle.fill;

    canvas.drawPath(islandPath, landPaint);
  }

  void _drawInteriorWaterBody(Canvas canvas) {
    if (island.isPresidential) return;

    final lagoonPaint = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;

    final lagoonSandRim = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;

    final lagoonFoam = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    if (island.shapeStyle == IslandShapeStyle.ringAtoll ||
        island.shapeStyle == IslandShapeStyle.crescentLagoon) {
      final lagoonPath = Path();
      lagoonPath.addOval(Rect.fromCenter(center: const Offset(15, 15), width: 110, height: 80));
      canvas.drawPath(lagoonPath, lagoonSandRim);
      canvas.drawPath(lagoonPath, lagoonPaint);
      canvas.drawPath(lagoonPath, lagoonFoam);
    } else if (island.shapeStyle == IslandShapeStyle.starAtoll) {
      final lagoonPath = Path();
      lagoonPath.addOval(Rect.fromCenter(center: Offset.zero, width: 68, height: 68));
      canvas.drawPath(lagoonPath, lagoonSandRim);
      canvas.drawPath(lagoonPath, lagoonPaint);
      canvas.drawPath(lagoonPath, lagoonFoam);
    }
  }

  void _drawRoadways(Canvas canvas) {
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
    if (island.isPresidential) {
      rPath.moveTo(-115, 0);
      rPath.lineTo(-35, 0);
    } else {
      // Loop avenue inside the green land connecting plots
      rPath.moveTo(-95, -65);
      rPath.quadraticBezierTo(0, -95, 95, -65);
      rPath.quadraticBezierTo(110, 0, 165, 20); // Pier link
      rPath.moveTo(-95, 65);
      rPath.quadraticBezierTo(0, 95, 95, 65);
      rPath.moveTo(-65, -65);
      rPath.lineTo(-65, 65);
      rPath.moveTo(65, -65);
      rPath.lineTo(65, 65);
    }
    canvas.drawPath(rPath, roadBorder);
    canvas.drawPath(rPath, roadPaint);
  }

  // =========================================================================
  // ⚽ MINI SPORTS TURF PITCH (FOOTBALL TURF WITH WHITE MARKINGS - BENCHMARK #2)
  // =========================================================================
  void _drawSportsTurfPitch(Canvas canvas) {
    const pitchCenter = Offset(24, -36);
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
  // 🚤 CRUISING BOATS WITH V-SHAPED FOAM WAKES (LIVE 60FPS MOTION)
  // =========================================================================
  void _drawCruisingBoatsWithWakes(Canvas canvas) {
    if (island.isPresidential) return;

    // 1. Moving Cruising Speedboat orbiting around the outer turquoise reef
    final t1 = (timeSeconds * 0.14) % (2 * math.pi);
    final pos1 = Offset(215.0 * math.cos(t1), 165.0 * math.sin(t1));
    final angle1 = t1 + math.pi / 2;
    _drawBoatWithWake(
      canvas,
      pos: pos1,
      angle: angle1,
      boatLength: 14,
      boatWidth: 6,
      wakeLength: 46,
    );

    // 2. Southeast Cruising Yacht traveling along southern waters
    final t2 = (-timeSeconds * 0.10) % (2 * math.pi);
    final pos2 = Offset(205.0 * math.cos(t2) * 0.9, 155.0 * math.sin(t2) + 25);
    final angle2 = t2 - math.pi / 2;
    _drawBoatWithWake(
      canvas,
      pos: pos2,
      angle: angle2,
      boatLength: 16,
      boatWidth: 7,
      wakeLength: 52,
    );

    // 3. East Off-Shore Tender Boat
    _drawBoatWithWake(
      canvas,
      pos: const Offset(210, -85),
      angle: 0.45,
      boatLength: 11,
      boatWidth: 5,
      wakeLength: 35,
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
  // ☁️ DRIFTING ATMOSPHERIC CLOUD SHADOWS
  // =========================================================================
  void _drawAtmosphericClouds(Canvas canvas) {
    for (int c = 0; c < 3; c++) {
      final cx = -260.0 + ((timeSeconds * 10.0 + c * 210.0) % 650.0);
      final cy = -160.0 + ((timeSeconds * 5.0 + c * 130.0) % 490.0);
      final shadow = Paint()
        ..color = Colors.black.withValues(alpha: 0.05)
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 95, height: 42), shadow);
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
  // 🏡 50 HABIT HOUSE PLOTS (LOD: MINIMAL DOTS FROM FAR, DETAILED HOUSES UP CLOSE)
  // =========================================================================
  void _draw50HabitHousePlots(Canvas canvas) {
    final List<Offset> positions = get50PlotCoordinates(island.shapeStyle);

    for (int i = 0; i < 50; i++) {
      final pos = positions[i];
      final plotNumber = i + 1;
      final isSel = selectedPlotNumber == plotNumber;

      final CitizenPlot plot = i < plots.length
          ? plots[i]
          : CitizenPlot(
              plotNumber: plotNumber,
              userId: 'empty_$plotNumber',
              userName: 'Plot #$plotNumber',
              userAvatar: '',
              day: (plotNumber * 2) % 90 + 1,
              pocketScore: 500,
              streetName: 'Reefway Avenue',
              postOffice: island.name,
              countryName: island.name,
              planetName: 'Earth Prime',
              coordinates: pos,
            );

      final bool isOverview = !isInteractive || zoomScale < 1.6;

      if (isOverview) {
        // 🔭 FAR AWAY / OVERVIEW MODE (LOD: Tiny minimal glowing homestead dot nestled in greenery)
        final dotPaint = Paint()
          ..color = isSel
              ? const Color(0xFFFFD700)
              : (plot.day >= 90
                  ? const Color(0xFFFFD700)
                  : (plot.day >= 60 ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.95)));
        canvas.drawCircle(pos, 2.8, Paint()..color = Colors.black26); // Drop shadow
        canvas.drawCircle(pos, 2.2, dotPaint);
      } else {
        // 🔬 DEEP ZOOM INSPECTION MODE (LOD: Full demarcated plot lawn & 90-day house)
        // 1. Plot Demarcated Garden Lawn Boundary
        final plotRect = Rect.fromCenter(center: pos, width: 24, height: 24);
        final gardenPaint = Paint()
          ..color = isSel
              ? const Color(0xFFFFD700).withValues(alpha: 0.9)
              : const Color(0xFF166534).withValues(alpha: 0.45)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndRadius(plotRect, const Radius.circular(4)), gardenPaint);

        final fencePaint = Paint()
          ..color = isSel ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSel ? 1.8 : 0.7;
        canvas.drawRRect(RRect.fromRectAndRadius(plotRect, const Radius.circular(4)), fencePaint);

        // 2. Render Top-Down 90-Day Habit House Roof
        _drawTopDownHabitHouse(canvas, pos, plot.day, isSel);

        // 3. Mini Plot Number Badge
        final tp = TextPainter(
          text: TextSpan(
            text: '$plotNumber',
            style: TextStyle(
              color: isSel ? Colors.black : Colors.white,
              fontSize: 6.8,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final badgePos = pos.translate(-tp.width / 2, -15);
        final badgeBg = RRect.fromRectAndRadius(
          Rect.fromLTWH(badgePos.dx - 2, badgePos.dy - 1, tp.width + 4, tp.height + 2),
          const Radius.circular(3),
        );
        canvas.drawRRect(badgeBg, Paint()..color = isSel ? const Color(0xFFFFD700) : Colors.black87);
        tp.paint(canvas, badgePos);
      }
    }
  }

  /// 🏛️ Top-Down Habit House Roof based on Day 1-90 Progression (Matching Reference Benchmark Villas)
  void _drawTopDownHabitHouse(Canvas canvas, Offset pos, int day, bool isSelected) {
    // 0. Soft House Drop Shadow (giving true top-down aerial elevation)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos.translate(2.2, 2.8), width: 15, height: 13),
        const Radius.circular(2.5),
      ),
      Paint()..color = Colors.black26,
    );

    if (day <= 15) {
      // ⛺ Stage 1 (Day 1-15): Starter Camp / Wooden Thatched Bungalow (Image #1 style)
      final roofRect = Rect.fromCenter(center: pos, width: 13, height: 11);
      final roofPaint = Paint()..color = const Color(0xFFB45309); // Timber thatch
      canvas.drawRRect(RRect.fromRectAndRadius(roofRect, const Radius.circular(2)), roofPaint);

      // Thatch ridge center line
      canvas.drawLine(
        Offset(roofRect.left + 2, pos.dy),
        Offset(roofRect.right - 2, pos.dy),
        Paint()..color = const Color(0xFF78350F)..strokeWidth = 1.2,
      );
    } else if (day <= 35) {
      // 🏡 Stage 2 (Day 16-35): Terracotta Villa with 4-Way Hipped Roof
      final villaRect = Rect.fromCenter(center: pos, width: 14, height: 12);
      final roofPaint = Paint()..color = const Color(0xFFEA580C); // Warm terracotta tile
      canvas.drawRRect(RRect.fromRectAndRadius(villaRect, const Radius.circular(2)), roofPaint);

      // Hipped Roof 4-Corner Ridge Lines
      final ridgePaint = Paint()..color = Colors.white60..strokeWidth = 0.9;
      canvas.drawLine(villaRect.topLeft, Offset(pos.dx - 2.5, pos.dy), ridgePaint);
      canvas.drawLine(villaRect.bottomLeft, Offset(pos.dx - 2.5, pos.dy), ridgePaint);
      canvas.drawLine(villaRect.topRight, Offset(pos.dx + 2.5, pos.dy), ridgePaint);
      canvas.drawLine(villaRect.bottomRight, Offset(pos.dx + 2.5, pos.dy), ridgePaint);
      canvas.drawLine(Offset(pos.dx - 2.5, pos.dy), Offset(pos.dx + 2.5, pos.dy), ridgePaint);

      // Stone chimney
      canvas.drawCircle(pos.translate(4.0, -3.5), 1.6, Paint()..color = const Color(0xFF475569));
    } else if (day <= 60) {
      // 🏢 Stage 3 (Day 36-60): Crisp White Resort Villa with Turquoise Plunge Pool (Image #1 & #2 style)
      // Villa Main Body (White Hipped Roof)
      final villaRect = Rect.fromCenter(center: pos.translate(-3, 0), width: 13, height: 13);
      final villaPaint = Paint()..color = const Color(0xFFF8FAFC); // Crisp white roof
      canvas.drawRRect(RRect.fromRectAndRadius(villaRect, const Radius.circular(2)), villaPaint);

      // White hip roof diagonal ridges
      final ridge = Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 0.9;
      canvas.drawLine(villaRect.topLeft, villaRect.bottomRight, ridge);
      canvas.drawLine(villaRect.topRight, villaRect.bottomLeft, ridge);

      // Private Turquoise Plunge Pool with White Coping Stone
      final poolRect = Rect.fromCenter(center: pos.translate(5.8, 0), width: 6.5, height: 10.5);
      canvas.drawRRect(
        RRect.fromRectAndRadius(poolRect, const Radius.circular(1.8)),
        Paint()..color = Colors.white,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(poolRect.deflate(0.8), const Radius.circular(1.2)),
        Paint()..color = const Color(0xFF06B6D4), // Turquoise pool water
      );
    } else if (day <= 89) {
      // 🏰 Stage 4 (Day 61-89): Luxury Glass & Ocean Villa with Expanded L-Pool
      final manorRect = Rect.fromCenter(center: pos.translate(-3.2, 0), width: 14, height: 14);
      final manorPaint = Paint()..color = const Color(0xFF0284C7); // Sapphire glass roof
      canvas.drawRRect(RRect.fromRectAndRadius(manorRect, const Radius.circular(2.5)), manorPaint);

      final glassGlaze = Paint()..color = Colors.white70..strokeWidth = 0.8;
      canvas.drawLine(Offset(manorRect.left + 2, pos.dy), Offset(manorRect.right - 2, pos.dy), glassGlaze);
      canvas.drawLine(Offset(pos.dx - 3.2, manorRect.top + 2), Offset(pos.dx - 3.2, manorRect.bottom - 2), glassGlaze);

      // Large private pool
      final poolRect = Rect.fromCenter(center: pos.translate(6.5, 0), width: 7.0, height: 13.0);
      canvas.drawRRect(RRect.fromRectAndRadius(poolRect, const Radius.circular(2)), Paint()..color = Colors.white);
      canvas.drawRRect(RRect.fromRectAndRadius(poolRect.deflate(0.9), const Radius.circular(1.5)), Paint()..color = const Color(0xFF22D3EE));
    } else {
      // 👑 Stage 5 (Day 90): Sovereign Golden Apex Palace
      final goldPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawCircle(pos, 9.0, goldPaint);
      canvas.drawCircle(pos, 5.0, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(pos, 2.2, Paint()..color = Colors.white);
    }
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
            // Lush palm groves along pathways, beach perimeters, and between villas
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

      // 1. Soft tree drop shadow (angled southeast)
      canvas.drawCircle(
        pos.translate(2.5, 3.2),
        treeSize,
        Paint()..color = Colors.black.withValues(alpha: 0.28),
      );

      // 2. Base deep jungle green canopy
      canvas.drawCircle(pos, treeSize, Paint()..color = const Color(0xFF14532D));

      // 3. 6 Radiating Palm Star Fronds / Leaves (like tropical palm trees)
      final leafPaint = Paint()..color = const Color(0xFF16A34A)..strokeWidth = 2.2..strokeCap = StrokeCap.round;
      for (int f = 0; f < 6; f++) {
        final fa = (f * math.pi / 3) + (idx * 0.4);
        final lx = pos.dx + (treeSize * 1.1) * math.cos(fa);
        final ly = pos.dy + (treeSize * 1.1) * math.sin(fa);
        canvas.drawLine(pos, Offset(lx, ly), leafPaint);
      }

      // 4. Sunlit vibrant emerald center leaf layer
      canvas.drawCircle(
        pos.translate(-0.8, -1.0),
        treeSize * 0.72,
        Paint()..color = const Color(0xFF22C55E),
      );

      // 5. Bright highlight crown
      canvas.drawCircle(
        pos.translate(-1.4, -1.6),
        treeSize * 0.38,
        Paint()..color = const Color(0xFF86EFAC),
      );
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
  // 📍 50 PRE-CALCULATED PLOT COORDINATES (100% STRICTLY INSIDE GREEN LANDMASS)
  // Houses NEVER touch the ocean or beach! Generous 50px+ inland safety buffer!
  // =========================================================================
  static List<Offset> get50PlotCoordinates(IslandShapeStyle style) {
    final List<Offset> coords = [];

    switch (style) {
      case IslandShapeStyle.crescentLagoon:
        // Safely along the deep green crescent arch (well inside the green belt)
        for (int i = 0; i < 50; i++) {
          final t = (i / 49.0);
          final angle = -math.pi * 0.78 + t * math.pi * 1.42;
          final r = 75.0 + (i % 3) * 13.0;
          coords.add(Offset(r * math.cos(angle) - 10, r * math.sin(angle) * 0.90 + 5));
        }
        break;

      case IslandShapeStyle.sCurveArchipelago:
        // Safely inside the deep green S-curve spine
        for (int i = 0; i < 50; i++) {
          final t = (i / 49.0) * 2 * math.pi - math.pi;
          final x = 45.0 * math.sin(t) + ((i % 2 == 0) ? -9 : 9);
          final y = (i - 25) * 5.0;
          coords.add(Offset(x, y));
        }
        break;

      case IslandShapeStyle.starAtoll:
        // 10 plots on each of the 5 coral star arms, firmly inside the core
        for (int i = 0; i < 50; i++) {
          final arm = i % 5;
          final armIdx = i ~/ 5;
          final angle = (arm * 2 * math.pi / 5) - math.pi / 2;
          final r = 40.0 + armIdx * 9.5;
          coords.add(Offset(r * math.cos(angle), r * math.sin(angle)));
        }
        break;

      case IslandShapeStyle.dualIsletBridge:
        // 25 plots safely in West Islet core, 25 in East Islet core
        for (int i = 0; i < 25; i++) {
          final row = i ~/ 5;
          final col = i % 5;
          coords.add(Offset(-135.0 + col * 16.0, -35.0 + row * 18.0));
        }
        for (int i = 0; i < 25; i++) {
          final row = i ~/ 5;
          final col = i % 5;
          coords.add(Offset(55.0 + col * 16.0, -35.0 + row * 18.0));
        }
        break;

      case IslandShapeStyle.ringAtoll:
        // Circular ring well inside the green belt surrounding the central lagoon
        for (int i = 0; i < 50; i++) {
          final angle = (i * 2 * math.pi / 50) - math.pi / 2;
          final r = 85.0 + (i % 2) * 14.0;
          coords.add(Offset(r * math.cos(angle) + 10, r * math.sin(angle) * 0.95 + 10));
        }
        break;

      case IslandShapeStyle.hookPeninsula:
        // Firmly inside the inner J-hook land ridge
        for (int i = 0; i < 50; i++) {
          final t = i / 49.0;
          if (t < 0.45) {
            final subT = t / 0.45;
            coords.add(Offset(-40.0 + subT * 85.0, -115.0 + subT * 110.0 + ((i % 2 == 0) ? -8 : 8)));
          } else {
            final subT = (t - 0.45) / 0.55;
            final angle = subT * math.pi;
            coords.add(Offset(45.0 + 55.0 * math.sin(angle), -5.0 + subT * 140.0));
          }
        }
        break;

      case IslandShapeStyle.heartSanctuary:
        // Firmly inside the parametric heart lobes
        for (int i = 0; i < 50; i++) {
          final t = (i / 49.0) * 2 * math.pi;
          final x = 68.0 * math.sin(t) * math.sin(t) * math.sin(t);
          final y = -58.0 * math.cos(t) + 22.0 * math.cos(2 * t) + 10.0 * math.cos(3 * t) + 5.0 * math.cos(4 * t);
          coords.add(Offset(x, y + 15));
        }
        break;

      case IslandShapeStyle.cloverBays:
        // Firmly inside the 3 green lobes
        for (int i = 0; i < 16; i++) {
          final r = 24.0 + (i % 3) * 10.0;
          final a = (i / 15.0) * math.pi - math.pi;
          coords.add(Offset(r * math.cos(a), -70.0 + r * math.sin(a)));
        }
        for (int i = 0; i < 17; i++) {
          final r = 24.0 + (i % 3) * 10.0;
          final a = (i / 16.0) * math.pi - math.pi / 4;
          coords.add(Offset(55.0 + r * math.cos(a), 48.0 + r * math.sin(a)));
        }
        for (int i = 0; i < 17; i++) {
          final r = 24.0 + (i % 3) * 10.0;
          final a = (i / 16.0) * math.pi - 3 * math.pi / 4;
          coords.add(Offset(-55.0 + r * math.cos(a), 48.0 + r * math.sin(a)));
        }
        break;

      case IslandShapeStyle.fortressPlateau:
        // Diamond grid safely inside the hexagonal plateau core
        for (int i = 0; i < 50; i++) {
          final row = i ~/ 7;
          final col = i % 7;
          final x = (col - 3) * 24.0;
          final y = (row - 3) * 24.0;
          coords.add(Offset(x, y));
        }
        break;

      default:
        // General safe internal grid with generous spacing
        for (int i = 0; i < 50; i++) {
          final row = i ~/ 8;
          final col = i % 8;
          coords.add(Offset(-80.0 + col * 22.0, -55.0 + row * 20.0));
        }
        break;
    }

    return coords;
  }
}
