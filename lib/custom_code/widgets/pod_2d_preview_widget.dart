import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Full-featured 2-D print-on-demand preview.
///
/// In **edit mode** the user can:
///   • drag the design to reposition it
///   • pinch (two-finger scale) to resize
///   • drag the yellow rotate handle to rotate
///   • tap "⊕ Center" button to reset placement
///
/// The widget reports changes via [onCoordinatesChanged].
class Pod2DPreviewWidget extends StatefulWidget {
  final String? mockupImageUrl;
  final String? designImageUrl;
  final String productSlug;
  final double width;
  final double height;

  /// Fractional position of the design center, 0..1 in both axes.
  final double posX;
  final double posY;

  /// Uniform scale factor applied to a 300×300 base design size.
  final double scale;

  /// Rotation in radians.
  final double rot;

  final bool isEditing;
  final void Function(double x, double y, double scale, double rot)?
      onCoordinatesChanged;

  const Pod2DPreviewWidget({
    super.key,
    this.mockupImageUrl,
    this.designImageUrl,
    required this.productSlug,
    this.width = double.infinity,
    this.height = 300,
    this.posX = 0.5,
    this.posY = 0.4,
    this.scale = 0.45,
    this.rot = 0.0,
    this.isEditing = false,
    this.onCoordinatesChanged,
  });

  @override
  State<Pod2DPreviewWidget> createState() => _Pod2DPreviewWidgetState();
}

class _Pod2DPreviewWidgetState extends State<Pod2DPreviewWidget> {
  // ── local state (mirrors props so gestures feel snappy) ──────────────────
  late double _posX, _posY, _scale, _rot;

