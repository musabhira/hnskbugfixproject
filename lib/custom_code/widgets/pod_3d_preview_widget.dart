import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

/// A robust 3D product preview using model_viewer_plus.
/// Renders a GLB model reliably without custom Three.js scripts.
class Pod3DPreviewWidget extends StatefulWidget {
  final String glbUrl;
  final String? localGlbPath;
  final String? designImageUrl;
  final String productSlug;
  final double width;
  final double height;
  final bool autoRotate;
  final Function(double x, double y, double z, double scale, double rot)? onCoordinatesChanged;

  const Pod3DPreviewWidget({
    super.key,
    required this.glbUrl,
    this.localGlbPath,
    this.designImageUrl,
    required this.productSlug,
    required this.width,
    required this.height,
    this.autoRotate = true,
    this.onCoordinatesChanged,
  });

  @override
  State<Pod3DPreviewWidget> createState() => Pod3DPreviewWidgetState();
}

class Pod3DPreviewWidgetState extends State<Pod3DPreviewWidget> {
  @override
  void initState() {
    super.initState();
  }

  /// Apply a new design texture dynamically
  Future<void> applyDesign(String designUrl) async {
    // Advanced texture mapping is handled natively or skipped if using plain ModelViewer.
  }

  /// Update decal scale dynamically
  Future<void> updateScale(double scale) async {
    // Advanced decal scaling is handled natively or skipped if using plain ModelViewer.
  }

  @override
  Widget build(BuildContext context) {
    // Use local path with asset:// scheme if provided, else fallback to network URL.
    final src = (widget.localGlbPath != null && widget.localGlbPath!.isNotEmpty)
        ? 'asset://${widget.localGlbPath}'
        : widget.glbUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ModelViewer(
          backgroundColor: const Color(0xFF0A0A0A),
          src: src,
          alt: "3D Product Preview",
          autoRotate: widget.autoRotate,
          cameraControls: true,
          disableZoom: false,
          autoPlay: true,
        ),
      ),
    );
  }
}
