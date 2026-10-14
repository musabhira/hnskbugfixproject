import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import '../curriculum_data/day1_az_and_300vocab_data.dart';
import '../pocket_fortress_defense_service.dart';

/// 🎈 Floating Balloon Object Model
class SkyBalloonItem {
  final String letter;
  final String word;
  final String emoji;
  final Color color;

  double x; // 0.0 to 1.0 screen relative
  double y; // 0.0 to 1.15 screen relative
  double targetY; // Resting center position (~0.42)
  double swayPhase;
  double swayOffset;
  bool isPopped;

  SkyBalloonItem({
    required this.letter,
    required this.word,
    required this.emoji,
    required this.color,
    required this.x,
    required this.y,
    this.targetY = 0.42,
    required this.swayPhase,
    this.swayOffset = 0.0,
    this.isPopped = false,
  });
}

/// 💥 Particle effect for balloon pop explosion
class BalloonPopParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final Color color;
  final double size;

  BalloonPopParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
  });
}

/// 🎈 Responsive, Minimal Balloon Phonics Game
///
/// Features addressing user audio directive:
/// 1. Clean, minimal, responsive header (just "Balloon Game", no long title, no cluttering XP points).
/// 2. Balloon floats up smoothly from the bottom meadow and STOPS right in the CENTER.
/// 3. When the child taps the balloon, it pops with particles, and TTS pronounces ONLY the alphabet letter ("A").
/// 4. Minimal, centered Floating Action Button at the bottom with a mic icon.
/// 5. Above the button: Simple clean prompt `Speak "A for Apple"`. No extra clutter or translations.
/// 6. Child taps mic, says "A for Apple", and tapping again (or voice detection) smoothly advances to the next letter ('B').
/// 7. No strict verification blocking. Moves sequentially A -> B -> C -> ... -> Z!
class PocketAlphabetBalloonSkyGamePage extends StatefulWidget {
  final String? userId;
  final VoidCallback? onCompleted;

