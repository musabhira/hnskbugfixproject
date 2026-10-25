import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';

// ============================================================================
// 🎨 1. DRAWING CANVAS MODELS & PATH DATA
// ============================================================================

enum ArtToolType { brush, pencil, crayon, eraser }

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  DrawnLine({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
  });
}

class ArtChallengeItem {
  final String id;
  final String title;
  final String category;
  final String emoji;
  final int rewardKS;
  final String sampleWord;

  const ArtChallengeItem({
    required this.id,
    required this.title,
    required this.category,
    required this.emoji,
    required this.rewardKS,
    required this.sampleWord,
  });
}

// ============================================================================
// 📱 2. LITTLE ARTIST DRAWING & COLORING STUDIO (REFERENCE IMAGE 3)
// ============================================================================

class PocketKidsArtStudioPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsArtStudioPage({super.key, this.day = 1, this.onCompleted});

  static Future<void> show(BuildContext context, {int day = 1, VoidCallback? onCompleted}) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsArtStudioPage(day: day, onCompleted: onCompleted),
      ),
    );
  }

  @override
  State<PocketKidsArtStudioPage> createState() => _PocketKidsArtStudioPageState();
}

class _PocketKidsArtStudioPageState extends State<PocketKidsArtStudioPage> {
  final FlutterTts _tts = FlutterTts();

  // Curated Daily Art Challenges (Matching Reference Image 3)
  final List<ArtChallengeItem> _challenges = const [
    ArtChallengeItem(
      id: 'whale',
      title: 'Imagine a Whale!',
      category: 'Magic animal',
      emoji: '🐋',
      rewardKS: 10,
      sampleWord: 'WHALE',
    ),
    ArtChallengeItem(
      id: 'rainbow',
      title: "Let's Draw a Rainbow!",
      category: 'Nature',
      emoji: '🌈',
      rewardKS: 10,
      sampleWord: 'RAINBOW',
    ),
    ArtChallengeItem(
      id: 'lion',
      title: 'Sketch King Lion!',
      category: 'Animals',
      emoji: '🦁',
      rewardKS: 10,
      sampleWord: 'LION',
    ),
    ArtChallengeItem(
      id: 'apple',
      title: 'Color a Sweet Apple!',
      category: 'Fruits',
      emoji: '🍎',
      rewardKS: 10,
      sampleWord: 'APPLE',
    ),
    ArtChallengeItem(
      id: 'sun',
      title: 'Draw a Shining Sun!',
      category: 'Nature',
      emoji: '☀️',
      rewardKS: 10,
      sampleWord: 'SUN',
    ),
    ArtChallengeItem(
      id: 'house',
      title: 'Build a Dream Cabin!',
      category: 'Magic',
      emoji: '🏡',
      rewardKS: 15,
      sampleWord: 'CABIN',
    ),
  ];

  int _currentChallengeIndex = 0;
  late ArtChallengeItem _activeChallenge;
  int _activeCategoryIndex = 0;
  final List<String> _categories = ['Animals', 'Cars', 'Flowers', 'Magic', 'Nature'];

  // Canvas State
  final List<DrawnLine> _lines = [];
  DrawnLine? _currentLine;
  Color _selectedColor = const Color(0xFF0284C7); // Deep Blue
  ArtToolType _selectedTool = ArtToolType.brush;
  bool _showPolaroidVictory = false;

