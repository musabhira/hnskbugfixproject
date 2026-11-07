import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';


/// 🌄 2D Open World Living Scenery Painter (1800 x 1600 Cinematic Landscape)
/// Features infinite cosmic night sky (or azure daytime), passing space rocket / satellite,
/// glowing crescent moon, Aurora Borealis, rotating Dutch windmill, arched stone footbridge,
/// rotating waterwheel, swimming white swans, fluttering butterflies (day) / fireflies (night),
/// floating hot air balloon, festive celebration bunting, flowerbeds, and lush orchard trees.
class CitadelScenicLandscapePainter extends CustomPainter {
  final bool isDamaged;
  final double groundBaseY;
  final bool isNight;
  final bool isDay90;
  final double ambientProg;
  final bool isPresident;
  final String? planetCode; // 'EP', 'MAR', 'JUP', 'SAT', 'LUN', 'EUR', 'VEN', 'TTN', 'PLT', 'NEP'

  CitadelScenicLandscapePainter({
    this.isDamaged = false,
    this.groundBaseY = 920.0,
    this.isNight = false,
    this.isDay90 = false,
    this.ambientProg = 0.0,
    this.isPresident = false,
    this.planetCode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final w = size.width;
    final h = size.height;
    final gy = groundBaseY > 0 ? groundBaseY : 920.0;

    // 1. Sky & Cosmic Atmosphere (Covers full world canvas down to ground)
    final Shader skyShader;
    if (isNight) {
      skyShader = const LinearGradient(
        colors: [
          Color(0xFF030712), // Deep Space Obsidian
          Color(0xFF090D1A),
          Color(0xFF0F172A),
          Color(0xFF1E293B), // Horizon Twilight
        ],
        stops: [0.0, 0.35, 0.70, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    } else {
      switch (planetCode) {
        case 'MAR':
          skyShader = const LinearGradient(
            colors: [Color(0xFF7F1D1D), Color(0xFFC2410C), Color(0xFFFDBA74)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, h));
          break;
        case 'JUP':
          skyShader = const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF0284C7), Color(0xFF78350F)],
            stops: [0.0, 0.40, 0.80, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, h));
          break;
        case 'LUN':
          skyShader = const LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0B0F19), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, h));
          break;
        case 'PLT':
          skyShader = const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF3B0764), Color(0xFF581C87)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, h));
          break;
        case 'EUR':
          skyShader = const LinearGradient(
            colors: [Color(0xFF0C4A6E), Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFE0F2FE)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, h));
          break;
        case 'SAT':
          skyShader = const LinearGradient(
            colors: [Color(0xFF451A03), Color(0xFF78350F), Color(0xFFD97706), Color(0xFFFDE68A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, h));
          break;
        case 'VEN':
          skyShader = const LinearGradient(
            colors: [Color(0xFF78350F), Color(0xFFB45309), Color(0xFFF59E0B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, h));
          break;
        case 'TTN':
          skyShader = const LinearGradient(
            colors: [Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF10B981), Color(0xFFA7F3D0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, h));
          break;
        case 'NEP':
          skyShader = const LinearGradient(
            colors: [Color(0xFF172554), Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF93C5FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, h));
          break;
        default: // 'EP' or null: 100% untouched Earth Prime
          skyShader = const LinearGradient(
            colors: [
              Color(0xFF0284C7), // Deep Azure
              Color(0xFF38BDF8), // Vibrant Cyan
              Color(0xFFBAE6FD), // Horizon Mist
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(0, 0, w, h));
      }
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..shader = skyShader);

    // Celestial Starlight / Atmosphere Accents on Alien Worlds
    if (!isNight) {
      if (planetCode == 'LUN' || planetCode == 'PLT') {
        // Twinkling stars in daytime void of Moon and Pluto
        final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.65);
        for (int s = 0; s < 35; s++) {
          final sx = ((s * 97.0) % w);
          final sy = ((s * 43.0) % (gy * 0.55));
          final sz = 0.8 + ((s % 3) * 0.5);
          canvas.drawCircle(Offset(sx, sy), sz, starPaint);
        }
      } else if (planetCode == 'JUP') {
        // Swirling Jovian storm auroral ribbons
        final jovianPaint = Paint()
          ..color = const Color(0xFFF59E0B).withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14.0;
        canvas.drawLine(Offset(0, gy * 0.22), Offset(w, gy * 0.25), jovianPaint);
        canvas.drawLine(Offset(0, gy * 0.40), Offset(w, gy * 0.38), jovianPaint);
      }
    }

    if (isNight) {
      // 🌌 Faint Celestial Nebula Dust Band Across Upper Sky
      final nebulaPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF6366F1).withValues(alpha: 0.09),
            const Color(0xFFA855F7).withValues(alpha: 0.08),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, w, gy * 0.7))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, gy * 0.7), nebulaPaint);

      // 🌌 Shimmering Aurora Borealis (Northern Lights Ribbon)
      final auroraPath = Path();
      final auroraWave = math.sin(ambientProg * 2 * math.pi) * 18.0;
      auroraPath.moveTo(0, gy * 0.35 + auroraWave);
      auroraPath.cubicTo(w * 0.28, gy * 0.22 - auroraWave, w * 0.62,
          gy * 0.44 + auroraWave, w, gy * 0.28);
      auroraPath.lineTo(w, gy * 0.46);
      auroraPath.cubicTo(w * 0.62, gy * 0.60 + auroraWave, w * 0.28,
          gy * 0.38 - auroraWave, 0, gy * 0.52);
      auroraPath.close();

      final auroraShader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF10B981).withValues(alpha: 0.18),
          const Color(0xFF38BDF8).withValues(alpha: 0.16),
          const Color(0xFFC084FC).withValues(alpha: 0.14),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, gy * 0.20, w, gy * 0.40));
      canvas.drawPath(
          auroraPath,
          Paint()
            ..shader = auroraShader
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22));

      // 🌙 Glowing Crescent Moon
      final moonCenter = Offset(w * 0.82, gy * 0.22);
      canvas.drawCircle(
        moonCenter,
        52,
        Paint()
          ..color = const Color(0xFFFEF08A).withValues(alpha: 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
      );
      canvas.drawCircle(
        moonCenter,
        34,
        Paint()
          ..color = const Color(0xFFFEF08A).withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawCircle(
          moonCenter, 22, Paint()..color = const Color(0xFFFEF08A));
      canvas.drawCircle(Offset(moonCenter.dx + 8, moonCenter.dy - 5), 20,
          Paint()..color = const Color(0xFF090D1A));

      // ✨ Expansive Twinkling Starfield across width
      final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.88);
      final starGlowPaint = Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

      final starPoints = [
        Offset(w * 0.04, gy * 0.08),
        Offset(w * 0.08, gy * 0.24),
        Offset(w * 0.12, gy * 0.14),
        Offset(w * 0.16, gy * 0.32),
        Offset(w * 0.20, gy * 0.06),
        Offset(w * 0.24, gy * 0.20),
        Offset(w * 0.28, gy * 0.10),
        Offset(w * 0.32, gy * 0.28),
        Offset(w * 0.36, gy * 0.15),
        Offset(w * 0.40, gy * 0.05),
        Offset(w * 0.44, gy * 0.22),
        Offset(w * 0.48, gy * 0.12),
        Offset(w * 0.52, gy * 0.30),
        Offset(w * 0.56, gy * 0.08),
        Offset(w * 0.60, gy * 0.25),
        Offset(w * 0.64, gy * 0.16),
        Offset(w * 0.68, gy * 0.07),
        Offset(w * 0.72, gy * 0.28),
        Offset(w * 0.76, gy * 0.14),
        Offset(w * 0.80, gy * 0.05),
        Offset(w * 0.84, gy * 0.34),
        Offset(w * 0.88, gy * 0.18),
        Offset(w * 0.92, gy * 0.09),
        Offset(w * 0.96, gy * 0.26),
        Offset(w * 0.06, gy * 0.42),
        Offset(w * 0.15, gy * 0.46),
        Offset(w * 0.22, gy * 0.38),
        Offset(w * 0.35, gy * 0.42),
        Offset(w * 0.42, gy * 0.36),
        Offset(w * 0.58, gy * 0.44),
        Offset(w * 0.67, gy * 0.38),
        Offset(w * 0.75, gy * 0.46),
        Offset(w * 0.89, gy * 0.40),
        Offset(w * 0.95, gy * 0.48),
        Offset(w * 0.10, gy * 0.04),
        Offset(w * 0.50, gy * 0.03),
        Offset(w * 0.70, gy * 0.03),
        Offset(w * 0.90, gy * 0.04),
      ];

      for (int i = 0; i < starPoints.length; i++) {
        final pt = starPoints[i];
        final twinkle = 0.75 + math.sin(ambientProg * 8 * math.pi + i) * 0.25;
        final size =
            ((i % 4 == 0) ? 2.5 : ((i % 2 == 0) ? 1.8 : 1.2)) * twinkle;
        if (size >= 1.6) {
          canvas.drawCircle(pt, size + 1.2, starGlowPaint);
        }
        canvas.drawCircle(pt, size, starPaint);
      }

      // ☄️ Shooting Stars (Meteors)
      _drawShootingStar(canvas, w * 0.28, gy * 0.14, 68);
      _drawShootingStar(canvas, w * 0.72, gy * 0.08, 85);

      // 🚀 Cosmic Space Rocket with pulsating plasma flame
      _drawCosmicRocket(canvas, w * 0.24, gy * 0.20, ambientProg: ambientProg);
    } else {
      if (planetCode == null || planetCode == 'EP') {
        // ☀️ Earth Prime Original Baseline (100% untouched gold standard)
        final sunCenter = Offset(w * 0.82, gy * 0.26);
        canvas.drawCircle(
          sunCenter,
          64,
          Paint()
            ..color = const Color(0xFFFDE047).withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
        );
        canvas.drawCircle(
          sunCenter,
          42,
          Paint()
            ..color = const Color(0xFFFDE047).withValues(alpha: 0.38)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
        canvas.drawCircle(
            sunCenter, 26, Paint()..color = const Color(0xFFFDE047));

        // 🎈 Floating Striped Hot Air Balloon
        final balloonX = w * 0.38 + math.sin(ambientProg * 2 * math.pi) * 28.0;
        final balloonY = gy * 0.16 + math.cos(ambientProg * 2 * math.pi) * 8.0;
        _drawHotAirBalloon(canvas, balloonX, balloonY);

        // ☁️ Drifting Fluffy Clouds
        final cloudFloat = math.sin(ambientProg * 2 * math.pi) * 14.0;
        _drawFluffyCloud(canvas, w * 0.12 + cloudFloat, gy * 0.18, 22);
        _drawFluffyCloud(canvas, w * 0.44 - cloudFloat, gy * 0.28, 18);
        _drawFluffyCloud(canvas, w * 0.62 + cloudFloat, gy * 0.22, 20);
        _drawFluffyCloud(canvas, w * 0.88 - cloudFloat, gy * 0.38, 16);

        // 🕊️ Flying Birds Soaring Across the Sky with Flapping Wings & Migrating Flock
        _drawFlyingBird(canvas, w * 0.24, gy * 0.16, 15,
            ambientProg: ambientProg, phase: 0.0);
        _drawFlyingBird(canvas, w * 0.30, gy * 0.12, 11,
            ambientProg: ambientProg, phase: 0.25);
        _drawFlyingBird(canvas, w * 0.54, gy * 0.14, 13,
            ambientProg: ambientProg, phase: 0.5);
        _drawFlyingBird(canvas, w * 0.70, gy * 0.10, 10,
            ambientProg: ambientProg, phase: 0.75);
        _drawFlyingBirdsFlock(canvas, w, gy, ambientProg);
      } else {
        // 🪐 Celestial Planetary Atmosphere Accents
        _drawPlanetaryCelestialFeatures(canvas, w, gy, ambientProg, planetCode!);
      }
    }

    // 🏔️ 2. Distant Majestic Mountain Ranges
    final mountainPath = Path();
    mountainPath.moveTo(0, gy - 20);
    mountainPath.lineTo(w * 0.10, gy - 95);
    mountainPath.lineTo(w * 0.24, gy - 160); // High Peak 1
    mountainPath.lineTo(w * 0.38, gy - 85);
    mountainPath.lineTo(w * 0.52, gy - 145); // High Peak 2
    mountainPath.lineTo(w * 0.68, gy - 80);
    mountainPath.lineTo(w * 0.82, gy - 175); // High Peak 3
    mountainPath.lineTo(w * 0.92, gy - 90);
    mountainPath.lineTo(w, gy - 35);
    mountainPath.lineTo(w, h);
    mountainPath.lineTo(0, h);
    mountainPath.close();

    final Color mountainColor;
    if (isNight) {
      mountainColor = const Color(0xFF1E1B4B).withValues(alpha: 0.65);
    } else {
      switch (planetCode) {
        case 'MAR':
          mountainColor = const Color(0xFF7C2D12).withValues(alpha: 0.65);
          break;
        case 'JUP':
          mountainColor = const Color(0xFF1E3A8A).withValues(alpha: 0.55);
          break;
        case 'LUN':
          mountainColor = const Color(0xFF475569).withValues(alpha: 0.60);
          break;
        case 'PLT':
          mountainColor = const Color(0xFF581C87).withValues(alpha: 0.60);
          break;
        case 'EUR':
          mountainColor = const Color(0xFF0284C7).withValues(alpha: 0.50);
          break;
        case 'SAT':
          mountainColor = const Color(0xFF78350F).withValues(alpha: 0.55);
          break;
        case 'VEN':
          mountainColor = const Color(0xFF92400E).withValues(alpha: 0.60);
          break;
        case 'TTN':
          mountainColor = const Color(0xFF064E3B).withValues(alpha: 0.55);
          break;
        case 'NEP':
          mountainColor = const Color(0xFF1E3A8A).withValues(alpha: 0.60);
          break;
        default:
          mountainColor = const Color(0xFF0D9488).withValues(alpha: 0.40);
      }
    }
    final mountainPaint = Paint()..color = mountainColor;
    canvas.drawPath(mountainPath, mountainPaint);

    // Mountain Peak highlights
    final peakHighlight = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.20 : 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(
        Offset(w * 0.24, gy - 160), Offset(w * 0.28, gy - 120), peakHighlight);
    canvas.drawLine(
        Offset(w * 0.52, gy - 145), Offset(w * 0.56, gy - 110), peakHighlight);
    canvas.drawLine(
        Offset(w * 0.82, gy - 175), Offset(w * 0.86, gy - 130), peakHighlight);

    // 🌊 Cascading Mountain Waterfall on High Peak
    _drawMountainWaterfall(
      canvas,
      w * 0.24,
      gy - 160,
      gy - 20,
      ambientProg: ambientProg,
      isNight: isNight,
    );

    // 🌲 3. Midground Rolling Green Foothills
    final foothillPath = Path();
    foothillPath.moveTo(0, gy - 10);
    foothillPath.quadraticBezierTo(w * 0.22, gy - 55, w * 0.48, gy - 25);
    foothillPath.quadraticBezierTo(w * 0.74, gy - 60, w, gy - 15);
    foothillPath.lineTo(w, h);
    foothillPath.lineTo(0, h);
    foothillPath.close();

    final Color foothillColor;
    if (isNight) {
      foothillColor = const Color(0xFF064E3B).withValues(alpha: 0.70);
    } else {
      switch (planetCode) {
        case 'MAR':
          foothillColor = const Color(0xFF9A3412).withValues(alpha: 0.75);
          break;
        case 'JUP':
          foothillColor = const Color(0xFF047857).withValues(alpha: 0.70);
          break;
        case 'LUN':
          foothillColor = const Color(0xFF334155).withValues(alpha: 0.70);
          break;
        case 'PLT':
          foothillColor = const Color(0xFF3B0764).withValues(alpha: 0.75);
          break;
        case 'EUR':
          foothillColor = const Color(0xFF0369A1).withValues(alpha: 0.65);
          break;
        case 'SAT':
          foothillColor = const Color(0xFFB45309).withValues(alpha: 0.70);
          break;
        case 'VEN':
          foothillColor = const Color(0xFFB45309).withValues(alpha: 0.70);
          break;
        case 'TTN':
          foothillColor = const Color(0xFF065F46).withValues(alpha: 0.70);
          break;
        case 'NEP':
          foothillColor = const Color(0xFF1D4ED8).withValues(alpha: 0.70);
          break;
        default:
          foothillColor = const Color(0xFF15803D).withValues(alpha: 0.65);
      }
    }
    final foothillPaint = Paint()..color = foothillColor;
    canvas.drawPath(foothillPath, foothillPaint);

    // 💨 4. Traditional Dutch Windmill with Rotating Sails on Hilltop
    if (!isPresident) {
      _drawDutchWindmill(canvas, w * 0.18, gy - 32,
          ambientProg: ambientProg, isNight: isNight);
    }

    // 🏡 5. Citadel Courtyard Hill Plateau (Island vs Normal Estate)
    final hillPath = Path();
    if (isPresident) {
      // 🏝️ Sovereign Fortress Island Plateau ("Dweepu")
      // Center is a grand elevated plateau, tapering down into the sea on both left and right shores
      hillPath.moveTo(0, gy + 140);
      hillPath.quadraticBezierTo(w * 0.16, gy + 20, w * 0.32, gy - 12);
      hillPath.lineTo(w * 0.68, gy - 12);
      hillPath.quadraticBezierTo(w * 0.84, gy + 20, w, gy + 140);
      hillPath.lineTo(w, h);
      hillPath.lineTo(0, h);
      hillPath.close();
    } else {
      hillPath.moveTo(0, gy);
      hillPath.quadraticBezierTo(w * 0.25, gy - 22, w * 0.50, gy - 14);
      hillPath.quadraticBezierTo(w * 0.75, gy - 4, w, gy + 12);
      hillPath.lineTo(w, h);
      hillPath.lineTo(0, h);
      hillPath.close();
    }

    final List<Color> hillColors;
    final Color ridgeBorderColor;
    if (isNight) {
      hillColors = [
        const Color(0xFF064E3B),
        const Color(0xFF065F46),
        const Color(0xFF022C22),
        const Color(0xFF022C22)
      ];
      ridgeBorderColor = const Color(0xFF059669).withValues(alpha: 0.6);
    } else {
      switch (planetCode) {
        case 'MAR':
          hillColors = [
            const Color(0xFFEA580C),
            const Color(0xFFC2410C),
            const Color(0xFF9A3412),
            const Color(0xFF7C2D12),
          ];
          ridgeBorderColor = const Color(0xFFFDBA74);
          break;
        case 'JUP':
          hillColors = [
            const Color(0xFF10B981),
            const Color(0xFF059669),
            const Color(0xFF047857),
            const Color(0xFF064E3B),
          ];
          ridgeBorderColor = const Color(0xFF6EE7B7);
          break;
        case 'LUN':
          hillColors = [
            const Color(0xFF64748B),
            const Color(0xFF475569),
            const Color(0xFF334155),
            const Color(0xFF1E293B),
          ];
          ridgeBorderColor = const Color(0xFF94A3B8);
          break;
        case 'PLT':
          hillColors = [
            const Color(0xFFA855F7),
            const Color(0xFF9333EA),
            const Color(0xFF7E22CE),
            const Color(0xFF581C87),
          ];
          ridgeBorderColor = const Color(0xFFD8B4FE);
          break;
        case 'EUR':
          hillColors = [
            const Color(0xFF38BDF8),
            const Color(0xFF0EA5E9),
            const Color(0xFF0284C7),
            const Color(0xFF0369A1),
          ];
          ridgeBorderColor = const Color(0xFFBAE6FD);
          break;
        case 'SAT':
          hillColors = [
            const Color(0xFFD97706),
            const Color(0xFFB45309),
            const Color(0xFF92400E),
            const Color(0xFF78350F),
          ];
          ridgeBorderColor = const Color(0xFFFDE68A);
          break;
        case 'VEN':
          hillColors = [
            const Color(0xFFF59E0B),
            const Color(0xFFD97706),
            const Color(0xFFB45309),
            const Color(0xFF78350F),
          ];
          ridgeBorderColor = const Color(0xFFFEF08A);
          break;
        case 'TTN':
          hillColors = [
            const Color(0xFF10B981),
            const Color(0xFF059669),
            const Color(0xFF047857),
            const Color(0xFF064E3B),
          ];
          ridgeBorderColor = const Color(0xFFA7F3D0);
          break;
        case 'NEP':
          hillColors = [
            const Color(0xFF2563EB),
            const Color(0xFF1D4ED8),
            const Color(0xFF1E3A8A),
            const Color(0xFF172554),
          ];
          ridgeBorderColor = const Color(0xFF93C5FD);
          break;
        default:
          hillColors = [
            const Color(0xFF22C55E),
            const Color(0xFF16A34A),
            const Color(0xFF15803D),
            const Color(0xFF14532D)
          ];
          ridgeBorderColor = const Color(0xFF86EFAC);
      }
    }

    final hillPaint = Paint()
      ..shader = LinearGradient(
        colors: hillColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, gy - 32, w, h - gy + 32));
    canvas.drawPath(hillPath, hillPaint);

    // Vibrant Grass Ridge Edge
    final ridgePaint = Paint()
      ..color = ridgeBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;
    canvas.drawPath(hillPath, ridgePaint);

    if (isPresident) {
      // 🌊 6. Boundless Sovereign Ocean, Island Coastal Shoreline, Bioluminescent Waves & Marine Life
      _drawPresidentialSovereignOcean(canvas, w, h, gy,
          ambientProg: ambientProg, isNight: isNight);

      // Coastal royal trees & island perimeter lamps
      _drawTree(canvas, w * 0.14, gy + 45, scale: 1.3);
      _drawTree(canvas, w * 0.86, gy + 45, scale: 1.35);
      _drawStreetLamp(canvas, w * 0.28, gy - 6, isNight: isNight);
      _drawStreetLamp(canvas, w * 0.72, gy - 6, isNight: isNight);
    } else {
      // 🌊 6. Curving Flowing River Across Valley
      final riverPath = Path();
      final ry = gy + 190.0;
      riverPath.moveTo(0, ry + 15);
      riverPath.cubicTo(
          w * 0.25, ry - 35, w * 0.55, ry + 55, w * 0.82, ry - 15);
      riverPath.cubicTo(w * 0.90, ry - 25, w * 0.96, ry, w, ry + 25);
      riverPath.lineTo(w, ry + 115);
      riverPath.cubicTo(
          w * 0.96, ry + 95, w * 0.90, ry + 75, w * 0.82, ry + 85);
      riverPath.cubicTo(w * 0.55, ry + 155, w * 0.25, ry + 65, 0, ry + 115);
      riverPath.close();

      final List<Color> riverColors;
      if (isNight) {
        riverColors = [
          const Color(0xFF0C4A6E),
          const Color(0xFF075985),
          const Color(0xFF0369A1)
        ];
      } else {
        switch (planetCode) {
          case 'MAR':
            riverColors = [
              const Color(0xFFB45309),
              const Color(0xFFD97706),
              const Color(0xFFF59E0B),
            ];
            break;
          case 'JUP':
            riverColors = [
              const Color(0xFF1E40AF),
              const Color(0xFF2563EB),
              const Color(0xFF38BDF8),
            ];
            break;
          case 'LUN':
            riverColors = [
              const Color(0xFF38BDF8),
              const Color(0xFF94A3B8),
              const Color(0xFFE2E8F0),
            ];
            break;
          case 'PLT':
            riverColors = [
              const Color(0xFF7E22CE),
              const Color(0xFFA855F7),
              const Color(0xFFC084FC),
            ];
            break;
          case 'EUR':
            riverColors = [
              const Color(0xFF0284C7),
              const Color(0xFF38BDF8),
              const Color(0xFFE0F2FE),
            ];
            break;
          case 'SAT':
            riverColors = [
              const Color(0xFFB45309),
              const Color(0xFFD97706),
              const Color(0xFFFBBF24),
            ];
            break;
          case 'VEN':
            riverColors = [
              const Color(0xFFEA580C),
              const Color(0xFFF59E0B),
              const Color(0xFFFEF08A),
            ];
            break;
          case 'TTN':
            riverColors = [
              const Color(0xFF047857),
              const Color(0xFF10B981),
              const Color(0xFF34D399),
            ];
            break;
          case 'NEP':
            riverColors = [
              const Color(0xFF1D4ED8),
              const Color(0xFF2563EB),
              const Color(0xFF60A5FA),
            ];
            break;
          default:
            riverColors = [
              const Color(0xFF0284C7),
              const Color(0xFF38BDF8),
              const Color(0xFF0EA5E9)
            ];
        }
      }
      final riverPaint = Paint()
        ..shader = LinearGradient(
          colors: riverColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, ry - 35, w, 150));
      canvas.drawPath(riverPath, riverPaint);

      // Sparkling River Water Ripples (Animated with ambientProg)
      final rippleOffset = math.sin(ambientProg * 2 * math.pi) * 8.0;
      final wavePaint = Paint()
        ..color = Colors.white.withValues(alpha: isNight ? 0.35 : 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(w * 0.12 + rippleOffset, ry + 22),
          Offset(w * 0.22 + rippleOffset, ry + 16), wavePaint);
      canvas.drawLine(Offset(w * 0.36 - rippleOffset, ry + 36),
          Offset(w * 0.48 - rippleOffset, ry + 46), wavePaint);
      canvas.drawLine(Offset(w * 0.65 + rippleOffset, ry + 50),
          Offset(w * 0.76 + rippleOffset, ry + 40), wavePaint);
      canvas.drawLine(Offset(w * 0.86 - rippleOffset, ry + 24),
          Offset(w * 0.94 - rippleOffset, ry + 32), wavePaint);

      // 🪷 Floating Pink Lotus Water Lilies on River
      _drawWaterLily(canvas, w * 0.28, ry + 38);
      _drawWaterLily(canvas, w * 0.78, ry + 68);

      // 🦢 Swimming White Swans with water ripple wake
      final swanX1 = w * 0.42 + math.sin(ambientProg * 2 * math.pi) * 16.0;
      final swanY1 = ry + 46.0;
      _drawSwan(canvas, swanX1, swanY1);

      final swanX2 =
          w * 0.46 + math.sin(ambientProg * 2 * math.pi + 0.5) * 12.0;
      final swanY2 = ry + 56.0;
      _drawSwan(canvas, swanX2, swanY2);

      // 🛶 Floating Wooden Rowboat
      final boatBob = math.sin(ambientProg * 2 * math.pi) * 2.5;
      final boatX = w * 0.66;
      final boatY = ry + 46.0 + boatBob;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(boatX, boatY + 9), width: 44, height: 7),
        Paint()..color = Colors.black.withValues(alpha: 0.30),
      );
      final boatPath = Path();
      boatPath.moveTo(boatX - 20, boatY);
      boatPath.quadraticBezierTo(boatX - 14, boatY + 10, boatX, boatY + 10);
      boatPath.quadraticBezierTo(boatX + 14, boatY + 10, boatX + 20, boatY);
      boatPath.lineTo(boatX + 15, boatY - 1.5);
      boatPath.quadraticBezierTo(boatX, boatY + 2.5, boatX - 15, boatY - 1.5);
      boatPath.close();
      canvas.drawPath(boatPath, Paint()..color = const Color(0xFF78350F));
      canvas.drawLine(
          Offset(boatX - 4, boatY + 2),
          Offset(boatX + 4, boatY + 2),
          Paint()
            ..color = const Color(0xFFB45309)
            ..strokeWidth = 2.4);
      canvas.drawLine(
          Offset(boatX - 8, boatY - 5),
          Offset(boatX + 10, boatY + 12),
          Paint()
            ..color = const Color(0xFFFDE68A)
            ..strokeWidth = 1.6);

      // ⚙️ Rotating Wooden Waterwheel on Riverbank
      _drawWaterWheel(canvas, w * 0.88, ry + 18, ambientProg: ambientProg);

      // 🌉 7. Handsome Stone Arched Footbridge Spanning Across River
      _drawStoneBridge(canvas, w * 0.50, ry + 40, isNight: isNight);

      // 🏡 8. Cobblestone Courtyard Walkway from house entrance towards bridge
      final walkPath = Path();
      walkPath.moveTo(w * 0.47, gy + 10);
      walkPath.quadraticBezierTo(w * 0.48, gy + 80, w * 0.44, ry - 10);
      walkPath.lineTo(w * 0.56, ry - 10);
      walkPath.quadraticBezierTo(w * 0.52, gy + 80, w * 0.53, gy + 10);
      walkPath.close();

      final walkPaint = Paint()
        ..color =
            const Color(0xFFCBD5E1).withValues(alpha: isNight ? 0.20 : 0.35);
      canvas.drawPath(walkPath, walkPaint);

      final stonePaint = Paint()
        ..color =
            const Color(0xFFE2E8F0).withValues(alpha: isNight ? 0.25 : 0.40);
      for (int i = 0; i < 7; i++) {
        final stoneY = gy + 18 + (i * 22);
        final stoneX = w * 0.50 + math.sin(i * 1.4) * 6;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset(stoneX, stoneY),
                  width: 34 - (i * 1.5),
                  height: 9),
              const Radius.circular(4.5)),
          stonePaint,
        );
      }

      // 🚩 9. Festive Celebration Bunting Flags (Triangle party flags)
      _drawPartyBunting(canvas, w * 0.24, gy - 16, w * 0.36, gy - 12);
      _drawPartyBunting(canvas, w * 0.64, gy - 12, w * 0.76, gy - 16);

      // 10. White Picket Fences along property bounds
      _drawPicketFence(canvas, w * 0.24, gy - 6, 5);
      _drawPicketFence(canvas, w * 0.68, gy - 2, 5);

      // 11. Colorful Flowerbeds (Tulips, Roses, Blossoms)
      _drawFlowerbed(canvas, w * 0.34, gy + 2);
      _drawFlowerbed(canvas, w * 0.64, gy + 4);

      // 🦋 12. Fluttering Butterflies in Day / ✨ Glowing Fireflies at Night
      if (!isNight) {
        _drawButterfly(canvas, w * 0.33, gy - 8,
            ambientProg: ambientProg, color: const Color(0xFFFB923C));
        _drawButterfly(canvas, w * 0.36, gy + 6,
            ambientProg: ambientProg + 0.3, color: const Color(0xFF38BDF8));
        _drawButterfly(canvas, w * 0.63, gy - 4,
            ambientProg: ambientProg + 0.6, color: const Color(0xFFFACC15));
        _drawButterfly(canvas, w * 0.66, gy + 8,
            ambientProg: ambientProg + 0.2, color: const Color(0xFFF43F5E));
        _drawButterfly(canvas, w * 0.26, gy - 22,
            ambientProg: ambientProg + 0.8, color: const Color(0xFFA855F7));
      } else {
        _drawFirefly(canvas, w * 0.28, gy - 14,
            ambientProg: ambientProg, phase: 0.1);
        _drawFirefly(canvas, w * 0.32, gy + 8,
            ambientProg: ambientProg, phase: 0.4);
        _drawFirefly(canvas, w * 0.65, gy - 10,
            ambientProg: ambientProg, phase: 0.7);
        _drawFirefly(canvas, w * 0.72, gy + 12,
            ambientProg: ambientProg, phase: 0.2);
        _drawFirefly(canvas, w * 0.48, ry + 20,
            ambientProg: ambientProg, phase: 0.5);
        _drawFirefly(canvas, w * 0.54, ry + 35,
            ambientProg: ambientProg, phase: 0.8);
        _drawFirefly(canvas, w * 0.80, gy - 25,
            ambientProg: ambientProg, phase: 0.3);
        _drawFirefly(canvas, w * 0.15, gy - 18,
            ambientProg: ambientProg, phase: 0.9);
      }

      // 13. Lush Trees: Orchard Apples & Japanese Cherry Blossom (Sakura)
      _drawTree(canvas, w * 0.12, gy - 8, scale: 1.3);
      _drawCherryBlossomTree(canvas, w * 0.22, gy - 16,
          scale: 1.1, ambientProg: ambientProg);
      _drawCherryBlossomTree(canvas, w * 0.78, gy - 4,
          scale: 1.15, ambientProg: ambientProg);
      _drawTree(canvas, w * 0.88, gy + 6, scale: 1.35);

      // Riverbank shade trees
      _drawTree(canvas, w * 0.08, ry + 10, scale: 1.1);
      _drawTree(canvas, w * 0.92, ry + 20, scale: 1.15);

      // 14. Street Lamps with Warm Golden Glowing Lanterns
      _drawStreetLamp(canvas, w * 0.30, gy + 12, isNight: isNight);
      _drawStreetLamp(canvas, w * 0.70, gy + 16, isNight: isNight);

      // 15. Lower Valley Rolling Meadows
      final lowerMeadowPath = Path();
      lowerMeadowPath.moveTo(0, ry + 115);
      lowerMeadowPath.quadraticBezierTo(w * 0.40, ry + 130, w * 0.75, ry + 110);
      lowerMeadowPath.quadraticBezierTo(w * 0.90, ry + 100, w, ry + 115);
      lowerMeadowPath.lineTo(w, h);
      lowerMeadowPath.lineTo(0, h);
      lowerMeadowPath.close();

      final meadowPaint = Paint()
        ..color = isNight ? const Color(0xFF022C22) : const Color(0xFF15803D);
      canvas.drawPath(lowerMeadowPath, meadowPaint);

      // Trees in the lower valley
      _drawTree(canvas, w * 0.18, ry + 180, scale: 1.1);
      _drawCherryBlossomTree(canvas, w * 0.42, ry + 220,
          scale: 1.05, ambientProg: ambientProg);
      _drawTree(canvas, w * 0.68, ry + 200, scale: 1.2);
      _drawTree(canvas, w * 0.84, ry + 240, scale: 1.05);
    }

    // 💨 Cozy Chimney Smoke Drifting Gently from Starter House
    _drawChimneySmoke(canvas, w * 0.425, gy - 335, ambientProg: ambientProg);

    // 👑 Day 90 Sovereign Citadel Special: Majestic Celestial Grandeur & Floating Crown
    if (isDay90) {
      _drawDay90CelestialGrandeur(canvas, w, gy, ambientProg);

      final crownCenter = Offset(w * 0.5, gy - 430);
      canvas.drawCircle(
        crownCenter,
        44,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
      final crownPath = Path();
      crownPath.moveTo(crownCenter.dx - 26, crownCenter.dy + 10);
      crownPath.lineTo(crownCenter.dx + 26, crownCenter.dy + 10);
      crownPath.lineTo(crownCenter.dx + 24, crownCenter.dy - 14);
      crownPath.lineTo(crownCenter.dx + 12, crownCenter.dy - 3);
      crownPath.lineTo(crownCenter.dx, crownCenter.dy - 18);
      crownPath.lineTo(crownCenter.dx - 12, crownCenter.dy - 3);
      crownPath.lineTo(crownCenter.dx - 24, crownCenter.dy - 14);
      crownPath.close();
      canvas.drawPath(crownPath, Paint()..color = const Color(0xFFFFD700));
      canvas.drawCircle(Offset(crownCenter.dx - 24, crownCenter.dy - 14), 2.8,
          Paint()..color = const Color(0xFFEF4444));
      canvas.drawCircle(Offset(crownCenter.dx, crownCenter.dy - 18), 3.4,
          Paint()..color = const Color(0xFF38BDF8));
      canvas.drawCircle(Offset(crownCenter.dx + 24, crownCenter.dy - 14), 2.8,
          Paint()..color = const Color(0xFF10B981));
    }
    canvas.restore();
  }

  /// 🪐 Planetary Celestial Atmospheric Rendering for Alien Worlds
  void _drawPlanetaryCelestialFeatures(
      Canvas canvas, double w, double gy, double ambientProg, String code) {
    switch (code) {
      case 'LUN': // Moon: Earthrise & Starfield & Artemis Orbiter
        _drawMoonEarthriseAtmosphere(canvas, w, gy, ambientProg);
        break;
      case 'EUR': // Europa: Giant Jupiter looming over ice mountains
        _drawEuropaJupiterAtmosphere(canvas, w, gy, ambientProg);
        break;
      case 'SAT': // Saturn: Vast tilted golden rings in the sky
        _drawSaturnRingedAtmosphere(canvas, w, gy, ambientProg);
        break;
      case 'MAR': // Mars: Phobos & Deimos twin moons & dust corona
        _drawMarsCelestialAtmosphere(canvas, w, gy, ambientProg);
        break;
      case 'JUP': // Jupiter: Jovian storm auroras, Io & Europa crescent moons
        _drawJupiterCelestialAtmosphere(canvas, w, gy, ambientProg);
        break;
      case 'PLT': // Pluto: Charon companion moon & deep purple nebula starfield
        _drawPlutoCharonAtmosphere(canvas, w, gy, ambientProg);
        break;
      case 'VEN': // Venus: Golden sunbeams through sulfuric clouds & aerostat
        _drawVenusCelestialAtmosphere(canvas, w, gy, ambientProg);
        break;
      case 'TTN': // Titan: Emerald haze, ringed Saturn silhouette, bioluminescent spores
        _drawTitanSaturnAtmosphere(canvas, w, gy, ambientProg);
        break;
      case 'NEP': // Neptune: Deep cosmic cobalt, Triton cryo-geysers, ring arcs
        _drawNeptuneCelestialAtmosphere(canvas, w, gy, ambientProg);
        break;
      default:
        break;
    }
  }

  /// 🌍 Moon: The Majestic Earthrise hanging in the dark lunar cosmos
  void _drawMoonEarthriseAtmosphere(
      Canvas canvas, double w, double gy, double ambientProg) {
    // 🌌 Starfield in lunar void
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (int i = 0; i < 40; i++) {
      final sx = ((i * 89.0) % w);
      final sy = ((i * 47.0) % (gy * 0.65));
      final sz = 0.8 + ((i % 3) * 0.5);
      canvas.drawCircle(Offset(sx, sy), sz, starPaint);
    }

    // 🌍 Earthrise Sphere
    final ecx = w * 0.78;
    final ecy = gy * 0.22;
    const eradius = 52.0;

    // Atmospheric cyan halo
    canvas.drawCircle(
      Offset(ecx, ecy),
      eradius + 16,
      Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // Earth Base Sphere (Deep Ocean Gradient)
    canvas.save();
    final earthPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(ecx, ecy), radius: eradius));
    canvas.clipPath(earthPath);

    final oceanPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF0284C7), Color(0xFF0369A1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(ecx, ecy), radius: eradius));
    canvas.drawCircle(Offset(ecx, ecy), eradius, oceanPaint);

    // Continents
    final continentPaint = Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.85);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(ecx - 12, ecy - 8), width: 32, height: 22),
      continentPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(ecx + 14, ecy + 12), width: 26, height: 34),
      continentPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(ecx - 18, ecy + 22), width: 18, height: 16),
      continentPaint,
    );

    // Swirling White Cloud Belts
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    final cloudPath1 = Path()
      ..moveTo(ecx - eradius, ecy - 12)
      ..cubicTo(ecx - 15, ecy - 24, ecx + 15, ecy - 6, ecx + eradius, ecy - 18);
    canvas.drawPath(cloudPath1, cloudPaint);

    final cloudPath2 = Path()
      ..moveTo(ecx - eradius + 6, ecy + 18)
      ..cubicTo(ecx - 8, ecy + 8, ecx + 20, ecy + 26, ecx + eradius, ecy + 12);
    canvas.drawPath(cloudPath2, cloudPaint);

    // Spherical 3D shading
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
        stops: const [0.65, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(ecx, ecy), radius: eradius));
    canvas.drawCircle(Offset(ecx, ecy), eradius, shadowPaint);
    canvas.restore();

    // 🛰️ Apollo / Artemis Lunar Orbiter Satellite
    final satX = w * 0.28 + math.sin(ambientProg * 2 * math.pi) * 20.0;
    final satY = gy * 0.16;
    _drawLunarSatellite(canvas, satX, satY, ambientProg);
  }

  void _drawLunarSatellite(Canvas canvas, double x, double y, double ambientProg) {
    // Solar wings
    final wingPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawRect(Rect.fromLTWH(x - 24, y - 4, 14, 8), wingPaint);
    canvas.drawRect(Rect.fromLTWH(x + 10, y - 4, 14, 8), wingPaint);

    // Gold foil satellite body
    final bodyPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(x, y), width: 12, height: 12), const Radius.circular(3)),
      bodyPaint,
    );

    // Blinking green beacon
    final blink = (math.sin(ambientProg * 8 * math.pi) > 0);
    if (blink) {
      canvas.drawCircle(Offset(x, y - 8), 2.5, Paint()..color = const Color(0xFF4ADE80));
    }
  }

  /// 🪐 Europa: Colossal Jupiter looming above the glacial ice mountains
  void _drawEuropaJupiterAtmosphere(
      Canvas canvas, double w, double gy, double ambientProg) {
    final jcx = w * 0.74;
    final jcy = gy * 0.32;
    const jradius = 82.0;

    // Atmospheric warm haze
    canvas.drawCircle(
      Offset(jcx, jcy),
      jradius + 22,
      Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    canvas.save();
    final jupClip = Path()
      ..addOval(Rect.fromCircle(center: Offset(jcx, jcy), radius: jradius));
    canvas.clipPath(jupClip);

    // Jovian striped atmosphere base
    final jupBase = Paint()..color = const Color(0xFFFEF3C7);
    canvas.drawRect(Rect.fromCircle(center: Offset(jcx, jcy), radius: jradius), jupBase);

    final List<Map<String, dynamic>> bands = [
      {'y': -60.0, 'h': 16.0, 'c': const Color(0xFFB45309)},
      {'y': -36.0, 'h': 12.0, 'c': const Color(0xFFD97706)},
      {'y': -14.0, 'h': 24.0, 'c': const Color(0xFF78350F)},
      {'y': 18.0, 'h': 18.0, 'c': const Color(0xFF92400E)},
      {'y': 44.0, 'h': 22.0, 'c': const Color(0xFFB45309)},
    ];

    for (final b in bands) {
      final bp = Paint()
        ..color = (b['c'] as Color).withValues(alpha: 0.88)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawRect(
        Rect.fromLTWH(jcx - jradius, jcy + (b['y'] as double), jradius * 2, b['h'] as double),
        bp,
      );
    }

    // Great Red Spot Oval
    final grsPaint = Paint()..color = const Color(0xFFDC2626);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(jcx + 26, jcy + 24), width: 28, height: 16),
      grsPaint,
    );
    canvas.drawCircle(Offset(jcx + 26, jcy + 24), 4.5, Paint()..color = const Color(0xFFFDBA74));

    // Spherical 3D shading
    final jupShade = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
        stops: const [0.70, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(jcx, jcy), radius: jradius));
    canvas.drawCircle(Offset(jcx, jcy), jradius, jupShade);
    canvas.restore();

    // ❄️ Shimmering Ice Crystal Sparkles drifting above glacial mountains
    _drawDriftingIceSparkles(canvas, w, gy, ambientProg);
  }

  void _drawDriftingIceSparkles(Canvas canvas, double w, double gy, double ambientProg) {
    final sparklePaint = Paint()..color = const Color(0xFFE0F2FE);
    for (int i = 0; i < 24; i++) {
      final t = ((ambientProg + (i * 0.12)) % 1.0);
      final sx = ((i * 53.0) + (math.sin(t * 2 * math.pi) * 12.0)) % w;
      final sy = (gy * 0.15) + (t * (gy * 0.50));
      final size = 1.2 + ((i % 3) * 0.8);
      canvas.drawCircle(Offset(sx, sy), size, sparklePaint);
    }
  }

  /// 🪐 Saturn: Vast tilted golden planetary rings arcing across the sky
  void _drawSaturnRingedAtmosphere(
      Canvas canvas, double w, double gy, double ambientProg) {
    final scx = w * 0.72;
    final scy = gy * 0.22;
    const sradius = 46.0;

    // Atmospheric warm halo
    canvas.drawCircle(
      Offset(scx, scy),
      sradius + 18,
      Paint()
        ..color = const Color(0xFFFDE68A).withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // Back half of rings (behind planet)
    canvas.save();
    canvas.translate(scx, scy);
    canvas.rotate(-0.38); // Tilted -22 degrees

    final ringPaintOuter = Paint()
      ..color = const Color(0xFFD97706).withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0;
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 230, height: 55), ringPaintOuter);

    final ringPaintInner = Paint()
      ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0;
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 175, height: 42), ringPaintInner);
    canvas.restore();

    // Saturn Globe
    final saturnPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFEF3C7), Color(0xFFFBBF24), Color(0xFFB45309)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(scx, scy), radius: sradius));
    canvas.drawCircle(Offset(scx, scy), sradius, saturnPaint);

    // Front half of rings (in front of planet)
    canvas.save();
    canvas.translate(scx, scy);
    canvas.rotate(-0.38);

    // Clip to bottom half so rings cross cleanly in front of planet
    canvas.clipRect(const Rect.fromLTWH(-150, 0, 300, 100));
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 230, height: 55), ringPaintOuter);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 175, height: 42), ringPaintInner);
    canvas.restore();

    // Crescent moon Enceladus
    canvas.drawCircle(Offset(w * 0.32, gy * 0.16), 5.5, Paint()..color = const Color(0xFFF8FAFC));
  }

  /// 🔴 Mars: Pale sun, Phobos & Deimos twin moons and red dust haze
  void _drawMarsCelestialAtmosphere(
      Canvas canvas, double w, double gy, double ambientProg) {
    final sunCenter = Offset(w * 0.80, gy * 0.22);
    canvas.drawCircle(
      sunCenter,
      50,
      Paint()
        ..color = const Color(0xFFFDBA74).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    canvas.drawCircle(sunCenter, 22, Paint()..color = const Color(0xFFFED7AA));

    // Phobos (larger, cratered potato moon)
    final phobosX = w * 0.32 + math.sin(ambientProg * 2 * math.pi) * 12.0;
    final phobosY = gy * 0.18;
    final phobosPaint = Paint()..color = const Color(0xFFCBD5E1);
    canvas.drawOval(Rect.fromCenter(center: Offset(phobosX, phobosY), width: 18, height: 13), phobosPaint);
    canvas.drawCircle(Offset(phobosX - 3, phobosY - 2), 2.2, Paint()..color = const Color(0xFF64748B));
    canvas.drawCircle(Offset(phobosX + 3, phobosY + 2), 1.8, Paint()..color = const Color(0xFF64748B));

    // Deimos (smaller distant moon)
    final deimosX = w * 0.60 - math.sin(ambientProg * 2 * math.pi) * 8.0;
    final deimosY = gy * 0.12;
    canvas.drawCircle(Offset(deimosX, deimosY), 4.5, Paint()..color = const Color(0xFFE2E8F0));

    // Drifting red dust wisps
    final dustPaint = Paint()
      ..color = const Color(0xFFEA580C).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final dustOffset = math.sin(ambientProg * 2 * math.pi) * 20.0;
    canvas.drawRect(Rect.fromLTWH(0, gy * 0.30 + dustOffset, w, 35), dustPaint);
  }

  /// 🌀 Jupiter: Jovian storm auroras, Io & Europa crescent moons
  void _drawJupiterCelestialAtmosphere(
      Canvas canvas, double w, double gy, double ambientProg) {
    final wave = math.sin(ambientProg * 2 * math.pi) * 16.0;
    final aurPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawRect(Rect.fromLTWH(0, gy * 0.18 + wave, w, 40), aurPaint);
    canvas.drawRect(Rect.fromLTWH(0, gy * 0.34 - wave, w, 32), aurPaint);

    final eurX = w * 0.34;
    final eurY = gy * 0.14;
    canvas.drawCircle(Offset(eurX, eurY), 8.0, Paint()..color = const Color(0xFFE0F2FE));
    canvas.drawCircle(Offset(eurX + 2, eurY - 1), 7.0, Paint()..color = const Color(0xFF0F172A));

    final ioX = w * 0.72;
    final ioY = gy * 0.20;
    canvas.drawCircle(Offset(ioX, ioY), 9.0, Paint()..color = const Color(0xFFFDE047));
    canvas.drawCircle(Offset(ioX + 3, ioY - 1), 8.0, Paint()..color = const Color(0xFF0F172A));
  }

  /// 🌑 Pluto: Charon companion moon & deep purple nebula starfield
  void _drawPlutoCharonAtmosphere(
      Canvas canvas, double w, double gy, double ambientProg) {
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (int i = 0; i < 45; i++) {
      final sx = ((i * 91.0) % w);
      final sy = ((i * 51.0) % (gy * 0.65));
      final sz = 0.8 + ((i % 3) * 0.5);
      canvas.drawCircle(Offset(sx, sy), sz, starPaint);
    }

    final ccx = w * 0.75;
    final ccy = gy * 0.22;
    const cradius = 44.0;

    canvas.drawCircle(
      Offset(ccx, ccy),
      cradius + 12,
      Paint()
        ..color = const Color(0xFFA855F7).withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    final charonPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Color(0xFF94A3B8), Color(0xFF475569)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(ccx, ccy), radius: cradius));
    canvas.drawCircle(Offset(ccx, ccy), cradius, charonPaint);

    final craterPaint = Paint()..color = const Color(0xFF334155).withValues(alpha: 0.65);
    canvas.drawCircle(Offset(ccx - 12, ccy - 8), 7.0, craterPaint);
    canvas.drawCircle(Offset(ccx + 10, ccy + 12), 9.0, craterPaint);
    canvas.drawCircle(Offset(ccx - 6, ccy + 18), 5.5, craterPaint);

    final nebPaint = Paint()
      ..color = const Color(0xFFC084FC).withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawRect(Rect.fromLTWH(0, gy * 0.32, w, 40), nebPaint);
  }

  /// 🟡 Venus: Golden sunbeams through sulfuric clouds & atmospheric aerostat
  void _drawVenusCelestialAtmosphere(
      Canvas canvas, double w, double gy, double ambientProg) {
    final vSun = Offset(w * 0.76, gy * 0.20);
    canvas.drawCircle(
      vSun,
      65,
      Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
    canvas.drawCircle(vSun, 30, Paint()..color = const Color(0xFFFEF08A));

    final rayPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFEF08A).withValues(alpha: 0.20),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, gy * 0.15, w, gy * 0.45));

    final rayPath = Path();
    rayPath.moveTo(vSun.dx - 20, vSun.dy);
    rayPath.lineTo(vSun.dx - 180, gy - 10);
    rayPath.lineTo(vSun.dx - 110, gy - 10);
    rayPath.close();
    canvas.drawPath(rayPath, rayPaint);

    final rayPath2 = Path();
    rayPath2.moveTo(vSun.dx, vSun.dy);
    rayPath2.lineTo(vSun.dx - 40, gy - 10);
    rayPath2.lineTo(vSun.dx + 40, gy - 10);
    rayPath2.close();
    canvas.drawPath(rayPath2, rayPaint);

    final aeroX = w * 0.32 + math.sin(ambientProg * 2 * math.pi) * 16.0;
    final aeroY = gy * 0.16;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(aeroX, aeroY), width: 34, height: 16),
      Paint()..color = const Color(0xFFFFFBEB),
    );
    canvas.drawRect(
      Rect.fromLTWH(aeroX - 8, aeroY + 8, 16, 4),
      Paint()..color = const Color(0xFFB45309),
    );
  }

  /// 🟢 Titan: Emerald haze, veiled Saturn silhouette, bioluminescent spores
  void _drawTitanSaturnAtmosphere(
      Canvas canvas, double w, double gy, double ambientProg) {
    final tcx = w * 0.70;
    final tcy = gy * 0.24;
    const tradius = 58.0;

    canvas.drawCircle(
      Offset(tcx, tcy),
      tradius + 20,
      Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    canvas.drawCircle(
      Offset(tcx, tcy),
      tradius,
      Paint()..color = const Color(0xFFD97706).withValues(alpha: 0.55),
    );

    final ringPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.save();
    canvas.translate(tcx, tcy);
    canvas.rotate(-0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 220, height: 48), ringPaint);
    canvas.restore();

    final sporePaint = Paint()..color = const Color(0xFF34D399);
    for (int i = 0; i < 20; i++) {
      final t = ((ambientProg + (i * 0.14)) % 1.0);
      final sx = ((i * 61.0) + math.sin(t * 2 * math.pi) * 16.0) % w;
      final sy = (gy * 0.12) + (t * (gy * 0.55));
      final sz = 1.2 + ((i % 3) * 0.7);
      canvas.drawCircle(Offset(sx, sy), sz, sporePaint);
    }
  }

  /// 🔵 Neptune: Deep cosmic cobalt, Triton cryo-geysers, ring arcs
  void _drawNeptuneCelestialAtmosphere(
      Canvas canvas, double w, double gy, double ambientProg) {
    final wave = math.sin(ambientProg * 2 * math.pi) * 14.0;
    final aurPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawRect(Rect.fromLTWH(0, gy * 0.16 + wave, w, 32), aurPaint);

    final ringPaint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, gy * 0.8), width: w * 1.2, height: gy * 1.1),
      -math.pi * 0.85,
      math.pi * 0.70,
      false,
      ringPaint,
    );

    final tcx = w * 0.76;
    final tcy = gy * 0.22;
    canvas.drawCircle(Offset(tcx, tcy), 14.0, Paint()..color = const Color(0xFFE0F2FE));
    final plumePaint = Paint()
      ..color = const Color(0xFF67E8F9).withValues(alpha: 0.70)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(tcx - 5, tcy - 12), Offset(tcx - 14, tcy - 28), plumePaint);
    canvas.drawLine(Offset(tcx + 4, tcy - 12), Offset(tcx + 12, tcy - 26), plumePaint);
  }

  /// 💨 Cozy Chimney Smoke Drifting Gently into the Sky
  void _drawChimneySmoke(Canvas canvas, double cx, double cy,
      {double ambientProg = 0.0}) {
    final smokePaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (int i = 0; i < 6; i++) {
      final t = ((ambientProg + (i * 0.18)) % 1.0);
      final sx = cx + (math.sin(t * 2 * math.pi) * 14.0) + (t * 22.0);
      final sy = cy - (t * 85.0);
      final radius = 5.0 + (t * 14.0);
      final alpha = (1.0 - t) * 0.32;
      smokePaint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(sx, sy), radius, smokePaint);
    }
  }

  /// 💨 Traditional Dutch Windmill with Rotating Timber Sails
  void _drawDutchWindmill(Canvas canvas, double x, double y,
      {double ambientProg = 0.0, bool isNight = false}) {
    // Stone base
    final basePath = Path();
    basePath.moveTo(x - 18, y);
    basePath.lineTo(x - 14, y - 48);
    basePath.lineTo(x + 14, y - 48);
    basePath.lineTo(x + 18, y);
    basePath.close();
    canvas.drawPath(
        basePath,
        Paint()
          ..color =
              isNight ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    // Wooden dome cap
    final capPath = Path();
    capPath.moveTo(x - 16, y - 48);
    capPath.quadraticBezierTo(x, y - 62, x + 16, y - 48);
    capPath.close();
    canvas.drawPath(capPath, Paint()..color = const Color(0xFF78350F));

    // Warm round window
    canvas.drawCircle(
      Offset(x, y - 28),
      4.5,
      Paint()
        ..color = isNight ? const Color(0xFFFFB703) : const Color(0xFF38BDF8),
    );

    // Center hub for rotating sails
    final hub = Offset(x, y - 46);
    final angle = ambientProg * 2 * math.pi;

    canvas.save();
    canvas.translate(hub.dx, hub.dy);
    canvas.rotate(angle);

    final sailPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;
    final sparPaint = Paint()
      ..color = const Color(0xFF92400E)
      ..strokeWidth = 2.0;

    // 4 lattice sails
    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * (math.pi / 2));
      // Spar
      canvas.drawLine(Offset.zero, const Offset(0, -38), sparPaint);
      // Sail canvas
      final sail = Path();
      sail.moveTo(1.5, -12);
      sail.lineTo(9.5, -14);
      sail.lineTo(9.5, -36);
      sail.lineTo(1.5, -36);
      sail.close();
      canvas.drawPath(sail, sailPaint);
      canvas.restore();
    }

    // Hub cap
    canvas.drawCircle(
        Offset.zero, 3.5, Paint()..color = const Color(0xFF451A03));
    canvas.restore();
  }

  /// 🎈 Striped Hot Air Balloon Floating Across Sky
  void _drawHotAirBalloon(Canvas canvas, double x, double y) {
    // Balloon envelope
    final envPath = Path();
    envPath.moveTo(x - 18, y - 10);
    envPath.cubicTo(x - 24, y - 38, x + 24, y - 38, x + 18, y - 10);
    envPath.lineTo(x + 7, y + 10);
    envPath.lineTo(x - 7, y + 10);
    envPath.close();

    canvas.drawPath(
      envPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFEF4444),
            Color(0xFFFBBF24),
            Color(0xFF06B6D4),
            Color(0xFFEC4899)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(
            Rect.fromCenter(center: Offset(x, y - 14), width: 48, height: 48)),
    );

    // Ropes to basket
    final ropePaint = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(x - 6, y + 10), Offset(x - 4, y + 18), ropePaint);
    canvas.drawLine(Offset(x + 6, y + 10), Offset(x + 4, y + 18), ropePaint);

    // Wicker basket
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y + 21), width: 9, height: 6),
          const Radius.circular(1.5)),
      Paint()..color = const Color(0xFF92400E),
    );
  }

  /// 🌉 Classical Stone Arched Footbridge Spanning River
  void _drawStoneBridge(Canvas canvas, double x, double y,
      {bool isNight = false}) {
    // Arch Path
    final bridgePath = Path();
    bridgePath.moveTo(x - 46, y - 40);
    bridgePath.lineTo(x + 46, y - 40);
    bridgePath.lineTo(x + 46, y + 42);
    bridgePath.lineTo(x - 46, y + 42);
    bridgePath.close();

    // Stone bridge body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: 90, height: 80),
          const Radius.circular(8)),
      Paint()
        ..color = isNight ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );

    // Under-arch cutout for water
    final archCut = Path();
    archCut.moveTo(x - 30, y + 42);
    archCut.quadraticBezierTo(x, y - 4, x + 30, y + 42);
    archCut.close();
    canvas.drawPath(
        archCut,
        Paint()
          ..color =
              isNight ? const Color(0xFF0369A1) : const Color(0xFF0284C7));

    // Bridge Balustrade Rails
    final railPaint = Paint()
      ..color = isNight ? const Color(0xFF1E293B) : const Color(0xFF94A3B8)
      ..strokeWidth = 2.4;
    canvas.drawLine(Offset(x - 44, y - 36), Offset(x + 44, y - 36), railPaint);
    canvas.drawLine(Offset(x - 44, y + 36), Offset(x + 44, y + 36), railPaint);

    // 4 Coach Lanterns at bridge corners
    for (final ox in [-40.0, 40.0]) {
      for (final oy in [-38.0, 38.0]) {
        canvas.drawCircle(
          Offset(x + ox, y + oy),
          isNight ? 9.0 : 6.0,
          Paint()
            ..color =
                const Color(0xFFFFD700).withValues(alpha: isNight ? 0.45 : 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        canvas.drawCircle(Offset(x + ox, y + oy), 2.5,
            Paint()..color = const Color(0xFFFFD700));
      }
    }
  }

  /// ⚙️ Rotating Wooden Waterwheel
  void _drawWaterWheel(Canvas canvas, double x, double y,
      {double ambientProg = 0.0}) {
    canvas.save();
    canvas.translate(x, y);
    final angle = ambientProg * 2 * math.pi;
    canvas.rotate(angle);

    final timberPaint = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = 2.5;
    // Outer Rim
    canvas.drawCircle(
        Offset.zero,
        18,
        Paint()
          ..color = const Color(0xFF92400E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    // Inner Hub
    canvas.drawCircle(Offset.zero, 5, Paint()..color = const Color(0xFF451A03));

    // 8 Paddles
    for (int i = 0; i < 8; i++) {
      canvas.save();
      canvas.rotate(i * (math.pi / 4));
      canvas.drawLine(Offset.zero, const Offset(0, -18), timberPaint);
      canvas.drawLine(
          const Offset(-4, -18),
          const Offset(4, -18),
          Paint()
            ..color = const Color(0xFFB45309)
            ..strokeWidth = 2.0);
      canvas.restore();
    }
    canvas.restore();
  }

  /// 🦢 Elegant White Swan Swimming in River
  void _drawSwan(Canvas canvas, double x, double y) {
    // Water ripple under swan
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + 3), width: 22, height: 5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Swan Body
    final body = Path();
    body.moveTo(x - 9, y);
    body.quadraticBezierTo(x - 5, y + 4, x + 4, y + 4);
    body.quadraticBezierTo(x + 9, y + 2, x + 8, y - 2);
    body.quadraticBezierTo(x + 2, y, x - 7, y - 2);
    body.close();
    canvas.drawPath(body, Paint()..color = Colors.white);

    // Swan S-Curved Neck & Head
    final neck = Path();
    neck.moveTo(x + 6, y);
    neck.cubicTo(x + 10, y - 6, x + 8, y - 12, x + 5, y - 11);
    neck.close();
    canvas.drawPath(neck, Paint()..color = Colors.white);

    // Orange Beak
    canvas.drawCircle(
        Offset(x + 4, y - 11), 1.2, Paint()..color = const Color(0xFFF97316));
  }

  /// 🪷 Floating Pink Lotus Water Lily
  void _drawWaterLily(Canvas canvas, double x, double y) {
    // Lily Pad
    canvas.drawCircle(
        Offset(x, y), 6.5, Paint()..color = const Color(0xFF059669));
    // Pink Lotus Blossom
    canvas.drawCircle(
        Offset(x - 1, y - 1), 3.0, Paint()..color = const Color(0xFFF472B6));
    canvas.drawCircle(
        Offset(x, y), 1.5, Paint()..color = const Color(0xFFFEF08A));
  }

  /// 🚩 Festive Party Bunting (Triangle celebration flags)
  void _drawPartyBunting(
      Canvas canvas, double x1, double y1, double x2, double y2) {
    // String wire
    final stringPath = Path();
    stringPath.moveTo(x1, y1);
    stringPath.quadraticBezierTo((x1 + x2) / 2, ((y1 + y2) / 2) + 8, x2, y2);
    canvas.drawPath(
        stringPath,
        Paint()
          ..color = Colors.white70
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke);

    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFFFBBF24),
      const Color(0xFF06B6D4),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
    ];

    // Triangle Pennant Flags hanging
    const flagCount = 6;
    for (int i = 0; i < flagCount; i++) {
      final t = (i + 0.5) / flagCount;
      final fx = ui.lerpDouble(x1, x2, t)!;
      final fy = ui.lerpDouble(y1, y2, t)! + math.sin(t * math.pi) * 8.0;

      final flag = Path();
      flag.moveTo(fx - 4, fy);
      flag.lineTo(fx + 4, fy);
      flag.lineTo(fx, fy + 7);
      flag.close();
      canvas.drawPath(flag, Paint()..color = colors[i % colors.length]);
    }
  }

  /// 🦋 Fluttering Butterfly (Daytime)
  void _drawButterfly(Canvas canvas, double x, double y,
      {double ambientProg = 0.0, Color color = const Color(0xFFFB923C)}) {
    final wingScale = math.sin(ambientProg * 18 * math.pi).abs();
    canvas.save();
    canvas.translate(x, y);

    final wingPaint = Paint()..color = color;
    // Left wing
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(-3.5 * wingScale, -2),
          width: 7 * wingScale,
          height: 6),
      wingPaint,
    );
    // Right wing
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(3.5 * wingScale, -2), width: 7 * wingScale, height: 6),
      wingPaint,
    );
    // Body
    canvas.drawLine(
        const Offset(0, -3),
        const Offset(0, 3),
        Paint()
          ..color = const Color(0xFF1E293B)
          ..strokeWidth = 1.2);
    canvas.restore();
  }

  /// ✨ Pulsing Firefly (Nighttime)
  void _drawFirefly(Canvas canvas, double x, double y,
      {double ambientProg = 0.0, double phase = 0.0}) {
    final pulse =
        0.4 + (math.sin((ambientProg + phase) * 8 * math.pi) * 0.6).abs();
    canvas.drawCircle(
      Offset(x, y),
      8.0 * pulse,
      Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.45 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
        Offset(x, y), 2.2, Paint()..color = const Color(0xFFFEF08A));
  }

  /// 🌸 Japanese Cherry Blossom (Sakura) Tree with Falling Petals
  void _drawCherryBlossomTree(Canvas canvas, double x, double y,
      {double scale = 1.0, double ambientProg = 0.0}) {
    // Tree Trunk
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y - (28 * scale)),
      Paint()
        ..color = const Color(0xFF5B3417)
        ..strokeWidth = 5.0 * scale,
    );
    // Soft pink blossom foliage
    final p1 = Paint()..color = const Color(0xFFF472B6);
    final p2 = Paint()..color = const Color(0xFFFBCFE8);
    canvas.drawCircle(Offset(x, y - (38 * scale)), 17 * scale, p1);
    canvas.drawCircle(
        Offset(x - (8 * scale), y - (32 * scale)), 13 * scale, p2);
    canvas.drawCircle(
        Offset(x + (8 * scale), y - (32 * scale)), 13 * scale, p2);
    canvas.drawCircle(Offset(x, y - (46 * scale)), 12 * scale, p2);

    // Drifting flower petals
    for (int i = 0; i < 3; i++) {
      final t = (ambientProg + (i * 0.33)) % 1.0;
      final px = x - 12 + (t * 26) + math.sin(t * 8) * 4;
      final py = y - 25 + (t * 30);
      canvas.drawCircle(Offset(px, py), 1.6,
          Paint()..color = const Color(0xFFF472B6).withValues(alpha: 1.0 - t));
    }
  }

  /// 🚀 Cosmic Space Rocket / Satellite soaring through upper atmosphere
  void _drawCosmicRocket(Canvas canvas, double x, double y,
      {double ambientProg = 0.0}) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(-0.38);

    // 1. Plasma exhaust flame trail (pulsing with ambientProg)
    final pulse = 0.85 + math.sin(ambientProg * 14 * math.pi) * 0.15;
    final flameLen = 75.0 * pulse;
    final flamePath = Path();
    flamePath.moveTo(-24, -5);
    flamePath.lineTo(-flameLen, 0);
    flamePath.lineTo(-24, 5);
    flamePath.close();

    final flameShader = const LinearGradient(
      colors: [
        Color(0xFF38BDF8),
        Color(0xFFFB923C),
        Color(0xFFEF4444),
        Colors.transparent
      ],
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
    ).createShader(Rect.fromLTWH(-flameLen, -5, flameLen - 24, 10));
    canvas.drawPath(flamePath, Paint()..shader = flameShader);

    // Inner bright hot core flame
    final innerFlame = Path();
    innerFlame.moveTo(-24, -2.5);
    innerFlame.lineTo(-44 * pulse, 0);
    innerFlame.lineTo(-24, 2.5);
    innerFlame.close();
    canvas.drawPath(innerFlame, Paint()..color = const Color(0xFFFEF08A));

    // 2. Rocket Fuselage
    final bodyPath = Path();
    bodyPath.moveTo(-24, -7);
    bodyPath.lineTo(12, -7);
    bodyPath.quadraticBezierTo(26, -5, 34, 0);
    bodyPath.quadraticBezierTo(26, 5, 12, 7);
    bodyPath.lineTo(-24, 7);
    bodyPath.close();
    canvas.drawPath(bodyPath, Paint()..color = const Color(0xFFF1F5F9));

    // Red Nose Cone tip
    final nosePath = Path();
    nosePath.moveTo(14, -6.5);
    nosePath.quadraticBezierTo(26, -5, 34, 0);
    nosePath.quadraticBezierTo(26, 5, 14, 6.5);
    nosePath.close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFFEF4444));

    // Delta stabilization fins
    final topFin = Path()
      ..moveTo(-18, -7)
      ..lineTo(-28, -18)
      ..lineTo(-10, -7)
      ..close();
    canvas.drawPath(topFin, Paint()..color = const Color(0xFFDC2626));
    final btmFin = Path()
      ..moveTo(-18, 7)
      ..lineTo(-28, 18)
      ..lineTo(-10, 7)
      ..close();
    canvas.drawPath(btmFin, Paint()..color = const Color(0xFFDC2626));

    // Glowing cyan cockpit porthole window
    canvas.drawCircle(
      const Offset(2, 0),
      4.5,
      Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
        const Offset(2, 0), 3.0, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawCircle(const Offset(1, -1), 1.0, Paint()..color = Colors.white);

    // Blinking beacon light on top fin tip
    canvas.drawCircle(
        const Offset(-28, -18), 2.2, Paint()..color = const Color(0xFFF43F5E));

    canvas.restore();
  }

  /// ☄️ Luminous shooting star with tapering tail
  void _drawShootingStar(
      Canvas canvas, double startX, double startY, double length) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white,
          const Color(0xFF38BDF8).withValues(alpha: 0.6),
          Colors.transparent
        ],
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ).createShader(
          Rect.fromLTWH(startX - length, startY, length, length * 0.4))
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(startX, startY),
        Offset(startX - length, startY + (length * 0.35)), paint);
    canvas.drawCircle(
        Offset(startX, startY), 2.2, Paint()..color = Colors.white);
  }

  void _drawFluffyCloud(Canvas canvas, double cx, double cy, double r) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.80);
    canvas.drawCircle(Offset(cx, cy), r, cloudPaint);
    canvas.drawCircle(
        Offset(cx + r * 0.9, cy - r * 0.35), r * 1.25, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 1.9, cy - r * 0.15), r, cloudPaint);
    canvas.drawCircle(Offset(cx + r * 2.6, cy + r * 0.1), r * 0.75, cloudPaint);
  }

  /// 🕊️ Flying Bird with Organic Wing Flapping
  void _drawFlyingBird(
    Canvas canvas,
    double x,
    double y,
    double span, {
    double ambientProg = 0.0,
    double phase = 0.0,
    Color color = const Color(0xFF0369A1),
  }) {
    final wingFlap =
        math.sin((ambientProg + phase) * 12 * math.pi) * (span * 0.42);
    final birdPaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final birdPath = Path();
    birdPath.moveTo(x - span, y + wingFlap);
    birdPath.quadraticBezierTo(
        x - (span * 0.45), y - (span * 0.35) - wingFlap * 0.35, x, y);
    birdPath.quadraticBezierTo(x + (span * 0.45),
        y - (span * 0.35) - wingFlap * 0.35, x + span, y + wingFlap);
    canvas.drawPath(birdPath, birdPaint);
  }

  /// 🕊️ Flock of Birds soaring gracefully in formation across the sky
  void _drawFlyingBirdsFlock(
      Canvas canvas, double w, double gy, double ambientProg) {
    // Flock travels horizontally across screen
    final baseOffset = (ambientProg * (w + 200)) - 100.0;
    final flockY = gy * 0.14 + math.sin(ambientProg * 4 * math.pi) * 8.0;

    final birdPositions = [
      Offset(baseOffset, flockY),
      Offset(baseOffset - 20, flockY + 11),
      Offset(baseOffset - 40, flockY + 22),
      Offset(baseOffset - 60, flockY + 33),
      Offset(baseOffset - 24, flockY - 11),
      Offset(baseOffset - 48, flockY - 20),
    ];

    for (int i = 0; i < birdPositions.length; i++) {
      final pos = birdPositions[i];
      if (pos.dx >= -40 && pos.dx <= w + 40) {
        _drawFlyingBird(
          canvas,
          pos.dx,
          pos.dy,
          9.0 + (i == 0 ? 3.5 : 0.0),
          ambientProg: ambientProg,
          phase: i * 0.16,
          color: const Color(0xFF0284C7),
        );
      }
    }
  }

  /// 🌊 Cascading Mountain Waterfall with Shimmering Rapids and White Foam
  void _drawMountainWaterfall(
    Canvas canvas,
    double x,
    double topY,
    double btmY, {
    double ambientProg = 0.0,
    bool isNight = false,
  }) {
    final waterHeight = btmY - topY;
    if (waterHeight <= 0) return;

    // Waterfall stream path
    final fallPath = Path();
    fallPath.moveTo(x - 3, topY);
    fallPath.cubicTo(x - 5, topY + waterHeight * 0.35, x - 7,
        topY + waterHeight * 0.7, x - 10, btmY);
    fallPath.lineTo(x + 10, btmY);
    fallPath.cubicTo(x + 7, topY + waterHeight * 0.7, x + 5,
        topY + waterHeight * 0.35, x + 3, topY);
    fallPath.close();

    final fallShader = LinearGradient(
      colors: isNight
          ? [
              const Color(0xFF38BDF8).withValues(alpha: 0.35),
              const Color(0xFF67E8F9).withValues(alpha: 0.65),
              Colors.white.withValues(alpha: 0.8),
            ]
          : [
              const Color(0xFF0284C7).withValues(alpha: 0.50),
              const Color(0xFF38BDF8).withValues(alpha: 0.80),
              Colors.white.withValues(alpha: 0.95),
            ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(x - 12, topY, 24, waterHeight));

    canvas.drawPath(fallPath, Paint()..shader = fallShader);

    // Animated shimmering water streaks flowing down
    for (int i = 0; i < 4; i++) {
      final t = (ambientProg * 2.2 + (i * 0.25)) % 1.0;
      final streakY = topY + (t * waterHeight);
      final streakW = 2.0 + (t * 4.0);
      final streakX = x + math.sin(t * math.pi) * 3;
      canvas.drawLine(
        Offset(streakX - streakW / 2, streakY),
        Offset(streakX + streakW / 2, streakY + 8),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round,
      );
    }

    // Splash mist & foam pool at bottom
    final splashPulse = 0.85 + math.sin(ambientProg * 8 * math.pi) * 0.15;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(x, btmY),
          width: 28 * splashPulse,
          height: 9 * splashPulse),
      Paint()
        ..color = Colors.white.withValues(alpha: isNight ? 0.45 : 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(x, btmY + 2), width: 34 * splashPulse, height: 6),
      Paint()
        ..color = (isNight ? const Color(0xFF38BDF8) : const Color(0xFFBAE6FD))
            .withValues(alpha: 0.55),
    );
  }

  /// 👑 Day 90 Celestial Sovereign Grandeur: Golden Aura, Ascending Light Pillars & Soaring Golden Eagle
  void _drawDay90CelestialGrandeur(
    Canvas canvas,
    double w,
    double gy,
    double ambientProg,
  ) {
    final centerX = w * 0.5;
    final crownCenter = Offset(centerX, gy - 430);

    // 1. Divine Radiant Sunburst Rays rotating slowly behind crown
    const rayCount = 16;
    const rayRadius = 140.0;
    final rotAngle = ambientProg * 2 * math.pi;
    for (int i = 0; i < rayCount; i++) {
      final angle = rotAngle + (i * (2 * math.pi / rayCount));
      final rayPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.28),
            const Color(0xFFF59E0B).withValues(alpha: 0.12),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: crownCenter, radius: rayRadius))
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      final startPt = Offset(
        crownCenter.dx + math.cos(angle) * 35,
        crownCenter.dy + math.sin(angle) * 35,
      );
      final endPt = Offset(
        crownCenter.dx + math.cos(angle) * rayRadius,
        crownCenter.dy + math.sin(angle) * rayRadius,
      );
      canvas.drawLine(startPt, endPt, rayPaint);
    }

    // 2. Twin Ascending Divine Light Pillars flanking the citadel
    final pillarLeftX = w * 0.22;
    final pillarRightX = w * 0.78;
    final pillarTopY = gy - 480;
    final pillarBtmY = gy + 20;
    const pillarWidth = 22.0;

    final pillarShader = LinearGradient(
      colors: [
        Colors.transparent,
        const Color(0xFFFFD700).withValues(alpha: 0.22),
        const Color(0xFFFDE047).withValues(alpha: 0.35),
        const Color(0xFFFFD700).withValues(alpha: 0.10),
        Colors.transparent,
      ],
      stops: const [0.0, 0.25, 0.5, 0.85, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    canvas.drawRect(
      Rect.fromLTWH(pillarLeftX - pillarWidth / 2, pillarTopY, pillarWidth,
          pillarBtmY - pillarTopY),
      Paint()
        ..shader = pillarShader.createShader(Rect.fromLTWH(
            pillarLeftX - pillarWidth / 2,
            pillarTopY,
            pillarWidth,
            pillarBtmY - pillarTopY))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawRect(
      Rect.fromLTWH(pillarRightX - pillarWidth / 2, pillarTopY, pillarWidth,
          pillarBtmY - pillarTopY),
      Paint()
        ..shader = pillarShader.createShader(Rect.fromLTWH(
            pillarRightX - pillarWidth / 2,
            pillarTopY,
            pillarWidth,
            pillarBtmY - pillarTopY))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // 3. Soaring Majestic Golden Eagle circling above citadel
    final eagleOrbitX =
        centerX + math.cos(ambientProg * 2 * math.pi) * (w * 0.32);
    final eagleOrbitY = gy - 360 + math.sin(ambientProg * 4 * math.pi) * 25;
    _drawGoldenEagle(canvas, eagleOrbitX, eagleOrbitY, ambientProg);

    // 4. Shimmering Golden Dust particles ascending
    for (int i = 0; i < 14; i++) {
      final t = (ambientProg + (i * 0.071)) % 1.0;
      final px = centerX - (w * 0.35) + ((i * 47) % (w * 0.70));
      final py = gy + 10 - (t * 460);
      final sparkleAlpha = math.sin(t * math.pi);
      canvas.drawCircle(
        Offset(px, py),
        2.2 * sparkleAlpha,
        Paint()
          ..color =
              const Color(0xFFFFE066).withValues(alpha: 0.75 * sparkleAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawCircle(
        Offset(px, py),
        1.2 * sparkleAlpha,
        Paint()..color = Colors.white.withValues(alpha: 0.9 * sparkleAlpha),
      );
    }
  }

  /// 🦅 Majestic Golden Eagle with broad outstretched wings soaring
  void _drawGoldenEagle(Canvas canvas, double x, double y, double ambientProg) {
    canvas.save();
    canvas.translate(x, y);

    final wingFlap = math.sin(ambientProg * 8 * math.pi) * 7.0;

    // Outer Golden Glow
    canvas.drawCircle(
      Offset.zero,
      28,
      Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Left Wing
    final leftWing = Path();
    leftWing.moveTo(0, 0);
    leftWing.cubicTo(
        -14, -8 + wingFlap, -30, -18 + wingFlap, -44, -12 + wingFlap);
    leftWing.cubicTo(-34, -2 + wingFlap, -18, 2, 0, 4);
    leftWing.close();
    canvas.drawPath(leftWing, Paint()..color = const Color(0xFFD97706));

    // Right Wing
    final rightWing = Path();
    rightWing.moveTo(0, 0);
    rightWing.cubicTo(
        14, -8 + wingFlap, 30, -18 + wingFlap, 44, -12 + wingFlap);
    rightWing.cubicTo(34, -2 + wingFlap, 18, 2, 0, 4);
    rightWing.close();
    canvas.drawPath(rightWing, Paint()..color = const Color(0xFFD97706));

    // Feather Highlights
    final featherPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        const Offset(0, 0), Offset(-40, -10 + wingFlap), featherPaint);
    canvas.drawLine(
        const Offset(0, 0), Offset(40, -10 + wingFlap), featherPaint);

    // Eagle Body & Tail
    final body = Path();
    body.moveTo(-4, -6);
    body.lineTo(4, -6);
    body.lineTo(3, 10);
    body.lineTo(6, 18);
    body.lineTo(-6, 18);
    body.lineTo(-3, 10);
    body.close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF92400E));

    // Golden Head & Beak
    canvas.drawCircle(const Offset(0, -9), 4.5, Paint()..color = Colors.white);
    final beak = Path()
      ..moveTo(-2, -9)
      ..lineTo(2, -9)
      ..lineTo(0, -14)
      ..close();
    canvas.drawPath(beak, Paint()..color = const Color(0xFFFBBF24));

    canvas.restore();
  }

  void _drawPicketFence(
      Canvas canvas, double startX, double groundY, int pickets) {
    final fencePaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final shadowPaint = Paint()..color = Colors.black26;

    // Cross rails
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(startX, groundY - 18, pickets * 12.0 + 4, 3),
            const Radius.circular(1.5)),
        fencePaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(startX, groundY - 8, pickets * 12.0 + 4, 3),
            const Radius.circular(1.5)),
        fencePaint);

    // Vertical pickets with pointed tops
    for (int i = 0; i < pickets; i++) {
      final px = startX + (i * 12.0) + 2;
      final path = Path();
      path.moveTo(px, groundY);
      path.lineTo(px, groundY - 22);
      path.lineTo(px + 3, groundY - 26);
      path.lineTo(px + 6, groundY - 22);
      path.lineTo(px + 6, groundY);
      path.close();
      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, fencePaint);
    }
  }

  void _drawFlowerbed(Canvas canvas, double x, double y) {
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFFFBBF24),
      const Color(0xFFEC4899),
      const Color(0xFF38BDF8),
      const Color(0xFFA855F7)
    ];
    for (int i = 0; i < 6; i++) {
      final fx = x + (i * 7) - 17;
      final fy = y + math.sin(i * 1.8) * 3;
      final stemPaint = Paint()
        ..color = const Color(0xFF15803D)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(fx, fy), Offset(fx, fy - 7), stemPaint);
      final petalPaint = Paint()..color = colors[i % colors.length];
      canvas.drawCircle(Offset(fx, fy - 8), 3.2, petalPaint);
    }
  }

  void _drawTree(Canvas canvas, double x, double y, {double scale = 1.0}) {
    // Tree Trunk
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y - (28 * scale)),
      Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 5.0 * scale,
    );
    // Overlapping lush foliage balls
    final leafPaint1 = Paint()..color = const Color(0xFF15803D);
    final leafPaint2 = Paint()..color = const Color(0xFF22C55E);
    canvas.drawCircle(Offset(x, y - (38 * scale)), 16 * scale, leafPaint1);
    canvas.drawCircle(
        Offset(x - (8 * scale), y - (32 * scale)), 12 * scale, leafPaint2);
    canvas.drawCircle(
        Offset(x + (8 * scale), y - (32 * scale)), 12 * scale, leafPaint2);
    canvas.drawCircle(Offset(x, y - (44 * scale)), 11 * scale, leafPaint2);

    // Little red apples on branches
    final applePaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(
        Offset(x - (4 * scale), y - (36 * scale)), 2.4 * scale, applePaint);
    canvas.drawCircle(
        Offset(x + (5 * scale), y - (40 * scale)), 2.4 * scale, applePaint);
    canvas.drawCircle(
        Offset(x + (3 * scale), y - (30 * scale)), 2.4 * scale, applePaint);
  }

  void _drawStreetLamp(Canvas canvas, double x, double y,
      {bool isNight = false}) {
    // Post
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y - 46),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 3.2,
    );
    // Glowing warm lantern orb
    final glowRadius = isNight ? 28.0 : 20.0;
    canvas.drawCircle(
      Offset(x, y - 46),
      glowRadius,
      Paint()
        ..color = (isNight ? const Color(0xFFFFB703) : const Color(0xFFFFFC00))
            .withValues(alpha: isNight ? 0.45 : 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(
        Offset(x, y - 46), 5.5, Paint()..color = const Color(0xFFFFFC00));
  }

  /// 🌊 6. Boundless Sovereign Ocean ("Samudram") surrounding Fortress Island ("Dweepu")
  /// Includes golden shoreline beach, granite sea walls, shimmering moonlight reflection beam,
  /// undulating wave crests, bioluminescent glowing wave foam, darting schools of glowing fish,
  /// ceremonial marble naval pier, and nautical buoy beacons.
  void _drawPresidentialSovereignOcean(
    Canvas canvas,
    double w,
    double h,
    double gy, {
    required double ambientProg,
    required bool isNight,
  }) {
    final oceanTopY = gy + 75.0;

    // A. 🏖️ Island Coastal Sandy Beach & Granite Sea Wall Breakwater
    final beachPath = Path();
    beachPath.moveTo(0, gy + 138);
    beachPath.quadraticBezierTo(w * 0.16, gy + 18, w * 0.32, gy - 10);
    beachPath.lineTo(w * 0.68, gy - 10);
    beachPath.quadraticBezierTo(w * 0.84, gy + 18, w, gy + 138);
    beachPath.lineTo(w, gy + 175);
    beachPath.quadraticBezierTo(w * 0.84, gy + 65, w * 0.68, gy + 32);
    beachPath.lineTo(w * 0.32, gy + 32);
    beachPath.quadraticBezierTo(w * 0.16, gy + 65, 0, gy + 175);
    beachPath.close();

    final beachPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? const [
                Color(0xFF78592E),
                Color(0xFF523B18),
                Color(0xFF2E220D),
              ]
            : const [
                Color(0xFFFDE68A),
                Color(0xFFF59E0B),
                Color(0xFFD97706),
              ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, gy - 10, w, 190));
    canvas.drawPath(beachPath, beachPaint);

    // Granite Breakwater Boulders along island base
    final rockPaint = Paint()
      ..color = isNight ? const Color(0xFF1E293B) : const Color(0xFF64748B);
    for (int i = 0; i < 28; i++) {
      final rx = (i / 27) * w;
      double ryBase;
      if (rx < w * 0.32) {
        final t = rx / (w * 0.32);
        ryBase = ui.lerpDouble(gy + 155, gy + 18, t)!;
      } else if (rx > w * 0.68) {
        final t = (rx - w * 0.68) / (w * 0.32);
        ryBase = ui.lerpDouble(gy + 18, gy + 155, t)!;
      } else {
        ryBase = gy + 18;
      }
      final rockSize = 14.0 + (math.sin(i * 2.3) * 6).abs();
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(rx, ryBase + 12),
            width: rockSize * 1.5,
            height: rockSize * 0.85),
        rockPaint,
      );
    }

    // B. 🌊 Boundless Sovereign Ocean Gradient
    final oceanRect = Rect.fromLTWH(0, oceanTopY, w, h - oceanTopY);
    final oceanShader = LinearGradient(
      colors: isNight
          ? const [
              Color(0xFF092E4E), // Shoreline deep navy
              Color(0xFF07243F),
              Color(0xFF051B30),
              Color(0xFF031221),
              Color(0xFF010A14), // Abyssal deep base
            ]
          : const [
              Color(0xFF0284C7), // Shallows tropical azure
              Color(0xFF0369A1),
              Color(0xFF075985),
              Color(0xFF0C4A6E),
              Color(0xFF082F49), // Deep sea
            ],
      stops: const [0.0, 0.22, 0.48, 0.75, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(oceanRect);

    final oceanPath = Path();
    oceanPath.moveTo(0, oceanTopY + 45);
    oceanPath.quadraticBezierTo(w * 0.20, oceanTopY + 15, w * 0.50, oceanTopY);
    oceanPath.quadraticBezierTo(w * 0.80, oceanTopY + 15, w, oceanTopY + 45);
    oceanPath.lineTo(w, h);
    oceanPath.lineTo(0, h);
    oceanPath.close();
    canvas.drawPath(oceanPath, Paint()..shader = oceanShader);

    // C. 🌕 Shimmering Vertical Moonlight Reflection Track on Sea Surface (Night)
    if (isNight) {
      final moonCenterX = w * 0.48;
      for (int i = 0; i < 20; i++) {
        final my = oceanTopY + 40 + (i * ((h - oceanTopY - 60) / 20));
        final trackWidth = 50.0 + (i * 28.0);
        final shimmerOffset =
            math.sin(ambientProg * 2 * math.pi + i * 0.6) * 18.0;
        final shimmerAlpha =
            (0.18 + 0.25 * math.sin(ambientProg * 4 * math.pi + i * 0.8))
                .clamp(0.08, 0.50);

        final shimmerPaint = Paint()
          ..color = const Color(0xFFBAE6FD).withValues(alpha: shimmerAlpha)
          ..strokeWidth = 2.2 + (i * 0.12)
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(moonCenterX - (trackWidth / 2) + shimmerOffset, my),
          Offset(moonCenterX + (trackWidth / 2) + shimmerOffset, my),
          shimmerPaint,
        );
      }
    }

    // D. 🌊 Rolling Ocean Wave Swells with Bioluminescent Crests
    for (int i = 0; i < 16; i++) {
      final wy = oceanTopY + 30 + (i * ((h - oceanTopY - 40) / 16));
      final waveOffset = math.sin(ambientProg * 2 * math.pi + (i * 0.8)) * 32.0;
      final waveSpeed = (ambientProg * 2 * math.pi + (i * 0.4));
      final waveAlpha = isNight
          ? (0.20 + (0.35 * math.sin(waveSpeed + i).abs())).clamp(0.12, 0.60)
          : (0.30 + (0.30 * math.sin(waveSpeed + i).abs())).clamp(0.20, 0.65);

      final crestColor = isNight
          ? (i % 2 == 0 ? const Color(0xFF00F0FF) : const Color(0xFF2DD4BF))
          : const Color(0xFFE0F2FE);

      final wavePaint = Paint()
        ..color = crestColor.withValues(alpha: waveAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8 + (i * 0.15)
        ..strokeCap = StrokeCap.round;

      final p = Path();
      p.moveTo(0, wy);
      for (double x = 0; x <= w; x += 160) {
        final hAmp = 4.0 + (i * 0.35);
        p.quadraticBezierTo(
          math.min(w, x + 40 + waveOffset),
          wy - hAmp,
          math.min(w, x + 80),
          wy,
        );
        p.quadraticBezierTo(
          math.min(w, x + 120 - waveOffset),
          wy + hAmp,
          math.min(w, x + 160),
          wy,
        );
      }
      canvas.drawPath(p, wavePaint);
    }

    // E. 🐟 Darting Schools of Bioluminescent Ocean Fish
    _drawBioluminescentFishSchool(canvas, w, oceanTopY + (h * 0.05),
        ambientProg: ambientProg, isNight: isNight, count: 7, dir: 1.0);
    _drawBioluminescentFishSchool(canvas, w, oceanTopY + (h * 0.11),
        ambientProg: (ambientProg + 0.4) % 1.0,
        isNight: isNight,
        count: 9,
        dir: -1.0);
    _drawBioluminescentFishSchool(canvas, w, oceanTopY + (h * 0.17),
        ambientProg: (ambientProg + 0.7) % 1.0,
        isNight: isNight,
        count: 6,
        dir: 1.0);

    // F. 🏛️ Grand Ceremonial Presidential Naval Pier / Marble Promenade
    _drawCeremonialOceanPier(canvas, w * 0.50, gy + 16,
        ambientProg: ambientProg, isNight: isNight);

    // G. 🚨 Offshore Nautical Territorial Warning Buoys with Flashing Beacons
    _drawOceanNavigationalBuoy(canvas, w * 0.12, oceanTopY + (h * 0.04),
        ambientProg: ambientProg,
        isNight: isNight,
        beaconColor: const Color(0xFFEF4444));
    _drawOceanNavigationalBuoy(canvas, w * 0.88, oceanTopY + (h * 0.05),
        ambientProg: ambientProg,
        isNight: isNight,
        beaconColor: const Color(0xFF10B981));

    // H. 🏝️ Southern Vantage Island (Challenger's Island Shoreline looking across the Sovereign Bay)
    _drawSouthernVantageIsland(canvas, w, h,
        ambientProg: ambientProg, isNight: isNight);

    // I. 🛥️ Foreground Big Tactical Assault Boat (Stationed at Vantage Shoreline Pier)
    _drawForegroundBigBoat(canvas, w * 0.50, h * 0.655,
        ambientProg: ambientProg, isNight: isNight);

    // J. 🌴 Giant Tropical Coconut Palms (Framing the Panoramic View from Vantage Island)
    _drawGiantCoconutTree(canvas, 100.0, h * 0.90,
        height: h * 0.28,
        curveDirection: 1.0,
        ambientProg: ambientProg,
        isNight: isNight,
        twin: true);
    _drawGiantCoconutTree(canvas, w - 100.0, h * 0.91,
        height: h * 0.29,
        curveDirection: -1.0,
        ambientProg: ambientProg,
        isNight: isNight);
  }

  /// 🐟 Swimming Bioluminescent Fish in the Deep Sovereign Sea
  void _drawBioluminescentFishSchool(
    Canvas canvas,
    double w,
    double baseY, {
    required double ambientProg,
    required bool isNight,
    required int count,
    required double dir,
  }) {
    final schoolSpeed = ambientProg * w;
    final fishGlow = Paint()
      ..color = (isNight ? const Color(0xFF00F0FF) : const Color(0xFF38BDF8))
          .withValues(alpha: isNight ? 0.65 : 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final fishBody = Paint()
      ..color = isNight ? const Color(0xFFE0F2FE) : const Color(0xFF0284C7);

    for (int i = 0; i < count; i++) {
      final fx = (dir > 0)
          ? ((schoolSpeed + (i * 24)) % (w + 100)) - 50
          : w - (((schoolSpeed + (i * 24)) % (w + 100)) - 50);
      final fy = baseY +
          (math.sin((ambientProg * 4 * math.pi) + (i * 0.7)) * 14.0) +
          (i * 4);

      // Glow halo
      canvas.drawCircle(Offset(fx, fy), 5.0, fishGlow);

      // Tiny fish body
      final fPath = Path();
      fPath.moveTo(fx + (dir * 7), fy);
      fPath.quadraticBezierTo(fx, fy - 3, fx - (dir * 6), fy);
      fPath.quadraticBezierTo(fx, fy + 3, fx + (dir * 7), fy);
      fPath.close();
      canvas.drawPath(fPath, fishBody);

      // Tail fin
      final tail = Path();
      tail.moveTo(fx - (dir * 6), fy);
      tail.lineTo(fx - (dir * 11), fy - 4);
      tail.lineTo(fx - (dir * 11), fy + 4);
      tail.close();
      canvas.drawPath(tail, fishBody);
    }
  }

  /// 🏛️ Grand Ceremonial Presidential Pier Extending into the Sovereign Harbor
  void _drawCeremonialOceanPier(Canvas canvas, double x, double y,
      {required double ambientProg, required bool isNight}) {
    const pierW = 120.0;
    const pierH = 260.0;

    // Granite foundation pillars under water
    final pillarPaint = Paint()
      ..color = isNight ? const Color(0xFF0F172A) : const Color(0xFF475569);
    for (int i = 0; i < 4; i++) {
      final py = y + 40 + (i * 55);
      canvas.drawRect(
          Rect.fromLTWH(x - (pierW / 2) + 10, py, 14, 28), pillarPaint);
      canvas.drawRect(
          Rect.fromLTWH(x + (pierW / 2) - 24, py, 14, 28), pillarPaint);
    }

    // Marble Pier Deck
    final pierRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x - (pierW / 2), y, pierW, pierH),
      const Radius.circular(8),
    );
    final deckShader = LinearGradient(
      colors: isNight
          ? const [Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A)]
          : const [Color(0xFFF1F5F9), Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(pierRect.outerRect);
    canvas.drawRRect(pierRect, Paint()..shader = deckShader);

    // Presidential Red Carpet Runner down the pier
    final carpetRect = Rect.fromLTWH(x - 14, y, 28, pierH - 12);
    canvas.drawRect(carpetRect, Paint()..color = const Color(0xFFDC2626));
    canvas.drawRect(
      Rect.fromLTWH(x - 14, y, 28, pierH - 12),
      Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Golden Deck Railings & Warm Lantern Posts
    final railPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2.4;
    canvas.drawLine(Offset(x - (pierW / 2) + 4, y),
        Offset(x - (pierW / 2) + 4, y + pierH - 8), railPaint);
    canvas.drawLine(Offset(x + (pierW / 2) - 4, y),
        Offset(x + (pierW / 2) - 4, y + pierH - 8), railPaint);

    // Pierhead Flagpole with Presidential Standard
    final poleX = x;
    final poleY = y + pierH - 10;
    canvas.drawLine(
        Offset(poleX, poleY),
        Offset(poleX, poleY - 45),
        Paint()
          ..color = const Color(0xFFFFD700)
          ..strokeWidth = 3);
    final flagPath = Path();
    flagPath.moveTo(poleX, poleY - 45);
    flagPath.lineTo(poleX + 26, poleY - 37);
    flagPath.lineTo(poleX, poleY - 29);
    flagPath.close();
    canvas.drawPath(flagPath, Paint()..color = const Color(0xFF1E40AF));
    canvas.drawCircle(Offset(poleX + 10, poleY - 37), 3,
        Paint()..color = const Color(0xFFFFD700));

    // Warm pierhead lantern
    canvas.drawCircle(
      Offset(poleX, poleY - 46),
      14,
      Paint()
        ..color =
            const Color(0xFFFFB703).withValues(alpha: isNight ? 0.55 : 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
        Offset(poleX, poleY - 46), 4, Paint()..color = const Color(0xFFFFFC00));
  }

  /// 🚨 Offshore Navigational Buoy with Flashing Beacon
  void _drawOceanNavigationalBuoy(
    Canvas canvas,
    double x,
    double y, {
    required double ambientProg,
    required bool isNight,
    required Color beaconColor,
  }) {
    final bob = math.sin(ambientProg * 2 * math.pi + (x * 0.05)) * 3.5;
    final by = y + bob;

    // Buoy float body
    final buoyPath = Path();
    buoyPath.moveTo(x - 14, by);
    buoyPath.lineTo(x - 9, by - 22);
    buoyPath.lineTo(x + 9, by - 22);
    buoyPath.lineTo(x + 14, by);
    buoyPath.quadraticBezierTo(x, by + 10, x - 14, by);
    buoyPath.close();
    canvas.drawPath(buoyPath, Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawRect(
        Rect.fromLTWH(x - 11, by - 14, 22, 7), Paint()..color = beaconColor);

    // Cage mast
    canvas.drawLine(
        Offset(x - 5, by - 22),
        Offset(x - 2, by - 36),
        Paint()
          ..color = const Color(0xFF475569)
          ..strokeWidth = 2);
    canvas.drawLine(
        Offset(x + 5, by - 22),
        Offset(x + 2, by - 36),
        Paint()
          ..color = const Color(0xFF475569)
          ..strokeWidth = 2);
    canvas.drawLine(
        Offset(x, by - 22),
        Offset(x, by - 36),
        Paint()
          ..color = const Color(0xFF475569)
          ..strokeWidth = 2);

    // Flashing Strobe Light
    final flashProg = ((ambientProg * 3.0) + (x * 0.01)) % 1.0;
    final isStrobe = flashProg > 0.65;
    if (isStrobe || !isNight) {
      canvas.drawCircle(
        Offset(x, by - 38),
        16,
        Paint()
          ..color = beaconColor.withValues(alpha: 0.60)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      canvas.drawCircle(Offset(x, by - 38), 4.5, Paint()..color = Colors.white);
    }
  }

  // =========================================================================
  // 🏝️ SOUTHERN VANTAGE ISLAND & CHALLENGER'S FOREGROUND WORLD
  // =========================================================================

  /// 🏝️ Southern Vantage Island: The curved tropical island shoreline from which
  /// the challenger views the distant Sovereign Presidential Palace across the sea.
  void _drawSouthernVantageIsland(
    Canvas canvas,
    double w,
    double h, {
    required double ambientProg,
    required bool isNight,
  }) {
    final lagoonTop = h * 0.65;
    final beachTop = h * 0.685;
    final grassTop = h * 0.73;

    // 1. Shallow Aquamarine / Turquoise Coral Lagoon Wash
    final lagoonPath = Path();
    lagoonPath.moveTo(-60, h + 60);
    lagoonPath.lineTo(-60, lagoonTop + 20);
    lagoonPath.cubicTo(
      w * 0.25,
      lagoonTop - 15,
      w * 0.75,
      lagoonTop - 10,
      w + 60,
      lagoonTop + 15,
    );
    lagoonPath.lineTo(w + 60, h + 60);
    lagoonPath.close();

    final lagoonPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? const [
                Color(0x660891B2),
                Color(0x330E7490),
                Color(0x000F172A),
              ]
            : const [
                Color(0x9922D3EE),
                Color(0x6606B6D4),
                Color(0x000284C7),
              ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(-60, lagoonTop, w + 120, h - lagoonTop));
    canvas.drawPath(lagoonPath, lagoonPaint);

    // Dynamic foam surf lines breaking along the shoreline
    final surfPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int s = 0; s < 3; s++) {
      final surfOffset =
          math.sin((ambientProg * 2 * math.pi) + (s * 1.8)) * 14.0;
      final surfY = lagoonTop + 25.0 + (s * 15.0) + surfOffset;
      surfPaint
        ..color = (isNight ? const Color(0xFF67E8F9) : Colors.white)
            .withValues(alpha: (0.35 - (s * 0.08)).clamp(0.1, 0.5))
        ..strokeWidth = 3.5 - (s * 0.8);

      final sp = Path();
      sp.moveTo(-40, surfY);
      for (double x = -40; x <= w + 40; x += 140) {
        sp.quadraticBezierTo(
          x + 35 + (math.sin((ambientProg * 3 * math.pi) + (x * 0.01)) * 12),
          surfY - 6,
          x + 70,
          surfY,
        );
        sp.quadraticBezierTo(
          x + 105 - (math.sin((ambientProg * 3 * math.pi) + (x * 0.01)) * 12),
          surfY + 6,
          x + 140,
          surfY,
        );
      }
      canvas.drawPath(sp, surfPaint);
    }

    // 2. Golden Sand Shoreline / Sandy Beach (Deep crescent curve)
    final beachPath = Path();
    beachPath.moveTo(-40, h + 60);
    beachPath.lineTo(-40, beachTop + 20);
    beachPath.cubicTo(
      w * 0.28,
      beachTop - 15,
      w * 0.72,
      beachTop - 10,
      w + 40,
      beachTop + 15,
    );
    beachPath.lineTo(w + 40, h + 60);
    beachPath.close();

    final beachPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? const [
                Color(0xFF64748B),
                Color(0xFF475569),
                Color(0xFF334155),
              ]
            : const [
                Color(0xFFFDE68A), // Warm sunlight golden sand
                Color(0xFFF59E0B),
                Color(0xFFD97706), // Wet tide-line amber
              ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(-40, beachTop, w + 80, h - beachTop));
    canvas.drawPath(beachPath, beachPaint);

    // Subtle beach dunes and pebbles
    final pebblePaint = Paint()
      ..color = (isNight ? const Color(0xFF1E293B) : const Color(0xFFB45309))
          .withValues(alpha: 0.4);
    final pebbleRand = math.Random(108);
    for (int i = 0; i < 45; i++) {
      final px = pebbleRand.nextDouble() * w;
      final py = beachTop + 10.0 + pebbleRand.nextDouble() * (h * 0.08);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(px, py),
            width: 6.0 + pebbleRand.nextDouble() * 8,
            height: 3.0 + pebbleRand.nextDouble() * 4),
        pebblePaint,
      );
    }

    // 3. Lush Curved Island Terrain / Grassy Headland (Deep emerald tropical turf)
    final grassPath = Path();
    grassPath.moveTo(-40, h + 60);
    grassPath.lineTo(-40, grassTop + 20);
    grassPath.cubicTo(
      w * 0.22,
      grassTop - 15,
      w * 0.45,
      grassTop,
      w * 0.65,
      grassTop - 20,
    );
    grassPath.cubicTo(
      w * 0.85,
      grassTop - 25,
      w * 0.95,
      grassTop - 5,
      w + 40,
      grassTop + 10,
    );
    grassPath.lineTo(w + 40, h + 60);
    grassPath.close();

    final grassPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? const [
                Color(0xFF022C22),
                Color(0xFF064E3B),
                Color(0xFF065F46),
              ]
            : const [
                Color(0xFF064E3B),
                Color(0xFF047857),
                Color(0xFF10B981), // Sunlight emerald grass crest
              ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(
          Rect.fromLTWH(-40, grassTop - 25, w + 80, h - grassTop + 25));
    canvas.drawPath(grassPath, grassPaint);

    // Grass crest highlight ridge
    final ridgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = (isNight ? const Color(0xFF10B981) : const Color(0xFF34D399))
          .withValues(alpha: 0.55);
    canvas.drawPath(grassPath, ridgePaint);

    // 4. Southern Wooden Assault Pier / Dock (Extending into the bay toward the citadel)
    _drawVantageIslandPier(canvas, w * 0.50, grassTop + 5,
        pierLength: (h * 0.08).clamp(120.0, 200.0),
        isNight: isNight,
        ambientProg: ambientProg);

    // 5. Challenger's Tactical Reconnaissance Outpost (Telescope, Supply Crates, Lantern)
    _drawVantageReconPost(canvas, w * 0.41, grassTop + (h * 0.04),
        isNight: isNight, ambientProg: ambientProg);
  }

  /// 🪵 Wooden Assault Dock extending from the southern vantage beach into the water
  void _drawVantageIslandPier(
    Canvas canvas,
    double cx,
    double landY, {
    required double pierLength,
    required bool isNight,
    required double ambientProg,
  }) {
    final pierTopY = landY - pierLength;
    const pierW = 84.0;

    // Heavy wooden pylons submerged in water
    final pylonPaint = Paint()
      ..color = isNight ? const Color(0xFF1E293B) : const Color(0xFF451A03);
    final pylonHighlight = Paint()
      ..color = isNight ? const Color(0xFF334155) : const Color(0xFF78350F);

    for (double py = pierTopY + 20; py < landY; py += 55) {
      // Left pylon
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(cx - (pierW / 2) - 8, py, 14, 28),
            const Radius.circular(3)),
        pylonPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(cx - (pierW / 2) - 6, py, 4, 28),
            const Radius.circular(2)),
        pylonHighlight,
      );
      // Right pylon
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(cx + (pierW / 2) - 6, py, 14, 28),
            const Radius.circular(3)),
        pylonPaint,
      );
    }

    // Pier main wooden deck structure
    final deckRect = Rect.fromCenter(
      center: Offset(cx, pierTopY + (pierLength / 2)),
      width: pierW,
      height: pierLength,
    );
    final deckPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? const [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF1E293B)]
            : const [Color(0xFF78350F), Color(0xFFB45309), Color(0xFF78350F)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(deckRect);
    canvas.drawRRect(
        RRect.fromRectAndRadius(deckRect, const Radius.circular(6)), deckPaint);

    // Wooden plank floor lines
    final plankLine = Paint()
      ..color = (isNight ? const Color(0xFF0F172A) : const Color(0xFF451A03))
          .withValues(alpha: 0.8)
      ..strokeWidth = 2.0;
    for (double py = pierTopY + 8; py < landY; py += 16) {
      canvas.drawLine(Offset(cx - (pierW / 2) + 2, py),
          Offset(cx + (pierW / 2) - 2, py), plankLine);
    }

    // Pier bollards / mooring posts with coiled ropes
    final bollardPaint = Paint()
      ..color = isNight ? const Color(0xFF64748B) : const Color(0xFF92400E);
    canvas.drawCircle(
        Offset(cx - (pierW / 2) + 8, pierTopY + 12), 6, bollardPaint);
    canvas.drawCircle(
        Offset(cx + (pierW / 2) - 8, pierTopY + 12), 6, bollardPaint);

    // Warm dockhead navigational lantern at the tip of the pier
    final flicker = 0.85 + 0.15 * math.sin(ambientProg * 8 * math.pi);
    final lanternGlow = Paint()
      ..color = (isNight ? const Color(0xFFF59E0B) : const Color(0xFFFBBF24))
          .withValues(alpha: 0.55 * flicker)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(Offset(cx, pierTopY - 4), 22, lanternGlow);
    canvas.drawCircle(Offset(cx, pierTopY - 4), 5.5,
        Paint()..color = const Color(0xFFFEF08A));
  }

  /// 🔭 Reconnaissance Vantage Post (Long-range Brass Telescope on Tripod pointing at Citadel)
  void _drawVantageReconPost(
    Canvas canvas,
    double x,
    double y, {
    required bool isNight,
    required double ambientProg,
  }) {
    // Sturdy wooden expedition crates
    final cratePaint = Paint()
      ..color = isNight ? const Color(0xFF334155) : const Color(0xFF92400E);
    final crateBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isNight ? const Color(0xFF1E293B) : const Color(0xFF78350F);

    canvas.drawRect(Rect.fromLTWH(x - 30, y - 24, 28, 24), cratePaint);
    canvas.drawRect(Rect.fromLTWH(x - 30, y - 24, 28, 24), crateBorder);
    canvas.drawRect(Rect.fromLTWH(x - 6, y - 20, 22, 20), cratePaint);
    canvas.drawRect(Rect.fromLTWH(x - 6, y - 20, 22, 20), crateBorder);

    // High-powered tactical observation telescope on tripod pointing directly north
    final metalPaint = Paint()
      ..color = isNight ? const Color(0xFF94A3B8) : const Color(0xFFD97706);
    // Tripod legs
    final legPaint = Paint()
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..color = isNight ? const Color(0xFF475569) : const Color(0xFF78350F);
    canvas.drawLine(Offset(x + 36, y - 28), Offset(x + 24, y), legPaint);
    canvas.drawLine(Offset(x + 36, y - 28), Offset(x + 36, y + 2), legPaint);
    canvas.drawLine(Offset(x + 36, y - 28), Offset(x + 48, y), legPaint);

    // Optical barrel pointed upward toward the distant castle (-0.28 rad elevation)
    canvas.save();
    canvas.translate(x + 36, y - 28);
    canvas.rotate(-0.28);
    final barrelRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, -5, 34, 10), const Radius.circular(3));
    canvas.drawRRect(barrelRect, metalPaint);
    // Lens reflection
    canvas.drawCircle(
      const Offset(26, 0),
      4.0,
      Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.85),
    );
    canvas.restore();
  }

  // =========================================================================
  // 🛥️ FOREGROUND BIG TACTICAL ASSAULT BOAT ("Valiya Boat")
  // =========================================================================

  /// 🛥️ Draws a large, detailed, high-impact tactical assault cruiser anchored
  /// in the foreground waters right by the southern vantage pier.
  /// When zoomed out, this vessel stands grand and close to the camera, giving
  /// immediate depth and scale before the view transitions to the distant palace.
  void _drawForegroundBigBoat(
    Canvas canvas,
    double cx,
    double cy, {
    required double ambientProg,
    required bool isNight,
  }) {
    // Gentle nautical buoyancy bobbing and pitching
    final bobY = math.sin(ambientProg * 2 * math.pi) * 7.0;
    final pitchAngle = math.sin((ambientProg * 2 * math.pi) + 1.0) * 0.022;

    canvas.save();
    canvas.translate(cx, cy + bobY);
    canvas.rotate(pitchAngle);

    // 1. Churning Water Wake & Reflection around the massive hull
    final wakePaint = Paint()
      ..color = (isNight ? const Color(0xFF38BDF8) : Colors.white)
          .withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final wakePath = Path();
    wakePath.moveTo(-240, 48);
    wakePath.quadraticBezierTo(-120, 68, 0, 58);
    wakePath.quadraticBezierTo(120, 68, 240, 48);
    canvas.drawPath(wakePath, wakePaint);

    final foamGlow = Paint()
      ..color = (isNight ? const Color(0xFF00F0FF) : const Color(0xFFE0F2FE))
          .withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, 54), width: 440, height: 42),
        foamGlow);

    // 2. Heavy Armored Cruiser Hull (Width ~420, Height ~90)
    // Sharpened tactical bow facing north towards the Citadel
    final hullPath = Path();
    hullPath.moveTo(-200, 36); // Stern waterline
    hullPath.lineTo(-210, -8); // Stern transom
    hullPath.lineTo(-140, -18); // Stern deck
    hullPath.lineTo(130, -18); // Foredeck
    hullPath.cubicTo(
      180, -18,
      215, 0,
      225, 26, // Sharp tactical prow
    );
    hullPath.cubicTo(
      190, 48,
      120, 52,
      -180, 50, // Keel curve
    );
    hullPath.close();

    // Hull military paint gradient
    final hullPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? const [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF334155),
              ]
            : const [
                Color(0xFF1E293B), // Sleek tactical stealth slate
                Color(0xFF334155),
                Color(0xFF475569),
              ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(const Rect.fromLTWH(-210, -20, 440, 75));
    canvas.drawPath(hullPath, hullPaint);

    // Tactical Crimson Antifouling Waterline Stripe
    final waterlinePath = Path();
    waterlinePath.moveTo(-198, 36);
    waterlinePath.cubicTo(0, 42, 140, 42, 222, 28);
    waterlinePath.lineTo(218, 35);
    waterlinePath.cubicTo(140, 48, 0, 48, -196, 42);
    waterlinePath.close();
    canvas.drawPath(waterlinePath, Paint()..color = const Color(0xFFDC2626));

    // Hull armor plating seam lines
    final seamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = (isNight ? const Color(0xFF020617) : const Color(0xFF0F172A))
          .withValues(alpha: 0.65);
    canvas.drawLine(const Offset(-100, -18), const Offset(-100, 46), seamPaint);
    canvas.drawLine(const Offset(0, -18), const Offset(0, 48), seamPaint);
    canvas.drawLine(const Offset(100, -18), const Offset(100, 44), seamPaint);

    // Hull upper deck safety handrails
    final railPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isNight ? const Color(0xFF94A3B8) : const Color(0xFFE2E8F0);
    canvas.drawLine(const Offset(-140, -28), const Offset(130, -28), railPaint);
    for (double rx = -130; rx <= 120; rx += 35) {
      canvas.drawLine(Offset(rx, -18), Offset(rx, -28), railPaint);
    }

    // 3. Central Armored Command Wheelhouse / Pilot Bridge
    final bridgePath = Path();
    bridgePath.moveTo(-85, -18);
    bridgePath.lineTo(-78, -62);
    bridgePath.lineTo(45, -62);
    bridgePath.lineTo(68, -18);
    bridgePath.close();

    final bridgePaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? const [Color(0xFF1E293B), Color(0xFF475569)]
            : const [Color(0xFF334155), Color(0xFF64748B)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(const Rect.fromLTWH(-85, -62, 155, 45));
    canvas.drawPath(bridgePath, bridgePaint);

    // Panoramic cockpit observation glass (glowing cockpit lights)
    final windowPaint = Paint()
      ..color = isNight
          ? const Color(0xFF00F0FF).withValues(alpha: 0.85)
          : const Color(0xFF38BDF8).withValues(alpha: 0.75);
    final windowGlow = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (int wIdx = 0; wIdx < 4; wIdx++) {
      final wx = -62.0 + (wIdx * 28.0);
      final wRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(wx, -54, 20, 14),
        const Radius.circular(3),
      );
      if (isNight) canvas.drawRRect(wRect, windowGlow);
      canvas.drawRRect(wRect, windowPaint);
    }

    // 4. Roof Tactical Mast & Rotating Radar Dish
    final mastPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..color = isNight ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1);

    canvas.drawLine(const Offset(-15, -62), const Offset(-15, -95), mastPaint);
    canvas.drawLine(const Offset(-32, -82), const Offset(2, -82), mastPaint);

    // Rotating Radar Dish (oscillates dynamically with ambientProg)
    final radarAngle = math.cos(ambientProg * 4 * math.pi) * 0.85;
    canvas.save();
    canvas.translate(-15, -95);
    canvas.rotate(radarAngle);
    final radarDish = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..color = const Color(0xFFF59E0B);
    canvas.drawArc(const Rect.fromLTWH(-16, -10, 32, 20), -math.pi * 0.75,
        math.pi * 1.5, false, radarDish);
    canvas.drawCircle(Offset.zero, 3.5, Paint()..color = Colors.white);
    canvas.restore();

    // 5. Twin Tactical Heavy Cannons / Plasma Harpoon Turret on Forward Deck
    final turretBase = Paint()
      ..color = isNight ? const Color(0xFF0F172A) : const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(115, -28, 38, 14), const Radius.circular(4)),
      turretBase,
    );

    // Twin cannon barrels pointing proudly north-east toward the President's Citadel
    final cannonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..color = isNight ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    canvas.drawLine(
        const Offset(145, -24), const Offset(195, -42), cannonPaint);
    canvas.drawLine(
        const Offset(148, -19), const Offset(198, -37), cannonPaint);

    // Glowing targeting lens optics at cannon tips
    final opticGlow = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(const Offset(195, -42), 3.0, opticGlow);
    canvas.drawCircle(const Offset(198, -37), 3.0, opticGlow);

    // 6. Challenger Fleet Flag flying high at the stern
    final flagSway = math.sin((ambientProg * 3 * math.pi) + 0.5) * 8.0;
    final polePaint = Paint()
      ..strokeWidth = 2.5
      ..color = isNight ? const Color(0xFFCBD5E1) : const Color(0xFF64748B);
    canvas.drawLine(
        const Offset(-135, -28), const Offset(-135, -85), polePaint);

    final flagPath = Path();
    flagPath.moveTo(-135, -85);
    flagPath.quadraticBezierTo(-112 + flagSway, -80, -90, -78);
    flagPath.lineTo(-90, -58);
    flagPath.quadraticBezierTo(-112 + flagSway, -60, -135, -65);
    flagPath.close();

    final flagPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(const Rect.fromLTWH(-135, -85, 50, 30));
    canvas.drawPath(flagPath, flagPaint);

    // 7. Powerful Forward Searchlight Beam cutting through water toward the Citadel
    final beamPath = Path();
    beamPath.moveTo(180, -10);
    beamPath.lineTo(440, -140);
    beamPath.lineTo(480, -40);
    beamPath.close();

    final beamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          (isNight ? const Color(0xFF38BDF8) : Colors.white)
              .withValues(alpha: isNight ? 0.35 : 0.20),
          Colors.transparent,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(const Rect.fromLTWH(180, -140, 300, 140));
    canvas.drawPath(beamPath, beamPaint);

    canvas.restore();
  }

  // =========================================================================
  // 🌴 GIANT TROPICAL COCONUT PALMS ("Valiya Coconut Tree")
  // =========================================================================

  /// 🌴 Draws majestic towering coconut palms arching in from the vantage island.
  /// When zoomed out, these giant palms frame the panoramic ocean view, giving
  /// the authentic feeling of standing on a tropical island looking across at
  /// the distant Sovereign Presidential Palace.
  void _drawGiantCoconutTree(
    Canvas canvas,
    double baseX,
    double baseY, {
    required double height,
    required double curveDirection, // 1.0 = leaning right, -1.0 = leaning left
    required double ambientProg,
    required bool isNight,
    bool twin = false,
  }) {
    // If twin is true, draw a slightly smaller companion palm behind it
    if (twin) {
      _drawSingleCoconutTree(
        canvas,
        baseX - (curveDirection * 90.0),
        baseY + 30.0,
        height * 0.82,
        curveDirection * 1.25,
        ambientProg: ambientProg,
        isNight: isNight,
      );
    }

    _drawSingleCoconutTree(
      canvas,
      baseX,
      baseY,
      height,
      curveDirection,
      ambientProg: ambientProg,
      isNight: isNight,
    );
  }

  /// Single giant coconut tree with ringed segmented trunk, ripe coconuts, and swaying fronds
  void _drawSingleCoconutTree(
    Canvas canvas,
    double baseX,
    double baseY,
    double height,
    double curveDirection, {
    required double ambientProg,
    required bool isNight,
  }) {
    // Dynamic breeze sway for canopy apex
    final windSway =
        math.sin((ambientProg * 2 * math.pi) + (baseX * 0.005)) * 24.0;
    final topX = baseX + (curveDirection * (height * 0.42)) + windSway;
    final topY = baseY - height;
    final ctrlX = baseX + (curveDirection * (height * 0.22));
    final ctrlY = baseY - (height * 0.55);

    // 1. Root Flare & Ground Tufts at Base of Tree
    final rootPaint = Paint()
      ..color = isNight ? const Color(0xFF1E293B) : const Color(0xFF451A03);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(baseX, baseY), width: 72, height: 28),
      rootPaint,
    );

    // 2. Thick Curved Palm Trunk (Tapering from 34px at base to 18px at crown)
    const int segments = 24;
    for (int i = 0; i < segments; i++) {
      final t0 = i / segments;
      final t1 = (i + 1) / segments;

      // Quadratic bezier point calculation: B(t) = (1-t)^2 P0 + 2(1-t)t P1 + t^2 P2
      final p0x = math.pow(1 - t0, 2) * baseX +
          2 * (1 - t0) * t0 * ctrlX +
          math.pow(t0, 2) * topX;
      final p0y = math.pow(1 - t0, 2) * baseY +
          2 * (1 - t0) * t0 * ctrlY +
          math.pow(t0, 2) * topY;
      final p1x = math.pow(1 - t1, 2) * baseX +
          2 * (1 - t1) * t1 * ctrlX +
          math.pow(t1, 2) * topX;
      final p1y = math.pow(1 - t1, 2) * baseY +
          2 * (1 - t1) * t1 * ctrlY +
          math.pow(t1, 2) * topY;

      final w0 = 36.0 - (t0 * 18.0);
      final w1 = 36.0 - (t1 * 18.0);

      final segPath = Path();
      segPath.moveTo(p0x - (w0 / 2), p0y);
      segPath.lineTo(p1x - (w1 / 2), p1y);
      segPath.lineTo(p1x + (w1 / 2), p1y);
      segPath.lineTo(p0x + (w0 / 2), p0y);
      segPath.close();

      // Alternating wood tones creating natural ring ridges
      final isLightRing = (i % 2 == 0);
      final trunkPaint = Paint()
        ..shader = LinearGradient(
          colors: isNight
              ? (isLightRing
                  ? const [Color(0xFF334155), Color(0xFF1E293B)]
                  : const [Color(0xFF1E293B), Color(0xFF0F172A)])
              : (isLightRing
                  ? const [
                      Color(0xFFB45309),
                      Color(0xFF78350F),
                      Color(0xFF451A03)
                    ]
                  : const [
                      Color(0xFF92400E),
                      Color(0xFF5A2508),
                      Color(0xFF361502)
                    ]),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(p0x - w0, p0y - 10, w0 * 2, 20));

      canvas.drawPath(segPath, trunkPaint);

      // Distinct horizontal ring ridge line
      final ringRidge = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = (isNight ? const Color(0xFF020617) : const Color(0xFF260F02))
            .withValues(alpha: 0.7);
      canvas.drawLine(
          Offset(p1x - (w1 / 2), p1y), Offset(p1x + (w1 / 2), p1y), ringRidge);
    }

    // 3. Cluster of Ripe Coconuts hanging beneath the palm crown
    final nutColors = isNight
        ? const [Color(0xFF334155), Color(0xFF1E293B)]
        : const [
            Color(0xFFD97706),
            Color(0xFF92400E),
            Color(0xFF65A30D)
          ]; // Mix of golden & green nuts

    final nutRand = math.Random(42);
    for (int n = 0; n < 9; n++) {
      final angle = (n * (2 * math.pi / 9)) + 0.3;
      final dist = 10.0 + nutRand.nextDouble() * 14.0;
      final nutX = topX + math.cos(angle) * dist;
      final nutY = topY + 12.0 + math.sin(angle) * (dist * 0.7);

      final nutPaint = Paint()..color = nutColors[n % nutColors.length];
      canvas.drawOval(
        Rect.fromCenter(center: Offset(nutX, nutY), width: 18.0, height: 22.0),
        nutPaint,
      );
      // Nut specular highlight dot
      canvas.drawCircle(
        Offset(nutX - 3, nutY - 4),
        2.5,
        Paint()..color = Colors.white.withValues(alpha: isNight ? 0.3 : 0.5),
      );
    }

    // 4. Magnificent Radiating Palm Fronds (Feathered Pinnate Leaves)
    // 8 long sweeping fronds radiating outwards
    final frondAngles = [
      -math.pi * 0.88, // Far left drooping frond
      -math.pi * 0.72,
      -math.pi * 0.56, // Upright left
      -math.pi * 0.44, // Upright center-right
      -math.pi * 0.30,
      -math.pi * 0.12, // Far right drooping frond
      math.pi * 0.05, // Heavy lower right droop
      -math.pi * 0.98, // Heavy lower left droop
    ];

    for (int f = 0; f < frondAngles.length; f++) {
      final baseAngle = frondAngles[f];
      final frondLen = height * (0.42 + (0.08 * (f % 3)));
      final swayFrond =
          math.sin((ambientProg * 2 * math.pi) + (f * 0.8)) * 0.07;

      canvas.save();
      canvas.translate(topX, topY);
      _drawDetailedPalmFrond(
        canvas,
        frondLen,
        baseAngle + swayFrond,
        0.55 + (0.15 * (f % 2)),
        isNight: isNight,
        ambientProg: ambientProg,
        frondIndex: f,
      );
      canvas.restore();
    }
  }

  /// 🌿 High-fidelity feathered palm frond with individual leaflet pinnae
  void _drawDetailedPalmFrond(
    Canvas canvas,
    double length,
    double angle,
    double curvature, {
    required bool isNight,
    required double ambientProg,
    required int frondIndex,
  }) {
    canvas.save();
    canvas.rotate(angle);

    // Frond central stem / rachis path
    final stemPath = Path();
    stemPath.moveTo(0, 0);
    final midX = length * 0.52;
    final midY = length * curvature * 0.45;
    final endX = length;
    final endY = length * curvature;
    stemPath.quadraticBezierTo(midX, midY, endX, endY);

    // Frond leaflets (feathered pinnae on both sides of rachis)
    final leafletPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leafColors = isNight
        ? const [
            Color(0xFF047857),
            Color(0xFF065F46),
            Color(0xFF064E3B),
          ]
        : const [
            Color(0xFF10B981), // Emerald green
            Color(0xFF34D399), // Sunlight mint
            Color(0xFF84CC16), // Lime sunlight edge
            Color(0xFF047857), // Deep shadow green
          ];

    const int pinnaeCount = 28;
    for (int p = 3; p < pinnaeCount; p++) {
      final t = p / pinnaeCount;
      // Stem location at t
      final sx = 2 * (1 - t) * t * midX + math.pow(t, 2) * endX;
      final sy = 2 * (1 - t) * t * midY + math.pow(t, 2) * endY;

      final pinnaLen =
          (math.sin(t * math.pi) * (length * 0.24)).clamp(12.0, 75.0);
      final col = leafColors[(p + frondIndex) % leafColors.length];
      leafletPaint
        ..color = col
        ..strokeWidth = 2.4 - (t * 0.8);

      // Left leaflet
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx - (pinnaLen * 0.4), sy + pinnaLen),
        leafletPaint,
      );
      // Right leaflet
      canvas.drawLine(
        Offset(sx, sy),
        Offset(sx + (pinnaLen * 0.4), sy + pinnaLen),
        leafletPaint,
      );
    }

    // Main rachis stem
    final stemPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = isNight ? const Color(0xFF064E3B) : const Color(0xFF65A30D);
    canvas.drawPath(stemPath, stemPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CitadelScenicLandscapePainter oldDelegate) =>
      oldDelegate.isDamaged != isDamaged ||
      oldDelegate.groundBaseY != groundBaseY ||
      oldDelegate.isNight != isNight ||
      oldDelegate.isDay90 != isDay90 ||
      oldDelegate.ambientProg != ambientProg ||
      oldDelegate.isPresident != isPresident;
}

