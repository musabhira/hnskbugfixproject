import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'poket_cosmos_models.dart';

/// 🌌 Scientific 3D Flame Solar System Simulation with Moons & Deep Space
class FlameSolarSystemGame extends FlameGame with TapCallbacks {
  final List<PoketPlanet> planets;
  final PoketPlanet? selectedPlanet;
  final ValueChanged<PoketPlanet> onPlanetSelected;
  final double tiltAngle; // 3D bend / side perspective
  final bool
      followSelectedPlanet; // Center camera on selected planet (e.g. Jupiter)

  FlameSolarSystemGame({
    required this.planets,
    required this.selectedPlanet,
    required this.onPlanetSelected,
    this.tiltAngle = 0.45,
    this.followSelectedPlanet = false,
  });

  double _orbitElapsedSeconds = 0.0;
  final math.Random _random = math.Random(101);
  late List<_StarParticle> _stars;

  @override
  Color backgroundColor() => const Color(0xFF0D121D); // Deep midnight cosmos

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 140 subtle twinkling stars
    _stars = List.generate(140, (i) {
      return _StarParticle(
        x: (_random.nextDouble() - 0.5) * 1400,
        y: (_random.nextDouble() - 0.5) * 1400,
        radius: 0.7 + _random.nextDouble() * 1.5,
        alpha: 0.25 + _random.nextDouble() * 0.7,
        blinkSpeed: 1.0 + _random.nextDouble() * 2.5,
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
    final double yCompress = math.cos(tiltAngle).clamp(0.35, 1.0);

    // 1. Draw Starfield in deep space background
    canvas.save();
    canvas.translate(center.x, center.y);
    for (final star in _stars) {
      final blink = (math.sin(_orbitElapsedSeconds * star.blinkSpeed) + 1) / 2;
      final starPaint = Paint()
        ..color = Colors.white.withValues(
            alpha: (star.alpha * (0.35 + blink * 0.65)).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(star.x, star.y), star.radius, starPaint);
    }
    canvas.restore();

    // 2. Camera centering on selected planet (e.g. Jupiter)
    double targetX = 0.0;
    double targetY = 0.0;
    if (followSelectedPlanet && selectedPlanet != null) {
      final selAngle =
          (_orbitElapsedSeconds * 0.35 * selectedPlanet!.orbitSpeed) %
              (2 * math.pi);
      targetX = selectedPlanet!.orbitDistance * math.cos(selAngle);
      targetY = selectedPlanet!.orbitDistance * math.sin(selAngle) * yCompress;
    }

    canvas.save();
    canvas.translate(center.x - targetX, center.y - targetY);

    // 3. Draw Orbit Track Rings
    for (final planet in planets) {
      final isSel = planet.id == selectedPlanet?.id;
      final ringPaint = Paint()
        ..color = isSel
            ? planet.primaryColor.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSel ? 1.8 : 0.75;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: planet.orbitDistance * 2,
          height: planet.orbitDistance * 2 * yCompress,
        ),
        ringPaint,
      );
    }

    // 4. Draw Fiery Central Sun
    _renderSun(canvas);

    // 5. Draw Orbiting Planets with Scientific Moons (Sorted by Y for true 3D depth)
    final List<_RenderablePlanet> renderList = [];
    for (final planet in planets) {
      final angle =
          (_orbitElapsedSeconds * 0.35 * planet.orbitSpeed) % (2 * math.pi);
      final double px = planet.orbitDistance * math.cos(angle);
      final double py = planet.orbitDistance * math.sin(angle) * yCompress;

      renderList.add(_RenderablePlanet(
        planet: planet,
        position: Offset(px, py),
        angle: angle,
      ));
    }

    renderList.sort((a, b) => a.position.dy.compareTo(b.position.dy));

    for (final item in renderList) {
      _renderPlanet(canvas, item, yCompress);
    }

    canvas.restore();
  }

