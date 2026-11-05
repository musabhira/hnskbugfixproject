import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:google_fonts/google_fonts.dart';
import 'poket_cosmos_models.dart';

/// 🌌 Flame Solar System Simulation Game with Realistic Planetary Orbits
class FlameSolarSystemGame extends FlameGame with TapCallbacks {
  final List<PoketPlanet> planets;
  final PoketPlanet? selectedPlanet;
  final ValueChanged<PoketPlanet> onPlanetSelected;
  final ValueChanged<PoketPlanet> onPlanetDoubleTapped;
  final double tiltAngle; // 3D bend / side perspective

  FlameSolarSystemGame({
    required this.planets,
    required this.selectedPlanet,
    required this.onPlanetSelected,
    required this.onPlanetDoubleTapped,
    this.tiltAngle = 0.0, // 0.0 = top down, up to 0.75 = 3D isometric tilt
  });

  double _orbitElapsedSeconds = 0.0;
  final math.Random _random = math.Random(42);
  late List<_StarParticle> _stars;

  @override
  Color backgroundColor() => const Color(0xFF030712); // Deep Cosmos Starlight

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Generate starry cosmos background
    _stars = List.generate(120, (i) {
      return _StarParticle(
        x: (_random.nextDouble() - 0.5) * 1200,
        y: (_random.nextDouble() - 0.5) * 1200,
        radius: 0.8 + _random.nextDouble() * 1.6,
        alpha: 0.3 + _random.nextDouble() * 0.7,
        blinkSpeed: 1.5 + _random.nextDouble() * 3.0,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _orbitElapsedSeconds += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = size / 2;
    canvas.save();
    canvas.translate(center.x, center.y);

    // 1. Draw Starry Space
    for (final star in _stars) {
      final blink = (math.sin(_orbitElapsedSeconds * star.blinkSpeed) + 1) / 2;
      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: (star.alpha * (0.4 + blink * 0.6)).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(star.x, star.y), star.radius, starPaint);
    }

    // 2. Apply 3D Tilt Matrix (Side Perspective / Isometric Bend)
    // Scale Y by cos(tiltAngle) to create the elliptical 3D orbit plane
    final double yCompress = math.cos(tiltAngle).clamp(0.45, 1.0);

    // 3. Draw Orbit Rings
    for (final planet in planets) {
      final isSel = planet.id == selectedPlanet?.id;
      final ringPaint = Paint()
        ..color = isSel
            ? planet.primaryColor.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSel ? 2.0 : 0.8;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: planet.orbitDistance * 2,
          height: planet.orbitDistance * 2 * yCompress,
        ),
        ringPaint,
      );
    }

    // 4. Draw Fiery Glowing Sun at Center
    _renderSun(canvas);

    // 5. Draw Orbiting Planets (Sorted by Y for correct 3D depth overlap)
    final List<_RenderablePlanet> renderList = [];
    for (final planet in planets) {
      final angle = (_orbitElapsedSeconds * 0.4 * planet.orbitSpeed) % (2 * math.pi);
      final double px = planet.orbitDistance * math.cos(angle);
      final double py = planet.orbitDistance * math.sin(angle) * yCompress;

      renderList.add(_RenderablePlanet(
        planet: planet,
        position: Offset(px, py),
        angle: angle,
      ));
    }

    // Sort: farther away planets (smaller py) drawn behind Sun, closer ones drawn in front
    renderList.sort((a, b) => a.position.dy.compareTo(b.position.dy));

    for (final item in renderList) {
      _renderPlanet(canvas, item, yCompress);
    }

    canvas.restore();
  }

  void _renderSun(Canvas canvas) {
    final sunPulse = (math.sin(_orbitElapsedSeconds * 2.0) + 1) / 2;

    // Corona Outer Aura
    final outerCorona = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF59E0B).withValues(alpha: 0.5 + sunPulse * 0.2),
          const Color(0xFFEA580C).withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 64));
    canvas.drawCircle(Offset.zero, 64, outerCorona);

    // Inner Core
    final sunCore = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFFBEB),
          Color(0xFFFEF08A),
          Color(0xFFFBBF24),
          Color(0xFFEA580C),
        ],
        stops: [0.0, 0.35, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 36));
    canvas.drawCircle(Offset.zero, 34, sunCore);

    // Center text label
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Sun ☀️',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }

  void _renderPlanet(Canvas canvas, _RenderablePlanet item, double yCompress) {
    final p = item.planet;
    final pos = item.position;
    final isSel = p.id == selectedPlanet?.id;
    final radius = p.radius;

    // Planet Glow if selected
    if (isSel) {
      final glowPaint = Paint()
        ..color = p.glowColor.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(pos, radius + 8, glowPaint);
    }

    // 🪐 Saturn Rings
    if (p.id == 6) { // Saturn
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(-0.35);
      final ringPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withValues(alpha: 0.7),
            const Color(0xFFFDE68A).withValues(alpha: 0.9),
            const Color(0xFF78350F).withValues(alpha: 0.5),
          ],
        ).createShader(Rect.fromCenter(center: Offset.zero, width: radius * 3.8, height: radius * 1.2))
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.45;

      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: radius * 3.6, height: radius * 1.1),
        ringPaint,
      );
      canvas.restore();
    }

    // Planet Sphere (3D Shaded Sphere)
    final planetPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.85,
        colors: [
          Colors.white.withValues(alpha: 0.8),
          p.primaryColor,
          p.glowColor,
          const Color(0xFF030712), // Deep shadow away from sun
        ],
        stops: const [0.0, 0.45, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: radius));

    canvas.drawCircle(pos, radius, planetPaint);

    // Planet Selection Ring
    if (isSel) {
      final selBorder = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.drawCircle(pos, radius + 4, selBorder);
    }

    // Label above/below planet
    final namePainter = TextPainter(
      text: TextSpan(
        text: p.name,
        style: TextStyle(
          color: isSel ? const Color(0xFFFFD700) : Colors.white,
          fontSize: isSel ? 11 : 9.5,
          fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    namePainter.paint(canvas, Offset(pos.dx - namePainter.width / 2, pos.dy + radius + 4));
  }

  @override
  void onTapDown(TapDownEvent event) {
    final localTap = event.localPosition - size / 2;
    final double yCompress = math.cos(tiltAngle).clamp(0.45, 1.0);

    for (final planet in planets) {
      final angle = (_orbitElapsedSeconds * 0.4 * planet.orbitSpeed) % (2 * math.pi);
      final px = planet.orbitDistance * math.cos(angle);
      final py = planet.orbitDistance * math.sin(angle) * yCompress;

      final dist = (Offset(px, py) - Offset(localTap.x, localTap.y)).distance;
      if (dist <= planet.radius + 18) {
        if (selectedPlanet?.id == planet.id) {
          onPlanetDoubleTapped(planet);
        } else {
          onPlanetSelected(planet);
        }
        return;
      }
    }
  }
}

class _RenderablePlanet {
  final PoketPlanet planet;
  final Offset position;
  final double angle;

  _RenderablePlanet({
    required this.planet,
    required this.position,
    required this.angle,
  });
}

class _StarParticle {
  final double x;
  final double y;
  final double radius;
  final double alpha;
  final double blinkSpeed;

  _StarParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.alpha,
    required this.blinkSpeed,
  });
}
