import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🌟 Particle effect for chest discovery & correct answers
class MeadowParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final Color color;
  final double size;

  MeadowParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.color,
    required this.size,
  });
}

/// 🌳 2D Open-World Meadow Explorer & Word Hunt Game
///
/// Fully responsive 2D exploration game based in an open meadow world.
/// Features 4 interactive discovery chests on an open meadow canvas,
/// hero explorer character, TTS audio, particle celebrations,
/// and smooth non-blocking touch interaction that allows parent scrolling.
class MeadowRunnerGamePage extends StatefulWidget {
  final List<Map<String, dynamic>> rounds;
  final int initialRound;
  final String nativeLanguage;
  final ValueChanged<int>? onRoundCompleted;
  final VoidCallback? onAllCompleted;
  final bool isFullscreen;

  const MeadowRunnerGamePage({
    super.key,
    required this.rounds,
    this.initialRound = 0,
    this.nativeLanguage = 'Malayalam',
    this.onRoundCompleted,
    this.onAllCompleted,
    this.isFullscreen = false,
  });

  @override
  State<MeadowRunnerGamePage> createState() => _MeadowRunnerGamePageState();
}

class _MeadowRunnerGamePageState extends State<MeadowRunnerGamePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final FlutterTts _tts = FlutterTts();
  final math.Random _random = math.Random();

  late int _currentRound;
  int _score = 0;
  int _streak = 0;
  bool _isMuted = false;

  // Selected chest index
  int? _selectedChestIndex;
  bool _isSuccessAnim = false;
  String? _lastAnswerFeedback;

  // Hero position on the meadow (0.0 to 1.0 relative coordinates)
  double _heroTargetX = 0.50;
  double _heroTargetY = 0.72;
  double _heroX = 0.50;
  double _heroY = 0.72;

  final List<MeadowParticle> _particles = [];
  double _cloudOffset = 0.0;
  double _butterflyAnim = 0.0;

  // 4 chest anchor positions on the 2D meadow (x, y relative to canvas)
  static const List<Offset> _chestPositions = [
    Offset(0.18, 0.44), // North-West grove
    Offset(0.82, 0.44), // North-East grove
    Offset(0.24, 0.76), // South-West path
    Offset(0.76, 0.76), // South-East path
  ];

  @override
  void initState() {
    super.initState();
    _currentRound = widget.initialRound.clamp(0, math.max(0, widget.rounds.length - 1));
    _initTts();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 32),
    )..addListener(_gameLoop);
    _animController.repeat();

    _speakCurrentPrompt();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
    } catch (_) {}
  }

  void _speak(String text) async {
    if (_isMuted) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _speakCurrentPrompt() {
    if (widget.rounds.isEmpty) return;
    final rData = widget.rounds[_currentRound % widget.rounds.length];
    final target = rData['target']?.toString() ?? '';
    final prompt = _getPromptText(rData);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _speak(target.isNotEmpty ? 'Find $target' : prompt);
    });
  }

  String _getPromptText(Map<String, dynamic> rData) {
    final promptRaw = rData['prompt'];
    if (promptRaw is Map) {
      return promptRaw[widget.nativeLanguage]?.toString() ??
          promptRaw['en']?.toString() ??
          promptRaw['ml']?.toString() ??
          promptRaw['Malayalam']?.toString() ??
          '';
    }
    return promptRaw?.toString() ?? '';
  }

  @override
  void dispose() {
    _animController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _gameLoop() {
    if (!mounted) return;
    setState(() {
      _cloudOffset += 0.25;
      _butterflyAnim += 0.08;

      // Smooth hero interpolation to target
      _heroX += (_heroTargetX - _heroX) * 0.14;
      _heroY += (_heroTargetY - _heroY) * 0.14;

      // Update particles
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.25; // gravity
        p.life -= 0.035;
        if (p.life <= 0) {
          _particles.removeAt(i);
        }
      }
    });
  }

  void _spawnSparkles(double x, double y) {
    for (int i = 0; i < 28; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 2.0 + _random.nextDouble() * 5.0;
      final colors = [
        const Color(0xFFFFD700),
        const Color(0xFFFACC15),
        const Color(0xFF10B981),
        const Color(0xFF38BDF8),
        const Color(0xFFEC4899),
        Colors.white,
      ];
      _particles.add(
        MeadowParticle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 3.0,
          life: 1.0,
          color: colors[_random.nextInt(colors.length)],
          size: 4.0 + _random.nextDouble() * 6.0,
        ),
      );
    }
  }

  void _onOptionChosen(int index, String option, String correct, Size canvasSize) {
    if (_isSuccessAnim) return;

    final isCorrect = option.trim().toUpperCase() == correct.trim().toUpperCase();

    // Move hero towards the chosen chest
    final chestOffset = _chestPositions[index % _chestPositions.length];
    setState(() {
      _selectedChestIndex = index;
      _heroTargetX = chestOffset.dx;
      _heroTargetY = (chestOffset.dy + 0.08).clamp(0.2, 0.9);
    });

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      _score += 100 + (_streak * 25);
      _streak++;

      final pX = chestOffset.dx * canvasSize.width;
      final pY = chestOffset.dy * canvasSize.height;
      _spawnSparkles(pX, pY);

      setState(() {
        _isSuccessAnim = true;
        _lastAnswerFeedback = 'Correct! $option';
      });

      _speak('Awesome! Correct: $option');
      widget.onRoundCompleted?.call(_currentRound);

      if (_currentRound < widget.rounds.length - 1) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) {
            setState(() {
              _currentRound++;
              _selectedChestIndex = null;
              _isSuccessAnim = false;
              _lastAnswerFeedback = null;
              // Reset hero towards center path
              _heroTargetX = 0.50;
              _heroTargetY = 0.72;
            });
            _speakCurrentPrompt();
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 950), () {
          if (mounted) {
            widget.onAllCompleted?.call();
            _showVictoryDialog();
          }
        });
      }
    } else {
      HapticFeedback.vibrate();
      _streak = 0;
      setState(() {
        _lastAnswerFeedback = 'Try another chest!';
      });
      _speak('Try another chest!');
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) {
          setState(() {
            _selectedChestIndex = null;
            _lastAnswerFeedback = null;
          });
        }
      });
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 10),
              Text(
                'MEADOW EXPLORER COMPLETE!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You found all 6 target items in the Open World Meadow!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'TOTAL XP: $_score',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (widget.isFullscreen) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(
                    'CLAIM REWARD ➔',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rounds.isEmpty) {
      return const SizedBox.shrink();
    }

    final rData = widget.rounds[_currentRound % widget.rounds.length];
    final promptText = _getPromptText(rData);
    final targetWord = rData['target']?.toString() ?? '';
    final options = (rData['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final correct = rData['correct']?.toString() ?? '';

    final content = Column(
      children: [
        // 1. Top HUD Banner
        _buildHud(promptText, targetWord, widget.rounds.length),
        const SizedBox(height: 8),

        // 2. 2D Open-World Meadow Explorer Canvas
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // A. Scenic Open Meadow Landscape
                    CustomPaint(
                      size: canvasSize,
                      painter: _OpenMeadowPainter(
                        cloudOffset: _cloudOffset,
                        butterflyAnim: _butterflyAnim,
                      ),
                    ),

                    // B. Interactive Discovery Chests on the Meadow
                    for (int i = 0; i < options.length && i < _chestPositions.length; i++)
                      _buildChestItem(
                        index: i,
                        option: options[i],
                        correct: correct,
                        canvasSize: canvasSize,
                      ),

                    // C. Walking Adventurer Avatar
                    _buildExplorerAvatar(canvasSize),

                    // D. Particle Celebration FX
                    IgnorePointer(
                      child: CustomPaint(
                        painter: _MeadowParticlePainter(particles: _particles),
                      ),
                    ),

                    // E. Floating Feedback Bubble
                    if (_lastAnswerFeedback != null)
                      Positioned(
                        top: 14,
                        left: 20,
                        right: 20,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                            decoration: BoxDecoration(
                              color: _isSuccessAnim ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              _lastAnswerFeedback!,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // 3. Quick-Tap Choice Dock (Allows instant tapping with zero friction)
        _buildQuickTapDock(options, correct),
      ],
    );

    if (widget.isFullscreen) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: content,
          ),
        ),
      );
    }

    return content;
  }

  Widget _buildHud(String prompt, String target, int totalRounds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF047857), Color(0xFF065F46)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6EE7B7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Round Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_currentRound + 1} / $totalRounds',
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Quest Target Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('🧭 ', style: TextStyle(fontSize: 12)),
                    Flexible(
                      child: Text(
                        target.isNotEmpty ? 'QUEST: FIND "$target"' : 'OPEN WORLD QUEST',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  prompt,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Audio Speaker Button
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () {
              final rData = widget.rounds[_currentRound % widget.rounds.length];
              final targetW = rData['target']?.toString() ?? '';
              _speak(targetW.isNotEmpty ? targetW : _getPromptText(rData));
            },
          ),

          // Score Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_score XP',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChestItem({
    required int index,
    required String option,
    required String correct,
    required Size canvasSize,
  }) {
    final pos = _chestPositions[index % _chestPositions.length];
    final left = (pos.dx * canvasSize.width) - 45.0;
    final top = (pos.dy * canvasSize.height) - 45.0;

    final isSelected = _selectedChestIndex == index;
    final isCorrectOption = option.trim().toUpperCase() == correct.trim().toUpperCase();

    Color borderColor = const Color(0xFFFFD700);
    Color bgColor = const Color(0xFF1E293B);
    if (isSelected) {
      if (isCorrectOption) {
        borderColor = const Color(0xFF10B981);
        bgColor = const Color(0xFF065F46);
      } else {
        borderColor = const Color(0xFFEF4444);
        bgColor = const Color(0xFF7F1D1D);
      }
    }

    return Positioned(
      left: left.clamp(4.0, math.max(4.0, canvasSize.width - 94.0)),
      top: top.clamp(4.0, math.max(4.0, canvasSize.height - 94.0)),
      child: GestureDetector(
        onTap: () => _onOptionChosen(index, option, correct, canvasSize),
        child: AnimatedScale(
          scale: isSelected ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Letter / Word Label Plaque
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  option,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              // Chest Graphic
              Container(
                width: 48,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected && isCorrectOption
                        ? [const Color(0xFFFFD700), const Color(0xFFF59E0B)]
                        : [const Color(0xFFB45309), const Color(0xFF78350F)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isSelected && isCorrectOption ? '✨' : '📦',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplorerAvatar(Size canvasSize) {
    final x = (_heroX * canvasSize.width) - 20.0;
    final y = (_heroY * canvasSize.height) - 20.0;

    return Positioned(
      left: x.clamp(0.0, math.max(0.0, canvasSize.width - 44.0)),
      top: y.clamp(0.0, math.max(0.0, canvasSize.height - 44.0)),
      child: IgnorePointer(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0F172A),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Center(
            child: Text('🤠', style: TextStyle(fontSize: 22)),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTapDock(List<String> options, String correct) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TAP CHEST OR CHOOSE OPTION:',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (_streak > 1)
                Text(
                  '🔥 ${_streak}X STREAK',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: List.generate(options.length, (idx) {
                  final opt = options[idx];
                  final isSelected = _selectedChestIndex == idx;
                  final isCorrect = opt.trim().toUpperCase() == correct.trim().toUpperCase();

                  Color btnBg = const Color(0xFF1E293B);
                  Color btnBorder = const Color(0xFF334155);
                  if (isSelected) {
                    btnBg = isCorrect ? const Color(0xFF065F46) : const Color(0xFF7F1D1D);
                    btnBorder = isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                  }

                  return SizedBox(
                    width: (constraints.maxWidth - 24) / 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnBg,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        elevation: 2,
                        side: BorderSide(color: btnBorder, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final canvasW = MediaQuery.of(context).size.width;
                        _onOptionChosen(idx, opt, correct, Size(canvasW, 300));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📦 ', style: TextStyle(fontSize: 13)),
                          Flexible(
                            child: Text(
                              opt,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 🎨 Natural Meadow Painter: Rolling hills, stone path, trees, flowers, sun & sky
class _OpenMeadowPainter extends CustomPainter {
  final double cloudOffset;
  final double butterflyAnim;

  _OpenMeadowPainter({
    required this.cloudOffset,
    required this.butterflyAnim,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Sky Gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFF7DD3FC), Color(0xFFBAE6FD)],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.45));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.45), skyPaint);

    // 2. Distant Sun
    final sunPaint = Paint()..color = const Color(0xFFFEF08A);
    canvas.drawCircle(Offset(w * 0.82, h * 0.16), 26, sunPaint);
    final sunGlow = Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.35);
    canvas.drawCircle(Offset(w * 0.82, h * 0.16), 40, sunGlow);

    // 3. Clouds
    _drawCloud(canvas, (w * 0.15 + cloudOffset) % (w + 100) - 50, h * 0.12, 34);
    _drawCloud(canvas, (w * 0.60 + cloudOffset * 0.6) % (w + 100) - 50, h * 0.18, 28);

    // 4. Distant Mountains / Rolling Hills
    final hillBack = Paint()..color = const Color(0xFF047857);
    final pathBack = Path()
      ..moveTo(0, h * 0.38)
      ..quadraticBezierTo(w * 0.35, h * 0.30, w * 0.65, h * 0.36)
      ..quadraticBezierTo(w * 0.85, h * 0.33, w, h * 0.40)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(pathBack, hillBack);

    // 5. Lush Meadow Foreground
    final meadowPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
      ).createShader(Rect.fromLTWH(0, h * 0.35, w, h * 0.65));

    final meadowPath = Path()
      ..moveTo(0, h * 0.44)
      ..quadraticBezierTo(w * 0.28, h * 0.40, w * 0.55, h * 0.46)
      ..quadraticBezierTo(w * 0.80, h * 0.42, w, h * 0.48)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(meadowPath, meadowPaint);

    // 6. Cobblestone Path winding from bottom to center
    final stonePath = Path()
      ..moveTo(w * 0.44, h)
      ..quadraticBezierTo(w * 0.47, h * 0.70, w * 0.50, h * 0.52)
      ..lineTo(w * 0.54, h * 0.52)
      ..quadraticBezierTo(w * 0.53, h * 0.70, w * 0.56, h)
      ..close();
    final pathPaint = Paint()..color = const Color(0xFFE2E8F0).withValues(alpha: 0.35);
    canvas.drawPath(stonePath, pathPaint);

    // 7. Decorative Meadow Trees & Flowers
    _drawTree(canvas, w * 0.08, h * 0.38, 22);
    _drawTree(canvas, w * 0.92, h * 0.38, 24);
    _drawTree(canvas, w * 0.50, h * 0.40, 16);

    _drawFlower(canvas, w * 0.36, h * 0.65, const Color(0xFFF43F5E));
    _drawFlower(canvas, w * 0.64, h * 0.66, const Color(0xFFFBBF24));
    _drawFlower(canvas, w * 0.12, h * 0.84, const Color(0xFFA855F7));
    _drawFlower(canvas, w * 0.88, h * 0.82, const Color(0xFF38BDF8));
  }

  void _drawCloud(Canvas canvas, double cx, double cy, double radius) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(Offset(cx, cy), radius, paint);
    canvas.drawCircle(Offset(cx + radius * 0.65, cy - radius * 0.2), radius * 0.75, paint);
    canvas.drawCircle(Offset(cx - radius * 0.65, cy + radius * 0.1), radius * 0.6, paint);
  }

  void _drawTree(Canvas canvas, double tx, double ty, double radius) {
    final trunk = Paint()..color = const Color(0xFF78350F);
    canvas.drawRect(Rect.fromLTWH(tx - 3, ty + radius * 0.5, 6, radius * 0.8), trunk);

    final foliage = Paint()..color = const Color(0xFF065F46);
    canvas.drawCircle(Offset(tx, ty), radius, foliage);
    final highlight = Paint()..color = const Color(0xFF10B981);
    canvas.drawCircle(Offset(tx - 3, ty - 3), radius * 0.65, highlight);
  }

  void _drawFlower(Canvas canvas, double fx, double fy, Color color) {
    final p = Paint()..color = color;
    canvas.drawCircle(Offset(fx, fy), 4, p);
    final center = Paint()..color = const Color(0xFFFEF08A);
    canvas.drawCircle(Offset(fx, fy), 2, center);
  }

  @override
  bool shouldRepaint(covariant _OpenMeadowPainter oldDelegate) => true;
}

/// 🎆 Particle FX Painter
class _MeadowParticlePainter extends CustomPainter {
  final List<MeadowParticle> particles;

  _MeadowParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.life, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MeadowParticlePainter oldDelegate) => true;
}
