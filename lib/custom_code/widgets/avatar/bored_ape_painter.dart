import 'dart:math';
import 'package:flutter/material.dart';

class BoredApeTraits {
  final String furColor; // 'brown', 'leopard', 'gold', 'cyber_grey', 'zombie_green', 'obsidian'
  final String eyes; // 'laser_beams', 'cyborg_red', '3d_glasses', 'vr_visor', 'x_eyes', 'sleepy', 'normal'
  final String mouth; // 'wide_grin', 'tongue_out', 'cigarette', 'pout', 'closed'
  final String headwear; // 'sailor_hat', 'captain_hat', 'gold_crown', 'beanie', 'none'
  final String outfit; // 'military_jacket', 'cyber_armor', 'king_robe', 'tuxedo', 'naked'
  final String background; // 'orange', 'teal', 'cyan', 'purple', 'amber', 'dark'
  final bool hasEarring;

  const BoredApeTraits({
    this.furColor = 'brown',
    this.eyes = 'laser_beams',
    this.mouth = 'wide_grin',
    this.headwear = 'none',
    this.outfit = 'military_jacket',
    this.background = 'orange',
    this.hasEarring = true,
  });

  static Color getBackgroundColor(String bg) {
    switch (bg) {
      case 'orange':
        return const Color(0xFFE58E26);
      case 'teal':
        return const Color(0xFF00B894);
      case 'cyan':
        return const Color(0xFF00CEC9);
      case 'purple':
        return const Color(0xFF6C5CE7);
      case 'amber':
        return const Color(0xFFF39C12);
      case 'dark':
        return const Color(0xFF1E202E);
      default:
        return const Color(0xFFE58E26);
    }
  }

  static Color getFurColor(String fur) {
    switch (fur) {
      case 'brown':
        return const Color(0xFF8D5524);
      case 'leopard':
        return const Color(0xFFE4A444);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'cyber_grey':
        return const Color(0xFF7F8C8D);
      case 'zombie_green':
        return const Color(0xFF55EFC4);
      case 'obsidian':
        return const Color(0xFF2D3436);
      default:
        return const Color(0xFF8D5524);
    }
  }
}

class BoredApePainter extends CustomPainter {
  final BoredApeTraits traits;

  BoredApePainter({required this.traits});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = w / 300.0; // scale factor based on 300x300 canvas

