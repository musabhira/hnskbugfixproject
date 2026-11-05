import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'poket_cosmos_models.dart';

/// 🏝️ Aerial Top-Down Island View Painter
/// Matches user reference images: Bird's-eye view of lush tropical island,
/// turquoise shallow waters, golden sandy beach, central lagoon, winding paths,
/// white/terracotta villas, wooden pier with speedboats, and beach umbrellas.
class IslandAerialViewWidget extends StatelessWidget {
  final PoketCountryMap island;
  final bool isInteractive;
  final ValueChanged<int>? onPlotTapped;
  final int? selectedPlotNumber;

  const IslandAerialViewWidget({
    super.key,
    required this.island,
    this.isInteractive = false,
    this.onPlotTapped,
    this.selectedPlotNumber,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: IslandAerialPainter(
        island: island,
        isInteractive: isInteractive,
        selectedPlotNumber: selectedPlotNumber,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class IslandAerialPainter extends CustomPainter {
  final PoketCountryMap island;
  final bool isInteractive;
  final int? selectedPlotNumber;

  IslandAerialPainter({
    required this.island,
    this.isInteractive = false,
    this.selectedPlotNumber,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = math.min(size.width, size.height) / 380.0;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    // 1. Vast Ocean Background with Subtle Waves
    _drawOceanWaters(canvas, size, scale);

    // 2. Satellite Small Islets (like in Reference Image 1)
    if (!island.isPresidential) {
      _drawSatelliteIslets(canvas);
    }

    // 3. Shallow Cyan Reef Contour (Translucent turquoise water)
    _drawShallowReef(canvas);

    // 4. Sandy Golden Beach
    _drawSandBeach(canvas);

    // 5. Lush Tropical Green Island Body
    _drawGreenIslandBody(canvas);

    // 6. Central Lagoon / Freshwater Pool (like in Reference Images 1 & 2)
    _drawCentralLagoon(canvas);

    // 7. Footpaths & Roadways
    _drawFootpaths(canvas);

    // 8. Wooden Pier / Jetty with Moored Yachts & Boats (like in Reference Images 1, 2, 3)
    _drawWoodenPierAndBoats(canvas);

    // 9. Dotted Villas / Houses / Habit Cabanas
    _drawVillasAndPlots(canvas);

    // 10. Clustered Palm Tree Canopies
    _drawPalmTreeCanopies(canvas);

    // 11. Beach Umbrellas & Loungers along the Sand
    _drawBeachUmbrellas(canvas);

    // 12. Special Presidential Palace Dome if President's Island
    if (island.isPresidential) {
      _drawPresidentialCitadel(canvas);
    }

    canvas.restore();
  }

  void _drawOceanWaters(Canvas canvas, Size size, double scale) {
    final oceanRect = Rect.fromCenter(
      center: Offset.zero,
      width: (size.width / scale) * 1.5,
      height: (size.height / scale) * 1.5,
    );

    final oceanGradient = RadialGradient(
      center: const Alignment(0, 0),
      radius: 1.1,
      colors: [
        const Color(0xFF00B4D8), // Tropical cyan near island
        island.waterColor,      // Island sea color
        const Color(0xFF0077B6),
        const Color(0xFF03045E), // Deep ocean abyss
      ],
    );

    final oceanPaint = Paint()..shader = oceanGradient.createShader(oceanRect);
    canvas.drawRect(oceanRect, oceanPaint);

    // Subtle boat wake ripples
    final ripplePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawArc(
      Rect.fromCenter(center: const Offset(110, -80), width: 60, height: 25),
      0.3,
      1.8,
      false,
      ripplePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(-100, 110), width: 50, height: 20),
      2.1,
      1.5,
      false,
      ripplePaint,
    );
  }

  Path _getIslandPath() {
    final path = Path();
    if (island.isPresidential) {
      // Elegant organic droplet / rounded sanctuary (Inspired by Reference Image 3)
      path.moveTo(-60, -70);
      path.quadraticBezierTo(0, -95, 65, -60);
      path.quadraticBezierTo(95, 0, 75, 65);
      path.quadraticBezierTo(10, 95, -60, 65);
      path.quadraticBezierTo(-95, 0, -60, -70);
      path.close();
    } else {
      // Natural tropical island with coves and bays (Inspired by Reference Image 1 & 2)
      path.moveTo(-110, -90);
      path.cubicTo(-60, -135, 60, -115, 115, -75);
      path.cubicTo(155, -20, 140, 70, 105, 110);
      path.cubicTo(60, 145, -50, 130, -100, 105);
      path.cubicTo(-145, 60, -150, -40, -110, -90);
      path.close();
    }
    return path;
  }

  void _drawSatelliteIslets(Canvas canvas) {
    // 1st islet below main island (elongated green sandbar with trees)
    final islet1Path = Path();
    islet1Path.moveTo(-65, 135);
    islet1Path.quadraticBezierTo(0, 125, 45, 138);
    islet1Path.quadraticBezierTo(0, 155, -65, 135);
    islet1Path.close();

    // Sand rim
    final sandPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawPath(islet1Path, sandPaint);

    // Green land
    final greenPaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..style = PaintingStyle.fill;
    canvas.drawPath(islet1Path, greenPaint);

    // Trees on islet
    final treePaint = Paint()..color = const Color(0xFF15803D);
    canvas.drawCircle(const Offset(-35, 137), 5.5, treePaint);
    canvas.drawCircle(const Offset(-15, 136), 6.5, treePaint);
    canvas.drawCircle(const Offset(10, 137), 6.0, treePaint);
    canvas.drawCircle(const Offset(28, 138), 5.0, treePaint);

    // 2nd tiny rock islet
    final islet2 = Path();
    islet2.addOval(Rect.fromCenter(center: const Offset(75, 135), width: 22, height: 16));
    canvas.drawPath(islet2, sandPaint);
    canvas.drawPath(islet2, greenPaint);
    canvas.drawCircle(const Offset(75, 135), 4.5, treePaint);
  }

  void _drawShallowReef(Canvas canvas) {
    final islandPath = _getIslandPath();
    final reefPaint = Paint()
      ..color = const Color(0xFF67E8F9).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = island.isPresidential ? 22 : 32
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(islandPath, reefPaint);

    // Outer foam contour
    final foamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(islandPath, foamPaint);
  }

  void _drawSandBeach(Canvas canvas) {
    final islandPath = _getIslandPath();
    final sandPaint = Paint()
      ..color = const Color(0xFFFDE68A) // Sunny golden beach sand
      ..style = PaintingStyle.stroke
      ..strokeWidth = island.isPresidential ? 14 : 20
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(islandPath, sandPaint);
  }

  void _drawGreenIslandBody(Canvas canvas) {
    final islandPath = _getIslandPath();
    final landGradient = RadialGradient(
      center: const Alignment(-0.2, -0.2),
      radius: 0.85,
      colors: [
        const Color(0xFF22C55E), // Fresh light green sunlit canopy
        island.landColor,        // Island signature lush green
        const Color(0xFF14532D), // Deep shade forest
      ],
    );

    final landPaint = Paint()
      ..shader = landGradient.createShader(islandPath.getBounds())
      ..style = PaintingStyle.fill;
    canvas.drawPath(islandPath, landPaint);
  }

  void _drawCentralLagoon(Canvas canvas) {
    if (island.isPresidential) return;

    // Organic freshwater lagoon in center of island (Inspired by Image 1)
    final lagoonPath = Path();
    lagoonPath.moveTo(-15, -10);
    lagoonPath.cubicTo(15, -25, 30, 5, 20, 25);
    lagoonPath.cubicTo(5, 35, -25, 30, -25, 10);
    lagoonPath.close();

    // Sandy rim around lagoon
    final rimPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawPath(lagoonPath, rimPaint);

    // Clear turquoise lagoon water
    final lagoonPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF67E8F9), Color(0xFF0EA5E9)],
      ).createShader(Rect.fromCircle(center: const Offset(0, 8), radius: 25))
      ..style = PaintingStyle.fill;
    canvas.drawPath(lagoonPath, lagoonPaint);
  }

  void _drawFootpaths(Canvas canvas) {
    final pathPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.85) // Light stone path
      ..style = PaintingStyle.stroke
      ..strokeWidth = island.isPresidential ? 3.0 : 3.8
      ..strokeCap = StrokeCap.round;

    if (island.isPresidential) {
      // Royal pathway from dock to palace
      final p = Path();
      p.moveTo(-75, 10);
      p.lineTo(-20, 0);
      p.lineTo(0, 0);
      canvas.drawPath(p, pathPaint);
    } else {
      // Winding trail network
      final p1 = Path();
      p1.moveTo(-85, -45);
      p1.quadraticBezierTo(-20, -55, 60, -40);
      p1.quadraticBezierTo(90, 0, 115, 15); // Connects to pier
      canvas.drawPath(p1, pathPaint);

      final p2 = Path();
      p2.moveTo(-60, 45);
      p2.quadraticBezierTo(0, 55, 65, 35);
      canvas.drawPath(p2, pathPaint);

      final p3 = Path();
      p3.moveTo(0, -50);
      p3.lineTo(-30, 0);
      p3.lineTo(0, 50);
      canvas.drawPath(p3, pathPaint);
    }
  }

