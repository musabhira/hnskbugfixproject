import 'dart:convert';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'flame_avatar_widget.dart';
import 'vector_avatar_config.dart';
import 'vector_avatar_painter.dart';

/// Reusable Widget for rendering 2D Vector Avatars & Network/Drawn Avatars
/// Automatically leverages the Flame Game Engine for interactive animations and aura particles!
class VectorAvatarWidget extends StatelessWidget {
  final VectorAvatarConfig? config;
  final double size;
  final bool showAura;
  final VoidCallback? onTap;
  final bool isInteractive;
  final BorderRadius? borderRadius;
  final bool? useFlame;

  const VectorAvatarWidget({
    super.key,
    this.config,
    this.size = 100.0,
    this.showAura = true,
    this.onTap,
    this.isInteractive = false,
    this.borderRadius,
    this.useFlame,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = config ?? const VectorAvatarConfig();
    final imgUrl = effectiveConfig.networkImageUrl ?? effectiveConfig.imageUrl;
    final drawingImg = effectiveConfig.customDrawingImage;

    Widget clipChild(Widget child) {
      if (borderRadius != null) {
        return ClipRRect(borderRadius: borderRadius!, child: child);
      }
      return ClipOval(child: child);
    }

    Widget innerContent;
    final bool isImageBased = (drawingImg != null && drawingImg.isNotEmpty) || (imgUrl != null && imgUrl.isNotEmpty);

    if (drawingImg != null && drawingImg.isNotEmpty) {
      if (drawingImg.startsWith('data:image')) {
        final base64Str = drawingImg.split(',').last;
        final bytes = base64Decode(base64Str);
        innerContent = clipChild(
          Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      } else {
        innerContent = clipChild(
          CachedNetworkImage(
            imageUrl: drawingImg,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
          ),
        );
      }
    } else if (imgUrl != null && imgUrl.isNotEmpty) {
      if (imgUrl.startsWith('assets/')) {
        innerContent = clipChild(
          Image.asset(
            imgUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => CustomPaint(
              size: Size(size, size),
              painter: VectorAvatarPainter(
                config: effectiveConfig,
                showBackgroundAura: false,
              ),
            ),
          ),
        );
      } else {
        innerContent = clipChild(
          CachedNetworkImage(
            imageUrl: imgUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: size,
              height: size,
              color: const Color(0xFF1E1E24),
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFFC00)),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => CustomPaint(
              size: Size(size, size),
              painter: VectorAvatarPainter(
                config: effectiveConfig,
                showBackgroundAura: false,
              ),
            ),
          ),
        );
      }
    } else {
      // Only use the GPU-backed FlameGame for large avatar displays (≥120px).
      // Smaller avatars in lists/feeds use CustomPaint to avoid exhausting the
      // Windows ANGLE EGL context pool (EGL_CONTEXT_LOST / error 12302).
      final shouldUseFlame = useFlame ?? (size >= 120);
      if (shouldUseFlame) {
        innerContent = FlameAvatarWidget(
          config: effectiveConfig,
          size: size,
          showAura: showAura,
          onTap: onTap,
          isInteractive: isInteractive,
          borderRadius: borderRadius,
        );
      } else if (showAura) {
        innerContent = _AnimatedVectorAvatar(
          config: effectiveConfig,
          size: size,
          showAura: showAura,
          borderRadius: borderRadius,
        );
      } else {
        innerContent = CustomPaint(
          size: Size(size, size),
          painter: VectorAvatarPainter(
            config: effectiveConfig,
            showBackgroundAura: showAura,
            borderRadius: borderRadius,
          ),
        );
      }
    }

    Widget avatarWidget = isImageBased
        ? Container(
            width: size,
            height: size,
            decoration: showAura
                ? BoxDecoration(
                    shape: borderRadius != null ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFFFFC00).withValues(alpha: 0.85),
                      width: size * 0.03,
                    ),
                  )
                : null,
            child: innerContent,
          )
        : SizedBox(
            width: size,
            height: size,
            child: innerContent,
          );

    if (onTap != null || isInteractive) {
      avatarWidget = GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}