  const PocketAlphabetBalloonSkyGamePage({
    super.key,
    this.userId,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    String? userId,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketAlphabetBalloonSkyGamePage(
          userId: userId,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketAlphabetBalloonSkyGamePage> createState() =>
      _PocketAlphabetBalloonSkyGamePageState();
}

class _PocketAlphabetBalloonSkyGamePageState
    extends State<PocketAlphabetBalloonSkyGamePage>
    with TickerProviderStateMixin {
  late final AnimationController _gameLoopController;
  late final AnimationController _pulseController;
  late final FlutterTts _tts;
  late final stt.SpeechToText _speech;

  final math.Random _random = math.Random();
  final List<SkyBalloonItem> _activeBalloons = [];
  final List<BalloonPopParticle> _particles = [];
  final Set<String> _poppedLetters = {};

  int _currentLetterIndex = 0; // 0 to 25 (A to Z)
  bool _isSoundMuted = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _allCompleted = false;
  bool _isAdvancing = false;
  double _cloudScroll = 0.0;

  static const List<Color> _balloonPalette = [
    Color(0xFFEF4444), // Crimson Red
    Color(0xFF3B82F6), // Royal Blue
    Color(0xFF10B981), // Emerald Green
    Color(0xFFF59E0B), // Warm Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF97316), // Orange
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeechRecognizer();
    _initBgmVolume();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_gameLoop);
    _gameLoopController.repeat();

    // Spawn the first balloon (Letter A)
    _spawnTargetLetterBalloon(_currentLetterIndex);
  }

  Future<void> _initBgmVolume() async {
    try {
      await PocketGameAudioService.instance.setVolume(0.12);
    } catch (_) {}
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _initSpeechRecognizer() async {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!isMobile) {
      _speechAvailable = false;
      return;
    }
    try {
      _speech = stt.SpeechToText();
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isListening) {
              setState(() => _isListening = false);
            }
          }
        },
        onError: (_) {
          if (mounted && _isListening) {
            setState(() => _isListening = false);
          }
        },
      );
      if (mounted) setState(() => _speechAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _speechAvailable = false);
    }
  }

  /// Spawns the balloon at the bottom meadow, to float up to center
  void _spawnTargetLetterBalloon(int letterIdx) {
    final letters = Day1AlphabetData.lettersAtoZ;
    if (letterIdx >= letters.length) {
      _allCompleted = true;
      _onCompleteAllLetters();
      return;
    }

    final data = letters[letterIdx];
    final ltr = data['letter']?.toString() ?? 'A';
    final wrd = data['word']?.toString() ?? 'Apple';
    final em = data['emoji']?.toString() ?? '🍎';
    final color = _balloonPalette[letterIdx % _balloonPalette.length];

    _activeBalloons.clear();
    _activeBalloons.add(
      SkyBalloonItem(
        letter: ltr,
        word: wrd,
        emoji: em,
        color: color,
        x: 0.5, // Dead center horizontally
        y: 1.12, // Start below screen in the green meadow
        targetY: 0.40, // Stops right in the center of the screen
        swayPhase: 0.0,
      ),
    );
  }

  @override
  void dispose() {
    _gameLoopController.dispose();
    _pulseController.dispose();
    _tts.stop();
    try {
      if (_speechAvailable) _speech.stop();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_isSoundMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  // =========================================================================
  // 🎮 GAME LOOP: FLOAT UP TO CENTER & HOVER
  // =========================================================================

  void _gameLoop() {
    if (_allCompleted) return;

    setState(() {
      _cloudScroll += 0.15;

      for (final b in _activeBalloons) {
        if (!b.isPopped) {
          // If balloon is below center, float up smoothly
          if (b.y > b.targetY) {
            b.y -= 0.010; // Smooth, steady float up to center
            if (b.y < b.targetY) b.y = b.targetY;
          } else {
            // Balloon has reached center: gently hover and sway!
            b.swayPhase += 0.035;
            b.swayOffset = math.sin(b.swayPhase) * 0.025;
          }
        }
      }

      // Update pop explosion particles
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.life -= 0.04;
        if (p.life <= 0) {
          _particles.removeAt(i);
        }
      }
    });
  }

  void _handleBalloonTap(SkyBalloonItem balloon) {
    if (balloon.isPopped) return;

    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCoinSound();

    // Trigger pop explosion particles
    for (int i = 0; i < 28; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final speed = 0.007 + _random.nextDouble() * 0.014;
      _particles.add(
        BalloonPopParticle(
          x: balloon.x + balloon.swayOffset,
          y: balloon.y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          life: 1.0,
          color: balloon.color,
          size: 6 + _random.nextDouble() * 7,
        ),
      );
    }

    setState(() {
      balloon.isPopped = true;
      _poppedLetters.add(balloon.letter);
    });

    // 🛑 User Directive: NEVER speak "A for Apple" from the game side!
    // Pronounce ONLY the alphabet letter ("A")!
    _speak(balloon.letter);
  }

  /// Handles Child Tapping the Minimal Bottom Floating Mic Button
  void _handleMicFabTap(SkyBalloonItem balloon) {
    HapticFeedback.mediumImpact();

    if (!_isListening) {
      // Start listening
      _isAdvancing = false;
      setState(() => _isListening = true);

      final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
      if (isMobile && _speechAvailable) {
        try {
          _speech.listen(
            onResult: (result) {
              if (result.finalResult && mounted && !_isAdvancing) {
                _isAdvancing = true;
                _advanceToNextLetter();
              }
            },
            listenOptions: stt.SpeechListenOptions(
              listenFor: const Duration(seconds: 5),
              pauseFor: const Duration(seconds: 2),
              listenMode: stt.ListenMode.dictation,
            ),
          );
        } catch (_) {}
      } else {
        // Auto-advance after 2 seconds if web/simulator
        Future.delayed(const Duration(milliseconds: 2200), () {
          if (mounted && _isListening && !_isAdvancing) {
            _isAdvancing = true;
            _advanceToNextLetter();
          }
        });
      }
    } else {
      // Child tapped again to finish and continue
      if (!_isAdvancing) {
        _isAdvancing = true;
        _advanceToNextLetter();
      }
    }
  }

  void _advanceToNextLetter() {
    try {
      if (_speechAvailable) _speech.stop();
    } catch (_) {}

    PocketGameAudioService.instance.playVictorySfx();

    setState(() {
      _isListening = false;
      _currentLetterIndex++;
      final letters = Day1AlphabetData.lettersAtoZ;
      if (_currentLetterIndex < letters.length) {
        _spawnTargetLetterBalloon(_currentLetterIndex.clamp(0, letters.length - 1));
      } else {
        _allCompleted = true;
        _onCompleteAllLetters();
      }
      _isAdvancing = false;
    });
  }

  Future<void> _onCompleteAllLetters() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playVictorySfx();
    _speak('Congratulations! You completed all letters!');

    final uid = widget.userId ?? SupaFlow.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pocket_day_${uid ?? "guest"}_1_step_1_done', true);

    if (uid != null && uid.isNotEmpty) {
      await PocketFortressDefenseService.recordTrainingPoints(35, uid);
    }

    widget.onCompleted?.call();
  }

  // =========================================================================
  // 🎨 UI & CANVAS DRAWING
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final currentItem = _activeBalloons.isNotEmpty ? _activeBalloons.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0284C7),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Atmosphere Canvas (Sky, Sun, Clouds, Green Meadow, Trees)
            Positioned.fill(
              child: CustomPaint(
                painter: _BalloonSkyPainter(
                  cloudScroll: _cloudScroll,
                  particles: _particles,
                ),
              ),
            ),

            // 2. Interactive Floating Balloon (Floats up from bottom and rests at center)
            if (currentItem != null && !currentItem.isPopped)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final posX = (currentItem.x + currentItem.swayOffset) * constraints.maxWidth - 44;
                    final posY = currentItem.y * constraints.maxHeight - 55;

                    return Stack(
                      children: [
                        Positioned(
                          left: posX.clamp(16.0, constraints.maxWidth - 100.0),
                          top: posY,
                          child: GestureDetector(
                            onTap: () => _handleBalloonTap(currentItem),
                            child: _buildBalloonWidget(currentItem),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // 3. Popped Letter Showcase (When tapped, rests in center with emoji & word)
            if (currentItem != null && currentItem.isPopped)
              Positioned.fill(
                child: Center(
                  child: _buildPoppedCenterShowcase(currentItem),
                ),
              ),

            // 4. Responsive Minimal Top Bar (No long title, no XP clutter, plenty of space!)
            Positioned(
              top: 10,
              left: 14,
              right: 14,
              child: _buildMinimalTopBar(),
            ),

            // 5. Minimal Bottom Floating Mic Action (Centered, clean prompt above it)
            if (currentItem != null && currentItem.isPopped)
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: _buildMinimalBottomMicSection(currentItem),
              ),

            // 6. Grand Victory Overlay when all letters are finished
            if (_allCompleted)
              Positioned.fill(
                child: _buildGrandVictoryOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  /// 🌟 Super Clean, Responsive Top Navigation Bar
  Widget _buildMinimalTopBar() {
    final letters = Day1AlphabetData.lettersAtoZ;
    final currentLetter = _currentLetterIndex < letters.length
        ? letters[_currentLetterIndex]['letter'] ?? 'A'
        : 'Z';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.75),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          ),
        ),

        // Clean, Compact Title & Letter Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎈', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Balloon Game • Letter $currentLetter (${_currentLetterIndex + 1}/26)',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),

        // Sound Mute Toggle
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _isSoundMuted = !_isSoundMuted);
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.75),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(
              _isSoundMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: _isSoundMuted ? Colors.redAccent : const Color(0xFFFFD700),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// 🎈 Large, Beautiful Floating Balloon (Center area)
  Widget _buildBalloonWidget(SkyBalloonItem balloon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Balloon Body
        Container(
          width: 88,
          height: 104,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.4),
              radius: 0.85,
              colors: [
                Colors.white.withValues(alpha: 0.88),
                balloon.color,
                balloon.color.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(44),
              bottom: Radius.circular(52),
            ),
            boxShadow: [
              BoxShadow(
                color: balloon.color.withValues(alpha: 0.55),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              balloon.letter,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                shadows: [
                  const Shadow(
                    color: Colors.black45,
                    offset: Offset(1.5, 1.5),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Balloon Knot
        CustomPaint(
          size: const Size(16, 8),
          painter: _BalloonKnotPainter(balloon.color),
        ),

        // String
        Container(
          width: 1.5,
          height: 28,
          color: Colors.white70,
        ),
      ],
    );
  }

  /// 🌟 Popped Center Showcase: Clean, Elegant, showing Letter & Emoji
  Widget _buildPoppedCenterShowcase(SkyBalloonItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
      margin: const EdgeInsets.only(bottom: 90),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 10),
          Text(
            item.letter,
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFD700),
              fontSize: 52,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            item.word,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 🎙️ Minimal Centered Floating Mic Button with Clean Text Above It
  Widget _buildMinimalBottomMicSection(SkyBalloonItem item) {
    final targetPhrase = '${item.letter} for ${item.word}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Minimal clean prompt: Speak "A for Apple" (no extra clutter or translations)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isListening ? const Color(0xFFEF4444) : const Color(0xFFFFD700),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            'Speak "$targetPhrase"',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Centered Floating Action Button (Mic)
        GestureDetector(
          onTap: () => _handleMicFabTap(item),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = _isListening
                  ? 1.0 + (_pulseController.value * 0.12)
                  : 1.0;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isListening
                          ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)]
                          : [const Color(0xFF059669), const Color(0xFF10B981)],
                    ),
                    border: Border.all(
                      color: _isListening
                          ? const Color(0xFFFCA5A5)
                          : const Color(0xFFFFD700),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isListening
                            ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                            : const Color(0xFF10B981).withValues(alpha: 0.5),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Subtle hint
        Text(
          _isListening ? 'Listening... Tap to finish' : 'Tap mic to speak / continue',
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGrandVictoryOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.88),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              Text(
                'A-Z SKY QUEST COMPLETED! 🎈',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You popped all 26 balloons and mastered A-Z phonics!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '🚗 COMPLETE STEP 1 ➔',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🌄 CustomPainter for Open Sky, Sun, Clouds, Green Meadow, and Trees
class _BalloonSkyPainter extends CustomPainter {
  final double cloudScroll;
  final List<BalloonPopParticle> particles;

  _BalloonSkyPainter({
    required this.cloudScroll,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky Gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Radiant Sun ☀️
    final sunCenter = Offset(size.width * 0.84, size.height * 0.14);
    final sunGlowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(sunCenter, 42, sunGlowPaint);

    final sunPaint = Paint()..color = const Color(0xFFFFF066);
    canvas.drawCircle(sunCenter, 24, sunPaint);

    // 3. Clouds
    _drawCloud(canvas, Offset((cloudScroll * 18) % (size.width + 120) - 60, size.height * 0.08), 38);
    _drawCloud(canvas, Offset(((cloudScroll * 12) + 160) % (size.width + 120) - 60, size.height * 0.16), 30);

    // 4. Distant Green Hills
    final distantHillPaint = Paint()..color = const Color(0xFF059669);
    final distantHillPath = Path();
    distantHillPath.moveTo(0, size.height * 0.88);
    for (double x = 0; x <= size.width; x += 40) {
      final y = size.height * 0.86 + math.sin(x * 0.015) * 12;
      distantHillPath.lineTo(x, y);
    }
    distantHillPath.lineTo(size.width, size.height);
    distantHillPath.lineTo(0, size.height);
    distantHillPath.close();
    canvas.drawPath(distantHillPath, distantHillPaint);

    // 5. Fore-ground Lush Green Meadow
    final meadowPaint = Paint()..color = const Color(0xFF10B981);
    final meadowPath = Path();
    meadowPath.moveTo(0, size.height * 0.91);
    for (double x = 0; x <= size.width; x += 30) {
      final y = size.height * 0.90 + math.sin(x * 0.02) * 8;
      meadowPath.lineTo(x, y);
    }
    meadowPath.lineTo(size.width, size.height);
    meadowPath.lineTo(0, size.height);
    meadowPath.close();
    canvas.drawPath(meadowPath, meadowPaint);

    // 6. Trees at the bottom
    _drawTree(canvas, Offset(size.width * 0.12, size.height * 0.91), 22);
    _drawTree(canvas, Offset(size.width * 0.88, size.height * 0.90), 26);

    // 7. Pop Explosion Particles
    for (final p in particles) {
      final pPaint = Paint()..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, pPaint);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double radius) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.82);
    canvas.drawCircle(center, radius, cloudPaint);
    canvas.drawCircle(center.translate(-radius * 0.55, radius * 0.1), radius * 0.75, cloudPaint);
    canvas.drawCircle(center.translate(radius * 0.55, radius * 0.1), radius * 0.75, cloudPaint);
  }

  void _drawTree(Canvas canvas, Offset groundPos, double height) {
    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF78350F)..strokeWidth = 4;
    canvas.drawLine(groundPos, groundPos.translate(0, -height), trunkPaint);

    // Foliage
    final foliagePaint = Paint()..color = const Color(0xFF047857);
    canvas.drawCircle(groundPos.translate(0, -height - 10), height * 0.65, foliagePaint);
  }

  @override
  bool shouldRepaint(covariant _BalloonSkyPainter oldDelegate) => true;
}

class _BalloonKnotPainter extends CustomPainter {
  final Color color;
  _BalloonKnotPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BalloonKnotPainter oldDelegate) => false;
}
