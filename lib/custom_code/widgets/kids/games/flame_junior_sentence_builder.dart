import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';

// ============================================================================
// 🚂 1. JUNIOR SENTENCE BUILDER DATA MODELS & 90-DAY CURRICULUM
// ============================================================================

class JuniorSentenceTile {
  final String id;
  final String text;
  final String emoji;
  final Color cardColor;

  const JuniorSentenceTile({
    required this.id,
    required this.text,
    required this.emoji,
    required this.cardColor,
  });
}

class JuniorSentenceChallenge {
  final int day;
  final String fullSentence;
  final String translationMl;
  final String hint;
  final List<JuniorSentenceTile> tiles;

  const JuniorSentenceChallenge({
    required this.day,
    required this.fullSentence,
    required this.translationMl,
    required this.hint,
    required this.tiles,
  });
}

/// 📚 Progressive 90-Day Junior Sentence Database for Young Learners
class KidsSentenceCurriculum {
  static final List<JuniorSentenceChallenge> challenges = [
    // --- DAY 1 ---
    JuniorSentenceChallenge(
      day: 1,
      fullSentence: "I see a cute cat",
      translationMl: "ഞാൻ ഒരു കൊച്ചു പൂച്ചയെ കാണുന്നു 🐱",
      hint: "Start with who is looking! (I see...)",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'I see',
          emoji: '👁️',
          cardColor: Color(0xFFFF2D55),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'a cute',
          emoji: '✨',
          cardColor: Color(0xFFFF9500),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'cat',
          emoji: '🐱',
          cardColor: Color(0xFFFFCC00),
        ),
      ],
    ),

    // --- DAY 2 ---
    JuniorSentenceChallenge(
      day: 2,
      fullSentence: "The puppy can run fast",
      translationMl: "നായക്കുട്ടിക്ക് വേഗത്തിൽ ഓടാൻ കഴിയും 🐶",
      hint: "Who can run fast? The puppy!",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'The puppy',
          emoji: '🐶',
          cardColor: Color(0xFF007AFF),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'can run',
          emoji: '🏃',
          cardColor: Color(0xFF34C759),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'fast',
          emoji: '⚡',
          cardColor: Color(0xFFAF52DE),
        ),
      ],
    ),

    // --- DAY 3 ---
    JuniorSentenceChallenge(
      day: 3,
      fullSentence: "I love sweet red apples",
      translationMl: "എനിക്ക് ചുവന്ന മധുരമുള്ള ആപ്പിൾ ഇഷ്ടമാണ് 🍎",
      hint: "What sweet fruit do you love?",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'I love',
          emoji: '❤️',
          cardColor: Color(0xFFFF2D55),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'sweet red',
          emoji: '🍓',
          cardColor: Color(0xFFFF9500),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'apples',
          emoji: '🍎',
          cardColor: Color(0xFF34C759),
        ),
      ],
    ),

    // --- DAY 4 ---
    JuniorSentenceChallenge(
      day: 4,
      fullSentence: "The bright sun is shining",
      translationMl: "ശോഭയുള്ള സൂര്യൻ പ്രകാശിക്കുന്നു ☀️",
      hint: "Look up at the sky!",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'The bright sun',
          emoji: '☀️',
          cardColor: Color(0xFFFFCC00),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'is',
          emoji: '✨',
          cardColor: Color(0xFFFF9500),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'shining',
          emoji: '🌟',
          cardColor: Color(0xFF00C7BE),
        ),
      ],
    ),

    // --- DAY 5 ---
    JuniorSentenceChallenge(
      day: 5,
      fullSentence: "This is my happy house",
      translationMl: "ഇത് എൻ്റെ സന്തോഷമുള്ള വീടാണ് 🏡",
      hint: "Welcome to your house!",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'This is',
          emoji: '👉',
          cardColor: Color(0xFF5856D6),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'my happy',
          emoji: '😊',
          cardColor: Color(0xFFFF2D55),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'house',
          emoji: '🏡',
          cardColor: Color(0xFF34C759),
        ),
      ],
    ),

    // --- DAY 10 ---
    JuniorSentenceChallenge(
      day: 10,
      fullSentence: "Birds fly high in the sky",
      translationMl: "പക്ഷികൾ ആകാശത്തിൽ ഉയരത്തിൽ പറക്കുന്നു 🕊️",
      hint: "Where do birds fly?",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'Birds fly',
          emoji: '🕊️',
          cardColor: Color(0xFF007AFF),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'high up',
          emoji: '☁️',
          cardColor: Color(0xFF00C7BE),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'in the sky',
          emoji: '🌈',
          cardColor: Color(0xFFAF52DE),
        ),
      ],
    ),

    // --- DAY 20 ---
    JuniorSentenceChallenge(
      day: 20,
      fullSentence: "Please give me cold water",
      translationMl: "ദയവായി എനിക്ക് തണുത്ത വെള്ളം തരുമോ 💧",
      hint: "Say the polite word first! (Please...)",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'Please give',
          emoji: '🙏',
          cardColor: Color(0xFF34C759),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'me some',
          emoji: '🤲',
          cardColor: Color(0xFF007AFF),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'cold water',
          emoji: '💧',
          cardColor: Color(0xFF00C7BE),
        ),
      ],
    ),

    // --- DAY 30 ---
    JuniorSentenceChallenge(
      day: 30,
      fullSentence: "We play with good friends",
      translationMl: "ഞങ്ങൾ നല്ല കൂട്ടുകാരോടൊപ്പം കളിക്കുന്നു 👫",
      hint: "Who do you play with every day?",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'We play',
          emoji: '⚽',
          cardColor: Color(0xFFFF9500),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'together with',
          emoji: '🤝',
          cardColor: Color(0xFFFF2D55),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'good friends',
          emoji: '👫',
          cardColor: Color(0xFF5856D6),
        ),
      ],
    ),

    // --- DAY 60 ---
    JuniorSentenceChallenge(
      day: 60,
      fullSentence: "I can read stories nicely",
      translationMl: "എനിക്ക് കഥകൾ ഭംഗിയായി വായിക്കാൻ കഴിയും 📖",
      hint: "Show your story reading super power!",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'I can read',
          emoji: '📖',
          cardColor: Color(0xFF007AFF),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'funny stories',
          emoji: '🎭',
          cardColor: Color(0xFFFFCC00),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'very nicely',
          emoji: '🌟',
          cardColor: Color(0xFF34C759),
        ),
      ],
    ),

    // --- DAY 90 ---
    JuniorSentenceChallenge(
      day: 90,
      fullSentence: "I speak English with big joy",
      translationMl: "ഞാൻ വളരെ സന്തോഷത്തോടെ ഇംഗ്ലീഷ് സംസാരിക്കുന്നു 🎓",
      hint: "The 90-Day Junior Diplomat Master motto!",
      tiles: [
        JuniorSentenceTile(
          id: '1',
          text: 'I speak',
          emoji: '🗣️',
          cardColor: Color(0xFFFF2D55),
        ),
        JuniorSentenceTile(
          id: '2',
          text: 'fluent English',
          emoji: '🇬🇧',
          cardColor: Color(0xFF007AFF),
        ),
        JuniorSentenceTile(
          id: '3',
          text: 'with big joy',
          emoji: '🎉',
          cardColor: Color(0xFFFFD700),
        ),
      ],
    ),
  ];

  static JuniorSentenceChallenge getForDay(int day) {
    if (day <= 0) return challenges.first;
    // Find closest or matching challenge
    for (final c in challenges) {
      if (c.day == day) return c;
    }
    // Return modulo mapped challenge
    return challenges[(day - 1) % challenges.length];
  }
}

