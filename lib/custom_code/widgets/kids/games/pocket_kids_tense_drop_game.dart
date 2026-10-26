import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_verb_timeline_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_card_flame_game.dart';
import 'package:pocket_mates_app/custom_code/widgets/cards/pop_art_cards_viewer_page.dart';

// ============================================================================
// 🔥 1. FLAME 2D ENGINE FOR TENSE DROP GAME
// ============================================================================

/// ☁️ Drifting Fluffy Sky Cloud Component in Flame
class FlameSkyCloud extends PositionComponent {
  final double speed;
  final double scaleFactor;

  FlameSkyCloud({
    required Vector2 position,
    required Vector2 size,
    this.speed = 15.0,
    this.scaleFactor = 1.0,
  }) : super(position: position, size: size);

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * dt;
    final parentGame = findGame();
    if (parentGame != null && position.x > parentGame.size.x + 80) {
      position.x = -size.x - 20;
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final w = size.x;
    final h = size.y;
    canvas.drawCircle(Offset(w * 0.3, h * 0.6), h * 0.45, paint);
    canvas.drawCircle(Offset(w * 0.55, h * 0.4), h * 0.55, paint);
    canvas.drawCircle(Offset(w * 0.8, h * 0.6), h * 0.4, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.5, w * 0.7, h * 0.4),
        Radius.circular(h * 0.2),
      ),
      paint,
    );
  }
}

/// 📦 Physics Dropping Tense Block Component in Flame
class FlameTenseDropBlock extends PositionComponent {
  final String text;
  final Color blockColor;
  final double targetY;
  final VoidCallback? onLanded;

  double velocityY = 0.0;
  bool hasLanded = false;
  double squashX = 1.0;
  double squashY = 1.0;
  double landTime = 0.0;

  FlameTenseDropBlock({
    required Vector2 position,
    required Vector2 size,
    required this.text,
    required this.blockColor,
    required this.targetY,
    this.onLanded,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    if (!hasLanded) {
      velocityY += 1200.0 * dt; // gravity
      position.y += velocityY * dt;

      if (position.y >= targetY) {
        position.y = targetY;
        hasLanded = true;
        squashX = 1.25;
        squashY = 0.75;
        onLanded?.call();
      }
    } else {
      landTime += dt;
      squashX = 1.0 + math.sin(landTime * 16) * 0.25 * math.exp(-landTime * 5);
      squashY = 1.0 - math.sin(landTime * 16) * 0.25 * math.exp(-landTime * 5);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.scale(squashX, squashY);

    final w = size.x;
    final h = size.y;
    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(18));

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(rrect.shift(const Offset(0, 6)), shadowPaint);

    // Border
    final borderPaint = Paint()
      ..color = HSLColor.fromColor(blockColor)
          .withLightness((HSLColor.fromColor(blockColor).lightness - 0.2).clamp(0.0, 1.0))
          .toColor();
    canvas.drawRRect(rrect.inflate(2), borderPaint);

    // Body
    final bodyPaint = Paint()..color = blockColor;
    canvas.drawRRect(rrect, bodyPaint);

    // Gloss
    final glossPath = Path();
    glossPath.moveTo(-w / 2 + 8, -h / 2 + 5);
    glossPath.lineTo(w / 2 - 8, -h / 2 + 5);
    glossPath.quadraticBezierTo(0, -h / 2 + 18, -w / 2 + 8, -h / 2 + 5);
    glossPath.close();

    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawPath(glossPath, glossPaint);

    // Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }
}

/// 🐻 Mascot Bear Component for Tense Game
class FlameTenseMascotComponent extends PositionComponent {
  double animTime = 0.0;
  bool isCheering = false;
  double cheerTimer = 0.0;

  FlameTenseMascotComponent({required Vector2 position, required Vector2 size})
      : super(position: position, size: size, anchor: Anchor.bottomCenter);

  void cheer() {
    isCheering = true;
    cheerTimer = 1.2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    animTime += dt;
    if (cheerTimer > 0) {
      cheerTimer -= dt;
      if (cheerTimer <= 0) isCheering = false;
    }
  }

  @override
  void render(Canvas canvas) {
    final double bounce = isCheering ? -math.sin(animTime * 14).abs() * 12.0 : math.sin(animTime * 3) * 3.0;

    canvas.save();
    canvas.translate(0, bounce);

    final w = size.x;
    final h = size.y;
    final center = Offset(w / 2, h / 2 + 5);
    const double headRadius = 32.0;

    // Ears
    final earPaint = Paint()..color = const Color(0xFFB45309);
    final innerEarPaint = Paint()..color = const Color(0xFFFDE68A);
    canvas.drawCircle(Offset(center.dx - 24, center.dy - 26), 12, earPaint);
    canvas.drawCircle(Offset(center.dx - 24, center.dy - 26), 7, innerEarPaint);
    canvas.drawCircle(Offset(center.dx + 24, center.dy - 26), 12, earPaint);
    canvas.drawCircle(Offset(center.dx + 24, center.dy - 26), 7, innerEarPaint);

    // Head
    final headPaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawCircle(center, headRadius, headPaint);

    // Muzzle
    final snoutPaint = Paint()..color = const Color(0xFFFEF3C7);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 6), width: 32, height: 22),
      snoutPaint,
    );

