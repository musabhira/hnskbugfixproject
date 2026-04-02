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
  bool _isReplaying = false;
  bool _isLoadingSession = false;
  bool _showSavedIndicator = false;
  SymmetryMode _symmetryMode = SymmetryMode.none;
  List<String> _recentDrawingsPaths = [];
  Offset _sidebarOffset = const Offset(8, 0);
  double _sidebarRotation = 0.0;
  double _sidebarScale = 1.0;
  double _lastRotation = 0.0;
  double _lastScale = 1.0;
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
      
      // Center sidebar vertically
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
    _autoSave();
  }

  // ── Drawing Logic ──
  void _onPanStart(DragStartDetails details) {
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

  void _onPanUpdate(DragUpdateDetails details) {
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
      if (_symmetryMode != SymmetryMode.none) {
        _applySymmetry(pos);
      }
    });
  }

  void _applySymmetry(Offset pos) {
    if (_symmetryMode == SymmetryMode.horizontal) {
      final symX = _canvasWidth + (_canvasWidth - pos.dx);
      _currentStroke?.points.add(DrawingPoint(Offset(symX, pos.dy), 1.0));
    } else if (_symmetryMode == SymmetryMode.vertical) {
      final symY = _canvasHeight + (_canvasHeight - pos.dy);
      _currentStroke?.points.add(DrawingPoint(Offset(pos.dx, symY), 1.0));
    } else if (_symmetryMode == SymmetryMode.quad) {
      final symX = _canvasWidth + (_canvasWidth - pos.dx);
      final symY = _canvasHeight + (_canvasHeight - pos.dy);
      _currentStroke?.points.add(DrawingPoint(Offset(symX, pos.dy), 1.0));
      _currentStroke?.points.add(DrawingPoint(Offset(pos.dx, symY), 1.0));
      _currentStroke?.points.add(DrawingPoint(Offset(symX, symY), 1.0));
    }
  }

  Future<void> _floodFill(Offset startPos) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filling...'), duration: Duration(milliseconds: 500)));
    
    try {
      final renderContext = _canvasKey.currentContext;
      if (renderContext == null) return;
      RenderRepaintBoundary boundary = renderContext.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      if (!mounted) return;
      
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null || !mounted) return;

      final fillColor = _selectedColor;
      
      setState(() {
        _layers[_activeLayerIndex].backgroundColor = fillColor;
      });
      _autoSave();
      
    } catch (e) {
      debugPrint("Fill error: $e");
    }
  }

  void _onPanEnd(DragEndDetails details) {
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

      // Save Data
      final jsonFile = File('${dir.path}/sketch_$_projectId.json');
      final data = {
        'layers': _layers.map((l) => l.toJson()).toList(),
        'textOverlays': _textOverlays.map((t) => t.toJson()).toList(),
        'imageOverlays': _imageOverlays.map((i) => i.toJson()).toList(),
        'canvasWidth': _canvasWidth,
        'canvasHeight': _canvasHeight,
        'ts': DateTime.now().millisecondsSinceEpoch,
      };
      await jsonFile.writeAsString(jsonEncode(data));
      
      // Also save to current_session for quick resume
      final sessionFile = File('${dir.path}/current_session.json');
      await sessionFile.writeAsString(jsonEncode(data));

      // Save Preview Thumbnail (low quality for performance)
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
      
      // Use lower pixelRatio for faster thumbnail generation
      ui.Image image = await boundary.toImage(pixelRatio: 0.5);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final pngFile = File('$drawingDirPath/sketch_$_projectId.png');
        await pngFile.writeAsBytes(bytes);
      }
    } catch (e) {
      debugPrint("Thumbnail save error: $e");
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
      
      setState(() => _isLoadingSession = true);
      final json = jsonDecode(await file.readAsString());
      final List layersJson = json['layers'];
      final List? textJson = json['textOverlays'];
      final List? imgsJson = json['imageOverlays'];
      
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

      setState(() {
        _canvasWidth = json['canvasWidth']?.toDouble() ?? 3000;
        _canvasHeight = json['canvasHeight']?.toDouble() ?? 3000;
        
        _layers.clear();
        _layers.addAll(loadedLayers);
        
        _textOverlays.clear();
        if (textJson != null) {
          for (var tj in textJson) {
            _textOverlays.add(TextOverlay.fromJson(tj));
          }
        }

        _imageOverlays.clear();
        if (imgsJson != null) {
          for (var ij in imgsJson) {
            _imageOverlays.add(ImageOverlay.fromJson(ij));
          }
        }

        _activeLayerIndex = 0;
        _isLoadingSession = false;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session Loaded!'), backgroundColor: Colors.green));
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

  // ── Recording Logic ──
  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        final RecordOutput result = await _screenRecorder.stopRecord();
        setState(() => _isRecording = false);
        
        if (result.success == true) {
          final String videoPath = result.file.path;
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Recording saved successfully!', style: GoogleFonts.outfit()),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => Share.shareXFiles([XFile(videoPath)]),
            ),
          ));
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save recording')));
        }
      } else {
        final size = MediaQuery.of(context).size;
        final Directory appDir = await getTemporaryDirectory();
        final String videoDir = appDir.path;
        final String fileName = "PM_Drawing_${DateTime.now().millisecondsSinceEpoch}";

        final RecordOutput result = await _screenRecorder.startRecordScreen(
          fileName: fileName,
          dirPathToSave: videoDir,
          addTimeCode: true,
          videoFrame: 30,
          videoBitrate: 3000000,
          width: size.width.toInt(),
          height: size.height.toInt(),
          audioEnable: false,
        );

        if (result.success == true) {
          setState(() => _isRecording = true);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Recording started...'),
            duration: Duration(seconds: 1),
          ));
        } else {
          final msg = result.message ?? 'Unknown error';
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start recording: $msg')));
        }
      }
    } catch (e) {
      debugPrint("Recording error: $e");
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
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
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _layers[_activeLayerIndex].strokes.add(s);
      });
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
      debugPrint("Error loading drawings: $e");
    }
  }

  Future<void> _saveImage() async {
    final settings = await _showSaveCustomizationDialog();
    if (settings == null) return;
    final double pixelRatio = settings['pixelRatio'] ?? 3.0;

    try {
      RenderRepaintBoundary? boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        final dir = await getApplicationDocumentsDirectory();
        final drawingDir = Directory('${dir.path}/saved_drawings');
        if (!await drawingDir.exists()) await drawingDir.create(recursive: true);
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final jsonFile = File('${drawingDir.path}/sketch_$timestamp.json');
        final projectData = {
          'layers': _layers.map((l) => l.toJson()).toList(),
          'canvasWidth': _canvasWidth,
          'canvasHeight': _canvasHeight,
          'ts': timestamp,
        };
        await jsonFile.writeAsString(jsonEncode(projectData));

        final file = File('${drawingDir.path}/sketch_$timestamp.png');
        await file.writeAsBytes(bytes);
        if (!mounted) return;
        _loadRecentDrawings();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to Gallery!', style: GoogleFonts.outfit()), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      debugPrint("Save error: $e");
    }
  }

  Future<void> _exportImage() async {
    final settings = await _showSaveCustomizationDialog();
    if (settings == null) return;
    final double pixelRatio = settings['pixelRatio'] ?? 3.0;

    try {
      RenderRepaintBoundary? boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
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
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      setState(() {
        final newLayer = DrawingLayer(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Image Layer ${_layers.length + 1}',
          importedImage: image,
          imageBytes: bytes,
          imageOffset: Offset(_canvasWidth / 2 - image.width / 2, _canvasHeight / 2 - image.height / 2),
        );
        _layers.add(newLayer);
        _activeLayerIndex = _layers.length - 1;
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
    _clearAutoSave();
  }

  Future<void> _clearAutoSave() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/current_session.json');
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint("Clear autosave error: $e");
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
                style: GoogleFonts.outfit(color: Colors.white, fontSize: tempFontSize / 2),
                decoration: const InputDecoration(
                  hintText: 'Enter text...',
                  hintStyle: TextStyle(color: Colors.white38),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.format_size, color: Colors.white54, size: 18),
                  Expanded(
                    child: Slider(
                      value: tempFontSize,
                      min: 10,
                      max: 200,
                      activeColor: Colors.amber,
                      onChanged: (v) => setDialogState(() => tempFontSize = v),
                    ),
                  ),
                  Text('${tempFontSize.toInt()}px', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      backgroundColor: const Color(0xFF1E1E1E),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: tempColor,
                          onColorChanged: (c) => setDialogState(() => tempColor = c),
                        ),
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.color_lens_outlined, color: Colors.white54, size: 18),
                    const SizedBox(width: 12),
                    Container(width: 40, height: 20, decoration: BoxDecoration(color: tempColor, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.white24))),
                    const SizedBox(width: 8),
                    const Text('Select Color', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
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
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Add Text', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

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
                  width: _canvasWidth,
                  height: _canvasHeight,
                  decoration: BoxDecoration(
                    color: _canvasBgColor,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 120)],
                  ),
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: Stack(
                      children: [
                        Container(color: _canvasBgColor),
                        if (_showGrid) CustomPaint(painter: GridPainter(), size: Size(_canvasWidth, _canvasHeight)),
                        ..._imageOverlays.map((img) => Positioned(
                          left: img.position.dx, top: img.position.dy,
                          child: GestureDetector(
                            onPanUpdate: (d) {
                              if (_pointerCount <= 1) {
                                setState(() => img.position += d.delta);
                              }
                            },
                            onPanEnd: (_) => _autoSave(),
                            child: Transform.scale(scale: img.scale, child: Transform.rotate(angle: img.rotation, child: Image.memory(img.bytes, width: 300, fit: BoxFit.contain))),
                          ),
                        )),
                        ..._layers.map((layer) {
                          if (!layer.isVisible) return const SizedBox.shrink();
                          return Opacity(
                            opacity: layer.opacity,
                            child: Stack(
                              children: [
                                if (layer.backgroundColor != null)
                                  Container(
                                    width: _canvasWidth,
                                    height: _canvasHeight,
                                    color: layer.backgroundColor,
                                  ),
                                if (layer.importedImage != null)
                                  Positioned(
                                    left: layer.imageOffset.dx,
                                    top: layer.imageOffset.dy,
                                    child: Transform.scale(
                                      scale: layer.imageScale,
                                      child: RawImage(image: layer.importedImage),
                                    ),
                                  ),
                                CustomPaint(
                                  painter: LayerPainter(
                                    strokes: layer.strokes, 
                                    activeStroke: (_layers.indexOf(layer) == _activeLayerIndex) ? _currentStroke : null
                                  ), 
                                  size: Size(_canvasWidth, _canvasHeight)
                                ),
                              ],
                            ),
                          );
                        }),
                        if (_activeTool == DrawingTool.shape && _shapeStart != null && _shapeEnd != null)
                          CustomPaint(painter: ShapePreviewPainter(shape: _selectedShape, start: _shapeStart!, end: _shapeEnd!, color: _selectedColor, strokeWidth: _strokeWidth, filled: _shapeFilled), size: Size(_canvasWidth, _canvasHeight)),
                        if (_pointerCount <= 1)
                          GestureDetector(onPanStart: _onPanStart, onPanUpdate: _onPanUpdate, onPanEnd: _onPanEnd, child: Container(color: Colors.transparent)),
                        ..._textOverlays.map((t) => Positioned(
                          left: t.position.dx, top: t.position.dy,
                          child: GestureDetector(
                            onPanUpdate: (d) {
                              if (_pointerCount <= 1) {
                                setState(() => t.position += d.delta);
                              }
                            },
                            onPanEnd: (_) => _autoSave(),
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

          // ── Movable Sidebar ──
          Positioned(
            left: _sidebarOffset.dx,
            top: _sidebarOffset.dy,
            child: GestureDetector(
              onScaleStart: (details) {
                _lastRotation = _sidebarRotation;
                _lastScale = _sidebarScale;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _sidebarRotation = _lastRotation + details.rotation;
                  _sidebarScale = (_lastScale * details.scale).clamp(0.5, 2.0);
                  
                  // Handle drag if only one finger (translation delta)
                  if (details.pointerCount == 1) {
                    _sidebarOffset = Offset(
                      (_sidebarOffset.dx + details.focalPointDelta.dx).clamp(0, screenSize.width - 60),
                      (_sidebarOffset.dy + details.focalPointDelta.dy).clamp(0, screenSize.height - 400),
                    );
                  }
                });
              },
              child: Transform.rotate(
                angle: _sidebarRotation,
                child: Transform.scale(
                  scale: _sidebarScale,
                  child: _buildLeftSidebar(theme),
                ),
              ),
            ),
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

          // ── Saved Indicator ──
          if (_showSavedIndicator)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 80, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 6),
                    Text('Draft Saved', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ).animate().fadeIn().fadeOut(delay: 800.ms),

          // ── Panels ──
          if (_showLayersPanel)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60, right: 8,
              child: _buildLayersPanel(theme, isTablet),
            ),

          if (_showBrushSettings)
            Positioned(
              left: _sidebarOffset.dx + 60, top: _sidebarOffset.dy,
              child: _buildBrushSettingsPanel(theme),
            ),

          if (_showRecentPanel)
            Positioned(left: _sidebarOffset.dx + 60, top: _sidebarOffset.dy, bottom: 80, width: isTablet ? 320 : 250, child: _buildRecentPanel(theme)),

          if (_isLoadingSession)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.amber),
                      const SizedBox(height: 16),
                      Text('Resuming session...', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),

          // ── Recording indicator ──
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
        ],
      ),
    );
  }

  Widget _buildLeftSidebar(FlutterFlowTheme theme) {
    return Container(
      width: 52, padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.drag_handle_rounded, color: Colors.white12, size: 16),
        const SizedBox(height: 8),
        _sideBtn(Icons.brush_rounded, _activeTool == DrawingTool.brush && !_isEraser, () {
          if (_activeTool == DrawingTool.brush && !_isEraser) { _showBrushPickerSheet(); } else { setState(() { _activeTool = DrawingTool.brush; _isEraser = false; }); }
        }),
        const SizedBox(height: 14),
        _sideBtn(Icons.auto_fix_high_rounded, _isEraser, () => setState(() { _isEraser = true; })),
        const SizedBox(height: 14),
        _sideBtn(Icons.crop_square_rounded, _activeTool == DrawingTool.shape, () { setState(() => _activeTool = DrawingTool.shape); _showShapePicker(); }),
        const SizedBox(height: 14),
        _sideBtn(Icons.text_fields_rounded, false, _addText),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _showColorPicker,
          child: Container(width: 28, height: 28, decoration: BoxDecoration(color: _selectedColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5))),
        ),
        const SizedBox(height: 14),
        _sideBtn(Icons.tune_rounded, _showBrushSettings, () => setState(() => _showBrushSettings = !_showBrushSettings)),
        const SizedBox(height: 14),
        _sideBtn(Icons.format_color_fill_rounded, _activeTool == DrawingTool.fillBucket, () => setState(() => _activeTool = DrawingTool.fillBucket)),
        const SizedBox(height: 14),
        _sideBtn(Icons.grid_3x3_rounded, _activeTool == DrawingTool.symmetry, () {
          setState(() {
             _activeTool = DrawingTool.symmetry;
             if (_symmetryMode == SymmetryMode.none) {
               _symmetryMode = SymmetryMode.horizontal;
             } else if (_symmetryMode == SymmetryMode.horizontal) {
               _symmetryMode = SymmetryMode.vertical;
             } else if (_symmetryMode == SymmetryMode.vertical) {
               _symmetryMode = SymmetryMode.quad;
             } else {
               _symmetryMode = SymmetryMode.none;
             }
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Symmetry: ${_symmetryMode.name}'), duration: const Duration(seconds: 1)));
        }),
        const SizedBox(height: 14),
        _sideBtn(Icons.image_outlined, false, _importImage),
        const SizedBox(height: 8),
        _sideBtn(Icons.sync_alt_rounded, false, () {
          setState(() {
            _sidebarRotation = (_sidebarRotation == 0) ? 1.5708 : 0; // Toggle 90 deg
          });
        }),
      ]),
    );
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

  Widget _buildTopBar(FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _headerBtn(Icons.home_outlined, () => Navigator.pop(context)),
        Row(children: [
          if (!_isReplaying) _headerBtn(Icons.play_circle_outline_rounded, _replayDrawing, color: Colors.amber),
          const SizedBox(width: 12),
          _headerBtn(_isRecording ? Icons.stop_circle : Icons.fiber_manual_record, _toggleRecording, color: _isRecording ? Colors.red : Colors.white70),
          const SizedBox(width: 12),
          _headerBtn(Icons.layers_outlined, () => setState(() => _showLayersPanel = !_showLayersPanel)),
          const SizedBox(width: 12),
          _headerBtn(Icons.more_horiz_rounded, _showOptionsSheet),
        ]),
      ],
    );
  }

  Widget _headerBtn(IconData icon, VoidCallback onTap, {Color color = Colors.white70}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle), child: Icon(icon, color: color, size: 22)),
    );
  }

  Widget _buildBottomBar(FlutterFlowTheme theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _headerBtn(Icons.undo_rounded, _undo),
        _headerBtn(Icons.redo_rounded, _redo),
      ],
    );
  }

  Widget _buildLayersPanel(FlutterFlowTheme theme, bool isTablet) {
    return Container(
      width: isTablet ? 90 : 70,
      decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 15)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: _addLayer,
          child: Container(padding: const EdgeInsets.all(12), child: const Icon(Icons.add, color: Colors.white70, size: 22)),
        ),
        const Divider(color: Colors.white10, height: 1),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _layers.length,
            itemBuilder: (ctx, i) {
              final ri = _layers.length - 1 - i;
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
                    border: Border.all(color: isActive ? Colors.amber : Colors.transparent, width: isActive ? 2.5 : 0),
                  ),
                  child: Stack(children: [
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
        GestureDetector(
          onTap: _showCanvasBgPicker,
          child: Container(
            margin: const EdgeInsets.all(10),
            width: 30, height: 30,
            decoration: BoxDecoration(color: _canvasBgColor, shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
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
          Row(children: [
            const Icon(Icons.opacity, color: Colors.white54, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Slider(value: _layers[index].opacity, min: 0, max: 1, activeColor: Colors.amber, onChanged: (v) => setState(() => _layers[index].opacity = v))),
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
        Slider(value: _strokeWidth, min: 0.5, max: 100, activeColor: Colors.amber, onChanged: (v) => setState(() => _strokeWidth = v)),
        Text('Opacity: ${(_strokeOpacity * 100).toInt()}%', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Slider(value: _strokeOpacity, min: 0.01, max: 1.0, activeColor: Colors.amber, onChanged: (v) => setState(() => _strokeOpacity = v)),
        if (_isEraser) ...[
          Text('Eraser: ${_eraserWidth.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Slider(value: _eraserWidth, min: 5, max: 200, activeColor: Colors.redAccent, onChanged: (v) => setState(() => _eraserWidth = v)),
        ],
        const SizedBox(height: 8),
        Row(children: [
          const Text('Grid', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const Spacer(),
          Switch(value: _showGrid, activeThumbColor: Colors.amber, onChanged: (v) => setState(() => _showGrid = v)),
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
            await Share.shareXFiles([XFile(path)], text: 'PocketMates Sketch'); 
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
            _optBtn(_isRecording ? Icons.stop_circle : Icons.fiber_manual_record, 'Record', () { Navigator.pop(ctx); _toggleRecording(); }, highlight: _isRecording),
            _optBtn(Icons.ios_share_rounded, 'Export', () { Navigator.pop(ctx); _exportImage(); }),
          ]),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
          ListTile(leading: const Icon(Icons.grid_3x3, color: Colors.white54), title: Text('Canvas Grid', style: GoogleFonts.outfit(color: Colors.white70)), trailing: Switch(value: _showGrid, activeThumbColor: Colors.amber, onChanged: (v) => setState(() => _showGrid = v))),
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
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _selectedShape == s.$1 ? Colors.amber.withValues(alpha: 0.2) : const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12), border: Border.all(color: _selectedShape == s.$1 ? Colors.amber : Colors.white12)), child: Icon(s.$2, color: Colors.white70, size: 28)),
              const SizedBox(height: 6),
              Text(s.$3, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11)),
            ]),
          )).toList()),
          const SizedBox(height: 20),
          Row(children: [
            Text('Fill Shape', style: GoogleFonts.outfit(color: Colors.white54)),
            const Spacer(),
            Switch(value: _shapeFilled, activeThumbColor: Colors.amber, onChanged: (v) => setState(() => _shapeFilled = v)),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
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
                        color: sel ? Colors.amber.withValues(alpha: 0.1) : Colors.transparent,
                        child: Row(children: [
                          Icon(icons[cat] ?? Icons.brush, size: 16, color: cat == 'Favorites' ? Colors.pinkAccent : (sel ? Colors.amber : Colors.white38)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(cat, style: GoogleFonts.outfit(color: sel ? Colors.amber : Colors.white54, fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
                              decoration: BoxDecoration(color: isSel ? Colors.amber.withValues(alpha: 0.1) : Colors.white10, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSel ? Colors.amber : Colors.transparent)),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text(b.name, style: GoogleFonts.outfit(color: isSel ? Colors.amber : Colors.white70, fontWeight: isSel ? FontWeight.bold : FontWeight.w500, fontSize: 15)),
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

  void _showColorPicker() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      title: Text('Palette', style: GoogleFonts.outfit(color: Colors.white)),
      content: SingleChildScrollView(child: ColorPicker(pickerColor: _selectedColor, onColorChanged: (c) => setState(() => _selectedColor = c), pickerAreaHeightPercent: 0.7, labelTypes: const [])),
      actions: [TextButton(child: const Text('Select'), onPressed: () => Navigator.pop(ctx))],
    ));
  }

  Future<Map<String, dynamic>?> _showSaveCustomizationDialog() async {
    double selectedPixelRatio = 3.0;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Row(
                children: [
                  Icon(Icons.settings, color: Colors.yellow, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Save Settings',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color fix warning for high pixel ratios
                  if (selectedPixelRatio > 6.0)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'High ratios may cause color issues',
                              style:
                                  TextStyle(color: Colors.orange, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Text(
                    'Select Image Quality:',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Quality options with color-safe recommendations
                  _buildQualityOption('Standard (1x)', 1.0, selectedPixelRatio,
                      () => setState(() => selectedPixelRatio = 1.0)),
                  _buildQualityOption('High (2x)', 2.0, selectedPixelRatio,
                      () => setState(() => selectedPixelRatio = 2.0)),
                  _buildQualityOption(
                      'Ultra HD (3x) ✓',
                      3.0,
                      selectedPixelRatio,
                      () => setState(() => selectedPixelRatio = 3.0)),
                  _buildQualityOption(
                      'Super HD (5x) ✓',
                      5.0,
                      selectedPixelRatio,
                      () => setState(() => selectedPixelRatio = 5.0)),
                  _buildQualityOption('Maximum (8x)', 8.0, selectedPixelRatio,
                      () => setState(() => selectedPixelRatio = 8.0)),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 16),

                  // Custom slider section
                  const Row(
                    children: [
                      Icon(Icons.tune, color: Colors.yellow, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Custom Pixel Ratio:',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Slider with labels
                  Row(
                    children: [
                      const Text('1x',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.yellow,
                            inactiveTrackColor: Colors.grey[700],
                            thumbColor: Colors.yellow,
                            overlayColor: Colors.yellow.withValues(alpha: 0.3),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 20),
                            valueIndicatorColor: Colors.yellow,
                            valueIndicatorTextStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Slider(
                            value: selectedPixelRatio,
                            min: 1.0,
                            max: 10.0,
                            divisions: 90, // 0.1 increments
                            label: '${selectedPixelRatio.toStringAsFixed(1)}x',
                            onChanged: (value) {
                              setState(() {
                                selectedPixelRatio = value;
                              });
                            },
                          ),
                        ),
                      ),
                      const Text('10x',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.yellow, width: 1),
                      ),
                      child: Text(
                        'Current: ${selectedPixelRatio.toStringAsFixed(1)}x',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String quality = '';
                    switch (selectedPixelRatio) {
                      case 1.0:
                        quality = 'standard';
                        break;
                      case 2.0:
                        quality = 'high';
                        break;
                      case 3.0:
                        quality = 'ultra_hd';
                        break;
                      case 5.0:
                        quality = 'super_hd';
                        break;
                      case 8.0:
                        quality = 'maximum';
                        break;
                      default:
                        quality = 'custom';
                        break;
                    }

                    Navigator.of(context).pop({
                      'pixelRatio': selectedPixelRatio,
                      'quality': quality,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save, size: 18),
                      SizedBox(width: 4),
                      Text('Save'),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildQualityOption(
      String title, double value, double current, VoidCallback onTap) {
    final bool isSelected = current == value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.yellow.withValues(alpha: 0.2) : Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.yellow : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.yellow : Colors.white,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
