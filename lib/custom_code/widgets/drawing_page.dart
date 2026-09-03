import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:ed_screen_recorder/ed_screen_recorder.dart';
import 'drawing_page_models.dart';
import 'drawing_page_painters.dart';

class DrawingPage extends StatefulWidget {
  final String? sessionPath;
  final double? canvasWidth;
  final double? canvasHeight;

  const DrawingPage({
    super.key, 
    this.sessionPath,
    this.canvasWidth,
    this.canvasHeight,
  });
  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> with TickerProviderStateMixin {
  final GlobalKey _canvasKey = GlobalKey();
  // final EdScreenRecorder _screenRecorder = EdScreenRecorder();

  // Layers
  final List<DrawingLayer> _layers = [];
  int _activeLayerIndex = 0;

  // Text & Image Overlays
  final List<TextOverlay> _textOverlays = [];
  final List<ImageOverlay> _imageOverlays = [];

  // Tool State
  DrawingTool _activeTool = DrawingTool.brush;
  bool _isEraser = false;
  BrushInfo _selectedBrushInfo = allBrushes[0];
  String _selectedBrushCategory = 'Favorites';
  BrushType _selectedBrushType = BrushType.pencil;
  Color _selectedColor = Colors.black;
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
  bool _isReplaying = false;
  bool _isLoadingSession = false;
  bool _showSavedIndicator = false;
  bool _isInteractingWithOverlay = false;
  List<String> _recentDrawingsPaths = [];
  Offset _sidebarOffset = const Offset(8, 0);
  String? _selectedOverlayId;
  Path? _lassoPath;
  List<DrawingPoint> _lassoPoints = [];
  
  String? _projectId;
  final String _selectedFont = 'Outfit';

  // Canvas
  final TransformationController _transformationController = TransformationController();
  int _pointerCount = 0;
  late double _canvasWidth;
  late double _canvasHeight;

  @override
  void initState() {
    super.initState();
    _canvasWidth = widget.canvasWidth ?? 3000;
    _canvasHeight = widget.canvasHeight ?? 3000;
    
    if (widget.sessionPath != null) {
      final fileName = widget.sessionPath!.split('/').last.split('\\').last;
      _projectId = fileName.replaceAll('sketch_', '').replaceAll('.json', '');
    } else {
      _projectId = DateTime.now().millisecondsSinceEpoch.toString();
    }
    
    _addLayer();
    _loadRecentDrawings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      _transformationController.value = Matrix4.identity()
        ..setTranslationRaw(-(_canvasWidth / 2) + size.width / 2, -(_canvasHeight / 2) + size.height / 2, 0);
      
      setState(() {
        _sidebarOffset = Offset(8, (size.height - 400) / 2);
      });
      if (widget.sessionPath != null) {
        _loadSession(widget.sessionPath!);
      } else {
        _checkLastSession();
      }
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
    _autoSave();
  }

  void _mergeDown(int index) {
    if (index <= 0) return;
    setState(() {
      _layers[index - 1].strokes.addAll(_layers[index].strokes);
      _layers.removeAt(index);
      _activeLayerIndex = index - 1;
    });
    _autoSave();
  }

  void _clearLayer() {
    setState(() {
    for (var layer in _layers) {
      layer.strokes.clear();
    }
    for (var layer in _layers) {
      layer.redoStack.clear();
    }
    });
    _autoSave();
  }

  // ── Drawing Logic ──
  void _handlePanStart(DragStartDetails details) {
    if (_pointerCount > 1 || _layers[_activeLayerIndex].isLocked || _isInteractingWithOverlay) return;
    
    final renderContext = _canvasKey.currentContext;
    if (renderContext == null) return;
    RenderBox box = renderContext.findRenderObject() as RenderBox;
    Offset pos = box.globalToLocal(details.globalPosition);

    if (_activeTool == DrawingTool.lasso) {
      setState(() {
        _lassoPoints = [DrawingPoint(pos, 1.0)];
        _lassoPath = Path()..moveTo(pos.dx, pos.dy);
      });
      return;
    }

    if (_activeTool == DrawingTool.transform) {
      // Check for overlay selection
      String? clickedId;
      for (final img in _imageOverlays.reversed) {
        if (Rect.fromLTWH(img.position.dx, img.position.dy, 300 * img.scale, 300 * img.scale).contains(pos)) {
          clickedId = img.id;
          break;
        }
      }
      if (clickedId == null) {
        for (final txt in _textOverlays.reversed) {
          if (Rect.fromLTWH(txt.position.dx, txt.position.dy, 200, 50).contains(pos)) {
            clickedId = txt.id;
            break;
          }
        }
      }
      setState(() => _selectedOverlayId = clickedId);
      return;
    }

    if (_activeTool == DrawingTool.shape) {
      setState(() { _shapeStart = pos; _shapeEnd = pos; });
      return;
    }
    if (_activeTool == DrawingTool.fillBucket) {
      _floodFill(pos);
      return;
    }
    if (_activeTool == DrawingTool.eyedropper) return;

    if (_selectedOverlayId != null) return; // Disable drawing when image selected

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

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_pointerCount > 1 || _isInteractingWithOverlay) return;
    final renderContext = _canvasKey.currentContext;
    if (renderContext == null) return;
    RenderBox box = renderContext.findRenderObject() as RenderBox;
    Offset pos = box.globalToLocal(details.globalPosition);

    if (_activeTool == DrawingTool.lasso) {
      setState(() {
        _lassoPoints.add(DrawingPoint(pos, 1.0));
        _lassoPath?.lineTo(pos.dx, pos.dy);
      });
      return;
    }

    if (_activeTool == DrawingTool.transform && _selectedOverlayId != null) {
      // Move selected overlay
      setState(() {
        try {
          final img = _imageOverlays.firstWhere((i) => i.id == _selectedOverlayId);
          img.position += details.delta;
        } catch (_) {
          try {
            final txt = _textOverlays.firstWhere((t) => t.id == _selectedOverlayId);
            txt.position += details.delta;
          } catch (_) {}
        }
      });
      return;
    }

    if (_activeTool == DrawingTool.shape) {
      setState(() => _shapeEnd = pos);
      return;
    }

    if (_selectedOverlayId != null) return;

    setState(() {
      _currentStroke?.points.add(DrawingPoint(pos, 1.0));
    });
  }

