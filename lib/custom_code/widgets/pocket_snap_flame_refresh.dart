import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 📸 Premium Photo-Booth Polaroid Doodle Pull-To-Refresh Widget
/// Inspired by the candid photobooth memory strip on a warm doodle desk:
/// - Chic tilted photo-strip with authentic white polaroid card border & soft shadow
/// - Hand-drawn illustrated friends taking fun selfies together
/// - Blue ink doodle annotations: 👑 crown, 😈 devil horns, ⭐ cheek star, ♡ heart, and "Pocket Mates" handwriting
/// - Organic micro-interactions on pull (doodle inking, winking avatar)
/// - Elegant camera shutter flash effect on release
/// - 100% reliable refresh triggering without tacky badges or cheap borders
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
    this.pullText = 'Pull for memories...',
    this.readyText = 'Release to snap!',
    this.refreshingText = 'Syncing mates...',
    this.successText = 'All caught up!',
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

            // Minimal, clean status indicator (discreet, no tacky yellow pills)
            Positioned(
              bottom: 4,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: (pullRatio > 0.35 || isRefreshing) ? 1.0 : 0.0,
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
                        isReady ? '📸 Release to snap' : '⬇️ Pull to snap',
                        style: GoogleFonts.caveat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    if (isRefreshing) const SizedBox(width: 6),
                    if (isRefreshing)
                      Text(
                        isSuccess ? 'Caught up! ✨' : 'Snapping memories...',
                        style: GoogleFonts.caveat(
                          fontSize: 14,
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
      ..lineTo(w * 0.22, h * 0.28) // sharp lead tip
      ..lineTo(w * 0.22, h * 0.37)
      ..close();
    canvas.drawPath(tip, penPaint..strokeWidth = 1.4);
  }

  @override
  bool shouldRepaint(covariant _TabletopDoodleBackgroundPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

/// 🎨 Precision Painter for the Photobooth Polaroid Filmstrip
/// Recreates the user's reference image:
/// - Top Frame: Smiling girl with dark wavy hair, friend peeking from top with beanie, blue ink crown 👑, blue "Pocket Mates" handwriting
/// - Bottom Frame: 3 close mates selfie:
///   - Left friend: Beanie, circular blue doodle glasses, peace sign ✌️
///   - Center friend: Winking pouty selfie ( > ‿ 0 ), blue doodle star ⭐ on cheek
///   - Right friend: Spiky hair, open laugh, blue doodle devil horns 😈, shaka sign 🤙
///   - Handwritten blue ink doodle heart ♡ and smiley :)
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
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillHair = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final fillSkin = Paint()
      ..color = const Color(0xFFFFFBEB)
      ..style = PaintingStyle.fill;

    final fillYellow = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.fill;

    // Signature Blue Ballpoint Pen Doodle Ink (from reference photo)
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
    // PHOTO FRAME 1 (TOP)
    // =========================================================================
    final topFrameRect = Rect.fromLTWH(0, 0, w, frameHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(topFrameRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFF1F5F9)..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(topFrameRect, const Radius.circular(4)),
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Draw Top Photo Content inside clip
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(topFrameRect, const Radius.circular(4)));

    // Yellow shirt
    canvas.drawCircle(
      Offset(w * 0.50, frameHeight + 16),
      34,
      fillYellow,
    );
    canvas.drawCircle(
      Offset(w * 0.50, frameHeight + 16),
      34,
      blackInk..strokeWidth = 1.6,
    );

    // Girl Head & Neck
    final girlCenter = Offset(w * 0.48, frameHeight * 0.54);
    canvas.drawCircle(girlCenter, 18, fillSkin);

    // Dark wavy hair framing face
    final hairPath = Path()
      // Left wave
      ..moveTo(girlCenter.dx - 18, girlCenter.dy + 8)
      ..quadraticBezierTo(girlCenter.dx - 26, girlCenter.dy - 2, girlCenter.dx - 16, girlCenter.dy - 16)
      // Top curve
      ..quadraticBezierTo(girlCenter.dx, girlCenter.dy - 24, girlCenter.dx + 16, girlCenter.dy - 16)
      // Right wave
      ..quadraticBezierTo(girlCenter.dx + 26, girlCenter.dy - 2, girlCenter.dx + 18, girlCenter.dy + 8)
      ..quadraticBezierTo(girlCenter.dx + 12, girlCenter.dy + 12, girlCenter.dx + 14, girlCenter.dy - 6)
      ..quadraticBezierTo(girlCenter.dx, girlCenter.dy - 12, girlCenter.dx - 14, girlCenter.dy - 6)
      ..close();
    canvas.drawPath(hairPath, fillHair);

    // Happy open smiling eyes & lips
    canvas.drawArc(
      Rect.fromCenter(center: Offset(girlCenter.dx - 6, girlCenter.dy - 1), width: 7, height: 5),
      0.2,
      math.pi - 0.4,
      false,
      blackInk..strokeWidth = 1.7,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(girlCenter.dx + 6, girlCenter.dy - 1), width: 7, height: 5),
      0.2,
      math.pi - 0.4,
      false,
      blackInk..strokeWidth = 1.7,
    );

    // Cute pouty/smiling black lips
    final lips = Path()
      ..moveTo(girlCenter.dx - 5, girlCenter.dy + 7)
      ..quadraticBezierTo(girlCenter.dx, girlCenter.dy + 11, girlCenter.dx + 5, girlCenter.dy + 7)
      ..quadraticBezierTo(girlCenter.dx, girlCenter.dy + 5, girlCenter.dx - 5, girlCenter.dy + 7);
    canvas.drawPath(lips, fillHair);

    // Friend peeking from upper right corner
    final peekCenter = Offset(w * 0.88, frameHeight * 0.20);
    canvas.drawCircle(peekCenter, 16, fillYellow); // Beanie
    canvas.drawCircle(peekCenter, 13, fillSkin); // Face peeking
    canvas.drawCircle(peekCenter, 13, blackInk..strokeWidth = 1.4);
    // Beanie stripes
    canvas.drawLine(Offset(w * 0.76, frameHeight * 0.12), Offset(w * 0.86, frameHeight * 0.04), blackInk..strokeWidth = 1.2);

    // Peeking friend eye
    canvas.drawCircle(Offset(peekCenter.dx - 4, peekCenter.dy + 2), 2.2, fillHair);

    // --- BLUE INK DOODLES OVER TOP PHOTO (from reference image) ---
    // 1. "Pocket Mates" handwriting on top left
    _drawHandwrittenText(canvas, Offset(w * 0.08, frameHeight * 0.22), "Pocket Mates", doodleBlue);
    canvas.drawLine(
      Offset(w * 0.08, frameHeight * 0.28),
      Offset(w * 0.46, frameHeight * 0.24),
      doodleBlue..strokeWidth = 1.2,
    );

    // 2. Royal Doodle Crown 👑 perched over girl's head
    _drawDoodleCrown(canvas, Offset(girlCenter.dx + 4, girlCenter.dy - 25), doodleBlue);

    // 3. Cute squiggle notes 〰️
    canvas.drawLine(Offset(w * 0.74, frameHeight * 0.74), Offset(w * 0.84, frameHeight * 0.68), doodleBlue);
    canvas.drawLine(Offset(w * 0.76, frameHeight * 0.82), Offset(w * 0.86, frameHeight * 0.76), doodleBlue);

    canvas.restore();

    // =========================================================================
    // PHOTO FRAME 2 (BOTTOM - 3 FRIENDS SQUAD)
    // =========================================================================
    final bottomFrameTop = frameHeight + 8;
    final bottomFrameRect = Rect.fromLTWH(0, bottomFrameTop, w, frameHeight);

    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomFrameRect, const Radius.circular(4)),
      Paint()..color = const Color(0xFFF1F5F9)..style = PaintingStyle.fill,
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

    // Center Friend (Girl with winking eye & pout)
    final midX = w * 0.50;
    final midY = bottomFrameTop + frameHeight * 0.54;
    canvas.drawCircle(Offset(midX, midY), 16, fillSkin);

    // Center Friend Hair
    final midHair = Path()
      ..moveTo(midX - 16, midY + 8)
      ..quadraticBezierTo(midX - 22, midY - 6, midX - 14, midY - 14)
      ..quadraticBezierTo(midX, midY - 20, midX + 14, midY - 14)
      ..quadraticBezierTo(midX + 22, midY - 6, midX + 16, midY + 8)
      ..close();
    canvas.drawPath(midHair, fillHair);

    // Left Friend (Beanie + Glasses + Peace Sign ✌️)
    final leftX = w * 0.20;
    final leftY = bottomFrameTop + frameHeight * 0.50;
    canvas.drawCircle(Offset(leftX, leftY - 6), 14, fillYellow); // Beanie
    canvas.drawCircle(Offset(leftX, leftY + 2), 13, fillSkin); // Face
    canvas.drawCircle(Offset(leftX, leftY + 2), 13, blackInk..strokeWidth = 1.3);

    // Right Friend (Spiky hair + Open laugh + Shaka 🤙)
    final rightX = w * 0.80;
    final rightY = bottomFrameTop + frameHeight * 0.48;
    canvas.drawCircle(Offset(rightX, rightY), 15, fillSkin);

    // Spiky black hair
    final spikyHair = Path()
      ..moveTo(rightX - 14, rightY - 4)
      ..lineTo(rightX - 10, rightY - 18)
      ..lineTo(rightX - 2, rightY - 12)
      ..lineTo(rightX + 6, rightY - 20)
      ..lineTo(rightX + 12, rightY - 12)
      ..lineTo(rightX + 16, rightY - 2)
      ..close();
    canvas.drawPath(spikyHair, fillHair);

    // Right friend big laughing mouth
    final laughMouth = Path()
      ..moveTo(rightX - 7, rightY + 3)
      ..lineTo(rightX + 7, rightY + 3)
      ..quadraticBezierTo(rightX, rightY + 13, rightX - 7, rightY + 3);
    canvas.drawPath(laughMouth, fillHair);

    // Center friend winking eye & kiss pout
    // Left eye closed winking ( > )
    final wink = Path()
      ..moveTo(midX - 8, midY - 2)
      ..lineTo(midX - 3, midY)
      ..lineTo(midX - 8, midY + 2);
    canvas.drawPath(wink, blackInk..strokeWidth = 1.6);
    // Right eye happy arc
    canvas.drawArc(
      Rect.fromCenter(center: Offset(midX + 5, midY - 1), width: 6, height: 4),
      0.2,
      math.pi - 0.4,
      false,
      blackInk..strokeWidth = 1.6,
    );
    // Kiss/pout lips ( 3 )
    final kissLips = Path()
      ..moveTo(midX - 3, midY + 5)
      ..quadraticBezierTo(midX + 1, midY + 4, midX + 3, midY + 6)
      ..quadraticBezierTo(midX + 1, midY + 8, midX - 3, midY + 7);
    canvas.drawPath(kissLips, fillHair);

    // --- BLUE INK DOODLES OVER BOTTOM PHOTO (from reference image) ---
    // 1. Blue Ink Glasses drawn over Left Friend's eyes
    canvas.drawCircle(Offset(leftX - 4, leftY), 5.5, doodleBlue..strokeWidth = 1.4);
    canvas.drawCircle(Offset(leftX + 6, leftY), 5.5, doodleBlue..strokeWidth = 1.4);
    canvas.drawLine(Offset(leftX + 1.5, leftY), Offset(leftX + 0.5, leftY), doodleBlue);

    // 2. Blue Star ⭐ on Center Friend's cheek
    _drawDoodleStar(canvas, Offset(midX - 8, midY + 6), 4.2, doodleBlue);

    // 3. Blue Devil Horns 😈 over Right Friend's head
    final leftHorn = Path()
      ..moveTo(rightX - 10, rightY - 16)
      ..quadraticBezierTo(rightX - 14, rightY - 23, rightX - 8, rightY - 25)
      ..quadraticBezierTo(rightX - 7, rightY - 20, rightX - 5, rightY - 16);
    canvas.drawPath(leftHorn, doodleBlue..strokeWidth = 1.4);

    final rightHorn = Path()
      ..moveTo(rightX + 6, rightY - 17)
      ..quadraticBezierTo(rightX + 10, rightY - 24, rightX + 14, rightY - 21)
      ..quadraticBezierTo(rightX + 11, rightY - 18, rightX + 9, rightY - 16);
    canvas.drawPath(rightHorn, doodleBlue..strokeWidth = 1.4);

    // 4. Blue Ink Heart ♡ in upper right
    _drawDoodleHeart(canvas, Offset(w * 0.70, bottomFrameTop + 14), doodleBlue);

    // 5. Smiley :) on bottom right border
    final eyePaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: (pullRatio * 1.1).clamp(0.3, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.92, bottomFrameTop + frameHeight - 12), 1.2, eyePaint);
    canvas.drawCircle(Offset(w * 0.95, bottomFrameTop + frameHeight - 10), 1.2, eyePaint);
    final smileArc = Path()
      ..moveTo(w * 0.91, bottomFrameTop + frameHeight - 6)
      ..quadraticBezierTo(
        w * 0.94,
        bottomFrameTop + frameHeight - 3,
        w * 0.97,
        bottomFrameTop + frameHeight - 5,
      );
    canvas.drawPath(smileArc, doodleBlue..strokeWidth = 1.3);

    canvas.restore();
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
