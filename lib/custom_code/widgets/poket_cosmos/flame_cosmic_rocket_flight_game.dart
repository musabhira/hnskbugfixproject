import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_distance_service.dart';

/// 🌟 Dynamic Plasma Particle emitted from the Rocket Engine
class PlasmaThrustParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final double maxLife;
  final Color color;
  final double radius;

  PlasmaThrustParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.maxLife,
    required this.color,
    required this.radius,
  }) : life = maxLife;

  bool update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;
    return life > 0;
  }
}

/// 🌠 Star Particle for Deep Space Parallax
class CosmicStarParticle {
  double x;
  double y;
  double radius;
  double alpha;
  double blinkSpeed;
  double depth; // 0.2 (distant) to 1.0 (near)

  CosmicStarParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.alpha,
    required this.blinkSpeed,
    required this.depth,
  });
}

/// 🚀 Full-Screen Flame Interplanetary Rocket Flight Simulation
class FlameCosmicRocketFlightGame extends FlameGame {
  final CosmosFlightManifest manifest;
  final void Function(double currentKm, double progressFraction) onDistanceProgress;
  final VoidCallback onArrival;

  FlameCosmicRocketFlightGame({
    required this.manifest,
    required this.onDistanceProgress,
    required this.onArrival,
  });

  // Flight State
  double _flightProgress = 0.0; // 0.0 to 1.0
  double _currentSpeedMultiplier = 1.0;
  double _boostTimer = 0.0;
  bool _isHoldingThrust = false;
  bool _hasArrived = false;
  double _gameTime = 0.0;
  bool isPaused = false;

  // Particle Pools
  final List<CosmicStarParticle> _stars = [];
  final List<PlasmaThrustParticle> _thrustParticles = [];
  final math.Random _rng = math.Random(42);

  // Slingshot Planet State
  bool _isSlingshotLooping = false;
  String? _activeSlingshotCode;
  double _slingshotAngle = 0.0;

