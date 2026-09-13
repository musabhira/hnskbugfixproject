import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

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

/// A specialized Voice Note Player for AI / Pocket Robots.
/// Instead of streaming remote audio files, this renders an authentic
/// voice message bubble with speech synthesis (TTS) in crisp English,
/// animated waveforms, and play/pause controls.
class RobotVoiceMessagePlayer extends StatefulWidget {
  final String messageText;
  final int durationSeconds;
  final bool isFromCurrentUser;
  final Map<String, dynamic>? metadata;

  const RobotVoiceMessagePlayer({
    super.key,
    required this.messageText,
    required this.durationSeconds,
    required this.isFromCurrentUser,
    this.metadata,
  });

  @override
  State<RobotVoiceMessagePlayer> createState() => _RobotVoiceMessagePlayerState();
}

class _RobotVoiceMessagePlayerState extends State<RobotVoiceMessagePlayer>
    with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  int _currentSeconds = 0;
  Timer? _playbackTimer;
  bool _showTranscript = false;
  late final List<double> _barHeights;
  late AnimationController _waveAnimController;

  @override
  void initState() {
    super.initState();
    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Generate fixed randomized waveform bars based on text hash
    final seed = widget.messageText.hashCode;
    final rnd = math.Random(seed.abs());
    _barHeights = List.generate(24, (_) => 0.25 + (rnd.nextDouble() * 0.75));

    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.05);

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentSeconds = 0;
          });
          _waveAnimController.stop();
          _playbackTimer?.cancel();
        }
      });

      _flutterTts.setCancelHandler(() {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentSeconds = 0;
          });
          _waveAnimController.stop();
          _playbackTimer?.cancel();
        }
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('Robot TTS error: $msg');
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentSeconds = 0;
          });
          _waveAnimController.stop();
          _playbackTimer?.cancel();
        }
      });
    } catch (e) {
      debugPrint('Robot TTS init error: $e');
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _playbackTimer?.cancel();
    _waveAnimController.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    HapticFeedback.selectionClick();
    if (_isPlaying) {
      await _flutterTts.stop();
      _playbackTimer?.cancel();
      _waveAnimController.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentSeconds = 0;
        });
      }
    } else {
      if (widget.messageText.trim().isEmpty) return;
      setState(() {
        _isPlaying = true;
        _currentSeconds = 0;
      });
      _waveAnimController.repeat(reverse: true);

      final totalSec = math.max(2, widget.durationSeconds);
      _playbackTimer?.cancel();
      _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            if (_currentSeconds < totalSec) {
              _currentSeconds++;
            } else {
              timer.cancel();
            }
          });
        }
      });

      try {
        await _flutterTts.speak(widget.messageText);
      } catch (e) {
        debugPrint('Failed to speak robot voice note: $e');
        if (mounted) {
          setState(() => _isPlaying = false);
          _playbackTimer?.cancel();
          _waveAnimController.stop();
        }
      }
    }
  }

  String _formatSeconds(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final totalSec = math.max(2, widget.durationSeconds);
    final progress = (_currentSeconds / totalSec).clamp(0.0, 1.0);
    const accentYellow = Color(0xFFFFFC00);

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header badge
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: accentYellow.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  size: 13,
                  color: accentYellow,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'VOICE NOTE',
                style: GoogleFonts.inter(
                  color: accentYellow.withValues(alpha: 0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Optional transcript expander
              GestureDetector(
                onTap: () {
                  setState(() => _showTranscript = !_showTranscript);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showTranscript ? Icons.visibility_off : Icons.subtitles,
                        size: 11,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _showTranscript ? 'Hide' : 'Text',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Player controls and waveform
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Play/Pause button
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accentYellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accentYellow.withValues(alpha: _isPlaying ? 0.45 : 0.2),
                        blurRadius: _isPlaying ? 10 : 4,
                        spreadRadius: _isPlaying ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.black,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Animated Waveform
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 28,
                      child: AnimatedBuilder(
                        animation: _waveAnimController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(_barHeights.length, (index) {
                              final barRatio = (index + 1) / _barHeights.length;
                              final isPassed = barRatio <= progress;
                              final baseHeight = _barHeights[index] * 24;
                              final animOffset = _isPlaying
                                  ? math.sin((_waveAnimController.value * math.pi * 2) + (index * 0.4)) * 4
                                  : 0.0;
                              final h = (baseHeight + animOffset).clamp(4.0, 26.0);

                              return Container(
                                width: 3,
                                height: h,
                                decoration: BoxDecoration(
                                  color: isPassed
                                      ? accentYellow
                                      : Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Progress & Duration labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatSeconds(_currentSeconds),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatSeconds(totalSec),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white54,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Optional text transcript (hidden by default)
          if (_showTranscript) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Text(
                widget.messageText,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

