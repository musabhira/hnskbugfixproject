import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_distance_service.dart';
import 'poket_cosmos_transit_models.dart';

/// 🌟 Dynamic Engine Exhaust / Contrail Particle
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
  double depth;

  CosmicStarParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.alpha,
    required this.blinkSpeed,
    required this.depth,
  });
}

/// ☁️ Drifting Atmospheric Cloud Particle for Aeroplane Flight
class AtmosphericCloud {
  double x;
  double y;
  double width;
  double height;
  double speed;
  double opacity;

  AtmosphericCloud({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.speed,
    required this.opacity,
  });
}

/// 🏝️ Passing Archipelago Island Beneath Aeroplane Flight
class PassingIsland {
  double relX; // -0.8 to 0.8
  double appearProgress; // 0.0 to 0.9
  double radius;
  Color sandColor;
  Color vegetationColor;

  PassingIsland({
    required this.relX,
    required this.appearProgress,
    required this.radius,
    required this.sandColor,
    required this.vegetationColor,
  });
}

/// 🚀 / ✈️ Full-Screen Flame Cosmic & Atmospheric Flight Simulation
class FlameCosmicRocketFlightGame extends FlameGame {
  final CosmosFlightManifest manifest;
  final void Function(double currentKm, double progressFraction)
      onDistanceProgress;
  final VoidCallback onArrival;
  final CosmosVehicle? vehicle;

  FlameCosmicRocketFlightGame({
    required this.manifest,
    required this.onDistanceProgress,
    required this.onArrival,
    this.vehicle,
  });

  // Flight State
  double _flightProgress = 0.0; // 0.0 to 1.0
  double _currentSpeedMultiplier = 1.0;
  double _boostTimer = 0.0;
  bool _isHoldingThrust = false;
  bool _hasArrived = false;
  double _gameTime = 0.0;
  bool isPaused = false;

  // Zoom Level (0.6x to 1.8x)
  double zoomLevel = 1.0;

  void setZoom(double z) {
    zoomLevel = z.clamp(0.6, 1.8);
  }

  void zoomIn() {
    setZoom(zoomLevel + 0.15);
  }

  void zoomOut() {
    setZoom(zoomLevel - 0.15);
  }

  void resetZoom() {
    zoomLevel = 1.0;
  }

  // Particle & Object Pools
  final List<CosmicStarParticle> _stars = [];
  final List<PlasmaThrustParticle> _thrustParticles = [];
  final List<AtmosphericCloud> _clouds = [];
  final List<PassingIsland> _passingIslands = [];
  final math.Random _rng = math.Random(42);

  // Slingshot State for Interplanetary
  bool _isSlingshotLooping = false;
  String? _activeSlingshotCode;
  double _slingshotAngle = 0.0;

