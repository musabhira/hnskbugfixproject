import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as cp;
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'poster_models.dart';

class PosterEditorPage extends StatefulWidget {
  final PosterDesign? initialDesign;

  const PosterEditorPage({super.key, this.initialDesign});

  @override
  State<PosterEditorPage> createState() => _PosterEditorPageState();
}

class _PosterEditorPageState extends State<PosterEditorPage> {
  final GlobalKey _canvasKey = GlobalKey();
  late PosterDesign _design;
  DesignElement? _selectedElement;
  bool _isSaving = false;

  // Curated Designer Gradients
  final List<List<Color>> _presetGradients = [
    [const Color(0xFF0F172A), const Color(0xFF1E1B4B)], // Midnight Dark
    [const Color(0xFFFF007A), const Color(0xFF7928CA)], // Cyberpunk Neon
    [const Color(0xFFFF512F), const Color(0xFFDD2476)], // Sunset Blaze
    [const Color(0xFF064E3B), const Color(0xFF047857)], // Emerald Luxury
    [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)], // Deep Ocean
    [const Color(0xFFFFB700), const Color(0xFFFF8906)], // Golden Amber
    [const Color(0xFF4C1D95), const Color(0xFFEC4899)], // Cosmic Violet
    [const Color(0xFF18181B), const Color(0xFF27272A)], // Obsidian Matte
    [const Color(0xFF8EC5FC), const Color(0xFFE0C3FC)], // Pastel Dream
    [const Color(0xFFFFFFFF), const Color(0xFFE2E8F0)], // Clean Paper
  ];

  @override
  void initState() {
    super.initState();
    _design = widget.initialDesign ??
        PosterDesign(
          title: 'My Design',
          elements: [],
          backgroundColor: const Color(0xFF0F172A),
          backgroundGradient: [
            const Color(0xFF0F172A),
            const Color(0xFF1E1B4B)
          ],
          aspectRatio: 3 / 4,
        );
  }

  void _addElement(ElementType type, {String? text, IconData? icon}) {
    HapticFeedback.selectionClick();
    setState(() {
      final id = const Uuid().v4();
      final newElement = DesignElement(
        id: id,
        type: type,
        text: type == ElementType.text
            ? (text ?? 'Double Tap to Edit')
            : null,
        textStyle: type == ElementType.text
            ? GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )
            : null,
        imageUrl:
            type == ElementType.image ? 'https://picsum.photos/400' : null,
        color: type == ElementType.shape
            ? const Color(0xFFFFFC00)
            : Colors.white,
        size: type == ElementType.text
            ? const Size(260, 60)
            : (type == ElementType.sticker
                ? const Size(120, 120)
                : const Size(160, 160)),
        borderRadius: type == ElementType.shape ? 16 : null,
        stickerIcon: icon,
        position: const Offset(40, 140),
      );
      _design.elements.add(newElement);
      _selectedElement = newElement;
    });
  }

  // Pick Image from Gallery to add to canvas
  void _pickImageElement() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        final id = const Uuid().v4();
        final newEl = DesignElement(
          id: id,
          type: ElementType.image,
          imageUrl: picked.path,
          size: const Size(200, 200),
          position: const Offset(50, 100),
        );
        _design.elements.add(newEl);
        _selectedElement = newEl;
      });
    }
  }

  // Pick Custom Background Image
  void _pickBackgroundImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _design.backgroundImageUrl = picked.path;
      });
    }
  }

  // Show Rich Typography Editor Sheet
  void _showTextEditorSheet(DesignElement element) {
    final textController = TextEditingController(text: element.text ?? '');
    double currentFontSize = element.textStyle?.fontSize ?? 28;
    double currentLetterSpacing = element.textStyle?.letterSpacing ?? 0;
    FontWeight currentWeight =
        element.textStyle?.fontWeight ?? FontWeight.bold;
    TextAlign currentAlign = element.textAlign ?? TextAlign.center;
    Color currentColor = element.textStyle?.color ?? Colors.white;
    Color? currentBgColor = element.textBackgroundColor;

    final fonts = [
      ('Outfit', GoogleFonts.outfit),
      ('Inter', GoogleFonts.inter),
      ('Bebas Neue', GoogleFonts.bebasNeue),
      ('Montserrat', GoogleFonts.montserrat),
      ('Playfair Display', GoogleFonts.playfairDisplay),
      ('Poppins', GoogleFonts.poppins),
      ('Pacifico', GoogleFonts.pacifico),
      ('Dancing Script', GoogleFonts.dancingScript),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Customize Typography',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded,
                          color: Color(0xFFFFFC00), size: 26),
                      onPressed: () {
                        setState(() {
                          element.text = textController.text;
                          element.textAlign = currentAlign;
                          element.textBackgroundColor = currentBgColor;
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Text Input
                TextField(
                  controller: textController,
                  maxLines: 2,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your headline...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => element.text = val);
                  },
                ),

                const SizedBox(height: 16),

                // Font Family Selector
                Text('FONT FAMILY',
                    style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: fonts.length,
                    itemBuilder: (context, i) {
                      final f = fonts[i];
                      final isSelected =
                          element.textStyle?.fontFamily == f.$1;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setSheetState(() {
                            element.textStyle = f.$2(
                              fontSize: currentFontSize,
                              fontWeight: currentWeight,
                              color: currentColor,
                              letterSpacing: currentLetterSpacing,
                            );
                          });
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFFFC00)
                                : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.white12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            f.$1,
                            style: f.$2(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Font Size Slider
                Row(
                  children: [
                    Text('Size',
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 13)),
                    Expanded(
                      child: Slider(
                        value: currentFontSize,
                        min: 12,
                        max: 90,
                        activeColor: const Color(0xFFFFFC00),
                        onChanged: (val) {
                          setSheetState(() => currentFontSize = val);
                          setState(() {
                            element.textStyle =
                                element.textStyle?.copyWith(fontSize: val) ??
                                    TextStyle(fontSize: val);
                          });
                        },
                      ),
                    ),
                    Text('${currentFontSize.toInt()}px',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),

                // Letter Spacing Slider
                Row(
                  children: [
                    Text('Spacing',
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 13)),
                    Expanded(
                      child: Slider(
                        value: currentLetterSpacing,
                        min: -2,
                        max: 12,
                        activeColor: const Color(0xFFFFFC00),
                        onChanged: (val) {
                          setSheetState(() => currentLetterSpacing = val);
                          setState(() {
                            element.textStyle = element.textStyle
                                    ?.copyWith(letterSpacing: val) ??
                                TextStyle(letterSpacing: val);
                          });
                        },
                      ),
                    ),
                    Text('${currentLetterSpacing.toStringAsFixed(1)}',
                        style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(height: 12),

                // Alignment & Color Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Alignment buttons
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.format_align_left_rounded,
                                color: currentAlign == TextAlign.left
                                    ? const Color(0xFFFFFC00)
                                    : Colors.white54,
                                size: 18),
                            onPressed: () {
                              setSheetState(() => currentAlign = TextAlign.left);
                              setState(() => element.textAlign = TextAlign.left);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.format_align_center_rounded,
                                color: currentAlign == TextAlign.center
                                    ? const Color(0xFFFFFC00)
                                    : Colors.white54,
                                size: 18),
                            onPressed: () {
                              setSheetState(
                                  () => currentAlign = TextAlign.center);
                              setState(
                                  () => element.textAlign = TextAlign.center);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.format_align_right_rounded,
                                color: currentAlign == TextAlign.right
                                    ? const Color(0xFFFFFC00)
                                    : Colors.white54,
                                size: 18),
                            onPressed: () {
                              setSheetState(
                                  () => currentAlign = TextAlign.right);
                              setState(
                                  () => element.textAlign = TextAlign.right);
                            },
                          ),
                        ],
                      ),
                    ),

                    // Color Picker Button
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            backgroundColor: const Color(0xFF1E1E24),
                            title: const Text('Text Color',
                                style: TextStyle(color: Colors.white)),
                            content: SingleChildScrollView(
                              child: cp.ColorPicker(
                                pickerColor: currentColor,
                                onColorChanged: (color) {
                                  setSheetState(() => currentColor = color);
                                  setState(() {
                                    element.textStyle = element.textStyle
                                            ?.copyWith(color: color) ??
                                        TextStyle(color: color);
                                  });
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Done',
                                    style: TextStyle(color: Color(0xFFFFFC00))),
                                onPressed: () => Navigator.pop(c),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: currentColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Color',
                                style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
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
    );
  }

  // High-Res Save to Gallery & Share
  Future<void> _saveDesign() async {
    setState(() {
      _isSaving = true;
      _selectedElement = null; // deselect to remove bounding box
    });

    await Future.delayed(const Duration(milliseconds: 150));

    try {
      final RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      // 4.0 pixelRatio yields ultra crisp 4K Canva export quality
      final ui.Image image = await boundary.toImage(pixelRatio: 4.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/Poster_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);

        // Check gallery access & save directly with Gal
        final hasAccess = await Gal.hasAccess(toAlbum: false);
        if (!hasAccess) {
          await Gal.requestAccess(toAlbum: false);
        }
        await Gal.putImage(filePath);

        HapticFeedback.heavyImpact();

        if (mounted) {
          showModalBottomSheet(
            context: context,
            backgroundColor: const Color(0xFF1E1E24),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (ctx) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Poster Saved to Camera Roll!',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ultra HD High-Resolution output is now in your device Gallery.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          label: Text('Keep Editing',
                              style: GoogleFonts.outfit(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            SharePlus.instance.share(ShareParams(
                              files: [XFile(filePath)],
                              text: 'Designed with PocketMates Poster Studio!',
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFFC00),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: Text('Share Now',
                              style: GoogleFonts.outfit(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentYellow = Color(0xFFFFFC00);

    return Scaffold(
      backgroundColor: const Color(0xFF090E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _design.title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              'Canva-Grade Studio',
              style: GoogleFonts.inter(
                color: accentYellow,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          // Aspect Ratio Switcher Dropdown in App Bar
          PopupMenuButton<double>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.aspect_ratio_rounded,
                      size: 14, color: accentYellow),
                  const SizedBox(width: 4),
                  Text(
                    _getAspectRatioName(_design.aspectRatio),
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            color: const Color(0xFF1E1E24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (ratio) {
              setState(() => _design.aspectRatio = ratio);
            },
            itemBuilder: (context) => [
              _buildRatioMenuItem(3 / 4, 'Flyer / Poster (3:4)'),
              _buildRatioMenuItem(9 / 16, 'Story / Reel (9:16)'),
              _buildRatioMenuItem(1 / 1, 'Square Post (1:1)'),
              _buildRatioMenuItem(16 / 9, 'Landscape (16:9)'),
            ],
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: accentYellow, strokeWidth: 2))
                : const Icon(Icons.download_rounded,
                    color: accentYellow, size: 24),
            onPressed: _isSaving ? null : _saveDesign,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Main Interactive Canvas Area
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() => _selectedElement = null),
                child: AspectRatio(
                  aspectRatio: _design.aspectRatio,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _design.backgroundColor,
                      gradient: _design.backgroundGradient != null
                          ? LinearGradient(
                              colors: _design.backgroundGradient!,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      image: _design.backgroundImageUrl != null
                          ? DecorationImage(
                              image: _design.backgroundImageUrl!
                                      .startsWith('http')
                                  ? NetworkImage(_design.backgroundImageUrl!)
                                  : FileImage(
                                          File(_design.backgroundImageUrl!))
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 24,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: Stack(
                        children: _design.elements.map((element) {
                          return _buildDraggableElement(element);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Selected Element Action Toolbar (Duplicate, Layer Order, Delete)
          if (_selectedElement != null) _buildSelectedElementControls(),

          // Bottom Creation Toolbar (Text, Shapes, Badges, Background, Image)
          _buildBottomStudioToolbar(accentYellow),
        ],
      ),
    );
  }

  String _getAspectRatioName(double ratio) {
    if ((ratio - 9 / 16).abs() < 0.05) return '9:16';
    if ((ratio - 1).abs() < 0.05) return '1:1';
    if ((ratio - 16 / 9).abs() < 0.05) return '16:9';
    return '3:4';
  }

  PopupMenuItem<double> _buildRatioMenuItem(double ratio, String label) {
    return PopupMenuItem<double>(
      value: ratio,
      child: Text(label,
          style: GoogleFonts.inter(
              color: (_design.aspectRatio - ratio).abs() < 0.05
                  ? const Color(0xFFFFFC00)
                  : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600)),
    );
  }

  // RENDER CANVAS ELEMENT WITH DRAG & ROTATE
  Widget _buildDraggableElement(DesignElement element) {
    final isSelected = _selectedElement?.id == element.id;

    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedElement = element);
        },
        onDoubleTap: () {
          if (element.type == ElementType.text) {
            _showTextEditorSheet(element);
          }
        },
        onPanUpdate: (details) {
          setState(() {
            element.position += details.delta;
          });
        },
        child: Transform.rotate(
          angle: element.rotation,
          child: Container(
            width: element.size.width,
            height: element.size.height,
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: const Color(0xFFFFFC00), width: 1.8)
                  : null,
              borderRadius: isSelected ? BorderRadius.circular(8) : null,
            ),
            child: Opacity(
              opacity: element.opacity,
              child: _renderElementContent(element),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderElementContent(DesignElement element) {
    switch (element.type) {
      case ElementType.text:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: element.textBackgroundColor != null
              ? BoxDecoration(
                  color: element.textBackgroundColor,
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          alignment: _getAlignment(element.textAlign),
          child: Text(
            element.text ?? '',
            textAlign: element.textAlign,
            style: element.textStyle ??
                GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
          ),
        );

      case ElementType.image:
        if (element.imageUrl == null) return const SizedBox();
        return ClipRRect(
          borderRadius: BorderRadius.circular(element.borderRadius ?? 8),
          child: element.imageUrl!.startsWith('http')
              ? Image.network(element.imageUrl!, fit: BoxFit.cover)
              : Image.file(File(element.imageUrl!), fit: BoxFit.cover),
        );

      case ElementType.shape:
        return Container(
          decoration: BoxDecoration(
            color: element.color,
            borderRadius: BorderRadius.circular(element.borderRadius ?? 12),
          ),
        );

      case ElementType.sticker:
        return Container(
          decoration: BoxDecoration(
            color: element.color.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: element.color, width: 2),
          ),
          child: Center(
            child: Icon(element.stickerIcon ?? Icons.stars_rounded,
                color: element.color, size: element.size.width * 0.55),
          ),
        );
    }
  }

  Alignment _getAlignment(TextAlign? align) {
    switch (align) {
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  // SELECTED ELEMENT CONTROLS (Duplicate, Layer Order, Delete)
  Widget _buildSelectedElementControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_selectedElement!.type == ElementType.text)
            _buildToolbarIconBtn(Icons.edit_rounded, 'Edit Text', () {
              _showTextEditorSheet(_selectedElement!);
            }),
          _buildToolbarIconBtn(Icons.flip_to_front_rounded, 'To Front', () {
            setState(() {
              _design.elements.remove(_selectedElement);
              _design.elements.add(_selectedElement!);
            });
          }),
          _buildToolbarIconBtn(Icons.flip_to_back_rounded, 'To Back', () {
            setState(() {
              _design.elements.remove(_selectedElement);
              _design.elements.insert(0, _selectedElement!);
            });
          }),
          _buildToolbarIconBtn(Icons.copy_rounded, 'Duplicate', () {
            setState(() {
              final dup = _selectedElement!.copyWith(
                position: _selectedElement!.position + const Offset(15, 15),
              );
              _design.elements.add(dup);
              _selectedElement = dup;
            });
          }),
          _buildToolbarIconBtn(Icons.delete_outline_rounded, 'Delete', () {
            setState(() {
              _design.elements.remove(_selectedElement);
              _selectedElement = null;
            });
          }, color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildToolbarIconBtn(IconData icon, String label, VoidCallback onTap,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color ?? Colors.white70, size: 18),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.inter(
                    color: color ?? Colors.white60, fontSize: 9.5)),
          ],
        ),
      ),
    );
  }

  // BOTTOM STUDIO TOOLBAR (Add Elements, Backgrounds, Badges)
  Widget _buildBottomStudioToolbar(Color accentYellow) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomActionItem(Icons.text_fields_rounded, 'Add Text', () {
            _addElement(ElementType.text);
          }),
          _buildBottomActionItem(
              Icons.add_photo_alternate_rounded, 'Add Photo', _pickImageElement),
          _buildBottomActionItem(Icons.crop_square_rounded, 'Shapes', () {
            _showShapePickerSheet();
          }),
          _buildBottomActionItem(Icons.stars_rounded, 'Stickers', () {
            _showStickersSheet();
          }),
          _buildBottomActionItem(Icons.color_lens_rounded, 'Background', () {
            _showBackgroundPickerSheet();
          }),
        ],
      ),
    );
  }

  Widget _buildBottomActionItem(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // SHAPE PICKER SHEET
  void _showShapePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Shape',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShapeItem('Card Box', () {
                  _addElement(ElementType.shape);
                  Navigator.pop(ctx);
                }),
                _buildShapeItem('Circle', () {
                  final id = const Uuid().v4();
                  final newEl = DesignElement(
                    id: id,
                    type: ElementType.shape,
                    color: const Color(0xFF38BDF8),
                    size: const Size(140, 140),
                    borderRadius: 70,
                  );
                  setState(() {
                    _design.elements.add(newEl);
                    _selectedElement = newEl;
                  });
                  Navigator.pop(ctx);
                }),
                _buildShapeItem('Pill Banner', () {
                  final id = const Uuid().v4();
                  final newEl = DesignElement(
                    id: id,
                    type: ElementType.shape,
                    color: const Color(0xFFF43F5E),
                    size: const Size(220, 48),
                    borderRadius: 24,
                  );
                  setState(() {
                    _design.elements.add(newEl);
                    _selectedElement = newEl;
                  });
                  Navigator.pop(ctx);
                }),
                _buildShapeItem('Divider Line', () {
                  final id = const Uuid().v4();
                  final newEl = DesignElement(
                    id: id,
                    type: ElementType.shape,
                    color: Colors.white70,
                    size: const Size(240, 3),
                    borderRadius: 2,
                  );
                  setState(() {
                    _design.elements.add(newEl);
                    _selectedElement = newEl;
                  });
                  Navigator.pop(ctx);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapeItem(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(Icons.category_rounded,
                color: Color(0xFFFFFC00), size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  // STICKERS & BADGES SHEET
  void _showStickersSheet() {
    final stickers = [
      (Icons.verified_rounded, const Color(0xFF38BDF8), 'Verified'),
      (Icons.stars_rounded, const Color(0xFFFFD700), 'Gold Star'),
      (Icons.local_fire_department_rounded, const Color(0xFFEF4444), 'Hot Deal'),
      (Icons.offline_bolt_rounded, const Color(0xFFFFFC00), 'Flash'),
      (Icons.favorite_rounded, const Color(0xFFEC4899), 'Love'),
      (Icons.military_tech_rounded, const Color(0xFFF59E0B), 'Award'),
      (Icons.workspace_premium_rounded, const Color(0xFF10B981), 'VIP'),
      (Icons.discount_rounded, const Color(0xFF8B5CF6), '50% OFF'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Badges & Vector Stickers',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: stickers.map((s) {
                return GestureDetector(
                  onTap: () {
                    final id = const Uuid().v4();
                    final newEl = DesignElement(
                      id: id,
                      type: ElementType.sticker,
                      color: s.$2,
                      stickerIcon: s.$1,
                      size: const Size(100, 100),
                    );
                    setState(() {
                      _design.elements.add(newEl);
                      _selectedElement = newEl;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: s.$2.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: s.$2, width: 1.5),
                        ),
                        child: Icon(s.$1, color: s.$2, size: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(s.$3,
                          style: GoogleFonts.inter(
                              color: Colors.white70, fontSize: 10.5)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // BACKGROUND PICKER SHEET (Gradients, Solids, Photos)
  void _showBackgroundPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Background Style',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _pickBackgroundImage();
                  },
                  icon: const Icon(Icons.add_photo_alternate_rounded,
                      color: Color(0xFFFFFC00), size: 16),
                  label: Text('Custom Photo',
                      style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFC00),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('CURATED DESIGNER GRADIENTS',
                style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _presetGradients.length,
                itemBuilder: (context, i) {
                  final g = _presetGradients[i];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _design.backgroundGradient = g;
                        _design.backgroundImageUrl = null;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: g,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
