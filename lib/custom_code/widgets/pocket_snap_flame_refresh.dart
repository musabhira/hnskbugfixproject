import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// ✨ Floating Street Sparkle Particle
class _SwaggerParticle {
  double xRatio;
  double yRatio;
  double size;
  double speed;
  double opacity;
  double wobblePhase;
  String glyph;
  Color color;

  _SwaggerParticle({
    required this.xRatio,
    required this.yRatio,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.wobblePhase,
    required this.glyph,
    required this.color,
  });

  static _SwaggerParticle random(math.Random rand) {
    const glyphs = ['✦', '⭐', '✨', '⚡', '🔥'];
    const colors = [
      Color(0xFFFFFC00), // Snapchat Yellow
      Color(0xFF38BDF8), // Cyan Neon
      Color(0xFFF472B6), // Pink Sparkle
      Color(0xFFA78BFA), // Violet Glow
      Color(0xFF34D399), // Emerald
      Color(0xFFFFFFFF), // Pure Light
    ];
    return _SwaggerParticle(
      xRatio: 0.10 + rand.nextDouble() * 0.80,
      yRatio: 0.05 + rand.nextDouble() * 0.85,
      size: 10.0 + rand.nextDouble() * 8.0,
      speed: 0.5 + rand.nextDouble() * 1.1,
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
      xRatio = 0.10 + (math.sin(wobblePhase) * 0.5 + 0.5) * 0.80;
    }
  }
}

/// 🕶️ Swagger Squad Pull-To-Refresh Widget
/// Features a colorful crew of 6 swagger mascot characters posing in a hip-hop stance
/// with glossy sunglasses, vibrant streetwear hues, floating golden stars,
/// "POCKET MATES" graffiti logo in the background, and 100% reliable refresh triggering.
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
    this.triggerDistance = 85.0,
    this.maxPullDistance = 200.0,
    this.restingHeight = 140.0,
    this.primaryFlameColor = const Color(0xFFFFFC00),
    this.accentFlameColor = const Color(0xFFFF8906),
    this.pullText = 'Pull down the squad... 🕶️',
    this.readyText = 'Squad Ready! Release! 🔥',
    this.refreshingText = 'Pocket Mates Syncing... ⚡',
    this.successText = 'Squad Synced! Let\'s Go! 🚀',
  });

  @override
  State<PocketSnapFlameRefresh> createState() => _PocketSnapFlameRefreshState();
}

