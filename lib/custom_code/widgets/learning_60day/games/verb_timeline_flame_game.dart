import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_verb_localization_service.dart';
import '../pocket_fortress_defense_service.dart';
import '../curriculum_data/pocket_90day_verb_timeline_data.dart';

/// 🌟 Flame Particle Sparkle for Verb Timeline celebration
class VerbParticleSparkle extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  final double radius;
  double life = 1.0;
  final double decay;

  VerbParticleSparkle({
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

/// 🔥 Flame Game Engine for Verb Timeline & Tenses Arcade
class VerbTimelineFlameGame extends FlameGame {
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
      if (children.whereType<VerbParticleSparkle>().length < 25) {
        final p = VerbParticleSparkle(
          position: Vector2(_rng.nextDouble() * size.x, size.y + 10),
          velocity: Vector2(
            (_rng.nextDouble() - 0.5) * 30,
            -30 - _rng.nextDouble() * 40,
          ),
          color: (_rng.nextBool()
                  ? const Color(0xFFFF9100)
                  : const Color(0xFF00E5FF))
              .withValues(alpha: 0.5),
          radius: 1.5 + _rng.nextDouble() * 2.0,
          decay: 0.35,
        );
        add(p);
      }
    }
  }

  void burstCelebration(Vector2 pos, Color tileColor) {
    for (int i = 0; i < 20; i++) {
      final angle = _rng.nextDouble() * math.pi * 2;
      final speed = 80.0 + _rng.nextDouble() * 160.0;
      final p = VerbParticleSparkle(
        position: pos.clone(),
        velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed - 50),
        color: i % 2 == 0 ? tileColor : const Color(0xFFFFD700),
        radius: 2.5 + _rng.nextDouble() * 3.5,
        decay: 1.4 + _rng.nextDouble() * 0.8,
      );
      add(p);
    }
  }

  void burstMegaVictory(Vector2 center) {
    final colors = [
      const Color(0xFFFF9100),
      const Color(0xFF00E676),
      const Color(0xFF00E5FF),
      const Color(0xFFFFD700),
      const Color(0xFFE91E63),
    ];
    for (int i = 0; i < 45; i++) {
      final angle = _rng.nextDouble() * math.pi * 2;
      final speed = 100.0 + _rng.nextDouble() * 220.0;
      final c = colors[i % colors.length];
      final p = VerbParticleSparkle(
        position: center.clone(),
        velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed - 80),
        color: c,
        radius: 3.0 + _rng.nextDouble() * 4.0,
        decay: 1.1 + _rng.nextDouble() * 0.6,
      );
      add(p);
    }
  }
}

