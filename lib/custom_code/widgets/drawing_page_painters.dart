import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'drawing_page_models.dart';

class LayerPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? activeStroke;

  LayerPainter({required this.strokes, this.activeStroke});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (activeStroke != null) _drawStroke(canvas, activeStroke!);
    canvas.restore();
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color.withValues(alpha: stroke.opacity)
      ..strokeWidth = stroke.strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..style = stroke.isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..isAntiAlias = true;

    if (stroke.shapeType != null && stroke.shapeEnd != null) {
      _drawShape(canvas, stroke.shapeType!, stroke.points[0].offset, stroke.shapeEnd!, paint);
      return;
    }

    // Brush-specific rendering
    switch (stroke.brushType) {
      case BrushType.pen:
      case BrushType.calligraphy:
        paint.strokeCap = StrokeCap.round;
        break;
      case BrushType.marker:
        paint.strokeCap = StrokeCap.square;
        break;
      case BrushType.pencil:
        paint.strokeCap = StrokeCap.round;
        paint.color = stroke.color.withValues(alpha: stroke.opacity * 0.7);
        break;
      case BrushType.airbrush:
        paint.strokeCap = StrokeCap.round;
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, stroke.strokeWidth * 0.8);
        break;
      case BrushType.watercolor:
        paint.strokeCap = StrokeCap.round;
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, stroke.strokeWidth * 0.5);
        paint.color = stroke.color.withValues(alpha: stroke.opacity * 0.4);
        break;
      case BrushType.chalk:
        paint.strokeCap = StrokeCap.round;
        paint.color = stroke.color.withValues(alpha: stroke.opacity * 0.55);
        break;
      case BrushType.charcoal:
        paint.strokeCap = StrokeCap.round;
        paint.color = stroke.color.withValues(alpha: stroke.opacity * 0.6);
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, stroke.strokeWidth * 0.15);
        break;
      case BrushType.glow:
        paint.strokeCap = StrokeCap.round;
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, stroke.strokeWidth * 1.5);
        paint.color = stroke.color.withValues(alpha: stroke.opacity * 0.6);
        break;
      case BrushType.fill:
        paint.style = PaintingStyle.fill;
        break;
    }

    if (stroke.isEraser) {
      paint.blendMode = BlendMode.clear;
      paint.color = Colors.transparent;
    }

    final path = Path();
    path.moveTo(stroke.points[0].offset.dx, stroke.points[0].offset.dy);

    if (stroke.points.length < 3) {
      for (final point in stroke.points) {
        path.lineTo(point.offset.dx, point.offset.dy);
      }
    } else {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i].offset;
        final p2 = stroke.points[i + 1].offset;
        final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
        path.quadraticBezierTo(p1.dx, p1.dy, mid.dx, mid.dy);
      }
    }

    canvas.drawPath(path, paint);

    // Glow extra pass
    if (stroke.brushType == BrushType.glow && !stroke.isEraser) {
      final glowPaint = Paint()
        ..color = stroke.color.withValues(alpha: stroke.opacity * 0.2)
        ..strokeWidth = stroke.strokeWidth * 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke.strokeWidth * 3);
      canvas.drawPath(path, glowPaint);
    }
  }

  void _drawShape(Canvas canvas, ShapeTool shape, Offset start, Offset end, Paint paint) {
    switch (shape) {
      case ShapeTool.line:
        canvas.drawLine(start, end, paint);
        break;
      case ShapeTool.rectangle:
        canvas.drawRect(Rect.fromPoints(start, end), paint);
        break;
      case ShapeTool.circle:
        final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
        final radius = (end - start).distance / 2;
        canvas.drawCircle(center, radius, paint);
        break;
      case ShapeTool.triangle:
        final path = Path();
        path.moveTo((start.dx + end.dx) / 2, start.dy);
        path.lineTo(end.dx, end.dy);
        path.lineTo(start.dx, end.dy);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case ShapeTool.arrow:
        canvas.drawLine(start, end, paint);
        final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
        const arrowLen = 20.0;
        final p1 = Offset(end.dx - arrowLen * math.cos(angle - 0.4), end.dy - arrowLen * math.sin(angle - 0.4));
        final p2 = Offset(end.dx - arrowLen * math.cos(angle + 0.4), end.dy - arrowLen * math.sin(angle + 0.4));
        canvas.drawLine(end, p1, paint);
        canvas.drawLine(end, p2, paint);
        break;
      case ShapeTool.star:
        final cx = (start.dx + end.dx) / 2;
        final cy = (start.dy + end.dy) / 2;
        final r = (end - start).distance / 2;
        final ir = r * 0.4;
        final path = Path();
        for (int i = 0; i < 10; i++) {
          final angle = (i * math.pi / 5) - math.pi / 2;
          final radius = i.isEven ? r : ir;
          final x = cx + radius * math.cos(angle);
          final y = cy + radius * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant LayerPainter oldDelegate) => true;
}

class BrushPreviewPainter extends CustomPainter {
  final BrushType brushType;
  final Color baseColor;
  final double opacity, thickness;

  BrushPreviewPainter({required this.brushType, required this.baseColor, required this.opacity, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = baseColor.withValues(alpha: opacity)
      ..strokeWidth = thickness.clamp(1.0, 12.0)
      ..strokeCap = brushType == BrushType.marker ? StrokeCap.square : StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (brushType == BrushType.airbrush || brushType == BrushType.watercolor) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, thickness * 0.4);
    }
    if (brushType == BrushType.glow) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, thickness * 0.8);
    }

    final path = Path();
    final h = size.height / 2;
    path.moveTo(10, h + 4);
    path.cubicTo(size.width * 0.15, h - 12, size.width * 0.25, h + 10, size.width * 0.4, h - 2);
    path.cubicTo(size.width * 0.55, h - 14, size.width * 0.7, h + 8, size.width - 10, h);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BrushPreviewPainter oldDelegate) => false;
}

