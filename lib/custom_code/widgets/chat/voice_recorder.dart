import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VoiceMessageRecorder extends StatefulWidget {
  final String groupId;
  final String currentUserId;
  final Function(String messageType, String fileUrl, int duration)
      onSendMessage;

  const VoiceMessageRecorder({
    super.key,
    required this.groupId,
    required this.currentUserId,
    required this.onSendMessage,
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
    _audioRecorder.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        _path =
            '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig();
        await _audioRecorder.start(config, path: _path!);

        setState(() {
          _isRecording = true;
          _isCancelled = false;
          _dragOffset = 0.0;
          _duration = Duration.zero;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          setState(() {
            _duration += const Duration(seconds: 1);
          });
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stop() async {
    if (!_isRecording) return;

    try {
      final path = await _audioRecorder.stop();
      _timer?.cancel();

      final bool wasCancelled = _isCancelled || _dragOffset < -100;

      setState(() {
        _isRecording = false;
      });

      if (!wasCancelled && path != null && _duration.inSeconds > 0) {
        _uploadAndSend(path, _duration.inSeconds);
      } else if (path != null) {
        // Cancelled: Delete the file
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _uploadAndSend(String path, int duration) async {
    try {
      final file = File(path);
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final storagePath = '${widget.currentUserId}/$fileName';

      final supabase = Supabase.instance.client;
      await supabase.storage.from('voice-messages').upload(storagePath, file);
      final url =
          supabase.storage.from('voice-messages').getPublicUrl(storagePath);

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
      alignment: Alignment.centerRight,
      children: [
        if (_isRecording)
          Positioned(
            right: 60,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, color: Colors.red, size: 12),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(_duration),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '< Slide to cancel',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        GestureDetector(
          onLongPress: _start,
          onLongPressMoveUpdate: (details) {
            if (_isRecording) {
              setState(() {
                _dragOffset = details.localOffsetFromOrigin.dx;
                if (_dragOffset < -100) _isCancelled = true;
              });
            }
          },
          onLongPressUp: _stop,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            transform:
                Matrix4.translationValues(_dragOffset.clamp(-120.0, 0.0), 0, 0),
            decoration: BoxDecoration(
              color: _isCancelled
                  ? Colors.grey
                  : (_isRecording ? Colors.red : Colors.yellow),
              shape: BoxShape.circle,
              boxShadow: _isRecording
                  ? [
                      BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 5)
                    ]
                  : null,
            ),
            child: Icon(
              _isCancelled
                  ? Icons.delete_outline
                  : (_isRecording ? Icons.mic : Icons.mic_none),
              color:
                  (_isRecording || _isCancelled) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
