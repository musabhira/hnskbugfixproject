import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🔥 Snap / Flame Ember Particle
class _FlameEmberParticle {
  double xRatio;
  double yRatio;
  double size;
  double speed;
  double opacity;
  double wobblePhase;
  Color color;

  _FlameEmberParticle({
    required this.xRatio,
    required this.yRatio,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.wobblePhase,
    required this.color,
  });

  static _FlameEmberParticle random(math.Random rand) {
    const colors = [
      Color(0xFFFFFC00), // Snapchat signature yellow
      Color(0xFFFF9100), // Radiant orange
      Color(0xFFFF3D00), // Deep ember flame
      Color(0xFFFFD54F), // Amber spark
      Color(0xFFFFFFFF), // Core spark
    ];
    return _FlameEmberParticle(
      xRatio: 0.2 + rand.nextDouble() * 0.6,
      yRatio: 0.2 + rand.nextDouble() * 0.8,
      size: 2.0 + rand.nextDouble() * 3.5,
      speed: 0.8 + rand.nextDouble() * 1.6,
      opacity: 0.3 + rand.nextDouble() * 0.7,
      wobblePhase: rand.nextDouble() * math.pi * 2,
      color: colors[rand.nextInt(colors.length)],
    );
  }

  void update(double dt) {
    yRatio -= dt * speed * 0.4;
    wobblePhase += dt * 3.5;
    if (yRatio < -0.1) {
      yRatio = 1.1;
      xRatio = 0.2 + (math.sin(wobblePhase) * 0.5 + 0.5) * 0.6;
    }
  }
}

/// 🔥 Snapchat-Style Flame Pull-To-Refresh Widget
/// Translates the whole view downwards on pull-down, revealing a custom
/// squash-and-stretch animated flame character with glowing embers,
/// haptic snap, dynamic status badges, and fiery burst effects!
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
    this.restingHeight = 70.0,
    this.primaryFlameColor = const Color(0xFFFFFC00),
    this.accentFlameColor = const Color(0xFFFF5722),
    this.pullText = 'Pull to ignite... 🔥',
    this.readyText = 'Release to rekindle! ✨',
    this.refreshingText = 'Igniting fresh mates... 🔥',
    this.successText = 'Ignited! ✨',
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

  late AnimationController _flameSpinController;
  late AnimationController _emberTicker;

  final List<_FlameEmberParticle> _embers = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _flameSpinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _emberTicker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tickEmbers);

    for (int i = 0; i < 14; i++) {
      _embers.add(_FlameEmberParticle.random(_random));
    }
  }

  void _tickEmbers() {
    if (_pullDistance > 10 || _isRefreshing) {
      for (final e in _embers) {
        e.update(0.016);
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _springController.dispose();
    _flameSpinController.dispose();
    _emberTicker.dispose();
    super.dispose();
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

    // Only engage pull-to-refresh if the scrollable is at the very top
    if (_currentScrollOffset <= 1.0) {
      final dy = event.position.dy - _startY;
      if (dy > 0) {
        _isDragging = true;
        _rawDrag = dy;

        // Realistic rubber-band resistance curve
        final progress = math.min(1.0, dy / (widget.maxPullDistance * 1.8));
        final damped = math.pow(progress, 0.75) * widget.maxPullDistance;

        setState(() {
          _pullDistance = damped.clamp(0.0, widget.maxPullDistance);
        });

        if (!_emberTicker.isAnimating) {
          _emberTicker.repeat();
        }

        // Haptic feedback when crossing ignition threshold
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
      _animateBackTo(0.0);
    }
  }

  void _startRefresh() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRefreshing = true;
      _isSuccess = false;
    });

    _flameSpinController.repeat();
    if (!_emberTicker.isAnimating) {
      _emberTicker.repeat();
    }

    final refreshFuture = widget.onRefresh();

    _animateBackTo(widget.restingHeight, onComplete: () async {
      try {
        await refreshFuture;
      } catch (e) {
        debugPrint('PocketSnapFlameRefresh error: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isSuccess = true;
          });
          HapticFeedback.lightImpact();

          // Brief delay so learner sees the success ignite badge
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) {
            _flameSpinController.stop();
            _emberTicker.stop();
            _animateBackTo(0.0, onComplete: () {
              if (mounted) {
                setState(() {
                  _isRefreshing = false;
                  _isSuccess = false;
                  _pullDistance = 0.0;
                });
              }
            });
          }
        }
      }
    });
  }

  void _animateBackTo(double target, {VoidCallback? onComplete}) {
    _springAnimation = Tween<double>(
      begin: _pullDistance,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _springController,
        curve: target == 0.0 ? Curves.easeOutCubic : Curves.easeOutBack,
      ),
    )..addListener(() {
        setState(() {
          _pullDistance = _springAnimation.value;
        });
      });

    _springController.reset();
    _springController.forward().then((_) {
      if (onComplete != null) onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pullRatio = (_pullDistance / widget.triggerDistance).clamp(0.0, 1.5);
    final isReady = _pullDistance >= widget.triggerDistance;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _currentScrollOffset = notification.metrics.pixels;
        return false;
      },
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // 1. Snapchat Flame Header revealed in the pulled gap
            if (_pullDistance > 0.5)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _pullDistance,
                child: _SnapFlameHeader(
                  pullRatio: pullRatio,
                  pullDistance: _pullDistance,
                  isRefreshing: _isRefreshing,
                  isReady: isReady,
                  isSuccess: _isSuccess,
                  spinAnimation: _flameSpinController,
                  embers: _embers,
                  primaryColor: widget.primaryFlameColor,
                  accentColor: widget.accentFlameColor,
                  pullText: widget.pullText,
                  readyText: widget.readyText,
                  refreshingText: widget.refreshingText,
                  successText: widget.successText,
                ),
              ),

            // 2. Entire Child Translated Downwards together!
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

