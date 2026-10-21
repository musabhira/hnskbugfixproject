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
import '../pocket_fortress_defense_service.dart';
import '../curriculum_data/pocket_90day_prepositions_visual_data.dart';

/// 🌟 Flame Particle Sparkle for Spatial Preposition discoveries
class PrepParticleSparkle extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  final double radius;
  double life = 1.0;
  final double decay;

  PrepParticleSparkle({
    required Vector2 position,
    required this.velocity,
    required this.color,
    required this.radius,
    this.decay = 1.6,
  }) : super(position: position);

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity.y += 140.0 * dt;
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

class PrepositionsFlameGame extends FlameGame {
  final math.Random _rng = math.Random();

  @override
  Color backgroundColor() => Colors.transparent;

  void burstSplash(Vector2 pos, Color color) {
    for (int i = 0; i < 24; i++) {
      final angle = _rng.nextDouble() * math.pi * 2;
      final speed = 70.0 + _rng.nextDouble() * 150.0;
      final p = PrepParticleSparkle(
        position: pos.clone(),
        velocity: Vector2(math.cos(angle) * speed, math.sin(angle) * speed - 40),
        color: i % 2 == 0 ? color : const Color(0xFF00E5FF),
        radius: 2.5 + _rng.nextDouble() * 3.0,
        decay: 1.2 + _rng.nextDouble() * 0.7,
      );
      add(p);
    }
  }
}