class _PocketSnapFlameRefreshState extends State<PocketSnapFlameRefresh>
    with TickerProviderStateMixin {
  double _pullDistance = 0.0;
  double _startY = 0.0;
  bool _isDragging = false;
  bool _isRefreshing = false;
  bool _isSuccess = false;
  bool _hasFiredHaptic = false;
  double _currentScrollOffset = 0.0;

  late AnimationController _springController;
  late Animation<double> _springAnimation;

  late AnimationController _grooveController;
  late AnimationController _particleTicker;

  final List<_SwaggerParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );

    _grooveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _particleTicker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tickParticles);

    for (int i = 0; i < 16; i++) {
      _particles.add(_SwaggerParticle.random(_random));
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
    _grooveController.dispose();
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

      // Handle overscroll dragging from native scroll physics
      if (!_isRefreshing) {
        if (notification is OverscrollNotification && notification.overscroll < 0) {
          _handleOverscrollDelta(-notification.overscroll);
        } else if (notification is ScrollUpdateNotification) {
          if (notification.metrics.pixels <= 0 && (notification.scrollDelta ?? 0) < 0) {
            _handleOverscrollDelta(-(notification.scrollDelta ?? 0));
          }
        } else if (notification is ScrollEndNotification) {
          if (_isDragging) {
            _finishPull();
          }
        }
      }
    }
    return false;
  }

  void _handleOverscrollDelta(double delta) {
    _isDragging = true;
    final newDistance = (_pullDistance + delta * 0.7).clamp(0.0, widget.maxPullDistance);
    setState(() {
      _pullDistance = newDistance;
    });

    if (!_particleTicker.isAnimating) {
      _particleTicker.repeat();
    }

    _checkHaptic();
  }

  void _checkHaptic() {
    if (_pullDistance >= widget.triggerDistance && !_hasFiredHaptic) {
      HapticFeedback.mediumImpact();
      _hasFiredHaptic = true;
    } else if (_pullDistance < widget.triggerDistance) {
      _hasFiredHaptic = false;
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_isRefreshing) return;
    _startY = event.position.dy;
    _isDragging = false;
    _hasFiredHaptic = false;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isRefreshing) return;

    // Allow pulling if close to the top of the scroll view
    if (_currentScrollOffset <= 5.0) {
      final dy = event.position.dy - _startY;
      if (dy > 0) {
        _isDragging = true;
        final progress = math.min(1.0, dy / (widget.maxPullDistance * 1.8));
        final damped = math.pow(progress, 0.78) * widget.maxPullDistance;

        setState(() {
          _pullDistance = damped.clamp(0.0, widget.maxPullDistance);
        });

        if (!_particleTicker.isAnimating) {
          _particleTicker.repeat();
        }

        _checkHaptic();
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
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _isSuccess = false;
    });

    _animateTo(widget.restingHeight);
    _grooveController.repeat(reverse: true);
    HapticFeedback.mediumImpact();

    try {
      // Execute the actual backend data refresh
      await widget.onRefresh();
      if (!mounted) return;

      setState(() {
        _isSuccess = true;
      });
      HapticFeedback.lightImpact();

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
    } catch (e) {
      debugPrint('PocketSnapFlameRefresh onRefresh error: $e');
    } finally {
      if (mounted) {
        _grooveController.stop();
        _particleTicker.stop();
        _animateTo(0.0);
        await Future.delayed(const Duration(milliseconds: 320));
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

  @override
  Widget build(BuildContext context) {
    final pullRatio = (_pullDistance / widget.triggerDistance).clamp(0.0, 1.6);
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
            // 🕶️ Swagger Squad Header with "POCKET MATES" Logo
            if (_pullDistance > 0 || _isRefreshing)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _pullDistance,
                child: _SwaggerSquadHeader(
                  pullRatio: pullRatio,
                  pullDistance: _pullDistance,
                  isRefreshing: _isRefreshing,
                  isReady: isReady,
                  isSuccess: _isSuccess,
                  grooveAnimation: _grooveController,
                  particles: _particles,
                  primaryColor: widget.primaryFlameColor,
                  accentColor: widget.accentFlameColor,
                  pullText: widget.pullText,
                  readyText: widget.readyText,
                  refreshingText: widget.refreshingText,
                  successText: widget.successText,
                ),
              ),

            // Translated Scrollable Child
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

/// 🕶️ Header displaying the Swagger Squad & "POCKET MATES" Logo
class _SwaggerSquadHeader extends StatelessWidget {
  final double pullRatio;
  final double pullDistance;
  final bool isRefreshing;
  final bool isReady;
  final bool isSuccess;
  final Animation<double> grooveAnimation;
  final List<_SwaggerParticle> particles;
  final Color primaryColor;
  final Color accentColor;
  final String pullText;
  final String readyText;
  final String refreshingText;
  final String successText;

  const _SwaggerSquadHeader({
    required this.pullRatio,
    required this.pullDistance,
    required this.isRefreshing,
    required this.isReady,
    required this.isSuccess,
    required this.grooveAnimation,
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

    return ClipRect(
      child: Container(
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF07090E), // Ultra deep midnight
              Color(0xFF0F172A), // Slate black
              Color(0xFF161F33), // Rich navy-slate
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          border: Border(
            bottom: BorderSide(
              color: isReady || isRefreshing
                  ? const Color(0xFFFFFC00).withValues(alpha: 0.85)
                  : const Color(0xFF38BDF8).withValues(alpha: 0.4),
              width: 1.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: (isReady || isRefreshing
                      ? const Color(0xFFFFFC00)
                      : const Color(0xFF38BDF8))
                  .withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Floating Sparkle Particles
            Positioned.fill(
              child: CustomPaint(
                painter: _SwaggerParticleCanvasPainter(
                  particles: particles,
                  intensity: pullRatio.clamp(0.2, 1.0),
                ),
              ),
            ),

            // Ambient Glow Sphere Behind Squad
            Positioned(
              bottom: 12,
              child: Container(
                width: 220,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isReady || isRefreshing
                          ? const Color(0xFFFFFC00).withValues(alpha: 0.28)
                          : const Color(0xFF06B6D4).withValues(alpha: 0.22),
                      blurRadius: 36,
                      spreadRadius: 14,
                    ),
                  ],
                ),
              ),
            ),

            // Content: POCKET MATES Logo + Swagger Squad Characters + Status Pill
            OverflowBox(
              alignment: Alignment.bottomCenter,
              maxHeight: 220,
              minHeight: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔥 "POCKET MATES" Streetwear Graffiti Logo in Background
                    _buildPocketMatesLogo(),

                    const SizedBox(height: 2),

                    // 🕶️ The Swagger Squad Mascot Vector Illustration
                    _SwaggerSquadGraphic(
                      pullRatio: pullRatio,
                      isReady: isReady,
                      isRefreshing: isRefreshing,
                      isSuccess: isSuccess,
                      grooveAnimation: grooveAnimation,
                    ),

                    const SizedBox(height: 5),

                    // Interactive Status Badge Pill
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 140),
                      opacity: (pullRatio > 0.30 || isRefreshing) ? 1.0 : 0.0,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF090D16).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isReady || isRefreshing
                                ? const Color(0xFFFFFC00).withValues(alpha: 0.9)
                                : Colors.white24,
                            width: 1.2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          statusText,
                          style: GoogleFonts.outfit(
                            color: isReady || isRefreshing
                                ? const Color(0xFFFFFC00)
                                : Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPocketMatesLogo() {
    final scale = (pullRatio * 0.9 + 0.1).clamp(0.4, 1.0);

    return Transform.scale(
      scale: scale,
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            Color(0xFFFFFC00), // Snapchat gold
            Color(0xFFFF8A00), // Electric orange
            Color(0xFFFF007A), // Hot magenta
          ],
        ).createShader(bounds),
        child: Text(
          'POCKET MATES',
          textAlign: TextAlign.center,
          style: GoogleFonts.bungee(
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Color(0xFFFFFC00),
                blurRadius: 16,
              ),
              Shadow(
                color: Colors.black,
                offset: Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🕶️ Dynamic Animated Swagger Squad Graphic
class _SwaggerSquadGraphic extends StatelessWidget {
  final double pullRatio;
  final bool isReady;
  final bool isRefreshing;
  final bool isSuccess;
  final Animation<double> grooveAnimation;

  const _SwaggerSquadGraphic({
    required this.pullRatio,
    required this.isReady,
    required this.isRefreshing,
    required this.isSuccess,
    required this.grooveAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: grooveAnimation,
      builder: (context, child) {
        final bounce = isRefreshing
            ? math.sin(grooveAnimation.value * math.pi * 2) * 3.2
            : (pullRatio * 4.0).clamp(0.0, 5.0);

        return Transform.translate(
          offset: Offset(0, -bounce),
          child: SizedBox(
            width: 270,
            height: 82,
            child: CustomPaint(
              painter: _SwaggerSquadCustomPainter(
                pullRatio: pullRatio,
                isReady: isReady,
                isRefreshing: isRefreshing,
                isSuccess: isSuccess,
                groovePhase: grooveAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🎨 Vector Canvas Painter rendering the exact Swagger Crew from the user's reference image
/// Includes:
/// 1. Top Center Boss: Arms crossed in 'X', tilted shades
/// 2. Center Front Boss: Crouched low in swagger squat, arms outstretched
/// 3. Bottom Left Chiller: Lying on elbow looking up with shades
/// 4. Left Middle: Pointing/dabbing to the left with shades
/// 5. Right Front Rocker: Hands doing rock horns 🤘, open hyped mouth & goatee
/// 6. Top Right Swagger: Leaning right in swagger pose
/// Plus signature 4-pointed golden sparkle stars (✦)
class _SwaggerSquadCustomPainter extends CustomPainter {
  final double pullRatio;
  final bool isReady;
  final bool isRefreshing;
  final bool isSuccess;
  final double groovePhase;

  _SwaggerSquadCustomPainter({
    required this.pullRatio,
    required this.isReady,
    required this.isRefreshing,
    required this.isSuccess,
    required this.groovePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Line stroke paint
    final strokePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Sunglasses dark paint
    final shadesPaint = Paint()
      ..color = const Color(0xFF080C14)
      ..style = PaintingStyle.fill;

    // Sunglasses glare paint
    final glarePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    // Character body base paint with soft marshmallow shading
    final whiteBodyPaint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;

    // Gold sparkle paint for 4-point stars
    final goldStarPaint = Paint()
      ..color = const Color(0xFFFFFC00)
      ..style = PaintingStyle.fill;

    // --- DRAW 4-POINTED SIGNATURE STARS (✦) FROM USER'S SKETCH ---
    _drawFourPointStar(canvas, Offset(w * 0.08, h * 0.40), 5.5, goldStarPaint);
    _drawFourPointStar(canvas, Offset(w * 0.36, h * 0.16), 5.0, goldStarPaint);
    _drawFourPointStar(canvas, Offset(w * 0.94, h * 0.72), 6.0, goldStarPaint);

    // =========================================================================
    // CHARACTER 1: TOP-LEFT / LEFT-MIDDLE (Pointing / Dabbing Mate)
    // Head at (w * 0.20, h * 0.32), leaning left, arms pointing left
    // =========================================================================
    {
      final headCenter = Offset(w * 0.20, h * 0.32);
      final headRadius = 14.0;

      // Body leaning left
      final bodyPath = Path()
        ..moveTo(headCenter.dx, headCenter.dy + headRadius * 0.85)
        ..lineTo(w * 0.12, h * 0.58)
        ..lineTo(w * 0.25, h * 0.58)
        ..close();
      canvas.drawPath(
        bodyPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF472B6), Color(0xFFF8FAFC)],
          ).createShader(Rect.fromLTWH(w * 0.10, h * 0.30, 40, 30)),
      );
      canvas.drawPath(bodyPath, strokePaint);

      // Outstretched pointing arms to the left
      final leftArm = Path()
        ..moveTo(headCenter.dx - 6, headCenter.dy + headRadius * 0.8)
        ..lineTo(w * 0.04, h * 0.32) // pointing hand
        ..lineTo(w * 0.02, h * 0.30);
      canvas.drawPath(leftArm, strokePaint..strokeWidth = 2.4);

      final rightArm = Path()
        ..moveTo(headCenter.dx + 4, headCenter.dy + headRadius * 0.9)
        ..lineTo(w * 0.08, h * 0.42);
      canvas.drawPath(rightArm, strokePaint..strokeWidth = 2.4);

      // Head
      canvas.drawCircle(headCenter, headRadius, whiteBodyPaint);
      canvas.drawCircle(headCenter, headRadius, strokePaint..strokeWidth = 2.0);

      // Sunglasses
      _drawSwaggerShades(
        canvas: canvas,
        center: Offset(headCenter.dx - 2, headCenter.dy + 1),
        width: 17,
        height: 7.5,
        shadesPaint: shadesPaint,
        glarePaint: glarePaint,
      );
    }

    // =========================================================================
    // CHARACTER 2: TOP-RIGHT (Fly Swagger Mate)
    // Head at (w * 0.78, h * 0.25), arms bent in swagger dab pose
    // =========================================================================
    {
      final headCenter = Offset(w * 0.78, h * 0.25);
      final headRadius = 14.0;

      // Torso
      final bodyPath = Path()
        ..moveTo(headCenter.dx - 8, headCenter.dy + headRadius * 0.8)
        ..lineTo(w * 0.68, h * 0.48)
        ..lineTo(w * 0.84, h * 0.48)
        ..lineTo(headCenter.dx + 8, headCenter.dy + headRadius * 0.8)
        ..close();
      canvas.drawPath(
        bodyPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF38BDF8), Color(0xFFF8FAFC)],
          ).createShader(Rect.fromLTWH(w * 0.65, h * 0.22, 45, 30)),
      );
      canvas.drawPath(bodyPath, strokePaint);

      // Bent arm dabbing behind head
      final armPath = Path()
        ..moveTo(headCenter.dx + 8, headCenter.dy + headRadius * 0.8)
        ..lineTo(w * 0.88, h * 0.22)
        ..lineTo(w * 0.76, h * 0.34);
      canvas.drawPath(armPath, strokePaint..strokeWidth = 2.4);

      // Head
      canvas.drawCircle(headCenter, headRadius, whiteBodyPaint);
      canvas.drawCircle(headCenter, headRadius, strokePaint..strokeWidth = 2.0);

      // Sunglasses angled
      _drawSwaggerShades(
        canvas: canvas,
        center: Offset(headCenter.dx, headCenter.dy + 1),
        width: 17,
        height: 7.5,
        shadesPaint: shadesPaint,
        glarePaint: glarePaint,
        angle: 0.12,
      );
    }

    // =========================================================================
    // CHARACTER 3: TOP CENTER (Boss Mate with Crossed Arms)
    // Head at (w * 0.50, h * 0.18), arms crossed 'X' over chest, tilted head
    // =========================================================================
    {
      final headCenter = Offset(w * 0.50, h * 0.18);
      final headRadius = 15.0;

      // Upper torso
      final torsoPath = Path()
        ..moveTo(headCenter.dx - 12, headCenter.dy + headRadius * 0.8)
        ..lineTo(w * 0.42, h * 0.50)
        ..lineTo(w * 0.58, h * 0.50)
        ..lineTo(headCenter.dx + 12, headCenter.dy + headRadius * 0.8)
        ..close();
      canvas.drawPath(
        torsoPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF38BDF8), Color(0xFFF8FAFC)],
          ).createShader(Rect.fromLTWH(w * 0.40, h * 0.15, 30, 35)),
      );
      canvas.drawPath(torsoPath, strokePaint);

      // Folded Crossed Arms 'X'
      final arm1 = Path()
        ..moveTo(w * 0.40, h * 0.36)
        ..lineTo(w * 0.58, h * 0.44);
      final arm2 = Path()
        ..moveTo(w * 0.60, h * 0.36)
        ..lineTo(w * 0.42, h * 0.44);
      canvas.drawPath(arm1, strokePaint..strokeWidth = 3.0);
      canvas.drawPath(arm2, strokePaint..strokeWidth = 3.0);

      // Head
      canvas.drawCircle(headCenter, headRadius, whiteBodyPaint);
      canvas.drawCircle(headCenter, headRadius, strokePaint..strokeWidth = 2.0);

      // Boss Sunglasses with sharp gleam
      _drawSwaggerShades(
        canvas: canvas,
        center: Offset(headCenter.dx, headCenter.dy + 1),
        width: 19,
        height: 8.0,
        shadesPaint: shadesPaint,
        glarePaint: glarePaint,
      );

      // Smirk line under sunglasses
      final smirk = Path()
        ..moveTo(headCenter.dx - 3, headCenter.dy + 8)
        ..quadraticBezierTo(headCenter.dx + 1, headCenter.dy + 9.5, headCenter.dx + 4, headCenter.dy + 7.5);
      canvas.drawPath(smirk, strokePaint..strokeWidth = 1.6);
    }

    // =========================================================================
    // CHARACTER 4: BOTTOM-LEFT (The Chiller Reclining on Elbow)
    // Head at (w * 0.16, h * 0.74), body stretched horizontally across bottom
    // =========================================================================
    {
      final headCenter = Offset(w * 0.16, h * 0.74);
      final headRadius = 13.5;

      // Reclined body along ground
      final bodyPath = Path()
        ..moveTo(headCenter.dx + headRadius * 0.7, headCenter.dy + 2)
        ..lineTo(w * 0.38, h * 0.88)
        ..lineTo(w * 0.38, h * 0.98)
        ..lineTo(w * 0.08, h * 0.98)
        ..lineTo(w * 0.08, h * 0.88)
        ..close();
      canvas.drawPath(
        bodyPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFA78BFA), Color(0xFFF8FAFC)],
          ).createShader(Rect.fromLTWH(w * 0.06, h * 0.70, 70, 25)),
      );
      canvas.drawPath(bodyPath, strokePaint);

      // Propping arm: elbow on ground supporting chin
      final armPath = Path()
        ..moveTo(w * 0.08, h * 0.94) // elbow
        ..lineTo(headCenter.dx - 2, headCenter.dy + headRadius * 0.85); // hand to chin
      canvas.drawPath(armPath, strokePaint..strokeWidth = 2.8);

      // Head
      canvas.drawCircle(headCenter, headRadius, whiteBodyPaint);
      canvas.drawCircle(headCenter, headRadius, strokePaint..strokeWidth = 2.0);

      // Reclined Sunglasses looking up
      _drawSwaggerShades(
        canvas: canvas,
        center: Offset(headCenter.dx + 1, headCenter.dy),
        width: 16,
        height: 7.0,
        shadesPaint: shadesPaint,
        glarePaint: glarePaint,
        angle: -0.15,
      );
    }

    // =========================================================================
    // CHARACTER 5: RIGHT FRONT (Rocker Mate with Horns 🤘 and Open Mouth)
    // Head at (w * 0.82, h * 0.60), hands raising rock horns
    // =========================================================================
    {
      final headCenter = Offset(w * 0.82, h * 0.60);
      final headRadius = 14.5;

      // Torso
      final bodyPath = Path()
        ..moveTo(headCenter.dx - 10, headCenter.dy + headRadius * 0.8)
        ..lineTo(w * 0.72, h * 0.92)
        ..lineTo(w * 0.90, h * 0.92)
        ..lineTo(headCenter.dx + 10, headCenter.dy + headRadius * 0.8)
        ..close();
      canvas.drawPath(
        bodyPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xFF34D399), Color(0xFFF8FAFC)],
          ).createShader(Rect.fromLTWH(w * 0.70, h * 0.55, 40, 35)),
      );
      canvas.drawPath(bodyPath, strokePaint);

      // Left arm with Rock Horns 🤘
      final leftRockArm = Path()
        ..moveTo(headCenter.dx - 10, headCenter.dy + headRadius * 0.7)
        ..lineTo(w * 0.68, h * 0.44);
      canvas.drawPath(leftRockArm, strokePaint..strokeWidth = 2.6);
      _drawRockHornsHand(canvas, Offset(w * 0.67, h * 0.40), strokePaint);

      // Right arm with Rock Horns 🤘
      final rightRockArm = Path()
        ..moveTo(headCenter.dx + 10, headCenter.dy + headRadius * 0.7)
        ..lineTo(w * 0.93, h * 0.45);
      canvas.drawPath(rightRockArm, strokePaint..strokeWidth = 2.6);
      _drawRockHornsHand(canvas, Offset(w * 0.94, h * 0.41), strokePaint);

      // Head
      canvas.drawCircle(headCenter, headRadius, whiteBodyPaint);
      canvas.drawCircle(headCenter, headRadius, strokePaint..strokeWidth = 2.0);

      // Rocker Sunglasses
      _drawSwaggerShades(
        canvas: canvas,
        center: Offset(headCenter.dx, headCenter.dy - 1),
        width: 17,
        height: 7.5,
        shadesPaint: shadesPaint,
        glarePaint: glarePaint,
      );

      // Open hyping mouth (😮) with goatee
      canvas.drawCircle(
        Offset(headCenter.dx, headCenter.dy + 7),
        3.2,
        Paint()..color = const Color(0xFF0F172A),
      );
      // Small soul patch goatee
      canvas.drawCircle(
        Offset(headCenter.dx, headCenter.dy + 12),
        1.6,
        Paint()..color = const Color(0xFF0F172A),
      );
    }

    // =========================================================================
    // CHARACTER 6: CENTER FRONT (The Swagger Leader in Low Sumo Crouch)
    // Head at (w * 0.48, h * 0.58), arms outstretched, wide squat legs
    // =========================================================================
    {
      final headCenter = Offset(w * 0.48, h * 0.58);
      final headRadius = 17.5;

      // Wide Squat Legs & Outstretched Arms
      final legsPath = Path()
        // Left squat leg
        ..moveTo(headCenter.dx - 12, headCenter.dy + headRadius * 0.8)
        ..lineTo(w * 0.33, h * 0.75)
        ..lineTo(w * 0.28, h * 0.98)
        ..lineTo(w * 0.38, h * 0.98)
        ..lineTo(w * 0.44, h * 0.82)
        // Center crotch
        ..lineTo(headCenter.dx, h * 0.84)
        // Right squat leg
        ..lineTo(w * 0.52, h * 0.82)
        ..lineTo(w * 0.58, h * 0.98)
        ..lineTo(w * 0.68, h * 0.98)
        ..lineTo(w * 0.63, h * 0.75)
        ..lineTo(headCenter.dx + 12, headCenter.dy + headRadius * 0.8)
        ..close();

      canvas.drawPath(
        legsPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFC00), Color(0xFFF8FAFC)],
          ).createShader(Rect.fromLTWH(w * 0.26, h * 0.55, 90, 40)),
      );
      canvas.drawPath(legsPath, strokePaint..strokeWidth = 2.4);

      // Outstretched Left Arm (pointing to left mate)
      final leftArm = Path()
        ..moveTo(headCenter.dx - 14, headCenter.dy + headRadius * 0.6)
        ..lineTo(w * 0.25, h * 0.52);
      canvas.drawPath(leftArm, strokePaint..strokeWidth = 3.2);

      // Outstretched Right Arm (pointing right)
      final rightArm = Path()
        ..moveTo(headCenter.dx + 14, headCenter.dy + headRadius * 0.6)
        ..lineTo(w * 0.68, h * 0.56);
      canvas.drawPath(rightArm, strokePaint..strokeWidth = 3.2);

      // Head
      canvas.drawCircle(headCenter, headRadius, whiteBodyPaint);
      canvas.drawCircle(headCenter, headRadius, strokePaint..strokeWidth = 2.2);

      // Center Leader Big Glossy Sunglasses
      _drawSwaggerShades(
        canvas: canvas,
        center: Offset(headCenter.dx, headCenter.dy + 1),
        width: 23,
        height: 9.5,
        shadesPaint: shadesPaint,
        glarePaint: glarePaint,
      );

      // Confident mouth line
      final mouth = Path()
        ..moveTo(headCenter.dx - 4, headCenter.dy + 10)
        ..lineTo(headCenter.dx + 4, headCenter.dy + 10);
      canvas.drawPath(mouth, strokePaint..strokeWidth = 1.8);
    }
  }

  /// 🕶️ Helper to draw glossy sunglasses with diagonal reflective gleam lines
  void _drawSwaggerShades({
    required Canvas canvas,
    required Offset center,
    required double width,
    required double height,
    required Paint shadesPaint,
    required Paint glarePaint,
    double angle = 0.0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (angle != 0.0) {
      canvas.rotate(angle);
    }

    final halfW = width / 2;
    final halfH = height / 2;
    final lensW = halfW * 0.90;

    // Left Lens
    final leftRect = Rect.fromCenter(
      center: Offset(-halfW * 0.55, 0),
      width: lensW,
      height: height,
    );
    final leftRRect = RRect.fromRectAndRadius(leftRect, Radius.circular(height * 0.35));
    canvas.drawRRect(leftRRect, shadesPaint);

    // Right Lens
    final rightRect = Rect.fromCenter(
      center: Offset(halfW * 0.55, 0),
      width: lensW,
      height: height,
    );
    final rightRRect = RRect.fromRectAndRadius(rightRect, Radius.circular(height * 0.35));
    canvas.drawRRect(rightRRect, shadesPaint);

    // Bridge
    canvas.drawLine(
      Offset(-halfW * 0.15, -halfH * 0.3),
      Offset(halfW * 0.15, -halfH * 0.3),
      shadesPaint..strokeWidth = 2.0..style = PaintingStyle.stroke,
    );
    shadesPaint.style = PaintingStyle.fill;

    // White diagonal gleam streaks on lenses (//)
    canvas.drawLine(
      Offset(-halfW * 0.75, halfH * 0.4),
      Offset(-halfW * 0.45, -halfH * 0.4),
      glarePaint,
    );
    canvas.drawLine(
      Offset(halfW * 0.35, halfH * 0.4),
      Offset(halfW * 0.65, -halfH * 0.4),
      glarePaint,
    );

    canvas.restore();
  }

  /// 🤘 Helper to draw Rock Horns hand gesture
  void _drawRockHornsHand(Canvas canvas, Offset pos, Paint stroke) {
    // Index finger up
    canvas.drawLine(pos, Offset(pos.dx - 2, pos.dy - 6), stroke..strokeWidth = 2.0);
    // Pinky finger up
    canvas.drawLine(Offset(pos.dx + 4, pos.dy), Offset(pos.dx + 6, pos.dy - 6), stroke..strokeWidth = 2.0);
    // Closed middle fingers
    canvas.drawCircle(Offset(pos.dx + 1, pos.dy), 2.2, stroke..strokeWidth = 1.8..style = PaintingStyle.stroke);
  }

  /// ✦ Helper to draw 4-pointed golden sparkle star
  void _drawFourPointStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    final inner = radius * 0.28;

    path.moveTo(center.dx, center.dy - radius);
    path.quadraticBezierTo(center.dx, center.dy - inner, center.dx + inner, center.dy);
    path.quadraticBezierTo(center.dx + inner, center.dy, center.dx + radius, center.dy);
    path.quadraticBezierTo(center.dx + inner, center.dy, center.dx, center.dy + inner);
    path.quadraticBezierTo(center.dx, center.dy + inner, center.dx, center.dy + radius);
    path.quadraticBezierTo(center.dx, center.dy + inner, center.dx - inner, center.dy);
    path.quadraticBezierTo(center.dx - inner, center.dy, center.dx - radius, center.dy);
    path.quadraticBezierTo(center.dx - inner, center.dy, center.dx, center.dy - inner);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SwaggerSquadCustomPainter oldDelegate) {
    return oldDelegate.pullRatio != pullRatio ||
        oldDelegate.isReady != isReady ||
        oldDelegate.isRefreshing != isRefreshing ||
        oldDelegate.isSuccess != isSuccess ||
        oldDelegate.groovePhase != groovePhase;
  }
}

/// 🎨 Particle Canvas Painter for Floating Street Sparkles
class _SwaggerParticleCanvasPainter extends CustomPainter {
  final List<_SwaggerParticle> particles;
  final double intensity;

  _SwaggerParticleCanvasPainter({
    required this.particles,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final x = p.xRatio * size.width + math.sin(p.wobblePhase) * 12.0;
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
  bool shouldRepaint(covariant _SwaggerParticleCanvasPainter oldDelegate) => true;
}
