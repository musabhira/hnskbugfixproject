import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// --------------------------------------------------------------------------------
// MODELS
// --------------------------------------------------------------------------------

enum BrushType { pen, marker, pencil, airbrush }

class DrawingPoint {
  final Offset offset;
  final double pressure;

  DrawingPoint(this.offset, this.pressure);
}

class DrawingStroke {
  final Color color;
  final double strokeWidth;
  final List<DrawingPoint> points;
  final bool isEraser;
  final double opacity;
  final BrushType brushType;

  DrawingStroke({
    required this.color,
    required this.strokeWidth,
    required this.points,
    this.isEraser = false,
    this.opacity = 1.0,
    this.brushType = BrushType.pen,
  });
}

class DrawingLayer {
  String id;
  String name;
  bool isVisible;
  double opacity;
  List<DrawingStroke> strokes;
  List<DrawingStroke> redoStack;

  DrawingLayer({
    required this.id,
    required this.name,
    this.isVisible = true,
    this.opacity = 1.0,
    List<DrawingStroke>? strokes,
  })  : strokes = strokes ?? [],
        redoStack = [];
}

class TextOverlay {
  String id;
  String text;
  Offset position;
  Color color;
  double fontSize;
  TextStyle style;

  TextOverlay({
    required this.id,
    required this.text,
    required this.position,
    required this.color,
    this.fontSize = 20.0,
    required this.style,
  });
}

