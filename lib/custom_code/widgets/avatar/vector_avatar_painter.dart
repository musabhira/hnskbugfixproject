import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'jackie_chan_talisman_service.dart';
import 'vector_avatar_config.dart';

/// Multi-Style & Profession Avatar Painter
/// Visually transforms on every single config change (Face Shape, Hair, Beard, Eyes, Mouth, Outfit, Props, Aura, Art Style).
class VectorAvatarPainter extends CustomPainter {
  final VectorAvatarConfig config;
  final bool showBackgroundAura;
  final double animationValue;
  final BorderRadius? borderRadius;

  VectorAvatarPainter({
    required this.config,
    this.showBackgroundAura = true,
    this.animationValue = 0.0,
    this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Background Aura & Thematic Backdrop
    if (showBackgroundAura) {
      _paintAura(canvas, size, center, radius);
    }

    // Clip avatar inside profile boundary (Circular or Squircle)
    canvas.save();
    final clipPath = Path();
    if (borderRadius != null) {
      clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius!.topLeft.x),
      ));
    } else {
      clipPath.addOval(Rect.fromCircle(center: center, radius: radius - 2));
    }
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
    if (borderRadius != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius!.topLeft.x),
        ),
        borderPaint,
      );
    } else {
      canvas.drawCircle(center, radius - size.width * 0.015, borderPaint);
    }

    // 🔮 Jackie Chan Talisman Floating Rune Stone!
    if (config.talismanId != null && config.talismanId!.isNotEmpty) {
      _paintEquippedTalisman(canvas, size);
    }
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
    // 🌟 1-of-1 Full Animal Characters across the 3 Iconic Eras
    if (config.species == 'cyber_cat') {
      _paintCatCharacter(canvas, size);
      return;
    } else if (config.species == 'bored_ape') {
      _paintApeCharacter(canvas, size);
      return;
    } else if (config.species == 'cosmic_dragon') {
      _paintCartoonDragonSideView(canvas, size);
      return;
    }

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
    } else if (config.species == 'royal_tiger') {
      // Royal Tiger Ears & Forehead Stripes
      final leftEar = Path();
      leftEar.moveTo(size.width * 0.28, size.height * 0.32);
      leftEar.lineTo(size.width * 0.20, size.height * 0.16);
      leftEar.lineTo(size.width * 0.40, size.height * 0.24);
      leftEar.close();
      canvas.drawPath(leftEar, Paint()..color = const Color(0xFFF97316));
      final rightEar = Path();
      rightEar.moveTo(size.width * 0.72, size.height * 0.32);
      rightEar.lineTo(size.width * 0.80, size.height * 0.16);
      rightEar.lineTo(size.width * 0.60, size.height * 0.24);
      rightEar.close();
      canvas.drawPath(rightEar, Paint()..color = const Color(0xFFF97316));
      final stripePaint = Paint()..color = const Color(0xFF1E1B4B)..strokeWidth = 2.5;
      canvas.drawLine(Offset(size.width * 0.44, size.height * 0.22), Offset(size.width * 0.56, size.height * 0.22), stripePaint);
      canvas.drawLine(Offset(size.width * 0.46, size.height * 0.18), Offset(size.width * 0.54, size.height * 0.18), stripePaint);
    } else if (config.species == 'golden_lion') {
      // Golden Lion Fluffy Mane Ring & Ears
      final manePaint = Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 10;
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.42), size.width * 0.36, manePaint);
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.22), size.width * 0.08, Paint()..color = const Color(0xFFD97706));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.22), size.width * 0.08, Paint()..color = const Color(0xFFD97706));
    } else if (config.species == 'mighty_elephant') {
      // Large Gentle Elephant Fan Ears
      final earPaint = Paint()..color = const Color(0xFF94A3B8);
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.18, size.height * 0.36), width: size.width * 0.24, height: size.height * 0.32), earPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.82, size.height * 0.36), width: size.width * 0.24, height: size.height * 0.32), earPaint);
    } else if (config.species == 'noble_bear') {
      // Round Grizzly Bear Ears
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.24), size.width * 0.08, Paint()..color = const Color(0xFF78350F));
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.24), size.width * 0.045, Paint()..color = const Color(0xFFD97706));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.24), size.width * 0.08, Paint()..color = const Color(0xFF78350F));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.24), size.width * 0.045, Paint()..color = const Color(0xFFD97706));
    } else if (config.species == 'majestic_eagle') {
      // Noble Eagle Feather Crest Plume
      final crestPath = Path();
      crestPath.moveTo(size.width * 0.44, size.height * 0.22);
      crestPath.lineTo(size.width * 0.50, size.height * 0.06);
      crestPath.lineTo(size.width * 0.56, size.height * 0.22);
      crestPath.close();
      canvas.drawPath(crestPath, Paint()..color = const Color(0xFFFFD700));
    } else if (config.species == 'shadow_leopard') {
      // Spotted Leopard Ears
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.22), size.width * 0.075, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.22), 2.5, Paint()..color = const Color(0xFF1E293B));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.22), size.width * 0.075, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.22), 2.5, Paint()..color = const Color(0xFF1E293B));
    } else if (config.species == 'cosmic_unicorn') {
      // Radiant Starlight Unicorn Horn
      final hornPath = Path();
      hornPath.moveTo(size.width * 0.47, size.height * 0.24);
      hornPath.lineTo(size.width * 0.50, size.height * 0.04);
      hornPath.lineTo(size.width * 0.53, size.height * 0.24);
      hornPath.close();
      canvas.drawPath(hornPath, Paint()..color = const Color(0xFFFFD700));
      canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.04), 4.0, Paint()..color = const Color(0xFF00F0FF).withValues(alpha: 0.6));
    } else if (config.species == 'solar_phoenix') {
      // Blazing Phoenix Feather Plumage
      final flamePath = Path();
      flamePath.moveTo(size.width * 0.40, size.height * 0.24);
      flamePath.quadraticBezierTo(size.width * 0.35, size.height * 0.08, size.width * 0.50, size.height * 0.04);
      flamePath.quadraticBezierTo(size.width * 0.65, size.height * 0.08, size.width * 0.60, size.height * 0.24);
      flamePath.close();
      canvas.drawPath(flamePath, Paint()..color = const Color(0xFFEF4444));
    } else if (config.species == 'armored_rhino') {
      // 🦏 Armored Rhino Forehead Horn
      final horn = Path();
      horn.moveTo(size.width * 0.46, size.height * 0.36);
      horn.lineTo(size.width * 0.50, size.height * 0.16);
      horn.lineTo(size.width * 0.54, size.height * 0.36);
      horn.close();
      canvas.drawPath(horn, Paint()..color = const Color(0xFFCBD5E1));
    } else if (config.species == 'thunder_bison') {
      // 🦬 Thunder Bison / Bull Curved Horns
      final leftHorn = Path()
        ..moveTo(size.width * 0.32, size.height * 0.28)
        ..quadraticBezierTo(size.width * 0.14, size.height * 0.18, size.width * 0.16, size.height * 0.08)
        ..lineTo(size.width * 0.22, size.height * 0.14)
        ..quadraticBezierTo(size.width * 0.28, size.height * 0.22, size.width * 0.38, size.height * 0.26)
        ..close();
      canvas.drawPath(leftHorn, Paint()..color = const Color(0xFFF59E0B));
      final rightHorn = Path()
        ..moveTo(size.width * 0.68, size.height * 0.28)
        ..quadraticBezierTo(size.width * 0.86, size.height * 0.18, size.width * 0.84, size.height * 0.08)
        ..lineTo(size.width * 0.78, size.height * 0.14)
        ..quadraticBezierTo(size.width * 0.72, size.height * 0.22, size.width * 0.62, size.height * 0.26)
        ..close();
      canvas.drawPath(rightHorn, Paint()..color = const Color(0xFFF59E0B));
    } else if (config.species == 'mystic_croc') {
      // 🐊 Mystic Croc Scutes / Spikes
      for (int i = 0; i < 3; i++) {
        final spikeLeft = Path()
          ..moveTo(size.width * 0.20, size.height * (0.35 + i * 0.08))
          ..lineTo(size.width * 0.12, size.height * (0.32 + i * 0.08))
          ..lineTo(size.width * 0.22, size.height * (0.39 + i * 0.08))
          ..close();
        canvas.drawPath(spikeLeft, Paint()..color = const Color(0xFF047857));
        final spikeRight = Path()
          ..moveTo(size.width * 0.80, size.height * (0.35 + i * 0.08))
          ..lineTo(size.width * 0.88, size.height * (0.32 + i * 0.08))
          ..lineTo(size.width * 0.78, size.height * (0.39 + i * 0.08))
          ..close();
        canvas.drawPath(spikeRight, Paint()..color = const Color(0xFF047857));
      }
    } else if (config.species == 'abyssal_shark') {
      // 🦈 Abyssal Shark Dorsal Fin
      final fin = Path()
        ..moveTo(size.width * 0.44, size.height * 0.25)
        ..quadraticBezierTo(size.width * 0.48, size.height * 0.06, size.width * 0.54, size.height * 0.04)
        ..quadraticBezierTo(size.width * 0.50, size.height * 0.14, size.width * 0.56, size.height * 0.25)
        ..close();
      canvas.drawPath(fin, Paint()..color = const Color(0xFF0284C7));
    } else if (config.species == 'wisdom_owl') {
      // 🦉 Wisdom Owl Feather Tufts
      final leftTuft = Path()
        ..moveTo(size.width * 0.32, size.height * 0.28)
        ..lineTo(size.width * 0.22, size.height * 0.12)
        ..lineTo(size.width * 0.38, size.height * 0.22)
        ..close();
      canvas.drawPath(leftTuft, Paint()..color = const Color(0xFF92400E));
      final rightTuft = Path()
        ..moveTo(size.width * 0.68, size.height * 0.28)
        ..lineTo(size.width * 0.78, size.height * 0.12)
        ..lineTo(size.width * 0.62, size.height * 0.22)
        ..close();
      canvas.drawPath(rightTuft, Paint()..color = const Color(0xFF92400E));
    } else if (config.species == 'astral_stag') {
      // 🦌 Astral Stag Antlers
      final antlerPaint = Paint()..color = const Color(0xFFD97706)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(size.width * 0.36, size.height * 0.24), Offset(size.width * 0.24, size.height * 0.08), antlerPaint);
      canvas.drawLine(Offset(size.width * 0.28, size.height * 0.15), Offset(size.width * 0.18, size.height * 0.14), antlerPaint);
      canvas.drawLine(Offset(size.width * 0.64, size.height * 0.24), Offset(size.width * 0.76, size.height * 0.08), antlerPaint);
      canvas.drawLine(Offset(size.width * 0.72, size.height * 0.15), Offset(size.width * 0.82, size.height * 0.14), antlerPaint);
    } else if (config.species == 'silverback_titan') {
      // 🦍 Titan Brow Ridge & Heavy Ears
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.28), width: size.width * 0.44, height: size.height * 0.10), Paint()..color = const Color(0xFF1E293B));
      canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.46), size.width * 0.075, Paint()..color = const Color(0xFF1E293B));
      canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.46), size.width * 0.075, Paint()..color = const Color(0xFF1E293B));
    } else if (config.species == 'imperial_cobra') {
      // 🐍 Imperial Cobra Hood
      final hoodPaint = Paint()..color = const Color(0xFF047857).withValues(alpha: 0.5);
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.44), width: size.width * 0.72, height: size.height * 0.42), hoodPaint);
    } else if (config.species == 'pegasus_stallion') {
      // 🐎 Pegasus Stallion Ears
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.32, size.height * 0.18), width: size.width * 0.08, height: size.height * 0.20), Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.68, size.height * 0.18), width: size.width * 0.08, height: size.height * 0.20), Paint()..color = const Color(0xFFE2E8F0));
    } else if (config.species == 'royal_peacock') {
      // 🦚 Royal Peacock Plumage Fan
      for (int i = 0; i < 5; i++) {
        final angle = (i * 20 - 40) * math.pi / 180;
        final px = size.width * 0.5 + size.width * 0.35 * math.sin(angle);
        final py = size.height * 0.25 - size.height * 0.22 * math.cos(angle);
        canvas.drawLine(Offset(size.width * 0.5, size.height * 0.25), Offset(px, py), Paint()..color = const Color(0xFF0284C7)..strokeWidth = 2.5);
        canvas.drawCircle(Offset(px, py), 4.5, Paint()..color = const Color(0xFF10B981));
      }
    } else if (config.species == 'combat_kangaroo') {
      // 🦘 Combat Kangaroo Ears
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.30, size.height * 0.14), width: size.width * 0.09, height: size.height * 0.24), Paint()..color = const Color(0xFFD97706));
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.70, size.height * 0.14), width: size.width * 0.09, height: size.height * 0.24), Paint()..color = const Color(0xFFD97706));
    } else if (config.species == 'nightfang_bat') {
      // 🦇 Nightfang Bat Pointed Ears
      final leftBatEar = Path()
        ..moveTo(size.width * 0.28, size.height * 0.30)
        ..lineTo(size.width * 0.18, size.height * 0.10)
        ..lineTo(size.width * 0.38, size.height * 0.22)
        ..close();
      canvas.drawPath(leftBatEar, Paint()..color = const Color(0xFF1E1E24));
      final rightBatEar = Path()
        ..moveTo(size.width * 0.72, size.height * 0.30)
        ..lineTo(size.width * 0.82, size.height * 0.10)
        ..lineTo(size.width * 0.62, size.height * 0.22)
        ..close();
      canvas.drawPath(rightBatEar, Paint()..color = const Color(0xFF1E1E24));
    } else if (config.species == 'zen_sloth') {
      // 🦥 Zen Sloth Eye Patches
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.37, size.height * 0.42), width: size.width * 0.12, height: size.height * 0.08), Paint()..color = const Color(0xFF78350F).withValues(alpha: 0.4));
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.63, size.height * 0.42), width: size.width * 0.12, height: size.height * 0.08), Paint()..color = const Color(0xFF78350F).withValues(alpha: 0.4));
    } else if (config.species == 'celestial_hound') {
      // 🐕 Celestial Hound Ears
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.22, size.height * 0.38), width: size.width * 0.12, height: size.height * 0.22), Paint()..color = const Color(0xFFF59E0B));
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.78, size.height * 0.38), width: size.width * 0.12, height: size.height * 0.22), Paint()..color = const Color(0xFFF59E0B));
    } else if (config.species == 'astral_rabbit') {
      // 🐇 Astral Rabbit Long Ears
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.34, size.height * 0.12), width: size.width * 0.08, height: size.height * 0.28), Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.34, size.height * 0.12), width: size.width * 0.04, height: size.height * 0.20), Paint()..color = const Color(0xFFFF80AB));
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.66, size.height * 0.12), width: size.width * 0.08, height: size.height * 0.28), Paint()..color = const Color(0xFFFFFFFF));
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.66, size.height * 0.12), width: size.width * 0.04, height: size.height * 0.20), Paint()..color = const Color(0xFFFF80AB));
    } else if (config.species == 'abyssal_kraken') {
      // 🐙 Abyssal Kraken Crown Tentacles
      for (int i = 0; i < 4; i++) {
        final tx = size.width * (0.28 + i * 0.14);
        final tentacle = Path()
          ..moveTo(tx - 6, size.height * 0.26)
          ..quadraticBezierTo(tx + (i % 2 == 0 ? 8 : -8), size.height * 0.10, tx, size.height * 0.04)
          ..lineTo(tx + 4, size.height * 0.06)
          ..quadraticBezierTo(tx + (i % 2 == 0 ? 12 : -4), size.height * 0.14, tx + 6, size.height * 0.26)
          ..close();
        canvas.drawPath(tentacle, Paint()..color = const Color(0xFF831843));
      }
    } else if (config.species == 'golden_cheetah') {
      // 🐆 Cheetah teardrop eye tracks & rounded ears
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.22), size.width * 0.07, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.22), size.width * 0.07, Paint()..color = const Color(0xFFF59E0B));
      final tearPaint = Paint()..color = const Color(0xFF18181B)..strokeWidth = 2.0;
      canvas.drawLine(Offset(size.width * 0.38, size.height * 0.42), Offset(size.width * 0.36, size.height * 0.52), tearPaint);
      canvas.drawLine(Offset(size.width * 0.62, size.height * 0.42), Offset(size.width * 0.64, size.height * 0.52), tearPaint);
    } else if (config.species == 'polar_bear') {
      // 🐻‍❄️ Frosty Arctic Bear Ears
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.24), size.width * 0.08, Paint()..color = const Color(0xFFE0F2FE));
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.24), size.width * 0.04, Paint()..color = const Color(0xFFBAE6FD));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.24), size.width * 0.08, Paint()..color = const Color(0xFFE0F2FE));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.24), size.width * 0.04, Paint()..color = const Color(0xFFBAE6FD));
    } else if (config.species == 'wild_boar') {
      // 🐗 Boar Curved Snout Tusks & Crest
      final leftTusk = Path()..moveTo(size.width * 0.38, size.height * 0.56)..quadraticBezierTo(size.width * 0.30, size.height * 0.50, size.width * 0.34, size.height * 0.44)..close();
      final rightTusk = Path()..moveTo(size.width * 0.62, size.height * 0.56)..quadraticBezierTo(size.width * 0.70, size.height * 0.50, size.width * 0.66, size.height * 0.44)..close();
      canvas.drawPath(leftTusk, Paint()..color = const Color(0xFFF5F5F4));
      canvas.drawPath(rightTusk, Paint()..color = const Color(0xFFF5F5F4));
    } else if (config.species == 'electric_ray') {
      // ⚡ Manta Ray Wings & Horns
      final wingLeft = Path()..moveTo(size.width * 0.24, size.height * 0.35)..lineTo(size.width * 0.06, size.height * 0.40)..lineTo(size.width * 0.22, size.height * 0.55)..close();
      final wingRight = Path()..moveTo(size.width * 0.76, size.height * 0.35)..lineTo(size.width * 0.94, size.height * 0.40)..lineTo(size.width * 0.78, size.height * 0.55)..close();
      canvas.drawPath(wingLeft, Paint()..color = const Color(0xFF0284C7));
      canvas.drawPath(wingRight, Paint()..color = const Color(0xFF0284C7));
    } else if (config.species == 'cyber_chameleon') {
      // 🦎 Chameleon Crest & Turret Eyes
      canvas.drawArc(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.18), width: size.width * 0.35, height: size.height * 0.20), math.pi, math.pi, true, Paint()..color = const Color(0xFF10B981));
    } else if (config.species == 'armored_armadillo') {
      // 🛡️ Armadillo Segmented Head Shield
      final shield = Path()..moveTo(size.width * 0.35, size.height * 0.20)..lineTo(size.width * 0.50, size.height * 0.12)..lineTo(size.width * 0.65, size.height * 0.20)..close();
      canvas.drawPath(shield, Paint()..color = const Color(0xFF78716C));
    } else if (config.species == 'red_panda') {
      // 🐾 Red Panda White Ear Ruffs
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.24), size.width * 0.08, Paint()..color = const Color(0xFFEA580C));
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.24), size.width * 0.04, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.24), size.width * 0.08, Paint()..color = const Color(0xFFEA580C));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.24), size.width * 0.04, Paint()..color = Colors.white);
    } else if (config.species == 'peregrine_falcon') {
      // 🦅 Falcon Brow & Raptor Crest
      final crest = Path()..moveTo(size.width * 0.46, size.height * 0.20)..lineTo(size.width * 0.50, size.height * 0.08)..lineTo(size.width * 0.54, size.height * 0.20)..close();
      canvas.drawPath(crest, Paint()..color = const Color(0xFF475569));
    } else if (config.species == 'iron_wolverine') {
      // 🦡 Wolverine Iron Brow Plate
      canvas.drawRect(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.24), width: size.width * 0.32, height: 6), Paint()..color = const Color(0xFFF59E0B));
    } else if (config.species == 'tundra_lynx') {
      // 🐱 Tundra Lynx Ear Tufts
      final leftEar = Path()..moveTo(size.width * 0.28, size.height * 0.32)..lineTo(size.width * 0.20, size.height * 0.12)..lineTo(size.width * 0.40, size.height * 0.24)..close();
      final rightEar = Path()..moveTo(size.width * 0.72, size.height * 0.32)..lineTo(size.width * 0.80, size.height * 0.12)..lineTo(size.width * 0.60, size.height * 0.24)..close();
      canvas.drawPath(leftEar, Paint()..color = const Color(0xFFCBD5E1));
      canvas.drawPath(rightEar, Paint()..color = const Color(0xFFCBD5E1));
      canvas.drawLine(Offset(size.width * 0.20, size.height * 0.12), Offset(size.width * 0.18, size.height * 0.06), Paint()..color = Colors.black..strokeWidth = 2.5);
      canvas.drawLine(Offset(size.width * 0.80, size.height * 0.12), Offset(size.width * 0.82, size.height * 0.06), Paint()..color = Colors.black..strokeWidth = 2.5);
    } else if (config.species == 'colossal_walrus') {
      // 🦭 Walrus Long Ivory Downward Tusks
      canvas.drawLine(Offset(size.width * 0.42, size.height * 0.52), Offset(size.width * 0.40, size.height * 0.68), Paint()..color = Colors.white..strokeWidth = 4.0..strokeCap = StrokeCap.round);
      canvas.drawLine(Offset(size.width * 0.58, size.height * 0.52), Offset(size.width * 0.60, size.height * 0.68), Paint()..color = Colors.white..strokeWidth = 4.0..strokeCap = StrokeCap.round);
    } else if (config.species == 'apex_orca') {
      // 🐋 Orca White Eye Patches & Tall Fin
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.28, size.height * 0.38), width: 14, height: 8), Paint()..color = Colors.white);
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.72, size.height * 0.38), width: 14, height: 8), Paint()..color = Colors.white);
      final dorsal = Path()..moveTo(size.width * 0.47, size.height * 0.24)..lineTo(size.width * 0.50, size.height * 0.08)..lineTo(size.width * 0.53, size.height * 0.24)..close();
      canvas.drawPath(dorsal, Paint()..color = const Color(0xFF0F172A));
    } else if (config.species == 'honey_badger') {
      // 🦡 Honey Badger Forehead Mantle
      final mantle = Path()..moveTo(size.width * 0.42, size.height * 0.14)..lineTo(size.width * 0.50, size.height * 0.38)..lineTo(size.width * 0.58, size.height * 0.14)..close();
      canvas.drawPath(mantle, Paint()..color = Colors.white);
    } else if (config.species == 'spotted_hyena') {
      // 🐺 Hyena Broad Rounded Ears
      canvas.drawCircle(Offset(size.width * 0.24, size.height * 0.26), size.width * 0.085, Paint()..color = const Color(0xFFB45309));
      canvas.drawCircle(Offset(size.width * 0.76, size.height * 0.26), size.width * 0.085, Paint()..color = const Color(0xFFB45309));
    } else if (config.species == 'armored_hippo') {
      // 🦛 Hippo Broad Snout
      canvas.drawCircle(Offset(size.width * 0.24, size.height * 0.28), size.width * 0.06, Paint()..color = const Color(0xFF64748B));
      canvas.drawCircle(Offset(size.width * 0.76, size.height * 0.28), size.width * 0.06, Paint()..color = const Color(0xFF64748B));
      canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.54), 5, Paint()..color = const Color(0xFF334155));
      canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.54), 5, Paint()..color = const Color(0xFF334155));
    } else if (config.species == 'savanna_giraffe') {
      // 🦒 Giraffe Ossicones (Horn Nubs)
      canvas.drawLine(Offset(size.width * 0.42, size.height * 0.22), Offset(size.width * 0.38, size.height * 0.08), Paint()..color = const Color(0xFFD97706)..strokeWidth = 4.0..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.08), 5, Paint()..color = const Color(0xFF78350F));
      canvas.drawLine(Offset(size.width * 0.58, size.height * 0.22), Offset(size.width * 0.62, size.height * 0.08), Paint()..color = const Color(0xFFD97706)..strokeWidth = 4.0..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.08), 5, Paint()..color = const Color(0xFF78350F));
    } else if (config.species == 'tree_viper') {
      // 🐍 Emerald Viper Head Scales
      final viperHead = Path()..moveTo(size.width * 0.32, size.height * 0.22)..lineTo(size.width * 0.50, size.height * 0.12)..lineTo(size.width * 0.68, size.height * 0.22)..close();
      canvas.drawPath(viperHead, Paint()..color = const Color(0xFF059669));
    } else if (config.species == 'horned_ram') {
      // 🐏 Bighorn Ram Grand Spiral Horns
      final leftSpiral = Path()..moveTo(size.width * 0.34, size.height * 0.28)..quadraticBezierTo(size.width * 0.12, size.height * 0.18, size.width * 0.14, size.height * 0.36)..close();
      final rightSpiral = Path()..moveTo(size.width * 0.66, size.height * 0.28)..quadraticBezierTo(size.width * 0.88, size.height * 0.18, size.width * 0.86, size.height * 0.36)..close();
      canvas.drawPath(leftSpiral, Paint()..color = const Color(0xFF78350F));
      canvas.drawPath(rightSpiral, Paint()..color = const Color(0xFF78350F));
    } else if (config.species == 'emperor_penguin') {
      // 🐧 Emperor Penguin Golden Collar
      canvas.drawArc(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.38), width: size.width * 0.44, height: size.height * 0.30), 0, math.pi, true, Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.4));
    } else if (config.species == 'golden_jaguar') {
      // 🐆 Jaguar Rosettes
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.24), size.width * 0.075, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.24), size.width * 0.075, Paint()..color = const Color(0xFFF59E0B));
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.22), 3, Paint()..color = const Color(0xFF1C1917));
    } else if (config.species == 'sea_otter') {
      // 🦦 Sea Otter Button Snout
      canvas.drawCircle(Offset(size.width * 0.24, size.height * 0.28), size.width * 0.05, Paint()..color = const Color(0xFF92400E));
      canvas.drawCircle(Offset(size.width * 0.76, size.height * 0.28), size.width * 0.05, Paint()..color = const Color(0xFF92400E));
    } else if (config.species == 'giant_anteater') {
      // 🦔 Anteater Tubular Snout
      final snout = Path()..moveTo(size.width * 0.44, size.height * 0.46)..lineTo(size.width * 0.50, size.height * 0.64)..lineTo(size.width * 0.56, size.height * 0.46)..close();
      canvas.drawPath(snout, Paint()..color = const Color(0xFF475569));
    } else if (config.species == 'woolly_mammoth') {
      // 🦣 Mammoth Grand Curved Tusks
      final leftTusk = Path()..moveTo(size.width * 0.36, size.height * 0.52)..quadraticBezierTo(size.width * 0.16, size.height * 0.60, size.width * 0.20, size.height * 0.40)..close();
      final rightTusk = Path()..moveTo(size.width * 0.64, size.height * 0.52)..quadraticBezierTo(size.width * 0.84, size.height * 0.60, size.width * 0.80, size.height * 0.40)..close();
      canvas.drawPath(leftTusk, Paint()..color = const Color(0xFFFACC15));
      canvas.drawPath(rightTusk, Paint()..color = const Color(0xFFFACC15));
    } else if (config.species == 'swordfish') {
      // 🐟 Swordfish Projecting Bill
      final bill = Path()..moveTo(size.width * 0.48, size.height * 0.42)..lineTo(size.width * 0.50, size.height * 0.70)..lineTo(size.width * 0.52, size.height * 0.42)..close();
      canvas.drawPath(bill, Paint()..color = const Color(0xFF00F0FF));
    } else if (config.species == 'komodo_titan') {
      // 🦎 Komodo Titan Throat Dewlap
      canvas.drawArc(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.50), width: size.width * 0.40, height: size.height * 0.24), 0, math.pi, true, Paint()..color = const Color(0xFF3F3F46));
    } else if (config.species == 'rainforest_toucan') {
      // 🦜 Toucan Oversized Rainbow Bill
      final beak = Path()..moveTo(size.width * 0.44, size.height * 0.42)..quadraticBezierTo(size.width * 0.72, size.height * 0.46, size.width * 0.50, size.height * 0.64)..close();
      canvas.drawPath(beak, Paint()..color = const Color(0xFFF59E0B));
    } else if (config.species == 'crimson_flamingo') {
      // 🦩 Flamingo Curved Bill
      final flamingoCrest = Path()..moveTo(size.width * 0.48, size.height * 0.20)..lineTo(size.width * 0.50, size.height * 0.08)..lineTo(size.width * 0.52, size.height * 0.20)..close();
      canvas.drawPath(flamingoCrest, Paint()..color = const Color(0xFFF43F5E));
    } else if (config.species == 'cyber_meerkat') {
      // 🐾 Meerkat Sentinel Goggles
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.36, size.height * 0.42), width: 14, height: 10), Paint()..color = const Color(0xFF18181B));
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.64, size.height * 0.42), width: 14, height: 10), Paint()..color = const Color(0xFF18181B));
    } else if (config.species == 'shadow_manticore') {
      // 🦂 Manticore Scorpion Stinger & Wings
      final stinger = Path()..moveTo(size.width * 0.48, size.height * 0.22)..quadraticBezierTo(size.width * 0.50, size.height * 0.04, size.width * 0.56, size.height * 0.08)..close();
      canvas.drawPath(stinger, Paint()..color = const Color(0xFFDC2626));
    } else if (config.species == 'golden_griffin') {
      // 🦅 Griffin Crown & Wings
      final leftWing = Path()..moveTo(size.width * 0.30, size.height * 0.28)..lineTo(size.width * 0.10, size.height * 0.12)..lineTo(size.width * 0.35, size.height * 0.20)..close();
      final rightWing = Path()..moveTo(size.width * 0.70, size.height * 0.28)..lineTo(size.width * 0.90, size.height * 0.12)..lineTo(size.width * 0.65, size.height * 0.20)..close();
      canvas.drawPath(leftWing, Paint()..color = const Color(0xFFFFD700));
      canvas.drawPath(rightWing, Paint()..color = const Color(0xFFFFD700));
    } else if (config.species == 'volcanic_salamander') {
      // 🌋 Magma Frills
      for (int i = 0; i < 4; i++) {
        canvas.drawCircle(Offset(size.width * (0.30 + i * 0.13), size.height * 0.18), 5, Paint()..color = const Color(0xFFF97316));
      }
    } else if (config.species == 'oceanic_narwhal') {
      // 🦄 Narwhal Spiral Ocean Tusk
      final tusk = Path()..moveTo(size.width * 0.48, size.height * 0.24)..lineTo(size.width * 0.50, size.height * 0.02)..lineTo(size.width * 0.52, size.height * 0.24)..close();
      canvas.drawPath(tusk, Paint()..color = const Color(0xFFE0F2FE));
    } else if (config.species == 'snow_leopard') {
      // 🐆 Snow Leopard Frosted Ears
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.24), size.width * 0.075, Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.24), size.width * 0.075, Paint()..color = const Color(0xFFE2E8F0));
    } else if (config.species == 'fennec_fox') {
      // 🦊 Gigantic Fennec Radar Ears
      final leftEar = Path()..moveTo(size.width * 0.30, size.height * 0.34)..lineTo(size.width * 0.12, size.height * 0.06)..lineTo(size.width * 0.44, size.height * 0.24)..close();
      final rightEar = Path()..moveTo(size.width * 0.70, size.height * 0.34)..lineTo(size.width * 0.88, size.height * 0.06)..lineTo(size.width * 0.56, size.height * 0.24)..close();
      canvas.drawPath(leftEar, Paint()..color = const Color(0xFFFDE047));
      canvas.drawPath(rightEar, Paint()..color = const Color(0xFFFDE047));
    } else if (config.species == 'cyber_mantis') {
      // 🦗 Mantis Scythe Blades
      canvas.drawLine(Offset(size.width * 0.30, size.height * 0.25), Offset(size.width * 0.18, size.height * 0.10), Paint()..color = const Color(0xFF10B981)..strokeWidth = 3.5);
      canvas.drawLine(Offset(size.width * 0.70, size.height * 0.25), Offset(size.width * 0.82, size.height * 0.10), Paint()..color = const Color(0xFF10B981)..strokeWidth = 3.5);
    } else if (config.species == 'ghost_jellyfish') {
      // 🎐 Jellyfish Bioluminescent Dome
      canvas.drawArc(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.22), width: size.width * 0.50, height: size.height * 0.24), math.pi, math.pi, true, Paint()..color = const Color(0xFFC084FC).withValues(alpha: 0.4));
    } else if (config.species == 'armored_pangolin') {
      // 🛡️ Pangolin Scale Rings
      for (int i = 0; i < 3; i++) {
        canvas.drawCircle(Offset(size.width * (0.38 + i * 0.12), size.height * 0.20), 6, Paint()..color = const Color(0xFFD97706));
      }
    } else if (config.species == 'black_panther') {
      // 🐈‍⬛ Obsidian Panther Sleek Silhouette
      canvas.drawCircle(Offset(size.width * 0.26, size.height * 0.24), size.width * 0.075, Paint()..color = const Color(0xFF18181B));
      canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.24), size.width * 0.075, Paint()..color = const Color(0xFF18181B));
    } else if (config.species == 'sky_thunderbird') {
      // ⚡ Thunderbird Lightning Plumes
      canvas.drawLine(Offset(size.width * 0.46, size.height * 0.22), Offset(size.width * 0.38, size.height * 0.06), Paint()..color = const Color(0xFFFDE047)..strokeWidth = 3.0);
      canvas.drawLine(Offset(size.width * 0.54, size.height * 0.22), Offset(size.width * 0.62, size.height * 0.06), Paint()..color = const Color(0xFFFDE047)..strokeWidth = 3.0);
    } else if (config.species == 'cerberus_hound') {
      // 🐕 Nether Cerberus Fiery Horns
      final leftHorn = Path()..moveTo(size.width * 0.30, size.height * 0.28)..lineTo(size.width * 0.20, size.height * 0.10)..lineTo(size.width * 0.38, size.height * 0.22)..close();
      final rightHorn = Path()..moveTo(size.width * 0.70, size.height * 0.28)..lineTo(size.width * 0.80, size.height * 0.10)..lineTo(size.width * 0.62, size.height * 0.22)..close();
      canvas.drawPath(leftHorn, Paint()..color = const Color(0xFFDC2626));
      canvas.drawPath(rightHorn, Paint()..color = const Color(0xFFDC2626));
    } else if (config.species == 'reef_seahorse') {
      // 🌊 Seahorse Spined Coronet
      for (int i = 0; i < 4; i++) {
        canvas.drawCircle(Offset(size.width * (0.35 + i * 0.10), size.height * 0.16), 4, Paint()..color = const Color(0xFF38BDF8));
      }
    } else if (config.species == 'gorilla_king') {
      // 👑 Gorilla Sovereign 24K Crown
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.24), width: size.width * 0.40, height: 10), Paint()..color = const Color(0xFFFFD700));
    } else if (config.species == 'cyber_chimera') {
      // 🐉 Chimera Horns & Frills
      canvas.drawLine(Offset(size.width * 0.34, size.height * 0.26), Offset(size.width * 0.22, size.height * 0.08), Paint()..color = const Color(0xFFEC4899)..strokeWidth = 3.5);
      canvas.drawLine(Offset(size.width * 0.66, size.height * 0.26), Offset(size.width * 0.78, size.height * 0.08), Paint()..color = const Color(0xFFEC4899)..strokeWidth = 3.5);
    } else if (config.species == 'tree_frog') {
      // 🐸 Poison Dart Frog Bulging Eyes
      canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.24), 10, Paint()..color = const Color(0xFF2563EB));
      canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.24), 10, Paint()..color = const Color(0xFF2563EB));
    } else if (config.species == 'monarch_butterfly') {
      // 🦋 Monarch Butterfly Wings
      final wingLeft = Path()..moveTo(size.width * 0.30, size.height * 0.32)..quadraticBezierTo(size.width * 0.05, size.height * 0.10, size.width * 0.18, size.height * 0.48)..close();
      final wingRight = Path()..moveTo(size.width * 0.70, size.height * 0.32)..quadraticBezierTo(size.width * 0.95, size.height * 0.10, size.width * 0.82, size.height * 0.48)..close();
      canvas.drawPath(wingLeft, Paint()..color = const Color(0xFFEA580C));
      canvas.drawPath(wingRight, Paint()..color = const Color(0xFFEA580C));
    } else if (config.species == 'musk_ox') {
      // 🐂 Musk Ox Drooped Horn Boss Helmet
      canvas.drawLine(Offset(size.width * 0.30, size.height * 0.22), Offset(size.width * 0.70, size.height * 0.22), Paint()..color = const Color(0xFFCBD5E1)..strokeWidth = 8.0..strokeCap = StrokeCap.round);
    } else if (config.species == 'chameleon_king') {
      // 👑 Triple Chameleon Horns
      canvas.drawLine(Offset(size.width * 0.42, size.height * 0.24), Offset(size.width * 0.38, size.height * 0.10), Paint()..color = const Color(0xFF8B5CF6)..strokeWidth = 3.0);
      canvas.drawLine(Offset(size.width * 0.50, size.height * 0.22), Offset(size.width * 0.50, size.height * 0.06), Paint()..color = const Color(0xFF00F0FF)..strokeWidth = 3.5);
      canvas.drawLine(Offset(size.width * 0.58, size.height * 0.24), Offset(size.width * 0.62, size.height * 0.10), Paint()..color = const Color(0xFF8B5CF6)..strokeWidth = 3.0);
    } else if (config.species == 'horned_lizard') {
      // 🦎 Desert Horned Lizard Spiny Crown
      for (int i = 0; i < 5; i++) {
        final hx = size.width * (0.28 + i * 0.11);
        canvas.drawLine(Offset(hx, size.height * 0.24), Offset(hx, size.height * 0.12), Paint()..color = const Color(0xFFB45309)..strokeWidth = 2.5);
      }
    } else if (config.species == 'angler_leviathan') {
      // 💡 Angler Stalk & Bioluminescent Lure
      final stalk = Path()..moveTo(size.width * 0.50, size.height * 0.22)..quadraticBezierTo(size.width * 0.50, size.height * 0.04, size.width * 0.54, size.height * 0.12);
      canvas.drawPath(stalk, Paint()..color = const Color(0xFF00F0FF)..style = PaintingStyle.stroke..strokeWidth = 2.0);
      canvas.drawCircle(Offset(size.width * 0.54, size.height * 0.12), 4, Paint()..color = const Color(0xFFFACC15));
    } else if (config.species == 'mecha_wolf') {
      // 🤖 Mecha Wolf Titanium Plating
      final leftEar = Path()..moveTo(size.width * 0.28, size.height * 0.34)..lineTo(size.width * 0.20, size.height * 0.12)..lineTo(size.width * 0.42, size.height * 0.26)..close();
      final rightEar = Path()..moveTo(size.width * 0.72, size.height * 0.34)..lineTo(size.width * 0.80, size.height * 0.12)..lineTo(size.width * 0.58, size.height * 0.26)..close();
      canvas.drawPath(leftEar, Paint()..color = const Color(0xFF38BDF8));
      canvas.drawPath(rightEar, Paint()..color = const Color(0xFF38BDF8));
    } else if (config.species == 'kitsune_emperor') {
      // 🦊 Kitsune Nine-Tails Mask & Aura
      final leftEar = Path()..moveTo(size.width * 0.26, size.height * 0.32)..lineTo(size.width * 0.16, size.height * 0.08)..lineTo(size.width * 0.40, size.height * 0.26)..close();
      final rightEar = Path()..moveTo(size.width * 0.74, size.height * 0.32)..lineTo(size.width * 0.84, size.height * 0.08)..lineTo(size.width * 0.60, size.height * 0.26)..close();
      canvas.drawPath(leftEar, Paint()..color = const Color(0xFFFF6D00));
      canvas.drawPath(rightEar, Paint()..color = const Color(0xFFFF6D00));
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.18), size.width * 0.22, Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    } else if (config.species == 'solar_lion') {
      // ☀️ Solar Lion Radiant Halo
      final haloPaint = Paint()..color = const Color(0xFFFFD700)..style = PaintingStyle.stroke..strokeWidth = 3.0;
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.40), size.width * 0.42, haloPaint);
    } else if (config.species == 'sea_dragon') {
      // 🐉 Sea Dragon Aquatic Frills
      for (int i = 0; i < 3; i++) {
        canvas.drawCircle(Offset(size.width * 0.18, size.height * (0.30 + i * 0.10)), 6, Paint()..color = const Color(0xFF00F0FF));
        canvas.drawCircle(Offset(size.width * 0.82, size.height * (0.30 + i * 0.10)), 6, Paint()..color = const Color(0xFF00F0FF));
      }
    } else if (config.species == 'thunder_roc') {
      // ⚡ Thunder Roc Avian Lightning Crown
      final crown = Path()..moveTo(size.width * 0.44, size.height * 0.22)..lineTo(size.width * 0.50, size.height * 0.04)..lineTo(size.width * 0.56, size.height * 0.22)..close();
      canvas.drawPath(crown, Paint()..color = const Color(0xFFFFD700));
    } else if (config.species == 'obsidian_basilisk') {
      // 🐍 Obsidian Basilisk Jagged Crown
      for (int i = 0; i < 5; i++) {
        final bx = size.width * (0.30 + i * 0.10);
        final spire = Path()..moveTo(bx - 3, size.height * 0.24)..lineTo(bx, size.height * 0.10)..lineTo(bx + 3, size.height * 0.24)..close();
        canvas.drawPath(spire, Paint()..color = const Color(0xFF10B981));
      }
    } else if (config.species == 'celestial_phoenix') {
      // 🕊️ 24K Celestial Phoenix Halo
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.20), size.width * 0.22, Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.45)..style = PaintingStyle.stroke..strokeWidth = 3.5);
    } else if (config.species == 'cosmic_hydra') {
      // 🌌 Cosmic Hydra Triple Crests
      canvas.drawLine(Offset(size.width * 0.38, size.height * 0.24), Offset(size.width * 0.28, size.height * 0.08), Paint()..color = const Color(0xFFC084FC)..strokeWidth = 3.0);
      canvas.drawLine(Offset(size.width * 0.50, size.height * 0.22), Offset(size.width * 0.50, size.height * 0.05), Paint()..color = const Color(0xFF00F0FF)..strokeWidth = 3.5);
      canvas.drawLine(Offset(size.width * 0.62, size.height * 0.24), Offset(size.width * 0.72, size.height * 0.08), Paint()..color = const Color(0xFFC084FC)..strokeWidth = 3.0);
    } else if (config.species == 'chrono_dragon') {
      // ⏳ Chrono Dragon Gear Horns
      final leftHorn = Path()..moveTo(size.width * 0.32, size.height * 0.28)..quadraticBezierTo(size.width * 0.14, size.height * 0.14, size.width * 0.20, size.height * 0.06)..close();
      final rightHorn = Path()..moveTo(size.width * 0.68, size.height * 0.28)..quadraticBezierTo(size.width * 0.86, size.height * 0.14, size.width * 0.80, size.height * 0.06)..close();
      canvas.drawPath(leftHorn, Paint()..color = const Color(0xFFFFD700));
      canvas.drawPath(rightHorn, Paint()..color = const Color(0xFFFFD700));
    } else if (config.species == 'astral_titan') {
      // 🪐 Astral Titan Celestial Orbit Ring
      canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.20), width: size.width * 0.65, height: 16), Paint()..color = const Color(0xFF818CF8).withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    } else if (config.species == 'cosmic_dragon_sovereign') {
      // 👑 Supreme Cosmic Dragon Sovereign Divine Quad Horns & Halo
      final leftHorn = Path()..moveTo(size.width * 0.30, size.height * 0.26)..quadraticBezierTo(size.width * 0.08, size.height * 0.14, size.width * 0.14, size.height * 0.02)..close();
      final rightHorn = Path()..moveTo(size.width * 0.70, size.height * 0.26)..quadraticBezierTo(size.width * 0.92, size.height * 0.14, size.width * 0.86, size.height * 0.02)..close();
      canvas.drawPath(leftHorn, Paint()..color = const Color(0xFFFFD700));
      canvas.drawPath(rightHorn, Paint()..color = const Color(0xFFFFD700));
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.18), size.width * 0.26, Paint()..color = const Color(0xFF00F0FF).withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 3.5);
    }
  }

  // ==========================================
  // 🔮 JACKIE CHAN 12 ZODIAC TALISMAN STONE (മാന്ത്രിക കല്ല്)
  // ==========================================
  void _paintEquippedTalisman(Canvas canvas, Size size) {
    final talismanId = config.talismanId;
    if (talismanId == null) return;

    final talisman = kJackieChanTalismans.firstWhere(
      (t) => t.id == talismanId,
      orElse: () => kJackieChanTalismans.first,
    );

    // Floating position at bottom-right corner of avatar frame
    final center = Offset(size.width * 0.80, size.height * 0.80);
    final radius = size.width * 0.16;

    // 1. Mystical pulsing glow aura
    final glowPaint = Paint()
      ..color = talisman.glowColor.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawCircle(center, radius + 3, glowPaint);

    // 2. Canonical 8-sided octagonal talisman shape
    final octPath = Path();
    const double angleStep = math.pi / 4; // 45 degrees
    const double initialAngle = -math.pi / 8; // flat top/bottom
    for (int i = 0; i < 8; i++) {
      final a = initialAngle + i * angleStep;
      final x = center.dx + radius * math.cos(a);
      final y = center.dy + radius * math.sin(a);
      if (i == 0) {
        octPath.moveTo(x, y);
      } else {
        octPath.lineTo(x, y);
      }
    }
    octPath.close();

    // 3. Ancient textured stone body
    final stoneGradient = RadialGradient(
      colors: [
        const Color(0xFFE2E8F0),
        talisman.stoneColor,
        const Color(0xFF1E293B),
      ],
      stops: const [0.1, 0.65, 1.0],
    );
    final stonePaint = Paint()
      ..shader = stoneGradient.createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(octPath, stonePaint);

    // 4. Inner beveled octagonal border
    final innerPath = Path();
    final innerRadius = radius * 0.82;
    for (int i = 0; i < 8; i++) {
      final a = initialAngle + i * angleStep;
      final x = center.dx + innerRadius * math.cos(a);
      final y = center.dy + innerRadius * math.sin(a);
      if (i == 0) {
        innerPath.moveTo(x, y);
      } else {
        innerPath.lineTo(x, y);
      }
    }
    innerPath.close();
    final bevelPaint = Paint()
      ..color = talisman.glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(innerPath, bevelPaint);

    // 5. Carved Chinese Zodiac Glyph in the center
    final textSpan = TextSpan(
      text: talisman.runeSymbol,
      style: TextStyle(
        color: Colors.white,
        fontSize: radius * 0.95,
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(
            color: talisman.glowColor,
            blurRadius: 6,
          ),
          const Shadow(
            color: Colors.black,
            blurRadius: 3,
          ),
        ],
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  // ==========================================
  // 🐱 1. FULL VECTOR ANIME & CYBER CAT
  // ==========================================
  void _paintCatCharacter(Canvas canvas, Size size) {
    final furColor = VectorAvatarConfig.parseHex(config.skinColor, fallback: const Color(0xFFF59E0B));
    final furShade = _darken(furColor, 0.15);
    final outfitColor = VectorAvatarConfig.parseHex(config.outfitColor, fallback: const Color(0xFF1E293B));
    final accentColor = VectorAvatarConfig.parseHex(config.outfitAccentColor, fallback: const Color(0xFFFFFC00));
    final eyeColor = VectorAvatarConfig.parseHex(config.eyeColor, fallback: const Color(0xFF10B981));

    // 1. Shoulders & Outfit Base
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.15, size.height);
    bodyPath.quadraticBezierTo(size.width * 0.20, size.height * 0.72, size.width * 0.35, size.height * 0.70);
    bodyPath.lineTo(size.width * 0.65, size.height * 0.70);
    bodyPath.quadraticBezierTo(size.width * 0.80, size.height * 0.72, size.width * 0.85, size.height);
    bodyPath.close();
    canvas.drawPath(bodyPath, Paint()..color = outfitColor);

    // Collar with Bell
    final collarRect = Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.73), width: size.width * 0.36, height: size.height * 0.08);
    canvas.drawRRect(RRect.fromRectAndRadius(collarRect, Radius.circular(size.width * 0.04)), Paint()..color = accentColor);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.76), size.width * 0.045, Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.76), size.width * 0.02, Paint()..color = Colors.black45);

    // 2. Pointed Cat Ears (Behind Head)
    final leftEar = Path();
    leftEar.moveTo(size.width * 0.22, size.height * 0.44);
    leftEar.lineTo(size.width * 0.16, size.height * 0.16);
    leftEar.lineTo(size.width * 0.42, size.height * 0.32);
    leftEar.close();
    canvas.drawPath(leftEar, Paint()..color = furColor);
    final leftInner = Path();
    leftInner.moveTo(size.width * 0.23, size.height * 0.38);
    leftInner.lineTo(size.width * 0.20, size.height * 0.22);
    leftInner.lineTo(size.width * 0.36, size.height * 0.32);
    leftInner.close();
    canvas.drawPath(leftInner, Paint()..color = const Color(0xFFFF80AB));

    final rightEar = Path();
    rightEar.moveTo(size.width * 0.78, size.height * 0.44);
    rightEar.lineTo(size.width * 0.84, size.height * 0.16);
    rightEar.lineTo(size.width * 0.58, size.height * 0.32);
    rightEar.close();
    canvas.drawPath(rightEar, Paint()..color = furColor);
    final rightInner = Path();
    rightInner.moveTo(size.width * 0.77, size.height * 0.38);
    rightInner.lineTo(size.width * 0.80, size.height * 0.22);
    rightInner.lineTo(size.width * 0.64, size.height * 0.32);
    rightInner.close();
    canvas.drawPath(rightInner, Paint()..color = const Color(0xFFFF80AB));

    // 3. Round Feline Head & Fluffy Cheeks
    final headRect = Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.50), width: size.width * 0.62, height: size.height * 0.50);
    canvas.drawOval(headRect, Paint()..color = furColor);

    final leftCheek = Path();
    leftCheek.moveTo(size.width * 0.20, size.height * 0.52);
    leftCheek.lineTo(size.width * 0.12, size.height * 0.55);
    leftCheek.lineTo(size.width * 0.21, size.height * 0.59);
    leftCheek.close();
    canvas.drawPath(leftCheek, Paint()..color = furColor);

    final rightCheek = Path();
    rightCheek.moveTo(size.width * 0.80, size.height * 0.52);
    rightCheek.lineTo(size.width * 0.88, size.height * 0.55);
    rightCheek.lineTo(size.width * 0.79, size.height * 0.59);
    rightCheek.close();
    canvas.drawPath(rightCheek, Paint()..color = furColor);

    // Tabby Markings on Forehead
    final stripePaint = Paint()..color = furShade ..strokeWidth = 2.5 ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.30), Offset(size.width * 0.5, size.height * 0.36), stripePaint);
    canvas.drawLine(Offset(size.width * 0.44, size.height * 0.32), Offset(size.width * 0.46, size.height * 0.38), stripePaint);
    canvas.drawLine(Offset(size.width * 0.56, size.height * 0.32), Offset(size.width * 0.54, size.height * 0.38), stripePaint);

    // 4. Expressive Anime Cat Eyes
    void drawCatEye(double cx, double cy) {
      final eyeRect = Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.14, height: size.height * 0.16);
      canvas.drawOval(eyeRect, Paint()..color = Colors.white);

      final irisRect = Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.10, height: size.height * 0.13);
      final irisPaint = Paint()
        ..shader = RadialGradient(colors: [eyeColor, _darken(eyeColor, 0.35)]).createShader(irisRect);
      canvas.drawOval(irisRect, irisPaint);

      final pupilRect = Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.038, height: size.height * 0.10);
      canvas.drawOval(pupilRect, Paint()..color = Colors.black);

      canvas.drawCircle(Offset(cx - 3, cy - 4), size.width * 0.025, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(cx + 2, cy + 3), size.width * 0.012, Paint()..color = Colors.white);

      final lashPaint = Paint()..color = const Color(0xFF1E1E24) ..style = PaintingStyle.stroke ..strokeWidth = 2.2;
      canvas.drawArc(eyeRect.inflate(1), math.pi * 1.1, math.pi * 0.8, false, lashPaint);
    }
    drawCatEye(size.width * 0.37, size.height * 0.49);
    drawCatEye(size.width * 0.63, size.height * 0.49);

    // 5. Pink Nose & Curved Kitty Smile (:3)
    final nosePath = Path();
    nosePath.moveTo(size.width * 0.47, size.height * 0.57);
    nosePath.lineTo(size.width * 0.53, size.height * 0.57);
    nosePath.lineTo(size.width * 0.50, size.height * 0.60);
    nosePath.close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFFFF4081));

    final mouthPaint = Paint()..color = const Color(0xFF1E1E24) ..style = PaintingStyle.stroke ..strokeWidth = 2 ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.50, size.height * 0.60), Offset(size.width * 0.50, size.height * 0.62), mouthPaint);
    final leftSmile = Path()
      ..moveTo(size.width * 0.50, size.height * 0.62)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.65, size.width * 0.42, size.height * 0.62);
    canvas.drawPath(leftSmile, mouthPaint);
    final rightSmile = Path()
      ..moveTo(size.width * 0.50, size.height * 0.62)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.65, size.width * 0.58, size.height * 0.62);
    canvas.drawPath(rightSmile, mouthPaint);

    // 6. Whiskers (3 on each side)
    final whiskerPaint = Paint()..color = const Color(0xFF2C3437) ..strokeWidth = 1.6 ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.36, size.height * 0.58), Offset(size.width * 0.16, size.height * 0.54), whiskerPaint);
    canvas.drawLine(Offset(size.width * 0.36, size.height * 0.60), Offset(size.width * 0.14, size.height * 0.61), whiskerPaint);
    canvas.drawLine(Offset(size.width * 0.36, size.height * 0.62), Offset(size.width * 0.17, size.height * 0.68), whiskerPaint);

    canvas.drawLine(Offset(size.width * 0.64, size.height * 0.58), Offset(size.width * 0.84, size.height * 0.54), whiskerPaint);
    canvas.drawLine(Offset(size.width * 0.64, size.height * 0.60), Offset(size.width * 0.86, size.height * 0.61), whiskerPaint);
    canvas.drawLine(Offset(size.width * 0.64, size.height * 0.62), Offset(size.width * 0.83, size.height * 0.68), whiskerPaint);

    // 7. Accessories (Crown, Shades, Headphones)
    _paintAccessories(canvas, size, null);
  }

  // ==========================================
  // 🐵 2. FULL VECTOR BORED APE / CYBER CHIMP
  // ==========================================
  void _paintApeCharacter(Canvas canvas, Size size) {
    final furColor = VectorAvatarConfig.parseHex(config.skinColor, fallback: const Color(0xFF8D5B4C));
    final muzzleColor = const Color(0xFFE8B896);
    final outfitColor = VectorAvatarConfig.parseHex(config.outfitColor, fallback: const Color(0xFF1E293B));

    // 1. Broad Streetwear Torso
    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.10, size.height);
    bodyPath.quadraticBezierTo(size.width * 0.16, size.height * 0.70, size.width * 0.32, size.height * 0.68);
    bodyPath.lineTo(size.width * 0.68, size.height * 0.68);
    bodyPath.quadraticBezierTo(size.width * 0.84, size.height * 0.70, size.width * 0.90, size.height);
    bodyPath.close();
    canvas.drawPath(bodyPath, Paint()..color = outfitColor);

    // Gold Chain & Medallion
    final chainPaint = Paint()..color = const Color(0xFFFFD700) ..style = PaintingStyle.stroke ..strokeWidth = 4.5;
    final chainPath = Path();
    chainPath.moveTo(size.width * 0.32, size.height * 0.72);
    chainPath.quadraticBezierTo(size.width * 0.5, size.height * 0.86, size.width * 0.68, size.height * 0.72);
    canvas.drawPath(chainPath, chainPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.83), size.width * 0.055, Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.83), size.width * 0.04, Paint()..color = const Color(0xFFB45309));

    // 2. Large Round Ape Ears
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.48), size.width * 0.12, Paint()..color = furColor);
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.48), size.width * 0.075, Paint()..color = muzzleColor);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.48), size.width * 0.12, Paint()..color = furColor);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.48), size.width * 0.075, Paint()..color = muzzleColor);

    // 3. Ape Cranial Skull Dome
    final skullRect = Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.42), width: size.width * 0.60, height: size.height * 0.48);
    canvas.drawOval(skullRect, Paint()..color = furColor);

    // 4. Iconic Ape Muzzle & Snout
    final muzzleRect = Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.56), width: size.width * 0.54, height: size.height * 0.32);
    canvas.drawRRect(RRect.fromRectAndRadius(muzzleRect, Radius.circular(size.width * 0.16)), Paint()..color = muzzleColor);

    final nostrilPaint = Paint()..color = const Color(0xFF6B4226);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.44, size.height * 0.52), width: size.width * 0.045, height: size.height * 0.035), nostrilPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.56, size.height * 0.52), width: size.width * 0.045, height: size.height * 0.035), nostrilPaint);

    final mouthPaint = Paint()..color = const Color(0xFF3E2723) ..style = PaintingStyle.stroke ..strokeWidth = 3 ..strokeCap = StrokeCap.round;
    final apeMouth = Path();
    apeMouth.moveTo(size.width * 0.32, size.height * 0.62);
    apeMouth.quadraticBezierTo(size.width * 0.50, size.height * 0.68, size.width * 0.68, size.height * 0.61);
    canvas.drawPath(apeMouth, mouthPaint);

    // 5. Bored Ape Eyes (Half-Lidded or Laser)
    if (config.eyeStyle == 'laser' || (config.mintId?.contains('DAY45') ?? false)) {
      final laserPaint = Paint()..color = const Color(0xFFFF0055) ..strokeWidth = 5 ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(size.width * 0.38, size.height * 0.42), Offset(0, size.height * 0.36), laserPaint);
      canvas.drawLine(Offset(size.width * 0.62, size.height * 0.42), Offset(size.width, size.height * 0.36), laserPaint);
    } else {
      void drawApeEye(double cx, double cy) {
        final eyeRect = Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.13, height: size.height * 0.11);
        canvas.drawOval(eyeRect, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(cx, cy + 1), size.width * 0.032, Paint()..color = const Color(0xFF2C1B18));

        final lidPath = Path();
        lidPath.moveTo(cx - size.width * 0.065, cy);
        lidPath.quadraticBezierTo(cx, cy + size.height * 0.03, cx + size.width * 0.065, cy);
        lidPath.lineTo(cx + size.width * 0.065, cy - size.height * 0.05);
        lidPath.lineTo(cx - size.width * 0.065, cy - size.height * 0.05);
        lidPath.close();
        canvas.drawPath(lidPath, Paint()..color = furColor);

        canvas.drawLine(Offset(cx - size.width * 0.07, cy - size.height * 0.03), Offset(cx + size.width * 0.07, cy - size.height * 0.02), Paint()..color = const Color(0xFF3E2723) ..strokeWidth = 2.5);
      }
      drawApeEye(size.width * 0.38, size.height * 0.42);
      drawApeEye(size.width * 0.62, size.height * 0.42);
    }

    // 6. Accessories (Crown, Beanie, Glasses)
    _paintAccessories(canvas, size, null);
  }

  // ==========================================
  // 🐉 3. SIDE-VIEW CARTOON PROFILE DRAGON
  // ==========================================
  void _paintCartoonDragonSideView(Canvas canvas, Size size) {
    final scaleColor = VectorAvatarConfig.parseHex(config.skinColor, fallback: const Color(0xFF8B5CF6));
    final bellyColor = VectorAvatarConfig.parseHex(config.outfitAccentColor, fallback: const Color(0xFFFFD700));
    final hornColor = VectorAvatarConfig.parseHex(config.hairColor, fallback: const Color(0xFFFFFC00));
    final eyeColor = VectorAvatarConfig.parseHex(config.eyeColor, fallback: const Color(0xFF00F0FF));

    // 1. Dragon Neck & Body (Side Profile from left to right)
    final neckPath = Path();
    neckPath.moveTo(size.width * 0.15, size.height);
    neckPath.quadraticBezierTo(size.width * 0.28, size.height * 0.65, size.width * 0.38, size.height * 0.50);
    neckPath.lineTo(size.width * 0.72, size.height * 0.50);
    neckPath.quadraticBezierTo(size.width * 0.82, size.height * 0.75, size.width * 0.90, size.height);
    neckPath.close();
    canvas.drawPath(neckPath, Paint()..color = scaleColor);

    // Segmented Underbelly Plates
    final bellyPath = Path();
    bellyPath.moveTo(size.width * 0.52, size.height * 0.52);
    bellyPath.quadraticBezierTo(size.width * 0.70, size.height * 0.70, size.width * 0.78, size.height);
    bellyPath.lineTo(size.width * 0.90, size.height);
    bellyPath.quadraticBezierTo(size.width * 0.82, size.height * 0.75, size.width * 0.72, size.height * 0.50);
    bellyPath.close();
    canvas.drawPath(bellyPath, Paint()..color = bellyColor.withValues(alpha: 0.9));

    final platePaint = Paint()..color = _darken(bellyColor, 0.25) ..strokeWidth = 2;
    for (double y = 0.58; y < 0.95; y += 0.08) {
      canvas.drawLine(Offset(size.width * 0.58 + (y - 0.58) * 30, size.height * y), Offset(size.width * 0.80, size.height * y), platePaint);
    }

    // 2. Curving Astral Dragon Horns (Side Profile pointing back-left)
    final hornPath1 = Path();
    hornPath1.moveTo(size.width * 0.36, size.height * 0.34);
    hornPath1.cubicTo(size.width * 0.18, size.height * 0.26, size.width * 0.08, size.height * 0.12, size.width * 0.05, size.height * 0.06);
    hornPath1.cubicTo(size.width * 0.16, size.height * 0.18, size.width * 0.26, size.height * 0.28, size.width * 0.42, size.height * 0.32);
    hornPath1.close();
    canvas.drawPath(hornPath1, Paint()..color = hornColor);
    canvas.drawPath(hornPath1, Paint()..style = PaintingStyle.stroke ..color = Colors.white70 ..strokeWidth = 1.5);

    final hornPath2 = Path();
    hornPath2.moveTo(size.width * 0.30, size.height * 0.38);
    hornPath2.cubicTo(size.width * 0.16, size.height * 0.32, size.width * 0.10, size.height * 0.22, size.width * 0.08, size.height * 0.16);
    hornPath2.cubicTo(size.width * 0.16, size.height * 0.26, size.width * 0.22, size.height * 0.34, size.width * 0.34, size.height * 0.36);
    hornPath2.close();
    canvas.drawPath(hornPath2, Paint()..color = _darken(hornColor, 0.2));

    // 3. Spiky Dorsal Frills along back
    final frillPaint = Paint()..color = _darken(scaleColor, 0.2);
    for (int i = 0; i < 5; i++) {
      final fx = size.width * (0.24 + i * 0.04);
      final fy = size.height * (0.42 + i * 0.09);
      final spike = Path();
      spike.moveTo(fx, fy);
      spike.lineTo(fx - size.width * 0.07, fy - size.height * 0.04);
      spike.lineTo(fx + size.width * 0.03, fy + size.height * 0.04);
      spike.close();
      canvas.drawPath(spike, frillPaint);
    }

    // 4. Cartoon Dragon Head & Snout (Side View)
    final headPath = Path();
    headPath.moveTo(size.width * 0.30, size.height * 0.40);
    headPath.quadraticBezierTo(size.width * 0.44, size.height * 0.28, size.width * 0.58, size.height * 0.34);
    headPath.quadraticBezierTo(size.width * 0.70, size.height * 0.38, size.width * 0.84, size.height * 0.44);
    headPath.quadraticBezierTo(size.width * 0.88, size.height * 0.48, size.width * 0.84, size.height * 0.52);
    headPath.lineTo(size.width * 0.62, size.height * 0.53);
    headPath.quadraticBezierTo(size.width * 0.60, size.height * 0.58, size.width * 0.78, size.height * 0.58);
    headPath.quadraticBezierTo(size.width * 0.80, size.height * 0.62, size.width * 0.74, size.height * 0.64);
    headPath.quadraticBezierTo(size.width * 0.48, size.height * 0.64, size.width * 0.38, size.height * 0.52);
    headPath.close();
    canvas.drawPath(headPath, Paint()..color = scaleColor);

    // Mouth Line & Little White Fang
    final mouthPaint = Paint()..color = _darken(scaleColor, 0.4) ..strokeWidth = 2.5 ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * 0.62, size.height * 0.53), Offset(size.width * 0.82, size.height * 0.50), mouthPaint);

    final toothPath = Path();
    toothPath.moveTo(size.width * 0.76, size.height * 0.51);
    toothPath.lineTo(size.width * 0.78, size.height * 0.56);
    toothPath.lineTo(size.width * 0.80, size.height * 0.51);
    toothPath.close();
    canvas.drawPath(toothPath, Paint()..color = Colors.white);

    // Nostril & Animated Flame Puff
    canvas.drawCircle(Offset(size.width * 0.80, size.height * 0.46), size.width * 0.022, Paint()..color = const Color(0xFF1E1E24));

    final flamePath = Path();
    flamePath.moveTo(size.width * 0.82, size.height * 0.46);
    flamePath.quadraticBezierTo(size.width * 0.92, size.height * 0.42, size.width * 0.96, size.height * 0.40);
    flamePath.quadraticBezierTo(size.width * 0.88, size.height * 0.48, size.width * 0.84, size.height * 0.48);
    flamePath.close();
    canvas.drawPath(
      flamePath,
      Paint()..shader = LinearGradient(
        colors: [const Color(0xFFFFFC00), const Color(0xFFFF0055).withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(size.width * 0.82, size.height * 0.40, size.width * 0.15, size.height * 0.1)),
    );

    // 5. Expressive Cartoon Dragon Eye
    final eyeCenter = Offset(size.width * 0.56, size.height * 0.39);
    final eyeRect = Rect.fromCenter(center: eyeCenter, width: size.width * 0.14, height: size.height * 0.16);
    canvas.drawOval(eyeRect, Paint()..color = Colors.white);

    final irisPaint = Paint()..shader = RadialGradient(colors: [eyeColor, _darken(eyeColor, 0.4)]).createShader(eyeRect);
    canvas.drawOval(Rect.fromCenter(center: eyeCenter, width: size.width * 0.10, height: size.height * 0.13), irisPaint);
    canvas.drawOval(Rect.fromCenter(center: eyeCenter, width: size.width * 0.032, height: size.height * 0.11), Paint()..color = Colors.black);
    canvas.drawCircle(Offset(eyeCenter.dx - 3, eyeCenter.dy - 4), size.width * 0.025, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(eyeCenter.dx + 2, eyeCenter.dy + 3), size.width * 0.012, Paint()..color = Colors.white);

    final browPaint = Paint()..color = _darken(scaleColor, 0.35) ..style = PaintingStyle.stroke ..strokeWidth = 3 ..strokeCap = StrokeCap.round;
    final browPath = Path();
    browPath.moveTo(size.width * 0.48, size.height * 0.34);
    browPath.quadraticBezierTo(size.width * 0.56, size.height * 0.30, size.width * 0.64, size.height * 0.34);
    canvas.drawPath(browPath, browPaint);

    // 6. Cute Dragon Wing visible in background
    final wingPath = Path();
    wingPath.moveTo(size.width * 0.30, size.height * 0.65);
    wingPath.lineTo(size.width * 0.18, size.height * 0.48);
    wingPath.lineTo(size.width * 0.28, size.height * 0.54);
    wingPath.lineTo(size.width * 0.22, size.height * 0.60);
    wingPath.close();
    canvas.drawPath(wingPath, Paint()..color = _darken(scaleColor, 0.15));
    canvas.drawPath(wingPath, Paint()..style = PaintingStyle.stroke ..color = hornColor ..strokeWidth = 1.5);

    // 7. Accessories / Crown for higher tiers
    _paintAccessories(canvas, size, null);
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
        oldDelegate.animationValue != animationValue ||
        oldDelegate.borderRadius != borderRadius;
  }
}
