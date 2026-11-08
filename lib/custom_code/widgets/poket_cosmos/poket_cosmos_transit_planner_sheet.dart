import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/poket_cosmos_distance_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'poket_cosmos_transit_models.dart';
import 'poket_cosmic_flight_page.dart';
import 'poket_cosmos_plot_drive_page.dart';

/// 🧭 Google Maps-Style Transit Navigation Planner Sheet
/// Displays origin/destination route, interactive glowing route line,
/// multi-vehicle transport selector with speeds & ETAs, and launches transit.
class PoketCosmosTransitPlannerSheet extends StatefulWidget {
  final CosmosTransitRoute route;

  const PoketCosmosTransitPlannerSheet({
    super.key,
    required this.route,
  });

  static Future<void> show(BuildContext context, CosmosTransitRoute route) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PoketCosmosTransitPlannerSheet(route: route),
    );
  }

  @override
  State<PoketCosmosTransitPlannerSheet> createState() =>
      _PoketCosmosTransitPlannerSheetState();
}

class _PoketCosmosTransitPlannerSheetState
    extends State<PoketCosmosTransitPlannerSheet>
    with SingleTickerProviderStateMixin {
  late CosmosVehicle _selectedVehicle;
  late AnimationController _routeAnimController;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.route.selectedVehicle;
    _routeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _routeAnimController.dispose();
    super.dispose();
  }

  void _startJourney() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playPopSound();
    Navigator.of(context).pop(); // Dismiss bottom sheet

    widget.route.selectedVehicle = _selectedVehicle;

    if (widget.route.tier == CosmosTravelTier.plotToPlot) {
      // Launch Tier 3: Local Island Street Drive Simulation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PoketCosmosPlotDrivePage(route: widget.route),
        ),
      );
    } else {
      // Launch Tier 1 (Interplanetary) or Tier 2 (Island-to-Island) Flight Simulation
      final manifest = PoketCosmosDistanceService.instance.calculateFlightManifest(
        originCode: widget.route.originPlanetCode,
        destinationCode: widget.route.destPlanetCode,
        originPlot: widget.route.originPlotNumber,
        destinationPlot: widget.route.destPlotNumber,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PoketCosmicFlightPage(
            manifest: manifest,
            targetUserId: widget.route.targetUserId,
            targetName: widget.route.targetName,
            preloadedProfile: widget.route.preloadedProfile,
            neighbor: widget.route.neighbor,
            isRobot: widget.route.isRobot,
            robotData: widget.route.robotData,
            destinationPlanetCode: widget.route.destPlanetCode,
            destinationPlotNumber: widget.route.destPlotNumber,
            selectedVehicle: _selectedVehicle,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    final vehicles = CosmosVehicleCatalog.getVehiclesForTier(route.tier);
    final etaSeconds = _selectedVehicle.calculateEtaSeconds(route.distanceKm);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B132B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF38BDF8), width: 1.2),
          left: BorderSide(color: Color(0xFF38BDF8), width: 0.4),
          right: BorderSide(color: Color(0xFF38BDF8), width: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00E5FF),
            blurRadius: 32,
            spreadRadius: -10,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 18,
        right: 18,
        bottom: MediaQuery.of(context).padding.bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Google Maps Navigation Header (Origin -> Destination)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1.0),
                ),
                child: const Icon(Icons.navigation_rounded, color: Color(0xFF38BDF8), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getTierBadgeText(route.tier),
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF38BDF8),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${route.formattedDistance}',
                          style: GoogleFonts.orbitron(
                            color: const Color(0xFFFFD700),
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${route.originPlanetName} ➔ ${route.destPlanetName}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3. Detailed Origin / Destination Addresses
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.my_location_rounded, color: Color(0xFF38BDF8), size: 15),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Base: ${route.originPlanetName} • ${route.originIslandName} (Plot #${route.originPlotNumber})',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 7),
                      Container(width: 1.5, height: 12, color: Colors.white24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Divider(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.place_rounded, color: Color(0xFFFF4081), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Target: ${route.targetName} • ${route.destPlanetName} • ${route.destIslandName} (Plot #${route.destPlotNumber})',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 4. Interactive Glowing Google Maps Route Preview Box
          Container(
            height: 125,
            decoration: BoxDecoration(
              color: const Color(0xFF070B14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _routeAnimController,
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: _GoogleMapsRoutePreviewPainter(
                        tier: route.tier,
                        progress: _routeAnimController.value,
                        originName: route.originPlanetName,
                        destName: route.destPlanetName,
                        vehicleEmoji: _selectedVehicle.emoji,
                      ),
                    );
                  },
                ),
                // Route ETA Overlay Tag
                Positioned(
                  top: 8,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, color: Color(0xFF38BDF8), size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'ETA: ~$etaSeconds sec',
                          style: GoogleFonts.orbitron(
                            color: const Color(0xFF38BDF8),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 5. Vehicle Mode Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHOOSE TRANSPORT VEHICLE (വാഹനം തിരഞ്ഞെടുക്കുക):',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${_selectedVehicle.speedMultiplier}x Speed',
                style: GoogleFonts.orbitron(
                  color: _selectedVehicle.primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Vehicle Cards
          Row(
            children: vehicles.map((v) {
              final isSelected = v.id == _selectedVehicle.id;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedVehicle = v;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3.5),
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? v.primaryColor.withValues(alpha: 0.22)
                          : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? v.primaryColor : Colors.white12,
                        width: isSelected ? 1.6 : 0.8,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: v.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(v.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          v.name,
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          v.speedLabel,
                          style: GoogleFonts.inter(
                            color: isSelected ? v.primaryColor : Colors.white38,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // 6. Big CTA "START NAVIGATION" Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _startJourney,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                elevation: 8,
                shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_selectedVehicle.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'START NAVIGATION / യാത്ര ആരംഭിക്കുക ▶',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTierBadgeText(CosmosTravelTier tier) {
    switch (tier) {
      case CosmosTravelTier.interplanetary:
        return '🪐 INTERPLANETARY ORBIT ROUTE';
      case CosmosTravelTier.islandToIsland:
        return '🏝️ ISLAND AIRWAY & SEA PASSAGE';
      case CosmosTravelTier.plotToPlot:
        return '🏡 LOCAL DISTRICT STREET NAVIGATION';
    }
  }
}

/// 🎨 Google Maps Style Glowing Navigation Route Painter
class _GoogleMapsRoutePreviewPainter extends CustomPainter {
  final CosmosTravelTier tier;
  final double progress; // 0.0 to 1.0 animation loop
  final String originName;
  final String destName;
  final String vehicleEmoji;

  _GoogleMapsRoutePreviewPainter({
    required this.tier,
    required this.progress,
    required this.originName,
    required this.destName,
    required this.vehicleEmoji,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background Subtle Grid
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;
    for (double x = 0; x < w; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    if (tier == CosmosTravelTier.interplanetary) {
      _paintInterplanetaryOrbit(canvas, size);
    } else if (tier == CosmosTravelTier.islandToIsland) {
      _paintIslandToIslandAirway(canvas, size);
    } else {
      _paintPlotToPlotStreet(canvas, size);
    }
  }

  void _paintInterplanetaryOrbit(Canvas canvas, Size size) {
    final start = Offset(size.width * 0.15, size.height * 0.75);
    final control = Offset(size.width * 0.48, size.height * 0.15);
    final end = Offset(size.width * 0.85, size.height * 0.35);

    // Glowing Orbit Curve
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    final glowPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.35)
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glowPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Intermediate Slingshot Body
    final moonCenter = Offset(size.width * 0.52, size.height * 0.42);
    canvas.drawCircle(moonCenter, 7, Paint()..color = const Color(0xFF94A3B8));
    canvas.drawCircle(moonCenter, 14, Paint()..color = const Color(0xFF94A3B8).withValues(alpha: 0.2)..style = PaintingStyle.stroke);

    // Origin Planet
    canvas.drawCircle(start, 11, Paint()..color = const Color(0xFF0284C7));
    canvas.drawCircle(start, 5, Paint()..color = Colors.white);

    // Destination Planet
    canvas.drawCircle(end, 13, Paint()..color = const Color(0xFFD97706));
    canvas.drawCircle(end, 6, Paint()..color = const Color(0xFFFFD700));

    // Vehicle Moving along the path
    final t = progress;
    final vx = (1 - t) * (1 - t) * start.dx + 2 * (1 - t) * t * control.dx + t * t * end.dx;
    final vy = (1 - t) * (1 - t) * start.dy + 2 * (1 - t) * t * control.dy + t * t * end.dy;
    _drawEmoji(canvas, vehicleEmoji, Offset(vx, vy), 16);
  }

  void _paintIslandToIslandAirway(Canvas canvas, Size size) {
    final start = Offset(size.width * 0.18, size.height * 0.70);
    final end = Offset(size.width * 0.82, size.height * 0.30);

    // Island at Start
    canvas.drawOval(
      Rect.fromCenter(center: start, width: 34, height: 22),
      Paint()..color = const Color(0xFF16A34A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: start, width: 40, height: 26),
      Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    // Island at End
    canvas.drawOval(
      Rect.fromCenter(center: end, width: 38, height: 24),
      Paint()..color = const Color(0xFF059669),
    );
    canvas.drawOval(
      Rect.fromCenter(center: end, width: 44, height: 28),
      Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );

    // Sea Route Curve
    final c1 = Offset(size.width * 0.40, size.height * 0.85);
    final c2 = Offset(size.width * 0.60, size.height * 0.15);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);

    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.3)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path, glowPaint);

    final dashedPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, dashedPaint);

    // Vehicle position
    final t = progress;
    final vx = math.pow(1 - t, 3) * start.dx +
        3 * math.pow(1 - t, 2) * t * c1.dx +
        3 * (1 - t) * t * t * c2.dx +
        t * t * t * end.dx;
    final vy = math.pow(1 - t, 3) * start.dy +
        3 * math.pow(1 - t, 2) * t * c1.dy +
        3 * (1 - t) * t * t * c2.dy +
        t * t * t * end.dy;
    _drawEmoji(canvas, vehicleEmoji, Offset(vx, vy), 16);
  }

  void _paintPlotToPlotStreet(Canvas canvas, Size size) {
    // Street grid
    final roadPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * 0.20, size.height * 0.70);
    final corner = Offset(size.width * 0.20, size.height * 0.32);
    final end = Offset(size.width * 0.80, size.height * 0.32);

    canvas.drawLine(start, corner, roadPaint);
    canvas.drawLine(corner, end, roadPaint);

    // Blue Navigation Route
    final navPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, corner, navPaint);
    canvas.drawLine(corner, end, navPaint);

    // Plot A & Plot B House Markers
    _drawMarker(canvas, start, const Color(0xFF38BDF8), 'A');
    _drawMarker(canvas, end, const Color(0xFFFF4081), 'B');

    // Vehicle driving along L-route
    Offset vPos;
    if (progress < 0.45) {
      final t = progress / 0.45;
      vPos = Offset.lerp(start, corner, t)!;
    } else {
      final t = (progress - 0.45) / 0.55;
      vPos = Offset.lerp(corner, end, t)!;
    }
    _drawEmoji(canvas, vehicleEmoji, vPos, 16);
  }

  void _drawMarker(Canvas canvas, Offset pos, Color color, String label) {
    canvas.drawCircle(pos, 9, Paint()..color = color);
    canvas.drawCircle(pos, 4, Paint()..color = Colors.white);
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
  bool shouldRepaint(covariant _GoogleMapsRoutePreviewPainter oldDelegate) => true;
}
