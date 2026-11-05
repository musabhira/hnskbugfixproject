import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'poket_cosmos_models.dart';

/// 🚗✈️ Flame Game simulating Google Maps travel across Poket World
class PoketMapTravelGame extends FlameGame {
  final List<CitizenPlot> plots;
  final CitizenPlot currentOrigin;
  final CitizenPlot currentTarget;
  final TravelMode travelMode;
  final Function(CitizenPlot target) onArrived;

  PoketMapTravelGame({
    required this.plots,
    required this.currentOrigin,
    required this.currentTarget,
    required this.travelMode,
    required this.onArrived,
  });

  late Vector2 vehiclePosition;
  late Vector2 targetPosition;
  double travelProgress = 0.0;
  double vehicleAngle = 0.0;
  bool hasArrived = false;

  @override
  Color backgroundColor() => const Color(0xFF0F172A); // Midnight Slate map base

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    vehiclePosition = Vector2(
      currentOrigin.coordinates.dx,
      currentOrigin.coordinates.dy,
    );
    targetPosition = Vector2(
      currentTarget.coordinates.dx,
      currentTarget.coordinates.dy,
    );

    // Initial heading angle towards target
    final diff = targetPosition - vehiclePosition;
    vehicleAngle = math.atan2(diff.y, diff.x);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (hasArrived) return;

    final distance = vehiclePosition.distanceTo(targetPosition);

    // Dynamic travel speed depending on vehicle mode
    final double speed = travelMode == TravelMode.plane
        ? 280.0
        : travelMode == TravelMode.train
            ? 210.0
            : 140.0;

    if (distance < 6.0) {
      vehiclePosition = targetPosition.clone();
      hasArrived = true;
      onArrived(currentTarget);
    } else {
      final direction = (targetPosition - vehiclePosition).normalized();
      vehiclePosition += direction * speed * dt;
      vehicleAngle = math.atan2(direction.y, direction.x);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Draw Map Grid / Green Land Blocks
    _renderMapTerrain(canvas);

    // 2. Draw Roadways & Rail Tracks
    _renderRoadways(canvas);

    // 3. Draw Navigation Route Path (Google Maps Blue Polyline)
    _renderNavigationRoute(canvas);

    // 4. Draw Citizen Houses & Plots
    _renderCitizenPlots(canvas);

    // 5. Draw Dynamic Moving Vehicle (Car or Airplane)
    _renderVehicle(canvas);
  }

