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
    final scale = widget.isInteractive
        ? ((size.height / 850.0) * 1.15).clamp(0.95, 1.50)
        : (math.min(size.width, size.height) / 540.0);

    final islandX = (details.localPosition.dx - cx) / scale;
    final islandY = (details.localPosition.dy - cy) / scale;
    final tapPoint = Offset(islandX, islandY);

    CitizenPlot? hitPlot;
    double minDistance = 30.0 * scale; // Responsive touch hit radius for generous 34x28 parcels

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

    // 5. Expansive Lush Tropical Green Island Body (Generous landmass)
    _drawGreenIslandBody(canvas);

    // 5b. 35 Territorial Districts (State/District Map Partition with Border Lines!)
    // Like US / Indian states on a map, entire island is partitioned into 35 contiguous districts!
    if (!island.isPresidential) {
      _draw35TerritorialDistricts(canvas);
    }

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

    // 10. Living Wildlife & Grazing Animals (Peaceful sheep & horses on meadow belt)
    _drawGrazingAnimals(canvas);

    // 11. Habit Houses / Plots (Strictly inside the green landmass with safe buffer)
    if (island.isPresidential) {
      _drawPresidentialCitadel(canvas);
    } else {
      _drawCitizenPlots(canvas);
    }

    // 11. Clustered Palm Tree Canopies with Organic Shadows
    _drawPalmTreeCanopies(canvas);

    // 12. Beach Umbrellas & Sunbed Loungers along the Golden Sand
    _drawBeachUmbrellas(canvas);

    // 13. High-Altitude Atmospheric Drifting Clouds & Soft Shadows
    _drawAtmosphericClouds(canvas);

    // 14. Soaring Seagulls gliding over the azure ocean
    _drawSoaringSeagulls(canvas);

    canvas.restore();
  }

  // =========================================================================
  // 🌊 UNIFIED LIVING WORLD OCEAN (Edge-to-edge ocean, wave swells & sunlight)
  // =========================================================================
  void _drawUnifiedWorldOcean(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    // 1. Vast Depth Gradient (matches Scaffold ocean color at edge)
    final oceanGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.15,
      colors: [
        Color.lerp(island.waterColor, const Color(0xFF0284C7), 0.65) ?? const Color(0xFF0284C7),
        Color.lerp(island.waterColor, const Color(0xFF0369A1), 0.80) ?? const Color(0xFF0369A1),
        const Color(0xFF075985),
        const Color(0xFF033F63),
        const Color(0xFF022B45), // Outermost edge matches Scaffold background identically!
      ],
      stops: const [0.0, 0.35, 0.65, 0.85, 1.0],
    );

    final oceanPaint = Paint()..shader = oceanGradient.createShader(fullRect);
    canvas.drawRect(fullRect, oceanPaint);

    // 2. High-Altitude Sunlight Sheen (Subtle Specular Glint)
    final sunGlintPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.9,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(fullRect);
    canvas.drawRect(fullRect, sunGlintPaint);

    // 3. Living Wave Crest Arcs across the open sea
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final faintWave = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
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

    if (island.shapeStyle == IslandShapeStyle.ringAtoll) {
      final lagoonPath = Path();
      lagoonPath.addOval(Rect.fromCenter(center: const Offset(10, 10), width: 95, height: 75));
      canvas.drawPath(lagoonPath, lagoonSandRim);
      canvas.drawPath(lagoonPath, lagoonPaint);
      canvas.drawPath(lagoonPath, lagoonFoam);
    } else if (island.shapeStyle == IslandShapeStyle.starAtoll) {
      final lagoonPath = Path();
      lagoonPath.addOval(Rect.fromCenter(center: Offset.zero, width: 55, height: 55));
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
    } else if (island.shapeStyle == IslandShapeStyle.crescentLagoon) {
      // 🌙 Grand Crescent Coastal Boulevard running directly between the two rows of villas at r = 145!
      const r = 145.0;
      for (int i = 0; i <= 36; i++) {
        final a = -2.15 + (i / 36.0) * 3.9;
        final x = r * math.cos(a) - 6;
        final y = r * math.sin(a) * 0.92 + 5;
        if (i == 0) {
          rPath.moveTo(x, y);
        } else {
          rPath.lineTo(x, y);
        }
      }
      // Connection to the wooden pier on the east shore
      rPath.moveTo(145, 15);
      rPath.lineTo(175, 18);
    } else if (island.shapeStyle == IslandShapeStyle.sCurveArchipelago) {
      // 🐉 Spine boulevard along the S-curve
      for (int i = 0; i <= 30; i++) {
        final t = (i / 30.0) * 2 - 1;
        final y = t * 122.0;
        final x = 46.0 * math.sin(t * math.pi);
        if (i == 0) {
          rPath.moveTo(x, y);
        } else {
          rPath.lineTo(x, y);
        }
      }
      rPath.moveTo(46, 15);
      rPath.lineTo(165, 20); // Pier link
    } else if (island.shapeStyle == IslandShapeStyle.starAtoll) {
      // ⭐ Radial avenues from center to each star point
      const points = 5;
      for (int k = 0; k < points; k++) {
        final a = (k * 2 * math.pi / points) - math.pi / 2;
        rPath.moveTo(35 * math.cos(a), 35 * math.sin(a));
        rPath.lineTo(135 * math.cos(a), 135 * math.sin(a));
      }
    } else {
      // Safe inland circular promenade
      rPath.addOval(Rect.fromCenter(center: Offset.zero, width: 230, height: 160));
    }
    canvas.drawPath(rPath, roadBorder);
    canvas.drawPath(rPath, roadPaint);
  }

  // =========================================================================
  // ⚽ MINI SPORTS TURF PITCH (FOOTBALL TURF WITH WHITE MARKINGS)
  // Strictly on green land! Never inside water bays or lagoons!
  // =========================================================================
  void _drawSportsTurfPitch(Canvas canvas) {
    Offset pitchCenter;
    switch (island.shapeStyle) {
      case IslandShapeStyle.crescentLagoon:
        pitchCenter = const Offset(0, -145); // Thick northern green cape
        break;
      case IslandShapeStyle.sCurveArchipelago:
        pitchCenter = const Offset(42, -65); // East green bend
        break;
      case IslandShapeStyle.starAtoll:
        pitchCenter = const Offset(0, -95); // North star arm
        break;
      case IslandShapeStyle.dualIsletBridge:
        pitchCenter = const Offset(-105, 25); // West islet green center
        break;
      default:
        pitchCenter = const Offset(20, -75);
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

    // 1. Moving Offshore Speedboat cruising in wide deep blue waters
    final t1 = (timeSeconds * 0.12) % (2 * math.pi);
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
    final t2 = (-timeSeconds * 0.08) % (2 * math.pi);
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
    final t3 = (timeSeconds * 0.09) % (2 * math.pi);
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
  static final Map<IslandShapeStyle, List<Path>> _cachedDistrictCells = {};

  void _draw35TerritorialDistricts(Canvas canvas) {
    final islandPath = _getIslandPath();
    final cells = _getOrComputeDistrictCells(island.shapeStyle);

    canvas.save();
    canvas.clipPath(islandPath);

    // 1. Subtle distinct territorial fill per district (alternating harmonious emerald & forest hues)
    final districtPaints = [
      Paint()..color = const Color(0xFF15803D).withValues(alpha: 0.28),
      Paint()..color = const Color(0xFF16A34A).withValues(alpha: 0.20),
      Paint()..color = const Color(0xFF047857).withValues(alpha: 0.26),
      Paint()..color = const Color(0xFF166534).withValues(alpha: 0.32),
      Paint()..color = const Color(0xFF0F766E).withValues(alpha: 0.22),
    ];

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

    canvas.restore();
  }

  static List<Path> _getOrComputeDistrictCells(IslandShapeStyle style) {
    if (_cachedDistrictCells.containsKey(style)) {
      return _cachedDistrictCells[style]!;
    }

    final coords = get35PlotCoordinates(style);
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

    _cachedDistrictCells[style] = paths;
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
  void _drawCitizenPlots(Canvas canvas) {
    final List<Offset> positions = get35PlotCoordinates(island.shapeStyle);
    final int count = math.min(35, positions.length);

    for (int i = 0; i < count; i++) {
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

      final day = plot.day;
      // Generous Cadastral Parcel Box (34.0 x 28.0)
      final parcelRect = Rect.fromCenter(center: pos, width: 34.0, height: 28.0);
      final housePos = pos.translate(day >= 31 ? 1.5 : 0.0, day >= 45 ? -2.5 : 0.0);

      // 1. Cadastral Demarcated Boundary Parcel (മാപ്പിൽ ജില്ലകൾ തിരിക്കുന്നതുപോലെ വരയിട്ട് തിരിച്ച ചുറ്റുമതിൽ)
      _drawCadastralBoundaryParcel(canvas, parcelRect, isSel, day);

      // 2. Driveway & Parked Vehicle (കാർപോർച്ചും വാഹനങ്ങളും - വ്യത്യസ്ത കാറുകൾ)
      _drawDrivewayAndCar(canvas, parcelRect, day, plotNumber);

      // 3. Swimming Pool with Sun Deck & Striped Beach Umbrella (സ്വിമ്മിംഗ് പൂളും ഡെക്കും)
      if (day >= 45) {
        _drawSwimmingPoolAndDeck(canvas, parcelRect, day, plotNumber);
      } else if (day >= 20) {
        // Garden Gazebo / Shed with yellow pitched roof (Image 2)
        _drawGardenGazebo(canvas, parcelRect, day);
      }

      // 4. Connecting Paved Footpaths (നടപ്പാതകൾ)
      _drawWalkwayPaths(canvas, parcelRect, housePos, day);

      // 5. 90-Day Progression Architectural Villa Roof (വ്യത്യസ്ത നിറങ്ങളും രൂപകൽപ്പനകളും!)
      _drawArchitecturalRoof(canvas, housePos, day, isSel, plotNumber);

      // 6. Estate Entrance Nameplate Signboard (ഒരു ബോർഡ് വെച്ചിട്ട് യൂസർ നെയിം എന്ന് എഴുതിയിട്ടുണ്ടാവും)
      _drawEstateNameBoard(canvas, parcelRect, plot, isSel);

      // 7. District Marker Badge in overview (#1, #2, ... #35)
      _drawDistrictMarkerBadge(canvas, pos, plotNumber, isSel);

      // 8. Courtyard Pet / Dog / Cat (Drifts peacefully in yard)
      final petT = timeSeconds * 0.8 + i;
      final petDriftX = math.cos(petT) * 1.8;
      final petDriftY = math.sin(petT) * 1.3;
      final petPos = pos.translate(-10.5 + petDriftX, 8.5 + petDriftY);
      final petColor = (i % 2 == 0) ? const Color(0xFFD97706) : const Color(0xFF475569);
      canvas.drawCircle(petPos, 0.95, Paint()..color = petColor);
      canvas.drawCircle(petPos.translate(0.5, 0.25), 0.6, Paint()..color = petColor);

      // 9. Golden Selection Beacon Aura
      if (isSel) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            parcelRect.inflate(2.5),
            const Radius.circular(5.0),
          ),
          Paint()
            ..color = const Color(0xFFFFD700)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
        canvas.drawCircle(
          pos,
          18.0,
          Paint()
            ..color = const Color(0xFFFFD700).withValues(alpha: 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
  }

  // 1. Cadastral Boundary Parcel Demarcation (ചുറ്റുമതിലും സ്വകാര്യ പുൽത്തകിടിയും)
  void _drawCadastralBoundaryParcel(Canvas canvas, Rect parcelRect, bool isSel, int day) {
    // Ground Shadow for boundary wall
    final wallShadow = parcelRect.translate(0.7, 0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(wallShadow, const Radius.circular(3.8)),
      Paint()..color = Colors.black26,
    );

    // Private Lawn Turf inside parcel
    final lawnPaint = Paint()
      ..color = isSel
          ? const Color(0xFFFFD700).withValues(alpha: 0.35)
          : (day >= 60 ? const Color(0xFF15803D) : const Color(0xFF16A34A))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(parcelRect, const Radius.circular(3.5)), lawnPaint);

    // Demarcated Boundary Partition Wall (Enclosure Wall ചുറ്റുമതിൽ)
    final boundaryWall = Paint()
      ..color = isSel
          ? const Color(0xFFFFD700)
          : const Color(0xFFF8FAFC) // Crisp limestone white boundary wall
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSel ? 2.0 : 1.15;
    canvas.drawRRect(RRect.fromRectAndRadius(parcelRect, const Radius.circular(3.5)), boundaryWall);

    // Corner Pillar Accents on boundary wall
    final pillarPaint = Paint()..color = isSel ? const Color(0xFFFFD700) : Colors.white;
    canvas.drawCircle(parcelRect.topLeft.translate(1.2, 1.2), 0.9, pillarPaint);
    canvas.drawCircle(parcelRect.topRight.translate(-1.2, 1.2), 0.9, pillarPaint);
    canvas.drawCircle(parcelRect.bottomLeft.translate(1.2, -1.2), 0.9, pillarPaint);
    canvas.drawCircle(parcelRect.bottomRight.translate(-1.2, -1.2), 0.9, pillarPaint);

    // Topiary hedge dots along outer boundary perimeter (Image 2 style)
    final hedgePaint = Paint()..color = const Color(0xFF14532D);
    for (double hx = parcelRect.left + 3.5; hx <= parcelRect.right - 3.5; hx += 4.5) {
      canvas.drawCircle(Offset(hx, parcelRect.top + 1.2), 0.85, hedgePaint);
      canvas.drawCircle(Offset(hx, parcelRect.bottom - 1.2), 0.85, hedgePaint);
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

  // 6. Estate Entrance Nameplate Signboard (ഒരു ബോർഡ് വെച്ചിട്ട് യൂസർ നെയിം എന്ന് എഴുതിയിട്ടുണ്ടാവും)
  void _drawEstateNameBoard(Canvas canvas, Rect parcelRect, CitizenPlot plot, bool isSel) {
    final boardCenter = Offset(parcelRect.left + 14.0, parcelRect.bottom - 2.8);
    final boardRect = Rect.fromCenter(center: boardCenter, width: 18.0, height: 4.8);

    // Signpost wooden/slate legs
    final postPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 0.7;
    canvas.drawLine(Offset(boardRect.left + 2.0, boardRect.bottom), Offset(boardRect.left + 2.0, boardRect.bottom + 2.2), postPaint);
    canvas.drawLine(Offset(boardRect.right - 2.0, boardRect.bottom), Offset(boardRect.right - 2.0, boardRect.bottom + 2.2), postPaint);

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
        ..strokeWidth = isSel ? 0.8 : 0.45,
    );

    // User Name Text on Estate Board
    final nameText = plot.userName.length > 8 ? '${plot.userName.substring(0, 8)}..' : plot.userName;
    final label = '#${plot.plotNumber} $nameText';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: isSel ? const Color(0xFFFFD700) : Colors.white,
          fontSize: 2.2,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(boardCenter.dx - tp.width / 2, boardCenter.dy - tp.height / 2));
  }

  // 7. District Marker Badge in overview (#1, #2, ... #35)
  void _drawDistrictMarkerBadge(Canvas canvas, Offset pos, int plotNumber, bool isSel) {
    final badgeCenter = pos.translate(-11.5, -9.5);
    canvas.drawCircle(badgeCenter.translate(0.3, 0.4), 3.2, Paint()..color = Colors.black26);
    canvas.drawCircle(badgeCenter, 3.0, Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.88));
    canvas.drawCircle(
      badgeCenter,
      3.0,
      Paint()
        ..color = isSel ? const Color(0xFFFFD700) : Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSel ? 1.0 : 0.6,
    );
    final badgeTp = TextPainter(
      text: TextSpan(
        text: '$plotNumber',
        style: TextStyle(
          color: isSel ? const Color(0xFFFFD700) : Colors.white,
          fontSize: 2.6,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    badgeTp.paint(canvas, Offset(badgeCenter.dx - badgeTp.width / 2, badgeCenter.dy - badgeTp.height / 2));
  }

  // 8. Architectural Top-Down Villa Roof with 90-Day Progression & Diverse Colors
  void _drawArchitecturalRoof(Canvas canvas, Offset pos, int day, bool isSel, int plotNumber) {
    // Soft 3D drop shadow underneath the entire roof structure
    final roofShadowPaint = Paint()..color = Colors.black45;

    // 5 Distinct Roof Tile Palettes across the 35 houses so adjacent houses never look identical!
    final colorVariant = (plotNumber * 7 + day) % 5;
    Color roofBase;
    Color ridgeHighlight;

    if (isSel) {
      roofBase = const Color(0xFFFFD700);
      ridgeHighlight = const Color(0xFFFFF9C4);
    } else {
      switch (colorVariant) {
        case 0: // Classic Terracotta Orange
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

    if (day <= 15) {
      // -------------------------------------------------------------
      // LEVEL 1 (Day 1 - 15): Compact Starter Cottage
      // -------------------------------------------------------------
      final roofRect = Rect.fromCenter(center: pos, width: 11.0, height: 9.0);
      // Shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(roofRect.translate(0.8, 1.0), const Radius.circular(1.4)),
        roofShadowPaint,
      );
      // Roof Body
      canvas.drawRRect(
        RRect.fromRectAndRadius(roofRect, const Radius.circular(1.2)),
        Paint()..color = roofBase,
      );
      // Hipped Ridge Lines
      final ridge = Paint()
        ..color = ridgeHighlight
        ..strokeWidth = 0.85
        ..style = PaintingStyle.stroke;
      canvas.drawLine(pos.translate(-2.2, 0), pos.translate(2.2, 0), ridge);
      canvas.drawLine(pos.translate(-2.2, 0), roofRect.topLeft, ridge);
      canvas.drawLine(pos.translate(-2.2, 0), roofRect.bottomLeft, ridge);
      canvas.drawLine(pos.translate(2.2, 0), roofRect.topRight, ridge);
      canvas.drawLine(pos.translate(2.2, 0), roofRect.bottomRight, ridge);

      // Single Chimney
      _drawChimney(canvas, pos.translate(2.5, -2.2));

    } else if (day <= 30) {
      // -------------------------------------------------------------
      // LEVEL 2 (Day 16 - 30): Suburban Ranch House with Skylight
      // -------------------------------------------------------------
      final roofRect = Rect.fromCenter(center: pos, width: 14.0, height: 10.5);
      // Shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(roofRect.translate(0.9, 1.1), const Radius.circular(1.5)),
        roofShadowPaint,
      );
      // Roof Body
      canvas.drawRRect(
        RRect.fromRectAndRadius(roofRect, const Radius.circular(1.2)),
        Paint()..color = roofBase,
      );
      // Hipped Ridge Lines
      final ridge = Paint()
        ..color = ridgeHighlight
        ..strokeWidth = 0.9
        ..style = PaintingStyle.stroke;
      canvas.drawLine(pos.translate(-3.2, 0), pos.translate(3.2, 0), ridge);
      canvas.drawLine(pos.translate(-3.2, 0), roofRect.topLeft, ridge);
      canvas.drawLine(pos.translate(-3.2, 0), roofRect.bottomLeft, ridge);
      canvas.drawLine(pos.translate(3.2, 0), roofRect.topRight, ridge);
      canvas.drawLine(pos.translate(3.2, 0), roofRect.bottomRight, ridge);

      // 1 Skylight Window on sunny slope (Image 2)
      _drawSkylight(canvas, pos.translate(-1.0, -2.5));

      // Chimney
      _drawChimney(canvas, pos.translate(3.6, -2.4));

    } else if (day <= 60) {
      // -------------------------------------------------------------
      // LEVEL 3 (Day 31 - 60): L-Shaped Executive Villa (Image 2 Iconic Shape!)
      // -------------------------------------------------------------
      final isLeftWing = (plotNumber % 2 == 0);
      final mainRect = Rect.fromCenter(center: pos.translate(1.0, -1.5), width: 15.0, height: 8.5);
      final wingRect = Rect.fromCenter(
        center: pos.translate(isLeftWing ? -3.0 : 5.0, 3.5),
        width: 7.0,
        height: 11.5,
      );

      // Composite Drop Shadow
      final shadowPath = Path()
        ..addRRect(RRect.fromRectAndRadius(mainRect.translate(0.9, 1.1), const Radius.circular(1.4)))
        ..addRRect(RRect.fromRectAndRadius(wingRect.translate(0.9, 1.1), const Radius.circular(1.4)));
      canvas.drawPath(shadowPath, roofShadowPaint);

      // Roof Wings
      final roofPaint = Paint()..color = roofBase;
      canvas.drawRRect(RRect.fromRectAndRadius(mainRect, const Radius.circular(1.2)), roofPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(wingRect, const Radius.circular(1.2)), roofPaint);

      // Hipped Ridges
      final ridge = Paint()
        ..color = ridgeHighlight
        ..strokeWidth = 0.9
        ..style = PaintingStyle.stroke;

      // Main Wing Ridge
      canvas.drawLine(mainRect.center.translate(-3.0, 0), mainRect.center.translate(4.0, 0), ridge);
      canvas.drawLine(mainRect.center.translate(4.0, 0), mainRect.topRight, ridge);
      canvas.drawLine(mainRect.center.translate(4.0, 0), mainRect.bottomRight, ridge);

      // Side Wing Ridge
      canvas.drawLine(wingRect.center.translate(0, -2.5), wingRect.center.translate(0, 3.5), ridge);
      canvas.drawLine(wingRect.center.translate(0, 3.5), wingRect.bottomLeft, ridge);
      canvas.drawLine(wingRect.center.translate(0, 3.5), wingRect.bottomRight, ridge);

      // 2 Blue Skylight Windows on main roof (Image 2)
      _drawSkylight(canvas, mainRect.center.translate(0.5, -2.2));
      _drawSkylight(canvas, mainRect.center.translate(3.5, -2.2));

      // Chimney
      _drawChimney(canvas, mainRect.center.translate(4.8, 2.2));

    } else if (day <= 89) {
      // -------------------------------------------------------------
      // LEVEL 4 (Day 61 - 89): Luxury Multi-Wing Estate Compound (Image 1 & 2)
      // -------------------------------------------------------------
      final mainRect = Rect.fromCenter(center: pos.translate(0.0, -2.0), width: 17.5, height: 9.0);
      final westWing = Rect.fromCenter(center: pos.translate(-4.5, 3.5), width: 8.5, height: 11.0);
      final eastPorch = Rect.fromCenter(center: pos.translate(5.0, 2.0), width: 6.5, height: 6.5);

      // Compound Shadow
      final shadowPath = Path()
        ..addRRect(RRect.fromRectAndRadius(mainRect.translate(1.0, 1.2), const Radius.circular(1.5)))
        ..addRRect(RRect.fromRectAndRadius(westWing.translate(1.0, 1.2), const Radius.circular(1.5)))
        ..addRRect(RRect.fromRectAndRadius(eastPorch.translate(1.0, 1.2), const Radius.circular(1.5)));
      canvas.drawPath(shadowPath, roofShadowPaint);

      // Roof Bodies
      final roofPaint = Paint()..color = roofBase;
      canvas.drawRRect(RRect.fromRectAndRadius(mainRect, const Radius.circular(1.2)), roofPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(westWing, const Radius.circular(1.2)), roofPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(eastPorch, const Radius.circular(1.2)), roofPaint);

      // Hipped Ridge Highlights
      final ridge = Paint()
        ..color = ridgeHighlight
        ..strokeWidth = 0.95
        ..style = PaintingStyle.stroke;

      // Main Ridge
      canvas.drawLine(mainRect.center.translate(-4.0, 0), mainRect.center.translate(5.0, 0), ridge);
      canvas.drawLine(mainRect.center.translate(5.0, 0), mainRect.topRight, ridge);
      canvas.drawLine(mainRect.center.translate(5.0, 0), mainRect.bottomRight, ridge);

      // West Wing Ridge
      canvas.drawLine(westWing.center.translate(0, -2.5), westWing.center.translate(0, 3.5), ridge);
      canvas.drawLine(westWing.center.translate(0, 3.5), westWing.bottomLeft, ridge);
      canvas.drawLine(westWing.center.translate(0, 3.5), westWing.bottomRight, ridge);

      // 3 Blue Skylights (Image 2)
      _drawSkylight(canvas, mainRect.center.translate(-1.5, -2.3));
      _drawSkylight(canvas, mainRect.center.translate(1.8, -2.3));
      _drawSkylight(canvas, mainRect.center.translate(5.0, -2.3));

      // Dual Chimneys
      _drawChimney(canvas, mainRect.center.translate(-5.5, 2.0));
      _drawChimney(canvas, mainRect.center.translate(6.0, 2.0));

    } else {
      // -------------------------------------------------------------
      // LEVEL 5 (Day 90 / Max Streak): Sovereign Grand Palace Manor (U-Shape)
      // -------------------------------------------------------------
      final centerHall = Rect.fromCenter(center: pos.translate(0, -3.5), width: 19.0, height: 9.5);
      final leftWing = Rect.fromCenter(center: pos.translate(-6.0, 2.5), width: 7.5, height: 13.0);
      final rightWing = Rect.fromCenter(center: pos.translate(6.0, 2.5), width: 7.5, height: 13.0);

      // Sovereign Shadow
      final shadowPath = Path()
        ..addRRect(RRect.fromRectAndRadius(centerHall.translate(1.2, 1.4), const Radius.circular(1.8)))
        ..addRRect(RRect.fromRectAndRadius(leftWing.translate(1.2, 1.4), const Radius.circular(1.8)))
        ..addRRect(RRect.fromRectAndRadius(rightWing.translate(1.2, 1.4), const Radius.circular(1.8)));
      canvas.drawPath(shadowPath, roofShadowPaint);

      // Grand Terracotta Palace Wings
      final roofPaint = Paint()..color = roofBase;
      canvas.drawRRect(RRect.fromRectAndRadius(centerHall, const Radius.circular(1.5)), roofPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(leftWing, const Radius.circular(1.5)), roofPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rightWing, const Radius.circular(1.5)), roofPaint);

      // Sovereign Golden Hip Ridge Lines
      final ridge = Paint()
        ..color = const Color(0xFFFFD700)
        ..strokeWidth = 1.1
        ..style = PaintingStyle.stroke;

      canvas.drawLine(centerHall.center.translate(-5.5, 0), centerHall.center.translate(5.5, 0), ridge);
      canvas.drawLine(leftWing.center.translate(0, -3.5), leftWing.center.translate(0, 4.5), ridge);
      canvas.drawLine(rightWing.center.translate(0, -3.5), rightWing.center.translate(0, 4.5), ridge);

      // 4 Cyan Skylights
      _drawSkylight(canvas, centerHall.center.translate(-3.0, -2.5));
      _drawSkylight(canvas, centerHall.center.translate(3.0, -2.5));
      _drawSkylight(canvas, leftWing.center.translate(0, 3.0));
      _drawSkylight(canvas, rightWing.center.translate(0, 3.0));

      // Dual Grand Chimneys
      _drawChimney(canvas, centerHall.center.translate(-6.5, -2.5));
      _drawChimney(canvas, centerHall.center.translate(6.5, -2.5));

      // Golden Sovereign Prestige Crest atop central ridge
      canvas.drawCircle(centerHall.center, 1.2, Paint()..color = const Color(0xFFFFD700));
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
  // 📍 50 CITIZEN PLOT COORDINATES (100% Strictly Inland on Solid Green Landmass)
  // Houses NEVER touch the ocean or water lagoon! Guaranteed dry inland plots!
  // =========================================================================
  // 📍 35 CITIZEN PLOT COORDINATES (100% Strictly Inland on Solid Green Landmass)
  // 35 generous parcels per island with cadastral boundary walls!
  // =========================================================================
  static List<Offset> get35PlotCoordinates(IslandShapeStyle style) {
    final List<Offset> coords = [];

    switch (style) {
      case IslandShapeStyle.crescentLagoon:
        // 🌙 Crescent Green Belt: 35 plots distributed safely across the 3 thick green sectors
        // 1. West Green Arm (11 plots: x = -175..-145, y = -105..+15)
        for (int i = 0; i < 11; i++) {
          final t = i / 10.0;
          final y = -100.0 + t * 110.0;
          final xBase = -165.0 - math.sin(t * math.pi) * 10.0;
          final lane = (i % 2 == 0 ? -10.0 : 10.0);
          coords.add(Offset(xBase + lane, y));
        }
        // 2. North Green Cape (13 plots: x = -100..+100, y = -180..-135)
        for (int i = 0; i < 13; i++) {
          final t = i / 12.0;
          final x = -95.0 + t * 190.0;
          final yBase = -166.0 + (x * x) / 600.0;
          final lane = (i % 2 == 0 ? -10.0 : 10.0);
          coords.add(Offset(x, yBase + lane));
        }
        // 3. East Green Peninsula (11 plots: x = 145..195, y = -75..+120)
        for (int i = 0; i < 11; i++) {
          final t = i / 10.0;
          final y = -70.0 + t * 190.0;
          final xBase = 168.0 + math.sin(t * math.pi) * 12.0;
          final lane = (i % 2 == 0 ? -10.0 : 10.0);
          coords.add(Offset(xBase + lane, y));
        }
        break;

      case IslandShapeStyle.sCurveArchipelago:
        // 🐉 Expansive S-Curve dragon spine: 2 parallel lanes (17 West lane, 18 East lane = 35 total)
        for (int i = 0; i < 17; i++) {
          final t = (i / 16.0) * 2.0 - 1.0;
          final y = t * 150.0;
          final xCenter = 44.0 * math.sin(t * math.pi);
          coords.add(Offset(xCenter - 16.0, y));
        }
        for (int i = 0; i < 18; i++) {
          final t = (i / 17.0) * 2.0 - 1.0;
          final y = t * 150.0;
          final xCenter = 44.0 * math.sin(t * math.pi);
          coords.add(Offset(xCenter + 16.0, y));
        }
        break;

      case IslandShapeStyle.starAtoll:
        // ⭐ 7 plots on each of the 5 coral star arms = 35 plots total
        for (int k = 0; k < 5; k++) {
          final angle = (k * 2 * math.pi / 5) - math.pi / 2;
          final perp = angle + math.pi / 2;
          for (int j = 0; j < 7; j++) {
            final r = 74.0 + j * 12.5;
            final offset = (j % 2 == 0 ? -9.5 : 9.5);
            final x = r * math.cos(angle) + offset * math.cos(perp);
            final y = r * math.sin(angle) + offset * math.sin(perp);
            coords.add(Offset(x, y));
          }
        }
        break;

      case IslandShapeStyle.dualIsletBridge:
        // 🏝️ 18 plots in West Islet core, 17 plots in East Islet core = 35 total
        for (int i = 0; i < 18; i++) {
          final row = i ~/ 6;
          final col = i % 6;
          coords.add(Offset(-130.0 + col * 16.0, -28.0 + row * 18.0));
        }
        for (int i = 0; i < 17; i++) {
          final row = i ~/ 6;
          final col = i % 6;
          coords.add(Offset(74.0 + col * 16.0, -28.0 + row * 18.0));
        }
        break;

      case IslandShapeStyle.ringAtoll:
        // ⭕ Concentric rings safely within circular green body (17 inner, 18 outer = 35 total)
        for (int i = 0; i < 17; i++) {
          final angle = (i * 2 * math.pi / 17) - math.pi / 2;
          coords.add(Offset(118.0 * math.cos(angle) + 10, 118.0 * math.sin(angle) * 0.95 + 10));
        }
        for (int i = 0; i < 18; i++) {
          final angle = (i * 2 * math.pi / 18) - math.pi / 2;
          coords.add(Offset(146.0 * math.cos(angle) + 10, 146.0 * math.sin(angle) * 0.95 + 10));
        }
        break;

      case IslandShapeStyle.hookPeninsula:
        // 🪝 35 plots firmly inside the J-hook land ridge
        for (int i = 0; i < 35; i++) {
          final t = i / 34.0;
          final offsetSide = (i % 2 == 0 ? -11.0 : 11.0);
          if (t < 0.45) {
            final subT = t / 0.45;
            coords.add(Offset(-35.0 + subT * 75.0 + offsetSide, -110.0 + subT * 105.0));
          } else {
            final subT = (t - 0.45) / 0.55;
            final angle = subT * math.pi * 0.95;
            coords.add(Offset(40.0 + 50.0 * math.sin(angle) + offsetSide, -5.0 + subT * 135.0));
          }
        }
        break;

      case IslandShapeStyle.heartSanctuary:
        // ❤️ 18 Left atrium, 17 Right atrium = 35 total
        for (int i = 0; i < 18; i++) {
          final col = i % 6;
          final row = i ~/ 6;
          coords.add(Offset(-78.0 + col * 13.0, -42.0 + row * 18.0));
        }
        for (int i = 0; i < 17; i++) {
          final col = i % 6;
          final row = i ~/ 6;
          coords.add(Offset(22.0 + col * 13.0, -42.0 + row * 18.0));
        }
        break;

      case IslandShapeStyle.cloverBays:
        // ☘️ 12 Top lobe, 12 Right lobe, 11 Left lobe = 35 total
        for (int i = 0; i < 12; i++) {
          final r = 24.0 + (i % 3) * 11.0;
          final a = (i / 11.0) * math.pi - math.pi;
          coords.add(Offset(r * math.cos(a), -70.0 + r * math.sin(a)));
        }
        for (int i = 0; i < 12; i++) {
          final r = 24.0 + (i % 3) * 11.0;
          final a = (i / 11.0) * math.pi - math.pi / 4;
          coords.add(Offset(55.0 + r * math.cos(a), 48.0 + r * math.sin(a)));
        }
        for (int i = 0; i < 11; i++) {
          final r = 24.0 + (i % 3) * 11.0;
          final a = (i / 10.0) * math.pi - 3 * math.pi / 4;
          coords.add(Offset(-55.0 + r * math.cos(a), 48.0 + r * math.sin(a)));
        }
        break;

      case IslandShapeStyle.fortressPlateau:
        // 💎 Diamond grid safely inside hexagonal plateau core: 35 plots in 5x7 grid
        for (int i = 0; i < 35; i++) {
          final row = i ~/ 7;
          final col = i % 7;
          final x = (col - 3) * 23.0;
          final y = (row - 2) * 23.0;
          coords.add(Offset(x, y));
        }
        break;

      default:
        // General safe internal grid: 35 plots in 5 rows of 7
        for (int i = 0; i < 35; i++) {
          final row = i ~/ 7;
          final col = i % 7;
          coords.add(Offset(-66.0 + col * 22.0, -44.0 + row * 22.0));
        }
        break;
    }

    return coords;
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
