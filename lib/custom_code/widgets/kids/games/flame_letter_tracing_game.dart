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
// 🌟 1. TRACING DATA MODELS & LETTER VECTOR PATHS (A to Z + Numbers)
// ============================================================================

/// Represents an individual directional stroke of a letter (from start to end)
class TracingStroke {
  final List<Offset> points; // Normalized coordinates (0.0 to 1.0)
  final String label;

  const TracingStroke({required this.points, this.label = '1'});
}

/// Complete educational metadata for a letter or character
class LetterTraceItem {
  final String char;
  final String word;
  final String emoji;
  final String phonics;
  final String malayalam;
  final Color primaryColor;
  final Color accentColor;
  final List<TracingStroke> strokes;

  const LetterTraceItem({
    required this.char,
    required this.word,
    required this.emoji,
    required this.phonics,
    required this.malayalam,
    required this.primaryColor,
    required this.accentColor,
    required this.strokes,
  });
}

/// 📚 Comprehensive A to Z Letter Vector Database
class KidsTracingCurriculum {
  static final List<LetterTraceItem> letters = [
    // --- LETTER A ---
    LetterTraceItem(
      char: 'A',
      word: 'Apple',
      emoji: '🍎',
      phonics: '/æ/ like in Apple',
      malayalam: 'ആപ്പിൾ',
      primaryColor: const Color(0xFFFF2D55),
      accentColor: const Color(0xFFFF9500),
      strokes: [
        TracingStroke(
          label: '1',
          points: [
            const Offset(0.50, 0.12),
            const Offset(0.40, 0.35),
            const Offset(0.30, 0.60),
            const Offset(0.18, 0.88),
          ],
        ),
        TracingStroke(
          label: '2',
          points: [
            const Offset(0.50, 0.12),
            const Offset(0.60, 0.35),
            const Offset(0.70, 0.60),
            const Offset(0.82, 0.88),
          ],
        ),
        TracingStroke(
          label: '3',
          points: [
            const Offset(0.30, 0.58),
            const Offset(0.50, 0.58),
            const Offset(0.70, 0.58),
          ],
        ),
      ],
    ),

    // --- LETTER B ---
    LetterTraceItem(
      char: 'B',
      word: 'Ball',
      emoji: '⚽',
      phonics: '/b/ like in Ball',
      malayalam: 'പന്ത്',
      primaryColor: const Color(0xFF007AFF),
      accentColor: const Color(0xFF5856D6),
      strokes: [
        TracingStroke(
          label: '1',
          points: [
            const Offset(0.24, 0.12),
            const Offset(0.24, 0.36),
            const Offset(0.24, 0.62),
            const Offset(0.24, 0.88),
          ],
        ),
        TracingStroke(
          label: '2',
          points: [
            const Offset(0.24, 0.12),
            const Offset(0.55, 0.12),
            const Offset(0.75, 0.28),
            const Offset(0.55, 0.48),
            const Offset(0.24, 0.48),
          ],
        ),
        TracingStroke(
          label: '3',
          points: [
            const Offset(0.24, 0.48),
            const Offset(0.60, 0.48),
            const Offset(0.80, 0.68),
            const Offset(0.60, 0.88),
            const Offset(0.24, 0.88),
          ],
        ),
      ],
    ),

    // --- LETTER C ---
    LetterTraceItem(
      char: 'C',
      word: 'Cat',
      emoji: '🐱',
      phonics: '/k/ like in Cat',
      malayalam: 'പൂച്ച',
      primaryColor: const Color(0xFFFF9500),
      accentColor: const Color(0xFFFFCC00),
      strokes: [
        TracingStroke(
          label: '1',
          points: [
            const Offset(0.78, 0.24),
            const Offset(0.55, 0.12),
            const Offset(0.28, 0.28),
            const Offset(0.20, 0.50),
            const Offset(0.28, 0.72),
            const Offset(0.55, 0.88),
            const Offset(0.78, 0.76),
          ],
        ),
      ],
    ),

    // --- LETTER D ---
    LetterTraceItem(
      char: 'D',
      word: 'Duck',
      emoji: '🦆',
      phonics: '/d/ like in Duck',
      malayalam: 'താറാവ്',
      primaryColor: const Color(0xFF34C759),
      accentColor: const Color(0xFF30D158),
      strokes: [
        TracingStroke(
          label: '1',
          points: [
            const Offset(0.24, 0.12),
            const Offset(0.24, 0.50),
            const Offset(0.24, 0.88),
          ],
        ),
        TracingStroke(
          label: '2',
          points: [
            const Offset(0.24, 0.12),
            const Offset(0.55, 0.12),
            const Offset(0.80, 0.35),
            const Offset(0.80, 0.65),
            const Offset(0.55, 0.88),
            const Offset(0.24, 0.88),
          ],
        ),
      ],
    ),

    // --- LETTER E ---
    LetterTraceItem(
      char: 'E',
      word: 'Elephant',
      emoji: '🐘',
      phonics: '/e/ like in Elephant',
      malayalam: 'ആന',
      primaryColor: const Color(0xFFAF52DE),
      accentColor: const Color(0xFFFF2D55),
      strokes: [
        TracingStroke(
          label: '1',
          points: [
            const Offset(0.25, 0.12),
            const Offset(0.25, 0.50),
            const Offset(0.25, 0.88),
          ],
        ),
        TracingStroke(
          label: '2',
          points: [const Offset(0.25, 0.12), const Offset(0.78, 0.12)],
        ),
        TracingStroke(
          label: '3',
          points: [const Offset(0.25, 0.50), const Offset(0.68, 0.50)],
        ),
        TracingStroke(
          label: '4',
          points: [const Offset(0.25, 0.88), const Offset(0.78, 0.88)],
        ),
      ],
    ),

    // --- LETTER F ---
    LetterTraceItem(
      char: 'F',
      word: 'Fish',
      emoji: '🐟',
      phonics: '/f/ like in Fish',
      malayalam: 'മത്സ്യം',
      primaryColor: const Color(0xFF00C7BE),
      accentColor: const Color(0xFF32ADE6),
      strokes: [
        TracingStroke(
          label: '1',
          points: [
            const Offset(0.26, 0.12),
            const Offset(0.26, 0.50),
            const Offset(0.26, 0.88),
          ],
        ),
        TracingStroke(
          label: '2',
          points: [const Offset(0.26, 0.12), const Offset(0.78, 0.12)],
        ),
        TracingStroke(
          label: '3',
          points: [const Offset(0.26, 0.50), const Offset(0.66, 0.50)],
        ),
      ],
    ),

    // --- LETTER G ---
    LetterTraceItem(
      char: 'G',
      word: 'Giraffe',
      emoji: '🦒',
      phonics: '/dʒ/ or /ɡ/ like Giraffe',
      malayalam: 'ജിറാഫ്',
      primaryColor: const Color(0xFFFF9500),
      accentColor: const Color(0xFFFFCC00),
      strokes: [
        TracingStroke(
          label: '1',
          points: [
            const Offset(0.78, 0.24),
            const Offset(0.55, 0.12),
            const Offset(0.28, 0.28),
            const Offset(0.20, 0.50),
            const Offset(0.28, 0.72),
            const Offset(0.55, 0.88),
            const Offset(0.78, 0.76),
            const Offset(0.78, 0.54),
          ],
        ),
        TracingStroke(
          label: '2',
          points: [const Offset(0.78, 0.54), const Offset(0.52, 0.54)],
        ),
      ],
    ),

    // --- LETTER H ---
    LetterTraceItem(
      char: 'H',
      word: 'Horse',
      emoji: '🐴',
      phonics: '/h/ like in Horse',
      malayalam: 'കുതിര',
      primaryColor: const Color(0xFF8E8E93),
      accentColor: const Color(0xFFFF9500),
      strokes: [
        TracingStroke(
          label: '1',
          points: [
            const Offset(0.25, 0.12),
            const Offset(0.25, 0.88),
          ],
        ),
        TracingStroke(
          label: '2',
          points: [
            const Offset(0.75, 0.12),
            const Offset(0.75, 0.88),
          ],
        ),
        TracingStroke(
          label: '3',
          points: [
            const Offset(0.25, 0.50),
            const Offset(0.75, 0.50),
          ],
        ),
      ],
    ),

    // --- LETTER I ---
    LetterTraceItem(
      char: 'I',
      word: 'Ice Cream',
      emoji: '🍦',
      phonics: '/aɪ/ like in Ice Cream',
      malayalam: 'ഐസ്ക്രീം',
      primaryColor: const Color(0xFFFF2D55),
      accentColor: const Color(0xFFFFCC00),
      strokes: [
        TracingStroke(
          label: '1',
          points: [
            const Offset(0.50, 0.12),
            const Offset(0.50, 0.88),
          ],
        ),
        TracingStroke(
          label: '2',
          points: [const Offset(0.28, 0.12), const Offset(0.72, 0.12)],
        ),
        TracingStroke(
          label: '3',
          points: [const Offset(0.28, 0.88), const Offset(0.72, 0.88)],
        ),
      ],
    ),

    // --- LETTER M ---
    LetterTraceItem(
      char: 'M',
      word: 'Monkey',
      emoji: '🐵',
      phonics: '/m/ like in Monkey',
      malayalam: 'കുരങ്ങൻ',
      primaryColor: const Color(0xFFFF9500),
      accentColor: const Color(0xFF8B572A),
      strokes: [
        TracingStroke(
          label: '1',
          points: [const Offset(0.20, 0.88), const Offset(0.20, 0.14)],
        ),
        TracingStroke(
          label: '2',
          points: [const Offset(0.20, 0.14), const Offset(0.50, 0.58)],
        ),
        TracingStroke(
          label: '3',
          points: [const Offset(0.50, 0.58), const Offset(0.80, 0.14)],
        ),
        TracingStroke(
          label: '4',
          points: [const Offset(0.80, 0.14), const Offset(0.80, 0.88)],
        ),
      ],
    ),

    // --- LETTER S ---
    LetterTraceItem(
      char: 'S',
      word: 'Sun',
      emoji: '☀️',
      phonics: '/s/ like in Sun',
      malayalam: 'സൂര്യൻ',
      primaryColor: const Color(0xFFFFCC00),
      accentColor: const Color(0xFFFF9500),
      strokes: [
        TracingStroke(
          label: '1',
          points: [
            const Offset(0.75, 0.24),
            const Offset(0.50, 0.12),
            const Offset(0.28, 0.28),
            const Offset(0.50, 0.50),
            const Offset(0.72, 0.72),
            const Offset(0.50, 0.88),
            const Offset(0.25, 0.76),
          ],
        ),
      ],
    ),

    // --- LETTER Z ---
    LetterTraceItem(
      char: 'Z',
      word: 'Zebra',
      emoji: '🦓',
      phonics: '/z/ like in Zebra',
      malayalam: 'സീബ്ര',
      primaryColor: const Color(0xFF5856D6),
      accentColor: const Color(0xFF007AFF),
      strokes: [
        TracingStroke(
          label: '1',
          points: [const Offset(0.22, 0.14), const Offset(0.78, 0.14)],
        ),
        TracingStroke(
          label: '2',
          points: [const Offset(0.78, 0.14), const Offset(0.22, 0.86)],
        ),
        TracingStroke(
          label: '3',
          points: [const Offset(0.22, 0.86), const Offset(0.78, 0.86)],
        ),
      ],
    ),
  ];

