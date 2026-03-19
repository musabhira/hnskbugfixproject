import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
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
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRecording) {
      return GestureDetector(
        onTap: _start,
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Colors.yellow,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mic,
            color: Colors.black,
            size: 24,
          ),
        ),
      );
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121B22),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 24),
            onPressed: () => _stop(isCancel: true),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          FadeTransition(
            opacity: _animationController,
            child: const Icon(Icons.circle, color: Colors.red, size: 10),
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(_duration),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _stop(isCancel: false),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.black, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