  void _drawWoodenPierAndBoats(Canvas canvas) {
    final pierPaint = Paint()
      ..color = const Color(0xFF92400E) // Wood plank brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.square;

    if (island.isPresidential) {
      // Pier on west side
      canvas.drawLine(const Offset(-65, 10), const Offset(-105, 10), pierPaint);

      // Moored Presidential Royal Yacht
      _drawYacht(canvas, const Offset(-115, 5), angle: -math.pi / 2, isGold: true);
    } else {
      // Pier on east side (Reference Image 1 & 2)
      canvas.drawLine(const Offset(105, 15), const Offset(148, 15), pierPaint);

      // T-head dock platform
      canvas.drawLine(const Offset(148, -5), const Offset(148, 35), pierPaint);

      // Speedboats & Yachts moored at dock
      _drawYacht(canvas, const Offset(158, 2), angle: 0);
      _drawYacht(canvas, const Offset(158, 28), angle: 0);
      _drawYacht(canvas, const Offset(125, -25), angle: -0.4);
    }
  }

  void _drawYacht(Canvas canvas, Offset pos, {double angle = 0, bool isGold = false}) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    final hullPath = Path();
    hullPath.moveTo(-8, -4);
    hullPath.lineTo(4, -4);
    hullPath.lineTo(10, 0); // Bow pointed
    hullPath.lineTo(4, 4);
    hullPath.lineTo(-8, 4);
    hullPath.close();

