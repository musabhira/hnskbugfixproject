import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _globalKey = GlobalKey();
  List<DrawingStroke> _strokes = [];
  DrawingStroke? _currentStroke;

  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  bool _isEraser = false;

  // Undo/Redo
  List<DrawingStroke> _redoStack = [];

  void _startStroke(DragStartDetails details) {
    setState(() {
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      final localPosition = renderBox.globalToLocal(details.globalPosition);

      _currentStroke = DrawingStroke(
        color: _isEraser ? Colors.transparent : _selectedColor,
        width: _strokeWidth,
        points: [localPosition],
        isEraser: _isEraser,
      );
      _redoStack.clear();
    });
  }

  void _updateStroke(DragUpdateDetails details) {
    setState(() {
      RenderBox renderBox = context.findRenderObject() as RenderBox;
      final localPosition = renderBox.globalToLocal(details.globalPosition);
      _currentStroke?.points.add(localPosition);
    });
  }

  void _endStroke(DragEndDetails details) {
    setState(() {
      if (_currentStroke != null) {
        _strokes.add(_currentStroke!);
        _currentStroke = null;
      }
    });
  }

  void _undo() {
    setState(() {
      if (_strokes.isNotEmpty) {
        _redoStack.add(_strokes.removeLast());
      }
    });
  }

  void _redo() {
    setState(() {
      if (_redoStack.isNotEmpty) {
        _strokes.add(_redoStack.removeLast());
      }
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _redoStack.clear();
    });
  }

  Future<void> _saveAsPng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        final directory = await getTemporaryDirectory();
        final file = File(
            '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(pngBytes);

        // Share the file
        await Share.shareXFiles([XFile(file.path)],
            text: 'Check out my drawing!');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drawing saved and shared!')),
        );
      }
    } catch (e) {
      debugPrint("Error saving drawing: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
                _isEraser = false;
              });
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Mini Sketchpad',
            style: GoogleFonts.outfit(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _strokes.isNotEmpty ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _redoStack.isNotEmpty ? _redo : null,
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveAsPng,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRect(
                child: RepaintBoundary(
                  key: _globalKey,
                  child: GestureDetector(
                    onPanStart: _startStroke,
                    onPanUpdate: _updateStroke,
                    onPanEnd: _endStroke,
                    child: CustomPaint(
                      painter: DrawingPainter(
                        strokes: _strokes,
                        currentStroke: _currentStroke,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Size',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              Expanded(
                child: Slider(
                  value: _strokeWidth,
                  min: 1.0,
                  max: 20.0,
                  activeColor: _isEraser ? Colors.grey : _selectedColor,
                  onChanged: (val) => setState(() => _strokeWidth = val),
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _isEraser ? Colors.white : _selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                    child: Container(
                  width: _strokeWidth,
                  height: _strokeWidth,
                  decoration: BoxDecoration(
                    color: _isEraser
                        ? Colors.grey
                        : Colors.black, // Just to show size
                    shape: BoxShape.circle,
                  ),
                )),
              )
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildToolButton(
                icon: Icons.edit,
                label: 'Pencil',
                isSelected: !_isEraser,
                onTap: () => setState(() => _isEraser = false),
              ),
              _buildToolButton(
                icon: Icons.auto_fix_high, // Eraser-like icon
                label: 'Eraser',
                isSelected: _isEraser,
                onTap: () => setState(() => _isEraser = true),
              ),
              _buildColorButton(),
              _buildToolButton(
                icon: Icons.delete_outline,
                label: 'Clear',
                isSelected: false,
                onTap: _clearCanvas,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.yellow.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Colors.yellow, width: 2)
                  : null,
            ),
            child: Icon(icon,
                color: isSelected ? Colors.orange : Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.orange : Colors.grey[600],
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildColorButton() {
    return GestureDetector(
      onTap: _pickColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!)),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[400]!),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('Color',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

class DrawingStroke {
  final Color color;
  final double width;
  final List<Offset> points;
  final bool isEraser;

  DrawingStroke({
    required this.color,
    required this.width,
    required this.points,
    this.isEraser = false,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final DrawingStroke? currentStroke;

  DrawingPainter({required this.strokes, this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background (white)
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white);

    // Using SaveLayer for true erasing if needed, but simple white paint works for basic eraser on white bg.
    // However, if we want transparency later, we need BlendMode.srcOver.

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }

    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.isEraser ? Colors.white : stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Smooth path
    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      // Simple line to
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);

      // Quadratic bezier for smoother lines (optional, keep simple for now)
      // final p0 = stroke.points[i - 1];
      // final p1 = stroke.points[i];
      // final p2 = (p0 + p1) / 2;
      // path.quadraticBezierTo(p0.dx, p0.dy, p2.dx, p2.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true;
  }
}