/// 🌌 🌊 Full-Bleed Infinite Ocean & Sky Backdrop behind InteractiveViewer.
/// Guarantees that no matter how far the user zooms out or pans around the island,
/// the screen is 100% covered in beautiful boundless ocean and sky—NEVER black bars!
class CitadelInfiniteOceanSkyBackdropPainter extends CustomPainter {
  final bool isNight;
  final double ambientProg;

  CitadelInfiniteOceanSkyBackdropPainter({
    required this.isNight,
    this.ambientProg = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final horizonY = h * 0.44;

    // 1. Sky Gradient (Upper 44% of infinite viewport)
    final skyPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? const [
                Color(0xFF020713), // Deep Cosmos
                Color(0xFF081226),
                Color(0xFF0F203C),
                Color(0xFF193252), // Atmospheric horizon glow
              ]
            : const [
                Color(0xFF0284C7),
                Color(0xFF38BDF8),
                Color(0xFF7DD3FC),
                Color(0xFFBAE6FD),
              ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, horizonY + 2));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, horizonY + 2), skyPaint);

    // Cosmic Stars in the backdrop
    if (isNight) {
      final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.65);
      final r = math.Random(42);
      for (int i = 0; i < 70; i++) {
        final sx = r.nextDouble() * w;
        final sy = r.nextDouble() * (horizonY - 20);
        final rad = 0.7 + r.nextDouble() * 1.5;
        final twinkle = 0.5 + 0.5 * math.sin(ambientProg * 2 * math.pi + i);
        canvas.drawCircle(
            Offset(sx, sy),
            rad,
            starPaint
              ..color = Colors.white.withValues(alpha: 0.3 + 0.6 * twinkle));
      }
    }

    // 2. Boundless Ocean (Lower 56% of infinite viewport)
    final oceanPaint = Paint()
      ..shader = LinearGradient(
        colors: isNight
            ? const [
                Color(0xFF0A2540), // Horizon ocean edge
                Color(0xFF071C33),
                Color(0xFF041224),
                Color(0xFF020A14), // Abyssal deep base
              ]
            : const [
                Color(0xFF0284C7),
                Color(0xFF0369A1),
                Color(0xFF075985),
                Color(0xFF0C4A6E),
              ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawRect(Rect.fromLTWH(0, horizonY, w, h - horizonY), oceanPaint);

    // Ocean horizon glow & distant rolling waves
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 14; i++) {
      final wy = horizonY + 15 + (i * ((h - horizonY) / 14));
      final waveOffset = math.sin(ambientProg * 2 * math.pi + (i * 0.7)) * 25.0;
      final alpha = (0.12 + (0.18 * (i / 14))).clamp(0.08, 0.35);
      wavePaint
        ..color = (isNight ? const Color(0xFF38BDF8) : Colors.white)
            .withValues(alpha: alpha)
        ..strokeWidth = 1.0 + (i * 0.18);

      final p = Path();
      p.moveTo(-40, wy);
      for (double x = -40; x <= w + 40; x += 120) {
        p.quadraticBezierTo(
          x + 30 + waveOffset,
          wy - 3 - (i * 0.3),
          x + 60,
          wy,
        );
        p.quadraticBezierTo(
          x + 90 - waveOffset,
          wy + 3 + (i * 0.3),
          x + 120,
          wy,
        );
      }
      canvas.drawPath(p, wavePaint);
    }
  }

  @override
  bool shouldRepaint(
          covariant CitadelInfiniteOceanSkyBackdropPainter oldDelegate) =>
      oldDelegate.isNight != isNight || oldDelegate.ambientProg != ambientProg;
}
