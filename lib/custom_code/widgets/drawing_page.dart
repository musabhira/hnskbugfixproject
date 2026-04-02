import 'dart:io';
import 'dart:convert';
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
import 'package:ed_screen_recorder/ed_screen_recorder.dart';
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
  final EdScreenRecorder _screenRecorder = EdScreenRecorder();

  // Layers
  final List<DrawingLayer> _layers = [];
  int _activeLayerIndex = 0;

  // Text & Image Overlays
  final List<TextOverlay> _textOverlays = [];
  final List<ImageOverlay> _imageOverlays = [];

  // Tool State
  DrawingTool _activeTool = DrawingTool.brush;
  bool _isEraser = false;
  BrushType _selectedBrushType = BrushType.pen;
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
  bool _isRecording = false;
  bool _isReplaying = false;
  bool _isLoadingSession = false;
  bool _showSavedIndicator = false;
  SymmetryMode _symmetryMode = SymmetryMode.none;
  List<String> _recentDrawingsPaths = [];
  Offset _sidebarOffset = const Offset(8, 0);
  String? _selectedOverlayId;
  
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

  void _clearLayer() {
    setState(() {
      _layers[_activeLayerIndex].strokes.clear();
      _layers[_activeLayerIndex].redoStack.clear();
    });
    _autoSave();
  }

  // ── Drawing Logic ──
  void _handlePanStart(DragStartDetails details) {
    if (_pointerCount > 1 || _layers[_activeLayerIndex].isLocked) return;
    final renderContext = _canvasKey.currentContext;
    if (renderContext == null) return;
    RenderBox box = renderContext.findRenderObject() as RenderBox;
    Offset pos = box.globalToLocal(details.globalPosition);

    if (_activeTool == DrawingTool.shape) {
      setState(() { _shapeStart = pos; _shapeEnd = pos; });
      return;
    }
    if (_activeTool == DrawingTool.fillBucket) {
      _floodFill(pos);
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

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_pointerCount > 1) return;
    final renderContext = _canvasKey.currentContext;
    if (renderContext == null) return;
    RenderBox box = renderContext.findRenderObject() as RenderBox;
    Offset pos = box.globalToLocal(details.globalPosition);

    if (_activeTool == DrawingTool.shape) {
      setState(() => _shapeEnd = pos);
      return;
    }

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
          backgroundColor: Colors.amber,
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

  void _undo() {
    setState(() {
      final layer = _layers[_activeLayerIndex];
      if (layer.strokes.isNotEmpty) layer.redoStack.add(layer.strokes.removeLast());
    });
    _autoSave();
  }

  void _redo() {
    setState(() {
      final layer = _layers[_activeLayerIndex];
      if (layer.redoStack.isNotEmpty) layer.strokes.add(layer.redoStack.removeLast());
    });
    _autoSave();
  }

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        final RecordOutput result = await _screenRecorder.stopRecord();
        setState(() => _isRecording = false);
        if (result.success == true && mounted) {
           Share.shareXFiles([XFile(result.file.path)]);
        }
      } else {
        final size = MediaQuery.of(context).size;
        final dir = await getTemporaryDirectory();
        final result = await _screenRecorder.startRecordScreen(
          fileName: "Drawing_${DateTime.now().millisecondsSinceEpoch}",
          dirPathToSave: dir.path,
          width: size.width.toInt(),
          height: size.height.toInt(),
          audioEnable: false,
        );
        if (result.success == true) setState(() => _isRecording = true);
      }
    } catch (e) {
      debugPrint("Recording error: $e");
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
         await File(path).writeAsBytes(byteData.buffer.asUint8List());
         await Share.shareXFiles([XFile(path)]);
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

  void _newCanvas() {
    setState(() {
      _layers.clear();
      _textOverlays.clear();
      _imageOverlays.clear();
      _addLayer();
    });
    _autoSave();
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
              Slider(value: tempFontSize, min: 10, max: 200, activeColor: Colors.amber, onChanged: (v) => setDialogState(() => tempFontSize = v)),
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
              child: const Text('Add', style: TextStyle(color: Colors.amber)),
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
                  width: _canvasWidth,
                  height: _canvasHeight,
                  decoration: BoxDecoration(color: _canvasBgColor),
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: Stack(
                      children: [
                        Container(color: _canvasBgColor),
                        ..._imageOverlays.map((img) => Positioned(
                          left: img.position.dx, top: img.position.dy,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedOverlayId = img.id),
                            child: Transform.rotate(
                              angle: img.rotation,
                              child: Transform.scale(
                                scale: img.scale,
                                child: Container(
                                  decoration: BoxDecoration(border: _selectedOverlayId == img.id ? Border.all(color: Colors.amber, width: 2) : null),
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
                        if (_activeTool == DrawingTool.shape && _shapeStart != null && _shapeEnd != null)
                          CustomPaint(painter: ShapePreviewPainter(shape: _selectedShape, start: _shapeStart!, end: _shapeEnd!, color: _selectedColor, strokeWidth: _strokeWidth, filled: _shapeFilled), size: Size(_canvasWidth, _canvasHeight)),
                        
                        if (_pointerCount <= 1)
                          GestureDetector(
                            onPanStart: _handlePanStart,
                            onPanUpdate: _handlePanUpdate,
                            onPanEnd: _handlePanEnd,
                            child: Container(color: Colors.transparent),
                          ),

                        ..._textOverlays.map((t) => Positioned(
                          left: t.position.dx, top: t.position.dy,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedOverlayId = t.id),
                            child: Transform.rotate(
                              angle: t.rotation,
                              child: Container(
                                decoration: BoxDecoration(border: _selectedOverlayId == t.id ? Border.all(color: Colors.amber, width: 2) : null),
                                child: Text(t.text, style: GoogleFonts.getFont(_selectedFont, color: t.color, fontSize: t.fontSize)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_selectedOverlayId != null) _buildSelectionHandles(),
                      ],
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
              GestureDetector(onPanUpdate: (d) => setState(() => overlay.position += d.delta), onPanEnd: (_) => _autoSave(), child: Container(color: Colors.transparent)),
              _handle(Alignment.topLeft, (d) => setState(() { if(isImage) overlay.scale = (overlay.scale - d.delta.dx/300).clamp(0.1, 5.0); else overlay.fontSize = (overlay.fontSize - d.delta.dx).clamp(10, 200); })),
              _handle(Alignment.topRight, (d) => setState(() => overlay.rotation += d.delta.dx/100)),
              _handle(Alignment.bottomRight, (d) => setState(() { if(isImage) overlay.scale = (overlay.scale + d.delta.dx/300).clamp(0.1, 5.0); else overlay.fontSize = (overlay.fontSize + d.delta.dx).clamp(10, 200); })),
              Positioned(right:-10, top:-10, child: GestureDetector(onTap: () => setState(() { if(isImage)_imageOverlays.remove(overlay); else _textOverlays.remove(overlay); _selectedOverlayId=null; _autoSave(); }), child: Container(padding:const EdgeInsets.all(4), decoration:const BoxDecoration(color:Colors.red, shape:BoxShape.circle), child:const Icon(Icons.close, color:Colors.white, size:12)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handle(Alignment align, Function(DragUpdateDetails) onDrag) => Align(alignment: align, child: GestureDetector(onPanUpdate: onDrag, onPanEnd: (_)=>_autoSave(), child: Container(width:18, height:18, decoration:BoxDecoration(color:Colors.amber, border:Border.all(color:Colors.white, width:1.5), borderRadius:BorderRadius.circular(4)))));

  Widget _buildLeftSidebar(FlutterFlowTheme theme) {
    return Container(
      width: 52, padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _sideBtn(Icons.brush, _activeTool == DrawingTool.brush && !_isEraser, () => setState(() { _activeTool = DrawingTool.brush; _isEraser = false; })),
        _sideBtn(Icons.auto_fix_high, _isEraser, () => setState(() { _isEraser = true; })),
        _sideBtn(Icons.crop_square, _activeTool == DrawingTool.shape, () => setState(() => _activeTool = DrawingTool.shape)),
        _sideBtn(Icons.text_fields, false, _addText),
        const SizedBox(height: 8),
        GestureDetector(onTap: _showColorPicker, child: Container(width: 24, height: 24, decoration: BoxDecoration(color: _selectedColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
        const SizedBox(height: 8),
        _sideBtn(Icons.image_outlined, false, _importImage),
        _sideBtn(Icons.more_horiz, false, _showOptionsSheet),
      ]),
    );
  }

  Widget _sideBtn(IconData icon, bool active, VoidCallback onTap) => IconButton(icon: Icon(icon, color: active ? Colors.amber : Colors.white30, size: 22), onPressed: onTap);

  Widget _buildTopBar(FlutterFlowTheme theme) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    _headerBtn(Icons.home, () => Navigator.pop(context)),
    Row(children: [
      _headerBtn(Icons.save_outlined, _saveImage),
      const SizedBox(width: 8),
      _headerBtn(Icons.layers_outlined, () => setState(() => _showLayersPanel = !_showLayersPanel)),
    ]),
  ]);

  Widget _headerBtn(IconData icon, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle), child: Icon(icon, color: Colors.white70, size: 20)));

  Widget _buildLayersPanel(FlutterFlowTheme theme) => Container(
    width: 60, decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: _addLayer),
      const Divider(color: Colors.white10),
      ..._layers.asMap().entries.map((e) => GestureDetector(
        onTap: () => setState(() => _activeLayerIndex = e.key),
        child: Container(margin: const EdgeInsets.all(4), height: 40, decoration: BoxDecoration(color: e.key == _activeLayerIndex ? Colors.amber.withValues(alpha: 0.2) : Colors.white10, borderRadius: BorderRadius.circular(4), border: Border.all(color: e.key == _activeLayerIndex ? Colors.amber : Colors.transparent))),
      )),
    ]),
  );

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (c) => setState(() => _selectedColor = c),
          ),
        ),
      ),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.refresh, color: Colors.white), title: const Text('New Canvas', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _newCanvas(); }),
          ListTile(leading: const Icon(Icons.delete_sweep, color: Colors.white), title: const Text('Clear Layer', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _clearLayer(); }),
          ListTile(leading: const Icon(Icons.undo, color: Colors.white), title: const Text('Undo', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _undo(); }),
          ListTile(leading: const Icon(Icons.redo, color: Colors.white), title: const Text('Redo', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _redo(); }),
          ListTile(leading: const Icon(Icons.replay, color: Colors.white), title: const Text('Replay', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _replayDrawing(); }),
          ListTile(leading: const Icon(Icons.videocam, color: Colors.white), title: const Text('Record Screen', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _toggleRecording(); }),
          ListTile(leading: const Icon(Icons.share, color: Colors.white), title: const Text('Export & Share', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _exportImage(); }),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _showSaveCustomizationDialog() async {
    double ratio = 2.0;
    return showDialog<Map<String, dynamic>>(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Colors.black,
      title: const Text('Save Quality', style: TextStyle(color: Colors.white)),
      content: StatefulBuilder(builder: (c, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
        Slider(value: ratio, min: 1, max: 5, activeColor: Colors.amber, onChanged: (v) => setS(() => ratio = v)),
        Text('${ratio.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.white)),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, {'pixelRatio': ratio}), child: const Text('Save'))],
    ));
  }
}
