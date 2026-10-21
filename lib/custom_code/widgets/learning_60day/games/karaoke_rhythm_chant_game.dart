import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import '../pocket_fortress_defense_service.dart';
import '../curriculum_data/pocket_90day_rhythm_chants_data.dart';

/// 🌟 Musical Note Floating Component for Flame Canvas
class MusicalParticle extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  final String noteChar;
  double life = 1.0;
  final double decay;

  MusicalParticle({
    required Vector2 position,
    required this.velocity,
    required this.color,
    required this.noteChar,
    this.decay = 1.4,
  }) : super(position: position);

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    life -= decay * dt;
    if (life <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (life <= 0) return;
    final textPainter = TextPainter(
      text: TextSpan(
        text: noteChar,
        style: TextStyle(
          color: color.withValues(alpha: life.clamp(0.0, 1.0)),
          fontSize: 22,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset.zero);
  }
}

class KaraokeChantFlameGame extends FlameGame {
  final math.Random _rng = math.Random();
  final List<String> notes = ['🎵', '🎶', '✨', '⭐', '🎤'];

  @override
  Color backgroundColor() => Colors.transparent;

  void spawnMusicalBurst(Vector2 center) {
    for (int i = 0; i < 15; i++) {
      final angle = _rng.nextDouble() * math.pi * 2;
      final speed = 80.0 + _rng.nextDouble() * 140.0;
      final note = notes[_rng.nextInt(notes.length)];
      final p = MusicalParticle(
        position: center.clone(),
        velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed - 60),
        color: _rng.nextBool() ? const Color(0xFFFF4081) : const Color(0xFF00E5FF),
        noteChar: note,
      );
      add(p);
    }
  }
}

