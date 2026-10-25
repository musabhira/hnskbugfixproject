import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🌲 ☀️ ☁️ Kids Cartoon Nature & Open World Living Scenery Background
/// 
/// Recreates the vibrant cartoon RPG open-world atmosphere requested by the user:
/// - Azure Daytime Sky with atmospheric gradient
/// - Radiant Cartoon Sun with rotating golden sunbeams
/// - Drifting fluffy cartoon clouds
/// - Distant rolling pastel mountain ridges
/// - Lush emerald rolling forest hills with cartoon pine & oak trees
/// - Meadow grass tufts, wildflower dots & floating pollen/star motes
/// - Subtle protective nature scrim ensuring 100% text readability
class PocketKidsNatureSceneryBackground extends StatefulWidget {
  final Widget? child;
  final bool showSun;
  final bool showTrees;
  final double hillHeightFraction;
  final double glassOverlayOpacity;

  const PocketKidsNatureSceneryBackground({
    super.key,
    this.child,
    this.showSun = true,
    this.showTrees = true,
    this.hillHeightFraction = 0.38,
    this.glassOverlayOpacity = 0.08,
  });

  @override
  State<PocketKidsNatureSceneryBackground> createState() =>
      _PocketKidsNatureSceneryBackgroundState();
}

class _PocketKidsNatureSceneryBackgroundState
    extends State<PocketKidsNatureSceneryBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Living Animated Cartoon Nature Canvas
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) => CustomPaint(
                painter: _CartoonOpenWorldNaturePainter(
                  progress: _animController.value,
                  showSun: widget.showSun,
                  showTrees: widget.showTrees,
                  hillHeightFraction: widget.hillHeightFraction,
                ),
              ),
            ),
          ),
        ),

        // 2. Translucent Nature Tint for perfect card readability
        if (widget.glassOverlayOpacity > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: const Color(0xFF0F3E34)
                    .withValues(alpha: widget.glassOverlayOpacity * 0.5),
              ),
            ),
          ),

        // 3. Page Content
        if (widget.child != null) Positioned.fill(child: widget.child!),
      ],
    );
  }
}

/// 🎨 CustomPainter drawing the Cartoon Open World Nature Landscape
class _CartoonOpenWorldNaturePainter extends CustomPainter {
  final double progress;
  final bool showSun;
  final bool showTrees;
  final double hillHeightFraction;

