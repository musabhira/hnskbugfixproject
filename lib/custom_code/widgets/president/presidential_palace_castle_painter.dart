import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🏛️ Procedural 2D Vector Presidential Palace Castle Painter
/// Hand-crafted architectural canvas rendering of the Sovereign Citadel:
/// - Grand Central Clock Belfry with moving hands and golden belfry bell
/// - Tall soaring turquoise spires with gilded copper ridges and royal finials
/// - Symmetrical neoclassical/Gothic state wings with arched French windows
/// - Rusticated ashlar limestone coursing, quoins, corbels, and machicolations
/// - Portico of 4 fluted marble columns with gold Corinthian capitals
/// - Cascading white marble steps with rich royal crimson carpet
/// - Hand-carved Guardian Lion pedestals, wall torches, and waving silk banners
class PresidentialPalaceCastleWidget extends StatelessWidget {
  final double width;
  final double height;
  final double animProg;

  const PresidentialPalaceCastleWidget({
    super.key,
    required this.width,
    required this.height,
    required this.animProg,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: PresidentialPalaceCastlePainter(animProg: animProg),
      ),
    );
  }
}

class PresidentialPalaceCastlePainter extends CustomPainter {
  final double animProg;

  PresidentialPalaceCastlePainter({required this.animProg});

  // Architectural Theme Tokens
  static const Color wallLight = Color(0xFFF1F5F9); // Light Ashlar Limestone
  static const Color wallBase = Color(0xFFE2E8F0); // Mid Ashlar Stone
  static const Color wallShade = Color(0xFFCBD5E1); // Shaded Stone Facets
  static const Color wallDark = Color(0xFF94A3B8); // Deep Stone Recesses
  static const Color rusticatedGranite = Color(0xFF475569); // Heavy Base Plinth
  static const Color mortarJoint = Color(0xFF94A3B8); // Stone Courses

  // Spires & Slate Mansard Roofs
  static const Color roofTurquoiseLight = Color(0xFF2DD4BF); // Highlight Slate
  static const Color roofTurquoise = Color(0xFF14B8A6); // Patina Copper Base
  static const Color roofTurquoiseDark = Color(0xFF0F766E); // Shaded Roof Pitch
  static const Color roofTurquoiseDeep = Color(0xFF042F2E); // Shadow Crevices