/// 🎤 Full-Screen Karaoke Sing-Along & Fluency Rhythm Chant Game Page
class PocketKaraokeRhythmChantPage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketKaraokeRhythmChantPage({
    super.key,
    this.day = 1,
    this.userId,
    this.onStepFinished,
  });

  static Future<bool?> show(
    BuildContext context, {
    int day = 1,
    String? userId,
    Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKaraokeRhythmChantPage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketKaraokeRhythmChantPage> createState() =>
      _PocketKaraokeRhythmChantPageState();
}

class _PocketKaraokeRhythmChantPageState
    extends State<PocketKaraokeRhythmChantPage>
    with SingleTickerProviderStateMixin {
  late final KaraokeChantFlameGame _flameGame;
  final FlutterTts _flutterTts = FlutterTts();

  // Voice recording & playback controllers
  final AudioRecorder _audioRecorder = AudioRecorder();
  AudioPlayer? _userAudioPlayer;
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;
  String? _recordedFilePath;
  bool _isPlayingUserAudio = false;
  bool _hasRecorded = false;

  late final DayRhythmChantItem _chant;
  int _activeLyricIdx = -1;
  bool _isPlayingAppSong = false;
  // ignore: unused_field
  bool _hasListenedSong = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _flameGame = KaraokeChantFlameGame();
    _initTts();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _chant = Pocket90DayRhythmChantsData.getChantForDay(widget.day);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _recordTimer?.cancel();
    _audioRecorder.dispose();
    _userAudioPlayer?.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("en-IN");
      await _flutterTts.setSpeechRate(0.46);
      await _flutterTts.setPitch(1.08);
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_flutterTts);
    } catch (_) {}
  }

  Future<void> _playKaraokeSong() async {
    if (_isPlayingAppSong) return;
    setState(() {
      _isPlayingAppSong = true;
      _activeLyricIdx = 0;
    });

    final size = MediaQuery.of(context).size;
    PocketGameSfx.instance.playClick();

    for (int i = 0; i < _chant.lyrics.length; i++) {
      if (!mounted) return;
      setState(() => _activeLyricIdx = i);

      _flameGame.spawnMusicalBurst(Vector2(size.width / 2, size.height * 0.28));

      await _flutterTts.speak(_chant.lyrics[i]);
      // Small pause between rhythmic lines
      await Future.delayed(const Duration(milliseconds: 1400));
    }

    if (!mounted) return;
    setState(() {
      _isPlayingAppSong = false;
      _activeLyricIdx = -1;
      _hasListenedSong = true;
    });

    PocketGameSfx.instance.playVictory();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        HapticFeedback.mediumImpact();
        PocketGameSfx.instance.playClick();

        final dir = await getTemporaryDirectory();
        final fileName = 'karaoke_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _recordedFilePath = '${dir.path}/$fileName';

        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        await _audioRecorder.start(config, path: _recordedFilePath!);

        setState(() {
          _isRecording = true;
          _recordDuration = Duration.zero;
        });

        _recordTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
          if (mounted) {
            setState(() {
              _recordDuration += const Duration(milliseconds: 100);
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    try {
      final path = await _audioRecorder.stop();
      _recordTimer?.cancel();
      HapticFeedback.mediumImpact();
      PocketGameSfx.instance.playSnapCorrect();

      setState(() {
        _isRecording = false;
        _recordedFilePath = path ?? _recordedFilePath;
        _hasRecorded = true;
      });
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      setState(() => _isRecording = false);
    }
  }

  Future<void> _togglePlayUserRecording() async {
    if (_recordedFilePath == null) return;
    try {
      _userAudioPlayer ??= AudioPlayer();
      if (_isPlayingUserAudio) {
        await _userAudioPlayer!.stop();
        setState(() => _isPlayingUserAudio = false);
      } else {
        await _userAudioPlayer!.setFilePath(_recordedFilePath!);
        setState(() => _isPlayingUserAudio = true);
        _userAudioPlayer!.play();
        _userAudioPlayer!.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (mounted) setState(() => _isPlayingUserAudio = false);
          }
        });
      }
    } catch (e) {
      debugPrint('Error playing recorded song: $e');
      if (mounted) setState(() => _isPlayingUserAudio = false);
    }
  }

  Future<void> _completeStep() async {
    final uid = widget.userId ?? Supabase.instance.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pocket_day_${uid ?? "guest"}_${widget.day}_karaoke_done', true);
    await PocketFortressDefenseService.recordTrainingPoints(30, uid);

    widget.onStepFinished?.call(9);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C0B3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFFF4081), width: 2),
        ),
        title: Row(
          children: [
            const Text('🎤', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Day ${widget.day} Rhythm Star!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎉 You sang and chanted with native rhythm & earworm musical memory!',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF4081).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '+30 Fluency XP • Rhythm Chant Mastered!',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFF4081),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4081),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(true);
            },
            child: Text(
              'Continue Roadmap 🚀',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140727),
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _flameGame)),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildChantVinylHero(),
                        const SizedBox(height: 20),
                        _buildKaraokeLyricsCard(),
                        const SizedBox(height: 20),
                        _buildControls(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAY ${widget.day} • KARAOKE SING-ALONG CHANT',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFF4081),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  _chant.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4081).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF4081)),
            ),
            child: Text(
              '${_chant.beatBpm} BPM 🎵',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFF4081),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChantVinylHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A148C).withValues(alpha: 0.8),
            const Color(0xFF260D4E).withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF4081).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4081).withValues(alpha: 0.2),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (ctx, child) {
              final isAnimating = _isPlayingAppSong || _isRecording || _isPlayingUserAudio;
              final scale = isAnimating ? 1.0 + (_pulseController.value * 0.08) : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: _isRecording
                          ? [const Color(0xFFFF1744), const Color(0xFFD50000)]
                          : [const Color(0xFFFF4081), const Color(0xFF7B1FA2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? const Color(0xFFFF1744) : const Color(0xFFFF4081))
                            .withValues(alpha: 0.5),
                        blurRadius: 18,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _isRecording ? '🎙️' : (_isPlayingUserAudio ? '🎧' : '🎤'),
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            _chant.contextMl,
            style: GoogleFonts.notoSansMalayalam(
              color: const Color(0xFFE1BEE7),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildKaraokeLyricsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0E38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('📜', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'KARAOKE LYRICS (Sing Along)',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Listen to App Sing',
                icon: Icon(
                  _isPlayingAppSong ? Icons.volume_up : Icons.play_circle_fill,
                  color: const Color(0xFFFF4081),
                  size: 26,
                ),
                onPressed: _playKaraokeSong,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_chant.lyrics.length, (idx) {
            final isHighlight = _activeLyricIdx == idx;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isHighlight
                    ? const Color(0xFFFF4081).withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isHighlight ? const Color(0xFFFF4081) : Colors.white12,
                  width: isHighlight ? 2.0 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    isHighlight ? '▶️' : '🎵',
                    style: TextStyle(
                      fontSize: 16,
                      color: isHighlight ? const Color(0xFFFF4081) : Colors.white30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _chant.lyrics[idx],
                      style: GoogleFonts.outfit(
                        color: isHighlight ? Colors.white : Colors.white70,
                        fontSize: isHighlight ? 16 : 14,
                        fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final tenths = ((d.inMilliseconds % 1000) ~/ 100).toString();
    return '$minutes:$seconds.$tenths';
  }

  Widget _buildControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. App Singing Section
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B1FA2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 4,
          ),
          icon: Icon(_isPlayingAppSong ? Icons.volume_up : Icons.play_arrow_rounded, size: 24),
          label: Text(
            _isPlayingAppSong ? 'App Singing Along...' : 'Listen to Song Demo 🎵',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          onPressed: _isPlayingAppSong ? null : _playKaraokeSong,
        ),

        const SizedBox(height: 18),

        // 2. Studio Recording Booth Card
        // User Audio Directive: "പാട്ടുകൾ പാടിയിട്ട് റെക്കോർഡ് ചെയ്തിട്ട് അങ്ങോട്ട് ഇടണം, പാട്ട് പാടി ഇടുക"
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _isRecording
                    ? const Color(0xFF4A0010).withValues(alpha: 0.9)
                    : const Color(0xFF1E1035).withValues(alpha: 0.95),
                const Color(0xFF120822).withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isRecording
                  ? const Color(0xFFFF1744)
                  : (_hasRecorded ? const Color(0xFF00E676) : const Color(0xFF00E5FF).withValues(alpha: 0.4)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (_isRecording ? const Color(0xFFFF1744) : const Color(0xFF00E5FF))
                    .withValues(alpha: 0.15),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    _isRecording ? '🔴' : (_hasRecorded ? '✅' : '🎙️'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isRecording
                              ? 'RECORDING YOUR SINGING...'
                              : (_hasRecorded ? 'SONG RECORDED READY!' : 'SINGING STUDIO (Record Voice)'),
                          style: GoogleFonts.outfit(
                            color: _isRecording
                                ? const Color(0xFFFF5252)
                                : (_hasRecorded ? const Color(0xFF00E676) : const Color(0xFF00E5FF)),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          _isRecording
                              ? 'Sing clearly into mic now! 🎶'
                              : 'പാട്ട് പാടി റെക്കോർഡ് ചെയ്യുക (Sing into mic)',
                          style: GoogleFonts.notoSansMalayalam(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isRecording)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF1744).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFF1744)),
                      ),
                      child: Text(
                        _formatDuration(_recordDuration),
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFF5252),
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              if (!_isRecording && !_hasRecorded) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4081),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 6,
                  ),
                  icon: const Icon(Icons.mic, size: 26),
                  label: Text(
                    'Record My Singing Voice 🎤',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  onPressed: _startRecording,
                ),
              ] else if (_isRecording) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF1744),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 6,
                  ),
                  icon: const Icon(Icons.stop_circle, size: 28),
                  label: Text(
                    'Stop Recording ⏹️',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  onPressed: _stopRecording,
                ),
              ] else if (_hasRecorded) ...[
                // Playback and Re-record Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        icon: Icon(
                          _isPlayingUserAudio ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          size: 22,
                        ),
                        label: Text(
                          _isPlayingUserAudio ? 'Pause' : 'Play My Song ▶️',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                        onPressed: _togglePlayUserRecording,
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(
                        'Re-record',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12.5),
                      ),
                      onPressed: _startRecording,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 6,
                  ),
                  icon: const Icon(Icons.check_circle, size: 24),
                  label: Text(
                    'Submit Song & Complete Step 9 🚀',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15.5),
                  ),
                  onPressed: _completeStep,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
