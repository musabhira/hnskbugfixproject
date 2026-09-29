import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🌟 Living Spreading Aura Widget
/// Provides organic radial aura spread, upward floating particles/motes,
/// and subtle breathing micro-motion around ANY child (President avatar, Tools, Groups, etc.)
class LivingSpreadingAura extends StatefulWidget {
  final Widget child;
  final Color color;
  final double size;
  final bool animate;
  final BorderRadius? borderRadius;
  final double speed;
  final int maxParticles;
  final double intensity;

  const LivingSpreadingAura({
    super.key,
    required this.child,
    required this.color,
    this.size = 50.0,
    this.animate = true,
    this.borderRadius,
    this.speed = 1.0,
    this.maxParticles = 12,
    this.intensity = 1.0,
  });

  @override
  State<LivingSpreadingAura> createState() => _LivingSpreadingAuraState();
}

class _LivingSpreadingAuraState extends State<LivingSpreadingAura>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_FlameAuraParticle> _particles = [];
  final math.Random _random = math.Random();
  double _elapsedTime = 0.0;
  DateTime _lastTick = DateTime.now();

  @override
  void initState() {
    super.initState();
    _lastTick = DateTime.now();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_onTick);
    if (widget.animate) {
      _controller.repeat();
    }
  }

  void _onTick() {
    final now = DateTime.now();
    final dt = (now.difference(_lastTick).inMicroseconds / 1000000.0).clamp(0.001, 0.05) * widget.speed;
    _lastTick = now;
    _elapsedTime += dt;

    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i].update(dt);
      if (!_particles[i].isAlive) {
        _particles.removeAt(i);
      }
    }

    if (widget.animate &&
        _particles.length < widget.maxParticles &&
        _random.nextDouble() < (0.28 * widget.speed.clamp(0.2, 1.0))) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = (15.0 + _random.nextDouble() * 25.0) * widget.speed.clamp(0.4, 1.0);
      final dist = (widget.size * 0.44);
      final px = widget.size / 2 + math.cos(angle) * dist;
      final py = widget.size / 2 + math.sin(angle) * dist;

      _particles.add(
        _FlameAuraParticle(
          x: px,
          y: py,
          vx: math.cos(angle) * speed * 0.5,
          vy: -speed * 0.7,
          color: widget.color,
          size: 1.8 + _random.nextDouble() * 2.0,
          lifespan: (0.8 + _random.nextDouble() * 0.7) / widget.speed.clamp(0.4, 1.0),
        ),
      );
    }

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Spreading radial aura and upward floating flame motes
          Positioned.fill(
            child: CustomPaint(
              painter: _SpreadingAuraPainter(
                color: widget.color,
                particles: _particles,
                elapsedTime: _elapsedTime,
                intensity: widget.intensity,
              ),
            ),
          ),

          // 2. Subtle living breathing micro-motion
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final breathing = math.sin(_elapsedTime * 2.5) * (0.018 * widget.speed.clamp(0.3, 1.0));
              final totalScale = (1.0 + breathing).clamp(0.95, 1.25);
              final bobY = math.sin(_elapsedTime * 2.5) * (widget.size * 0.012 * widget.speed.clamp(0.3, 1.0));

              return Transform.translate(
                offset: Offset(0, bobY),
                child: Transform.scale(
                  scale: totalScale,
                  child: child,
                ),
              );
            },
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _FlameAuraParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double lifespan;
  double remainingLife;

  _FlameAuraParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.lifespan,
  }) : remainingLife = lifespan;

  bool get isAlive => remainingLife > 0;
  double get lifeProgress => (remainingLife / lifespan).clamp(0.0, 1.0);

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    remainingLife -= dt;
  }
}

class _SpreadingAuraPainter extends CustomPainter {
  final Color color;
  final List<_FlameAuraParticle> particles;
  final double elapsedTime;
  final double intensity;

  _SpreadingAuraPainter({
    required this.color,
    required this.particles,
    required this.elapsedTime,
    this.intensity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);

    // Spreading radial aura glow in backdrop
    final spreadPulse = (math.sin(elapsedTime * 2.5) + 1.0) / 2.0;
    final baseAlpha = (0.35 + 0.15 * spreadPulse) * intensity;
    final midAlpha = (0.10 * spreadPulse) * intensity;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: baseAlpha.clamp(0.0, 1.0)),
          color.withValues(alpha: midAlpha.clamp(0.0, 1.0)),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.65));
    canvas.drawCircle(center, size.width * 0.65, glowPaint);

    // Upward floating flame particles
    for (final p in particles) {
      final pPaint = Paint()
        ..color = p.color.withValues(alpha: (p.lifeProgress * 0.75 * intensity).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.lifeProgress, pPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpreadingAuraPainter oldDelegate) => true;
}
