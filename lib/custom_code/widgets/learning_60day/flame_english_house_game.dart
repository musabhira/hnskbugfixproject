import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pocket_defense_trap_modal.dart';
import 'pocket_fortress_defense_service.dart';
import 'pocket_world_street_page.dart';
import 'pocket_arsenal_store_modal.dart';

/// 🎨 Curated Color Schemes for the English Habit House
class HousePalette {
  final String id;
  final String name;
  final Color wallColor;
  final Color wallShade;
  final Color mortarColor;
  final Color foundationColor;
  final Color roofColor;
  final Color roofShade;
  final Color roofTrim;
  final Color roofUnderTrim;
  final Color doorColor;
  final Color windowColor;
  final Color accentColor;

  const HousePalette({
    required this.id,
    required this.name,
    required this.wallColor,
    required this.wallShade,
    required this.mortarColor,
    required this.foundationColor,
    required this.roofColor,
    required this.roofShade,
    required this.roofTrim,
    required this.roofUnderTrim,
    required this.doorColor,
    required this.windowColor,
    required this.accentColor,
  });

  static const List<HousePalette> presets = [
    HousePalette(
      id: 'terracotta',
      name: '🏡 Classic Storybook',
      wallColor: Color(0xFFF7E8D0),
      wallShade: Color(0xFFEBD4B4),
      mortarColor: Color(0xFFDEC5A5),
      foundationColor: Color(0xFF5A6A78),
      roofColor: Color(0xFFE04938),
      roofShade: Color(0xFFBF3728),
      roofTrim: Color(0xFFFFF7ED),
      roofUnderTrim: Color(0xFFA62A1D),
      doorColor: Color(0xFFD97706),
      windowColor: Color(0xFF38BDF8),
      accentColor: Color(0xFFFFD700),
    ),
    HousePalette(
      id: 'cyber_yellow',
      name: '⚡ Profile Neon Yellow',
      wallColor: Color(0xFF1E293B),
      wallShade: Color(0xFF0F172A),
      mortarColor: Color(0xFF334155),
      foundationColor: Color(0xFF0A0F1D),
      roofColor: Color(0xFFFFFC00),
      roofShade: Color(0xFFEAB308),
      roofTrim: Color(0xFFFFFFFF),
      roofUnderTrim: Color(0xFFCA8A04),
      doorColor: Color(0xFFFFD700),
      windowColor: Color(0xFF00F0FF),
      accentColor: Color(0xFFFFFC00),
    ),
    HousePalette(
      id: 'mirror_glass',
      name: '💎 Luxury Mirror Flat',
      wallColor: Color(0xFF1E3A8A),
      wallShade: Color(0xFF172554),
      mortarColor: Color(0xFF3B82F6),
      foundationColor: Color(0xFF0F172A),
      roofColor: Color(0xFF0284C7),
      roofShade: Color(0xFF0369A1),
      roofTrim: Color(0xFFE0F2FE),
      roofUnderTrim: Color(0xFF0284C7),
      doorColor: Color(0xFF38BDF8),
      windowColor: Color(0xFF67E8F9),
      accentColor: Color(0xFF00F0FF),
    ),
    HousePalette(
      id: 'royal_gold',
      name: '👑 Royal Grandmaster',
      wallColor: Color(0xFF2E1065),
      wallShade: Color(0xFF1E1B4B),
      mortarColor: Color(0xFF581C87),
      foundationColor: Color(0xFF0F0A1C),
      roofColor: Color(0xFFFFD700),
      roofShade: Color(0xFFD97706),
      roofTrim: Color(0xFFFEF08A),
      roofUnderTrim: Color(0xFFB45309),
      doorColor: Color(0xFFF59E0B),
      windowColor: Color(0xFFFDE047),
      accentColor: Color(0xFFFFD700),
    ),
    HousePalette(
      id: 'emerald',
      name: '🌲 Emerald Pine Lodge',
      wallColor: Color(0xFFF1F5F9),
      wallShade: Color(0xFFE2E8F0),
      mortarColor: Color(0xFFCBD5E1),
      foundationColor: Color(0xFF334155),
      roofColor: Color(0xFF059669),
      roofShade: Color(0xFF047857),
      roofTrim: Color(0xFFD1FAE5),
      roofUnderTrim: Color(0xFF065F46),
      doorColor: Color(0xFFB45309),
      windowColor: Color(0xFF34D399),
      accentColor: Color(0xFF10B981),
    ),
    HousePalette(
      id: 'sakura',
      name: '🌸 Rose Blossom',
      wallColor: Color(0xFFFFF1F2),
      wallShade: Color(0xFFFFE4E6),
      mortarColor: Color(0xFFFECDD3),
      foundationColor: Color(0xFF4A044E),
      roofColor: Color(0xFFE11D48),
      roofShade: Color(0xFFBE123C),
      roofTrim: Color(0xFFFFFFFF),
      roofUnderTrim: Color(0xFF9F1239),
      doorColor: Color(0xFFFB7185),
      windowColor: Color(0xFFF472B6),
      accentColor: Color(0xFFFF80AB),
    ),
  ];

  static HousePalette getById(String id) {
    return presets.firstWhere((p) => p.id == id, orElse: () => presets[0]);
  }
}

/// 🏡 Flame-powered Interactive Habit House & Grand Victorian Manor
/// Progresses from a cozy cottage into a magnificent Victorian Manor Palace with soaring birds and colonnades.
class FlameEnglishHouseGame extends FlameGame with TapCallbacks {
  int currentDay;
  int streak;
  HousePalette palette;
  bool isDamaged;
  Vector2? _cachedSize;

  FlameEnglishHouseGame({
    required this.currentDay,
    this.streak = 1,
    HousePalette? initialPalette,
    this.isDamaged = false,
  }) : palette = initialPalette ?? HousePalette.presets[0];

  late HouseMasterComponent houseComponent;
  late AtmosphereComponent atmosphereComponent;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final effectiveSize = _cachedSize ?? size;

    // 1. Transparent atmosphere with drifting clouds, twinkling stars, & flying birds
    atmosphereComponent = AtmosphereComponent(day: currentDay);
    atmosphereComponent.size = effectiveSize;
    add(atmosphereComponent);

    // 2. The progressive cartoon house / Victorian manor & citadel
    houseComponent = HouseMasterComponent(
      day: currentDay,
      streak: streak,
      palette: palette,
      isDamaged: isDamaged,
    );
    houseComponent.resize(effectiveSize);
    add(houseComponent);
  }

  void updateDayAndStreak(int newDay, int newStreak) {
    currentDay = newDay;
    streak = newStreak;
    if (isLoaded) {
      houseComponent.day = newDay;
      houseComponent.streak = newStreak;
      atmosphereComponent.day = newDay;
    }
  }

  void updatePalette(HousePalette newPalette) {
    palette = newPalette;
    if (isLoaded) {
      houseComponent.palette = newPalette;
    }
  }

  void updateDamage(bool damaged) {
    isDamaged = damaged;
    if (isLoaded) {
      houseComponent.isDamaged = damaged;
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _cachedSize = size;
    if (isLoaded) {
      atmosphereComponent.size = size;
      houseComponent.resize(size);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // In-place playful tap effect (no page navigation)
    houseComponent.handleTap(event.localPosition);
  }
}

/// Gentle ambient atmosphere: drifting clouds, twinkling stardust & soaring birds ("കിളികൾ, പക്ഷികൾ")
class AtmosphereComponent extends Component {
  int day;
  Vector2 size = Vector2.zero();
  double time = 0;

  final List<_DriftingCloud> _clouds = [
    _DriftingCloud(xRatio: 0.06, yRatio: 0.07, scale: 0.9, speed: 8),
    _DriftingCloud(xRatio: 0.54, yRatio: 0.14, scale: 0.75, speed: 6),
    _DriftingCloud(xRatio: 0.85, yRatio: 0.06, scale: 1.05, speed: 10),
  ];

  final List<_FlyingBird> _birds = [
    _FlyingBird(xRatio: 0.15, yRatio: 0.12, speed: 22, scale: 0.9, phase: 0.0),
    _FlyingBird(xRatio: 0.28, yRatio: 0.08, speed: 25, scale: 1.1, phase: 1.2),
    _FlyingBird(xRatio: 0.42, yRatio: 0.15, speed: 20, scale: 0.8, phase: 2.4),
    _FlyingBird(xRatio: 0.72, yRatio: 0.10, speed: 24, scale: 1.0, phase: 0.6),
  ];

  AtmosphereComponent({required this.day});

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;

    // Drifting clouds
    for (final cloud in _clouds) {
      cloud.xRatio += (cloud.speed * dt) / (size.x > 0 ? size.x : 400);
      if (cloud.xRatio > 1.25) {
        cloud.xRatio = -0.28;
      }
    }

    // Soaring birds gliding across the sky
    for (final bird in _birds) {
      bird.xRatio += (bird.speed * dt) / (size.x > 0 ? size.x : 400);
      if (bird.xRatio > 1.30) {
        bird.xRatio = -0.25;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (size.x <= 0 || size.y <= 0) return;

    // Twinkling stardust & sparkles ("കുത്തു കുത്തു കുത്തുപോലെ... നക്ഷത്രങ്ങൾ")
    final starPaint = Paint()..style = PaintingStyle.fill;
    final rng = math.Random(day * 13);
    for (int i = 0; i < 26; i++) {
      final sx = rng.nextDouble() * size.x;
      final sy = rng.nextDouble() * (size.y * 0.48);
      final twinkle = (math.sin(time * 3.2 + i * 1.5) + 1.0) / 2.0;
      final r = 0.9 + twinkle * 1.5;
      starPaint.color = Colors.amber.shade200.withValues(alpha: 0.20 + twinkle * 0.70);
      canvas.drawCircle(Offset(sx, sy), r, starPaint);

      if (i % 5 == 0 && twinkle > 0.6) {
        final sparklePaint = Paint()
          ..color = Colors.white.withValues(alpha: twinkle * 0.7)
          ..strokeWidth = 1.0;
        canvas.drawLine(Offset(sx - 3, sy), Offset(sx + 3, sy), sparklePaint);
        canvas.drawLine(Offset(sx, sy - 3), Offset(sx, sy + 3), sparklePaint);
      }
    }

    // Soft drifting cartoon clouds
    for (final cloud in _clouds) {
      _renderCartoonCloud(canvas, cloud.xRatio * size.x, cloud.yRatio * size.y, cloud.scale);
    }

    // 🕊️ Flying Birds ("കിളികൾ / പക്ഷികൾ")
    for (final bird in _birds) {
      _renderBird(canvas, bird.xRatio * size.x, bird.yRatio * size.y, bird.scale, time * 6.5 + bird.phase);
    }
  }

  void _renderBird(Canvas canvas, double cx, double cy, double scale, double wingAngle) {
    final birdPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final wingSpan = 7.0 * scale;
    final wingY = math.sin(wingAngle) * 3.0 * scale;

    final path = Path();
    path.moveTo(cx - wingSpan, cy + wingY);
    path.quadraticBezierTo(cx - wingSpan * 0.4, cy - 2.5 * scale, cx, cy);
    path.quadraticBezierTo(cx + wingSpan * 0.4, cy - 2.5 * scale, cx + wingSpan, cy + wingY);
    canvas.drawPath(path, birdPaint);
  }

  void _renderCartoonCloud(Canvas canvas, double cx, double cy, double scale) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    final r = 16.0 * scale;
    canvas.drawCircle(Offset(cx, cy), r, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 0.85, cy - r * 0.25), r * 1.15, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 1.7, cy), r * 0.8, cloudPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - r * 0.3, cy + r * 0.15, r * 2.4, r * 0.85),
        Radius.circular(r * 0.4),
      ),
      cloudPaint,
    );
  }
}

class _DriftingCloud {
  double xRatio;
  double yRatio;
  double scale;
  double speed;
  _DriftingCloud({
    required this.xRatio,
    required this.yRatio,
    required this.scale,
    required this.speed,
  });
}

class _FlyingBird {
  double xRatio;
  double yRatio;
  double speed;
  double scale;
  double phase;
  _FlyingBird({
    required this.xRatio,
    required this.yRatio,
    required this.speed,
    required this.scale,
    this.phase = 0.0,
  });
}

/// 🏰 Progressive Architectural Cartoon Pyramid House & Grand Victorian Manor
class HouseMasterComponent extends Component {
  int day;
  int streak;
  HousePalette palette;
  bool isDamaged;

  Vector2 canvasSize = Vector2.zero();
  double animTimer = 0;
  bool lightsOn = true;
  final List<_SmokeParticle> _smokeParticles = [];

  HouseMasterComponent({
    required this.day,
    required this.streak,
    required this.palette,
    this.isDamaged = false,
  });

  void resize(Vector2 newSize) {
    canvasSize = newSize;
  }

  @override
  void update(double dt) {
    super.update(dt);
    animTimer += dt;

    // Spawn chimney smoke periodically
    if (_smokeParticles.length < 24 && (animTimer % 0.28) < dt) {
      _smokeParticles.add(_SmokeParticle());
    }

    // Update smoke puffs
    for (int i = _smokeParticles.length - 1; i >= 0; i--) {
      final p = _smokeParticles[i];
      p.life += dt;
      p.y -= dt * 26;
      p.x += math.sin(p.life * 4.2) * dt * 10;
      p.scale += dt * 0.55;
      if (p.life > 2.0) {
        _smokeParticles.removeAt(i);
      }
    }
  }

  /// In-place micro-interaction: Does NOT navigate away!
  void handleTap(Vector2 pos) {
    HapticFeedback.lightImpact();

    // Spawn playful chimney puff burst
    for (int i = 0; i < 4; i++) {
      _smokeParticles.add(_SmokeParticle()
        ..x = (math.Random().nextDouble() - 0.5) * 16
        ..scale = 1.3);
    }

    // Toggle warm window glow
    lightsOn = !lightsOn;
  }

  @override
  void render(Canvas canvas) {
    if (canvasSize.x <= 0 || canvasSize.y <= 0) return;

    final cx = canvasSize.x / 2;
    final groundY = canvasSize.y - 34;

    // Building apex and dimensions for dynamic auto-framing
    final double buildingApexY;
    final double totalBuildingW;

    if (day >= 71) {
      // 🏛️ Monumental Rajput & Indo-Saracenic Imperial Palace (Images 1 & 2)
      buildingApexY = groundY - 256.0;
      totalBuildingW = (day >= 86) ? 420.0 : 392.0;
    } else if (day >= 46) {
      // 🏰 Fortified Castle with Bastion Towers
      buildingApexY = groundY - 200.0;
      totalBuildingW = 370.0;
    } else if (day >= 28) {
      // 🏛️ Grand Victorian Manor
      buildingApexY = groundY - 176.0;
      totalBuildingW = 330.0;
    } else if (day >= 16) {
      // 🏡 2-to-3 Storey European Chateau
      buildingApexY = groundY - 162.0;
      totalBuildingW = 270.0;
    } else if (day >= 8) {
      // 🏠 Quirky Storybook European Townhouse (Image 3)
      buildingApexY = groundY - 164.0;
      totalBuildingW = 220.0;
    } else {
      // 🛖 Storybook Cottage (Days 1–7)
      buildingApexY = groundY - 138.0;
      totalBuildingW = 240.0;
    }

    final double totalBuildingH = groundY - buildingApexY;
    final double availableH = canvasSize.y - 42.0;
    final double availableW = canvasSize.x * 0.94;
    final double scale = math.min(availableW / totalBuildingW, availableH / totalBuildingH).clamp(0.65, 1.05);

    canvas.save();
    canvas.translate(cx, groundY);
    canvas.scale(scale);
    canvas.translate(-cx, -groundY);

    // 1. Garden lawn & stone pathway (drawn for European/Cottage/Castle stages)
    if (day < 90) {
      _renderLawnAndPath(canvas, cx, groundY);
    }

    // 2. Multi-Stage Architectural House & Citadel Progression
    if (day >= 90) {
      // ============================================================
      // 🏛️ MONUMENTAL RAJPUT & INDO-SARACENIC IMPERIAL PALACE (DAY 90 APEX)
      // ============================================================
      _renderImperialRajputPalace(canvas, cx, groundY);
    } else if (day >= 46) {
      // ============================================================
      // 🏰 FORTIFIED CASTLE CITADEL & BASTION KEEP (DAYS 46–89, വലിയ കോട്ട)
      // ============================================================
      _renderFortifiedCastleCitadel(canvas, cx, groundY);
    } else if (day >= 28) {
      // ============================================================
      // 🏛️ THE BELOVED GRAND VICTORIAN MANOR (DAYS 28–45)
      // ============================================================
      _renderGrandVictorianManorWithGround(canvas, cx, groundY);
    } else if (day >= 16) {
      // ============================================================
      // 🏡 TWO-STORY CHATEAU & PROGRESSIVE VILLA (DAYS 16–27)
      // ============================================================
      _renderDay16to27VictorianRising(canvas, cx, groundY);
    } else if (day >= 8) {
      // ============================================================
      // 🏠 QUIRKY STORYBOOK EUROPEAN TOWNHOUSE (IMAGE 3, DAYS 8–15)
      // ============================================================
      _renderDay8to15Townhouse(canvas, cx, groundY);
    } else {
      // ============================================================
      // 🛖 STORYBOOK COUNTRY COTTAGE (DAYS 1–7)
      // ============================================================
      _renderDay1to7Cottage(canvas, cx, groundY);
    }

    // Active Chimney Smoke Particles
    if (day >= 86) {
      _renderSmoke(canvas, cx - 172, groundY - 240);
      _renderSmoke(canvas, cx - 50, groundY - 220);
      _renderSmoke(canvas, cx + 50, groundY - 220);
      _renderSmoke(canvas, cx + 172, groundY - 240);
    } else if (day >= 28) {
      _renderSmoke(canvas, cx - 50, groundY - 210);
      _renderSmoke(canvas, cx + 50, groundY - 210);
    } else if (day >= 8) {
      _renderSmoke(canvas, cx - 36, groundY - 180);
      _renderSmoke(canvas, cx + 36, groundY - 180);
    } else if (day >= 4) {
      _renderSmoke(canvas, cx - 54, groundY - 165);
    }

    // Lush Garden Bushes (Cottage & Chateau phases)
    if (day < 71) {
      _renderBushes(canvas, cx, groundY);
    }

    // Day 90: Presidential VIP Motorcade with Security Strobe Lights
    if (day >= 90) {
      _renderDay90VipMotorcade(canvas, cx, groundY);
    }

    // Raid Damage Overlay
    if (isDamaged) {
      _renderDamageOverlay(canvas, cx, groundY);
    }

    canvas.restore();
  }

  // ============================================================
  // 🛖 1. STORYBOOK COUNTRY COTTAGE (DAYS 1–7)
  // ============================================================
  void _renderDay1to7Cottage(Canvas canvas, double cx, double groundY) {
    // Core Cottage (Walls, Brick Mortar, Windows & Door)
    _renderCoreCottage(canvas, cx, groundY);

    // Daily Prominent Upgrades:
    if (day >= 2) _renderDay2FrontPorchAwning(canvas, cx, groundY);
    if (day >= 3) _renderDay3GardenFlowerBeds(canvas, cx, groundY);
    if (day >= 4) _renderChimneyShaft(canvas, cx - 54, groundY - 146, 14, 28);
    if (day >= 5) _renderDay5StoneWalkway(canvas, cx, groundY);
    if (day >= 6) _renderDay6PicketFence(canvas, cx, groundY);
    if (day >= 7) {
      _renderDay7StreetLamps(canvas, cx, groundY);
      _renderDay7CottageWing(canvas, cx, groundY);
    }
  }

  void _renderDay7CottageWing(Canvas canvas, double cx, double groundY) {
    const wingW = 54.0;
    const wingH = 74.0;
    final wingLeft = cx - 88.0 - wingW + 6;
    final wingTop = groundY - wingH;

    // Stone foundation
    canvas.drawRect(Rect.fromLTWH(wingLeft, groundY - 14, wingW, 14), Paint()..color = palette.foundationColor);

    // Ashlar brick wall
    final wRect = Rect.fromLTWH(wingLeft, wingTop, wingW, wingH - 14);
    canvas.drawRect(wRect, Paint()..color = palette.wallColor);
    canvas.drawRect(wRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5);

    // Ashlar quoins on outer corner
    for (double y = wingTop + 2; y < groundY - 14; y += 12) {
      canvas.drawRect(Rect.fromLTWH(wingLeft, y, 7, 8), Paint()..color = palette.wallShade);
    }

    // Leaded mullion bay window
    _renderStorybookWindow(canvas, wingLeft + wingW / 2, wingTop + 32, 28, 36);

    // Steep gabled roof
    final rPath = Path()
      ..moveTo(wingLeft - 4, wingTop + 4)
      ..lineTo(wingLeft + wingW / 2, wingTop - 26)
      ..lineTo(cx - 88 + 4, wingTop + 4)
      ..close();
    canvas.drawPath(rPath, Paint()..color = palette.roofColor);
    canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 2.5);