  // Royal Imperial Gold
  static const Color goldBright = Color(0xFFFFE066);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB45309);
  static const Color goldDeep = Color(0xFF78350F);

  // Royal Carpet & Velvet Drapes
  static const Color crimsonLight = Color(0xFFF43F5E);
  static const Color crimson = Color(0xFFBE123C);
  static const Color crimsonDark = Color(0xFF881337);

  // Interior Luminescence
  static const Color windowAmberLight = Color(0xFFFEF08A);
  static const Color windowAmber = Color(0xFFFACC15);
  static const Color windowDark = Color(0xFF1E293B);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final groundY = h - 16.0;

    // 0. Ambient Calculations
    final flamePulse = math.sin(animProg * 10 * math.pi);
    final flagWave = math.sin(animProg * 3.5 * math.pi) * 4.0;
    final windowPulse = 0.85 + (math.sin(animProg * 4 * math.pi) * 0.15);

    // 1. Foundation Ground Plinth & Reflecting Moat
    _drawFoundationAndMoat(canvas, w, groundY);

    // 2. Rear Outer Spires (Depth Background)
    _drawRearSpires(canvas, w, groundY, flagWave);

    // 3. Left & Right Outer Bastion Towers
    _drawOuterBastions(canvas, w, groundY, flagWave, flamePulse);

    // 4. Symmetrical Main Wings (Left & Right)
    _drawPalaceWings(canvas, w, groundY, windowPulse);

    // 5. Central Grand Keep & Throne Hall
    _drawCentralKeep(canvas, cx, groundY, windowPulse);

    // 6. Central Grand Clock Belfry & Imperial Spire
    _drawClockBelfryAndSpire(canvas, cx, groundY, flagWave);

    // 7. Grand Entrance Portico, Colonnade, Steps & Red Carpet
    _drawGrandPorticoAndStairs(canvas, cx, groundY, flamePulse);

    // 8. Guardian Lions on Pedestals
    _drawGuardianLions(canvas, cx, groundY);
  }

  /// 01. Foundation Plinth & Reflecting Water Basin
  void _drawFoundationAndMoat(Canvas canvas, double w, double groundY) {
    // Heavy rusticated plinth
    final plinthRect = Rect.fromLTWH(20, groundY - 14, w - 40, 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(plinthRect, const Radius.circular(4)),
      Paint()..color = rusticatedGranite,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(plinthRect, const Radius.circular(4)),
      Paint()
        ..color = goldDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Plinth stone blocks
    final mortarPaint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1.0;
    for (double x = 40; x < w - 40; x += 32) {
      canvas.drawLine(Offset(x, groundY - 14), Offset(x, groundY + 8), mortarPaint);
    }

    // Reflecting Moat Water Basin at the base
    final moatRect = Rect.fromLTWH(10, groundY + 4, w - 20, 16);
    final waterShader = const LinearGradient(
      colors: [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFF0369A1)],
      stops: [0.0, 0.45, 0.55, 1.0],
    ).createShader(moatRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(moatRect, const Radius.circular(8)),
      Paint()..shader = waterShader,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(moatRect, const Radius.circular(8)),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  /// 02. Rear Spires (Background Depth Layer)
  void _drawRearSpires(Canvas canvas, double w, double groundY, double flagWave) {
    const spireW = 38.0;
    const spireH = 280.0;
    final leftX = w * 0.28;
    final rightX = w * 0.72;

    for (final sx in [leftX, rightX]) {
      final baseY = groundY - 240.0;
      final apexY = baseY - spireH * 0.55;

      // Shaft
      final shaftRect = Rect.fromLTWH(sx - spireW / 2, baseY, spireW, 90);
      canvas.drawRect(shaftRect, Paint()..color = wallShade);
      canvas.drawRect(shaftRect, Paint()..color = mortarJoint ..style = PaintingStyle.stroke ..strokeWidth = 0.8);

      // Conical Spire
      final spirePath = Path()
        ..moveTo(sx - spireW / 2 - 2, baseY)
        ..lineTo(sx, apexY)
        ..lineTo(sx + spireW / 2 + 2, baseY)
        ..close();
      canvas.drawPath(spirePath, Paint()..color = roofTurquoiseDark);

      // Shaded ridge
      final ridgePath = Path()
        ..moveTo(sx, apexY)
        ..lineTo(sx + spireW / 2 + 2, baseY)
        ..lineTo(sx, baseY)
        ..close();
      canvas.drawPath(ridgePath, Paint()..color = roofTurquoiseDeep.withValues(alpha: 0.45));

      // Gold Needle Finial
      canvas.drawLine(Offset(sx, apexY), Offset(sx, apexY - 18), Paint()..color = gold ..strokeWidth = 2.0);
      canvas.drawCircle(Offset(sx, apexY - 18), 3.0, Paint()..color = goldBright);

      // Rear Swallowtail Pennant
      final pPath = Path()
        ..moveTo(sx, apexY - 16)
        ..lineTo(sx + 18 + flagWave * 0.7, apexY - 13)
        ..lineTo(sx + 12 + flagWave * 0.7, apexY - 9)
        ..lineTo(sx + 18 + flagWave * 0.7, apexY - 5)
        ..lineTo(sx, apexY - 5)
        ..close();
      canvas.drawPath(pPath, Paint()..color = crimson);
    }
  }

  /// 03. Left & Right Outer Bastion Towers
  void _drawOuterBastions(Canvas canvas, double w, double groundY, double flagWave, double flamePulse) {
    const towerW = 68.0;
    const towerH = 340.0;

    for (final isLeft in [true, false]) {
      final tx = isLeft ? 14.0 : w - 14.0 - towerW;
      final towerCx = tx + towerW / 2;
      final topY = groundY - towerH;

      // Tower Stone Body
      final towerRect = Rect.fromLTWH(tx, topY + 60, towerW, towerH - 60);
      final bodyShader = LinearGradient(
        colors: isLeft
            ? [wallLight, wallBase, wallShade]
            : [wallShade, wallBase, wallLight],
      ).createShader(towerRect);
      canvas.drawRect(towerRect, Paint()..shader = bodyShader);
      canvas.drawRect(towerRect, Paint()..color = wallDark ..style = PaintingStyle.stroke ..strokeWidth = 1.0);

      // Stone Coursing & Chamfer Lines
      final lineP = Paint()..color = mortarJoint.withValues(alpha: 0.4)..strokeWidth = 0.8;
      for (double y = topY + 70; y < groundY - 20; y += 14) {
        canvas.drawLine(Offset(tx, y), Offset(tx + towerW, y), lineP);
      }

      // Vertical Arrow Loop Windows (3 high)
      for (int i = 0; i < 3; i++) {
        final wy = topY + 110 + (i * 55.0);
        final wRect = Rect.fromLTWH(towerCx - 4, wy, 8, 22);
        canvas.drawRRect(RRect.fromRectAndRadius(wRect, const Radius.circular(4)), Paint()..color = windowDark);
        canvas.drawRRect(RRect.fromRectAndRadius(wRect, const Radius.circular(4)), Paint()..color = gold ..style = PaintingStyle.stroke ..strokeWidth = 1.0);
        canvas.drawCircle(Offset(towerCx, wy + 11), 2.5, Paint()..color = windowAmber);
      }

      // Machicolations & Corbel Brackets
      final corbelY = topY + 60;
      final cPath = Path();
      for (double bx = tx - 4; bx <= tx + towerW + 4; bx += 10) {
        cPath
          ..moveTo(bx, corbelY)
          ..lineTo(bx + 4, corbelY + 12)
          ..lineTo(bx + 8, corbelY)
          ..close();
      }
      canvas.drawPath(cPath, Paint()..color = rusticatedGranite);

      // Crenellated Parapet (Battlements)
      final parapetRect = Rect.fromLTWH(tx - 6, topY + 36, towerW + 12, 24);
      canvas.drawRect(parapetRect, Paint()..color = wallLight);
      canvas.drawRect(parapetRect, Paint()..color = goldDark ..style = PaintingStyle.stroke ..strokeWidth = 1.2);

      // Merlons (Teeth)
      for (double mx = tx - 6; mx < tx + towerW + 6; mx += 14) {
        canvas.drawRect(Rect.fromLTWH(mx, topY + 22, 9, 14), Paint()..color = wallLight);
        canvas.drawRect(Rect.fromLTWH(mx, topY + 22, 9, 14), Paint()..color = wallDark ..style = PaintingStyle.stroke ..strokeWidth = 0.8);
      }

      // Soaring Conical Turquoise Spire
      final spireApexY = topY - 70;
      final sPath = Path()
        ..moveTo(tx - 4, topY + 24)
        ..lineTo(towerCx, spireApexY)
        ..lineTo(tx + towerW + 4, topY + 24)
        ..close();
      canvas.drawPath(sPath, Paint()..color = roofTurquoise);

      // Spire 3D facet shading
      final shadePath = Path()
        ..moveTo(towerCx, spireApexY)
        ..lineTo(tx + towerW + 4, topY + 24)
        ..lineTo(towerCx, topY + 24)
        ..close();
      canvas.drawPath(shadePath, Paint()..color = roofTurquoiseDark.withValues(alpha: 0.5));

      // Gold Trim Ring at Spire Base
      canvas.drawLine(
        Offset(tx - 5, topY + 24),
        Offset(tx + towerW + 5, topY + 24),
        Paint()..color = gold ..strokeWidth = 3.0,
      );

      // Spire Pinnacle Needle & Finial
      canvas.drawLine(
        Offset(towerCx, spireApexY),
        Offset(towerCx, spireApexY - 24),
        Paint()..color = gold ..strokeWidth = 2.4,
      );
      canvas.drawCircle(Offset(towerCx, spireApexY - 24), 4.0, Paint()..color = goldBright);

      // Royal Silk Swallowtail Flag
      final flagPath = Path()
        ..moveTo(towerCx, spireApexY - 22)
        ..lineTo(towerCx + (isLeft ? 26 + flagWave : -(26 + flagWave)), spireApexY - 17)
        ..lineTo(towerCx + (isLeft ? 18 + flagWave : -(18 + flagWave)), spireApexY - 11)
        ..lineTo(towerCx + (isLeft ? 26 + flagWave : -(26 + flagWave)), spireApexY - 5)
        ..lineTo(towerCx, spireApexY - 5)
        ..close();
      canvas.drawPath(flagPath, Paint()..color = isLeft ? gold : crimson);
      canvas.drawPath(flagPath, Paint()..color = Colors.black26 ..style = PaintingStyle.stroke ..strokeWidth = 0.6);

      // Long Imperial Banner hanging down the bastion face
      final banX = towerCx - 12;
      final banRect = Rect.fromLTWH(banX, topY + 95, 24, 85);
      canvas.drawRRect(
        RRect.fromRectAndRadius(banRect, const Radius.circular(3)),
        Paint()..color = const Color(0xFF1E3A8A),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(banRect, const Radius.circular(3)),
        Paint()..color = gold ..style = PaintingStyle.stroke ..strokeWidth = 1.0,
      );
      // Gold Crest Star on Banner
      canvas.drawCircle(Offset(towerCx, topY + 115), 5.5, Paint()..color = gold);
      canvas.drawCircle(Offset(towerCx, topY + 115), 2.5, Paint()..color = crimson);

      // Wall Sconce Torch with Animated Fire
      final torchY = topY + 210;
      final torchX = isLeft ? tx + towerW - 4 : tx + 4;
      _drawWallTorch(canvas, torchX, torchY, flamePulse * (isLeft ? 1.0 : -1.0));
    }
  }

  /// 04. Symmetrical Main State Wings (Left & Right)
  void _drawPalaceWings(Canvas canvas, double w, double groundY, double windowPulse) {
    const wingW = 165.0;
    const wingH = 260.0;
    final leftX = 82.0;
    final rightX = w - 82.0 - wingW;
    final topY = groundY - wingH;

    for (final isLeft in [true, false]) {
      final wx = isLeft ? leftX : rightX;

      // 1. Wing Masonry Body
      final wingRect = Rect.fromLTWH(wx, topY + 50, wingW, wingH - 50);
      final wingShader = LinearGradient(
        colors: [wallLight, wallBase],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(wingRect);
      canvas.drawRect(wingRect, Paint()..shader = wingShader);
      canvas.drawRect(wingRect, Paint()..color = wallDark ..style = PaintingStyle.stroke ..strokeWidth = 1.0);

      // Stone ashlar course lines
      final courseP = Paint()..color = mortarJoint.withValues(alpha: 0.35)..strokeWidth = 0.7;
      for (double y = topY + 60; y < groundY - 14; y += 15) {
        canvas.drawLine(Offset(wx, y), Offset(wx + wingW, y), courseP);
      }

      // Ground Floor: 3 Rusticated Arch Windows
      for (int i = 0; i < 3; i++) {
        final winX = wx + 20 + (i * 48.0);
        final winY = groundY - 75.0;
        _drawArchedWindow(canvas, winX, winY, 26, 42, windowPulse, hasBalcony: false);
      }

      // Piano Nobile (Second Floor): 3 Grand French Arched Windows with Balconies
      for (int i = 0; i < 3; i++) {
        final winX = wx + 20 + (i * 48.0);
        final winY = topY + 80.0;
        _drawArchedWindow(canvas, winX, winY, 28, 56, windowPulse, hasBalcony: true);
      }

      // Classical Floor-Dividing Stone Cornice with Dentils
      final corniceY = topY + 148.0;
      canvas.drawRect(Rect.fromLTWH(wx - 4, corniceY, wingW + 8, 8), Paint()..color = rusticatedGranite);
      canvas.drawLine(Offset(wx - 6, corniceY), Offset(wx + wingW + 6, corniceY), Paint()..color = goldDark ..strokeWidth = 1.5);
      for (double dx = wx; dx < wx + wingW; dx += 8) {
        canvas.drawRect(Rect.fromLTWH(dx, corniceY + 2, 4, 4), Paint()..color = wallLight);
      }

      // Roof Balustrade with Stone Urns
      final balustradeY = topY + 44.0;
      canvas.drawRect(Rect.fromLTWH(wx - 2, balustradeY, wingW + 4, 7), Paint()..color = wallBase);
      canvas.drawLine(Offset(wx - 4, balustradeY), Offset(wx + wingW + 4, balustradeY), Paint()..color = gold ..strokeWidth = 1.2);
      for (double bx = wx + 6; bx < wx + wingW - 6; bx += 12) {
        canvas.drawLine(Offset(bx, balustradeY), Offset(bx, balustradeY + 6), Paint()..color = wallDark ..strokeWidth = 1.4);
      }
      // Classical Urns on Balustrade
      for (double ux = wx + 12; ux < wx + wingW; ux += 45) {
        canvas.drawCircle(Offset(ux, balustradeY - 3), 3.0, Paint()..color = gold);
        canvas.drawRect(Rect.fromLTWH(ux - 2, balustradeY, 4, 3), Paint()..color = wallDark);
      }

      // Mansard Turquoise Slate Roof
      final roofPath = Path()
        ..moveTo(wx - 8, balustradeY)
        ..lineTo(wx + 18, topY - 6)
        ..lineTo(wx + wingW - 18, topY - 6)
        ..lineTo(wx + wingW + 8, balustradeY)
        ..close();
      canvas.drawPath(roofPath, Paint()..color = roofTurquoise);
      canvas.drawPath(roofPath, Paint()..color = roofTurquoiseDark ..style = PaintingStyle.stroke ..strokeWidth = 1.0);

      // Gold Ridge Cresting along Roof Peak
      canvas.drawLine(Offset(wx + 16, topY - 6), Offset(wx + wingW - 16, topY - 6), Paint()..color = gold ..strokeWidth = 2.4);
      for (double rx = wx + 24; rx < wx + wingW - 20; rx += 14) {
        canvas.drawLine(Offset(rx, topY - 6), Offset(rx, topY - 12), Paint()..color = gold ..strokeWidth = 1.2);
        canvas.drawCircle(Offset(rx, topY - 12), 1.5, Paint()..color = goldBright);
      }

      // 2 Elaborate Dormer Windows per wing
      for (int d = 0; d < 2; d++) {
        final dx = wx + 38 + (d * 70.0);
        final dy = topY + 8;
        _drawDormerWindow(canvas, dx, dy);
      }
    }
  }

  /// 05. Central Grand Keep & Throne Hall
  void _drawCentralKeep(Canvas canvas, double cx, double groundY, double windowPulse) {
    const keepW = 206.0;
    const keepH = 340.0;
    final kx = cx - keepW / 2;
    final topY = groundY - keepH;

    // Grand Central Keep Body
    final keepRect = Rect.fromLTWH(kx, topY + 50, keepW, keepH - 50);
    final keepShader = const LinearGradient(
      colors: [wallLight, wallBase, wallLight],
      stops: [0.0, 0.5, 1.0],
    ).createShader(keepRect);
    canvas.drawRect(keepRect, Paint()..shader = keepShader);
    canvas.drawRect(keepRect, Paint()..color = goldDark ..style = PaintingStyle.stroke ..strokeWidth = 1.4);

    // Ashlar stone courses
    final lineP = Paint()..color = mortarJoint.withValues(alpha: 0.35)..strokeWidth = 0.8;
    for (double y = topY + 60; y < groundY - 14; y += 14) {
      canvas.drawLine(Offset(kx, y), Offset(kx + keepW, y), lineP);
    }

    // Fluted Classical Corner Pilasters
    for (final px in [kx + 4, kx + keepW - 18]) {
      final pRect = Rect.fromLTWH(px, topY + 52, 14, keepH - 52);
      canvas.drawRect(pRect, Paint()..color = wallLight);
      canvas.drawRect(pRect, Paint()..color = goldDark ..style = PaintingStyle.stroke ..strokeWidth = 0.8);
      canvas.drawLine(Offset(px + 4, topY + 52), Offset(px + 4, groundY - 14), Paint()..color = wallShade ..strokeWidth = 1.0);
      canvas.drawLine(Offset(px + 9, topY + 52), Offset(px + 9, groundY - 14), Paint()..color = wallShade ..strokeWidth = 1.0);
    }

    // Grand Imperial Throne Room: 3 Monumental Gothic Cusped Windows
    for (int i = -1; i <= 1; i++) {
      final winX = cx + (i * 54.0);
      final winY = topY + 84.0;
      final isCenter = i == 0;
      final winW = isCenter ? 36.0 : 30.0;
      final winH = isCenter ? 68.0 : 58.0;

      // Stained Glass Arched Window
      final wRect = Rect.fromLTWH(winX - winW / 2, winY, winW, winH);
      final wPath = Path()
        ..moveTo(wRect.left, wRect.bottom)
        ..lineTo(wRect.left, wRect.top + winW * 0.45)
        ..arcToPoint(
          Offset(wRect.right, wRect.top + winW * 0.45),
          radius: Radius.circular(winW * 0.48),
        )
        ..lineTo(wRect.right, wRect.bottom)
        ..close();

      // Glowing Interior Chandelier Luminescence
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            windowAmberLight.withValues(alpha: windowPulse),
            windowAmber.withValues(alpha: windowPulse * 0.9),
            const Color(0xFFD97706),
          ],
        ).createShader(wRect);
      canvas.drawPath(wPath, glowPaint);
      canvas.drawPath(wPath, Paint()..color = gold ..style = PaintingStyle.stroke ..strokeWidth = 1.5);

      // Gothic Stone Tracery & Mullions
      canvas.drawLine(Offset(winX, wRect.top + 10), Offset(winX, wRect.bottom), Paint()..color = wallDark ..strokeWidth = 1.2);
      canvas.drawLine(Offset(wRect.left + 4, wRect.top + winH * 0.45), Offset(wRect.right - 4, wRect.top + winH * 0.45), Paint()..color = wallDark ..strokeWidth = 1.0);
      canvas.drawLine(Offset(wRect.left + 4, wRect.top + winH * 0.72), Offset(wRect.right - 4, wRect.top + winH * 0.72), Paint()..color = wallDark ..strokeWidth = 1.0);
    }

    // Royal Imperial Crest / Shield of Pocket World Sovereign
    final crestRect = Rect.fromLTWH(cx - 18, topY + 54, 36, 26);
    canvas.drawRRect(
      RRect.fromRectAndRadius(crestRect, const Radius.circular(6)),
      Paint()..color = gold,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(crestRect, const Radius.circular(6)),
      Paint()..color = goldDeep ..style = PaintingStyle.stroke ..strokeWidth = 1.5,
    );
    canvas.drawCircle(Offset(cx, topY + 67), 8.0, Paint()..color = const Color(0xFF1E3A8A));
    canvas.drawCircle(Offset(cx, topY + 67), 4.0, Paint()..color = goldBright);

    // Mid-tier Grand Royal Balcony with Crimson Velvet Bunting
    final balcY = topY + 158.0;
    final balcRect = Rect.fromLTWH(cx - 72, balcY, 144, 12);
    canvas.drawRRect(RRect.fromRectAndRadius(balcRect, const Radius.circular(3)), Paint()..color = wallLight);
    canvas.drawRRect(RRect.fromRectAndRadius(balcRect, const Radius.circular(3)), Paint()..color = gold ..style = PaintingStyle.stroke ..strokeWidth = 1.2);
    // Crimson velvet swag drapery with gold tassels
    for (double bx = cx - 60; bx <= cx + 45; bx += 30) {
      final drapePath = Path()
        ..moveTo(bx, balcY + 2)
        ..quadraticBezierTo(bx + 15, balcY + 16, bx + 30, balcY + 2)
        ..close();
      canvas.drawPath(drapePath, Paint()..color = crimson);
      canvas.drawCircle(Offset(bx + 15, balcY + 14), 2.0, Paint()..color = gold);
    }
  }

  /// 06. Central Grand Clock Belfry & Imperial Turquoise Spire
  void _drawClockBelfryAndSpire(Canvas canvas, double cx, double groundY, double flagWave) {
    const belfryW = 96.0;
    const belfryH = 140.0;
    final bx = cx - belfryW / 2;
    final baseY = groundY - 340.0;
    final belfryTopY = baseY - belfryH;

    // Belfry Tower Stone Body
    final belfryRect = Rect.fromLTWH(bx, belfryTopY, belfryW, belfryH);
    canvas.drawRect(belfryRect, Paint()..color = wallLight);
    canvas.drawRect(belfryRect, Paint()..color = goldDark ..style = PaintingStyle.stroke ..strokeWidth = 1.4);

    // Stone Quoins along corners
    for (double y = belfryTopY; y < baseY; y += 14) {
      canvas.drawRect(Rect.fromLTWH(bx, y, 7, 7), Paint()..color = wallShade);
      canvas.drawRect(Rect.fromLTWH(bx + belfryW - 7, y, 7, 7), Paint()..color = wallShade);
    }

    // 🕒 Monumental Royal Gold Clock
    final clockCenter = Offset(cx, belfryTopY + 54);
    const clockRadius = 24.0;

    // Gold Outer Filigree Bezel
    canvas.drawCircle(clockCenter, clockRadius + 3.5, Paint()..color = gold);
    canvas.drawCircle(clockCenter, clockRadius + 3.5, Paint()..color = goldDark ..style = PaintingStyle.stroke ..strokeWidth = 1.2);

    // Ivory Luminous Dial
    canvas.drawCircle(clockCenter, clockRadius, Paint()..color = const Color(0xFFFFFBEB));
    canvas.drawCircle(clockCenter, clockRadius, Paint()..color = goldDeep ..style = PaintingStyle.stroke ..strokeWidth = 1.0);

    // Clock Hour Ticks (12 Roman numerals simulated)
    final tickP = Paint()..color = goldDeep ..strokeWidth = 1.2;
    for (int i = 0; i < 12; i++) {
      final angle = i * (math.pi / 6);
      final r1 = clockRadius - 2;
      final r2 = clockRadius - 5.5;
      final p1 = Offset(clockCenter.dx + math.cos(angle) * r1, clockCenter.dy + math.sin(angle) * r1);
      final p2 = Offset(clockCenter.dx + math.cos(angle) * r2, clockCenter.dy + math.sin(angle) * r2);
      canvas.drawLine(p1, p2, tickP);
    }

    // Moving Clock Hands (Based on animProg)
    final hourAngle = (animProg * 2 * math.pi) - (math.pi / 2);
    final minAngle = (animProg * 12 * math.pi) - (math.pi / 2);
    canvas.drawLine(clockCenter, Offset(clockCenter.dx + math.cos(hourAngle) * 11, clockCenter.dy + math.sin(hourAngle) * 11), Paint()..color = Colors.black ..strokeWidth = 2.0);
    canvas.drawLine(clockCenter, Offset(clockCenter.dx + math.cos(minAngle) * 16, clockCenter.dy + math.sin(minAngle) * 16), Paint()..color = crimson ..strokeWidth = 1.2);
    canvas.drawCircle(clockCenter, 2.5, Paint()..color = gold);

    // Arched Belfry Bell Gallery (Above Clock)
    final bellArchRect = Rect.fromLTWH(cx - 16, belfryTopY + 86, 32, 44);
    final bPath = Path()
      ..moveTo(bellArchRect.left, bellArchRect.bottom)
      ..lineTo(bellArchRect.left, bellArchRect.top + 16)
      ..arcToPoint(Offset(bellArchRect.right, bellArchRect.top + 16), radius: const Radius.circular(16))
      ..lineTo(bellArchRect.right, bellArchRect.bottom)
      ..close();
    canvas.drawPath(bPath, Paint()..color = windowDark);
    canvas.drawPath(bPath, Paint()..color = gold ..style = PaintingStyle.stroke ..strokeWidth = 1.2);

    // Gold Ceremonial Liberty Bell in the chamber
    final bellPath = Path()
      ..moveTo(cx - 7, belfryTopY + 104)
      ..lineTo(cx + 7, belfryTopY + 104)
      ..lineTo(cx + 10, belfryTopY + 120)
      ..lineTo(cx - 10, belfryTopY + 120)
      ..close();
    canvas.drawPath(bellPath, Paint()..color = goldBright);
    canvas.drawCircle(Offset(cx, belfryTopY + 122), 2.5, Paint()..color = gold);

    // Belfry Cornice & Parapet
    canvas.drawRect(Rect.fromLTWH(bx - 6, belfryTopY - 6, belfryW + 12, 8), Paint()..color = wallLight);
    canvas.drawRect(Rect.fromLTWH(bx - 6, belfryTopY - 6, belfryW + 12, 8), Paint()..color = gold ..style = PaintingStyle.stroke ..strokeWidth = 1.2);

    // 👑 Majestic Central Turquoise Needle Spire
    const spireH = 135.0;
    final apexY = belfryTopY - spireH;

    // Multi-faceted Octagonal Spire
    final sPath = Path()
      ..moveTo(bx - 4, belfryTopY - 6)
      ..lineTo(cx, apexY)
      ..lineTo(bx + belfryW + 4, belfryTopY - 6)
      ..close();
    canvas.drawPath(sPath, Paint()..color = roofTurquoise);

    // Shaded Spire Face
    final shadePath = Path()
      ..moveTo(cx, apexY)
      ..lineTo(bx + belfryW + 4, belfryTopY - 6)
      ..lineTo(cx, belfryTopY - 6)
      ..close();
    canvas.drawPath(shadePath, Paint()..color = roofTurquoiseDark);

    // Golden Copper Ribs along Spire Facets
    canvas.drawLine(Offset(bx - 4, belfryTopY - 6), Offset(cx, apexY), Paint()..color = gold ..strokeWidth = 1.5);
    canvas.drawLine(Offset(bx + belfryW + 4, belfryTopY - 6), Offset(cx, apexY), Paint()..color = gold ..strokeWidth = 1.5);
    canvas.drawLine(Offset(cx, belfryTopY - 6), Offset(cx, apexY), Paint()..color = goldBright ..strokeWidth = 2.0);

    // Pinnacle Finial with Gold Cross / Orb
    canvas.drawLine(Offset(cx, apexY), Offset(cx, apexY - 32), Paint()..color = gold ..strokeWidth = 3.0);
    canvas.drawCircle(Offset(cx, apexY - 24), 5.5, Paint()..color = goldBright);
    canvas.drawCircle(Offset(cx, apexY - 32), 3.0, Paint()..color = gold);

    // 🚩 The Grand Imperial Standard Flag of The President of Pocket World
    final fPath = Path()
      ..moveTo(cx, apexY - 32)
      ..lineTo(cx + 42 + flagWave, apexY - 26)
      ..lineTo(cx + 34 + flagWave, apexY - 18)
      ..lineTo(cx + 42 + flagWave, apexY - 10)
      ..lineTo(cx, apexY - 10)
      ..close();
    canvas.drawPath(fPath, Paint()..color = gold);
    canvas.drawPath(fPath, Paint()..color = goldDeep ..style = PaintingStyle.stroke ..strokeWidth = 1.0);
    // Royal Emblem Crown on Flag
    canvas.drawCircle(Offset(cx + 18 + flagWave * 0.4, apexY - 21), 4.5, Paint()..color = crimson);
  }

  /// 07. Grand Entrance Portico, Colonnade, Steps & Red Carpet
  void _drawGrandPorticoAndStairs(Canvas canvas, double cx, double groundY, double flamePulse) {
    const porticoW = 168.0;
    final px = cx - porticoW / 2;
    final porticoTopY = groundY - 110.0;

    // Entablature Pediment above the Portico
    final pedPath = Path()
      ..moveTo(px - 10, porticoTopY)
      ..lineTo(cx, porticoTopY - 24)
      ..lineTo(px + porticoW + 10, porticoTopY)
      ..close();
    canvas.drawPath(pedPath, Paint()..color = wallLight);
    canvas.drawPath(pedPath, Paint()..color = gold ..style = PaintingStyle.stroke ..strokeWidth = 1.4);
    // Gold Sunburst Carving in Pediment Tympanum
    canvas.drawCircle(Offset(cx, porticoTopY - 8), 6.0, Paint()..color = gold);

    // Architrave Beam
    canvas.drawRect(Rect.fromLTWH(px - 6, porticoTopY, porticoW + 12, 10), Paint()..color = wallBase);
    canvas.drawRect(Rect.fromLTWH(px - 6, porticoTopY, porticoW + 12, 10), Paint()..color = goldDark ..style = PaintingStyle.stroke ..strokeWidth = 1.0);

    // 4 Grand Fluted Marble Columns
    final colSpacing = (porticoW - 20) / 3;
    for (int i = 0; i < 4; i++) {
      final colX = px + 10 + (i * colSpacing);
      const colW = 11.0;
      final colRect = Rect.fromLTWH(colX - colW / 2, porticoTopY + 10, colW, 80);

      // Fluted shaft
      canvas.drawRect(colRect, Paint()..color = wallLight);
      canvas.drawRect(colRect, Paint()..color = wallDark ..style = PaintingStyle.stroke ..strokeWidth = 0.8);
      canvas.drawLine(Offset(colX, porticoTopY + 10), Offset(colX, porticoTopY + 90), Paint()..color = wallShade ..strokeWidth = 1.0);

      // Corinthian Gilded Capital & Base
      canvas.drawRect(Rect.fromLTWH(colX - 8, porticoTopY + 7, 16, 5), Paint()..color = gold);
      canvas.drawRect(Rect.fromLTWH(colX - 7, porticoTopY + 88, 14, 4), Paint()..color = gold);
    }

    // Massive Arched Double Oak Portcullis Portal (Center)
    const doorW = 48.0;
    const doorH = 68.0;
    final doorRect = Rect.fromLTWH(cx - doorW / 2, groundY - doorH, doorW, doorH);
    final dPath = Path()
      ..moveTo(doorRect.left, doorRect.bottom)
      ..lineTo(doorRect.left, doorRect.top + doorW * 0.45)
      ..arcToPoint(Offset(doorRect.right, doorRect.top + doorW * 0.45), radius: Radius.circular(doorW * 0.48))
      ..lineTo(doorRect.right, doorRect.bottom)
      ..close();

    // Dark Carved Bog Oak Door with Golden Interior Spill
    canvas.drawPath(dPath, Paint()..color = const Color(0xFF291508));
    canvas.drawPath(dPath, Paint()..color = gold ..style = PaintingStyle.stroke ..strokeWidth = 1.8);

    // Golden Portcullis Studs & Center Meeting Stile
    canvas.drawLine(Offset(cx, doorRect.top + 6), Offset(cx, doorRect.bottom), Paint()..color = gold ..strokeWidth = 1.4);
    for (double sy = doorRect.top + 24; sy < doorRect.bottom - 4; sy += 12) {
      canvas.drawCircle(Offset(cx - 10, sy), 2.0, Paint()..color = goldBright);
      canvas.drawCircle(Offset(cx + 10, sy), 2.0, Paint()..color = goldBright);
    }

    // Cascading Grand Marble Steps (4 Steps)
    for (int step = 0; step < 4; step++) {
      final stepW = porticoW + 30 + (step * 24.0);
      final stepH = 5.0;
      final sy = groundY - 14 + (step * stepH);
      final sRect = Rect.fromLTWH(cx - stepW / 2, sy, stepW, stepH);
      canvas.drawRect(sRect, Paint()..color = (step % 2 == 0) ? wallLight : wallBase);
      canvas.drawLine(Offset(cx - stepW / 2, sy), Offset(cx + stepW / 2, sy), Paint()..color = wallDark ..strokeWidth = 0.8);
    }

    // 🌹 Rich Royal Crimson Velvet Carpet Cascading Down the Center
    final carpetPath = Path()
      ..moveTo(cx - 18, groundY - 4)
      ..lineTo(cx + 18, groundY - 4)
      ..lineTo(cx + 28, groundY + 12)
      ..lineTo(cx - 28, groundY + 12)
      ..close();
    canvas.drawPath(carpetPath, Paint()..color = crimson);
    // Gold Fringe Trims on Carpet
    canvas.drawLine(Offset(cx - 18, groundY - 4), Offset(cx - 28, groundY + 12), Paint()..color = goldBright ..strokeWidth = 1.4);
    canvas.drawLine(Offset(cx + 18, groundY - 4), Offset(cx + 28, groundY + 12), Paint()..color = goldBright ..strokeWidth = 1.4);

    // Flanking Ornate Iron Torches on Grand Portal
    _drawWallTorch(canvas, cx - doorW / 2 - 14, groundY - 42, flamePulse);
    _drawWallTorch(canvas, cx + doorW / 2 + 14, groundY - 42, -flamePulse);
  }

  /// 08. Hand-Carved Guardian Lions on Pedestals
  void _drawGuardianLions(Canvas canvas, double cx, double groundY) {
    for (final isLeft in [true, false]) {
      final lx = isLeft ? cx - 110 : cx + 110;
      final ly = groundY - 12;

      // Stone Pedestal
      final pedRect = Rect.fromLTWH(lx - 12, ly, 24, 16);
      canvas.drawRect(pedRect, Paint()..color = rusticatedGranite);
      canvas.drawRect(pedRect, Paint()..color = goldDark ..style = PaintingStyle.stroke ..strokeWidth = 1.0);

      // Carved Lion Silhouette
      final lionPaint = Paint()..color = wallLight;
      canvas.drawCircle(Offset(lx, ly - 10), 6.5, lionPaint); // Lion head & mane
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(lx - 7, ly - 8, 14, 10), const Radius.circular(3)), lionPaint);
      // Lion Gold Crown
      canvas.drawCircle(Offset(lx, ly - 16), 2.5, Paint()..color = gold);
    }
  }

  /// Helper: Arched Window
  void _drawArchedWindow(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    double pulse, {
    required bool hasBalcony,
  }) {
    final rect = Rect.fromLTWH(x - w / 2, y, w, h);
    final path = Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top + w / 2)
      ..arcToPoint(Offset(rect.right, rect.top + w / 2), radius: Radius.circular(w / 2))
      ..lineTo(rect.right, rect.bottom)
      ..close();

    // Warm Interior Glow
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          colors: [
            windowAmberLight.withValues(alpha: pulse),
            windowAmber.withValues(alpha: pulse * 0.8),
            const Color(0xFFD97706),
          ],
        ).createShader(rect),
    );
    canvas.drawPath(path, Paint()..color = goldDark ..style = PaintingStyle.stroke ..strokeWidth = 1.2);

    // Stone Arch Keystone
    canvas.drawRect(Rect.fromLTWH(x - 3, y - 2, 6, 5), Paint()..color = wallLight);

    // Muntins (Cross Bars)
    canvas.drawLine(Offset(x, y + 4), Offset(x, y + h), Paint()..color = wallDark ..strokeWidth = 0.9);
    canvas.drawLine(Offset(rect.left + 2, y + h * 0.5), Offset(rect.right - 2, y + h * 0.5), Paint()..color = wallDark ..strokeWidth = 0.8);

    // Stone Balustrade on Piano Nobile
    if (hasBalcony) {
      final bRect = Rect.fromLTWH(x - w / 2 - 4, y + h - 14, w + 8, 14);
      canvas.drawRect(bRect, Paint()..color = wallLight);
      canvas.drawRect(bRect, Paint()..color = gold ..style = PaintingStyle.stroke ..strokeWidth = 1.0);
      for (double bx = bRect.left + 3; bx < bRect.right - 3; bx += 5) {
        canvas.drawLine(Offset(bx, bRect.top), Offset(bx, bRect.bottom), Paint()..color = wallDark ..strokeWidth = 0.8);
      }
    }
  }

  /// Helper: Dormer Roof Window
  void _drawDormerWindow(Canvas canvas, double x, double y) {
    const dw = 18.0;
    const dh = 24.0;
    final dRect = Rect.fromLTWH(x - dw / 2, y, dw, dh);

    // Dormer Stone Body
    canvas.drawRect(dRect, Paint()..color = wallLight);
    canvas.drawRect(dRect, Paint()..color = wallDark ..style = PaintingStyle.stroke ..strokeWidth = 0.8);

    // Dormer Pediment Peak
    final pPath = Path()
      ..moveTo(x - dw / 2 - 3, y)
      ..lineTo(x, y - 8)
      ..lineTo(x + dw / 2 + 3, y)
      ..close();
    canvas.drawPath(pPath, Paint()..color = wallLight);
    canvas.drawPath(pPath, Paint()..color = gold ..style = PaintingStyle.stroke ..strokeWidth = 1.0);

    // Window Pane
    final paneRect = Rect.fromLTWH(x - dw / 2 + 2, y + 4, dw - 4, dh - 6);
    canvas.drawRect(paneRect, Paint()..color = windowAmberLight);
    canvas.drawRect(paneRect, Paint()..color = wallDark ..style = PaintingStyle.stroke ..strokeWidth = 0.8);
  }

  /// Helper: Cast-Iron Wall Torch with Animated Fire Flame
  void _drawWallTorch(Canvas canvas, double x, double y, double flameOffset) {
    // Sconce Bracket
    canvas.drawLine(Offset(x, y + 8), Offset(x, y), Paint()..color = const Color(0xFF1E293B) ..strokeWidth = 2.4);
    canvas.drawRect(Rect.fromLTWH(x - 4, y - 4, 8, 5), Paint()..color = goldDark);

    // Animated Fire Flame
    final flameP = Path()
      ..moveTo(x - 4, y - 4)
      ..quadraticBezierTo(x - 6 + flameOffset, y - 14, x, y - 22 + (flameOffset * 2))
      ..quadraticBezierTo(x + 6 + flameOffset, y - 14, x + 4, y - 4)
      ..close();

    // Outer Red/Amber Glow
    canvas.drawPath(
      flameP,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFEF08A), Color(0xFFF59E0B), Color(0xFFDC2626)],
        ).createShader(Rect.fromLTWH(x - 8, y - 24, 16, 22)),
    );

    // Torch Heat Light Halo
    canvas.drawCircle(
      Offset(x, y - 10),
      14.0,
      Paint()..color = const Color(0xFFFFD700).withValues(alpha: 0.25),
    );
  }

  @override
  bool shouldRepaint(covariant PresidentialPalaceCastlePainter oldDelegate) {
    return oldDelegate.animProg != animProg;
  }
}