    // 1. Background
    final bgPaint = Paint()..color = BoredApeTraits.getBackgroundColor(traits.background);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final furPaint = Paint()..color = BoredApeTraits.getFurColor(traits.furColor);
    final muzzleColor = const Color(0xFFC68642);
    final muzzlePaint = Paint()..color = muzzleColor;
    final blackOutline = Paint()
      ..color = const Color(0xFF1E1B18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final linePaint = Paint()
      ..color = const Color(0xFF1E1B18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * s
      ..strokeCap = StrokeCap.round;

    // 2. Neck & Cyber Body / Outfit
    _drawBodyAndNeck(canvas, s, w, h, furPaint, blackOutline);

    // 3. Ears
    _drawEars(canvas, s, furPaint, muzzlePaint, blackOutline);

    // 4. Head Silhouette & Fur
    _drawHead(canvas, s, furPaint, blackOutline);

    // 5. Leopard Spots (if leopard fur)
    if (traits.furColor == 'leopard') {
      _drawLeopardSpots(canvas, s);
    }

    // 6. Muzzle / Mouth Area
    _drawMuzzleAndMouth(canvas, s, muzzlePaint, blackOutline, linePaint);

    // 7. Eyes & Laser Beams / Visors
    _drawEyes(canvas, s, blackOutline, linePaint);

    // 8. Headwear
    _drawHeadwear(canvas, s, blackOutline, linePaint);
  }

  void _drawBodyAndNeck(Canvas canvas, double s, double w, double h, Paint furPaint, Paint outline) {
    final neckPath = Path()
      ..moveTo(100 * s, 170 * s)
      ..lineTo(70 * s, 300 * s)
      ..lineTo(230 * s, 300 * s)
      ..lineTo(200 * s, 170 * s)
      ..close();

    if (traits.outfit == 'cyber_armor') {
      // Cybernetic armor neck (Like Ape 1, Ape 3, Ape 6 in screenshot)
      final cyberPaint = Paint()..color = const Color(0xFF2C3E50);
      canvas.drawPath(neckPath, cyberPaint);
      canvas.drawPath(neckPath, outline);

      // Cyber plate lines
      final plateLine = Paint()
        ..color = const Color(0xFF1A252F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * s;
      canvas.drawLine(Offset(100 * s, 200 * s), Offset(200 * s, 200 * s), plateLine);
      canvas.drawLine(Offset(85 * s, 240 * s), Offset(215 * s, 240 * s), plateLine);
      canvas.drawLine(Offset(75 * s, 275 * s), Offset(225 * s, 275 * s), plateLine);

      final chestPlate = Path()
        ..moveTo(125 * s, 200 * s)
        ..lineTo(150 * s, 280 * s)
        ..lineTo(175 * s, 200 * s);
      canvas.drawPath(chestPlate, plateLine);
    } else if (traits.outfit == 'military_jacket') {
      // Military army jacket (Like Ape 1 in screenshot)
      canvas.drawPath(neckPath, furPaint);
      canvas.drawPath(neckPath, outline);

      final jacketPaint = Paint()..color = const Color(0xFF3F5A36);
      final jacketPath = Path()
        ..moveTo(60 * s, 225 * s)
        ..lineTo(150 * s, 255 * s)
        ..lineTo(240 * s, 225 * s)
        ..lineTo(250 * s, 300 * s)
        ..lineTo(50 * s, 300 * s)
        ..close();
      canvas.drawPath(jacketPath, jacketPaint);
      canvas.drawPath(jacketPath, outline);

      // Collar
      final collarPath = Path()
        ..moveTo(90 * s, 225 * s)
        ..lineTo(150 * s, 270 * s)
        ..lineTo(210 * s, 225 * s);
      canvas.drawPath(collarPath, outline);

      // Rank badge
      final badgePaint = Paint()..color = const Color(0xFFF1C40F);
      canvas.drawRect(Rect.fromLTWH(80 * s, 250 * s, 16 * s, 10 * s), badgePaint);
    } else {
      // Natural / Naked Fur Neck
      canvas.drawPath(neckPath, furPaint);
      canvas.drawPath(neckPath, outline);
    }
  }

  void _drawEars(Canvas canvas, double s, Paint furPaint, Paint innerPaint, Paint outline) {
    // Left Ear
    final leftEar = Path()
      ..addOval(Rect.fromCenter(center: Offset(75 * s, 120 * s), width: 44 * s, height: 52 * s));
    canvas.drawPath(leftEar, furPaint);
    canvas.drawPath(leftEar, outline);
    final innerLeft = Path()
      ..addOval(Rect.fromCenter(center: Offset(75 * s, 120 * s), width: 26 * s, height: 34 * s));
    canvas.drawPath(innerLeft, innerPaint);
    canvas.drawPath(innerLeft, outline);

    // Right Ear
    final rightEar = Path()
      ..addOval(Rect.fromCenter(center: Offset(225 * s, 120 * s), width: 44 * s, height: 52 * s));
    canvas.drawPath(rightEar, furPaint);
    canvas.drawPath(rightEar, outline);
    final innerRight = Path()
      ..addOval(Rect.fromCenter(center: Offset(225 * s, 120 * s), width: 26 * s, height: 34 * s));
    canvas.drawPath(innerRight, innerPaint);
    canvas.drawPath(innerRight, outline);

    // Gold Earring (like Ape 2, Ape 6 in screenshot)
    if (traits.hasEarring) {
      final ringPaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * s;
      canvas.drawCircle(Offset(60 * s, 135 * s), 6 * s, ringPaint);
    }
  }

  void _drawHead(Canvas canvas, double s, Paint furPaint, Paint outline) {
    final headPath = Path()
      ..moveTo(95 * s, 140 * s)
      ..cubicTo(85 * s, 60 * s, 215 * s, 60 * s, 205 * s, 140 * s)
      ..cubicTo(205 * s, 170 * s, 95 * s, 170 * s, 95 * s, 140 * s)
      ..close();
    canvas.drawPath(headPath, furPaint);
    canvas.drawPath(headPath, outline);
  }

  void _drawLeopardSpots(Canvas canvas, double s) {
    final spotPaint = Paint()..color = const Color(0xFF2C1810);
    final spots = [
      Offset(110 * s, 85 * s),
      Offset(130 * s, 70 * s),
      Offset(160 * s, 75 * s),
      Offset(185 * s, 90 * s),
      Offset(100 * s, 115 * s),
      Offset(195 * s, 120 * s),
    ];
    for (final p in spots) {
      canvas.drawCircle(p, 4.5 * s, spotPaint);
      canvas.drawCircle(Offset(p.dx + 4 * s, p.dy - 2 * s), 3 * s, spotPaint);
    }
  }

  void _drawMuzzleAndMouth(Canvas canvas, double s, Paint muzzlePaint, Paint outline, Paint linePaint) {
    // Large Ape Muzzle
    final muzzlePath = Path()
      ..moveTo(105 * s, 130 * s)
      ..cubicTo(95 * s, 115 * s, 205 * s, 115 * s, 195 * s, 130 * s)
      ..cubicTo(215 * s, 180 * s, 210 * s, 225 * s, 150 * s, 225 * s)
      ..cubicTo(90 * s, 225 * s, 85 * s, 180 * s, 105 * s, 130 * s)
      ..close();
    canvas.drawPath(muzzlePath, muzzlePaint);
    canvas.drawPath(muzzlePath, outline);

    // Stubble Dots on Muzzle
    final stubblePaint = Paint()..color = const Color(0xFF8D5524).withValues(alpha: 0.6);
    for (double y = 145 * s; y <= 180 * s; y += 7 * s) {
      for (double x = 118 * s; x <= 182 * s; x += 8 * s) {
        canvas.drawCircle(Offset(x, y), 0.8 * s, stubblePaint);
      }
    }

    // Nostrils
    final nostrilPaint = Paint()..color = const Color(0xFF1E1B18);
    canvas.drawOval(Rect.fromCenter(center: Offset(143 * s, 138 * s), width: 5 * s, height: 7 * s), nostrilPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(157 * s, 138 * s), width: 5 * s, height: 7 * s), nostrilPaint);

    // Mouth variations
    if (traits.mouth == 'wide_grin') {
      // Big Grinning Teeth (Like Ape 1, Ape 6 in screenshot)
      final mouthRect = Rect.fromCenter(center: Offset(150 * s, 182 * s), width: 75 * s, height: 28 * s);
      final mouthRRect = RRect.fromRectAndRadius(mouthRect, Radius.circular(14 * s));
      final teethBg = Paint()..color = Colors.white;
      canvas.drawRRect(mouthRRect, teethBg);
      canvas.drawRRect(mouthRRect, outline);

      // Teeth grid lines
      canvas.drawLine(Offset(115 * s, 182 * s), Offset(185 * s, 182 * s), linePaint);
      for (double x = 125 * s; x <= 175 * s; x += 10 * s) {
        canvas.drawLine(Offset(x, 168 * s), Offset(x, 196 * s), linePaint);
      }
    } else if (traits.mouth == 'tongue_out') {
      // Tongue sticking out (Like Ape 4 in screenshot)
      final mouthLine = Path()
        ..moveTo(125 * s, 180 * s)
        ..cubicTo(140 * s, 188 * s, 160 * s, 188 * s, 175 * s, 180 * s);
      canvas.drawPath(mouthLine, outline);

      // Pink Tongue
      final tonguePaint = Paint()..color = const Color(0xFFFF5252);
      final tonguePath = Path()
        ..moveTo(152 * s, 182 * s)
        ..cubicTo(145 * s, 212 * s, 175 * s, 212 * s, 168 * s, 182 * s)
        ..close();
      canvas.drawPath(tonguePath, tonguePaint);
      canvas.drawPath(tonguePath, outline);
    } else {
      // Closed / Cigarette Mouth (Like Ape 3, Ape 5 in screenshot)
      final mouthLine = Path()
        ..moveTo(125 * s, 182 * s)
        ..lineTo(175 * s, 182 * s);
      canvas.drawPath(mouthLine, outline);

      // Cigarette in mouth
      if (traits.mouth == 'cigarette' || traits.eyes == '3d_glasses' || traits.eyes == 'vr_visor') {
        final cigPaint = Paint()..color = Colors.white;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(170 * s, 180 * s, 24 * s, 4 * s), Radius.circular(2 * s)),
          cigPaint,
        );
        final ashPaint = Paint()..color = const Color(0xFFFF7675);
        canvas.drawCircle(Offset(194 * s, 182 * s), 2.5 * s, ashPaint);
      }
    }
  }

  void _drawEyes(Canvas canvas, double s, Paint outline, Paint linePaint) {
    if (traits.eyes == 'laser_beams') {
      // Cyan Laser Beams shooting out! (Like Ape 1 in screenshot)
      final laserPaint = Paint()
        ..color = const Color(0xFF00CEC9)
        ..style = PaintingStyle.fill;
      final laserGlow = Paint()
        ..color = const Color(0xFF00CEC9).withValues(alpha: 0.5)
        ..strokeWidth = 14 * s
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Laser beams
      final beamPath1 = Path()
        ..moveTo(128 * s, 105 * s)
        ..lineTo(0, 0)
        ..lineTo(10 * s, 0)
        ..lineTo(135 * s, 105 * s)
        ..close();
      final beamPath2 = Path()
        ..moveTo(165 * s, 105 * s)
        ..lineTo(30 * s, 0)
        ..lineTo(45 * s, 0)
        ..lineTo(172 * s, 105 * s)
        ..close();

      canvas.drawPath(beamPath1, laserPaint);
      canvas.drawPath(beamPath2, laserPaint);
      canvas.drawLine(Offset(131 * s, 105 * s), const Offset(5, 0), laserGlow);
      canvas.drawLine(Offset(168 * s, 105 * s), Offset(37 * s, 0), laserGlow);

      // Glowing Eyes
      canvas.drawOval(Rect.fromCenter(center: Offset(131 * s, 105 * s), width: 18 * s, height: 12 * s), laserPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(168 * s, 105 * s), width: 18 * s, height: 12 * s), laserPaint);
    } else if (traits.eyes == 'cyborg_red') {
      // Cyborg Metal & Glowing Red Eye (Like Ape 2 in screenshot)
      final metalPaint = Paint()..color = const Color(0xFF7F8C8D);
      final metalEye = Path()
        ..addOval(Rect.fromCenter(center: Offset(168 * s, 105 * s), width: 30 * s, height: 30 * s));
      canvas.drawPath(metalEye, metalPaint);
      canvas.drawPath(metalEye, outline);

      final redEye = Paint()..color = const Color(0xFFFF0055);
      canvas.drawCircle(Offset(168 * s, 105 * s), 7 * s, redEye);
      final redGlow = Paint()
        ..color = const Color(0xFFFF0055).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(Offset(168 * s, 105 * s), 12 * s, redGlow);

      // Normal Left Eye
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawOval(Rect.fromCenter(center: Offset(131 * s, 105 * s), width: 16 * s, height: 12 * s), whitePaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(131 * s, 105 * s), width: 16 * s, height: 12 * s), outline);
      canvas.drawCircle(Offset(131 * s, 105 * s), 4 * s, Paint()..color = Colors.black);
    } else if (traits.eyes == '3d_glasses') {
      // 3D Red-Blue Glasses (Like Ape 3 in screenshot)
      final framePaint = Paint()..color = Colors.white;
      final glassesRect = Rect.fromCenter(center: Offset(150 * s, 104 * s), width: 78 * s, height: 26 * s);
      final glassesRRect = RRect.fromRectAndRadius(glassesRect, Radius.circular(4 * s));
      canvas.drawRRect(glassesRRect, framePaint);
      canvas.drawRRect(glassesRRect, outline);

      // Blue Lens Left
      final blueLens = Paint()..color = const Color(0xFF0984E3);
      canvas.drawRect(Rect.fromLTWH(115 * s, 94 * s, 30 * s, 20 * s), blueLens);
      // Red Lens Right
      final redLens = Paint()..color = const Color(0xFFD63031);
      canvas.drawRect(Rect.fromLTWH(155 * s, 94 * s, 30 * s, 20 * s), redLens);
    } else if (traits.eyes == 'vr_visor') {
      // Glowing Blue Neon VR Visor (Like Ape 5 in screenshot)
      final vrPaint = Paint()..color = const Color(0xFF00CEC9);
      final vrRect = Rect.fromCenter(center: Offset(150 * s, 104 * s), width: 80 * s, height: 20 * s);
      final vrRRect = RRect.fromRectAndRadius(vrRect, Radius.circular(8 * s));
      canvas.drawRRect(vrRRect, vrPaint);
      canvas.drawRRect(vrRRect, outline);

      final shine = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = 2 * s;
      canvas.drawLine(Offset(125 * s, 98 * s), Offset(175 * s, 98 * s), shine);
    } else if (traits.eyes == 'x_eyes') {
      // Dead Cross X-Eyes (Like Ape 6 in screenshot)
      final xPaint = Paint()
        ..color = const Color(0xFF1E1B18)
        ..strokeWidth = 3.5 * s
        ..strokeCap = StrokeCap.round;
      // Left X
      canvas.drawLine(Offset(124 * s, 99 * s), Offset(138 * s, 111 * s), xPaint);
      canvas.drawLine(Offset(138 * s, 99 * s), Offset(124 * s, 111 * s), xPaint);
      // Right X
      canvas.drawLine(Offset(161 * s, 99 * s), Offset(175 * s, 111 * s), xPaint);
      canvas.drawLine(Offset(175 * s, 99 * s), Offset(161 * s, 111 * s), xPaint);
    } else {
      // Sleepy Drooping Eyes (Like Ape 4 in screenshot)
      final eyeWhite = Paint()..color = const Color(0xFFF5E6CA);
      canvas.drawOval(Rect.fromCenter(center: Offset(131 * s, 105 * s), width: 18 * s, height: 14 * s), eyeWhite);
      canvas.drawOval(Rect.fromCenter(center: Offset(131 * s, 105 * s), width: 18 * s, height: 14 * s), outline);
      canvas.drawOval(Rect.fromCenter(center: Offset(168 * s, 105 * s), width: 18 * s, height: 14 * s), eyeWhite);
      canvas.drawOval(Rect.fromCenter(center: Offset(168 * s, 105 * s), width: 18 * s, height: 14 * s), outline);

      // Drooping half-closed eyelids
      final lidPaint = Paint()..color = BoredApeTraits.getFurColor(traits.furColor);
      canvas.drawRect(Rect.fromLTWH(120 * s, 96 * s, 22 * s, 8 * s), lidPaint);
      canvas.drawRect(Rect.fromLTWH(157 * s, 96 * s, 22 * s, 8 * s), lidPaint);
      canvas.drawLine(Offset(120 * s, 104 * s), Offset(142 * s, 104 * s), outline);
      canvas.drawLine(Offset(157 * s, 104 * s), Offset(179 * s, 104 * s), outline);
    }
  }

  void _drawHeadwear(Canvas canvas, double s, Paint outline, Paint linePaint) {
    if (traits.headwear == 'sailor_hat') {
      // Navy Sailor Hat with Anchor (Like Ape 2 in screenshot)
      final hatPaint = Paint()..color = Colors.white;
      final hatPath = Path()
        ..moveTo(105 * s, 70 * s)
        ..lineTo(195 * s, 70 * s)
        ..lineTo(185 * s, 30 * s)
        ..lineTo(115 * s, 30 * s)
        ..close();
      canvas.drawPath(hatPath, hatPaint);
      canvas.drawPath(hatPath, outline);

      // Anchor Symbol
      final anchorPaint = Paint()
        ..color = const Color(0xFF0984E3)
        ..strokeWidth = 2.5 * s
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(150 * s, 42 * s), Offset(150 * s, 58 * s), anchorPaint);
      canvas.drawArc(Rect.fromLTWH(142 * s, 48 * s, 16 * s, 12 * s), 0, pi, false, anchorPaint);
    } else if (traits.headwear == 'captain_hat') {
      // Navy Captain Hat with Golden Badge & Black Visor (Like Ape 3 in screenshot)
      final visorPaint = Paint()..color = const Color(0xFF1E272E);
      final visorRect = Rect.fromLTWH(95 * s, 62 * s, 110 * s, 16 * s);
      canvas.drawRRect(RRect.fromRectAndRadius(visorRect, Radius.circular(8 * s)), visorPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(visorRect, Radius.circular(8 * s)), outline);

      final crownPaint = Paint()..color = Colors.white;
      final crownPath = Path()
        ..moveTo(105 * s, 62 * s)
        ..lineTo(195 * s, 62 * s)
        ..lineTo(185 * s, 22 * s)
        ..lineTo(115 * s, 22 * s)
        ..close();
      canvas.drawPath(crownPath, crownPaint);
      canvas.drawPath(crownPath, outline);

      // Golden Wreath Badge
      final goldBadge = Paint()..color = const Color(0xFFFFD700);
      canvas.drawCircle(Offset(150 * s, 42 * s), 7 * s, goldBadge);
    } else if (traits.headwear == 'gold_crown') {
      // Royal King Golden Crown
      final crownPaint = Paint()..color = const Color(0xFFFFD700);
      final crownPath = Path()
        ..moveTo(105 * s, 65 * s)
        ..lineTo(115 * s, 25 * s)
        ..lineTo(135 * s, 45 * s)
        ..lineTo(150 * s, 20 * s)
        ..lineTo(165 * s, 45 * s)
        ..lineTo(185 * s, 25 * s)
        ..lineTo(195 * s, 65 * s)
        ..close();
      canvas.drawPath(crownPath, crownPaint);
      canvas.drawPath(crownPath, outline);
    }
  }

  @override
  bool shouldRepaint(covariant BoredApePainter oldDelegate) => true;
}

class BoredApeWidget extends StatelessWidget {
  final BoredApeTraits traits;
  final double size;

  const BoredApeWidget({
    super.key,
    required this.traits,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.15),
        child: CustomPaint(
          size: Size(size, size),
          painter: BoredApePainter(traits: traits),
        ),
      ),
    );
  }
}
