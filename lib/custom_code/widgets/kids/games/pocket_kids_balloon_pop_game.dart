import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

/// 🎈 Balloon Pop Spelling & Phonics Game (Ages 4-8)
///
/// Features:
/// - Floating pastel letter balloons in dedicated play arena (no HUD overlap).
/// - Instant responsive tap with pop burst animation and audio.
/// - Accurate sequential word spelling (C - A - T, S - U - N, etc.).
/// - Visual hint: the needed letter balloon has a subtle gold glow.
/// - 5 progressive word rounds, multi-round trophy celebration.
class PocketKidsBalloonPopGame extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsBalloonPopGame({
    super.key,
    this.day = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsBalloonPopGame(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsBalloonPopGame> createState() =>
      _PocketKidsBalloonPopGameState();
}

class _BalloonTargetWord {
  final String word;
  final String emoji;
  final String meaningMl;

  const _BalloonTargetWord({
    required this.word,
    required this.emoji,
    required this.meaningMl,
  });
}

class _BalloonItem {
  final int id;
  final String letter;
  final Color color;
  double x; // 0.05 to 0.82
  double y; // 0.05 to 0.90
  double speed;
  double swayOffset;
  bool isPopped;
  bool showBurst;

  _BalloonItem({
    required this.id,
    required this.letter,
    required this.color,
    required this.x,
    required this.y,
    required this.speed,
    required this.swayOffset,
    this.isPopped = false,
    this.showBurst = false,
  });
}

class _PocketKidsBalloonPopGameState extends State<PocketKidsBalloonPopGame>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late AnimationController _floatTicker;

  final List<_BalloonTargetWord> _wordRounds = const [
    _BalloonTargetWord(word: 'CAT', emoji: '🐱', meaningMl: 'പൂച്ച'),
    _BalloonTargetWord(word: 'SUN', emoji: '☀️', meaningMl: 'സൂര്യൻ'),
    _BalloonTargetWord(word: 'STAR', emoji: '⭐', meaningMl: 'നക്ഷത്രം'),
    _BalloonTargetWord(word: 'FROG', emoji: '🐸', meaningMl: 'തവള'),
    _BalloonTargetWord(word: 'LION', emoji: '🦁', meaningMl: 'സിംഹം'),
  ];

  int _roundIndex = 0;
  int _letterIndex = 0;
  int _score = 0;
  int _combo = 0;

  final List<_BalloonItem> _balloons = [];
  final math.Random _rng = math.Random();
  int _nextBalloonId = 1;

  final List<Color> _balloonColors = const [
    Color(0xFFFF6B81), // Coral pink
    Color(0xFF38BDF8), // Sky blue
    Color(0xFFFBBF24), // Amber yellow
    Color(0xFF34D399), // Mint green
    Color(0xFFA78BFA), // Pastel lavender
    Color(0xFFFB923C), // Peach orange
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    _startRound();

    // 30fps smooth float ticker
    _floatTicker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tickFloat);
    _floatTicker.repeat();
  }

  @override
  void dispose() {
    _floatTicker.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.35);
      await _tts.setSpeechRate(0.42);
    } catch (_) {}
  }

  void _startRound() {
    _letterIndex = 0;
    _balloons.clear();
    final currentWord = _wordRounds[_roundIndex].word;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.stop();
      _tts.speak("Find letter ${currentWord[0]}!");
    });

    final neededLetters = currentWord.split('');
    final distractors = ['B', 'P', 'T', 'M', 'D', 'K', 'R', 'O', 'E', 'H'];

    final pool = <String>[...neededLetters];
    for (int i = 0; i < 4; i++) {
      pool.add(distractors[_rng.nextInt(distractors.length)]);
    }
    pool.shuffle(_rng);

    for (int i = 0; i < pool.length; i++) {
      _balloons.add(
        _BalloonItem(
          id: _nextBalloonId++,
          letter: pool[i],
          color: _balloonColors[_rng.nextInt(_balloonColors.length)],
          x: 0.08 + (_rng.nextDouble() * 0.72),
          y: 0.15 + (i * 0.12).clamp(0.0, 0.75),
          speed: 0.0012 + (_rng.nextDouble() * 0.0010),
          swayOffset: _rng.nextDouble() * math.pi * 2,
        ),
      );
    }
    setState(() {});
  }

  void _tickFloat() {
    if (!mounted) return;
    setState(() {
      for (final b in _balloons) {
        if (!b.isPopped) {
          b.y -= b.speed;
          if (b.y < -0.12) {
            b.y = 1.05;
            b.x = 0.08 + (_rng.nextDouble() * 0.72);
          }
        }
      }
    });
  }

  void _onTapBalloon(_BalloonItem balloon) {
    if (balloon.isPopped) return;

    final currentWord = _wordRounds[_roundIndex].word;
    final expectedLetter = currentWord[_letterIndex];

    if (balloon.letter.toUpperCase() == expectedLetter.toUpperCase()) {
      // 🌟 Correct Pop!
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playPopSound();

      setState(() {
        balloon.showBurst = true;
        balloon.isPopped = true;
        _score += 10 + (_combo * 5);
        _combo++;
        _letterIndex++;
      });

      // Hide burst particles after 350ms
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => balloon.showBurst = false);
      });

      _tts.stop();
      _tts.speak("${balloon.letter}! Superstar!");

      // Word completed check
      if (_letterIndex >= currentWord.length) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _onWordCompleted();
        });
      } else {
        // Prompt next letter
        final nextLetter = currentWord[_letterIndex];
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted && _letterIndex < currentWord.length) {
            _tts.speak("Now find letter $nextLetter!");
          }
        });
      }
    } else {
      // ⚠️ Wrong letter
      HapticFeedback.selectionClick();
      PocketGameAudioService.instance.playPopSound();
      setState(() => _combo = 0);
      _tts.stop();
      _tts.speak("Look for letter $expectedLetter!");
    }
  }

  void _onWordCompleted() async {
    HapticFeedback.heavyImpact();
    PocketGameSFX.playCorrectChime();

    await PocketKidsService.addKidsScore(15);
    await PocketKidsService.addKidStars(1);

    final round = _wordRounds[_roundIndex];

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFFBBF24), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(round.emoji, style: const TextStyle(fontSize: 54)),
              const SizedBox(height: 8),
              Text(
                'SUPERSTAR! 🌟',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF78350F),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You spelled "${round.word}"!',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                '${round.meaningMl} • +15 KS ⭐',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (_roundIndex < _wordRounds.length - 1) {
                    setState(() {
                      _roundIndex++;
                      _startRound();
                    });
                  } else {
                    _onAllRoundsCompleted();
                  }
                },
                child: Text(
                  _roundIndex < _wordRounds.length - 1
                      ? 'Next Word ▶'
                      : 'Finish Game 🏆',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAllRoundsCompleted() async {
    PocketGameSFX.playVictoryFanfare();
    await PocketKidsService.addKidsScore(30);
    await PocketKidsService.addKidStars(2);
    widget.onCompleted?.call();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF10B981), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎈 🏆 🎈', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                'Balloon Pop Master!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You completed all 5 words!\nEarned +45 KS & 3 Star Cookies! ⭐',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Text(
                  'Back to Arcade 🎮',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
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
    final currentRound = _wordRounds[_roundIndex];
    final currentWord = currentRound.word;
    final expectedLetter = _letterIndex < currentWord.length
        ? currentWord[_letterIndex]
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // Soft mint pastel sky
      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // 1. TOP HUD (NON-OVERLAPPING)
            // =================================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Column(
                children: [
                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.close_rounded, color: Color(0xFF0F172A), size: 20),
                        ),
                      ),

                      // Round & Score Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Round ${_roundIndex + 1}/5',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('⭐', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 3),
                            Text(
                              '$_score',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Pronounce prompt button
                      GestureDetector(
                        onTap: () {
                          _tts.stop();
                          _tts.speak("Find letter $expectedLetter!");
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Target Word HUD Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF34D399), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(currentRound.emoji, style: const TextStyle(fontSize: 26)),
                            const SizedBox(width: 8),
                            Text(
                              'Pop the balloons to spell:',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Letter Slots
                        Wrap(
                          spacing: 8,
                          children: List.generate(currentWord.length, (idx) {
                            final isFilled = idx < _letterIndex;
                            final isNext = idx == _letterIndex;
                            final char = currentWord[idx];

                            return Container(
                              width: 44,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isFilled
                                    ? const Color(0xFF10B981)
                                    : isNext
                                        ? const Color(0xFFFEF3C7)
                                        : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isNext
                                      ? const Color(0xFFF59E0B)
                                      : isFilled
                                          ? const Color(0xFF059669)
                                          : const Color(0xFFCBD5E1),
                                  width: isNext ? 2.5 : 1.5,
                                ),
                              ),
                              child: Text(
                                isFilled ? char : (isNext ? '?' : '_'),
                                style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: isFilled
                                      ? Colors.white
                                      : isNext
                                          ? const Color(0xFFB45309)
                                          : const Color(0xFF94A3B8),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =================================================================
            // 2. DEDICATED BALLOON ARENA (EXPANDED - NO OVERLAP)
            // =================================================================
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final arenaW = constraints.maxWidth;
                  final arenaH = constraints.maxHeight;

                  return Stack(
                    children: [
                      // Clouds
                      Positioned(
                        top: 20,
                        left: 15,
                        child: Opacity(
                          opacity: 0.35,
                          child: Text('☁️', style: TextStyle(fontSize: arenaW * 0.14)),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        right: 20,
                        child: Opacity(
                          opacity: 0.35,
                          child: Text('☁️', style: TextStyle(fontSize: arenaW * 0.12)),
                        ),
                      ),

                      // Floating Balloons
                      ..._balloons.map((b) {
                        if (b.isPopped && !b.showBurst) {
                          return const SizedBox.shrink();
                        }

                        final balloonX = (b.x * arenaW) +
                            (math.sin((b.y * 10) + b.swayOffset) * 10.0);
                        final balloonY = b.y * arenaH;

                        // Burst animation state
                        if (b.showBurst) {
                          return Positioned(
                            left: balloonX.clamp(10.0, arenaW - 80.0),
                            top: balloonY.clamp(0.0, arenaH - 80.0),
                            child: _buildBurstWidget(),
                          );
                        }

                        final isTargetLetter = expectedLetter.isNotEmpty &&
                            b.letter.toUpperCase() == expectedLetter.toUpperCase();

                        return Positioned(
                          left: balloonX.clamp(10.0, arenaW - 80.0),
                          top: balloonY.clamp(0.0, arenaH - 95.0),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _onTapBalloon(b),
                            child: _buildBalloonWidget(b, isTargetLetter),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBurstWidget() {
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      child: const Text('💥 ✨', style: TextStyle(fontSize: 38)),
    );
  }

  Widget _buildBalloonWidget(_BalloonItem b, bool isTargetLetter) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 78,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: b.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(34),
                topRight: Radius.circular(34),
                bottomLeft: Radius.circular(34),
                bottomRight: Radius.circular(34),
              ),
              border: isTargetLetter
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isTargetLetter
                      ? const Color(0xFFFFD700).withValues(alpha: 0.6)
                      : b.color.withValues(alpha: 0.4),
                  blurRadius: isTargetLetter ? 14 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Highlight shine
                Positioned(
                  top: 8,
                  left: 12,
                  child: Container(
                    width: 12,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  b.letter,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Balloon knot and string
          Container(
            width: 8,
            height: 5,
            decoration: BoxDecoration(
              color: b.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: 1.5,
            height: 14,
            color: Colors.grey.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}
