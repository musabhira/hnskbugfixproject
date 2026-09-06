import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🔥 Ember / Flame Spark Model for lightweight background rendering
class _FlameEmber {
  double x; // Normalized 0.0 - 1.0
  double y; // Normalized 0.0 - 1.0
  double size;
  double speed;
  double opacity;
  double phase;
  Color color;

  _FlameEmber({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
    required this.color,
  });

  static _FlameEmber createRandom(math.Random rand, {bool initial = false}) {
    // Warm flame color spectrum
    const colors = [
      Color(0xFFFFFC00), // Signature yellow
      Color(0xFFFFD700), // Radiant gold
      Color(0xFFFF8906), // Vivid ember orange
      Color(0xFFEF4444), // Crimson fire
      Color(0xFFF59E0B), // Warm amber
    ];

    return _FlameEmber(
      x: rand.nextDouble(),
      y: initial ? rand.nextDouble() : (1.0 + rand.nextDouble() * 0.1),
      size: 2.0 + rand.nextDouble() * 3.5,
      speed: 0.0006 + rand.nextDouble() * 0.0014,
      opacity: 0.25 + rand.nextDouble() * 0.55,
      phase: rand.nextDouble() * math.pi * 2,
      color: colors[rand.nextInt(colors.length)],
    );
  }
}

/// 🔥 Beautiful Subtle Ambient Flame & Ember Canvas for Chat Backgrounds
class PocketAmbientFlameBackground extends StatefulWidget {
  final Widget? child;
  final bool showTopFlameGlow;
  final double emberDensity; // 0.0 - 1.0
  final bool isEnglishHub;

  const PocketAmbientFlameBackground({
    super.key,
    this.child,
    this.showTopFlameGlow = true,
    this.emberDensity = 0.7,
    this.isEnglishHub = false,
  });

  @override
  State<PocketAmbientFlameBackground> createState() =>
      _PocketAmbientFlameBackgroundState();
}

class _PocketAmbientFlameBackgroundState
    extends State<PocketAmbientFlameBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final math.Random _random = math.Random();
  late List<_FlameEmber> _embers;

  @override
  void initState() {
    super.initState();
    // Initialize 24-32 subtle floating embers
    final count = (20 + (14 * widget.emberDensity)).round();
    _embers = List.generate(count, (_) => _FlameEmber.createRandom(_random, initial: true));

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _animController.addListener(_updateEmbers);
  }

  void _updateEmbers() {
    for (final ember in _embers) {
      ember.y -= ember.speed;
      ember.phase += 0.03;
      // Slight sinusoidal horizontal drift like real rising heat
      ember.x += math.sin(ember.phase) * 0.0008;

      // Respawn at bottom when drifted past top
      if (ember.y < -0.05) {
        ember.y = 1.0 + _random.nextDouble() * 0.08;
        ember.x = _random.nextDouble();
      }
      if (ember.x < 0.0) ember.x = 1.0;
      if (ember.x > 1.0) ember.x = 0.0;
    }
  }

  @override
  void dispose() {
    _animController.removeListener(_updateEmbers);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Subtle warm bottom flame aura gradient
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isEnglishHub
                        ? [
                            const Color(0xFFFFD700).withValues(alpha: 0.08),
                            Colors.transparent,
                            const Color(0xFFFF8906).withValues(alpha: 0.12),
                          ]
                        : [
                            const Color(0xFFFFFC00).withValues(alpha: 0.05),
                            Colors.transparent,
                            const Color(0xFFEF4444).withValues(alpha: 0.07),
                          ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 2. Animated rising flame embers
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _FlameEmbersPainter(
                      embers: _embers,
                      progress: _animController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Top subtle ambient flame streak
          if (widget.showTopFlameGlow)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 4,
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    final pulse = 0.5 + 0.5 * math.sin(_animController.value * math.pi * 2);
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            (widget.isEnglishHub ? const Color(0xFFFFD700) : const Color(0xFFFFFC00))
                                .withValues(alpha: 0.45 + 0.35 * pulse),
                            const Color(0xFFFF8906).withValues(alpha: 0.55 + 0.25 * pulse),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.35, 0.65, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isEnglishHub ? const Color(0xFFFFD700) : const Color(0xFFFF8906))
                                .withValues(alpha: 0.3 * pulse),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

          // Child content if provided
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

/// 🎨 CustomPainter for smooth floating flame particles
class _FlameEmbersPainter extends CustomPainter {
  final List<_FlameEmber> embers;
  final double progress;

  _FlameEmbersPainter({
    required this.embers,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final ember in embers) {
      final px = ember.x * size.width;
      final py = ember.y * size.height;

      // Subtle breathing twinkle
      final twinkle = 0.7 + 0.3 * math.sin(ember.phase + progress * math.pi * 2);
      final currentAlpha = (ember.opacity * twinkle).clamp(0.0, 1.0);

      paint.color = ember.color.withValues(alpha: currentAlpha * 0.75);

      // Draw soft outer glow
      canvas.drawCircle(
        Offset(px, py),
        ember.size * 1.8,
        Paint()
          ..color = ember.color.withValues(alpha: currentAlpha * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );

      // Core ember spark
      canvas.drawCircle(Offset(px, py), ember.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlameEmbersPainter oldDelegate) => true;
}
