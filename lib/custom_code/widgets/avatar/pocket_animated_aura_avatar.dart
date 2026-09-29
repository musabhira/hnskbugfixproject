import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'vector_avatar_config.dart';
import 'vector_avatar_widget.dart';

/// 🌟 PocketAnimatedAuraAvatar
/// Renders an organic, breathing avatar with a spreading radial aura glow behind it.
/// Inspired by the original animated avatar with spreading color pulse and Snapchat story ring.
class PocketAnimatedAuraAvatar extends StatefulWidget {
  final double size;
  final VectorAvatarConfig? config;
  final String? imageUrl;
  final String? name;
  final bool hasStory;
  final bool isOnline;
  final Color? auraColor;
  final bool animate;
  final VoidCallback? onTap;

  const PocketAnimatedAuraAvatar({
    super.key,
    this.size = 52.0,
    this.config,
    this.imageUrl,
    this.name,
    this.hasStory = false,
    this.isOnline = false,
    this.auraColor,
    this.animate = true,
    this.onTap,
  });

  @override
  State<PocketAnimatedAuraAvatar> createState() => _PocketAnimatedAuraAvatarState();
}

class _PocketAnimatedAuraAvatarState extends State<PocketAnimatedAuraAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowSpreadAnimation;
  late Animation<double> _glowOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.035).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _glowSpreadAnimation = Tween<double>(begin: 0.12, end: 0.32).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _glowOpacityAnimation = Tween<double>(begin: 0.30, end: 0.72).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PocketAnimatedAuraAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _resolveAuraColor() {
    if (widget.auraColor != null) return widget.auraColor!;
    if (widget.config != null) {
      return VectorAvatarConfig.parseHex(
        widget.config!.outfitColor,
        fallback: const Color(0xFFFFD700),
      );
    }
    return const Color(0xFFFFD700); // Sovereign Gold Default
  }

  @override
  Widget build(BuildContext context) {
    final auraBaseColor = _resolveAuraColor();
    final totalDimension = widget.size * 1.5;

    Widget avatarCore;
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      avatarCore = ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl!,
          width: widget.size,
          height: widget.size,
          memCacheWidth: 160,
          memCacheHeight: 160,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: widget.size,
            height: widget.size,
            color: const Color(0xFF1E293B),
            child: Center(
              child: SizedBox(
                width: widget.size * 0.35,
                height: widget.size * 0.35,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFFFD700),
                ),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => widget.config != null
              ? VectorAvatarWidget(
                  config: widget.config,
                  size: widget.size,
                  showAura: false,
                )
              : Container(
                  width: widget.size,
                  height: widget.size,
                  color: const Color(0xFF1E293B),
                  child: Center(
                    child: Text(
                      (widget.name != null && widget.name!.isNotEmpty)
                          ? widget.name![0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.size * 0.45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
        ),
      );
    } else {
      avatarCore = VectorAvatarWidget(
        config: widget.config ?? const VectorAvatarConfig(),
        size: widget.size,
        showAura: false,
      );
    }

    Widget content = SizedBox(
      width: totalDimension,
      height: totalDimension,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🌈 1. Spreading Breathing Ambient Aura Glow
          if (widget.animate)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final spreadRatio = _glowSpreadAnimation.value;
                final glowOpacity = _glowOpacityAnimation.value;
                final glowRadius = (widget.size / 2) + (widget.size * spreadRatio);

                return CustomPaint(
                  size: Size(totalDimension, totalDimension),
                  painter: _AuraSpreadPainter(
                    center: Offset(totalDimension / 2, totalDimension / 2),
                    radius: glowRadius,
                    color: auraBaseColor.withValues(alpha: glowOpacity),
                  ),
                );
              },
            )
          else
            CustomPaint(
              size: Size(totalDimension, totalDimension),
              painter: _AuraSpreadPainter(
                center: Offset(totalDimension / 2, totalDimension / 2),
                radius: (widget.size / 2) + 6,
                color: auraBaseColor.withValues(alpha: 0.45),
              ),
            ),

          // ⭕ 2. Snapchat-Style Story Ring (if user has active story/vibe)
          if (widget.hasStory)
            Container(
              width: widget.size + 8,
              height: widget.size + 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(
                  colors: [
                    Color(0xFF00C6FF),
                    Color(0xFF0072FF),
                    Color(0xFFFF007F),
                    Color(0xFFFFD700),
                    Color(0xFF00C6FF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0072FF).withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),

          // 🐾 3. The Animated Avatar Itself (Subtle breathing scale & gentle float)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = widget.animate ? _scaleAnimation.value : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.hasStory
                          ? Colors.black
                          : auraBaseColor.withValues(alpha: 0.75),
                      width: widget.hasStory ? 2.0 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
            child: avatarCore,
          ),

          // 🟢 4. Online Indicator Dot
          if (widget.isOnline)
            Positioned(
              right: (totalDimension - widget.size) / 2 + 1,
              bottom: (totalDimension - widget.size) / 2 + 1,
              child: Container(
                width: widget.size * 0.25,
                height: widget.size * 0.25,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981), // Emerald online
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: content,
      );
    }

    return content;
  }
}

/// Custom painter that draws a smooth spreading radial gradient behind the avatar
class _AuraSpreadPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  _AuraSpreadPainter({
    required this.center,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: color.a * 0.5),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AuraSpreadPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.color != color ||
        oldDelegate.center != center;
  }
}
