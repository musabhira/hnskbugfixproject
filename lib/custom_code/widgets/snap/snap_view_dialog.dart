import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_snap_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';

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

  final String? caption;

  const SnapViewDialog({
    super.key,
    required this.mediaUrl,
    required this.senderName,
    required this.isMe,
    this.durationSeconds = 8,
    required this.onBurned,
    this.caption,
  });

  static Future<void> show({
    required BuildContext context,
    required String mediaUrl,
    required String senderName,
    required bool isMe,
    int durationSeconds = 8,
    required VoidCallback onBurned,
    String? caption,
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
        caption: caption,
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
  FlutterTts? _tts;

  bool get _isTextSnap =>
      widget.mediaUrl.isEmpty ||
      widget.mediaUrl == 'vibe_text' ||
      widget.mediaUrl.startsWith('text') ||
      !widget.mediaUrl.startsWith('http');

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    )..forward();

    if (_isTextSnap) {
      _tts = FlutterTts();
      PocketVoiceService.instance.configureOptimalFemaleVoice(_tts!).catchError((_) {
        _tts?.setLanguage('en-IN');
        _tts?.setSpeechRate(0.48);
      });
    }

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
    _tts?.stop();
    // ⚡ On Seen: immediately remove image file from Supabase storage on the spot
    if (widget.mediaUrl.startsWith('http')) {
      unawaited(PocketSnapService.purgeSnapStorage(widget.mediaUrl));
    }
    widget.onBurned();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animController.dispose();
    _tts?.stop();
    super.dispose();
  }

  Widget _buildTextVibeCard() {
    final text = (widget.caption != null && widget.caption!.trim().isNotEmpty)
        ? widget.caption!
        : (widget.mediaUrl.startsWith('text:')
            ? widget.mediaUrl.substring(5)
            : '🌟 Keep practicing your spoken English every day!');

    final seed = text.hashCode.abs();
    // Rich green and yellow/amber gradients matching user audio directive
    final gradients = [
      [const Color(0xFF064E3B), const Color(0xFF047857), const Color(0xFF059669)], // Emerald Green
      [const Color(0xFF78350F), const Color(0xFFB45309), const Color(0xFFD97706)], // Warm Amber Yellow
      [const Color(0xFF14532D), const Color(0xFF15803D), const Color(0xFF16A34A)], // Forest Green
      [const Color(0xFF713F12), const Color(0xFFA16207), const Color(0xFFEAB308)], // Golden Sun
    ];
    final selectedGradient = gradients[seed % gradients.length];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: selectedGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 70),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'POCKET MATE VIBE SNAP',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // TTS Listen Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        await _tts?.stop();
                        await _tts?.speak(text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: const Color(0xFFFFD700),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFFFD700), width: 1.2),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      icon: const Icon(Icons.volume_up_rounded, size: 18, color: Color(0xFFFFD700)),
                      label: Text(
                        '👂 Listen / കേൾക്കുക',
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              // 1. Media Image OR Full-Screen Text Vibe Snap
              Center(
                child: _isTextSnap
                    ? _buildTextVibeCard()
                    : InteractiveViewer(
                        maxScale: 3.0,
                        child: CachedNetworkImage(
                          imageUrl: widget.mediaUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(color: Color(0xFFFFFC00)),
                          ),
                          errorWidget: (context, url, error) => _buildTextVibeCard(),
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

              // 3. Snapchat-style Caption Banner (Only for image/media snaps, NOT text vibe cards)
              if (!_isTextSnap && widget.caption != null && widget.caption!.trim().isNotEmpty)
                Positioned(
                  bottom: 70,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.caption!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

              // 4. Bottom screenshot protection alert
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