  @override
  Color backgroundColor() => const Color(0xFF070B14); // Deep space abyss

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Generate 160 deep space parallax stars
    for (int i = 0; i < 160; i++) {
      _stars.add(
        CosmicStarParticle(
          x: (_rng.nextDouble() - 0.5) * 1600,
          y: (_rng.nextDouble() - 0.5) * 2400,
          radius: 0.6 + _rng.nextDouble() * 1.8,
          alpha: 0.2 + _rng.nextDouble() * 0.8,
          blinkSpeed: 1.0 + _rng.nextDouble() * 3.0,
          depth: 0.3 + _rng.nextDouble() * 0.7,
        ),
      );
    }
  }

  /// ⚡ Single Tap Burst
  void applyThrustBoost() {
    _boostTimer = 0.85;
    _currentSpeedMultiplier = 2.8;
    _burstPlasmaSparks(count: 18);
  }

  /// 🔥 Continuous Long-Press Hyperthrust
  void startContinuousThrust() {
    _isHoldingThrust = true;
    _currentSpeedMultiplier = 3.4;
    _burstPlasmaSparks(count: 12);
  }

  void stopContinuousThrust() {
    _isHoldingThrust = false;
    if (_boostTimer <= 0) {
      _currentSpeedMultiplier = 1.0;
    }
  }

  void _burstPlasmaSparks({int count = 12}) {
    for (int i = 0; i < count; i++) {
      _thrustParticles.add(
        PlasmaThrustParticle(
          x: (_rng.nextDouble() - 0.5) * 14.0,
          y: 40.0,
          vx: (_rng.nextDouble() - 0.5) * 75,
          vy: 85.0 + _rng.nextDouble() * 140,
          maxLife: 0.35 + _rng.nextDouble() * 0.25,
          color: (i % 2 == 0) ? const Color(0xFFFFD700) : const Color(0xFF00E5FF),
          radius: 2.5 + _rng.nextDouble() * 2.5,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPaused) return;
    _gameTime += dt;

    if (_hasArrived) return;

    // Manage continuous hold or single tap boost decay
    if (_isHoldingThrust) {
      _currentSpeedMultiplier = 3.4;
      if (_rng.nextDouble() < 0.4) {
        _burstPlasmaSparks(count: 3);
      }
    } else if (_boostTimer > 0) {
      _boostTimer -= dt;
      if (_boostTimer <= 0) {
        _currentSpeedMultiplier = 1.0;
      }
    }

    // Normal flight speed: base transit ~10-12s, boost cuts it to ~4-5s
    final double baseSpeed = manifest.isSamePlanet ? 0.16 : 0.085;
    final double step = baseSpeed * _currentSpeedMultiplier * dt;

    // Slingshot loop logic around intermediate celestial bodies (staged e.g. Moon then Mars)
    final intermediateCodes = manifest.intermediatePlanetCodes;
    bool inSlingshot = false;
    String? currentTargetCode;

    if (intermediateCodes.isNotEmpty) {
      if (intermediateCodes.length == 1) {
        if (_flightProgress >= 0.35 && _flightProgress <= 0.65) {
          inSlingshot = true;
          currentTargetCode = intermediateCodes[0];
        }
      } else {
        // Multi-stop staging: Moon loop at 0.25..0.44, Mars/Jupiter assist loop at 0.50..0.68
        if (_flightProgress >= 0.25 && _flightProgress <= 0.44) {
          inSlingshot = true;
          currentTargetCode = intermediateCodes[0];
        } else if (_flightProgress >= 0.50 && _flightProgress <= 0.68) {
          inSlingshot = true;
          currentTargetCode = intermediateCodes[1];
        }
      }
    }

    if (inSlingshot) {
      _isSlingshotLooping = true;
      _activeSlingshotCode = currentTargetCode;
      _slingshotAngle += dt * 3.8 * _currentSpeedMultiplier;
      _flightProgress += step * 0.55; // Slower forward progress while in gravity assist loop
    } else {
      _isSlingshotLooping = false;
      _activeSlingshotCode = null;
      _flightProgress += step;
    }

    // Emit standard plasma flame engine exhaust
    final spawnCount = (_boostTimer > 0) ? 4 : 2;
    for (int i = 0; i < spawnCount; i++) {
      _thrustParticles.add(
        PlasmaThrustParticle(
          x: (_rng.nextDouble() - 0.5) * 8.0,
          y: 36.0,
          vx: (_rng.nextDouble() - 0.5) * 24.0,
          vy: 45.0 + _rng.nextDouble() * 75.0,
          maxLife: 0.22 + _rng.nextDouble() * 0.18,
          color: (_rng.nextBool()) ? const Color(0xFF38BDF8) : const Color(0xFFFFD700),
          radius: 1.5 + _rng.nextDouble() * 1.5,
        ),
      );
    }

    // Update existing particles
    _thrustParticles.removeWhere((p) => !p.update(dt));

    // Cap and check arrival
    if (_flightProgress >= 1.0) {
      _flightProgress = 1.0;
      _hasArrived = true;
      onDistanceProgress(manifest.distanceKm, 1.0);
      onArrival();
    } else {
      final currentKm = manifest.distanceKm * _flightProgress;
      onDistanceProgress(currentKm, _flightProgress);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;
    final cx = w / 2;
    final cy = h / 2;

    // 1. Cosmic Nebula Dust Cloud
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF312E81).withValues(alpha: 0.22),
          const Color(0xFF0F172A).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        radius: 0.85,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), nebulaPaint);

    // 2. Parallax Stars (Moving downward as rocket travels upward)
    final scrollOffset = (_flightProgress * 1800.0) % 2400.0;
    canvas.save();
    canvas.translate(cx, cy);
    for (final star in _stars) {
      final sy = ((star.y + scrollOffset * star.depth + 1200) % 2400) - 1200;
      final blink = (math.sin(_gameTime * star.blinkSpeed) + 1.0) / 2.0;
      final paint = Paint()
        ..color = Colors.white.withValues(
          alpha: (star.alpha * (0.4 + blink * 0.6)).clamp(0.0, 1.0),
        );
      canvas.drawCircle(Offset(star.x, sy), star.radius, paint);
    }
    canvas.restore();

    // 3. Render Origin Atmosphere & Planetary Launch Surface (Receding as rocket climbs)
    if (_flightProgress < 0.42) {
      final originAlpha = (1.0 - (_flightProgress / 0.42)).clamp(0.0, 1.0);
      _drawOriginAtmosphereAndSurface(canvas, w, h, originAlpha);
    }

    // 4. Render Intermediate Planet & Gravitational Slingshot Loop
    final activeCode = _activeSlingshotCode;
    if (activeCode != null) {
      final double planetCenterY = h * 0.45;
      final double planetRadius = 55.0;

      // Draw gravitational orbit guide ring
      final orbitRingPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(Offset(cx, planetCenterY), 95.0, orbitRingPaint);

      // Draw intermediate planet
      _drawPlanetSphere(canvas, cx, planetCenterY, planetRadius, activeCode, alpha: 1.0);

      // Draw label
      final name = PoketCosmosDistanceService.instance.getCleanPlanetName(activeCode);
      _drawText(canvas, '$name Gravity Assist', cx, planetCenterY + planetRadius + 14,
          color: const Color(0xFFFFD700));
    }

    // 5. Render Destination Celestial Sphere (Approaching from top: 0.65 to 1.0)
    if (_flightProgress > 0.60) {
      final destProgress = ((_flightProgress - 0.60) / 0.40).clamp(0.0, 1.0);
      final destRadius = 35.0 + (destProgress * 85.0);
      final destY = -30.0 + (destProgress * (h * 0.38));
      _drawPlanetSphere(canvas, cx, destY, destRadius, manifest.destinationCode, alpha: destProgress);
    }

    // 6. Rocket Ship (Positioned in center, tilts/orbits dynamically during slingshot)
    canvas.save();
    double rocketX = cx;
    double rocketY = cy + 40.0;
    double rocketAngle = 0.0;

    if (_isSlingshotLooping) {
      // Orbiting around intermediate planet at (cx, h * 0.45)
      final orbitR = 95.0;
      rocketX = cx + math.cos(_slingshotAngle) * orbitR;
      rocketY = (h * 0.45) + math.sin(_slingshotAngle) * orbitR;
      rocketAngle = _slingshotAngle + (math.pi / 2); // Facing tangential flight direction
    }

    canvas.translate(rocketX, rocketY);
    canvas.rotate(rocketAngle);

    // Render Engine Exhaust Particles
    for (final p in _thrustParticles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radius * (0.8 + alpha * 0.4),
        Paint()..color = p.color.withValues(alpha: alpha),
      );
    }

    // Draw Sleek Cosmic Rocket Body
    _drawRocketShip(canvas, isBoosting: _boostTimer > 0);
    canvas.restore();
  }

  /// 🚀 Sleek Futuristic Spacecraft
  void _drawRocketShip(Canvas canvas, {bool isBoosting = false}) {
    // 1. Engine Core Glow
    final glowPaint = Paint()
      ..color = (isBoosting ? const Color(0xFFFF9100) : const Color(0xFF00E5FF)).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(const Offset(0, 28), isBoosting ? 18 : 10, glowPaint);

    // 2. Rocket Fins / Wings
    final finPaint = Paint()..color = const Color(0xFF0284C7);
    final leftFin = Path()
      ..moveTo(-8, 12)
      ..lineTo(-24, 28)
      ..lineTo(-8, 24)
      ..close();
    canvas.drawPath(leftFin, finPaint);

    final rightFin = Path()
      ..moveTo(8, 12)
      ..lineTo(24, 28)
      ..lineTo(8, 24)
      ..close();
    canvas.drawPath(rightFin, finPaint);

    // 3. Main Hull Fuselage
    final hullPath = Path()
      ..moveTo(0, -38) // Nose cone tip
      ..cubicTo(14, -14, 13, 14, 11, 26)
      ..lineTo(-11, 26)
      ..cubicTo(-13, 14, -14, -14, 0, -38)
      ..close();

    final hullPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0), Color(0xFF94A3B8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-14, -38, 28, 64));
    canvas.drawPath(hullPath, hullPaint);

    // 4. Cockpit Viewport Visor
    final visorPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawOval(
      const Rect.fromLTWH(-5.5, -16, 11, 16),
      visorPaint,
    );
    canvas.drawOval(
      const Rect.fromLTWH(-3.5, -14, 5, 8),
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );

    // 5. Golden Solar Accent Stripes
    final goldStripe = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRect(const Rect.fromLTWH(-7, 2, 14, 2.5), goldStripe);
  }

  /// 🪐 3D Planet Sphere Renderer with Atmospheres & Surface Bands
  void _drawPlanetSphere(Canvas canvas, double x, double y, double radius, String planetCode, {double alpha = 1.0}) {
    canvas.save();
    canvas.translate(x, y);

    final Color primary;
    final Color secondary;
    final Color atmosphericGlow;

    switch (planetCode.toUpperCase()) {
      case 'MAR':
        primary = const Color(0xFFDC2626);
        secondary = const Color(0xFF7C2D12);
        atmosphericGlow = const Color(0xFFF97316);
        break;
      case 'JUP':
        primary = const Color(0xFFD97706);
        secondary = const Color(0xFF78350F);
        atmosphericGlow = const Color(0xFFFDE68A);
        break;
      case 'SAT':
        primary = const Color(0xFFEAB308);
        secondary = const Color(0xFF854D0E);
        atmosphericGlow = const Color(0xFFFEF08A);
        break;
      case 'LUN':
        primary = const Color(0xFF94A3B8);
        secondary = const Color(0xFF334155);
        atmosphericGlow = const Color(0xFFCBD5E1);
        break;
      case 'EUR':
        primary = const Color(0xFF38BDF8);
        secondary = const Color(0xFF0369A1);
        atmosphericGlow = const Color(0xFFBAE6FD);
        break;
      case 'VEN':
        primary = const Color(0xFFF59E0B);
        secondary = const Color(0xFFB45309);
        atmosphericGlow = const Color(0xFFFDE047);
        break;
      case 'TTN':
        primary = const Color(0xFF10B981);
        secondary = const Color(0xFF064E3B);
        atmosphericGlow = const Color(0xFF6EE7B7);
        break;
      case 'NEP':
        primary = const Color(0xFF2563EB);
        secondary = const Color(0xFF1E3A8A);
        atmosphericGlow = const Color(0xFF93C5FD);
        break;
      case 'PLT':
        primary = const Color(0xFFA855F7);
        secondary = const Color(0xFF581C87);
        atmosphericGlow = const Color(0xFFE9D5FF);
        break;
      default: // EP Earth
        primary = const Color(0xFF0284C7);
        secondary = const Color(0xFF16A34A);
        atmosphericGlow = const Color(0xFF38BDF8);
    }

    // Outer Atmospheric Halo
    canvas.drawCircle(
      Offset.zero,
      radius * 1.18,
      Paint()
        ..color = atmosphericGlow.withValues(alpha: 0.28 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Planet Body Sphere (3D Light Spherical Gradient)
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.9,
        colors: [primary.withValues(alpha: alpha), secondary.withValues(alpha: alpha)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
    canvas.drawCircle(Offset.zero, radius, spherePaint);

    // Special: Saturn Ring System
    if (planetCode.toUpperCase() == 'SAT') {
      final ringPaint = Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.55 * alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.22;
      canvas.save();
      canvas.rotate(0.35);
      canvas.scale(1.0, 0.32);
      canvas.drawCircle(Offset.zero, radius * 1.85, ringPaint);
      canvas.restore();
    }

    canvas.restore();
  }

  /// 🌍 Realistic Origin Atmosphere & Ground Launch Surface with House
  /// Atmospheric colors match CitadelScenicLandscapePainter celestial horizons
  void _drawOriginAtmosphereAndSurface(Canvas canvas, double w, double h, double alpha) {
    final cx = w / 2;
    final code = manifest.originCode.toUpperCase();

    // 1. Atmosphere Gradient (Sky layer transitioning into space from horizon)
    final List<Color> skyColors;
    final Color landColor;

    switch (code) {
      case 'MAR':
        // Mars: Deep rose-wine to sunset pink & coral into warm amber & peach
        skyColors = const [
          Color(0xFFFED7AA), // Peach Horizon Haze
          Color(0xFFF97316), // Warm Amber Glow
          Color(0xFFE11D48), // Vivid Coral Pink
          Color(0xFF9F1239), // Sunset Magenta-Pink
          Color(0xFF4C0519), // Deep Rose-Wine
        ];
        landColor = const Color(0xFF991B1B);
        break;
      case 'JUP':
        // Jupiter: Jovian cobalt & indigo into auroral gold
        skyColors = const [
          Color(0xFFF59E0B), // Auroral Gold Horizon
          Color(0xFF0284C7), // Azure Ribbon
          Color(0xFF1D4ED8), // Electric Jovian Cobalt
          Color(0xFF1E1B4B), // Royal Indigo
          Color(0xFF020617), // Deep Space Abyss
        ];
        landColor = const Color(0xFF065F46);
        break;
      case 'SAT':
        // Saturn: Ring gold & amber into cosmic purple
        skyColors = const [
          Color(0xFFFEF08A), // Radiant Gold Horizon
          Color(0xFFD97706), // Golden Amber
          Color(0xFFDB2777), // Sunset Pink Glow
          Color(0xFF9D174D), // Twilight Rose-Pink
          Color(0xFF3B0764), // Cosmic Purple Void
        ];
        landColor = const Color(0xFF92400E);
        break;
      case 'LUN':
        // Moon: Lunar ash into slate & pure obsidian void
        skyColors = const [
          Color(0xFF1E293B), // Horizon Lunar Ash
          Color(0xFF0F172A), // Slate Space Dusk
          Color(0xFF020617), // Deep Obsidian
          Color(0xFF000000), // Pure Black Void
        ];
        landColor = const Color(0xFF334155);
        break;
      case 'EUR':
        // Europa: Glacial ice into cyan aurora & cosmic indigo
        skyColors = const [
          Color(0xFFE0F2FE), // Glacial White Horizon
          Color(0xFF0284C7), // Shimmering Cyan Ice
          Color(0xFFC026D3), // Rose-Violet Twilight
          Color(0xFF701A75), // Deep Magenta Glow
          Color(0xFF1E1B4B), // Cosmic Indigo Void
        ];
        landColor = const Color(0xFF0284C7);
        break;
      case 'VEN':
        // Venus: Sulfuric golden dawn into apricot & plum twilight
        skyColors = const [
          Color(0xFFFEF08A), // Radiant Warm Corona
          Color(0xFFF59E0B), // Sulfuric Golden Dawn
          Color(0xFFC2410C), // Deep Terracotta
          Color(0xFF831843), // Sunset Wine
          Color(0xFF4A044E), // Deep Plum Twilight
        ];
        landColor = const Color(0xFFB45309);
        break;
      case 'TTN':
        // Titan: Golden methane into methane cyan & petrol teal
        skyColors = const [
          Color(0xFFFBBF24), // Golden Methane Horizon
          Color(0xFFB45309), // Amber Smog Layer
          Color(0xFF0F766E), // Methane Cyan Glow
          Color(0xFF065F46), // Emerald Twilight
          Color(0xFF042F2E), // Deep Petrol Teal
        ];
        landColor = const Color(0xFF047857);
        break;
      case 'NEP':
        // Neptune: Pale icy silver into cyan & electric violet
        skyColors = const [
          Color(0xFFE0E7FF), // Pale Icy Silver Horizon
          Color(0xFF0284C7), // Shimmering Cyan Aurora
          Color(0xFF4338CA), // Electric Violet Ribbon
          Color(0xFF1E1B4B), // Midnight Indigo
          Color(0xFF020617), // Deep Space Abyss
        ];
        landColor = const Color(0xFF1D4ED8);
        break;
      case 'PLT':
        // Pluto: Distant frozen rose into neon purple & royal amethyst
        skyColors = const [
          Color(0xFFF5D0FE), // Distant Frozen Rose Horizon
          Color(0xFFA855F7), // Neon Purple Aurora
          Color(0xFF6B21A8), // Vibrant Violet Nebula
          Color(0xFF2E1065), // Cosmic Amethyst Twilight
          Color(0xFF030712), // Deep Space Obsidian
        ];
        landColor = const Color(0xFF581C87);
        break;
      default: // Earth Prime
        skyColors = const [
          Color(0xFFBAE6FD), // Horizon Mist
          Color(0xFF38BDF8), // Vibrant Cyan
          Color(0xFF0284C7), // Deep Azure
          Color(0xFF0C4A6E), // Deep Sea
          Color(0xFF020617), // Space Void
        ];
        landColor = const Color(0xFF16A34A);
    }

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          for (final c in skyColors) c.withValues(alpha: alpha * 0.9),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // 2. Horizon ground surface curve that drops down during ascent
    final surfaceY = h * 0.72 + (_flightProgress * h * 1.55);
    final surfacePath = Path()
      ..moveTo(-50, surfaceY)
      ..quadraticBezierTo(cx, surfaceY - 26, w + 50, surfaceY)
      ..lineTo(w + 50, h + 100)
      ..lineTo(-50, h + 100)
      ..close();

    final landPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          landColor.withValues(alpha: 0.95 * alpha),
          const Color(0xFF0B132B).withValues(alpha: 0.95 * alpha),
        ],
      ).createShader(Rect.fromLTWH(0, surfaceY - 26, w, h - surfaceY + 126));
    canvas.drawPath(surfacePath, landPaint);

    // 3. Citizen Launchpad & Home Base (At center-left of the launch surface)
    final houseX = cx - 65;
    final houseY = surfaceY - 14;

    // Launch Gantry Tower
    final gantryPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(cx + 40, houseY), Offset(cx + 40, houseY - 45), gantryPaint);
    canvas.drawLine(Offset(cx + 34, houseY - 30), Offset(cx + 40, houseY - 20), gantryPaint);

    // Launchpad Lights
    final lightPaint = Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.85 * alpha);
    canvas.drawCircle(Offset(cx - 30, houseY + 6), 3, lightPaint);
    canvas.drawCircle(Offset(cx + 30, houseY + 6), 3, lightPaint);

    // Citizen House Base
    final housePaint = Paint()..color = const Color(0xFF1E293B).withValues(alpha: 0.95 * alpha);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(houseX, houseY), width: 34, height: 22),
        const Radius.circular(5),
      ),
      housePaint,
    );
    // House Roof
    final roofPaint = Paint()..color = const Color(0xFFE2E8F0).withValues(alpha: 0.95 * alpha);
    final roofPath = Path()
      ..moveTo(houseX - 20, houseY - 11)
      ..lineTo(houseX, houseY - 24)
      ..lineTo(houseX + 20, houseY - 11)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Origin Location Label Pill
    _drawText(
      canvas,
      '🏡 ${manifest.originName.toUpperCase()} SURFACE',
      cx,
      surfaceY + 18,
      color: Colors.white.withValues(alpha: 0.85 * alpha),
    );
  }

  void _drawText(Canvas canvas, String text, double x, double y, {Color color = Colors.white}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(x - (textPainter.width / 2), y));
  }
}