class ShapePreviewPainter extends CustomPainter {
  final ShapeTool shape;
  final Offset start, end;
  final Color color;
  final double strokeWidth;
  final bool filled;

  ShapePreviewPainter({required this.shape, required this.start, required this.end, required this.color, this.strokeWidth = 2.0, this.filled = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..isAntiAlias = true;

    switch (shape) {
      case ShapeTool.line:
        canvas.drawLine(start, end, paint);
        break;
      case ShapeTool.rectangle:
        canvas.drawRect(Rect.fromPoints(start, end), paint);
        break;
      case ShapeTool.circle:
        final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
        final radius = (end - start).distance / 2;
        canvas.drawCircle(center, radius, paint);
        break;
      case ShapeTool.triangle:
        final path = Path();
        path.moveTo((start.dx + end.dx) / 2, start.dy);
        path.lineTo(end.dx, end.dy);
        path.lineTo(start.dx, end.dy);
        path.close();
        canvas.drawPath(path, paint);
        break;
      case ShapeTool.arrow:
        canvas.drawLine(start, end, paint);
        final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
        const arrowLen = 20.0;
        final p1 = Offset(end.dx - arrowLen * math.cos(angle - 0.4), end.dy - arrowLen * math.sin(angle - 0.4));
        final p2 = Offset(end.dx - arrowLen * math.cos(angle + 0.4), end.dy - arrowLen * math.sin(angle + 0.4));
        canvas.drawLine(end, p1, paint);
        canvas.drawLine(end, p2, paint);
        break;
      case ShapeTool.star:
        _drawStar(canvas, paint);
        break;
    }
  }

  void _drawStar(Canvas canvas, Paint paint) {
    final cx = (start.dx + end.dx) / 2;
    final cy = (start.dy + end.dy) / 2;
    final r = (end - start).distance / 2;
    final ir = r * 0.4;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi / 5) - math.pi / 2;
      final radius = i.isEven ? r : ir;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ShapePreviewPainter oldDelegate) => true;
}

class GridPainter extends CustomPainter {
  final double gridSize;
  final Color color;
  GridPainter({this.gridSize = 50, this.color = const Color(0x0AFFFFFF)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) => false;
}
