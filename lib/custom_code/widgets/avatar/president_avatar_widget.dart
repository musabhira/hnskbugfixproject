import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🏛️ Official Presidential Seal Avatar Widget
/// Distinct, executive, and reserved exclusively for The President of Pocket Mates.
class PresidentAvatarWidget extends StatefulWidget {
  final double size;
  final bool showGlow;

  const PresidentAvatarWidget({
    super.key,
    this.size = 48.0,
    this.showGlow = true,
  });

  @override
  State<PresidentAvatarWidget> createState() => _PresidentAvatarWidgetState();
}

class _PresidentAvatarWidgetState extends State<PresidentAvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        final glowProgress = _pulseCtrl.value;
        final glowColor = const Color(0xFFFFD700).withValues(alpha: 0.35 + glowProgress * 0.25);

        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFDF00), // Pure Gold
                Color(0xFFD4AF37), // Metallic Gold
                Color(0xFFAA771C), // Deep Bronze Gold
                Color(0xFFFFE57F), // Shimmer Gold
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: widget.showGlow
                ? [
                    BoxShadow(
                      color: glowColor,
                      blurRadius: 10 + glowProgress * 4,
                      spreadRadius: 1.5,
                    ),
                  ]
                : null,
          ),
          padding: EdgeInsets.all(widget.size * 0.045),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color(0xFF1E293B), // Dark Slate
                  Color(0xFF0A0F1D), // Royal Midnight Navy
                ],
                center: Alignment(0, -0.2),
                radius: 0.9,
              ),
            ),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _PresidentSealPainter(glowProgress: glowProgress),
            ),
          ),
        );
      },
    );
  }
}

class _PresidentSealPainter extends CustomPainter {
  final double glowProgress;

  _PresidentSealPainter({required this.glowProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // 1. Inner Golden Beaded / Star Ring
    final ringPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, size.width * 0.025);

    canvas.drawCircle(c, r * 0.78, ringPaint);

    // 2. Five Golden Stars on Top Arc
    const int starCount = 5;
    final starR = r * 0.62;
    for (int i = 0; i < starCount; i++) {
      final angle = -math.pi / 2 + (i - 2) * 0.28;
      final sx = c.dx + starR * math.cos(angle);
      final sy = c.dy + starR * math.sin(angle);
      _drawMiniStar(canvas, Offset(sx, sy), size.width * 0.038);
    }

    // 3. Laurel Wreath Base Leaves (Bottom Arc)
    final wreathPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.2, size.width * 0.035);

    final wreathRect = Rect.fromCircle(center: c, radius: r * 0.64);
    canvas.drawArc(wreathRect, 0.35, math.pi - 0.7, false, wreathPaint);

    // 4. Center Executive Presidential Shield with Crown Emblem
    final emblemPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    // Center Crown
    final crownPath = Path();
    final cw = size.width * 0.32;
    final ch = size.height * 0.22;
    final cy = c.dy + size.height * 0.04;

    crownPath.moveTo(c.dx - cw / 2, cy);
    crownPath.lineTo(c.dx - cw / 2.3, cy - ch);
    crownPath.lineTo(c.dx - cw / 4, cy - ch * 0.5);
    crownPath.lineTo(c.dx, cy - ch * 1.15);
    crownPath.lineTo(c.dx + cw / 4, cy - ch * 0.5);
    crownPath.lineTo(c.dx + cw / 2.3, cy - ch);
    crownPath.lineTo(c.dx + cw / 2, cy);
    crownPath.close();

    canvas.drawPath(crownPath, emblemPaint);

    // Small Royal Gem dots on Crown Points
    final gemPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(c.dx, cy - ch * 1.15), size.width * 0.025, gemPaint);
    canvas.drawCircle(Offset(c.dx - cw / 2.3, cy - ch), size.width * 0.02, gemPaint);
    canvas.drawCircle(Offset(c.dx + cw / 2.3, cy - ch), size.width * 0.02, gemPaint);
  }

  void _drawMiniStar(Canvas canvas, Offset pos, double r) {
    final paint = Paint()
      ..color = const Color(0xFFFFE082)
      ..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * (4 * math.pi / 5);
      final x = pos.dx + r * math.cos(a);
      final y = pos.dy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PresidentSealPainter oldDelegate) =>
      oldDelegate.glowProgress != glowProgress;
}