  void _renderSun(Canvas canvas) {
    final sunPulse = (math.sin(_orbitElapsedSeconds * 2.2) + 1) / 2;

    // Glowing Sun Corona
    final outerCorona = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF59E0B).withValues(alpha: 0.45 + sunPulse * 0.25),
          const Color(0xFFEA580C).withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.3, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 58));
    canvas.drawCircle(Offset.zero, 58, outerCorona);

    // Sun Core
    final sunCore = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFFBEB),
          Color(0xFFFEF08A),
          Color(0xFFFBBF24),
          Color(0xFFEA580C),
        ],
        stops: [0.0, 0.35, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 32));
    canvas.drawCircle(Offset.zero, 30, sunCore);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'Sun ☀️',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 9.5,
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

    // Planet Selection Aura (Hardware Shader)
    if (isSel) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            p.glowColor.withValues(alpha: 0.65),
            p.glowColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: radius + 10));
      canvas.drawCircle(pos, radius + 10, glowPaint);
    }

    // 🪐 Saturn Rings
    if (p.id == 6) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(-0.32);
      final ringPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withValues(alpha: 0.7),
            const Color(0xFFFDE68A).withValues(alpha: 0.9),
            const Color(0xFF78350F).withValues(alpha: 0.4),
          ],
        ).createShader(Rect.fromCenter(
            center: Offset.zero, width: radius * 3.6, height: radius * 1.1))
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.4;

      canvas.drawOval(
        Rect.fromCenter(
            center: Offset.zero, width: radius * 3.6, height: radius * 1.1),
        ringPaint,
      );
      canvas.restore();
    }

    // 3D Shaded Planet Sphere
    final planetPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.85,
        colors: [
          Colors.white.withValues(alpha: 0.85),
          p.primaryColor,
          p.glowColor,
          const Color(0xFF030712),
        ],
        stops: const [0.0, 0.45, 0.82, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: radius));

    canvas.drawCircle(pos, radius, planetPaint);

    // Selected Border
    if (isSel) {
      final selBorder = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(pos, radius + 3, selBorder);
    }

    // 🌕 Scientific Satellites / Moons Orbiting around Parent Planet (Earth's Moon, Jupiter's Moons, etc.)
    for (final sat in p.satellites) {
      final satAngle = _orbitElapsedSeconds *
          (0.8 + sat.orbitSpeed.abs() * 0.4) *
          (sat.orbitSpeed < 0 ? -1 : 1);
      final satDist = sat.orbitDistance;
      final sx = pos.dx + satDist * math.cos(satAngle);
      final sy = pos.dy + satDist * math.sin(satAngle) * yCompress;
      final satPos = Offset(sx, sy);

      // Satellite Elliptical Orbit Track around Parent Planet
      final satOrbitPaint = Paint()
        ..color = sat.glowColor.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.65;
      canvas.drawOval(
        Rect.fromCenter(
            center: pos, width: satDist * 2, height: satDist * 2 * yCompress),
        satOrbitPaint,
      );

      // Satellite Sphere with 3D Shading
      final satPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          colors: [
            Colors.white,
            sat.primaryColor,
            sat.glowColor,
          ],
        ).createShader(Rect.fromCircle(center: satPos, radius: sat.radius));
      canvas.drawCircle(satPos, sat.radius, satPaint);

      // Mini Moon Label (e.g. "The Moon 🌕" or "Europa 🧊")
      final satLabel = TextPainter(
        text: TextSpan(
          text: sat.name,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 7.2,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      satLabel.paint(canvas,
          Offset(satPos.dx - satLabel.width / 2, satPos.dy + sat.radius + 2));
    }

    // Planet Label
    final namePainter = TextPainter(
      text: TextSpan(
        text: p.isExoplanet
            ? '🌌 ${p.name}'
            : (p.isDwarfPlanet ? '❄️ ${p.name}' : p.name),
        style: TextStyle(
          color: isSel ? const Color(0xFFFFD700) : Colors.white70,
          fontSize: isSel ? 10.5 : 9.0,
          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    namePainter.paint(
        canvas, Offset(pos.dx - namePainter.width / 2, pos.dy + radius + 4));
  }

  @override
  void onTapDown(TapDownEvent event) {
    final double yCompress = math.cos(tiltAngle).clamp(0.35, 1.0);
    double targetX = 0.0;
    double targetY = 0.0;
    if (followSelectedPlanet && selectedPlanet != null) {
      final selAngle =
          (_orbitElapsedSeconds * 0.35 * selectedPlanet!.orbitSpeed) %
              (2 * math.pi);
      targetX = selectedPlanet!.orbitDistance * math.cos(selAngle);
      targetY = selectedPlanet!.orbitDistance * math.sin(selAngle) * yCompress;
    }
    final localTap =
        event.localPosition - size / 2 + Vector2(targetX, targetY);

    for (final planet in planets) {
      final angle =
          (_orbitElapsedSeconds * 0.35 * planet.orbitSpeed) % (2 * math.pi);
      final px = planet.orbitDistance * math.cos(angle);
      final py = planet.orbitDistance * math.sin(angle) * yCompress;
      final planetPos = Offset(px, py);

      // 1. Check if user tapped directly on one of this planet's natural satellites (Moons)
      for (final sat in planet.satellites) {
        final satAngle = _orbitElapsedSeconds *
            (0.8 + sat.orbitSpeed.abs() * 0.4) *
            (sat.orbitSpeed < 0 ? -1 : 1);
        final sx = planetPos.dx + sat.orbitDistance * math.cos(satAngle);
        final sy =
            planetPos.dy + sat.orbitDistance * math.sin(satAngle) * yCompress;
        final satDist =
            (Offset(sx, sy) - Offset(localTap.x, localTap.y)).distance;

        if (satDist <= sat.radius + 14) {
          onPlanetSelected(sat.toPlanet());
          return;
        }
      }

      // 2. Check if user tapped on the planet body
      final dist = (planetPos - Offset(localTap.x, localTap.y)).distance;
      if (dist <= planet.radius + 18) {
        onPlanetSelected(planet);
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
