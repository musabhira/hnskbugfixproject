import 'dart:math';
import 'package:flutter/material.dart';

/// Reusable Rich Doodle Background Canvas for Pocket Mates pages
class PocketDoodleBackgroundPainter extends CustomPainter {
  final Color color;
  final bool isDark;
  final double opacityMultiplier;

  PocketDoodleBackgroundPainter({
    this.color = const Color(0xFFFFFC00),
    this.isDark = true,
    this.opacityMultiplier = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseAlpha = (isDark ? 0.045 : 0.035) * opacityMultiplier;
    final paint = Paint()
      ..color = color.withValues(alpha: baseAlpha.clamp(0.01, 0.2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    const stepX = 110.0;
    const stepY = 130.0;

    int type = 0;
    for (double y = 20; y < size.height + 80; y += stepY) {
      for (double x = 20; x < size.width + 80; x += stepX) {
        final cx = x + ((y ~/ stepY) % 2 == 0 ? 0 : 40);
        final cy = y;

        switch (type % 10) {
          case 0:
            _drawStar(canvas, cx, cy, 10, paint);
            break;
          case 1:
            _drawSpeechBubble(canvas, cx, cy, 18, 12, paint);
            break;
          case 2:
            _drawGamepad(canvas, cx, cy, 20, 12, paint);
            break;
          case 3:
            _drawLightning(canvas, cx, cy, paint);
            break;
          case 4:
            _drawHeart(canvas, cx, cy, paint);
            break;
          case 5:
            _drawCrown(canvas, cx, cy, paint);
            break;
          case 6:
            _drawPencil(canvas, cx, cy, paint);
            break;
          case 7:
            _drawCoffee(canvas, cx, cy, paint);
            break;
          case 8:
            _drawPlanet(canvas, cx, cy, paint);
            break;
          case 9:
            _drawMusicNote(canvas, cx, cy, paint);
            break;
        }
        type++;
      }
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double radius, Paint p) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * pi / 5) - (pi / 2);
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, p);
  }

  void _drawSpeechBubble(Canvas canvas, double cx, double cy, double w, double h, Paint p) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
      const Radius.circular(5),
    );
    canvas.drawRRect(rect, p);
    final tail = Path()
      ..moveTo(cx - 3, cy + h / 2)
      ..lineTo(cx - 7, cy + h / 2 + 4)
      ..lineTo(cx + 2, cy + h / 2);
    canvas.drawPath(tail, p);
  }

  void _drawGamepad(Canvas canvas, double cx, double cy, double w, double h, Paint p) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, p);
    canvas.drawLine(Offset(cx - 4, cy - 3), Offset(cx - 4, cy + 3), p);
    canvas.drawLine(Offset(cx - 7, cy), Offset(cx - 1, cy), p);
    canvas.drawCircle(Offset(cx + 4, cy), 1.2, p);
  }

  void _drawLightning(Canvas canvas, double cx, double cy, Paint p) {
    final path = Path()
      ..moveTo(cx + 2, cy - 7)
      ..lineTo(cx - 4, cy)
      ..lineTo(cx, cy)
      ..lineTo(cx - 2, cy + 7)
      ..lineTo(cx + 4, cy - 1)
      ..lineTo(cx, cy - 1)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawHeart(Canvas canvas, double cx, double cy, Paint p) {
    final path = Path()
      ..moveTo(cx, cy + 5)
      ..cubicTo(cx - 6, cy + 1, cx - 6, cy - 4, cx, cy - 2)
      ..cubicTo(cx + 6, cy - 4, cx + 6, cy + 1, cx, cy + 5);
    canvas.drawPath(path, p);
  }

  void _drawCrown(Canvas canvas, double cx, double cy, Paint p) {
    final path = Path()
      ..moveTo(cx - 7, cy + 4)
      ..lineTo(cx - 8, cy - 3)
      ..lineTo(cx - 3, cy)
      ..lineTo(cx, cy - 5)
      ..lineTo(cx + 3, cy)
      ..lineTo(cx + 8, cy - 3)
      ..lineTo(cx + 7, cy + 4)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawPencil(Canvas canvas, double cx, double cy, Paint p) {
    final path = Path()
      ..moveTo(cx - 5, cy + 5)
      ..lineTo(cx + 4, cy - 4)
      ..lineTo(cx + 6, cy - 2)
      ..lineTo(cx - 3, cy + 7)
      ..lineTo(cx - 6, cy + 7)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawCoffee(Canvas canvas, double cx, double cy, Paint p) {
    final path = Path()
      ..moveTo(cx - 5, cy - 3)
      ..lineTo(cx + 5, cy - 3)
      ..lineTo(cx + 4, cy + 4)
      ..lineTo(cx - 4, cy + 4)
      ..close();
    canvas.drawPath(path, p);
    canvas.drawArc(Rect.fromLTWH(cx + 3, cy - 2, 4, 4), -pi / 2, pi, false, p);
  }

  void _drawPlanet(Canvas canvas, double cx, double cy, Paint p) {
    canvas.drawCircle(Offset(cx, cy), 5, p);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 16, height: 5),
      p,
    );
  }

  void _drawMusicNote(Canvas canvas, double cx, double cy, Paint p) {
    canvas.drawCircle(Offset(cx - 3, cy + 3), 2, p);
    canvas.drawCircle(Offset(cx + 3, cy + 1), 2, p);
    canvas.drawLine(Offset(cx - 1, cy + 3), Offset(cx - 1, cy - 4), p);
    canvas.drawLine(Offset(cx + 5, cy + 1), Offset(cx + 5, cy - 6), p);
    canvas.drawLine(Offset(cx - 1, cy - 4), Offset(cx + 5, cy - 6), p);
  }

  @override
  bool shouldRepaint(covariant PocketDoodleBackgroundPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isDark != isDark ||
        oldDelegate.opacityMultiplier != opacityMultiplier;
  }
}
