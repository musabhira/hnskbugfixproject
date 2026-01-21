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
          _duration = Duration.zero;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          setState(() {
            _duration += const Duration(seconds: 1);
          });
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stop() async {
    try {
      final path = await _audioRecorder.stop();
      _timer?.cancel();
      setState(() {
        _isRecording = false;
      });

      if (path != null && _duration.inSeconds > 0) {
        _uploadAndSend(path, _duration.inSeconds);
      }
    } catch (e) {
      print('Error stopping recording: $e');
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
      print('Error uploading voice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _start,
      onLongPressUp: _stop,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red : Colors.yellow,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isRecording ? Icons.mic : Icons.mic_none,
          color: _isRecording ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
