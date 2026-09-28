import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pocket_mates_app/flutter_flow/nav/nav.dart';

/// 🔔 In-App Floating Heads-Up Notification Banner Service
/// Displays a sleek, stacked floating notification at the top of the screen
/// (like iOS / Instagram in-app push) when a new message arrives.
class InAppNotificationService {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// Show a floating notification banner from anywhere in the app
  static void show({
    required String title,
    required String message,
    String? avatarUrl,
    bool isRobot = false,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlayState = appNavigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    // Dismiss existing notification if one is currently visible
    _dismissCurrent();

    // Haptic feedback for tactile feel
    HapticFeedback.lightImpact();

    _currentEntry = OverlayEntry(
      builder: (context) => _InAppNotificationWidget(
        title: title,
        message: message,
        avatarUrl: avatarUrl,
        isRobot: isRobot,
        onTap: () {
          _dismissCurrent();
          onTap?.call();
        },
        onDismiss: _dismissCurrent,
      ),
    );

    overlayState.insert(_currentEntry!);

    _dismissTimer = Timer(duration, () {
      _dismissCurrent();
    });
  }

  /// Dismiss the currently visible notification banner
  static void _dismissCurrent() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_currentEntry != null) {
      _currentEntry?.remove();
      _currentEntry = null;
    }
  }
}

class _InAppNotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? avatarUrl;
  final bool isRobot;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationWidget({
    required this.title,
    required this.message,
    this.avatarUrl,
    required this.isRobot,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationWidget> createState() =>
      _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<_InAppNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _dismissWithAnimation() {
    _animController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 14,
      right: 14,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.onTap,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! < -6) {
                  _dismissWithAnimation();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2C34).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF25D366).withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar / Icon
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: widget.avatarUrl != null &&
                                  widget.avatarUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: widget.avatarUrl!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => _buildFallbackAvatar(),
                                )
                              : _buildFallbackAvatar(),
                        ),
                        if (widget.isRobot)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF005C4B),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.smart_toy_rounded,
                                  color: Color(0xFF25D366), size: 10),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Title & Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'NOW',
                                  style: TextStyle(
                                    color: Color(0xFF25D366),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.message,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Dismiss button
                    GestureDetector(
                      onTap: _dismissWithAnimation,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: widget.isRobot ? const Color(0xFF005C4B) : const Color(0xFF2A3942),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        widget.isRobot ? Icons.smart_toy_rounded : Icons.person,
        color: widget.isRobot ? const Color(0xFF25D366) : Colors.white70,
        size: 20,
      ),
    );
  }
}