    // Nose
    final nosePaint = Paint()..color = const Color(0xFF78350F);
    canvas.drawCircle(Offset(center.dx, center.dy + 3), 4, nosePaint);

    // Eyes
    final eyePaint = Paint()..color = const Color(0xFF1F2937);
    if (isCheering) {
      final squintPaint = Paint()
        ..color = const Color(0xFF1F2937)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx - 12, center.dy - 6), width: 10, height: 8),
        math.pi,
        math.pi,
        false,
        squintPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(center.dx + 12, center.dy - 6), width: 10, height: 8),
        math.pi,
        math.pi,
        false,
        squintPaint,
      );
    } else {
      canvas.drawCircle(Offset(center.dx - 12, center.dy - 6), 4.5, eyePaint);
      canvas.drawCircle(Offset(center.dx + 12, center.dy - 6), 4.5, eyePaint);
      canvas.drawCircle(Offset(center.dx - 13, center.dy - 8), 1.5, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(center.dx + 11, center.dy - 8), 1.5, Paint()..color = Colors.white);
    }

    // Blush
    final blushPaint = Paint()..color = const Color(0xFFF43F5E).withValues(alpha: 0.35);
    canvas.drawCircle(Offset(center.dx - 18, center.dy + 6), 5, blushPaint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 6), 5, blushPaint);

    canvas.restore();
  }
}

/// 🎮 Flame Game Engine managing the Tense Drop Arena
class TenseDropFlameGame extends FlameGame {
  late FlameTenseMascotComponent mascot;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Floating sky clouds
    add(FlameSkyCloud(position: Vector2(30, 20), size: Vector2(110, 60), speed: 12.0));
    add(FlameSkyCloud(position: Vector2(220, 50), size: Vector2(130, 70), speed: 18.0));

    // Animated Mascot at bottom
    mascot = FlameTenseMascotComponent(
      position: Vector2(70, size.y - 10),
      size: Vector2(80, 75),
    );
    add(mascot);
  }

  /// Drop a physical block from the sky into the target drop slot
  void dropBlock({
    required String text,
    required Color color,
    required double targetX,
    required double targetY,
    VoidCallback? onLanded,
  }) {
    // Clear past dropped blocks
    children.whereType<FlameTenseDropBlock>().forEach((b) => b.removeFromParent());

    final block = FlameTenseDropBlock(
      position: Vector2(targetX, -50),
      size: Vector2(150, 54),
      text: text,
      blockColor: color,
      targetY: targetY,
      onLanded: () {
        mascot.cheer();
        onLanded?.call();
      },
    );
    add(block);
  }

  void clearDroppedBlocks() {
    children.whereType<FlameTenseDropBlock>().forEach((b) => b.removeFromParent());
  }
}

// ============================================================================
// 📱 2. POCKET KIDS TENSE DROP GAME WIDGET (KUMI REFERENCE UI)
// ============================================================================