  @override
  Color backgroundColor() => manifest.isSamePlanet
      ? const Color(0xFF0369A1) // Oceanic sky blue
      : const Color(0xFF070B14); // Deep space black void

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    if (manifest.isSamePlanet) {
      _initAtmosphericEnvironment();
    } else {
      _initSpaceEnvironment();
    }
  }

  void _initSpaceEnvironment() {
    _stars.clear();
    for (int i = 0; i < 170; i++) {
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

  void _initAtmosphericEnvironment() {
    _clouds.clear();
    for (int i = 0; i < 18; i++) {
      _clouds.add(
        AtmosphericCloud(
          x: (_rng.nextDouble() - 0.5) * 1200,
          y: (_rng.nextDouble() - 0.5) * 2200,
          width: 90.0 + _rng.nextDouble() * 140.0,
          height: 38.0 + _rng.nextDouble() * 45.0,
          speed: 120.0 + _rng.nextDouble() * 180.0,
          opacity: 0.35 + _rng.nextDouble() * 0.45,
        ),
      );
    }

    _passingIslands.clear();
    _passingIslands.addAll([
      PassingIsland(
        relX: -0.35,
        appearProgress: 0.12,
        radius: 48,
        sandColor: const Color(0xFFFDE68A),
        vegetationColor: const Color(0xFF15803D),
      ),
      PassingIsland(
        relX: 0.42,
        appearProgress: 0.28,
        radius: 65,
        sandColor: const Color(0xFFFEF08A),
        vegetationColor: const Color(0xFF16A34A),
      ),
      PassingIsland(
        relX: -0.22,
        appearProgress: 0.46,
        radius: 54,
        sandColor: const Color(0xFFFDE68A),
        vegetationColor: const Color(0xFF047857),
      ),
      PassingIsland(
        relX: 0.30,
        appearProgress: 0.62,
        radius: 42,
        sandColor: const Color(0xFFFEF08A),
        vegetationColor: const Color(0xFF15803D),
      ),
    ]);
  }

  /// ⚡ Single Tap Burst
  void applyThrustBoost() {
    _boostTimer = 0.85;
    _currentSpeedMultiplier = 2.8;
    _burstParticles(count: manifest.isSamePlanet ? 14 : 18);
  }

  /// 🔥 Continuous Long-Press Hyperthrust
  void startContinuousThrust() {
    _isHoldingThrust = true;
    _currentSpeedMultiplier = 3.4;
    _burstParticles(count: manifest.isSamePlanet ? 10 : 14);
  }

  void stopContinuousThrust() {
    _isHoldingThrust = false;
    if (_boostTimer <= 0) {
      _currentSpeedMultiplier = 1.0;
    }
  }

  void _burstParticles({int count = 12}) {
    for (int i = 0; i < count; i++) {
      if (manifest.isSamePlanet) {
        // Airplane twin jet contrails & afterburner sparks
        final side = (i % 2 == 0) ? -18.0 : 18.0;
        _thrustParticles.add(
          PlasmaThrustParticle(
            x: side + (_rng.nextDouble() - 0.5) * 6.0,
            y: 22.0,
            vx: (_rng.nextDouble() - 0.5) * 35,
            vy: 95.0 + _rng.nextDouble() * 120,
            maxLife: 0.45 + _rng.nextDouble() * 0.3,
            color: (i % 3 == 0)
                ? const Color(0xFFFFD700)
                : Colors.white.withValues(alpha: 0.9),
            radius: 2.0 + _rng.nextDouble() * 2.5,
          ),
        );
      } else {
        // Rocket plasma thruster
        _thrustParticles.add(
          PlasmaThrustParticle(
            x: (_rng.nextDouble() - 0.5) * 14.0,
            y: 40.0,
            vx: (_rng.nextDouble() - 0.5) * 75,
            vy: 85.0 + _rng.nextDouble() * 140,
            maxLife: 0.35 + _rng.nextDouble() * 0.25,
            color: (i % 2 == 0)
                ? const Color(0xFFFFD700)
                : const Color(0xFF00E5FF),
            radius: 2.5 + _rng.nextDouble() * 2.5,
          ),
        );
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPaused) return;
    _gameTime += dt;

    if (_hasArrived) return;

    // Boost decay
    if (_isHoldingThrust) {
      _currentSpeedMultiplier = 3.4;
      if (_rng.nextDouble() < 0.45) {
        _burstParticles(count: 3);
      }
    } else if (_boostTimer > 0) {
      _boostTimer -= dt;
      if (_boostTimer <= 0) {
        _currentSpeedMultiplier = 1.0;
      }
    }

    // Flight forward speed factoring selected vehicle multiplier
    final double vehicleMultiplier = vehicle?.speedMultiplier ?? 1.0;
    final double baseSpeed =
        (manifest.isSamePlanet ? 0.13 : 0.088) * vehicleMultiplier;
    final double step = baseSpeed * _currentSpeedMultiplier * dt;

    if (!manifest.isSamePlanet) {
      // Slingshot logic for interplanetary rocket
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
        _flightProgress += step * 0.55;
      } else {
        _isSlingshotLooping = false;
        _activeSlingshotCode = null;
        _flightProgress += step;
      }

      // Continuous plasma trail for rocket
      final spawnCount = (_boostTimer > 0) ? 4 : 2;
      for (int i = 0; i < spawnCount; i++) {
        _thrustParticles.add(
          PlasmaThrustParticle(
            x: (_rng.nextDouble() - 0.5) * 8.0,
            y: 36.0,
            vx: (_rng.nextDouble() - 0.5) * 24.0,
            vy: 45.0 + _rng.nextDouble() * 75.0,
            maxLife: 0.22 + _rng.nextDouble() * 0.18,
            color: (_rng.nextBool())
                ? const Color(0xFF38BDF8)
                : const Color(0xFFFFD700),
            radius: 1.5 + _rng.nextDouble() * 1.5,
          ),
        );
      }
    } else {
      // Same-planet aeroplane forward progress
      _flightProgress += step;

      // Update atmospheric clouds
      for (final cloud in _clouds) {
        cloud.y += cloud.speed * _currentSpeedMultiplier * dt;
        if (cloud.y > 1100) {
          cloud.y = -1100;
          cloud.x = (_rng.nextDouble() - 0.5) * 1200;
        }
      }

      // Continuous jet contrails from twin wing engines
      for (final side in [-18.0, 18.0]) {
        _thrustParticles.add(
          PlasmaThrustParticle(
            x: side + (_rng.nextDouble() - 0.5) * 3.0,
            y: 22.0,
            vx: (_rng.nextDouble() - 0.5) * 10.0,
            vy: 65.0 + _rng.nextDouble() * 60.0,
            maxLife: 0.55 + _rng.nextDouble() * 0.35,
            color: Colors.white.withValues(alpha: 0.85),
            radius: 2.2 + _rng.nextDouble() * 2.0,
          ),
        );
      }
    }

    // Update particle life
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

    // Apply Dynamic Viewport Zoom Transformation
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(zoomLevel);
    canvas.translate(-cx, -cy);

    if (manifest.isSamePlanet) {
      _renderIntraPlanetaryAeroplaneFlight(canvas, w, h, cx, cy);
    } else {
      _renderInterplanetaryRocketFlight(canvas, w, h, cx, cy);
    }

    canvas.restore();
  }

  // =========================================================================
  // ✈️ MODE 1: INTRA-PLANETARY AEROPLANE ISLAND-TO-ISLAND FLIGHT
  // =========================================================================

  void _renderIntraPlanetaryAeroplaneFlight(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double cy,
  ) {
    // 1. Planetary Atmospheric Sky & Ocean Backdrop
    _drawAtmosphericSkyAndOcean(canvas, w, h);

    // 2. Passing Archipelago Islands Below
    _drawPassingArchipelagoMap(canvas, w, h, cx);

    // 3. Drifting Lower Atmospheric Clouds
    _drawDriftingClouds(canvas, cx, cy, isUpper: false);

    // 4. Approaching Destination Island at the Top (appears past 50% progress)
    if (_flightProgress > 0.48) {
      _drawApproachingDestinationIsland(canvas, w, h, cx);
    }

    // 5. Jet Aeroplane Cruiser
    canvas.save();
    // Gentle navigation banking angle (-8° to +8°)
    final bankAngle = math.sin(_gameTime * 1.8) * 0.12;
    final planeY = cy + 40.0;
    canvas.translate(cx, planeY);
    canvas.rotate(bankAngle);

    // Render Contrail / Jet Exhaust Particles
    for (final p in _thrustParticles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(p.x, p.y),
        p.radius * (0.8 + (1.0 - alpha) * 1.6),
        Paint()..color = p.color.withValues(alpha: alpha * 0.75),
      );
    }

    // Draw Selected Island Vehicle (Speedboat / Cruise Ship / Aeroplane)
    if (vehicle?.id == 'speedboat') {
      _drawSpeedboat(canvas, isBoosting: _boostTimer > 0 || _isHoldingThrust);
    } else if (vehicle?.id == 'cruise_ship') {
      _drawCruiseShip(canvas, isBoosting: _boostTimer > 0 || _isHoldingThrust);
    } else {
      _drawAeroplane(canvas, isBoosting: _boostTimer > 0 || _isHoldingThrust);
    }
    canvas.restore();

    // 6. Drifting Upper Atmospheric Clouds (Above the airplane)
    _drawDriftingClouds(canvas, cx, cy, isUpper: true);
  }

  /// 🌅 Sky gradient and ocean water matching origin planet climate
  void _drawAtmosphericSkyAndOcean(Canvas canvas, double w, double h) {
    final code = manifest.originCode.toUpperCase();
    final List<Color> skyGradient;
    final Color oceanDeep;

    switch (code) {
      case 'MAR':
        skyGradient = const [
          Color(0xFFFED7AA), // Peach Horizon
          Color(0xFFF97316), // Amber
          Color(0xFFE11D48), // Coral Pink
          Color(0xFF9F1239), // Rose Dusk
        ];
        oceanDeep = const Color(0xFF7F1D1D); // Red terra sea
        break;
      case 'JUP':
        skyGradient = const [
          Color(0xFFFDE68A), // Auroral Gold
          Color(0xFF38BDF8), // Cyan Ribbon
          Color(0xFF1D4ED8), // Cobalt
          Color(0xFF1E1B4B), // Indigo
        ];
        oceanDeep = const Color(0xFF0F172A);
        break;
      case 'SAT':
        skyGradient = const [
          Color(0xFFFEF08A), // Radiant Ring Gold
          Color(0xFFF59E0B), // Amber
          Color(0xFFDB2777), // Twilight Pink
          Color(0xFF4A044E), // Deep Plum
        ];
        oceanDeep = const Color(0xFF3B0764);
        break;
      case 'EUR':
        skyGradient = const [
          Color(0xFFE0F2FE), // Glacial White
          Color(0xFF38BDF8), // Shimmering Ice Cyan
          Color(0xFF0284C7), // Deep Azure
          Color(0xFF1E1B4B), // Indigo
        ];
        oceanDeep = const Color(0xFF0C4A6E);
        break;
      case 'TTN':
        skyGradient = const [
          Color(0xFFFDE68A), // Golden Methane Dawn
          Color(0xFF0D9488), // Methane Teal
          Color(0xFF065F46), // Emerald Twilight
          Color(0xFF042F2E), // Petrol
        ];
        oceanDeep = const Color(0xFF042F2E);
        break;
      default: // Earth Prime
        skyGradient = const [
          Color(0xFFE0F2FE), // Horizon White Mist
          Color(0xFF7DD3FC), // Sunlit Cyan
          Color(0xFF0284C7), // Deep Azure
          Color(0xFF0369A1), // Royal Sky Blue
        ];
        oceanDeep = const Color(0xFF0284C7);
    }

    // Sky base
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: skyGradient,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Ocean water layer beneath the flight path (translucent azure depths)
    final oceanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          oceanDeep.withValues(alpha: 0.40),
          oceanDeep.withValues(alpha: 0.85),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), oceanPaint);

    // Subtle wave ripples drifting down
    final waveYOffset = (_gameTime * 45.0) % 80.0;
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (double y = -80.0 + waveYOffset; y < h + 80.0; y += 75.0) {
      final wavePath = Path();
      wavePath.moveTo(0, y);
      for (double x = 0; x < w; x += 60) {
        wavePath.quadraticBezierTo(x + 30, y + 6, x + 60, y);
      }
      canvas.drawPath(wavePath, wavePaint);
    }
  }

  /// 🏝️ Archipelago islands passing underneath the plane
  void _drawPassingArchipelagoMap(
      Canvas canvas, double w, double h, double cx) {
    for (final island in _passingIslands) {
      // Island scrolls downwards as flight progresses
      final islandProgress = (_flightProgress - island.appearProgress) / 0.40;
      if (islandProgress < -0.2 || islandProgress > 1.2) continue;

      final islandX = cx + (island.relX * (w * 0.45));
      final islandY = -120.0 + (islandProgress * (h + 240.0));
      final r = island.radius;

      // Island Sandy Shore / Shallow Lagoon Ring
      final shorePaint = Paint()
        ..color = island.sandColor.withValues(alpha: 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(islandX, islandY), width: r * 2.3, height: r * 1.8),
        shorePaint,
      );

      // Inner Lush Landform
      final landPaint = Paint()..color = island.vegetationColor;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(islandX, islandY), width: r * 1.8, height: r * 1.3),
        landPaint,
      );

      // Coastal Wave Foam Ring
      final foamPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(islandX, islandY), width: r * 2.5, height: r * 2.0),
        foamPaint,
      );
    }
  }

  /// 🏝️ Approaching Destination Island at Top
  /// "ഒരു ചെറുതായിട്ട് മേലെ ഇങ്ങനെ പകുതിയായിട്ട് ഒരു ചെറിയ ദ്വീപ് പോലെ കാണിക്കുക"
  void _drawApproachingDestinationIsland(
      Canvas canvas, double w, double h, double cx) {
    final destProgress = ((_flightProgress - 0.48) / 0.52).clamp(0.0, 1.0);

    // Island emerges from top horizon
    final islandWidth = w * (0.55 + destProgress * 0.45);
    final islandHeight = 110.0 + (destProgress * 130.0);
    final islandCenterY = -40.0 + (destProgress * 80.0);

    canvas.save();
    canvas.translate(cx, islandCenterY);

    // 1. Coastal Turquoise Atoll Lagoon Glow
    final lagoonGlow = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.45 * destProgress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset.zero,
          width: islandWidth * 1.25,
          height: islandHeight * 1.25),
      lagoonGlow,
    );

    // 2. Golden Sand Shoreline
    final sandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFEF08A), Color(0xFFFDE68A), Color(0xFFF59E0B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(
          center: Offset.zero, width: islandWidth, height: islandHeight));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset.zero, width: islandWidth, height: islandHeight),
      sandPaint,
    );

    // 3. Lush Green Island Plateau
    final greenPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF22C55E), Color(0xFF16A34A), Color(0xFF15803D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(
          center: Offset.zero,
          width: islandWidth * 0.82,
          height: islandHeight * 0.78));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset.zero,
          width: islandWidth * 0.82,
          height: islandHeight * 0.78),
      greenPaint,
    );

    // 4. Island Landing Strip / Runway
    final runwayPaint = Paint()..color = const Color(0xFF1E293B);
    final runwayRect = Rect.fromCenter(
        center: Offset.zero, width: islandWidth * 0.38, height: 20);
    canvas.drawRRect(
        RRect.fromRectAndRadius(runwayRect, const Radius.circular(4)),
        runwayPaint);

    // Runway Centerline & Lights
    final linePaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(-islandWidth * 0.16, 0),
      Offset(islandWidth * 0.16, 0),
      linePaint,
    );

    // Approach Beacons
    final beaconPaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(Offset(-islandWidth * 0.18, 0), 3, beaconPaint);
    canvas.drawCircle(Offset(islandWidth * 0.18, 0), 3, beaconPaint);

    // 5. Destination Label Banner
    _drawText(
      canvas,
      '🏝️ ${manifest.destinationName.toUpperCase()} ISLAND',
      0,
      (islandHeight * 0.38),
      color: Colors.white,
    );

    canvas.restore();
  }

  /// ✈️ Sleek Jet Cruiser Aeroplane
  void _drawAeroplane(Canvas canvas, {bool isBoosting = false}) {
    // 1. Twin Engine Afterburner Glow when Boosting
    if (isBoosting) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFF9100).withValues(alpha: 0.65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(const Offset(-18, 20), 12, glowPaint);
      canvas.drawCircle(const Offset(18, 20), 12, glowPaint);
    }

    // 2. Swept Wings
    final wingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF8FAFC), Color(0xFFCBD5E1), Color(0xFF94A3B8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-55, -10, 110, 36));

    final wingsPath = Path()
      ..moveTo(0, -12)
      ..lineTo(54, 16)
      ..lineTo(48, 24)
      ..lineTo(14, 16)
      ..lineTo(0, 20)
      ..lineTo(-14, 16)
      ..lineTo(-48, 24)
      ..lineTo(-54, 16)
      ..close();
    canvas.drawPath(wingsPath, wingPaint);

    // Wing Leading Edge Accents
    final cyanTrim = Paint()..color = const Color(0xFF0284C7);
    canvas.drawLine(const Offset(0, -10), const Offset(52, 16),
        cyanTrim..strokeWidth = 1.8);
    canvas.drawLine(const Offset(0, -10), const Offset(-52, 16),
        cyanTrim..strokeWidth = 1.8);

    // Wingtip Strobe Lights (Blinking port red, starboard green)
    final blink = (math.sin(_gameTime * 8.0) > 0.0);
    if (blink) {
      final redStrobe = Paint()..color = const Color(0xFFEF4444);
      final greenStrobe = Paint()..color = const Color(0xFF22C55E);
      canvas.drawCircle(const Offset(-54, 16), 2.5, redStrobe);
      canvas.drawCircle(const Offset(54, 16), 2.5, greenStrobe);
    }

    // 3. Jet Engine Nacelles under wings
    final nacellePaint = Paint()..color = const Color(0xFF475569);
    for (final nx in [-18.0, 18.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(nx, 10), width: 7.5, height: 18),
          const Radius.circular(3.5),
        ),
        nacellePaint,
      );
      // Turbine intake rim
      canvas.drawOval(
        Rect.fromCenter(center: Offset(nx, 1), width: 7.5, height: 3.5),
        Paint()..color = const Color(0xFF0284C7),
      );
    }

    // 4. Horizontal Stabilizers & Tail Fin
    final tailPath = Path()
      ..moveTo(0, 18)
      ..lineTo(22, 34)
      ..lineTo(18, 38)
      ..lineTo(0, 32)
      ..lineTo(-18, 38)
      ..lineTo(-22, 34)
      ..close();
    canvas.drawPath(tailPath, wingPaint);

    // Vertical Fin Shadow
    final finPath = Path()
      ..moveTo(0, 12)
      ..lineTo(3.5, 34)
      ..lineTo(-3.5, 34)
      ..close();
    canvas.drawPath(finPath, Paint()..color = const Color(0xFF64748B));

    // 5. Main Fuselage
    final fuselagePath = Path()
      ..moveTo(0, -36) // Sleek nose
      ..cubicTo(9, -20, 8, 12, 6, 32)
      ..lineTo(-6, 32)
      ..cubicTo(-8, 12, -9, -20, 0, -36)
      ..close();

    final fuselagePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9), Color(0xFFCBD5E1)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(const Rect.fromLTWH(-9, -36, 18, 68));
    canvas.drawPath(fuselagePath, fuselagePaint);

    // 6. Cockpit Windshield (Vibrant Cyan Glass)
    final visorPaint = Paint()..color = const Color(0xFF0284C7);
    final cockpitPath = Path()
      ..moveTo(0, -26)
      ..lineTo(5, -17)
      ..lineTo(3.5, -14)
      ..lineTo(-3.5, -14)
      ..lineTo(-5, -17)
      ..close();
    canvas.drawPath(cockpitPath, visorPaint);

    // Glass glare reflection
    canvas.drawCircle(const Offset(-1.5, -20), 1.6,
        Paint()..color = Colors.white.withValues(alpha: 0.9));

    // 7. Passenger Windows Row
    final windowPaint = Paint()..color = const Color(0xFF38BDF8);
    for (int i = 0; i < 4; i++) {
      final wy = -7.0 + (i * 7.0);
      canvas.drawCircle(Offset(-4.5, wy), 1.0, windowPaint);
      canvas.drawCircle(Offset(4.5, wy), 1.0, windowPaint);
    }
  }

  /// 🚤 Hydrofoil Speedboat with dynamic foaming water wake
  void _drawSpeedboat(Canvas canvas, {bool isBoosting = false}) {
    // 1. Water spray & foaming V-wake
    final wakePaint = Paint()
      ..color = Colors.white.withValues(alpha: isBoosting ? 0.85 : 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isBoosting ? 3.5 : 2.5;

    final wake = Path()
      ..moveTo(-6, 22)
      ..lineTo(-32, 60)
      ..moveTo(6, 22)
      ..lineTo(32, 60);
    canvas.drawPath(wake, wakePaint);

    // Frothing water splash bubbles
    final bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (int i = 0; i < (isBoosting ? 6 : 4); i++) {
      final yOff = 26.0 + (i * 8.0);
      canvas.drawCircle(
          Offset(-8.0 - (i * 4.5), yOff), 2.2 + (i * 0.4), bubblePaint);
      canvas.drawCircle(
          Offset(8.0 + (i * 4.5), yOff), 2.2 + (i * 0.4), bubblePaint);
    }

    // 2. Speedboat Hull (Wedge Shape)
    final hullPath = Path()
      ..moveTo(0, -32) // Pointed bow
      ..lineTo(12, 10)
      ..lineTo(11, 24)
      ..lineTo(-11, 24)
      ..lineTo(-12, 10)
      ..close();

    final hullPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFF0284C7), Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-12, -32, 24, 56));
    canvas.drawPath(hullPath, hullPaint);

    // Deck Teak Floor
    final deckPaint = Paint()..color = const Color(0xFFFED7AA);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-7, -10, 14, 26), const Radius.circular(3)),
      deckPaint,
    );

    // Windshield
    final glassPaint = Paint()..color = const Color(0xFF38BDF8);
    final glassPath = Path()
      ..moveTo(0, -18)
      ..lineTo(8, -10)
      ..lineTo(-8, -10)
      ..close();
    canvas.drawPath(glassPath, glassPaint);

    // Twin Outboard Motors at Stern
    final motorPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(const Rect.fromLTWH(-8, 22, 5, 8), motorPaint);
    canvas.drawRect(const Rect.fromLTWH(3, 22, 5, 8), motorPaint);
  }

  /// 🚢 Oceanic Cruise Ship with multi-deck windows and rolling ocean waves
  void _drawCruiseShip(Canvas canvas, {bool isBoosting = false}) {
    // 1. Broad rolling ocean wave wakes
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 3; i++) {
      final yOff = 34.0 + (i * 12.0);
      final r = 24.0 + (i * 14.0);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(0, yOff), width: r * 2.2, height: r * 0.9),
        wavePaint,
      );
    }

    // 2. Main Ship Hull (Elongated ocean liner profile)
    final hullPath = Path()
      ..moveTo(0, -42) // Bulbous bow
      ..cubicTo(14, -28, 15, 12, 13, 34)
      ..lineTo(-13, 34)
      ..cubicTo(-15, 12, -14, -28, 0, -42)
      ..close();

    final hullPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF090D16)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(const Rect.fromLTWH(-15, -42, 30, 76));
    canvas.drawPath(hullPath, hullPaint);

    // Red Waterline Stripe
    final redStripe = Paint()..color = const Color(0xFFEF4444);
    canvas.drawRect(const Rect.fromLTWH(-12.5, 30, 25, 3.5), redStripe);

    // 3. Superstructure Decks (Crisp White)
    final deckPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-9, -24, 18, 50), const Radius.circular(4)),
      deckPaint,
    );

    // Cabin Windows
    final windowPaint = Paint()..color = const Color(0xFFFFD700);
    for (int i = 0; i < 5; i++) {
      final wy = -18.0 + (i * 7.5);
      canvas.drawCircle(Offset(-6, wy), 1.2, windowPaint);
      canvas.drawCircle(Offset(6, wy), 1.2, windowPaint);
    }

    // 4. Twin Iconic Red/Black Funnels (Smokestacks)
    final funnelPaint = Paint()..color = const Color(0xFFDC2626);
    final funnelTop = Paint()..color = const Color(0xFF0F172A);

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-4, -6, 8, 8), const Radius.circular(2)),
        funnelPaint);
    canvas.drawRect(const Rect.fromLTWH(-4, -6, 8, 2.5), funnelTop);

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-4, 8, 8, 8), const Radius.circular(2)),
        funnelPaint);
    canvas.drawRect(const Rect.fromLTWH(-4, 8, 8, 2.5), funnelTop);
  }

  /// ☁️ Drifting clouds with soft billows
  void _drawDriftingClouds(Canvas canvas, double cx, double cy,
      {required bool isUpper}) {
    canvas.save();
    canvas.translate(cx, cy);

    final cloudPaint = Paint();
    final filterClouds = isUpper ? _clouds.sublist(9) : _clouds.sublist(0, 9);

    for (final cloud in filterClouds) {
      cloudPaint.color = Colors.white
          .withValues(alpha: cloud.opacity * (isUpper ? 0.35 : 0.65));
      final rect = Rect.fromCenter(
        center: Offset(cloud.x, cloud.y),
        width: cloud.width,
        height: cloud.height,
      );
      canvas.drawOval(rect, cloudPaint);
    }

    canvas.restore();
  }

  // =========================================================================
  // 🚀 MODE 2: INTERPLANETARY ROCKET ORBIT & INFINITE COSMIC VOID FLIGHT
  // =========================================================================

  void _renderInterplanetaryRocketFlight(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double cy,
  ) {
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

    // 2. Parallax Stars (Infinite void stream)
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

    // 3. Render Origin Atmosphere Ceiling & Planetary Launch Surface
    // "ആ ലിമിറ്റേഷൻ കഴിഞ്ഞാൽ ഈ സ്ഥലം ഇങ്ങനെ ഗ്രേഡിയന്റ് ബ്ലാക്ക് ആയാൽ മതി"
    if (_flightProgress < 0.44) {
      final originAlpha = (1.0 - (_flightProgress / 0.44)).clamp(0.0, 1.0);
      _drawOriginAtmosphereAndSurface(canvas, w, h, originAlpha);
    }

    // 4. Render Intermediate Planet & Gravitational Slingshot Loop
    final activeCode = _activeSlingshotCode;
    if (activeCode != null) {
      final double planetCenterY = h * 0.45;
      final double planetRadius = 55.0;

      final orbitRingPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(Offset(cx, planetCenterY), 95.0, orbitRingPaint);

      _drawPlanetSphere(canvas, cx, planetCenterY, planetRadius, activeCode,
          alpha: 1.0);

      final name =
          PoketCosmosDistanceService.instance.getCleanPlanetName(activeCode);
      _drawText(
          canvas, '$name Gravity Assist', cx, planetCenterY + planetRadius + 14,
          color: const Color(0xFFFFD700));
    }

    // 5. Render Destination Celestial Sphere (Approaching from top: 0.58 to 1.0)
    if (_flightProgress > 0.58) {
      final destProgress = ((_flightProgress - 0.58) / 0.42).clamp(0.0, 1.0);
      final destRadius = 35.0 + (destProgress * 85.0);
      final destY = -30.0 + (destProgress * (h * 0.38));
      _drawPlanetSphere(canvas, cx, destY, destRadius, manifest.destinationCode,
          alpha: destProgress);
    }

    // 6. Rocket Ship (Positioned in center, tilts gracefully into orbital ascent curve)
    // "റോക്കറ്റ് ഇങ്ങനെ പോകുന്നു പിന്നെ വളയും"
    canvas.save();
    double rocketX = cx;
    double rocketY = cy + 40.0;
    double rocketAngle = 0.0;

    if (_isSlingshotLooping) {
      final orbitR = 95.0;
      rocketX = cx + math.cos(_slingshotAngle) * orbitR;
      rocketY = (h * 0.45) + math.sin(_slingshotAngle) * orbitR;
      rocketAngle = _slingshotAngle + (math.pi / 2);
    } else {
      // Natural Orbital Ascent Curve: lifts off vertically, curves gracefully into orbit (15°-24° tilt)
      if (_flightProgress >= 0.06 && _flightProgress <= 0.42) {
        final curveFraction = ((_flightProgress - 0.06) / 0.36);
        // Smooth sine arc tilt
        rocketAngle = math.sin(curveFraction * math.pi) * 0.36;
        rocketX += math.sin(curveFraction * math.pi) * 28.0;
      }
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

    // Draw Selected Interplanetary Spaceship (Starship / Hyper Warp Shuttle / Ion Cruiser)
    if (vehicle?.id == 'warp_shuttle') {
      _drawWarpShuttle(canvas, isBoosting: _boostTimer > 0 || _isHoldingThrust);
    } else if (vehicle?.id == 'ion_cruiser') {
      _drawIonCruiser(canvas, isBoosting: _boostTimer > 0 || _isHoldingThrust);
    } else {
      _drawRocketShip(canvas, isBoosting: _boostTimer > 0 || _isHoldingThrust);
    }
    canvas.restore();
  }

  /// 🚀 Sleek Futuristic Spacecraft
  void _drawRocketShip(Canvas canvas, {bool isBoosting = false}) {
    // 1. Engine Core Glow
    final glowPaint = Paint()
      ..color = (isBoosting ? const Color(0xFFFF9100) : const Color(0xFF00E5FF))
          .withValues(alpha: 0.5)
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
      ..moveTo(0, -38)
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
    canvas.drawOval(const Rect.fromLTWH(-5.5, -16, 11, 16), visorPaint);
    canvas.drawOval(
      const Rect.fromLTWH(-3.5, -14, 5, 8),
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );

    // 5. Golden Solar Accent Stripes
    final goldStripe = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRect(const Rect.fromLTWH(-7, 2, 14, 2.5), goldStripe);
  }

  /// ⚡ Hyper Warp Shuttle (Aggressive forward-swept golden interceptor)
  void _drawWarpShuttle(Canvas canvas, {bool isBoosting = false}) {
    // 1. Warp Core Glow
    final glowPaint = Paint()
      ..color =
          const Color(0xFFFFD700).withValues(alpha: isBoosting ? 0.7 : 0.45)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isBoosting ? 16 : 10);
    canvas.drawCircle(const Offset(0, 24), isBoosting ? 22 : 14, glowPaint);

    // 2. Swept Delta Wings (Golden yellow with amber edges)
    final wingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFEF08A), Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-32, -16, 64, 48));

    final wings = Path()
      ..moveTo(0, -32)
      ..lineTo(30, 18)
      ..lineTo(18, 26)
      ..lineTo(0, 16)
      ..lineTo(-18, 26)
      ..lineTo(-30, 18)
      ..close();
    canvas.drawPath(wings, wingPaint);

    // 3. Main Hull Fuselage
    final hullPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFFFEF08A), Color(0xFFB45309)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(const Rect.fromLTWH(-9, -36, 18, 64));

    final hull = Path()
      ..moveTo(0, -40)
      ..lineTo(8, 0)
      ..lineTo(7, 26)
      ..lineTo(-7, 26)
      ..lineTo(-8, 0)
      ..close();
    canvas.drawPath(hull, hullPaint);

    // Cockpit Visor (Orange/Amber Shield Glass)
    final visorPaint = Paint()..color = const Color(0xFFFF9100);
    canvas.drawOval(const Rect.fromLTWH(-4.5, -20, 9, 14), visorPaint);

    // Triple Afterburners
    final thrusterPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(const Rect.fromLTWH(-6, 26, 3, 4), thrusterPaint);
    canvas.drawRect(const Rect.fromLTWH(-1.5, 26, 3, 5), thrusterPaint);
    canvas.drawRect(const Rect.fromLTWH(3, 26, 3, 4), thrusterPaint);
  }

  /// 🛰️ Ion Deep-Space Cruiser (Heavy modular vessel with pulsating ion ring engines)
  void _drawIonCruiser(Canvas canvas, {bool isBoosting = false}) {
    // 1. Pulsating Ion Thruster Rings
    final ionRingPaint = Paint()
      ..color =
          const Color(0xFFA855F7).withValues(alpha: isBoosting ? 0.75 : 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(const Offset(-16, 24), 8, ionRingPaint);
    canvas.drawCircle(const Offset(16, 24), 8, ionRingPaint);

    // 2. Solar Collector / Outrigger Wings
    final wingPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRect(const Rect.fromLTWH(-28, 4, 14, 18), wingPaint);
    canvas.drawRect(const Rect.fromLTWH(14, 4, 14, 18), wingPaint);

    // Solar Panel Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(-28, 13), const Offset(-14, 13), gridPaint);
    canvas.drawLine(const Offset(14, 13), const Offset(28, 13), gridPaint);

    // 3. Heavy Modular Fuselage
    final hullPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF475569)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(const Rect.fromLTWH(-12, -34, 24, 60));

    final hull = Path()
      ..moveTo(-8, -34)
      ..lineTo(8, -34)
      ..lineTo(11, -10)
      ..lineTo(10, 24)
      ..lineTo(-10, 24)
      ..lineTo(-11, -10)
      ..close();
    canvas.drawPath(hull, hullPaint);

    // Central Command Dome
    final domePaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(const Offset(0, -14), 5, domePaint);

    // Front Radar Dish Array
    final dishPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawArc(const Rect.fromLTWH(-6, -38, 12, 10), math.pi, math.pi,
        false, dishPaint);
  }

  /// 🪐 3D Planet Sphere Renderer
  void _drawPlanetSphere(
      Canvas canvas, double x, double y, double radius, String planetCode,
      {double alpha = 1.0}) {
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

    canvas.drawCircle(
      Offset.zero,
      radius * 1.18,
      Paint()
        ..color = atmosphericGlow.withValues(alpha: 0.28 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.9,
        colors: [
          primary.withValues(alpha: alpha),
          secondary.withValues(alpha: alpha)
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
    canvas.drawCircle(Offset.zero, radius, spherePaint);

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

  /// 🌍 Origin Planetary Atmosphere Ceiling & Ground Base
  /// "ബോട്ടം ഫില്ലഡ് ആയി കിടക്കണം... ആ ലിമിറ്റേഷൻ കഴിഞ്ഞാൽ ഈ സ്ഥലം ഇങ്ങനെ ഗ്രേഡിയന്റ് ബ്ലാക്ക് ആയാൽ മതി"
  void _drawOriginAtmosphereAndSurface(
      Canvas canvas, double w, double h, double alpha) {
    final cx = w / 2;
    final code = manifest.originCode.toUpperCase();

    final List<Color> skyColors;
    final Color landColor;

    switch (code) {
      case 'MAR':
        skyColors = const [
          Color(0xFFFED7AA),
          Color(0xFFF97316),
          Color(0xFFE11D48),
          Color(0xFF9F1239),
          Color(0xFF4C0519),
        ];
        landColor = const Color(0xFF991B1B);
        break;
      case 'JUP':
        skyColors = const [
          Color(0xFFF59E0B),
          Color(0xFF0284C7),
          Color(0xFF1D4ED8),
          Color(0xFF1E1B4B),
          Color(0xFF020617),
        ];
        landColor = const Color(0xFF065F46);
        break;
      case 'SAT':
        skyColors = const [
          Color(0xFFFEF08A),
          Color(0xFFD97706),
          Color(0xFFDB2777),
          Color(0xFF9D174D),
          Color(0xFF3B0764),
        ];
        landColor = const Color(0xFF92400E);
        break;
      case 'LUN':
        skyColors = const [
          Color(0xFF1E293B),
          Color(0xFF0F172A),
          Color(0xFF020617),
          Color(0xFF000000),
        ];
        landColor = const Color(0xFF334155);
        break;
      case 'EUR':
        skyColors = const [
          Color(0xFFE0F2FE),
          Color(0xFF0284C7),
          Color(0xFFC026D3),
          Color(0xFF701A75),
          Color(0xFF1E1B4B),
        ];
        landColor = const Color(0xFF0284C7);
        break;
      case 'VEN':
        skyColors = const [
          Color(0xFFFEF08A),
          Color(0xFFF59E0B),
          Color(0xFFC2410C),
          Color(0xFF831843),
          Color(0xFF4A044E),
        ];
        landColor = const Color(0xFFB45309);
        break;
      case 'TTN':
        skyColors = const [
          Color(0xFFFBBF24),
          Color(0xFFB45309),
          Color(0xFF0F766E),
          Color(0xFF065F46),
          Color(0xFF042F2E),
        ];
        landColor = const Color(0xFF047857);
        break;
      case 'NEP':
        skyColors = const [
          Color(0xFFE0E7FF),
          Color(0xFF0284C7),
          Color(0xFF4338CA),
          Color(0xFF1E1B4B),
          Color(0xFF020617),
        ];
        landColor = const Color(0xFF1D4ED8);
        break;
      case 'PLT':
        skyColors = const [
          Color(0xFFF5D0FE),
          Color(0xFFA855F7),
          Color(0xFF6B21A8),
          Color(0xFF2E1065),
          Color(0xFF030712),
        ];
        landColor = const Color(0xFF581C87);
        break;
      default: // Earth Prime
        skyColors = const [
          Color(0xFFBAE6FD),
          Color(0xFF38BDF8),
          Color(0xFF0284C7),
          Color(0xFF0C4A6E),
          Color(0xFF020617),
        ];
        landColor = const Color(0xFF16A34A);
    }

    // Atmosphere gradient with smooth transition to gradient black void
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          for (final c in skyColors) c.withValues(alpha: alpha * 0.95),
          const Color(0xFF070B14).withValues(alpha: alpha),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Ground surface that recedes downward as rocket ascends
    final surfaceY = h * 0.72 + (_flightProgress * h * 1.85);
    final surfacePath = Path()
      ..moveTo(-50, surfaceY)
      ..quadraticBezierTo(cx, surfaceY - 26, w + 50, surfaceY)
      ..lineTo(w + 50, h + 120)
      ..lineTo(-50, h + 120)
      ..close();

    final landPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          landColor.withValues(alpha: 0.95 * alpha),
          const Color(0xFF0B132B).withValues(alpha: 0.95 * alpha),
        ],
      ).createShader(Rect.fromLTWH(0, surfaceY - 26, w, h - surfaceY + 146));
    canvas.drawPath(surfacePath, landPaint);

    // Citizen Launchpad & Home Base
    final houseX = cx - 65;
    final houseY = surfaceY - 14;

    // Launch Gantry Tower
    final gantryPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4 * alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(
        Offset(cx + 40, houseY), Offset(cx + 40, houseY - 45), gantryPaint);
    canvas.drawLine(Offset(cx + 34, houseY - 30), Offset(cx + 40, houseY - 20),
        gantryPaint);

    // Launchpad Lights
    final lightPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.85 * alpha);
    canvas.drawCircle(Offset(cx - 30, houseY + 6), 3, lightPaint);
    canvas.drawCircle(Offset(cx + 30, houseY + 6), 3, lightPaint);

    // Citizen House Base
    final housePaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.95 * alpha);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(houseX, houseY), width: 34, height: 22),
        const Radius.circular(5),
      ),
      housePaint,
    );
    // House Roof
    final roofPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.95 * alpha);
    final roofPath = Path()
      ..moveTo(houseX - 20, houseY - 11)
      ..lineTo(houseX, houseY - 24)
      ..lineTo(houseX + 20, houseY - 11)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Origin Location Label Pill
    _drawText(
      canvas,
      '🏡 ${manifest.originName.toUpperCase()} HOME BASE',
      cx,
      surfaceY + 18,
      color: Colors.white.withValues(alpha: 0.85 * alpha),
    );
  }

  void _drawText(Canvas canvas, String text, double x, double y,
      {Color color = Colors.white}) {
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