  Future<void> _floodFill(Offset startPos) async {
    try {
      setState(() {
        _layers[_activeLayerIndex].backgroundColor = _selectedColor;
      });
      _autoSave();
    } catch (e) {
      debugPrint("Fill error: $e");
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_activeTool == DrawingTool.lasso) {
      setState(() {
        _lassoPath = null;
        _lassoPoints = [];
      });
      // Lasso selection logic could be expanded here to select multiple objects
      return;
    }
    if (_activeTool == DrawingTool.shape && _shapeStart != null && _shapeEnd != null) {
      setState(() {
        _layers[_activeLayerIndex].strokes.add(DrawingStroke(
          color: _selectedColor,
          strokeWidth: _strokeWidth,
          points: [DrawingPoint(_shapeStart!, 1.0)],
          opacity: _strokeOpacity,
          brushType: _selectedBrushType,
          shapeType: _selectedShape,
          shapeEnd: _shapeEnd,
          isFilled: _shapeFilled,
        ));
        _shapeStart = null;
        _shapeEnd = null;
      });
      _autoSave();
      return;
    }
    if (_currentStroke != null) {
      setState(() {
        _layers[_activeLayerIndex].strokes.add(_currentStroke!);
        _currentStroke = null;
      });
      _autoSave();
    }
  }