class PocketKidsTenseDropGame extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsTenseDropGame({
    super.key,
    required this.day,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required int day,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsTenseDropGame(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsTenseDropGame> createState() =>
      _PocketKidsTenseDropGameState();
}

class _PocketKidsTenseDropGameState extends State<PocketKidsTenseDropGame>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late final TenseDropFlameGame _flameGame;

  late List<VerbTimelineItem> _verbs;
  int _currentVerbIndex = 0;
  // 0 = Past, 1 = Present, 2 = Future
  int _currentTenseStage = 0;

  String? _selectedOption;
  bool _isChecked = false;
  bool _isAnswerCorrect = false;
  bool _showVictoryDialog = false;

  int _hearts = 4;
  int _score = 0;

  List<String> _shuffledOptions = [];

  @override
  void initState() {
    super.initState();
    _initAudio();

    _flameGame = TenseDropFlameGame();

    _verbs = Pocket90DayVerbTimelineData.getVerbsForDay(widget.day);
    if (_verbs.isEmpty) {
      _verbs = Pocket90DayVerbTimelineData.getVerbsForDay(1);
    }

    _setupCurrentStage();
  }

  Future<void> _initAudio() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.44);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _setupCurrentStage() {
    _selectedOption = null;
    _isChecked = false;
    _isAnswerCorrect = false;
    _flameGame.clearDroppedBlocks();

    final currentVerb = _verbs[_currentVerbIndex % _verbs.length];
    final String targetCorrect;
    final List<String> distractors = [];

    if (_currentTenseStage == 0) {
      targetCorrect = currentVerb.past;
      distractors.add(currentVerb.present);
      distractors.add(currentVerb.future);
      distractors.add('${currentVerb.baseVerb}ing');
    } else if (_currentTenseStage == 1) {
      targetCorrect = currentVerb.present;
      distractors.add(currentVerb.past);
      distractors.add(currentVerb.future);
      distractors.add('${currentVerb.baseVerb}ed');
    } else {
      targetCorrect = currentVerb.future;
      distractors.add(currentVerb.past);
      distractors.add(currentVerb.present);
      distractors.add('Can ${currentVerb.baseVerb.toLowerCase()}');
    }

    final all = <String>{targetCorrect, ...distractors}.toList()..shuffle();
    setState(() {
      _shuffledOptions = all;
    });

    _speak("${currentVerb.baseVerb}. Select the ${_getTenseName(_currentTenseStage)} tense.");
  }

  String _getTenseName(int stage) {
    switch (stage) {
      case 0:
        return 'PAST';
      case 1:
        return 'PRESENT';
      case 2:
      default:
        return 'FUTURE';
    }
  }

  String _getTenseNativeHint(int stage) {
    final lang = PocketLanguageService.currentLanguage;
    switch (stage) {
      case 0:
        if (lang == 'ml') return 'കഴിഞ്ഞ കാലം (Past)';
        if (lang == 'hi') return 'बीता हुआ कल (Past)';
        return 'Happened Before (Past)';
      case 1:
        if (lang == 'ml') return 'ഇപ്പോഴത്തെ കാലം (Present)';
        if (lang == 'hi') return 'वर्तमान काल (Present)';
        return 'Happening Now (Present)';
      case 2:
      default:
        if (lang == 'ml') return 'ഭാവി കാലം (Future)';
        if (lang == 'hi') return 'आने वाला कल (Future)';
        return 'Will Happen (Future)';
    }
  }

  void _onOptionSelected(String option) {
    if (_isChecked && _isAnswerCorrect) return;

    HapticFeedback.selectionClick();
    PocketGameSFX.instance.playTilePop();

    setState(() {
      _selectedOption = option;
      _isChecked = false;
    });

    // Drop block in Flame Canvas
    _flameGame.dropBlock(
      text: option,
      color: const Color(0xFF0284C7),
      targetX: MediaQuery.of(context).size.width / 2,
      targetY: 280,
    );

    _speak(option);
  }

  void _onCheckItPressed() {
    if (_selectedOption == null) return;

    final currentVerb = _verbs[_currentVerbIndex % _verbs.length];
    final String targetCorrect = _currentTenseStage == 0
        ? currentVerb.past
        : (_currentTenseStage == 1 ? currentVerb.present : currentVerb.future);

    if (_selectedOption!.trim().toLowerCase() == targetCorrect.trim().toLowerCase()) {
      HapticFeedback.heavyImpact();
      PocketGameSFX.playCorrectChime();

      setState(() {
        _isChecked = true;
        _isAnswerCorrect = true;
        _score += 10;
      });

      _speak("Awesome! $targetCorrect is correct!");

      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        if (_currentTenseStage < 2) {
          setState(() {
            _currentTenseStage++;
          });
          _setupCurrentStage();
        } else if (_currentVerbIndex + 1 < _verbs.length) {
          setState(() {
            _currentVerbIndex++;
            _currentTenseStage = 0;
          });
          _setupCurrentStage();
        } else {
          _finishGameAndAwardCard();
        }
      });
    } else {
      HapticFeedback.lightImpact();
      PocketGameSfx.instance.playErrorBuzz();

      setState(() {
        _isChecked = true;
        _isAnswerCorrect = false;
        if (_hearts > 1) _hearts--;
      });

      _speak("Oops! Try again for ${_getTenseName(_currentTenseStage)}!");
    }
  }

  Future<void> _finishGameAndAwardCard() async {
    setState(() {
      _showVictoryDialog = true;
    });

    PocketGameSFX.playVictoryFanfare();
    await PocketKidsService.addKidsScore(30);
    widget.onCompleted?.call();
    _speak("Hooray! Day ${widget.day} Tenses Mastered! Great job!");
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentVerb = _verbs[_currentVerbIndex % _verbs.length];
    final stageName = _getTenseName(_currentTenseStage);
    final stageHint = _getTenseNativeHint(_currentTenseStage);
    final nativeMeaning = currentVerb.getLocalizedMeaning();
    final card = PopArtCardHelper.getCardForDay(widget.day, isMale: true);

    return Scaffold(
      backgroundColor: const Color(0xFF99E6D8), // Soft mint green from Kumi reference
      body: Stack(
        children: [
          // 1. Lush Pastel Cartoon Scenery Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFBAE6FD), // Sky pastel blue
                    Color(0xFFA7F3D0), // Meadow mint green
                  ],
                ),
              ),
            ),
          ),

          // 2. 🎮 Interactive Flame Game Engine Canvas
          Positioned.fill(
            child: GameWidget(game: _flameGame),
          ),

          // 3. 🌟 Top Kumi Reference Header & Question UI
          SafeArea(
            child: Column(
              children: [
                _buildTopKumiHeader(),

                // Mascot Dialogue & Prompt Banner (Reference Image 1 Screen 2)
                _buildMascotPromptBanner(currentVerb, stageName, stageHint, nativeMeaning),

                const Spacer(),

                // Option Choice Chips & "Check it" Lime Green Button
                _buildOptionChipsAndCheckButton(),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // 4. 🏆 "You won!" Victory Modal (Reference Image 1 Screen 6)
          if (_showVictoryDialog) _buildKumiVictoryOverlay(card),
        ],
      ),
    );
  }

  // =========================================================================
  // 🌟 TOP HEADER (REFERENCE IMAGE 1 SCREEN 2)
  // =========================================================================
  Widget _buildTopKumiHeader() {
    final totalStages = _verbs.length * 3;
    final completedStages = (_currentVerbIndex * 3) + _currentTenseStage;
    final progress = completedStages / totalStages;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.close_rounded, color: Color(0xFF0284C7), size: 22),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.08, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Score Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '+$_score KS',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFD97706),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Text('❤️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$_hearts',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFEF4444),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 💬 MASCOT PROMPT BANNER (KUMI STYLE)
  // =========================================================================
  Widget _buildMascotPromptBanner(
    VerbTimelineItem currentVerb,
    String stageName,
    String stageHint,
    String nativeMeaning,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('🐻', style: TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          currentVerb.baseVerb,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _speak(currentVerb.baseVerb),
                          child: const Icon(
                            Icons.volume_up_rounded,
                            color: Color(0xFF0284C7),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      nativeMeaning,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                ),
                child: Text(
                  stageName,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0284C7),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Responsive Fill-in Prompt Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isChecked
                    ? (_isAnswerCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                    : const Color(0xFFCBD5E1),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: RichText(
              textAlign: TextAlign.center,
              softWrap: true,
              text: TextSpan(
                style: GoogleFonts.inter(
                  color: const Color(0xFF475569),
                  fontSize: 13.5,
                  height: 1.35,
                ),
                children: [
                  const TextSpan(text: 'What is the '),
                  TextSpan(
                    text: stageName,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0284C7),
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                    ),
                  ),
                  const TextSpan(text: ' tense?\n'),
                  TextSpan(
                    text: '($stageHint)',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🔘 OPTION CHIPS & "CHECK IT" BUTTON (REFERENCE IMAGE 1 SCREEN 2)
  // =========================================================================
  Widget _buildOptionChipsAndCheckButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 2x2 Option Choice Chips matching Image 1 pastel rounded chips
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _shuffledOptions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.6,
            ),
            itemBuilder: (context, idx) {
              final opt = _shuffledOptions[idx];
              final isSelected = _selectedOption == opt;

              return GestureDetector(
                onTap: () => _onOptionSelected(opt),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFBAE6FD) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    opt,
                    style: GoogleFonts.outfit(
                      color: isSelected ? const Color(0xFF0369A1) : const Color(0xFF1E293B),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // Lime Green Bouncy "Check it" Button matching Image 1
          GestureDetector(
            onTap: _selectedOption != null ? _onCheckItPressed : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _selectedOption != null
                      ? [const Color(0xFF84CC16), const Color(0xFF65A30D)] // Vibrant lime green
                      : [const Color(0xFFCBD5E1), const Color(0xFF94A3B8)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  if (_selectedOption != null)
                    BoxShadow(
                      color: const Color(0xFF65A30D).withValues(alpha: 0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'Check it',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🏆 "YOU WON!" VICTORY MODAL (REFERENCE IMAGE 1 SCREEN 6)
  // =========================================================================
  Widget _buildKumiVictoryOverlay(PopArtAvatarCardData card) {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3 Big Shiny Gold Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStarIcon(size: 42, color: const Color(0xFFFFB703)),
                const SizedBox(width: 8),
                _buildStarIcon(size: 60, color: const Color(0xFFFFB703), isCenter: true),
                const SizedBox(width: 8),
                _buildStarIcon(size: 42, color: const Color(0xFFFFB703)),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'You won!',
              style: GoogleFonts.outfit(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Day ${widget.day} Past, Present & Future Tenses! ⏳',
              style: GoogleFonts.inter(
                color: const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),

            // Tense Mastery Badge Pill
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: card.rarityColor, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 54,
                    decoration: BoxDecoration(
                      color: card.bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(card.badgeEmoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TENSE MASTER BADGE ⭐',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0284C7),
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          card.title,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRewardPill('🎖️', '+30 KS', const Color(0xFF38BDF8)),
                _buildRewardPill('🟡', '+50', const Color(0xFFFBBF24)),
                _buildRewardPill('❤️', '$_hearts', const Color(0xFFF43F5E)),
              ],
            ),
            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showVictoryDialog = false;
                        _currentVerbIndex = 0;
                        _currentTenseStage = 0;
                        _hearts = 4;
                        _score = 0;
                      });
                      _setupCurrentStage();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.refresh_rounded, color: Color(0xFF475569), size: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF84CC16), Color(0xFF65A30D)], // Lime Green Candy
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF65A30D).withValues(alpha: 0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'NEXT LEVEL',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarIcon({required double size, required Color color, bool isCenter = false}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (isCenter)
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Icon(Icons.star_rounded, size: size, color: color),
    );
  }

  Widget _buildRewardPill(String emoji, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            count,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
