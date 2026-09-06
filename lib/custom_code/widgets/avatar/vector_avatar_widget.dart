import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'flame_avatar_widget.dart';
import 'vector_avatar_config.dart';
import 'vector_avatar_painter.dart';

/// Reusable Widget for rendering 2D Vector Avatars & Network/Drawn Avatars
/// Automatically leverages the Flame Game Engine for interactive animations and aura particles!
class VectorAvatarWidget extends StatelessWidget {
  final VectorAvatarConfig? config;
  final double size;
  final bool showAura;
  final VoidCallback? onTap;
  final bool isInteractive;
  final BorderRadius? borderRadius;
  final bool? useFlame;

  const VectorAvatarWidget({
    super.key,
    this.config,
    this.size = 100.0,
    this.showAura = true,
    this.onTap,
    this.isInteractive = false,
    this.borderRadius,
    this.useFlame,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = config ?? const VectorAvatarConfig();
    final imgUrl = effectiveConfig.networkImageUrl ?? effectiveConfig.imageUrl;
    final drawingImg = effectiveConfig.customDrawingImage;

    Widget clipChild(Widget child) {
      if (borderRadius != null) {
        return ClipRRect(borderRadius: borderRadius!, child: child);
      }
      return ClipOval(child: child);
    }

    Widget innerContent;
    final bool isImageBased = (drawingImg != null && drawingImg.isNotEmpty) || (imgUrl != null && imgUrl.isNotEmpty);

    if (drawingImg != null && drawingImg.isNotEmpty) {
      if (drawingImg.startsWith('data:image')) {
        final base64Str = drawingImg.split(',').last;
        final bytes = base64Decode(base64Str);
        innerContent = clipChild(
          Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      } else {
        innerContent = clipChild(
          CachedNetworkImage(
            imageUrl: drawingImg,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
          ),
        );
      }
    } else if (imgUrl != null && imgUrl.isNotEmpty) {
      if (imgUrl.startsWith('assets/')) {
        innerContent = clipChild(
          Image.asset(
            imgUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => CustomPaint(
              size: Size(size, size),
              painter: VectorAvatarPainter(
                config: effectiveConfig,
                showBackgroundAura: false,
              ),
            ),
          ),
        );
      } else {
        innerContent = clipChild(
          CachedNetworkImage(
            imageUrl: imgUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: size,
              height: size,
              color: const Color(0xFF1E1E24),
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFFC00)),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => CustomPaint(
              size: Size(size, size),
              painter: VectorAvatarPainter(
                config: effectiveConfig,
                showBackgroundAura: false,
              ),
            ),
          ),
        );
      }
    } else {
      final shouldUseFlame = useFlame ?? (size >= 44);
      if (shouldUseFlame) {
        innerContent = FlameAvatarWidget(
          config: effectiveConfig,
          size: size,
          showAura: showAura,
          onTap: onTap,
          isInteractive: isInteractive,
          borderRadius: borderRadius,
        );
      } else {
        innerContent = CustomPaint(
          size: Size(size, size),
          painter: VectorAvatarPainter(
            config: effectiveConfig,
            showBackgroundAura: showAura,
            borderRadius: borderRadius,
          ),
        );
      }
    }

    Widget avatarWidget = isImageBased
        ? Container(
            width: size,
            height: size,
            decoration: showAura
                ? BoxDecoration(
                    shape: borderRadius != null ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFFC00).withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFFFFC00).withValues(alpha: 0.85),
                      width: size * 0.03,
                    ),
                  )
                : null,
            child: innerContent,
          )
        : SizedBox(
            width: size,
            height: size,
            child: innerContent,
          );

    if (onTap != null || isInteractive) {
      avatarWidget = GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}
