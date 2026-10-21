import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import '../pocket_formula_blueprint_builder_card.dart';

/// 🌟 Flame Particle Sparkle for Formula Master
class FormulaSparkle extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  final double radius;
  double life = 1.0;
  final double decay;

  FormulaSparkle({
    required Vector2 position,
    required this.velocity,
    required this.color,
    required this.radius,
    this.decay = 1.5,
  }) : super(position: position);

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity.y += 120.0 * dt;
    life -= decay * dt;
    if (life <= 0) removeFromParent();
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

class FormulaFlameGame extends FlameGame {
  final math.Random _rng = math.Random();

  @override
  Color backgroundColor() => Colors.transparent;

  void burstCelebration(Vector2 pos, Color tileColor) {
    for (int i = 0; i < 22; i++) {
      final angle = _rng.nextDouble() * math.pi * 2;
      final speed = 80.0 + _rng.nextDouble() * 160.0;
      final p = FormulaSparkle(
        position: pos.clone(),
        velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed - 50),
        color: i % 2 == 0 ? tileColor : const Color(0xFFFFD700),
        radius: 2.5 + _rng.nextDouble() * 3.5,
        decay: 1.2 + _rng.nextDouble() * 0.8,
      );
      add(p);
    }
  }
}

/// 📐 Full-Screen Interactive Formula Master Game Page
///
/// Designed per User Audio Directives:
/// - Pinned Formula Header at top displaying the exact grammatical rule.
/// - Scrambled Word Bank at bottom.
/// - Incorrect tap causes realistic horizontal wobble / vibration + error buzz without placing.
/// - Correct tap snaps into the formula slot with celebratory sound, TTS pronunciation, and Flame particle bursts!
/// - Full-screen gamified experience, completing formula rules step by step!
class PocketFormulaMasterGamePage extends StatefulWidget {
  final String title;
  final List<FormulaRuleItem> rules;
  final int day;

  const PocketFormulaMasterGamePage({
    super.key,
    required this.title,
    required this.rules,
    this.day = 1,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required List<FormulaRuleItem> rules,
    int day = 1,
  }) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PocketFormulaMasterGamePage(
          title: title,
          rules: rules,
          day: day,
        ),
      ),
    );
  }

  @override
  State<PocketFormulaMasterGamePage> createState() =>
      _PocketFormulaMasterGamePageState();
}

