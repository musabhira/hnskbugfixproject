import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// 🎨 Neo-Pop Avatar Card Model with Gender Support & Detailed Neo-Expressionist Art
class PopArtAvatarCardData {
  final int id;
  final String title;
  final String subtitle;
  final bool isMale;
  final Color bgColor;
  final Color hairColor;
  final Color skinColor;
  final Color outfitColor;
  final Color secondaryColor;
  final String faceShape; // 'oval', 'chiseled_square', 'heart', 'long_angular', 'round_chubby', 'diamond', 'sharp_jaw'
  final String earringStyle; // 'star', 'rect', 'hoop', 'stud', 'cross', 'double_rings', 'none'
  final String headAccessory; // 'crown', 'hairclips', 'halo', 'headband', 'cap', 'beanie', 'headphones', 'bucket_hat', 'pilot_goggles', 'none'
  final String eyewear; // 'round_glasses', 'square_shades', 'cat_eye', 'browline', 'tinted_aviator', 'cyclops_visor', 'heart_glasses', 'none'
  final String facialHair; // 'stubble', 'mustache', 'goatee', 'chin_beard', 'full_beard', 'soul_patch', 'none'
  final String outfitStyle; // 'doodle_kimono', 'polka_dress', 'hoodie', 'bomber_jacket', 'turtleneck', 'leather_jacket', 'sport_jersey', 'cardigan', 'striped_sailor', 'overalls'
  final String hairStyle; // 'curly_cloud', 'short_crop', 'straight_bangs', 'messy_spikes', 'afro_puffs', 'side_swept', 'twin_buns', 'dreadlocks', 'pompadour', 'buzz_cut', 'mohawk', 'ponytail', 'braids', 'undercut'
  final String eyeStyle; // 'star_eyes', 'swirl_eyes', 'wide_black', 'chill_half', 'sparkle_glint', 'cross_eyes'
  final String expression; // 'smile', 'chill', 'smirk', 'open_mouth', 'sassy_wink', 'grimace', 'whistle'
  final String faceDecal; // 'bandaid', 'heart_tattoo', 'freckles', 'star_cheek', 'lightning_scar', 'tribal_mark', 'diamond_tear', 'blush_dots', 'none'
  final String quote;

  const PopArtAvatarCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isMale = false,
    required this.bgColor,
    required this.hairColor,
    required this.skinColor,
    required this.outfitColor,
    this.secondaryColor = const Color(0xFFFFD54F),
    this.faceShape = 'oval',
    this.earringStyle = 'star',
    this.headAccessory = 'none',
    this.eyewear = 'round_glasses',
    this.facialHair = 'none',
    this.outfitStyle = 'doodle_kimono',
    this.hairStyle = 'curly_cloud',
    this.eyeStyle = 'star_eyes',
    this.expression = 'chill',
    this.faceDecal = 'none',
    required this.quote,
  });

  Color get rarityColor => secondaryColor;
  String get badgeEmoji => isMale ? '⚡' : '🌸';
}

typedef PopArtCardModel = PopArtAvatarCardData;

/// 🖼️ Flame-Powered Vector Engine rendering high-fidelity Neo-Pop Art
class PopArtCardFlameGame extends FlameGame {
  final PopArtAvatarCardData data;
  double animationTime = 0.0;

  PopArtCardFlameGame({required this.data});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  void update(double dt) {
    super.update(dt);
    animationTime += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;
    if (w <= 0 || h <= 0) return;
    renderPopArtCard(canvas, w, h);
  }