    // Gabled attic dormer on main cottage roof
    _renderArchedDormer(canvas, cx, groundY - 98 - 28, 24, 30);
  }

  // ============================================================
  // 🏠 2. QUIRKY STORYBOOK EUROPEAN TOWNHOUSE (IMAGE 3, DAYS 8–15)
  // ============================================================
  void _renderDay8to15Townhouse(Canvas canvas, double cx, double groundY) {
    const coreW = 84.0;
    const coreH = 138.0;
    final coreTop = groundY - coreH;
    final coreLeft = cx - coreW / 2;
    final coreRight = cx + coreW / 2;

    // Stone Foundation
    final fRect = Rect.fromLTWH(coreLeft - 4, groundY - 12, coreW + 8, 12);
    canvas.drawRect(fRect, Paint()..color = palette.foundationColor);

    // Main 3-Storey Townhouse Facade Wall (Grey/Beige Ashlar like Image 3)
    final wallRect = Rect.fromLTWH(coreLeft, coreTop, coreW, coreH - 12);
    canvas.drawRect(wallRect, Paint()..color = palette.wallColor);

    // Ashlar Stone Quoins on Outer Corners (Alternating white/cream blocks like Image 3)
    final quoinPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final quoinBorder = Paint()..style = PaintingStyle.stroke ..color = Colors.black26 ..strokeWidth = 0.8;
    for (double y = coreTop + 4; y < groundY - 14; y += 12) {
      final qW = ((y ~/ 12) % 2 == 0) ? 9.0 : 6.0;
      final qL = Rect.fromLTWH(coreLeft, y, qW, 10);
      final qR = Rect.fromLTWH(coreRight - qW, y, qW, 10);
      canvas.drawRect(qL, quoinPaint);
      canvas.drawRect(qL, quoinBorder);
      canvas.drawRect(qR, quoinPaint);
      canvas.drawRect(qR, quoinBorder);
    }

    // Windows on Main Facade (Quaint Multi-Pane Storybook Windows)
    // First Floor
    _renderVictorianSashWindow(canvas, cx, coreTop + 84, 18, 28);
    // Second Floor
    _renderVictorianSashWindow(canvas, cx - 18, coreTop + 48, 16, 24);
    _renderVictorianSashWindow(canvas, cx + 18, coreTop + 48, 16, 24);
    // Third Floor Attic Windows
    _renderVictorianSashWindow(canvas, cx - 18, coreTop + 16, 14, 20);
    _renderVictorianSashWindow(canvas, cx + 18, coreTop + 16, 14, 20);

    // Day 9+: Lower-Left Cantilevered Room (Directly from Image 3!)
    if (day >= 9) {
      const roomW = 32.0;
      const roomH = 44.0;
      final roomLeft = coreLeft - roomW + 4;
      final roomTop = groundY - 82;
      final rRect = Rect.fromLTWH(roomLeft, roomTop, roomW, roomH);
      canvas.drawRect(rRect, Paint()..color = palette.wallShade);
      canvas.drawRect(rRect, Paint()..style = PaintingStyle.stroke ..color = Colors.black26 ..strokeWidth = 1.0);

      // Diagonal Timber Struts / Brackets supporting the cantilever (Image 3)
      final strutPaint = Paint()..color = const Color(0xFF78350F) ..strokeWidth = 2.2;
      canvas.drawLine(Offset(roomLeft + 6, roomTop + roomH), Offset(coreLeft, groundY - 16), strutPaint);
      canvas.drawLine(Offset(roomLeft + roomW - 4, roomTop + roomH), Offset(coreLeft, groundY - 24), strutPaint);

      // Casement Window
      _renderVictorianSashWindow(canvas, roomLeft + roomW / 2, roomTop + 22, 16, 24);

      // Blue Gabled Slate Roof
      final rPath = Path()
        ..moveTo(roomLeft - 4, roomTop)
        ..lineTo(roomLeft + roomW / 2, roomTop - 18)
        ..lineTo(roomLeft + roomW + 2, roomTop)
        ..close();
      canvas.drawPath(rPath, Paint()..color = palette.roofColor);
      canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.8);
    }

    // Day 10+: Upper-Left Cantilevered Bay Room (Directly from Image 3!)
    if (day >= 10) {
      const bayW = 28.0;
      const bayH = 36.0;
      final bayLeft = coreLeft - bayW + 6;
      final bayTop = coreTop + 14;
      final bRect = Rect.fromLTWH(bayLeft, bayTop, bayW, bayH);
      canvas.drawRect(bRect, Paint()..color = palette.wallShade);
      canvas.drawRect(bRect, Paint()..style = PaintingStyle.stroke ..color = Colors.black26 ..strokeWidth = 1.0);

      // Angled Timber Strut
      canvas.drawLine(Offset(bayLeft + 4, bayTop + bayH), Offset(coreLeft, bayTop + bayH + 18), Paint()..color = const Color(0xFF78350F) ..strokeWidth = 2.0);

      // Bay Window & Wall Lamp
      _renderVictorianSashWindow(canvas, bayLeft + bayW / 2, bayTop + 18, 14, 20);
      canvas.drawCircle(Offset(bayLeft - 2, bayTop + 12), 2.5, Paint()..color = const Color(0xFFFFD700));

      // Roof on Upper Bay
      final bayRoof = Path()
        ..moveTo(bayLeft - 3, bayTop)
        ..lineTo(bayLeft + bayW / 2, bayTop - 14)
        ..lineTo(bayLeft + bayW + 2, bayTop)
        ..close();
      canvas.drawPath(bayRoof, Paint()..color = palette.roofColor);
      canvas.drawPath(bayRoof, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.5);
    }

    // Day 11+: Lower-Right Cantilevered Side Extension & Stairs (Image 3!)
    if (day >= 11) {
      const extW = 32.0;
      const extH = 46.0;
      final extLeft = coreRight - 4;
      final extTop = groundY - 94;
      final extRect = Rect.fromLTWH(extLeft, extTop, extW, extH);
      canvas.drawRect(extRect, Paint()..color = palette.wallShade);
      canvas.drawRect(extRect, Paint()..style = PaintingStyle.stroke ..color = Colors.black26 ..strokeWidth = 1.0);

      // Exterior Wooden Staircase with White Handrail (Image 3)
      final stairPaint = Paint()..color = Colors.white ..strokeWidth = 1.4;
      for (int s = 0; s < 4; s++) {
        final sy = extTop + extH - 4 - s * 6.0;
        final sx = extLeft + extW - 2 - s * 5.0;
        canvas.drawRect(Rect.fromLTWH(sx, sy, 7, 5), Paint()..color = const Color(0xFFCBD5E1));
      }
      canvas.drawLine(Offset(extLeft + extW - 2, extTop + extH - 12), Offset(extLeft + 8, extTop + 14), stairPaint);

      // Side Door
      canvas.drawRect(Rect.fromLTWH(extLeft + 6, extTop + 14, 14, 26), Paint()..color = const Color(0xFF78350F));

      // Roof
      final extRoof = Path()
        ..moveTo(extLeft - 2, extTop)
        ..lineTo(extLeft + extW / 2, extTop - 18)
        ..lineTo(extLeft + extW + 4, extTop)
        ..close();
      canvas.drawPath(extRoof, Paint()..color = palette.roofColor);
      canvas.drawPath(extRoof, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.8);
    }

    // Day 12+: Upper-Right Cantilevered Dormer Turret with Circular Window (Image 3!)
    if (day >= 12) {
      const turW = 28.0;
      const turH = 34.0;
      final turLeft = coreRight - 6;
      final turTop = coreTop + 24;
      final tRect = Rect.fromLTWH(turLeft, turTop, turW, turH);
      canvas.drawRect(tRect, Paint()..color = palette.wallShade);
      canvas.drawRect(tRect, Paint()..style = PaintingStyle.stroke ..color = Colors.black26 ..strokeWidth = 1.0);

      // Diagonal Timber Strut
      canvas.drawLine(Offset(turLeft + turW - 4, turTop + turH), Offset(coreRight, turTop + turH + 16), Paint()..color = const Color(0xFF78350F) ..strokeWidth = 2.0);

      // Circular Portal Window (Image 3)
      final pCenter = Offset(turLeft + turW / 2, turTop + 14);
      canvas.drawCircle(pCenter, 7.0, Paint()..color = lightsOn ? palette.windowColor : const Color(0xFF1E293B));
      canvas.drawCircle(pCenter, 7.0, Paint()..style = PaintingStyle.stroke ..color = Colors.white ..strokeWidth = 1.5);
      canvas.drawLine(pCenter - const Offset(6, 0), pCenter + const Offset(6, 0), Paint()..color = Colors.white ..strokeWidth = 1.0);
      canvas.drawLine(pCenter - const Offset(0, 6), pCenter + const Offset(0, 6), Paint()..color = Colors.white ..strokeWidth = 1.0);

      // Window below
      _renderVictorianSashWindow(canvas, turLeft + turW / 2, turTop + 26, 12, 14);

      // Roof
      final turRoof = Path()
        ..moveTo(turLeft - 2, turTop)
        ..lineTo(turLeft + turW / 2, turTop - 14)
        ..lineTo(turLeft + turW + 4, turTop)
        ..close();
      canvas.drawPath(turRoof, Paint()..color = palette.roofColor);
      canvas.drawPath(turRoof, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.5);
    }

    // Day 13+: High Steep French Mansard Roof atop Townhouse (Image 3!)
    const mansardH = 46.0;
    final mansardTop = coreTop - mansardH;
    final mPath = Path()
      ..moveTo(coreLeft - 6, coreTop + 2)
      ..lineTo(coreLeft + 10, mansardTop)
      ..lineTo(coreRight - 10, mansardTop)
      ..lineTo(coreRight + 6, coreTop + 2)
      ..close();
    canvas.drawPath(mPath, Paint()..color = palette.roofColor);
    canvas.drawPath(mPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 2.5);

    // Double Attic Dormer Windows (Image 3)
    _renderVictorianArchedDormer(canvas, cx - 18, coreTop - 20, 14, 20);
    _renderVictorianArchedDormer(canvas, cx + 18, coreTop - 20, 14, 20);

    // Chimneys atop Roof with Smoke
    _renderChimneyShaft(canvas, coreLeft + 8, mansardTop - 16, 10, 18);
    _renderChimneyShaft(canvas, coreRight - 8, mansardTop - 16, 10, 18);

    // Day 14+: Window Flower Boxes with Cascading Red & Purple Roses
    if (day >= 14) {
      _renderWindowFlowerBox(canvas, cx, coreTop + 84 + 18, 26);
      _renderWindowFlowerBox(canvas, cx - 18, coreTop + 48 + 15, 22);
      _renderWindowFlowerBox(canvas, cx + 18, coreTop + 48 + 15, 22);
    }

    // Day 15+: Grand Entrance Steps with Curved Railing & Arched Pediment (Image 3!)
    if (day >= 15) {
      _renderImage3FrontEntrance(canvas, cx, groundY);
    } else {
      _renderCottageFrontDoor(canvas, cx, groundY);
    }

    // Pathway & Garden accessories
    _renderDay5StoneWalkway(canvas, cx, groundY);
    if (day >= 6) _renderDay6PicketFence(canvas, cx, groundY);
    if (day >= 7) _renderDay7StreetLamps(canvas, cx, groundY);
    if (day >= 9) _renderDay9GardenFountain(canvas, cx - 64, groundY);
    if (day >= 10) _renderDay8AppleTree(canvas, cx + 64, groundY);
  }

  void _renderImage3FrontEntrance(Canvas canvas, double cx, double groundY) {
    const doorW = 24.0;
    const doorH = 40.0;
    final dRect = Rect.fromLTWH(cx - doorW / 2, groundY - doorH - 8, doorW, doorH);

    // Classical Arched Stone Pediment Frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(dRect.left - 4, dRect.top - 6, doorW + 8, doorH + 6), const Radius.circular(4)),
      Paint()..color = Colors.white,
    );

    // Double Panelled Wood Door with arched transom window
    canvas.drawRect(dRect, Paint()..color = const Color(0xFF78350F));
    canvas.drawArc(Rect.fromLTWH(dRect.left + 2, dRect.top + 2, doorW - 4, 14), math.pi, math.pi, true, Paint()..color = lightsOn ? const Color(0xFFFFE082) : const Color(0xFF1E293B));
    canvas.drawCircle(Offset(cx - 3, dRect.center.dy + 4), 1.8, Paint()..color = const Color(0xFFFFD700));

    // Curved Stone Steps with White Railings (Image 3!)
    for (int i = 0; i < 3; i++) {
      final sW = doorW + 8 + i * 6.0;
      final sy = groundY - 8 + i * 3.0;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, sy), width: sW, height: 3.5), const Radius.circular(1.5)), Paint()..color = const Color(0xFFE2E8F0));
    }
    // White Railing posts
    canvas.drawLine(Offset(cx - doorW / 2 - 6, groundY - 18), Offset(cx - doorW / 2 - 6, groundY - 2), Paint()..color = Colors.white ..strokeWidth = 2.0);
    canvas.drawLine(Offset(cx + doorW / 2 + 6, groundY - 18), Offset(cx + doorW / 2 + 6, groundY - 2), Paint()..color = Colors.white ..strokeWidth = 2.0);
  }

  // ============================================================
  // 🏛️ 3. THE BELOVED GRAND VICTORIAN MANOR (DAYS 28–45)
  // ============================================================
  void _renderGrandVictorianManorWithGround(Canvas canvas, double cx, double groundY) {
    final floor2Top = groundY - 134.0;

    // Core manor structure (Always full, complete, and glorious from Day 28!)
    _renderGrandVictorianManor(canvas, cx, groundY);

    // Day 29+: Classical 4-Pillar Portico with Carved Tympanum Pediment
    if (day >= 29) {
      _renderDay32ClassicalPortico(canvas, cx, groundY, groundY - 66.0);
    }

    // Day 30+: Central Chateau Clock Tower Pavilion & Spire
    if (day >= 30) {
      _renderCentralChateauTower(canvas, cx, floor2Top, 78.0);
    }

    // Day 31+: Wrought-Iron Rooftop Cresting along Mansard Roofs
    if (day >= 31) {
      _renderDay35RoofCrestings(canvas, cx, floor2Top);
    }

    // Day 33+: First-Floor Stone Balustrade
    if (day >= 33) {
      _renderDay36FirstFloorBalustrade(canvas, cx, groundY - 66.0);
    }

    // Day 34+: Terraced Grand Marble Steps
    if (day >= 34) {
      _renderGrandSteps(canvas, cx, groundY);
    } else {
      _renderDay5StoneWalkway(canvas, cx, groundY);
    }

    // Day 35+: Twin Cascading Courtyard Fountains
    if (day >= 35) {
      _renderCourtyardFountain(canvas, cx - 110, groundY - 6);
      _renderCourtyardFountain(canvas, cx + 110, groundY - 6);
    }

    // Day 36+: Left Wing Ornate Glasshouse Conservatory (Winter Garden)
    if (day >= 36) {
      _renderDay41Conservatory(canvas, cx, groundY);
    }

    // Day 37+: Right Wing Grand Stone Balustraded Terrace with Classical Urns
    if (day >= 37) {
      _renderDay42Terrace(canvas, cx, groundY);
    }

    // Day 38+: Sculpted Stone Guardian Lions on Marble Pedestals
    if (day >= 38) {
      _renderGuardianLionPedestal(canvas, cx - 44, groundY - 14);
      _renderGuardianLionPedestal(canvas, cx + 44, groundY - 14);
    }

    // Day 39+: Formal Parterre Topiary Boxwood Gardens
    if (day >= 39) {
      _renderVictorianParterreGarden(canvas, cx, groundY);
    }

    // Day 40+: Covered Porte-Cochère Carriage Portico with Amber Lantern
    if (day >= 40) {
      _renderDay44PorteCochere(canvas, cx, groundY);
    }

    // Day 41+: Stately Perimeter Stone Entrance Pillars with Carriage Lanterns
    if (day >= 41) {
      _renderDay45EstateLanternPillars(canvas, cx, groundY);
    }

    // Day 42+: Circular Paved Estate Carriage Driveway with Lawn Medallion
    if (day >= 42) {
      _renderDay42CircularDriveway(canvas, cx, groundY);
    }

    // Day 43+: Rooftop Classical Bronze Statues on Balustrade Pedestals
    if (day >= 43) {
      _renderDay37RooftopUrns(canvas, cx, floor2Top);
    }

    // Day 44+: Flanking Stone Guard Lodges at Estate Perimeter
    if (day >= 44) {
      _renderDay44GuardLodges(canvas, cx, groundY);
    }

    // Day 45+: Royal Wrought-Iron Spear Perimeter Gates
    if (day >= 45) {
      _renderPalaceSpearGates(canvas, cx, groundY, 320.0);
    }
  }

  void _renderDay32ClassicalPortico(Canvas canvas, double cx, double groundY, double floor1Top) {
    const porticoW = 74.0;
    final porticoLeft = cx - porticoW / 2;
    final porticoTop = floor1Top - 8;

    // Triangular Pediment Tympanum
    final pPath = Path()
      ..moveTo(porticoLeft - 6, porticoTop + 4)
      ..lineTo(cx, porticoTop - 24)
      ..lineTo(porticoLeft + porticoW + 6, porticoTop + 4)
      ..close();
    canvas.drawPath(pPath, Paint()..color = palette.wallColor);
    canvas.drawPath(pPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 2.5);

    // Carved Rosette Medallion inside tympanum
    canvas.drawCircle(Offset(cx, porticoTop - 8), 6.0, Paint()..color = palette.accentColor);
    canvas.drawCircle(Offset(cx, porticoTop - 8), 4.0, Paint()..color = Colors.white);

    // Entablature beam
    canvas.drawRect(Rect.fromLTWH(porticoLeft - 4, porticoTop + 4, porticoW + 8, 6), Paint()..color = palette.roofTrim);

    // 4 Grand Corinthian Fluted Columns
    for (final px in [porticoLeft + 4, porticoLeft + 22, porticoLeft + porticoW - 22, porticoLeft + porticoW - 4]) {
      final cRect = Rect.fromLTWH(px - 3.5, porticoTop + 10, 7, groundY - porticoTop - 24);
      canvas.drawRect(cRect, Paint()..color = Colors.white);
      canvas.drawRect(cRect, Paint()..style = PaintingStyle.stroke ..color = const Color(0xFFCBD5E1) ..strokeWidth = 1.0);
      canvas.drawRect(Rect.fromLTWH(px - 5, porticoTop + 10, 10, 4), Paint()..color = Colors.white);
      canvas.drawRect(Rect.fromLTWH(px - 5, groundY - 18, 10, 4), Paint()..color = Colors.white);
    }
  }

  void _renderDay35RoofCrestings(Canvas canvas, double cx, double floor2Top) {
    final crestPaint = Paint()..color = palette.accentColor ..strokeWidth = 1.4;
    for (final wx in [cx - 90.0, cx + 90.0]) {
      final y = floor2Top - 38.0;
      canvas.drawLine(Offset(wx - 40, y), Offset(wx + 40, y), crestPaint);
      for (double fx = wx - 36; fx <= wx + 36; fx += 8) {
        canvas.drawLine(Offset(fx, y), Offset(fx, y - 5), crestPaint);
        canvas.drawCircle(Offset(fx, y - 5), 1.2, crestPaint);
      }
    }
  }

  void _renderDay36FirstFloorBalustrade(Canvas canvas, double cx, double floor1Top) {
    final bTop = floor1Top - 7.0;
    canvas.drawLine(Offset(cx - 150, bTop), Offset(cx + 150, bTop), Paint()..color = Colors.white ..strokeWidth = 2.5);
    for (double bx = cx - 146; bx <= cx + 146; bx += 8.0) {
      if ((bx - cx).abs() > 36) {
        canvas.drawLine(Offset(bx, bTop), Offset(bx, floor1Top), Paint()..color = const Color(0xFFCBD5E1) ..strokeWidth = 1.4);
      }
    }
  }

  void _renderDay37RooftopUrns(Canvas canvas, double cx, double floor2Top) {
    _renderClassicalUrn(canvas, cx - 144, floor2Top - 38);
    _renderClassicalUrn(canvas, cx - 44, floor2Top - 38);
    _renderClassicalUrn(canvas, cx + 44, floor2Top - 38);
    _renderClassicalUrn(canvas, cx + 144, floor2Top - 38);
  }

  void _renderVictorianParterreGarden(Canvas canvas, double cx, double groundY) {
    final bPaint = Paint()..color = const Color(0xFF15803D);
    for (final gx in [cx - 72.0, cx + 72.0]) {
      canvas.drawCircle(Offset(gx, groundY - 4), 6.0, bPaint);
      canvas.drawCircle(Offset(gx - 8, groundY - 2), 4.5, bPaint);
      canvas.drawCircle(Offset(gx + 8, groundY - 2), 4.5, bPaint);
      canvas.drawCircle(Offset(gx, groundY - 8), 2.0, Paint()..color = palette.accentColor);
    }
  }

  void _renderDay41Conservatory(Canvas canvas, double cx, double groundY) {
    const cW = 40.0;
    const cH = 50.0;
    final cLeft = cx - 160.0 - cW + 4;
    final cTop = groundY - cH - 14;

    canvas.drawRect(Rect.fromLTWH(cLeft, groundY - 14, cW, 14), Paint()..color = palette.foundationColor);
    final gRect = Rect.fromLTWH(cLeft, cTop, cW, cH);
    canvas.drawRect(gRect, Paint()..color = (lightsOn ? palette.windowColor : const Color(0xFF38BDF8)).withValues(alpha: 0.35));
    canvas.drawRect(gRect, Paint()..style = PaintingStyle.stroke ..color = Colors.white ..strokeWidth = 1.5);

    final rPath = Path()
      ..moveTo(cLeft - 2, cTop)
      ..cubicTo(cLeft + 4, cTop - 18, cLeft + cW - 4, cTop - 18, cLeft + cW + 2, cTop)
      ..close();
    canvas.drawPath(rPath, Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.45));
    canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = Colors.white ..strokeWidth = 1.5);

    final pPaint = Paint()..color = const Color(0xFF22C55E);
    canvas.drawCircle(Offset(cLeft + 12, groundY - 22), 5, pPaint);
    canvas.drawCircle(Offset(cLeft + 20, groundY - 26), 7, pPaint);
    canvas.drawCircle(Offset(cLeft + 28, groundY - 22), 5, pPaint);
  }

  void _renderDay42Terrace(Canvas canvas, double cx, double groundY) {
    const tW = 40.0;
    const tH = 34.0;
    final tLeft = cx + 160.0 - 4;
    final tTop = groundY - tH - 14;

    canvas.drawRect(Rect.fromLTWH(tLeft, groundY - 14, tW, 14), Paint()..color = palette.foundationColor);
    final wRect = Rect.fromLTWH(tLeft, tTop, tW, tH);
    canvas.drawRect(wRect, Paint()..color = palette.wallColor);
    canvas.drawRect(wRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.2);

    final bTop = tTop - 6;
    canvas.drawLine(Offset(tLeft, bTop), Offset(tLeft + tW, bTop), Paint()..color = Colors.white ..strokeWidth = 2.0);
    for (double bx = tLeft + 4; bx <= tLeft + tW - 4; bx += 6.0) {
      canvas.drawLine(Offset(bx, bTop), Offset(bx, tTop), Paint()..color = const Color(0xFFCBD5E1) ..strokeWidth = 1.2);
    }
    _renderClassicalUrn(canvas, tLeft + 6, bTop - 4);
    _renderClassicalUrn(canvas, tLeft + tW - 6, bTop - 4);
  }

  void _renderDay44PorteCochere(Canvas canvas, double cx, double groundY) {
    const pcW = 80.0;
    final pcTop = groundY - 56.0;
    final pcLeft = cx - pcW / 2;

    final rPath = Path()
      ..moveTo(pcLeft - 6, pcTop + 8)
      ..lineTo(cx, pcTop - 12)
      ..lineTo(pcLeft + pcW + 6, pcTop + 8)
      ..close();
    canvas.drawPath(rPath, Paint()..color = palette.roofColor);
    canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 2.5);

    canvas.drawRect(Rect.fromLTWH(pcLeft + 2, pcTop + 8, 6, groundY - pcTop - 22), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(pcLeft + pcW - 8, pcTop + 8, 6, groundY - pcTop - 22), Paint()..color = Colors.white);

    canvas.drawCircle(Offset(cx, pcTop + 2), 6.0, Paint()..color = Colors.amber.withValues(alpha: 0.5));
    canvas.drawCircle(Offset(cx, pcTop + 2), 2.5, Paint()..color = palette.accentColor);
  }

  void _renderDay45EstateLanternPillars(Canvas canvas, double cx, double groundY) {
    for (final px in [cx - 180.0, cx + 180.0]) {
      final pRect = Rect.fromLTWH(px - 7, groundY - 42, 14, 42);
      canvas.drawRect(pRect, Paint()..color = palette.wallColor);
      canvas.drawRect(pRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.2);
      canvas.drawRect(Rect.fromLTWH(px - 9, groundY - 45, 18, 4), Paint()..color = Colors.white);
      canvas.drawRect(Rect.fromLTWH(px - 5, groundY - 57, 10, 12), Paint()..color = lightsOn ? Colors.amberAccent : const Color(0xFF334155));
      canvas.drawRect(Rect.fromLTWH(px - 5, groundY - 57, 10, 12), Paint()..style = PaintingStyle.stroke ..color = palette.accentColor ..strokeWidth = 1.0);
      canvas.drawCircle(Offset(px, groundY - 51), 3.0, Paint()..color = lightsOn ? Colors.white : Colors.white54);
    }
  }

  void _renderDay42CircularDriveway(Canvas canvas, double cx, double groundY) {
    final dRect = Rect.fromCenter(center: Offset(cx, groundY + 12), width: 140, height: 32);
    canvas.drawOval(dRect, Paint()..color = const Color(0xFF94A3B8).withValues(alpha: 0.35));
    canvas.drawOval(dRect, Paint()..style = PaintingStyle.stroke ..color = const Color(0xFF64748B) ..strokeWidth = 1.2);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, groundY + 12), width: 60, height: 16), Paint()..color = const Color(0xFF16A34A));
    canvas.drawCircle(Offset(cx, groundY + 12), 4.0, Paint()..color = palette.accentColor);
  }

  void _renderDay44GuardLodges(Canvas canvas, double cx, double groundY) {
    for (final lx in [cx - 150.0, cx + 150.0]) {
      final lRect = Rect.fromLTWH(lx - 12, groundY - 32, 24, 20);
      canvas.drawRect(lRect, Paint()..color = palette.wallColor);
      canvas.drawRect(lRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.0);
      final rPath = Path()
        ..moveTo(lx - 15, groundY - 32)
        ..lineTo(lx, groundY - 44)
        ..lineTo(lx + 15, groundY - 32)
        ..close();
      canvas.drawPath(rPath, Paint()..color = palette.roofColor);
      canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.2);
      _renderVictorianSashWindow(canvas, lx, groundY - 22, 10, 12);
    }
  }

  // ============================================================
  // 🏰 4. FORTIFIED CASTLE CITADEL & BASTION KEEP (DAYS 46–70, വലിയ കോട്ട)
  // ============================================================
  void _renderFortifiedCastleCitadel(Canvas canvas, double cx, double groundY) {
    final floor2Top = groundY - 134.0;

    // Day 46+: Heavy Stone Ramparts Foundation
    _renderCastleCurtainRamparts(canvas, cx, groundY);

    // Left Bastion Tower (Days 48–51)
    if (day >= 48) {
      _renderProgressiveBastionTower(canvas, cx - 172, groundY - 14, isLeft: true);
    }
    // Left Aerial Arcade (Day 53+)
    if (day >= 53) {
      _renderConnectingArcade(canvas, cx - 162, cx - 110, groundY - 14, groundY - 120);
    }

    // Right Bastion Tower (Days 54–57)
    if (day >= 54) {
      _renderProgressiveBastionTower(canvas, cx + 172, groundY - 14, isLeft: false);
    }
    // Right Aerial Arcade (Day 58+)
    if (day >= 58) {
      _renderConnectingArcade(canvas, cx + 110, cx + 162, groundY - 14, groundY - 120);
    }

    // Victorian Manor Core (Kept as the central palace citadel)
    _renderGrandVictorianManor(canvas, cx, groundY);
    _renderCentralChateauTower(canvas, cx, floor2Top, 78.0);

    // Day 52+: Heavy Portcullis Iron Gate
    if (day >= 52) {
      _renderPortcullisGate(canvas, cx, groundY);
    }

    // Day 60+: Sovereign Spear Gates
    if (day >= 60) {
      _renderPalaceSpearGates(canvas, cx, groundY, 320.0);
    }

    // Day 61+: Rear Great Keep (Donjon) rising high behind
    if (day >= 61) {
      _renderRearCitadelGreatKeep(canvas, cx, floor2Top);
    }

    // Day 64+: Left Rear Octagonal Spire Tower
    if (day >= 64) {
      _renderRearOctagonalSpire(canvas, cx - 94, floor2Top - 36, isLeft: true);
    }
    // Day 65+: Right Rear Octagonal Spire Tower
    if (day >= 65) {
      _renderRearOctagonalSpire(canvas, cx + 94, floor2Top - 36, isLeft: false);
    }

    // Day 66+: Elevated Battle-Bridge connecting rear towers
    if (day >= 66) {
      _renderElevatedBattleBridge(canvas, cx - 80, cx + 80, floor2Top - 70);
    }

    // Day 67+: Signal Belfry with Bell
    if (day >= 67) {
      _renderCitadelSignalBelfry(canvas, cx, floor2Top - 92);
    }

    // Day 68+: Flying Stone Buttresses
    if (day >= 68) {
      _renderFlyingButtresses(canvas, cx, groundY);
    }

    // Day 69+: Ballista Emplacements on Ramparts
    if (day >= 69) {
      _renderBallistaEmplacements(canvas, cx, groundY);
    }

    // Day 70+: Royal Citadel Standard Mast
    if (day >= 70) {
      _renderCitadelRoyalStandard(canvas, cx, floor2Top - 110);
    }

    // Day 71+: Deep Castle Moat & Heavy Drawbridge with Suspension Chains
    if (day >= 71) {
      _renderCastleMoatAndDrawbridge(canvas, cx, groundY);
    }

    // Day 72+: West Outer Barbican Watchtower
    if (day >= 72) {
      _renderBarbicanWatchtower(canvas, cx - 208, groundY, isLeft: true);
    }

    // Day 73+: East Outer Barbican Watchtower
    if (day >= 73) {
      _renderBarbicanWatchtower(canvas, cx + 208, groundY, isLeft: false);
    }

    // Day 74+: Apex Citadel War Standards & Golden Battle Cresting
    if (day >= 74) {
      _renderCitadelWarStandards(canvas, cx, floor2Top);
    }

    // ============================================================
    // 👑 PROGRESSIVE CITADEL APEX UPGRADES (DAYS 75–89)
    // Directly building upon Day 74 without removing anything!
    // ============================================================

    // Day 75+: High Royal Citadel 3rd Story Floor ("ഒരു നിലയും കൂടി add ചെയ്തു!")
    if (day >= 75) {
      _renderCitadelThirdStoryFloor(canvas, cx, floor2Top);
    }

    // Day 76+: Twin Cantilevered Corner Bartizans on 3rd Floor
    if (day >= 76) {
      _renderThirdStoryBartizans(canvas, cx, floor2Top);
    }

    // Day 77+: Machicolated Stone Parapet & Gilded Roof Cresting
    if (day >= 77) {
      _renderThirdStoryParapetAndCresting(canvas, cx, floor2Top);
    }

    // Day 78+: Soaring Central Octagonal Clock Spire & Belfry
    if (day >= 78) {
      _renderCitadelClockSpire(canvas, cx, floor2Top);
    }

    // Day 79+: Upper Rampart Heavy Bronze Fortress Cannons
    if (day >= 79) {
      _renderUpperRampartCannons(canvas, cx, groundY);
    }

    // Day 80+: Sprawling Stone Perimeter Curtain Enclosure Walls ("മതിലൊക്കെ കെട്ടി!")
    if (day >= 80) {
      _renderFortressPerimeterCurtainWalls(canvas, cx, groundY);
    }

    // Day 81+: West Outer Gatehouse Fortified Tower
    if (day >= 81) {
      _renderOuterGatehouseTower(canvas, cx - 238, groundY, isLeft: true);
    }

    // Day 82+: East Outer Gatehouse Fortified Tower
    if (day >= 82) {
      _renderOuterGatehouseTower(canvas, cx + 238, groundY, isLeft: false);
    }

    // Day 83+: Grand Triumphal Barbican Gate Arch over Drawbridge
    if (day >= 83) {
      _renderGrandBarbicanTriumphalArch(canvas, cx, groundY);
    }

    // Day 84+: High Aerial Stone Viaduct Skybridges connecting Outer Towers
    if (day >= 84) {
      _renderOuterViaductSkybridges(canvas, cx, groundY);
    }

    // Day 85+: Royal Imperial War Standards & Tower Pennants
    if (day >= 85) {
      _renderCitadelImperialWarBanners(canvas, cx, floor2Top);
    }

    // Day 86+: Deep Stone Moat Extended Across Entire Frontage
    if (day >= 86) {
      _renderExtendedPerimeterMoat(canvas, cx, groundY);
    }

    // Day 87+: Additional Courtyard Fountains (Quad Fountains Total)
    if (day >= 87) {
      _renderCourtyardFountain(canvas, cx - 180, groundY - 6);
      _renderCourtyardFountain(canvas, cx + 180, groundY - 6);
    }

    // Day 88+: Additional Golden Guardian Lions (Quad Lions Total)
    if (day >= 88) {
      _renderGuardianLionPedestal(canvas, cx - 92, groundY - 14);
      _renderGuardianLionPedestal(canvas, cx + 92, groundY - 14);
    }

    // Day 89+: Apex Night Torches, Flaming Sconces & Braziers
    if (day >= 89) {
      _renderFortressNightTorchesAndBraziers(canvas, cx, groundY, floor2Top);
    }

    _renderGrandSteps(canvas, cx, groundY);
    _renderCourtyardFountain(canvas, cx - 146, groundY - 6);
    _renderCourtyardFountain(canvas, cx + 146, groundY - 6);
    _renderGuardianLionPedestal(canvas, cx - 48, groundY - 14);
    _renderGuardianLionPedestal(canvas, cx + 48, groundY - 14);
  }

  void _renderCitadelThirdStoryFloor(Canvas canvas, double cx, double floor2Top) {
    // Monumental 3rd Floor Citadel Gallery sitting atop the central core (groundY - 180)
    const f3W = 168.0;
    const f3H = 46.0;
    final f3Top = floor2Top - f3H;
    final f3Left = cx - f3W / 2;

    // Solid ashlar masonry wall
    final f3Rect = Rect.fromLTWH(f3Left, f3Top, f3W, f3H);
    canvas.drawRect(f3Rect, Paint()..color = palette.wallColor);
    canvas.drawRect(f3Rect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.4);

    // Stone courses
    final linePaint = Paint()..color = palette.roofUnderTrim.withValues(alpha: 0.30)..strokeWidth = 0.8;
    for (double y = f3Top + 10; y <= floor2Top - 8; y += 9.0) {
      canvas.drawLine(Offset(f3Left, y), Offset(f3Left + f3W, y), linePaint);
    }

    // Heavy Stone Base Molding
    canvas.drawLine(Offset(f3Left - 4, floor2Top), Offset(f3Left + f3W + 4, floor2Top), Paint()..color = palette.foundationColor ..strokeWidth = 3.0);

    // 5 Arched Lancet Windows across the 3rd floor
    const winW = 14.0;
    const winH = 24.0;
    for (int i = -2; i <= 2; i++) {
      final wx = cx + i * 32.0;
      final wRect = Rect.fromLTWH(wx - winW / 2, f3Top + 10, winW, winH);
      final winPath = Path()
        ..moveTo(wRect.left, wRect.bottom)
        ..lineTo(wRect.left, wRect.top + winW / 2)
        ..arcToPoint(Offset(wRect.right, wRect.top + winW / 2), radius: Radius.circular(winW / 2))
        ..lineTo(wRect.right, wRect.bottom)
        ..close();

      canvas.drawPath(winPath, Paint()..color = lightsOn ? palette.windowColor : const Color(0xFF1E293B));
      canvas.drawPath(winPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.2);

      // Window cross muntin
      canvas.drawLine(Offset(wx, wRect.top + 4), Offset(wx, wRect.bottom), Paint()..color = palette.roofTrim ..strokeWidth = 0.8);
      canvas.drawLine(Offset(wRect.left, wRect.top + 14), Offset(wRect.right, wRect.top + 14), Paint()..color = palette.roofTrim ..strokeWidth = 0.8);
    }
  }

  void _renderThirdStoryBartizans(Canvas canvas, double cx, double floor2Top) {
    const f3W = 168.0;
    const f3H = 46.0;
    final f3Top = floor2Top - f3H;

    for (final isLeft in [true, false]) {
      final bx = isLeft ? cx - f3W / 2 - 2 : cx + f3W / 2 + 2;
      // Corbel brackets beneath bartizan
      final bPath = Path()
        ..moveTo(bx - 7, f3Top + 24)
        ..lineTo(bx, f3Top + 36)
        ..lineTo(bx + 7, f3Top + 24)
        ..close();
      canvas.drawPath(bPath, Paint()..color = palette.foundationColor);

      // Turret body
      final tRect = Rect.fromLTWH(bx - 8, f3Top + 2, 16, 22);
      canvas.drawRect(tRect, Paint()..color = palette.wallShade);
      canvas.drawRect(tRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.0);

      // Arrow loop
      canvas.drawLine(Offset(bx, f3Top + 8), Offset(bx, f3Top + 18), Paint()..color = const Color(0xFF0F172A) ..strokeWidth = 1.8);

      // Conical roof
      final cPath = Path()
        ..moveTo(bx - 10, f3Top + 2)
        ..lineTo(bx, f3Top - 16)
        ..lineTo(bx + 10, f3Top + 2)
        ..close();
      canvas.drawPath(cPath, Paint()..color = palette.roofColor);
      canvas.drawPath(cPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.2);
    }
  }

  void _renderThirdStoryParapetAndCresting(Canvas canvas, double cx, double floor2Top) {
    const f3W = 168.0;
    const f3H = 46.0;
    final f3Top = floor2Top - f3H;

    // Overhanging machicolated parapet ledge
    final pRect = Rect.fromLTWH(cx - f3W / 2 - 6, f3Top - 4, f3W + 12, 6);
    canvas.drawRect(pRect, Paint()..color = palette.foundationColor);
    canvas.drawRect(pRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.2);

    // Crenellated merlons
    for (double x = cx - f3W / 2 - 4; x <= cx + f3W / 2 - 2; x += 12.0) {
      canvas.drawRect(Rect.fromLTWH(x, f3Top - 11, 7, 7), Paint()..color = palette.foundationColor);
      canvas.drawRect(Rect.fromLTWH(x, f3Top - 11, 7, 7), Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 0.8);
    }

    // Wrought-iron gilded cresting along the parapet
    final crestPaint = Paint()..color = const Color(0xFFFFD700) ..strokeWidth = 1.0;
    for (double x = cx - f3W / 2; x <= cx + f3W / 2; x += 8.0) {
      canvas.drawLine(Offset(x, f3Top - 11), Offset(x, f3Top - 17), crestPaint);
      canvas.drawCircle(Offset(x, f3Top - 17), 1.2, Paint()..color = const Color(0xFFFFD700));
    }
  }

  void _renderCitadelClockSpire(Canvas canvas, double cx, double floor2Top) {
    const f3H = 46.0;
    final f3Top = floor2Top - f3H;
    const spW = 34.0;
    const spH = 26.0;
    final spTop = f3Top - 11 - spH;

    // Clock tower square chamber
    final cRect = Rect.fromLTWH(cx - spW / 2, spTop, spW, spH);
    canvas.drawRect(cRect, Paint()..color = palette.wallShade);
    canvas.drawRect(cRect, Paint()..style = PaintingStyle.stroke ..color = palette.accentColor ..strokeWidth = 1.5);

    // Circular clock face
    final clockCenter = Offset(cx, spTop + spH / 2);
    canvas.drawCircle(clockCenter, 8.0, Paint()..color = lightsOn ? palette.windowColor : Colors.white70);
    canvas.drawCircle(clockCenter, 8.0, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.2);
    // Clock hands
    canvas.drawLine(clockCenter, Offset(cx, clockCenter.dy - 5), Paint()..color = Colors.black87 ..strokeWidth = 1.2);
    canvas.drawLine(clockCenter, Offset(cx + 4, clockCenter.dy), Paint()..color = Colors.black87 ..strokeWidth = 1.0);

    // High soaring octagonal spire
    final spireTop = spTop - 38.0;
    final spPath = Path()
      ..moveTo(cx - spW / 2 - 2, spTop)
      ..lineTo(cx, spireTop)
      ..lineTo(cx + spW / 2 + 2, spTop)
      ..close();
    canvas.drawPath(spPath, Paint()..color = palette.roofColor);
    canvas.drawPath(spPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.5);

    // Golden Weathercock / Spire Finial
    canvas.drawLine(Offset(cx, spireTop), Offset(cx, spireTop - 14), Paint()..color = const Color(0xFFFFD700) ..strokeWidth = 1.8);
    canvas.drawCircle(Offset(cx, spireTop - 14), 2.5, Paint()..color = const Color(0xFFFFD700));
  }

  void _renderUpperRampartCannons(Canvas canvas, double cx, double groundY) {
    final cannonXs = [cx - 132.0, cx - 62.0, cx + 62.0, cx + 132.0];
    for (final x in cannonXs) {
      final isLeft = x < cx;
      final cy = groundY - 24.0;
      // Timber carriage
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, cy + 2), width: 14, height: 6), const Radius.circular(1.5)), Paint()..color = const Color(0xFF4A3728));
      // Carriage wheel
      canvas.drawCircle(Offset(x, cy + 4), 3.0, Paint()..color = const Color(0xFF261C14));
      // Bronze cannon barrel
      final barrelPaint = Paint()..color = const Color(0xFFD97706) ..strokeWidth = 2.8;
      canvas.drawLine(Offset(x, cy), Offset(isLeft ? x - 10 : x + 10, cy - 2), barrelPaint);
      canvas.drawCircle(Offset(isLeft ? x - 10 : x + 10, cy - 2), 1.6, Paint()..color = const Color(0xFFB45309));
    }
  }

  void _renderFortressPerimeterCurtainWalls(Canvas canvas, double cx, double groundY) {
    const wallH = 32.0;
    final wallTop = groundY - wallH;

    for (final isLeft in [true, false]) {
      final leftX = isLeft ? cx - 250.0 : cx + 192.0;
      const wW = 58.0;

      final wRect = Rect.fromLTWH(leftX, wallTop, wW, wallH - 12);
      canvas.drawRect(wRect, Paint()..color = palette.wallShade);
      canvas.drawRect(wRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.2);

      // Stone courses
      final linePaint = Paint()..color = palette.roofUnderTrim.withValues(alpha: 0.30)..strokeWidth = 0.8;
      for (double y = wallTop + 6; y <= wallTop + wallH - 14; y += 7.0) {
        canvas.drawLine(Offset(leftX, y), Offset(leftX + wW, y), linePaint);
      }

      // Battlements
      for (double bx = leftX + 2; bx <= leftX + wW - 8; bx += 10.0) {
        canvas.drawRect(Rect.fromLTWH(bx, wallTop - 5, 5, 5), Paint()..color = palette.foundationColor);
        canvas.drawRect(Rect.fromLTWH(bx, wallTop - 5, 5, 5), Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 0.8);
      }

      // Iron Torch Sconce on wall
      final tx = leftX + wW / 2;
      canvas.drawCircle(Offset(tx, wallTop + 8), 2.2, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawLine(Offset(tx, wallTop + 8), Offset(tx, wallTop + 12), Paint()..color = const Color(0xFF0F172A) ..strokeWidth = 1.2);
    }
  }

  void _renderOuterGatehouseTower(Canvas canvas, double tx, double groundY, {required bool isLeft}) {
    const tW = 34.0;
    const tH = 106.0;
    final topY = groundY - tH;

    final tRect = Rect.fromLTWH(tx - tW / 2, topY, tW, tH);
    canvas.drawRect(tRect, Paint()..color = palette.wallColor);
    canvas.drawRect(tRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5);

    // Stone courses
    final linePaint = Paint()..color = palette.roofUnderTrim.withValues(alpha: 0.35)..strokeWidth = 0.8;
    for (double y = topY + 12; y <= groundY - 8; y += 10.0) {
      canvas.drawLine(Offset(tRect.left, y), Offset(tRect.right, y), linePaint);
    }

    // Arched portal window
    final winRect = Rect.fromCenter(center: Offset(tx, topY + 36), width: 8.0, height: 16.0);
    canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(3)), Paint()..color = lightsOn ? palette.windowColor : const Color(0xFF0F172A));

    // Overhanging machicolated parapet
    const pW = 42.0;
    const pH = 12.0;
    final pRect = Rect.fromLTWH(tx - pW / 2, topY - pH, pW, pH);
    canvas.drawRect(pRect, Paint()..color = palette.foundationColor);
    canvas.drawRect(pRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.4);

    for (double bx = pRect.left + 2; bx <= pRect.right - 8; bx += 10.0) {
      canvas.drawRect(Rect.fromLTWH(bx, topY - pH - 6, 6, 6), Paint()..color = palette.foundationColor);
      canvas.drawRect(Rect.fromLTWH(bx, topY - pH - 6, 6, 6), Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 0.8);
    }

    // Pyramidal/conical slate roof
    final roofPath = Path()
      ..moveTo(tx - pW / 2 - 2, topY - pH - 6)
      ..lineTo(tx, topY - pH - 34)
      ..lineTo(tx + pW / 2 + 2, topY - pH - 6)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = palette.roofColor);
    canvas.drawPath(roofPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.5);

    // Royal Swallowtail Pennant
    canvas.drawLine(Offset(tx, topY - pH - 34), Offset(tx, topY - pH - 50), Paint()..color = palette.accentColor ..strokeWidth = 1.6);
    final flagPath = Path()
      ..moveTo(tx, topY - pH - 50)
      ..lineTo(isLeft ? tx - 18 : tx + 18, topY - pH - 43)
      ..lineTo(tx, topY - pH - 36)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = palette.accentColor);
  }

  void _renderGrandBarbicanTriumphalArch(Canvas canvas, double cx, double groundY) {
    const archW = 68.0;
    const archH = 46.0;
    final archTop = groundY - archH;

    // Twin stone archway pillars
    final pPaint = Paint()..color = palette.foundationColor;
    final pBorder = Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.5;
    final leftPillar = Rect.fromLTWH(cx - archW / 2, archTop, 12, archH);
    final rightPillar = Rect.fromLTWH(cx + archW / 2 - 12, archTop, 12, archH);
    canvas.drawRect(leftPillar, pPaint);
    canvas.drawRect(leftPillar, pBorder);
    canvas.drawRect(rightPillar, pPaint);
    canvas.drawRect(rightPillar, pBorder);

    // Semicircular stone arch
    final archPath = Path()
      ..moveTo(cx - archW / 2, archTop + 8)
      ..quadraticBezierTo(cx, archTop - 14, cx + archW / 2, archTop + 8)
      ..lineTo(cx + archW / 2 - 10, archTop + 8)
      ..quadraticBezierTo(cx, archTop - 6, cx - archW / 2 + 10, archTop + 8)
      ..close();
    canvas.drawPath(archPath, pPaint);
    canvas.drawPath(archPath, pBorder);

    // Carved Royal Escutcheon / Coat-of-Arms atop the arch
    final escRect = Rect.fromCenter(center: Offset(cx, archTop - 12), width: 14, height: 16);
    canvas.drawRRect(RRect.fromRectAndRadius(escRect, const Radius.circular(3)), Paint()..color = palette.accentColor);
    canvas.drawRRect(RRect.fromRectAndRadius(escRect, const Radius.circular(3)), Paint()..style = PaintingStyle.stroke ..color = const Color(0xFFFFD700) ..strokeWidth = 1.0);
  }

  void _renderOuterViaductSkybridges(Canvas canvas, double cx, double groundY) {
    final vPaint = Paint()..color = palette.wallShade;
    final vBorder = Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.0;
    for (final isLeft in [true, false]) {
      final x1 = isLeft ? cx - 238.0 : cx + 208.0;
      final x2 = isLeft ? cx - 208.0 : cx + 238.0;
      final y = groundY - 58.0;
      final vRect = Rect.fromLTRB(x1, y, x2, y + 12);
      canvas.drawRect(vRect, vPaint);
      canvas.drawRect(vRect, vBorder);

      // Balustrade on viaduct
      canvas.drawLine(Offset(x1, y - 4), Offset(x2, y - 4), Paint()..color = palette.roofTrim ..strokeWidth = 1.5);
    }
  }

  void _renderCitadelImperialWarBanners(Canvas canvas, double cx, double floor2Top) {
    final flagXs = [cx - 172.0, cx - 94.0, cx + 94.0, cx + 172.0];
    for (final x in flagXs) {
      final isLeft = x < cx;
      final poleTop = floor2Top - 62.0;
      canvas.drawLine(Offset(x, floor2Top - 36), Offset(x, poleTop), Paint()..color = palette.accentColor ..strokeWidth = 2.0);
      canvas.drawCircle(Offset(x, poleTop), 2.2, Paint()..color = const Color(0xFFFFD700));

      final flagPath = Path()
        ..moveTo(x, poleTop)
        ..lineTo(isLeft ? x - 22 : x + 22, poleTop + 6)
        ..lineTo(x, poleTop + 14)
        ..close();
      canvas.drawPath(flagPath, Paint()..color = (x.abs() % 2 == 0) ? const Color(0xFFDC2626) : palette.accentColor);
    }
  }

  void _renderExtendedPerimeterMoat(Canvas canvas, double cx, double groundY) {
    final moatRect = Rect.fromLTWH(cx - 190, groundY + 8, 380, 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(moatRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF1E3A8A).withValues(alpha: 0.85),
    );
    final ripplePaint = Paint()..color = const Color(0xFF60A5FA).withValues(alpha: 0.5)..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - 160, groundY + 14), Offset(cx - 90, groundY + 14), ripplePaint);
    canvas.drawLine(Offset(cx + 90, groundY + 16), Offset(cx + 160, groundY + 16), ripplePaint);
    canvas.drawLine(Offset(cx - 60, groundY + 22), Offset(cx + 60, groundY + 22), ripplePaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(moatRect, const Radius.circular(8)),
      Paint()..style = PaintingStyle.stroke ..color = palette.foundationColor ..strokeWidth = 2.5,
    );
  }

  void _renderFortressNightTorchesAndBraziers(Canvas canvas, double cx, double groundY, double floor2Top) {
    final brazierXs = [cx - 172.0, cx - 94.0, cx + 94.0, cx + 172.0];
    for (final bx in brazierXs) {
      final by = floor2Top - 20.0;
      canvas.drawArc(Rect.fromCenter(center: Offset(bx, by), width: 12, height: 8), 0, 3.14159, false, Paint()..color = const Color(0xFF1E293B));
      canvas.drawCircle(Offset(bx, by - 3), 5.0, Paint()..color = const Color(0xFFF59E0B).withValues(alpha: 0.85));
      canvas.drawCircle(Offset(bx, by - 4), 3.0, Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.90));
      canvas.drawCircle(Offset(bx, by - 5), 1.5, Paint()..color = const Color(0xFFFEF08A));
    }
  }

  void _renderCastleMoatAndDrawbridge(Canvas canvas, double cx, double groundY) {
    // Castle Moat with deep stone quay and glistening water
    final moatRect = Rect.fromLTWH(cx - 150, groundY + 8, 300, 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(moatRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF1E3A8A).withValues(alpha: 0.85),
    );
    final ripplePaint = Paint()..color = const Color(0xFF60A5FA).withValues(alpha: 0.5)..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - 120, groundY + 14), Offset(cx - 70, groundY + 14), ripplePaint);
    canvas.drawLine(Offset(cx + 60, groundY + 16), Offset(cx + 110, groundY + 16), ripplePaint);
    canvas.drawLine(Offset(cx - 40, groundY + 22), Offset(cx + 40, groundY + 22), ripplePaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(moatRect, const Radius.circular(8)),
      Paint()..style = PaintingStyle.stroke ..color = palette.foundationColor ..strokeWidth = 2.5,
    );

    // Heavy Timber Drawbridge
    const bridgeW = 56.0;
    const bridgeH = 26.0;
    final bRect = Rect.fromLTWH(cx - bridgeW / 2, groundY + 2, bridgeW, bridgeH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFF5C3A21),
    );
    final plankPaint = Paint()..color = const Color(0xFF3E2723)..strokeWidth = 1.5;
    for (double y = groundY + 6; y <= groundY + bridgeH; y += 6.0) {
      canvas.drawLine(Offset(bRect.left, y), Offset(bRect.right, y), plankPaint);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(bRect, const Radius.circular(3)),
      Paint()..style = PaintingStyle.stroke ..color = const Color(0xFF261C14) ..strokeWidth = 2.0,
    );

    // Suspension chains rising to portcullis gate
    final chainPaint = Paint()..color = const Color(0xFF94A3B8) ..strokeWidth = 1.8;
    canvas.drawLine(Offset(bRect.left + 4, bRect.bottom - 4), Offset(cx - 24, groundY - 26), chainPaint);
    canvas.drawLine(Offset(bRect.right - 4, bRect.bottom - 4), Offset(cx + 24, groundY - 26), chainPaint);
  }

  void _renderBarbicanWatchtower(Canvas canvas, double tx, double groundY, {required bool isLeft}) {
    const tW = 36.0;
    const tH = 92.0;
    final topY = groundY - tH;

    final tRect = Rect.fromLTWH(tx - tW / 2, topY, tW, tH);
    canvas.drawRect(tRect, Paint()..color = palette.wallShade);
    canvas.drawRect(tRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5);

    final linePaint = Paint()..color = palette.roofUnderTrim.withValues(alpha: 0.35)..strokeWidth = 0.8;
    for (double y = topY + 12; y <= groundY - 8; y += 10.0) {
      canvas.drawLine(Offset(tRect.left, y), Offset(tRect.right, y), linePaint);
    }

    final slitRect = Rect.fromCenter(center: Offset(tx, topY + 40), width: 4.0, height: 16.0);
    canvas.drawRRect(RRect.fromRectAndRadius(slitRect, const Radius.circular(2)), Paint()..color = const Color(0xFF0F172A));

    const pW = 44.0;
    const pH = 12.0;
    final pRect = Rect.fromLTWH(tx - pW / 2, topY - pH, pW, pH);
    canvas.drawRect(pRect, Paint()..color = palette.foundationColor);
    canvas.drawRect(pRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.4);

    for (double bx = pRect.left + 2; bx <= pRect.right - 8; bx += 10.0) {
      canvas.drawRect(Rect.fromLTWH(bx, topY - pH - 6, 6, 6), Paint()..color = palette.foundationColor);
      canvas.drawRect(Rect.fromLTWH(bx, topY - pH - 6, 6, 6), Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.0);
    }

    final roofPath = Path()
      ..moveTo(tx - pW / 2 - 2, topY - pH - 6)
      ..lineTo(tx, topY - pH - 32)
      ..lineTo(tx + pW / 2 + 2, topY - pH - 6)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = palette.roofColor);
    canvas.drawPath(roofPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.5);

    canvas.drawLine(Offset(tx, topY - pH - 32), Offset(tx, topY - pH - 46), Paint()..color = palette.accentColor ..strokeWidth = 1.5);
    final pennantPath = Path()
      ..moveTo(tx, topY - pH - 46)
      ..lineTo(isLeft ? tx - 16 : tx + 16, topY - pH - 40)
      ..lineTo(tx, topY - pH - 34)
      ..close();
    canvas.drawPath(pennantPath, Paint()..color = palette.accentColor);
  }

  void _renderCitadelWarStandards(Canvas canvas, double cx, double floor2Top) {
    for (int i = -2; i <= 2; i++) {
      if (i == 0) continue;
      final sx = cx + i * 44.0;
      final poleTop = floor2Top - 38.0;
      canvas.drawLine(Offset(sx, floor2Top - 10), Offset(sx, poleTop), Paint()..color = palette.accentColor ..strokeWidth = 2.0);
      canvas.drawCircle(Offset(sx, poleTop), 2.5, Paint()..color = const Color(0xFFFFD700));

      final flagPath = Path()
        ..moveTo(sx, poleTop)
        ..lineTo(sx + (i < 0 ? -20 : 20), poleTop + 6)
        ..lineTo(sx, poleTop + 12)
        ..close();
      canvas.drawPath(flagPath, Paint()..color = (i.abs() == 1) ? const Color(0xFFDC2626) : palette.accentColor);
    }
  }

  void _renderCastleCurtainRamparts(Canvas canvas, double cx, double groundY) {
    const rampW = 340.0;
    const rampH = 22.0;
    final rLeft = cx - rampW / 2;
    final rTop = groundY - rampH;

    final rRect = Rect.fromLTWH(rLeft, rTop, rampW, rampH);
    canvas.drawRect(rRect, Paint()..color = palette.foundationColor);
    canvas.drawRect(rRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.2);

    if (day >= 47) {
      final bPaint = Paint()..color = palette.wallShade;
      final bBorder = Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.0;
      for (double x = rLeft + 8; x <= rLeft + rampW - 16; x += 16.0) {
        final merlonRect = Rect.fromLTWH(x, rTop - 8, 10, 8);
        canvas.drawRect(merlonRect, bPaint);
        canvas.drawRect(merlonRect, bBorder);
        canvas.drawLine(Offset(x + 5, rTop - 6), Offset(x + 5, rTop - 2), Paint()..color = Colors.black45 ..strokeWidth = 1.2);
      }
    }
  }

  void _renderProgressiveBastionTower(Canvas canvas, double tx, double groundY, {required bool isLeft}) {
    const towerW = 46.0;
    const towerH = 150.0;
    final towerTop = groundY - towerH;
    final tLeft = tx - towerW / 2;

    // Ground Floor & 2nd Floor Base (Solid Fortified Tower from Day 48/54!)
    canvas.drawRect(Rect.fromLTWH(tLeft, groundY - 100, towerW, 86), Paint()..color = palette.wallColor);
    canvas.drawRect(Rect.fromLTWH(tLeft, groundY - 100, towerW, 86), Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.2);
    _renderVictorianSashWindow(canvas, tx, groundY - 76, 16, 28);
    // Arrow loops on ground floor
    canvas.drawRect(Rect.fromLTWH(tx - 1.5, groundY - 36, 3, 14), Paint()..color = const Color(0xFF0F172A));

    final min3rd = isLeft ? 49 : 55;
    if (day >= min3rd) {
      canvas.drawRect(Rect.fromLTWH(tLeft, towerTop, towerW, 50), Paint()..color = palette.wallColor);
      canvas.drawRect(Rect.fromLTWH(tLeft, towerTop, towerW, 50), Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.2);
      _renderLancetWindow(canvas, tx, towerTop + 24, 14, 26);
      canvas.drawRect(Rect.fromLTWH(tLeft - 3, towerTop - 6, towerW + 6, 7), Paint()..color = palette.roofTrim);
    }

    final minRoof = isLeft ? 50 : 56;
    if (day >= minRoof) {
      const roofH = 52.0;
      final peakY = towerTop - 6 - roofH;
      final rPath = Path()
        ..moveTo(tLeft - 4, towerTop - 4)
        ..lineTo(tx, peakY)
        ..lineTo(tLeft + towerW + 4, towerTop - 4)
        ..close();
      canvas.drawPath(rPath, Paint()..color = palette.roofColor);
      canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 2.0);

      final minFlag = isLeft ? 51 : 57;
      if (day >= minFlag) {
        final goldPaint = Paint()..color = palette.accentColor;
        canvas.drawLine(Offset(tx, peakY), Offset(tx, peakY - 20), goldPaint..strokeWidth = 2.0);
        final flagPath = Path()
          ..moveTo(tx, peakY - 20)
          ..lineTo(isLeft ? tx - 16 : tx + 16, peakY - 14)
          ..lineTo(tx, peakY - 8)
          ..close();
        canvas.drawPath(flagPath, Paint()..color = isLeft ? palette.accentColor : palette.doorColor);
      }
    }
  }

  void _renderPortcullisGate(Canvas canvas, double cx, double groundY) {
    const gW = 34.0;
    const gH = 46.0;
    final gRect = Rect.fromCenter(center: Offset(cx, groundY - gH / 2 - 14), width: gW, height: gH);
    canvas.drawRRect(RRect.fromRectAndRadius(gRect, const Radius.circular(16)), Paint()..color = const Color(0xFF0F172A));
    canvas.drawRRect(RRect.fromRectAndRadius(gRect, const Radius.circular(16)), Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 2.0);
    final barPaint = Paint()..color = const Color(0xFF94A3B8) ..strokeWidth = 1.4;
    for (double x = gRect.left + 5; x <= gRect.right - 5; x += 6.0) {
      canvas.drawLine(Offset(x, gRect.top + 4), Offset(x, gRect.bottom), barPaint);
    }
    for (double y = gRect.top + 10; y <= gRect.bottom - 4; y += 8.0) {
      canvas.drawLine(Offset(gRect.left + 2, y), Offset(gRect.right - 2, y), barPaint);
    }
  }

  void _renderRearCitadelGreatKeep(Canvas canvas, double cx, double floor2Top) {
    const keepW = 120.0;
    const keepH = 70.0;
    final kLeft = cx - keepW / 2;
    final kTop = floor2Top - keepH;

    // Heavy Ashlar stone Donjon Keep wall
    final kRect = Rect.fromLTWH(kLeft, kTop, keepW, keepH);
    canvas.drawRect(kRect, Paint()..color = palette.wallShade);
    canvas.drawRect(kRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5);

    // Stone masonry courses (Never looks like a flat board!)
    final stoneLine = Paint()..color = palette.roofUnderTrim.withValues(alpha: 0.6) ..strokeWidth = 0.8;
    for (double y = kTop + 14; y < floor2Top; y += 14) {
      canvas.drawLine(Offset(kLeft, y), Offset(kLeft + keepW, y), stoneLine);
    }
    // Ashlar quoins on outer corners
    for (double y = kTop; y < floor2Top; y += 12) {
      canvas.drawRect(Rect.fromLTWH(kLeft, y, 7, 8), Paint()..color = palette.wallColor);
      canvas.drawRect(Rect.fromLTWH(kLeft + keepW - 7, y, 7, 8), Paint()..color = palette.wallColor);
    }

    // Machicolations and crenellated battlements across Keep top (Always present Day 61+!)
    final bPaint = Paint()..color = palette.wallColor;
    final bBorder = Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.0;
    for (double x = kLeft + 4; x <= kLeft + keepW - 12; x += 14.0) {
      final mRect = Rect.fromLTWH(x, kTop - 8, 8, 8);
      canvas.drawRect(mRect, bPaint);
      canvas.drawRect(mRect, bBorder);
    }
    _renderBartizanTurret(canvas, kLeft + 2, kTop - 2);
    _renderBartizanTurret(canvas, kLeft + keepW - 2, kTop - 2);

    // Triple arched lancet stained-glass windows (Always present Day 61+!)
    _renderLancetWindow(canvas, cx - 36, kTop + 28, 14, 28);
    _renderLancetWindow(canvas, cx, kTop + 24, 16, 32);
    _renderLancetWindow(canvas, cx + 36, kTop + 28, 14, 28);
  }

  void _renderBartizanTurret(Canvas canvas, double cx, double cy) {
    canvas.drawCircle(Offset(cx, cy), 6.0, Paint()..color = palette.wallColor);
    canvas.drawCircle(Offset(cx, cy), 6.0, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.2);
    final cPath = Path()
      ..moveTo(cx - 7, cy)
      ..lineTo(cx, cy - 14)
      ..lineTo(cx + 7, cy)
      ..close();
    canvas.drawPath(cPath, Paint()..color = palette.roofColor);
  }

  void _renderRearOctagonalSpire(Canvas canvas, double tx, double baseTop, {required bool isLeft}) {
    const spW = 28.0;
    const spH = 64.0;
    final sTop = baseTop - spH;
    final sLeft = tx - spW / 2;

    canvas.drawRect(Rect.fromLTWH(sLeft, sTop, spW, spH), Paint()..color = palette.wallColor);
    canvas.drawRect(Rect.fromLTWH(sLeft, sTop, spW, spH), Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.2);
    _renderLancetWindow(canvas, tx, sTop + 28, 10, 20);

    final peakY = sTop - 38.0;
    final rPath = Path()
      ..moveTo(sLeft - 2, sTop)
      ..lineTo(tx, peakY)
      ..lineTo(sLeft + spW + 2, sTop)
      ..close();
    canvas.drawPath(rPath, Paint()..color = palette.roofColor);
    canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.8);
    canvas.drawLine(Offset(tx, peakY), Offset(tx, peakY - 12), Paint()..color = palette.accentColor ..strokeWidth = 1.8);
  }

  void _renderElevatedBattleBridge(Canvas canvas, double x1, double x2, double bridgeY) {
    final bRect = Rect.fromLTRB(x1, bridgeY, x2, bridgeY + 10);
    canvas.drawRect(bRect, Paint()..color = palette.wallShade);
    canvas.drawRect(bRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.2);
    canvas.drawLine(Offset(x1, bridgeY - 5), Offset(x2, bridgeY - 5), Paint()..color = Colors.white ..strokeWidth = 1.5);
  }

  void _renderCitadelSignalBelfry(Canvas canvas, double cx, double baseTop) {
    const bW = 24.0;
    const bH = 22.0;
    final bRect = Rect.fromLTWH(cx - bW / 2, baseTop, bW, bH);
    canvas.drawRect(bRect, Paint()..color = palette.wallColor);
    canvas.drawRect(bRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.2);

    canvas.drawCircle(Offset(cx, baseTop + 11), 5.0, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(Offset(cx, baseTop + 10), 3.0, Paint()..color = palette.accentColor);

    final rPath = Path()
      ..moveTo(cx - bW / 2 - 2, baseTop)
      ..lineTo(cx, baseTop - 14)
      ..lineTo(cx + bW / 2 + 2, baseTop)
      ..close();
    canvas.drawPath(rPath, Paint()..color = palette.roofColor);
  }

  void _renderFlyingButtresses(Canvas canvas, double cx, double groundY) {
    final bPaint = Paint()..color = palette.wallShade ..strokeWidth = 2.4 ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 160, groundY - 14), Offset(cx - 120, groundY - 70), bPaint);
    canvas.drawLine(Offset(cx + 160, groundY - 14), Offset(cx + 120, groundY - 70), bPaint);
  }

  void _renderBallistaEmplacements(Canvas canvas, double cx, double groundY) {
    final mPaint = Paint()..color = palette.accentColor;
    for (final bx in [cx - 130.0, cx + 130.0]) {
      canvas.drawCircle(Offset(bx, groundY - 30), 3.5, mPaint);
      canvas.drawLine(Offset(bx, groundY - 30), Offset(bx - 6, groundY - 38), Paint()..color = const Color(0xFF334155) ..strokeWidth = 1.8);
    }
  }

  void _renderCitadelRoyalStandard(Canvas canvas, double cx, double poleTop) {
    canvas.drawLine(Offset(cx, poleTop + 24), Offset(cx, poleTop), Paint()..color = palette.accentColor ..strokeWidth = 2.2);
    canvas.drawCircle(Offset(cx, poleTop), 2.5, Paint()..color = palette.accentColor);

    final flagPath = Path()
      ..moveTo(cx, poleTop)
      ..lineTo(cx + 24, poleTop + 7)
      ..lineTo(cx, poleTop + 14)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = palette.roofColor);
  }

  // ============================================================
  // 🏛️ 5. MONUMENTAL RAJPUT & INDO-SARACENIC IMPERIAL PALACE (DAY 90 APEX)
  // ============================================================
  void _renderImperialRajputPalace(Canvas canvas, double cx, double groundY) {
    const palaceW = 420.0;
    const floor1H = 68.0;
    const floor2H = 64.0;
    final floor1Top = groundY - floor1H;
    final floor2Top = floor1Top - floor2H;
    final palaceLeft = cx - palaceW / 2;
    final palaceRight = cx + palaceW / 2;

    // High Carved Sandstone & Terracotta Perimeter Boundary Walls ("മതിലൊക്കെ കെട്ടി!")
    _renderPalaceBoundaryWalls(canvas, cx, groundY, palaceLeft, palaceRight);

    // 1. Processional Grand Avenue / Boulevard (Directly from Image 1!)
    _renderProcessionalBoulevard(canvas, cx, groundY);

    // 2. Wide Sandstone & Terracotta Podium Base (Image 1 & 2 - Uses active palette!)
    final pRect = Rect.fromLTWH(palaceLeft, groundY - 16, palaceW, 16);
    canvas.drawRect(pRect, Paint()..color = palette.foundationColor);
    canvas.drawRect(Rect.fromLTWH(palaceLeft - 4, groundY - 16, palaceW + 8, 4), Paint()..color = palette.roofTrim);

    // 3. Ground Floor Colonnaded Arcade with Scalloped / Cusped Arches (Image 1 & 2)
    final gRect = Rect.fromLTWH(palaceLeft + 8, floor1Top, palaceW - 16, floor1H - 12);
    canvas.drawRect(gRect, Paint()..color = palette.wallColor.withValues(alpha: 0.22));

    // Continuous Ground Colonnade with Cusped Trefoil Arches across the whole facade
    const archSpacing = 28.0;
    for (double x = palaceLeft + 24; x <= palaceRight - 24; x += archSpacing) {
      if ((x - cx).abs() > 36) {
        _renderCuspedPalaceArch(canvas, x, floor1Top, archSpacing - 4, floor1H - 14);
        // Day 78+: Ornate Mughal Carved Stone Jalis (intricate latticework)
        if (day >= 78) {
          _renderMughalJaliScreen(canvas, x, floor1Top + 8, archSpacing - 8, floor1H - 24);
        }
      }
    }

    // 4. Grand Central Durbar Entrance Archway & Pavilion (Image 1 & 2)
    _renderCentralDurbarPavilion(canvas, cx, groundY, floor1Top, floor2Top);

    // 5. First Floor Arcaded Gallery & Jharokhas (Complete 2nd Floor from Day 75!)
    final f2Rect = Rect.fromLTWH(palaceLeft + 18, floor2Top, palaceW - 36, floor2H);
    canvas.drawRect(f2Rect, Paint()..color = palette.wallColor.withValues(alpha: 0.30));

    // Upper Terrace Stone Balustrade with Ornamental Rosettes
    final balY = floor1Top;
    canvas.drawLine(Offset(palaceLeft + 12, balY), Offset(palaceRight - 12, balY), Paint()..color = palette.roofTrim ..strokeWidth = 3.0);
    for (double bx = palaceLeft + 16; bx <= palaceRight - 16; bx += 8.0) {
      canvas.drawLine(Offset(bx, balY - 6), Offset(bx, balY), Paint()..color = Colors.white ..strokeWidth = 1.5);
    }

    // First Floor Windows & Cantilevered Jharokhas (Image 2)
    for (double x = palaceLeft + 36; x <= palaceRight - 36; x += archSpacing) {
      if ((x - cx).abs() > 42) {
        final isLeft = x < cx;
        final isJharokhaSlot = ((x - palaceLeft) ~/ archSpacing) % 2 == 0;
        if (isJharokhaSlot && ((isLeft && day >= 76) || (!isLeft && day >= 77))) {
          _renderJharokhaBalcony(canvas, x, floor2Top + 32, 22, 34);
        } else {
          _renderCuspedPalaceArch(canvas, x, floor2Top + 6, archSpacing - 4, floor2H - 12);
        }
      }
    }

    // 6. Rooftop Parapet, Cornice Chhajjas (Overhanging Eaves) (Image 1 & 2)
    final roofY = floor2Top;
    final chhajjaPath = Path()
      ..moveTo(palaceLeft + 10, roofY + 2)
      ..lineTo(palaceLeft + 4, roofY - 5)
      ..lineTo(palaceRight - 4, roofY - 5)
      ..lineTo(palaceRight - 10, roofY + 2)
      ..close();
    canvas.drawPath(chhajjaPath, Paint()..color = palette.roofColor);
    canvas.drawPath(chhajjaPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.8);

    // Day 80+: Rooftop Ornamental Gold Finials Balustrade
    if (day >= 80) {
      for (double fx = palaceLeft + 16; fx <= palaceRight - 16; fx += 14.0) {
        canvas.drawLine(Offset(fx, roofY - 5), Offset(fx, roofY - 11), Paint()..color = const Color(0xFFFFD700) ..strokeWidth = 1.5);
        canvas.drawCircle(Offset(fx, roofY - 11), 1.8, Paint()..color = const Color(0xFFFFD700));
      }
    }

    // Intermediate Rooftop Chhatris (Image 1 & 2):
    if (day >= 81) {
      _renderChhatriPavilion(canvas, cx - 85, floor2Top - 6, 24, 28, isOuter: false);
    }
    if (day >= 82) {
      _renderChhatriPavilion(canvas, cx + 85, floor2Top - 6, 24, 28, isOuter: false);
    }
    if (day >= 85) {
      _renderChhatriPavilion(canvas, cx - 130, floor2Top - 6, 24, 28, isOuter: false);
      _renderChhatriPavilion(canvas, cx + 130, floor2Top - 6, 24, 28, isOuter: false);
    }

    // 7. Outer Left & Right Corner Bastion Towers with Grand Chhatris (Image 1 & 2):
    if (day >= 83) {
      _renderCornerChhatriTower(canvas, palaceLeft + 24, groundY, isLeft: true);
    }
    if (day >= 84) {
      _renderCornerChhatriTower(canvas, palaceRight - 24, groundY, isLeft: false);
    }

    // 8. Day 87+: Central Grand Royal Fluted Chhatri Onion Dome (Image 1 & 2)
    if (day >= 87) {
      _renderApexPalaceGrandDome(canvas, cx, floor2Top - 28);
    }

    // 9. Forecourt Features (Steps, Fountains, Lions, Flags, Elephants)
    _renderImperialSteps(canvas, cx, groundY);

    // Day 79+: Grand Royal Plinth Elephant Statues
    if (day >= 79) {
      _renderRoyalElephantStatue(canvas, cx - 64, groundY - 12, isLeft: true);
      _renderRoyalElephantStatue(canvas, cx + 64, groundY - 12, isLeft: false);
    }

    if (day >= 88) {
      _renderGuardianLionPedestal(canvas, cx - 52, groundY - 14);
      _renderGuardianLionPedestal(canvas, cx + 52, groundY - 14);
      _renderCourtyardFountain(canvas, cx - 148, groundY - 6);
      _renderCourtyardFountain(canvas, cx + 148, groundY - 6);
    }

    if (day >= 89) {
      _renderDay90PalaceBanner(canvas, cx, groundY);
    }

    // Day 90 Apex: 24K Royal Sovereign Eagle Crown with radiant sunburst corona!
    if (day >= 90) {
      _renderDay90DomeCrown(canvas, cx, groundY);
    }
  }

  void _renderMughalJaliScreen(Canvas canvas, double cx, double topY, double w, double h) {
    final jaliPaint = Paint()
      ..color = palette.accentColor.withValues(alpha: 0.65)
      ..strokeWidth = 0.8;
    final halfW = w / 2;
    for (double dy = 0; dy <= h; dy += 5.0) {
      canvas.drawLine(Offset(cx - halfW, topY + dy), Offset(cx + halfW, topY + dy + 4.0), jaliPaint);
      canvas.drawLine(Offset(cx - halfW, topY + dy + 4.0), Offset(cx + halfW, topY + dy), jaliPaint);
    }
  }

  void _renderRoyalElephantStatue(Canvas canvas, double ex, double ey, {required bool isLeft}) {
    // Carved Marble Elephant Plinth
    final plinthRect = Rect.fromCenter(center: Offset(ex, ey + 4), width: 22, height: 6);
    canvas.drawRRect(RRect.fromRectAndRadius(plinthRect, const Radius.circular(2)), Paint()..color = palette.foundationColor);
    canvas.drawRRect(RRect.fromRectAndRadius(plinthRect, const Radius.circular(2)), Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.0);

    // Elephant Body (Rounded torso)
    final bodyRect = Rect.fromCenter(center: Offset(ex, ey - 4), width: 16, height: 12);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)), Paint()..color = Colors.white70);

    // Elephant Head & Raised Trunk
    final hx = isLeft ? ex + 7 : ex - 7;
    canvas.drawCircle(Offset(hx, ey - 8), 4.5, Paint()..color = Colors.white70);

    final trunkPath = Path()
      ..moveTo(hx, ey - 8)
      ..quadraticBezierTo(isLeft ? hx + 5 : hx - 5, ey - 14, isLeft ? hx + 3 : hx - 3, ey - 16);
    canvas.drawPath(trunkPath, Paint()..style = PaintingStyle.stroke ..color = Colors.white70 ..strokeWidth = 2.0);

    // Decorative Golden Howdah Saddle Cloth
    final saddleRect = Rect.fromCenter(center: Offset(ex, ey - 6), width: 8, height: 6);
    canvas.drawRect(saddleRect, Paint()..color = palette.accentColor);
    canvas.drawRect(saddleRect, Paint()..style = PaintingStyle.stroke ..color = const Color(0xFFFFD700) ..strokeWidth = 0.8);
  }

  void _renderPalaceBoundaryWalls(Canvas canvas, double cx, double groundY, double palaceLeft, double palaceRight) {
    const wallH = 42.0;
    final wallTop = groundY - wallH;

    // Left Boundary Wall
    final leftWallRect = Rect.fromLTWH(palaceLeft - 70, wallTop, 74, wallH - 12);
    canvas.drawRect(leftWallRect, Paint()..color = palette.wallColor.withValues(alpha: 0.35));
    canvas.drawRect(leftWallRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.4);

    // Right Boundary Wall
    final rightWallRect = Rect.fromLTWH(palaceRight - 4, wallTop, 74, wallH - 12);
    canvas.drawRect(rightWallRect, Paint()..color = palette.wallColor.withValues(alpha: 0.35));
    canvas.drawRect(rightWallRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.4);

    // Decorative cusped arches along the perimeter walls
    for (double x = palaceLeft - 60; x <= palaceLeft - 16; x += 18.0) {
      _renderCuspedPalaceArch(canvas, x, wallTop + 6, 12, wallH - 22);
    }
    for (double x = palaceRight + 12; x <= palaceRight + 56; x += 18.0) {
      _renderCuspedPalaceArch(canvas, x, wallTop + 6, 12, wallH - 22);
    }

    // Outer boundary wall Chhatri kiosks at the far ends
    _renderChhatriPavilion(canvas, palaceLeft - 66, wallTop, 20, 24, isOuter: true);
    _renderChhatriPavilion(canvas, palaceRight + 66, wallTop, 20, 24, isOuter: true);
  }

  void _renderProcessionalBoulevard(Canvas canvas, double cx, double groundY) {
    // Broad paved ceremonial boulevard extending into the foreground (Image 1!)
    final pPath = Path()
      ..moveTo(cx - 36, groundY - 6)
      ..lineTo(cx - 96, groundY + 34)
      ..lineTo(cx + 96, groundY + 34)
      ..lineTo(cx + 36, groundY - 6)
      ..close();
    canvas.drawPath(pPath, Paint()..color = palette.wallColor.withValues(alpha: 0.28));

    // Theme borders
    canvas.drawLine(Offset(cx - 36, groundY - 6), Offset(cx - 96, groundY + 34), Paint()..color = palette.roofColor ..strokeWidth = 3.5);
    canvas.drawLine(Offset(cx + 36, groundY - 6), Offset(cx + 96, groundY + 34), Paint()..color = palette.roofColor ..strokeWidth = 3.5);

    // Central ceremonial runner
    canvas.drawLine(Offset(cx, groundY - 6), Offset(cx, groundY + 34), Paint()..color = palette.accentColor ..strokeWidth = 2.0);

    // Flanking stone flower urns along boulevard (Image 1)
    for (int i = 0; i < 3; i++) {
      final t = (i + 1) / 3.0;
      final ly = groundY - 6 + 40.0 * t;
      final lx = cx - 36 - 60.0 * t;
      final rx = cx + 36 + 60.0 * t;
      _renderClassicalUrn(canvas, lx, ly);
      _renderClassicalUrn(canvas, rx, ly);
    }
  }

  void _renderCuspedPalaceArch(Canvas canvas, double cx, double topY, double w, double h) {
    // Cusped / trefoil scalloped archway (Image 1 & 2)
    final aRect = Rect.fromLTWH(cx - w / 2, topY, w, h);
    canvas.drawRect(aRect, Paint()..color = lightsOn ? palette.windowColor.withValues(alpha: 0.40) : const Color(0xFF1E293B));

    // Slender marble/trim pillars
    final pPaint = Paint()..color = palette.roofTrim ..strokeWidth = 2.0;
    canvas.drawLine(Offset(aRect.left, aRect.top + 10), Offset(aRect.left, aRect.bottom), pPaint);
    canvas.drawLine(Offset(aRect.right, aRect.top + 10), Offset(aRect.right, aRect.bottom), pPaint);

    // Scalloped trefoil arch curve
    final aPath = Path()
      ..moveTo(aRect.left, aRect.top + 10)
      ..cubicTo(aRect.left, aRect.top + 4, cx - 4, aRect.top + 4, cx, aRect.top)
      ..cubicTo(cx + 4, aRect.top + 4, aRect.right, aRect.top + 4, aRect.right, aRect.top + 10);
    canvas.drawPath(aPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 2.0);
  }

  void _renderCentralDurbarPavilion(Canvas canvas, double cx, double groundY, double floor1Top, double floor2Top) {
    const pavilionW = 76.0;
    final pavilionLeft = cx - pavilionW / 2;
    final pavilionTop = (day >= 85) ? floor2Top - 42 : floor2Top - 24;

    // Multi-tier Durbar Gateway Wall
    final dRect = Rect.fromLTWH(pavilionLeft, pavilionTop, pavilionW, groundY - pavilionTop - 14);
    canvas.drawRect(dRect, Paint()..color = palette.wallColor);
    canvas.drawRect(dRect, Paint()..style = PaintingStyle.stroke ..color = palette.accentColor ..strokeWidth = 2.0);

    // Monumental Central Cusped Arch Gateway (Image 2)
    const archW = 34.0;
    const archH = 50.0;
    final archRect = Rect.fromCenter(center: Offset(cx, groundY - archH / 2 - 14), width: archW, height: archH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(archRect, const Radius.circular(16)),
      Paint()..color = palette.doorColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(archRect, const Radius.circular(16)),
      Paint()..style = PaintingStyle.stroke ..color = palette.accentColor ..strokeWidth = 2.0,
    );

    // Upper Royal Viewing Balcony (Baradari open gallery with pillars)
    final vRect = Rect.fromCenter(center: Offset(cx, floor1Top - 6), width: 44, height: 26);
    canvas.drawRect(vRect, Paint()..color = (lightsOn ? palette.windowColor : Colors.white).withValues(alpha: 0.85));
    canvas.drawRect(vRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.8);
    for (double x = vRect.left + 8; x <= vRect.right - 8; x += 9.0) {
      canvas.drawLine(Offset(x, vRect.top), Offset(x, vRect.bottom), Paint()..color = palette.roofTrim ..strokeWidth = 1.4);
    }

    // Day 85+: Grand Central Royal Durbar Upper Pavilion (Image 2)
    if (day >= 85) {
      const uW = 54.0;
      const uH = 22.0;
      final uRect = Rect.fromLTWH(cx - uW / 2, pavilionTop + 2, uW, uH);
      canvas.drawRect(uRect, Paint()..color = palette.wallShade);
      canvas.drawRect(uRect, Paint()..style = PaintingStyle.stroke ..color = palette.accentColor ..strokeWidth = 1.5);

      // Triple miniature cusped archways with golden jaali screen
      for (int a = -1; a <= 1; a++) {
        final ax = cx + a * 15.0;
        final aPath = Path()
          ..moveTo(ax - 5, uRect.bottom)
          ..lineTo(ax - 5, uRect.top + 6)
          ..quadraticBezierTo(ax, uRect.top + 1, ax + 5, uRect.top + 6)
          ..lineTo(ax + 5, uRect.bottom);
        canvas.drawPath(aPath, Paint()..color = lightsOn ? palette.windowColor : const Color(0xFF1E293B));
        canvas.drawPath(aPath, Paint()..style = PaintingStyle.stroke ..color = palette.accentColor ..strokeWidth = 1.2);
      }
    }
  }

  void _renderJharokhaBalcony(Canvas canvas, double cx, double cy, double w, double h) {
    // Rajasthani Cantilevered Jharokha Balcony (Image 2)
    final jRect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);

    // Corbel bracket beneath balcony
    final bPath = Path()
      ..moveTo(cx - w / 2, jRect.bottom)
      ..lineTo(cx, jRect.bottom + 8)
      ..lineTo(cx + w / 2, jRect.bottom)
      ..close();
    canvas.drawPath(bPath, Paint()..color = palette.roofShade);

    // Balcony Box with Lattice Jaali screen
    canvas.drawRect(jRect, Paint()..color = palette.wallShade);
    canvas.drawRect(jRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.2);

    // Arched stained glass opening glowing inside
    final winRect = Rect.fromCenter(center: Offset(cx, cy - 2), width: w - 8, height: h - 10);
    canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(4)), Paint()..color = lightsOn ? palette.windowColor : const Color(0xFF1E293B));
    canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(4)), Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.0);

    // Domed hood atop Jharokha
    final hoodPath = Path()
      ..moveTo(cx - w / 2 - 2, jRect.top)
      ..quadraticBezierTo(cx, jRect.top - 8, cx + w / 2 + 2, jRect.top)
      ..close();
    canvas.drawPath(hoodPath, Paint()..color = palette.roofColor);
    canvas.drawPath(hoodPath, Paint()..style = PaintingStyle.stroke ..color = palette.accentColor ..strokeWidth = 1.2);
  }

  void _renderChhatriPavilion(Canvas canvas, double cx, double baseTop, double w, double h, {required bool isOuter}) {
    // 4-Pillar Open Chhatri Kiosk (Image 1 & 2)
    const pillarH = 14.0;
    final pillarTop = baseTop - pillarH;
    final pPaint = Paint()..color = palette.roofTrim ..strokeWidth = 1.5;

    // Slender pillars
    canvas.drawLine(Offset(cx - w / 2 + 3, baseTop), Offset(cx - w / 2 + 3, pillarTop), pPaint);
    canvas.drawLine(Offset(cx + w / 2 - 3, baseTop), Offset(cx + w / 2 - 3, pillarTop), pPaint);
    canvas.drawLine(Offset(cx - 3, baseTop), Offset(cx - 3, pillarTop), pPaint);
    canvas.drawLine(Offset(cx + 3, baseTop), Offset(cx + 3, pillarTop), pPaint);

    // Curved Rajput Dome Cupola
    final domeH = h - pillarH;
    final domeTop = pillarTop - domeH;
    final dPath = Path()
      ..moveTo(cx - w / 2 - 2, pillarTop)
      ..cubicTo(cx - w / 2, domeTop + 4, cx - 4, domeTop + 2, cx, domeTop)
      ..cubicTo(cx + 4, domeTop + 2, cx + w / 2, domeTop + 4, cx + w / 2 + 2, pillarTop)
      ..close();
    canvas.drawPath(dPath, Paint()..color = palette.roofColor);
    canvas.drawPath(dPath, Paint()..style = PaintingStyle.stroke ..color = palette.accentColor ..strokeWidth = 1.2);

    // Golden Kalasa Finial
    canvas.drawLine(Offset(cx, domeTop), Offset(cx, domeTop - 6), Paint()..color = palette.accentColor ..strokeWidth = 1.8);
    canvas.drawCircle(Offset(cx, domeTop - 6), 1.8, Paint()..color = palette.accentColor);
  }

  void _renderCornerChhatriTower(Canvas canvas, double cx, double groundY, {required bool isLeft}) {
    const towerW = 34.0;
    const towerH = 148.0;
    final towerTop = groundY - towerH;
    final tRect = Rect.fromLTWH(cx - towerW / 2, towerTop, towerW, towerH - 14);

    // 3-Storey Rajput Bastion Tower (Image 1 & 2)
    canvas.drawRect(tRect, Paint()..color = palette.wallColor);
    canvas.drawRect(tRect, Paint()..style = PaintingStyle.stroke ..color = palette.accentColor ..strokeWidth = 1.5);

    // Arched windows on tower levels
    for (int lvl = 0; lvl < 3; lvl++) {
      final wy = towerTop + 24 + lvl * 40.0;
      _renderVictorianSashWindow(canvas, cx, wy, 12, 18);
    }

    // Crowning Grand 4-Pillar Chhatri (Image 1 & 2)
    _renderChhatriPavilion(canvas, cx, towerTop, 36, 32, isOuter: true);

    // Royal Silk Flag
    final flagColor = isLeft ? palette.accentColor : palette.doorColor;
    final flagPath = Path()
      ..moveTo(cx, towerTop - 36)
      ..lineTo(isLeft ? cx - 18 : cx + 18, towerTop - 30)
      ..lineTo(cx, towerTop - 24)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = flagColor);
  }

  void _renderApexPalaceGrandDome(Canvas canvas, double cx, double baseTop) {
    // Grand Central Fluted Golden Chhatri Dome (Image 1 & 2)
    const domeW = 68.0;
    const domeH = 48.0;
    final domeTop = baseTop - domeH;

    // Lotus petal drum base
    final drumRect = Rect.fromCenter(center: Offset(cx, baseTop + 4), width: domeW - 8, height: 10);
    canvas.drawRRect(RRect.fromRectAndRadius(drumRect, const Radius.circular(3)), Paint()..color = palette.roofTrim);
    canvas.drawRRect(RRect.fromRectAndRadius(drumRect, const Radius.circular(3)), Paint()..style = PaintingStyle.stroke ..color = palette.accentColor ..strokeWidth = 1.5);

    // Fluted Golden Dome
    final dPath = Path()
      ..moveTo(cx - domeW / 2, baseTop)
      ..cubicTo(cx - domeW / 2 + 4, domeTop + 6, cx - 14, domeTop + 2, cx, domeTop)
      ..cubicTo(cx + 14, domeTop + 2, cx + domeW / 2 - 4, domeTop + 6, cx + domeW / 2, baseTop)
      ..close();
    canvas.drawPath(dPath, Paint()..color = palette.roofColor);
    canvas.drawPath(dPath, Paint()..style = PaintingStyle.stroke ..color = palette.accentColor ..strokeWidth = 2.0);

    // Vertical Golden Fluting Ribs
    final rib = Paint()..color = palette.accentColor ..strokeWidth = 1.4 ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, domeTop), Offset(cx, baseTop), rib);
    canvas.drawLine(Offset(cx - 16, baseTop), Offset(cx - 6, domeTop + 14), rib);
    canvas.drawLine(Offset(cx + 16, baseTop), Offset(cx + 6, domeTop + 14), rib);

    // Ornate Golden Kalasa Finial Spire
    canvas.drawLine(Offset(cx, domeTop), Offset(cx, domeTop - 22), Paint()..color = palette.accentColor ..strokeWidth = 2.4);
    canvas.drawCircle(Offset(cx, domeTop - 22), 3.5, Paint()..color = palette.accentColor);
    canvas.drawCircle(Offset(cx, domeTop - 12), 2.2, Paint()..color = palette.accentColor);
  }

  void _renderDay5StoneWalkway(Canvas canvas, double cx, double groundY) {
    final stonePaint = Paint()..color = const Color(0xFF94A3B8);
    final border = Paint()..color = const Color(0xFF64748B) ..style = PaintingStyle.stroke ..strokeWidth = 0.8;
    for (int i = 0; i < 4; i++) {
      final sy = groundY - 10 + i * 5.0;
      final sw = 14.0 + (i % 2) * 4.0;
      final rect = Rect.fromCenter(center: Offset(cx, sy), width: sw, height: 4.0);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), stonePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), border);
    }
  }

  void _renderWindowFlowerBox(Canvas canvas, double cx, double cy, double width) {
    final boxRect = Rect.fromCenter(center: Offset(cx, cy), width: width, height: 6.0);
    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(2)), Paint()..color = const Color(0xFF78350F));
    final colors = [const Color(0xFFE11D48), const Color(0xFFF43F5E), const Color(0xFFFB7185), const Color(0xFF22C55E)];
    for (int i = 0; i < 5; i++) {
      final fx = boxRect.left + 4 + i * ((width - 8) / 4);
      final col = colors[i % colors.length];
      canvas.drawCircle(Offset(fx, cy - 2.5), 2.2, Paint()..color = col);
    }
  }


  // ============================================================
  // 🏡 2. TWO-STORY CHATEAU & PROGRESSIVE VILLA (DAYS 16–27)
  // ============================================================
  void _renderDay16to27VictorianRising(Canvas canvas, double cx, double groundY) {
    const estateWidth = 270.0;
    const floor1Height = 66.0;
    const floor2Height = 64.0;
    final floor1Top = groundY - floor1Height;
    final floor2Top = floor1Top - floor2Height;

    // Foundation Base
    final fRect = Rect.fromLTWH(cx - estateWidth / 2, groundY - 14, estateWidth, 14);
    canvas.drawRect(fRect, Paint()..color = palette.foundationColor);
    final fBorder = Paint()..color = Colors.black26 ..strokeWidth = 1.0;
    for (double x = cx - estateWidth / 2 + 18; x < cx + estateWidth / 2; x += 18) {
      canvas.drawLine(Offset(x, groundY - 14), Offset(x, groundY), fBorder);
    }

    // Ground Floor Wall
    final gRect = Rect.fromLTWH(cx - estateWidth / 2 + 8, floor1Top, estateWidth - 16, floor1Height);
    canvas.drawRect(gRect, Paint()..color = palette.wallColor);

    // Ground Floor Symmetrical Windows & Door
    _renderVictorianSashWindow(canvas, cx - 80, floor1Top + 32, 20, 34);
    _renderVictorianSashWindow(canvas, cx + 80, floor1Top + 32, 20, 34);

    if (day >= 25) {
      _renderColonnadedPorch(canvas, cx, groundY, estateWidth, floor1Height);
    } else {
      _renderCottageFrontDoor(canvas, cx, groundY);
      _renderDay2FrontPorchAwning(canvas, cx, groundY);
    }

    // Second Floor Center (Day 16+)
    const centerW = 88.0;
    final cRect = Rect.fromLTWH(cx - centerW / 2, floor2Top, centerW, floor2Height);
    canvas.drawRect(cRect, Paint()..color = palette.wallColor);
    canvas.drawRect(cRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5);

    // French Doors & Juliet Balcony
    final fDoor = Rect.fromCenter(center: Offset(cx, floor2Top + 30), width: 26, height: 38);
    canvas.drawRRect(RRect.fromRectAndRadius(fDoor, const Radius.circular(2)), Paint()..color = lightsOn ? palette.windowColor : const Color(0xFF1E293B));
    canvas.drawRRect(RRect.fromRectAndRadius(fDoor, const Radius.circular(2)), Paint()..style = PaintingStyle.stroke ..color = Colors.white ..strokeWidth = 1.8);
    final bRail = Rect.fromCenter(center: Offset(cx, floor1Top - 5), width: 44, height: 10);
    canvas.drawRRect(RRect.fromRectAndRadius(bRail, const Radius.circular(2)), Paint()..color = Colors.white);
    for (double bx = cx - 18; bx <= cx + 18; bx += 6) {
      canvas.drawLine(Offset(bx, bRail.top), Offset(bx, bRail.bottom), Paint()..color = const Color(0xFF94A3B8) ..strokeWidth = 1.2);
    }

    // Second Floor West Wing Bedchamber (Always complete Day 16+)
    final wRect = Rect.fromLTWH(cx - estateWidth / 2 + 10, floor2Top + 6, (estateWidth - centerW) / 2 - 14, floor2Height - 6);
    canvas.drawRect(wRect, Paint()..color = palette.wallShade);
    _renderVictorianSashWindow(canvas, wRect.center.dx, floor2Top + 34, 20, 32);

    // Second Floor East Wing Study (Always complete Day 16+)
    final eRect = Rect.fromLTWH(cx + centerW / 2 + 4, floor2Top + 6, (estateWidth - centerW) / 2 - 14, floor2Height - 6);
    canvas.drawRect(eRect, Paint()..color = palette.wallShade);
    _renderVictorianSashWindow(canvas, eRect.center.dx, floor2Top + 34, 20, 32);

    // Mansard Roofs on Wings (Always complete Day 16+)
    _renderVictorianMansardRoof(canvas, cx - 80, floor2Top, 100, isLeft: true);
    _renderVictorianMansardRoof(canvas, cx + 80, floor2Top, 100, isLeft: false);

    // Twin Brick Chimneys with rising smoke (Always complete Day 16+)
    _renderChimneyShaft(canvas, cx - 96, floor2Top - 24, 14, 26);
    _renderChimneyShaft(canvas, cx + 96, floor2Top - 24, 14, 26);

    // Day 17+: Front Terrace Stone Balustrade & Urns
    if (day >= 17) {
      final bTop = floor1Top - 6;
      canvas.drawLine(Offset(cx - estateWidth / 2 + 12, bTop), Offset(cx + estateWidth / 2 - 12, bTop), Paint()..color = Colors.white ..strokeWidth = 2.0);
      _renderClassicalUrn(canvas, cx - estateWidth / 2 + 16, bTop - 4);
      _renderClassicalUrn(canvas, cx + estateWidth / 2 - 16, bTop - 4);
    }

    // Day 18+: Twin Blooming Trees Flanking Villa
    if (day >= 18) {
      _renderDay8AppleTree(canvas, cx - 110, groundY);
      _renderDay8AppleTree(canvas, cx + 110, groundY);
    }

    // Day 19+: Cobblestone Promenade & Flower Beds
    if (day >= 19) {
      _renderDay5StoneWalkway(canvas, cx, groundY);
      _renderDay3GardenFlowerBeds(canvas, cx, groundY);
    }

    // Day 20+: Symmetrical Roof Dormers
    if (day >= 20) {
      _renderVictorianArchedDormer(canvas, cx - 80, floor2Top - 18, 20, 26);
      _renderVictorianArchedDormer(canvas, cx + 80, floor2Top - 18, 20, 26);
    }

    // Day 21+: Fluted Veranda Columns & Coach Lamps
    if (day >= 21) {
      _renderDay21PorchPillars(canvas, cx, groundY);
    }

    // Day 22+: Garden Gazebo / Tea Pavilion on the Lawn (Fixes "just a line"!)
    if (day >= 22) {
      _renderGardenGazebo(canvas, cx - 96, groundY);
    }

    // Day 23+: Stone Courtyard Fountain with Sparkling Water Ripples (Fixes "chumma 2 saadhanam"!)
    if (day >= 23) {
      _renderCourtyardFountain(canvas, cx + 96, groundY - 6);
    }

    // Day 24+: Topiary Shrubs
    if (day >= 24) {
      _renderVictorianParterreGarden(canvas, cx, groundY);
    }

    // Center gabled roof cap
    final rPath = Path();
    rPath.moveTo(cx - centerW / 2 - 6, floor2Top + 2);
    rPath.lineTo(cx, floor2Top - 38);
    rPath.lineTo(cx + centerW / 2 + 6, floor2Top + 2);
    rPath.close();
    canvas.drawPath(rPath, Paint()..color = palette.roofColor);
    canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 3.0);

    // Day 26+: Rooftop Golden Eagle Weathervane & Carved Pediment Crest
    if (day >= 26) {
      _renderDay10Weathervane(canvas, cx, floor2Top - 38);
      canvas.drawCircle(Offset(cx, floor2Top - 18), 4.5, Paint()..color = palette.accentColor);
    }

    // Day 27+: Grand Arched Stone Perimeter Gateway with Carriage Lanterns (Fixes "bottom pillar"!)
    if (day >= 27) {
      _renderDay27PerimeterGateway(canvas, cx, groundY);
    }

    // Garden & courtyard features
    _renderDay6PicketFence(canvas, cx, groundY);
    _renderDay7StreetLamps(canvas, cx, groundY);
  }

  void _renderDay21PorchPillars(Canvas canvas, double cx, double groundY) {
    for (final px in [cx - 24.0, cx + 24.0]) {
      final pRect = Rect.fromLTWH(px - 3, groundY - 50, 6, 36);
      canvas.drawRect(pRect, Paint()..color = Colors.white);
      canvas.drawRect(pRect, Paint()..style = PaintingStyle.stroke ..color = const Color(0xFFCBD5E1) ..strokeWidth = 1.0);
      canvas.drawCircle(Offset(px, groundY - 42), 2.5, Paint()..color = lightsOn ? Colors.amber : Colors.white70);
    }
  }

  void _renderGardenGazebo(Canvas canvas, double gx, double groundY) {
    const gW = 38.0;
    const gH = 44.0;
    final gTop = groundY - gH - 12;
    // Raised wooden deck base
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(gx - gW / 2 - 2, groundY - 14, gW + 4, 6), const Radius.circular(2)), Paint()..color = const Color(0xFF78350F));
    // Slender wooden posts
    final postPaint = Paint()..color = Colors.white ..strokeWidth = 2.0;
    canvas.drawLine(Offset(gx - gW / 2 + 3, groundY - 14), Offset(gx - gW / 2 + 3, gTop + 10), postPaint);
    canvas.drawLine(Offset(gx + gW / 2 - 3, groundY - 14), Offset(gx + gW / 2 - 3, gTop + 10), postPaint);
    canvas.drawLine(Offset(gx - 5, groundY - 14), Offset(gx - 5, gTop + 10), postPaint);
    canvas.drawLine(Offset(gx + 5, groundY - 14), Offset(gx + 5, gTop + 10), postPaint);
    // Railing
    canvas.drawLine(Offset(gx - gW / 2 + 3, groundY - 22), Offset(gx + gW / 2 - 3, groundY - 22), Paint()..color = Colors.white70 ..strokeWidth = 1.2);
    // Bell-cast curved pagoda/gazebo roof
    final rPath = Path()
      ..moveTo(gx - gW / 2 - 4, gTop + 10)
      ..quadraticBezierTo(gx, gTop + 2, gx, gTop - 4)
      ..quadraticBezierTo(gx, gTop + 2, gx + gW / 2 + 4, gTop + 10)
      ..close();
    canvas.drawPath(rPath, Paint()..color = palette.roofColor);
    canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.5);
    // Hanging glowing lantern
    canvas.drawLine(Offset(gx, gTop + 6), Offset(gx, gTop + 14), Paint()..color = palette.accentColor ..strokeWidth = 1.0);
    canvas.drawCircle(Offset(gx, gTop + 16), 3.0, Paint()..color = lightsOn ? Colors.amberAccent : Colors.white70);
  }

  void _renderDay27PerimeterGateway(Canvas canvas, double cx, double groundY) {
    const gateW = 260.0;
    final leftX = cx - gateW / 2;
    final rightX = cx + gateW / 2;
    // Wrought iron low perimeter fence
    final fPaint = Paint()..color = const Color(0xFF334155) ..strokeWidth = 1.4;
    canvas.drawLine(Offset(leftX, groundY - 22), Offset(cx - 36, groundY - 22), fPaint);
    canvas.drawLine(Offset(cx + 36, groundY - 22), Offset(rightX, groundY - 22), fPaint);
    for (double x = leftX + 4; x <= cx - 38; x += 8) {
      canvas.drawLine(Offset(x, groundY - 26), Offset(x, groundY - 14), fPaint);
    }
    for (double x = cx + 38; x <= rightX - 4; x += 8) {
      canvas.drawLine(Offset(x, groundY - 26), Offset(x, groundY - 14), fPaint);
    }
    // Twin Ashlar Stone Entrance Gate Pillars
    for (final px in [cx - 36.0, cx + 36.0]) {
      final pRect = Rect.fromLTWH(px - 5, groundY - 42, 10, 28);
      canvas.drawRect(pRect, Paint()..color = palette.wallColor);
      canvas.drawRect(pRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.0);
      canvas.drawRect(Rect.fromLTWH(px - 7, groundY - 44, 14, 3), Paint()..color = Colors.white);
      // Ornate coach lantern
      canvas.drawCircle(Offset(px, groundY - 48), 2.8, Paint()..color = lightsOn ? Colors.amberAccent : Colors.white60);
      canvas.drawCircle(Offset(px, groundY - 52), 1.8, Paint()..color = palette.accentColor);
    }
  }

  // ============================================================
  // 🏰 3. THE BELOVED GRAND VICTORIAN MANOR (DAYS 28–90)
  // ============================================================
  void _renderGrandVictorianManor(Canvas canvas, double cx, double groundY) {
    final estateWidth = (day >= 85) ? 346.0 : 320.0;
    final wingWidth = (day >= 85) ? 122.0 : 110.0;
    const floor1Height = 66.0;
    const floor2Height = 68.0;

    final baseLeft = cx - estateWidth / 2;
    final baseRight = cx + estateWidth / 2;
    final floor1Top = groundY - floor1Height;
    final floor2Top = floor1Top - floor2Height;

    // --- Ashlar Stone Foundation Base ---
    final fRect = Rect.fromLTWH(baseLeft, groundY - 14, estateWidth, 14);
    canvas.drawRect(fRect, Paint()..color = palette.foundationColor);
    final fBorder = Paint()..color = Colors.black26 ..strokeWidth = 1.2;
    for (double x = baseLeft + 20; x < baseRight; x += 20) {
      canvas.drawLine(Offset(x, groundY - 14), Offset(x, groundY), fBorder);
    }

    // --- Main Facade Wall (Ground & Second Floor) ---
    final facadeRect = Rect.fromLTWH(baseLeft + 10, floor2Top, estateWidth - 20, floor1Height + floor2Height - 14);
    canvas.drawRect(facadeRect, Paint()..color = palette.wallColor);

    // Ashlar quoins on left and right outer corners
    final quoinPaint = Paint()..color = palette.wallShade;
    for (double y = floor2Top; y < groundY - 14; y += 12) {
      canvas.drawRect(Rect.fromLTWH(baseLeft + 10, y, 10, 10), quoinPaint);
      canvas.drawRect(Rect.fromLTWH(baseRight - 20, y, 10, 10), quoinPaint);
    }

    // --- Second Floor Sash Windows (Symmetrical Grand Estate Rows - Always present Day 28+) ---
    final wingWinOffset = (day >= 85) ? 12.0 : 0.0;
    // Left Wing Windows (3 pairs)
    _renderVictorianSashWindow(canvas, cx - 124 - wingWinOffset, floor2Top + 32, 22, 38);
    _renderVictorianSashWindow(canvas, cx - 90 - wingWinOffset * 0.5, floor2Top + 32, 22, 38);
    _renderVictorianSashWindow(canvas, cx - 56, floor2Top + 32, 22, 38);

    // Center Tower Windows (Double Sash)
    _renderVictorianSashWindow(canvas, cx - 15, floor2Top + 32, 20, 38);
    _renderVictorianSashWindow(canvas, cx + 15, floor2Top + 32, 20, 38);

    // Right Wing Windows (3 pairs)
    _renderVictorianSashWindow(canvas, cx + 56, floor2Top + 32, 22, 38);
    _renderVictorianSashWindow(canvas, cx + 90 + wingWinOffset * 0.5, floor2Top + 32, 22, 38);
    _renderVictorianSashWindow(canvas, cx + 124 + wingWinOffset, floor2Top + 32, 22, 38);

    // --- Left & Right Mansard Roofs (Always present Day 28+) ---
    _renderVictorianMansardRoof(canvas, cx - 92 - wingWinOffset * 0.5, floor2Top, wingWidth + 16, isLeft: true);
    _renderVictorianMansardRoof(canvas, cx + 92 + wingWinOffset * 0.5, floor2Top, wingWidth + 16, isLeft: false);

    // Left & Right Dormers - Day 32+
    if (day >= 32) {
      _renderVictorianArchedDormer(canvas, cx - 122 - wingWinOffset, floor2Top - 18, 20, 26);
      _renderVictorianArchedDormer(canvas, cx - 68, floor2Top - 18, 20, 26);
      _renderVictorianArchedDormer(canvas, cx + 68, floor2Top - 18, 20, 26);
      _renderVictorianArchedDormer(canvas, cx + 122 + wingWinOffset, floor2Top - 18, 20, 26);
    }

    // --- Classical Colonnaded Portico Veranda (Ground Floor) ---
    _renderColonnadedPorch(canvas, cx, groundY, estateWidth, floor1Height);

    // Twin Brick Chimneys on Outer Wings (Always present Day 28+)
    _renderChimneyShaft(canvas, cx - 146 - wingWinOffset, floor2Top - 28, 16, 32);
    _renderChimneyShaft(canvas, cx + 146 + wingWinOffset, floor2Top - 28, 16, 32);
  }

  void _renderChimneyShaft(Canvas canvas, double cx, double topY, double w, double h) {
    final rect = Rect.fromLTWH(cx - w / 2, topY, w, h);
    canvas.drawRect(rect, Paint()..color = palette.roofShade);
    // Corbelled stepped crown cap
    canvas.drawRect(Rect.fromLTWH(cx - w / 2 - 2.5, topY - 4, w + 5, 5), Paint()..color = palette.roofTrim);
    // Brick lines
    final p = Paint()..color = palette.roofUnderTrim ..strokeWidth = 1.0;
    canvas.drawLine(Offset(rect.left, topY + 12), Offset(rect.right, topY + 12), p);
    canvas.drawLine(Offset(rect.left, topY + 24), Offset(rect.right, topY + 24), p);
  }

  void _renderVictorianMansardRoof(Canvas canvas, double cx, double floor2Top, double width, {required bool isLeft}) {
    const roofH = 38.0;
    final roofTop = floor2Top - roofH;
    final rPath = Path();

    if (isLeft) {
      rPath.moveTo(cx - width / 2 - 8, floor2Top + 2);
      rPath.lineTo(cx - width / 2 + 12, roofTop);
      rPath.lineTo(cx + width / 2, roofTop);
      rPath.lineTo(cx + width / 2, floor2Top + 2);
    } else {
      rPath.moveTo(cx - width / 2, floor2Top + 2);
      rPath.lineTo(cx - width / 2, roofTop);
      rPath.lineTo(cx + width / 2 - 12, roofTop);
      rPath.lineTo(cx + width / 2 + 8, floor2Top + 2);
    }
    rPath.close();

    canvas.drawPath(rPath, Paint()..color = palette.roofColor);
    canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 3.0);
  }

  void _renderCentralChateauTower(Canvas canvas, double cx, double floor2Top, double centerW) {
    const towerH = 46.0;
    final towerTop = floor2Top - towerH;
    final towerLeft = cx - centerW / 2;

    // 3rd floor center tower wall
    canvas.drawRect(Rect.fromLTWH(towerLeft, towerTop, centerW, towerH), Paint()..color = palette.wallColor);
    canvas.drawRect(
      Rect.fromLTWH(towerLeft, towerTop, centerW, towerH),
      Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5,
    );

    // Ornate Center Dormer with Romanesque Arch
    _renderVictorianArchedDormer(canvas, cx, towerTop + 20, 24, 32);

    // Steep High-Peaked Chateau Roof
    const roofPeakHeight = 56.0;
    final roofPeakY = towerTop - roofPeakHeight;
    final rPath = Path();
    rPath.moveTo(towerLeft - 6, towerTop + 2);
    rPath.lineTo(cx, roofPeakY);
    rPath.lineTo(towerLeft + centerW + 6, towerTop + 2);
    rPath.close();

    final rShader = LinearGradient(
      colors: [palette.roofColor, palette.roofShade],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(towerLeft, roofPeakY, centerW, roofPeakHeight));
    canvas.drawPath(rPath, Paint()..shader = rShader);
    canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 3.5);

    // Scalloped tile lines on chateau roof
    for (double i = 1; i <= 3; i++) {
      final t = i / 4.0;
      final y = roofPeakY + roofPeakHeight * t;
      final w = centerW * t;
      canvas.drawLine(
        Offset(cx - w / 2, y),
        Offset(cx + w / 2, y),
        Paint()..color = palette.roofUnderTrim.withValues(alpha: 0.5) ..strokeWidth = 1.5,
      );
    }

    // Tall Pointed Finial Spire Spike at top peak
    final finialPaint = Paint()..color = palette.accentColor;
    canvas.drawLine(Offset(cx, roofPeakY), Offset(cx, roofPeakY - 18), finialPaint..strokeWidth = 2.5);
    canvas.drawCircle(Offset(cx, roofPeakY - 18), 3.0, finialPaint);
    canvas.drawCircle(Offset(cx, roofPeakY - 10), 2.0, finialPaint);
  }



  void _renderDay90DomeCrown(Canvas canvas, double cx, double groundY) {
    final floor2Top = groundY - 134.0;
    final crownCenter = Offset(cx, floor2Top - 156);
    final goldPaint = Paint()..color = const Color(0xFFFFD700);
    final redPaint = Paint()..color = const Color(0xFFDC2626);

    final coronaPulse = (math.sin(animTimer * 4.0) + 1.0) / 2.0;
    final rayPaint = Paint()
      ..color = const Color(0xFFFFFC00).withValues(alpha: 0.60 + coronaPulse * 0.35)
      ..strokeWidth = 2.0;
    for (double a = -math.pi * 0.75; a <= math.pi * 0.75; a += 0.35) {
      final r1 = 12.0;
      final r2 = 20.0 + coronaPulse * 6.0;
      canvas.drawLine(
        Offset(crownCenter.dx + math.sin(a) * r1, crownCenter.dy - math.cos(a) * r1),
        Offset(crownCenter.dx + math.sin(a) * r2, crownCenter.dy - math.cos(a) * r2),
        rayPaint,
      );
    }

    canvas.drawCircle(crownCenter, 7.5, goldPaint);
    canvas.drawCircle(crownCenter, 4.5, redPaint);
    canvas.drawCircle(crownCenter, 2.2, Paint()..color = const Color(0xFFFFFC00));

    final eaglePath = Path();
    eaglePath.moveTo(crownCenter.dx - 8, crownCenter.dy - 2);
    eaglePath.lineTo(crownCenter.dx, crownCenter.dy - 12);
    eaglePath.lineTo(crownCenter.dx + 8, crownCenter.dy - 2);
    eaglePath.lineTo(crownCenter.dx, crownCenter.dy - 6);
    eaglePath.close();
    canvas.drawPath(eaglePath, goldPaint);
  }

  void _renderDamageOverlay(Canvas canvas, double cx, double groundY) {
    // 1. Structural fissure cracks on front walls
    final crackPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final crack1 = Path()
      ..moveTo(cx - 45, groundY - 95)
      ..lineTo(cx - 32, groundY - 70)
      ..lineTo(cx - 40, groundY - 50)
      ..lineTo(cx - 24, groundY - 25);
    canvas.drawPath(crack1, crackPaint);

    final crack2 = Path()
      ..moveTo(cx + 40, groundY - 110)
      ..lineTo(cx + 52, groundY - 80)
      ..lineTo(cx + 42, groundY - 60)
      ..lineTo(cx + 56, groundY - 35);
    canvas.drawPath(crack2, crackPaint);

    // 2. Fallen stone & masonry rubble
    final rubblePaint = Paint()..color = const Color(0xFF475569);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 70, groundY - 8, 14, 7), const Radius.circular(2)), rubblePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 60, groundY - 10, 16, 8), const Radius.circular(2)), rubblePaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 15, groundY - 6, 12, 6), const Radius.circular(2)), rubblePaint);

    // 3. Battle smoke & scorch marks
    final scorchPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(cx - 35, groundY - 75), 18, scorchPaint);
    canvas.drawCircle(Offset(cx + 45, groundY - 85), 20, scorchPaint);
  }

  // ============================================================
  // 🌿 1. LAWN & PATHWAY
  // ============================================================
  void _renderLawnAndPath(Canvas canvas, double cx, double groundY) {
    final lawnWidth = math.min(canvasSize.x * 0.96, 380.0);

    final lawnRect = Rect.fromCenter(
      center: Offset(cx, groundY + 10),
      width: lawnWidth,
      height: 38,
    );
    canvas.drawOval(lawnRect, Paint()..color = const Color(0xFF86EFAC).withValues(alpha: 0.35));

    final innerLawnRect = Rect.fromCenter(
      center: Offset(cx, groundY + 8),
      width: lawnWidth * 0.90,
      height: 30,
    );
    canvas.drawOval(innerLawnRect, Paint()..color = const Color(0xFF4ADE80).withValues(alpha: 0.65));

    final stonePaint = Paint()..color = const Color(0xFFE2E8F0);
    final stoneBorder = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < 3; i++) {
      final sy = groundY + 4 + i * 8.0;
      final sw = 28.0 - i * 3.0;
      final stoneRect = Rect.fromCenter(center: Offset(cx, sy), width: sw, height: 5.5);
      final rrect = RRect.fromRectAndRadius(stoneRect, const Radius.circular(3));
      canvas.drawRRect(rrect, stonePaint);
      canvas.drawRRect(rrect, stoneBorder);
    }

    // 🏎️ MILESTONE VEHICLE PARKED ON DRIVEWAY (DAYS 30, 60, 90)
    if (day >= 90) {
      _renderParkedRollsRoyce(canvas, cx + 128, groundY + 8);
    } else if (day >= 60) {
      _renderParkedLuxurySUV(canvas, cx + 124, groundY + 8);
    } else if (day >= 30) {
      _renderParkedSuperbike(canvas, cx + 124, groundY + 8);
    }
  }

  // ============================================================
  // 🏍️ / 🚙 / 🏎️ MILESTONE VEHICLE RENDERERS (DAYS 30, 60, 90)
  // ============================================================

  /// Day 30+: Cyber Sports Superbike on driveway
  void _renderParkedSuperbike(Canvas canvas, double vx, double vy) {
    final padRect = Rect.fromCenter(center: Offset(vx, vy + 4), width: 38, height: 14);
    canvas.drawOval(padRect, Paint()..color = const Color(0xFF334155).withValues(alpha: 0.6));

    final wheelPaint = Paint()..color = const Color(0xFF0F172A);
    final rimPaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Wheels
    canvas.drawCircle(Offset(vx - 10, vy), 5.5, wheelPaint);
    canvas.drawCircle(Offset(vx - 10, vy), 3.5, rimPaint);
    canvas.drawCircle(Offset(vx + 10, vy), 5.5, wheelPaint);
    canvas.drawCircle(Offset(vx + 10, vy), 3.5, rimPaint);

    // Frame & Body
    final framePath = Path();
    framePath.moveTo(vx - 9, vy - 2);
    framePath.lineTo(vx - 2, vy - 10);
    framePath.lineTo(vx + 6, vy - 8);
    framePath.lineTo(vx + 10, vy);
    framePath.lineTo(vx + 4, vy);
    framePath.lineTo(vx, vy - 4);
    framePath.close();
    canvas.drawPath(framePath, Paint()..color = const Color(0xFF0284C7));
    canvas.drawPath(
      framePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFF00F0FF)
        ..strokeWidth = 1.0,
    );

    // Handlebar & Headlight
    canvas.drawLine(
      Offset(vx + 6, vy - 8),
      Offset(vx + 7, vy - 11),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(Offset(vx + 12, vy - 6), 2.0, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(vx + 12, vy - 6), 4.5, Paint()..color = const Color(0xFF00F0FF).withValues(alpha: 0.4));
  }

  /// Day 60+: Luxury Grand SUV
  void _renderParkedLuxurySUV(Canvas canvas, double vx, double vy) {
    final padRect = Rect.fromCenter(center: Offset(vx, vy + 4), width: 54, height: 16);
    canvas.drawOval(padRect, Paint()..color = const Color(0xFF334155).withValues(alpha: 0.6));

    final wheelPaint = Paint()..color = const Color(0xFF0F172A);
    final rimPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(vx - 14, vy + 2), 6.0, wheelPaint);
    canvas.drawCircle(Offset(vx - 14, vy + 2), 3.5, rimPaint);
    canvas.drawCircle(Offset(vx + 14, vy + 2), 6.0, wheelPaint);
    canvas.drawCircle(Offset(vx + 14, vy + 2), 3.5, rimPaint);

    final bodyRect = Rect.fromLTWH(vx - 22, vy - 10, 44, 12);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(3)), Paint()..color = const Color(0xFF4C1D95));

    final cabinPath = Path();
    cabinPath.moveTo(vx - 16, vy - 10);
    cabinPath.lineTo(vx - 10, vy - 18);
    cabinPath.lineTo(vx + 10, vy - 18);
    cabinPath.lineTo(vx + 16, vy - 10);
    cabinPath.close();
    canvas.drawPath(cabinPath, Paint()..color = const Color(0xFF6D28D9));

    final winRect = Rect.fromLTWH(vx - 8, vy - 16, 16, 6);
    canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(2)), Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.8));
    canvas.drawCircle(Offset(vx + 21, vy - 6), 2.0, Paint()..color = Colors.amber.shade200);
  }

  /// Day 90+: Imperial 24K Rolls-Royce Sovereign Supercar!
  void _renderParkedRollsRoyce(Canvas canvas, double vx, double vy) {
    final padRect = Rect.fromCenter(center: Offset(vx, vy + 4), width: 66, height: 18);
    canvas.drawOval(padRect, Paint()..color = const Color(0xFF1E293B));
    canvas.drawOval(
      padRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.4)
        ..strokeWidth = 1.0,
    );

    final wheelPaint = Paint()..color = const Color(0xFF0F172A);
    final chromeRim = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(Offset(vx - 18, vy + 2), 6.5, wheelPaint);
    canvas.drawCircle(Offset(vx - 18, vy + 2), 4.0, chromeRim);
    canvas.drawCircle(Offset(vx + 18, vy + 2), 6.5, wheelPaint);
    canvas.drawCircle(Offset(vx + 18, vy + 2), 4.0, chromeRim);

    final bodyRect = Rect.fromLTWH(vx - 28, vy - 8, 56, 11);
    canvas.drawRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(3)), Paint()..color = const Color(0xFF0F172A));
    canvas.drawLine(Offset(vx - 26, vy - 7), Offset(vx + 26, vy - 7), Paint()..color = const Color(0xFFFFD700)..strokeWidth = 1.0);

    final cabinPath = Path();
    cabinPath.moveTo(vx - 18, vy - 8);
    cabinPath.lineTo(vx - 12, vy - 17);
    cabinPath.lineTo(vx + 10, vy - 17);
    cabinPath.lineTo(vx + 16, vy - 8);
    cabinPath.close();
    canvas.drawPath(cabinPath, Paint()..color = const Color(0xFF1E293B));

    final winRect = Rect.fromLTWH(vx - 10, vy - 15, 20, 7);
    canvas.drawRRect(RRect.fromRectAndRadius(winRect, const Radius.circular(2)), Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.85));
    canvas.drawRRect(
      RRect.fromRectAndRadius(winRect, const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFFFD700)
        ..strokeWidth = 0.8,
    );

    final grilleRect = Rect.fromLTWH(vx + 25, vy - 7, 3.5, 8);
    canvas.drawRect(grilleRect, Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(Offset(vx + 27, vy - 9), 1.5, Paint()..color = const Color(0xFFFFD700));

    canvas.drawCircle(Offset(vx + 27, vy - 4), 2.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(vx + 27, vy - 4), 6.0, Paint()..color = Colors.amber.withValues(alpha: 0.45));
  }



  void _renderColonnadedPorch(Canvas canvas, double cx, double groundY, double estateWidth, double porchH) {
    final porchTop = groundY - porchH;
    final porchLeft = cx - estateWidth / 2 + 6;

    // Covered Porch Entablature Beam (Red metal/tile trim + white cornice)
    final eRect = Rect.fromLTWH(porchLeft, porchTop - 8, estateWidth - 12, 10);
    canvas.drawRRect(RRect.fromRectAndRadius(eRect, const Radius.circular(2)), Paint()..color = palette.roofColor);
    canvas.drawRect(Rect.fromLTWH(porchLeft, porchTop - 2, estateWidth - 12, 4), Paint()..color = palette.roofTrim);

    // White Classical Pillars / Columns across the veranda (14 columns on Days 85-90, 12 on Days 71-84)
    final columnXs = (day >= 85)
        ? [
            cx - 160.0, cx - 134.0, cx - 108.0, cx - 82.0, cx - 56.0, cx - 36.0, cx - 18.0,
            cx + 18.0, cx + 36.0, cx + 56.0, cx + 82.0, cx + 108.0, cx + 134.0, cx + 160.0,
          ]
        : [
            cx - 144.0, cx - 118.0, cx - 90.0, cx - 62.0, cx - 36.0, cx - 18.0,
            cx + 18.0, cx + 36.0, cx + 62.0, cx + 90.0, cx + 118.0, cx + 144.0,
          ];

    final colPaint = Paint()..color = Colors.white;
    final colBorder = Paint()..color = const Color(0xFFCBD5E1) ..strokeWidth = 1.0;

    for (final x in columnXs) {
      final colRect = Rect.fromLTWH(x - 3.5, porchTop + 2, 7, porchH - 16);
      canvas.drawRect(colRect, colPaint);
      canvas.drawRect(colRect, colBorder);
      // Capital & Base
      canvas.drawRect(Rect.fromLTWH(x - 5, porchTop + 2, 10, 3.5), colPaint);
      canvas.drawRect(Rect.fromLTWH(x - 5, groundY - 17, 10, 3.5), colPaint);
    }

    // Balustrade Railings between pillars
    final railPaint = Paint()..color = Colors.white;
    final railBorder = Paint()..color = const Color(0xFF94A3B8) ..strokeWidth = 1.0;

    for (int i = 0; i < columnXs.length - 1; i++) {
      final x1 = columnXs[i] + 4;
      final x2 = columnXs[i + 1] - 4;
      if (i == 5) continue; // Gap for the grand central entrance stairs!

      final rH = 14.0;
      final rTop = groundY - 14 - rH;
      // Top & bottom rail
      canvas.drawLine(Offset(x1, rTop), Offset(x2, rTop), railBorder);
      canvas.drawLine(Offset(x1, rTop + rH), Offset(x2, rTop + rH), railBorder);

      // Balusters
      for (double bx = x1 + 3; bx < x2; bx += 4.5) {
        canvas.drawLine(Offset(bx, rTop), Offset(bx, rTop + rH), railPaint..strokeWidth = 2.0);
      }
    }

    // Behind columns: Ground floor windows and Grand Double Front Door
    _renderVictorianFrontDoor(canvas, cx, groundY - 14);
    _renderVictorianSashWindow(canvas, cx - 104, porchTop + 26, 20, 32);
    _renderVictorianSashWindow(canvas, cx - 76, porchTop + 26, 20, 32);
    _renderVictorianSashWindow(canvas, cx + 76, porchTop + 26, 20, 32);
    _renderVictorianSashWindow(canvas, cx + 104, porchTop + 26, 20, 32);
  }


  void _renderVictorianSashWindow(Canvas canvas, double cx, double cy, double w, double h) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);

    // Decorative white pediment molding at top
    canvas.drawRect(Rect.fromLTWH(rect.left - 2, rect.top - 3, w + 4, 3.5), Paint()..color = Colors.white);
    // White outer window frame
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), Paint()..color = Colors.white);

    // Cyan / Sky glass pane
    final inner = rect.deflate(2.5);
    final winColor = lightsOn ? palette.windowColor : const Color(0xFF1E293B);
    canvas.drawRect(inner, Paint()..color = winColor);

    if (lightsOn) {
      canvas.drawLine(Offset(inner.left + 3, inner.bottom - 3), Offset(inner.right - 3, inner.top + 3), Paint()..color = Colors.white70 ..strokeWidth = 1.5);
    }

    // Mullion cross bars
    final g = Paint()..color = Colors.white ..strokeWidth = 1.5;
    canvas.drawLine(Offset(inner.left, inner.center.dy), Offset(inner.right, inner.center.dy), g);
    canvas.drawLine(Offset(inner.center.dx, inner.top), Offset(inner.center.dx, inner.bottom), g);
  }

  void _renderVictorianArchedDormer(Canvas canvas, double cx, double cy, double w, double h) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(w / 2),
      topRight: Radius.circular(w / 2),
      bottomLeft: const Radius.circular(2),
      bottomRight: const Radius.circular(2),
    );

    // White trim surround
    canvas.drawRRect(rrect.inflate(1.5), Paint()..color = Colors.white);
    // Glass
    final winColor = lightsOn ? palette.windowColor : const Color(0xFF1E293B);
    canvas.drawRRect(rrect.deflate(2), Paint()..color = winColor);

    // Glazing bars
    final g = Paint()..color = Colors.white ..strokeWidth = 1.2;
    canvas.drawLine(Offset(rect.left + 2, rect.center.dy), Offset(rect.right - 2, rect.center.dy), g);
    canvas.drawLine(Offset(cx, rect.top + 2), Offset(cx, rect.bottom - 2), g);
  }

  void _renderVictorianFrontDoor(Canvas canvas, double cx, double groundY) {
    const dW = 34.0;
    const dH = 46.0;
    final dRect = Rect.fromCenter(center: Offset(cx, groundY - dH / 2), width: dW, height: dH);

    // Arched portico entrance
    final archRRect = RRect.fromRectAndCorners(
      dRect.inflate(3),
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
    );
    canvas.drawRRect(archRRect, Paint()..color = Colors.white);

    // Dark mahogany double doors
    canvas.drawRect(dRect, Paint()..color = const Color(0xFF78350F));
    canvas.drawLine(Offset(cx, dRect.top), Offset(cx, dRect.bottom), Paint()..color = Colors.white70 ..strokeWidth = 1.2);

    // Fanlight transom window
    final fanRect = Rect.fromLTWH(dRect.left + 4, dRect.top + 3, dW - 8, 12);
    canvas.drawRRect(RRect.fromRectAndRadius(fanRect, const Radius.circular(6)), Paint()..color = palette.windowColor);

    // Brass knobs
    canvas.drawCircle(Offset(cx - 3, dRect.center.dy + 4), 1.8, Paint()..color = palette.accentColor);
    canvas.drawCircle(Offset(cx + 3, dRect.center.dy + 4), 1.8, Paint()..color = palette.accentColor);
  }

  // ============================================================
  // 🏰 DAYS 78–90: PROGRESSIVE REAR PALATIAL LAYERS & CITADEL EXPANSIONS
  // "ബാക്കിലോ മേലെയോ എന്തെങ്കിലുമൊക്കെ വെച്ച് പിന്നെയും ബാക്കിലൂടെയൊക്കെ എന്തെങ്കിലുമൊക്കെ ഡെവലപ്പ് ചെയ്യുക."
  // ============================================================








  void _renderGrandSteps(Canvas canvas, double cx, double groundY) {
    final stepPaint = Paint()..color = const Color(0xFFE2E8F0);
    final border = Paint()..color = const Color(0xFF94A3B8) ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      final sy = groundY - 14 + i * 3.5;
      final sw = 44.0 + i * 8.0;
      final sRect = Rect.fromCenter(center: Offset(cx, sy), width: sw, height: 4.0);
      canvas.drawRRect(RRect.fromRectAndRadius(sRect, const Radius.circular(2)), stepPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(sRect, const Radius.circular(2)), border);
    }
  }

  void _renderLancetWindow(Canvas canvas, double cx, double cy, double w, double h) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    final path = Path();
    path.moveTo(rect.left, rect.bottom);
    path.lineTo(rect.left, rect.top + h * 0.4);
    path.quadraticBezierTo(rect.left, rect.top, cx, rect.top);
    path.quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + h * 0.4);
    path.lineTo(rect.right, rect.bottom);
    path.close();

    // Stone trim
    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke ..color = Colors.white ..strokeWidth = 2.0);
    // Warm stained glass
    final winColor = lightsOn ? const Color(0xFFFBBF24) : const Color(0xFF1E293B);
    canvas.drawPath(path, Paint()..color = winColor);
    // Center mullion
    canvas.drawLine(Offset(cx, rect.top + 4), Offset(cx, rect.bottom), Paint()..color = Colors.white70 ..strokeWidth = 1.0);
  }



  void _renderConnectingArcade(Canvas canvas, double x1, double x2, double groundY, double roofTop) {
    final w = x2 - x1;
    final h = groundY - roofTop;

    // Gallery wall
    final rect = Rect.fromLTWH(x1, roofTop, w, h);
    canvas.drawRect(rect, Paint()..color = palette.wallColor);

    // 2 Romanesque Arched Portals
    final archW = (w - 12) / 2;
    for (int i = 0; i < 2; i++) {
      final ax = x1 + 4 + i * (archW + 4);
      final aRect = Rect.fromLTWH(ax, groundY - 42, archW, 42);
      final aPath = Path();
      aPath.moveTo(aRect.left, aRect.bottom);
      aPath.lineTo(aRect.left, aRect.top + archW / 2);
      aPath.arcToPoint(Offset(aRect.right, aRect.top + archW / 2), radius: Radius.circular(archW / 2));
      aPath.lineTo(aRect.right, aRect.bottom);
      aPath.close();

      // Depth shadow & warm inner light
      canvas.drawPath(aPath, Paint()..color = const Color(0xFF0F172A));
      if (lightsOn) {
        canvas.drawCircle(Offset(ax + archW / 2, aRect.top + archW / 2 + 4), 6.0, Paint()..color = const Color(0xFFFBBF24).withValues(alpha: 0.5));
      }
      canvas.drawPath(aPath, Paint()..style = PaintingStyle.stroke ..color = Colors.white ..strokeWidth = 1.8);
    }

    // Upper glazed gallery
    final gRect = Rect.fromLTWH(x1 + 6, roofTop + 8, w - 12, 16);
    canvas.drawRect(gRect, Paint()..color = lightsOn ? palette.windowColor : const Color(0xFF1E293B));
    canvas.drawRect(gRect, Paint()..style = PaintingStyle.stroke ..color = Colors.white ..strokeWidth = 1.2);

    // Rooftop gallery balustrade & urns
    final bTop = roofTop - 8;
    canvas.drawLine(Offset(x1, roofTop), Offset(x2, roofTop), Paint()..color = palette.roofTrim ..strokeWidth = 3.0);
    canvas.drawLine(Offset(x1, bTop), Offset(x2, bTop), Paint()..color = Colors.white ..strokeWidth = 1.5);
    for (double bx = x1 + 6; bx < x2 - 2; bx += 8) {
      canvas.drawLine(Offset(bx, bTop), Offset(bx, roofTop), Paint()..color = Colors.white ..strokeWidth = 1.5);
    }
    // Urn finials on balustrade posts
    _renderClassicalUrn(canvas, x1 + 2, bTop - 4);
    _renderClassicalUrn(canvas, x1 + w / 2, bTop - 4);
    _renderClassicalUrn(canvas, x2 - 2, bTop - 4);
  }

  void _renderClassicalUrn(Canvas canvas, double cx, double cy) {
    final p = Paint()..color = const Color(0xFFFFD700);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 5, height: 7), p);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 4), width: 6, height: 2), p);
  }

  void _renderImperialSteps(Canvas canvas, double cx, double groundY) {
    final stepPaint = Paint()..color = const Color(0xFFF8FAFC);
    final border = Paint()..color = const Color(0xFF94A3B8) ..strokeWidth = 1.0;
    final carpetPaint = Paint()..color = const Color(0xFFDC2626);
    final brassRodPaint = Paint()..color = const Color(0xFFFFD700) ..strokeWidth = 1.5;

    for (int i = 0; i < 5; i++) {
      final sy = groundY - 15 + i * 3.4;
      final sw = 52.0 + i * 9.0;
      final sRect = Rect.fromCenter(center: Offset(cx, sy), width: sw, height: 4.0);
      canvas.drawRRect(RRect.fromRectAndRadius(sRect, const Radius.circular(2)), stepPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(sRect, const Radius.circular(2)), border);

      // Crimson Carpet Runner
      final cRect = Rect.fromCenter(center: Offset(cx, sy), width: 24.0, height: 4.0);
      canvas.drawRect(cRect, carpetPaint);
      // Brass stair rod
      canvas.drawLine(Offset(cx - 12.0, sy - 1.5), Offset(cx + 12.0, sy - 1.5), brassRodPaint);
    }
  }

  void _renderGuardianLionPedestal(Canvas canvas, double px, double py) {
    // Marble Pedestal Block
    final pRect = Rect.fromCenter(center: Offset(px, py - 8), width: 18, height: 16);
    canvas.drawRRect(RRect.fromRectAndRadius(pRect, const Radius.circular(2)), Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawRRect(RRect.fromRectAndRadius(pRect, const Radius.circular(2)), Paint()..style = PaintingStyle.stroke ..color = const Color(0xFF94A3B8) ..strokeWidth = 1.0);

    // Sculpted Golden Guardian Lion Statuette
    final lionGold = Paint()..color = const Color(0xFFFFD700);
    final lionShade = Paint()..color = const Color(0xFFB45309);
    final ly = pRect.top;
    // Lion Body & Haunches
    canvas.drawOval(Rect.fromCenter(center: Offset(px, ly - 7), width: 11, height: 13), lionGold);
    // Head & Mane
    canvas.drawCircle(Offset(px, ly - 14), 5.5, lionShade);
    canvas.drawCircle(Offset(px, ly - 14), 4.2, lionGold);
    // Snout & Crown
    canvas.drawCircle(Offset(px, ly - 13), 2.0, lionShade);
    canvas.drawRect(Rect.fromCenter(center: Offset(px, ly - 18), width: 4, height: 3), lionGold);
  }

  void _renderCourtyardFountain(Canvas canvas, double fx, double fy) {
    final marblePaint = Paint()..color = const Color(0xFFE2E8F0);
    final marbleBorder = Paint()..color = const Color(0xFF94A3B8) ..strokeWidth = 1.0;
    final waterPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.85);

    // 1. Lower Marble Basin
    final b1Rect = Rect.fromCenter(center: Offset(fx, fy), width: 38, height: 10);
    canvas.drawOval(b1Rect, marblePaint);
    canvas.drawOval(b1Rect, marbleBorder);
    canvas.drawOval(b1Rect.deflate(2.5), waterPaint);

    // 2. Center Column Pedestal
    final pedRect = Rect.fromLTWH(fx - 3.5, fy - 14, 7, 14);
    canvas.drawRect(pedRect, marblePaint);
    canvas.drawRect(pedRect, marbleBorder);

    // 3. Upper Marble Basin
    final b2Rect = Rect.fromCenter(center: Offset(fx, fy - 14), width: 22, height: 7);
    canvas.drawOval(b2Rect, marblePaint);
    canvas.drawOval(b2Rect, marbleBorder);
    canvas.drawOval(b2Rect.deflate(1.5), waterPaint);

    // 4. Animated Water Jets & Splashes
    final sprayT = (animTimer * 2.5) % 1.0;
    final jetPaint = Paint()..color = Colors.cyanAccent.withValues(alpha: 0.85) ..strokeWidth = 1.6;
    // Center rising jet
    canvas.drawLine(Offset(fx, fy - 15), Offset(fx, fy - 26), jetPaint);
    canvas.drawCircle(Offset(fx, fy - 26), 2.2, Paint()..color = Colors.white);

    // Graceful Arcing Spray Water Streams
    final arcPaint = Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.75) ..strokeWidth = 1.2 ..style = PaintingStyle.stroke;
    final leftSpray = Path()..moveTo(fx, fy - 24)..quadraticBezierTo(fx - 12, fy - 25, fx - 14, fy - 10);
    final rightSpray = Path()..moveTo(fx, fy - 24)..quadraticBezierTo(fx + 12, fy - 25, fx + 14, fy - 10);
    canvas.drawPath(leftSpray, arcPaint);
    canvas.drawPath(rightSpray, arcPaint);

    // Sparkling Droplet
    final dropX = fx - 10.0 + sprayT * 20.0;
    final dropY = fy - 20.0 + (sprayT - 0.5) * (sprayT - 0.5) * 24.0;
    canvas.drawCircle(Offset(dropX, dropY), 1.3, Paint()..color = Colors.white);
  }

  void _renderPalaceSpearGates(Canvas canvas, double cx, double groundY, double estateWidth) {
    final gatePaint = Paint()..color = const Color(0xFF1E293B) ..strokeWidth = 1.4;
    final spearPaint = Paint()..color = const Color(0xFFFFD700);

    // Left gate fence segment
    final leftStart = cx - estateWidth / 2 + 10;
    final leftEnd = cx - 58;
    canvas.drawLine(Offset(leftStart, groundY - 14), Offset(leftEnd, groundY - 14), gatePaint);
    canvas.drawLine(Offset(leftStart, groundY - 26), Offset(leftEnd, groundY - 26), gatePaint);
    for (double x = leftStart + 4; x <= leftEnd; x += 10) {
      canvas.drawLine(Offset(x, groundY - 2), Offset(x, groundY - 30), gatePaint);
      _drawSpearFinial(canvas, x, groundY - 30, spearPaint);
    }

    // Right gate fence segment
    final rightStart = cx + 58;
    final rightEnd = cx + estateWidth / 2 - 10;
    canvas.drawLine(Offset(rightStart, groundY - 14), Offset(rightEnd, groundY - 14), gatePaint);
    canvas.drawLine(Offset(rightStart, groundY - 26), Offset(rightEnd, groundY - 26), gatePaint);
    for (double x = rightStart + 4; x <= rightEnd; x += 10) {
      canvas.drawLine(Offset(x, groundY - 2), Offset(x, groundY - 30), gatePaint);
      _drawSpearFinial(canvas, x, groundY - 30, spearPaint);
    }

    // Gatepost Carriage Lamps
    _renderCarriageLamp(canvas, leftEnd, groundY - 28);
    _renderCarriageLamp(canvas, rightStart, groundY - 28);
  }

  void _drawSpearFinial(Canvas canvas, double x, double y, Paint p) {
    final path = Path();
    path.moveTo(x - 2.5, y);
    path.lineTo(x, y - 5.5);
    path.lineTo(x + 2.5, y);
    path.close();
    canvas.drawPath(path, p);
  }

  void _renderCarriageLamp(Canvas canvas, double cx, double cy) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: 7, height: 11);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(Offset(cx, cy), 3.0, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawCircle(Offset(cx, cy), 1.5, Paint()..color = Colors.white);
  }

  void _renderDay90PalaceBanner(Canvas canvas, double cx, double groundY) {
    final bannerRect = Rect.fromCenter(center: Offset(cx, groundY - 14), width: 250, height: 18);
    final bGradient = const LinearGradient(
      colors: [Color(0xFF78350F), Color(0xFFB45309), Color(0xFF78350F)],
    ).createShader(bannerRect);

    canvas.drawRRect(RRect.fromRectAndRadius(bannerRect, const Radius.circular(9)), Paint()..shader = bGradient);
    canvas.drawRRect(RRect.fromRectAndRadius(bannerRect, const Radius.circular(9)), Paint()..style = PaintingStyle.stroke ..color = const Color(0xFFFFD700) ..strokeWidth = 1.4);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '👑 IMPERIAL CITADEL • DAY 90 MASTER 👑',
        style: TextStyle(
          color: Color(0xFFFEF08A),
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, groundY - 14 - textPainter.height / 2));
  }

  // ============================================================
  // 🏡 3. CORE COTTAGE (DAYS 1–70, IMAGE 1)
  // ============================================================
  void _renderCoreCottage(Canvas canvas, double cx, double groundY) {
    const wallWidth = 176.0;
    const wallHeight = 98.0;
    const foundationHeight = 16.0;

    final wallLeft = cx - wallWidth / 2;
    final wallTop = groundY - wallHeight;

    final fRect = Rect.fromLTWH(wallLeft, groundY - foundationHeight, wallWidth, foundationHeight);
    canvas.drawRect(fRect, Paint()..color = palette.foundationColor);

    final stoneLinePaint = Paint()..color = Colors.black26 ..strokeWidth = 1.2;
    for (double x = wallLeft + 22; x < wallLeft + wallWidth; x += 22) {
      canvas.drawLine(Offset(x, groundY - foundationHeight), Offset(x, groundY), stoneLinePaint);
    }
    canvas.drawLine(Offset(wallLeft, groundY - foundationHeight), Offset(wallLeft + wallWidth, groundY - foundationHeight), stoneLinePaint);

    final wRect = Rect.fromLTWH(wallLeft, wallTop, wallWidth, wallHeight - foundationHeight);
    canvas.drawRect(wRect, Paint()..color = palette.wallColor);

    final mortarPaint = Paint()..color = palette.mortarColor ..strokeWidth = 1.0;
    for (double y = wallTop + 12; y < groundY - foundationHeight; y += 12) {
      canvas.drawLine(Offset(wallLeft, y), Offset(wallLeft + wallWidth, y), mortarPaint);
      final rowOffset = ((y - wallTop) ~/ 12) % 2 == 0 ? 0.0 : 12.0;
      for (double x = wallLeft + 12 + rowOffset; x < wallLeft + wallWidth; x += 24) {
        canvas.drawLine(Offset(x, y - 12), Offset(x, y), mortarPaint);
      }
    }

    canvas.drawRect(
      Rect.fromLTWH(wallLeft, wallTop, wallWidth, wallHeight),
      Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 2.0,
    );

    _renderStorybookWindow(canvas, cx - 48, wallTop + 38, 36, 44);
    _renderStorybookWindow(canvas, cx + 48, wallTop + 38, 36, 44);

    _renderCottageFrontDoor(canvas, cx, groundY);
    if (day <= 7) {
      _renderCoreRoof(canvas, cx, wallTop, wallWidth);
    }
  }

  void _renderCoreRoof(Canvas canvas, double cx, double wallTop, double wallWidth) {
    const roofOverhang = 18.0;
    const roofPeakHeight = 68.0;
    final roofLeft = cx - wallWidth / 2 - roofOverhang;
    final roofRight = cx + wallWidth / 2 + roofOverhang;
    final roofPeakY = wallTop - roofPeakHeight;

    final chimLeft = cx - 62;
    final chimTop = roofPeakY - 8;
    final chimRect = Rect.fromLTWH(chimLeft, chimTop, 22, 42);
    canvas.drawRect(chimRect, Paint()..color = palette.roofShade);
    final capRect = Rect.fromLTWH(chimLeft - 3, chimTop - 5, 28, 6);
    canvas.drawRect(capRect, Paint()..color = palette.roofTrim);

    final roofPath = Path();
    roofPath.moveTo(roofLeft, wallTop + 4);
    roofPath.lineTo(cx, roofPeakY);
    roofPath.lineTo(roofRight, wallTop + 4);
    roofPath.close();

    final roofPaint = Paint()
      ..shader = LinearGradient(
        colors: [palette.roofColor, palette.roofShade],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(roofLeft, roofPeakY, roofRight - roofLeft, roofPeakHeight + 4));
    canvas.drawPath(roofPath, roofPaint);

    final tilePaint = Paint()
      ..color = palette.roofUnderTrim.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    for (double i = 1; i <= 4; i++) {
      final t = i / 5.0;
      final y = roofPeakY + (wallTop + 4 - roofPeakY) * t;
      final xL = cx + (roofLeft - cx) * t;
      final xR = cx + (roofRight - cx) * t;
      canvas.drawLine(Offset(xL, y), Offset(xR, y), tilePaint);
    }

    final trimPaint = Paint()
      ..color = palette.roofTrim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final trimPath = Path();
    trimPath.moveTo(roofLeft - 2, wallTop + 4);
    trimPath.lineTo(cx, roofPeakY);
    trimPath.lineTo(roofRight + 2, wallTop + 4);
    canvas.drawPath(trimPath, trimPaint);

    canvas.drawPath(
      trimPath,
      Paint()
        ..color = palette.roofUnderTrim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Day 5+ Attic Dormer
    if (day >= 5) {
      _renderArchedDormer(canvas, cx, wallTop - 28, 26, 32);
    }

    // Day 10+ Golden Weathervane of Mastery
    if (day >= 10) {
      _renderDay10Weathervane(canvas, cx, roofPeakY);
    }
  }


  void _renderStorybookWindow(Canvas canvas, double cx, double cy, double w, double h) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    canvas.drawRect(rect.inflate(2), Paint()..color = palette.roofUnderTrim.withValues(alpha: 0.3));

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = Colors.white,
    );

    final innerRect = rect.deflate(3.5);
    final winColor = lightsOn ? palette.windowColor : const Color(0xFF1E293B);
    canvas.drawRect(innerRect, Paint()..color = winColor);

    if (lightsOn) {
      canvas.drawLine(Offset(innerRect.left + 4, innerRect.bottom - 4), Offset(innerRect.right - 4, innerRect.top + 4), Paint()..color = Colors.white.withValues(alpha: 0.55) ..strokeWidth = 2.0);
    }

    final gridPaint = Paint()..color = Colors.white ..strokeWidth = 2.0;
    canvas.drawLine(Offset(innerRect.left, innerRect.center.dy), Offset(innerRect.right, innerRect.center.dy), gridPaint);
    canvas.drawLine(Offset(innerRect.center.dx, innerRect.top), Offset(innerRect.center.dx, innerRect.bottom), gridPaint);

    if (day >= 3) {
      final boxRect = Rect.fromLTWH(rect.left - 2, rect.bottom - 1, w + 4, 8);
      canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(2)), Paint()..color = const Color(0xFF854D0E));

      final leafPaint = Paint()..color = const Color(0xFF22C55E);
      canvas.drawCircle(Offset(boxRect.left + 5, boxRect.top - 1), 3.5, leafPaint);
      canvas.drawCircle(Offset(boxRect.center.dx, boxRect.top - 2), 4.0, leafPaint);
      canvas.drawCircle(Offset(boxRect.right - 5, boxRect.top - 1), 3.5, leafPaint);

      canvas.drawCircle(Offset(boxRect.left + 7, boxRect.top - 2), 2.0, Paint()..color = const Color(0xFFF43F5E));
      canvas.drawCircle(Offset(boxRect.center.dx, boxRect.top - 3), 2.0, Paint()..color = const Color(0xFFFACC15));
      canvas.drawCircle(Offset(boxRect.right - 7, boxRect.top - 2), 2.0, Paint()..color = const Color(0xFFEC4899));
    }
  }

  // ============================================================
  // 🌱 DAILY VISIBLE INCREMENTAL UPGRADES (DAYS 1 TO 10)
  // ============================================================

  /// Day 2: Prominent Front Porch & Veranda Awning with Glowing Lantern
  void _renderDay2FrontPorchAwning(Canvas canvas, double cx, double groundY) {
    const porchW = 54.0;
    const porchH = 50.0;
    final porchTop = groundY - porchH - 18;

    // Support timber posts flanking the front door
    final postPaint = Paint()..color = Colors.white;
    final postBorder = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.0;

    // Left post
    final leftPost = Rect.fromLTWH(cx - porchW / 2 + 2, porchTop + 10, 5, porchH + 6);
    canvas.drawRect(leftPost, postPaint);
    canvas.drawRect(leftPost, postBorder);

    // Right post
    final rightPost = Rect.fromLTWH(cx + porchW / 2 - 7, porchTop + 10, 5, porchH + 6);
    canvas.drawRect(rightPost, postPaint);
    canvas.drawRect(rightPost, postBorder);

    // Gabled awning roof over the door
    final roofPath = Path();
    roofPath.moveTo(cx - porchW / 2 - 5, porchTop + 12);
    roofPath.lineTo(cx, porchTop - 4);
    roofPath.lineTo(cx + porchW / 2 + 5, porchTop + 12);
    roofPath.close();

    canvas.drawPath(roofPath, Paint()..color = palette.roofColor);
    canvas.drawPath(
      roofPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = palette.roofTrim
        ..strokeWidth = 2.5,
    );

    // Ornate Hanging Porch Lantern with warm amber glow!
    final lanternY = porchTop + 18;
    canvas.drawLine(
      Offset(cx, porchTop - 2),
      Offset(cx, lanternY),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 1.2,
    );
    // Amber glow circle
    canvas.drawCircle(Offset(cx, lanternY + 5), 8.0, Paint()..color = Colors.amber.withValues(alpha: 0.35));
    // Brass lantern body
    final lRect = Rect.fromCenter(center: Offset(cx, lanternY + 5), width: 8, height: 10);
    canvas.drawRRect(RRect.fromRectAndRadius(lRect, const Radius.circular(2)), Paint()..color = Colors.amber.shade300);
    canvas.drawRRect(
      RRect.fromRectAndRadius(lRect, const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFB45309)
        ..strokeWidth = 1.0,
    );
  }

  /// Day 3: Blooming Garden Flower Beds
  void _renderDay3GardenFlowerBeds(Canvas canvas, double cx, double groundY) {
    final flowerColors = [
      const Color(0xFFF43F5E),
      const Color(0xFFEC4899),
      const Color(0xFFFACC15),
      const Color(0xFF8B5CF6),
    ];

    // Left garden bed
    for (int i = 0; i < 4; i++) {
      final fx = cx - 36 - i * 8.0;
      final fy = groundY - 2 + (i % 2) * 3.0;
      canvas.drawLine(
        Offset(fx, fy),
        Offset(fx, fy - 6),
        Paint()
          ..color = const Color(0xFF16A34A)
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(Offset(fx, fy - 7), 3.0, Paint()..color = flowerColors[i % flowerColors.length]);
      canvas.drawCircle(Offset(fx, fy - 7), 1.2, Paint()..color = Colors.white);
    }

    // Right garden bed
    for (int i = 0; i < 4; i++) {
      final fx = cx + 36 + i * 8.0;
      final fy = groundY - 2 + (i % 2) * 3.0;
      canvas.drawLine(
        Offset(fx, fy),
        Offset(fx, fy - 6),
        Paint()
          ..color = const Color(0xFF16A34A)
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(Offset(fx, fy - 7), 3.0, Paint()..color = flowerColors[(i + 2) % flowerColors.length]);
      canvas.drawCircle(Offset(fx, fy - 7), 1.2, Paint()..color = Colors.white);
    }
  }

  /// Day 6: White Wooden Picket Fence & Garden Gate
  void _renderDay6PicketFence(Canvas canvas, double cx, double groundY) {
    final fencePaint = Paint()..color = Colors.white;
    final fenceBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.0;
    const fenceTop = 14.0;

    // Left fence
    for (double x = cx - 110; x <= cx - 30; x += 9.0) {
      final pPath = Path();
      pPath.moveTo(x - 3, groundY);
      pPath.lineTo(x - 3, groundY - fenceTop + 3);
      pPath.lineTo(x, groundY - fenceTop);
      pPath.lineTo(x + 3, groundY - fenceTop + 3);
      pPath.lineTo(x + 3, groundY);
      pPath.close();
      canvas.drawPath(pPath, fencePaint);
      canvas.drawPath(pPath, fenceBorder);
    }
    canvas.drawLine(Offset(cx - 110, groundY - 5), Offset(cx - 30, groundY - 5), fenceBorder);
    canvas.drawLine(Offset(cx - 110, groundY - 11), Offset(cx - 30, groundY - 11), fenceBorder);

    // Right fence
    for (double x = cx + 30; x <= cx + 110; x += 9.0) {
      final pPath = Path();
      pPath.moveTo(x - 3, groundY);
      pPath.lineTo(x - 3, groundY - fenceTop + 3);
      pPath.lineTo(x, groundY - fenceTop);
      pPath.lineTo(x + 3, groundY - fenceTop + 3);
      pPath.lineTo(x + 3, groundY);
      pPath.close();
      canvas.drawPath(pPath, fencePaint);
      canvas.drawPath(pPath, fenceBorder);
    }
    canvas.drawLine(Offset(cx + 30, groundY - 5), Offset(cx + 110, groundY - 5), fenceBorder);
    canvas.drawLine(Offset(cx + 30, groundY - 11), Offset(cx + 110, groundY - 11), fenceBorder);
  }

  /// Day 7: Twin Vintage Street Lantern Posts
  void _renderDay7StreetLamps(Canvas canvas, double cx, double groundY) {
    for (final lx in [cx - 28, cx + 28]) {
      final postY = groundY - 26;
      // Dark wrought-iron lamp post
      canvas.drawLine(
        Offset(lx, groundY),
        Offset(lx, postY),
        Paint()
          ..color = const Color(0xFF334155)
          ..strokeWidth = 2.0,
      );
      // Amber lamp lantern
      final lRect = Rect.fromCenter(center: Offset(lx, postY - 4), width: 7, height: 9);
      canvas.drawCircle(Offset(lx, postY - 4), 7.0, Paint()..color = Colors.amber.withValues(alpha: 0.3));
      canvas.drawRRect(RRect.fromRectAndRadius(lRect, const Radius.circular(2)), Paint()..color = Colors.amber.shade300);
      canvas.drawRRect(
        RRect.fromRectAndRadius(lRect, const Radius.circular(2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFF1E293B)
          ..strokeWidth = 1.0,
      );
    }
  }

  /// Day 8: Blooming Apple Tree & Bird Feeder
  void _renderDay8AppleTree(Canvas canvas, double cx, double groundY) {
    const tx = -118.0;
    final treeX = cx + tx;
    final treeBaseY = groundY - 2;

    // Brown trunk
    final tPath = Path();
    tPath.moveTo(treeX - 4, treeBaseY);
    tPath.lineTo(treeX - 2, treeBaseY - 28);
    tPath.lineTo(treeX + 2, treeBaseY - 28);
    tPath.lineTo(treeX + 4, treeBaseY);
    tPath.close();
    canvas.drawPath(tPath, Paint()..color = const Color(0xFF78350F));

    // Green canopy
    final canopyY = treeBaseY - 38;
    canvas.drawCircle(Offset(treeX, canopyY), 16.0, Paint()..color = const Color(0xFF15803D));
    canvas.drawCircle(Offset(treeX - 8, canopyY + 4), 12.0, Paint()..color = const Color(0xFF16A34A));
    canvas.drawCircle(Offset(treeX + 8, canopyY + 4), 12.0, Paint()..color = const Color(0xFF22C55E));

    // Bright red apples
    canvas.drawCircle(Offset(treeX - 5, canopyY - 4), 2.5, Paint()..color = const Color(0xFFDC2626));
    canvas.drawCircle(Offset(treeX + 4, canopyY - 2), 2.5, Paint()..color = const Color(0xFFDC2626));
    canvas.drawCircle(Offset(treeX - 1, canopyY + 6), 2.5, Paint()..color = const Color(0xFFDC2626));

    // Little wooden birdhouse
    final bhRect = Rect.fromLTWH(treeX + 6, canopyY + 6, 8, 9);
    canvas.drawRect(bhRect, Paint()..color = const Color(0xFF92400E));
    canvas.drawCircle(Offset(treeX + 10, canopyY + 10), 1.5, Paint()..color = Colors.black);
  }

  /// Day 9: Stone Garden Fountain
  void _renderDay9GardenFountain(Canvas canvas, double cx, double groundY) {
    final fx = cx + 118.0;
    final fy = groundY - 2;

    // Stone pedestal
    final fPaint = Paint()..color = const Color(0xFFCBD5E1);
    final fBorder = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1.0;

    canvas.drawRect(Rect.fromCenter(center: Offset(fx, fy - 4), width: 18, height: 8), fPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(fx, fy - 4), width: 18, height: 8), fBorder);

    // Basin
    final bRect = Rect.fromCenter(center: Offset(fx, fy - 12), width: 26, height: 8);
    canvas.drawOval(bRect, fPaint);
    canvas.drawOval(bRect, fBorder);

    // Blue sparkling water
    canvas.drawOval(bRect.deflate(2), Paint()..color = const Color(0xFF38BDF8));
    canvas.drawCircle(Offset(fx, fy - 16), 2.0, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(fx - 2, fy - 14), 1.2, Paint()..color = const Color(0xFFBAE6FD));
    canvas.drawCircle(Offset(fx + 2, fy - 14), 1.2, Paint()..color = const Color(0xFFBAE6FD));
  }

  /// Day 10: Golden Weathervane of Mastery
  void _renderDay10Weathervane(Canvas canvas, double cx, double peakY) {
    final goldPaint = Paint()..color = const Color(0xFFFFD700);
    // Spire post
    canvas.drawLine(Offset(cx, peakY), Offset(cx, peakY - 18), goldPaint..strokeWidth = 2.0);
    // Direction arrows
    canvas.drawLine(Offset(cx - 7, peakY - 12), Offset(cx + 7, peakY - 12), goldPaint..strokeWidth = 1.5);
    // Golden rooster / pennant
    final pPath = Path();
    pPath.moveTo(cx, peakY - 18);
    pPath.lineTo(cx + 10, peakY - 14);
    pPath.lineTo(cx, peakY - 10);
    pPath.close();
    canvas.drawPath(pPath, goldPaint);
    canvas.drawCircle(Offset(cx, peakY - 18), 2.0, goldPaint);
  }

  void _renderArchedDormer(Canvas canvas, double cx, double cy, double w, double h) {
    final frameRect = Rect.fromCenter(center: Offset(cx, cy), width: w, height: h);
    final rrect = RRect.fromRectAndCorners(
      frameRect,
      topLeft: Radius.circular(w / 2),
      topRight: Radius.circular(w / 2),
      bottomLeft: const Radius.circular(3),
      bottomRight: const Radius.circular(3),
    );

    canvas.drawRRect(rrect, Paint()..color = Colors.white);
    canvas.drawRRect(rrect, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5);

    final innerRRect = rrect.deflate(3);
    final winColor = lightsOn ? palette.windowColor : const Color(0xFF1E293B);
    canvas.drawRRect(innerRRect, Paint()..color = winColor);

    final gridPaint = Paint()..color = Colors.white ..strokeWidth = 1.8;
    canvas.drawLine(Offset(frameRect.left + 3, frameRect.center.dy), Offset(frameRect.right - 3, frameRect.center.dy), gridPaint);
    canvas.drawLine(Offset(cx, frameRect.top + 3), Offset(cx, frameRect.bottom - 3), gridPaint);
  }

  void _renderCottageFrontDoor(Canvas canvas, double cx, double groundY) {
    const doorW = 38.0;
    const doorH = 68.0;
    final doorRect = Rect.fromCenter(center: Offset(cx, groundY - doorH / 2 - 2), width: doorW, height: doorH);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        doorRect.inflate(3.5),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        doorRect.inflate(3.5),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      ),
      Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5,
    );

    canvas.drawRect(doorRect, Paint()..color = palette.doorColor);

    final pPaint = Paint()..color = Colors.black26 ..style = PaintingStyle.stroke ..strokeWidth = 1.5;
    canvas.drawRect(Rect.fromLTWH(doorRect.left + 5, doorRect.top + 28, 12, 16), pPaint);
    canvas.drawRect(Rect.fromLTWH(doorRect.right - 17, doorRect.top + 28, 12, 16), pPaint);
    canvas.drawRect(Rect.fromLTWH(doorRect.left + 5, doorRect.top + 48, 12, 16), pPaint);
    canvas.drawRect(Rect.fromLTWH(doorRect.right - 17, doorRect.top + 48, 12, 16), pPaint);

    final fanRect = Rect.fromLTWH(doorRect.left + 5, doorRect.top + 6, doorW - 10, 18);
    final fanRRect = RRect.fromRectAndCorners(
      fanRect,
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
    );
    canvas.drawRRect(fanRRect, Paint()..color = palette.windowColor);
    canvas.drawRRect(fanRRect, Paint()..style = PaintingStyle.stroke ..color = Colors.white ..strokeWidth = 1.5);
    canvas.drawLine(Offset(cx, fanRect.bottom), Offset(cx, fanRect.top), Paint()..color = Colors.white ..strokeWidth = 1.5);
    canvas.drawLine(Offset(cx, fanRect.bottom), Offset(fanRect.left + 4, fanRect.top + 5), Paint()..color = Colors.white ..strokeWidth = 1.2);
    canvas.drawLine(Offset(cx, fanRect.bottom), Offset(fanRect.right - 4, fanRect.top + 5), Paint()..color = Colors.white ..strokeWidth = 1.2);

    canvas.drawCircle(Offset(doorRect.right - 6, doorRect.center.dy + 8), 3.0, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(Offset(doorRect.right - 6, doorRect.center.dy + 8), 1.5, Paint()..color = palette.accentColor);

    final stepPaint = Paint()..color = const Color(0xFFCBD5E1);
    final stepBorder = Paint()..color = const Color(0xFF94A3B8) ..style = PaintingStyle.stroke ..strokeWidth = 1.0;

    for (int i = 0; i < 3; i++) {
      final sy = groundY - 2 + i * 3.5;
      final sw = doorW + 12 + i * 8.0;
      final sRect = Rect.fromCenter(center: Offset(cx, sy), width: sw, height: 4.0);
      canvas.drawRRect(RRect.fromRectAndRadius(sRect, const Radius.circular(2)), stepPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(sRect, const Radius.circular(2)), stepBorder);
    }
  }

  void _renderBushes(Canvas canvas, double cx, double groundY) {
    final isCitadel = day >= 84;
    final isManor = day >= 71;
    final bushOffset = isCitadel ? 212.0 : (isManor ? 168.0 : (day >= 26 ? 155.0 : (day >= 11 ? 120.0 : 92.0)));

    _drawCartoonBush(canvas, cx - bushOffset, groundY - 6, isCitadel ? 32 : (isManor ? 28 : 24));
    _drawCartoonBush(canvas, cx - bushOffset - 20, groundY - 2, isCitadel ? 24 : (isManor ? 22 : 18));

    _drawCartoonBush(canvas, cx + bushOffset, groundY - 6, isCitadel ? 32 : (isManor ? 28 : 24));
    _drawCartoonBush(canvas, cx + bushOffset + 20, groundY - 2, isCitadel ? 24 : (isManor ? 22 : 18));
  }

  void _drawCartoonBush(Canvas canvas, double x, double y, double r) {
    canvas.drawCircle(Offset(x, y), r + 1.5, Paint()..color = const Color(0xFF15803D));
    canvas.drawCircle(Offset(x, y), r, Paint()..color = const Color(0xFF22C55E));
    canvas.drawCircle(Offset(x - r * 0.25, y - r * 0.25), r * 0.6, Paint()..color = const Color(0xFF4ADE80));
  }

  void _renderSmoke(Canvas canvas, double startX, double startY) {
    for (final p in _smokeParticles) {
      final alpha = (1.0 - (p.life / 2.0)).clamp(0.0, 1.0) * 0.55;
      final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(startX + p.x, startY + p.y), 4.5 * p.scale, paint);
    }
  }

  void _renderDay90VipMotorcade(Canvas canvas, double cx, double groundY) {
    final t = animTimer * 7.5;
    final strobe = math.sin(t) > 0;

    // 🏎️ 24K Gold Sovereign Phantom Limousine
    final limoX = cx + 42.0;
    final limoY = groundY - 2.0;

    // Limo Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(limoX + 42, limoY + 2), width: 88, height: 8),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Limo Lower Body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(limoX, limoY - 14, 84, 13),
      const Radius.circular(5),
    );
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFFFFD700));
    canvas.drawRRect(bodyRect, Paint()..style = PaintingStyle.stroke ..color = const Color(0xFFB45309) ..strokeWidth = 1.0);

    // Limo Roof & Tinted Windows
    final roofRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(limoX + 16, limoY - 23, 52, 10),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(5),
    );
    canvas.drawRRect(roofRect, Paint()..color = const Color(0xFF0F172A));
    canvas.drawRect(
      Rect.fromLTWH(limoX + 22, limoY - 21, 16, 7),
      Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.7),
    );
    canvas.drawRect(
      Rect.fromLTWH(limoX + 42, limoY - 21, 20, 7),
      Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.7),
    );

    // Wheels
    final wheelPaint = Paint()..color = const Color(0xFF1E293B);
    final rimPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(limoX + 16, limoY - 2), 5.5, wheelPaint);
    canvas.drawCircle(Offset(limoX + 16, limoY - 2), 2.5, rimPaint);
    canvas.drawCircle(Offset(limoX + 68, limoY - 2), 5.5, wheelPaint);
    canvas.drawCircle(Offset(limoX + 68, limoY - 2), 2.5, rimPaint);

    // 🏍️ Left Armed Tactical Escort (Alpha)
    final leftX = limoX - 22.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(leftX, limoY - 11, 16, 10), const Radius.circular(3)),
      Paint()..color = const Color(0xFF1E293B),
    );
    final leftStrobe = strobe ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);
    canvas.drawCircle(Offset(leftX + 8, limoY - 14), 2.8, Paint()..color = leftStrobe);

    // 🏍️ Right Armed Tactical Escort (Bravo)
    final rightX = limoX + 88.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rightX, limoY - 11, 16, 10), const Radius.circular(3)),
      Paint()..color = const Color(0xFF1E293B),
    );
    final rightStrobe = strobe ? const Color(0xFF3B82F6) : const Color(0xFFEF4444);
    canvas.drawCircle(Offset(rightX + 8, limoY - 14), 2.8, Paint()..color = rightStrobe);
  }


}