/// 🔥 Visual Component for the Flame & Sparks Header
class _SnapFlameHeader extends StatelessWidget {
  final double pullRatio;
  final double pullDistance;
  final bool isRefreshing;
  final bool isReady;
  final bool isSuccess;
  final Animation<double> spinAnimation;
  final List<_FlameEmberParticle> embers;
  final Color primaryColor;
  final Color accentColor;
  final String pullText;
  final String readyText;
  final String refreshingText;
  final String successText;

  const _SnapFlameHeader({
    required this.pullRatio,
    required this.pullDistance,
    required this.isRefreshing,
    required this.isReady,
    required this.isSuccess,
    required this.spinAnimation,
    required this.embers,
    required this.primaryColor,
    required this.accentColor,
    required this.pullText,
    required this.readyText,
    required this.refreshingText,
    required this.successText,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic squash & stretch based on pull ratio
    final stretchY = isRefreshing
        ? 1.0 + math.sin(spinAnimation.value * math.pi * 4) * 0.08
        : 1.0 + (pullRatio * 0.3).clamp(0.0, 0.45);
    final stretchX = isRefreshing
        ? 1.0 - math.sin(spinAnimation.value * math.pi * 4) * 0.08
        : 1.0 - (pullRatio * 0.15).clamp(0.0, 0.2);

    final flameScale = isRefreshing
        ? 1.05
        : (pullRatio * 1.15).clamp(0.3, 1.25);

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

    return ClipRect(
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 8),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Ember particle canvas
            Positioned.fill(
              child: CustomPaint(
                painter: _EmberCanvasPainter(
                  embers: embers,
                  intensity: pullRatio.clamp(0.2, 1.0),
                ),
              ),
            ),

            // Pulsing Heat Glow
            Positioned(
              bottom: 12,
              child: Container(
                width: 90 * flameScale,
                height: 50 * flameScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isReady || isRefreshing
                          ? primaryColor.withValues(alpha: 0.45)
                          : accentColor.withValues(alpha: 0.25),
                      blurRadius: isRefreshing ? 30 : 18,
                      spreadRadius: isRefreshing ? 8 : 2,
                    ),
                  ],
                ),
              ),
            ),

            // Main Flame Character & Interactive Status Badge
            OverflowBox(
              alignment: Alignment.bottomCenter,
              maxHeight: 150,
              minHeight: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(stretchX * flameScale, stretchY * flameScale),
                  child: AnimatedBuilder(
                    animation: spinAnimation,
                    builder: (context, child) {
                      final rot = isRefreshing
                          ? (spinAnimation.value * math.pi * 2)
                          : (math.sin(pullRatio * math.pi) * 0.12);
                      return Transform.rotate(
                        angle: rot,
                        child: _SnapFlameGraphic(
                          isReady: isReady,
                          isRefreshing: isRefreshing,
                          isSuccess: isSuccess,
                          primaryColor: primaryColor,
                          accentColor: accentColor,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),

                // Interactive Status Badge Pill
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: (pullRatio > 0.45 || isRefreshing) ? 1.0 : 0.0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141622).withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isReady || isRefreshing
                            ? primaryColor.withValues(alpha: 0.6)
                            : Colors.white12,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isReady || isRefreshing
                              ? primaryColor.withValues(alpha: 0.2)
                              : Colors.black26,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.outfit(
                        color: isReady || isRefreshing
                            ? primaryColor
                            : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔥 Vector Custom Painted Snapchat-Style Flame
class _SnapFlameGraphic extends StatelessWidget {
  final bool isReady;
  final bool isRefreshing;
  final bool isSuccess;
  final Color primaryColor;
  final Color accentColor;

  const _SnapFlameGraphic({
    required this.isReady,
    required this.isRefreshing,
    required this.isSuccess,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 44,
      child: CustomPaint(
        painter: _FlameVectorPainter(
          isReady: isReady,
          isRefreshing: isRefreshing,
          isSuccess: isSuccess,
          primaryColor: primaryColor,
          accentColor: accentColor,
        ),
      ),
    );
  }
}

/// Custom Painter for 3-layered glowing flame
class _FlameVectorPainter extends CustomPainter {
  final bool isReady;
  final bool isRefreshing;
  final bool isSuccess;
  final Color primaryColor;
  final Color accentColor;

  _FlameVectorPainter({
    required this.isReady,
    required this.isRefreshing,
    required this.isSuccess,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Outer Flame (Fiery Red-Orange)
    final outerPath = Path()
      ..moveTo(w * 0.5, 0)
      ..cubicTo(w * 0.75, h * 0.22, w * 0.95, h * 0.52, w * 0.88, h * 0.78)
      ..cubicTo(w * 0.82, h * 0.96, w * 0.62, h, w * 0.5, h)
      ..cubicTo(w * 0.38, h, w * 0.18, h * 0.96, w * 0.12, h * 0.78)
      ..cubicTo(w * 0.05, h * 0.52, w * 0.25, h * 0.22, w * 0.5, 0)
      ..close();

    final outerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isSuccess
            ? const [Color(0xFF10B981), Color(0xFF059669)]
            : (isReady || isRefreshing)
                ? [primaryColor, accentColor]
                : [accentColor, const Color(0xFFD32F2F)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(outerPath, outerPaint);

    // Middle Flame (Bright Yellow Amber)
    final midW = w * 0.65;
    final midH = h * 0.65;
    final midLeft = (w - midW) / 2;
    final midTop = h * 0.32;

    final midPath = Path()
      ..moveTo(midLeft + midW * 0.5, midTop)
      ..cubicTo(midLeft + midW * 0.8, midTop + midH * 0.25,
          midLeft + midW * 0.95, midTop + midH * 0.55,
          midLeft + midW * 0.88, midTop + midH * 0.82)
      ..cubicTo(midLeft + midW * 0.78, midTop + midH,
          midLeft + midW * 0.6, midTop + midH,
          midLeft + midW * 0.5, midTop + midH)
      ..cubicTo(midLeft + midW * 0.4, midTop + midH,
          midLeft + midW * 0.22, midTop + midH,
          midLeft + midW * 0.12, midTop + midH * 0.82)
      ..cubicTo(midLeft + midW * 0.05, midTop + midH * 0.55,
          midLeft + midW * 0.2, midTop + midH * 0.25,
          midLeft + midW * 0.5, midTop)
      ..close();

    final midPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isSuccess
            ? const [Color(0xFFA7F3D0), Color(0xFF34D399)]
            : [const Color(0xFFFFF9C4), primaryColor],
      ).createShader(Rect.fromLTWH(midLeft, midTop, midW, midH));

    canvas.drawPath(midPath, midPaint);

    // Inner White Energy Spark
    final coreW = w * 0.25;
    final coreH = h * 0.3;
    final coreLeft = (w - coreW) / 2;
    final coreTop = h * 0.62;

    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(coreLeft, coreTop, coreW, coreH),
      corePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FlameVectorPainter oldDelegate) {
    return oldDelegate.isReady != isReady ||
        oldDelegate.isRefreshing != isRefreshing ||
        oldDelegate.isSuccess != isSuccess ||
        oldDelegate.primaryColor != primaryColor;
  }
}

/// Ember Sparks Canvas Painter
class _EmberCanvasPainter extends CustomPainter {
  final List<_FlameEmberParticle> embers;
  final double intensity;

  _EmberCanvasPainter({
    required this.embers,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final ember in embers) {
      final x = ember.xRatio * size.width +
          math.sin(ember.wobblePhase) * 12.0;
      final y = ember.yRatio * size.height;

      final paint = Paint()
        ..color = ember.color.withValues(
          alpha: (ember.opacity * intensity).clamp(0.0, 1.0),
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), ember.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EmberCanvasPainter oldDelegate) => true;
}