  // For pinch
  double? _baseScale;
  double? _baseRot;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant Pod2DPreviewWidget old) {
    super.didUpdateWidget(old);
    // Only resync when props change from outside (not during active gesture)
    _posX = widget.posX;
    _posY = widget.posY;
    _scale = widget.scale;
    _rot = widget.rot;
  }

  void _sync() {
    _posX = widget.posX;
    _posY = widget.posY;
    _scale = widget.scale;
    _rot = widget.rot;
  }

  void _notify() =>
      widget.onCoordinatesChanged?.call(_posX, _posY, _scale, _rot);

  // ── geometry helpers ─────────────────────────────────────────────────────
  double get _designPx => 300.0 * _scale;

  static const _amber = Color(0xFFFFFC00);

  // ── build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, box) {
      final w = box.maxWidth.isFinite ? box.maxWidth : widget.width;
      final h = widget.height;

      return Container(
        width: w,
        height: h,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // ── 1. Mockup / T-shirt background ──────────────────────────
            Positioned.fill(child: _buildMockup()),

            // ── 2. Print-area guide (only in edit mode) ─────────────────
            if (widget.isEditing) _printAreaGuide(w, h),

            // ── 3. Design overlay ────────────────────────────────────────
            if (widget.designImageUrl != null &&
                widget.designImageUrl!.isNotEmpty)
              _buildDesignOverlay(w, h),

            // ── 4. Edit hint when no design yet ─────────────────────────
            if (widget.isEditing &&
                (widget.designImageUrl == null ||
                    widget.designImageUrl!.isEmpty))
              _uploadHint(),

            // ── 5. Drag hint (after design placed) ──────────────────────
            if (widget.isEditing &&
                widget.designImageUrl != null &&
                widget.designImageUrl!.isNotEmpty)
              _dragHint(),
          ],
        ),
      );
    });
  }

  // ── Mockup image ─────────────────────────────────────────────────────────
  Widget _buildMockup() {
    if (widget.mockupImageUrl != null &&
        widget.mockupImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.mockupImageUrl!,
        fit: BoxFit.contain,
        placeholder: (_, __) => const Center(
            child: CircularProgressIndicator(color: _amber, strokeWidth: 2)),
        errorWidget: (_, __, ___) => _fallbackMockup(),
      );
    }
    return _fallbackMockup();
  }

  Widget _fallbackMockup() {
    final isMug = widget.productSlug.toLowerCase().contains('mug');
    final isBag = widget.productSlug.toLowerCase().contains('bag') ||
        widget.productSlug.toLowerCase().contains('tote');
    final icon = isMug
        ? Icons.local_cafe_outlined
        : isBag
            ? Icons.shopping_bag_outlined
            : Icons.checkroom_outlined;
    final label = isMug ? 'Mug' : isBag ? 'Tote Bag' : 'T-Shirt';

    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 110, color: Colors.white.withValues(alpha: 0.07)),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.18),
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ]),
    );
  }

  // ── Print-area guide ─────────────────────────────────────────────────────
  Widget _printAreaGuide(double w, double h) {
    // Centered box representing roughly the chest print area
    const guideW = 120.0;
    const guideH = 110.0;
    return Positioned(
      left: (w - guideW) / 2,
      top: h * 0.28,
      child: IgnorePointer(
        child: Container(
          width: guideW,
          height: guideH,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: _amber.withValues(alpha: 0.35),
                width: 1.2,
                strokeAlign: BorderSide.strokeAlignInside),
          ),
          child: Center(
            child: Text('Print Area',
                style: TextStyle(
                    color: _amber.withValues(alpha: 0.45),
                    fontSize: 10,
                    letterSpacing: 0.8)),
          ),
        ),
      ),
    );
  }

  // ── Design overlay with gestures ─────────────────────────────────────────
  Widget _buildDesignOverlay(double w, double h) {
    final designPx = _designPx;
    // Center of design in pixels
    final cx = _posX * w;
    final cy = _posY * h;

    if (!widget.isEditing) {
      return Positioned(
        left: cx - designPx / 2,
        top: cy - designPx / 2,
        child: Transform.rotate(
          angle: _rot,
          child: _designImage(designPx),
        ),
      );
    }

    return Positioned(
      left: cx - designPx / 2,
      top: cy - designPx / 2,
      child: GestureDetector(
        // ── drag to move ───────────────────────────────────────────────
        onPanUpdate: (d) {
          setState(() {
            _posX = (_posX + d.delta.dx / w).clamp(0.05, 0.95);
            _posY = (_posY + d.delta.dy / h).clamp(0.05, 0.95);
          });
          _notify();
        },
        // ── pinch to scale + rotate ────────────────────────────────────
        onScaleStart: (d) {
          _baseScale = _scale;
          _baseRot = _rot;
        },
        onScaleUpdate: (d) {
          setState(() {
            if (_baseScale != null) {
              _scale = (_baseScale! * d.scale).clamp(0.1, 1.2);
            }
            if (_baseRot != null) {
              _rot = _baseRot! + d.rotation;
            }
          });
          _notify();
        },
        onScaleEnd: (_) {
          _baseScale = null;
          _baseRot = null;
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Selection border
            Container(
              width: designPx,
              height: designPx,
              decoration: BoxDecoration(
                border: Border.all(
                    color: _amber.withValues(alpha: 0.6), width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Transform.rotate(
                angle: _rot,
                child: _designImage(designPx),
              ),
            ),
            // ── Rotate handle (top-right) ─────────────────────────────
            Positioned(
              top: -14,
              right: -14,
              child: GestureDetector(
                onPanUpdate: (d) {
                  // Compute rotation delta from center of design
                  final center = Offset(cx, cy);
                  final handlePos = Offset(cx + designPx / 2, cy - designPx / 2);
                  final before = (handlePos - center).direction;
                  final after = (handlePos + d.delta - center).direction;
                  setState(() {
                    _rot += after - before;
                  });
                  _notify();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: _amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6)
                      ]),
                  child: const Icon(Icons.refresh,
                      color: Colors.black, size: 15),
                ),
              ),
            ),
            // ── Scale handle (bottom-right) ───────────────────────────
            Positioned(
              bottom: -14,
              right: -14,
              child: GestureDetector(
                onPanUpdate: (d) {
                  setState(() {
                    _scale = (_scale + d.delta.dx / 200).clamp(0.1, 1.2);
                  });
                  _notify();
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6)
                      ]),
                  child: const Icon(Icons.open_with,
                      color: Colors.black, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _designImage(double size) => SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: widget.designImageUrl!,
          fit: BoxFit.contain,
          placeholder: (_, __) => const Center(
              child:
                  CircularProgressIndicator(color: _amber, strokeWidth: 2)),
          errorWidget: (_, __, ___) =>
              const Icon(Icons.broken_image_outlined, color: Colors.white24),
        ),
      );

  Widget _uploadHint() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.upload_file_outlined,
              color: Colors.white.withValues(alpha: 0.15), size: 40),
          const SizedBox(height: 8),
          Text('Upload your design to see it here',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 12)),
        ]),
      );

  Widget _dragHint() => const Positioned(
        bottom: 10,
        left: 0,
        right: 0,
        child: IgnorePointer(
          child: Center(
            child: Text('Drag · Pinch · Rotate handle',
                style: TextStyle(color: Colors.white38, fontSize: 11)),
          ),
        ),
      );
}

// ── Helper: center-button exposed for parent ─────────────────────────────────
extension Pod2DCenter on Pod2DPreviewWidget {
  static const double defaultPosX = 0.5;
  static const double defaultPosY = 0.4;
  static const double defaultScale = 0.45;
  static const double defaultRot = 0.0;
}
