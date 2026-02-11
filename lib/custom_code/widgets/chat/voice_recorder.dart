import 'dart:async';
import 'dart:async';
import 'dart:io';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceMessageRecorder extends StatefulWidget {
  final Function(String path, int duration) onSendMessage;
  final Function(bool isRecording) onRecordingStateChanged;

  const VoiceMessageRecorder({
    super.key,
    required this.onSendMessage,
    required this.onRecordingStateChanged,
  });

  @override
  State<VoiceMessageRecorder> createState() => _VoiceMessageRecorderState();
}

class _VoiceMessageRecorderState extends State<VoiceMessageRecorder>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();

  // State
  bool _isRecording = false;
  bool _isLocked = false;
  bool _isCancelled = false;
  Duration _duration = Duration.zero;
  Timer? _timer;
  String? _path;

  // Gestures
  double _dragOffset = 0.0; // Horizontal drag (cancel)
  double _lockDragOffset = 0.0; // Vertical drag (lock)

  // Animation
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        HapticFeedback.mediumImpact();

        final dir = await getTemporaryDirectory();
        final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _path = '${dir.path}/$fileName';

        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        await _audioRecorder.start(config, path: _path!);

        if (mounted) {
          setState(() {
            _isRecording = true;
            _isLocked = false;
            _isCancelled = false;
            _dragOffset = 0.0;
            _lockDragOffset = 0.0;
            _duration = Duration.zero;
          });
          widget.onRecordingStateChanged(true);
        }

        _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
          if (mounted) {
            setState(() {
              _duration += const Duration(milliseconds: 100);
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stop({bool isCancel = false}) async {
    if (!_isRecording) return;

    try {
      final path = await _audioRecorder.stop();
      _timer?.cancel();

      if (mounted) {
        setState(() {
          _isRecording = false;
          _isLocked = false;
        });
        widget.onRecordingStateChanged(false);
      }

      if (!isCancel &&
          !_isCancelled &&
          path != null &&
          _duration.inMilliseconds > 500) {
        // Send
        HapticFeedback.lightImpact();
        widget.onSendMessage(path, _duration.inSeconds);
      } else {
        // Cancel logic
        HapticFeedback.mediumImpact();
        if (path != null) {
          final file = File(path);
          if (await file.exists()) await file.delete();
        }
      }

      // Reset state used for UI
      if (mounted) {
        setState(() {
          _duration = Duration.zero;
          _dragOffset = 0;
          _lockDragOffset = 0;
        });
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      if (mounted) {
        setState(() => _isRecording = false);
        widget.onRecordingStateChanged(false);
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // When recording, we expand effectively taking up the Row's space (sibling Expanded shrinks)
    final desiredWidth = MediaQuery.of(context).size.width - 60;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isRecording ? desiredWidth : 50,
      height: 50,
      decoration: BoxDecoration(
        color: _isRecording
            ? const Color(0xFF1F2C34)
            : Colors.transparent, // Only bg when recording
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: [
          // 1. Sliding Cancellation UI (Visible when recording but NOT locked)
          if (_isRecording && !_isLocked)
            Positioned(
                right: 60, // Left of the mic button
                left: 10,
                top: 0,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Timer & Icon
                    Row(
                      children: [
                        FadeTransition(
                          opacity: _animationController,
                          child: const Icon(Icons.mic,
                              color: Colors.red, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(_duration),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),
                    // Cancel Text
                    const Text(
                      '< Slide to cancel',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                )),

          // 2. Locked UI (Visible when Locked) - Replaces everything
          if (_isLocked)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Delete / Cancel Button
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 28),
                      onPressed: () => _stop(isCancel: true),
                    ),

                    // Timer
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),

                    // Send Button (Replaces Mic)
                    GestureDetector(
                      onTap: () => _stop(isCancel: false),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. The Details (Mic Button Trigger)
          // Visible only when NOT locked.
          if (!_isLocked)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onLongPressStart: (_) => _start(),
                onLongPressMoveUpdate: (details) {
                  if (_isRecording) {
                    setState(() {
                      // Robust drag detection
                      _dragOffset = details.localOffsetFromOrigin.dx;
                      _lockDragOffset = details.localOffsetFromOrigin.dy;

                      if (_dragOffset < -100)
                        _isCancelled = true;
                      else
                        _isCancelled = false;

                      // Swipe UP to Lock (-Y)
                      if (_lockDragOffset < -60) {
                        _isLocked = true;
                        HapticFeedback.heavyImpact();
                      }
                    });
                  }
                },
                onLongPressEnd: (_) {
                  if (!_isLocked) {
                    _stop(isCancel: _isCancelled);
                  }
                },
                onLongPressCancel: () {
                  if (!_isLocked) _stop(isCancel: true);
                },
                child: Transform.translate(
                  offset: _isRecording
                      ? Offset(0, _lockDragOffset.clamp(-60.0, 0.0).toDouble())
                      : Offset.zero,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _isCancelled
                          ? Colors.grey
                          : (_isRecording ? Colors.red : Colors.yellow),
                      shape: BoxShape.circle,
                      boxShadow: _isRecording
                          ? [
                              BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  blurRadius: 15)
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lock Hint
                        if (_isRecording && _lockDragOffset < -10)
                          const Icon(Icons.lock_open,
                              size: 12, color: Colors.white),

                        Icon(
                          _isCancelled ? Icons.delete_outline : Icons.mic,
                          color: (_isRecording || _isCancelled)
                              ? Colors.white
                              : Colors.black,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}