class _SmokeParticle {
  double x = 0;
  double y = 0;
  double life = 0;
  double scale = 1.0;
}

/// 🏡 Seamless Drop-in Widget with In-Place Color Customizer
/// 🏡 Seamless Drop-in Widget with In-Place Color Customizer
class FlameEnglishHouseWidget extends StatefulWidget {
  final int currentDay;
  final int streak;
  final bool? isDamaged;
  final String? houseId;
  final String? paletteId;
  final bool showTestingControls;

  const FlameEnglishHouseWidget({
    super.key,
    required this.currentDay,
    this.streak = 1,
    this.isDamaged,
    this.houseId,
    this.paletteId,
    this.showTestingControls = false,
  });

  @override
  State<FlameEnglishHouseWidget> createState() => _FlameEnglishHouseWidgetState();
}

class _FlameEnglishHouseWidgetState extends State<FlameEnglishHouseWidget> {
  late FlameEnglishHouseGame _game;
  HousePalette _currentPalette = HousePalette.presets[0];
  HouseDefenseStatus _defenseStatus = const HouseDefenseStatus();
  late int _previewDay;

  @override
  void initState() {
    super.initState();
    _previewDay = widget.currentDay.clamp(1, 90);
    if (widget.paletteId != null) {
      _currentPalette = HousePalette.getById(widget.paletteId!);
    } else {
      _loadSavedPalette();
    }
    
    // Only load local defense status if isDamaged was not explicitly provided
    if (widget.isDamaged == null && (widget.houseId == null || widget.houseId == 'me')) {
      _loadDefenseStatus();
    }

    _game = FlameEnglishHouseGame(
      currentDay: _previewDay,
      streak: widget.streak,
      initialPalette: _currentPalette,
      isDamaged: widget.isDamaged ?? false,
    );
  }

