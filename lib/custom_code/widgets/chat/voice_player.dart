import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class VoiceMessagePlayer extends StatefulWidget {
  final String fileUrl;
  final int duration;
  final bool isFromCurrentUser;

  const VoiceMessagePlayer({
    super.key,
    required this.fileUrl,
    required this.duration,
    required this.isFromCurrentUser,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _duration = Duration(seconds: widget.duration);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(widget.fileUrl));
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on sender
    // Optimized for performance with const constants where possible
    final activeColor = widget.isFromCurrentUser ? Colors.black : Colors.yellow;
    final inactiveColor =
        widget.isFromCurrentUser ? Colors.black38 : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      width: 220, // Check constraints
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: activeColor,
              size: 36,
            ),
            onPressed: _togglePlay,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                    thumbColor: activeColor,
                    activeTrackColor: activeColor,
                    inactiveTrackColor: inactiveColor,
                  ),
                  child: Slider(
                    value: _position.inSeconds
                        .toDouble()
                        .clamp(0.0, _duration.inSeconds.toDouble()),
                    max: (_duration.inSeconds > 0)
                        ? _duration.inSeconds.toDouble()
                        : widget.duration.toDouble(),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(position);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.isFromCurrentUser
                              ? Colors.black54
                              : Colors.grey[600],
                        ),
                      ),
                      Text(
                        _formatDuration(_duration > Duration.zero
                            ? _duration
                            : Duration(seconds: widget.duration)),
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.isFromCurrentUser
                              ? Colors.black54
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
