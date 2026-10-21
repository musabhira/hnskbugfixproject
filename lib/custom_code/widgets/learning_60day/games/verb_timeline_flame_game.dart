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
    // "ഇപ്പൊ past സെലക്ട് ആയി കിടക്കുന്നുണ്ടെങ്കിൽ today യും tomorrow യും സെലക്ട് ചെയ്യുക.
    // ഇപ്പൊ today സെലക്ട് ആയി കിടക്കുന്നുണ്ടെങ്കിൽ past ഉം ഇതും കണക്ട് ചെയ്യുക."
    // On even rounds (0, 2): PRESENT (Today) is pre-selected and placed as anchor!
    // On odd rounds (1, 3): PAST (Yesterday) is pre-selected and placed as anchor!
    final bool isPresentPrePlaced = _currentIndex % 2 == 0;
    final bool isPastPrePlaced = _currentIndex % 2 != 0;

    final placedPast = isPastPrePlaced ? item.past : null;
    final placedPresent = isPresentPrePlaced ? item.present : null;

    // Remaining words for user to find from Word Bank:
    final Set<String> targetWords = {};
    if (placedPast == null) targetWords.add(item.past);
    if (placedPresent == null) targetWords.add(item.present);
    targetWords.add(item.future);

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
      _placedFuture = null;
      _remainingCards.clear();
      _remainingCards.addAll(words);
      _isRoundCompleted = false;
      _shakingCard = null;
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
                      '+35 Fluency XP • Step 8 Complete!\nEnglish Hub Chat unlocked!',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
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

  /// Minimal clean header: Action Verb + Malayalam translation
  Widget _buildVerbPromptHeader(VerbTimelineItem item) {
    return Container(
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
            item.meaningMl,
            style: GoogleFonts.notoSansMalayalam(
              color: const Color(0xFF00E5FF),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Minimal 3-Slot Timeline Runway
  /// User Audio Directive:
  /// "PAST, PRESENT, FUTURE ഇത്ര മാത്രം മതി. വേറെ ഒന്നും വേണ്ട.
  /// എന്നിട്ട് ജസ്റ്റ് അടിയിൽ Yesterday, Today, Tomorrow... ഇത്ര എഴുതുക. അത്ര മതി."
  Widget _buildTimelineRunway(VerbTimelineItem item) {
    return Column(
      children: [
        Row(
          children: [
            // 1. PAST / Yesterday
            Expanded(
              child: _buildTimelineSlot(
                title: 'PAST',
                sub: 'Yesterday',
                color: const Color(0xFFE91E63), // Sentence Builder Magenta
                placedWord: _placedPast,
                sentence: item.pastSentence,
              ),
            ),
            const SizedBox(width: 8),

            // 2. PRESENT / Today
            Expanded(
              child: _buildTimelineSlot(
                title: 'PRESENT',
                sub: 'Today',
                color: const Color(0xFF00E676), // Sentence Builder Green
                placedWord: _placedPresent,
                sentence: item.presentSentence,
              ),
            ),
            const SizedBox(width: 8),

            // 3. FUTURE / Tomorrow
            Expanded(
              child: _buildTimelineSlot(
                title: 'FUTURE',
                sub: 'Tomorrow',
                color: const Color(0xFF00E5FF), // Sentence Builder Cyan
                placedWord: _placedFuture,
                sentence: item.futureSentence,
              ),
            ),
          ],
        ),
        if (!_isRoundCompleted) _buildSentencePreviewBar(item),
      ],
    );
  }

  Widget _buildTimelineSlot({
    required String title,
    required String sub,
    required Color color,
    required String? placedWord,
    required String sentence,
  }) {
    final isFilled = placedWord != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: isFilled
            ? color.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFilled ? color : Colors.white12,
          width: isFilled ? 2.0 : 1.0,
        ),
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: PAST / PRESENT / FUTURE
          Text(
            title,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          // Sub: Yesterday / Today / Tomorrow
          Text(
            sub,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),

          // Word Slot
          if (isFilled)
            GestureDetector(
              onTap: () => _speak(sentence),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        placedWord,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(Icons.volume_up, size: 13, color: Colors.white),
                  ],
                ),
              ),
            )
          else
            Container(
              height: 42,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withValues(alpha: 0.4),
                  style: BorderStyle.solid,
                ),
              ),
              child: Text(
                '?',
                style: GoogleFonts.outfit(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSentencePreviewBar(VerbTimelineItem item) {
    String? activeSentence;
    Color activeColor = const Color(0xFF00E5FF);
    if (_placedFuture != null) {
      activeSentence = item.futureSentence;
      activeColor = const Color(0xFF00E5FF);
    } else if (_placedPast != null) {
      activeSentence = item.pastSentence;
      activeColor = const Color(0xFFE91E63);
    } else if (_placedPresent != null) {
      activeSentence = item.presentSentence;
      activeColor = const Color(0xFF00E676);
    }

    if (activeSentence == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _speak(activeSentence!),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: activeColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: activeColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.volume_up, size: 15, color: Colors.white70),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                activeSentence,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
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

              // Sentence Builder style colors
              Color tileColor;
              final item = _items[_currentIndex];
              if (word == item.past) {
                tileColor = const Color(0xFFE91E63);
              } else if (word == item.present) {
                tileColor = const Color(0xFF00E676);
              } else if (word == item.future) {
                tileColor = const Color(0xFF00E5FF);
              } else {
                tileColor = const Color(0xFF7C4DFF);
              }

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
                          ? Border.all(color: Colors.redAccent, width: 2.5)
                          : null,
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