// --------------------------------------------------------------------------------
// PAGE
// --------------------------------------------------------------------------------

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  // Canvas Key
  final GlobalKey _canvasKey = GlobalKey();

  // Layers
  List<DrawingLayer> _layers = [];
  int _activeLayerIndex = 0;

  // Text Overlays
  List<TextOverlay> _textOverlays = [];
  TextOverlay? _selectedTextOverlay;

  // Tool State
  bool _isEraser = false;
  BrushType _selectedBrushType = BrushType.pen;
  Color _selectedColor = Colors.white;
  double _strokeWidth = 4.0;
  double _eraserWidth = 20.0;
  double _strokeOpacity = 1.0;

  // Current Stroke
  DrawingStroke? _currentStroke;

  // UI State
  bool _showLayersPanel = false;
  bool _showColorPanel = false;
  bool _isPanMode = false;
  double _canvasRotation = 0.0;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _addLayer(); // Initial layer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      // Center the 2000x2000 canvas in the view
      _transformationController.value = Matrix4.identity()
        ..translate(
            -(2000.0 / 2) + size.width / 2, -(2000.0 / 2) + size.height / 2);
    });
  }

  void _addLayer() {
    setState(() {
      _layers.add(DrawingLayer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Layer ${_layers.length + 1}',
      ));
      _activeLayerIndex = _layers.length - 1;
    });
  }

  void _removeLayer(int index) {
    if (_layers.length <= 1) return;
    setState(() {
      _layers.removeAt(index);
      if (_activeLayerIndex >= _layers.length) {
        _activeLayerIndex = _layers.length - 1;
      }
    });
  }

  void _clearLayer() {
    setState(() {
      _layers[_activeLayerIndex].strokes.clear();
      _layers[_activeLayerIndex].redoStack.clear();
    });
  }

  // Drawing Logic
  void _onPanStart(DragStartDetails details) {
    if (_isPanMode) return;
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.globalPosition);

    setState(() {
      _currentStroke = DrawingStroke(
        color: _isEraser ? Colors.transparent : _selectedColor,
        strokeWidth: _isEraser ? _eraserWidth : _strokeWidth,
        points: [DrawingPoint(localPosition, 1.0)],
        isEraser: _isEraser,
        opacity: _strokeOpacity,
        brushType: _selectedBrushType,
      );
      // Clear redo stack on new action
      _layers[_activeLayerIndex].redoStack.clear();
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isPanMode) return;
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.globalPosition);

    setState(() {
      _currentStroke?.points.add(DrawingPoint(localPosition, 1.0));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isPanMode) return;
    if (_currentStroke != null) {
      setState(() {
        _layers[_activeLayerIndex].strokes.add(_currentStroke!);
        _currentStroke = null;
      });
    }
  }

  void _undo() {
    setState(() {
      final layer = _layers[_activeLayerIndex];
      if (layer.strokes.isNotEmpty) {
        layer.redoStack.add(layer.strokes.removeLast());
      }
    });
  }

  void _redo() {
    setState(() {
      final layer = _layers[_activeLayerIndex];
      if (layer.redoStack.isNotEmpty) {
        layer.strokes.add(layer.redoStack.removeLast());
      }
    });
  }

  // Saving
  Future<void> _saveImage() async {
    try {
      RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final path =
            '${directory.path}/sketch_${DateTime.now().millisecondsSinceEpoch}.png';
        File(path).writeAsBytesSync(pngBytes);

        await Share.shareXFiles([XFile(path)],
            text: 'Created with Pocket Mates Drawing Tool');
      }
    } catch (e) {
      debugPrint("Save error: $e");
    }
  }

  // Text Tools
  void _addText() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'Enter text...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _textOverlays.add(TextOverlay(
                    id: DateTime.now().toString(),
                    text: controller.text,
                    position: Offset(100, 100),
                    color: _selectedColor,
                    style: GoogleFonts.outfit(),
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme base
      body: Stack(
        children: [
          // 1. Drawing Area
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformationController,
              panEnabled: _isPanMode,
              scaleEnabled: true,
              minScale: 0.1,
              maxScale: 20.0,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              constrained: false, // Let the canvas be its own size
              child: Transform.rotate(
                angle: _canvasRotation,
                child: Container(
                  width: 2000,
                  height: 2000,
                  decoration: BoxDecoration(
                    color: Colors.white, // Canvas background
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.05),
                        blurRadius: 50,
                        spreadRadius: 20,
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: Stack(
                      children: [
                        // Layers
                        ..._layers.map((layer) {
                          if (!layer.isVisible) return const SizedBox.shrink();
                          return Opacity(
                            opacity: layer.opacity,
                            child: CustomPaint(
                              painter: LayerPainter(
                                  strokes: layer.strokes,
                                  activeStroke: (_layers.indexOf(layer) ==
                                          _activeLayerIndex)
                                      ? _currentStroke
                                      : null),
                              size: Size.infinite,
                            ),
                          );
                        }).toList(),

                        // Interaction Detector (Top level)
                        GestureDetector(
                          onPanStart: _isPanMode ? null : _onPanStart,
                          onPanUpdate: _isPanMode ? null : _onPanUpdate,
                          onPanEnd: _isPanMode ? null : _onPanEnd,
                          child: Container(color: Colors.transparent),
                        ),

                        // Text Overlays
                        ..._textOverlays.map((textOverlay) {
                          return Positioned(
                            left: textOverlay.position.dx,
                            top: textOverlay.position.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                if (_isPanMode) return;
                                setState(() {
                                  textOverlay.position += details.delta;
                                });
                              },
                              onTap: () {
                                if (_isPanMode) return;
                                setState(() {
                                  _selectedTextOverlay = textOverlay;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: _selectedTextOverlay == textOverlay
                                    ? BoxDecoration(
                                        border: Border.all(
                                            color: Colors.blueAccent, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      )
                                    : null,
                                child: Text(
                                  textOverlay.text,
                                  style: textOverlay.style.copyWith(
                                    color: textOverlay.color,
                                    fontSize: textOverlay.fontSize,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Top Bar (Floating Glassmorphism)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.rotate_left_rounded,
                            color: Colors.white),
                        onPressed: () =>
                            setState(() => _canvasRotation -= math.pi / 2),
                      ),
                      IconButton(
                        icon: const Icon(Icons.rotate_right_rounded,
                            color: Colors.white),
                        onPressed: () =>
                            setState(() => _canvasRotation += math.pi / 2),
                      ),
                      const Spacer(),
                      IconButton(
                        icon:
                            const Icon(Icons.undo_rounded, color: Colors.white),
                        onPressed: _undo,
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.redo_rounded, color: Colors.white),
                        onPressed: _redo,
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => setState(
                            () => _showLayersPanel = !_showLayersPanel),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _showLayersPanel
                                ? Colors.blueAccent
                                : Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.layers_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.save_alt_rounded,
                            color: Colors.greenAccent),
                        onPressed: _saveImage,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Bottom Toolbar (Floating Glassmorphism)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(32),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Size Slider if active
                      if (!_showColorPanel && !_isPanMode)
                        Column(
                          children: [
                            Row(
                              children: [
                                Text('Opacity',
                                    style: GoogleFonts.outfit(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Slider(
                                    value: _strokeOpacity,
                                    min: 0.1,
                                    max: 1.0,
                                    activeColor: Colors.blueAccent,
                                    inactiveColor: Colors.white24,
                                    onChanged: (v) =>
                                        setState(() => _strokeOpacity = v),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Size',
                                    style: GoogleFonts.outfit(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Slider(
                                    value:
                                        _isEraser ? _eraserWidth : _strokeWidth,
                                    min: 1.0,
                                    max: 100.0,
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white24,
                                    onChanged: (v) => setState(() {
                                      if (_isEraser) {
                                        _eraserWidth = v;
                                      } else {
                                        _strokeWidth = v;
                                      }
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: BrushType.values.map((b) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ChoiceChip(
                                      label: Text(b.name.toUpperCase(),
                                          style: const TextStyle(fontSize: 10)),
                                      selected: _selectedBrushType == b &&
                                          !_isEraser &&
                                          !_isPanMode,
                                      selectedColor: Colors.blueAccent
                                          .withValues(alpha: 0.3),
                                      backgroundColor: Colors.transparent,
                                      side: BorderSide(
                                          color: Colors.white
                                              .withValues(alpha: 0.2)),
                                      onSelected: (val) {
                                        setState(() {
                                          _isEraser = false;
                                          _isPanMode = false;
                                          _selectedBrushType = b;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const Divider(color: Colors.white12),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildToolIcon(
                              Icons.brush_rounded,
                              !_isEraser && !_isPanMode,
                              () => setState(() {
                                    _isEraser = false;
                                    _isPanMode = false;
                                  })),
                          _buildToolIcon(
                              Icons.cleaning_services_rounded,
                              _isEraser && !_isPanMode,
                              () => setState(() {
                                    _isEraser = true;
                                    _isPanMode = false;
                                  })),
                          _buildToolIcon(Icons.pan_tool_rounded, _isPanMode,
                              () => setState((() => _isPanMode = true))),
                          _buildToolIcon(
                              Icons.text_fields_rounded, false, _addText),
                          GestureDetector(
                            onTap: _showColorPicker,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _selectedColor,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        _selectedColor.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Layers Panel
          if (_showLayersPanel)
            Positioned(
              top: 100,
              right: 16,
              width: 220,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 10)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Layers',
                              style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: _addLayer,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: ReorderableListView(
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final item = _layers.removeAt(oldIndex);
                            _layers.insert(newIndex, item);
                            // Adjust active index logic if needed
                            // Simpler to just reset active to new position of moved item
                            _activeLayerIndex = newIndex;
                          });
                        },
                        children: [
                          for (int i = _layers.length - 1; i >= 0; i--)
                            _buildLayerItem(i),
                        ],
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

  Widget _buildLayerItem(int index) {
    final layer = _layers[index];
    final isActive = index == _activeLayerIndex;

    return Container(
      key: ValueKey(layer.id),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color:
            isActive ? Colors.blue.withValues(alpha: 0.2) : Colors.transparent,
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => layer.isVisible = !layer.isVisible),
                child: Icon(
                  layer.isVisible ? Icons.visibility : Icons.visibility_off,
                  color: layer.isVisible ? Colors.white70 : Colors.white30,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeLayerIndex = index),
                  child: Text(
                    layer.name,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white60,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (_layers.length > 1)
                GestureDetector(
                  onTap: () => _removeLayer(index),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 18),
                ),
            ],
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.opacity, color: Colors.white54, size: 14),
                  Expanded(
                    child: Slider(
                      value: layer.opacity,
                      min: 0.0,
                      max: 1.0,
                      activeColor: Colors.blueAccent,
                      onChanged: (val) => setState(() => layer.opacity = val),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            color: isActive ? Colors.white : Colors.white54, size: 24),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title:
            const Text('Select Color', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (c) => setState(() => _selectedColor = c),
            showLabel: false,
            pickerAreaHeightPercent: 0.7,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Done'),
            onPressed: () => Navigator.pop(ctx),
          )
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------------
// PAINTER
// --------------------------------------------------------------------------------

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
    if (activeStroke != null) {
      _drawStroke(canvas, activeStroke!);
    }
    canvas.restore();
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.isEraser
          ? Colors.white
          : stroke.color.withValues(alpha: stroke.opacity)
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (!stroke.isEraser) {
      switch (stroke.brushType) {
        case BrushType.marker:
          paint.strokeJoin = StrokeJoin.bevel;
          paint.color = stroke.color.withValues(alpha: stroke.opacity * 0.5);
          break;
        case BrushType.pencil:
          paint.color = stroke.color.withValues(alpha: stroke.opacity * 0.8);
          paint.strokeWidth = stroke.strokeWidth * 0.5;
          break;
        case BrushType.airbrush:
          paint.maskFilter =
              MaskFilter.blur(BlurStyle.normal, stroke.strokeWidth * 0.5);
          paint.color = stroke.color.withValues(alpha: stroke.opacity * 0.3);
          break;
        case BrushType.pen:
          break;
      }
    }

    if (stroke.isEraser) {
      paint.blendMode = BlendMode.clear;
      paint.color = Colors.transparent;
    }

    // Smoothing with Quadratic Bezier
    final path = Path();
    if (stroke.points.length < 2) {
      // Draw point
      canvas.drawPoints(
          ui.PointMode.points, [stroke.points.first.offset], paint);
      return;
    }

    path.moveTo(stroke.points.first.offset.dx, stroke.points.first.offset.dy);

    for (int i = 1; i < stroke.points.length - 1; i++) {
      final p0 = stroke.points[i].offset;
      final p1 = stroke.points[i + 1].offset;

      // Midpoint
      final control = p0;
      final dest = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);

      path.quadraticBezierTo(control.dx, control.dy, dest.dx, dest.dy);
    }
    // Last point
    path.lineTo(stroke.points.last.offset.dx, stroke.points.last.offset.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LayerPainter oldDelegate) {
    return true; // Optimize later with checking list length
  }
}
