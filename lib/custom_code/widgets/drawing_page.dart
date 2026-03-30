import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'drawing_page_models.dart';
import 'drawing_page_painters.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> with TickerProviderStateMixin {
  final GlobalKey _canvasKey = GlobalKey();

  // Layers
  List<DrawingLayer> _layers = [];
  int _activeLayerIndex = 0;

  // Text & Image Overlays
  List<TextOverlay> _textOverlays = [];
  List<ImageOverlay> _imageOverlays = [];

  // Tool State
  DrawingTool _activeTool = DrawingTool.brush;
  bool _isEraser = false;
  BrushInfo _selectedBrushInfo = allBrushes[0];
  String _selectedBrushCategory = 'Favorites';
  BrushType _selectedBrushType = BrushType.pencil;
  Color _selectedColor = Colors.white;
  Color _canvasBgColor = Colors.white;
  double _strokeWidth = 4.0;
  double _eraserWidth = 20.0;
  double _strokeOpacity = 1.0;

  // Shape State
  ShapeTool _selectedShape = ShapeTool.line;
  bool _shapeFilled = false;
  Offset? _shapeStart, _shapeEnd;

  // Current Stroke
  DrawingStroke? _currentStroke;

  // UI State
  bool _showLayersPanel = false;
  bool _showRecentPanel = false;
  bool _showBrushSettings = false;
  bool _showGrid = false;
  bool _isRecording = false;
  List<String> _recentDrawingsPaths = [];

  // Canvas
  final TransformationController _transformationController = TransformationController();
  int _pointerCount = 0;
  final double _canvasSize = 3000;

  @override
  void initState() {
    super.initState();
    _addLayer();
    _loadRecentDrawings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      _transformationController.value = Matrix4.identity()
        ..translate(-(_canvasSize / 2) + size.width / 2, -(_canvasSize / 2) + size.height / 2);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  // ── Layer Management ──
  void _addLayer() {
    setState(() {
      _layers.add(DrawingLayer(id: DateTime.now().millisecondsSinceEpoch.toString(), name: 'Layer ${_layers.length + 1}'));
      _activeLayerIndex = _layers.length - 1;
    });
  }

  void _removeLayer(int index) {
    if (_layers.length <= 1) return;
    setState(() {
      _layers.removeAt(index);
      if (_activeLayerIndex >= _layers.length) _activeLayerIndex = _layers.length - 1;
    });
  }

  void _duplicateLayer(int index) {
    final src = _layers[index];
    setState(() {
      _layers.insert(index + 1, DrawingLayer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '${src.name} copy',
        opacity: src.opacity,
        strokes: List.from(src.strokes),
      ));
      _activeLayerIndex = index + 1;
    });
  }

  void _mergeDown(int index) {
    if (index <= 0) return;
    setState(() {
      _layers[index - 1].strokes.addAll(_layers[index].strokes);
      _layers.removeAt(index);
      _activeLayerIndex = index - 1;
    });
  }

  void _clearLayer() {
    setState(() {
      _layers[_activeLayerIndex].strokes.clear();
      _layers[_activeLayerIndex].redoStack.clear();
    });
  }

  // ── Drawing Logic ──
  void _onPanStart(DragStartDetails details) {
    if (_pointerCount > 1 || _layers[_activeLayerIndex].isLocked) return;
    RenderBox box = _canvasKey.currentContext!.findRenderObject() as RenderBox;
    Offset pos = box.globalToLocal(details.globalPosition);

    if (_activeTool == DrawingTool.shape) {
      setState(() { _shapeStart = pos; _shapeEnd = pos; });
      return;
    }
    if (_activeTool == DrawingTool.eyedropper) return;

    setState(() {
      _currentStroke = DrawingStroke(
        color: _isEraser ? Colors.transparent : _selectedColor,
        strokeWidth: _isEraser ? _eraserWidth : _strokeWidth,
        points: [DrawingPoint(pos, 1.0)],
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
    Offset pos = box.globalToLocal(details.globalPosition);

    if (_activeTool == DrawingTool.shape) {
      setState(() => _shapeEnd = pos);
      return;
    }

    setState(() => _currentStroke?.points.add(DrawingPoint(pos, 1.0)));
  }

  void _onPanEnd(DragEndDetails details) {
    if (_activeTool == DrawingTool.shape && _shapeStart != null && _shapeEnd != null) {
      // Convert shape to stroke points  
      setState(() { _shapeStart = null; _shapeEnd = null; });
      return;
    }
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
      if (layer.strokes.isNotEmpty) layer.redoStack.add(layer.strokes.removeLast());
    });
  }

  void _redo() {
    setState(() {
      final layer = _layers[_activeLayerIndex];
      if (layer.redoStack.isNotEmpty) layer.strokes.add(layer.redoStack.removeLast());
    });
  }

  // ── File Operations ──
  Future<void> _loadRecentDrawings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final drawingDir = Directory('${directory.path}/saved_drawings');
      if (await drawingDir.exists()) {
        final files = drawingDir.listSync();
        setState(() {
          _recentDrawingsPaths = files.where((f) => f is File && f.path.endsWith('.png')).map((f) => f.path).toList()..sort((a, b) => b.compareTo(a));
        });
      }
    } catch (e) {
      debugPrint("Error loading drawings: $e");
    }
  }

  Future<void> _saveImage() async {
    try {
      RenderRepaintBoundary? boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final dir = await getApplicationDocumentsDirectory();
        final drawingDir = Directory('${dir.path}/saved_drawings');
        if (!await drawingDir.exists()) await drawingDir.create(recursive: true);
        final file = File('${drawingDir.path}/sketch_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes);
        _loadRecentDrawings();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved!', style: GoogleFonts.outfit()), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      debugPrint("Save error: $e");
    }
  }

  Future<void> _exportImage() async {
    try {
      RenderRepaintBoundary? boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/export_${DateTime.now().millisecondsSinceEpoch}.png';
        File(path).writeAsBytesSync(bytes);
        await Share.shareXFiles([XFile(path)], text: 'Created with PocketMates');
      }
    } catch (e) {
      debugPrint("Export error: $e");
    }
  }

  Future<void> _importImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageOverlays.add(ImageOverlay(id: DateTime.now().millisecondsSinceEpoch.toString(), bytes: bytes, position: Offset(_canvasSize / 2 - 150, _canvasSize / 2 - 150)));
      });
    } catch (e) {
      debugPrint("Import error: $e");
    }
  }

  void _newCanvas() {
    setState(() {
      _layers.clear();
      _textOverlays.clear();
      _imageOverlays.clear();
      _addLayer();
    });
  }

  // ── Text Tool ──
  void _addText() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Add Text', style: GoogleFonts.outfit(color: Colors.white)),
        content: TextField(controller: controller, autofocus: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Enter text...', hintStyle: TextStyle(color: Colors.white38))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () {
            if (controller.text.isNotEmpty) {
              setState(() => _textOverlays.add(TextOverlay(id: DateTime.now().toString(), text: controller.text, position: Offset(_canvasSize / 2, _canvasSize / 2), color: _selectedColor, style: GoogleFonts.outfit())));
              Navigator.pop(ctx);
            }
          }, child: const Text('Add', style: TextStyle(color: Colors.yellow))),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // ── Canvas ──
          Positioned.fill(
            child: Listener(
              onPointerDown: (_) => setState(() => _pointerCount++),
              onPointerUp: (_) => setState(() => _pointerCount--),
              child: InteractiveViewer(
                transformationController: _transformationController,
                panEnabled: _pointerCount > 1,
                scaleEnabled: _pointerCount > 1,
                minScale: 0.05,
                maxScale: 30.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                constrained: false,
                child: Container(
                  width: _canvasSize,
                  height: _canvasSize,
                  decoration: BoxDecoration(
                    color: _canvasBgColor,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 120)],
                  ),
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: Stack(
                      children: [
                        Container(color: _canvasBgColor),
                        if (_showGrid) CustomPaint(painter: GridPainter(), size: Size(_canvasSize, _canvasSize)),
                        // Image overlays
                        ..._imageOverlays.map((img) => Positioned(
                          left: img.position.dx, top: img.position.dy,
                          child: GestureDetector(
                            onPanUpdate: (d) { if (_pointerCount <= 1) setState(() => img.position += d.delta); },
                            child: Transform.scale(scale: img.scale, child: Transform.rotate(angle: img.rotation, child: Image.memory(img.bytes, width: 300, fit: BoxFit.contain))),
                          ),
                        )),
                        // Layer strokes
                        ..._layers.map((layer) {
                          if (!layer.isVisible) return const SizedBox.shrink();
                          return Opacity(
                            opacity: layer.opacity,
                            child: CustomPaint(painter: LayerPainter(strokes: layer.strokes, activeStroke: (_layers.indexOf(layer) == _activeLayerIndex) ? _currentStroke : null), size: Size(_canvasSize, _canvasSize)),
                          );
                        }),
                        // Shape preview
                        if (_activeTool == DrawingTool.shape && _shapeStart != null && _shapeEnd != null)
                          CustomPaint(painter: ShapePreviewPainter(shape: _selectedShape, start: _shapeStart!, end: _shapeEnd!, color: _selectedColor, strokeWidth: _strokeWidth, filled: _shapeFilled), size: Size(_canvasSize, _canvasSize)),
                        // Touch handler
                        if (_pointerCount <= 1)
                          GestureDetector(onPanStart: _onPanStart, onPanUpdate: _onPanUpdate, onPanEnd: _onPanEnd, child: Container(color: Colors.transparent)),
                        // Text overlays
                        ..._textOverlays.map((t) => Positioned(
                          left: t.position.dx, top: t.position.dy,
                          child: GestureDetector(
                            onPanUpdate: (d) { if (_pointerCount <= 1) setState(() => t.position += d.delta); },
                            child: Text(t.text, style: t.style.copyWith(color: t.color, fontSize: t.fontSize)),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Left Sidebar ──
          Positioned(
            left: 8, top: 0, bottom: 0,
            child: Center(child: _buildLeftSidebar(theme)),
          ),

          // ── Top Bar ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16,
            child: _buildTopBar(theme),
          ),

          // ── Bottom Undo/Redo ──
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16, left: 24, right: 24,
            child: _buildBottomBar(theme),
          ),

          // ── Layers Panel ──
          if (_showLayersPanel)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60, right: 8,
              child: _buildLayersPanel(theme, isTablet),
            ),

          // ── Brush Settings ──
          if (_showBrushSettings)
            Positioned(
              left: 72, top: MediaQuery.of(context).size.height * 0.25,
              child: _buildBrushSettingsPanel(theme),
            ),

          // ── Recent Panel ──
          if (_showRecentPanel)
            Positioned(left: 72, top: 120, bottom: 120, width: isTablet ? 320 : 250, child: _buildRecentPanel(theme)),

          // ── Recording indicator ──
          if (_isRecording)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60, left: 0, right: 0,
              child: Center(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('Recording', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                ]),
              )),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // LEFT SIDEBAR
  // ══════════════════════════════════════════════════════════════════
  Widget _buildLeftSidebar(FlutterFlowTheme theme) {
    return Container(
      width: 52, padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _sideBtn(Icons.brush_rounded, _activeTool == DrawingTool.brush && !_isEraser, () {
          if (_activeTool == DrawingTool.brush && !_isEraser) { _showBrushPickerSheet(); } else { setState(() { _activeTool = DrawingTool.brush; _isEraser = false; }); }
        }),
        const SizedBox(height: 14),
        _sideBtn(Icons.gesture_rounded, _activeTool == DrawingTool.lasso, () => setState(() => _activeTool = DrawingTool.lasso)),
        const SizedBox(height: 14),
        _sideBtn(Icons.auto_fix_high_rounded, _isEraser, () => setState(() { _isEraser = true; _activeTool = DrawingTool.eraser; })),
        const SizedBox(height: 14),
        _sideBtn(Icons.crop_square_rounded, _activeTool == DrawingTool.shape, () { setState(() => _activeTool = DrawingTool.shape); _showShapePicker(); }),
        const SizedBox(height: 14),
        _sideBtn(Icons.text_fields_rounded, false, _addText),
        const SizedBox(height: 14),
        // Color dot
        GestureDetector(
          onTap: _showColorPicker,
          child: Container(width: 28, height: 28, decoration: BoxDecoration(color: _selectedColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5), boxShadow: [BoxShadow(color: _selectedColor.withValues(alpha: 0.5), blurRadius: 8)])),
        ),
        const SizedBox(height: 14),
        // Opacity dot
        GestureDetector(
          onTap: () => setState(() => _showBrushSettings = !_showBrushSettings),
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white54, width: 1.5)),
            child: Center(child: Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: _strokeOpacity)))),
          ),
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.5);
  }

  Widget _sideBtn(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: active ? Colors.white.withValues(alpha: 0.12) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: active ? Colors.white : Colors.white30, size: 22),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // TOP BAR
  // ══════════════════════════════════════════════════════════════════
  Widget _buildTopBar(FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _headerBtn(Icons.home_outlined, () => Navigator.pop(context)),
        Row(children: [
          _headerBtn(Icons.architecture_outlined, () {}), // Transform
          const SizedBox(width: 12),
          _headerBtn(Icons.layers_outlined, () => setState(() => _showLayersPanel = !_showLayersPanel)),
          const SizedBox(width: 12),
          _headerBtn(Icons.more_horiz_rounded, _showOptionsSheet),
        ]),
      ],
    );
  }

  Widget _headerBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle), child: Icon(icon, color: Colors.white70, size: 22)),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // BOTTOM BAR
  // ══════════════════════════════════════════════════════════════════
  Widget _buildBottomBar(FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _headerBtn(Icons.undo_rounded, _undo),
        _headerBtn(Icons.redo_rounded, _redo),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // LAYERS PANEL (Right side like reference)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildLayersPanel(FlutterFlowTheme theme, bool isTablet) {
    return Container(
      width: isTablet ? 90 : 70,
      decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 15)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Add button
        GestureDetector(
          onTap: _addLayer,
          child: Container(padding: const EdgeInsets.all(12), child: const Icon(Icons.add, color: Colors.white70, size: 22)),
        ),
        const Divider(color: Colors.white10, height: 1),
        // Layer thumbnails
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _layers.length,
            itemBuilder: (ctx, i) {
              final ri = _layers.length - 1 - i; // Reverse order (top layer first)
              final layer = _layers[ri];
              final isActive = ri == _activeLayerIndex;
              return GestureDetector(
                onTap: () => setState(() => _activeLayerIndex = ri),
                onLongPress: () => _showLayerOptions(ri),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  height: isTablet ? 70 : 55,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: layer.isVisible ? 0.9 : 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isActive ? Colors.red : Colors.transparent, width: isActive ? 2.5 : 0),
                  ),
                  child: Stack(children: [
                    // Visibility toggle
                    Positioned(right: 2, top: 2, child: GestureDetector(
                      onTap: () => setState(() => layer.isVisible = !layer.isVisible),
                      child: Icon(Icons.visibility, size: 14, color: layer.isVisible ? Colors.black38 : Colors.black12),
                    )),
                    if (layer.isLocked) const Positioned(left: 2, bottom: 2, child: Icon(Icons.lock, size: 12, color: Colors.black38)),
                  ]),
                ),
              );
            },
          ),
        ),
        const Divider(color: Colors.white10, height: 1),
        // Background color toggle
        GestureDetector(
          onTap: _showCanvasBgPicker,
          child: Container(
            margin: const EdgeInsets.all(10),
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: _canvasBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
            ),
          ),
        ),
      ]),
    ).animate().fadeIn().slideX(begin: 0.2);
  }

  void _showLayerOptions(int index) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_layers[index].name, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Opacity slider
          Row(children: [
            const Icon(Icons.opacity, color: Colors.white54, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Slider(value: _layers[index].opacity, min: 0, max: 1, activeColor: Colors.blueAccent, onChanged: (v) => setState(() => _layers[index].opacity = v))),
            Text('${(_layers[index].opacity * 100).toInt()}%', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
          const Divider(color: Colors.white10),
          _layerOption(Icons.copy, 'Duplicate', () { _duplicateLayer(index); Navigator.pop(ctx); }),
          _layerOption(Icons.merge, 'Merge Down', () { _mergeDown(index); Navigator.pop(ctx); }),
          _layerOption(Icons.lock_outline, _layers[index].isLocked ? 'Unlock' : 'Lock', () { setState(() => _layers[index].isLocked = !_layers[index].isLocked); Navigator.pop(ctx); }),
          _layerOption(Icons.cleaning_services, 'Clear', () { setState(() { _activeLayerIndex = index; }); _clearLayer(); Navigator.pop(ctx); }),
          if (_layers.length > 1) _layerOption(Icons.delete_outline, 'Delete', () { _removeLayer(index); Navigator.pop(ctx); }, color: Colors.redAccent),
        ]),
      ),
    );
  }

  Widget _layerOption(IconData icon, String label, VoidCallback onTap, {Color color = Colors.white70}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: GoogleFonts.outfit(color: color)),
      onTap: onTap,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // BRUSH SETTINGS PANEL
  // ══════════════════════════════════════════════════════════════════
  Widget _buildBrushSettingsPanel(FlutterFlowTheme theme) {
    return Container(
      width: 220, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 15)]),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Brush Settings', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          GestureDetector(onTap: () => setState(() => _showBrushSettings = false), child: const Icon(Icons.close, color: Colors.white38, size: 18)),
        ]),
        const SizedBox(height: 16),
        Text('Size: ${_strokeWidth.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Slider(value: _strokeWidth, min: 0.5, max: 60, activeColor: Colors.blueAccent, onChanged: (v) => setState(() => _strokeWidth = v)),
        Text('Opacity: ${(_strokeOpacity * 100).toInt()}%', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Slider(value: _strokeOpacity, min: 0.01, max: 1.0, activeColor: Colors.blueAccent, onChanged: (v) => setState(() => _strokeOpacity = v)),
        if (_isEraser) ...[
          Text('Eraser: ${_eraserWidth.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Slider(value: _eraserWidth, min: 5, max: 100, activeColor: Colors.redAccent, onChanged: (v) => setState(() => _eraserWidth = v)),
        ],
        const SizedBox(height: 8),
        Row(children: [
          const Text('Grid', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const Spacer(),
          Switch(value: _showGrid, activeColor: Colors.blueAccent, onChanged: (v) => setState(() => _showGrid = v)),
        ]),
      ]),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  // ══════════════════════════════════════════════════════════════════
  // RECENT PANEL
  // ══════════════════════════════════════════════════════════════════
  Widget _buildRecentPanel(FlutterFlowTheme theme) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 25)]),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('History', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          GestureDetector(onTap: () => setState(() => _showRecentPanel = false), child: const Icon(Icons.close, color: Colors.white38, size: 18)),
        ])),
        const Divider(color: Colors.white10, height: 1),
        Expanded(
          child: _recentDrawingsPaths.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.history_toggle_off, color: Colors.white24, size: 36), const SizedBox(height: 8), Text('No saved sketches', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13))]))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
                  itemCount: _recentDrawingsPaths.length,
                  itemBuilder: (ctx, i) {
                    final path = _recentDrawingsPaths[i];
                    return GestureDetector(
                      onTap: () => _viewSavedImage(path),
                      child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12), image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover))),
                    );
                  },
                ),
        ),
      ]),
    ).animate().fadeIn().slideX(begin: -0.05);
  }

  void _viewSavedImage(String path) {
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(File(path))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _headerBtn(Icons.share_rounded, () async { await Share.shareXFiles([XFile(path)], text: 'Created with PocketMates'); }),
          const SizedBox(width: 16),
          _headerBtn(Icons.delete_outline_rounded, () async { await File(path).delete(); _loadRecentDrawings(); Navigator.pop(ctx); }),
        ]),
      ]),
    ));
  }

  // ══════════════════════════════════════════════════════════════════
  // OPTIONS SHEET (Matching reference: New, Open, Save, Import, Record, Export)
  // ══════════════════════════════════════════════════════════════════
  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Options', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 28),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _optBtn(Icons.add, 'New', () { Navigator.pop(ctx); _newCanvas(); }),
            _optBtn(Icons.folder_open, 'Open', () { Navigator.pop(ctx); setState(() => _showRecentPanel = true); }),
            _optBtn(Icons.save, 'Save', () { Navigator.pop(ctx); _saveImage(); }),
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _optBtn(Icons.file_upload_outlined, 'Import', () { Navigator.pop(ctx); _importImage(); }),
            _optBtn(Icons.fiber_manual_record, 'Record', () { Navigator.pop(ctx); setState(() => _isRecording = !_isRecording); }, highlight: _isRecording),
            _optBtn(Icons.file_download_outlined, 'Export', () { Navigator.pop(ctx); _exportImage(); }),
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _optBtn(Icons.public, 'Community', () => Navigator.pop(ctx)),
            _optBtn(Icons.help_outline, 'Classroom', () => Navigator.pop(ctx)),
            _optBtn(Icons.settings_outlined, 'Settings', () { Navigator.pop(ctx); _showSettingsSheet(); }),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _optBtn(IconData icon, String label, VoidCallback onTap, {bool highlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: highlight ? Colors.red.withValues(alpha: 0.5) : const Color(0xFF1A1A1A), border: Border.all(color: highlight ? Colors.red : Colors.white12), shape: BoxShape.circle), child: Icon(icon, color: highlight ? Colors.red : Colors.white70, size: 24)),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SETTINGS SHEET
  // ══════════════════════════════════════════════════════════════════
  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Settings', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ListTile(leading: const Icon(Icons.grid_3x3, color: Colors.white54), title: Text('Show Grid', style: GoogleFonts.outfit(color: Colors.white70)), trailing: Switch(value: _showGrid, activeColor: Colors.blueAccent, onChanged: (v) => setState(() => _showGrid = v))),
          ListTile(leading: const Icon(Icons.format_paint, color: Colors.white54), title: Text('Canvas Color', style: GoogleFonts.outfit(color: Colors.white70)), trailing: Container(width: 28, height: 28, decoration: BoxDecoration(color: _canvasBgColor, shape: BoxShape.circle, border: Border.all(color: Colors.white24))), onTap: () { Navigator.pop(ctx); _showCanvasBgPicker(); }),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showCanvasBgPicker() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: Text('Canvas Color', style: GoogleFonts.outfit(color: Colors.white)),
      content: SingleChildScrollView(child: ColorPicker(pickerColor: _canvasBgColor, onColorChanged: (c) => setState(() => _canvasBgColor = c), labelTypes: const [])),
      actions: [TextButton(child: const Text('Done'), onPressed: () => Navigator.pop(ctx))],
    ));
  }

  // ══════════════════════════════════════════════════════════════════
  // SHAPE PICKER
  // ══════════════════════════════════════════════════════════════════
  void _showShapePicker() {
    final shapes = [
      (ShapeTool.line, Icons.horizontal_rule, 'Line'),
      (ShapeTool.rectangle, Icons.crop_square, 'Rectangle'),
      (ShapeTool.circle, Icons.circle_outlined, 'Circle'),
      (ShapeTool.triangle, Icons.change_history, 'Triangle'),
      (ShapeTool.arrow, Icons.arrow_forward, 'Arrow'),
      (ShapeTool.star, Icons.star_border, 'Star'),
    ];
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Shapes', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(spacing: 16, runSpacing: 16, children: shapes.map((s) => GestureDetector(
            onTap: () { setState(() => _selectedShape = s.$1); Navigator.pop(ctx); },
            child: Column(children: [
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _selectedShape == s.$1 ? Colors.blueAccent.withValues(alpha: 0.5) : const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: _selectedShape == s.$1 ? Colors.blueAccent : Colors.white12)), child: Icon(s.$2, color: Colors.white70, size: 28)),
              const SizedBox(height: 6),
              Text(s.$3, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
            ]),
          )).toList()),
          const SizedBox(height: 16),
          Row(children: [
            Text('Filled', style: GoogleFonts.outfit(color: Colors.white54)),
            const Spacer(),
            Switch(value: _shapeFilled, activeColor: Colors.blueAccent, onChanged: (v) => setState(() => _shapeFilled = v)),
          ]),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // BRUSH PICKER SHEET
  // ══════════════════════════════════════════════════════════════════
  void _showBrushPickerSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final brushes = allBrushes.where((b) => b.category == _selectedBrushCategory || (_selectedBrushCategory == 'Recent' && b.category == 'Favorites') || (_selectedBrushCategory == 'New' && b.category == 'Favorites')).toList();
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: const BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Brush Library', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Row(children: [IconButton(icon: const Icon(Icons.add, color: Colors.white54), onPressed: () {}), IconButton(icon: const Icon(Icons.tune, color: Colors.white54), onPressed: () {})]),
            ])),
            const Divider(color: Colors.white12, height: 1),
            Expanded(child: Row(children: [
              // Categories
              Container(
                width: 130,
                decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white12))),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: brushCategories.length,
                  itemBuilder: (ctx, i) {
                    final cat = brushCategories[i];
                    final sel = cat == _selectedBrushCategory;
                    final icons = {'New': Icons.add, 'Favorites': Icons.favorite, 'Recent': Icons.access_time, 'Pencils': Icons.create, 'Pens': Icons.gesture, 'Calligraphy': Icons.water_drop_outlined, 'Markers': Icons.format_paint, 'Paint': Icons.color_lens_outlined, 'Watercolor': Icons.waves, 'Sprayers': Icons.blur_on, 'Chalks': Icons.cloud_outlined, 'Charcoals': Icons.change_history, 'Design': Icons.science_outlined, 'Fills': Icons.format_color_fill, 'Glow': Icons.lightbulb_outline};
                    return InkWell(
                      onTap: () { setSheet(() {}); setState(() => _selectedBrushCategory = cat); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        color: sel ? Colors.white.withValues(alpha: 0.5) : Colors.transparent,
                        child: Row(children: [
                          Icon(icons[cat] ?? Icons.brush, size: 16, color: cat == 'Favorites' ? Colors.pinkAccent : (sel ? Colors.white : Colors.white38)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(cat, style: GoogleFonts.outfit(color: sel ? Colors.white : Colors.white54, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              // Brushes
              Expanded(
                child: brushes.isEmpty
                    ? const Center(child: Text('No brushes', style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: brushes.length,
                        itemBuilder: (ctx, i) {
                          final b = brushes[i];
                          final isSel = b.id == _selectedBrushInfo.id;
                          return InkWell(
                            onTap: () {
                              setState(() { _selectedBrushInfo = b; _selectedBrushType = b.type; _strokeWidth = b.defaultSize; _strokeOpacity = b.defaultOpacity; _isEraser = false; _activeTool = DrawingTool.brush; });
                              setSheet(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: isSel ? Colors.blueAccent.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(14), border: Border.all(color: isSel ? Colors.blueAccent.withValues(alpha: 0.5) : Colors.transparent)),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(b.name, style: GoogleFonts.outfit(color: isSel ? Colors.white : Colors.white70, fontWeight: isSel ? FontWeight.bold : FontWeight.w500, fontSize: 15)),
                                  Icon(Icons.favorite, size: 14, color: b.category == 'Favorites' ? Colors.pinkAccent : Colors.transparent),
                                ]),
                                const SizedBox(height: 10),
                                SizedBox(height: 28, width: double.infinity, child: CustomPaint(painter: BrushPreviewPainter(brushType: b.type, baseColor: Colors.white, opacity: b.defaultOpacity, thickness: b.defaultSize))),
                              ]),
                            ),
                          );
                        },
                      ),
              ),
            ])),
          ]),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // COLOR PICKER
  // ══════════════════════════════════════════════════════════════════
  void _showColorPicker() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: Text('Select Color', style: GoogleFonts.outfit(color: Colors.white)),
      content: SingleChildScrollView(child: ColorPicker(pickerColor: _selectedColor, onColorChanged: (c) => setState(() => _selectedColor = c), pickerAreaHeightPercent: 0.7, labelTypes: const [])),
      actions: [TextButton(child: const Text('Done'), onPressed: () => Navigator.pop(ctx))],
    ));
  }
}