/// 🎮 Full-Screen Verb Timeline & Tenses Arcade Game Page
class PocketVerbTimelineGamePage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketVerbTimelineGamePage({
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
        builder: (_) => PocketVerbTimelineGamePage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketVerbTimelineGamePage> createState() =>
      _PocketVerbTimelineGamePageState();
}

class _PocketVerbTimelineGamePageState extends State<PocketVerbTimelineGamePage>
    with SingleTickerProviderStateMixin {
  late final VerbTimelineFlameGame _flameGame;
  final FlutterTts _flutterTts = FlutterTts();

  late final List<VerbTimelineItem> _items;
  int _currentIndex = 0;

  String? _placedPast;
  String? _placedPresent;
  String? _placedFuture;

  // 'present' | 'future' | 'past'
  String _anchorTense = 'present';

  // Remaining available words at bottom
  final List<String> _remainingCards = [];

  bool _isRoundCompleted = false;

  late AnimationController _shakeAnimController;
  String? _shakingCard;

  @override
  void initState() {
    super.initState();
    _flameGame = VerbTimelineFlameGame();
    _initTts();

    _shakeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _items = Pocket90DayVerbTimelineData.getVerbsForDay(widget.day);
    _loadCurrentVerb();
  }

  @override
  void dispose() {
    _shakeAnimController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("en-IN");
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setPitch(1.05);
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_flutterTts);
    } catch (_) {}
  }

  void _loadCurrentVerb() {
    if (_currentIndex >= _items.length) {
      _showCompletionDialog();
      return;
    }

    final item = _items[_currentIndex];

    // User Audio Directive:
    // "Aa step-il vendath: Present, athe pole past, past present future. Athan concept, okay? Oru verb kodukkum.
    // Aa verbinte past-um, present-um, future-um padikkuka.
    // Athengane, chila samayath future kodukkum, apo athinte present-um past-um padikkuka.
    // Present kodukkumbozhekk future-um past-um padikkuka.
    // Angane oru saadhanam. Ee sentence builder ille, athe same concept, same saadhanam, ath angane avide kodutho."
    //
    // Rotate anchor types:
    // Round 0: PRESENT given -> user finds Past & Future
    // Round 1: FUTURE given -> user finds Present & Past
    // Round 2: PAST given -> user finds Present & Future
    // Round 3: PRESENT given -> user finds Past & Future
    final int mode = _currentIndex % 3;
    final bool isPresentPrePlaced = mode == 0;
    final bool isFuturePrePlaced = mode == 1;
    final bool isPastPrePlaced = mode == 2;

    _anchorTense = isPresentPrePlaced
        ? 'present'
        : (isFuturePrePlaced ? 'future' : 'past');

    final placedPast = isPastPrePlaced ? item.past : null;
    final placedPresent = isPresentPrePlaced ? item.present : null;
    final placedFuture = isFuturePrePlaced ? item.future : null;

    // Remaining words for user to find from Word Bank:
    final Set<String> targetWords = {};
    if (placedPast == null) targetWords.add(item.past);
    if (placedPresent == null) targetWords.add(item.present);
    if (placedFuture == null) targetWords.add(item.future);

    // Add distractor action verbs from other items in Day 1:
    final Set<String> wordBankSet = Set.from(targetWords);
    for (final other in _items) {
      if (other.baseVerb != item.baseVerb) {
        wordBankSet.add(other.past);
        wordBankSet.add(other.present);
        wordBankSet.add(other.future);
      }
    }
    final words = wordBankSet.toList()..shuffle(math.Random());

    setState(() {
      _placedPast = placedPast;
      _placedPresent = placedPresent;
      _placedFuture = placedFuture;
      _remainingCards.clear();
      _remainingCards.addAll(words);
      _isRoundCompleted = false;
      _shakingCard = null;
    });
  }

  void _onPlacedWordTapped(String tense) {
    if (_isRoundCompleted) {
      final item = _items[_currentIndex];
      if (tense == 'past') _speak(item.pastSentence);
      if (tense == 'present') _speak(item.presentSentence);
      if (tense == 'future') _speak(item.futureSentence);
      return;
    }

    if (tense == _anchorTense) {
      // Anchor is fixed, tap plays audio
      final item = _items[_currentIndex];
      if (tense == 'past') _speak(item.pastSentence);
      if (tense == 'present') _speak(item.presentSentence);
      if (tense == 'future') _speak(item.futureSentence);
      return;
    }

    // User-placed word: pop back to word bank
    PocketGameSfx.instance.playTilePop();
    setState(() {
      if (tense == 'past' && _placedPast != null) {
        _remainingCards.add(_placedPast!);
        _placedPast = null;
      } else if (tense == 'present' && _placedPresent != null) {
        _remainingCards.add(_placedPresent!);
        _placedPresent = null;
      } else if (tense == 'future' && _placedFuture != null) {
        _remainingCards.add(_placedFuture!);
        _placedFuture = null;
      }
    });
  }

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  void _onCardTapped(String word) {
    if (_isRoundCompleted) return;

    final item = _items[_currentIndex];
    final screenW = MediaQuery.of(context).size.width;

    // 1. Is it the target PAST word?
    if (word == item.past) {
      if (_placedPast != null) return;
      PocketGameSfx.instance.playSnapCorrect();
      HapticFeedback.mediumImpact();
      setState(() {
        _placedPast = word;
        _remainingCards.remove(word);
      });
      _speak('${item.past}. ${item.pastSentence}');
      _flameGame.burstCelebration(
        Vector2(screenW * 0.2, 220),
        const Color(0xFFE91E63),
      );
      _checkRoundCompletion();
      return;
    }

    // 2. Is it the target PRESENT word?
    if (word == item.present) {
      if (_placedPresent != null) return;
      PocketGameSfx.instance.playSnapCorrect();
      HapticFeedback.mediumImpact();
      setState(() {
        _placedPresent = word;
        _remainingCards.remove(word);
      });
      _speak('${item.present}. ${item.presentSentence}');
      _flameGame.burstCelebration(
        Vector2(screenW * 0.5, 220),
        const Color(0xFF00E676),
      );
      _checkRoundCompletion();
      return;
    }

    // 3. Is it the target FUTURE word?
    if (word == item.future) {
      if (_placedFuture != null) return;
      PocketGameSfx.instance.playSnapCorrect();
      HapticFeedback.mediumImpact();
      setState(() {
        _placedFuture = word;
        _remainingCards.remove(word);
      });
      _speak('${item.future}. ${item.futureSentence}');
      _flameGame.burstCelebration(
        Vector2(screenW * 0.8, 220),
        const Color(0xFF00E5FF),
      );
      _checkRoundCompletion();
      return;
    }

    // 4. Incorrect tap -> Heavy vibration & wobble shake!
    _handleWrongCard(word);
  }

  void _checkRoundCompletion() {
    if (_placedPast != null && _placedPresent != null && _placedFuture != null) {
      _onAllSlotsFilled();
    }
  }

  void _handleWrongCard(String word) {
    PocketGameSfx.instance.playErrorBuzz();
    HapticFeedback.heavyImpact();
    setState(() => _shakingCard = word);
    _shakeAnimController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _shakingCard = null);
    });
  }

  void _onAllSlotsFilled() {
    setState(() => _isRoundCompleted = true);
    PocketGameSfx.instance.playVictory();

    final size = MediaQuery.of(context).size;
    _flameGame.burstMegaVictory(Vector2(size.width / 2, 220));

    // Speak natural rhythm chant after a short pause
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _playChant();
    });
  }

  Future<void> _playChant() async {
    if (!mounted) return;
    final item = _items[_currentIndex];
    await _speak(item.rhythmChant);
  }

  void _proceedNextVerb() {
    PocketGameSfx.instance.playClick();
    if (_currentIndex + 1 < _items.length) {
      setState(() => _currentIndex++);
      _loadCurrentVerb();
    } else {
      _showCompletionDialog();
    }
  }

  Future<void> _showCompletionDialog() async {
    final uid = widget.userId ?? Supabase.instance.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pocket_day_${uid ?? "guest"}_${widget.day}_verb_timeline_done', true);
    await PocketFortressDefenseService.recordTrainingPoints(35, uid);

    widget.onStepFinished?.call(8);

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
                'Day ${widget.day} Verb Master!',
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
              '🎉 You mastered all 4 action verb timelines with Past, Present & Future precision!',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF38083E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '+35 Fluency XP • Step 8 Complete!\nStep 9: English Hub Community Chat Unlocked! 💬',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.w700,
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
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(true);
            },
            child: Text(
              'CONTINUE TO STEP 9 (ENGLISH HUB) ➔',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _items.length) {
      return const Scaffold(backgroundColor: Color(0xFF250529));
    }

    final item = _items[_currentIndex];
    final progress = (_currentIndex + 1) / _items.length;

    return Scaffold(
      backgroundColor: const Color(0xFF250529),
      body: Stack(
        children: [
          // 1. Deep plum / magenta background gradient matching Sentence Builder
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4A0E4E),
                    Color(0xFF3A083C),
                    Color(0xFF250529),
                    Color(0xFF16031B),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 2. Background Flame particle canvas
          Positioned.fill(
            child: IgnorePointer(
              child: GameWidget(game: _flameGame),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(progress),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        _buildVerbPromptHeader(item),
                        const SizedBox(height: 16),
                        _buildTimelineRunway(item),
                        const SizedBox(height: 20),
                        if (!_isRoundCompleted) _buildWordBank(),
                        if (_isRoundCompleted) _buildCelebrationCard(item),
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

  Widget _buildAppBar(double progress) {
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
                  'DAY ${widget.day} • VERB TIMELINE',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00E5FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              '${_currentIndex + 1}/${_items.length}',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Minimal clean header: Action Verb + Dynamic Native Translation + Directive
  Widget _buildVerbPromptHeader(VerbTimelineItem item) {
    String anchorTitle;
    String anchorWord;
    Color anchorColor;

    if (_anchorTense == 'present') {
      anchorTitle = item.presentLabel;
      anchorWord = item.present;
      anchorColor = const Color(0xFF00E676);
    } else if (_anchorTense == 'future') {
      anchorTitle = item.futureLabel;
      anchorWord = item.future;
      anchorColor = const Color(0xFF00E5FF);
    } else {
      anchorTitle = item.pastLabel;
      anchorWord = item.past;
      anchorColor = const Color(0xFFE91E63);
    }

    final directive = PocketVerbLocalizationService.getDirective(
      anchorTitle: anchorTitle,
      anchorWord: anchorWord,
    );
    final localizedMeaning = item.getLocalizedMeaning();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.baseVerb.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '•',
                style: TextStyle(color: Colors.white38, fontSize: 16),
              ),
              const SizedBox(width: 10),
              Text(
                localizedMeaning,
                style: PocketVerbLocalizationService.getNativeTextStyle(
                  color: const Color(0xFF00E5FF),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: anchorColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: anchorColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  directive,
                  style: PocketVerbLocalizationService.getNativeTextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Responsive Stacked 3-Tier Timeline Shelf (Past, Present, Future)
  Widget _buildTimelineRunway(VerbTimelineItem item) {
    return Column(
      children: [
        // 1. PAST Tier
        _buildTimelineTierCard(
          title: item.pastLabel,
          sub: item.getLocalizedPastSubtitle(),
          icon: Icons.history_rounded,
          color: const Color(0xFFE91E63), // Sentence Builder Magenta
          placedWord: _placedPast,
          sentence: item.pastSentence,
          isAnchor: _anchorTense == 'past',
          tense: 'past',
        ),
        const SizedBox(height: 12),

        // 2. PRESENT Tier
        _buildTimelineTierCard(
          title: item.presentLabel,
          sub: item.getLocalizedPresentSubtitle(),
          icon: Icons.wb_sunny_rounded,
          color: const Color(0xFF00E676), // Sentence Builder Neon Green
          placedWord: _placedPresent,
          sentence: item.presentSentence,
          isAnchor: _anchorTense == 'present',
          tense: 'present',
        ),
        const SizedBox(height: 12),

        // 3. FUTURE Tier
        _buildTimelineTierCard(
          title: item.futureLabel,
          sub: item.getLocalizedFutureSubtitle(),
          icon: Icons.rocket_launch_rounded,
          color: const Color(0xFF00E5FF), // Sentence Builder Cyan
          placedWord: _placedFuture,
          sentence: item.futureSentence,
          isAnchor: _anchorTense == 'future',
          tense: 'future',
        ),
      ],
    );
  }

  Widget _buildTimelineTierCard({
    required String title,
    required String sub,
    required IconData icon,
    required Color color,
    required String? placedWord,
    required String sentence,
    required bool isAnchor,
    required String tense,
  }) {
    final isFilled = placedWord != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isFilled
            ? color.withValues(alpha: 0.12)
            : const Color(0xFF131722),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFilled ? color : Colors.white12,
          width: isFilled ? 2.0 : 1.0,
        ),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Icon + Title + Native sub + Anchor/Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sub,
                  style: PocketVerbLocalizationService.getNativeTextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isAnchor)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 12),
                      const SizedBox(width: 3),
                      Text(
                        'GIVEN',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Content Box: Placed Word vs Drop/Tap Target
          if (isFilled)
            GestureDetector(
              onTap: () => _onPlacedWordTapped(tense),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAnchor ? const Color(0xFFFFD700) : color,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          placedWord,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        if (!isAnchor && !_isRoundCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.close_rounded, size: 12, color: Colors.white70),
                                const SizedBox(width: 3),
                                Text(
                                  'Tap to remove',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Icon(
                            isAnchor ? Icons.lock_outline_rounded : Icons.check_circle_rounded,
                            size: 16,
                            color: isAnchor ? const Color(0xFFFFD700) : color,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Sentence bar with audio button
                    GestureDetector(
                      onTap: () => _speak(sentence),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.volume_up_rounded, size: 16, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                sentence,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withValues(alpha: 0.35),
                  style: BorderStyle.solid,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_outlined, size: 14, color: color.withValues(alpha: 0.8)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Tap $title',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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


  /// 📚 Word Bank with direct downward Wrap (NO horizontal scroll)
  /// User Audio Directive:
  /// "word vocabulary horizontal scrolling കൊടുക്കാതെ ഫുൾ അടിയിലേക്ക് കാണണം.
  /// എന്നിട്ട് എന്ത് ചെയ്യുക? ഒരു word bank ന്റെ അടിയിൽ കൊടുക്കുക."
  Widget _buildWordBank() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0E38).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'WORD BANK',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: _remainingCards.map((word) {
              final isShaking = _shakingCard == word;

              // Uniform styling for all cards (avoids giving away answers)
              const tileColor = Color(0xFF2A1647);

              return AnimatedBuilder(
                animation: _shakeAnimController,
                builder: (ctx, child) {
                  double offset = 0.0;
                  if (isShaking) {
                    offset = math.sin(_shakeAnimController.value * math.pi * 6) * 8.0;
                  }
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () => _onCardTapped(word),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(10),
                      border: isShaking
                          ? Border.all(color: Colors.redAccent, width: 2.2)
                          : Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.5), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 10,
                          offset: const Offset(3, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      word,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationCard(VerbTimelineItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0E38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E676), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.2),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'TIMELINE COMPLETE!',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF00E676),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummarySentenceRow('⏪ Yesterday', item.pastSentence, const Color(0xFFE91E63)),
          const SizedBox(height: 6),
          _buildSummarySentenceRow('☀️ Today', item.presentSentence, const Color(0xFF00E676)),
          const SizedBox(height: 6),
          _buildSummarySentenceRow('🚀 Tomorrow', item.futureSentence, const Color(0xFF00E5FF)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.getLocalizedGrammarTrap(),
                    style: PocketVerbLocalizationService.getNativeTextStyle(
                      color: const Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _proceedNextVerb,
            child: Text(
              _currentIndex + 1 < _items.length ? 'Next Verb Challenge ➔' : 'Complete Step 8 🏆',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySentenceRow(String label, String sentence, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              sentence,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
