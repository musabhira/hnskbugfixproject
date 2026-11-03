import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 1. 🔤 LETTER SOUND QUEST (Flame 2D Phonics & Acoustic Sound Match)
/// Children listen to acoustic phonics phonemes and tap flying star bubbles
class LetterSoundQuestGame extends FlameGame {
  final VoidCallback onStarCollected;
  LetterSoundQuestGame({required this.onStarCollected});

  @override
  Color backgroundColor() => Colors.transparent;

  void spawnSparkles(Vector2 pos) {
    for (int i = 0; i < 12; i++) {
      add(_QuestSparkleParticle(pos));
    }
  }
}

class _QuestSparkleParticle extends PositionComponent {
  final math.Random _rng = math.Random();
  late Vector2 _vel;
  double _life = 1.0;
  final Color _color;

  _QuestSparkleParticle(Vector2 startPos)
      : _color = [
          const Color(0xFFFFD700),
          const Color(0xFFFF2D55),
          const Color(0xFF00C7BE),
          const Color(0xFF34C759)
        ][math.Random().nextInt(4)],
        super(position: startPos.clone(), size: Vector2.all(8)) {
    final angle = _rng.nextDouble() * 2 * math.pi;
    final speed = 60.0 + _rng.nextDouble() * 120.0;
    _vel = Vector2(math.cos(angle) * speed, math.sin(angle) * speed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _vel * dt;
    _life -= dt * 1.5;
    if (_life <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (_life <= 0) return;
    final paint = Paint()
      ..color = _color.withValues(alpha: _life.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 4.0 * _life, paint);
  }
}

class PocketKidsLetterSoundQuestPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsLetterSoundQuestPage({
    super.key,
    required this.day,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required int day,
    VoidCallback? onCompleted,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PocketKidsLetterSoundQuestPage(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsLetterSoundQuestPage> createState() =>
      _PocketKidsLetterSoundQuestPageState();
}

class _PocketKidsLetterSoundQuestPageState
    extends State<PocketKidsLetterSoundQuestPage> {
  final FlutterTts _tts = FlutterTts();
  late LetterSoundQuestGame _flameGame;

  int _roundIndex = 0;
  bool _isAnswered = false;
  int _score = 0;

  // Curated 5 questions per session based on Day & Phonics groups
  final List<Map<String, dynamic>> _questions = [
    {
      'phoneme': '/æ/',
      'soundPrompt': 'Listen carefully! Find the sound /æ/ as in Apple!',
      'targetLetter': 'A',
      'word': 'Apple 🍎',
      'meaningMl': 'ആപ്പിൾ',
      'meaningHi': 'सेब',
      'options': ['A', 'B', 'P', 'T'],
    },
    {
      'phoneme': '/b/',
      'soundPrompt': 'Find the bouncing sound /b/ as in Ball!',
      'targetLetter': 'B',
      'word': 'Ball ⚽',
      'meaningMl': 'പന്ത്',
      'meaningHi': 'गेंद',
      'options': ['D', 'B', 'P', 'R'],
    },
    {
      'phoneme': '/k/',
      'soundPrompt': 'Find the sound /k/ as in Cat!',
      'targetLetter': 'C',
      'word': 'Cat 🐱',
      'meaningMl': 'പൂച്ച',
      'meaningHi': 'बिल्ली',
      'options': ['S', 'C', 'K', 'O'],
    },
    {
      'phoneme': '/d/',
      'soundPrompt': 'Find the sound /d/ as in Dog!',
      'targetLetter': 'D',
      'word': 'Dog 🐶',
      'meaningMl': 'പട്ടി',
      'meaningHi': 'कुत्ता',
      'options': ['B', 'P', 'D', 'Q'],
    },
    {
      'phoneme': '/e/',
      'soundPrompt': 'Find the sound /e/ as in Elephant!',
      'targetLetter': 'E',
      'word': 'Elephant 🐘',
      'meaningMl': 'ആന',
      'meaningHi': 'हाथी',
      'options': ['I', 'A', 'E', 'F'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _flameGame = LetterSoundQuestGame(onStarCollected: () {});
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.38); // Gentle slow tempo for kids
      await _tts.setPitch(1.15); // Friendly cartoon voice
    } catch (_) {}
    _playCurrentPrompt();
  }

  Future<void> _playCurrentPrompt() async {
    final q = _questions[_roundIndex];
    await _tts.stop();
    await _tts.speak(q['soundPrompt'] as String);
  }

  void _handleChoice(String letter) async {
    if (_isAnswered) return;
    final q = _questions[_roundIndex];
    final bool isCorrect = letter == q['targetLetter'];

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playCoinSound();
      _flameGame.spawnSparkles(Vector2(200, 300));
      setState(() {
        _isAnswered = true;
        _score += 10;
      });
      await _tts.speak("Super! $letter sounds like ${q['word']}!");

      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;

      if (_roundIndex + 1 < _questions.length) {
        setState(() {
          _roundIndex++;
          _isAnswered = false;
        });
        _playCurrentPrompt();
      } else {
        // Complete Quest!
        PocketKidsService.addKidsScore(20);
        widget.onCompleted?.call();
        _showVictoryDialog();
      }
    } else {
      HapticFeedback.lightImpact();
      await _tts.speak("Oops! Try again! Listen carefully!");
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: const Color(0xFF0F172A),
        title: Center(
          child: Column(
            children: [
              const Text("🌟 🔤 🌟", style: TextStyle(fontSize: 36)),
              const SizedBox(height: 8),
              Text(
                "QUEST COMPLETED!",
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You conquered all letter phoneme sounds!",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF8CD837).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF8CD837)),
              ),
              child: Text(
                "+20 Kids Score Earned! 🏆",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF8CD837),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8CD837),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                "YAY! CONTINUE 🚀",
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_roundIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Flame 2D Ambient Particles
          Positioned.fill(child: GameWidget(game: _flameGame)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8CD837),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Round ${_roundIndex + 1} / ${_questions.length} • Score: $_score",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _playCurrentPrompt,
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFD700)),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Big Center Sound & Word Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF334155)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF8CD837), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8CD837).withValues(alpha: 0.25),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          q['phoneme'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 54,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          q['word'] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "💡 ${q['meaningMl']} / ${q['meaningHi']}",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF67E8F9),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Text(
                    "TAP THE MATCHING LETTER 🎯",
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Option Bubbles (4 Large Pastel Blocks)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.6,
                    children: (q['options'] as List<String>).map((opt) {
                      return GestureDetector(
                        onTap: () => _handleChoice(opt),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            opt,
                            style: GoogleFonts.outfit(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

