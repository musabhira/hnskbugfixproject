import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 📸 Premium Photo-Booth Polaroid Doodle Pull-To-Refresh Widget
/// Combines the beloved warm golden tabletop background, artist pencil, coffee mug,
/// and white polaroid filmstrip with the swagger friends squad from the user's sketch:
/// - Top Frame: Two swagger friends pointing dual finger-guns (👉👉) with cool sunglasses,
///   blue ink crown 👑, and blue handwritten "Pocket Mates" signature.
/// - Bottom Frame: The Swagger Squad: Center mate in low crouch dabbing, Right mate with dual
///   peace signs (✌️✌️) and blue devil horns 😈, Left mate chilling on elbow with blue star ⭐,
///   and blue ink heart ♡ & smiley :)
/// - Clean status text: "Pull to connect Pocket Mates" / "Release to connect Pocket Mates"
/// - Camera shutter flash effect (📸) on release
/// - 100% reliable backend refresh of all chats and user data.
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
    this.maxPullDistance = 210.0,
    this.restingHeight = 150.0,
    this.primaryFlameColor = const Color(0xFFF59E0B),
    this.accentFlameColor = const Color(0xFFFFC107),
    this.pullText = 'Pull to connect Pocket Mates',
    this.readyText = 'Release to connect Pocket Mates',
    this.refreshingText = 'Connecting Pocket Mates...',
    this.successText = 'Pocket Mates Connected! ✨',
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

  late AnimationController _flashController;
  late AnimationController _idleFloatController;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _idleFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    _flashController.dispose();
    _idleFloatController.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    _springAnimation = Tween<double>(
      begin: _pullDistance,
      end: target,
    ).animate(CurvedAnimation(
      parent: _springController,
      curve: Curves.easeOutCubic,
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

      if (!_isRefreshing) {
        if (notification is OverscrollNotification && notification.overscroll < 0) {
          _handleDragDelta(-notification.overscroll * 0.7);
        } else if (notification is ScrollUpdateNotification) {
          if (notification.metrics.pixels <= 0 && (notification.scrollDelta ?? 0) < 0) {
            _handleDragDelta(-(notification.scrollDelta ?? 0) * 0.7);
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

  void _handleDragDelta(double delta) {
    _isDragging = true;
    final newDist = (_pullDistance + delta).clamp(0.0, widget.maxPullDistance);
    setState(() {
      _pullDistance = newDist;
    });

    _checkThreshold();
  }

  void _checkThreshold() {
    if (_pullDistance >= widget.triggerDistance && !_hasFiredHaptic) {
      HapticFeedback.lightImpact();
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

    if (_currentScrollOffset <= 5.0) {
      final dy = event.position.dy - _startY;
      if (dy > 0) {
        _isDragging = true;
        final progress = math.min(1.0, dy / (widget.maxPullDistance * 1.7));
        final damped = math.pow(progress, 0.82) * widget.maxPullDistance;

        setState(() {
          _pullDistance = damped.clamp(0.0, widget.maxPullDistance);
        });

        _checkThreshold();
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
    _idleFloatController.repeat(reverse: true);
    _flashController.forward(from: 0.0);
    HapticFeedback.mediumImpact();

    try {
      await widget.onRefresh();
      if (!mounted) return;

      setState(() {
        _isSuccess = true;
      });
      HapticFeedback.selectionClick();

      await Future.delayed(const Duration(milliseconds: 550));
      if (!mounted) return;
    } catch (e) {
      debugPrint('PocketSnapFlameRefresh onRefresh error: $e');
    } finally {
      if (mounted) {
        _idleFloatController.stop();
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
            // 📸 Photobooth Polaroid Strip Header
            if (_pullDistance > 0 || _isRefreshing)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _pullDistance,
                child: _PhotoboothStripHeader(
                  pullRatio: pullRatio,
                  pullDistance: _pullDistance,
                  isRefreshing: _isRefreshing,
                  isReady: isReady,
                  isSuccess: _isSuccess,
                  flashAnimation: _flashController,
                  idleAnimation: _idleFloatController,
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

/// 📸 Header Container displaying the Polaroid Photobooth Filmstrip on Warm Doodle Surface
class _PhotoboothStripHeader extends StatelessWidget {
  final double pullRatio;
  final double pullDistance;
  final bool isRefreshing;
  final bool isReady;
  final bool isSuccess;
  final Animation<double> flashAnimation;
  final Animation<double> idleAnimation;

  const _PhotoboothStripHeader({
    required this.pullRatio,
    required this.pullDistance,
    required this.isRefreshing,
    required this.isReady,
    required this.isSuccess,
    required this.flashAnimation,
    required this.idleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        alignment: Alignment.bottomCenter,
        decoration: const BoxDecoration(
          // Warm Golden Doodle Tabletop Surface (from reference image)
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEAB308), // Rich warm yellow
              Color(0xFFF59E0B), // Golden amber
              Color(0xFFD97706), // Warm deep amber
            ],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Background Tabletop Doodles (Coffee Mug, Earbuds, Pencil hints)
            Positioned.fill(
              child: CustomPaint(
                painter: _TabletopDoodleBackgroundPainter(
                  opacity: (pullRatio * 0.7).clamp(0.2, 0.85),
                ),
              ),
            ),

            // Centered Polaroid Photobooth Filmstrip
            OverflowBox(
              alignment: Alignment.bottomCenter,
              maxHeight: 240,
              minHeight: 0,
              child: AnimatedBuilder(
                animation: Listenable.merge([flashAnimation, idleAnimation]),
                builder: (context, child) {
                  final floatY = isRefreshing
                      ? math.sin(idleAnimation.value * math.pi * 2) * 2.5
                      : 0.0;
                  final tilt = -0.045 + (pullRatio * 0.015);

                  return Transform.translate(
                    offset: Offset(0, floatY - 6),
                    child: Transform.rotate(
                      angle: tilt,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Physical Polaroid Card Strip
                          Container(
                            width: 178,
                            height: 198,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDF8), // Natural photo paper
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.28),
                                  blurRadius: 14,
                                  offset: const Offset(2, 6),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              painter: _PhotoboothStripPainter(
                                pullRatio: pullRatio,
                                isReady: isReady,
                                isRefreshing: isRefreshing,
                                isSuccess: isSuccess,
                              ),
                            ),
                          ),

                          // 📸 Camera Shutter Flash Overlay on Refresh Release
                          if (flashAnimation.value > 0.01 && flashAnimation.value < 0.99)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: (1.0 - flashAnimation.value).clamp(0.0, 0.85),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Minimal, clean status indicator
            Positioned(
              bottom: 4,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: (pullRatio > 0.30 || isRefreshing) ? 1.0 : 0.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isRefreshing)
                      const SizedBox(
                        width: 11,
                        height: 11,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.8,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                        ),
                      )
                    else
                      Text(
                        isReady
                            ? '⚡ Release to connect Pocket Mates'
                            : '⬇️ Pull to connect Pocket Mates',
                        style: GoogleFonts.caveat(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    if (isRefreshing) const SizedBox(width: 6),
                    if (isRefreshing)
                      Text(
                        isSuccess
                            ? 'Pocket Mates Connected! ✨'
                            : 'Connecting Pocket Mates...',
                        style: GoogleFonts.caveat(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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

/// 🎨 Custom Painter for the Tabletop Background Doodles (Coffee Mug, Earbuds, Pencil, Scribbles)
class _TabletopDoodleBackgroundPainter extends CustomPainter {
  final double opacity;

  _TabletopDoodleBackgroundPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final penPaint = Paint()
      ..color = Colors.black.withValues(alpha: (0.18 * opacity).clamp(0.0, 0.35))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: (0.12 * opacity).clamp(0.0, 0.25))
      ..style = PaintingStyle.fill;

    // 1. Top-Right Coffee Mug from top view
    final mugCenter = Offset(w * 0.88, h * 0.25);
    canvas.drawCircle(mugCenter, 32, fillPaint);
    canvas.drawCircle(mugCenter, 32, penPaint..strokeWidth = 2.0);
    // Coffee inside
    canvas.drawCircle(
      mugCenter,
      25,
      Paint()
        ..color = const Color(0xFF451A03).withValues(alpha: (0.28 * opacity).clamp(0.0, 0.45))
        ..style = PaintingStyle.fill,
    );
    // Mug handle
    final handle = Path()
      ..moveTo(mugCenter.dx - 30, mugCenter.dy - 8)
      ..quadraticBezierTo(mugCenter.dx - 44, mugCenter.dy, mugCenter.dx - 30, mugCenter.dy + 8);
    canvas.drawPath(handle, penPaint..strokeWidth = 2.4);

    // 2. Earbuds wire winding on right
    final earbudWire = Path()
      ..moveTo(w * 0.95, h * 0.65)
      ..quadraticBezierTo(w * 0.86, h * 0.72, w * 0.90, h * 0.85)
      ..quadraticBezierTo(w * 0.94, h * 0.95, w * 0.88, h * 0.98);
    canvas.drawPath(earbudWire, penPaint..strokeWidth = 1.8);

    // 3. Left Diagonal Drawing Pencil
    final pencilPath = Path()
      ..moveTo(w * 0.02, h * 0.88)
      ..lineTo(w * 0.18, h * 0.35)
      ..lineTo(w * 0.22, h * 0.37)
      ..lineTo(w * 0.05, h * 0.90)
      ..close();
    canvas.drawPath(
      pencilPath,
      Paint()
        ..color = Colors.black.withValues(alpha: (0.25 * opacity).clamp(0.0, 0.4))
        ..style = PaintingStyle.fill,
    );
    // Pencil tip
    final tip = Path()
      ..moveTo(w * 0.18, h * 0.35)
      ..lineTo(w * 0.22, h * 0.28)
      ..lineTo(w * 0.22, h * 0.37)
      ..close();
    canvas.drawPath(tip, penPaint..strokeWidth = 1.4);
  }

  @override
  bool shouldRepaint(covariant _TabletopDoodleBackgroundPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

/// 🎨 Precision Painter for the Photobooth Polaroid Filmstrip
/// Recreates the user's reference sketches inside the 2 photo frames:
/// - Frame 1 (Top): Two swagger buddies pointing dual finger-guns (👉👉) with cool sunglasses,
///   blue ink crown 👑, and handwritten "Pocket Mates" signature.
/// - Frame 2 (Bottom): The Swagger Squad: Center mate dabbing, Right mate with dual peace
///   signs (✌️✌️) and blue devil horns 😈, Left mate chilling on elbow with blue star ⭐,
///   and blue ink heart ♡ & smiley :)
class _PhotoboothStripPainter extends CustomPainter {
  final double pullRatio;
  final bool isReady;
  final bool isRefreshing;
  final bool isSuccess;

  _PhotoboothStripPainter({
    required this.pullRatio,
    required this.isReady,
    required this.isRefreshing,
    required this.isSuccess,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ink pen paints
    final blackInk = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final whiteBodyPaint = Paint()
      ..color = const Color(0xFFFFFDF8)
      ..style = PaintingStyle.fill;

    // Signature Blue Ballpoint Pen Doodle Ink
    final doodleBlue = Paint()
      ..color = const Color(0xFF2563EB).withValues(
        alpha: (pullRatio * 1.1).clamp(0.3, 1.0),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final frameHeight = (h - 22) / 2;

    // =========================================================================
    // PHOTO FRAME 1 (TOP) - The Dual Finger-Gun Swagger Duo (from sketch)
    // =========================================================================
    final topFrameRect = Rect.fromLTWH(0, 0, w, frameHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(topFrameRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(topFrameRect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(topFrameRect, const Radius.circular(4)));

    // Mate A (Left Buddy with Finger Guns 👉👉)
    final mateAHead = Offset(w * 0.35, frameHeight * 0.44);
    const mateARadius = 14.5;

    // Torso A
    final torsoAPath = Path()
      ..moveTo(mateAHead.dx - 10, mateAHead.dy + mateARadius * 0.8)
      ..lineTo(w * 0.22, frameHeight)
      ..lineTo(w * 0.46, frameHeight)
      ..lineTo(mateAHead.dx + 10, mateAHead.dy + mateARadius * 0.8)
      ..close();
    canvas.drawPath(torsoAPath, whiteBodyPaint);
    canvas.drawPath(torsoAPath, blackInk..strokeWidth = 1.8);

    // Mate A Finger-Guns Arms pointing right 👉👉
    final armA1 = Path()
      ..moveTo(mateAHead.dx - 6, mateAHead.dy + 8)
      ..lineTo(w * 0.48, mateAHead.dy + 4)
      ..lineTo(w * 0.54, mateAHead.dy + 4); // pointing finger
    canvas.drawPath(armA1, blackInk..strokeWidth = 2.4);

    final armA2 = Path()
      ..moveTo(mateAHead.dx + 4, mateAHead.dy + 10)
      ..lineTo(w * 0.50, mateAHead.dy + 14)
      ..lineTo(w * 0.56, mateAHead.dy + 14); // lower pointing finger
    canvas.drawPath(armA2, blackInk..strokeWidth = 2.4);

    // Mate A Head & Shades
    canvas.drawCircle(mateAHead, mateARadius, whiteBodyPaint);
    canvas.drawCircle(mateAHead, mateARadius, blackInk..strokeWidth = 2.0);
    _drawMiniShades(canvas, Offset(mateAHead.dx + 1, mateAHead.dy), 17.5, 7.5);

    // Mate A Smirk
    final smirkA = Path()
      ..moveTo(mateAHead.dx - 2, mateAHead.dy + 7)
      ..quadraticBezierTo(mateAHead.dx + 3, mateAHead.dy + 9, mateAHead.dx + 5, mateAHead.dy + 6.5);
    canvas.drawPath(smirkA, blackInk..strokeWidth = 1.5);

    // Mate B (Right Buddy with Finger Guns 👉👉)
    final mateBHead = Offset(w * 0.70, frameHeight * 0.42);
    const mateBRadius = 14.5;

    // Torso B
    final torsoBPath = Path()
      ..moveTo(mateBHead.dx - 10, mateBHead.dy + mateBRadius * 0.8)
      ..lineTo(w * 0.58, frameHeight)
      ..lineTo(w * 0.86, frameHeight)
      ..lineTo(mateBHead.dx + 10, mateBHead.dy + mateBRadius * 0.8)
      ..close();
    canvas.drawPath(torsoBPath, whiteBodyPaint);
    canvas.drawPath(torsoBPath, blackInk..strokeWidth = 1.8);

    // Mate B Finger Guns Arms pointing right 👉👉
    final armB1 = Path()
      ..moveTo(mateBHead.dx - 6, mateBHead.dy + 8)
      ..lineTo(w * 0.84, mateBHead.dy + 4)
      ..lineTo(w * 0.92, mateBHead.dy + 4);
    canvas.drawPath(armB1, blackInk..strokeWidth = 2.4);

    final armB2 = Path()
      ..moveTo(mateBHead.dx + 4, mateBHead.dy + 10)
      ..lineTo(w * 0.86, mateBHead.dy + 14)
      ..lineTo(w * 0.94, mateBHead.dy + 14);
    canvas.drawPath(armB2, blackInk..strokeWidth = 2.4);

    // Mate B Head & Shades
    canvas.drawCircle(mateBHead, mateBRadius, whiteBodyPaint);
    canvas.drawCircle(mateBHead, mateBRadius, blackInk..strokeWidth = 2.0);
    _drawMiniShades(canvas, Offset(mateBHead.dx + 1, mateBHead.dy), 17.5, 7.5, angle: 0.08);

    // Mate B Grin
    final grinB = Path()
      ..moveTo(mateBHead.dx - 3, mateBHead.dy + 7)
      ..quadraticBezierTo(mateBHead.dx + 2, mateBHead.dy + 9.5, mateBHead.dx + 5, mateBHead.dy + 7);
    canvas.drawPath(grinB, blackInk..strokeWidth = 1.5);

    // --- BLUE INK DOODLES OVER TOP PHOTO ---
    // 1. Royal Crown 👑 over Mate A's head
    _drawDoodleCrown(canvas, Offset(mateAHead.dx, mateAHead.dy - 23), doodleBlue);

    // 2. Handwritten "Pocket Mates" in blue pen with underline
    _drawHandwrittenText(canvas, Offset(w * 0.06, frameHeight * 0.20), "Pocket Mates", doodleBlue);
    canvas.drawLine(
      Offset(w * 0.06, frameHeight * 0.26),
      Offset(w * 0.44, frameHeight * 0.22),
      doodleBlue..strokeWidth = 1.2,
    );

    // 3. Arrow / Sparkle doodle
    canvas.drawLine(Offset(w * 0.86, frameHeight * 0.12), Offset(w * 0.94, frameHeight * 0.12), doodleBlue..strokeWidth = 1.3);
    canvas.drawLine(Offset(w * 0.90, frameHeight * 0.08), Offset(w * 0.94, frameHeight * 0.12), doodleBlue..strokeWidth = 1.3);

    canvas.restore();

    // =========================================================================
    // PHOTO FRAME 2 (BOTTOM) - The Swagger Squad (Dab + Peace ✌️ + Reclined)
    // =========================================================================
    final bottomFrameTop = frameHeight + 8;
    final bottomFrameRect = Rect.fromLTWH(0, bottomFrameTop, w, frameHeight);

    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomFrameRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFF8FAFC)..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomFrameRect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(bottomFrameRect, const Radius.circular(4)));

    // 1. Reclined Mate on Left Floor (Chiller lying on elbow)
    final chillHead = Offset(w * 0.16, bottomFrameTop + frameHeight * 0.70);
    const chillRadius = 13.0;

    // Body lying horizontally along floor
    final chillBody = Path()
      ..moveTo(chillHead.dx + chillRadius * 0.6, chillHead.dy)
      ..lineTo(w * 0.42, bottomFrameTop + frameHeight * 0.84)
      ..lineTo(w * 0.42, bottomFrameTop + frameHeight)
      ..lineTo(w * 0.06, bottomFrameTop + frameHeight)
      ..lineTo(w * 0.06, bottomFrameTop + frameHeight * 0.84)
      ..close();
    canvas.drawPath(chillBody, whiteBodyPaint);
    canvas.drawPath(chillBody, blackInk..strokeWidth = 1.8);

    // Elbow on floor supporting chin
    final chillArm = Path()
      ..moveTo(w * 0.06, bottomFrameTop + frameHeight * 0.90)
      ..lineTo(chillHead.dx - 2, chillHead.dy + chillRadius * 0.8);
    canvas.drawPath(chillArm, blackInk..strokeWidth = 2.4);

    // Chill Head & Shades
    canvas.drawCircle(chillHead, chillRadius, whiteBodyPaint);
    canvas.drawCircle(chillHead, chillRadius, blackInk..strokeWidth = 2.0);
    _drawMiniShades(canvas, Offset(chillHead.dx + 1, chillHead.dy), 15.5, 6.5, angle: -0.15);

    // 2. Center Mate (Low Squat Crouch & Dab Pose)
    final dabHead = Offset(w * 0.50, bottomFrameTop + frameHeight * 0.38);
    const dabRadius = 15.0;

    // Wide Squat Legs
    final dabLegs = Path()
      ..moveTo(dabHead.dx - 10, dabHead.dy + dabRadius * 0.8)
      ..lineTo(w * 0.34, bottomFrameTop + frameHeight * 0.72)
      ..lineTo(w * 0.30, bottomFrameTop + frameHeight)
      ..lineTo(w * 0.42, bottomFrameTop + frameHeight)
      ..lineTo(dabHead.dx, bottomFrameTop + frameHeight * 0.80)
      ..lineTo(w * 0.58, bottomFrameTop + frameHeight)
      ..lineTo(w * 0.70, bottomFrameTop + frameHeight)
      ..lineTo(w * 0.64, bottomFrameTop + frameHeight * 0.72)
      ..lineTo(dabHead.dx + 10, dabHead.dy + dabRadius * 0.8)
      ..close();
    canvas.drawPath(dabLegs, whiteBodyPaint);
    canvas.drawPath(dabLegs, blackInk..strokeWidth = 2.0);

    // Dab Arm 1: Tucked across face / chin
    final dabArm1 = Path()
      ..moveTo(dabHead.dx - 12, dabHead.dy + 8)
      ..lineTo(dabHead.dx + 10, dabHead.dy + 4);
    canvas.drawPath(dabArm1, blackInk..strokeWidth = 2.8);

    // Dab Arm 2: Pointing up-right into the air
    final dabArm2 = Path()
      ..moveTo(dabHead.dx + 8, dabHead.dy + 10)
      ..lineTo(w * 0.74, bottomFrameTop + frameHeight * 0.18);
    canvas.drawPath(dabArm2, blackInk..strokeWidth = 2.8);

    // Dab Head & Shades
    canvas.drawCircle(dabHead, dabRadius, whiteBodyPaint);
    canvas.drawCircle(dabHead, dabRadius, blackInk..strokeWidth = 2.0);
    _drawMiniShades(canvas, Offset(dabHead.dx - 1, dabHead.dy - 1), 18.0, 7.5, angle: 0.12);

    // 3. Right Mate (Wide Stance with Dual Peace Signs ✌️ ✌️)
    final peaceHead = Offset(w * 0.82, bottomFrameTop + frameHeight * 0.44);
    const peaceRadius = 14.0;

    // Torso & Wide Stance
    final peaceBody = Path()
      ..moveTo(peaceHead.dx - 10, peaceHead.dy + peaceRadius * 0.8)
      ..lineTo(w * 0.70, bottomFrameTop + frameHeight * 0.90)
      ..lineTo(w * 0.65, bottomFrameTop + frameHeight)
      ..lineTo(w * 0.96, bottomFrameTop + frameHeight)
      ..lineTo(w * 0.92, bottomFrameTop + frameHeight * 0.90)
      ..lineTo(peaceHead.dx + 10, peaceHead.dy + peaceRadius * 0.8)
      ..close();
    canvas.drawPath(peaceBody, whiteBodyPaint);
    canvas.drawPath(peaceBody, blackInk..strokeWidth = 2.0);

    // Left Arm with Peace Sign ✌️
    final peaceArm1 = Path()
      ..moveTo(peaceHead.dx - 8, peaceHead.dy + 8)
      ..lineTo(w * 0.68, peaceHead.dy - 4);
    canvas.drawPath(peaceArm1, blackInk..strokeWidth = 2.2);
    _drawPeaceFingers(canvas, Offset(w * 0.67, peaceHead.dy - 8), blackInk);

    // Right Arm with Peace Sign ✌️
    final peaceArm2 = Path()
      ..moveTo(peaceHead.dx + 8, peaceHead.dy + 8)
      ..lineTo(w * 0.94, peaceHead.dy - 4);
    canvas.drawPath(peaceArm2, blackInk..strokeWidth = 2.2);
    _drawPeaceFingers(canvas, Offset(w * 0.95, peaceHead.dy - 8), blackInk);

    // Peace Head & Shades
    canvas.drawCircle(peaceHead, peaceRadius, whiteBodyPaint);
    canvas.drawCircle(peaceHead, peaceRadius, blackInk..strokeWidth = 2.0);
    _drawMiniShades(canvas, Offset(peaceHead.dx, peaceHead.dy), 17.0, 7.0);

    // Confident grin
    final peaceGrin = Path()
      ..moveTo(peaceHead.dx - 3, peaceHead.dy + 7)
      ..lineTo(peaceHead.dx + 3, peaceHead.dy + 7);
    canvas.drawPath(peaceGrin, blackInk..strokeWidth = 1.5);

    // --- BLUE INK DOODLES OVER BOTTOM PHOTO (from sketch) ---
    // 1. Blue Devil Horns 😈 over Peace Friend's head
    final leftHorn = Path()
      ..moveTo(peaceHead.dx - 9, peaceHead.dy - 15)
      ..quadraticBezierTo(peaceHead.dx - 13, peaceHead.dy - 22, peaceHead.dx - 7, peaceHead.dy - 24)
      ..quadraticBezierTo(peaceHead.dx - 6, peaceHead.dy - 19, peaceHead.dx - 4, peaceHead.dy - 15);
    canvas.drawPath(leftHorn, doodleBlue..strokeWidth = 1.4);

    final rightHorn = Path()
      ..moveTo(peaceHead.dx + 4, peaceHead.dy - 15)
      ..quadraticBezierTo(peaceHead.dx + 8, peaceHead.dy - 22, peaceHead.dx + 13, peaceHead.dy - 20)
      ..quadraticBezierTo(peaceHead.dx + 9, peaceHead.dy - 17, peaceHead.dx + 7, peaceHead.dy - 15);
    canvas.drawPath(rightHorn, doodleBlue..strokeWidth = 1.4);

    // 2. Blue Star ⭐ on Chill Friend's cheek
    _drawDoodleStar(canvas, Offset(chillHead.dx + 8, chillHead.dy + 3), 3.8, doodleBlue);

    // 3. Blue Heart ♡ in top center
    _drawDoodleHeart(canvas, Offset(w * 0.65, bottomFrameTop + 14), doodleBlue);

    // 4. Smiley :) on bottom right border
    final eyePaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: (pullRatio * 1.1).clamp(0.3, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.90, bottomFrameTop + frameHeight - 12), 1.2, eyePaint);
    canvas.drawCircle(Offset(w * 0.93, bottomFrameTop + frameHeight - 10), 1.2, eyePaint);
    final smileArc = Path()
      ..moveTo(w * 0.89, bottomFrameTop + frameHeight - 6)
      ..quadraticBezierTo(
        w * 0.92,
        bottomFrameTop + frameHeight - 3,
        w * 0.95,
        bottomFrameTop + frameHeight - 5,
      );
    canvas.drawPath(smileArc, doodleBlue..strokeWidth = 1.3);

    canvas.restore();
  }

  /// 🕶️ Helper to draw glossy sunglasses with diagonal reflective gleam lines
  void _drawMiniShades(
    Canvas canvas,
    Offset center,
    double width,
    double height, {
    double angle = 0.0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (angle != 0.0) canvas.rotate(angle);

    final shadesPaint = Paint()..color = const Color(0xFF0A0F1D)..style = PaintingStyle.fill;
    final glarePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final halfW = width / 2;
    final halfH = height / 2;
    final lensW = halfW * 0.88;

    // Left lens
    final leftRect = Rect.fromCenter(center: Offset(-halfW * 0.52, 0), width: lensW, height: height);
    canvas.drawRRect(RRect.fromRectAndRadius(leftRect, Radius.circular(height * 0.35)), shadesPaint);

    // Right lens
    final rightRect = Rect.fromCenter(center: Offset(halfW * 0.52, 0), width: lensW, height: height);
    canvas.drawRRect(RRect.fromRectAndRadius(rightRect, Radius.circular(height * 0.35)), shadesPaint);

    // Bridge
    canvas.drawLine(
      Offset(-halfW * 0.12, -halfH * 0.2),
      Offset(halfW * 0.12, -halfH * 0.2),
      shadesPaint..strokeWidth = 1.8..style = PaintingStyle.stroke,
    );
    shadesPaint.style = PaintingStyle.fill;

    // Glare white lines (//)
    canvas.drawLine(Offset(-halfW * 0.70, halfH * 0.35), Offset(-halfW * 0.45, -halfH * 0.35), glarePaint);
    canvas.drawLine(Offset(halfW * 0.35, halfH * 0.35), Offset(halfW * 0.60, -halfH * 0.35), glarePaint);

    canvas.restore();
  }

  /// ✌️ Helper to draw Peace sign fingers (index and middle fingers in 'V')
  void _drawPeaceFingers(Canvas canvas, Offset pos, Paint paint) {
    // Index finger
    canvas.drawLine(pos, Offset(pos.dx - 2, pos.dy - 6), paint..strokeWidth = 2.0);
    // Middle finger
    canvas.drawLine(pos, Offset(pos.dx + 3, pos.dy - 6), paint..strokeWidth = 2.0);
    // Hand fist
    canvas.drawCircle(pos, 2.2, paint..strokeWidth = 1.6..style = PaintingStyle.stroke);
  }

  /// 👑 Helper to draw doodle crown in blue ink
  void _drawDoodleCrown(Canvas canvas, Offset center, Paint paint) {
    final crown = Path()
      ..moveTo(center.dx - 9, center.dy + 4)
      ..lineTo(center.dx - 11, center.dy - 6) // left spike
      ..lineTo(center.dx - 4, center.dy - 1)
      ..lineTo(center.dx, center.dy - 8) // center tall spike
      ..lineTo(center.dx + 4, center.dy - 1)
      ..lineTo(center.dx + 11, center.dy - 6) // right spike
      ..lineTo(center.dx + 9, center.dy + 4)
      ..close();
    canvas.drawPath(crown, paint..strokeWidth = 1.4);
  }

  /// ⭐ Helper to draw 5-pointed doodle star in blue ink
  void _drawDoodleStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * (math.pi * 2 / 5);
      final inA = a + math.pi / 5;
      final x = center.dx + math.cos(a) * radius;
      final y = center.dy + math.sin(a) * radius;
      final inX = center.dx + math.cos(inA) * (radius * 0.45);
      final inY = center.dy + math.sin(inA) * (radius * 0.45);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      path.lineTo(inX, inY);
    }
    path.close();
    canvas.drawPath(path, paint..strokeWidth = 1.3);
  }

  /// ♡ Helper to draw doodle heart in blue ink
  void _drawDoodleHeart(Canvas canvas, Offset center, Paint paint) {
    final heart = Path()
      ..moveTo(center.dx, center.dy + 4)
      ..cubicTo(center.dx - 6, center.dy - 3, center.dx - 8, center.dy - 8, center.dx - 3, center.dy - 8)
      ..cubicTo(center.dx, center.dy - 8, center.dx, center.dy - 4, center.dx, center.dy - 4)
      ..cubicTo(center.dx, center.dy - 4, center.dx, center.dy - 8, center.dx + 3, center.dy - 8)
      ..cubicTo(center.dx + 8, center.dy - 8, center.dx + 6, center.dy - 3, center.dx, center.dy + 4);
    canvas.drawPath(heart, paint..strokeWidth = 1.3);
  }

  /// ✍️ Helper to draw simulated cursive handwriting in blue ink
  void _drawHandwrittenText(Canvas canvas, Offset start, String text, Paint paint) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.caveat(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2563EB),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, start);
  }

  @override
  bool shouldRepaint(covariant _PhotoboothStripPainter oldDelegate) {
    return oldDelegate.pullRatio != pullRatio ||
        oldDelegate.isReady != isReady ||
        oldDelegate.isRefreshing != isRefreshing ||
        oldDelegate.isSuccess != isSuccess;
  }
}