  void _renderMapTerrain(Canvas canvas) {
    final terrainPaint = Paint()..color = const Color(0xFF132238);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), terrainPaint);

    // Subtle river / waterways
    final riverPaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26;

    final riverPath = Path();
    riverPath.moveTo(-20, size.y * 0.45);
    riverPath.cubicTo(
      size.x * 0.3,
      size.y * 0.35,
      size.x * 0.65,
      size.y * 0.6,
      size.x + 20,
      size.y * 0.5,
    );
    canvas.drawPath(riverPath, riverPaint);
  }

  void _renderRoadways(Canvas canvas) {
    final roadPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;

    final roadDashes = Paint()
      ..color = const Color(0xFFFCD34D).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Horizontal main avenue
    canvas.drawLine(
      Offset(0, size.y * 0.28),
      Offset(size.x, size.y * 0.28),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.y * 0.72),
      Offset(size.x, size.y * 0.72),
      roadPaint,
    );

    // Vertical connecting streets
    canvas.drawLine(
      Offset(size.x * 0.28, 0),
      Offset(size.x * 0.28, size.y),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.x * 0.72, 0),
      Offset(size.x * 0.72, size.y),
      roadPaint,
    );

    // Center dash markings
    for (double x = 10; x < size.x; x += 30) {
      canvas.drawLine(
        Offset(x, size.y * 0.28),
        Offset(x + 15, size.y * 0.28),
        roadDashes,
      );
      canvas.drawLine(
        Offset(x, size.y * 0.72),
        Offset(x + 15, size.y * 0.72),
        roadDashes,
      );
    }
  }

  void _renderNavigationRoute(Canvas canvas) {
    final routeGlow = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final routeSolid = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final originOffset = currentOrigin.coordinates;
    final targetOffset = currentTarget.coordinates;

    canvas.drawLine(originOffset, targetOffset, routeGlow);
    canvas.drawLine(originOffset, targetOffset, routeSolid);
  }

  void _renderCitizenPlots(Canvas canvas) {
    for (final plot in plots) {
      final isSelectedTarget = plot.plotNumber == currentTarget.plotNumber;
      final isCurrentOrigin = plot.plotNumber == currentOrigin.plotNumber;

      final plotRect = Rect.fromCenter(
        center: plot.coordinates,
        width: 48,
        height: 48,
      );

      // Plot Base Yard
      final yardPaint = Paint()
        ..color = isSelectedTarget
            ? const Color(0xFF059669).withValues(alpha: 0.3)
            : const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;

      final yardBorder = Paint()
        ..color = isSelectedTarget
            ? const Color(0xFF10B981)
            : isCurrentOrigin
                ? const Color(0xFF38BDF8)
                : const Color(0xFF475569)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelectedTarget ? 2.5 : 1.2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(plotRect, const Radius.circular(8)),
        yardPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(plotRect, const Radius.circular(8)),
        yardBorder,
      );

      // House structure (Scale increases with user Day)
      final housePaint = Paint()
        ..color = plot.isPresident
            ? const Color(0xFFFFD700)
            : plot.isVip
                ? const Color(0xFFA855F7)
                : const Color(0xFFF97316);

      final houseSize = 16.0 + (plot.day.clamp(1, 90) / 90.0) * 12.0;
      final houseRect = Rect.fromCenter(
        center: plot.coordinates.translate(0, -2),
        width: houseSize,
        height: houseSize * 0.85,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(houseRect, const Radius.circular(4)),
        housePaint,
      );

      // Roof triangle
      final roofPath = Path();
      roofPath.moveTo(houseRect.left - 2, houseRect.top);
      roofPath.lineTo(houseRect.center.dx, houseRect.top - 8);
      roofPath.lineTo(houseRect.right + 2, houseRect.top);
      roofPath.close();
      final roofPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
      canvas.drawPath(roofPath, roofPaint);

      // Plot Number Badge
      final tp = TextPainter(
        text: TextSpan(
          text: '#${plot.plotNumber}',
          style: TextStyle(
            color: isSelectedTarget ? const Color(0xFF10B981) : Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, plot.coordinates.translate(-tp.width / 2, 12));
    }
  }

  void _renderVehicle(Canvas canvas) {
    canvas.save();
    canvas.translate(vehiclePosition.x, vehiclePosition.y);
    canvas.rotate(vehicleAngle);

    if (travelMode == TravelMode.plane) {
      // ✈️ Aeroplane
      final planePaint = Paint()..color = Colors.white;
      final wingPaint = Paint()..color = const Color(0xFF38BDF8);

      // Fuselage
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-14, -4, 28, 8),
          const Radius.circular(4),
        ),
        planePaint,
      );
      // Wings
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-4, -14, 8, 28),
          const Radius.circular(2),
        ),
        wingPaint,
      );
      // Tail
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-14, -8, 4, 16),
          const Radius.circular(1),
        ),
        wingPaint,
      );
    } else {
      // 🚗 Car / Vehicle
      final carBody = Paint()..color = const Color(0xFFEF4444);
      final carRoof = Paint()..color = Colors.black.withValues(alpha: 0.7);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-12, -7, 24, 14),
          const Radius.circular(4),
        ),
        carBody,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-4, -5, 12, 10),
          const Radius.circular(2),
        ),
        carRoof,
      );

      // Headlights
      final lightPaint = Paint()..color = const Color(0xFFFDE047);
      canvas.drawCircle(const Offset(11, -4), 1.5, lightPaint);
      canvas.drawCircle(const Offset(11, 4), 1.5, lightPaint);
    }

    canvas.restore();
  }
}
