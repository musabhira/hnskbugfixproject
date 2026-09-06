import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'vector_avatar_config.dart';
import 'vector_avatar_painter.dart';

/// 🌟 Flame-Powered Living Animal Avatar Game
/// Features dynamic game-loop breathing, glowing ambient aura,
/// floating Jackie Chan talisman stones, and interactive particle bursts!
class FlameAvatarGame extends FlameGame with TapCallbacks {
  VectorAvatarConfig config;
  final bool showAura;
  final VoidCallback? onAvatarTapped;

  double _elapsedTime = 0.0;
  double _bounceScale = 1.0;
  final List<_FlameParticle> _particles = [];
  final math.Random _random = math.Random();

  FlameAvatarGame({
    required this.config,
    this.showAura = true,
    this.onAvatarTapped,
  });

  @override
  Color backgroundColor() => Colors.transparent;

  void updateConfig(VectorAvatarConfig newConfig) {
    config = newConfig;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;

    if (!hasLayout) return;

    // Smooth recovery from tap bounce
    if (_bounceScale > 1.0) {
      _bounceScale = math.max(1.0, _bounceScale - dt * 2.5);
    }

    // Update active particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i].update(dt);
      if (!_particles[i].isAlive) {
        _particles.removeAt(i);
      }
    }

    // Occasionally spawn subtle floating aura motes
    if (showAura && _particles.length < 12 && _random.nextDouble() < 0.25) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 15.0 + _random.nextDouble() * 25.0;
      final dist = (size.x * 0.42);
      final px = size.x / 2 + math.cos(angle) * dist;
      final py = size.y / 2 + math.sin(angle) * dist;

      final accentColor = VectorAvatarConfig.parseHex(
        config.outfitAccentColor,
        fallback: const Color(0xFFFFFC00),
      );

      _particles.add(
        _FlameParticle(
          x: px,
          y: py,
          vx: math.cos(angle) * speed * 0.5,
          vy: -speed * 0.7,
          color: accentColor,
          size: 2.0 + _random.nextDouble() * 2.5,
          lifespan: 0.8 + _random.nextDouble() * 0.7,
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    if (!hasLayout || size.x <= 0 || size.y <= 0) return;

    super.render(canvas);

    final center = Offset(size.x / 2, size.y / 2);

    // 1. Render Floating Flame Aura Particles Behind Avatar
    for (final p in _particles) {
      final pPaint = Paint()
        ..color = p.color.withValues(alpha: (p.lifeProgress * 0.7).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.lifeProgress, pPaint);
    }

    // 2. Living Breathing Micro-Motion (Scale & Subtle Bob)
    canvas.save();
    final breathing = math.sin(_elapsedTime * 2.5) * 0.018;
    final totalScale = (_bounceScale + breathing).clamp(0.95, 1.25);
    final bobY = math.sin(_elapsedTime * 2.5) * (size.y * 0.012);

    canvas.translate(center.dx, center.dy + bobY);
    canvas.scale(totalScale);
    canvas.translate(-center.dx, -center.dy);

    // 3. Render the 90-Species Vector/Flame Avatar
    final painter = VectorAvatarPainter(
      config: config,
      showBackgroundAura: showAura,
      animationValue: (_elapsedTime * 0.8) % 1.0,
    );
    painter.paint(canvas, Size(size.x, size.y));

    canvas.restore();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    HapticFeedback.lightImpact();

    // Trigger joyful bounce
    _bounceScale = 1.14;

    if (!hasLayout || size.x <= 0 || size.y <= 0) {
      onAvatarTapped?.call();
      return;
    }

    // Burst of magical Flame celebratory particles
    final center = Offset(size.x / 2, size.y / 2);
    final accentColor = VectorAvatarConfig.parseHex(
      config.outfitAccentColor,
      fallback: const Color(0xFFFFD700),
    );

    for (int i = 0; i < 18; i++) {
      final angle = (i * math.pi * 2 / 18) + (_random.nextDouble() * 0.2);
      final speed = 40.0 + _random.nextDouble() * 60.0;
      _particles.add(
        _FlameParticle(
          x: center.dx,
          y: center.dy,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          color: (i % 2 == 0) ? accentColor : Colors.white,
          size: 3.5 + _random.nextDouble() * 2.5,
          lifespan: 0.6 + _random.nextDouble() * 0.4,
        ),
      );
    }

    onAvatarTapped?.call();
  }
}

class _FlameParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double lifespan;
  double remainingLife;

  _FlameParticle({
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

/// 🌟 Flame-Powered Animal Avatar Widget
/// Seamlessly wraps FlameGame inside Flutter with zero configuration!
class FlameAvatarWidget extends StatefulWidget {
  final VectorAvatarConfig config;
  final double size;
  final bool showAura;
  final VoidCallback? onTap;
  final bool isInteractive;
  final BorderRadius? borderRadius;

  const FlameAvatarWidget({
    super.key,
    required this.config,
    this.size = 100.0,
    this.showAura = true,
    this.onTap,
    this.isInteractive = true,
    this.borderRadius,
  });

  @override
  State<FlameAvatarWidget> createState() => _FlameAvatarWidgetState();
}

class _FlameAvatarWidgetState extends State<FlameAvatarWidget> {
  late FlameAvatarGame _game;

  @override
  void initState() {
    super.initState();
    _game = FlameAvatarGame(
      config: widget.config,
      showAura: widget.showAura,
      onAvatarTapped: widget.onTap,
    );
  }

  @override
  void didUpdateWidget(covariant FlameAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _game.updateConfig(widget.config);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget gameView = SizedBox(
      width: widget.size,
      height: widget.size,
      child: GameWidget(game: _game),
    );

    if (widget.borderRadius != null) {
      gameView = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: gameView,
      );
    }

    if (widget.onTap != null && !widget.isInteractive) {
      gameView = GestureDetector(
        onTap: widget.onTap,
        child: gameView,
      );
    }

    return gameView;
  }
}
