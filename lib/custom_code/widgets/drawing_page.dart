import 'dart:io';

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '/flutter_flow/flutter_flow_theme.dart';

import 'package:flutter_animate/flutter_animate.dart';

// --------------------------------------------------------------------------------
// MODELS
// --------------------------------------------------------------------------------

enum BrushType { pen, marker, pencil, airbrush }

class BrushInfo {
  final String id;
  final String name;
  final String category;
  final BrushType type;
  final double defaultSize;
  final double defaultOpacity;

  const BrushInfo({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    this.defaultSize = 4.0,
    this.defaultOpacity = 1.0,
  });
}

const List<String> brushCategories = [
  'Favorites',
  'Recent',
  'Pencils',
  'Pens',
  'Calligraphy',
  'Markers',
  'Paint',
  'Watercolor',
  'Sprayers',
  'Chalks',
  'Charcoals',
  'Design',
  'Fills',
  'Glow',
];

const List<BrushInfo> allBrushes = [
  BrushInfo(id: 'proko_pencil', name: 'Proko Pencil', category: 'Favorites', type: BrushType.pencil, defaultSize: 2.0, defaultOpacity: 0.6),
  BrushInfo(id: 'gesture_vine', name: 'Gesture Vine', category: 'Favorites', type: BrushType.pencil, defaultSize: 6.0, defaultOpacity: 0.5),
  BrushInfo(id: 'pilot_pen', name: 'Pilot Pen', category: 'Favorites', type: BrushType.pen, defaultSize: 3.0, defaultOpacity: 1.0),
  BrushInfo(id: 'manga_inker', name: 'Manga Inker', category: 'Favorites', type: BrushType.pen, defaultSize: 2.5, defaultOpacity: 1.0),
  BrushInfo(id: 'dry_ink_marker', name: 'Dry Ink Marker', category: 'Favorites', type: BrushType.marker, defaultSize: 8.0, defaultOpacity: 0.8),
  BrushInfo(id: 'fine_blender', name: 'Fine Blender', category: 'Favorites', type: BrushType.airbrush, defaultSize: 10.0, defaultOpacity: 0.3),
  BrushInfo(id: 'soft_airbrush', name: 'Soft Airbrush', category: 'Favorites', type: BrushType.airbrush, defaultSize: 15.0, defaultOpacity: 0.4),
  
  BrushInfo(id: 'hb_pencil', name: 'HB Pencil', category: 'Pencils', type: BrushType.pencil, defaultSize: 1.5, defaultOpacity: 0.7),
  BrushInfo(id: 'technical_pen', name: 'Technical Pen', category: 'Pens', type: BrushType.pen, defaultSize: 2.0, defaultOpacity: 1.0),
  BrushInfo(id: 'script', name: 'Script', category: 'Calligraphy', type: BrushType.pen, defaultSize: 5.0, defaultOpacity: 0.9),
  BrushInfo(id: 'round_brush', name: 'Round Brush', category: 'Paint', type: BrushType.marker, defaultSize: 12.0, defaultOpacity: 0.85),
];

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

class _DrawingPageState extends State<DrawingPage> with TickerProviderStateMixin {
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
  BrushInfo _selectedBrushInfo = allBrushes[0];
  String _selectedBrushCategory = 'Favorites';
  BrushType _selectedBrushType = BrushType.pencil;
  Color _selectedColor = Colors.white;
  double _strokeWidth = 4.0;
  double _eraserWidth = 20.0;
  double _strokeOpacity = 1.0;

  // Current Stroke
  DrawingStroke? _currentStroke;

  // UI State
  bool _showLayersPanel = false;
  bool _showRecentPanel = false;
  double _canvasRotation = 0.0;
  List<String> _recentDrawingsPaths = [];
  
  // Multi-touch Pan/Zoom
  final TransformationController _transformationController = TransformationController();
  int _pointerCount = 0;

