import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

/// Snapchat-style Ephemeral Snap Viewer Dialog
/// Provides high security:
/// - 1-time view countdown (burn after timer or closing)
/// - Anti-screenshot warning and full screen overlay
/// - View-once burn callback
class SnapViewDialog extends StatefulWidget {
  final String mediaUrl;
  final String senderName;
  final bool isMe;
  final int durationSeconds;
  final VoidCallback onBurned;

  const SnapViewDialog({
    super.key,
    required this.mediaUrl,
    required this.senderName,
    required this.isMe,
    this.durationSeconds = 8,
    required this.onBurned,
  });

  static Future<void> show({
    required BuildContext context,
    required String mediaUrl,
    required String senderName,
    required bool isMe,
    int durationSeconds = 8,
    required VoidCallback onBurned,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      pageBuilder: (context, anim1, anim2) => SnapViewDialog(
        mediaUrl: mediaUrl,
        senderName: senderName,
        isMe: isMe,
        durationSeconds: durationSeconds,
        onBurned: onBurned,
      ),
    );
  }

  @override
  State<SnapViewDialog> createState() => _SnapViewDialogState();
}

class _SnapViewDialogState extends State<SnapViewDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _remainingSeconds = 8;
  Timer? _countdownTimer;
  bool _hasBurned = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    )..forward();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        _burnAndClose();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });

    HapticFeedback.heavyImpact();
  }

  void _burnAndClose() {
    if (_hasBurned) return;
    _hasBurned = true;
    _countdownTimer?.cancel();
    widget.onBurned();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _burnAndClose();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Media Image
              Center(
                child: InteractiveViewer(
                  maxScale: 3.0,
                  child: CachedNetworkImage(
                    imageUrl: widget.mediaUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
                    ),
                    errorWidget: (context, url, error) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image_rounded, color: Colors.white54, size: 50),
                        const SizedBox(height: 8),
                        Text('Snap Expired or Unavailable',
                            style: GoogleFonts.outfit(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Top Progress Bar & Header
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Column(
                  children: [
                    // Linear progress line
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: 1.0 - _animController.value,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFFC00)),
                            minHeight: 3,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Color(0xFFFFFC00), size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.senderName} • ${_remainingSeconds}s',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // High Security View Once badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.security_rounded, color: Colors.redAccent, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                'VIEW ONCE 🔒',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Close & Burn button
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                          onPressed: _burnAndClose,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Bottom screenshot protection alert
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility_off_rounded, color: Color(0xFFFFFC00), size: 15),
                        const SizedBox(width: 8),
                        Text(
                          'Burns permanently after viewing. Protected Snap.',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