  void _stepPreviewDay(int delta) {
    HapticFeedback.selectionClick();
    final newDay = (_previewDay + delta).clamp(1, 90);
    if (newDay != _previewDay) {
      setState(() {
        _previewDay = newDay;
      });
      _game.updateDayAndStreak(_previewDay, widget.streak);
    }
  }

  void _setPreviewDay(int newDay) {
    HapticFeedback.lightImpact();
    final clamped = newDay.clamp(1, 90);
    setState(() {
      _previewDay = clamped;
    });
    _game.updateDayAndStreak(_previewDay, widget.streak);
  }

  String _getEstateStageTitle(int d) {
    switch (d) {
      case 1: return '🛖 Cozy Storybook Cottage';
      case 2: return '🛖 Shingle Porch Awning';
      case 3: return '🛖 English Garden Flowerbeds';
      case 4: return '🛖 Red Brick Hearth & Chimney';
      case 5: return '🛖 Cobblestone Garden Walkway';
      case 6: return '🛖 Picket Fence & Garden Gate';
      case 7: return '🏡 Cottage Wing & Attic Dormer';
      case 8: return '🏠 3-Story Storybook Townhouse';
      case 9: return '🏠 Cantilevered Ground Wing';
      case 10: return '🏠 Cantilevered Upper Bay Room';
      case 11: return '🏠 Side Wing & Wooden Staircase';
      case 12: return '🏠 Turret Dormer & Portal Window';
      case 13: return '🏠 French Mansard Double Dormers';
      case 14: return '🏠 Cascading Rose Flower Boxes';
      case 15: return '🏠 Grand Entrance Arched Pediment';
      case 16: return '🏡 2-Story Chateau Central Hall';
      case 17: return '🏡 West Wing Bedchamber Suite';
      case 18: return '🏡 East Wing Library & Study';
      case 19: return '🏡 Dual French Mansard Slate Roofs';
      case 20: return '🏡 Symmetrical Arched Dormers';
      case 21: return '🏡 Fluted Veranda Columns & Lamps';
      case 22: return '🏡 Garden Tea Gazebo Pavilion';
      case 23: return '🏡 Courtyard Cascading Stone Fountain';
      case 24: return '🏡 Cobblestone Garden Walkway';
      case 25: return '🏡 Classical Colonnaded Porch';
      case 26: return '🏡 Rooftop Golden Eagle Weathervane';
      case 27: return '🏡 Grand Perimeter Carriage Gateway';
      case 28: return '🏛️ Grand Victorian Manor & Slate Mansard';
      case 29: return '🏛️ Classical 4-Pillar Entrance Portico';
      case 30: return '🏛️ Central Chateau Clock Spire Tower';
      case 31: return '🏛️ Wrought-Iron Rooftop Cresting';
      case 32: return '🏛️ Quad Arched Mansard Dormers';
      case 33: return '🏛️ First-Floor Terrace Stone Balustrade';
      case 34: return '🏛️ Terraced Grand Marble Steps & Runner';
      case 35: return '🏛️ Twin Cascading Courtyard Fountains';
      case 36: return '🏛️ Left Glasshouse Conservatory Winter Garden';
      case 37: return '🏛️ Right Wing Stone Balustraded Terrace';
      case 38: return '🏛️ Twin Sculpted Guardian Lions';
      case 39: return '🏛️ Formal Geometric Parterre Topiary Gardens';
      case 40: return '🏛️ Covered Porte-Cochère Carriage Portico';
      case 41: return '🏛️ Stately Perimeter Stone Pillars & Lamps';
      case 42: return '🏛️ Circular Estate Driveway & Medallion';
      case 43: return '🏛️ Rooftop Bronze Classical Statues';
      case 44: return '🏛️ Flanking Estate Stone Guard Lodges';
      case 45: return '🏛️ Royal Spear Boundary Gate';
      case 46: return '🏰 Fortress Heavy Stone Ramparts';
      case 47: return '🏰 Machicolated Stone Battlements';
      case 48: return '🏰 West Bastion Flanking Stone Tower';
      case 49: return '🏰 West Bastion Arrow Loop Embrasures';
      case 50: return '🏰 West Tower Crenellated Crown';
      case 51: return '🏰 West Tower Conical Slate Turret';
      case 52: return '🏰 Reinforced Portcullis Iron Gate';
      case 53: return '🏰 Western Connecting Aerial Arcade';
      case 54: return '🏰 East Bastion Flanking Stone Tower';
      case 55: return '🏰 East Bastion Arrow Loop Embrasures';
      case 56: return '🏰 East Tower Crenellated Crown';
      case 57: return '🏰 East Tower Conical Slate Turret';
      case 58: return '🏰 Eastern Connecting Aerial Arcade';
      case 59: return '🏰 Rampart Bronze Heavy Cannons';
      case 60: return '🏰 Sovereign Spear Rampart Gates';
      case 61: return '🏰 Massive Donjon Great Keep';
      case 62: return '🏰 Keep Lancet Stained Glass Windows';
      case 63: return '🏰 Keep Machicolated Parapet Corbels';
      case 64: return '🏰 West Rear Octagonal Spire Tower';
      case 65: return '🏰 East Rear Octagonal Spire Tower';
      case 66: return '🏰 Aerial Defensive Battle-Bridge';
      case 67: return '🏰 Citadel Bronze Signal Belfry';
      case 68: return '🏰 Flanking Flying Stone Buttresses';
      case 69: return '🏰 Fortress Ballista Emplacements';
      case 70: return '🏰 Citadel Royal Standard Mast';
      case 71: return '🏰 Castle Moat & Heavy Drawbridge';
      case 72: return '🏰 Western Outer Barbican Watchtower';
      case 73: return '🏰 Eastern Outer Barbican Watchtower';
      case 74: return '🏰 Citadel War Horns & Heraldic Standards';
      case 75: return '🏰 High Citadel 3rd Story Royal Gallery';
      case 76: return '🏰 Twin Cantilevered Corner Bartizans';
      case 77: return '🏰 Machicolated Parapet & Gilded Cresting';
      case 78: return '🏰 Soaring Octagonal Chateau Clock Spire';
      case 79: return '🏰 Upper Rampart Heavy Bronze Cannons';
      case 80: return '🏰 Sprawling Perimeter Stone Curtain Walls';
      case 81: return '🏰 Western Outer Gatehouse Fortified Tower';
      case 82: return '🏰 Eastern Outer Gatehouse Fortified Tower';
      case 83: return '🏰 Grand Triumphal Barbican Gate Arch';
      case 84: return '🏰 High Aerial Stone Viaduct Skybridges';
      case 85: return '🏰 Royal Imperial War Standards & Pennants';
      case 86: return '🏰 Extended Perimeter Deep Water Moat';
      case 87: return '🏰 Quad Cascading Royal Courtyard Fountains';
      case 88: return '🏰 Quad Sculpted Golden Guardian Lions';
      case 89: return '🏰 Citadel Night Sconces, Torches & Braziers';
      case 90: return '🏛️ Monumental Rajput Imperial Palace Apex';
      default: return '🏰 Monumental Estate';
    }
  }

