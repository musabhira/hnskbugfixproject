import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'poket_cosmos_models.dart';

/// 🏝️ Aerial Top-Down Island View Widget with 50 Top-Down Habit Houses,
/// Multiple Distinct Architectural Island Shapes (Crescent, S-Curve, Star, Dual-Islet,
/// Ring Atoll, Hook, Heart, Clover, Fortress, and President's Grand Golden Citadel),
/// and Deep Zoom Plot Inspection.
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
    final scale = math.min(size.width, size.height) / 420.0;

    // Convert local tap position into island canvas coordinates
    final islandX = (details.localPosition.dx - cx) / scale;
    final islandY = (details.localPosition.dy - cy) / scale;
    final tapPoint = Offset(islandX, islandY);

    // Find closest plot within hit radius
    CitizenPlot? hitPlot;
    double minDistance = 22.0; // Hit threshold in island coordinates

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

/// 🎨 Island Aerial CustomPainter
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
    // 1. Draw Infinite Edge-to-Edge Ocean (Covers entire screen, never breaks into square)
    _drawInfiniteOcean(canvas, size);

    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = math.min(size.width, size.height) / 420.0;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    // 2. Satellite Small Islets (for organic archipelago feel)
    if (!island.isPresidential) {
      _drawSatelliteIslets(canvas);
    }

    // 3. Shallow Coral Reef Lagoon Rim (Translucent turquoise water)
    _drawShallowCoralReef(canvas);

    // 4. Sandy Shoreline Beach
    _drawSandyBeach(canvas);

    // 5. Lush Tropical Green Island Body
    _drawGreenIslandBody(canvas);

    // 6. Central Lagoon / Freshwater Pool (if applicable to shape)
    _drawInteriorWaterBody(canvas);

    // 7. Winding Paved Roadways & Trails
    _drawRoadways(canvas);

    // 8. Wooden Pier / Jetty with Moored Yachts & Speedboats
    _drawWoodenPierAndBoats(canvas);

    // 9. Habit Houses / Plots (50 Plots across the island)
    if (island.isPresidential) {
      _drawPresidentialCitadel(canvas);
    } else {
      _draw50HabitHousePlots(canvas);
    }

    // 10. Clustered Palm Tree Canopies
    _drawPalmTreeCanopies(canvas);

    // 11. Beach Umbrellas & Loungers along the Sand
    _drawBeachUmbrellas(canvas);

    canvas.restore();
  }

  // =========================================================================
  // 🌊 INFINITE OCEAN (Prevents "breaking" when zooming out)
  // =========================================================================
  void _drawInfiniteOcean(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    final oceanGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.25,
      colors: [
        island.waterColor.withValues(alpha: 0.95), // Vibrant island sea color
        Color.lerp(island.waterColor, const Color(0xFF03045E), 0.5) ?? const Color(0xFF0284C7),
        const Color(0xFF0A1128), // Deep abyssal navy edge
      ],
      stops: const [0.0, 0.65, 1.0],
    );

    final oceanPaint = Paint()..shader = oceanGradient.createShader(fullRect);
    canvas.drawRect(fullRect, oceanPaint);

    // Subtle gentle wave crest arcs across the open waters
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 7; i++) {
      final angle = (i * 0.9);
      final rx = size.width * (0.2 + (i % 3) * 0.3);
      final ry = size.height * (0.15 + (i ~/ 3) * 0.35);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(rx, ry), width: 70, height: 26),
        angle,
        1.6,
        false,
        wavePaint,
      );
    }
  }

  // =========================================================================
  // 🏝️ DISTINCT ARCHITECTURAL ISLAND PATH GEOMETRIES
  // =========================================================================
  Path _getIslandPath() {
    final path = Path();

    if (island.isPresidential || island.shapeStyle == IslandShapeStyle.citadelApex) {
      // 👑 Symmetrical Imperial Octagonal Island
      const r = 92.0;
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
        // 🌙 C-shaped Crescent wrapping around a wide turquoise bay
        path.moveTo(-110, -85);
        path.cubicTo(-60, -145, 80, -135, 125, -60);
        path.cubicTo(155, 10, 130, 95, 75, 125);
        path.cubicTo(45, 140, 10, 110, 30, 80);
        path.cubicTo(65, 30, 70, -30, 20, -60);
        path.cubicTo(-25, -80, -75, -50, -90, -15);
        path.cubicTo(-105, 15, -135, 20, -140, -15);
        path.cubicTo(-145, -55, -130, -75, -110, -85);
        path.close();
        break;

      case IslandShapeStyle.sCurveArchipelago:
        // 🐉 S-Curve meandering dragon island with alternating sandy coves
        path.moveTo(-90, -125);
        path.cubicTo(-30, -145, 45, -110, 65, -60);
        path.cubicTo(80, -15, 25, 15, -25, 25);
        path.cubicTo(-75, 35, -85, 85, -55, 125);
        path.cubicTo(-25, 155, 55, 145, 95, 110);
        path.cubicTo(125, 80, 140, 120, 105, 145);
        path.cubicTo(60, 175, -55, 175, -100, 125);
        path.cubicTo(-135, 80, -125, 10, -70, -10);
        path.cubicTo(-20, -25, 10, -55, -5, -95);
        path.cubicTo(-15, -125, -65, -135, -90, -125);
        path.close();
        break;

      case IslandShapeStyle.starAtoll:
        // ⭐ 5-Pointed Tropical Coral Star Island
        const int points = 5;
        const outerR = 125.0;
        const innerR = 68.0;
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
        // 🏝️-🏝️ Twin Islands connected by central land bridge
        // West Islet
        path.moveTo(-130, -60);
        path.cubicTo(-80, -110, -30, -85, -20, -30);
        // Sandbar Bridge North edge
        path.lineTo(20, -25);
        // East Islet
        path.cubicTo(30, -85, 85, -105, 130, -55);
        path.cubicTo(165, -10, 150, 70, 105, 105);
        path.cubicTo(55, 130, 25, 85, 20, 30);
        // Sandbar Bridge South edge
        path.lineTo(-20, 25);
        // West Islet South
        path.cubicTo(-30, 85, -80, 120, -125, 85);
        path.cubicTo(-165, 50, -165, -20, -130, -60);
        path.close();
        break;

      case IslandShapeStyle.ringAtoll:
        // ⭕ Ring Atoll enclosing central lagoon (Reference Image 2)
        path.moveTo(-115, -95);
        path.cubicTo(-50, -145, 65, -135, 120, -80);
        path.cubicTo(165, -25, 155, 75, 110, 120);
        path.cubicTo(60, 155, -60, 145, -115, 100);
        path.cubicTo(-160, 50, -160, -45, -115, -95);
        path.close();
        break;

      case IslandShapeStyle.hookPeninsula:
        // 🪝 J-Shaped Hook Peninsula
        path.moveTo(-50, -135);
        path.cubicTo(0, -145, 50, -110, 55, -50);
        path.cubicTo(60, 20, 75, 85, 125, 105);
        path.cubicTo(155, 120, 140, 155, 95, 155);
        path.cubicTo(35, 155, 0, 115, -10, 55);
        path.cubicTo(-20, -10, -25, -60, -75, -80);
        path.cubicTo(-115, -95, -100, -145, -50, -135);
        path.close();
        break;

      case IslandShapeStyle.heartSanctuary:
        // 💖 Heart-shaped tropical paradise
        path.moveTo(0, -50);
        path.cubicTo(35, -120, 125, -110, 125, -30);
        path.cubicTo(125, 45, 60, 95, 0, 145);
        path.cubicTo(-60, 95, -125, 45, -125, -30);
        path.cubicTo(-125, -110, -35, -120, 0, -50);
        path.close();
        break;

      case IslandShapeStyle.cloverBays:
        // 🍀 3-Leaf Clover Island with 3 lush lobes
        path.moveTo(0, -135);
        path.cubicTo(70, -135, 70, -45, 30, -20);
        path.cubicTo(95, 0, 130, 80, 70, 125);
        path.cubicTo(20, 150, 0, 75, 0, 45);
        path.cubicTo(0, 75, -20, 150, -70, 125);
        path.cubicTo(-130, 80, -95, 0, -30, -20);
        path.cubicTo(-70, -45, -70, -135, 0, -135);
        path.close();
        break;

      case IslandShapeStyle.fortressPlateau:
        // 🛡️ Diamond / Hexagonal Fortress Plateau
        path.moveTo(0, -130);
        path.lineTo(125, -45);
        path.lineTo(110, 75);
        path.lineTo(0, 135);
        path.lineTo(-110, 75);
        path.lineTo(-125, -45);
        path.close();
        break;

      case IslandShapeStyle.citadelApex:
        // Handled above
        break;
    }

    return path;
  }

  // =========================================================================
  // 3. REEF, BEACH & TERRAIN
  // =========================================================================
  void _drawShallowCoralReef(Canvas canvas) {
    final islandPath = _getIslandPath();

    // Outer Turquoise Reef Glow
    final reefPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(islandPath, reefPaint);

    // Inner Radiant Aquamarine Rim
    final reefInnerPaint = Paint()
      ..color = const Color(0xFF67E8F9).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(islandPath, reefInnerPaint);
  }

  void _drawSandyBeach(Canvas canvas) {
    final islandPath = _getIslandPath();

    final sandPaint = Paint()
      ..color = const Color(0xFFFDE68A) // Golden tropical sand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(islandPath, sandPaint);

    final wetSandPaint = Paint()
      ..color = const Color(0xFFFCD34D) // Wet shoreline sand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
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
      ..shader = landGradient.createShader(Rect.fromCircle(center: Offset.zero, radius: 150))
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
      ..strokeWidth = 3;

    if (island.shapeStyle == IslandShapeStyle.ringAtoll ||
        island.shapeStyle == IslandShapeStyle.crescentLagoon) {
      final lagoonPath = Path();
      lagoonPath.addOval(Rect.fromCenter(center: const Offset(10, 10), width: 75, height: 55));
      canvas.drawPath(lagoonPath, lagoonSandRim);
      canvas.drawPath(lagoonPath, lagoonPaint);
    } else if (island.shapeStyle == IslandShapeStyle.starAtoll) {
      final lagoonPath = Path();
      lagoonPath.addOval(Rect.fromCenter(center: Offset.zero, width: 45, height: 45));
      canvas.drawPath(lagoonPath, lagoonSandRim);
      canvas.drawPath(lagoonPath, lagoonPaint);
    }
  }

  void _drawRoadways(Canvas canvas) {
    final roadPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final rPath = Path();
    if (island.isPresidential) {
      rPath.moveTo(-80, 0);
      rPath.lineTo(-25, 0);
    } else {
      // Loop avenue around the island connecting plots
      rPath.moveTo(-65, -45);
      rPath.quadraticBezierTo(0, -65, 65, -45);
      rPath.quadraticBezierTo(75, 0, 115, 15); // Connects to pier
      rPath.moveTo(-65, 45);
      rPath.quadraticBezierTo(0, 65, 65, 45);
      rPath.moveTo(-45, -45);
      rPath.lineTo(-45, 45);
      rPath.moveTo(45, -45);
      rPath.lineTo(45, 45);
    }
    canvas.drawPath(rPath, roadPaint);
  }

  void _drawWoodenPierAndBoats(Canvas canvas) {
    final pierPaint = Paint()
      ..color = const Color(0xFF92400E) // Wood plank brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.square;

    if (island.isPresidential) {
      // Royal West Pier
      canvas.drawLine(const Offset(-85, 0), const Offset(-125, 0), pierPaint);
      canvas.drawLine(const Offset(-125, -20), const Offset(-125, 20), pierPaint);
      _drawYacht(canvas, const Offset(-138, 0), angle: -math.pi / 2, isGold: true);
    } else {
      // East Side Marina (Reference Images 1 & 2)
      canvas.drawLine(const Offset(105, 15), const Offset(150, 15), pierPaint);
      canvas.drawLine(const Offset(150, -8), const Offset(150, 38), pierPaint);
      _drawYacht(canvas, const Offset(160, 2), angle: 0);
      _drawYacht(canvas, const Offset(160, 28), angle: 0);
      _drawYacht(canvas, const Offset(128, -25), angle: -0.35);
    }
  }

  void _drawYacht(Canvas canvas, Offset pos, {double angle = 0, bool isGold = false}) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    final hullPath = Path();
    hullPath.moveTo(-9, -4);
    hullPath.lineTo(4, -4);
    hullPath.lineTo(11, 0); // Bow
    hullPath.lineTo(4, 4);
    hullPath.lineTo(-9, 4);
    hullPath.close();

    final hullPaint = Paint()..color = isGold ? const Color(0xFFFFD700) : Colors.white;
    canvas.drawPath(hullPath, hullPaint);

    final deckPaint = Paint()..color = isGold ? Colors.black87 : const Color(0xFF0284C7);
    canvas.drawRect(const Rect.fromLTWH(-3, -2.5, 6, 5), deckPaint);

    canvas.restore();
  }

  // =========================================================================
  // 🏡 50 HABIT HOUSE PLOTS (TOP-DOWN 90-DAY HABIT PROGRESSION)
  // =========================================================================
  void _draw50HabitHousePlots(Canvas canvas) {
    final List<Offset> positions = get50PlotCoordinates(island.shapeStyle);

    for (int i = 0; i < 50; i++) {
      final pos = positions[i];
      final plotNumber = i + 1;
      final isSel = selectedPlotNumber == plotNumber;

      // Match plot from data or generate placeholder
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

      // 1. Plot Demarcated Lawn / Garden Boundary
      final plotRect = Rect.fromCenter(center: pos, width: 22, height: 22);
      final gardenPaint = Paint()
        ..color = isSel
            ? const Color(0xFFFFD700).withValues(alpha: 0.85)
            : const Color(0xFF166534).withValues(alpha: 0.45)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(plotRect, const Radius.circular(4)), gardenPaint);

      final fencePaint = Paint()
        ..color = isSel ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSel ? 1.8 : 0.65;
      canvas.drawRRect(RRect.fromRectAndRadius(plotRect, const Radius.circular(4)), fencePaint);

      // 2. Render Top-Down 90-Day Habit House Roof
      _drawTopDownHabitHouse(canvas, pos, plot.day, isSel);

      // 3. Mini Plot Number Badge
      final tp = TextPainter(
        text: TextSpan(
          text: '$plotNumber',
          style: TextStyle(
            color: isSel ? Colors.black : Colors.white,
            fontSize: 6.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final badgePos = pos.translate(-tp.width / 2, -14);
      final badgeBg = RRect.fromRectAndRadius(
        Rect.fromLTWH(badgePos.dx - 2, badgePos.dy - 1, tp.width + 4, tp.height + 2),
        const Radius.circular(3),
      );
      canvas.drawRRect(badgeBg, Paint()..color = isSel ? const Color(0xFFFFD700) : Colors.black87);
      tp.paint(canvas, badgePos);
    }
  }

  /// 🏛️ Top-Down Habit House Roof based on Day 1-90 Progression
  void _drawTopDownHabitHouse(Canvas canvas, Offset pos, int day, bool isSelected) {
    if (day <= 15) {
      // ⛺ Stage 1 (Day 1-15): Starter Camp / Wooden Thatched Cottage
      final roofPaint = Paint()..color = const Color(0xFFD97706); // Warm thatch brown
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: 11, height: 9), const Radius.circular(2)),
        roofPaint,
      );
      // Ridge line
      canvas.drawLine(pos.translate(-4, 0), pos.translate(4, 0), Paint()..color = const Color(0xFF78350F)..strokeWidth = 1.0);
    } else if (day <= 35) {
      // 🏡 Stage 2 (Day 16-35): Terracotta Stone Villa with Chimney
      final roofPaint = Paint()..color = const Color(0xFFEA580C); // Terracotta clay red
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: 13, height: 11), const Radius.circular(2)),
        roofPaint,
      );
      // White roof ridge & tiny chimney
      canvas.drawLine(pos.translate(-5, 0), pos.translate(5, 0), Paint()..color = Colors.white54..strokeWidth = 1.2);
      canvas.drawCircle(pos.translate(3, -3), 1.6, Paint()..color = const Color(0xFF475569));
    } else if (day <= 60) {
      // 🏢 Stage 3 (Day 36-60): Modern Executive Villa with Private Swimming Pool
      final villaPaint = Paint()..color = const Color(0xFFF8FAFC); // Clean white flat roof
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos.translate(-2, 0), width: 11, height: 12), const Radius.circular(2)),
        villaPaint,
      );
      // Private Turquoise Swimming Pool
      final poolPaint = Paint()..color = const Color(0xFF06B6D4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos.translate(5, 0), width: 5, height: 9), const Radius.circular(1.5)),
        poolPaint,
      );
    } else if (day <= 89) {
      // 🏰 Stage 4 (Day 61-89): Luxury Glass Manor with Skylight & Pool
      final manorPaint = Paint()..color = const Color(0xFF0284C7); // Glass sky-blue roof
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos.translate(-2, 0), width: 13, height: 13), const Radius.circular(2.5)),
        manorPaint,
      );
      // Skylight cross
      canvas.drawLine(pos.translate(-7, 0), pos.translate(3, 0), Paint()..color = Colors.white70..strokeWidth = 0.8);
      canvas.drawLine(pos.translate(-2, -5), pos.translate(-2, 5), Paint()..color = Colors.white70..strokeWidth = 0.8);
      // Large Pool
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos.translate(6, 0), width: 5.5, height: 11), const Radius.circular(1.5)),
        Paint()..color = const Color(0xFF38BDF8),
      );
    } else {
      // 👑 Stage 5 (Day 90): Sovereign Golden Apex Palace
      final goldPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawCircle(pos, 7.5, goldPaint);
      canvas.drawCircle(pos, 4.0, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(pos, 1.8, Paint()..color = Colors.white);
    }
  }

  // =========================================================================
  // 👑 PRESIDENTIAL CITADEL (MUS'AB SOVEREIGN ISLAND APEX)
  // =========================================================================
  void _drawPresidentialCitadel(Canvas canvas) {
    // 1. Water Moat around palace
    final moatPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(Offset.zero, 56, moatPaint);

    // 2. Marble Quad Courtyard
    final courtyardPaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 84, height: 84), const Radius.circular(14)),
      courtyardPaint,
    );

    // 3. Formal Palace Gardens (4 Green Quads)
    final gardenPaint = Paint()..color = const Color(0xFF15803D);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-36, -36, 30, 30), const Radius.circular(6)), gardenPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(6, -36, 30, 30), const Radius.circular(6)), gardenPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-36, 6, 30, 30), const Radius.circular(6)), gardenPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(6, 6, 30, 30), const Radius.circular(6)), gardenPaint);

    // 4. Central Royal Grand Palace with 5 Golden Domes
    final palaceBase = Paint()..color = const Color(0xFFE2E8F0);
    canvas.drawCircle(Offset.zero, 25, palaceBase);

    // 4 Corner Golden Domes
    final smallDomePaint = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(const Offset(-13, -13), 6.5, smallDomePaint);
    canvas.drawCircle(const Offset(13, -13), 6.5, smallDomePaint);
    canvas.drawCircle(const Offset(-13, 13), 6.5, smallDomePaint);
    canvas.drawCircle(const Offset(13, 13), 6.5, smallDomePaint);

    // Grand Central Golden Dome
    final grandDome = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset.zero, 13.5, grandDome);
    canvas.drawCircle(const Offset(-3, -3), 4.5, Paint()..color = Colors.white70); // Golden reflection

    // 5. Helipad [H] on North Terrace
    final helipadPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawCircle(const Offset(0, -62), 11.5, helipadPaint);
    canvas.drawCircle(const Offset(0, -62), 10.0, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
    final hPainter = TextPainter(
      text: const TextSpan(
        text: 'H',
        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    hPainter.paint(canvas, Offset(-hPainter.width / 2, -62 - hPainter.height / 2));

    // 6. Presidential Crown Crest Badge
    final crownPainter = TextPainter(
      text: const TextSpan(text: '👑', style: TextStyle(fontSize: 16)),
      textDirection: TextDirection.ltr,
    )..layout();
    crownPainter.paint(canvas, Offset(-crownPainter.width / 2, 28));
  }

  // =========================================================================
  // 🌴 VEGETATION & BEACH UMBRELLAS
  // =========================================================================
  void _drawPalmTreeCanopies(Canvas canvas) {
    final List<Offset> trees = island.isPresidential
        ? [
            const Offset(-55, -45), const Offset(55, -45),
            const Offset(-55, 45), const Offset(55, 45),
            const Offset(0, 68), const Offset(-70, 0),
          ]
        : [
            const Offset(-105, -30), const Offset(-95, 0), const Offset(-95, 30),
            const Offset(90, -45), const Offset(95, 45), const Offset(0, 85),
            const Offset(-35, 80), const Offset(45, 80),
          ];

    for (final pos in trees) {
      canvas.drawCircle(pos.translate(1.5, 2.0), 6.5, Paint()..color = Colors.black26);
      canvas.drawCircle(pos, 6.0, Paint()..color = const Color(0xFF15803D));
      canvas.drawCircle(pos.translate(-0.8, -0.8), 4.2, Paint()..color = const Color(0xFF22C55E));
    }
  }

  void _drawBeachUmbrellas(Canvas canvas) {
    final List<Offset> umbrellas = island.isPresidential
        ? [const Offset(70, -10), const Offset(70, 10)]
        : [
            const Offset(-120, -60), const Offset(-115, 60),
            const Offset(115, -60), const Offset(110, 65),
          ];

    for (int i = 0; i < umbrellas.length; i++) {
      final pos = umbrellas[i];
      canvas.drawCircle(pos, 4.0, Paint()..color = i.isEven ? const Color(0xFFEF4444) : const Color(0xFF3B82F6));
      canvas.drawCircle(pos, 1.2, Paint()..color = Colors.white);
    }
  }

  void _drawSatelliteIslets(Canvas canvas) {
    final isletPath = Path();
    isletPath.addOval(Rect.fromCenter(center: const Offset(-80, 145), width: 34, height: 18));

    canvas.drawPath(isletPath, Paint()..color = const Color(0xFFFDE68A)..style = PaintingStyle.stroke..strokeWidth = 6);
    canvas.drawPath(isletPath, Paint()..color = const Color(0xFF16A34A)..style = PaintingStyle.fill);
    canvas.drawCircle(const Offset(-80, 145), 5.5, Paint()..color = const Color(0xFF15803D));
  }

  @override
  bool shouldRepaint(covariant IslandAerialPainter oldDelegate) {
    return oldDelegate.island.id != island.id ||
        oldDelegate.selectedPlotNumber != selectedPlotNumber ||
        oldDelegate.plots != plots;
  }

  // =========================================================================
  // 📍 50 PRE-CALCULATED PLOT COORDINATES FOR EVERY ISLAND GEOMETRY
  // =========================================================================
  static List<Offset> get50PlotCoordinates(IslandShapeStyle style) {
    final List<Offset> coords = [];

    switch (style) {
      case IslandShapeStyle.crescentLagoon:
        // Distributed along the C-curve
        for (int i = 0; i < 50; i++) {
          final t = (i / 49.0);
          final angle = -math.pi * 0.85 + t * math.pi * 1.55;
          final r = 68.0 + (i % 3) * 18.0;
          coords.add(Offset(r * math.cos(angle) - 15, r * math.sin(angle) * 0.95 + 10));
        }
        break;

      case IslandShapeStyle.sCurveArchipelago:
        // Distributed along the S-curve
        for (int i = 0; i < 50; i++) {
          final t = (i / 49.0) * 2 * math.pi - math.pi;
          final x = 55.0 * math.sin(t) + ((i % 2 == 0) ? -12 : 12);
          final y = (i - 25) * 4.6;
          coords.add(Offset(x, y));
        }
        break;

      case IslandShapeStyle.starAtoll:
        // Distributed across the 5 star arms
        for (int i = 0; i < 50; i++) {
          final arm = i % 5;
          final armIdx = i ~/ 5;
          final angle = (arm * 2 * math.pi / 5) - math.pi / 2;
          final r = 36.0 + armIdx * 8.5;
          coords.add(Offset(r * math.cos(angle), r * math.sin(angle)));
        }
        break;

      case IslandShapeStyle.dualIsletBridge:
        // 25 plots on West Islet, 25 plots on East Islet
        for (int i = 0; i < 25; i++) {
          final row = i ~/ 5;
          final col = i % 5;
          coords.add(Offset(-115.0 + col * 16.0, -40.0 + row * 18.0));
        }
        for (int i = 0; i < 25; i++) {
          final row = i ~/ 5;
          final col = i % 5;
          coords.add(Offset(45.0 + col * 16.0, -40.0 + row * 18.0));
        }
        break;

      default:
        // Organic Grid (Ring / Hook / Heart / Clover / Fortress)
        // 50 carefully placed offsets around center
        final List<Offset> standardGrid = [
          const Offset(-75, -55), const Offset(-50, -58), const Offset(-25, -60), const Offset(0, -60), const Offset(25, -60), const Offset(50, -58), const Offset(75, -55),
          const Offset(-80, -35), const Offset(-55, -35), const Offset(-30, -38), const Offset(30, -38), const Offset(55, -35), const Offset(80, -35),
          const Offset(-85, -15), const Offset(-60, -15), const Offset(-35, -15), const Offset(35, -15), const Offset(60, -15), const Offset(85, -15),
          const Offset(-85, 8),   const Offset(-60, 8),   const Offset(-35, 8),   const Offset(35, 8),   const Offset(60, 8),   const Offset(85, 8),
          const Offset(-80, 28),  const Offset(-55, 28),  const Offset(-30, 28),  const Offset(30, 28),  const Offset(55, 28),  const Offset(80, 28),
          const Offset(-70, 48),  const Offset(-45, 48),  const Offset(-20, 50),  const Offset(0, 52),   const Offset(20, 50),  const Offset(45, 48),  const Offset(70, 48),
          const Offset(-50, 68),  const Offset(-25, 70),  const Offset(0, 72),    const Offset(25, 70),  const Offset(50, 68),
          const Offset(-50, -78), const Offset(-25, -80), const Offset(0, -82),   const Offset(25, -80), const Offset(50, -78),
        ];

        for (int i = 0; i < 50; i++) {
          if (i < standardGrid.length) {
            coords.add(standardGrid[i]);
          } else {
            coords.add(Offset((i % 7 - 3) * 22.0, (i ~/ 7 - 3) * 22.0));
          }
        }
        break;
    }

    return coords;
  }
}