  static LetterTraceItem getItem(int index) {
    if (index < 0 || index >= letters.length) return letters.first;
    return letters[index];
  }
}

// ============================================================================
// 🔥 2. FLAME SPARKLE & CELEBRATION ENGINE
// ============================================================================

/// A joyful glowing stardust particle that follows the child's touch
class RainbowTouchSparkle extends Component {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double radius;
  double life;
  double decay;

  RainbowTouchSparkle({
    required this.position,
    required this.velocity,
    required this.color,
    this.radius = 8.0,
    this.life = 1.0,
    this.decay = 2.4,
  });

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity.y += 40.0 * dt; // gentle gravity
    life -= decay * dt;
    if (life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (life <= 0) return;
    final paint = Paint()
      ..color = color.withValues(alpha: life.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawCircle(Offset(position.x, position.y), radius * life, paint);
  }
}

/// Flame Game managing interactive touch sparkle fireworks
class LetterTracingFlameGame extends FlameGame {
  final math.Random _rng = math.Random();
  double _ambientTimer = 0.0;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  void update(double dt) {
    super.update(dt);
    _ambientTimer += dt;
    if (_ambientTimer > 0.4) {
      _ambientTimer = 0;
      if (children.whereType<RainbowTouchSparkle>().length < 20) {
        // Spawn gentle ambient glowing bubble drifting upwards
        add(
          RainbowTouchSparkle(
            position: Vector2(_rng.nextDouble() * size.x, size.y + 10),
            velocity: Vector2(
              (_rng.nextDouble() - 0.5) * 20,
              -25 - _rng.nextDouble() * 35,
            ),
            color: [
              const Color(0xFFFF2D55),
              const Color(0xFFFF9500),
              const Color(0xFFFFCC00),
              const Color(0xFF34C759),
              const Color(0xFF007AFF),
              const Color(0xFFAF52DE),
            ][_rng.nextInt(6)],
            radius: 5.0 + _rng.nextDouble() * 4,
            life: 1.2,
            decay: 0.4,
          ),
        );
      }
    }
  }

