import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🌟 Particle effect for collecting correct letters/tokens
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

/// 🏃 2D Open-World Meadow Runner & Letter Hunt Game
///
/// Designed with lush green open meadows, bright blue sunlit skies,
/// 3-lane running mechanics, letter collection, jump mechanics,
/// TTS audio feedback, and fullscreen immersion.
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
  int _playerLane = 1; // 0 = Left, 1 = Center, 2 = Right
  double _playerJumpY = 0.0;
  bool _isJumping = false;
  int _score = 0;
  int _streak = 0;
  bool _isMuted = false;

  final List<MeadowParticle> _particles = [];
  double _cloudOffset = 0.0;
  double _walkCycle = 0.0;

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

  @override
  void dispose() {
    _animController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _gameLoop() {
    if (!mounted) return;
    setState(() {
      _cloudOffset += 0.4;
      _walkCycle += 0.15;

      // Jump gravity
      if (_isJumping) {
        _playerJumpY -= 4.0;
        if (_playerJumpY <= 0) {
          _playerJumpY = 0;
          _isJumping = false;
        }
      }

      // Update particles
      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.3; // gravity
        p.life -= 0.04;
        if (p.life <= 0) {
          _particles.removeAt(i);
        }
      }
    });
  }

  void _jump() {
    if (_isJumping) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isJumping = true;
      _playerJumpY = 48.0;
    });
  }

  void _changeLane(int targetLane) {
    if (targetLane < 0 || targetLane > 2) return;
    HapticFeedback.selectionClick();
    setState(() {
      _playerLane = targetLane;
    });
  }

  void _spawnSparkles(double x, double y) {
    for (int i = 0; i < 20; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 2.0 + _random.nextDouble() * 4.5;
      final colors = [
        const Color(0xFFFFD700),
        const Color(0xFFFACC15),
        const Color(0xFF10B981),
        const Color(0xFF38BDF8),
        Colors.white,
      ];
      _particles.add(
        MeadowParticle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 2.5,
          life: 1.0,
          color: colors[_random.nextInt(colors.length)],
          size: 4.0 + _random.nextDouble() * 5.0,
        ),
      );
    }
  }

  void _onOptionChosen(String option, String correct, int lane) {
    _changeLane(lane);
    final isCorrect = option.trim().toUpperCase() == correct.trim().toUpperCase();

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      _score += 100 + (_streak * 20);
      _streak++;
      _spawnSparkles(MediaQuery.of(context).size.width * ((lane + 1) / 4), 160.0);
      _speak('Awesome! Correct letter $option');

      widget.onRoundCompleted?.call(_currentRound);

      if (_currentRound < widget.rounds.length - 1) {
        Future.delayed(const Duration(milliseconds: 650), () {
          if (mounted) {
            setState(() {
              _currentRound++;
            });
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            widget.onAllCompleted?.call();
            _showVictoryDialog();
          }
        });
      }
    } else {
      HapticFeedback.vibrate();
      _streak = 0;
      _speak('Oops, try another letter!');
    }
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF047857), Color(0xFF064E3B)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.5),
                blurRadius: 25,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 54)),
              const SizedBox(height: 10),
              Text(
                'MEADOW RUNNER MASTERED!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You found all target letters in the open world meadow!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      'TOTAL SCORE: $_score XP',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (widget.isFullscreen) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(
                    'CLAIM VICTORY ➔',
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
    final promptRaw = rData['prompt'];
    String promptText = '';
    if (promptRaw is Map) {
      promptText = promptRaw[widget.nativeLanguage]?.toString() ??
          promptRaw['en']?.toString() ??
          promptRaw['Malayalam']?.toString() ??
          '';
    } else {
      promptText = promptRaw?.toString() ?? '';
    }

    final options = (rData['options'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final correct = rData['correct']?.toString() ?? '';

    final content = Column(
      children: [
        // Top HUD Banner
        _buildHud(promptText, widget.rounds.length),
        const SizedBox(height: 10),

        // 2D Open-World Meadow Canvas
        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) > 100) {
                _changeLane(_playerLane + 1); // Swipe Right
              } else if ((details.primaryVelocity ?? 0) < -100) {
                _changeLane(_playerLane - 1); // Swipe Left
              }
            },
            onVerticalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) < -100) {
                _jump(); // Swipe Up to Jump
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Natural Sky & Meadow Rolling Hills Landscape
                  CustomPaint(
                    painter: _MeadowLandscapePainter(
                      cloudOffset: _cloudOffset,
                      walkCycle: _walkCycle,
                    ),
                  ),

                  // 2. Target Letter Tokens Floating in 3 Lanes
                  _buildFloatingLetterTokens(options, correct),

                  // 3. 2D Animated Runner Avatar
                  _buildRunnerAvatar(),

                  // 4. Sparkle Particles
                  IgnorePointer(
                    child: CustomPaint(
                      painter: _MeadowParticlePainter(particles: _particles),
                    ),
                  ),

                  // 5. Controls Overlay Hint
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: _buildControlsRow(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.isFullscreen) {
      return Scaffold(
        backgroundColor: const Color(0xFF0284C7),
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

  Widget _buildHud(String prompt, int totalRounds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0284C7)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Round Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ROUND ${_currentRound + 1} / $totalRounds',
                  style: GoogleFonts.outfit(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // XP Score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '+$_score XP',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              if (_streak > 1) ...[
                const SizedBox(width: 6),
                Text(
                  '🔥 ${_streak}x',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFF9100),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
              const Spacer(),
              // Sound Toggle
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _isMuted = !_isMuted);
                },
              ),
              // Fullscreen Toggle
              if (!widget.isFullscreen)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.fullscreen_rounded, color: Color(0xFFFFD700), size: 24),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MeadowRunnerGamePage(
                          rounds: widget.rounds,
                          initialRound: _currentRound,
                          nativeLanguage: widget.nativeLanguage,
                          isFullscreen: true,
                          onRoundCompleted: widget.onRoundCompleted,
                          onAllCompleted: widget.onAllCompleted,
                        ),
                      ),
                    );
                  },
                )
              else
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_fullscreen_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            prompt,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              shadows: const [
                Shadow(color: Colors.black45, blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingLetterTokens(List<String> options, String correct) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final laneWidth = constraints.maxWidth / 3;
        final tokenY = constraints.maxHeight * 0.32;

        return Stack(
          children: List.generate(options.take(3).length, (i) {
            final opt = options[i];
            final x = (i * laneWidth) + (laneWidth / 2) - 38;
            final isTarget = opt.trim().toUpperCase() == correct.trim().toUpperCase();

            // Floating bounce offset
            final bounce = math.sin(_walkCycle + (i * 1.5)) * 6.0;

            return Positioned(
              left: x,
              top: tokenY + bounce,
              child: GestureDetector(
                onTap: () => _onOptionChosen(opt, correct, i),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isTarget
                          ? const [Color(0xFFFFD700), Color(0xFFF59E0B)]
                          : const [Color(0xFF0F172A), Color(0xFF1E293B)],
                    ),
                    border: Border.all(
                      color: isTarget ? const Color(0xFFFEF08A) : const Color(0xFF38BDF8),
                      width: 3.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isTarget ? const Color(0xFFFFD700) : const Color(0xFF38BDF8))
                            .withValues(alpha: 0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      opt,
                      style: GoogleFonts.outfit(
                        color: isTarget ? const Color(0xFF0F172A) : Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildRunnerAvatar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final laneWidth = constraints.maxWidth / 3;
        final x = (_playerLane * laneWidth) + (laneWidth / 2) - 35;
        final y = constraints.maxHeight * 0.70 - _playerJumpY;

        // Running bounce animation
        final runBob = math.sin(_walkCycle * 2) * 4.0;

        return Positioned(
          left: x,
          top: y + runBob,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Character sprite container
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🏃‍♂️', style: TextStyle(fontSize: 38)),
                ),
              ),
              const SizedBox(height: 2),
              // Shadow under runner
              Container(
                width: 44,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton('◀ LANE', () => _changeLane(_playerLane - 1)),
          _buildControlButton('JUMP 🦘', _jump, isPrimary: true),
          _buildControlButton('LANE ▶', () => _changeLane(_playerLane + 1)),
        ],
      ),
    );
  }

  Widget _buildControlButton(String label, VoidCallback onTap, {bool isPrimary = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? const Color(0xFF34D399) : Colors.white24,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// 🎨 Natural Meadow & Sunny Sky 2D Landscape Painter
class _MeadowLandscapePainter extends CustomPainter {
  final double cloudOffset;
  final double walkCycle;

  _MeadowLandscapePainter({
    required this.cloudOffset,
    required this.walkCycle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Sky Gradient (Deep rich azure blue)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF0EA5E9)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 2. Glowing Warm Sun
    final sunCenter = Offset(size.width * 0.85, 60);
    final sunGlow = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(sunCenter, 46, sunGlow);

    final sunCore = Paint()..color = const Color(0xFFFACC15);
    canvas.drawCircle(sunCenter, 28, sunCore);

    // 3. Drifting Puffy Clouds
    _drawCloud(canvas, (size.width * 0.15 + cloudOffset) % (size.width + 120) - 60, 50, 24);
    _drawCloud(canvas, (size.width * 0.60 + cloudOffset * 0.8) % (size.width + 120) - 60, 85, 20);

    // 4. Distant Rolling Green Hills (Deep forest green)
    final farHillPaint = Paint()..color = const Color(0xFF15803D);
    final farHillPath = Path()
      ..moveTo(0, size.height * 0.46)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.40, size.width * 0.55, size.height * 0.47)
      ..quadraticBezierTo(size.width * 0.80, size.height * 0.52, size.width, size.height * 0.44)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(farHillPath, farHillPaint);

    // 5. Near Rolling Meadows (Lush vibrant grass)
    final nearHillPaint = Paint()..color = const Color(0xFF16A34A);
    final nearHillPath = Path()
      ..moveTo(0, size.height * 0.54)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.50, size.width * 0.70, size.height * 0.56)
      ..quadraticBezierTo(size.width * 0.88, size.height * 0.60, size.width, size.height * 0.54)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(nearHillPath, nearHillPaint);

    // 6. Foreground Runner Meadow & Stone Pathway
    final groundPaint = Paint()..color = const Color(0xFF14532D);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38), groundPaint);

    // 3 Running Track Lanes (Perspective lines)
    final laneLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final lane1X = size.width / 3;
    final lane2X = (size.width / 3) * 2;
    canvas.drawLine(Offset(lane1X, size.height * 0.62), Offset(lane1X, size.height), laneLinePaint);
    canvas.drawLine(Offset(lane2X, size.height * 0.62), Offset(lane2X, size.height), laneLinePaint);

    // Wildflowers on grass
    final flowerPaint = Paint()..color = const Color(0xFFF43F5E);
    for (int i = 0; i < 6; i++) {
      final fx = (size.width * 0.1) + (i * size.width * 0.16);
      final fy = size.height * 0.64 + (i % 2 == 0 ? 6 : -4);
      canvas.drawCircle(Offset(fx, fy), 4, flowerPaint);
      canvas.drawCircle(Offset(fx, fy), 1.5, Paint()..color = Colors.yellow);
    }
  }

  void _drawCloud(Canvas canvas, double x, double y, double r) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.90);
    canvas.drawCircle(Offset(x, y), r, p);
    canvas.drawCircle(Offset(x + r * 0.8, y - r * 0.2), r * 0.7, p);
    canvas.drawCircle(Offset(x - r * 0.7, y + r * 0.1), r * 0.6, p);
    canvas.drawCircle(Offset(x + r * 1.4, y + r * 0.1), r * 0.55, p);
  }

  @override
  bool shouldRepaint(covariant _MeadowLandscapePainter oldDelegate) {
    return oldDelegate.cloudOffset != cloudOffset || oldDelegate.walkCycle != walkCycle;
  }
}

/// ✨ Particle Painter
class _MeadowParticlePainter extends CustomPainter {
  final List<MeadowParticle> particles;

  _MeadowParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color.withValues(alpha: p.life.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, p.y), p.size * p.life, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MeadowParticlePainter oldDelegate) => true;
}
