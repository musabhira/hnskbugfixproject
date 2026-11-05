import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🌊 Infinite Living Ocean & High-Altitude Cloud Atmosphere
/// Renders an edge-to-edge, 100% fullscreen satellite / airplane aerial ocean.
/// Zero card boxes, zero boundaries. Endless open world with drifting clouds,
/// wave crest swells, and sunlight reflections.
class InfiniteLivingOceanWidget extends StatelessWidget {
  final Color waterColor;
  final Animation<double>? animation;

  const InfiniteLivingOceanWidget({
    super.key,
    required this.waterColor,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: InfiniteLivingOceanPainter(
        waterColor: waterColor,
        animation: animation,
      ),
      size: Size.infinite,
    );
  }
}

class InfiniteLivingOceanPainter extends CustomPainter {
  final Color waterColor;
  final Animation<double>? animation;

  InfiniteLivingOceanPainter({
    required this.waterColor,
    this.animation,
  }) : super(repaint: animation);

  double get animProgress => animation?.value ?? 0.0;
  double get timeSeconds => animProgress * 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    // 1. 🌊 Infinite Open-World Ocean Radial Gradient (Satellite Depth)
    final oceanBase = RadialGradient(
      center: const Alignment(-0.15, -0.20),
      radius: 1.45,
      colors: [
        Color.lerp(waterColor, const Color(0xFF0284C7), 0.65) ?? const Color(0xFF0284C7),
        Color.lerp(waterColor, const Color(0xFF0369A1), 0.80) ?? const Color(0xFF0369A1),
        const Color(0xFF075985),
        const Color(0xFF033F63),
        const Color(0xFF022B45),
      ],
      stops: const [0.0, 0.35, 0.65, 0.85, 1.0],
    );

    canvas.drawRect(fullRect, Paint()..shader = oceanBase.createShader(fullRect));

    // 2. ✨ High-Altitude Sunlight Sheen (Subtle Specular Glint)
    final sunGlintPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.5),
        radius: 0.9,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(fullRect);
    canvas.drawRect(fullRect, sunGlintPaint);

    // 3. 🌊 Oceanic Wave Swell Arcs (Living Open Waters)
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final faintWavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // 18 naturally distributed wave crest arcs drifting across open sea
    for (int i = 0; i < 18; i++) {
      final speed = 2.5 + (i % 3) * 0.8;
      final driftX = (timeSeconds * speed + i * 42.0) % (size.width + 120) - 60;
      final yRow = (i * 0.055 + 0.04) * size.height;
      final arcWidth = 55.0 + (i % 4) * 18.0;
      final arcHeight = 14.0 + (i % 3) * 6.0;

      final waveRect = Rect.fromCenter(
        center: Offset(driftX, yRow),
        width: arcWidth,
        height: arcHeight,
      );

      final p = (i % 2 == 0) ? wavePaint : faintWavePaint;
      canvas.drawArc(waveRect, 0.15 + (i * 0.2), 1.6, false, p);
    }

    // 4. ☁️ High-Altitude Drifting Airplane Clouds & Soft Ground Shadows
    _drawHighAltitudeClouds(canvas, size);
  }

  void _drawHighAltitudeClouds(Canvas canvas, Size size) {
    // 4 major soft puffy cloud formations cruising across the sky
    final List<_CloudData> clouds = [
      _CloudData(baseX: 0.15, baseY: 0.22, scale: 1.1, speed: 1.8),
      _CloudData(baseX: 0.72, baseY: 0.18, scale: 1.3, speed: 1.4),
      _CloudData(baseX: 0.28, baseY: 0.75, scale: 1.25, speed: 2.1),
      _CloudData(baseX: 0.82, baseY: 0.68, scale: 0.95, speed: 1.6),
    ];

    for (int i = 0; i < clouds.length; i++) {
      final c = clouds[i];
      // Continuous smooth wrap-around drift across screen
      final drift = (timeSeconds * c.speed * 12.0) % (size.width + 280) - 140;
      final cloudCenterX = (c.baseX * size.width + drift) % (size.width + 240) - 120;
      final cloudCenterY = c.baseY * size.height + math.sin(timeSeconds * 0.3 + i) * 8.0;

      // 1. Soft Shadow on the Ocean below (offset by +24, +30)
      final shadowOffset = Offset(cloudCenterX + 22, cloudCenterY + 28);
      _drawCloudCluster(canvas, shadowOffset, c.scale, isShadow: true);

      // 2. Volumetric Soft White Cloud Puffs
      final cloudOffset = Offset(cloudCenterX, cloudCenterY);
      _drawCloudCluster(canvas, cloudOffset, c.scale, isShadow: false);
    }
  }

  void _drawCloudCluster(Canvas canvas, Offset center, double scale, {required bool isShadow}) {
    final puffOffsets = [
      Offset.zero,
      const Offset(-28, -6),
      const Offset(24, -4),
      const Offset(-14, 10),
      const Offset(16, 8),
      const Offset(0, -14),
    ];

    final puffRadii = [34.0, 24.0, 26.0, 22.0, 24.0, 20.0];

    for (int j = 0; j < puffOffsets.length; j++) {
      final pPos = center + puffOffsets[j] * scale;
      final r = puffRadii[j] * scale;

      final Paint paint = Paint();
      if (isShadow) {
        paint.shader = RadialGradient(
          colors: [
            Colors.black.withValues(alpha: 0.13),
            Colors.black.withValues(alpha: 0.06),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: pPos, radius: r * 1.25));
      } else {
        paint.shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.42),
            Colors.white.withValues(alpha: 0.20),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: pPos, radius: r * 1.2));
      }

      canvas.drawCircle(pPos, r * 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant InfiniteLivingOceanPainter oldDelegate) {
    return oldDelegate.waterColor != waterColor;
  }
}

class _CloudData {
  final double baseX;
  final double baseY;
  final double scale;
  final double speed;

  const _CloudData({
    required this.baseX,
    required this.baseY,
    required this.scale,
    required this.speed,
  });
}
