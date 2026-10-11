import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

/// 🎈 Kids Interactive 2D Game Session Page
/// Features:
/// - Balloon Popping with Phonics & Alphabet (Day 1 - 15)
/// - Animal Safari Words & Sounds (Day 16 - 30)
/// - Colors & Numbers Adventure (Day 31 - 50)
/// - Food, Action & Story mini-games (Day 51 - 100)
class PocketKidsGameSessionPage extends StatefulWidget {
  final int day;
  const PocketKidsGameSessionPage({super.key, required this.day});

  @override
  State<PocketKidsGameSessionPage> createState() =>
      _PocketKidsGameSessionPageState();
}

class _BalloonItem {
  final String id;
  final String label;
  final String subtitle;
  final String emoji;
  final Color color;
  double x; // 0.1 to 0.85
  double y; // 0.1 to 0.85
  double scale = 1.0;
  bool isPopped = false;

  _BalloonItem({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.x,
    required this.y,
  });
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double opacity = 1.0;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
  });
}

class _PocketKidsGameSessionPageState extends State<PocketKidsGameSessionPage>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late AnimationController _floatController;
  late AnimationController _particleController;

  final List<_BalloonItem> _balloons = [];
  final List<_Particle> _particles = [];
  int _currentRound = 0;
  int _starsEarned = 0;
  bool _isSessionFinished = false;
  String _targetLetter = 'A';
  String _targetPrompt = 'Pop the letter A! 🎈';

  static const List<Color> _balloonColors = [
    Color(0xFFEF4444), // Candy Red
    Color(0xFF3B82F6), // Sky Blue
    Color(0xFF10B981), // Jungle Green
    Color(0xFFF59E0B), // Sunny Amber
    Color(0xFF8B5CF6), // Royal Purple
    Color(0xFFEC4899), // Bubble Pink
  ];

  @override
  void initState() {
    super.initState();
    _initTts();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        _updateParticles();
      });

    _startRound(0);
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3); // Cheerful kid pitch
      await _tts.setSpeechRate(0.42); // Clear and slow for kids
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.speak(text);
    } catch (_) {}
  }

  void _startRound(int roundIndex) {
    _currentRound = roundIndex;
    _balloons.clear();

    final rand = math.Random();

    if (widget.day <= 15) {
      // 🔤 Alphabet Valley (A-Z)
      final letters = [
        ['A', 'Apple', '🍎'],
        ['B', 'Ball', '⚽'],
        ['C', 'Cat', '🐱'],
        ['D', 'Dog', '🐶'],
        ['E', 'Elephant', '🐘'],
        ['F', 'Fish', '🐟'],
        ['G', 'Giraffe', '🦒'],
        ['H', 'House', '🏡'],
      ];

      final pair = letters[roundIndex % letters.length];
      _targetLetter = pair[0];
      _targetPrompt = 'Pop the letter $_targetLetter! 🎈';

      // Pick target + 3 distractors
      final pool = List<List<String>>.from(letters)..shuffle();
      pool.removeWhere((item) => item[0] == _targetLetter);
      final roundItems = [pair, pool[0], pool[1], pool[2]]..shuffle();

      final positions = [
        const Offset(0.25, 0.32),
        const Offset(0.72, 0.28),
        const Offset(0.30, 0.65),
        const Offset(0.70, 0.68),
      ];

      for (int i = 0; i < roundItems.length; i++) {
        final it = roundItems[i];
        final pos = positions[i];
        _balloons.add(
          _BalloonItem(
            id: 'b_${it[0]}_$i',
            label: it[0],
            subtitle: it[1],
            emoji: it[2],
            color: _balloonColors[rand.nextInt(_balloonColors.length)],
            x: pos.dx,
            y: pos.dy,
          ),
        );
      }
    } else if (widget.day <= 30) {
      // 🦁 Animal Safari Words
      final animals = [
        ['Lion', 'Roar!', '🦁'],
        ['Panda', 'Bamboo', '🐼'],
        ['Fox', 'Clever', '🦊'],
        ['Bunny', 'Hop hop', '🐰'],
        ['Tiger', 'Stripes', '🐯'],
        ['Bear', 'Honey', '🐻'],
      ];
      final target = animals[roundIndex % animals.length];
      _targetLetter = target[0];
      _targetPrompt = 'Find the ${target[0]}! ${target[2]}';

      final pool = List<List<String>>.from(animals)..shuffle();
      pool.removeWhere((item) => item[0] == _targetLetter);
      final roundItems = [target, pool[0], pool[1], pool[2]]..shuffle();

      final positions = [
        const Offset(0.24, 0.30),
        const Offset(0.74, 0.28),
        const Offset(0.28, 0.65),
        const Offset(0.72, 0.66),
      ];

      for (int i = 0; i < roundItems.length; i++) {
        final it = roundItems[i];
        final pos = positions[i];
        _balloons.add(
          _BalloonItem(
            id: 'b_${it[0]}_$i',
            label: it[0],
            subtitle: it[1],
            emoji: it[2],
            color: _balloonColors[rand.nextInt(_balloonColors.length)],
            x: pos.dx,
            y: pos.dy,
          ),
        );
      }
    } else {
      // 🍎 Colors & Yummy Orchard
      final items = [
        ['Red', 'Strawberry', '🍓'],
        ['Blue', 'Blueberry', '🫐'],
        ['Yellow', 'Banana', '🍌'],
        ['Green', 'Apple', '🍏'],
        ['Orange', 'Orange', '🍊'],
        ['Purple', 'Grape', '🍇'],
      ];
      final target = items[roundIndex % items.length];
      _targetLetter = target[0];
      _targetPrompt = 'Tap the ${target[0]} item! 🎈';

      final pool = List<List<String>>.from(items)..shuffle();
      pool.removeWhere((item) => item[0] == _targetLetter);
      final roundItems = [target, pool[0], pool[1], pool[2]]..shuffle();

      final positions = [
        const Offset(0.24, 0.30),
        const Offset(0.74, 0.28),
        const Offset(0.28, 0.65),
        const Offset(0.72, 0.66),
      ];

      for (int i = 0; i < roundItems.length; i++) {
        final it = roundItems[i];
        final pos = positions[i];
        _balloons.add(
          _BalloonItem(
            id: 'b_${it[0]}_$i',
            label: it[0],
            subtitle: it[1],
            emoji: it[2],
            color: _balloonColors[rand.nextInt(_balloonColors.length)],
            x: pos.dx,
            y: pos.dy,
          ),
        );
      }
    }

    setState(() {});
    _speak(_targetPrompt);
  }

  void _onTapBalloon(_BalloonItem balloon) {
    if (balloon.isPopped) return;

    if (balloon.label == _targetLetter) {
      // 🌟 Correct! Pop balloon with star particle burst
      HapticFeedback.heavyImpact();
      balloon.isPopped = true;
      _spawnParticles(balloon.x, balloon.y, balloon.color);
      _starsEarned++;

      final successWord = '${balloon.label} is for ${balloon.subtitle}! ${balloon.emoji}';
      _speak(successWord);

      setState(() {});

      Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        if (_currentRound + 1 >= 5) {
          _finishSession();
        } else {
          _startRound(_currentRound + 1);
        }
      });
    } else {
      // Gentle wobble & audio reminder
      HapticFeedback.lightImpact();
      _speak('Oops! Try finding $_targetLetter!');
    }
  }

  void _spawnParticles(double x, double y, Color color) {
    final rand = math.Random();
    _particles.clear();
    for (int i = 0; i < 24; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = rand.nextDouble() * 300 + 150;
      _particles.add(
        _Particle(
          x: x,
          y: y,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          color: color,
          size: rand.nextDouble() * 10 + 6,
        ),
      );
    }
    _particleController.forward(from: 0.0);
  }

  void _updateParticles() {
    final dt = 0.016;
    for (final p in _particles) {
      p.x += p.vx * dt * 0.001;
      p.y += p.vy * dt * 0.001 + (300 * dt * dt * 0.001); // gentle gravity
      p.opacity = (1.0 - _particleController.value).clamp(0.0, 1.0);
    }
    setState(() {});
  }

  Future<void> _finishSession() async {
    if (_isSessionFinished) return;
    _isSessionFinished = true;
    final earnedStars = _starsEarned.clamp(1, 3);
    await PocketKidsService.completeDayGame(widget.day, earnedStars);

    HapticFeedback.heavyImpact();
    _speak('Super star! Day ${widget.day} Complete! You earned 3 stars!');

    if (!mounted) return;

    final currentHouse = PocketKidsService.currentHouse;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF38BDF8),
                  Color(0xFF1E3A8A),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFFFD700), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  'DAY ${widget.day} COMPLETE!',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Awesome job, ${PocketKidsService.kidName}! 🌟',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // 3 Bouncing Golden Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('⭐', style: TextStyle(fontSize: 42)),
                    SizedBox(width: 8),
                    Text('⭐', style: TextStyle(fontSize: 52)),
                    SizedBox(width: 8),
                    Text('⭐', style: TextStyle(fontSize: 42)),
                  ],
                ),
                const SizedBox(height: 16),

                // Homestead progress badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currentHouse.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        'Achieved: ${currentHouse.title}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Back to Map Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context); // back to home map
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: const Color(0xFF1E3A8A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'BACK TO ADVENTURE MAP ➔',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _particleController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0284C7),
      body: Stack(
        children: [
          // Background Cartoon Sky & Rolling Green Hills
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF38BDF8), // Sunny Blue Sky
                  Color(0xFFBAE6FD), // Soft Sky
                  Color(0xFF4ADE80), // Rolling Meadow
                ],
                stops: [0.0, 0.72, 1.0],
              ),
            ),
          ),

          // Floating Cartoon Clouds
          Positioned(
            top: 60,
            left: 20,
            child: Opacity(
              opacity: 0.35,
              child: const Text('☁️', style: TextStyle(fontSize: 70)),
            ),
          ),
          Positioned(
            top: 110,
            right: 25,
            child: Opacity(
              opacity: 0.3,
              child: const Text('☁️', style: TextStyle(fontSize: 90)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top HUD Bar: Close, Level, Stars Counter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Back Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Day Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white38),
                        ),
                        child: Text(
                          'DAY ${widget.day} • LEVEL ${_currentRound + 1}/5',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Stars Earned
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 15)),
                            const SizedBox(width: 4),
                            Text(
                              '$_starsEarned',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Prompt Card
                GestureDetector(
                  onTap: () => _speak(_targetPrompt),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF38BDF8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.volume_up_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            _targetPrompt,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF0F172A),
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // 🎈 PLAYGROUND: BALLOONS CANVAS
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;

                      return Stack(
                        children: [
                          // Custom Painter for Burst Particles
                          CustomPaint(
                            size: Size(w, h),
                            painter: _ParticlePainter(particles: _particles, w: w, h: h),
                          ),

                          // Render Floating Balloons
                          ..._balloons.map((b) {
                            if (b.isPopped) return const SizedBox.shrink();

                            return AnimatedBuilder(
                              animation: _floatController,
                              builder: (context, child) {
                                final floatOffset = math.sin(_floatController.value * math.pi + (b.x * 10)) * 12;
                                return Positioned(
                                  left: b.x * w - 55,
                                  top: b.y * h - 70 + floatOffset,
                                  child: child!,
                                );
                              },
                              child: GestureDetector(
                                onTap: () => _onTapBalloon(b),
                                child: _buildCartoonBalloon(b),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartoonBalloon(_BalloonItem b) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Balloon Body
        Container(
          width: 110,
          height: 125,
          decoration: BoxDecoration(
            color: b.color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(55),
              bottom: Radius.circular(50),
            ),
            boxShadow: [
              BoxShadow(
                color: b.color.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
              // Inner highlight for 3D cartoon shine
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.35),
                blurRadius: 4,
                offset: const Offset(-8, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                b.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 2),
              Text(
                b.label,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Balloon Knot
        Container(
          width: 10,
          height: 6,
          decoration: BoxDecoration(
            color: b.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        // Balloon String
        Container(
          width: 2,
          height: 26,
          color: Colors.black26,
        ),
      ],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double w;
  final double h;

  const _ParticlePainter({required this.particles, required this.w, required this.h});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x * w, p.y * h), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
