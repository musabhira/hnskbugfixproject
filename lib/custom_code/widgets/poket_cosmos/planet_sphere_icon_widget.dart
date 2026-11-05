import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🪐 Realistic 3D Planetary Sphere Icon Widget
/// Renders high-fidelity spherical shading, atmospheric glows, surface features,
/// and planetary ring systems (e.g. Saturn) using custom Canvas rendering.
class PlanetSphereIconWidget extends StatelessWidget {
  final String name;
  final Color primaryColor;
  final Color glowColor;
  final double size;
  final bool isMoon;

  const PlanetSphereIconWidget({
    super.key,
    required this.name,
    required this.primaryColor,
    required this.glowColor,
    this.size = 46.0,
    this.isMoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: PlanetSphereIconPainter(
          name: name.toLowerCase(),
          primaryColor: primaryColor,
          glowColor: glowColor,
          isMoon: isMoon,
        ),
      ),
    );
  }
}

class PlanetSphereIconPainter extends CustomPainter {
  final String name;
  final Color primaryColor;
  final Color glowColor;
  final bool isMoon;

  PlanetSphereIconPainter({
    required this.name,
    required this.primaryColor,
    required this.glowColor,
    required this.isMoon,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final double sphereRadius = size.width * 0.38;

    // Check specific celestial identities
    final isSaturn = name.contains('saturn');
    final isEarth = name.contains('earth');
    final isMoonBody = isMoon || name.contains('moon');
    final isMars = name.contains('mars');
    final isJupiter = name.contains('jupiter');
    final isEuropa = name.contains('europa');
    final isGanymede = name.contains('ganymede');
    final isTitan = name.contains('titan');
    final isTriton = name.contains('triton');
    final isNeptune = name.contains('neptune');
    final isUranus = name.contains('uranus');
    final isPluto = name.contains('pluto');
    final isKepler = name.contains('kepler');

    // 1. Back Ring for Saturn (drawn BEHIND the planet sphere)
    if (isSaturn) {
      _drawSaturnRingBack(canvas, center, sphereRadius);
    }

    // 2. Soft Outer Atmospheric Corona Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          glowColor.withValues(alpha: 0.40),
          glowColor.withValues(alpha: 0.12),
          glowColor.withValues(alpha: 0.0),
        ],
        stops: const [0.65, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: sphereRadius * 1.35));
    canvas.drawCircle(center, sphereRadius * 1.35, glowPaint);

