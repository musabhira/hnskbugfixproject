import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart' as material;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as cp;
import 'package:share_plus/share_plus.dart';
import 'poster_models.dart';
import 'package:uuid/uuid.dart';

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

  @override
  void initState() {
    super.initState();
    _design = widget.initialDesign ??
        PosterDesign(
          title: 'New Design',
          elements: [],
          backgroundColor: material.Colors.white,
        );
  }

  void _addElement(ElementType type) {
    setState(() {
      final id = const Uuid().v4();
      final newElement = DesignElement(
        id: id,
        type: type,
        text: type == ElementType.text ? 'TAP TO EDIT' : null,
        textStyle: type == ElementType.text
            ? GoogleFonts.inter(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: material.Colors.black)
            : null,
        imageUrl:
            type == ElementType.image ? 'https://picsum.photos/400' : null,
        color: type == ElementType.shape
            ? material.Colors.yellow
            : material.Colors.black,
        size: type == ElementType.text
            ? const Size(300, 60)
            : const Size(200, 200),
      );
      _design.elements.add(newElement);
      _selectedElement = newElement;
    });
  }

  void _showTextEditor(DesignElement element) {
    final controller = TextEditingController(text: element.text);
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Edit Text'),
        content: material.TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          style: const material.TextStyle(color: material.Colors.white),
          decoration: const material.InputDecoration(
            hintText: 'Enter your text...',
            hintStyle: material.TextStyle(color: material.Colors.grey),
          ),
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Done'),
            onPressed: () {
              setState(() {
                element.text = controller.text;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // In a real app, you'd upload this to Supabase Storage first.
      // For now, we'll use local path if possible or a placeholder.
      setState(() {
        final id = const Uuid().v4();
        _design.elements.add(DesignElement(
          id: id,
          type: ElementType.image,
          imageUrl: pickedFile.path,
          size: const Size(200, 200),
        ));
      });
    }
  }

  Future<void> _saveDesign() async {
    setState(() => _isSaving = true);
    // Clear selection so bounding box isn't exported
    setState(() => _selectedElement = null);
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      // High pixelRatio ensures high quality output
      final ui.Image image = await boundary.toImage(pixelRatio: 4.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(pngBytes,
                  mimeType: 'image/png', name: 'poster_design.png')
            ],
            text: 'Check out my new poster design!',
          ),
        );

        if (mounted) {
          displayInfoBar(context, builder: (context, close) {
            return const InfoBar(
              title: Text('Success'),
              content: Text('Design saved securely.'),
              severity: InfoBarSeverity.success,
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text('Error'),
            content: Text(e.toString()),
            severity: InfoBarSeverity.error,
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return material.Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: material.AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_design.title,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        leading: material.IconButton(
          icon: const Icon(FluentIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          material.IconButton(
            icon: const Icon(FluentIcons.save),
            onPressed: _isSaving ? null : _saveDesign,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() => _selectedElement = null),
                child: AspectRatio(
                  aspectRatio: 1, // Square for social media posts
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _design.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: material.Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
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
          _buildBottomToolbar(),
        ],
      ),
    );
  }

  Widget _buildDraggableElement(DesignElement element) {
    final isSelected = _selectedElement == element;

    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: GestureDetector(
        onTap: () => setState(() => _selectedElement = element),
        onDoubleTap: () {
          if (element.type == ElementType.text) {
            _showTextEditor(element);
          }
        },
        onPanUpdate: (details) {
          setState(() {
            element.position += details.delta;
          });
        },
        child: Container(
          width: element.size.width,
          height: element.size.height,
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: material.Colors.blue, width: 2)
                : null,
          ),
          child: Stack(
            children: [
              _buildElementContent(element),
              if (isSelected) ...[
                // Resize Handle
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        element.size = Size(
                          (element.size.width + details.delta.dx)
                              .clamp(20.0, 1000.0),
                          (element.size.height + details.delta.dy)
                              .clamp(20.0, 1000.0),
                        );
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: material.Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(material.Icons.zoom_out_map,
                          size: 10, color: material.Colors.white),
                    ),
                  ),
                ),
                // Delete Button
                Positioned(
                  left: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _design.elements.remove(element);
                        _selectedElement = null;
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: material.Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(material.Icons.close,
                          size: 14, color: material.Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElementContent(DesignElement element) {
    switch (element.type) {
      case ElementType.text:
        return Center(
          child: Text(
            element.text ?? '',
            textAlign: element.textAlign,
            style: element.textStyle?.copyWith(color: element.color),
          ),
        );
      case ElementType.image:
        return Image.network(
          element.imageUrl ?? '',
          fit: material.BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(FluentIcons.photo_error),
        );
      case ElementType.shape:
        return Container(
          decoration: BoxDecoration(
            color: element.color,
            borderRadius: BorderRadius.circular(element.borderRadius ?? 0),
          ),
        );
      case ElementType.sticker:
        return const Icon(FluentIcons.emoji2);
    }
  }

  Widget _buildBottomToolbar() {
    final bottomPadding = material.MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 20 + bottomPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: material.Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedElement != null) _buildEditingTools(),
          if (_selectedElement == null) _buildAddingTools(),
        ],
      ),
    );
  }

  Widget _buildAddingTools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _toolButton(FluentIcons.text_field, 'Text',
            () => _addElement(ElementType.text)),
        _toolButton(FluentIcons.photo2, 'Image', _pickImage),
        _toolButton(
            FluentIcons.shapes, 'Shape', () => _addElement(ElementType.shape)),
        _toolButton(FluentIcons.color, 'Background', _showBgColorPicker),
      ],
    );
  }

  Widget _buildEditingTools() {
    final element = _selectedElement!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (element.type == ElementType.text)
          _toolButton(FluentIcons.edit, 'Edit', () => _showTextEditor(element)),
        _toolButton(
            FluentIcons.color, 'Color', () => _showElementColorPicker(element)),
        if (element.type == ElementType.text)
          _toolButton(material.Icons.format_size, 'Size',
              () {}), // Implement slider later
        _toolButton(FluentIcons.delete, 'Delete', () {
          setState(() {
            _design.elements.remove(element);
            _selectedElement = null;
          });
        }),
      ],
    );
  }

  Widget _toolButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: material.Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: material.Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style:
                  GoogleFonts.inter(fontSize: 12, color: material.Colors.grey)),
        ],
      ),
    );
  }

  void _showBgColorPicker() {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Background Color'),
        content: material.SingleChildScrollView(
          child: cp.ColorPicker(
            pickerColor: _design.backgroundColor,
            onColorChanged: (color) => setState(() => _design = PosterDesign(
                  id: _design.id,
                  title: _design.title,
                  elements: _design.elements,
                  backgroundColor: color,
                  backgroundImageUrl: _design.backgroundImageUrl,
                )),
          ),
        ),
        actions: [
          FilledButton(
              child: const Text('Done'),
              onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  void _showElementColorPicker(DesignElement element) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Pick a Color'),
        content: material.SingleChildScrollView(
          child: cp.ColorPicker(
            pickerColor: element.color,
            onColorChanged: (color) => setState(() => element.color = color),
          ),
        ),
        actions: [
          FilledButton(
              child: const Text('Done'),
              onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