  void renderPopArtCard(Canvas canvas, double w, double h) {
    final cardRect = Rect.fromLTWH(0, 0, w, h);

    // 1. Vibrant Quad/Multi-Patch Neo-Pop Background
    _renderVibrantBackground(canvas, w, h);

    // 2. Neo-Pop Comic Wall Decals (Abstract gallery art cards, symbols, squiggles, stars)
    _renderBackgroundWallDoodles(canvas, w, h);

    // 3. Render Avatar Character (Hair back, Neck, Outfit, Ears, Face, Eyes/Glasses, Bangs, Accessories)
    _renderAvatarCharacter(canvas, w, h);

    // 4. Black Thick Neo-Expressionist Ink Outer Border
    final borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cardRect, const Radius.circular(18)),
      borderPaint,
    );
  }

  /// 🌈 Neo-Pop Color Block Background with split sections like reference images
  void _renderVibrantBackground(Canvas canvas, double w, double h) {
    // Split into 4 color blocks or vibrant duo tones
    final bgPaint = Paint()..color = data.bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final p1 = Paint()..color = data.secondaryColor.withValues(alpha: 0.9);
    final p2 = Paint()..color = const Color(0xFF60A5FA).withValues(alpha: 0.65);
    final p3 = Paint()..color = const Color(0xFFC084FC).withValues(alpha: 0.7);

    // Top Right quadrant block
    canvas.drawRect(Rect.fromLTWH(w * 0.5, 0, w * 0.5, h * 0.42), p1);
    // Bottom Left quadrant block
    canvas.drawRect(Rect.fromLTWH(0, h * 0.6, w * 0.4, h * 0.4), p3);
    // Right Mid block
    canvas.drawRect(Rect.fromLTWH(w * 0.78, h * 0.28, w * 0.22, h * 0.35), p2);

    // Ink division grid lines
    final lineInk = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.5, h * 0.42), lineInk);
    canvas.drawLine(Offset(0, h * 0.6), Offset(w * 0.4, h * 0.6), lineInk);
  }

  /// 🖼️ Background Poster Mini-Frames, Geometric Glyphs, Letter "W", Swirls & Flowers
  void _renderBackgroundWallDoodles(Canvas canvas, double w, double h) {
    final ink = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillWhite = Paint()..color = Colors.white;
    final fillYellow = Paint()..color = const Color(0xFFFFE082);
    final fillPink = Paint()..color = const Color(0xFFF48FB1);
    final fillLavender = Paint()..color = const Color(0xFFCE93D8);
    final fillMint = Paint()..color = const Color(0xFFA7F3D0);

    // Frame 1: Top Left mini canvas / card
    final f1 = Rect.fromLTWH(w * 0.08, h * 0.03, w * 0.18, h * 0.11);
    canvas.drawRRect(RRect.fromRectAndRadius(f1, const Radius.circular(5)), fillYellow);
    canvas.drawRRect(RRect.fromRectAndRadius(f1, const Radius.circular(5)), ink);
    canvas.drawLine(Offset(f1.left + 6, f1.top + 8), Offset(f1.right - 6, f1.bottom - 8), ink);
    canvas.drawCircle(Offset(f1.left + 12, f1.bottom - 12), 4, ink);

    // Frame 2: Top Center-Right gallery card
    final f2 = Rect.fromLTWH(w * 0.72, h * 0.04, w * 0.20, h * 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(f2, const Radius.circular(5)), fillMint);
    canvas.drawRRect(RRect.fromRectAndRadius(f2, const Radius.circular(5)), ink);
    canvas.drawRect(Rect.fromCenter(center: f2.center, width: 14, height: 14), ink);

    // Top Left Pop Flower
    final flowerCenter = Offset(w * 0.16, h * 0.18);
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * math.pi * 2;
      final px = flowerCenter.dx + math.cos(angle) * 11;
      final py = flowerCenter.dy + math.sin(angle) * 11;
      canvas.drawCircle(Offset(px, py), 8, fillWhite);
      canvas.drawCircle(Offset(px, py), 8, ink);
    }
    final flowerCore = Paint()..color = const Color(0xFFFFB300);
    canvas.drawCircle(flowerCenter, 7, flowerCore);
    canvas.drawCircle(flowerCenter, 7, ink);

    // Top Right Geometric Purple Triangle
    final triPath = Path()
      ..moveTo(w * 0.65, h * 0.07)
      ..lineTo(w * 0.86, h * 0.06)
      ..lineTo(w * 0.75, h * 0.14)
      ..close();
    canvas.drawPath(triPath, fillLavender);
    canvas.drawPath(triPath, ink);

    // Pop Lettering "W" or "★" on Right Side
    final wTextPath = Path()
      ..moveTo(w * 0.86, h * 0.44)
      ..lineTo(w * 0.88, h * 0.49)
      ..lineTo(w * 0.90, h * 0.45)
      ..lineTo(w * 0.92, h * 0.49)
      ..lineTo(w * 0.94, h * 0.44);
    final wPaint = Paint()
      ..color = const Color(0xFFFFAB91)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(wTextPath, wPaint);
    canvas.drawPath(wTextPath, ink);

    // Bottom Left Large Flower
    final bFlowerCenter = Offset(w * 0.18, h * 0.88);
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * math.pi * 2;
      final px = bFlowerCenter.dx + math.cos(angle) * 13;
      final py = bFlowerCenter.dy + math.sin(angle) * 13;
      canvas.drawCircle(Offset(px, py), 9, fillYellow);
      canvas.drawCircle(Offset(px, py), 9, ink);
    }
    canvas.drawCircle(bFlowerCenter, 7, fillWhite);
    canvas.drawCircle(bFlowerCenter, 7, ink);

    // Bottom Right Graffiti Heart
    final heartCenter = Offset(w * 0.82, h * 0.88);
    final heartPath = Path();
    heartPath.moveTo(heartCenter.dx, heartCenter.dy + 12);
    heartPath.cubicTo(
      heartCenter.dx - 18, heartCenter.dy - 6,
      heartCenter.dx - 18, heartCenter.dy - 18,
      heartCenter.dx, heartCenter.dy - 10,
    );
    heartPath.cubicTo(
      heartCenter.dx + 18, heartCenter.dy - 18,
      heartCenter.dx + 18, heartCenter.dy - 6,
      heartCenter.dx, heartCenter.dy + 12,
    );
    heartPath.close();
    canvas.drawPath(heartPath, fillPink);
    canvas.drawPath(heartPath, ink);

    final squiggle = Path()
      ..moveTo(w * 0.05, h * 0.44)
      ..quadraticBezierTo(w * 0.12, h * 0.46, w * 0.05, h * 0.50)
      ..quadraticBezierTo(w * 0.12, h * 0.54, w * 0.05, h * 0.58);
    canvas.drawPath(squiggle, ink);

    final rightSquiggle = Path()
      ..moveTo(w * 0.94, h * 0.38)
      ..quadraticBezierTo(w * 0.88, h * 0.42, w * 0.94, h * 0.46)
      ..quadraticBezierTo(w * 0.88, h * 0.50, w * 0.94, h * 0.54);
    canvas.drawPath(rightSquiggle, ink);
  }

  /// 👩‍🎨 / 👨‍🎨 Renders the Character according to Gender & Chosen Neo-Pop Attributes
  void _renderAvatarCharacter(Canvas canvas, double w, double h) {
    final cx = w * 0.5;
    final cy = h * 0.38;

    final ink = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final skinPaint = Paint()..color = data.skinColor;
    final hairPaint = Paint()..color = data.hairColor;

    // --- 1. BACK HAIR / HEAD SHAPE ---
    _renderBackHair(canvas, cx, cy, w, h, hairPaint, ink);

    // --- 2. HEAD ACCESSORIES ---
    if (data.headAccessory == 'crown') {
      _renderGoldenCrown(canvas, cx, cy - h * 0.18, w, ink);
    } else if (data.headAccessory == 'halo') {
      _renderAngelHalo(canvas, cx, cy - h * 0.24, w, ink);
    } else if (data.headAccessory == 'cap') {
      _renderBaseballCap(canvas, cx, cy - h * 0.16, w, h, ink);
    } else if (data.headAccessory == 'bucket_hat') {
      _renderBucketHat(canvas, cx, cy - h * 0.16, w, h, ink);
    } else if (data.headAccessory == 'pilot_goggles') {
      _renderPilotGoggles(canvas, cx, cy - h * 0.16, w, h, ink);
    } else if (data.headAccessory == 'beanie') {
      _renderBeanie(canvas, cx, cy - h * 0.18, w, h, ink);
    } else if (data.headAccessory == 'headband') {
      _renderHeadband(canvas, cx, cy - h * 0.12, w, ink);
    } else if (data.headAccessory == 'headphones') {
      _renderOverEarHeadphones(canvas, cx, cy, w, h, ink);
    }

    // --- 3. LONG SLENDER NECK & COLLARBONE ---
    final neckWidth = (data.faceShape == 'chiseled_square' || data.isMale) ? w * 0.17 : w * 0.11;
    final neckHeight = h * 0.28;
    final neckRect = Rect.fromLTWH(cx - neckWidth / 2, cy + h * 0.08, neckWidth, neckHeight);
    canvas.drawRect(neckRect, skinPaint);
    canvas.drawRect(neckRect, ink);

    final neckBlushPaint = Paint()..color = const Color(0xFFFF5252).withValues(alpha: 0.35);
    canvas.drawRect(
      Rect.fromLTWH(cx - neckWidth / 2 + 1, cy + h * 0.14, neckWidth - 2, h * 0.03),
      neckBlushPaint,
    );

    // --- 4. OUTFIT / CLOTHES ---
    _renderOutfit(canvas, cx, cy, w, h, ink);

    // --- 5. HUGE STYLED POP-ART EARS (Left & Right) ---
    _renderBigEars(canvas, cx, cy, w, h, skinPaint, ink);

    // --- 6. POP-ART EARRINGS ---
    _renderEarrings(canvas, cx, cy, w, h, ink);

    // --- 7. DISTINCT FACE SHAPES ---
    _renderFaceShape(canvas, cx, cy, w, h, skinPaint, ink);

    final cheekPaint = Paint()..color = const Color(0xFFFF4081).withValues(alpha: 0.65);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.16, cy + h * 0.05), width: w * 0.12, height: h * 0.06),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + w * 0.16, cy + h * 0.05), width: w * 0.12, height: h * 0.06),
      cheekPaint,
    );

    // Face Decals (Bandaid, Heart, Freckles, Diamond Tear, Blush Dots, etc.)
    _renderFaceDecals(canvas, cx, cy, w, h, ink);

    // Facial Hair (Stubble, Mustache, Goatee, Full Beard, Soul Patch)
    if (data.isMale && data.facialHair != 'none') {
      _renderFacialHair(canvas, cx, cy, w, h, ink);
    }

    // Nose & Distinct Expressions (Smile, Smirk, Chill, Open mouth, Whistle, Grimace)
    _renderNoseAndMouth(canvas, cx, cy, w, h, ink);

    // --- 8. DIVERSE EYEWEAR ---
    _renderEyesAndGlasses(canvas, cx, cy, w, h, ink);

    // --- 9. FRONT BANGS & HAIR CLIPS ---
    _renderFrontHairAndClips(canvas, cx, cy, w, h, hairPaint, ink);
  }

  /// 🪖 90s Streetwear Bucket Hat
  void _renderBucketHat(Canvas canvas, double cx, double cy, double w, double h, Paint ink) {
    final hatPaint = Paint()..color = const Color(0xFFFBBF24);
    final crownPath = Path()
      ..moveTo(cx - w * 0.22, cy - h * 0.08)
      ..lineTo(cx - w * 0.18, cy - h * 0.18)
      ..lineTo(cx + w * 0.18, cy - h * 0.18)
      ..lineTo(cx + w * 0.22, cy - h * 0.08)
      ..close();
    canvas.drawPath(crownPath, hatPaint);
    canvas.drawPath(crownPath, ink);

    // Wide downward brim
    final brimPath = Path()
      ..moveTo(cx - w * 0.32, cy - h * 0.02)
      ..lineTo(cx - w * 0.22, cy - h * 0.08)
      ..lineTo(cx + w * 0.22, cy - h * 0.08)
      ..lineTo(cx + w * 0.32, cy - h * 0.02)
      ..close();
    canvas.drawPath(brimPath, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawPath(brimPath, ink);
  }

  /// 🥽 Steampunk / Pilot Goggles rested on forehead
  void _renderPilotGoggles(Canvas canvas, double cx, double cy, double w, double h, Paint ink) {
    final gY = cy - h * 0.12;
    final gL = Offset(cx - w * 0.12, gY);
    final gR = Offset(cx + w * 0.12, gY);
    final strap = Paint()..color = const Color(0xFF451A03)..strokeWidth = 6.0;
    canvas.drawLine(Offset(cx - w * 0.28, gY), Offset(cx + w * 0.28, gY), strap);
    canvas.drawLine(Offset(cx - w * 0.28, gY), Offset(cx + w * 0.28, gY), ink..strokeWidth = 2.0);

    final lensPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawCircle(gL, 14, lensPaint);
    canvas.drawCircle(gR, 14, lensPaint);
    final rimPaint = Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.stroke..strokeWidth = 4.0;
    canvas.drawCircle(gL, 14, rimPaint);
    canvas.drawCircle(gL, 14, ink);
    canvas.drawCircle(gR, 14, rimPaint);
    canvas.drawCircle(gR, 14, ink);
  }

  /// 🎧 Over-Ear DJ Headphones
  void _renderOverEarHeadphones(Canvas canvas, double cx, double cy, double w, double h, Paint ink) {
    final bandPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy - h * 0.08), width: w * 0.64, height: h * 0.38), math.pi, math.pi, false, bandPaint);
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy - h * 0.08), width: w * 0.64, height: h * 0.38), math.pi, math.pi, false, ink);

    final leftEarCup = Rect.fromCenter(center: Offset(cx - w * 0.32, cy - h * 0.01), width: w * 0.14, height: h * 0.16);
    final rightEarCup = Rect.fromCenter(center: Offset(cx + w * 0.32, cy - h * 0.01), width: w * 0.14, height: h * 0.16);
    final cupPaint = Paint()..color = const Color(0xFFFF007A);
    canvas.drawRRect(RRect.fromRectAndRadius(leftEarCup, const Radius.circular(10)), cupPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(leftEarCup, const Radius.circular(10)), ink);
    canvas.drawRRect(RRect.fromRectAndRadius(rightEarCup, const Radius.circular(10)), cupPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightEarCup, const Radius.circular(10)), ink);
  }

  /// 🗿 Distinct Face Shapes: Chiseled square, Heart, Diamond, Long Angular, Round Chubby, Oval
  void _renderFaceShape(Canvas canvas, double cx, double cy, double w, double h, Paint skin, Paint ink) {
    if (data.faceShape == 'chiseled_square' || (data.isMale && data.faceShape == 'oval')) {
      final jawPath = Path()
        ..moveTo(cx - w * 0.23, cy - h * 0.10)
        ..lineTo(cx - w * 0.23, cy + h * 0.05)
        ..lineTo(cx - w * 0.16, cy + h * 0.12)
        ..lineTo(cx - w * 0.06, cy + h * 0.14)
        ..lineTo(cx + w * 0.06, cy + h * 0.14)
        ..lineTo(cx + w * 0.16, cy + h * 0.12)
        ..lineTo(cx + w * 0.23, cy + h * 0.05)
        ..lineTo(cx + w * 0.23, cy - h * 0.10)
        ..close();
      canvas.drawPath(jawPath, skin);
      canvas.drawPath(jawPath, ink);
      if (data.id % 2 == 0) {
        canvas.drawLine(Offset(cx, cy + h * 0.11), Offset(cx, cy + h * 0.13), ink..strokeWidth = 2.5);
      }
    } else if (data.faceShape == 'heart') {
      final heartPath = Path()
        ..moveTo(cx - w * 0.24, cy - h * 0.08)
        ..quadraticBezierTo(cx - w * 0.26, cy + h * 0.04, cx - w * 0.08, cy + h * 0.14)
        ..lineTo(cx, cy + h * 0.15)
        ..lineTo(cx + w * 0.08, cy + h * 0.14)
        ..quadraticBezierTo(cx + w * 0.26, cy + h * 0.04, cx + w * 0.24, cy - h * 0.08)
        ..close();
      canvas.drawPath(heartPath, skin);
      canvas.drawPath(heartPath, ink);
    } else if (data.faceShape == 'diamond') {
      final diamondPath = Path()
        ..moveTo(cx - w * 0.20, cy - h * 0.10)
        ..lineTo(cx - w * 0.26, cy)
        ..lineTo(cx - w * 0.12, cy + h * 0.14)
        ..lineTo(cx + w * 0.12, cy + h * 0.14)
        ..lineTo(cx + w * 0.26, cy)
        ..lineTo(cx + w * 0.20, cy - h * 0.10)
        ..close();
      canvas.drawPath(diamondPath, skin);
      canvas.drawPath(diamondPath, ink);
    } else if (data.faceShape == 'round_chubby') {
      final roundRect = Rect.fromCenter(center: Offset(cx, cy + h * 0.01), width: w * 0.52, height: h * 0.26);
      canvas.drawOval(roundRect, skin);
      canvas.drawOval(roundRect, ink);
    } else {
      final faceRect = Rect.fromCenter(
        center: Offset(cx, cy),
        width: w * 0.46,
        height: h * 0.24,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(faceRect, Radius.circular(w * 0.22)), skin);
      canvas.drawRRect(RRect.fromRectAndRadius(faceRect, Radius.circular(w * 0.22)), ink);
    }
  }

  /// 🩹 Neo-Pop Face Decals (Bandaid, Heart, Star, Freckles, Lightning Scar, Tribal Mark, Diamond Tear, Blush Dots)
  void _renderFaceDecals(Canvas canvas, double cx, double cy, double w, double h, Paint ink) {
    if (data.faceDecal == 'bandaid') {
      final bandRect = Rect.fromCenter(center: Offset(cx, cy + h * 0.035), width: 28, height: 11);
      final bandPaint = Paint()..color = const Color(0xFFFFD54F);
      canvas.drawRRect(RRect.fromRectAndRadius(bandRect, const Radius.circular(3)), bandPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(bandRect, const Radius.circular(3)), ink..strokeWidth = 2.0);
      canvas.drawCircle(Offset(cx, cy + h * 0.035), 2.5, Paint()..color = const Color(0xFFEF4444));
    } else if (data.faceDecal == 'diamond_tear') {
      // Pierrot / Harlequin diamond under eye
      final dPos = Offset(cx - w * 0.16, cy + h * 0.08);
      final dPath = Path()
        ..moveTo(dPos.dx, dPos.dy - 7)
        ..lineTo(dPos.dx + 5, dPos.dy)
        ..lineTo(dPos.dx, dPos.dy + 7)
        ..lineTo(dPos.dx - 5, dPos.dy)
        ..close();
      canvas.drawPath(dPath, Paint()..color = const Color(0xFF00E5FF));
      canvas.drawPath(dPath, ink..strokeWidth = 1.5);
    } else if (data.faceDecal == 'blush_dots') {
      // Anime triple vertical blush lines
      final bP = Paint()..color = const Color(0xFFFF007A)..strokeWidth = 2.5;
      for (int i = -1; i <= 1; i++) {
        canvas.drawLine(Offset(cx - w * 0.16 + i * 4, cy + h * 0.05), Offset(cx - w * 0.16 + i * 4, cy + h * 0.08), bP);
        canvas.drawLine(Offset(cx + w * 0.16 + i * 4, cy + h * 0.05), Offset(cx + w * 0.16 + i * 4, cy + h * 0.08), bP);
      }
    } else if (data.faceDecal == 'lightning_scar') {
      final bolt = Path()
        ..moveTo(cx + w * 0.16, cy - h * 0.04)
        ..lineTo(cx + w * 0.13, cy + h * 0.02)
        ..lineTo(cx + w * 0.18, cy + h * 0.02)
        ..lineTo(cx + w * 0.14, cy + h * 0.08);
      canvas.drawPath(bolt, Paint()..color = const Color(0xFFFFD600)..style = PaintingStyle.stroke..strokeWidth = 4.0);
      canvas.drawPath(bolt, ink..strokeWidth = 2.0);
    } else if (data.faceDecal == 'tribal_mark') {
      final tP = Paint()..color = const Color(0xFFFF007A)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx - w * 0.22, cy + h * 0.06), Offset(cx - w * 0.14, cy + h * 0.08), tP);
      canvas.drawLine(Offset(cx - w * 0.20, cy + h * 0.09), Offset(cx - w * 0.12, cy + h * 0.11), tP);
      canvas.drawLine(Offset(cx + w * 0.14, cy + h * 0.08), Offset(cx + w * 0.22, cy + h * 0.06), tP);
      canvas.drawLine(Offset(cx + w * 0.12, cy + h * 0.11), Offset(cx + w * 0.20, cy + h * 0.09), tP);
    } else if (data.faceDecal == 'heart_tattoo') {
      final hPos = Offset(cx + w * 0.18, cy + h * 0.08);
      canvas.drawCircle(Offset(hPos.dx - 3, hPos.dy), 3.5, Paint()..color = Colors.black);
      canvas.drawCircle(Offset(hPos.dx + 3, hPos.dy), 3.5, Paint()..color = Colors.black);
      final tPath = Path()
        ..moveTo(hPos.dx - 6, hPos.dy + 1)
        ..lineTo(hPos.dx, hPos.dy + 7)
        ..lineTo(hPos.dx + 6, hPos.dy + 1)
        ..close();
      canvas.drawPath(tPath, Paint()..color = Colors.black);
    } else if (data.faceDecal == 'star_cheek') {
      _drawMiniStar(canvas, Offset(cx - w * 0.18, cy + h * 0.08), 5, Paint()..color = const Color(0xFFFF007A));
    } else if (data.faceDecal == 'freckles') {
      final fPaint = Paint()..color = const Color(0xFF78350F);
      final dots = [
        Offset(cx - 14, cy + h * 0.05),
        Offset(cx - 8, cy + h * 0.04),
        Offset(cx - 16, cy + h * 0.06),
        Offset(cx + 14, cy + h * 0.05),
        Offset(cx + 8, cy + h * 0.04),
        Offset(cx + 16, cy + h * 0.06),
      ];
      for (final d in dots) {
        canvas.drawCircle(d, 2.0, fPaint);
      }
    }
  }

  /// 🧔 Male Facial Hair (Stubble, Mustache, Goatee, Full Beard, Chin Beard, Soul Patch)
  void _renderFacialHair(Canvas canvas, double cx, double cy, double w, double h, Paint ink) {
    final hairP = Paint()..color = data.hairColor;
    if (data.facialHair == 'mustache') {
      final mPath = Path()
        ..moveTo(cx - 18, cy + h * 0.08)
        ..quadraticBezierTo(cx - 9, cy + h * 0.06, cx, cy + h * 0.075)
        ..quadraticBezierTo(cx + 9, cy + h * 0.06, cx + 18, cy + h * 0.08)
        ..quadraticBezierTo(cx + 10, cy + h * 0.09, cx, cy + h * 0.082)
        ..quadraticBezierTo(cx - 10, cy + h * 0.09, cx - 18, cy + h * 0.08)
        ..close();
      canvas.drawPath(mPath, hairP);
      canvas.drawPath(mPath, ink..strokeWidth = 2.0);
    } else if (data.facialHair == 'soul_patch') {
      // Petite triangular soul patch under lip
      final sp = Path()
        ..moveTo(cx - 4, cy + h * 0.11)
        ..lineTo(cx + 4, cy + h * 0.11)
        ..lineTo(cx, cy + h * 0.13)
        ..close();
      canvas.drawPath(sp, hairP);
      canvas.drawPath(sp, ink..strokeWidth = 1.5);
    } else if (data.facialHair == 'full_beard') {
      final fbPath = Path()
        ..moveTo(cx - w * 0.22, cy + h * 0.02)
        ..lineTo(cx - w * 0.20, cy + h * 0.12)
        ..lineTo(cx, cy + h * 0.17)
        ..lineTo(cx + w * 0.20, cy + h * 0.12)
        ..lineTo(cx + w * 0.22, cy + h * 0.02)
        ..lineTo(cx + w * 0.16, cy + h * 0.07)
        ..lineTo(cx, cy + h * 0.10)
        ..lineTo(cx - w * 0.16, cy + h * 0.07)
        ..close();
      canvas.drawPath(fbPath, hairP);
      canvas.drawPath(fbPath, ink..strokeWidth = 3.0);
    } else if (data.facialHair == 'goatee') {
      final gRect = Rect.fromCenter(center: Offset(cx, cy + h * 0.12), width: 14, height: 12);
      canvas.drawRRect(RRect.fromRectAndRadius(gRect, const Radius.circular(4)), hairP);
      canvas.drawRRect(RRect.fromRectAndRadius(gRect, const Radius.circular(4)), ink..strokeWidth = 2.0);
    } else if (data.facialHair == 'stubble') {
      final sPaint = Paint()..color = Colors.black45;
      for (int i = -4; i <= 4; i++) {
        canvas.drawCircle(Offset(cx + i * 5, cy + h * 0.11 + (i.abs() % 2) * 3), 1.5, sPaint);
      }
    } else if (data.facialHair == 'chin_beard') {
      final bPath = Path()
        ..moveTo(cx - w * 0.18, cy + h * 0.06)
        ..lineTo(cx - w * 0.12, cy + h * 0.14)
        ..lineTo(cx + w * 0.12, cy + h * 0.14)
        ..lineTo(cx + w * 0.18, cy + h * 0.06)
        ..lineTo(cx + w * 0.14, cy + h * 0.10)
        ..lineTo(cx, cy + h * 0.12)
        ..lineTo(cx - w * 0.14, cy + h * 0.10)
        ..close();
      canvas.drawPath(bPath, hairP);
      canvas.drawPath(bPath, ink..strokeWidth = 2.5);
    }
  }

  /// 🧢 Beanie Hat Accessory
  void _renderBeanie(Canvas canvas, double cx, double cy, double w, double h, Paint ink) {
    final bPaint = Paint()..color = const Color(0xFFEF4444);
    final beanieRect = Rect.fromCenter(center: Offset(cx, cy + 4), width: w * 0.52, height: h * 0.18);
    canvas.drawRRect(RRect.fromRectAndRadius(beanieRect, const Radius.circular(16)), bPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(beanieRect, const Radius.circular(16)), ink..strokeWidth = 3.5);
    canvas.drawLine(Offset(cx - w * 0.25, cy + 12), Offset(cx + w * 0.25, cy + 12), ink..strokeWidth = 3.0);
  }

  /// 🧢 Baseball Cap Accessory
  void _renderBaseballCap(Canvas canvas, double cx, double cy, double w, double h, Paint ink) {
    final capPaint = Paint()..color = const Color(0xFF1E293B);
    final capRect = Rect.fromCenter(center: Offset(cx, cy + 4), width: w * 0.48, height: h * 0.14);
    canvas.drawOval(capRect, capPaint);
    canvas.drawOval(capRect, ink);
    final visorPath = Path()
      ..moveTo(cx - w * 0.24, cy + 12)
      ..quadraticBezierTo(cx - w * 0.35, cy + 24, cx - w * 0.10, cy + 26)
      ..lineTo(cx + w * 0.20, cy + 12)
      ..close();
    canvas.drawPath(visorPath, Paint()..color = const Color(0xFFFFD54F));
    canvas.drawPath(visorPath, ink);
  }

  /// 🎀 Retro Headband
  void _renderHeadband(Canvas canvas, double cx, double cy, double w, Paint ink) {
    final bandPaint = Paint()
      ..color = const Color(0xFFFF007A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy), width: w * 0.44, height: 60), math.pi, math.pi, false, bandPaint);
    final bandInk = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy), width: w * 0.44, height: 60), math.pi, math.pi, false, bandInk);
  }

  /// 💇 Male vs Female Back Hair Silhouettes
  void _renderBackHair(
    Canvas canvas,
    double cx,
    double cy,
    double w,
    double h,
    Paint hairPaint,
    Paint ink,
  ) {
    if (data.isMale) {
      if (data.hairStyle == 'mohawk') {
        final mohawkPath = Path()
          ..moveTo(cx - w * 0.10, cy - h * 0.10)
          ..lineTo(cx - w * 0.08, cy - h * 0.32)
          ..lineTo(cx, cy - h * 0.35)
          ..lineTo(cx + w * 0.08, cy - h * 0.32)
          ..lineTo(cx + w * 0.10, cy - h * 0.10)
          ..close();
        canvas.drawPath(mohawkPath, hairPaint);
        canvas.drawPath(mohawkPath, ink);
      } else if (data.hairStyle == 'undercut') {
        // High fade undercut with voluminous top sweep
        final ucPath = Path()
          ..moveTo(cx - w * 0.26, cy + h * 0.02)
          ..lineTo(cx - w * 0.30, cy - h * 0.12)
          ..quadraticBezierTo(cx, cy - h * 0.32, cx + w * 0.28, cy - h * 0.16)
          ..lineTo(cx + w * 0.24, cy + h * 0.02)
          ..close();
        canvas.drawPath(ucPath, hairPaint);
        canvas.drawPath(ucPath, ink);
      } else if (data.hairStyle == 'messy_spikes') {
        final spikePath = Path()
          ..moveTo(cx - w * 0.32, cy + h * 0.05)
          ..lineTo(cx - w * 0.36, cy - h * 0.08)
          ..lineTo(cx - w * 0.26, cy - h * 0.14)
          ..lineTo(cx - w * 0.22, cy - h * 0.22)
          ..lineTo(cx - w * 0.08, cy - h * 0.26)
          ..lineTo(cx, cy - h * 0.28)
          ..lineTo(cx + w * 0.10, cy - h * 0.26)
          ..lineTo(cx + w * 0.22, cy - h * 0.22)
          ..lineTo(cx + w * 0.28, cy - h * 0.14)
          ..lineTo(cx + w * 0.36, cy - h * 0.08)
          ..lineTo(cx + w * 0.32, cy + h * 0.05)
          ..lineTo(cx + w * 0.20, cy + h * 0.12)
          ..lineTo(cx - w * 0.20, cy + h * 0.12)
          ..close();
        canvas.drawPath(spikePath, hairPaint);
        canvas.drawPath(spikePath, ink);
      } else if (data.hairStyle == 'pompadour') {
        final pompPath = Path()
          ..moveTo(cx - w * 0.24, cy + h * 0.04)
          ..quadraticBezierTo(cx - w * 0.32, cy - h * 0.18, cx, cy - h * 0.32)
          ..quadraticBezierTo(cx + w * 0.32, cy - h * 0.18, cx + w * 0.24, cy + h * 0.04)
          ..close();
        canvas.drawPath(pompPath, hairPaint);
        canvas.drawPath(pompPath, ink);
      } else if (data.hairStyle == 'buzz_cut') {
        final buzzRect = Rect.fromCenter(center: Offset(cx, cy - h * 0.02), width: w * 0.50, height: h * 0.26);
        canvas.drawRRect(RRect.fromRectAndRadius(buzzRect, Radius.circular(w * 0.25)), hairPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(buzzRect, Radius.circular(w * 0.25)), ink);
      } else if (data.hairStyle == 'dreadlocks') {
        for (int i = 0; i < 7; i++) {
          final lx = cx - w * 0.30 + i * (w * 0.10);
          final locRect = Rect.fromCenter(center: Offset(lx, cy - h * 0.08), width: w * 0.09, height: h * 0.28);
          canvas.drawRRect(RRect.fromRectAndRadius(locRect, const Radius.circular(8)), hairPaint);
          canvas.drawRRect(RRect.fromRectAndRadius(locRect, const Radius.circular(8)), ink);
        }
      } else if (data.hairStyle == 'side_swept') {
        final sweepPath = Path()
          ..moveTo(cx - w * 0.34, cy + h * 0.04)
          ..quadraticBezierTo(cx - w * 0.25, cy - h * 0.26, cx + w * 0.05, cy - h * 0.28)
          ..quadraticBezierTo(cx + w * 0.38, cy - h * 0.22, cx + w * 0.32, cy + h * 0.06)
          ..close();
        canvas.drawPath(sweepPath, hairPaint);
        canvas.drawPath(sweepPath, ink);
      } else {
        final cropRect = Rect.fromCenter(
          center: Offset(cx, cy - h * 0.05),
          width: w * 0.62,
          height: h * 0.36,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(cropRect, Radius.circular(w * 0.28)), hairPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(cropRect, Radius.circular(w * 0.28)), ink);
      }
    } else {
      if (data.hairStyle == 'braids') {
        // Dual long braided pigtails dropping forward
        final leftBraid = Rect.fromCenter(center: Offset(cx - w * 0.28, cy + h * 0.20), width: w * 0.10, height: h * 0.40);
        final rightBraid = Rect.fromCenter(center: Offset(cx + w * 0.28, cy + h * 0.20), width: w * 0.10, height: h * 0.40);
        canvas.drawRRect(RRect.fromRectAndRadius(leftBraid, const Radius.circular(10)), hairPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(leftBraid, const Radius.circular(10)), ink);
        canvas.drawRRect(RRect.fromRectAndRadius(rightBraid, const Radius.circular(10)), hairPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rightBraid, const Radius.circular(10)), ink);
        final hRect = Rect.fromCenter(center: Offset(cx, cy - h * 0.04), width: w * 0.54, height: h * 0.28);
        canvas.drawOval(hRect, hairPaint);
        canvas.drawOval(hRect, ink);
      } else if (data.hairStyle == 'ponytail') {
        final ponyPath = Path()
          ..moveTo(cx + w * 0.20, cy - h * 0.15)
          ..quadraticBezierTo(cx + w * 0.46, cy - h * 0.25, cx + w * 0.40, cy + h * 0.10)
          ..quadraticBezierTo(cx + w * 0.28, cy - h * 0.05, cx + w * 0.20, cy - h * 0.10)
          ..close();
        canvas.drawPath(ponyPath, hairPaint);
        canvas.drawPath(ponyPath, ink);
        final hRect = Rect.fromCenter(center: Offset(cx, cy - h * 0.04), width: w * 0.54, height: h * 0.28);
        canvas.drawOval(hRect, hairPaint);
        canvas.drawOval(hRect, ink);
      } else if (data.hairStyle == 'curly_cloud') {
        const cloudBubbles = 18;
        final radiusX = w * 0.44;
        final radiusY = h * 0.32;
        for (int i = 0; i < cloudBubbles; i++) {
          final angle = (i / cloudBubbles) * math.pi * 1.5 + math.pi * 0.75;
          final px = cx + math.cos(angle) * radiusX;
          final py = cy - h * 0.02 + math.sin(angle) * radiusY;
          canvas.drawCircle(Offset(px, py), w * 0.17, hairPaint);
          canvas.drawCircle(Offset(px, py), w * 0.17, ink);
        }
      } else if (data.hairStyle == 'twin_buns') {
        final leftBun = Offset(cx - w * 0.30, cy - h * 0.20);
        final rightBun = Offset(cx + w * 0.30, cy - h * 0.20);
        canvas.drawCircle(leftBun, w * 0.18, hairPaint);
        canvas.drawCircle(leftBun, w * 0.18, ink);
        canvas.drawCircle(rightBun, w * 0.18, hairPaint);
        canvas.drawCircle(rightBun, w * 0.18, ink);
      } else if (data.hairStyle == 'afro_puffs') {
        final pLeft = Offset(cx - w * 0.32, cy - h * 0.12);
        final pRight = Offset(cx + w * 0.32, cy - h * 0.12);
        canvas.drawCircle(pLeft, w * 0.22, hairPaint);
        canvas.drawCircle(pLeft, w * 0.22, ink);
        canvas.drawCircle(pRight, w * 0.22, hairPaint);
        canvas.drawCircle(pRight, w * 0.22, ink);
      } else {
        final hairPath = Path()
          ..moveTo(cx - w * 0.38, cy - h * 0.10)
          ..quadraticBezierTo(cx - w * 0.44, cy + h * 0.20, cx - w * 0.34, cy + h * 0.44)
          ..quadraticBezierTo(cx - w * 0.20, cy + h * 0.46, cx - w * 0.12, cy + h * 0.36)
          ..lineTo(cx - w * 0.10, cy + h * 0.18)
          ..lineTo(cx + w * 0.10, cy + h * 0.18)
          ..lineTo(cx + w * 0.12, cy + h * 0.36)
          ..quadraticBezierTo(cx + w * 0.20, cy + h * 0.46, cx + w * 0.34, cy + h * 0.44)
          ..quadraticBezierTo(cx + w * 0.44, cy + h * 0.20, cx + w * 0.38, cy - h * 0.10)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        canvas.drawPath(hairPath, ink);

        _renderHairDecals(canvas, cx, cy, w, h, ink);
      }
    }
  }

  /// 🌸 Stickers directly pasted onto hair
  void _renderHairDecals(Canvas canvas, double cx, double cy, double w, double h, Paint ink) {
    final fPos = Offset(cx - w * 0.22, cy + h * 0.25);
    final fillWhite = Paint()..color = Colors.white;
    for (int i = 0; i < 5; i++) {
      final a = (i / 5) * math.pi * 2;
      canvas.drawCircle(Offset(fPos.dx + math.cos(a) * 9, fPos.dy + math.sin(a) * 9), 6, fillWhite);
      canvas.drawCircle(Offset(fPos.dx + math.cos(a) * 9, fPos.dy + math.sin(a) * 9), 6, ink);
    }
    canvas.drawCircle(fPos, 5, Paint()..color = const Color(0xFF81C784));
    canvas.drawCircle(fPos, 5, ink);

    final sq = Rect.fromCenter(center: Offset(cx + w * 0.22, cy + h * 0.22), width: 22, height: 22);
    canvas.drawRRect(RRect.fromRectAndRadius(sq, const Radius.circular(3)), Paint()..color = const Color(0xFF80CBC4));
    canvas.drawRRect(RRect.fromRectAndRadius(sq, const Radius.circular(3)), ink);
    canvas.drawRect(Rect.fromCenter(center: sq.center, width: 8, height: 8), ink);

    final starPos = Offset(cx + w * 0.28, cy + h * 0.32);
    final pStar = Paint()..color = const Color(0xFFBA68C8);
    for (int i = 0; i < 4; i++) {
      final a = (i / 4) * math.pi;
      canvas.drawLine(
        Offset(starPos.dx - math.cos(a) * 10, starPos.dy - math.sin(a) * 10),
        Offset(starPos.dx + math.cos(a) * 10, starPos.dy + math.sin(a) * 10),
        pStar..strokeWidth = 4.5,
      );
      canvas.drawLine(
        Offset(starPos.dx - math.cos(a) * 10, starPos.dy - math.sin(a) * 10),
        Offset(starPos.dx + math.cos(a) * 10, starPos.dy + math.sin(a) * 10),
        ink,
      );
    }
  }

  /// 👗 Pop-Art Clothing & Patterns (Kimono / Streetwear / Polka / Bomber / Turtleneck / Leather / Sport Jersey / Cardigan / Overalls / Sailor)
  void _renderOutfit(Canvas canvas, double cx, double cy, double w, double h, Paint ink) {
    final outfitPaint = Paint()..color = data.outfitColor;

    if (data.outfitStyle == 'striped_sailor') {
      // Horizontal nautical stripes shirt
      final sPath = Path()
        ..moveTo(cx - w * 0.32, h)
        ..lineTo(cx - w * 0.18, cy + h * 0.22)
        ..lineTo(cx + w * 0.18, cy + h * 0.22)
        ..lineTo(cx + w * 0.32, h)
        ..close();
      canvas.drawPath(sPath, Paint()..color = Colors.white);
      canvas.drawPath(sPath, ink);
      // Navy stripes
      final stripeP = Paint()..color = outfitPaint.color..strokeWidth = 6.0;
      for (int i = 1; i <= 4; i++) {
        final sy = cy + h * 0.24 + i * 14;
        canvas.drawLine(Offset(cx - w * 0.22, sy), Offset(cx + w * 0.22, sy), stripeP);
      }
    } else if (data.outfitStyle == 'overalls') {
      // Denim overalls with shoulder straps and gold buckles
      final oPath = Path()
        ..moveTo(cx - w * 0.26, h)
        ..lineTo(cx - w * 0.18, cy + h * 0.28)
        ..lineTo(cx + w * 0.18, cy + h * 0.28)
        ..lineTo(cx + w * 0.26, h)
        ..close();
      canvas.drawPath(oPath, outfitPaint);
      canvas.drawPath(oPath, ink);
      // Straps
      final strapP = Paint()..color = outfitPaint.color..strokeWidth = 10.0;
      canvas.drawLine(Offset(cx - w * 0.12, cy + h * 0.18), Offset(cx - w * 0.12, cy + h * 0.28), strapP);
      canvas.drawLine(Offset(cx - w * 0.12, cy + h * 0.18), Offset(cx - w * 0.12, cy + h * 0.28), ink..strokeWidth = 3.0);
      canvas.drawLine(Offset(cx + w * 0.12, cy + h * 0.18), Offset(cx + w * 0.12, cy + h * 0.28), strapP);
      canvas.drawLine(Offset(cx + w * 0.12, cy + h * 0.18), Offset(cx + w * 0.12, cy + h * 0.28), ink..strokeWidth = 3.0);
      // Golden buckles
      canvas.drawCircle(Offset(cx - w * 0.12, cy + h * 0.28), 4, Paint()..color = const Color(0xFFFFD54F));
      canvas.drawCircle(Offset(cx + w * 0.12, cy + h * 0.28), 4, Paint()..color = const Color(0xFFFFD54F));
    } else if (data.outfitStyle == 'sport_jersey') {
      final jerseyPath = Path()
        ..moveTo(cx - w * 0.26, h)
        ..lineTo(cx - w * 0.16, cy + h * 0.22)
        ..lineTo(cx + w * 0.16, cy + h * 0.22)
        ..lineTo(cx + w * 0.26, h)
        ..close();
      canvas.drawPath(jerseyPath, outfitPaint);
      canvas.drawPath(jerseyPath, ink);
      final numPaint = Paint()..color = Colors.white..strokeWidth = 5.0..strokeCap = StrokeCap.square;
      final numPath = Path()
        ..moveTo(cx - 8, cy + h * 0.32)
        ..lineTo(cx + 8, cy + h * 0.32)
        ..lineTo(cx - 2, cy + h * 0.44);
      canvas.drawPath(numPath, numPaint);
      canvas.drawPath(numPath, ink..strokeWidth = 2.0);
    } else if (data.outfitStyle == 'cardigan') {
      final cardPath = Path()
        ..moveTo(cx - w * 0.36, h)
        ..lineTo(cx - w * 0.20, cy + h * 0.22)
        ..lineTo(cx, cy + h * 0.36)
        ..lineTo(cx + w * 0.20, cy + h * 0.22)
        ..lineTo(cx + w * 0.36, h)
        ..close();
      canvas.drawPath(cardPath, outfitPaint);
      canvas.drawPath(cardPath, ink);
      final inner = Path()
        ..moveTo(cx - w * 0.10, cy + h * 0.22)
        ..lineTo(cx, cy + h * 0.36)
        ..lineTo(cx + w * 0.10, cy + h * 0.22)
        ..close();
      canvas.drawPath(inner, Paint()..color = Colors.white);
      canvas.drawPath(inner, ink);
      canvas.drawCircle(Offset(cx, cy + h * 0.40), 3, ink);
      canvas.drawCircle(Offset(cx, cy + h * 0.46), 3, ink);
    } else if (data.outfitStyle == 'doodle_kimono') {
      final robePath = Path()
        ..moveTo(cx, cy + h * 0.24)
        ..lineTo(cx - w * 0.42, h)
        ..lineTo(cx + w * 0.42, h)
        ..close();
      canvas.drawPath(robePath, outfitPaint);
      canvas.drawPath(robePath, ink);

      final innerPath = Path()
        ..moveTo(cx - w * 0.08, cy + h * 0.26)
        ..lineTo(cx, cy + h * 0.38)
        ..lineTo(cx + w * 0.08, cy + h * 0.26)
        ..lineTo(cx + w * 0.08, cy + h * 0.38)
        ..lineTo(cx - w * 0.08, cy + h * 0.38)
        ..close();
      canvas.drawPath(innerPath, Paint()..color = const Color(0xFF1E1B18));
      canvas.drawPath(innerPath, ink);

      final dotColors = [const Color(0xFFFF4081), const Color(0xFFFFD54F), const Color(0xFF64B5F6), Colors.white];
      for (int i = 0; i < 6; i++) {
        final dx = cx - w * 0.05 + (i % 3) * (w * 0.04);
        final dy = cy + h * 0.28 + (i ~/ 3) * (h * 0.04);
        canvas.drawCircle(Offset(dx, dy), 3, Paint()..color = dotColors[i % dotColors.length]);
      }

      final pCloud = Rect.fromCenter(center: Offset(cx - w * 0.16, cy + h * 0.34), width: 26, height: 18);
      canvas.drawRRect(RRect.fromRectAndRadius(pCloud, const Radius.circular(8)), Paint()..color = const Color(0xFF81D4FA));
      canvas.drawRRect(RRect.fromRectAndRadius(pCloud, const Radius.circular(8)), ink);

      final pHeart = Offset(cx + w * 0.12, cy + h * 0.42);
      canvas.drawCircle(pHeart, 12, Paint()..color = const Color(0xFFF06292));
      canvas.drawCircle(pHeart, 12, ink);

      final pGhost = Offset(cx + w * 0.25, cy + h * 0.46);
      canvas.drawCircle(pGhost, 16, Paint()..color = const Color(0xFFBA68C8));
      canvas.drawCircle(pGhost, 16, ink);
    } else if (data.outfitStyle == 'turtleneck') {
      final tPath = Path()
        ..moveTo(cx - w * 0.24, h)
        ..lineTo(cx - w * 0.14, cy + h * 0.18)
        ..lineTo(cx + w * 0.14, cy + h * 0.18)
        ..lineTo(cx + w * 0.24, h)
        ..close();
      canvas.drawPath(tPath, outfitPaint);
      canvas.drawPath(tPath, ink);
      for (int i = 1; i <= 3; i++) {
        canvas.drawLine(
          Offset(cx - w * 0.09, cy + h * 0.13 + i * 5),
          Offset(cx + w * 0.09, cy + h * 0.13 + i * 5),
          ink..strokeWidth = 2.0,
        );
      }
    } else if (data.outfitStyle == 'bomber_jacket' || data.outfitStyle == 'leather_jacket' || data.outfitStyle == 'hoodie') {
      final jacketPath = Path()
        ..moveTo(cx - w * 0.38, h)
        ..lineTo(cx - w * 0.22, cy + h * 0.24)
        ..lineTo(cx + w * 0.22, cy + h * 0.24)
        ..lineTo(cx + w * 0.38, h)
        ..close();
      canvas.drawPath(jacketPath, outfitPaint);
      canvas.drawPath(jacketPath, ink);
      canvas.drawLine(Offset(cx, cy + h * 0.24), Offset(cx, h), ink..strokeWidth = 4.0);
      final collarPath = Path()
        ..moveTo(cx - w * 0.14, cy + h * 0.24)
        ..quadraticBezierTo(cx, cy + h * 0.30, cx + w * 0.14, cy + h * 0.24);
      canvas.drawPath(collarPath, Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.stroke..strokeWidth = 6);
      canvas.drawPath(collarPath, ink);
    } else {
      final dressPath = Path()
        ..moveTo(cx - w * 0.16, cy + h * 0.26)
        ..lineTo(cx - w * 0.18, h)
        ..lineTo(cx + w * 0.18, h)
        ..lineTo(cx + w * 0.16, cy + h * 0.26)
        ..close();
      canvas.drawPath(dressPath, outfitPaint);
      canvas.drawPath(dressPath, ink);

      final dots = [
        Offset(cx - 0.08 * w, cy + h * 0.32),
        Offset(cx + 0.06 * w, cy + h * 0.34),
        Offset(cx - 0.04 * w, cy + h * 0.42),
        Offset(cx + 0.08 * w, cy + h * 0.44),
        Offset(cx, cy + h * 0.37),
      ];
      final colors = [const Color(0xFFFF4081), const Color(0xFFFFB74D), const Color(0xFFBA68C8), const Color(0xFFFFD54F)];
      for (int i = 0; i < dots.length; i++) {
        canvas.drawCircle(dots[i], 6, Paint()..color = colors[i % colors.length]);
        canvas.drawCircle(dots[i], 6, ink);
      }
    }
  }

  /// 👂 Giant Cartoon Pop-Art Ears with inner shadows
  void _renderBigEars(Canvas canvas, double cx, double cy, double w, double h, Paint skin, Paint ink) {
    final earLeft = Rect.fromCenter(center: Offset(cx - w * 0.28, cy), width: w * 0.18, height: h * 0.16);
    final earRight = Rect.fromCenter(center: Offset(cx + w * 0.28, cy), width: w * 0.18, height: h * 0.16);

    canvas.drawOval(earLeft, skin);
    canvas.drawOval(earLeft, ink);
    final earShadow = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.6);
    canvas.drawOval(Rect.fromCenter(center: earLeft.center, width: w * 0.10, height: h * 0.10), earShadow);
    final innerCrease = Path()
      ..moveTo(earLeft.center.dx + 4, earLeft.center.dy - 6)
      ..lineTo(earLeft.center.dx - 4, earLeft.center.dy)
      ..lineTo(earLeft.center.dx + 2, earLeft.center.dy + 6);
    canvas.drawPath(innerCrease, ink);

    canvas.drawOval(earRight, skin);
    canvas.drawOval(earRight, ink);
    canvas.drawOval(Rect.fromCenter(center: earRight.center, width: w * 0.10, height: h * 0.10), earShadow);
    final innerCreaseR = Path()
      ..moveTo(earRight.center.dx - 4, earRight.center.dy - 6)
      ..lineTo(earRight.center.dx + 4, earRight.center.dy)
      ..lineTo(earRight.center.dx - 2, earRight.center.dy + 6);
    canvas.drawPath(innerCreaseR, ink);
  }

  /// 🌟 Bold Neo-Pop Earrings
  void _renderEarrings(Canvas canvas, double cx, double cy, double w, double h, Paint ink) {
    if (data.earringStyle == 'star') {
      final leftStar = Offset(cx - w * 0.32, cy + h * 0.10);
      final rightStar = Offset(cx + w * 0.32, cy + h * 0.10);
      _drawStarEarring(canvas, leftStar, w * 0.10, const Color(0xFFFFD54F), ink);
      _drawStarEarring(canvas, rightStar, w * 0.10, const Color(0xFFFFD54F), ink);
    } else if (data.earringStyle == 'cross') {
      final cP = Offset(cx - w * 0.32, cy + h * 0.12);
      final crossP = Paint()..color = Colors.white..strokeWidth = 3.5;
      canvas.drawLine(Offset(cP.dx, cP.dy - 10), Offset(cP.dx, cP.dy + 12), crossP);
      canvas.drawLine(Offset(cP.dx - 6, cP.dy - 3), Offset(cP.dx + 6, cP.dy - 3), crossP);
      canvas.drawLine(Offset(cP.dx, cP.dy - 10), Offset(cP.dx, cP.dy + 12), ink..strokeWidth = 1.5);
    } else if (data.earringStyle == 'double_rings') {
      // Interlocking punk hoops
      final hP = Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.stroke..strokeWidth = 3.0;
      canvas.drawCircle(Offset(cx - w * 0.30, cy + h * 0.08), 8, hP);
      canvas.drawCircle(Offset(cx - w * 0.30, cy + h * 0.12), 8, hP);
    } else if (data.earringStyle == 'rect') {
      final lRect = Rect.fromLTWH(cx - w * 0.35, cy + h * 0.05, w * 0.09, h * 0.08);
      final rRect = Rect.fromLTWH(cx + w * 0.26, cy + h * 0.05, w * 0.09, h * 0.08);
      final gold = Paint()..color = const Color(0xFFFFD54F);
      canvas.drawRRect(RRect.fromRectAndRadius(lRect, const Radius.circular(3)), gold);
      canvas.drawRRect(RRect.fromRectAndRadius(lRect, const Radius.circular(3)), ink);
      canvas.drawRRect(RRect.fromRectAndRadius(rRect, const Radius.circular(3)), gold);
      canvas.drawRRect(RRect.fromRectAndRadius(rRect, const Radius.circular(3)), ink);
    } else if (data.earringStyle == 'hoop') {
      final hoopPaint = Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.8;
      canvas.drawCircle(Offset(cx - w * 0.30, cy + h * 0.10), 12, hoopPaint);
      canvas.drawCircle(Offset(cx - w * 0.30, cy + h * 0.10), 12, ink);
      if (!data.isMale) {
        canvas.drawCircle(Offset(cx + w * 0.30, cy + h * 0.10), 12, hoopPaint);
        canvas.drawCircle(Offset(cx + w * 0.30, cy + h * 0.10), 12, ink);
      }
    } else if (data.earringStyle == 'stud') {
      final studPaint = Paint()..color = const Color(0xFF00E5FF);
      canvas.drawCircle(Offset(cx - w * 0.28, cy + h * 0.06), 5, studPaint);
      canvas.drawCircle(Offset(cx - w * 0.28, cy + h * 0.06), 5, ink);
    }
  }

  void _drawStarEarring(Canvas canvas, Offset center, double size, Color color, Paint ink) {
    final path = Path();
    const points = 8;
    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? size : size * 0.45;
      final a = (i / (points * 2)) * math.pi * 2;
      final px = center.dx + math.cos(a) * r;
      final py = center.dy + math.sin(a) * r;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(path, ink);
  }

  /// 👓 Rich Diverse Eyewear (Round Glasses, Square Sunglasses, Cyclops Visor, Heart Glasses, Aviator, or Naked Eyes with Bold Eyebrows)
  void _renderEyesAndGlasses(Canvas canvas, double cx, double cy, double w, double h, Paint ink) {
    final eyeSpacing = w * 0.13;
    final eyeRadius = w * 0.105;

    final leftCenter = Offset(cx - eyeSpacing, cy);
    final rightCenter = Offset(cx + eyeSpacing, cy);

    if (data.eyewear == 'heart_glasses') {
      // 💖 Retro Pop Lolita Heart Eyeglasses
      final hFill = Paint()..color = const Color(0xFFFF007A).withValues(alpha: 0.7);
      _drawHeartLens(canvas, leftCenter, eyeRadius * 1.3, hFill, ink);
      _drawHeartLens(canvas, rightCenter, eyeRadius * 1.3, hFill, ink);
      canvas.drawLine(Offset(leftCenter.dx + eyeRadius * 0.9, cy), Offset(rightCenter.dx - eyeRadius * 0.9, cy), ink..strokeWidth = 3.5);
      return;
    }

    if (data.eyewear == 'cyclops_visor') {
      final visorRect = Rect.fromCenter(center: Offset(cx, cy), width: w * 0.54, height: 26);
      final visorPaint = Paint()..color = const Color(0xFFFF007A);
      canvas.drawRRect(RRect.fromRectAndRadius(visorRect, const Radius.circular(8)), visorPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(visorRect, const Radius.circular(8)), ink..strokeWidth = 4.0);
      canvas.drawLine(Offset(visorRect.left + 8, cy), Offset(visorRect.right - 8, cy), Paint()..color = const Color(0xFF00E5FF)..strokeWidth = 4.0);
      return;
    }

    final isShades = data.eyewear == 'square_shades' || data.eyewear == 'tinted_aviator';
    final lensFill = Paint()..color = isShades ? const Color(0xFF1E293B) : Colors.white;

    if (data.eyewear == 'square_shades') {
      final leftRect = Rect.fromCenter(center: leftCenter, width: eyeRadius * 2.3, height: eyeRadius * 1.8);
      final rightRect = Rect.fromCenter(center: rightCenter, width: eyeRadius * 2.3, height: eyeRadius * 1.8);
      canvas.drawRRect(RRect.fromRectAndRadius(leftRect, const Radius.circular(5)), lensFill);
      canvas.drawRRect(RRect.fromRectAndRadius(rightRect, const Radius.circular(5)), lensFill);

      final reflPaint = Paint()..color = Colors.white54..strokeWidth = 2.5;
      canvas.drawLine(Offset(leftRect.left + 5, leftRect.bottom - 5), Offset(leftRect.center.dx, leftRect.top + 5), reflPaint);
      canvas.drawLine(Offset(rightRect.left + 5, rightRect.bottom - 5), Offset(rightRect.center.dx, rightRect.top + 5), reflPaint);

      final framePaint = Paint()..color = const Color(0xFF00E5FF)..style = PaintingStyle.stroke..strokeWidth = 5.0;
      canvas.drawRRect(RRect.fromRectAndRadius(leftRect, const Radius.circular(5)), framePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(leftRect, const Radius.circular(5)), ink);
      canvas.drawRRect(RRect.fromRectAndRadius(rightRect, const Radius.circular(5)), framePaint);
      canvas.drawRRect(RRect.fromRectAndRadius(rightRect, const Radius.circular(5)), ink);

      canvas.drawLine(Offset(leftRect.right, cy), Offset(rightRect.left, cy), ink..strokeWidth = 4.5);
      return;
    }

    if (data.eyewear == 'tinted_aviator') {
      final leftPath = Path()..addOval(Rect.fromCenter(center: leftCenter, width: eyeRadius * 2.2, height: eyeRadius * 2.2));
      final rightPath = Path()..addOval(Rect.fromCenter(center: rightCenter, width: eyeRadius * 2.2, height: eyeRadius * 2.2));
      canvas.drawPath(leftPath, Paint()..color = const Color(0xFFFFB300).withValues(alpha: 0.6));
      canvas.drawPath(rightPath, Paint()..color = const Color(0xFFFFB300).withValues(alpha: 0.6));
      final goldRim = Paint()..color = const Color(0xFFFFD54F)..style = PaintingStyle.stroke..strokeWidth = 4.0;
      canvas.drawPath(leftPath, goldRim);
      canvas.drawPath(leftPath, ink);
      canvas.drawPath(rightPath, goldRim);
      canvas.drawPath(rightPath, ink);
      canvas.drawLine(Offset(leftCenter.dx - 10, cy - eyeRadius), Offset(rightCenter.dx + 10, cy - eyeRadius), ink..strokeWidth = 3.5);
      canvas.drawLine(Offset(leftCenter.dx + eyeRadius * 0.8, cy), Offset(rightCenter.dx - eyeRadius * 0.8, cy), ink..strokeWidth = 3.0);
    } else if (data.eyewear != 'none') {
      canvas.drawCircle(leftCenter, eyeRadius, lensFill);
      canvas.drawCircle(rightCenter, eyeRadius, lensFill);
    }

    // Pupils
    if (data.expression == 'sassy_wink') {
      final pupilPaint = Paint()..color = const Color(0xFF1E1B18);
      canvas.drawCircle(leftCenter, eyeRadius * 0.85, pupilPaint);
      _drawMiniStar(canvas, leftCenter, 6, Paint()..color = const Color(0xFFFFB74D));

      final winkPath = Path()
        ..moveTo(rightCenter.dx - eyeRadius, rightCenter.dy)
        ..quadraticBezierTo(rightCenter.dx, rightCenter.dy + 8, rightCenter.dx + eyeRadius, rightCenter.dy);
      canvas.drawPath(winkPath, ink..strokeWidth = 4.5);
    } else if (data.eyeStyle == 'star_eyes') {
      final pupilPaint = Paint()..color = const Color(0xFF1E1B18);
      canvas.drawCircle(leftCenter, eyeRadius * 0.85, pupilPaint);
      canvas.drawCircle(rightCenter, eyeRadius * 0.85, pupilPaint);
      final starColor = Paint()..color = const Color(0xFFFFB74D);
      _drawMiniStar(canvas, leftCenter, 6, starColor);
      _drawMiniStar(canvas, rightCenter, 6, starColor);
    } else if (data.eyeStyle == 'swirl_eyes') {
      final pupilPaint = Paint()..color = const Color(0xFF1E1B18);
      canvas.drawCircle(leftCenter, eyeRadius * 0.82, pupilPaint);
      canvas.drawCircle(rightCenter, eyeRadius * 0.82, pupilPaint);
      final swirlInk = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2.2..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: leftCenter, radius: 10), 0, 4.8, false, swirlInk);
      canvas.drawArc(Rect.fromCircle(center: rightCenter, radius: 10), 0, 4.8, false, swirlInk);
    } else if (data.eyeStyle == 'chill_half') {
      final pupilPaint = Paint()..color = const Color(0xFF1E1B18);
      canvas.drawCircle(leftCenter, eyeRadius * 0.75, pupilPaint);
      canvas.drawCircle(rightCenter, eyeRadius * 0.75, pupilPaint);
      final lidPaint = Paint()..color = data.skinColor;
      canvas.drawRect(Rect.fromLTWH(leftCenter.dx - eyeRadius, leftCenter.dy - eyeRadius, eyeRadius * 2, eyeRadius), lidPaint);
      canvas.drawRect(Rect.fromLTWH(rightCenter.dx - eyeRadius, rightCenter.dy - eyeRadius, eyeRadius * 2, eyeRadius), lidPaint);
      canvas.drawLine(Offset(leftCenter.dx - eyeRadius, leftCenter.dy), Offset(leftCenter.dx + eyeRadius, leftCenter.dy), ink..strokeWidth = 4.0);
      canvas.drawLine(Offset(rightCenter.dx - eyeRadius, rightCenter.dy), Offset(rightCenter.dx + eyeRadius, rightCenter.dy), ink..strokeWidth = 4.0);
    } else {
      final pupilPaint = Paint()..color = const Color(0xFF1E1B18);
      canvas.drawCircle(leftCenter, eyeRadius * 0.70, pupilPaint);
      canvas.drawCircle(rightCenter, eyeRadius * 0.70, pupilPaint);
      final whiteGlint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(leftCenter.dx - 3, leftCenter.dy - 3), 3.5, whiteGlint);
      canvas.drawCircle(Offset(rightCenter.dx - 3, rightCenter.dy - 3), 3.5, whiteGlint);
    }

    if (data.eyewear == 'round_glasses') {
      final frameInk = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 5.2;
      canvas.drawCircle(leftCenter, eyeRadius, frameInk);
      canvas.drawCircle(rightCenter, eyeRadius, frameInk);
      final bridgePath = Path()
        ..moveTo(leftCenter.dx + eyeRadius - 1, cy)
        ..quadraticBezierTo(cx, cy - 5, rightCenter.dx - eyeRadius + 1, cy);
      canvas.drawPath(bridgePath, frameInk);
    } else if (data.eyewear == 'none') {
      final browPaint = Paint()..color = data.hairColor..strokeWidth = 5.5..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(leftCenter.dx - eyeRadius, cy - eyeRadius * 1.1), Offset(leftCenter.dx + eyeRadius, cy - eyeRadius * 1.2), browPaint);
      canvas.drawLine(Offset(leftCenter.dx - eyeRadius, cy - eyeRadius * 1.1), Offset(leftCenter.dx + eyeRadius, cy - eyeRadius * 1.2), ink..strokeWidth = 2.0);
      canvas.drawLine(Offset(rightCenter.dx - eyeRadius, cy - eyeRadius * 1.2), Offset(rightCenter.dx + eyeRadius, cy - eyeRadius * 1.1), browPaint);
      canvas.drawLine(Offset(rightCenter.dx - eyeRadius, cy - eyeRadius * 1.2), Offset(rightCenter.dx + eyeRadius, cy - eyeRadius * 1.1), ink..strokeWidth = 2.0);
    }

    final lash = Paint()..color = Colors.black..strokeWidth = 3.2..strokeCap = StrokeCap.round;
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(Offset(leftCenter.dx + i * 8, leftCenter.dy + eyeRadius + 2), Offset(leftCenter.dx + i * 8, leftCenter.dy + eyeRadius + 8), lash);
      canvas.drawLine(Offset(rightCenter.dx + i * 8, rightCenter.dy + eyeRadius + 2), Offset(rightCenter.dx + i * 8, rightCenter.dy + eyeRadius + 8), lash);
    }
  }

  void _drawHeartLens(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.45);
    path.cubicTo(
      center.dx - size * 0.7, center.dy - size * 0.2,
      center.dx - size * 0.7, center.dy - size * 0.7,
      center.dx, center.dy - size * 0.35,
    );
    path.cubicTo(
      center.dx + size * 0.7, center.dy - size * 0.7,
      center.dx + size * 0.7, center.dy - size * 0.2,
      center.dx, center.dy + size * 0.45,
    );
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke..strokeWidth = 4.0);
  }

  void _drawMiniStar(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final rad = (i % 2 == 0) ? r : r * 0.45;
      final a = (i / 10) * math.pi * 2;
      final px = c.dx + math.cos(a) * rad;
      final py = c.dy + math.sin(a) * rad;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, p);
  }

  /// 👄 Nose & Diverse Expressions (Chill, Smile, Smirk, Open Mouth, Whistle, Grimace)
  void _renderNoseAndMouth(Canvas canvas, double cx, double cy, double w, double h, Paint ink) {
    if (data.isMale || data.faceShape == 'chiseled_square') {
      final noseP = Path()
        ..moveTo(cx, cy + h * 0.02)
        ..lineTo(cx + 4, cy + h * 0.06)
        ..lineTo(cx - 3, cy + h * 0.06);
      canvas.drawPath(noseP, ink..strokeWidth = 3.0);
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + h * 0.05), width: 7, height: 5),
        ink,
      );
    }

    final mouthY = cy + h * 0.095;
    if (data.expression == 'smile') {
      final smilePath = Path()
        ..moveTo(cx - 12, mouthY)
        ..quadraticBezierTo(cx, mouthY + 10, cx + 12, mouthY)
        ..close();
      canvas.drawPath(smilePath, Paint()..color = const Color(0xFFE11D48));
      canvas.drawPath(smilePath, ink..strokeWidth = 3.0);
      canvas.drawLine(Offset(cx - 10, mouthY + 3), Offset(cx + 10, mouthY + 3), Paint()..color = Colors.white..strokeWidth = 3.0);
    } else if (data.expression == 'whistle') {
      // Cute round puckered whistling mouth
      canvas.drawCircle(Offset(cx + 2, mouthY + 2), 5.5, Paint()..color = const Color(0xFFE11D48));
      canvas.drawCircle(Offset(cx + 2, mouthY + 2), 5.5, ink..strokeWidth = 2.5);
      canvas.drawCircle(Offset(cx + 2, mouthY + 2), 2.5, Paint()..color = Colors.black);
    } else if (data.expression == 'smirk') {
      final smirkPath = Path()
        ..moveTo(cx - 8, mouthY)
        ..quadraticBezierTo(cx + 2, mouthY + 2, cx + 11, mouthY - 4);
      canvas.drawPath(smirkPath, ink..strokeWidth = 3.5);
    } else if (data.expression == 'grimace') {
      final gRect = Rect.fromCenter(center: Offset(cx, mouthY + 2), width: 22, height: 8);
      canvas.drawRRect(RRect.fromRectAndRadius(gRect, const Radius.circular(2)), Paint()..color = Colors.white);
      canvas.drawRRect(RRect.fromRectAndRadius(gRect, const Radius.circular(2)), ink..strokeWidth = 2.5);
      for (int i = -2; i <= 2; i++) {
        canvas.drawLine(Offset(cx + i * 4, gRect.top), Offset(cx + i * 4, gRect.bottom), ink..strokeWidth = 1.5);
      }
    } else if (data.expression == 'open_mouth') {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, mouthY + 2), width: 14, height: 12), Paint()..color = const Color(0xFF881337));
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, mouthY + 2), width: 14, height: 12), ink..strokeWidth = 3.0);
    } else {
      final mouthPath = Path()
        ..moveTo(cx - 8, mouthY)
        ..lineTo(cx + 8, mouthY);
      canvas.drawPath(mouthPath, ink);
    }
  }

  /// 💇 Bangs dropping over forehead & Colorful Pop Hairclips
  void _renderFrontHairAndClips(Canvas canvas, double cx, double cy, double w, double h, Paint hair, Paint ink) {
    if (data.isMale) {
      if (data.hairStyle == 'buzz_cut' || data.headAccessory == 'beanie' || data.hairStyle == 'mohawk' || data.headAccessory == 'bucket_hat') return;
      final fringePath = Path()
        ..moveTo(cx - w * 0.22, cy - h * 0.08)
        ..lineTo(cx - w * 0.12, cy - h * 0.03)
        ..lineTo(cx - w * 0.06, cy - h * 0.07)
        ..lineTo(cx + w * 0.04, cy - h * 0.02)
        ..lineTo(cx + w * 0.12, cy - h * 0.07)
        ..lineTo(cx + w * 0.22, cy - h * 0.08)
        ..close();
      canvas.drawPath(fringePath, hair);
      canvas.drawPath(fringePath, ink);
    } else {
      final bangsPath = Path()
        ..moveTo(cx - w * 0.24, cy - h * 0.10)
        ..lineTo(cx - w * 0.16, cy - h * 0.03)
        ..lineTo(cx - w * 0.10, cy - h * 0.08)
        ..lineTo(cx - w * 0.02, cy - h * 0.02)
        ..lineTo(cx + w * 0.06, cy - h * 0.08)
        ..lineTo(cx + w * 0.14, cy - h * 0.03)
        ..lineTo(cx + w * 0.24, cy - h * 0.10)
        ..close();
      canvas.drawPath(bangsPath, hair);
      canvas.drawPath(bangsPath, ink);

      if (data.headAccessory == 'hairclips') {
        final clip1 = Rect.fromLTWH(cx - w * 0.14, cy - h * 0.14, 18, 10);
        final clip2 = Rect.fromLTWH(cx + w * 0.08, cy - h * 0.14, 20, 11);
        final pPurple = Paint()..color = const Color(0xFFBA68C8);
        final pPink = Paint()..color = const Color(0xFFFF4081);

        canvas.drawRRect(RRect.fromRectAndRadius(clip1, const Radius.circular(4)), pPurple);
        canvas.drawRRect(RRect.fromRectAndRadius(clip1, const Radius.circular(4)), ink);
        canvas.drawRRect(RRect.fromRectAndRadius(clip2, const Radius.circular(4)), pPink);
        canvas.drawRRect(RRect.fromRectAndRadius(clip2, const Radius.circular(4)), ink);
      }
    }
  }

  /// 👑 Royal Neo-Pop Crown
  void _renderGoldenCrown(Canvas canvas, double cx, double cy, double w, Paint ink) {
    final gold = Paint()..color = const Color(0xFFFFD54F);
    final crownPath = Path()
      ..moveTo(cx - w * 0.18, cy + 12)
      ..lineTo(cx - w * 0.22, cy - 20)
      ..lineTo(cx - w * 0.09, cy - 6)
      ..lineTo(cx, cy - 28)
      ..lineTo(cx + w * 0.09, cy - 6)
      ..lineTo(cx + w * 0.22, cy - 20)
      ..lineTo(cx + w * 0.18, cy + 12)
      ..close();
    canvas.drawPath(crownPath, gold);
    canvas.drawPath(crownPath, ink);
  }

  /// 😇 Angel Halo
  void _renderAngelHalo(Canvas canvas, double cx, double cy, double w, Paint ink) {
    final haloPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: w * 0.42, height: 16), haloPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: w * 0.42, height: 16), ink);
  }
}

/// 🎨 High-Performance Flutter CustomPainter for PopArt Avatar Cards (Zero GPU overhead!)
class PopArtCardCustomPainter extends CustomPainter {
  final PopArtAvatarCardData data;
  late final PopArtCardFlameGame _renderer;

  PopArtCardCustomPainter({required this.data}) {
    _renderer = PopArtCardFlameGame(data: data);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    _renderer.renderPopArtCard(canvas, size.width, size.height);
  }

  @override
  bool shouldRepaint(covariant PopArtCardCustomPainter oldDelegate) {
    return oldDelegate.data.id != data.id || oldDelegate.data.isMale != data.isMale;
  }
}
