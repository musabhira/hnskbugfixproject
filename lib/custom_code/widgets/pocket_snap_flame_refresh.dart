import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// ✨ Playful Floating Doodle Sparkle Particle
class _DoodleParticle {
  double xRatio;
  double yRatio;
  double size;
  double speed;
  double opacity;
  double wobblePhase;
  String glyph;
  Color color;

  _DoodleParticle({
    required this.xRatio,
    required this.yRatio,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.wobblePhase,
    required this.glyph,
    required this.color,
  });

  static _DoodleParticle random(math.Random rand) {
    const glyphs = ['⭐', '✨', '🐾', '✦', '💖', '⚡'];
    const colors = [
      Color(0xFFFFFC00), // Snapchat yellow
      Color(0xFF38BDF8), // Cyan sparkle
      Color(0xFFF472B6), // Pink heart
      Color(0xFFA78BFA), // Violet star
      Color(0xFFFFFFFF), // Pure sparkle
    ];
    return _DoodleParticle(
      xRatio: 0.15 + rand.nextDouble() * 0.7,
      yRatio: 0.1 + rand.nextDouble() * 0.8,
      size: 11.0 + rand.nextDouble() * 7.0,
      speed: 0.6 + rand.nextDouble() * 1.2,
      opacity: 0.4 + rand.nextDouble() * 0.6,
      wobblePhase: rand.nextDouble() * math.pi * 2,
      glyph: glyphs[rand.nextInt(glyphs.length)],
      color: colors[rand.nextInt(colors.length)],
    );
  }

  void update(double dt) {
    yRatio -= dt * speed * 0.35;
    wobblePhase += dt * 3.0;
    if (yRatio < -0.1) {
      yRatio = 1.05;
      xRatio = 0.15 + (math.sin(wobblePhase) * 0.5 + 0.5) * 0.7;
    }
  }
}

/// 🐾 Snapchat-Style Peek-a-boo Doodle Cat Pull-To-Refresh Widget
/// Features a playful hand-drawn doodle cat mascot peeking over the top bar,
/// with animated blinking eyes, cute paws gripping the ledge, winking expressions,
/// floating doodle stars/sparkles, and a snappy haptic pop on release!
class PocketSnapFlameRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final double triggerDistance;
  final double maxPullDistance;
  final double restingHeight;
  final Color primaryFlameColor;
  final Color accentFlameColor;
  final String pullText;
  final String readyText;
  final String refreshingText;
  final String successText;

  const PocketSnapFlameRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.triggerDistance = 80.0,
    this.maxPullDistance = 140.0,
    this.restingHeight = 75.0,
    this.primaryFlameColor = const Color(0xFFFFFC00),
    this.accentFlameColor = const Color(0xFFFF8906),
    this.pullText = 'Pull to meet your mates... 🐾',
    this.readyText = 'Ready to pounce! Release! 😻',
    this.refreshingText = 'Syncing Pocket Mates... ✨',
    this.successText = 'Purrfect! All caught up! 🎉',
  });

  @override
  State<PocketSnapFlameRefresh> createState() => _PocketSnapFlameRefreshState();
}

