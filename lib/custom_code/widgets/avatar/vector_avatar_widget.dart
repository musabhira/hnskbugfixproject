import 'package:flutter/material.dart';
import 'vector_avatar_config.dart';
import 'vector_avatar_painter.dart';

/// Reusable Widget for rendering 2D Vector Avatars
class VectorAvatarWidget extends StatelessWidget {
  final VectorAvatarConfig config;
  final double size;
  final bool showAura;
  final VoidCallback? onTap;
  final bool isInteractive;

  const VectorAvatarWidget({
    super.key,
    required this.config,
    this.size = 100.0,
    this.showAura = true,
    this.onTap,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: VectorAvatarPainter(
          config: config,
          showBackgroundAura: showAura,
        ),
      ),
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