// ============================================================================
// 🔥 2. FLAME PARTICLES & TOY TRAIN LOCOMOTIVE FX
// ============================================================================

/// Floating candy sparkle & train smoke particle
class CandySmokeParticle extends Component {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double radius;
  double life;
  double decay;

  CandySmokeParticle({
    required this.position,
    required this.velocity,
    required this.color,
    this.radius = 12.0,
    this.life = 1.0,
    this.decay = 1.5,
  });

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity.x += 10.0 * dt; // gentle breeze
    radius += 4.0 * dt; // expanding smoke puff
    life -= decay * dt;
    if (life <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (life <= 0) return;
    final paint = Paint()
      ..color = color.withValues(alpha: life.clamp(0.0, 0.8))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(position.x, position.y), radius, paint);
  }
}

/// Flame Game managing drifting sky clouds, train smoke puffs and fireworks
class SentenceBuilderFlameEngine extends FlameGame {
  final math.Random _rng = math.Random();
  double _smokeTimer = 0.0;
  bool isTrainChugging = false;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  void update(double dt) {
    super.update(dt);
    _smokeTimer += dt;
    if (_smokeTimer > 0.25) {
      _smokeTimer = 0;
      // Ambient drifting floating star
      if (children.whereType<CandySmokeParticle>().length < 25) {
        add(
          CandySmokeParticle(
            position: Vector2(_rng.nextDouble() * size.x, size.y + 10),
            velocity: Vector2(
              (_rng.nextDouble() - 0.5) * 20,
              -30 - _rng.nextDouble() * 30,
            ),
            color: [
              const Color(0xFFFF9500),
              const Color(0xFFFFCC00),
              const Color(0xFF00C7BE),
              const Color(0xFFFF2D55),
              const Color(0xFFAF52DE),
            ][_rng.nextInt(5)],
            radius: 5.0 + _rng.nextDouble() * 4.0,
            life: 1.4,
            decay: 0.6,
          ),
        );
      }
    }
  }