  _CartoonOpenWorldNaturePainter({
    required this.progress,
    required this.showSun,
    required this.showTrees,
    required this.hillHeightFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    // --- 1. AZURE DAYTIME CARTOON SKY ---
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0284C7), // Vibrant Deep Sky Blue
          Color(0xFF38BDF8), // Sunny Azure
          Color(0xFF7DD3FC), // Pastel Sky
          Color(0xFFBAE6FD), // Warm Horizon Glow
        ],
        stops: [0.0, 0.35, 0.70, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // --- 2. RADIANT SMILING CARTOON SUN & ROTATING RAYS ---
    if (showSun) {
      final sunCenter = Offset(w * 0.82, h * 0.12);
      const sunRadius = 42.0;

      // Soft sun atmosphere glow
      final glowPaint = Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);
      canvas.drawCircle(sunCenter, sunRadius + 28, glowPaint);

      // Rotating Sun Rays (12 cartoon rays)
      final rayPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.75)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 12; i++) {
        final angle = (i * math.pi / 6) + (progress * math.pi * 2);
        final r1 = sunRadius + 8.0;
        final r2 = sunRadius + (i % 2 == 0 ? 24.0 : 16.0);
        final p1 = sunCenter + Offset(math.cos(angle) * r1, math.sin(angle) * r1);
        final p2 = sunCenter + Offset(math.cos(angle) * r2, math.sin(angle) * r2);
        canvas.drawLine(p1, p2, rayPaint);
      }

      // Golden Sun Body
      final sunBodyPaint = Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFFD700), Color(0xFFF59E0B)],
          stops: [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius));
      canvas.drawCircle(sunCenter, sunRadius, sunBodyPaint);

      // Cartoon Cute Eyes & Smile on Sun
      final eyePaint = Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(sunCenter.dx - 12, sunCenter.dy - 6),
            width: 6,
            height: 9),
        eyePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(sunCenter.dx + 12, sunCenter.dy - 6),
            width: 6,
            height: 9),
        eyePaint,
      );
      // Cheerful Smile arc
      final smilePaint = Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      final smilePath = Path()
        ..moveTo(sunCenter.dx - 14, sunCenter.dy + 8)
        ..quadraticBezierTo(
            sunCenter.dx, sunCenter.dy + 20, sunCenter.dx + 14, sunCenter.dy + 8);
      canvas.drawPath(smilePath, smilePaint);
      // Rosy cheeks
      final cheekPaint = Paint()
        ..color = const Color(0xFFF87171).withValues(alpha: 0.65);
      canvas.drawCircle(Offset(sunCenter.dx - 18, sunCenter.dy + 8), 5, cheekPaint);
      canvas.drawCircle(Offset(sunCenter.dx + 18, sunCenter.dy + 8), 5, cheekPaint);
    }

    // --- 3. DRIFTING CARTOON PUFFY CLOUDS ---
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.88);
    final cloudShadowPaint = Paint()
      ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.5);

    for (int c = 0; c < 4; c++) {
      final speed = 0.15 + (c * 0.08);
      final cx = ((c * 160.0 + (progress * w * speed)) % (w + 200.0)) - 100.0;
      final cy = (h * 0.08) + (c * 38.0);
      _drawCartoonCloud(canvas, cx, cy, 32 + (c % 2 * 10), cloudPaint, cloudShadowPaint);
    }

    // --- 4. DISTANT PASTEL TEAL MOUNTAINS ---
    final distMountainPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF6EE7B7).withValues(alpha: 0.70), // Mint Peak
          const Color(0xFF059669).withValues(alpha: 0.60), // Forest Valley
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.35, w, h * 0.4));

    final mtnPath = Path();
    final mtnBaseY = h * (1.0 - hillHeightFraction * 1.3);
    mtnPath.moveTo(0, h);
    mtnPath.lineTo(0, mtnBaseY);
    mtnPath.quadraticBezierTo(w * 0.25, mtnBaseY - 90, w * 0.52, mtnBaseY - 20);
    mtnPath.quadraticBezierTo(w * 0.78, mtnBaseY - 120, w, mtnBaseY - 40);
    mtnPath.lineTo(w, h);
    mtnPath.close();
    canvas.drawPath(mtnPath, distMountainPaint);

    // --- 5. MIDGROUND EMERALD ROLLING HILLS ---
    final midHillBaseY = h * (1.0 - hillHeightFraction);
    final midHillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF34D399), // Emerald Lime
          Color(0xFF10B981), // Rich Jade
          Color(0xFF059669), // Deep Meadow
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, midHillBaseY - 80, w, h));

    final midHillPath = Path();
    midHillPath.moveTo(0, h);
    midHillPath.lineTo(0, midHillBaseY - 20);
    midHillPath.quadraticBezierTo(
        w * 0.35, midHillBaseY - 80, w * 0.65, midHillBaseY - 10);
    midHillPath.quadraticBezierTo(
        w * 0.88, midHillBaseY - 70, w, midHillBaseY - 30);
    midHillPath.lineTo(w, h);
    midHillPath.close();
    canvas.drawPath(midHillPath, midHillPaint);

    // Midground Cartoon Trees
    if (showTrees) {
      _drawCartoonTree(canvas, w * 0.15, midHillBaseY - 32, 28, const Color(0xFF065F46));
      _drawCartoonPine(canvas, w * 0.28, midHillBaseY - 62, 34, const Color(0xFF047857));
      _drawCartoonTree(canvas, w * 0.72, midHillBaseY - 48, 30, const Color(0xFF065F46));
      _drawCartoonPine(canvas, w * 0.84, midHillBaseY - 58, 38, const Color(0xFF047857));
    }

    // --- 6. FOREGROUND LUSH GREEN NATURE MEADOW ---
    final fgBaseY = h * (1.0 - hillHeightFraction * 0.75);
    final fgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF22C55E), // Cartoon Apple Green
          Color(0xFF16A34A), // Forest Green
          Color(0xFF15803D), // Deep Emerald Grass
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, fgBaseY - 60, w, h));

    final fgPath = Path();
    fgPath.moveTo(0, h);
    fgPath.lineTo(0, fgBaseY + 10);
    fgPath.quadraticBezierTo(
        w * 0.28, fgBaseY - 50, w * 0.60, fgBaseY + 5);
    fgPath.quadraticBezierTo(
        w * 0.85, fgBaseY - 40, w, fgBaseY);
    fgPath.lineTo(w, h);
    fgPath.close();
    canvas.drawPath(fgPath, fgPaint);

    // Cute Grass Tufts & Wildflower Dots on the Foreground Meadow
    _drawGrassTuftsAndFlowers(canvas, w, fgBaseY, h);

    // Foreground Friendly Trees
    if (showTrees) {
      _drawCartoonPine(canvas, w * 0.08, fgBaseY - 20, 46, const Color(0xFF065F46));
      _drawCartoonTree(canvas, w * 0.92, fgBaseY - 14, 42, const Color(0xFF166534));
    }

    // --- 7. FLOATING GOLDEN SUNLIGHT STAR MOTES ---
    final motePaint = Paint()..color = const Color(0xFFFFD700);
    for (int m = 0; m < 14; m++) {
      final mx = (w * 0.05) + ((m * 68.0 + progress * 80.0) % (w * 0.9));
      final my = (h * 0.22) + ((m * 44.0 + math.sin(progress * math.pi * 2 + m) * 20.0) % (h * 0.65));
      final mRadius = 1.8 + (m % 3) * 0.8;
      final alpha = (0.35 + 0.55 * math.sin(progress * math.pi * 2 + m)).clamp(0.1, 0.9);
      canvas.drawCircle(
        Offset(mx, my),
        mRadius,
        mPaintWithAlpha(motePaint, alpha),
      );
    }
  }

  Paint mPaintWithAlpha(Paint p, double alpha) {
    return Paint()
      ..color = p.color.withValues(alpha: alpha)
      ..style = p.style;
  }

  void _drawCartoonCloud(
    Canvas canvas,
    double x,
    double y,
    double size,
    Paint fill,
    Paint shadow,
  ) {
    canvas.drawCircle(Offset(x, y + 4), size * 0.72, shadow);
    canvas.drawCircle(Offset(x + size * 0.6, y - 2 + 4), size * 0.88, shadow);
    canvas.drawCircle(Offset(x + size * 1.25, y + 4), size * 0.68, shadow);

    canvas.drawCircle(Offset(x, y), size * 0.72, fill);
    canvas.drawCircle(Offset(x + size * 0.6, y - 2), size * 0.88, fill);
    canvas.drawCircle(Offset(x + size * 1.25, y), size * 0.68, fill);
  }

  void _drawCartoonTree(
    Canvas canvas,
    double x,
    double y,
    double radius,
    Color leafColor,
  ) {
    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(x, y + radius * 0.7),
            width: radius * 0.32,
            height: radius * 0.9),
        const Radius.circular(4),
      ),
      trunkPaint,
    );
    // Round Lush Foliage (3 cloud-like leafy circles)
    final leafPaint = Paint()..color = leafColor;
    canvas.drawCircle(Offset(x, y), radius * 0.8, leafPaint);
    canvas.drawCircle(Offset(x - radius * 0.45, y + radius * 0.1), radius * 0.6, leafPaint);
    canvas.drawCircle(Offset(x + radius * 0.45, y + radius * 0.1), radius * 0.6, leafPaint);

    // Apple / Fruit dots
    final fruitPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(x - radius * 0.25, y - radius * 0.1), 3.0, fruitPaint);
    canvas.drawCircle(Offset(x + radius * 0.3, y), 3.0, fruitPaint);
  }

  void _drawCartoonPine(
    Canvas canvas,
    double x,
    double y,
    double height,
    Color pineColor,
  ) {
    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF5A2508);
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(x, y + height * 0.45),
          width: height * 0.16,
          height: height * 0.35),
      trunkPaint,
    );
    // 3 Triangular Tiers of Pine Foliage
    final pinePaint = Paint()..color = pineColor;
    for (int tier = 0; tier < 3; tier++) {
      final tierY = y + (tier * (height * 0.26));
      final tierW = (height * 0.45) + (tier * (height * 0.22));
      final tierH = height * 0.42;

      final p = Path();
      p.moveTo(x, tierY - tierH);
      p.lineTo(x - tierW / 2, tierY);
      p.lineTo(x + tierW / 2, tierY);
      p.close();
      canvas.drawPath(p, pinePaint);
    }
  }

  void _drawGrassTuftsAndFlowers(
      Canvas canvas, double w, double startY, double h) {
    final grassPaint = Paint()
      ..color = const Color(0xFF15803D)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final flowerColors = [
      const Color(0xFFFACC15), // Yellow buttercup
      const Color(0xFFF43F5E), // Pink daisy
      const Color(0xFFFFFFFF), // White chamomile
      const Color(0xFFA855F7), // Purple lavender
    ];

    for (int i = 0; i < 16; i++) {
      final gx = (w * 0.04) + (i * (w * 0.062));
      final gy = startY + (i % 3 * 22.0) + 12.0;
      if (gy > h - 10) continue;

      // Cute 3-blade grass tuft
      canvas.drawLine(Offset(gx, gy), Offset(gx - 4, gy - 8), grassPaint);
      canvas.drawLine(Offset(gx, gy), Offset(gx, gy - 11), grassPaint);
      canvas.drawLine(Offset(gx, gy), Offset(gx + 4, gy - 8), grassPaint);

      // Flower dot on every other tuft
      if (i % 2 == 0) {
        final fPaint = Paint()
          ..color = flowerColors[(i ~/ 2) % flowerColors.length];
        canvas.drawCircle(Offset(gx, gy - 13), 3.2, fPaint);
        // Golden flower center
        canvas.drawCircle(
            Offset(gx, gy - 13), 1.2, Paint()..color = const Color(0xFFCA8A04));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CartoonOpenWorldNaturePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