class _PocketFormulaMasterGamePageState
    extends State<PocketFormulaMasterGamePage>
    with SingleTickerProviderStateMixin {
  late final FormulaFlameGame _flameGame;
  final FlutterTts _flutterTts = FlutterTts();

  int _currentRuleIdx = 0;
  List<String> _expectedTokens = [];
  List<String> _availableTokens = [];
  final List<String> _placedTokens = [];

  bool _isRuleCompleted = false;

  late AnimationController _shakeAnimController;
  String? _shakingToken;

  @override
  void initState() {
    super.initState();
    _flameGame = FormulaFlameGame();
    _initTts();

    _shakeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _loadRule(_currentRuleIdx);
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

  void _loadRule(int index) {
    if (index >= widget.rules.length) {
      _showAllDoneDialog();
      return;
    }

    final rule = widget.rules[index];
    final rawTokens = rule.targetSentence
        .trim()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    final scrambled = List<String>.from(rawTokens);
    final rng = math.Random();
    if (scrambled.length > 1) {
      for (int i = 0; i < 5; i++) {
        scrambled.shuffle(rng);
        if (scrambled.join(' ') != rawTokens.join(' ')) break;
      }
    }

    setState(() {
      _currentRuleIdx = index;
      _expectedTokens = List.from(rawTokens);
      _placedTokens.clear();
      _availableTokens = scrambled;
      _isRuleCompleted = false;
      _shakingToken = null;
    });
  }

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  void _onWordTapped(String word) {
    if (_isRuleCompleted) return;

    final nextExpectedIndex = _placedTokens.length;
    if (nextExpectedIndex >= _expectedTokens.length) return;

    final expectedWord = _expectedTokens[nextExpectedIndex];

    if (word == expectedWord) {
      // ✅ Correct word in formula sequence!
      PocketGameSfx.instance.playSnapCorrect();
      _speak(word);

      setState(() {
        _availableTokens.remove(word);
        _placedTokens.add(word);
      });

      final size = MediaQuery.of(context).size;
      _flameGame.burstCelebration(
        Vector2(size.width / 2, size.height * 0.35),
        const Color(0xFF00E676),
      );

      // Check if sentence complete
      if (_placedTokens.length == _expectedTokens.length) {
        _onSentenceCompleted();
      }
    } else {
      // ❌ Incorrect Word in Formula sequence!
      // Shake with vibration and error buzz!
      PocketGameSfx.instance.playErrorBuzz();
      setState(() => _shakingToken = word);
      _shakeAnimController.forward(from: 0.0).then((_) {
        if (mounted) setState(() => _shakingToken = null);
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Follow the formula sequence: $expectedWord comes next!',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  void _onPlacedWordTapped(String word) {
    if (_isRuleCompleted) return;
    PocketGameSfx.instance.playTilePop();
    setState(() {
      _placedTokens.remove(word);
      _availableTokens.add(word);
    });
  }

  void _onSentenceCompleted() {
    setState(() => _isRuleCompleted = true);
    PocketGameSfx.instance.playVictory();

    final rule = widget.rules[_currentRuleIdx];
    _speak(rule.targetSentence);

    final size = MediaQuery.of(context).size;
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (!mounted) return;
        _flameGame.burstCelebration(
          Vector2(size.width * (0.3 + i * 0.2), size.height * 0.32),
          const Color(0xFF00E5FF),
        );
      });
    }
  }

  void _proceedNextRule() {
    PocketGameSfx.instance.playClick();
    if (_currentRuleIdx + 1 < widget.rules.length) {
      _loadRule(_currentRuleIdx + 1);
    } else {
      _showAllDoneDialog();
    }
  }

  void _showAllDoneDialog() {
    PocketGameSfx.instance.playVictory();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF130924),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 2),
        ),
        title: Row(
          children: [
            const Text('📐', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Formula Mastered!',
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
              '🎉 You mastered ${widget.title} with 100% syntactic precision!',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '+30 Mastery XP • Professional Formula Complete!',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF00E5FF),
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
              'Back to Conversation ➔',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentRuleIdx >= widget.rules.length) {
      return const Scaffold(backgroundColor: Color(0xFF0A0517));
    }

    final rule = widget.rules[_currentRuleIdx];
    final progress = (_currentRuleIdx + 1) / widget.rules.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0517),
      body: Stack(
        children: [
          Positioned.fill(child: GameWidget(game: _flameGame)),

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
                        _buildFormulaHeaderCard(rule),
                        const SizedBox(height: 16),
                        _buildFormulaSlotsRunway(rule),
                        const SizedBox(height: 20),
                        if (!_isRuleCompleted) _buildWordBank(),
                        if (_isRuleCompleted) _buildSuccessBanner(rule),
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
                  'DAY ${widget.day} • FORMULA MASTER ARENA',
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
              '${_currentRuleIdx + 1}/${widget.rules.length}',
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

  Widget _buildFormulaHeaderCard(FormulaRuleItem rule) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1035).withValues(alpha: 0.9),
            const Color(0xFF0D1B2A).withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4), width: 1.5),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00E5FF), width: 1.2),
                ),
                child: Text(
                  rule.formulaHeader.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00E5FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rule.subjectRule,
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            rule.nativeMeaning,
            style: GoogleFonts.notoSansMalayalam(
              color: Colors.white70,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaSlotsRunway(FormulaRuleItem rule) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧩', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'ASSEMBLE IN FORMULA ORDER:',
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Runway of Slots
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_expectedTokens.length, (slotIdx) {
              final isFilled = slotIdx < _placedTokens.length;

              if (isFilled) {
                final token = _placedTokens[slotIdx];
                return InkWell(
                  onTap: () => _onPlacedWordTapped(token),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF047857), Color(0xFF065F46)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF34D399), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF34D399).withValues(alpha: 0.3),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          token!,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.close, size: 14, color: Colors.white70),
                      ],
                    ),
                  ),
                );
              } else {
                return Container(
                  width: 58,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: slotIdx == _placedTokens.length
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.6)
                          : Colors.white24,
                      width: slotIdx == _placedTokens.length ? 1.5 : 1.0,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${slotIdx + 1}',
                      style: GoogleFonts.outfit(
                        color: slotIdx == _placedTokens.length
                            ? const Color(0xFF00E5FF)
                            : Colors.white24,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWordBank() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF160B29),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔤', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'WORD BANK (Tap next formula word)',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _availableTokens.map((word) {
              final isShaking = _shakingToken == word;

              return AnimatedBuilder(
                animation: _shakeAnimController,
                builder: (ctx, child) {
                  double dx = 0.0;
                  if (isShaking) {
                    dx = math.sin(_shakeAnimController.value * math.pi * 6) * 8.0;
                  }
                  return Transform.translate(
                    offset: Offset(dx, 0),
                    child: child,
                  );
                },
                child: InkWell(
                  onTap: () => _onWordTapped(word),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E1253), Color(0xFF1D0B36)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isShaking
                            ? const Color(0xFFE11D48)
                            : const Color(0xFF00E5FF).withValues(alpha: 0.5),
                        width: isShaking ? 2.0 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Text(
                      word,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
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

  Widget _buildSuccessBanner(FormulaRuleItem rule) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF064E3B).withValues(alpha: 0.95),
            const Color(0xFF0F172A).withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF00E676), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF00E676), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rule.targetSentence,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Color(0xFF00E676)),
                onPressed: () => _speak(rule.targetSentence),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _proceedNextRule,
            child: Text(
              _currentRuleIdx + 1 < widget.rules.length
                  ? 'Next Formula Rule ➔'
                  : 'Complete Formula Mastery 🏆',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
