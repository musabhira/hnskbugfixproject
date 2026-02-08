import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VoiceMessageRecorder extends StatefulWidget {
  final String? groupId;
  final String? receiverId; // For personal chat
  final String currentUserId;
  final Function(String messageType, String fileUrl, int duration)
      onSendMessage;
  final Function(bool isRecording)? onRecordingStateChanged;

  const VoiceMessageRecorder({
    super.key,
    this.groupId,
    this.receiverId,
    required this.currentUserId,
    required this.onSendMessage,
    this.onRecordingStateChanged,
  });

  @override
  State<VoiceMessageRecorder> createState() => _VoiceMessageRecorderState();
}

class _VoiceMessageRecorderState extends State<VoiceMessageRecorder> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  Duration _duration = Duration.zero;
  Timer? _timer;
  String? _path;
  double _dragOffset = 0.0;
  bool _isCancelled = false;

  @override
  void dispose() {
    _audioPlayerCleanup();
    _audioRecorder.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _audioPlayerCleanup() async {
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.stop();
    }
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        HapticFeedback.mediumImpact();

        final dir = await getTemporaryDirectory();
        _path =
            '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        await _audioRecorder.start(config, path: _path!);

        if (mounted) {
          setState(() {
            _isRecording = true;
            _isCancelled = false;
            _dragOffset = 0.0;
            _duration = Duration.zero;
          });
          widget.onRecordingStateChanged?.call(true);
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

  Future<void> _stop({bool forceCancel = false}) async {
    if (!_isRecording) return;

    try {
      final path = await _audioRecorder.stop();
      _timer?.cancel();

      final bool wasCancelled =
          forceCancel || _isCancelled || _dragOffset < -100;

      if (mounted) {
        setState(() {
          _isRecording = false;
        });
        widget.onRecordingStateChanged?.call(false);
      }

      if (!wasCancelled && path != null && _duration.inMilliseconds > 200) {
        HapticFeedback.lightImpact();
        _uploadAndSend(path, _duration.inSeconds);
      } else if (path != null) {
        HapticFeedback.heavyImpact();
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      if (mounted) {
        setState(() => _isRecording = false);
        widget.onRecordingStateChanged?.call(false);
      }
    }
  }

  Future<void> _uploadAndSend(String path, int duration) async {
    try {
      final file = File(path);
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final storagePath = '${widget.currentUserId}/$fileName';

      final supabase = Supabase.instance.client;
      // Use voice-messages bucket for both, or respect current use
      const bucket = 'voice-messages';

      await supabase.storage.from(bucket).upload(storagePath, file);
      final url = supabase.storage.from(bucket).getPublicUrl(storagePath);

      widget.onSendMessage('voice', url, duration);
    } catch (e) {
      debugPrint('Error uploading voice: $e');
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (_isRecording)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2C34),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mic, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '< Slide to cancel',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(width: 48), // Space for the mic button itself
                ],
              ),
            ),
          ),
        GestureDetector(
          onLongPressStart: (_) => _start(),
          onLongPressMoveUpdate: (details) {
            if (_isRecording) {
              setState(() {
                _dragOffset = details.localOffsetFromOrigin.dx;
                if (_dragOffset < -100)
                  _isCancelled = true;
                else
                  _isCancelled = false;
              });
            }
          },
          onLongPressEnd: (_) => _stop(),
          child: AnimatedScale(
            scale: _isRecording ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
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
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        )
                      ]
                    : null,
              ),
              child: Icon(
                _isCancelled
                    ? Icons.delete_outline
                    : (_isRecording ? Icons.mic : Icons.mic_none),
                color: (_isRecording || _isCancelled)
                    ? Colors.white
                    : Colors.black,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
