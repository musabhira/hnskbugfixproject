import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_attack_page.dart';
import 'package:pocket_mates_app/custom_code/widgets/poket_cosmos/poket_cosmos_resident_island_view.dart';
import 'poket_cosmos_transit_models.dart';

/// 🏡 Tier 3: Local Island Street Drive Simulation Page
/// Top-down aerial street navigation from Plot A to Plot B on the same island.
/// Features interactive vehicle driving (Motorbike / Buggy / Bicycle), glowing Google Maps route,
/// pause/resume, zoom in/out, and destination plot zoom touchdown.
class PoketCosmosPlotDrivePage extends StatefulWidget {
  final CosmosTransitRoute route;

  const PoketCosmosPlotDrivePage({
    super.key,
    required this.route,
  });

  @override
  State<PoketCosmosPlotDrivePage> createState() => _PoketCosmosPlotDrivePageState();
}

class _PoketCosmosPlotDrivePageState extends State<PoketCosmosPlotDrivePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  double _progress = 0.0;
  bool _isBoosting = false;
  bool _isPaused = false;
  bool _hasArrived = false;
  double _zoomLevel = 1.0;
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    final durationSeconds = widget.route.selectedVehicle.calculateEtaSeconds(widget.route.distanceKm);
    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSeconds),
    );

    _animController.addListener(() {
      if (mounted) {
        setState(() {
          _progress = _animController.value;
        });
        if (_animController.isCompleted && !_hasArrived) {
          _handleArrival();
        }
      }
    });

    _animController.forward();
  }

  void _handleArrival() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    setState(() {
      _hasArrived = true;
      _zoomLevel = 1.45; // Camera zooms in on destination plot
    });
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _animController.stop();
      } else {
        _animController.forward();
      }
    });
  }

  void _boostSpeed() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playPopSound();
    setState(() => _isBoosting = true);
    _animController.animateTo(
      math.min(1.0, _progress + 0.18),
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
    ).then((_) {
      if (mounted && !_hasArrived && !_isPaused) {
        setState(() => _isBoosting = false);
        _animController.forward();
      }
    });
  }

  void _zoomIn() {
    HapticFeedback.selectionClick();
    setState(() => _zoomLevel = (_zoomLevel + 0.15).clamp(0.6, 2.0));
  }

  void _zoomOut() {
    HapticFeedback.selectionClick();
    setState(() => _zoomLevel = (_zoomLevel - 0.15).clamp(0.6, 2.0));
  }

  void _resetZoom() {
    HapticFeedback.selectionClick();
    setState(() => _zoomLevel = 1.0);
  }

  void _proceedToCitadel() {
    Navigator.of(context).pop(); // Dismiss drive simulation

    if (widget.route.neighbor != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketCitadelAttackPage(
            neighbor: widget.route.neighbor!,
            attackerDay: 1,
          ),
        ),
      );
      return;
    }

    PocketCitadelAttackPage.openForUser(
      context,
      userId: widget.route.targetUserId,
      targetName: widget.route.targetName,
      preloadedProfile: widget.route.preloadedProfile,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;
    final route = widget.route;
    final vehicle = route.selectedVehicle;

    return Scaffold(
      backgroundColor: const Color(0xFF0369A1), // Azure Ocean Surrounding Island
      body: Stack(
        children: [
          // 1. Interactive Aerial Top-Down Street Canvas (Tap/Hold to Turbo Boost, Pinch-to-Zoom)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _hasArrived ? null : _boostSpeed,
              onScaleStart: (details) {
                _baseScale = _zoomLevel;
              },
              onScaleUpdate: (details) {
                if (details.pointerCount > 1) {
                  setState(() {
                    _zoomLevel = (_baseScale * details.scale).clamp(0.6, 2.0);
                  });
                }
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: _IslandStreetDrivePainter(
                  progress: _progress,
                  zoomLevel: _zoomLevel,
                  originPlot: route.originPlotNumber,
                  destPlot: route.destPlotNumber,
                  vehicle: vehicle,
                  isBoosting: _isBoosting,
                  hasArrived: _hasArrived,
                  targetName: route.targetName,
                ),
              ),
            ),
          ),

          // 2. Navigation Header HUD (Google Maps Style)
          Positioned(
            top: topPadding + 10,
            left: 14,
            right: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Street Route Pill
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.6), width: 0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '🏡 Plot #${route.originPlotNumber.toString().padLeft(2, '0')}',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                vehicle.emoji,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '🏁 Plot #${route.destPlotNumber.toString().padLeft(2, '0')} (${route.targetName})',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Pause / Resume Toggle
                    GestureDetector(
                      onTap: _togglePause,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                        decoration: BoxDecoration(
                          color: _isPaused ? const Color(0xFFF59E0B).withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _isPaused ? const Color(0xFFF59E0B) : Colors.white24, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                              color: _isPaused ? const Color(0xFFFFD700) : Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isPaused ? 'RESUME' : 'PAUSE',
                              style: GoogleFonts.outfit(
                                color: _isPaused ? const Color(0xFFFFD700) : Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Street Distance Tracker Strip
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(vehicle.emoji, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 5),
                              Text(
                                '${route.originIslandName} Street',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _isBoosting ? '⚡ TURBO' : '${((1.0 - _progress) * 100).toInt()}% left',
                            style: GoogleFonts.outfit(
                              color: _isBoosting ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: _progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isBoosting ? const Color(0xFFFFD700) : const Color(0xFF38BDF8),
                          ),
                          minHeight: 3.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Zoom Controls Floating Dock on Right Edge
          Positioned(
            top: topPadding + 115,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _zoomIn,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                      child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _resetZoom,
                    child: Text(
                      '${(_zoomLevel * 100).toInt()}%',
                      style: GoogleFonts.orbitron(color: const Color(0xFF38BDF8), fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _zoomOut,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                      child: const Icon(Icons.zoom_out_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Centered Pause Notification Banner
          if (_isPaused)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pause_circle_filled_rounded, color: Color(0xFFFFD700), size: 36),
                    const SizedBox(height: 8),
                    Text(
                      'NAVIGATION PAUSED',
                      style: GoogleFonts.orbitron(color: const Color(0xFFFFD700), fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'യാത്ര താൽക്കാലികമായി നിർത്തിയിരിക്കുന്നു',
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _togglePause,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFC00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 18),
                      label: Text('RESUME / തുടരുക', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Bottom Right Boost FAB (when moving)
          if (!_hasArrived)
            Positioned(
              bottom: bottomPadding + 18,
              right: 18,
              child: GestureDetector(
                onTap: _boostSpeed,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isBoosting
                          ? [const Color(0xFFFF9100), const Color(0xFFFFD700)]
                          : [vehicle.primaryColor, vehicle.secondaryColor],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: vehicle.primaryColor.withValues(alpha: 0.5),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(vehicle.emoji, style: const TextStyle(fontSize: 20)),
                      Text(
                        'BOOST',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 6. Arrival Plot Touchdown Card (Camera Zoomed on Destination Plot)
          if (_hasArrived)
            Positioned(
              bottom: bottomPadding + 20,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 1.0,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🏁', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'ARRIVED AT PLOT #${route.destPlotNumber.toString().padLeft(2, '0')}',
                              style: GoogleFonts.orbitron(
                                color: const Color(0xFFFFD700),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Navigated via ${vehicle.name} along ${route.originIslandName} to ${route.targetName}\'s residence.',
                        style: GoogleFonts.inter(color: const Color(0xFFCBD5E1), fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _proceedToCitadel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.fort_rounded, color: Colors.black, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'VIEW CITADEL / PROFILE ⚔️',
                                style: GoogleFonts.outfit(color: Colors.black, fontSize: 13.5, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 🎨 Top-Down Island Aerial Street Drive Painter
class _IslandStreetDrivePainter extends CustomPainter {
  final double progress;
  final double zoomLevel;
  final int originPlot;
  final int destPlot;
  final CosmosVehicle vehicle;
  final bool isBoosting;
  final bool hasArrived;
  final String targetName;

  _IslandStreetDrivePainter({
    required this.progress,
    required this.zoomLevel,
    required this.originPlot,
    required this.destPlot,
    required this.vehicle,
    required this.isBoosting,
    required this.hasArrived,
    required this.targetName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(zoomLevel);
    canvas.translate(-cx, -cy);

    // 1. Surrounding Ocean Water Shimmer
    final oceanPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), oceanPaint);

    // 2. Island Sandy Coastline Beach
    final islandCenter = Offset(cx, cy);
    final beachPaint = Paint()
      ..color = const Color(0xFFFEF08A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: islandCenter, width: w * 0.92, height: h * 0.72),
      beachPaint,
    );

    // 3. Lush Green Island Grass Plateau
    final grassPaint = Paint()..color = const Color(0xFF16A34A);
    canvas.drawOval(
      Rect.fromCenter(center: islandCenter, width: w * 0.82, height: h * 0.62),
      grassPaint,
    );

    // 4. Street Grid (Asphalt roads)
    final roadPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 22.0
      ..strokeCap = StrokeCap.round;

    final roadStripePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.8;

    // Outer Loop Avenue
    final loopRect = Rect.fromCenter(center: islandCenter, width: w * 0.64, height: h * 0.44);
    canvas.drawRRect(RRect.fromRectAndRadius(loopRect, const Radius.circular(32)), roadPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(loopRect, const Radius.circular(32)), roadStripePaint..style = PaintingStyle.stroke);

    // Cross Boulevard
    canvas.drawLine(Offset(islandCenter.dx, loopRect.top), Offset(islandCenter.dx, loopRect.bottom), roadPaint);

    // 5. Plots Layout (25 plots around the island avenue)
    final plotPoints = <Offset>[];
    for (int i = 0; i < 25; i++) {
      final angle = (i / 25.0) * (2 * math.pi) - (math.pi / 2);
      final rx = (loopRect.width / 2) + 32;
      final ry = (loopRect.height / 2) + 26;
      final px = islandCenter.dx + math.cos(angle) * rx;
      final py = islandCenter.dy + math.sin(angle) * ry;
      plotPoints.add(Offset(px, py));

      // Draw mini houses around the island
      _drawMiniHouse(canvas, Offset(px, py), i + 1 == destPlot, i + 1 == originPlot);
    }

    // 6. Navigation Route Line (from Origin Plot to Dest Plot)
    final startIdx = (originPlot - 1).clamp(0, 24);
    final endIdx = (destPlot - 1).clamp(0, 24);
    final startPlotPos = plotPoints[startIdx];
    final endPlotPos = plotPoints[endIdx];

    // Connect along the avenue
    final routePath = Path()..moveTo(startPlotPos.dx, startPlotPos.dy);
    final int stepCount = (endIdx - startIdx).abs() + 1;
    final int dir = (endIdx >= startIdx) ? 1 : -1;

    for (int s = 0; s <= stepCount; s++) {
      final currIdx = (startIdx + (s * dir)).clamp(0, 24);
      final p = plotPoints[currIdx];
      routePath.lineTo(p.dx, p.dy);
    }

    // Glowing Blue Route Line
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.4)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(routePath, glowPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(routePath, linePaint);

    // 7. Vehicle position along the route
    Offset vehiclePos = startPlotPos;
    double vehicleAngle = 0.0;

    final pathMetrics = routePath.computeMetrics().toList();
    if (pathMetrics.isNotEmpty) {
      final metric = pathMetrics.first;
      final distance = metric.length * progress;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        vehiclePos = tangent.position;
        vehicleAngle = tangent.angle;
      }
    }

    // Draw Headlight Beam
    canvas.save();
    canvas.translate(vehiclePos.dx, vehiclePos.dy);
    canvas.rotate(vehicleAngle);

    final headlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFEF08A).withValues(alpha: 0.65),
          Colors.transparent,
        ],
      ).createShader(const Rect.fromLTWH(0, -18, 55, 36));
    final beamPath = Path()
      ..moveTo(0, -4)
      ..lineTo(55, -20)
      ..lineTo(55, 20)
      ..lineTo(0, 4)
      ..close();
    canvas.drawPath(beamPath, headlightPaint);

    // Draw Vehicle Emoji Icon
    _drawEmoji(canvas, vehicle.emoji, Offset.zero, isBoosting ? 24 : 20);
    canvas.restore();

    // 8. Origin & Destination Markers
    _drawPlotMarker(canvas, startPlotPos, const Color(0xFF38BDF8), '#$originPlot (You)');
    _drawPlotMarker(canvas, endPlotPos, const Color(0xFFFFD700), '#$destPlot ($targetName)');

    canvas.restore();
  }

  void _drawMiniHouse(Canvas canvas, Offset pos, bool isDest, bool isOrigin) {
    final housePaint = Paint()
      ..color = isDest
          ? const Color(0xFFFFD700)
          : (isOrigin ? const Color(0xFF38BDF8) : const Color(0xFFF8FAFC));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: 14, height: 11), const Radius.circular(2.5)),
      housePaint,
    );
    final roofPaint = Paint()
      ..color = isDest ? const Color(0xFFD97706) : const Color(0xFF94A3B8);
    final roof = Path()
      ..moveTo(pos.dx - 8, pos.dy - 5.5)
      ..lineTo(pos.dx, pos.dy - 12)
      ..lineTo(pos.dx + 8, pos.dy - 5.5)
      ..close();
    canvas.drawPath(roof, roofPaint);
  }

  void _drawPlotMarker(Canvas canvas, Offset pos, Color color, String label) {
    canvas.drawCircle(pos, 8, Paint()..color = color);
    canvas.drawCircle(pos, 3.5, Paint()..color = Colors.white);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - (tp.width / 2), pos.dy - 22));
  }

  void _drawEmoji(Canvas canvas, String emoji, Offset pos, double size) {
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - (tp.width / 2), pos.dy - (tp.height / 2)));
  }

  @override
  bool shouldRepaint(covariant _IslandStreetDrivePainter oldDelegate) => true;
}