  /// Puff cartoon smoke from locomotive stack
  void puffTrainSmoke(Offset stackPos) {
    for (int i = 0; i < 6; i++) {
      add(
        CandySmokeParticle(
          position: Vector2(stackPos.dx, stackPos.dy),
          velocity: Vector2(
            -20.0 - _rng.nextDouble() * 40.0,
            -40.0 - _rng.nextDouble() * 50.0,
          ),
          color: Colors.white.withValues(alpha: 0.8),
          radius: 8.0 + _rng.nextDouble() * 6.0,
          life: 1.2,
          decay: 1.1,
        ),
      );
    }
  }

  /// Celebration firework shower on sentence completed
  void burstVictoryConfetti() {
    for (int i = 0; i < 50; i++) {
      final origin = Vector2(
        size.x * 0.2 + _rng.nextDouble() * size.x * 0.6,
        size.y * 0.2 + _rng.nextDouble() * size.y * 0.3,
      );
      final angle = _rng.nextDouble() * 2 * math.pi;
      final speed = 80.0 + _rng.nextDouble() * 220.0;
      final colors = [
        const Color(0xFFFF2D55),
        const Color(0xFFFF9500),
        const Color(0xFFFFCC00),
        const Color(0xFF34C759),
        const Color(0xFF007AFF),
        const Color(0xFFAF52DE),
        const Color(0xFFFFD700),
      ];

      add(
        CandySmokeParticle(
          position: origin,
          velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
          color: colors[_rng.nextInt(colors.length)],
          radius: 8.0 + _rng.nextDouble() * 6.0,
          life: 1.5,
          decay: 0.8,
        ),
      );
    }
  }
}

// ============================================================================
// 🧩 3. FULL-SCREEN JUNIOR SENTENCE BUILDER INTERACTIVE PAGE
// ============================================================================

class PocketKidsSentenceBuilderPage extends StatefulWidget {
  final int initialDay;
  final VoidCallback? onCompleted;

