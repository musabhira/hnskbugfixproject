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
  final List<CitizenPlot> plots;
  final ValueChanged<CitizenPlot>? onPlotTapped;
  final int? selectedPlotNumber;

  const IslandAerialViewWidget({
    super.key,
    required this.island,
    this.isInteractive = false,
    this.plots = const [],
    this.onPlotTapped,
    this.selectedPlotNumber,
  });

  @override
  State<IslandAerialViewWidget> createState() => _IslandAerialViewWidgetState();
}

class _IslandAerialViewWidgetState extends State<IslandAerialViewWidget> {
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
              plots: widget.plots,
              selectedPlotNumber: widget.selectedPlotNumber,
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
    // Scale factor calibrated for the expansive island canvas
    final scale = math.min(size.width, size.height) / 540.0;

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
  final List<CitizenPlot> plots;
  final int? selectedPlotNumber;

  IslandAerialPainter({
    required this.island,
    this.isInteractive = false,
    this.plots = const [],
    this.selectedPlotNumber,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Infinite Seamless Ocean
    _drawInfiniteOcean(canvas, size);

    final cx = size.width / 2;
    final cy = size.height / 2;
    // Vast island canvas scale factor
    final scale = math.min(size.width, size.height) / 540.0;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    // 2. Satellite Small Islets (for organic archipelago beauty)
    if (!island.isPresidential) {
      _drawSatelliteIslets(canvas);
    }

    // 3. Shallow Cyan Reef Contour (Translucent turquoise water)
    _drawShallowCoralReef(canvas);

    // 4. Sandy Golden Shoreline Beach
    _drawSandyBeach(canvas);

    // 5. Expansive Lush Tropical Green Island Body (Generous landmass)
    _drawGreenIslandBody(canvas);

    // 6. Central Lagoon / Saltwater Pool (if applicable)
    _drawInteriorWaterBody(canvas);

    // 7. Winding Paved Trails & Roadways
    _drawRoadways(canvas);

    // 8. Wooden Pier with Moored Speedboats & Yachts
    _drawWoodenPierAndBoats(canvas);

    // 9. Habit Houses / Plots (Strictly inside the green landmass with safe buffer)
    if (island.isPresidential) {
      _drawPresidentialCitadel(canvas);
    } else {
      _draw50HabitHousePlots(canvas);
    }

    // 10. Clustered Palm Tree Canopies
    _drawPalmTreeCanopies(canvas);

    // 11. Beach Umbrellas along the Sand
    _drawBeachUmbrellas(canvas);

    canvas.restore();
  }

  // =========================================================================
  // 🌊 INFINITE OCEAN BACKGROUND (Prevents breaking on zoom out)
  // =========================================================================
  void _drawInfiniteOcean(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    final oceanGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.35,
      colors: [
        island.waterColor.withValues(alpha: 0.96),
        Color.lerp(island.waterColor, const Color(0xFF03045E), 0.52) ?? const Color(0xFF0284C7),
        const Color(0xFF070E22), // Abyssal navy edge
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final oceanPaint = Paint()..shader = oceanGradient.createShader(fullRect);
    canvas.drawRect(fullRect, oceanPaint);

    // Subtle gentle wave crest arcs across the open waters
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 9; i++) {
      final angle = (i * 0.85);
      final rx = size.width * (0.15 + (i % 4) * 0.25);
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
  // 3. REEF, BEACH & GREEN TERRAIN
  // =========================================================================
  void _drawShallowCoralReef(Canvas canvas) {
    final islandPath = _getIslandPath();

    final reefPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 42
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(islandPath, reefPaint);

    final reefInnerPaint = Paint()
      ..color = const Color(0xFF67E8F9).withValues(alpha: 0.52)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(islandPath, reefInnerPaint);
  }

  void _drawSandyBeach(Canvas canvas) {
    final islandPath = _getIslandPath();

    final sandPaint = Paint()
      ..color = const Color(0xFFFDE68A) // Golden tropical sand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(islandPath, sandPaint);

    final wetSandPaint = Paint()
      ..color = const Color(0xFFFCD34D) // Wet shoreline sand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawPath(islandPath, wetSandPaint);
  }

  void _drawGreenIslandBody(Canvas canvas) {
    final islandPath = _getIslandPath();

    final landGradient = RadialGradient(
      center: const Alignment(-0.1, -0.2),
      radius: 0.95,
      colors: [
        const Color(0xFF4ADE80), // Sunlit bright lush green
        island.landColor,        // Island signature forest green
        Color.lerp(island.landColor, const Color(0xFF064E3B), 0.45) ?? const Color(0xFF14532D),
      ],
      stops: const [0.0, 0.55, 1.0],
    );

    final landPaint = Paint()
      ..shader = landGradient.createShader(Rect.fromCircle(center: Offset.zero, radius: 220))
      ..style = PaintingStyle.fill;

    canvas.drawPath(islandPath, landPaint);
  }

  void _drawInteriorWaterBody(Canvas canvas) {
    if (island.isPresidential) return;

    final lagoonPaint = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final lagoonSandRim = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    if (island.shapeStyle == IslandShapeStyle.ringAtoll ||
        island.shapeStyle == IslandShapeStyle.crescentLagoon) {
      final lagoonPath = Path();
      lagoonPath.addOval(Rect.fromCenter(center: const Offset(15, 15), width: 110, height: 80));
      canvas.drawPath(lagoonPath, lagoonSandRim);
      canvas.drawPath(lagoonPath, lagoonPaint);
    } else if (island.shapeStyle == IslandShapeStyle.starAtoll) {
      final lagoonPath = Path();
      lagoonPath.addOval(Rect.fromCenter(center: Offset.zero, width: 65, height: 65));
      canvas.drawPath(lagoonPath, lagoonSandRim);
      canvas.drawPath(lagoonPath, lagoonPaint);
    }
  }

  void _drawRoadways(Canvas canvas) {
    final roadPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
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
    canvas.drawPath(rPath, roadPaint);
  }

  void _drawWoodenPierAndBoats(Canvas canvas) {
    final pierPaint = Paint()
      ..color = const Color(0xFF92400E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.square;

    if (island.isPresidential) {
      // Royal Pier
      canvas.drawLine(const Offset(-125, 0), const Offset(-180, 0), pierPaint);
      canvas.drawLine(const Offset(-180, -28), const Offset(-180, 28), pierPaint);
      _drawYacht(canvas, const Offset(-198, 0), angle: -math.pi / 2, isGold: true);
    } else {
      // East Side Marina
      canvas.drawLine(const Offset(155, 20), const Offset(215, 20), pierPaint);
      canvas.drawLine(const Offset(215, -12), const Offset(215, 52), pierPaint);
      _drawYacht(canvas, const Offset(228, 2), angle: 0);
      _drawYacht(canvas, const Offset(228, 38), angle: 0);
      _drawYacht(canvas, const Offset(185, -35), angle: -0.35);
    }
  }

  void _drawYacht(Canvas canvas, Offset pos, {double angle = 0, bool isGold = false}) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    final hullPath = Path();
    hullPath.moveTo(-11, -5);
    hullPath.lineTo(5, -5);
    hullPath.lineTo(14, 0); // Bow
    hullPath.lineTo(5, 5);
    hullPath.lineTo(-11, 5);
    hullPath.close();

    final hullPaint = Paint()..color = isGold ? const Color(0xFFFFD700) : Colors.white;
    canvas.drawPath(hullPath, hullPaint);

    final deckPaint = Paint()..color = isGold ? Colors.black87 : const Color(0xFF0284C7);
    canvas.drawRect(const Rect.fromLTWH(-4, -3, 8, 6), deckPaint);

    canvas.restore();
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

      if (!isInteractive) {
        // 🔭 FAR AWAY / OVERVIEW MODE (LOD: Elegant glowing homestead dot nestled in greenery)
        final dotPaint = Paint()
          ..color = isSel
              ? const Color(0xFFFFD700)
              : (plot.day >= 90
                  ? const Color(0xFFFFD700)
                  : (plot.day >= 60 ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.9)));
        canvas.drawCircle(pos, 3.2, Paint()..color = Colors.black26); // Drop shadow
        canvas.drawCircle(pos, 2.8, dotPaint);
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

  /// 🏛️ Top-Down Habit House Roof based on Day 1-90 Progression
  void _drawTopDownHabitHouse(Canvas canvas, Offset pos, int day, bool isSelected) {
    if (day <= 15) {
      // ⛺ Stage 1 (Day 1-15): Starter Camp / Wooden Thatched Cottage
      final roofPaint = Paint()..color = const Color(0xFFD97706);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: 12, height: 10), const Radius.circular(2)),
        roofPaint,
      );
      canvas.drawLine(pos.translate(-5, 0), pos.translate(5, 0), Paint()..color = const Color(0xFF78350F)..strokeWidth = 1.0);
    } else if (day <= 35) {
      // 🏡 Stage 2 (Day 16-35): Terracotta Stone Villa with Chimney
      final roofPaint = Paint()..color = const Color(0xFFEA580C);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: 14, height: 12), const Radius.circular(2)),
        roofPaint,
      );
      canvas.drawLine(pos.translate(-5.5, 0), pos.translate(5.5, 0), Paint()..color = Colors.white54..strokeWidth = 1.2);
      canvas.drawCircle(pos.translate(3.5, -3.5), 1.8, Paint()..color = const Color(0xFF475569));
    } else if (day <= 60) {
      // 🏢 Stage 3 (Day 36-60): Modern Executive Villa with Private Swimming Pool
      final villaPaint = Paint()..color = const Color(0xFFF8FAFC);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos.translate(-2, 0), width: 12, height: 13), const Radius.circular(2)),
        villaPaint,
      );
      final poolPaint = Paint()..color = const Color(0xFF06B6D4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos.translate(5.5, 0), width: 5.5, height: 10), const Radius.circular(1.5)),
        poolPaint,
      );
    } else if (day <= 89) {
      // 🏰 Stage 4 (Day 61-89): Luxury Glass Manor with Skylight & Pool
      final manorPaint = Paint()..color = const Color(0xFF0284C7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos.translate(-2, 0), width: 14, height: 14), const Radius.circular(2.5)),
        manorPaint,
      );
      canvas.drawLine(pos.translate(-7, 0), pos.translate(3, 0), Paint()..color = Colors.white70..strokeWidth = 0.8);
      canvas.drawLine(pos.translate(-2, -5), pos.translate(-2, 5), Paint()..color = Colors.white70..strokeWidth = 0.8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos.translate(6.5, 0), width: 6, height: 12), const Radius.circular(1.5)),
        Paint()..color = const Color(0xFF38BDF8),
      );
    } else {
      // 👑 Stage 5 (Day 90): Sovereign Golden Apex Palace
      final goldPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawCircle(pos, 8.5, goldPaint);
      canvas.drawCircle(pos, 4.5, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(pos, 2.0, Paint()..color = Colors.white);
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

  void _drawPalmTreeCanopies(Canvas canvas) {
    final List<Offset> trees = island.isPresidential
        ? [
            const Offset(-80, -65), const Offset(80, -65),
            const Offset(-80, 65), const Offset(80, 65),
            const Offset(0, 95), const Offset(-105, 0),
          ]
        : [
            const Offset(-145, -45), const Offset(-135, 0), const Offset(-135, 45),
            const Offset(130, -65), const Offset(135, 65), const Offset(0, 120),
            const Offset(-55, 115), const Offset(65, 115),
          ];

    for (final pos in trees) {
      canvas.drawCircle(pos.translate(2.0, 2.5), 9.0, Paint()..color = Colors.black26);
      canvas.drawCircle(pos, 8.5, Paint()..color = const Color(0xFF15803D));
      canvas.drawCircle(pos.translate(-1.0, -1.0), 6.0, Paint()..color = const Color(0xFF22C55E));
    }
  }

  void _drawBeachUmbrellas(Canvas canvas) {
    final List<Offset> umbrellas = island.isPresidential
        ? [const Offset(105, -15), const Offset(105, 15)]
        : [
            const Offset(-170, -85), const Offset(-165, 85),
            const Offset(165, -85), const Offset(160, 90),
          ];

    for (int i = 0; i < umbrellas.length; i++) {
      final pos = umbrellas[i];
      canvas.drawCircle(pos, 5.5, Paint()..color = i.isEven ? const Color(0xFFEF4444) : const Color(0xFF3B82F6));
      canvas.drawCircle(pos, 1.8, Paint()..color = Colors.white);
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
        oldDelegate.plots != plots;
  }

  // =========================================================================
  // 📍 50 PRE-CALCULATED PLOT COORDINATES (STRICTLY INSIDE GREEN LANDMASS)
  // Houses NEVER touch the ocean or beach! Generous lawn spacing!
  // =========================================================================
  static List<Offset> get50PlotCoordinates(IslandShapeStyle style) {
    final List<Offset> coords = [];

    switch (style) {
      case IslandShapeStyle.crescentLagoon:
        // Distributed safely along the deep green crescent arch
        for (int i = 0; i < 50; i++) {
          final t = (i / 49.0);
          final angle = -math.pi * 0.82 + t * math.pi * 1.50;
          final r = 90.0 + (i % 3) * 16.0;
          coords.add(Offset(r * math.cos(angle) - 15, r * math.sin(angle) * 0.95 + 10));
        }
        break;

      case IslandShapeStyle.sCurveArchipelago:
        // Distributed safely along the deep S-curve spine
        for (int i = 0; i < 50; i++) {
          final t = (i / 49.0) * 2 * math.pi - math.pi;
          final x = 65.0 * math.sin(t) + ((i % 2 == 0) ? -14 : 14);
          final y = (i - 25) * 6.5;
          coords.add(Offset(x, y));
        }
        break;

      case IslandShapeStyle.starAtoll:
        // 10 plots on each of the 5 coral star arms, safely inside the green
        for (int i = 0; i < 50; i++) {
          final arm = i % 5;
          final armIdx = i ~/ 5;
          final angle = (arm * 2 * math.pi / 5) - math.pi / 2;
          final r = 50.0 + armIdx * 11.5;
          coords.add(Offset(r * math.cos(angle), r * math.sin(angle)));
        }
        break;

      case IslandShapeStyle.dualIsletBridge:
        // 25 plots safely on West Islet, 25 safely on East Islet
        for (int i = 0; i < 25; i++) {
          final row = i ~/ 5;
          final col = i % 5;
          coords.add(Offset(-160.0 + col * 22.0, -55.0 + row * 24.0));
        }
        for (int i = 0; i < 25; i++) {
          final row = i ~/ 5;
          final col = i % 5;
          coords.add(Offset(60.0 + col * 22.0, -55.0 + row * 24.0));
        }
        break;

      case IslandShapeStyle.ringAtoll:
        // Circular ring well inside the green belt surrounding the central lagoon
        for (int i = 0; i < 50; i++) {
          final angle = (i * 2 * math.pi / 50) - math.pi / 2;
          final r = 95.0 + (i % 2) * 20.0;
          coords.add(Offset(r * math.cos(angle) + 12, r * math.sin(angle) * 0.95 + 12));
        }
        break;

      case IslandShapeStyle.hookPeninsula:
        // Safely inside the J-hook land ridge
        for (int i = 0; i < 50; i++) {
          final t = i / 49.0;
          if (t < 0.45) {
            final subT = t / 0.45;
            coords.add(Offset(-55.0 + subT * 115.0, -155.0 + subT * 150.0 + ((i % 2 == 0) ? -10 : 10)));
          } else {
            final subT = (t - 0.45) / 0.55;
            final angle = subT * math.pi;
            coords.add(Offset(60.0 + 75.0 * math.sin(angle), -5.0 + subT * 190.0));
          }
        }
        break;

      case IslandShapeStyle.heartSanctuary:
        // Safely inside the parametric heart lobes
        for (int i = 0; i < 50; i++) {
          final t = (i / 49.0) * 2 * math.pi;
          final x = 95.0 * math.sin(t) * math.sin(t) * math.sin(t);
          final y = -80.0 * math.cos(t) + 30.0 * math.cos(2 * t) + 14.0 * math.cos(3 * t) + 7.0 * math.cos(4 * t);
          coords.add(Offset(x, y + 20));
        }
        break;

      case IslandShapeStyle.cloverBays:
        // 16 on Top Lobe, 17 on Bottom Right, 17 on Bottom Left
        for (int i = 0; i < 16; i++) {
          final r = 32.0 + (i % 3) * 14.0;
          final a = (i / 15.0) * math.pi - math.pi;
          coords.add(Offset(r * math.cos(a), -95.0 + r * math.sin(a)));
        }
        for (int i = 0; i < 17; i++) {
          final r = 32.0 + (i % 3) * 14.0;
          final a = (i / 16.0) * math.pi - math.pi / 4;
          coords.add(Offset(75.0 + r * math.cos(a), 65.0 + r * math.sin(a)));
        }
        for (int i = 0; i < 17; i++) {
          final r = 32.0 + (i % 3) * 14.0;
          final a = (i / 16.0) * math.pi - 3 * math.pi / 4;
          coords.add(Offset(-75.0 + r * math.cos(a), 65.0 + r * math.sin(a)));
        }
        break;

      case IslandShapeStyle.fortressPlateau:
        // Diamond grid safely inside the plateau
        for (int i = 0; i < 50; i++) {
          final row = i ~/ 7;
          final col = i % 7;
          final x = (col - 3) * 34.0;
          final y = (row - 3) * 34.0;
          if (x.abs() + y.abs() <= 160) {
            coords.add(Offset(x, y));
          } else {
            coords.add(Offset(x * 0.65, y * 0.65));
          }
        }
        break;

      default:
        // General safe internal grid with generous spacing
        for (int i = 0; i < 50; i++) {
          final row = i ~/ 8;
          final col = i % 8;
          coords.add(Offset(-105.0 + col * 30.0, -75.0 + row * 26.0));
        }
        break;
    }

    return coords;
  }
}
