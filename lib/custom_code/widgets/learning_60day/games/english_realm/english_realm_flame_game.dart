import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'english_realm_manifest.dart';
import 'english_realm_models.dart';
import 'english_realm_progress_service.dart';

/// 🌍 Data structure for an in-world interactive game station
class WorldGameStation {
  final int day;
  final int gameIndex;
  final String title;
  final String topic;
  final GameArchetype archetype;
  final double x;
  final double y;
  final Color color;
  final String icon;
  bool isCompleted = false;
  int stars = 0;

  WorldGameStation({
    required this.day,
    required this.gameIndex,
    required this.title,
    required this.topic,
    required this.archetype,
    required this.x,
    required this.y,
    required this.color,
    required this.icon,
  });

  Rect get touchRect => Rect.fromCenter(center: Offset(x, y), width: 140, height: 160);
}

/// 🌳 In-world environmental landmark node
class WorldLandmark {
  final int day;
  final String title;
  final String regionName;
  final double x;
  final double y;
  final Color color;
  final String emoji;

  const WorldLandmark({
    required this.day,
    required this.title,
    required this.regionName,
    required this.x,
    required this.y,
    required this.color,
    required this.emoji,
  });
}

/// 🎮 Flame 2D Open World Engine for English Realm
class EnglishRealmFlameGame extends FlameGame
    with KeyboardEvents, TapCallbacks {
  final int initialDay;
  final ValueChanged<WorldGameStation?> onProximityChanged;
  final ValueChanged<WorldGameStation> onStationSelected;

  EnglishRealmFlameGame({
    this.initialDay = 1,
    required this.onProximityChanged,
    required this.onStationSelected,
  });

  // World Geometry (36,000 px world across 9 distinct regions)
  static const double worldWidth = 36000.0;
  static const double worldHeight = 1600.0;
  static const double roadY = 900.0;

  // Player Physics & Animation
  double playerX = 400.0;
  double playerY = 900.0;
  double vx = 0.0;
  double vy = 0.0;
  double playerFacing = 1.0;
  bool isMoving = false;
  double walkCycle = 0.0;
  double zoomScale = 1.0;

  // Camera coordinates
  double cameraX = 400.0;
  double cameraY = 900.0;

  // Controls input vector (-1.0 to 1.0)
  double inputDx = 0.0;
  double inputDy = 0.0;

  // Proximity station detection
  WorldGameStation? activeStation;
  WorldGameStation? _lastDetectedStation;

  // World elements
  final List<WorldGameStation> stations = [];
  final List<WorldLandmark> landmarks = [];
  final List<Offset> riverPoints = [];

  // Particles
  final List<Map<String, dynamic>> _particles = [];
  double _gameTime = 0.0;

  @override
  Color backgroundColor() => const Color(0xFF0D1B2A);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _buildWorldEntities();
    await refreshProgress();
    teleportToDay(initialDay);
  }

  /// Refreshes completed stars & badges for all 180 stations
  Future<void> refreshProgress() async {
    for (final s in stations) {
      s.isCompleted = await EnglishRealmProgressService.isGameCompleted(s.day, s.gameIndex);
      s.stars = await EnglishRealmProgressService.getGameStars(s.day, s.gameIndex);
    }
  }

  /// Builds all 90 Day landmarks and 180 Game Stations along the connected realm road
  void _buildWorldEntities() {
    stations.clear();
    landmarks.clear();

    for (int day = 1; day <= 90; day++) {
      final region = EnglishRealmManifest.getRegionForDay(day);
      final games = EnglishRealmManifest.getGamesForDay(day);

      // Station position along the 36,000px realm route
      final dayX = 350.0 + ((day - 1) * 395.0);

      // Landmark plaza
      landmarks.add(
        WorldLandmark(
          day: day,
          title: games.isNotEmpty ? games[0].englishTopic : 'Day $day Lesson',
          regionName: region.name,
          x: dayX,
          y: roadY - 140,
          color: region.primaryColor,
          emoji: region.icon,
        ),
      );

      // Game 1 Portal (Plaza North)
      if (games.isNotEmpty) {
        stations.add(
          WorldGameStation(
            day: day,
            gameIndex: 1,
            title: games[0].title,
            topic: games[0].englishTopic,
            archetype: games[0].archetype,
            x: dayX - 85.0,
            y: roadY - 60.0,
            color: const Color(0xFF38BDF8),
            icon: games[0].icon,
          ),
        );
      }

      // Game 2 Portal (Plaza South)
      if (games.length > 1) {
        stations.add(
          WorldGameStation(
            day: day,
            gameIndex: 2,
            title: games[1].title,
            topic: games[1].englishTopic,
            archetype: games[1].archetype,
            x: dayX + 85.0,
            y: roadY + 60.0,
            color: const Color(0xFF10B981),
            icon: games[1].icon,
          ),
        );
      }
    }
  }

  /// Teleports player character smoothly to specified [day]
  void teleportToDay(int day) {
    final targetX = (350.0 + ((day - 1) * 395.0)).clamp(200.0, worldWidth - 400.0);
    playerX = targetX;
    playerY = roadY;
    cameraX = targetX;
    cameraY = roadY;
  }

  /// Sets locomotion inputs from on-screen virtual joystick or keyboard
  void setJoystickInput(double dx, double dy) {
    inputDx = dx.clamp(-1.0, 1.0);
    inputDy = dy.clamp(-1.0, 1.0);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    double kx = 0.0;
    double ky = 0.0;

    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      kx -= 1.0;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      kx += 1.0;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      ky -= 1.0;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      ky += 1.0;
    }

    inputDx = kx;
    inputDy = ky;

    if (keysPressed.contains(LogicalKeyboardKey.keyE) ||
        keysPressed.contains(LogicalKeyboardKey.space)) {
      if (activeStation != null) {
        onStationSelected(activeStation!);
      }
    }

    return KeyEventResult.handled;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _gameTime += dt;

    // Movement speed
    const double speed = 360.0;
    isMoving = inputDx.abs() > 0.05 || inputDy.abs() > 0.05;

    if (isMoving) {
      playerX += inputDx * speed * dt;
      playerY += inputDy * speed * dt;

      if (inputDx.abs() > 0.05) {
        playerFacing = inputDx > 0 ? 1.0 : -1.0;
      }

      walkCycle += dt * 10.0;

      // Spawn subtle dust particles
      if (math.Random().nextDouble() < 0.25) {
        _particles.add({
          'x': playerX - (playerFacing * 14.0),
          'y': playerY + 22.0,
          'life': 0.4,
          'maxLife': 0.4,
        });
      }
    } else {
      walkCycle = 0.0;
    }

    // World bounds clamp
    playerX = playerX.clamp(120.0, worldWidth - 120.0);
    playerY = playerY.clamp(420.0, worldHeight - 300.0);

    // Smooth camera follow
    cameraX += (playerX - cameraX) * 0.14;
    cameraY += (playerY - cameraY) * 0.14;

    // Update particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i]['life'] -= dt;
      if (_particles[i]['life'] <= 0) {
        _particles.removeAt(i);
      }
    }

    // Check proximity to stations
    _checkProximity();
  }

  void _checkProximity() {
    WorldGameStation? closest;
    double minDist = 110.0; // Interaction radius

    for (final s in stations) {
      final dx = s.x - playerX;
      final dy = s.y - playerY;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < minDist) {
        minDist = dist;
        closest = s;
      }
    }

    if (closest != activeStation) {
      activeStation = closest;
      if (closest != _lastDetectedStation) {
        _lastDetectedStation = closest;
        onProximityChanged(closest);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();

    // Camera transform
    final viewW = size.x;
    final viewH = size.y;
    canvas.translate(viewW / 2, viewH / 2);
    canvas.scale(zoomScale);
    canvas.translate(-cameraX, -cameraY);

    // 1. Render World Environment & Regions
    _renderEnvironment(canvas);

    // 2. Render Road & Pathways
    _renderRoadways(canvas);

    // 3. Render Landmarks & Day Plazas
    _renderLandmarks(canvas);

    // 4. Render Game Stations
    _renderGameStations(canvas);

    // 5. Render Dust Particles
    _renderParticles(canvas);

    // 6. Render Player Character
    _renderPlayer(canvas);

    canvas.restore();
  }

  // --------------------------------------------------------------------------
  // RENDER ENVIRONMENT
  // --------------------------------------------------------------------------
  void _renderEnvironment(Canvas canvas) {
    // Visible world window
    final halfW = (size.x / 2) / zoomScale + 400;
    final leftX = (cameraX - halfW).clamp(0.0, worldWidth);
    final rightX = (cameraX + halfW).clamp(0.0, worldWidth);

    for (final reg in EnglishRealmManifest.regions) {
      if (reg.worldEndX < leftX || reg.worldStartX > rightX) continue;

      final start = math.max(reg.worldStartX, leftX);
      final end = math.min(reg.worldEndX, rightX);

      // Terrain gradient for this region
      final rect = Rect.fromLTRB(start, 200, end, worldHeight);
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            reg.secondaryColor.withValues(alpha: 0.15),
            reg.primaryColor.withValues(alpha: 0.08),
            const Color(0xFF0F172A),
          ],
        ).createShader(rect);
      canvas.drawRect(rect, paint);

      // Region border demarcation line
      final borderPaint = Paint()
        ..color = reg.primaryColor.withValues(alpha: 0.3)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(reg.worldEndX, 250), Offset(reg.worldEndX, worldHeight), borderPaint);
    }
  }

  // --------------------------------------------------------------------------
  // RENDER ROADWAYS
  // --------------------------------------------------------------------------
  void _renderRoadways(Canvas canvas) {
    // Cobblestone Main Route
    final roadPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, roadY - 50, worldWidth, 100),
        const Radius.circular(8),
      ),
      roadPaint,
    );

    // Road dashed center line
    final dashPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.4)
      ..strokeWidth = 3.0;

    for (double x = 40; x < worldWidth; x += 60) {
      canvas.drawLine(Offset(x, roadY), Offset(x + 30, roadY), dashPaint);
    }
  }

  // --------------------------------------------------------------------------
  // RENDER LANDMARKS
  // --------------------------------------------------------------------------
  void _renderLandmarks(Canvas canvas) {
    for (final lm in landmarks) {
      if ((lm.x - cameraX).abs() > size.x + 200) continue;

      // Base Plaza Stone Circle
      final circlePaint = Paint()
        ..color = lm.color.withValues(alpha: 0.14)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(lm.x, roadY), 130, circlePaint);

      final rimPaint = Paint()
        ..color = lm.color.withValues(alpha: 0.35)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(Offset(lm.x, roadY), 130, rimPaint);

      // Landmark Monument Box
      final monumentRect = Rect.fromCenter(center: Offset(lm.x, lm.y), width: 150, height: 60);
      final monumentPaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(monumentRect, const Radius.circular(14)), monumentPaint);

      final monumentBorder = Paint()
        ..color = lm.color
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(RRect.fromRectAndRadius(monumentRect, const Radius.circular(14)), monumentBorder);

      // Day Number & Topic Text
      final textSpan = TextSpan(
        text: 'DAY ${lm.day} • ${lm.emoji}\n${lm.title}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          height: 1.25,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 140);
      textPainter.paint(
        canvas,
        Offset(lm.x - (textPainter.width / 2), lm.y - (textPainter.height / 2)),
      );
    }
  }

  // --------------------------------------------------------------------------
  // RENDER GAME STATIONS
  // --------------------------------------------------------------------------
  void _renderGameStations(Canvas canvas) {
    for (final s in stations) {
      if ((s.x - cameraX).abs() > size.x + 200) continue;

      final isCurrentTarget = s == activeStation;

      // Station Platform Pedestal
      final basePaint = Paint()
        ..color = s.isCompleted
            ? const Color(0xFF10B981).withValues(alpha: 0.3)
            : s.color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(s.x, s.y), 36, basePaint);

      // Glowing selection rim if nearby
      if (isCurrentTarget) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFFD700)
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(Offset(s.x, s.y), 42 + math.sin(_gameTime * 6) * 3, glowPaint);
      } else {
        final borderPaint = Paint()
          ..color = s.color.withValues(alpha: 0.6)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(Offset(s.x, s.y), 36, borderPaint);
      }

      // Station Icon Box
      final boxPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(s.x, s.y), 24, boxPaint);

      // Station Badge Icon
      final iconSpan = TextSpan(
        text: s.icon,
        style: const TextStyle(fontSize: 20),
      );
      final iconPainter = TextPainter(
        text: iconSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      iconPainter.paint(
        canvas,
        Offset(s.x - (iconPainter.width / 2), s.y - (iconPainter.height / 2)),
      );

      // Stars indicator above station
      if (s.isCompleted && s.stars > 0) {
        final starSpan = TextSpan(
          text: '⭐' * s.stars,
          style: const TextStyle(fontSize: 10),
        );
        final starPainter = TextPainter(
          text: starSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        starPainter.paint(
          canvas,
          Offset(s.x - (starPainter.width / 2), s.y - 42),
        );
      }

      // Game Title Plaque
      final titleSpan = TextSpan(
        text: 'G${s.gameIndex}: ${s.title}',
        style: TextStyle(
          color: s.isCompleted ? const Color(0xFF34D399) : Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
        ),
      );
      final titlePainter = TextPainter(
        text: titleSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      titlePainter.paint(
        canvas,
        Offset(s.x - (titlePainter.width / 2), s.y + 40),
      );
    }
  }

  // --------------------------------------------------------------------------
  // RENDER DUST PARTICLES
  // --------------------------------------------------------------------------
  void _renderParticles(Canvas canvas) {
    for (final p in _particles) {
      final alpha = (p['life'] / p['maxLife']).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p['x'], p['y']), 3.0 * (1.0 - alpha + 0.5), paint);
    }
  }

  // --------------------------------------------------------------------------
  // RENDER PLAYER CHARACTER (Cyber Cat / Adventurer)
  // --------------------------------------------------------------------------
  void _renderPlayer(Canvas canvas) {
    canvas.save();
    canvas.translate(playerX, playerY);

    // Flip sprite according to facing direction
    if (playerFacing < 0) {
      canvas.scale(-1.0, 1.0);
    }

    // Shadow oval
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 22), width: 34, height: 12),
      shadowPaint,
    );

    final bob = isMoving ? math.sin(walkCycle) * 3.5 : math.sin(_gameTime * 3) * 1.5;

    // Body Cloak / Tunic
    final bodyPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 4 - bob), width: 22, height: 26),
        const Radius.circular(8),
      ),
      bodyPaint,
    );

    // Scarf / Accent
    final scarfPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -6 - bob), width: 18, height: 6),
        const Radius.circular(3),
      ),
      scarfPaint,
    );

    // Head
    final headPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, -16 - bob), 14, headPaint);

    // Cat Ears / Explorer Cap
    final earPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.fill;

    // Left Ear
    final earPathL = Path()
      ..moveTo(-12, -22 - bob)
      ..lineTo(-5, -34 - bob)
      ..lineTo(-1, -22 - bob)
      ..close();
    canvas.drawPath(earPathL, earPaint);

    // Right Ear
    final earPathR = Path()
      ..moveTo(1, -22 - bob)
      ..lineTo(5, -34 - bob)
      ..lineTo(12, -22 - bob)
      ..close();
    canvas.drawPath(earPathR, earPaint);

    // Eyes
    final eyePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(4, -16 - bob), 2.2, eyePaint);
    canvas.drawCircle(Offset(9, -16 - bob), 2.2, eyePaint);

    // Cheerful blush
    final blushPaint = Paint()
      ..color = const Color(0xFFF43F5E).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(3, -12 - bob), 2.0, blushPaint);
    canvas.drawCircle(Offset(10, -12 - bob), 2.0, blushPaint);

    canvas.restore();
  }
}
