import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import '../pocket_fortress_defense_service.dart';
import '../curriculum_data/pocket_90day_sentence_builder_data.dart';

/// 🧩 Sentence Challenge Question Model
class SentenceChallengeRound {
  final int id;
  final String sentence; // Target full sentence
  final String translationMl; // Malayalam translation
  final String? translationHi;
  final String? translationTa;
  final String? translationTe;
  final String? translationKn;
  final List<SentenceTileData> tiles; // Words with assigned colors
  final String hint; // Helpful grammatical or contextual hint

  const SentenceChallengeRound({
    required this.id,
    required this.sentence,
    required this.translationMl,
    this.translationHi,
    this.translationTa,
    this.translationTe,
    this.translationKn,
    required this.tiles,
    required this.hint,
  });

  String getLocalizedTranslation() {
    if (PocketLanguageService.isEnglish) {
      return hint.isNotEmpty ? hint : 'Arrange words in the correct order';
    }
    if (PocketLanguageService.isMalayalam) {
      return translationMl;
    }
    if (PocketLanguageService.isHindi && translationHi != null && translationHi!.isNotEmpty) {
      return translationHi!;
    }
    if (PocketLanguageService.isTamil && translationTa != null && translationTa!.isNotEmpty) {
      return translationTa!;
    }
    if (PocketLanguageService.isTelugu && translationTe != null && translationTe!.isNotEmpty) {
      return translationTe!;
    }
    if (PocketLanguageService.isKannada && translationKn != null && translationKn!.isNotEmpty) {
      return translationKn!;
    }
    // Never fall back to Malayalam for non-Malayalam users!
    return hint.isNotEmpty ? hint : 'Arrange words to form the sentence';
  }
}

/// 🎨 Tile color classifications matching screenshots 3 & 4
enum SentenceTileColor {
  magenta, // Pink/red tiles like "Did", "put", "refrigerator", "asked"
  green,   // Bright green tiles like "you"
  cyan,    // Sky blue tiles like "in", "the", "?", "Who"
}

class SentenceTileData {
  final String id;
  final String word;
  final SentenceTileColor colorType;

  const SentenceTileData({
    required this.id,
    required this.word,
    required this.colorType,
  });

  Color get backgroundColor {
    switch (colorType) {
      case SentenceTileColor.magenta:
        return const Color(0xFFE91E63); // Vibrant Pink / Magenta
      case SentenceTileColor.green:
        return const Color(0xFF00E676); // Vibrant Green
      case SentenceTileColor.cyan:
        return const Color(0xFF00E5FF); // Vibrant Sky Cyan
    }
  }

  Color get textColor {
    return Colors.white;
  }
}

/// 🌟 Flame Particle Sparkle Component for celebratory pops
class ParticleSparkle extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  final double radius;
  double life = 1.0;
  final double decay;

  ParticleSparkle({
    required Vector2 position,
    required this.velocity,
    required this.color,
    required this.radius,
    this.decay = 1.8,
  }) : super(position: position);

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity.y += 180.0 * dt; // gravity
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
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * life, paint);
  }
}

/// 🔥 Sentence Builder Flame Game Engine
/// Manages atmospheric floating cosmic dust and celebratory particle bursts
class SentenceBuilderFlameGame extends FlameGame {
  final math.Random _rng = math.Random();
  double _ambientTimer = 0.0;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  void update(double dt) {
    super.update(dt);
    _ambientTimer += dt;
    if (_ambientTimer > 0.35) {
      _ambientTimer = 0;
      if (children.whereType<ParticleSparkle>().length < 25) {
        // Spawn subtle ambient drifting light mote
        final p = ParticleSparkle(
          position: Vector2(_rng.nextDouble() * size.x, size.y + 10),
          velocity: Vector2(
            (_rng.nextDouble() - 0.5) * 30,
            -30 - _rng.nextDouble() * 40,
          ),
          color: (_rng.nextBool()
                  ? const Color(0xFF00E5FF)
                  : const Color(0xFFE91E63))
              .withValues(alpha: 0.5),
          radius: 1.5 + _rng.nextDouble() * 2.0,
          decay: 0.35,
        );
        add(p);
      }
    }
  }

  /// Trigger a vibrant burst of confetti sparkles when a word is placed correctly
  void burstWordCelebration(Vector2 pos, Color tileColor) {
    for (int i = 0; i < 18; i++) {
      final angle = _rng.nextDouble() * math.pi * 2;
      final speed = 80.0 + _rng.nextDouble() * 160.0;
      final p = ParticleSparkle(
        position: pos.clone(),
        velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed - 50),
        color: i % 2 == 0 ? tileColor : const Color(0xFFFFD700),
        radius: 2.5 + _rng.nextDouble() * 3.5,
        decay: 1.4 + _rng.nextDouble() * 0.8,
      );
      add(p);
    }
  }
}

