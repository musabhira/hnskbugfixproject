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

  // 3 Target Slots & Active Tier (0: Past, 1: Present, 2: Future, 3: Completed)
  int _activeTier = 0;
  String? _placedPast;
  String? _placedPresent;
  String? _placedFuture;

  // Remaining available words at bottom
  final List<String> _remainingCards = [];

  bool _isRoundCompleted = false;
  bool _isPlayingChant = false;

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
    // Pool target words and distractors from other verbs in Day 1 so the vocabulary library is rich and scrollable
    final Set<String> wordsSet = {item.past, item.present, item.future};
    for (final other in _items) {
      if (other.baseVerb != item.baseVerb) {
        wordsSet.add(other.past);
        wordsSet.add(other.present);
        wordsSet.add(other.future);
      }
    }
    final words = wordsSet.toList()..shuffle(math.Random());

    setState(() {
      _activeTier = 0;
      _placedPast = null;
      _placedPresent = null;
      _placedFuture = null;
      _remainingCards.clear();
      _remainingCards.addAll(words);
      _isRoundCompleted = false;
      _isPlayingChant = false;
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

    if (_activeTier == 0) {
      // ⏪ Top Tier: PAST / Yesterday (Past is Yesterday)
      if (word == item.past) {
        PocketGameSfx.instance.playSnapCorrect();
        HapticFeedback.mediumImpact();
        setState(() {
          _placedPast = word;
          _remainingCards.remove(word);
          _activeTier = 1;
        });
        _speak('${item.past}. ${item.pastSentence}');
        _flameGame.burstCelebration(
          Vector2(screenW * 0.5, 230),
          const Color(0xFFE91E63),
        );
      } else {
        _handleWrongCard(word, 'Top Shelf: Past is Yesterday! Select PAST form for "${item.baseVerb}"!');
      }
    } else if (_activeTier == 1) {
      // ☀️ Middle Tier: PRESENT / Today (Today is Present)
      if (word == item.present) {
        PocketGameSfx.instance.playSnapCorrect();
        HapticFeedback.mediumImpact();
        setState(() {
          _placedPresent = word;
          _remainingCards.remove(word);
          _activeTier = 2;
        });
        _speak('${item.present}. ${item.presentSentence}');
        _flameGame.burstCelebration(
          Vector2(screenW * 0.5, 330),
          const Color(0xFF00E676),
        );
      } else {
        _handleWrongCard(word, 'Middle Shelf: Today is Present! Select PRESENT form for "${item.baseVerb}"!');
      }
    } else if (_activeTier == 2) {
      // 🚀 Bottom Tier: FUTURE / Tomorrow (Tomorrow is Future)
      if (word == item.future) {
        PocketGameSfx.instance.playSnapCorrect();
        HapticFeedback.mediumImpact();
        setState(() {
          _placedFuture = word;
          _remainingCards.remove(word);
          _activeTier = 3;
        });
        _speak('${item.future}. ${item.futureSentence}');
        _flameGame.burstCelebration(
          Vector2(screenW * 0.5, 430),
          const Color(0xFF00E5FF),
        );
        _onAllSlotsFilled();
      } else {
        _handleWrongCard(word, 'Bottom Shelf: Tomorrow is Future! Select FUTURE form for "${item.baseVerb}"!');
      }
    }
  }

  void _handleWrongCard(String word, String message) {
    PocketGameSfx.instance.playErrorBuzz();
    HapticFeedback.heavyImpact();
    setState(() => _shakingCard = word);
    _shakeAnimController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _shakingCard = null);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⚠️ $message',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE11D48),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  void _onAllSlotsFilled() {
    setState(() => _isRoundCompleted = true);
    PocketGameSfx.instance.playVictory();

    final size = MediaQuery.of(context).size;
    _flameGame.burstMegaVictory(Vector2(size.width / 2, 260));

    // Sing / Chant rhythmically after a short pause
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _playChant();
    });
  }

  Future<void> _playChant() async {
    if (!mounted) return;
    setState(() => _isPlayingChant = true);
    final item = _items[_currentIndex];
    await _speak(item.rhythmChant);
    if (mounted) setState(() => _isPlayingChant = false);
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
                      '+35 Fluency XP • Step 8 Complete!\nReady for Step 9 Sing-Along Studio!',
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
                        const SizedBox(height: 16),
                        if (!_isRoundCompleted) _buildWordBank(),
                        if (_isRoundCompleted) _buildCelebrationChantCard(item),
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
                  'DAY ${widget.day} • VERB TIMELINE ARCADE',
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

  Widget _buildVerbPromptHeader(VerbTimelineItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF38083E), Color(0xFF580C62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '⚡ ACTION VERB TIMELINE',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.baseVerb.toUpperCase(),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.meaningMl,
            style: GoogleFonts.notoSansMalayalam(
              color: const Color(0xFF00E5FF),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _activeTier == 0
                  ? 'Step 1: Select PAST (Yesterday) from Word Library below 👇'
                  : (_activeTier == 1
                      ? 'Step 2: Select PRESENT (Today) from Word Library below 👇'
                      : (_activeTier == 2
                          ? 'Step 3: Select FUTURE (Tomorrow) from Word Library below 👇'
                          : '🎉 All 3 shelves assembled with precision!')),
              style: GoogleFonts.outfit(
                color: _activeTier == 0
                    ? const Color(0xFFE91E63)
                    : (_activeTier == 1
                        ? const Color(0xFF00E676)
                        : const Color(0xFF00E5FF)),
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRunway(VerbTimelineItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Shelf 1 (Top / മേലെ): PAST (YESTERDAY) • Past is Yesterday
        _buildTimelineTierShelf(
          tierIndex: 0,
          shelfNumber: '1',
          tag: 'PAST (YESTERDAY)',
          title: 'Past is Yesterday',
          sub: 'കഴിഞ്ഞത് (Yesterday)',
          icon: '⏪',
          color: const Color(0xFFE91E63), // Sentence Builder Magenta
          placedWord: _placedPast,
          exampleSentence: item.pastSentence,
          isActive: _activeTier == 0,
        ),
        const SizedBox(height: 10),

        // Shelf 2 (Middle / ഇടയിൽ): PRESENT (TODAY) • Today is Present
        _buildTimelineTierShelf(
          tierIndex: 1,
          shelfNumber: '2',
          tag: 'PRESENT (TODAY)',
          title: 'Today is Present',
          sub: 'ഇപ്പോൾ നടക്കുന്നത് (Today)',
          icon: '☀️',
          color: const Color(0xFF00E676), // Sentence Builder Green
          placedWord: _placedPresent,
          exampleSentence: item.presentSentence,
          isActive: _activeTier == 1,
        ),
        const SizedBox(height: 10),

        // Shelf 3 (Bottom / താഴെ): FUTURE (TOMORROW) • Tomorrow is Future
        _buildTimelineTierShelf(
          tierIndex: 2,
          shelfNumber: '3',
          tag: 'FUTURE (TOMORROW)',
          title: 'Tomorrow is Future',
          sub: 'ഇനി നടക്കാൻ പോകുന്നത് (Tomorrow)',
          icon: '🚀',
          color: const Color(0xFF00E5FF), // Sentence Builder Cyan
          placedWord: _placedFuture,
          exampleSentence: item.futureSentence,
          isActive: _activeTier == 2,
        ),
      ],
    );
  }

  Widget _buildTimelineTierShelf({
    required int tierIndex,
    required String shelfNumber,
    required String tag,
    required String title,
    required String sub,
    required String icon,
    required Color color,
    required String? placedWord,
    required String exampleSentence,
    required bool isActive,
  }) {
    final isFilled = placedWord != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isFilled
            ? color.withValues(alpha: 0.15)
            : (isActive
                ? color.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFilled
              ? color
              : (isActive ? color : Colors.white12),
          width: isActive || isFilled ? 2.0 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shelf Header Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      tag,
                      style: GoogleFonts.outfit(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      sub,
                      style: GoogleFonts.notoSansMalayalam(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isFilled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check, size: 13, color: Colors.black),
                      SizedBox(width: 3),
                      Text(
                        'PLACED',
                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                )
              else if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: Text(
                    '👉 TAP BELOW',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFD700),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                const Icon(Icons.lock_outline, size: 15, color: Colors.white24),
            ],
          ),

          const SizedBox(height: 10),

          // Shelf Body Content
          if (isFilled) ...[
            Row(
              children: [
                // Placed Word Badge styled like Sentence Builder Placed Tile
                GestureDetector(
                  onTap: () => _speak(exampleSentence),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(2, 4),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          placedWord,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.volume_up, size: 15, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Full Natural Sentence
                Expanded(
                  child: GestureDetector(
                    onTap: () => _speak(exampleSentence),
                    child: Text(
                      exampleSentence,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? color.withValues(alpha: 0.5) : Colors.white12,
                  style: BorderStyle.solid,
                ),
              ),
              child: Text(
                isActive ? 'Waiting for $tag word from library below...' : 'Locked slot',
                style: GoogleFonts.outfit(
                  color: isActive ? color : Colors.white30,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 📚 Word Vocabulary Library (Scrollable Word Library)
  /// User audio: "വേർഡ് ലൈബ്രറി ഉണ്ടാവും... word vocabulary, പക്ഷെ സ്ക്രോൾ ചെയ്യാൻ പറ്റണം ട്ടോ"
  Widget _buildWordBank() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0E38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📚', style: TextStyle(fontSize: 17)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WORD VOCABULARY LIBRARY',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF00E5FF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'സ്ക്രോൾ ചെയ്ത് ശരിയായ വാക്ക് ടാപ്പ് ചെയ്യുക',
                      style: GoogleFonts.notoSansMalayalam(
                        color: Colors.white60,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.swipe, size: 13, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      'Scroll ➔',
                      style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal scrollable strip of Sentence Builder styled tiles
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _remainingCards.map((word) {
                final isShaking = _shakingCard == word;

                // Color accent determined by word or cycling
                Color tileBgColor;
                final item = _items[_currentIndex];
                if (word == item.past) {
                  tileBgColor = const Color(0xFFE91E63);
                } else if (word == item.present) {
                  tileBgColor = const Color(0xFF00E676);
                } else if (word == item.future) {
                  tileBgColor = const Color(0xFF00E5FF);
                } else {
                  tileBgColor = const Color(0xFF7C4DFF);
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 4, top: 4),
                  child: AnimatedBuilder(
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _onCardTapped(word),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: tileBgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: isShaking
                                ? Border.all(color: Colors.redAccent, width: 2.5)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 10,
                                offset: const Offset(3, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                word,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.touch_app, size: 14, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationChantCard(VerbTimelineItem item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D3B2E).withValues(alpha: 0.95),
            const Color(0xFF14243B).withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E676), width: 2),
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
              const Text('🎵', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'RHYTHM CHANT & SING-ALONG',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00E676),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _isPlayingChant ? Icons.volume_up : Icons.play_circle_fill,
                  color: const Color(0xFF00E676),
                  size: 28,
                ),
                onPressed: _playChant,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.rhythmChant,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // Grammar Trap Warning Alert
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
            ),
            child: Text(
              item.grammarTrapMl,
              style: GoogleFonts.notoSansMalayalam(
                color: const Color(0xFFFFD700),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: Text(
              _currentIndex + 1 < _items.length ? 'Next Verb Challenge ➔' : 'Complete Step 8 🏆',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            onPressed: _proceedNextVerb,
          ),
        ],
      ),
    );
  }
}