  void _showDayTestingSheet() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estate Day Testing Lab',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Scrub & inspect house stages from Day 1 to Day 90',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Active Day & Stage Name
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5), width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getEstateStageTitle(_previewDay),
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Day $_previewDay / 90',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Live Scrubbing Slider
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.amberAccent, size: 24),
                      onPressed: _previewDay > 1
                          ? () {
                              _stepPreviewDay(-1);
                              setSheetState(() {});
                            }
                          : null,
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                          activeTrackColor: const Color(0xFFFFD700),
                          inactiveTrackColor: Colors.white12,
                          thumbColor: const Color(0xFFFFD700),
                          overlayColor: const Color(0xFFFFD700).withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: _previewDay.toDouble(),
                          min: 1,
                          max: 90,
                          divisions: 89,
                          onChanged: (val) {
                            final d = val.round();
                            if (d != _previewDay) {
                              _setPreviewDay(d);
                              setSheetState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.amberAccent, size: 24),
                      onPressed: _previewDay < 90
                          ? () {
                              _stepPreviewDay(1);
                              setSheetState(() {});
                            }
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Quick Jump Milestone Pills
                const Text(
                  'Quick Milestone Jump:',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildMilestonePill(1, 'Day 1: Cottage', setSheetState),
                    _buildMilestonePill(8, 'Day 8: Townhouse Base (Image 3)', setSheetState),
                    _buildMilestonePill(11, 'Day 11: Cantilevered Townhouse (Image 3)', setSheetState),
                    _buildMilestonePill(15, 'Day 15: Grand Townhouse (Image 3)', setSheetState),
                    _buildMilestonePill(28, 'Day 28: Victorian Manor', setSheetState),
                    _buildMilestonePill(46, 'Day 46: Fort Keep (വലിയ കോട്ട)', setSheetState),
                    _buildMilestonePill(71, 'Day 71: Arcaded Rajput Palace (Image 1)', setSheetState),
                    _buildMilestonePill(86, 'Day 86: Chhatri Durbar Palace (Image 2)', setSheetState),
                    _buildMilestonePill(90, 'Day 90: Sovereign Imperial Apex', setSheetState),
                  ],
                ),
                const SizedBox(height: 16),

                // Reset to Real Day Button
                if (_previewDay != widget.currentDay)
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _setPreviewDay(widget.currentDay);
                        setSheetState(() {});
                      },
                      icon: const Icon(Icons.restore, size: 16, color: Color(0xFF38BDF8)),
                      label: Text(
                        'Reset to My Real Progress (Day ${widget.currentDay})',
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMilestonePill(int targetDay, String label, StateSetter setSheetState) {
    final isSelected = _previewDay == targetDay;
    return GestureDetector(
      onTap: () {
        _setPreviewDay(targetDay);
        setSheetState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white12,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _loadDefenseStatus() async {
    final s = await PocketFortressDefenseService.getHouseStatus(widget.currentDay);
    if (mounted) {
      setState(() {
        _defenseStatus = s;
        if (widget.isDamaged == null) {
          _game.updateDamage(s.isDamaged);
        }
      });
    }
  }

  Future<void> _loadSavedPalette() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('house_theme_palette_id');
      if (savedId != null && mounted) {
        setState(() {
          _currentPalette = HousePalette.getById(savedId);
          _game.updatePalette(_currentPalette);
        });
      }
    } catch (_) {}
  }

  Future<void> _savePalette(HousePalette p) async {
    setState(() {
      _currentPalette = p;
      _game.updatePalette(p);
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('house_theme_palette_id', p.id);
      await PocketFortressDefenseService.saveUserHousePalette(p.id);
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant FlameEnglishHouseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDay != widget.currentDay || oldWidget.streak != widget.streak) {
      _previewDay = widget.currentDay.clamp(1, 90);
      _game.updateDayAndStreak(_previewDay, widget.streak);
      if (widget.isDamaged == null && (widget.houseId == null || widget.houseId == 'me')) {
        _loadDefenseStatus();
      }
      setState(() {});
    }
    if (widget.isDamaged != null && widget.isDamaged != oldWidget.isDamaged) {
      _game.updateDamage(widget.isDamaged!);
    }
    if (widget.paletteId != null && widget.paletteId != oldWidget.paletteId) {
      _currentPalette = HousePalette.getById(widget.paletteId!);
      _game.updatePalette(_currentPalette);
    }
  }

  void _openPalettePicker() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B111E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🎨', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                const Text(
                  'House Theme Color',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Customize the colors of your progressive English Manor & Palace.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: HousePalette.presets.map((p) {
                final isSelected = p.id == _currentPalette.id;
                return GestureDetector(
                  onTap: () {
                    _savePalette(p);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? p.accentColor.withValues(alpha: 0.20)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? p.accentColor : Colors.white12,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: p.roofColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70, width: 1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          p.name,
                          style: TextStyle(
                            color: isSelected ? p.accentColor : Colors.white,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔍 Fullscreen Interactive Estate Inspector (Zoom & Pan colossal multi-building citadel)
  void _openFullscreenEstateViewer() {
    HapticFeedback.mediumImpact();
    final day = _previewDay;
    String estateTitle;
    String estateSubtitle;
    if (day >= 90) {
      estateTitle = '👑 Sovereign Imperial Fort & Citadel';
      estateSubtitle = 'Day 90 Apex Fort • 24K Eagle Crown & Imperial Motorcade';
    } else if (day >= 81) {
      estateTitle = '🏛️ Monumental Royal Imperial Citadel';
      estateSubtitle = 'Day 81+ • Royal Mezzanine Citadel & Marble Ramparts';
    } else if (day >= 71) {
      estateTitle = '🏰 Sprawling Grand Fort Citadel';
      estateSubtitle = 'Day 71+ • High Watchtowers, Spires & Bastions';
    } else if (day >= 46) {
      estateTitle = '🏰 Fortified Stone Keep & Manor';
      estateSubtitle = 'Day 46+ • Battlements, Rear Wings & Victorian Portico';
    } else if (day >= 28) {
      estateTitle = '🏛️ Grand Victorian Country Manor';
      estateSubtitle = 'Day 28+ • Ashlar Stone, Colonnaded Portico & Dormers';
    } else if (day >= 16) {
      estateTitle = '🏡 Two-Story Balcony Villa';
      estateSubtitle = 'Day 16+ • Mansard Roof, Balconies & Garden Wings';
    } else if (day >= 8) {
      estateTitle = '🏡 Country Garden Cottage';
      estateSubtitle = 'Day 8+ • Expanded Wings, Oak Door & Orchard';
    } else {
      estateTitle = '🛖 Storybook English Cottage';
      estateSubtitle = 'Days 1–7 • Cozy Hearth, Garden Beds & Lanterns';
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _currentPalette.accentColor.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _currentPalette.accentColor.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 14, 14, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.85),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                estateTitle,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                estateSubtitle,
                                style: GoogleFonts.inter(
                                  color: _currentPalette.accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Interactive Zoom & Pan Area
                  Flexible(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.70,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: InteractiveViewer(
                              minScale: 0.7,
                              maxScale: 3.8,
                              boundaryMargin: const EdgeInsets.all(120),
                              child: Center(
                                child: SizedBox(
                                  width: 440,
                                  height: 520,
                                  child: GameWidget(
                                    game: FlameEnglishHouseGame(
                                      currentDay: _previewDay,
                                      streak: widget.streak,
                                      initialPalette: _currentPalette,
                                      isDamaged: _defenseStatus.isDamaged,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Hint pill at bottom
                          Positioned(
                            bottom: 12,
                            left: 20,
                            right: 20,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.78),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24, width: 1),
                                ),
                                child: Text(
                                  '🔍 Pinch to zoom • Drag to explore wings & citadel • Tap house for glow',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double widgetHeight = _previewDay >= 71
        ? 520.0
        : (_previewDay >= 36 ? 460.0 : 420.0);
    return SizedBox(
      height: widgetHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // 🏡 Flame 2D Interactive Game View
          Positioned.fill(
            child: GameWidget(game: _game),
          ),

          if (widget.showTestingControls) ...[
            // 🚫 Condemned by Presidential Decree Banner
            if (_defenseStatus.isBanned)
            Positioned(
              top: 38,
              left: 14,
              right: 14,
              child: GestureDetector(
                onTap: () async {
                  PocketDefenseTrapModal.show(context, widget.currentDay);
                  await Future.delayed(const Duration(milliseconds: 500));
                  _loadDefenseStatus();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF450A0A), Color(0xFF7F1D1D)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🚫', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'CONDEMNED BY PRESIDENTIAL DECREE • TAP TO REBUILD',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'REBUILD',
                          style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          // ⚖️ President Call Pending Inspection Banner
          else if (_defenseStatus.isUnderPresidentInspection)
            Positioned(
              top: 38,
              left: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF78350F), Color(0xFF92400E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amberAccent, width: 1.2),
                ),
                child: Row(
                  children: [
                    const Text('⚖️', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'PRESIDENT CALL PENDING • AUDIT IN PROGRESS',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          // 🏚️ Damaged House Alert Ribbon (Visible when breached in a raid)
          else if (_defenseStatus.isDamaged || _defenseStatus.currentHp < 100)
            Positioned(
              top: 38,
              left: 14,
              right: 14,
              child: GestureDetector(
                onTap: () async {
                  PocketDefenseTrapModal.show(context, widget.currentDay);
                  await Future.delayed(const Duration(milliseconds: 500));
                  _loadDefenseStatus();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7F1D1D), Color(0xFF991B1B)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('🏚️', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'HOUSE DAMAGED IN RAID (${_defenseStatus.currentHp}/100 HP) • TAP TO REPAIR',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('REPAIR', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ⚡ ROW 1: Dedicated Day Testing Bar (Fixed, Non-scrolling, 100% visible on any phone!)
          Positioned(
            top: 6,
            left: 8,
            right: 8,
            child: Row(
              children: [
                // ◀ PREV Button
                GestureDetector(
                  onTap: () => _stepPreviewDay(-1),
                  onLongPress: () => _stepPreviewDay(-5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.3),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 6),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new_rounded, size: 13, color: Color(0xFFFFD700)),
                        SizedBox(width: 3),
                        Text('PREV', style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Center Stage & Day Badge (Tap to open full 1-90 testing sheet)
                Expanded(
                  child: GestureDetector(
                    onTap: _showDayTestingSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _previewDay != widget.currentDay ? const Color(0xFF38BDF8) : const Color(0xFFFFD700),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_previewDay != widget.currentDay ? const Color(0xFF38BDF8) : const Color(0xFFFFD700)).withValues(alpha: 0.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _previewDay >= 90 ? '👑' : (_previewDay >= 71 ? '🏛️' : (_previewDay >= 28 ? '🏰' : (_previewDay >= 8 ? '🏠' : '🛖'))),
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Day $_previewDay/90 • ${_getEstateStageTitle(_previewDay)}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _previewDay != widget.currentDay ? const Color(0xFF38BDF8) : const Color(0xFFFFD700),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // NEXT ▶ Button
                GestureDetector(
                  onTap: () => _stepPreviewDay(1),
                  onLongPress: () => _stepPreviewDay(5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.3),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 6),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('NEXT', style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.w900)),
                        SizedBox(width: 3),
                        Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFFFFD700)),
                      ],
                    ),
                  ),
                ),

                // Reset Button if previewing a different day
                if (_previewDay != widget.currentDay) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _setPreviewDay(widget.currentDay),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF38BDF8), width: 1.2),
                      ),
                      child: const Icon(Icons.restore, size: 15, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 🎮 ROW 2: Secondary Utility Controls (Pocket World, Theme, Zoom)
          Positioned(
            top: 45,
            left: 8,
            right: 8,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🌍 Pocket World Button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PocketWorldStreetPage(
                            currentDay: _previewDay,
                            streak: widget.streak,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF38BDF8),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🌍', style: TextStyle(fontSize: 11)),
                          SizedBox(width: 4),
                          Text(
                            'Pocket World',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // 🎨 Theme Switcher Button
                  GestureDetector(
                    onTap: _openPalettePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _currentPalette.accentColor.withValues(alpha: 0.65),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎨', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),
                          Text(
                            _currentPalette.name.split(' ').sublist(1).join(' '),
                            style: TextStyle(
                              color: _currentPalette.accentColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // 🔍 Zoom Estate Button
                  GestureDetector(
                    onTap: _openFullscreenEstateViewer,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.75),
                          width: 1.0,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔍', style: TextStyle(fontSize: 11)),
                          SizedBox(width: 4),
                          Text(
                            'Zoom Estate',
                            style: TextStyle(
                              color: Color(0xFFFDE68A),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ◀ Giant Floating Left Side Navigation Button on Canvas
          Positioned(
            left: 6,
            top: widgetHeight * 0.44,
            child: GestureDetector(
              onTap: () => _stepPreviewDay(-1),
              onLongPress: () => _stepPreviewDay(-5),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.85), width: 1.4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.chevron_left_rounded, color: Color(0xFFFFD700), size: 24),
                ),
              ),
            ),
          ),

          // ▶ Giant Floating Right Side Navigation Button on Canvas
          Positioned(
            right: 6,
            top: widgetHeight * 0.44,
            child: GestureDetector(
              onTap: () => _stepPreviewDay(1),
              onLongPress: () => _stepPreviewDay(5),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.85), width: 1.4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.chevron_right_rounded, color: Color(0xFFFFD700), size: 24),
                ),
              ),
            ),
          ),

          // 🛡️ Bottom Floating Controls (Live House HP, Arsenal Store, Defense Traps)
          Positioned(
            bottom: 8,
            left: 10,
            right: 10,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ❤️ Live House HP & Defense Vault Button
                  GestureDetector(
                    onTap: () async {
                      PocketDefenseTrapModal.show(context, widget.currentDay);
                      await Future.delayed(const Duration(milliseconds: 500));
                      _loadDefenseStatus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _defenseStatus.currentHp < 100 ? Colors.redAccent : const Color(0xFF10B981),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_defenseStatus.currentHp < 100 ? Colors.redAccent : const Color(0xFF10B981))
                                .withValues(alpha: 0.25),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_defenseStatus.currentHp < 100 ? '💔' : '❤️', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Text(
                            '${_defenseStatus.currentHp} HP',
                            style: GoogleFonts.outfit(
                              color: _defenseStatus.currentHp < 100 ? Colors.redAccent : const Color(0xFF34D399),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (_defenseStatus.hasIronDome) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00F0FF).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFF00F0FF), width: 0.8),
                              ),
                              child: const Text('DOME', style: TextStyle(color: Color(0xFF00F0FF), fontSize: 8.5, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 🏪 Fortress Arsenal Store Button
                  GestureDetector(
                    onTap: () {
                      PocketArsenalStoreModal.show(
                        context,
                        currentDay: widget.currentDay,
                        onPurchased: _loadDefenseStatus,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB45309), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.25),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🏪', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 4),
                          Text(
                            'Store',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 🛡️ House Defense Traps Button
                  GestureDetector(
                    onTap: () {
                      PocketDefenseTrapModal.show(context, widget.currentDay);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🛡️', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Text(
                            'Defense Traps',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
      ),
    );
  }
}