  Future<void> _checkLastSession() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/current_session.json');
      if (await file.exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Last session found!', style: GoogleFonts.outfit()),
          backgroundColor: Color(0xFFFFFC00),
          action: SnackBarAction(label: 'RESUME', textColor: Colors.black, onPressed: _loadSession),
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      debugPrint("Error checking session: $e");
    }
  }

  Future<void> _autoSave() async {
    if (_projectId == null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final drawingDir = Directory('${dir.path}/saved_drawings');
      if (!await drawingDir.exists()) await drawingDir.create(recursive: true);

      final jsonFile = File('${drawingDir.path}/sketch_$_projectId.json');
      final data = {
        'layers': _layers.map((l) => l.toJson()).toList(),
        'textOverlays': _textOverlays.map((t) => t.toJson()).toList(),
        'imageOverlays': _imageOverlays.map((i) => i.toJson()).toList(),
        'canvasWidth': _canvasWidth,
        'canvasHeight': _canvasHeight,
        'ts': DateTime.now().millisecondsSinceEpoch,
      };
      await jsonFile.writeAsString(jsonEncode(data));
      
      final sessionFile = File('${dir.path}/current_session.json');
      await sessionFile.writeAsString(jsonEncode(data));

      _savePreviewThumbnail(drawingDir.path);
      
      if (mounted) {
        setState(() => _showSavedIndicator = true);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() => _showSavedIndicator = false);
          }
        });
      }
    } catch (e) { 
      debugPrint("AutoSave error: $e"); 
    }
  }

  Future<void> _savePreviewThumbnail(String drawingDirPath) async {
    try {
      RenderRepaintBoundary? boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      ui.Image image = await boundary.toImage(pixelRatio: 0.5);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final pngFile = File('$drawingDirPath/sketch_$_projectId.png');
        await pngFile.writeAsBytes(bytes);
      }
    } catch (e) {
      debugPrint("Thumbnail error: $e");
    }
  }

  Future<void> _loadSession([String? path]) async {
    try {
      File file;
      if (path != null) {
        file = File(path);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        file = File('${dir.path}/current_session.json');
      }
      if (!await file.exists()) return;
      
      if (mounted) setState(() => _isLoadingSession = true);
      final json = jsonDecode(await file.readAsString());
      
      final List layersJson = json['layers'] ?? [];
      final List textJson = json['textOverlays'] ?? [];
      final List imgsJson = json['imageOverlays'] ?? [];
      
      final List<DrawingLayer> loadedLayers = [];
      for (var lj in layersJson) {
        final layer = DrawingLayer.fromJson(lj);
        if (layer.imageBytes != null) {
          final ui.Codec codec = await ui.instantiateImageCodec(layer.imageBytes!);
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          layer.importedImage = frameInfo.image;
        }
        loadedLayers.add(layer);
      }

      if (mounted) {
        setState(() {
          _canvasWidth = json['canvasWidth']?.toDouble() ?? 3000;
          _canvasHeight = json['canvasHeight']?.toDouble() ?? 3000;
          _layers.clear();
          _layers.addAll(loadedLayers);
          if (_layers.isEmpty) {
            _layers.add(DrawingLayer(id: DateTime.now().millisecondsSinceEpoch.toString(), name: 'Layer 1'));
          }
          _textOverlays.clear();
          for (var tj in textJson) _textOverlays.add(TextOverlay.fromJson(tj));
          _imageOverlays.clear();
          for (var ij in imgsJson) _imageOverlays.add(ImageOverlay.fromJson(ij));
          _activeLayerIndex = 0;
          _isLoadingSession = false;
        });
      }
    } catch (e) {
      debugPrint("Load error: $e");
      if (mounted) setState(() => _isLoadingSession = false);
    }
  }

  Future<void> _replayDrawing() async {
    if (_isReplaying || _layers[_activeLayerIndex].strokes.isEmpty) return;
    final allStrokes = List<DrawingStroke>.from(_layers[_activeLayerIndex].strokes);
    setState(() {
      _layers[_activeLayerIndex].strokes.clear();
      _isReplaying = true;
    });
    for (final s in allStrokes) {
      if (!mounted || !_isReplaying) break;
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() { _layers[_activeLayerIndex].strokes.add(s); });
    }
    if (mounted) setState(() => _isReplaying = false);
  }

  Future<void> _loadRecentDrawings() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final drawingDir = Directory('${directory.path}/saved_drawings');
      if (await drawingDir.exists()) {
        final files = drawingDir.listSync();
        if (mounted) {
          setState(() {
            _recentDrawingsPaths = files.where((f) => f is File && f.path.endsWith('.png')).map((f) => f.path).toList()..sort((a, b) => b.compareTo(a));
          });
        }
      }
    } catch (e) {
      debugPrint("Load recent error: $e");
    }
  }

  Future<void> _saveImage() async {
    final settings = await _showSaveCustomizationDialog();
    if (settings == null) return;
    try {
      RenderRepaintBoundary? boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      ui.Image image = await boundary.toImage(pixelRatio: settings['pixelRatio']);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final dir = await getApplicationDocumentsDirectory();
        final drawingDir = Directory('${dir.path}/saved_drawings');
        if (!await drawingDir.exists()) await drawingDir.create(recursive: true);
        final file = File('${drawingDir.path}/sketch_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes);
        _loadRecentDrawings();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
      }
    } catch (e) {
      debugPrint("Save error: $e");
    }
  }

  Future<void> _exportImage() async {
     final settings = await _showSaveCustomizationDialog();
     if (settings == null) return;
     try {
       RenderRepaintBoundary? boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
       if (boundary == null) return;
       ui.Image image = await boundary.toImage(pixelRatio: settings['pixelRatio']);
       ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
       if (byteData != null) {
         final dir = await getTemporaryDirectory();
         final path = '${dir.path}/export_${DateTime.now().millisecondsSinceEpoch}.png';
         final file = await File(path).writeAsBytes(byteData.buffer.asUint8List());
         final xFile = XFile(file.path);
         await SharePlus.instance.share(ShareParams(
          files: [xFile],
          text: 'My drawing from Pocketmates',
        ));
       }
     } catch (e) {
       debugPrint("Export error: $e");
     }
  }

  Future<void> _importImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageOverlays.add(ImageOverlay(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bytes: bytes,
          position: Offset(_canvasWidth / 2 - 150, _canvasHeight / 2 - 150),
          scale: 1.0,
          rotation: 0.0,
        ));
        _selectedOverlayId = _imageOverlays.last.id;
      });
      _autoSave();
    } catch (e) {
      debugPrint("Import error: $e");
    }
  }

  void _addText() {
    final controller = TextEditingController();
    double tempFontSize = 40.0;
    Color tempColor = _selectedColor;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text('Add Text', style: GoogleFonts.outfit(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                style: GoogleFonts.outfit(color: Colors.white),
                decoration: const InputDecoration(hintText: 'Enter text...', hintStyle: TextStyle(color: Colors.white38)),
              ),
              Slider(value: tempFontSize, min: 10, max: 200, activeColor: Color(0xFFFFFC00), onChanged: (v) => setDialogState(() => tempFontSize = v)),
              TextButton(child: Container(width: 40, height: 20, color: tempColor), onPressed: () {
                showDialog(context: context, builder: (c) => AlertDialog(content: SingleChildScrollView(child: ColorPicker(pickerColor: tempColor, onColorChanged: (c) => setDialogState(() => tempColor = c)))));
              }),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() => _textOverlays.add(TextOverlay(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text: controller.text,
                    position: Offset(_canvasWidth / 2, _canvasHeight / 2),
                    color: tempColor,
                    fontSize: tempFontSize,
                    style: GoogleFonts.getFont(_selectedFont),
                  )));
                  _autoSave();
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add', style: TextStyle(color: Color(0xFFFFFC00))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Listener(
              onPointerDown: (_) => setState(() => _pointerCount++),
              onPointerUp: (_) => setState(() => _pointerCount = _pointerCount > 0 ? _pointerCount - 1 : 0),
              onPointerCancel: (_) => setState(() => _pointerCount = 0),
              child: InteractiveViewer(
                transformationController: _transformationController,
                panEnabled: _pointerCount > 1,
                scaleEnabled: _pointerCount > 1,
                minScale: 0.05,
                maxScale: 30.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                constrained: false,
                child: Container(
                  width: _canvasWidth,
                  height: _canvasHeight,
                  decoration: BoxDecoration(color: _canvasBgColor),
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: GestureDetector(
                      onPanStart: _handlePanStart,
                      onPanUpdate: _handlePanUpdate,
                      onPanEnd: _handlePanEnd,
                      child: Stack(
                        children: [
                          Container(color: _canvasBgColor),
                          if (_showGrid) CustomPaint(painter: GridPainter(), size: Size(_canvasWidth, _canvasHeight)),
                          ..._imageOverlays.map((img) => Positioned(
                            left: img.position.dx, top: img.position.dy,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedOverlayId = img.id);
                              },
                              child: Transform.rotate(
                                angle: img.rotation,
                                child: Transform.scale(
                                  scale: img.scale,
                                  child: Container(
                                    decoration: BoxDecoration(border: _selectedOverlayId == img.id ? Border.all(color: Color(0xFFFFFC00), width: 2) : null),
                                    child: Image.memory(img.bytes, width: 300, fit: BoxFit.contain),
                                  ),
                                ),
                              ),
                            ),
                          )),
                          ..._layers.map((layer) {
                            if (!layer.isVisible) return const SizedBox.shrink();
                            return Opacity(
                              opacity: layer.opacity,
                              child: CustomPaint(
                                painter: LayerPainter(strokes: layer.strokes, activeStroke: (_layers.indexOf(layer) == _activeLayerIndex) ? _currentStroke : null),
                                size: Size(_canvasWidth, _canvasHeight),
                              ),
                            );
                          }),
                          if (_activeTool == DrawingTool.lasso && _lassoPath != null)
                            CustomPaint(
                              painter: LassoPainter(points: _lassoPoints),
                              size: Size(_canvasWidth, _canvasHeight),
                            ),
                          
                          if (_selectedOverlayId != null) _buildSelectionHandles(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          Positioned(
            left: _sidebarOffset.dx, top: _sidebarOffset.dy,
            child: GestureDetector(
              onScaleUpdate: (d) {
                if (d.pointerCount == 1) {
                   setState(() {
                     _sidebarOffset = Offset(
                       (_sidebarOffset.dx + d.focalPointDelta.dx).clamp(0, MediaQuery.of(context).size.width - 60),
                       (_sidebarOffset.dy + d.focalPointDelta.dy).clamp(0, MediaQuery.of(context).size.height - 400),
                     );
                   });
                }
              },
              child: _buildLeftSidebar(theme),
            ),
          ),

          Positioned(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, child: _buildTopBar(theme)),

          if (_showSavedIndicator) Positioned(bottom: 100, left: 0, right: 0, child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: const Text('Saved', style: TextStyle(color: Colors.white, fontSize: 10))))),

          if (_showLayersPanel) Positioned(top: 100, right: 10, child: _buildLayersPanel(theme)),
          
          // Brush Settings
          if (_showBrushSettings)
            Positioned(
              left: _sidebarOffset.dx + 66, top: _sidebarOffset.dy,
              child: _buildBrushSettingsPanel(theme),
            ),

          // Recent Panel
          if (_showRecentPanel)
             Positioned(left: _sidebarOffset.dx + 66, top: 100, bottom: 100, width: MediaQuery.of(context).size.shortestSide > 600 ? 320 : 250, child: _buildRecentPanel(theme)),

          // Recording indicator
          if (_isRecording)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60, left: 0, right: 0,
              child: Center(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1,1), end: const Offset(1.2,1.2), duration: 500.ms).then().scale(begin: const Offset(1.2,1.2), end: const Offset(1,1)),
                  const SizedBox(width: 8),
                  Text('Recording', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                ]),
              )),
            ),
          
          if (_isLoadingSession) Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildSelectionHandles() {
    dynamic overlay;
    try {
      overlay = _imageOverlays.firstWhere((i) => i.id == _selectedOverlayId);
    } catch (_) {
      try {
        overlay = _textOverlays.firstWhere((t) => t.id == _selectedOverlayId);
      } catch (_) {
        return const SizedBox.shrink();
      }
    }
    final bool isImage = overlay is ImageOverlay;
    final double scale = isImage ? overlay.scale : 1.0;
    final double rotation = overlay.rotation;
    final Size size = isImage ? const Size(300, 300) : const Size(200, 50);

    return Positioned(
      left: overlay.position.dx, top: overlay.position.dy,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: size.width * (isImage ? scale : 1.0),
          height: size.height * (isImage ? scale : 1.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onPanStart: (_) => setState(() => _isInteractingWithOverlay = true),
                onPanUpdate: (d) => setState(() => overlay.position += d.delta), 
                onPanEnd: (_) => setState(() { _isInteractingWithOverlay = false; _autoSave(); }), 
                child: Container(color: Colors.transparent)
              ),
              _handle(Alignment.topLeft, (d) => setState(() { if(isImage) overlay.scale = (overlay.scale - d.delta.dx/300).clamp(0.1, 5.0); else overlay.fontSize = (overlay.fontSize - d.delta.dx).clamp(10, 200); })),
              _handle(Alignment.topRight, (d) => setState(() => overlay.rotation += d.delta.dx/100)),
              _handle(Alignment.bottomRight, (d) => setState(() { if(isImage) overlay.scale = (overlay.scale + d.delta.dx/300).clamp(0.1, 5.0); else overlay.fontSize = (overlay.fontSize + d.delta.dx).clamp(10, 200); })),
              Positioned(
                right: -10,
                top: -10,
                child: GestureDetector(
                  onTap: () => setState(() {
                    if (isImage) {
                      _imageOverlays.remove(overlay);
                    } else {
                      _textOverlays.remove(overlay);
                    }
                    _selectedOverlayId = null;
                    _autoSave();
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handle(Alignment align, Function(DragUpdateDetails) onDrag) => Align(
    alignment: align, 
    child: GestureDetector(
      onPanStart: (_) => setState(() => _isInteractingWithOverlay = true),
      onPanUpdate: (d) => onDrag(d), 
      onPanEnd: (_)=> setState(() { _isInteractingWithOverlay = false; _autoSave(); }), 
      child: Container(width:24, height:24, decoration:BoxDecoration(color:Color(0xFFFFFC00), border:Border.all(color:Colors.white, width:2.0), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]))
    )
  );

  Widget _buildLeftSidebar(FlutterFlowTheme theme) {
    return Container(
      width: 52, padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A).withValues(alpha: 0.95), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.white10), 
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)]
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _sideBtn(Icons.brush, _activeTool == DrawingTool.brush && !_isEraser, () {
          if (_activeTool == DrawingTool.brush && !_isEraser) {
            _showBrushPickerSheet();
          } else {
            setState(() { _activeTool = DrawingTool.brush; _isEraser = false; _selectedOverlayId = null; });
          }
        }),
        _sideBtn(Icons.auto_fix_high, _activeTool == DrawingTool.eraser || _isEraser, () => setState(() { _isEraser = true; _activeTool = DrawingTool.eraser; _selectedOverlayId = null; })),
        _sideBtn(Icons.move_up_rounded, _activeTool == DrawingTool.transform, () => setState(() => _activeTool = DrawingTool.transform)),
        _sideBtn(Icons.gesture_rounded, _activeTool == DrawingTool.lasso, () => setState(() => _activeTool = DrawingTool.lasso)),
        _sideBtn(Icons.crop_square, _activeTool == DrawingTool.shape, () {
          if (_activeTool == DrawingTool.shape) {
            _showShapePicker();
          } else {
            setState(() { _activeTool = DrawingTool.shape; _selectedOverlayId = null; });
          }
        }),
        _sideBtn(Icons.text_fields, false, _addText),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showColorPicker, 
          child: Container(
            width: 28, height: 28, 
            decoration: BoxDecoration(
              color: _selectedColor, 
              shape: BoxShape.circle, 
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [BoxShadow(color: _selectedColor.withValues(alpha: 0.5), blurRadius: 8)]
            )
          )
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() => _showBrushSettings = !_showBrushSettings),
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white54, width: 1.5)),
            child: Center(child: Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: _strokeOpacity)))),
          ),
        ),
        const SizedBox(height: 8),
        _sideBtn(Icons.image_outlined, false, _importImage),
        _sideBtn(Icons.more_horiz, false, _showOptionsSheet),
      ]),
    );
  }

  Widget _sideBtn(IconData icon, bool active, VoidCallback onTap) => IconButton(icon: Icon(icon, color: active ? Color(0xFFFFFC00) : Colors.white30, size: 22), onPressed: onTap);

  Future<void> _convertTo1of1Avatar() async {
    try {
      HapticFeedback.heavyImpact();
      RenderRepaintBoundary? boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final base64Image = 'data:image/png;base64,${base64Encode(byteData.buffer.asUint8List())}';
      final dnaHash = '0xHAND-${DateTime.now().millisecondsSinceEpoch % 1000000}';

      final user = SupaFlow.client.auth.currentUser;
      if (user != null) {
        // Save to avatar_config only so user's real profile photo remains untouched
        await SupaFlow.client.from('profile').update({
          'avatar_config': {
            'species': 'hand_drawn_masterpiece',
            'dnaHash': dnaHash,
            'rarityTier': 'Mythic 1-of-1 Hand-Drawn',
            'artStyle': 'sketch',
            'customDrawingImage': base64Image,
          },
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', user.id);

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('profile_cache_${user.id}');
          await prefs.remove('cached_profile_${user.id}');
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.yellow),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🎉 Converted hand drawing to your official 1-of-1 NFT Profile Avatar!',
                    style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFFFC00),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Avatar convert error: $e");
    }
  }

  Widget _buildTopBar(FlutterFlowTheme theme) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    _headerBtn(Icons.home, () => Navigator.pop(context)),
    Row(children: [
      _headerBtn(Icons.face_retouching_natural_rounded, _convertTo1of1Avatar),
      const SizedBox(width: 8),
      _headerBtn(Icons.save_outlined, _saveImage),
      const SizedBox(width: 8),
      _headerBtn(Icons.layers_outlined, () => setState(() => _showLayersPanel = !_showLayersPanel)),
    ]),
  ]);

  Widget _headerBtn(IconData icon, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle), child: Icon(icon, color: Colors.white70, size: 20)));

  void _deleteLayer(int index) {
    if (_layers.length <= 1) return;
    setState(() {
      _layers.removeAt(index);
      if (_activeLayerIndex >= _layers.length) _activeLayerIndex = _layers.length - 1;
    });
    _autoSave();
  }

  Widget _buildLayersPanel(FlutterFlowTheme theme) => Container(
    width: 240, 
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
    margin: const EdgeInsets.only(right: 8),
    decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10), boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15)]),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Layers', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.add, color: Color(0xFFFFFC00), size: 20), onPressed: _addLayer),
        ]),
      ),
      const Divider(color: Colors.white10, height: 1),
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _layers.length,
          itemBuilder: (context, index) {
            final layer = _layers[(_layers.length - 1) - index];
            final actualIdx = (_layers.length - 1) - index;
            final isActive = actualIdx == _activeLayerIndex;
            return GestureDetector(
              onLongPress: () => _showLayerOptions(actualIdx),
              child: Container(
                color: isActive ? Color(0xFFFFFC00).withValues(alpha: 0.1) : Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      onTap: () => setState(() => _activeLayerIndex = actualIdx),
                      dense: true,
                      leading: IconButton(
                        icon: Icon(layer.isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70, size: 18),
                        onPressed: () => setState(() => layer.isVisible = !layer.isVisible),
                      ),
                      title: Text(layer.name, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(layer.isLocked ? Icons.lock : Icons.lock_open, color: Colors.white38, size: 14),
                          const SizedBox(width: 8),
                          if (isActive) Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFFFFC00), shape: BoxShape.circle)),
                        ],
                      ),
                    ),
                    if (isActive)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(50, 0, 16, 8),
                        child: Row(
                          children: [
                            const Icon(Icons.opacity, color: Colors.white38, size: 14),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
                                child: Slider(
                                  value: layer.opacity,
                                  min: 0, max: 1,
                                  activeColor: Color(0xFFFFFC00),
                                  onChanged: (v) => setState(() => layer.opacity = v),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ]),
  );

  void _showLayerOptions(int index) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_layers[index].name, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.opacity, color: Colors.white54, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Slider(value: _layers[index].opacity, min: 0, max: 1, activeColor: Color(0xFFFFFC00), onChanged: (v) => setState(() => _layers[index].opacity = v))),
            Text('${(_layers[index].opacity * 100).toInt()}%', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
          const Divider(color: Colors.white10),
          _layerOption(Icons.copy, 'Duplicate', () { _duplicateLayer(index); Navigator.pop(ctx); }),
          _layerOption(Icons.merge, 'Merge Down', () { _mergeDown(index); Navigator.pop(ctx); }),
          _layerOption(Icons.lock_outline, _layers[index].isLocked ? 'Unlock' : 'Lock', () { setState(() => _layers[index].isLocked = !_layers[index].isLocked); Navigator.pop(ctx); }),
          _layerOption(Icons.cleaning_services, 'Clear Content', () { setState(() { _activeLayerIndex = index; }); _clearLayer(); Navigator.pop(ctx); }),
          if (_layers.length > 1) _layerOption(Icons.delete_outline, 'Delete Layer', () { _deleteLayer(index); Navigator.pop(ctx); }, color: Colors.redAccent),
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

  Widget _buildBrushSettingsPanel(FlutterFlowTheme theme) {
    return Container(
      width: 220, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 15)]),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Brush Settings', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          GestureDetector(onTap: () => setState(() => _showBrushSettings = false), child: const Icon(Icons.close, color: Colors.white38, size: 18)),
        ]),
        const SizedBox(height: 16),
        Text('Size: ${_strokeWidth.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Slider(value: _strokeWidth, min: 0.5, max: 100, activeColor: Color(0xFFFFFC00), onChanged: (v) => setState(() => _strokeWidth = v)),
        Text('Opacity: ${(_strokeOpacity * 100).toInt()}%', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Slider(value: _strokeOpacity, min: 0.01, max: 1.0, activeColor: Color(0xFFFFFC00), onChanged: (v) => setState(() => _strokeOpacity = v)),
        if (_isEraser) ...[
          Text('Eraser: ${_eraserWidth.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Slider(value: _eraserWidth, min: 5, max: 200, activeColor: Colors.redAccent, onChanged: (v) => setState(() => _eraserWidth = v)),
        ],
        const SizedBox(height: 8),
        Row(children: [
          const Text('Grid', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const Spacer(),
          Switch(value: _showGrid, activeThumbColor: Color(0xFFFFFC00), onChanged: (v) => setState(() => _showGrid = v)),
        ]),
      ]),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildRecentPanel(FlutterFlowTheme theme) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 25)]),
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Gallery', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          GestureDetector(onTap: () => setState(() => _showRecentPanel = false), child: const Icon(Icons.close, color: Colors.white38, size: 18)),
        ])),
        const Divider(color: Colors.white12, height: 1),
        Expanded(
          child: _recentDrawingsPaths.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.history_toggle_off, color: Colors.white24, size: 36), const SizedBox(height: 8), Text('Empty Gallery', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13))]))
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
          _headerBtn(Icons.share_rounded, () async {
            await SharePlus.instance.share(ShareParams(
              files: [XFile(path)],
              text: 'PocketMates Sketch',
            ));
          }),
          const SizedBox(width: 16),
          _headerBtn(Icons.delete_outline_rounded, () async { 
            await File(path).delete(); 
            _loadRecentDrawings(); 
            if (ctx.mounted) Navigator.pop(ctx); 
          }),
        ]),
      ]),
    ));
  }

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
              Text('Professional Brushes', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(ctx)),
            ])),
            const Divider(color: Colors.white12, height: 1),
            Expanded(child: Row(children: [
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
                        color: sel ? Color(0xFFFFFC00).withValues(alpha: 0.1) : Colors.transparent,
                        child: Row(children: [
                          Icon(icons[cat] ?? Icons.brush, size: 16, color: cat == 'Favorites' ? Colors.pinkAccent : (sel ? Color(0xFFFFFC00) : Colors.white38)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(cat, style: GoogleFonts.outfit(color: sel ? Color(0xFFFFFC00) : Colors.white54, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: brushes.isEmpty
                    ? const Center(child: Text('No brushes found', style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: brushes.length,
                        itemBuilder: (ctx, i) {
                          final b = brushes[i];
                          final isSel = b.id == _selectedBrushInfo.id;
                          return InkWell(
                            onTap: () {
                              setState(() { _selectedBrushInfo = b; _selectedBrushType = b.type; _strokeWidth = b.defaultSize; _strokeOpacity = b.defaultOpacity; _isEraser = false; _activeTool = DrawingTool.brush; });
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: isSel ? Color(0xFFFFFC00).withValues(alpha: 0.1) : Colors.white10, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSel ? Color(0xFFFFFC00) : Colors.transparent)),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(b.name, style: GoogleFonts.outfit(color: isSel ? Color(0xFFFFFC00) : Colors.white70, fontWeight: isSel ? FontWeight.bold : FontWeight.w500, fontSize: 15)),
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
          Text('Select Shape', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(spacing: 16, runSpacing: 16, children: shapes.map((s) => GestureDetector(
            onTap: () { setState(() => _selectedShape = s.$1); Navigator.pop(ctx); },
            child: Column(children: [
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _selectedShape == s.$1 ? Color(0xFFFFFC00).withValues(alpha: 0.2) : const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: _selectedShape == s.$1 ? Color(0xFFFFFC00) : Colors.white12)), child: Icon(s.$2, color: Colors.white70, size: 28)),
              const SizedBox(height: 6),
              Text(s.$3, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
            ]),
          )).toList()),
          const SizedBox(height: 20),
          Row(children: [
            Text('Fill Shape', style: GoogleFonts.outfit(color: Colors.white54)),
            const Spacer(),
            Switch(value: _shapeFilled, activeThumbColor: Color(0xFFFFFC00), onChanged: (v) => setState(() => _shapeFilled = v)),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: Text('Palette', style: GoogleFonts.outfit(color: Colors.white)),
      content: SingleChildScrollView(child: ColorPicker(pickerColor: _selectedColor, onColorChanged: (c) => setState(() => _selectedColor = c), pickerAreaHeightPercent: 0.7, labelTypes: const [])),
      actions: [TextButton(child: const Text('Select'), onPressed: () => Navigator.pop(ctx))],
    ));
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('Tools & Actions', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 28),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _optBtn(Icons.add_photo_alternate_outlined, 'New', () { Navigator.pop(ctx); _newCanvas(); }),
            _optBtn(Icons.photo_library_outlined, 'Gallery', () { Navigator.pop(ctx); setState(() => _showRecentPanel = true); }),
            _optBtn(Icons.save_outlined, 'Save', () { Navigator.pop(ctx); _saveImage(); }),
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _optBtn(Icons.file_upload_outlined, 'Import', () { Navigator.pop(ctx); _importImage(); }),

            _optBtn(Icons.ios_share_rounded, 'Export', () { Navigator.pop(ctx); _exportImage(); }),
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _optBtn(Icons.public, 'Explore', () => Navigator.pop(ctx)),
            _optBtn(Icons.school_outlined, 'Learn', () => Navigator.pop(ctx)),
            _optBtn(Icons.settings_outlined, 'App Settings', () { Navigator.pop(ctx); _showSettingsSheet(); }),
          ]),
        ]),
      ),
    );
  }

  void _newCanvas() {
    setState(() {
      _layers.clear();
      _layers.add(DrawingLayer(id: 'bg', name: 'Background'));
      _activeLayerIndex = 0;
      _canvasBgColor = Colors.white;
      _projectId = DateTime.now().millisecondsSinceEpoch.toString();
    });
  }

  Widget _optBtn(IconData icon, String label, VoidCallback onTap, {bool highlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: highlight ? Colors.red.withValues(alpha: 0.2) : const Color(0xFF1A1A1A), border: Border.all(color: highlight ? Colors.red : Colors.white12), shape: BoxShape.circle), child: Icon(icon, color: highlight ? Colors.red : Colors.white70, size: 24)),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12)),
      ]),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Preferences', style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ListTile(leading: const Icon(Icons.grid_3x3, color: Colors.white54), title: Text('Canvas Grid', style: GoogleFonts.outfit(color: Colors.white70)), trailing: Switch(value: _showGrid, activeThumbColor: Color(0xFFFFFC00), onChanged: (v) => setState(() => _showGrid = v))),
          ListTile(leading: const Icon(Icons.format_paint, color: Colors.white54), title: Text('Paper Texture', style: GoogleFonts.outfit(color: Colors.white70)), trailing: Container(width: 28, height: 28, decoration: BoxDecoration(color: _canvasBgColor, shape: BoxShape.circle, border: Border.all(color: Colors.white24))), onTap: () { Navigator.pop(ctx); _showCanvasBgPicker(); }),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showCanvasBgPicker() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: Text('Canvas Background', style: GoogleFonts.outfit(color: Colors.white)),
      content: SingleChildScrollView(child: ColorPicker(pickerColor: _canvasBgColor, onColorChanged: (c) => setState(() => _canvasBgColor = c), labelTypes: const [])),
      actions: [TextButton(child: const Text('OK'), onPressed: () => Navigator.pop(ctx))],
    ));
  }

  Future<Map<String, dynamic>?> _showSaveCustomizationDialog() async {
    double ratio = 2.0;
    return showDialog<Map<String, dynamic>>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Colors.black,
      title: const Text('Save Quality', style: TextStyle(color: Colors.white)),
      content: StatefulBuilder(builder: (c, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
        Slider(value: ratio, min: 1, max: 5, activeColor: Color(0xFFFFFC00), onChanged: (v) => setS(() => ratio = v)),
        Text('${ratio.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.white)),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, {'pixelRatio': ratio}), child: const Text('Save'))],
    ));
  }
}

