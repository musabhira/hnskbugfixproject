import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'vector_avatar_config.dart';

/// Multi-Style & Profession Avatar Painter
/// Visually transforms on every single config change (Face Shape, Hair, Beard, Eyes, Mouth, Outfit, Props, Aura, Art Style).
class VectorAvatarPainter extends CustomPainter {
  final VectorAvatarConfig config;
  final bool showBackgroundAura;
  final double animationValue;

  VectorAvatarPainter({
    required this.config,
    this.showBackgroundAura = true,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Background Aura & Thematic Backdrop
    if (showBackgroundAura) {
      _paintAura(canvas, size, center, radius);
    }

    // Clip avatar inside circular profile boundary
    canvas.save();
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius - 2));
    canvas.clipPath(clipPath);

    switch (config.artStyle) {
      case 'doodle':
        _paintDoodleAvatar(canvas, size);
        break;
      case 'pixel':
        _paintPixelAvatar(canvas, size);
        break;
      case 'cyberpunk':
        _paintCyberpunkAvatar(canvas, size);
        break;
      default:
        _paintVectorAvatar(canvas, size);
        break;
    }

    canvas.restore();

    // Outer Border
    final borderPaint = Paint()
      ..color = VectorAvatarConfig.parseHex(config.outfitColor, fallback: const Color(0xFFFFFC00)).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03;
    canvas.drawCircle(center, radius - size.width * 0.015, borderPaint);
  }

  // ==========================================
  // 🌟 AURA & BACKGROUNDS
  // ==========================================
  void _paintAura(Canvas canvas, Size size, Offset center, double radius) {
    final auraColors = VectorAvatarPalette.auraStyles.firstWhere(
      (a) => a['id'] == config.auraStyle,
      orElse: () => VectorAvatarPalette.auraStyles.first,
    )['colors'] as List<Color>;

    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          auraColors[0],
          auraColors[1],
          auraColors[1].withValues(alpha: 0.85),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, auraPaint);

    if (config.auraStyle == 'matrix_green' || config.artStyle == 'cyberpunk') {
      final matrixPaint = Paint()
        ..color = const Color(0xFF00FF66).withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      for (double x = size.width * 0.15; x < size.width * 0.9; x += 16) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), matrixPaint);
      }
    } else if (config.auraStyle == 'comic_boom' || config.artStyle == 'doodle') {
      final rayPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      for (int i = 0; i < 12; i++) {
        final angle = (i * 30) * math.pi / 180;
        final x2 = center.dx + radius * math.cos(angle);
        final y2 = center.dy + radius * math.sin(angle);
        canvas.drawLine(center, Offset(x2, y2), rayPaint);
      }
    } else if (config.auraStyle == 'cherry_blossom') {
      final petalPaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
      for (int i = 0; i < 6; i++) {
        canvas.drawCircle(Offset(size.width * (0.2 + i * 0.12), size.height * (0.15 + (i % 3) * 0.1)), size.width * 0.02, petalPaint);
      }
    } else if (config.auraStyle == 'golden_sparks') {
      final sparkPaint = Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.4);
      for (int i = 0; i < 7; i++) {
        canvas.drawCircle(Offset(size.width * (0.18 + (i * 0.11)), size.height * (0.2 + (i % 2) * 0.15)), size.width * 0.025, sparkPaint);
      }
    } else if (config.artStyle == 'pixel') {
      final gridPaint = Paint()..color = Colors.white.withValues(alpha: 0.09);
      const int gridSize = 14;
      final double cell = size.width / gridSize;
      for (int x = 0; x < gridSize; x++) {
        for (int y = 0; y < gridSize; y++) {
          if ((x + y) % 2 == 0) {
            canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell * 0.9, cell * 0.9), gridPaint);
          }
        }
      }
    }
  }

  // ==========================================
  // ✨ 1. MODERN 2D VECTOR
  // ==========================================
  void _paintVectorAvatar(Canvas canvas, Size size) {
    final skin = VectorAvatarConfig.parseHex(config.skinColor);
    final outfit = VectorAvatarConfig.parseHex(config.outfitColor);
    final accent = VectorAvatarConfig.parseHex(config.outfitAccentColor);

    // 1. Back Hair (For long hair / dreadlocks / ponytail)
    _paintBackHair(canvas, size, null);

    // 2. Shoulders & Outfit Base
    _paintShouldersAndOutfit(canvas, size, outfit, accent, null);

    // 3. Neck
    final neckPaint = Paint()..color = _darken(skin, 0.12);
    final neckRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.65),
      width: size.width * 0.26,
      height: size.height * 0.25,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(neckRect, Radius.circular(size.width * 0.05)), neckPaint);

    // 4. Head & Face Shape (Oval, Round, Sharp, Square)
    _paintHeadAndFaceShape(canvas, size, skin, null);

    // 5. Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.27, size.height * 0.47), width: size.width * 0.11, height: size.height * 0.16), Paint()..color = skin);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.73, size.height * 0.47), width: size.width * 0.11, height: size.height * 0.16), Paint()..color = skin);

    // Cheek Blush
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.51), size.width * 0.045, Paint()..color = const Color(0xFFFF4081).withValues(alpha: 0.15));
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.51), size.width * 0.045, Paint()..color = const Color(0xFFFF4081).withValues(alpha: 0.15));

    // 6. Facial Features (Eyes, Eyebrows, Mouth, Beard)
    _paintEyes(canvas, size, null);
    _paintBeard(canvas, size, null);

    // 7. Front Hair (14 styles)
    _paintFrontHair(canvas, size, null);

    // 8. 1-of-1 Species Unique Features (Ears, Horns, Wings, Antennas)
    _paintSpeciesFeatures(canvas, size, null);

    // 9. Accessories & Hats/Crown
    _paintAccessories(canvas, size, null);
  }

  // ==========================================
  // 🎨 2. COMIC DOODLE / CARICATURE
  // ==========================================
  void _paintDoodleAvatar(Canvas canvas, Size size) {
    final skin = VectorAvatarConfig.parseHex(config.skinColor);
    final outfit = VectorAvatarConfig.parseHex(config.outfitColor);
    final accent = VectorAvatarConfig.parseHex(config.outfitAccentColor);

    final inkLine = Paint()
      ..color = const Color(0xFF1E1E24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.024
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. Back Hair
    _paintBackHair(canvas, size, inkLine);

    // 2. Shoulders & Outfit Base
    _paintShouldersAndOutfit(canvas, size, outfit, accent, inkLine);

    // 3. Neck
    final neckRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.65),
      width: size.width * 0.24,
      height: size.height * 0.20,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(neckRect, Radius.circular(size.width * 0.04)), Paint()..color = skin);
    canvas.drawRRect(RRect.fromRectAndRadius(neckRect, Radius.circular(size.width * 0.04)), inkLine);

    // 4. Head & Face Shape
    _paintHeadAndFaceShape(canvas, size, skin, inkLine);

    // Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.26, size.height * 0.47), width: size.width * 0.10, height: size.height * 0.16), Paint()..color = skin);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.26, size.height * 0.47), width: size.width * 0.10, height: size.height * 0.16), inkLine);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.74, size.height * 0.47), width: size.width * 0.10, height: size.height * 0.16), Paint()..color = skin);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.74, size.height * 0.47), width: size.width * 0.10, height: size.height * 0.16), inkLine);

    // 5. Facial Features
    _paintEyes(canvas, size, inkLine);
    _paintBeard(canvas, size, inkLine);

    // 6. Front Hair
    _paintFrontHair(canvas, size, inkLine);

    // 7. Accessories
    _paintAccessories(canvas, size, inkLine);
  }

  // ==========================================
  // ⚡ 3. CYBERPUNK NEON
  // ==========================================
  void _paintCyberpunkAvatar(Canvas canvas, Size size) {
    _paintVectorAvatar(canvas, size);

    // Glowing Neon Cyber Matrix Ring
    final neonGlowPaint = Paint()
      ..color = const Color(0xFF00FF66).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.022;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.48), size.width * 0.33, neonGlowPaint);
  }

  // ==========================================
  // 👾 4. 8-BIT RETRO PIXEL ART
  // ==========================================
  void _paintPixelAvatar(Canvas canvas, Size size) {
    const int grid = 22;
    final double s = size.width / grid;

    final skin = VectorAvatarConfig.parseHex(config.skinColor);
    final hair = VectorAvatarConfig.parseHex(config.hairColor);
    final eye = VectorAvatarConfig.parseHex(config.eyeColor);
    final outfit = VectorAvatarConfig.parseHex(config.outfitColor);
    final accent = VectorAvatarConfig.parseHex(config.outfitAccentColor);

    void p(int x, int y, Color c, [int w = 1, int h = 1]) {
      canvas.drawRect(Rect.fromLTWH(x * s, y * s, w * s, h * s), Paint()..color = c);
    }

    const int yOff = 3;

    // Shoulders
    p(3, yOff + 13, outfit, 16, 8);
    p(7, yOff + 10, _darken(skin, 0.12), 8, 3); // Neck

    // Outfits in Pixel Art
    if (config.outfitStyle == 'doctor_coat') {
      p(9, yOff + 13, accent, 4, 7);
      p(6, yOff + 13, Colors.white, 3, 7);
      p(13, yOff + 13, Colors.white, 3, 7);
      p(8, yOff + 14, const Color(0xFF37474F), 1, 4);
      p(13, yOff + 14, const Color(0xFF37474F), 1, 4);
      p(10, yOff + 17, const Color(0xFFCFD8DC), 2, 2);
    } else if (config.outfitStyle == 'spider_suit') {
      p(3, yOff + 13, const Color(0xFFE53935), 16, 8);
      p(10, yOff + 14, const Color(0xFF111111), 2, 3);
      p(7, yOff + 16, const Color(0xFF1E88E5), 2, 5);
      p(13, yOff + 16, const Color(0xFF1E88E5), 2, 5);
    } else if (config.outfitStyle == 'superman_suit') {
      p(3, yOff + 13, const Color(0xFF1E88E5), 16, 8);
      p(9, yOff + 14, const Color(0xFFFFD700), 4, 3);
      p(10, yOff + 15, const Color(0xFFE53935), 2, 2);
    } else if (config.outfitStyle == 'joker_suit') {
      p(9, yOff + 13, const Color(0xFF27AE60), 4, 3);
      p(10, yOff + 15, const Color(0xFFFF9900), 2, 5);
    } else if (config.outfitStyle == 'pilot_uniform') {
      p(4, yOff + 13, const Color(0xFFFFD700), 3, 1);
      p(15, yOff + 13, const Color(0xFFFFD700), 3, 1);
    } else if (config.outfitStyle == 'traditional_kurta') {
      p(10, yOff + 13, accent, 2, 8);
      p(10, yOff + 14, const Color(0xFFFFD700), 2, 1);
      p(10, yOff + 17, const Color(0xFFFFD700), 2, 1);
    }

    // Head (Reacts to Face Shape)
    if (config.faceShape == 'round') {
      p(6, yOff + 3, skin, 10, 8);
      p(7, yOff + 2, skin, 8, 10);
    } else if (config.faceShape == 'sharp') {
      p(7, yOff + 2, skin, 8, 7);
      p(8, yOff + 9, skin, 6, 2);
      p(9, yOff + 11, skin, 4, 1);
    } else if (config.faceShape == 'square') {
      p(6, yOff + 2, skin, 10, 9);
      p(6, yOff + 9, skin, 10, 2);
    } else {
      p(7, yOff + 2, skin, 8, 9);
    }

    p(6, yOff + 5, skin, 1, 4); // Left Ear
    p(15, yOff + 5, skin, 1, 4); // Right Ear

    // Hair in Pixel Art (Reacts to all styles)
    switch (config.hairStyle) {
      case 'anime_spiky':
        p(5, yOff - 1, hair, 3, 3);
        p(8, yOff - 2, hair, 6, 4);
        p(14, yOff - 1, hair, 3, 3);
        p(6, yOff + 2, hair, 10, 2);
        break;
      case 'afro':
        p(4, yOff - 2, hair, 14, 6);
        p(3, yOff + 1, hair, 16, 5);
        break;
      case 'mohawk':
        p(9, yOff - 3, hair, 4, 6);
        p(8, yOff + 1, hair, 6, 2);
        break;
      case 'dreadlocks':
        p(5, yOff + 0, hair, 12, 3);
        p(4, yOff + 3, hair, 2, 8);
        p(16, yOff + 3, hair, 2, 8);
        break;
      case 'high_bun':
        p(9, yOff - 3, hair, 4, 3);
        p(6, yOff + 0, hair, 10, 3);
        break;
      case 'bald_beanie':
        p(6, yOff + 0, accent, 10, 3);
        p(5, yOff + 3, outfit, 12, 1);
        break;
      default:
        p(6, yOff + 0, hair, 10, 3);
        p(5, yOff + 2, hair, 3, 3);
        p(14, yOff + 2, hair, 3, 3);
    }

    // Eyes
    if (config.eyeStyle == 'wink') {
      p(8, yOff + 5, Colors.white, 2, 2);
      p(9, yOff + 5, eye, 1, 2);
      p(12, yOff + 6, const Color(0xFF1E1E24), 2, 1);
    } else {
      p(8, yOff + 5, Colors.white, 2, 2);
      p(9, yOff + 5, eye, 1, 2);
      p(8, yOff + 5, Colors.white, 1, 1);

      p(12, yOff + 5, Colors.white, 2, 2);
      p(13, yOff + 5, eye, 1, 2);
      p(12, yOff + 5, Colors.white, 1, 1);
    }

    // Mouth
    if (config.mouthStyle == 'joker_grin') {
      p(8, yOff + 8, const Color(0xFFE53935), 6, 2);
      p(9, yOff + 8, Colors.white, 4, 1);
    } else if (config.mouthStyle == 'laugh') {
      p(9, yOff + 8, const Color(0xFF9E2A2B), 4, 2);
      p(9, yOff + 8, Colors.white, 4, 1);
    } else {
      p(10, yOff + 8, const Color(0xFF9E2A2B), 2, 1);
    }

    // Beard in Pixel Art
    if (config.beardStyle == 'full_beard') {
      p(7, yOff + 8, hair, 2, 3);
      p(13, yOff + 8, hair, 2, 3);
      p(8, yOff + 10, hair, 6, 2);
    } else if (config.beardStyle == 'stubble') {
      p(8, yOff + 9, _darken(hair, 0.4), 6, 1);
    } else if (config.beardStyle == 'mustache') {
      p(9, yOff + 7, hair, 4, 1);
    }

    // Accessories in Pixel
    if (config.accessory == 'crown') {
      p(7, yOff - 2, const Color(0xFFFFD700), 8, 2);
      p(7, yOff - 3, const Color(0xFFFFD700), 2, 1);
      p(10, yOff - 3, const Color(0xFFFFD700), 2, 1);
      p(13, yOff - 3, const Color(0xFFFFD700), 2, 1);
    } else if (config.accessory == 'cyber_visor') {
      p(6, yOff + 4, const Color(0xFF00FF66), 10, 3);
    } else if (config.accessory == 'cool_sunglasses') {
      p(7, yOff + 5, const Color(0xFF111111), 8, 2);
    } else if (config.accessory == 'ninja_mask') {
      p(7, yOff + 7, const Color(0xFF111111), 8, 4);
    }
  }

  // ==========================================
  // 📐 5. DYNAMIC FACE SHAPES (Oval, Round, Sharp, Square)
  // ==========================================
  void _paintHeadAndFaceShape(Canvas canvas, Size size, Color skin, Paint? inkLine) {
    final facePath = Path();

    switch (config.faceShape) {
      case 'round':
        facePath.moveTo(size.width * 0.26, size.height * 0.36);
        facePath.quadraticBezierTo(size.width * 0.5, size.height * 0.17, size.width * 0.74, size.height * 0.36);
        facePath.quadraticBezierTo(size.width * 0.78, size.height * 0.56, size.width * 0.67, size.height * 0.67);
        facePath.quadraticBezierTo(size.width * 0.5, size.height * 0.73, size.width * 0.33, size.height * 0.67);
        facePath.quadraticBezierTo(size.width * 0.22, size.height * 0.56, size.width * 0.26, size.height * 0.36);
        break;
      case 'sharp': // Anime V-Line
        facePath.moveTo(size.width * 0.29, size.height * 0.34);
        facePath.quadraticBezierTo(size.width * 0.5, size.height * 0.18, size.width * 0.71, size.height * 0.34);
        facePath.lineTo(size.width * 0.70, size.height * 0.53);
        facePath.lineTo(size.width * 0.50, size.height * 0.72); // Sharp pointed chin
        facePath.lineTo(size.width * 0.30, size.height * 0.53);
        break;
      case 'square': // Chiseled Jawline
        facePath.moveTo(size.width * 0.27, size.height * 0.35);
        facePath.quadraticBezierTo(size.width * 0.5, size.height * 0.18, size.width * 0.73, size.height * 0.35);
        facePath.lineTo(size.width * 0.73, size.height * 0.58);
        facePath.lineTo(size.width * 0.65, size.height * 0.68);
        facePath.lineTo(size.width * 0.35, size.height * 0.68);
        facePath.lineTo(size.width * 0.27, size.height * 0.58);
        break;
      default: // Classic Oval
        facePath.moveTo(size.width * 0.29, size.height * 0.35);
        facePath.quadraticBezierTo(size.width * 0.5, size.height * 0.19, size.width * 0.71, size.height * 0.35);
        facePath.quadraticBezierTo(size.width * 0.72, size.height * 0.55, size.width * 0.65, size.height * 0.65);
        facePath.quadraticBezierTo(size.width * 0.5, size.height * 0.70, size.width * 0.35, size.height * 0.65);
        facePath.quadraticBezierTo(size.width * 0.28, size.height * 0.55, size.width * 0.29, size.height * 0.35);
    }
    facePath.close();

    canvas.drawPath(facePath, Paint()..color = skin);
    if (inkLine != null) canvas.drawPath(facePath, inkLine);
  }

  // ==========================================
  // 💇 6. DYNAMIC HAIRSTYLES (14 Styles)
  // ==========================================
  void _paintBackHair(Canvas canvas, Size size, Paint? inkLine) {
    final hairColor = VectorAvatarConfig.parseHex(config.hairColor);
    final hairPaint = Paint()..color = hairColor;

    if (config.hairStyle == 'long_wavy' || config.hairStyle == 'dreadlocks' || config.hairStyle == 'mullet') {
      final backHair = Path();
      backHair.moveTo(size.width * 0.20, size.height * 0.35);
      backHair.lineTo(size.width * 0.18, size.height * 0.75);
      backHair.quadraticBezierTo(size.width * 0.25, size.height * 0.85, size.width * 0.35, size.height * 0.75);
      backHair.lineTo(size.width * 0.65, size.height * 0.75);
      backHair.quadraticBezierTo(size.width * 0.75, size.height * 0.85, size.width * 0.82, size.height * 0.75);
      backHair.lineTo(size.width * 0.80, size.height * 0.35);
      backHair.close();
      canvas.drawPath(backHair, hairPaint);
      if (inkLine != null) canvas.drawPath(backHair, inkLine);
    } else if (config.hairStyle == 'ponytail') {
      final pony = Path();
      pony.moveTo(size.width * 0.70, size.height * 0.28);
      pony.quadraticBezierTo(size.width * 0.95, size.height * 0.25, size.width * 0.88, size.height * 0.65);
      pony.quadraticBezierTo(size.width * 0.80, size.height * 0.55, size.width * 0.72, size.height * 0.38);
      pony.close();
      canvas.drawPath(pony, hairPaint);
      if (inkLine != null) canvas.drawPath(pony, inkLine);
    }
  }

  void _paintFrontHair(Canvas canvas, Size size, Paint? inkLine) {
    final hairColor = VectorAvatarConfig.parseHex(config.hairColor);
    final hairPaint = Paint()..color = hairColor;
    final path = Path();

    switch (config.hairStyle) {
      case 'anime_spiky':
        path.moveTo(size.width * 0.20, size.height * 0.44);
        path.lineTo(size.width * 0.12, size.height * 0.28);
        path.lineTo(size.width * 0.28, size.height * 0.24);
        path.lineTo(size.width * 0.25, size.height * 0.10);
        path.lineTo(size.width * 0.45, size.height * 0.16);
        path.lineTo(size.width * 0.50, size.height * 0.06);
        path.lineTo(size.width * 0.62, size.height * 0.16);
        path.lineTo(size.width * 0.75, size.height * 0.10);
        path.lineTo(size.width * 0.76, size.height * 0.26);
        path.lineTo(size.width * 0.88, size.height * 0.32);
        path.lineTo(size.width * 0.80, size.height * 0.44);
        path.quadraticBezierTo(size.width * 0.65, size.height * 0.28, size.width * 0.48, size.height * 0.33);
        path.quadraticBezierTo(size.width * 0.32, size.height * 0.28, size.width * 0.20, size.height * 0.44);
        break;
      case 'curly_fade':
        path.moveTo(size.width * 0.26, size.height * 0.42);
        path.quadraticBezierTo(size.width * 0.22, size.height * 0.20, size.width * 0.50, size.height * 0.18);
        path.quadraticBezierTo(size.width * 0.78, size.height * 0.20, size.width * 0.74, size.height * 0.42);
        path.quadraticBezierTo(size.width * 0.65, size.height * 0.32, size.width * 0.35, size.height * 0.32);
        break;
      case 'afro':
        canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.34), size.width * 0.32, hairPaint);
        if (inkLine != null) canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.34), size.width * 0.32, inkLine);
        return;
      case 'bob_cut':
        path.moveTo(size.width * 0.22, size.height * 0.58);
        path.lineTo(size.width * 0.22, size.height * 0.30);
        path.quadraticBezierTo(size.width * 0.50, size.height * 0.16, size.width * 0.78, size.height * 0.30);
        path.lineTo(size.width * 0.78, size.height * 0.58);
        path.lineTo(size.width * 0.70, size.height * 0.42);
        path.quadraticBezierTo(size.width * 0.50, size.height * 0.35, size.width * 0.30, size.height * 0.42);
        break;
      case 'mohawk':
        path.moveTo(size.width * 0.42, size.height * 0.32);
        path.lineTo(size.width * 0.44, size.height * 0.08);
        path.lineTo(size.width * 0.50, size.height * 0.04);
        path.lineTo(size.width * 0.56, size.height * 0.08);
        path.lineTo(size.width * 0.58, size.height * 0.32);
        break;
      case 'high_bun':
        canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.12), size.width * 0.12, hairPaint);
        if (inkLine != null) canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.12), size.width * 0.12, inkLine);
        path.moveTo(size.width * 0.25, size.height * 0.42);
        path.quadraticBezierTo(size.width * 0.22, size.height * 0.20, size.width * 0.50, size.height * 0.20);
        path.quadraticBezierTo(size.width * 0.75, size.height * 0.20, size.width * 0.75, size.height * 0.42);
        path.quadraticBezierTo(size.width * 0.60, size.height * 0.32, size.width * 0.30, size.height * 0.34);
        break;
      case 'slicked_back':
        path.moveTo(size.width * 0.25, size.height * 0.40);
        path.quadraticBezierTo(size.width * 0.22, size.height * 0.14, size.width * 0.50, size.height * 0.12);
        path.quadraticBezierTo(size.width * 0.78, size.height * 0.14, size.width * 0.75, size.height * 0.40);
        path.quadraticBezierTo(size.width * 0.50, size.height * 0.28, size.width * 0.25, size.height * 0.40);
        break;
      case 'bald_beanie':
        final beaniePaint = Paint()..color = VectorAvatarConfig.parseHex(config.outfitAccentColor);
        final beaniePath = Path();
        beaniePath.moveTo(size.width * 0.22, size.height * 0.38);
        beaniePath.quadraticBezierTo(size.width * 0.50, size.height * 0.12, size.width * 0.78, size.height * 0.38);
        beaniePath.close();
        canvas.drawPath(beaniePath, beaniePaint);
        if (inkLine != null) canvas.drawPath(beaniePath, inkLine);
        return;
      default: // Classic Side
        path.moveTo(size.width * 0.24, size.height * 0.42);
        path.quadraticBezierTo(size.width * 0.22, size.height * 0.20, size.width * 0.50, size.height * 0.18);
        path.quadraticBezierTo(size.width * 0.78, size.height * 0.20, size.width * 0.76, size.height * 0.42);
        path.quadraticBezierTo(size.width * 0.60, size.height * 0.30, size.width * 0.28, size.height * 0.34);
    }

    path.close();
    canvas.drawPath(path, hairPaint);
    if (inkLine != null) canvas.drawPath(path, inkLine);
  }

  // ==========================================
  // 👁️ 7. DYNAMIC EYES & EXPRESSIONS
  // ==========================================
  void _paintEyes(Canvas canvas, Size size, Paint? inkLine) {
    final eyeColor = VectorAvatarConfig.parseHex(config.eyeColor);
    final hairColor = VectorAvatarConfig.parseHex(config.hairColor);

    // Eyebrows (Reacts to style)
    final browPaint = Paint()
      ..color = hairColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.024;

    if (config.eyebrowStyle == 'angry_hero') {
      canvas.drawLine(Offset(size.width * 0.34, size.height * 0.38), Offset(size.width * 0.46, size.height * 0.41), browPaint);
      canvas.drawLine(Offset(size.width * 0.54, size.height * 0.41), Offset(size.width * 0.66, size.height * 0.38), browPaint);
    } else if (config.eyebrowStyle == 'arched') {
      canvas.drawLine(Offset(size.width * 0.35, size.height * 0.41), Offset(size.width * 0.46, size.height * 0.37), browPaint);
      canvas.drawLine(Offset(size.width * 0.54, size.height * 0.37), Offset(size.width * 0.65, size.height * 0.41), browPaint);
    } else {
      canvas.drawLine(Offset(size.width * 0.35, size.height * 0.39), Offset(size.width * 0.46, size.height * 0.38), browPaint);
      canvas.drawLine(Offset(size.width * 0.54, size.height * 0.38), Offset(size.width * 0.65, size.height * 0.39), browPaint);
    }

    // Eyes
    final leftEye = Offset(size.width * 0.41, size.height * 0.45);
    final rightEye = Offset(size.width * 0.59, size.height * 0.45);

    if (config.eyeStyle == 'wink') {
      // Left eye open
      canvas.drawOval(Rect.fromCenter(center: leftEye, width: size.width * 0.088, height: size.height * 0.07), Paint()..color = Colors.white);
      canvas.drawCircle(leftEye, size.width * 0.034, Paint()..color = eyeColor);
      canvas.drawCircle(Offset(leftEye.dx + 2, leftEye.dy - 2), size.width * 0.011, Paint()..color = Colors.white);

      // Right eye wink arc
      final winkPaint = Paint()
        ..color = const Color(0xFF1E1E24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.024
        ..strokeCap = StrokeCap.round;
      final winkPath = Path();
      winkPath.moveTo(size.width * 0.54, size.height * 0.46);
      winkPath.quadraticBezierTo(size.width * 0.59, size.height * 0.43, size.width * 0.64, size.height * 0.46);
      canvas.drawPath(winkPath, winkPaint);
    } else if (config.eyeStyle == 'anime') {
      // Sharp Angular Anime Eyes
      for (final center in [leftEye, rightEye]) {
        canvas.drawOval(Rect.fromCenter(center: center, width: size.width * 0.095, height: size.height * 0.06), Paint()..color = Colors.white);
        canvas.drawCircle(center, size.width * 0.035, Paint()..color = eyeColor);
        canvas.drawCircle(Offset(center.dx + 2, center.dy - 2), size.width * 0.014, Paint()..color = Colors.white);
      }
    } else if (config.eyeStyle == 'sparkle') {
      for (final center in [leftEye, rightEye]) {
        canvas.drawOval(Rect.fromCenter(center: center, width: size.width * 0.10, height: size.height * 0.08), Paint()..color = Colors.white);
        canvas.drawCircle(center, size.width * 0.038, Paint()..color = eyeColor);
        canvas.drawCircle(Offset(center.dx + 3, center.dy - 3), size.width * 0.015, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(center.dx - 2, center.dy + 2), size.width * 0.008, Paint()..color = Colors.white);
      }
    } else {
      for (final center in [leftEye, rightEye]) {
        canvas.drawOval(Rect.fromCenter(center: center, width: size.width * 0.088, height: size.height * 0.07), Paint()..color = Colors.white);
        canvas.drawCircle(center, size.width * 0.034, Paint()..color = eyeColor);
        canvas.drawCircle(Offset(center.dx + 2, center.dy - 2), size.width * 0.011, Paint()..color = Colors.white);
      }
    }

    // Mouth (Reacts to style)
    final mouthPaint = Paint()
      ..color = const Color(0xFF9E2A2B)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.02;

    if (config.mouthStyle == 'joker_grin') {
      final jPath = Path();
      jPath.moveTo(size.width * 0.36, size.height * 0.58);
      jPath.quadraticBezierTo(size.width * 0.5, size.height * 0.69, size.width * 0.64, size.height * 0.58);
      jPath.quadraticBezierTo(size.width * 0.5, size.height * 0.54, size.width * 0.36, size.height * 0.58);
      canvas.drawPath(jPath, Paint()..color = const Color(0xFFE53935));
      canvas.drawLine(Offset(size.width * 0.38, size.height * 0.60), Offset(size.width * 0.62, size.height * 0.60), Paint()..color = Colors.white..strokeWidth = 3);
    } else if (config.mouthStyle == 'laugh') {
      final lPath = Path();
      lPath.moveTo(size.width * 0.42, size.height * 0.58);
      lPath.quadraticBezierTo(size.width * 0.50, size.height * 0.67, size.width * 0.58, size.height * 0.58);
      lPath.close();
      canvas.drawPath(lPath, Paint()..color = const Color(0xFF9E2A2B));
    } else if (config.mouthStyle == 'smirk') {
      final sPath = Path();
      sPath.moveTo(size.width * 0.44, size.height * 0.60);
      sPath.quadraticBezierTo(size.width * 0.52, size.height * 0.63, size.width * 0.60, size.height * 0.57);
      canvas.drawPath(sPath, mouthPaint);
    } else if (config.mouthStyle == 'chill') {
      canvas.drawLine(Offset(size.width * 0.45, size.height * 0.60), Offset(size.width * 0.55, size.height * 0.60), mouthPaint);
    } else {
      final mouthPath = Path();
      mouthPath.moveTo(size.width * 0.43, size.height * 0.59);
      mouthPath.quadraticBezierTo(size.width * 0.5, size.height * 0.65, size.width * 0.57, size.height * 0.59);
      canvas.drawPath(mouthPath, mouthPaint);
    }
  }

  // ==========================================
  // 🧔 8. DYNAMIC BEARD & FACIAL HAIR (6 Styles)
  // ==========================================
  void _paintBeard(Canvas canvas, Size size, Paint? inkLine) {
    if (config.beardStyle == 'none') return;
    final hairColor = VectorAvatarConfig.parseHex(config.hairColor);
    final beardPaint = Paint()..color = hairColor;

    if (config.beardStyle == 'mustache') {
      final mPath = Path();
      mPath.moveTo(size.width * 0.40, size.height * 0.56);
      mPath.quadraticBezierTo(size.width * 0.50, size.height * 0.53, size.width * 0.60, size.height * 0.56);
      mPath.quadraticBezierTo(size.width * 0.50, size.height * 0.60, size.width * 0.40, size.height * 0.56);
      canvas.drawPath(mPath, beardPaint);
    } else if (config.beardStyle == 'french_beard') {
      // Circle Goatee
      final fPath = Path();
      fPath.addOval(Rect.fromCenter(center: Offset(size.width * 0.50, size.height * 0.62), width: size.width * 0.24, height: size.height * 0.16));
      canvas.drawPath(fPath, Paint()..color = hairColor.withValues(alpha: 0.85)..style = PaintingStyle.stroke..strokeWidth = size.width * 0.03);
    } else if (config.beardStyle == 'full_beard') {
      final bPath = Path();
      bPath.moveTo(size.width * 0.28, size.height * 0.52);
      bPath.quadraticBezierTo(size.width * 0.26, size.height * 0.68, size.width * 0.50, size.height * 0.74);
      bPath.quadraticBezierTo(size.width * 0.74, size.height * 0.68, size.width * 0.72, size.height * 0.52);
      bPath.quadraticBezierTo(size.width * 0.65, size.height * 0.62, size.width * 0.50, size.height * 0.64);
      bPath.quadraticBezierTo(size.width * 0.35, size.height * 0.62, size.width * 0.28, size.height * 0.52);
      bPath.close();
      canvas.drawPath(bPath, beardPaint);
    } else if (config.beardStyle == 'goatee') {
      canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.66), size.width * 0.04, beardPaint);
    } else if (config.beardStyle == 'stubble') {
      final sPaint = Paint()..color = hairColor.withValues(alpha: 0.25);
      canvas.drawArc(Rect.fromCenter(center: Offset(size.width * 0.50, size.height * 0.62), width: size.width * 0.35, height: size.height * 0.18), 0, math.pi, true, sPaint);
    }
  }

  // ==========================================
  // 🩺 👔 9. DYNAMIC PROFESSION & HERO OUTFITS (16 Styles)
  // ==========================================
  void _paintShouldersAndOutfit(Canvas canvas, Size size, Color outfit, Color accent, Paint? inkLine) {
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.05, size.height);
    bodyPath.quadraticBezierTo(size.width * 0.15, size.height * 0.74, size.width * 0.35, size.height * 0.72);
    bodyPath.lineTo(size.width * 0.65, size.height * 0.72);
    bodyPath.quadraticBezierTo(size.width * 0.85, size.height * 0.74, size.width * 0.95, size.height);
    bodyPath.close();

    canvas.drawPath(bodyPath, Paint()..color = outfit);
    if (inkLine != null) canvas.drawPath(bodyPath, inkLine);

    if (config.outfitStyle == 'doctor_coat') {
      // White Lab Coat with Inner Scrub
      final scrubPath = Path();
      scrubPath.moveTo(size.width * 0.40, size.height * 0.72);
      scrubPath.lineTo(size.width * 0.60, size.height * 0.72);
      scrubPath.lineTo(size.width * 0.55, size.height);
      scrubPath.lineTo(size.width * 0.45, size.height);
      scrubPath.close();
      canvas.drawPath(scrubPath, Paint()..color = accent);

      // Coat Lapels
      final coatLeft = Path();
      coatLeft.moveTo(size.width * 0.20, size.height * 0.74);
      coatLeft.lineTo(size.width * 0.40, size.height * 0.72);
      coatLeft.lineTo(size.width * 0.45, size.height);
      coatLeft.lineTo(size.width * 0.05, size.height);
      coatLeft.close();
      canvas.drawPath(coatLeft, Paint()..color = Colors.white);

      final coatRight = Path();
      coatRight.moveTo(size.width * 0.80, size.height * 0.74);
      coatRight.lineTo(size.width * 0.60, size.height * 0.72);
      coatRight.lineTo(size.width * 0.55, size.height);
      coatRight.lineTo(size.width * 0.95, size.height);
      coatRight.close();
      canvas.drawPath(coatRight, Paint()..color = Colors.white);
    } else if (config.outfitStyle == 'spider_suit') {
      // Spider-Suit Emblem & Webs
      final spiderPaint = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 2;
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.82), size.width * 0.04, Paint()..color = Colors.black);
      canvas.drawLine(Offset(size.width * 0.5, size.height * 0.82), Offset(size.width * 0.42, size.height * 0.78), spiderPaint);
      canvas.drawLine(Offset(size.width * 0.5, size.height * 0.82), Offset(size.width * 0.58, size.height * 0.78), spiderPaint);
      canvas.drawLine(Offset(size.width * 0.5, size.height * 0.82), Offset(size.width * 0.42, size.height * 0.86), spiderPaint);
      canvas.drawLine(Offset(size.width * 0.5, size.height * 0.82), Offset(size.width * 0.58, size.height * 0.86), spiderPaint);
    } else if (config.outfitStyle == 'superman_suit') {
      // Diamond S Crest
      final crestPath = Path();
      crestPath.moveTo(size.width * 0.50, size.height * 0.76);
      crestPath.lineTo(size.width * 0.58, size.height * 0.82);
      crestPath.lineTo(size.width * 0.50, size.height * 0.90);
      crestPath.lineTo(size.width * 0.42, size.height * 0.82);
      crestPath.close();
      canvas.drawPath(crestPath, Paint()..color = const Color(0xFFFFD700));
      canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.83), size.width * 0.025, Paint()..color = const Color(0xFFE53935));
    } else if (config.outfitStyle == 'pilot_uniform') {
      // Gold Epaulets on shoulders & tie
      final epauletPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.16, size.height * 0.74, size.width * 0.14, size.height * 0.04), const Radius.circular(3)), epauletPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.70, size.height * 0.74, size.width * 0.14, size.height * 0.04), const Radius.circular(3)), epauletPaint);
    } else if (config.outfitStyle == 'joker_suit') {
      // Green Vest & Orange Tie
      final tiePath = Path();
      tiePath.moveTo(size.width * 0.47, size.height * 0.72);
      tiePath.lineTo(size.width * 0.53, size.height * 0.72);
      tiePath.lineTo(size.width * 0.55, size.height * 0.90);
      tiePath.lineTo(size.width * 0.50, size.height * 0.96);
      tiePath.lineTo(size.width * 0.45, size.height * 0.90);
      tiePath.close();
      canvas.drawPath(tiePath, Paint()..color = const Color(0xFFFF9900));
    } else if (config.outfitStyle == 'developer_tee') {
      // Coder Bracket Symbol `<>`
      final codePaint = Paint()..color = accent..style = PaintingStyle.stroke..strokeWidth = 2.5;
      final codePath = Path();
      codePath.moveTo(size.width * 0.44, size.height * 0.80);
      codePath.lineTo(size.width * 0.40, size.height * 0.84);
      codePath.lineTo(size.width * 0.44, size.height * 0.88);

      codePath.moveTo(size.width * 0.56, size.height * 0.80);
      codePath.lineTo(size.width * 0.60, size.height * 0.84);
      codePath.lineTo(size.width * 0.56, size.height * 0.88);
      canvas.drawPath(codePath, codePaint);
    } else if (config.outfitStyle == 'artist_apron') {
      // Paint Splatters on Apron
      canvas.drawCircle(Offset(size.width * 0.40, size.height * 0.84), size.width * 0.025, Paint()..color = const Color(0xFFFF007F));
      canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.88), size.width * 0.022, Paint()..color = const Color(0xFF00F2FE));
      canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.92), size.width * 0.028, Paint()..color = const Color(0xFFFFD700));
    } else if (config.outfitStyle == 'traditional_kurta') {
      final slitPaint = Paint()..color = accent..style = PaintingStyle.stroke..strokeWidth = size.width * 0.016;
      canvas.drawLine(Offset(size.width * 0.5, size.height * 0.71), Offset(size.width * 0.5, size.height * 0.96), slitPaint);
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.78), size.width * 0.014, Paint()..color = const Color(0xFFFFD700));
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.86), size.width * 0.014, Paint()..color = const Color(0xFFFFD700));
    } else if (config.outfitStyle == 'hoodie') {
      final hoodieCollar = Path();
      hoodieCollar.moveTo(size.width * 0.33, size.height * 0.71);
      hoodieCollar.quadraticBezierTo(size.width * 0.5, size.height * 0.86, size.width * 0.67, size.height * 0.71);
      hoodieCollar.quadraticBezierTo(size.width * 0.5, size.height * 0.92, size.width * 0.33, size.height * 0.71);
      canvas.drawPath(hoodieCollar, Paint()..color = _darken(outfit, 0.18));

      final stringPaint = Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.width * 0.015;
      canvas.drawLine(Offset(size.width * 0.44, size.height * 0.82), Offset(size.width * 0.43, size.height * 0.93), stringPaint);
      canvas.drawLine(Offset(size.width * 0.56, size.height * 0.82), Offset(size.width * 0.57, size.height * 0.93), stringPaint);
    }
  }

  // ==========================================
  // 🎧 👑 10. DYNAMIC ACCESSORIES & GEAR (12 Styles)
  // ==========================================
  void _paintAccessories(Canvas canvas, Size size, Paint? inkLine) {
    if (config.accessory == 'none') return;
    final accColor = VectorAvatarConfig.parseHex(config.accessoryColor);

    if (config.accessory == 'stethoscope') {
      final stethoPaint = Paint()
        ..color = const Color(0xFF2C3E50)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.width * 0.035;

      final tubePath = Path();
      tubePath.moveTo(size.width * 0.35, size.height * 0.66);
      tubePath.quadraticBezierTo(size.width * 0.32, size.height * 0.84, size.width * 0.48, size.height * 0.90);
      tubePath.quadraticBezierTo(size.width * 0.68, size.height * 0.84, size.width * 0.65, size.height * 0.66);
      canvas.drawPath(tubePath, stethoPaint);

      canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.90), size.width * 0.045, Paint()..color = const Color(0xFFBDC3C7));
      canvas.drawCircle(Offset(size.width * 0.48, size.height * 0.90), size.width * 0.03, Paint()..color = const Color(0xFF7F8C8D));
    } else if (config.accessory == 'crown') {
      // Golden Crown
      final crownPath = Path();
      crownPath.moveTo(size.width * 0.32, size.height * 0.20);
      crownPath.lineTo(size.width * 0.30, size.height * 0.08);
      crownPath.lineTo(size.width * 0.40, size.height * 0.14);
      crownPath.lineTo(size.width * 0.50, size.height * 0.05); // High center point
      crownPath.lineTo(size.width * 0.60, size.height * 0.14);
      crownPath.lineTo(size.width * 0.70, size.height * 0.08);
      crownPath.lineTo(size.width * 0.68, size.height * 0.20);
      crownPath.close();

      canvas.drawPath(crownPath, Paint()..color = const Color(0xFFFFD700));
      if (inkLine != null) canvas.drawPath(crownPath, inkLine);

      // Jewels
      canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.12), size.width * 0.02, Paint()..color = const Color(0xFFE53935));
      canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.16), size.width * 0.015, Paint()..color = const Color(0xFF1E88E5));
      canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.16), size.width * 0.015, Paint()..color = const Color(0xFF1E88E5));
    } else if (config.accessory == 'beret') {
      // French Artist Beret
      final beretPath = Path();
      beretPath.moveTo(size.width * 0.22, size.height * 0.32);
      beretPath.quadraticBezierTo(size.width * 0.45, size.height * 0.10, size.width * 0.82, size.height * 0.24);
      beretPath.quadraticBezierTo(size.width * 0.60, size.height * 0.30, size.width * 0.22, size.height * 0.32);
      beretPath.close();
      canvas.drawPath(beretPath, Paint()..color = accColor);
      if (inkLine != null) canvas.drawPath(beretPath, inkLine);
    } else if (config.accessory == 'cap') {
      // Snapback Cap
      final capPath = Path();
      capPath.moveTo(size.width * 0.24, size.height * 0.34);
      capPath.quadraticBezierTo(size.width * 0.50, size.height * 0.14, size.width * 0.76, size.height * 0.34);
      capPath.close();
      canvas.drawPath(capPath, Paint()..color = accColor);

      // Visor
      final visor = Path();
      visor.moveTo(size.width * 0.22, size.height * 0.34);
      visor.lineTo(size.width * 0.82, size.height * 0.34);
      visor.lineTo(size.width * 0.78, size.height * 0.38);
      visor.lineTo(size.width * 0.26, size.height * 0.38);
      visor.close();
      canvas.drawPath(visor, Paint()..color = _darken(accColor, 0.2));
    } else if (config.accessory == 'headphones') {
      final bandPaint = Paint()
        ..color = accColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.width * 0.045;
      final bandPath = Path();
      bandPath.moveTo(size.width * 0.22, size.height * 0.44);
      bandPath.quadraticBezierTo(size.width * 0.50, size.height * 0.12, size.width * 0.78, size.height * 0.44);
      canvas.drawPath(bandPath, bandPaint);

      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width * 0.21, size.height * 0.47), width: size.width * 0.09, height: size.height * 0.15), const Radius.circular(8)), Paint()..color = accColor);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width * 0.79, size.height * 0.47), width: size.width * 0.09, height: size.height * 0.15), const Radius.circular(8)), Paint()..color = accColor);
    } else if (config.accessory == 'round_glasses') {
      final gPaint = Paint()..color = accColor..style = PaintingStyle.stroke..strokeWidth = 2.5;
      canvas.drawCircle(Offset(size.width * 0.41, size.height * 0.45), size.width * 0.065, gPaint);
      canvas.drawCircle(Offset(size.width * 0.59, size.height * 0.45), size.width * 0.065, gPaint);
      canvas.drawLine(Offset(size.width * 0.475, size.height * 0.45), Offset(size.width * 0.525, size.height * 0.45), gPaint);
    } else if (config.accessory == 'cool_sunglasses') {
      final shadePaint = Paint()..color = const Color(0xFF111111);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width * 0.40, size.height * 0.45), width: size.width * 0.16, height: size.height * 0.085), const Radius.circular(6)), shadePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width * 0.60, size.height * 0.45), width: size.width * 0.16, height: size.height * 0.085), const Radius.circular(6)), shadePaint);
    } else if (config.accessory == 'cyber_visor') {
      final visorPaint = Paint()..color = const Color(0xFF00FF66);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.45), width: size.width * 0.46, height: size.height * 0.10), const Radius.circular(4)), visorPaint);
    } else if (config.accessory == 'ninja_mask') {
      final maskPaint = Paint()..color = const Color(0xFF111111);
      final maskPath = Path();
      maskPath.moveTo(size.width * 0.30, size.height * 0.52);
      maskPath.lineTo(size.width * 0.70, size.height * 0.52);
      maskPath.lineTo(size.width * 0.60, size.height * 0.70);
      maskPath.lineTo(size.width * 0.40, size.height * 0.70);
      maskPath.close();
      canvas.drawPath(maskPath, maskPaint);
    } else if (config.accessory == 'earring') {
      canvas.drawCircle(Offset(size.width * 0.24, size.height * 0.54), size.width * 0.025, Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
  }

  // ==========================================
  // 🦁 1-OF-1 SPECIES FEATURES (Ears, Horns, Wings, Antennas)
  // ==========================================
  void _paintSpeciesFeatures(Canvas canvas, Size size, [Paint? inkLine]) {
    if (config.species == 'cyber_fox') {
      // Pointed Fox Kitsune Ears with Neon Inner Glow
      final leftEar = Path();
      leftEar.moveTo(size.width * 0.26, size.height * 0.32);
      leftEar.lineTo(size.width * 0.18, size.height * 0.12);
      leftEar.lineTo(size.width * 0.40, size.height * 0.26);
      leftEar.close();
      canvas.drawPath(leftEar, Paint()..color = const Color(0xFFFF7043));
      if (inkLine != null) canvas.drawPath(leftEar, inkLine);

      final leftInner = Path();
      leftInner.moveTo(size.width * 0.27, size.height * 0.28);
      leftInner.lineTo(size.width * 0.22, size.height * 0.16);
      leftInner.lineTo(size.width * 0.36, size.height * 0.25);
      leftInner.close();
      canvas.drawPath(leftInner, Paint()..color = const Color(0xFFFF4081));

      final rightEar = Path();
      rightEar.moveTo(size.width * 0.74, size.height * 0.32);
      rightEar.lineTo(size.width * 0.82, size.height * 0.12);
      rightEar.lineTo(size.width * 0.60, size.height * 0.26);
      rightEar.close();
      canvas.drawPath(rightEar, Paint()..color = const Color(0xFFFF7043));
      if (inkLine != null) canvas.drawPath(rightEar, inkLine);

      final rightInner = Path();
      rightInner.moveTo(size.width * 0.73, size.height * 0.28);
      rightInner.lineTo(size.width * 0.78, size.height * 0.16);
      rightInner.lineTo(size.width * 0.64, size.height * 0.25);
      rightInner.close();
      canvas.drawPath(rightInner, Paint()..color = const Color(0xFFFF4081));
    } else if (config.species == 'shadow_wolf') {
      // Midnight Wolf Ears
      final leftEar = Path();
      leftEar.moveTo(size.width * 0.28, size.height * 0.34);
      leftEar.lineTo(size.width * 0.20, size.height * 0.14);
      leftEar.lineTo(size.width * 0.42, size.height * 0.26);
      leftEar.close();
      canvas.drawPath(leftEar, Paint()..color = const Color(0xFF2C3437));
      if (inkLine != null) canvas.drawPath(leftEar, inkLine);

      final rightEar = Path();
      rightEar.moveTo(size.width * 0.72, size.height * 0.34);
      rightEar.lineTo(size.width * 0.80, size.height * 0.14);
      rightEar.lineTo(size.width * 0.58, size.height * 0.26);
      rightEar.close();
      canvas.drawPath(rightEar, Paint()..color = const Color(0xFF2C3437));
      if (inkLine != null) canvas.drawPath(rightEar, inkLine);
    } else if (config.species == 'ninja_panda') {
      // Round Panda Ears
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.24), size.width * 0.08, Paint()..color = const Color(0xFF1E1E24));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.24), size.width * 0.08, Paint()..color = const Color(0xFF1E1E24));
    } else if (config.species == 'cyber_cat') {
      // Neon Cat Ears
      final leftEar = Path();
      leftEar.moveTo(size.width * 0.30, size.height * 0.32);
      leftEar.lineTo(size.width * 0.22, size.height * 0.16);
      leftEar.lineTo(size.width * 0.42, size.height * 0.24);
      leftEar.close();
      canvas.drawPath(leftEar, Paint()..color = const Color(0xFFEC4899));

      final rightEar = Path();
      rightEar.moveTo(size.width * 0.70, size.height * 0.32);
      rightEar.lineTo(size.width * 0.78, size.height * 0.16);
      rightEar.lineTo(size.width * 0.58, size.height * 0.24);
      rightEar.close();
      canvas.drawPath(rightEar, Paint()..color = const Color(0xFFEC4899));
    } else if (config.species == 'cosmic_dragon') {
      // Curving Astral Dragon Horns
      final leftHorn = Path();
      leftHorn.moveTo(size.width * 0.32, size.height * 0.28);
      leftHorn.quadraticBezierTo(size.width * 0.12, size.height * 0.20, size.width * 0.16, size.height * 0.06);
      leftHorn.quadraticBezierTo(size.width * 0.26, size.height * 0.16, size.width * 0.40, size.height * 0.24);
      leftHorn.close();
      canvas.drawPath(leftHorn, Paint()..color = const Color(0xFF8B5CF6));

      final rightHorn = Path();
      rightHorn.moveTo(size.width * 0.68, size.height * 0.28);
      rightHorn.quadraticBezierTo(size.width * 0.88, size.height * 0.20, size.width * 0.84, size.height * 0.06);
      rightHorn.quadraticBezierTo(size.width * 0.74, size.height * 0.16, size.width * 0.60, size.height * 0.24);
      rightHorn.close();
      canvas.drawPath(rightHorn, Paint()..color = const Color(0xFF8B5CF6));
    } else if (config.species == 'space_robot') {
      // Cyber Antennas
      canvas.drawLine(Offset(size.width * 0.30, size.height * 0.24), Offset(size.width * 0.22, size.height * 0.10), Paint()..color = const Color(0xFF00E5FF)..strokeWidth = 3);
      canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.10), 4, Paint()..color = const Color(0xFFFFFC00));
      canvas.drawLine(Offset(size.width * 0.70, size.height * 0.24), Offset(size.width * 0.78, size.height * 0.10), Paint()..color = const Color(0xFF00E5FF)..strokeWidth = 3);
      canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.10), 4, Paint()..color = const Color(0xFFFFFC00));
    } else if (config.species == 'golden_monarch') {
      // Radiant Solar Halo
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.20), size.width * 0.18, Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 3);
    }
  }

  Color _darken(Color c, [double percent = .1]) {
    final hsl = HSLColor.fromColor(c);
    final hslDark = hsl.withLightness((hsl.lightness - percent).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  @override
  bool shouldRepaint(covariant VectorAvatarPainter oldDelegate) {
    return oldDelegate.config != config ||
        oldDelegate.showBackgroundAura != showBackgroundAura ||
        oldDelegate.animationValue != animationValue;
  }
}