  /// Trigger a shower of rainbow sparkles at the child's touch position
  void emitTouchSparkles(Offset pos, Color primaryColor) {
    for (int i = 0; i < 4; i++) {
      final angle = _rng.nextDouble() * 2 * math.pi;
      final speed = 30.0 + _rng.nextDouble() * 70.0;
      add(
        RainbowTouchSparkle(
          position: Vector2(pos.dx, pos.dy),
          velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed),
          color: _rng.nextBool()
              ? primaryColor
              : const Color(0xFFFFD700), // Gold glint
          radius: 6.0 + _rng.nextDouble() * 5.0,
          life: 1.0,
          decay: 2.2,
        ),
      );
    }
  }

  /// Full-screen victory confetti and star firework explosion
  void burstCelebrationFireworks() {
    for (int i = 0; i < 60; i++) {
      final origin = Vector2(
        size.x * 0.2 + _rng.nextDouble() * size.x * 0.6,
        size.y * 0.3 + _rng.nextDouble() * size.y * 0.3,
      );
      final angle = _rng.nextDouble() * 2 * math.pi;
      final speed = 80.0 + _rng.nextDouble() * 240.0;
      final colors = [
        const Color(0xFFFF2D55),
        const Color(0xFFFF9500),
        const Color(0xFFFFCC00),
        const Color(0xFF34C759),
        const Color(0xFF00C7BE),
        const Color(0xFF30B0C7),
        const Color(0xFF007AFF),
        const Color(0xFF5856D6),
        const Color(0xFFAF52DE),
      ];

      add(
        RainbowTouchSparkle(
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
// 🎨 3. FULL-SCREEN KIDS LETTER TRACING INTERACTIVE PAGE
// ============================================================================

class PocketKidsLetterTracingPage extends StatefulWidget {
  final int initialLetterIndex;
  final VoidCallback? onCompleted;

  const PocketKidsLetterTracingPage({
    super.key,
    this.initialLetterIndex = 0,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int initialIndex = 0,
    VoidCallback? onCompleted,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PocketKidsLetterTracingPage(
          initialLetterIndex: initialIndex,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsLetterTracingPage> createState() =>
      _PocketKidsLetterTracingPageState();
}

class _PocketKidsLetterTracingPageState extends State<PocketKidsLetterTracingPage>
    with SingleTickerProviderStateMixin {
  late final LetterTracingFlameGame _flameGame;
  final FlutterTts _tts = FlutterTts();

  late int _currentIndex;
  late LetterTraceItem _currentItem;

  // Tracing Progress States
  int _currentStrokeIndex = 0;
  final List<List<Offset>> _tracedStrokes = []; // Traced user points
  int _targetPointIndex = 0; // Checkpoint on current stroke
  bool _isCompleted = false;

  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialLetterIndex.clamp(
      0,
      KidsTracingCurriculum.letters.length - 1,
    );
    _currentItem = KidsTracingCurriculum.getItem(_currentIndex);
    _flameGame = LetterTracingFlameGame();

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    );

    _initTts();
    _resetLetterState();

    // Friendly initial vocal cheer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentLetterIntro();
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.2); // Child-friendly cheerful pitch
    await _tts.setSpeechRate(0.42); // Clear and slow
  }

  void _speakCurrentLetterIntro() {
    _tts.speak("Let's trace letter ${_currentItem.char}! ${_currentItem.word}");
  }

  void _resetLetterState() {
    _currentStrokeIndex = 0;
    _targetPointIndex = 0;
    _isCompleted = false;
    _tracedStrokes.clear();
    for (int i = 0; i < _currentItem.strokes.length; i++) {
      _tracedStrokes.add([]);
    }
    _celebrationController.reset();
  }

  void _switchLetter(int newIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = newIndex.clamp(0, KidsTracingCurriculum.letters.length - 1);
      _currentItem = KidsTracingCurriculum.getItem(_currentIndex);
      _resetLetterState();
    });
    _speakCurrentLetterIntro();
  }

  // --- ✍️ Interactive Touch Tracing Logic ---
  void _onPanStart(DragStartDetails details, Size canvasSize) {
    if (_isCompleted) return;
    _handleTouch(details.localPosition, canvasSize);
  }

  void _onPanUpdate(DragUpdateDetails details, Size canvasSize) {
    if (_isCompleted) return;
    _handleTouch(details.localPosition, canvasSize);
  }

  void _handleTouch(Offset localPos, Size canvasSize) {
    if (_currentStrokeIndex >= _currentItem.strokes.length) return;

    final currentStroke = _currentItem.strokes[_currentStrokeIndex];
    if (_targetPointIndex >= currentStroke.points.length) return;

    // Convert normalized target point to screen coordinates
    final targetNorm = currentStroke.points[_targetPointIndex];
    final targetScreen = Offset(
      targetNorm.dx * canvasSize.width,
      targetNorm.dy * canvasSize.height,
    );

    final distance = (localPos - targetScreen).distance;
    // Generous touch tolerance for young children (~42dp)
    if (distance <= 42.0) {
      // Point connected!
      _tracedStrokes[_currentStrokeIndex].add(targetScreen);
      _flameGame.emitTouchSparkles(localPos, _currentItem.primaryColor);
      HapticFeedback.lightImpact();

      _targetPointIndex++;
      setState(() {});

      // Check if current stroke is finished
      if (_targetPointIndex >= currentStroke.points.length) {
        PocketGameAudioService.instance.playCoinSound();
        _currentStrokeIndex++;
        _targetPointIndex = 0;

        // Check if entire letter is finished!
        if (_currentStrokeIndex >= _currentItem.strokes.length) {
          _onLetterCompleted();
        }
      }
    }
  }

  void _onLetterCompleted() {
    setState(() {
      _isCompleted = true;
    });

    // Award Kids Score & Star Cookies
    PocketKidsService.addKidsScore(30);
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();

    // Trigger Flame fireworks
    _flameGame.burstCelebrationFireworks();
    _celebrationController.forward();

    // Spoken cheer
    _tts.speak(
      "Awesome! ${_currentItem.char} is for ${_currentItem.word}! ${_currentItem.malayalam}",
    );

    widget.onCompleted?.call();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Cosmic midnight blue
      body: Stack(
        children: [
          // 🌌 1. Flame Interactive Particles & Cosmic Sparkle Background
          Positioned.fill(
            child: GameWidget(game: _flameGame),
          ),

          // 🌟 2. Gentle Ambient Colorful Radial Gradients
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 1.0,
                    colors: [
                      _currentItem.primaryColor.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 📱 3. Top Navigation & Mascot Header Bar
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

                      // Title & Phonics Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _currentItem.primaryColor.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _currentItem.emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${_currentItem.char} for ${_currentItem.word}",
                              style: GoogleFonts.fredoka(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Audio Pronunciation Button
                      IconButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          _tts.speak(
                            "${_currentItem.char}! ${_currentItem.word}! ${_currentItem.malayalam}",
                          );
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

                  // Malayalam & Phonics Subtitle Card
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentItem.phonics,
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text("•", style: TextStyle(color: Colors.white24)),
                        const SizedBox(width: 8),
                        Text(
                          _currentItem.malayalam,
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

          // ✍️ 4. Center Tracing Drawing Board
          Positioned.fill(
            top: 130,
            bottom: 120,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final boardSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );

                  return GestureDetector(
                    onPanStart: (d) => _onPanStart(d, boardSize),
                    onPanUpdate: (d) => _onPanUpdate(d, boardSize),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: _currentItem.primaryColor.withValues(alpha: 0.4),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _currentItem.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: CustomPaint(
                          size: boardSize,
                          painter: LetterTracingPainter(
                            item: _currentItem,
                            currentStrokeIndex: _currentStrokeIndex,
                            targetPointIndex: _targetPointIndex,
                            tracedStrokes: _tracedStrokes,
                            isCompleted: _isCompleted,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 🎉 5. Celebratory Pop-up when Completed
          if (_isCompleted)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _currentItem.primaryColor,
                            _currentItem.accentColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: _currentItem.primaryColor.withValues(alpha: 0.6),
                            blurRadius: 36,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("⭐⭐⭐", style: TextStyle(fontSize: 34)),
                          const SizedBox(height: 8),
                          Text(
                            "SUPER STAR!",
                            style: GoogleFonts.fredoka(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            "+30 KS Points & Star Cookie 🍪",
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ⏭️ 6. Bottom Letter Carousel & Actions Bar
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
                    // Previous Letter Button
                    ElevatedButton.icon(
                      onPressed: _currentIndex > 0
                          ? () => _switchLetter(_currentIndex - 1)
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

                    // Replay / Clear Tracing Button
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _resetLetterState();
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        padding: const EdgeInsets.all(14),
                      ),
                    ),

                    // Next Letter Button
                    ElevatedButton.icon(
                      onPressed:
                          _currentIndex < KidsTracingCurriculum.letters.length - 1
                              ? () => _switchLetter(_currentIndex + 1)
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentItem.primaryColor,
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

// ============================================================================
// 🖌️ 4. CUSTOM PAINTER: LETTER OUTLINE, LIQUID FILL & GUIDE ARROWS
// ============================================================================

class LetterTracingPainter extends CustomPainter {
  final LetterTraceItem item;
  final int currentStrokeIndex;
  final int targetPointIndex;
  final List<List<Offset>> tracedStrokes;
  final bool isCompleted;

  LetterTracingPainter({
    required this.item,
    required this.currentStrokeIndex,
    required this.targetPointIndex,
    required this.tracedStrokes,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw subtle background guide grid dots
    _drawGuideGrid(canvas, size);

    // 2. Draw Hollow Target Letter Strokes (Base Outline)
    final hollowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 38.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dashGuidePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (final stroke in item.strokes) {
      final path = Path();
      for (int i = 0; i < stroke.points.length; i++) {
        final pt = Offset(
          stroke.points[i].dx * size.width,
          stroke.points[i].dy * size.height,
        );
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(path, hollowPaint);
      canvas.drawPath(path, dashGuidePaint);
    }

    // 3. Draw Completed / Traced Liquid Fill with Vibrant Neon Glow
    final tracedPaint = Paint()
      ..shader = LinearGradient(
        colors: [item.primaryColor, item.accentColor],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 38.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final tracedPoints in tracedStrokes) {
      if (tracedPoints.length >= 2) {
        final path = Path();
        path.moveTo(tracedPoints.first.dx, tracedPoints.first.dy);
        for (int i = 1; i < tracedPoints.length; i++) {
          path.lineTo(tracedPoints[i].dx, tracedPoints[i].dy);
        }
        canvas.drawPath(path, tracedPaint);
      } else if (tracedPoints.length == 1) {
        canvas.drawCircle(
          tracedPoints.first,
          19.0,
          Paint()..color = item.primaryColor,
        );
      }
    }

    // 4. Draw Interactive Guide Checkpoint Numbered Badges (①, ②, ③)
    if (!isCompleted && currentStrokeIndex < item.strokes.length) {
      final activeStroke = item.strokes[currentStrokeIndex];

      // Draw all stroke starter pins
      for (int sIdx = 0; sIdx < item.strokes.length; sIdx++) {
        final stroke = item.strokes[sIdx];
        if (stroke.points.isEmpty) continue;
        final startPt = Offset(
          stroke.points.first.dx * size.width,
          stroke.points.first.dy * size.height,
        );

        final isCurrent = (sIdx == currentStrokeIndex);
        final pinColor = isCurrent ? const Color(0xFFFFD700) : Colors.white38;

        // Outer pulse circle
        if (isCurrent) {
          canvas.drawCircle(
            startPt,
            24,
            Paint()..color = pinColor.withValues(alpha: 0.25),
          );
        }

        // Inner numbered badge
        canvas.drawCircle(startPt, 14, Paint()..color = pinColor);
        final tp = TextPainter(
          text: TextSpan(
            text: stroke.label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          startPt - Offset(tp.width / 2, tp.height / 2),
        );
      }

      // Next Target Point Animated Spark Ring
      if (targetPointIndex < activeStroke.points.length) {
        final targetNorm = activeStroke.points[targetPointIndex];
        final targetPt = Offset(
          targetNorm.dx * size.width,
          targetNorm.dy * size.height,
        );

        final targetPaint = Paint()
          ..color = item.accentColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(targetPt, 10, targetPaint);

        final ringPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(targetPt, 16, ringPaint);
      }
    }
  }

  void _drawGuideGrid(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    const step = 40.0;
    for (double x = 20; x < size.width; x += step) {
      for (double y = 20; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LetterTracingPainter oldDelegate) {
    return oldDelegate.currentStrokeIndex != currentStrokeIndex ||
        oldDelegate.targetPointIndex != targetPointIndex ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.tracedStrokes != tracedStrokes;
  }
}