class _PocketSnapFlameRefreshState extends State<PocketSnapFlameRefresh>
    with TickerProviderStateMixin {
  double _pullDistance = 0.0;
  double _rawDrag = 0.0;
  double _startY = 0.0;
  bool _isDragging = false;
  bool _isRefreshing = false;
  bool _isSuccess = false;
  bool _hasFiredHaptic = false;
  double _currentScrollOffset = 0.0;

  late AnimationController _springController;
  late Animation<double> _springAnimation;

  late AnimationController _doodleSpinController;
  late AnimationController _particleTicker;

  final List<_DoodleParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _doodleSpinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _particleTicker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tickParticles);

    for (int i = 0; i < 14; i++) {
      _particles.add(_DoodleParticle.random(_random));
    }
  }

  void _tickParticles() {
    if (_pullDistance > 10 || _isRefreshing) {
      for (final p in _particles) {
        p.update(0.016);
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _springController.dispose();
    _doodleSpinController.dispose();
    _particleTicker.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _springAnimation = Tween<double>(
      begin: _pullDistance,
      end: target,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: Curves.easeOutBack,
    ))
      ..addListener(() {
        setState(() {
          _pullDistance = _springAnimation.value;
        });
      });
    _springController.forward(from: 0.0);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical) {
      _currentScrollOffset = notification.metrics.pixels;
    }
    return false;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_isRefreshing) return;
    _startY = event.position.dy;
    _rawDrag = 0.0;
    _isDragging = false;
    _hasFiredHaptic = false;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isRefreshing) return;

    if (_currentScrollOffset <= 1.0) {
      final dy = event.position.dy - _startY;
      if (dy > 0) {
        _isDragging = true;
        _rawDrag = dy;

        final progress = math.min(1.0, dy / (widget.maxPullDistance * 1.8));
        final damped = math.pow(progress, 0.75) * widget.maxPullDistance;

        setState(() {
          _pullDistance = damped.clamp(0.0, widget.maxPullDistance);
        });

        if (!_particleTicker.isAnimating) {
          _particleTicker.repeat();
        }

        if (_pullDistance >= widget.triggerDistance && !_hasFiredHaptic) {
          HapticFeedback.mediumImpact();
          _hasFiredHaptic = true;
        } else if (_pullDistance < widget.triggerDistance) {
          _hasFiredHaptic = false;
        }
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isRefreshing) return;
    _finishPull();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_isRefreshing) return;
    _finishPull();
  }

  void _finishPull() {
    if (!_isDragging) return;
    _isDragging = false;

    if (_pullDistance >= widget.triggerDistance) {
      _startRefresh();
    } else {
      _animateTo(0.0);
    }
  }

  void _startRefresh() async {
    setState(() {
      _isRefreshing = true;
      _isSuccess = false;
    });

    _animateTo(widget.restingHeight);
    _doodleSpinController.repeat();
    HapticFeedback.mediumImpact();

    try {
      await widget.onRefresh();
      if (!mounted) return;

      setState(() {
        _isSuccess = true;
      });
      HapticFeedback.lightImpact();

      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
    } catch (e) {
      debugPrint('PocketSnapFlameRefresh error: $e');
    } finally {
      if (mounted) {
        _doodleSpinController.stop();
        _particleTicker.stop();
        _animateTo(0.0);
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          setState(() {
            _isRefreshing = false;
            _isSuccess = false;
            _hasFiredHaptic = false;
            _pullDistance = 0.0;
          });
        }
      }
    }
  }

  void _cancelRefresh() {
    _particleTicker.stop();
    _animateTo(0.0);
    setState(() {
      _hasFiredHaptic = false;
      _isRefreshing = false;
      _isSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pullRatio = (_pullDistance / widget.triggerDistance).clamp(0.0, 1.5);
    final isReady = _pullDistance >= widget.triggerDistance && !_isRefreshing;

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: Stack(
          children: [
            // 🐾 Peek-a-boo Doodle Cat Header
            if (_pullDistance > 0 || _isRefreshing)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _pullDistance,
                child: _DoodleMascotHeader(
                  pullRatio: pullRatio,
                  pullDistance: _pullDistance,
                  isRefreshing: _isRefreshing,
                  isReady: isReady,
                  isSuccess: _isSuccess,
                  spinAnimation: _doodleSpinController,
                  particles: _particles,
                  primaryColor: widget.primaryFlameColor,
                  accentColor: widget.accentFlameColor,
                  pullText: widget.pullText,
                  readyText: widget.readyText,
                  refreshingText: widget.refreshingText,
                  successText: widget.successText,
                ),
              ),

            // Scrollable Child translated downwards on pull
            Transform.translate(
              offset: Offset(0, _pullDistance),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

/// 🐾 Header Container rendering the Peek-a-boo Doodle Mascot & Particles
class _DoodleMascotHeader extends StatelessWidget {
  final double pullRatio;
  final double pullDistance;
  final bool isRefreshing;
  final bool isReady;
  final bool isSuccess;
  final Animation<double> spinAnimation;
  final List<_DoodleParticle> particles;
  final Color primaryColor;
  final Color accentColor;
  final String pullText;
  final String readyText;
  final String refreshingText;
  final String successText;

  const _DoodleMascotHeader({
    required this.pullRatio,
    required this.pullDistance,
    required this.isRefreshing,
    required this.isReady,
    required this.isSuccess,
    required this.spinAnimation,
    required this.particles,
    required this.primaryColor,
    required this.accentColor,
    required this.pullText,
    required this.readyText,
    required this.refreshingText,
    required this.successText,
  });

  @override
  Widget build(BuildContext context) {
    String statusText;
    if (isSuccess) {
      statusText = successText;
    } else if (isRefreshing) {
      statusText = refreshingText;
    } else if (isReady) {
      statusText = readyText;
    } else {
      statusText = pullText;
    }

    // Cat moves upwards/downwards to peek over the bottom edge
    final peekProgress = isRefreshing ? 1.0 : (pullRatio * 1.1).clamp(0.2, 1.0);

    return ClipRect(
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF090D16), // Dark midnight
              Color(0xFF131B2E), // Rich navy
              Color(0xFF1E293B), // Soft slate
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          border: Border(
            bottom: BorderSide(
              color: isReady || isRefreshing
                  ? const Color(0xFFFFFC00).withValues(alpha: 0.75)
                  : const Color(0xFF38BDF8).withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: (isReady || isRefreshing
                      ? const Color(0xFFFFFC00)
                      : const Color(0xFF38BDF8))
                  .withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Floating Doodle Particles (Stars, Sparkles, Paws)
            Positioned.fill(
              child: CustomPaint(
                painter: _DoodleParticleCanvasPainter(
                  particles: particles,
                  intensity: pullRatio.clamp(0.2, 1.0),
                ),
              ),
            ),

            // Subtle Ambient Glow
            Positioned(
              bottom: 8,
              child: Container(
                width: 120 * peekProgress,
                height: 50 * peekProgress,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isReady || isRefreshing
                          ? const Color(0xFFFFFC00).withValues(alpha: 0.35)
                          : const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      blurRadius: 28,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),

            // Content Stack: Doodle Peek Cat + Status Badge
            OverflowBox(
              alignment: Alignment.bottomCenter,
              maxHeight: 160,
              minHeight: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🐱 Peek-a-boo Doodle Mascot Character
                    _DoodlePeekCatGraphic(
                      pullRatio: pullRatio,
                      isReady: isReady,
                      isRefreshing: isRefreshing,
                      isSuccess: isSuccess,
                      spinAnimation: spinAnimation,
                    ),
                    const SizedBox(height: 5),

                    // Interactive Status Badge Pill
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: (pullRatio > 0.35 || isRefreshing) ? 1.0 : 0.0,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isReady || isRefreshing
                                ? const Color(0xFFFFFC00).withValues(alpha: 0.8)
                                : Colors.white24,
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          statusText,
                          style: GoogleFonts.outfit(
                            color: isReady || isRefreshing
                                ? const Color(0xFFFFFC00)
                                : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🐱 Vector-Drawn Peek-a-boo Doodle Cat Mascot
class _DoodlePeekCatGraphic extends StatelessWidget {
  final double pullRatio;
  final bool isReady;
  final bool isRefreshing;
  final bool isSuccess;
  final Animation<double> spinAnimation;

  const _DoodlePeekCatGraphic({
    required this.pullRatio,
    required this.isReady,
    required this.isRefreshing,
    required this.isSuccess,
    required this.spinAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: spinAnimation,
      builder: (context, child) {
        final bounce = isRefreshing
            ? math.sin(spinAnimation.value * math.pi * 4) * 3.5
            : (pullRatio * 4.0).clamp(0.0, 6.0);

        return Transform.translate(
          offset: Offset(0, -bounce),
          child: SizedBox(
            width: 72,
            height: 48,
            child: CustomPaint(
              painter: _DoodleCatCustomPainter(
                pullRatio: pullRatio,
                isReady: isReady,
                isRefreshing: isRefreshing,
                isSuccess: isSuccess,
                spinPhase: spinAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🎨 Custom Painter drawing the cute Doodle Cat peeking over the ledge
class _DoodleCatCustomPainter extends CustomPainter {
  final double pullRatio;
  final bool isReady;
  final bool isRefreshing;
  final bool isSuccess;
  final double spinPhase;

  _DoodleCatCustomPainter({
    required this.pullRatio,
    required this.isReady,
    required this.isRefreshing,
    required this.isSuccess,
    required this.spinPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bodyFillPaint = Paint()
      ..color = const Color(0xFFFFFBEB) // Creamy soft white doodle cat
      ..style = PaintingStyle.fill;

    final pinkPaint = Paint()
      ..color = const Color(0xFFF472B6) // Soft pastel pink
      ..style = PaintingStyle.fill;

    final darkEyePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    // 1. Cat Head Arc & Ears
    final headPath = Path();
    // Left Ear tip
    headPath.moveTo(w * 0.16, h * 0.10);
    // Outer left ear down to cheek
    headPath.quadraticBezierTo(w * 0.10, h * 0.35, w * 0.12, h * 0.85);
    // Bottom neck across
    headPath.lineTo(w * 0.88, h * 0.85);
    // Outer right ear up to right tip
    headPath.quadraticBezierTo(w * 0.90, h * 0.35, w * 0.84, h * 0.10);
    // Inner right ear down
    headPath.lineTo(w * 0.68, h * 0.38);
    // Top of head curve between ears
    headPath.quadraticBezierTo(w * 0.50, h * 0.32, w * 0.32, h * 0.38);
    // Inner left ear up to left tip
    headPath.close();

    // Fill Head
    canvas.drawPath(headPath, bodyFillPaint);
    // Stroke Head
    canvas.drawPath(headPath, strokePaint);

    // 2. Pink Inner Ears
    final leftInnerEar = Path()
      ..moveTo(w * 0.19, h * 0.18)
      ..lineTo(w * 0.16, h * 0.42)
      ..lineTo(w * 0.30, h * 0.39)
      ..close();
    canvas.drawPath(leftInnerEar, pinkPaint);

    final rightInnerEar = Path()
      ..moveTo(w * 0.81, h * 0.18)
      ..lineTo(w * 0.70, h * 0.39)
      ..lineTo(w * 0.84, h * 0.42)
      ..close();
    canvas.drawPath(rightInnerEar, pinkPaint);

    // 3. Cheeks Blush Circles
    canvas.drawCircle(Offset(w * 0.22, h * 0.66), 4.2, pinkPaint..color = const Color(0xFFFFB5D5).withValues(alpha: 0.8));
    canvas.drawCircle(Offset(w * 0.78, h * 0.66), 4.2, pinkPaint..color = const Color(0xFFFFB5D5).withValues(alpha: 0.8));

    // 4. Eyes based on state
    if (isSuccess) {
      // Happy Closed Crescent Smiling Eyes: ( ^ ‿ ^ )
      final leftSmileEye = Path()
        ..moveTo(w * 0.28, h * 0.55)
        ..quadraticBezierTo(w * 0.35, h * 0.46, w * 0.42, h * 0.55);
      canvas.drawPath(leftSmileEye, strokePaint..strokeWidth = 2.2);

      final rightSmileEye = Path()
        ..moveTo(w * 0.58, h * 0.55)
        ..quadraticBezierTo(w * 0.65, h * 0.46, w * 0.72, h * 0.55);
      canvas.drawPath(rightSmileEye, strokePaint..strokeWidth = 2.2);
    } else if (isRefreshing) {
      // Starry Spinning Eyes: ★ ★
      _drawDoodleStar(canvas, Offset(w * 0.35, h * 0.53), 5.5, const Color(0xFFFFFC00), strokePaint);
      _drawDoodleStar(canvas, Offset(w * 0.65, h * 0.53), 5.5, const Color(0xFFFFFC00), strokePaint);
    } else if (isReady) {
      // Winking Eye: Left winks (>), Right open wide with heart!
      // Left Wink ( > )
      final winkPath = Path()
        ..moveTo(w * 0.30, h * 0.49)
        ..lineTo(w * 0.39, h * 0.54)
        ..lineTo(w * 0.30, h * 0.59);
      canvas.drawPath(winkPath, strokePaint..strokeWidth = 2.2);

      // Right Big Open Eye with sparkle pupil
      canvas.drawCircle(Offset(w * 0.65, h * 0.53), 5.5, darkEyePaint);
      canvas.drawCircle(Offset(w * 0.63, h * 0.51), 1.8, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(w * 0.67, h * 0.55), 0.9, Paint()..color = Colors.white);
    } else {
      // Regular Big Curious Anime/Doodle Eyes
      canvas.drawCircle(Offset(w * 0.35, h * 0.53), 5.2, darkEyePaint);
      canvas.drawCircle(Offset(w * 0.33, h * 0.51), 1.8, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(w * 0.37, h * 0.55), 0.9, Paint()..color = Colors.white);

      canvas.drawCircle(Offset(w * 0.65, h * 0.53), 5.2, darkEyePaint);
      canvas.drawCircle(Offset(w * 0.63, h * 0.51), 1.8, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(w * 0.67, h * 0.55), 0.9, Paint()..color = Colors.white);
    }

    // 5. Button Pink Nose & Cute 'w' Mouth
    final nosePath = Path()
      ..moveTo(w * 0.48, h * 0.60)
      ..lineTo(w * 0.52, h * 0.60)
      ..lineTo(w * 0.50, h * 0.63)
      ..close();
    canvas.drawPath(nosePath, Paint()..color = const Color(0xFFF472B6)..style = PaintingStyle.fill);

    // Mouth: =^･ω･^=
    final mouthPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path()
      ..moveTo(w * 0.43, h * 0.66)
      ..quadraticBezierTo(w * 0.46, h * 0.70, w * 0.50, h * 0.66)
      ..quadraticBezierTo(w * 0.54, h * 0.70, w * 0.57, h * 0.66);
    canvas.drawPath(mouthPath, mouthPaint);

    // 6. Whiskers (2 on each cheek)
    final whiskerPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    // Left whiskers
    canvas.drawLine(Offset(w * 0.14, h * 0.58), Offset(w * 0.24, h * 0.62), whiskerPaint);
    canvas.drawLine(Offset(w * 0.12, h * 0.68), Offset(w * 0.23, h * 0.67), whiskerPaint);

    // Right whiskers
    canvas.drawLine(Offset(w * 0.86, h * 0.58), Offset(w * 0.76, h * 0.62), whiskerPaint);
    canvas.drawLine(Offset(w * 0.88, h * 0.68), Offset(w * 0.77, h * 0.67), whiskerPaint);

    // 7. Cute Paws resting on the bottom edge! 🐾
    _drawCutePaw(canvas, Offset(w * 0.26, h * 0.90), bodyFillPaint, strokePaint);
    _drawCutePaw(canvas, Offset(w * 0.74, h * 0.90), bodyFillPaint, strokePaint);
  }

  void _drawCutePaw(Canvas canvas, Offset center, Paint fillPaint, Paint strokePaint) {
    final pawRect = Rect.fromCenter(center: center, width: 14, height: 11);
    final pawRRect = RRect.fromRectAndRadius(pawRect, const Radius.circular(6));
    canvas.drawRRect(pawRRect, fillPaint);
    canvas.drawRRect(pawRRect, strokePaint..strokeWidth = 1.8);

    // Toe bean indentation
    final beanPaint = Paint()
      ..color = const Color(0xFFF472B6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, center.dy - 1), 2.0, beanPaint);
  }

  void _drawDoodleStar(Canvas canvas, Offset center, double radius, Color color, Paint borderPaint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * (math.pi * 2 / 5);
      final innerAngle = angle + math.pi / 5;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      final inX = center.dx + math.cos(innerAngle) * (radius * 0.45);
      final inY = center.dy + math.sin(innerAngle) * (radius * 0.45);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      path.lineTo(inX, inY);
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawPath(path, borderPaint..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(covariant _DoodleCatCustomPainter oldDelegate) {
    return oldDelegate.pullRatio != pullRatio ||
        oldDelegate.isReady != isReady ||
        oldDelegate.isRefreshing != isRefreshing ||
        oldDelegate.isSuccess != isSuccess ||
        oldDelegate.spinPhase != spinPhase;
  }
}

/// 🎨 Particle Canvas Painter for Floating Doodle Glyphs (⭐, ✨, 🐾, ✦)
class _DoodleParticleCanvasPainter extends CustomPainter {
  final List<_DoodleParticle> particles;
  final double intensity;

  _DoodleParticleCanvasPainter({
    required this.particles,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final x = p.xRatio * size.width + math.sin(p.wobblePhase) * 10.0;
      final y = p.yRatio * size.height;

      final textSpan = TextSpan(
        text: p.glyph,
        style: TextStyle(
          fontSize: p.size * intensity,
          color: p.color.withValues(alpha: (p.opacity * intensity).clamp(0.0, 1.0)),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant _DoodleParticleCanvasPainter oldDelegate) => true;
}