  // Color Palette Dots matching Reference Image 3
  final List<Color> _palette = const [
    Color(0xFF0F172A), // Black
    Color(0xFF0284C7), // Blue
    Color(0xFF38BDF8), // Sky
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFFBBF24), // Yellow
    Color(0xFF10B981), // Green
    Color(0xFF6EE7B7), // Mint
  ];

  @override
  void initState() {
    super.initState();
    _currentChallengeIndex = 0;
    _activeChallenge = _challenges.first;
    _initTts();
  }

  void _nextArtChallenge() async {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playPopSound();

    if (_currentChallengeIndex < _challenges.length - 1) {
      setState(() {
        _currentChallengeIndex++;
        _activeChallenge = _challenges[_currentChallengeIndex];
        _showPolaroidVictory = false;
        _lines.clear();
        _currentLine = null;
      });
      _speak("Awesome! Challenge ${_currentChallengeIndex + 1}: ${_activeChallenge.title}");
    } else {
      // Completed all 6 challenges!
      await PocketKidsService.addKidsScore(25);
      await PocketKidsService.addKidStars(2);
      await PocketKidsService.markDayStepCompleted(widget.day, 9);
      widget.onCompleted?.call();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _initTts() async {
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

  double get _currentStrokeWidth {
    switch (_selectedTool) {
      case ArtToolType.brush:
        return 8.0;
      case ArtToolType.pencil:
        return 3.5;
      case ArtToolType.crayon:
        return 12.0;
      case ArtToolType.eraser:
        return 22.0;
    }
  }

  void _onTransformPressed() async {
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Draw something on the canvas first! 🎨',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    PocketGameSFX.playVictoryFanfare();
    await PocketKidsService.addKidsScore(_activeChallenge.rewardKS);

    setState(() {
      _showPolaroidVictory = true;
    });

    _speak("Brilliant masterpiece! ${_activeChallenge.sampleWord} Challenge Completed! You earned +${_activeChallenge.rewardKS} Kids Score!");
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEB), // Soft cream warm paper background
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                        ),
                      ),

                      // Challenge Title Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(_activeChallenge.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '${_activeChallenge.title} (${_currentChallengeIndex + 1}/${_challenges.length})',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF78350F),
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Clear / Trash Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          setState(() => _lines.clear());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Selector Row (Reference Image 3: Animals, Cars, Flowers, Magic, Nature)
                Container(
                  height: 38,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSel = _activeCategoryIndex == idx;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _activeCategoryIndex = idx;
                            final match = _challenges.firstWhere(
                              (c) => c.category.toLowerCase() == cat.toLowerCase(),
                              orElse: () => _challenges[idx % _challenges.length],
                            );
                            _activeChallenge = match;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFF59E0B) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel ? const Color(0xFFD97706) : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cat,
                            style: GoogleFonts.outfit(
                              color: isSel ? Colors.white : const Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Freehand Drawing Canvas (Dotted Grid Paper)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFFDE68A), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: GestureDetector(
                        onPanStart: (details) {
                          setState(() {
                            final point = details.localPosition;
                            _currentLine = DrawnLine(
                              points: [point],
                              color: _selectedTool == ArtToolType.eraser ? Colors.white : _selectedColor,
                              strokeWidth: _currentStrokeWidth,
                              isEraser: _selectedTool == ArtToolType.eraser,
                            );
                            _lines.add(_currentLine!);
                          });
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            final point = details.localPosition;
                            _currentLine?.points.add(point);
                          });
                        },
                        onPanEnd: (_) {
                          _currentLine = null;
                        },
                        child: CustomPaint(
                          painter: _ArtCanvasPainter(lines: _lines),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                ),

                // Glowing "Transform! ✨" Pill Button
                GestureDetector(
                  onTap: _onTransformPressed,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)], // Glowing emerald mint
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.45),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Transform!',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('✨', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),

                // Color Palette Dots Row (Reference Image 3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _palette.map((c) {
                        final isSel = _selectedColor == c && _selectedTool != ArtToolType.eraser;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedColor = c;
                              if (_selectedTool == ArtToolType.eraser) {
                                _selectedTool = ArtToolType.brush;
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? const Color(0xFFF59E0B) : Colors.white,
                                width: isSel ? 3.5 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Bottom Tool Picker Dock (Brush, Pencil, Crayon, Eraser)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildToolButton(ArtToolType.brush, '🖌️', 'Brush'),
                      _buildToolButton(ArtToolType.pencil, '✏️', 'Pencil'),
                      _buildToolButton(ArtToolType.crayon, '🖍️', 'Crayon'),
                      _buildToolButton(ArtToolType.eraser, '🧹', 'Eraser'),
                    ],
                  ),
                ),
              ],
            ),

            // Polaroid Celebration Result Modal (Reference Image 3 Right Screen)
            if (_showPolaroidVictory) _buildPolaroidVictoryModal(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(ArtToolType type, String emoji, String label) {
    final isSel = _selectedTool == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedTool = type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFFEF3C7) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSel ? const Color(0xFFF59E0B) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: isSel ? const Color(0xFFB45309) : const Color(0xFF64748B),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolaroidVictoryModal() {
    return Container(
      color: Colors.black.withValues(alpha: 0.65),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFF59E0B), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Challenge Completed! 🌟',
              style: GoogleFonts.outfit(
                color: const Color(0xFF78350F),
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 12),

            // Polaroid Snapshot Frame
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _activeChallenge.emoji,
                      style: const TextStyle(fontSize: 68),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _activeChallenge.sampleWord,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3 Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildModalStar(34),
                const SizedBox(width: 6),
                _buildModalStar(46, isCenter: true),
                const SizedBox(width: 6),
                _buildModalStar(34),
              ],
            ),
            const SizedBox(height: 14),

            // Stats row (Reference Image 3: 5 mins Speed, 100% Creativity, 3 days streak)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatPill('⚡', '5 mins', 'Speed'),
                _buildStatPill('🌈', '100%', 'Creativity'),
                _buildStatPill('🔥', '+${_activeChallenge.rewardKS}', 'KS Stars'),
              ],
            ),
            const SizedBox(height: 18),

            // Keep Drawing & Complete Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPolaroidVictory = false;
                        _lines.clear();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF64748B),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Keep Drawing',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _nextArtChallenge,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF84CC16), Color(0xFF65A30D)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF84CC16).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _currentChallengeIndex < _challenges.length - 1
                            ? 'Next Drawing (${_currentChallengeIndex + 2}/${_challenges.length}) ▶'
                            : 'Complete Studio 🏆',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
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

  Widget _buildModalStar(double size, {bool isCenter = false}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (isCenter)
            BoxShadow(
              color: const Color(0xFFFFB703).withValues(alpha: 0.5),
              blurRadius: 14,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Icon(Icons.star_rounded, size: size, color: const Color(0xFFFFB703)),
    );
  }

  Widget _buildStatPill(String emoji, String val, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(
                val,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF78350F),
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.black45, fontSize: 9.5),
          ),
        ],
      ),
    );
  }
}

class _ArtCanvasPainter extends CustomPainter {
  final List<DrawnLine> lines;

  _ArtCanvasPainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Subtle Dot Grid Pattern
    final dotPaint = Paint()..color = const Color(0xFFF1F5F9);
    for (double x = 12; x < size.width; x += 24) {
      for (double y = 12; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }

    // 2. Render Drawn Strokes
    for (var line in lines) {
      if (line.points.length < 2) continue;

      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(line.points.first.dx, line.points.first.dy);
      for (int i = 1; i < line.points.length; i++) {
        path.lineTo(line.points[i].dx, line.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArtCanvasPainter oldDelegate) => true;
}
