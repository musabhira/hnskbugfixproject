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
import 'pocket_vehicle_garage_modal.dart';
import 'pocket_world_street_page.dart';
import 'pocket_arsenal_store_modal.dart';
import 'day90_vip_master_card_dialog.dart';

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
  final int currentDay;
  final int streak;
  HousePalette palette;
  bool isDamaged;

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

    // 1. Transparent atmosphere with drifting clouds, twinkling stars, & flying birds
    atmosphereComponent = AtmosphereComponent(day: currentDay);
    add(atmosphereComponent);

    // 2. The progressive cartoon house / Victorian manor
    houseComponent = HouseMasterComponent(
      day: currentDay,
      streak: streak,
      palette: palette,
      isDamaged: isDamaged,
    );
    add(houseComponent);
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
  final int day;
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
  final int day;
  final int streak;
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

    // 1. Garden lawn & stone pathway
    _renderLawnAndPath(canvas, cx, groundY);

    // 2. THE MULTI-STAGE PROGRESSION:
    if (day >= 81) {
      // 👑 DAYS 81–90: THE MAJESTIC IMPERIAL PALACE CITADEL ("വലിയൊരു കൊട്ടാരം പോലെ")
      // Sprawling multi-wing palace with auxiliary bastion watchtowers, connecting colonnaded arcades,
      // grand tiered dome lantern spire, twin courtyard fountains, and imperial gates!
      _renderImperialPalaceCitadel(canvas, cx, groundY);
    } else if (day >= 71) {
      // 🌟 DAYS 71–80: THE MAJESTIC GRAND VICTORIAN MANOR ESTATE (Reference Image 2!)
      // Colonnaded porch, central chateau spire tower, dormers, and 4 tall chimneys!
      _renderGrandVictorianManor(canvas, cx, groundY);
    } else {
      // 🏡 DAYS 1–70: PROGRESSIVE COTTAGE TO PYRAMID MANOR (Reference Image 1)
      if (day >= 11) _renderLeftWing(canvas, cx, groundY);
      if (day >= 26) _renderRightWing(canvas, cx, groundY);
      _renderCoreCottage(canvas, cx, groundY);
      if (day >= 41) _renderSecondFloorCenter(canvas, cx, groundY);
      if (day >= 56) _renderSecondFloorWings(canvas, cx, groundY);

      // Distinct, prominent daily garden & house upgrades for Days 1-10:
      if (day >= 2) _renderDay2FrontPorchAwning(canvas, cx, groundY);
      if (day >= 3) _renderDay3GardenFlowerBeds(canvas, cx, groundY);
      if (day >= 6) _renderDay6PicketFence(canvas, cx, groundY);
      if (day >= 7) _renderDay7StreetLamps(canvas, cx, groundY);
      if (day >= 8) _renderDay8AppleTree(canvas, cx, groundY);
      if (day >= 9) _renderDay9GardenFountain(canvas, cx, groundY);
    }

    // 3. Chimney Smoke Particles (Unlocked at Day 4)
    if (day >= 81) {
      _renderSmoke(canvas, cx - 174, groundY - 240);
      _renderSmoke(canvas, cx - 54, groundY - 250);
      _renderSmoke(canvas, cx + 54, groundY - 250);
      _renderSmoke(canvas, cx + 174, groundY - 240);
    } else if (day >= 71) {
      _renderSmoke(canvas, cx - 52, groundY - 240);
      _renderSmoke(canvas, cx + 52, groundY - 240);
    } else if (day >= 4) {
      final chimX = cx - 54;
      final chimY = (day >= 41) ? groundY - 210 : groundY - 175;
      _renderSmoke(canvas, chimX, chimY);
    }

    // 4. Lush Green Bushes & Garden Trees flanking the estate
    _renderBushes(canvas, cx, groundY);

    // 5. 👑 Day 90 VIP Fleet: 24K Sovereign Limousine + 2 Armed Tactical Escorts (Alpha & Bravo)
    if (day >= 90) {
      _renderDay90VipMotorcade(canvas, cx, groundY);
    }

    // 6. 💥 House Damage & Rubble Visuals (Breach Aftermath)
    if (isDamaged) {
      _renderDamageOverlay(canvas, cx, groundY);
    }
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

  // ============================================================
  // 🏰 2. THE MAJESTIC GRAND VICTORIAN MANOR (DAYS 71–90, IMAGE 2)
  // ============================================================
  void _renderGrandVictorianManor(Canvas canvas, double cx, double groundY) {
    final estateWidth = (day >= 85) ? 346.0 : 320.0;
    final wingWidth = (day >= 85) ? 122.0 : 110.0;
    const centerWidth = 78.0;
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

    // --- Second Floor Sash Windows (Symmetrical Grand Estate Rows) ---
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

    // --- Left & Right Mansard Roofs with Ornate Dormers ---
    _renderVictorianMansardRoof(canvas, cx - 92 - wingWinOffset * 0.5, floor2Top, wingWidth + 16, isLeft: true);
    _renderVictorianMansardRoof(canvas, cx + 92 + wingWinOffset * 0.5, floor2Top, wingWidth + 16, isLeft: false);

    // Arched Dormer Windows on Wing Roofs
    _renderVictorianArchedDormer(canvas, cx - 90 - wingWinOffset * 0.5, floor2Top - 22, 24, 30);
    _renderVictorianArchedDormer(canvas, cx + 90 + wingWinOffset * 0.5, floor2Top - 22, 24, 30);

    // --- Central Chateau Spire Tower (Soaring Peak with Finial) ---
    _renderCentralChateauTower(canvas, cx, floor2Top, centerWidth);

    // --- 4 Tall Brick Chimneys ---
    final outerChimX = (day >= 85) ? 152.0 : 138.0;
    _renderChimneyShaft(canvas, cx - outerChimX, floor2Top - 36, 16, 42);
    _renderChimneyShaft(canvas, cx - 50, floor2Top - 44, 16, 48);
    _renderChimneyShaft(canvas, cx + 50, floor2Top - 44, 16, 48);
    _renderChimneyShaft(canvas, cx + outerChimX, floor2Top - 36, 16, 42);

    // --- Colonnaded Porch / Veranda (Full Width Ground Floor) ---
    _renderColonnadedPorch(canvas, cx, groundY, estateWidth, floor1Height);

    // --- Grand Central Sweeping Front Steps ---
    _renderGrandSteps(canvas, cx, groundY);

    // --- Days 85–90 Royal Pennants & Carriage Lamps ---
    if (day >= 85) {
      _renderRoyalBannersAndCarriageLamps(canvas, cx, groundY, floor2Top);
    }
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

  void _renderCentralChateauTower(Canvas canvas, double cx, double floor2Top, double centerW) {
    const towerH = 46.0;
    final towerTop = floor2Top - towerH;
    final towerLeft = cx - centerW / 2;

    // 3rd floor center tower wall
    canvas.drawRect(Rect.fromLTWH(towerLeft, towerTop, centerW, towerH), Paint()..color = palette.wallColor);
    canvas.drawRect(Rect.fromLTWH(towerLeft, towerTop, centerW, towerH), Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5);

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
      canvas.drawLine(Offset(cx - w / 2, y), Offset(cx + w / 2, y), Paint()..color = palette.roofUnderTrim.withValues(alpha: 0.5) ..strokeWidth = 1.5);
    }

    // Tall Pointed Finial Spire Spike at top peak
    final finialPaint = Paint()..color = palette.accentColor;
    canvas.drawLine(Offset(cx, roofPeakY), Offset(cx, roofPeakY - 18), finialPaint..strokeWidth = 2.5);
    canvas.drawCircle(Offset(cx, roofPeakY - 18), 3.0, finialPaint);
    canvas.drawCircle(Offset(cx, roofPeakY - 10), 2.0, finialPaint);
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

  // ============================================================
  // 👑 2B. THE MAJESTIC IMPERIAL PALACE CITADEL (DAYS 81–90)
  // "വലിയൊരു കൊട്ടാരം പോലെ" - Massive multi-building palace citadel
  // Auxiliary bastion watchtowers, connecting colonnaded arcades,
  // central imperial dome, clock pavilion, twin fountains, and royal gates.
  // ============================================================
  void _renderImperialPalaceCitadel(Canvas canvas, double cx, double groundY) {
    final availableW = canvasSize.x > 0 ? (canvasSize.x - 12) : 420.0;
    const estateWidth = 414.0;
    final scale = math.min(1.0, availableW / estateWidth);

    canvas.save();
    if (scale < 1.0) {
      canvas.translate(cx, groundY);
      canvas.scale(scale);
      canvas.translate(-cx, -groundY);
    }

    final baseLeft = cx - estateWidth / 2;
    final baseRight = cx + estateWidth / 2;
    const floor1Height = 68.0;
    const floor2Height = 70.0;
    final floor1Top = groundY - floor1Height;
    final floor2Top = floor1Top - floor2Height;

    // --- 1. Imperial Ashlar Stone Foundation Base ---
    final fRect = Rect.fromLTWH(baseLeft, groundY - 15, estateWidth, 15);
    canvas.drawRect(fRect, Paint()..color = palette.foundationColor);
    final fBorder = Paint()..color = Colors.black26 ..strokeWidth = 1.2;
    for (double x = baseLeft + 18; x < baseRight; x += 18) {
      canvas.drawLine(Offset(x, groundY - 15), Offset(x, groundY), fBorder);
    }
    canvas.drawLine(Offset(baseLeft, groundY - 15), Offset(baseRight, groundY - 15), fBorder);

    // --- 2. Connecting Colonnaded Bridge Arcades (Wings to Towers) ---
    _renderConnectingArcade(canvas, cx - 150, cx - 96, groundY - 15, floor2Top + 24);
    _renderConnectingArcade(canvas, cx + 96, cx + 150, groundY - 15, floor2Top + 24);

    // --- 3. Flanking Left & Right 3-Story Fortified Bastion Watchtowers ---
    _renderAuxiliaryBastionTower(canvas, cx - 174, groundY - 15, isLeft: true);
    _renderAuxiliaryBastionTower(canvas, cx + 174, groundY - 15, isLeft: false);

    // --- 4. Central Imperial Chateau Main Facade Wall ---
    const centerWidth = 192.0;
    final cLeft = cx - centerWidth / 2;
    final cRight = cx + centerWidth / 2;
    final facadeRect = Rect.fromLTWH(cLeft, floor2Top, centerWidth, floor1Height + floor2Height - 15);
    canvas.drawRect(facadeRect, Paint()..color = palette.wallColor);

    // Classical Pilasters & Quoins on Central Palace
    final quoinPaint = Paint()..color = palette.wallShade;
    for (double y = floor2Top; y < groundY - 15; y += 12) {
      canvas.drawRect(Rect.fromLTWH(cLeft, y, 9, 10), quoinPaint);
      canvas.drawRect(Rect.fromLTWH(cRight - 9, y, 9, 10), quoinPaint);
      canvas.drawRect(Rect.fromLTWH(cx - 48, y, 5, 10), quoinPaint);
      canvas.drawRect(Rect.fromLTWH(cx + 43, y, 5, 10), quoinPaint);
    }

    // --- 5. Second Floor (Piano Nobile) Windows & Royal Balcony ---
    _renderVictorianSashWindow(canvas, cx - 74, floor2Top + 34, 22, 40);
    _renderVictorianSashWindow(canvas, cx - 44, floor2Top + 34, 22, 40);
    _renderVictorianSashWindow(canvas, cx + 44, floor2Top + 34, 22, 40);
    _renderVictorianSashWindow(canvas, cx + 74, floor2Top + 34, 22, 40);

    // Central Royal French Double Doors & Balcony
    _renderRoyalBalcony(canvas, cx, floor2Top + 34);

    // --- 6. Left & Right Mansard Roofs on Central Palace Wings ---
    _renderVictorianMansardRoof(canvas, cx - 56, floor2Top, 78, isLeft: true);
    _renderVictorianMansardRoof(canvas, cx + 56, floor2Top, 78, isLeft: false);

    // Arched Dormers on Mansards
    _renderVictorianArchedDormer(canvas, cx - 56, floor2Top - 22, 24, 30);
    _renderVictorianArchedDormer(canvas, cx + 56, floor2Top - 22, 24, 30);

    // --- 7. Imperial Clock Pavilion & Central Baroque Dome Spire ---
    _renderCentralImperialDome(canvas, cx, floor2Top);

    // --- 8. 4 Tall Fluted Palace Chimneys ---
    _renderChimneyShaft(canvas, cx - 88, floor2Top - 36, 16, 44);
    _renderChimneyShaft(canvas, cx - 54, floor2Top - 46, 16, 52);
    _renderChimneyShaft(canvas, cx + 54, floor2Top - 46, 16, 52);
    _renderChimneyShaft(canvas, cx + 88, floor2Top - 36, 16, 44);

    // --- 9. Colonnaded Portico & Grand Royal Portal ---
    _renderColonnadedPorch(canvas, cx, groundY, centerWidth + 24, floor1Height);

    // --- 10. Grand Courtyard Forecourt (The Imperial Plaza) ---
    // Sweeping Marble Steps with Crimson Carpet
    _renderImperialSteps(canvas, cx, groundY);

    // Twin Marble Guardian Lion Pedestals
    _renderGuardianLionPedestal(canvas, cx - 52, groundY - 14);
    _renderGuardianLionPedestal(canvas, cx + 52, groundY - 14);

    // Twin Cascading Marble Courtyard Fountains
    _renderCourtyardFountain(canvas, cx - 134, groundY - 8);
    _renderCourtyardFountain(canvas, cx + 134, groundY - 8);

    // Wrought Iron Palace Gates with Spear Tips
    _renderPalaceSpearGates(canvas, cx, groundY, estateWidth);

    // Day 90 Royal Crown & Master Aureole
    if (day >= 90) {
      _renderDay90PalaceBanner(canvas, cx, groundY);
    }

    canvas.restore();
  }

  void _renderAuxiliaryBastionTower(Canvas canvas, double tx, double groundY, {required bool isLeft}) {
    const towerW = 48.0;
    const towerH = 152.0;
    final towerTop = groundY - towerH;
    final tLeft = tx - towerW / 2;

    // Fortified stone wall body
    final tRect = Rect.fromLTWH(tLeft, towerTop, towerW, towerH);
    canvas.drawRect(tRect, Paint()..color = palette.wallColor);

    // Corner quoins
    final qPaint = Paint()..color = palette.wallShade;
    for (double y = towerTop; y < groundY; y += 12) {
      canvas.drawRect(Rect.fromLTWH(tLeft, y, 7, 10), qPaint);
      canvas.drawRect(Rect.fromLTWH(tLeft + towerW - 7, y, 7, 10), qPaint);
    }

    // Machicolation corbels (projecting stone brackets)
    final corbelY = towerTop - 6;
    canvas.drawRect(Rect.fromLTWH(tLeft - 3, corbelY, towerW + 6, 8), Paint()..color = palette.roofTrim);
    for (double x = tLeft - 2; x <= tLeft + towerW + 2; x += 7) {
      canvas.drawRect(Rect.fromLTWH(x, corbelY + 6, 4, 6), Paint()..color = palette.roofShade);
    }

    // Lancet Stained-Glass Windows on 3rd & 2nd floors
    _renderLancetWindow(canvas, tx, towerTop + 24, 14, 28);
    _renderVictorianSashWindow(canvas, tx, towerTop + 68, 16, 30);
    // Cross arrow-slit on 1st floor
    _renderArrowSlit(canvas, tx, towerTop + 114);

    // Conical Chateau Turret Roof
    const roofH = 54.0;
    final roofPeakY = corbelY - roofH;
    final rPath = Path();
    rPath.moveTo(tLeft - 4, corbelY + 2);
    rPath.lineTo(tx, roofPeakY);
    rPath.lineTo(tLeft + towerW + 4, corbelY + 2);
    rPath.close();

    final rShader = LinearGradient(
      colors: [palette.roofColor, palette.roofShade],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(tLeft - 4, roofPeakY, towerW + 8, roofH));
    canvas.drawPath(rPath, Paint()..shader = rShader);
    canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 2.5);

    // Gilded Flagpole
    final goldPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawLine(Offset(tx, roofPeakY), Offset(tx, roofPeakY - 24), goldPaint..strokeWidth = 2.2);
    canvas.drawCircle(Offset(tx, roofPeakY - 24), 2.5, goldPaint);

    // Fluttering Royal Swallowtail Banner
    final wave = math.sin(animTimer * 4.8 + (isLeft ? 0.0 : 2.0)) * 4.5;
    const flagW = 26.0;
    const flagH = 15.0;
    final flagTop = roofPeakY - 22;
    final fPath = Path();
    final flagDir = isLeft ? -1.0 : 1.0;
    fPath.moveTo(tx, flagTop);
    fPath.lineTo(tx + flagDir * flagW, flagTop + wave);
    fPath.lineTo(tx + flagDir * (flagW - 7), flagTop + flagH / 2 + wave * 0.5);
    fPath.lineTo(tx + flagDir * flagW, flagTop + flagH + wave);
    fPath.lineTo(tx, flagTop + flagH);
    fPath.close();

    final flagColor = isLeft ? const Color(0xFF1D4ED8) : const Color(0xFFDC2626);
    canvas.drawPath(fPath, Paint()..color = flagColor);
    canvas.drawPath(fPath, Paint()..style = PaintingStyle.stroke ..color = const Color(0xFFFFD700) ..strokeWidth = 1.0);
    canvas.drawCircle(Offset(tx + flagDir * 10, flagTop + flagH / 2 + wave * 0.5), 2.0, goldPaint);
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

  void _renderArrowSlit(Canvas canvas, double cx, double cy) {
    final p = Paint()..color = const Color(0xFF0F172A) ..strokeWidth = 2.0;
    canvas.drawLine(Offset(cx, cy - 8), Offset(cx, cy + 8), p);
    canvas.drawLine(Offset(cx - 5, cy - 2), Offset(cx + 5, cy - 2), p);
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

  void _renderRoyalBalcony(Canvas canvas, double cx, double cy) {
    // Grand French double doors
    final dRect = Rect.fromCenter(center: Offset(cx, cy - 2), width: 28, height: 38);
    canvas.drawRRect(RRect.fromRectAndRadius(dRect, const Radius.circular(4)), Paint()..color = palette.windowColor);
    canvas.drawRRect(RRect.fromRectAndRadius(dRect, const Radius.circular(4)), Paint()..style = PaintingStyle.stroke ..color = Colors.white ..strokeWidth = 2.0);
    canvas.drawLine(Offset(cx, dRect.top), Offset(cx, dRect.bottom), Paint()..color = Colors.white ..strokeWidth = 1.2);

    // Projecting marble balcony slab
    final bRect = Rect.fromCenter(center: Offset(cx, cy + 19), width: 38, height: 6);
    canvas.drawRRect(RRect.fromRectAndRadius(bRect, const Radius.circular(2)), Paint()..color = const Color(0xFFF1F5F9));
    canvas.drawRRect(RRect.fromRectAndRadius(bRect, const Radius.circular(2)), Paint()..style = PaintingStyle.stroke ..color = const Color(0xFF94A3B8) ..strokeWidth = 1.0);

    // Balustrade railing with gold monogram
    const rH = 13.0;
    final rTop = bRect.top - rH;
    canvas.drawLine(Offset(bRect.left + 1, rTop), Offset(bRect.right - 1, rTop), Paint()..color = const Color(0xFFFFD700) ..strokeWidth = 1.5);
    for (double bx = bRect.left + 4; bx <= bRect.right - 4; bx += 4.5) {
      canvas.drawLine(Offset(bx, rTop), Offset(bx, bRect.top), Paint()..color = Colors.white ..strokeWidth = 1.2);
    }
    // Golden Royal Medallion in center
    canvas.drawCircle(Offset(cx, rTop + rH / 2), 4.5, Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(Offset(cx, rTop + rH / 2), 2.5, Paint()..color = const Color(0xFFB45309));
  }

  void _renderCentralImperialDome(Canvas canvas, double cx, double floor2Top) {
    const centerW = 86.0;
    const pavilionH = 46.0;
    final pTop = floor2Top - pavilionH;
    final pLeft = cx - centerW / 2;

    // 1. Clock Pavilion Wall (Floor 3 Center)
    final pRect = Rect.fromLTWH(pLeft, pTop, centerW, pavilionH);
    canvas.drawRect(pRect, Paint()..color = palette.wallColor);
    canvas.drawRect(pRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 2.0);

    // 2. Central Imperial Clock
    final clockCenter = Offset(cx, pTop + 23);
    canvas.drawCircle(clockCenter, 14.5, Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(clockCenter, 12.0, Paint()..color = Colors.white);
    // Hour markings
    final markPaint = Paint()..color = const Color(0xFF0F172A) ..strokeWidth = 1.2;
    canvas.drawLine(clockCenter - const Offset(0, 11), clockCenter - const Offset(0, 8), markPaint); // XII
    canvas.drawLine(clockCenter + const Offset(0, 8), clockCenter + const Offset(0, 11), markPaint); // VI
    canvas.drawLine(clockCenter - const Offset(11, 0), clockCenter - const Offset(8, 0), markPaint); // IX
    canvas.drawLine(clockCenter + const Offset(8, 0), clockCenter + const Offset(11, 0), markPaint); // III
    // Clock hands pointing to 10:10
    canvas.drawLine(clockCenter, clockCenter + const Offset(-4, -6), Paint()..color = const Color(0xFF0F172A) ..strokeWidth = 1.6);
    canvas.drawLine(clockCenter, clockCenter + const Offset(6, -4), Paint()..color = const Color(0xFF0F172A) ..strokeWidth = 1.2);
    canvas.drawCircle(clockCenter, 1.8, Paint()..color = const Color(0xFFFFD700));

    // Flanking Dormers on Clock Pavilion
    _renderVictorianArchedDormer(canvas, cx - 28, pTop + 24, 16, 24);
    _renderVictorianArchedDormer(canvas, cx + 28, pTop + 24, 16, 24);

    // 3. Baroque Dome Drum
    const drumW = 66.0;
    const drumH = 14.0;
    final drumTop = pTop - drumH;
    final drumRect = Rect.fromLTWH(cx - drumW / 2, drumTop, drumW, drumH);
    canvas.drawRect(drumRect, Paint()..color = palette.wallShade);
    canvas.drawRect(drumRect, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 1.5);
    // 3 Drum Windows
    for (int i = -1; i <= 1; i++) {
      final dx = cx + i * 18.0;
      final dWin = Rect.fromCenter(center: Offset(dx, drumTop + 7), width: 8, height: 9);
      canvas.drawRRect(RRect.fromRectAndRadius(dWin, const Radius.circular(3)), Paint()..color = lightsOn ? palette.windowColor : const Color(0xFF1E293B));
    }

    // 4. Grand Soaring Bell-Curve Dome
    const domeW = 74.0;
    const domeH = 46.0;
    final domeTop = drumTop - domeH;
    final dPath = Path();
    dPath.moveTo(cx - domeW / 2, drumTop);
    dPath.cubicTo(cx - domeW / 2 + 6, drumTop - domeH * 0.7, cx - 18, domeTop + 6, cx, domeTop);
    dPath.cubicTo(cx + 18, domeTop + 6, cx + domeW / 2 - 6, drumTop - domeH * 0.7, cx + domeW / 2, drumTop);
    dPath.close();

    final domeShader = LinearGradient(
      colors: [palette.roofColor, palette.roofShade],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(cx - domeW / 2, domeTop, domeW, domeH));
    canvas.drawPath(dPath, Paint()..shader = domeShader);
    canvas.drawPath(dPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 2.5);

    // Gilded Vertical Ribs on Dome
    final ribPaint = Paint()..color = const Color(0xFFFFD700) ..strokeWidth = 1.5 ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, domeTop), Offset(cx, drumTop), ribPaint);
    final leftRib = Path()..moveTo(cx - domeW * 0.28, drumTop)..quadraticBezierTo(cx - 12, domeTop + 14, cx, domeTop);
    final rightRib = Path()..moveTo(cx + domeW * 0.28, drumTop)..quadraticBezierTo(cx + 12, domeTop + 14, cx, domeTop);
    canvas.drawPath(leftRib, ribPaint);
    canvas.drawPath(rightRib, ribPaint);

    // 5. Open Lantern Cupola & Spire
    const cupolaW = 18.0;
    const cupolaH = 14.0;
    final cupolaTop = domeTop - cupolaH;
    final cRect = Rect.fromLTWH(cx - cupolaW / 2, cupolaTop, cupolaW, cupolaH);
    canvas.drawRect(cRect, Paint()..color = Colors.white);
    // Lantern columns
    canvas.drawLine(Offset(cx - 6, cupolaTop), Offset(cx - 6, domeTop), Paint()..color = const Color(0xFF64748B) ..strokeWidth = 1.2);
    canvas.drawLine(Offset(cx + 6, cupolaTop), Offset(cx + 6, domeTop), Paint()..color = const Color(0xFF64748B) ..strokeWidth = 1.2);
    // Lantern bell cap
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cupolaTop), width: cupolaW + 4, height: 10), math.pi, math.pi, true, Paint()..color = const Color(0xFFFFD700));

    // Tall Gilded Finial Spire
    final finialTop = cupolaTop - 24;
    final fPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawLine(Offset(cx, cupolaTop), Offset(cx, finialTop), fPaint..strokeWidth = 2.5);
    canvas.drawCircle(Offset(cx, finialTop), 3.5, fPaint);
    canvas.drawCircle(Offset(cx, finialTop + 8), 2.2, fPaint);

    // 👑 DAY 90 MASTER PERK: Imperial Sovereign Eagle Crown at pinnacle!
    if (day >= 90) {
      final crownCenter = Offset(cx, finialTop - 6);
      canvas.drawCircle(crownCenter, 6.0, Paint()..color = const Color(0xFFFFD700));
      canvas.drawCircle(crownCenter, 3.5, Paint()..color = const Color(0xFFDC2626));
      // Corona rays
      for (double a = -0.7; a <= 0.7; a += 0.35) {
        final rx = cx + math.sin(a) * 9.0;
        final ry = crownCenter.dy - math.cos(a) * 9.0;
        canvas.drawLine(crownCenter, Offset(rx, ry), Paint()..color = const Color(0xFFFFD700) ..strokeWidth = 1.5);
      }
    }
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
    final bannerRect = Rect.fromCenter(center: Offset(cx, groundY + 18), width: 250, height: 18);
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
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, groundY + 18 - textPainter.height / 2));
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
    _renderCoreRoof(canvas, cx, wallTop, wallWidth);
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

  void _renderLeftWing(Canvas canvas, double cx, double groundY) {
    const wingWidth = 60.0;
    const wingHeight = 84.0;
    final wingLeft = cx - 88.0 - wingWidth;
    final wingTop = groundY - wingHeight;

    canvas.drawRect(Rect.fromLTWH(wingLeft, groundY - 16, wingWidth, 16), Paint()..color = palette.foundationColor);
    canvas.drawRect(Rect.fromLTWH(wingLeft, wingTop, wingWidth, wingHeight - 16), Paint()..color = palette.wallShade);
    canvas.drawRect(Rect.fromLTWH(wingLeft, wingTop, wingWidth, wingHeight), Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5);

    final roofPath = Path();
    roofPath.moveTo(wingLeft - 8, wingTop + 4);
    roofPath.lineTo(cx - 88, wingTop - 24);
    roofPath.lineTo(cx - 88, wingTop + 4);
    roofPath.close();
    canvas.drawPath(roofPath, Paint()..color = palette.roofColor);
    canvas.drawPath(roofPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 3.0);

    _renderStorybookWindow(canvas, wingLeft + wingWidth / 2, wingTop + 34, 30, 38);
  }

  void _renderRightWing(Canvas canvas, double cx, double groundY) {
    const wingWidth = 60.0;
    const wingHeight = 84.0;
    final wingLeft = cx + 88.0;
    final wingTop = groundY - wingHeight;

    canvas.drawRect(Rect.fromLTWH(wingLeft, groundY - 16, wingWidth, 16), Paint()..color = palette.foundationColor);
    canvas.drawRect(Rect.fromLTWH(wingLeft, wingTop, wingWidth, wingHeight - 16), Paint()..color = palette.wallShade);
    canvas.drawRect(Rect.fromLTWH(wingLeft, wingTop, wingWidth, wingHeight), Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5);

    final roofPath = Path();
    roofPath.moveTo(cx + 88, wingTop - 24);
    roofPath.lineTo(wingLeft + wingWidth + 8, wingTop + 4);
    roofPath.lineTo(cx + 88, wingTop + 4);
    roofPath.close();
    canvas.drawPath(roofPath, Paint()..color = palette.roofColor);
    canvas.drawPath(roofPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 3.0);

    _renderStorybookWindow(canvas, wingLeft + wingWidth / 2, wingTop + 34, 30, 38);
  }

  void _renderSecondFloorCenter(Canvas canvas, double cx, double groundY) {
    const floorW = 116.0;
    const floorH = 72.0;
    final floorLeft = cx - floorW / 2;
    final floorTop = groundY - 98.0 - floorH + 10;

    canvas.drawRect(Rect.fromLTWH(floorLeft, floorTop, floorW, floorH), Paint()..color = palette.wallColor);
    canvas.drawRect(Rect.fromLTWH(floorLeft, floorTop, floorW, floorH), Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 2.0);

    final frenchDoorRect = Rect.fromCenter(center: Offset(cx, floorTop + floorH / 2 + 2), width: 34, height: 46);
    canvas.drawRRect(RRect.fromRectAndRadius(frenchDoorRect, const Radius.circular(4)), Paint()..color = palette.windowColor);
    canvas.drawRRect(RRect.fromRectAndRadius(frenchDoorRect, const Radius.circular(4)), Paint()..style = PaintingStyle.stroke ..color = Colors.white ..strokeWidth = 2.5);

    final balconyRect = Rect.fromCenter(center: Offset(cx, floorTop + floorH - 6), width: 54, height: 16);
    canvas.drawRRect(RRect.fromRectAndRadius(balconyRect, const Radius.circular(3)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(balconyRect, const Radius.circular(3)), Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.2);
    for (double bx = cx - 22; bx <= cx + 22; bx += 7) {
      canvas.drawLine(Offset(bx, balconyRect.top), Offset(bx, balconyRect.bottom), Paint()..color = const Color(0xFF64748B) ..strokeWidth = 1.5);
    }

    const roofPeakHeight = 44.0;
    final roofPeakY = floorTop - roofPeakHeight;
    final rPath = Path();
    rPath.moveTo(floorLeft - 10, floorTop + 2);
    rPath.lineTo(cx, roofPeakY);
    rPath.lineTo(floorLeft + floorW + 10, floorTop + 2);
    rPath.close();

    canvas.drawPath(rPath, Paint()..color = palette.roofColor);
    canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 4.5);
    canvas.drawPath(rPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5);
  }

  void _renderSecondFloorWings(Canvas canvas, double cx, double groundY) {
    // 🏛️ Solid 2nd-floor rooms sitting directly on top of 1st-floor wings (groundY - 84 to groundY - 148)
    // Completely solves the floating windows & air gap issue from Days 56 to 70!
    const wingW = 56.0;
    const wingH = 64.0;
    final wingTop = groundY - 148.0;

    // --- Left 2nd Floor Room (cx - 146 to cx - 90) ---
    final leftRoom = Rect.fromLTWH(cx - 146, wingTop, wingW, wingH);
    canvas.drawRect(leftRoom, Paint()..color = palette.wallColor);
    canvas.drawRect(leftRoom, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5);
    // Ashlar quoins on outer edge
    for (double y = wingTop; y < wingTop + wingH; y += 12) {
      canvas.drawRect(Rect.fromLTWH(leftRoom.left, y, 7, 10), Paint()..color = palette.wallShade);
    }
    // Centered sash window
    _renderStorybookWindow(canvas, leftRoom.center.dx, leftRoom.center.dy - 2, 26, 32);
    // Sloped mansard roof on top
    final leftRoofPath = Path();
    leftRoofPath.moveTo(leftRoom.left - 6, wingTop + 2);
    leftRoofPath.lineTo(leftRoom.left + 10, wingTop - 24);
    leftRoofPath.lineTo(leftRoom.right, wingTop - 24);
    leftRoofPath.lineTo(leftRoom.right, wingTop + 2);
    leftRoofPath.close();
    canvas.drawPath(leftRoofPath, Paint()..color = palette.roofColor);
    canvas.drawPath(leftRoofPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 3.0);

    // --- Right 2nd Floor Room (cx + 90 to cx + 146) ---
    final rightRoom = Rect.fromLTWH(cx + 90, wingTop, wingW, wingH);
    canvas.drawRect(rightRoom, Paint()..color = palette.wallColor);
    canvas.drawRect(rightRoom, Paint()..style = PaintingStyle.stroke ..color = palette.roofUnderTrim ..strokeWidth = 1.5);
    // Ashlar quoins on outer edge
    for (double y = wingTop; y < wingTop + wingH; y += 12) {
      canvas.drawRect(Rect.fromLTWH(rightRoom.right - 7, y, 7, 10), Paint()..color = palette.wallShade);
    }
    // Centered sash window
    _renderStorybookWindow(canvas, rightRoom.center.dx, rightRoom.center.dy - 2, 26, 32);
    // Sloped mansard roof on top
    final rightRoofPath = Path();
    rightRoofPath.moveTo(rightRoom.left, wingTop + 2);
    rightRoofPath.lineTo(rightRoom.left, wingTop - 24);
    rightRoofPath.lineTo(rightRoom.right - 10, wingTop - 24);
    rightRoofPath.lineTo(rightRoom.right + 6, wingTop + 2);
    rightRoofPath.close();
    canvas.drawPath(rightRoofPath, Paint()..color = palette.roofColor);
    canvas.drawPath(rightRoofPath, Paint()..style = PaintingStyle.stroke ..color = palette.roofTrim ..strokeWidth = 3.0);
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

  /// Days 85–90: Royal Pennants & Carriage Lanterns
  void _renderRoyalBannersAndCarriageLamps(Canvas canvas, double cx, double groundY, double floor2Top) {
    // Royal Pennants on wing roofs
    final flagPaint = Paint()..color = const Color(0xFFDC2626);
    final polePaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 1.8;

    for (final fx in [cx - 146.0, cx + 146.0]) {
      final fy = floor2Top - 44;
      canvas.drawLine(Offset(fx, fy), Offset(fx, fy - 16), polePaint);
      final fPath = Path();
      fPath.moveTo(fx, fy - 16);
      fPath.lineTo(fx + (fx > cx ? 12 : -12), fy - 12);
      fPath.lineTo(fx, fy - 8);
      fPath.close();
      canvas.drawPath(fPath, flagPaint);
    }

    // Carriage lanterns flanking front staircase
    for (final lx in [cx - 30.0, cx + 30.0]) {
      final ly = groundY - 18;
      canvas.drawCircle(Offset(lx, ly), 6.0, Paint()..color = Colors.amber.withValues(alpha: 0.4));
      canvas.drawCircle(Offset(lx, ly), 2.5, Paint()..color = const Color(0xFFFFD700));
    }
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
    final isCitadel = day >= 81;
    final isManor = day >= 71;
    final bushOffset = isCitadel ? 214.0 : (isManor ? 162.0 : (day >= 26 ? 155.0 : (day >= 11 ? 120.0 : 92.0)));

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
class FlameEnglishHouseWidget extends StatefulWidget {
  final int currentDay;
  final int streak;

  const FlameEnglishHouseWidget({
    super.key,
    required this.currentDay,
    this.streak = 1,
  });

  @override
  State<FlameEnglishHouseWidget> createState() => _FlameEnglishHouseWidgetState();
}

class _FlameEnglishHouseWidgetState extends State<FlameEnglishHouseWidget> {
  late FlameEnglishHouseGame _game;
  HousePalette _currentPalette = HousePalette.presets[0];
  HouseDefenseStatus _defenseStatus = const HouseDefenseStatus();

  @override
  void initState() {
    super.initState();
    _loadSavedPalette();
    _loadDefenseStatus();
    _game = FlameEnglishHouseGame(
      currentDay: widget.currentDay,
      streak: widget.streak,
      initialPalette: _currentPalette,
    );
  }

  Future<void> _loadDefenseStatus() async {
    final s = await PocketFortressDefenseService.getHouseStatus(widget.currentDay);
    if (mounted) {
      setState(() {
        _defenseStatus = s;
        _game.updateDamage(s.isDamaged);
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
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant FlameEnglishHouseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentDay != widget.currentDay || oldWidget.streak != widget.streak) {
      _game = FlameEnglishHouseGame(
        currentDay: widget.currentDay,
        streak: widget.streak,
        initialPalette: _currentPalette,
      );
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        children: [
          // 🏡 Flame 2D Interactive Game View
          Positioned.fill(
            child: GameWidget(game: _game),
          ),

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

          // 🌍 Pocket World Button (Top-Left)
          Positioned(
            top: 6,
            left: 14,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PocketWorldStreetPage(
                      currentDay: widget.currentDay,
                      streak: widget.streak,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF38BDF8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🌍', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 5),
                    Text(
                      'Pocket World',
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
          ),

          // 🏎️ Estate Garage / 90 VIP Fleet Button
          Positioned(
            top: 6,
            left: 128,
            child: GestureDetector(
              onTap: () {
                if (widget.currentDay >= 90) {
                  Day90VipMasterCardDialog.show(context, userDay: widget.currentDay);
                } else {
                  PocketVehicleGarageModal.show(context, widget.currentDay);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.currentDay >= 90
                        ? [const Color(0xFFB45309), const Color(0xFF78350F)]
                        : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.currentDay >= 90 ? const Color(0xFFFFD700) : Colors.white24,
                    width: 1.2,
                  ),
                  boxShadow: [
                    if (widget.currentDay >= 90)
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.currentDay >= 90 ? '👑' : (widget.currentDay >= 60 ? '🚙' : (widget.currentDay >= 30 ? '🏍️' : '🔒')),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      widget.currentDay >= 90
                          ? '90 VIP FLEET'
                          : (widget.currentDay >= 60 ? 'Grand SUV' : (widget.currentDay >= 30 ? 'Superbike' : 'Garage')),
                      style: GoogleFonts.outfit(
                        color: widget.currentDay >= 90 ? const Color(0xFFFFD700) : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🎨 Discreet Floating Theme Switcher Button
          Positioned(
            top: 6,
            right: 14,
            child: GestureDetector(
              onTap: _openPalettePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _currentPalette.accentColor.withValues(alpha: 0.65),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _currentPalette.accentColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎨', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(
                      _currentPalette.name.split(' ').sublist(1).join(' '),
                      style: TextStyle(
                        color: _currentPalette.accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ❤️ Live House HP & Defense Vault Button (Bottom-Left)
          Positioned(
            bottom: 8,
            left: 14,
            child: GestureDetector(
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
          ),

          // 🏪 Fortress Arsenal Store Button (Bottom-Left next to HP)
          Positioned(
            bottom: 8,
            left: 124,
            child: GestureDetector(
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
          ),

          // 🛡️ House Defense Traps Button
          Positioned(
            bottom: 8,
            right: 14,
            child: GestureDetector(
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
          ),
        ],
      ),
    );
  }
}