  @override
  void initState() {
    super.initState();
    _addLayer(); // Initial layer
    _loadRecentDrawings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      // Center the 2000x2000 canvas in the view
      _transformationController.value = Matrix4.identity()
        ..translate(-(2000.0 / 2) + size.width / 2, -(2000.0 / 2) + size.height / 2);
    });
  }

  Future<void> _loadRecentDrawings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final drawingDir = Directory('${directory.path}/saved_drawings');
      if (await drawingDir.exists()) {
        final List<FileSystemEntity> files = drawingDir.listSync();
        setState(() {
          _recentDrawingsPaths = files
              .where((f) => f is File && f.path.endsWith('.png'))
              .map((f) => f.path)
              .toList()
            ..sort((a, b) => b.compareTo(a)); // Newest first
        });
      }
    } catch (e) {
      debugPrint("Error loading drawings: $e");
    }
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
    if (_pointerCount > 1) return;
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
      _layers[_activeLayerIndex].redoStack.clear();
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_pointerCount > 1) return;
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(details.globalPosition);

    setState(() {
      _currentStroke?.points.add(DrawingPoint(localPosition, 1.0));
    });
  }

  void _onPanEnd(DragEndDetails details) {
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
      RenderRepaintBoundary? boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        
        final directory = await getApplicationDocumentsDirectory();
        final drawingDir = Directory('${directory.path}/saved_drawings');
        if (!await drawingDir.exists()) {
          await drawingDir.create(recursive: true);
        }
        
        final fileName = 'sketch_${DateTime.now().millisecondsSinceEpoch}.png';
        final filePath = '${drawingDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);

        _loadRecentDrawings(); // Refresh history
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sketch saved to history!', style: GoogleFonts.outfit()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Save error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save sketch')),
      );
    }
  }
  
  Future<void> _exportImage() async {
    try {
      RenderRepaintBoundary? boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/export_${DateTime.now().millisecondsSinceEpoch}.png';
        File(path).writeAsBytesSync(pngBytes);

        await Share.shareXFiles([XFile(path)], text: 'Created with Pocket Mates Drawing Tool');
      }
    } catch (e) {
      debugPrint("Export error: $e");
    }
  }

  // Text Tools
  void _addText() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Add Text', style: GoogleFonts.outfit(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter text...',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _textOverlays.add(TextOverlay(
                    id: DateTime.now().toString(),
                    text: controller.text,
                    position: const Offset(500, 500),
                    color: _selectedColor,
                    style: GoogleFonts.outfit(),
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.yellow)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Stack(
        children: [
          // 1. Drawing Area
          Positioned.fill(
            child: Listener(
              onPointerDown: (event) => setState(() => _pointerCount++),
              onPointerUp: (event) => setState(() => _pointerCount--),
              child: InteractiveViewer(
                transformationController: _transformationController,
                panEnabled: _pointerCount > 1,
                scaleEnabled: _pointerCount > 1,
                minScale: 0.1,
                maxScale: 20.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                constrained: false,
                child: Transform.rotate(
                  angle: _canvasRotation,
                  child: Container(
                    width: 2000,
                    height: 2000,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 100)],
                    ),
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: Stack(
                        children: [
                          ..._layers.map((layer) {
                            if (!layer.isVisible) return const SizedBox.shrink();
                            return Opacity(
                              opacity: layer.opacity,
                              child: CustomPaint(
                                painter: LayerPainter(
                                  strokes: layer.strokes,
                                  activeStroke: (_layers.indexOf(layer) == _activeLayerIndex) ? _currentStroke : null,
                                ),
                                size: Size.infinite,
                              ),
                            );
                          }).toList(),
                          if (_pointerCount == 1)
                            GestureDetector(
                                onPanStart: _onPanStart,
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                child: Container(color: Colors.transparent),
                              ),
                          ..._textOverlays.map((textOverlay) {
                            return Positioned(
                              left: textOverlay.position.dx,
                              top: textOverlay.position.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  if (_pointerCount > 1) return;
                                  setState(() => textOverlay.position += details.delta);
                                },
                                onTap: () => setState(() => _selectedTextOverlay = textOverlay),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: _selectedTextOverlay == textOverlay
                                      ? BoxDecoration(
                                          border: Border.all(color: Colors.blueAccent, width: 2),
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.blueAccent.withOpacity(0.1),
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
          ),

          // 2. Sidebar Tools
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                    )
                  ],
                  border: Border.all(color: theme.alternate),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSidebarTool(Icons.brush_rounded, !_isEraser, () {
                      if (!_isEraser) {
                        _showBrushPickerSheet();
                      } else {
                        setState(() => _isEraser = false);
                      }
                    }),
                    const SizedBox(height: 20),
                    _buildSidebarTool(Icons.cleaning_services_rounded, _isEraser, () => setState(() => _isEraser = true)),
                    const SizedBox(height: 20),
                    _buildSidebarTool(Icons.text_fields_rounded, false, _addText),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _showColorPicker,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [BoxShadow(color: _selectedColor.withOpacity(0.4), blurRadius: 10)],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildSidebarTool(Icons.history_rounded, _showRecentPanel, () => setState(() => _showRecentPanel = !_showRecentPanel)),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.6, end: 0),
            ),
          ),

          // 3. Header Action Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderIcon(Icons.home_rounded, () => Navigator.pop(context)),
                Row(
                  children: [
                    _buildHeaderIcon(Icons.undo_rounded, _undo),
                    const SizedBox(width: 16),
                    _buildHeaderIcon(Icons.redo_rounded, _redo),
                    const SizedBox(width: 16),
                    _buildHeaderIcon(Icons.layers_rounded, () => setState(() => _showLayersPanel = !_showLayersPanel)),
                    const SizedBox(width: 16),
                    _buildHeaderIcon(Icons.settings_rounded, _showOptionsSheet),
                  ],
                ),
              ],
            ),
          ),

          // 4. Layers Panel
          if (_showLayersPanel)
            Positioned(
              top: 100,
              right: 16,
              width: 240,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                    )
                  ],
                  border: Border.all(color: theme.alternate),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Layers', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.white70, size: 22), onPressed: _addLayer),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ReorderableListView(
                        shrinkWrap: true,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final item = _layers.removeAt(oldIndex);
                            _layers.insert(newIndex, item);
                            _activeLayerIndex = newIndex;
                          });
                        },
                        children: [
                          for (int i = _layers.length - 1; i >= 0; i--) _buildLayerItem(i),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),
            ),

          // 5. Recent Panel
          if (_showRecentPanel)
             Positioned(
              left: 80,
              top: 160,
              bottom: 160,
              width: 260,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.secondaryBackground,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                    )
                  ],
                  border: Border.all(color: theme.alternate),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent History', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                            onPressed: () => setState(() => _showRecentPanel = false),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    Expanded(
                      child: _recentDrawingsPaths.isEmpty 
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.history_toggle_off_rounded, color: Colors.white24, size: 40),
                                const SizedBox(height: 12),
                                Text('No saved sketches', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 14)),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            itemCount: _recentDrawingsPaths.length,
                            itemBuilder: (context, index) {
                              final path = _recentDrawingsPaths[index];
                              return GestureDetector(
                                onTap: () => _viewSavedImage(path),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white12),
                                    image: DecorationImage(
                                      image: FileImage(File(path)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideX(begin: -0.05, end: 0),
            ),
        ],
      ),
    );
  }

  void _viewSavedImage(String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(File(path)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeaderIcon(Icons.share_rounded, () async {
                   await Share.shareXFiles([XFile(path)], text: 'Created with Pocket Mates Drawing Tool');
                }),
                const SizedBox(width: 16),
                _buildHeaderIcon(Icons.delete_outline_rounded, () async {
                   await File(path).delete();
                   _loadRecentDrawings();
                   Navigator.pop(context);
                }),
              ],
            ),
          ],
        ),
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
        color: isActive ? FlutterFlowTheme.of(context).accent1 : Colors.transparent,
        border: Border(bottom: BorderSide(color: FlutterFlowTheme.of(context).alternate)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => layer.isVisible = !layer.isVisible),
                child: Icon(layer.isVisible ? Icons.visibility : Icons.visibility_off, color: layer.isVisible ? Colors.white70 : Colors.white24, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeLayerIndex = index),
                  child: Text(layer.name, style: TextStyle(color: isActive ? Colors.white : Colors.white60, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                ),
              ),
              if (_layers.length > 1)
                GestureDetector(onTap: () => _removeLayer(index), child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18)),
            ],
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.opacity, color: Colors.white54, size: 14),
                  Expanded(child: Slider(value: layer.opacity, min: 0.0, max: 1.0, activeColor: Colors.blueAccent, onChanged: (val) => setState(() => layer.opacity = val))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarTool(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: active ? Colors.white : Colors.white30, size: 26),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Options', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Wrap(
              spacing: 32,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                _buildOptionIcon(Icons.add_rounded, 'New', _clearLayer),
                _buildOptionIcon(Icons.history_rounded, 'History', () => setState(() => _showRecentPanel = true)),
                _buildOptionIcon(Icons.save_rounded, 'Save', _saveImage),
                _buildOptionIcon(Icons.share_rounded, 'Export', _exportImage),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionIcon(IconData icon, String label, VoidCallback onTap) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
              border: Border.all(color: theme.alternate),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.primaryText, size: 28),
          ),
          const SizedBox(height: 10),
          Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  void _showBrushPickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final categoryBrushes = allBrushes.where((b) => b.category == _selectedBrushCategory || (_selectedBrushCategory == 'Recent' && b.category == 'Favorites')).toList();
            
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.brush, color: Colors.white54, size: 20),
                            const SizedBox(width: 8),
                            Text('Brush Library', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.add, color: Colors.white70), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.tune, color: Colors.white70), onPressed: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  Expanded(
                    child: Row(
                      children: [
                        // Left Sidebar - Categories
                        Container(
                          width: 140,
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: Colors.white12)),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: brushCategories.length,
                            itemBuilder: (context, index) {
                              final cat = brushCategories[index];
                              final isSelected = cat == _selectedBrushCategory;
                              
                              IconData icon;
                              if (cat == 'Favorites') icon = Icons.favorite;
                              else if (cat == 'Recent') icon = Icons.access_time;
                              else if (cat == 'Pencils') icon = Icons.create;
                              else if (cat == 'Pens') icon = Icons.gesture;
                              else if (cat == 'Calligraphy') icon = Icons.water_drop_outlined;
                              else if (cat == 'Markers') icon = Icons.format_paint;
                              else if (cat == 'Paint') icon = Icons.color_lens_outlined;
                              else if (cat == 'Watercolor') icon = Icons.waves;
                              else if (cat == 'Sprayers') icon = Icons.blur_on;
                              else if (cat == 'Chalks') icon = Icons.cloud_outlined;
                              else if (cat == 'Charcoals') icon = Icons.change_history;
                              else if (cat == 'Design') icon = Icons.science_outlined;
                              else if (cat == 'Fills') icon = Icons.format_color_fill;
                              else icon = Icons.lightbulb_outline;

                              return InkWell(
                                onTap: () {
                                  setSheetState(() => _selectedBrushCategory = cat);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  color: isSelected ? Colors.white.withOpacity(0.08) : Colors.transparent,
                                  child: Row(
                                    children: [
                                      Icon(icon, size: 18, color: isSelected || cat == 'Favorites' ? (cat == 'Favorites' ? Colors.pinkAccent : Colors.white) : Colors.white54),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          cat,
                                          style: GoogleFonts.outfit(
                                            color: isSelected ? Colors.white : Colors.white54,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Right Side - Brushes
                        Expanded(
                          child: categoryBrushes.isEmpty 
                            ? const Center(child: Text('No brushes found.', style: TextStyle(color: Colors.white38)))
                            : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: categoryBrushes.length,
                              itemBuilder: (context, index) {
                                final brush = categoryBrushes[index];
                                final isSelectedBrush = brush.id == _selectedBrushInfo.id;
                                
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedBrushInfo = brush;
                                      _selectedBrushType = brush.type;
                                      _strokeWidth = brush.defaultSize;
                                      _strokeOpacity = brush.defaultOpacity;
                                    });
                                    setSheetState(() {});
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelectedBrush ? Colors.blueAccent.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelectedBrush ? Colors.blueAccent.withOpacity(0.5) : Colors.transparent,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  brush.name,
                                                  style: GoogleFonts.outfit(
                                                    color: isSelectedBrush ? Colors.white : Colors.white70,
                                                    fontWeight: isSelectedBrush ? FontWeight.bold : FontWeight.w500,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Icon(
                                              Icons.favorite,
                                              color: brush.category == 'Favorites' || _selectedBrushCategory == 'Favorites' ? Colors.pinkAccent : Colors.transparent,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Simulate a brush stroke preview
                                        SizedBox(
                                          height: 30,
                                          width: double.infinity,
                                          child: CustomPaint(
                                            painter: BrushPreviewPainter(
                                              brushType: brush.type,
                                              baseColor: Colors.white,
                                              opacity: brush.defaultOpacity,
                                              thickness: brush.defaultSize,
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
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        title: Text('Select Color', style: GoogleFonts.outfit(color: FlutterFlowTheme.of(context).primaryText)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (c) => setState(() => _selectedColor = c),
            pickerAreaHeightPercent: 0.7,
            labelTypes: const [],
          ),
        ),
        actions: [TextButton(child: const Text('Done'), onPressed: () => Navigator.pop(ctx))],
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
    // Optimization: avoid redrawing if possible
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
      ..color = stroke.color.withOpacity(stroke.opacity)
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = stroke.brushType == BrushType.marker ? StrokeCap.square : StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
      
    if (stroke.brushType == BrushType.airbrush) {
       paint.maskFilter = MaskFilter.blur(BlurStyle.normal, stroke.strokeWidth);
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
  }

  @override
  bool shouldRepaint(covariant LayerPainter oldDelegate) => true;
}

class BrushPreviewPainter extends CustomPainter {
  final BrushType brushType;
  final Color baseColor;
  final double opacity;
  final double thickness;

  BrushPreviewPainter({
    required this.brushType,
    required this.baseColor,
    required this.opacity,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = baseColor.withOpacity(opacity)
      ..strokeWidth = thickness
      ..strokeCap = brushType == BrushType.marker ? StrokeCap.square : StrokeCap.round
      ..style = PaintingStyle.stroke;
      
    if (brushType == BrushType.airbrush) {
       paint.maskFilter = MaskFilter.blur(BlurStyle.normal, thickness);
    }

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.2, size.width * 0.5, size.height / 2);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height / 2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BrushPreviewPainter oldDelegate) => false;
}