  const PocketKidsSentenceBuilderPage({
    super.key,
    this.initialDay = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    VoidCallback? onCompleted,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PocketKidsSentenceBuilderPage(
          initialDay: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsSentenceBuilderPage> createState() =>
      _PocketKidsSentenceBuilderPageState();
}

class _PocketKidsSentenceBuilderPageState
    extends State<PocketKidsSentenceBuilderPage>
    with SingleTickerProviderStateMixin {
  late final SentenceBuilderFlameEngine _flameGame;
  final FlutterTts _tts = FlutterTts();

  late int _currentDay;
  late JuniorSentenceChallenge _currentChallenge;

  // Snapped Slots & Tray State
  final List<JuniorSentenceTile?> _placedTiles = [];
  final List<JuniorSentenceTile> _availableTrayTiles = [];

  bool _isCompleted = false;
  int _highlightedWordIndex = -1; // For karaoke spoken highlight effect

  late AnimationController _trainWheelsController;

  @override
  void initState() {
    super.initState();
    _currentDay = widget.initialDay;
    _currentChallenge = KidsSentenceCurriculum.getForDay(_currentDay);
    _flameGame = SentenceBuilderFlameEngine();

    _trainWheelsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _initTts();
    _setupRound();

    // Spoken Intro
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.speak("Let's build a sentence! ${_currentChallenge.hint}");
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.2);
    await _tts.setSpeechRate(0.40);
  }

  void _setupRound() {
    _isCompleted = false;
    _highlightedWordIndex = -1;
    _placedTiles.clear();
    for (int i = 0; i < _currentChallenge.tiles.length; i++) {
      _placedTiles.add(null);
    }

    // Scramble tiles for the tray
    _availableTrayTiles.clear();
    _availableTrayTiles.addAll(_currentChallenge.tiles);
    _availableTrayTiles.shuffle(math.Random());
  }

  void _switchDay(int newDay) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentDay = newDay;
      _currentChallenge = KidsSentenceCurriculum.getForDay(_currentDay);
      _setupRound();
    });
    _tts.speak("Level $_currentDay! ${_currentChallenge.hint}");
  }

  // --- 🧩 Tactile Tap / Snapping Mechanics ---
  void _onTapTrayTile(JuniorSentenceTile tile) {
    if (_isCompleted) return;

    // Single tap sounds out word for pre-readers
    _tts.speak(tile.text);
    HapticFeedback.lightImpact();

    // Find first empty slot in train
    final emptySlotIdx = _placedTiles.indexOf(null);
    if (emptySlotIdx != -1) {
      setState(() {
        _availableTrayTiles.remove(tile);
        _placedTiles[emptySlotIdx] = tile;
      });

      // Puff locomotive smoke
      _flameGame.puffTrainSmoke(const Offset(80, 220));

      // Check if all slots filled!
      if (!_placedTiles.contains(null)) {
        _checkSentenceSolution();
      }
    }
  }

  void _onTapPlacedSlot(int slotIndex) {
    if (_isCompleted) return;
    final tile = _placedTiles[slotIndex];
    if (tile != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _placedTiles[slotIndex] = null;
        _availableTrayTiles.add(tile);
      });
    }
  }

  void _checkSentenceSolution() {
    bool isCorrect = true;
    for (int i = 0; i < _currentChallenge.tiles.length; i++) {
      if (_placedTiles[i]?.id != _currentChallenge.tiles[i].id) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      _onRoundWon();
    } else {
      // Gentle incorrect wobble
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playIncorrectSound();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Almost there! Tap a block to swap order 😊",
            style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFFF9500),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onRoundWon() {
    setState(() {
      _isCompleted = true;
    });

    // Reward points & star cookies
    PocketKidsService.addKidsScore(30);
    PocketGameAudioService.instance.playVictorySfx();
    HapticFeedback.heavyImpact();

    // Flame fireworks!
    _flameGame.burstVictoryConfetti();

    // Karaoke Spoken Read-Aloud
    _playKaraokeReading();

    widget.onCompleted?.call();
  }

  Future<void> _playKaraokeReading() async {
    for (int i = 0; i < _currentChallenge.tiles.length; i++) {
      if (!mounted) return;
      setState(() {
        _highlightedWordIndex = i;
      });
      await _tts.speak(_currentChallenge.tiles[i].text);
      await Future.delayed(const Duration(milliseconds: 650));
    }
    if (!mounted) return;
    setState(() {
      _highlightedWordIndex = -1;
    });
    // Speak Malayalam meaning
    await _tts.speak(_currentChallenge.translationMl);
  }

  @override
  void dispose() {
    _trainWheelsController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // 🌌 1. Flame Interactive Particles & Atmospheric Clouds
          Positioned.fill(
            child: GameWidget(game: _flameGame),
          ),

          // 🌟 2. Gentle Ambient Colorful Glow
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.3),
                    radius: 1.1,
                    colors: [
                      Color(0x2238BDF8), // sky blue glow
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 📱 3. Top Navigation & Header Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),

                      // Day / Level Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF00C7BE)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF007AFF).withValues(alpha: 0.4),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text("🚂", style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              "Level $_currentDay: Train Builder",
                              style: GoogleFonts.fredoka(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Sound Out Prompt Button
                      IconButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          _tts.speak(_currentChallenge.fullSentence);
                        },
                        icon: const Icon(
                          Icons.volume_up_rounded,
                          color: Color(0xFFFFD700),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),

                  // Malayalam Translation Card
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("💡", style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          _currentChallenge.translationMl,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🚂 4. Toy Train Slots Track (Magnetic Snapping Line)
          Positioned(
            top: 135,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cartoon Locomotive Engine
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF2D55), Color(0xFFFF9500)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF2D55).withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text("🚂", style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 6),
                          Text(
                            "EXPRESS",
                            style: GoogleFonts.fredoka(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Wagon Slots
                Row(
                  children: List.generate(_placedTiles.length, (index) {
                    final tile = _placedTiles[index];
                    final isHighlighted = (_highlightedWordIndex == index);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => _onTapPlacedSlot(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 85,
                            decoration: BoxDecoration(
                              color: tile != null
                                  ? tile.cardColor
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isHighlighted
                                    ? const Color(0xFFFFD700)
                                    : (tile != null
                                        ? Colors.white
                                        : Colors.white30),
                                width: isHighlighted ? 3.5 : 2.0,
                              ),
                              boxShadow: isHighlighted
                                  ? [
                                      const BoxShadow(
                                        color: Color(0xFFFFD700),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : (tile != null
                                      ? [
                                          BoxShadow(
                                            color: tile.cardColor.withValues(alpha: 0.4),
                                            blurRadius: 12,
                                          ),
                                        ]
                                      : []),
                            ),
                            child: tile != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          tile.emoji,
                                          style: const TextStyle(fontSize: 22),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          tile.text,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.fredoka(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline_rounded,
                                          color: Colors.white.withValues(alpha: 0.4),
                                          size: 26,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Slot ${index + 1}",
                                          style: GoogleFonts.outfit(
                                            color: Colors.white38,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // 🍬 5. Bottom Tray: Scrambled Magnetic Word Chips
          Positioned(
            left: 16,
            right: 16,
            bottom: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "TAP TO SNAP WORDS IN ORDER",
                  style: GoogleFonts.fredoka(
                    color: Colors.white54,
                    fontSize: 13,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),

                // Scrambled Tiles Row
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _availableTrayTiles.map((tile) {
                    return GestureDetector(
                      onTap: () => _onTapTrayTile(tile),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              tile.cardColor,
                              tile.cardColor.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white70, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: tile.cardColor.withValues(alpha: 0.45),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tile.emoji, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Text(
                              tile.text,
                              style: GoogleFonts.fredoka(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // 🎉 6. Celebratory Card when Completed
          if (_isCompleted)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34C759), Color(0xFF00C7BE)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF34C759).withValues(alpha: 0.6),
                          blurRadius: 36,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("🚂💨 ⭐⭐⭐", style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          "ALL ABOARD!",
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\"${_currentChallenge.fullSentence}\"",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "+30 KS Points & Golden Star Cookie 🍪",
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ⏭️ 7. Bottom Navigation & Level Actions Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Level Button
                    ElevatedButton.icon(
                      onPressed: _currentDay > 1
                          ? () => _switchDay(_currentDay - 1)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                      label: Text(
                        "PREV",
                        style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Reset / Clear Slots
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _setupRound();
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        padding: const EdgeInsets.all(14),
                      ),
                    ),

                    // Next Level Button
                    ElevatedButton.icon(
                      onPressed: _currentDay < 90
                          ? () => _switchDay(_currentDay + 1)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34C759),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 6,
                      ),
                      label: Text(
                        "NEXT ➔",
                        style: GoogleFonts.fredoka(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      icon: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
