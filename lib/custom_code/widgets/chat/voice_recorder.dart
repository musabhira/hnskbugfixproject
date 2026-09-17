import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

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

  bool _isRecording = false;
  Duration _duration = Duration.zero;
  Timer? _timer;
  String? _path;

  // Animation for recording indicator
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
            _duration = Duration.zero;
          });
          widget.onRecordingStateChanged(true);
        }

        _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
          if (mounted) {
            final nextDuration = _duration + const Duration(milliseconds: 100);
            if (nextDuration.inSeconds >= 30) {
              _stop(isCancel: false);
              return;
            }
            setState(() {
              _duration = nextDuration;
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
        });
        widget.onRecordingStateChanged(false);
      }

      if (!isCancel && path != null && _duration.inMilliseconds > 500) {
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

      if (mounted) {
        setState(() {
          _duration = Duration.zero;
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
    final seconds = d.inSeconds.clamp(0, 30);
    return '${seconds.toString().padLeft(2, '0')}/30s';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRecording) {
      return GestureDetector(
        onTap: _start,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFC00),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFFC00).withValues(alpha: 0.35),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.mic_rounded,
            color: Colors.black,
            size: 22,
          ),
        ),
      );
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF11141D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFFC00).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFFC00).withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cancel / Delete
          InkWell(
            onTap: () => _stop(isCancel: true),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 20),
            ),
          ),
          const SizedBox(width: 8),

          // Pulsing record dot
          FadeTransition(
            opacity: _animationController,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Duration
          Text(
            _formatDuration(_duration),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 10),

          // Live animated audio waveform bars
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 80, maxWidth: 160),
            child: SizedBox(
              height: 26,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(16, (index) {
                      final wave = math
                          .sin((_animationController.value * 2 * math.pi) +
                              (index * 0.45))
                          .abs();
                      final barHeight = (4.0 + (wave * 20.0)).clamp(4.0, 24.0);
                      return Container(
                        width: 2.6,
                        height: barHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFFC00),
                              index % 2 == 0
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFF00F0FF),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: () => _stop(isCancel: false),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFC00),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFFC00).withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