/// 🎮 Full-Screen Sentence Builder Interactive Page
/// Recreates screenshots 3 and 4 with high fidelity, Flame animations,
/// realistic touch feedback, sound effects, and Malayalam audio translation.
/// Expanded across ALL 90 DAYS with progressive difficulty!
class PocketSentenceBuilderGamePage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketSentenceBuilderGamePage({
    super.key,
    this.day = 1,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    String? userId,
    Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketSentenceBuilderGamePage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketSentenceBuilderGamePage> createState() =>
      _PocketSentenceBuilderGamePageState();
}

/// Backward compatibility alias for Day 1
typedef PocketDay1SentenceBuilderGamePage = PocketSentenceBuilderGamePage;

class _PocketSentenceBuilderGamePageState
    extends State<PocketSentenceBuilderGamePage>
    with TickerProviderStateMixin {
  late final SentenceBuilderFlameGame _flameGame;
  final FlutterTts _flutterTts = FlutterTts();

  int _currentRoundIdx = 0;
  bool _isRoundCompleted = false;
  bool _isSpeaking = false;

  // Selected tiles placed in the top area
  final List<SentenceTileData> _placedTiles = [];

  // Remaining tiles available in the bottom word bank
  final List<SentenceTileData> _remainingTiles = [];

  // Tile shaking/wobble animation state for incorrect taps
  String? _shakingTileId;
  late AnimationController _shakeAnimController;

  // Hint state
  String? _hintHighlightedTileId;

  // 90-Day Progressive Sentence Rounds (Loaded dynamically with 0 duplicates!)
  late final List<SentenceChallengeRound> _rounds;

  @override
  void initState() {
    super.initState();
    _flameGame = SentenceBuilderFlameGame();
    _initTts();

    _shakeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _rounds = Pocket90DaySentenceBuilderData.getSentencesForDay(widget.day);
    _loadRound(_currentRoundIdx);
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("en-IN");
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setPitch(1.05);
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_flutterTts);
    } catch (_) {}
  }

  void _loadRound(int index) {
    if (index >= _rounds.length) {
      _showAllCompletedDialog();
      return;
    }

    final round = _rounds[index];
    final shuffled = List<SentenceTileData>.from(round.tiles);
    // Shuffle the tiles so they are scrambled in the bottom word bank
    shuffled.shuffle(math.Random());

    setState(() {
      _currentRoundIdx = index;
      _placedTiles.clear();
      _remainingTiles.clear();
      _remainingTiles.addAll(shuffled);
      _isRoundCompleted = false;
      _hintHighlightedTileId = null;
      _shakingTileId = null;
    });
  }

  Future<void> _speakText(String text) async {
    try {
      if (mounted) setState(() => _isSpeaking = true);
      await _flutterTts.stop();
      await _flutterTts.speak(text);
      if (mounted) setState(() => _isSpeaking = false);
    } catch (_) {
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  /// Check whether tapping [tile] corresponds to the next expected word in sequence
  void _onTileTapped(SentenceTileData tile) {
    if (_isRoundCompleted) return;

    final round = _rounds[_currentRoundIdx];
    final targetWords = round.sentence.split(' ');
    final nextExpectedIndex = _placedTiles.length;

    if (nextExpectedIndex >= targetWords.length) return;

    final expectedWord = targetWords[nextExpectedIndex];

    // Case-sensitive or exact word comparison
    if (tile.word == expectedWord) {
      // ✅ CORRECT TILE!
      PocketGameSfx.instance.playSnapCorrect();

      setState(() {
        _remainingTiles.removeWhere((t) => t.id == tile.id);
        _placedTiles.add(tile);
        _hintHighlightedTileId = null;
      });

      // Pronounce the placed word for audio learning
      _speakText(tile.word);

      // Spawn Flame celebration sparkles
      _flameGame.burstWordCelebration(
        Vector2(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height * 0.32,
        ),
        tile.backgroundColor,
      );

      // Check if entire sentence is completed
      if (_placedTiles.length == targetWords.length) {
        _onRoundCompleted();
      }
    } else {
      // ❌ WRONG TILE!
      // User Audio Directive:
      // "തെറ്റായിട്ട് ഇട്ടു കഴിഞ്ഞുകഴിഞ്ഞാൽ വേറെന്തെങ്കിലും സൗണ്ട് കാണിക്കും...
      //  ഫസ്റ്റ് മിൽക്ക് ടാപ്പ് ചെയ്തു കഴിഞ്ഞാൽ അവിടെ വരില്ല, ജസ്റ്റ് വൈബ്രേറ്റ് / ആടും, ഗെയിം ഫീൽ!"
      PocketGameSfx.instance.playErrorBuzz();

      setState(() {
        _shakingTileId = tile.id;
      });

      _shakeAnimController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _shakingTileId = null;
          });
        }
      });

      // Show gentle snackbar guidance
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Try another word to begin or continue the sentence!',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  /// Remove a tile from the top assembled area back to the bottom word bank
  void _onPlacedTileTapped(SentenceTileData tile) {
    if (_isRoundCompleted) return;
    PocketGameSfx.instance.playTilePop();
    setState(() {
      _placedTiles.removeWhere((t) => t.id == tile.id);
      _remainingTiles.add(tile);
    });
  }

  void _onRoundCompleted() {
    setState(() {
      _isRoundCompleted = true;
    });

    PocketGameSfx.instance.playVictory();

    // Speak the full completed sentence with native TTS
    final fullSentence = _rounds[_currentRoundIdx].sentence;
    _speakText(fullSentence);

    // Flame celebration burst
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (!mounted) return;
        _flameGame.burstWordCelebration(
          Vector2(
            MediaQuery.of(context).size.width * (0.3 + (i * 0.2)),
            MediaQuery.of(context).size.height * 0.28,
          ),
          const Color(0xFF00E676),
        );
      });
    }
  }

  void _giveHint() {
    if (_isRoundCompleted) return;
    PocketGameSfx.instance.playClick();

    final round = _rounds[_currentRoundIdx];
    final targetWords = round.sentence.split(' ');
    final nextIndex = _placedTiles.length;
    if (nextIndex >= targetWords.length) return;

    final expectedWord = targetWords[nextIndex];
    final matchingRemaining =
        _remainingTiles.where((t) => t.word == expectedWord).firstOrNull;

    if (matchingRemaining != null) {
      setState(() {
        _hintHighlightedTileId = matchingRemaining.id;
      });

      // Speak word as hint
      _speakText(expectedWord);
    } else {
      _speakText(round.hint);
    }
  }

  void _proceedNextRound() {
    PocketGameSfx.instance.playClick();
    if (_currentRoundIdx + 1 < _rounds.length) {
      _loadRound(_currentRoundIdx + 1);
    } else {
      _showAllCompletedDialog();
    }
  }

  Future<void> _showAllCompletedDialog() async {
    final uid = widget.userId ?? Supabase.instance.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pocket_day_${uid ?? "guest"}_${widget.day}_step_2_done', true);
    await PocketFortressDefenseService.recordTrainingPoints(30, uid);

    widget.onStepFinished?.call(2);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF250529),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 2),
        ),
        title: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Day ${widget.day} Sentence Builder Mastered!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
              'Brilliant job! You completed all ${_rounds.length} sentence building rounds with native grammar order.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF38083E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700)),
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '+30 Pocket Score Earned!',
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
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              'CONTINUE TO STEP 3 ➔',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _shakeAnimController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentRound = _rounds[_currentRoundIdx];

    return Scaffold(
      backgroundColor: const Color(0xFF250529),
      body: Stack(
        children: [
          // 1. Deep magenta / plum background gradient matching Screenshots 3 & 4
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4A0E4E), // Top rich plum / magenta
                    Color(0xFF3A083C),
                    Color(0xFF250529), // Deep shadow plum
                    Color(0xFF16031B), // Bottom dark
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 2. Flame Particle Overlay (Sparkles, celebrations, and cosmic ambient dust)
          Positioned.fill(
            child: IgnorePointer(
              child: GameWidget(game: _flameGame),
            ),
          ),

          // 3. Main Gameplay Layout
          SafeArea(
            child: Column(
              children: [
                // Top App Bar matching Screenshot 4:
                // [ ✕ close ]    Beginner  ●-●-●    [ 💡 hint ]
                _buildTopHeader(),

                const SizedBox(height: 6),

                // TOP AREA: Sentence Assembly Board with Native Malayalam Prompt
                Expanded(
                  flex: 5,
                  child: _buildTopAssemblyBoard(currentRound),
                ),

                // Center Divider Line matching Screenshot 3 & 4
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),

                // BOTTOM AREA: Word Bank with Scrambled Tiles
                Expanded(
                  flex: 6,
                  child: _buildBottomWordBank(currentRound),
                ),

                // Bottom Completed Sentence Bar / Next Button
                if (_isRoundCompleted) _buildCompletionFooter(currentRound),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Top Status Bar matching Screenshot 4
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button ✕
          IconButton(
            onPressed: () {
              PocketGameSfx.instance.playClick();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 36),
          ),

          // Difficulty title + progress indicator dots
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DAY ${widget.day} • STEP 2: SENTENCE BUILDER 🧩',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF00E5FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_rounds.length, (idx) {
                  final isDone = idx < _currentRoundIdx;
                  final isCurrent = idx == _currentRoundIdx;
                  return Row(
                    children: [
                      Container(
                        width: isCurrent ? 14 : 10,
                        height: isCurrent ? 14 : 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone || isCurrent
                              ? const Color(0xFF00E5FF)
                              : Colors.white24,
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF)
                                        .withValues(alpha: 0.6),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      if (idx < _rounds.length - 1)
                        Container(
                          width: 8,
                          height: 2,
                          color: isDone
                              ? const Color(0xFF00E5FF)
                              : Colors.white24,
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),

          // Hint Bulb button 💡
          IconButton(
            onPressed: _giveHint,
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: Colors.white30),
              ),
              child: const Icon(Icons.lightbulb_outline_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  /// Top assembly drop board where correct words sit in neat sentence order
  Widget _buildTopAssemblyBoard(SentenceChallengeRound round) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🎯 Prominent Native Malayalam Challenge Banner
              // User Audio Directive: "നേറ്റീവ് ലാംഗ്വേജിലാണ് ട്ടോ അർത്ഥം വരേണ്ടത്"
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38083E), Color(0xFF580C62)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎯 ', style: TextStyle(fontSize: 16)),
                    Flexible(
                      child: Text(
                        round.getLocalizedTranslation(),
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Dropped Sentence Word Tiles
              Wrap(
                spacing: 12,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _placedTiles.isEmpty
                    ? [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                          ),
                          child: Text(
                            'Tap the word tiles below in order',
                            style: GoogleFonts.outfit(
                              color: Colors.white60,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ]
                    : _placedTiles.map((tile) {
                        return GestureDetector(
                          onTap: () => _onPlacedTileTapped(tile),
                          child: _buildTileWidget(
                            tile: tile,
                            isPlaced: true,
                            isShaking: false,
                            isHint: false,
                          ),
                        );
                      }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom word bank where scrambled tiles are displayed
  Widget _buildBottomWordBank(SentenceChallengeRound round) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            spacing: 14,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _remainingTiles.map((tile) {
              final isShaking = _shakingTileId == tile.id;
              final isHint = _hintHighlightedTileId == tile.id;

              return GestureDetector(
                onTap: () => _onTileTapped(tile),
                child: _buildTileWidget(
                  tile: tile,
                  isPlaced: false,
                  isShaking: isShaking,
                  isHint: isHint,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Reusable Tile Widget styled precisely like Screenshots 3 & 4
  Widget _buildTileWidget({
    required SentenceTileData tile,
    required bool isPlaced,
    required bool isShaking,
    required bool isHint,
  }) {
    Widget tileBox = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: EdgeInsets.symmetric(
        horizontal: tile.word.length == 1 ? 16 : 18,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: tile.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: isHint
            ? Border.all(color: const Color(0xFFFFD700), width: 3)
            : (isShaking
                ? Border.all(color: Colors.redAccent, width: 2.5)
                : null),
        boxShadow: [
          // Pronounced drop shadow matching Screenshots 3 & 4
          BoxShadow(
            color: Colors.black.withValues(alpha: isPlaced ? 0.45 : 0.6),
            blurRadius: isPlaced ? 10 : 14,
            offset: Offset(isPlaced ? 2 : 4, isPlaced ? 4 : 8),
          ),
          if (isHint)
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.6),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Text(
        tile.word,
        style: GoogleFonts.outfit(
          color: tile.textColor,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );

    // Apply shake animation if wrong tile was tapped
    if (isShaking) {
      return AnimatedBuilder(
        animation: _shakeAnimController,
        builder: (context, child) {
          final offset =
              math.sin(_shakeAnimController.value * math.pi * 5) * 8.0;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: tileBox,
      );
    }

    return tileBox;
  }

  /// Completion footer with translation and Next button
  Widget _buildCompletionFooter(SentenceChallengeRound round) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF16031B),
        border: const Border(
          top: BorderSide(color: Color(0xFF00E5FF), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Audio speaker button
          IconButton(
            onPressed: () => _speakText(round.sentence),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSpeaking ? const Color(0xFF00E5FF) : const Color(0xFF38083E),
              ),
              child: Icon(
                Icons.volume_up_rounded,
                color: _isSpeaking ? Colors.black : const Color(0xFF00E5FF),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Malayalam Meaning
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  round.sentence,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00E5FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  round.translationMl,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Next Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: _proceedNextRound,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentRoundIdx + 1 == _rounds.length ? 'FINISH' : 'NEXT',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