    // 3. Spherical Clipping & Surface Features
    canvas.save();
    final spherePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: sphereRadius));
    canvas.clipPath(spherePath);

    // Planet Base Color & Shading
    _drawPlanetSurface(canvas, center, sphereRadius,
        isEarth: isEarth,
        isMoon: isMoonBody,
        isMars: isMars,
        isJupiter: isJupiter,
        isEuropa: isEuropa,
        isGanymede: isGanymede,
        isSaturn: isSaturn,
        isTitan: isTitan,
        isUranus: isUranus,
        isNeptune: isNeptune,
        isTriton: isTriton,
        isPluto: isPluto,
        isKepler: isKepler);

    // 3D Spherical Volumetric Lighting Overlay (Light source from top-left)
    final lightSource = Offset(cx - sphereRadius * 0.35, cy - sphereRadius * 0.35);
    final sphereLightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.40, -0.40),
        radius: 1.15,
        colors: [
          Colors.white.withValues(alpha: 0.45),
          Colors.white.withValues(alpha: 0.0),
          Colors.black.withValues(alpha: 0.45),
          Colors.black.withValues(alpha: 0.88),
        ],
        stops: const [0.0, 0.45, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: sphereRadius));
    canvas.drawCircle(center, sphereRadius, sphereLightPaint);

    // Atmospheric Edge Rim Fresnel Highlight
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..shader = RadialGradient(
        center: const Alignment(-0.45, -0.45),
        radius: 1.0,
        colors: [
          glowColor.withValues(alpha: 0.85),
          glowColor.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: sphereRadius));
    canvas.drawCircle(center, sphereRadius - 0.8, rimPaint);

    canvas.restore();

    // 4. Front Ring for Saturn (drawn OVER the bottom-front of the planet sphere)
    if (isSaturn) {
      _drawSaturnRingFront(canvas, center, sphereRadius);
    }
  }

  void _drawPlanetSurface(
    Canvas canvas,
    Offset center,
    double r, {
    required bool isEarth,
    required bool isMoon,
    required bool isMars,
    required bool isJupiter,
    required bool isEuropa,
    required bool isGanymede,
    required bool isSaturn,
    required bool isTitan,
    required bool isUranus,
    required bool isNeptune,
    required bool isTriton,
    required bool isPluto,
    required bool isKepler,
  }) {
    final basePaint = Paint()..color = primaryColor;
    canvas.drawCircle(center, r, basePaint);

    if (isEarth) {
      // 🌍 Ocean Blue Base + Green Continents + Cloud Swirls
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFF0284C7));
      final contPaint = Paint()..color = const Color(0xFF10B981);
      canvas.drawOval(Rect.fromCenter(center: center + const Offset(-4, -3), width: r * 0.9, height: r * 0.7), contPaint);
      canvas.drawOval(Rect.fromCenter(center: center + const Offset(5, 4), width: r * 0.75, height: r * 0.85), contPaint);
      // Cloud swirl
      final cloudPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawArc(Rect.fromCircle(center: center, radius: r * 0.7), -0.5, 1.8, false, cloudPaint);
    } else if (isMoon) {
      // 🌕 Grey Lunar Basins (Maria) & Craters
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFF94A3B8));
      final marePaint = Paint()..color = const Color(0xFF475569);
      canvas.drawOval(Rect.fromCenter(center: center + const Offset(-3, -2), width: r * 0.55, height: r * 0.45), marePaint);
      canvas.drawOval(Rect.fromCenter(center: center + const Offset(3, 4), width: r * 0.45, height: r * 0.4), marePaint);
      canvas.drawCircle(center + const Offset(1, -4), r * 0.15, marePaint);
    } else if (isMars) {
      // 🔴 Rust-Red + White Polar Cap
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFFDC2626));
      final patchPaint = Paint()..color = const Color(0xFF991B1B);
      canvas.drawOval(Rect.fromCenter(center: center + const Offset(0, 2), width: r * 1.1, height: r * 0.45), patchPaint);
      // Polar Ice Cap
      final icePaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
      canvas.drawOval(Rect.fromCenter(center: center + Offset(0, -r * 0.85), width: r * 0.5, height: r * 0.25), icePaint);
    } else if (isJupiter) {
      // 🟠 Gas Giant Bands + Great Red Spot
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFFF59E0B));
      final bandPaint1 = Paint()..color = const Color(0xFFB45309);
      final bandPaint2 = Paint()..color = const Color(0xFFFEF3C7);
      canvas.drawRect(Rect.fromCenter(center: center + const Offset(0, -r * 0.45), width: r * 2.2, height: r * 0.28), bandPaint1);
      canvas.drawRect(Rect.fromCenter(center: center + const Offset(0, -r * 0.1), width: r * 2.2, height: r * 0.25), bandPaint2);
      canvas.drawRect(Rect.fromCenter(center: center + const Offset(0, r * 0.35), width: r * 2.2, height: r * 0.3), bandPaint1);
      // Great Red Spot
      final spotPaint = Paint()..color = const Color(0xFFDC2626);
      canvas.drawOval(Rect.fromCenter(center: center + Offset(r * 0.35, r * 0.25), width: r * 0.42, height: r * 0.26), spotPaint);
    } else if (isEuropa) {
      // 🧊 Ice Crust + Reddish Linia fractures
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFFE2E8F0));
      final fracturePaint = Paint()
        ..color = const Color(0xFFB45309).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(center + Offset(-r * 0.7, -r * 0.2), center + Offset(r * 0.6, r * 0.3), fracturePaint);
      canvas.drawLine(center + Offset(-r * 0.4, r * 0.5), center + Offset(r * 0.5, -r * 0.4), fracturePaint);
    } else if (isGanymede) {
      // 🛡️ Dark grey-brown grooved terrain
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFF64748B));
      final groovePaint = Paint()..color = const Color(0xFF334155);
      canvas.drawOval(Rect.fromCenter(center: center + const Offset(-2, 1), width: r * 1.1, height: r * 0.6), groovePaint);
    } else if (isSaturn) {
      // 🪐 Butterscotch Gaseous Bands
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFFFDE68A));
      final bandPaint = Paint()..color = const Color(0xFFD97706).withValues(alpha: 0.65);
      canvas.drawRect(Rect.fromCenter(center: center + const Offset(0, -r * 0.25), width: r * 2.2, height: r * 0.22), bandPaint);
      canvas.drawRect(Rect.fromCenter(center: center + const Offset(0, r * 0.25), width: r * 2.2, height: r * 0.22), bandPaint);
    } else if (isTitan) {
      // 🪐 Opaque Orange Nitrogen/Methane Smog
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFFF59E0B));
      final smogPaint = Paint()..color = const Color(0xFFD97706);
      canvas.drawOval(Rect.fromCenter(center: center + Offset(0, -r * 0.5), width: r * 1.2, height: r * 0.5), smogPaint);
    } else if (isUranus) {
      // 🌀 Aquamarine Ice Giant
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFF06B6D4));
      final hazePaint = Paint()..color = const Color(0xFF67E8F9).withValues(alpha: 0.4);
      canvas.drawCircle(center, r * 0.7, hazePaint);
    } else if (isNeptune) {
      // 🌊 Deep Cobalt Blue + Cirrus Clouds
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFF1D4ED8));
      final cirrusPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4;
      canvas.drawArc(Rect.fromCenter(center: center + const Offset(0, -2), width: r * 1.4, height: r * 0.6), 0.2, 2.2, false, cirrusPaint);
    } else if (isTriton) {
      // 🔱 Pinkish-Blue Cantaloupe Terrain
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFF93C5FD));
      final frostPaint = Paint()..color = const Color(0xFFF472B6).withValues(alpha: 0.4);
      canvas.drawOval(Rect.fromCenter(center: center, width: r * 1.1, height: r * 0.7), frostPaint);
    } else if (isPluto) {
      // ❄️ Reddish-Brown + White Heart Nitrogen Glacier (Sputnik Planitia)
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFFB45309));
      final heartPaint = Paint()..color = Colors.white.withValues(alpha: 0.88);
      // Sputnik Planitia heart lobe
      canvas.drawOval(Rect.fromCenter(center: center + const Offset(2, 2), width: r * 0.65, height: r * 0.6), heartPaint);
    } else if (isKepler) {
      // 🌿 Interstellar Habitable Super-Earth 2.0 (Emerald & Cyan)
      canvas.drawCircle(center, r, Paint()..color = const Color(0xFF065F46));
      final landPaint = Paint()..color = const Color(0xFF10B981);
      canvas.drawOval(Rect.fromCenter(center: center + const Offset(-2, -3), width: r * 0.95, height: r * 0.8), landPaint);
      canvas.drawOval(Rect.fromCenter(center: center + const Offset(3, 3), width: r * 0.8, height: r * 0.7), landPaint);
      final atmospherePaint = Paint()
        ..color = const Color(0xFF6EE7B7).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawArc(Rect.fromCircle(center: center, radius: r * 0.75), 0.5, 2.4, false, atmospherePaint);
    }
  }

  void _drawSaturnRingBack(Canvas canvas, Offset center, double r) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 7.5); // Tilted planetary ring plane

    // Back half arc of the ring (y < 0)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.36
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.85);

    final rect = Rect.fromCenter(center: Offset.zero, width: r * 2.8, height: r * 0.95);
    canvas.drawArc(rect, math.pi, math.pi, false, ringPaint);

    // Cassini Division gap in ring
    final gapPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF0D121D);
    canvas.drawArc(rect, math.pi, math.pi, false, gapPaint);

    canvas.restore();
  }

  void _drawSaturnRingFront(Canvas canvas, Offset center, double r) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 7.5); // Tilted planetary ring plane

    // Front half arc of the ring (y > 0)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.36
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.95);

    final rect = Rect.fromCenter(center: Offset.zero, width: r * 2.8, height: r * 0.95);
    canvas.drawArc(rect, 0, math.pi, false, ringPaint);

    // Cassini Division gap in ring
    final gapPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFF0D121D);
    canvas.drawArc(rect, 0, math.pi, false, gapPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PlanetSphereIconPainter oldDelegate) {
    return oldDelegate.name != name ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.isMoon != isMoon;
  }
}