/// 🌟 Living Animated Vector Avatar Widget
/// Replicates the FlameAvatarGame micro-motion and spreading upward flame particles
/// using native Flutter Canvas and Ticker (zero GPU EGL context overhead).
class _AnimatedVectorAvatar extends StatefulWidget {
  final VectorAvatarConfig config;
  final double size;
  final bool showAura;
  final BorderRadius? borderRadius;

  const _AnimatedVectorAvatar({
    required this.config,
    required this.size,
    required this.showAura,
    this.borderRadius,
  });

  @override
  State<_AnimatedVectorAvatar> createState() => _AnimatedVectorAvatarState();
}

class _AnimatedVectorAvatarState extends State<_AnimatedVectorAvatar>
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
    )..addListener(_onTick)
     ..repeat();
  }

  void _onTick() {
    final now = DateTime.now();
    final dt = (now.difference(_lastTick).inMicroseconds / 1000000.0).clamp(0.001, 0.05);
    _lastTick = now;
    _elapsedTime += dt;

    // Update active particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i].update(dt);
      if (!_particles[i].isAlive) {
        _particles.removeAt(i);
      }
    }

    // Spawn subtle floating aura motes spreading upward
    if (widget.showAura && _particles.length < 12 && _random.nextDouble() < 0.28) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 15.0 + _random.nextDouble() * 25.0;
      final dist = (widget.size * 0.42);
      final px = widget.size / 2 + math.cos(angle) * dist;
      final py = widget.size / 2 + math.sin(angle) * dist;

      final accentColor = VectorAvatarConfig.parseHex(
        widget.config.outfitAccentColor,
        fallback: const Color(0xFFFFFC00),
      );

      _particles.add(
        _FlameAuraParticle(
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

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _AnimatedVectorAvatarPainter(
        config: widget.config,
        showAura: widget.showAura,
        particles: _particles,
        elapsedTime: _elapsedTime,
        borderRadius: widget.borderRadius,
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

class _AnimatedVectorAvatarPainter extends CustomPainter {
  final VectorAvatarConfig config;
  final bool showAura;
  final List<_FlameAuraParticle> particles;
  final double elapsedTime;
  final BorderRadius? borderRadius;

  _AnimatedVectorAvatarPainter({
    required this.config,
    required this.showAura,
    required this.particles,
    required this.elapsedTime,
    this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Spreading radial aura glow in the backdrop
    if (showAura) {
      final auraColor = VectorAvatarConfig.parseHex(
        config.outfitAccentColor,
        fallback: const Color(0xFFFFFC00),
      );
      final spreadPulse = (math.sin(elapsedTime * 2.5) + 1.0) / 2.0;
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            auraColor.withValues(alpha: 0.35 + 0.15 * spreadPulse),
            auraColor.withValues(alpha: 0.10 * spreadPulse),
            Colors.transparent,
          ],
          stops: const [0.0, 0.65, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.65));
      canvas.drawCircle(center, size.width * 0.65, glowPaint);
    }

    // 2. Render Floating Flame Aura Particles Behind Avatar (spreading upward)
    for (final p in particles) {
      final pPaint = Paint()
        ..color = p.color.withValues(alpha: (p.lifeProgress * 0.75).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.lifeProgress, pPaint);
    }

    // 3. Living Breathing Micro-Motion (Scale & Subtle Bob)
    canvas.save();
    final breathing = math.sin(elapsedTime * 2.5) * 0.018;
    final totalScale = (1.0 + breathing).clamp(0.95, 1.25);
    final bobY = math.sin(elapsedTime * 2.5) * (size.height * 0.012);

    canvas.translate(center.dx, center.dy + bobY);
    canvas.scale(totalScale);
    canvas.translate(-center.dx, -center.dy);

    // 4. Render the Vector/Flame Avatar
    final painter = VectorAvatarPainter(
      config: config,
      showBackgroundAura: showAura,
      animationValue: (elapsedTime * 0.8) % 1.0,
      borderRadius: borderRadius,
    );
    painter.paint(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AnimatedVectorAvatarPainter oldDelegate) => true;
}