    final hullPaint = Paint()..color = isGold ? const Color(0xFFFFD700) : Colors.white;
    canvas.drawPath(hullPath, hullPaint);

    final deckPaint = Paint()..color = isGold ? Colors.black87 : const Color(0xFF0284C7);
    canvas.drawRect(const Rect.fromLTWH(-3, -2, 6, 4), deckPaint);

    canvas.restore();
  }

  void _drawVillasAndPlots(Canvas canvas) {
    if (island.isPresidential) return;

    // Grid / cluster of habit villas along footpaths (Reference Image 1)
    final villaOffsets = [
      const Offset(-70, -60),
      const Offset(-45, -65),
      const Offset(-20, -68),
      const Offset(5, -65),
      const Offset(30, -58),
      const Offset(55, -45),
      const Offset(-65, 30),
      const Offset(-40, 45),
      const Offset(35, 45),
      const Offset(60, 25),
      const Offset(70, -10),
      const Offset(-35, -15),
      const Offset(45, -15),
    ];

    for (int i = 0; i < villaOffsets.length; i++) {
      final pos = villaOffsets[i];
      final isSel = selectedPlotNumber == (i + 1);

      // Drop shadow
      canvas.drawRect(
        Rect.fromCenter(center: pos.translate(1.5, 2.0), width: 14, height: 14),
        Paint()..color = Colors.black38,
      );

      // White/Terracotta rooftop
      final roofPaint = Paint()
        ..color = isSel
            ? const Color(0xFFFFD700)
            : (i % 2 == 0 ? const Color(0xFFF8FAFC) : const Color(0xFFE2E8F0));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos, width: 13, height: 13),
          const Radius.circular(2.5),
        ),
        roofPaint,
      );

      // Roof ridge line
      final ridgePaint = Paint()
        ..color = Colors.black26
        ..strokeWidth = 1.0;
      canvas.drawLine(pos.translate(-4, 0), pos.translate(4, 0), ridgePaint);
    }
  }

  void _drawPalmTreeCanopies(Canvas canvas) {
    final treeOffsets = island.isPresidential
        ? [
            const Offset(-35, -45), const Offset(0, -60), const Offset(35, -45),
            const Offset(-55, -20), const Offset(55, -20),
            const Offset(-50, 35), const Offset(0, 55), const Offset(50, 35),
            const Offset(-25, 25), const Offset(25, 25),
          ]
        : [
            const Offset(-90, -30), const Offset(-80, 0), const Offset(-85, 30),
            const Offset(-45, -35), const Offset(-15, -40), const Offset(15, -40),
            const Offset(50, -30), const Offset(85, -40), const Offset(95, -15),
            const Offset(80, 50), const Offset(45, 65), const Offset(0, 65),
            const Offset(-45, 60), const Offset(-15, 10), const Offset(15, 10),
            const Offset(-10, -10), const Offset(30, 0),
          ];

    for (final pos in treeOffsets) {
      // Tree canopy shadow
      canvas.drawCircle(
        pos.translate(1.5, 2.0),
        7.5,
        Paint()..color = Colors.black26,
      );

      // Outer darker palm green
      canvas.drawCircle(
        pos,
        7.0,
        Paint()..color = const Color(0xFF15803D),
      );

      // Inner lighter sunlit crown
      canvas.drawCircle(
        pos.translate(-0.8, -0.8),
        4.8,
        Paint()..color = const Color(0xFF22C55E),
      );
    }
  }

  void _drawBeachUmbrellas(Canvas canvas) {
    // Striped sun umbrellas along the sand (Reference Image 2 & 3)
    final umbrellaPositions = island.isPresidential
        ? [
            const Offset(-65, -55), const Offset(65, -50),
            const Offset(70, 45), const Offset(-60, 50),
          ]
        : [
            const Offset(-105, -70), const Offset(-75, -100), const Offset(70, -85),
            const Offset(115, -50), const Offset(110, 75), const Offset(65, 115),
            const Offset(-45, 115), const Offset(-95, 80),
          ];

    for (int i = 0; i < umbrellaPositions.length; i++) {
      final pos = umbrellaPositions[i];
      // Red & white beach umbrella
      canvas.drawCircle(pos.translate(1, 1), 4.0, Paint()..color = Colors.black26);
      canvas.drawCircle(pos, 3.8, Paint()..color = const Color(0xFFEF4444));
      canvas.drawCircle(pos, 2.0, Paint()..color = Colors.white);
      canvas.drawCircle(pos, 0.8, Paint()..color = const Color(0xFFEF4444));
    }
  }

  void _drawPresidentialCitadel(Canvas canvas) {
    // Central Presidential Palace Citadel (Reference Image 3 style exclusive retreat)
    final palaceRect = Rect.fromCenter(center: Offset.zero, width: 36, height: 32);

    // Drop shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(palaceRect.translate(2, 3), const Radius.circular(6)),
      Paint()..color = Colors.black45,
    );

    // Marble white walls
    canvas.drawRRect(
      RRect.fromRectAndRadius(palaceRect, const Radius.circular(5)),
      Paint()..color = const Color(0xFFFFFBEB),
    );

    // Golden Royal Dome in center
    final domePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        colors: [Color(0xFFFEF08A), Color(0xFFF59E0B), Color(0xFFB45309)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 12));
    canvas.drawCircle(Offset.zero, 11, domePaint);

    // Crown Icon on Dome
    final crownPainter = TextPainter(
      text: const TextSpan(
        text: '👑',
        style: TextStyle(fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    crownPainter.paint(canvas, Offset(-crownPainter.width / 2, -crownPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant IslandAerialPainter oldDelegate) {
    return oldDelegate.island.id != island.id ||
        oldDelegate.selectedPlotNumber != selectedPlotNumber;
  }
}