/// 🥛 Prepositions Visual Lab Page — 2D Interactive Glass & Object Physics
class PocketPrepositionsVisualGamePage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketPrepositionsVisualGamePage({
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
        builder: (_) => PocketPrepositionsVisualGamePage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketPrepositionsVisualGamePage> createState() =>
      _PocketPrepositionsVisualGamePageState();
}

class _PocketPrepositionsVisualGamePageState
    extends State<PocketPrepositionsVisualGamePage>
    with SingleTickerProviderStateMixin {
  late final PrepositionsFlameGame _flameGame;
  final FlutterTts _flutterTts = FlutterTts();

  late final PrepositionDayData _dayData;
  int _currentChallengeIdx = 0;

  // Active object position on canvas: 'inside', 'top', 'under', 'between', 'behind', 'beside', 'default'
  String _activePosition = 'default';
  bool _isChallengeResolved = false;

  late AnimationController _springController;

  @override
  void initState() {
    super.initState();
    _flameGame = PrepositionsFlameGame();
    _initTts();

    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _dayData = Pocket90DayPrepositionsVisualData.getDataForDay(widget.day);
    _loadChallenge();
  }

  @override
  void dispose() {
    _springController.dispose();
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

  void _loadChallenge() {
    if (_currentChallengeIdx >= _dayData.challenges.length) {
      _showAllDoneDialog();
      return;
    }

    setState(() {
      _activePosition = 'default';
      _isChallengeResolved = false;
    });

    _springController.forward(from: 0.0);
  }

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  void _onSelectPosition(String positionKey) {
    if (_isChallengeResolved) return;

    final challenge = _dayData.challenges[_currentChallengeIdx];
    setState(() {
      _activePosition = positionKey;
    });

    _springController.forward(from: 0.0);

    final size = MediaQuery.of(context).size;
    final posVector = Vector2(size.width / 2, size.height * 0.38);

    if (positionKey == challenge.correctPosition) {
      // ✅ Correct Spatial Preposition!
      PocketGameSfx.instance.playSnapCorrect();
      _flameGame.burstSplash(posVector, const Color(0xFF00E676));
      _speak(challenge.sentence);

      setState(() {
        _isChallengeResolved = true;
      });
    } else {
      // ❌ Incorrect Position
      PocketGameSfx.instance.playErrorBuzz();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Not quite! Try placing the ${_dayData.objectName.toLowerCase()} ${challenge.targetPrep}!',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFE11D48),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
        ),
      );
    }
  }

  void _nextChallenge() {
    PocketGameSfx.instance.playClick();
    if (_currentChallengeIdx + 1 < _dayData.challenges.length) {
      setState(() => _currentChallengeIdx++);
      _loadChallenge();
    } else {
      _showAllDoneDialog();
    }
  }

  Future<void> _showAllDoneDialog() async {
    final uid = widget.userId ?? Supabase.instance.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pocket_day_${uid ?? "guest"}_${widget.day}_prep_visual_done', true);
    await PocketFortressDefenseService.recordTrainingPoints(30, uid);

    widget.onStepFinished?.call(10);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A2239),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 2),
        ),
        title: Row(
          children: [
            const Text('🥛', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Day ${widget.day} Preposition Lab!',
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
              '🎉 You mastered In, On, Under, Between & spatial prepositions visually with 2D physics!',
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
                      '+30 Fluency XP • Prepositions Mastered!',
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
    if (_currentChallengeIdx >= _dayData.challenges.length) {
      return const Scaffold(backgroundColor: Color(0xFF071426));
    }

    final challenge = _dayData.challenges[_currentChallengeIdx];
    final progress = (_currentChallengeIdx + 1) / _dayData.challenges.length;

    return Scaffold(
      backgroundColor: const Color(0xFF071426),
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
                      children: [
                        const SizedBox(height: 8),
                        _buildPromptCard(challenge),
                        const SizedBox(height: 16),
                        _buildGlassCanvas(challenge),
                        const SizedBox(height: 16),
                        _buildInteractivePositionControls(challenge),
                        const SizedBox(height: 20),
                        if (_isChallengeResolved) _buildSuccessBanner(challenge),
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
                  'DAY ${widget.day} • PREPOSITIONS 2D SPATIAL LAB',
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
              '${_currentChallengeIdx + 1}/${_dayData.challenges.length}',
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

  Widget _buildPromptCard(PrepositionChallenge challenge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D3B66).withValues(alpha: 0.85),
            const Color(0xFF08203E).withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🎯 TARGET PREPOSITION: ',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  challenge.targetPrep,
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.prompt,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            challenge.sentenceMl,
            style: GoogleFonts.notoSansMalayalam(
              color: const Color(0xFF80DEEA),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCanvas(PrepositionChallenge challenge) {
    final isBetween = _activePosition == 'between' || challenge.correctPosition == 'between';

    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            const Color(0xFF1E3A8A).withValues(alpha: 0.25),
            Colors.black.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Table Surface Line
          Positioned(
            bottom: 35,
            left: 20,
            right: 20,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Glass Visuals
          if (!isBetween) ...[
            Positioned(
              bottom: 35,
              child: _buildSingleGlass(isInverted: _activePosition == 'on'),
            ),
          ] else ...[
            // Two Glasses for "BETWEEN"
            Positioned(
              bottom: 35,
              left: 50,
              child: _buildSingleGlass(isInverted: false),
            ),
            Positioned(
              bottom: 35,
              right: 50,
              child: _buildSingleGlass(isInverted: false),
            ),
          ],

          // Animated Object (Ball / Lemon / Coin / Diamond)
          _buildAnimatedObject(challenge, isBetween),
        ],
      ),
    );
  }

  Widget _buildSingleGlass({required bool isInverted}) {
    return Transform.rotate(
      angle: isInverted ? math.pi : 0.0,
      child: Container(
        width: 100,
        height: 130,
        decoration: BoxDecoration(
          border: Border(
            left: const BorderSide(color: Color(0xFF80DEEA), width: 3),
            right: const BorderSide(color: Color(0xFF80DEEA), width: 3),
            bottom: const BorderSide(color: Color(0xFF80DEEA), width: 5),
          ),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF80DEEA).withValues(alpha: 0.15),
              const Color(0xFF00E5FF).withValues(alpha: 0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Text(
            '🥛',
            style: TextStyle(
              fontSize: 34,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedObject(PrepositionChallenge challenge, bool isBetween) {
    // Determine offset for object relative to center
    double dy = 0.0;
    double dx = 0.0;

    switch (_activePosition) {
      case 'inside':
        dy = 20.0;
        dx = 0.0;
        break;
      case 'top':
        dy = -75.0;
        dx = 0.0;
        break;
      case 'under':
        dy = 40.0;
        dx = 0.0;
        break;
      case 'between':
        dy = 25.0;
        dx = 0.0;
        break;
      case 'behind':
        dy = 15.0;
        dx = 0.0;
        break;
      case 'beside':
        dy = 30.0;
        dx = 80.0;
        break;
      default:
        dy = -90.0;
        dx = -100.0;
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      bottom: (125.0 - dy).clamp(10.0, 220.0),
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9100).withValues(alpha: 0.6),
                blurRadius: 14,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Center(
            child: Text('⚽', style: TextStyle(fontSize: 22)),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractivePositionControls(PrepositionChallenge challenge) {
    final positions = [
      {'key': 'inside', 'label': 'IN (ഉള്ളിൽ)', 'icon': '📥'},
      {'key': 'top', 'label': 'ON (മുകളിൽ)', 'icon': '🔝'},
      {'key': 'under', 'label': 'UNDER (അടിയിൽ)', 'icon': '👇'},
      {'key': 'between', 'label': 'BETWEEN (നടുവിൽ)', 'icon': '↔️'},
      {'key': 'behind', 'label': 'BEHIND (പിന്നിൽ)', 'icon': '🙈'},
      {'key': 'beside', 'label': 'BESIDE (അടുത്ത്)', 'icon': '👉'},
    ];

    return Column(
      children: [
        Text(
          'Choose the correct spatial position:',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: positions.map((p) {
            final key = p['key']!;
            final isSelected = _activePosition == key;
            final isTarget = challenge.correctPosition == key;

            Color btnColor = const Color(0xFF1E293B);
            if (isSelected) {
              btnColor = isTarget ? const Color(0xFF00E676) : const Color(0xFFE11D48);
            }

            return InkWell(
              onTap: () => _onSelectPosition(key),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: btnColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF00E5FF).withValues(alpha: 0.4),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: btnColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p['icon']!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      p['label']!,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuccessBanner(PrepositionChallenge challenge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF064E3B).withValues(alpha: 0.9),
            const Color(0xFF065F46).withValues(alpha: 0.95),
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
                  challenge.sentence,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Color(0xFF00E676)),
                onPressed: () => _speak(challenge.sentence),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            challenge.tip,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _nextChallenge,
            child: Text(
              _currentChallengeIdx + 1 < _dayData.challenges.length
                  ? 'Next Preposition ➔'
                  : 'Complete Preposition Lab 🏆',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
