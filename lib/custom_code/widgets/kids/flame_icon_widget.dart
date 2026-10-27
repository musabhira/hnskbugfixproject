import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🔥 Animated Living Flame Icon for Pocket Gamified Activities
class FlameIcon extends StatefulWidget {
  final double size;
  const FlameIcon({super.key, this.size = 28});

  @override
  State<FlameIcon> createState() => _FlameIconState();
}

class _FlameIconState extends State<FlameIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
        ..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 0.8,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: _FlamePainter(_ctrl.value),
        ),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  final double t;
  _FlamePainter(this.t);

  Path _drop(Size s, double w, double h, double sway) {
    final cx = s.width / 2;
    final b = s.height;
    return Path()
      ..moveTo(cx + sway, b - h)
      ..cubicTo(cx + w * .2 + sway, b - h * .6, cx + w, b - h * .45, cx + w * .8, b - h * .2)
      ..quadraticBezierTo(cx + w * .5, b, cx, b)
      ..quadraticBezierTo(cx - w * .5, b, cx - w * .8, b - h * .2)
      ..cubicTo(cx - w, b - h * .45, cx - w * .2 + sway, b - h * .6, cx + sway, b - h);
  }

  @override
  void paint(Canvas cv, Size s) {
    final sway = math.sin(t * 2 * math.pi) * s.width * .08;
    final fl = 1 + .05 * math.sin(t * 4 * math.pi);
    void layer(double w, double h, Color col, {bool glow = false}) {
      final p = _drop(s, s.width * w, s.height * h * fl, sway * h);
      if (glow) {
        cv.drawPath(
          p,
          Paint()
            ..color = col.withValues(alpha: .6)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
      cv.drawPath(p, Paint()..color = col);
    }

    layer(.5, .9, const Color(0xFFFF4D1A), glow: true);
    layer(.36, .68, const Color(0xFFFFA726));
    layer(.2, .42, const Color(0xFFFFE066));
  }

  @override
  bool shouldRepaint(_FlamePainter o) => o.t != t;
}
