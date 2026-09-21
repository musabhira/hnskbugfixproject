import 'dart:async';
import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pocket_mission_curriculum_1_18.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 🔥 FLAME 2D INTERACTIVE LETTER & PARTICLE ARENA
// ─────────────────────────────────────────────────────────────────────────────

class _FlameParticle {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  double life;
  double maxLife;
  Color color;

  _FlameParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.life,
    required this.maxLife,
    required this.color,
  });

  bool update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;
    radius = math.max(0.0, radius - dt * 1.5);
    return life > 0 && radius > 0;
  }
}

class AlphabetFlameGame extends FlameGame with TapCallbacks {
  String currentLetter = 'A a';
  VoidCallback? onArenaTap;

  final List<_FlameParticle> _particles = [];
  final math.Random _rng = math.Random();
  double _time = 0.0;
  double _bounceScale = 1.0;

  AlphabetFlameGame({
    required this.currentLetter,
    this.onArenaTap,
  });

  void updateLetter(String letter) {
    currentLetter = letter;
    triggerFlameBurst();
  }

  void triggerFlameBurst() {
    _bounceScale = 1.35;
    final cx = size.x / 2;
    final cy = size.y / 2;

    const colors = [
      Color(0xFFFF3D00),
      Color(0xFFFF9100),
      Color(0xFFFFD700),
      Color(0xFFFFAB00),
      Color(0xFFFF6D00),
      Color(0xFF00E5FF),
    ];

    for (int i = 0; i < 36; i++) {
      final angle = _rng.nextDouble() * 2 * math.pi;
      final speed = 70.0 + _rng.nextDouble() * 160.0;
      final life = 0.45 + _rng.nextDouble() * 0.55;
      _particles.add(
        _FlameParticle(
          x: cx + math.cos(angle) * 16,
          y: cy + math.sin(angle) * 16,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 25,
          radius: 3.5 + _rng.nextDouble() * 4.5,
          life: life,
          maxLife: life,
          color: colors[_rng.nextInt(colors.length)],
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    if (_bounceScale > 1.0) {
      _bounceScale = math.max(1.0, _bounceScale - dt * 2.2);
    }

    // Passive ambient sparks around the letter
    if (_particles.length < 18 && _rng.nextDouble() < 0.35) {
      final cx = size.x / 2;
      final cy = size.y / 2;
      final offset = (_rng.nextDouble() - 0.5) * 70;
      _particles.add(
        _FlameParticle(
          x: cx + offset,
          y: cy + 30 + _rng.nextDouble() * 10,
          vx: (_rng.nextDouble() - 0.5) * 35,
          vy: -35 - _rng.nextDouble() * 50,
          radius: 2.0 + _rng.nextDouble() * 2.5,
          life: 0.7,
          maxLife: 0.7,
          color: _rng.nextBool()
              ? const Color(0xFFFF9100)
              : const Color(0xFFFFD700),
        ),
      );
    }

    _particles.removeWhere((p) => !p.update(dt));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final cx = size.x / 2;
    final cy = size.y / 2;

    if (size.x <= 0 || size.y <= 0) return;

    // 1. Sleek Radiant Background Glow
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF6D00).withValues(alpha: 0.28),
          const Color(0xFFFF9100).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        radius: 0.85,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 140));
    canvas.drawCircle(Offset(cx, cy), 140, bgPaint);

    // 2. Rotating Flame Rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = const Color(0xFFFF9100).withValues(alpha: 0.45);

    final pulseRadius = 56.0 + math.sin(_time * 4.0) * 4.0;
    canvas.drawCircle(Offset(cx, cy), pulseRadius * _bounceScale, ringPaint);

    final outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.25);
    canvas.drawCircle(
        Offset(cx, cy), (pulseRadius + 16.0) * _bounceScale, outerRing);

    // 3. Central Glowing Emblem Orb
    final orbPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFF8500),
          Color(0xFFE65100),
          Color(0xFFBF360C),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 46));

    canvas.drawCircle(Offset(cx, cy), 46 * _bounceScale, orbPaint);

    // Orb border
    final orbBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = const Color(0xFFFFD700);
    canvas.drawCircle(Offset(cx, cy), 46 * _bounceScale, orbBorder);

    // 4. Draw Particles
    for (final p in _particles) {
      final pAlpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      final pPaint = Paint()
        ..color = p.color.withValues(alpha: pAlpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(p.x, p.y), p.radius, pPaint);
    }

    // 5. Render Centered Letter in Orb
    final textSpan = TextSpan(
      text: currentLetter,
      style: TextStyle(
        fontFamily: 'Outfit',
        fontSize: (currentLetter.length > 3 ? 24.0 : 30.0) * _bounceScale,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        shadows: const [
          Shadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    triggerFlameBurst();
    onArenaTap?.call();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🎮 DEDICATED ALPHABET & PHONICS GAME SCREEN (MINIMALIST GAME EDITION)
// ─────────────────────────────────────────────────────────────────────────────

class PocketAlphabetPhonicsGamePage extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final List<AlphabetPhonicItem> phonicsList;

  const PocketAlphabetPhonicsGamePage({
    super.key,
    required this.day,
    required this.selectedLanguage,
    required this.phonicsList,
  });

  @override
  State<PocketAlphabetPhonicsGamePage> createState() =>
      _PocketAlphabetPhonicsGamePageState();
}

class _PocketAlphabetPhonicsGamePageState
    extends State<PocketAlphabetPhonicsGamePage>
    with SingleTickerProviderStateMixin {
  late final FlutterTts _tts;
  late final AlphabetFlameGame _flameGame;

  int _currentIndex = 0;
  bool _isPlayingAudio = false;
  final Set<int> _completedIndices = {};
  late String _activeLanguage;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _activeLanguage = widget.selectedLanguage.isEmpty
        ? 'Malayalam'
        : widget.selectedLanguage;

    _tts = FlutterTts();
    _initTts();

    final initialLetter = widget.phonicsList.isNotEmpty
        ? widget.phonicsList.first.letter
        : 'A a';

    _flameGame = AlphabetFlameGame(
      currentLetter: initialLetter,
      onArenaTap: () {
        HapticFeedback.selectionClick();
        _speakCurrentLetter();
      },
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Audio directive: DO NOT auto-speak on initial screen open.
    // Audio only triggers when learner explicitly taps the speaker/sound button.
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(() {
        if (mounted) setState(() => _isPlayingAudio = false);
      });
      _tts.setErrorHandler((_) {
        if (mounted) setState(() => _isPlayingAudio = false);
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  AlphabetPhonicItem get _currentItem {
    if (widget.phonicsList.isEmpty) {
      return const AlphabetPhonicItem(
        letter: 'A a',
        phoneme: '/æ/',
        exampleWord: 'Apple',
        pronunciationGuide: 'വാ തുറന്ന് നാവ് താഴ്ത്തി: /æ/ ആപ്പിൾ',
        audioPrompt: 'A is for Apple, /æ/',
      );
    }
    return widget.phonicsList[_currentIndex.clamp(0, widget.phonicsList.length - 1)];
  }

  Future<void> _speakCurrentLetter() async {
    final item = _currentItem;
    try {
      if (mounted) setState(() => _isPlayingAudio = true);
      _flameGame.triggerFlameBurst();
      await _tts.stop();
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42);

      // Play audio prompt (e.g. "A is for Apple, /æ/")
      final textToSpeak = item.audioPrompt.isNotEmpty
          ? item.audioPrompt
          : '${item.letter}, ${item.exampleWord}';

      await _tts.speak(textToSpeak);
    } catch (_) {
      if (mounted) setState(() => _isPlayingAudio = false);
    }
  }

  Future<void> _speakWordOnly(String word) async {
    try {
      _flameGame.triggerFlameBurst();
      await _tts.stop();
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.speak(word);
    } catch (_) {}
  }

  void _goToNextLetter() {
    if (_currentIndex < widget.phonicsList.length - 1) {
      _selectIndex(_currentIndex + 1);
    } else {
      _showCompletionDialog();
    }
  }

  void _goToPrevLetter() {
    if (_currentIndex > 0) {
      _selectIndex(_currentIndex - 1);
    }
  }

  void _selectIndex(int index) {
    if (index < 0 || index >= widget.phonicsList.length) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
    _flameGame.updateLetter(widget.phonicsList[index].letter);
    // User Audio Directive: Silent by default; do NOT auto-speak when advancing letters!
  }

  void _markCurrentAsMastered() {
    HapticFeedback.mediumImpact();
    setState(() {
      _completedIndices.add(_currentIndex);
    });
    _flameGame.triggerFlameBurst();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              'Letter ${_currentItem.letter} Mastered! +10 XP',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Auto-advance to next letter if not last
    if (_currentIndex < widget.phonicsList.length - 1) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _selectIndex(_currentIndex + 1);
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    _completedIndices.add(_currentIndex);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFFF9100), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9100), Color(0xFFFFD700)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9100).withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🏆', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'ALPHABET QUEST COMPLETED!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'All ${widget.phonicsList.length} alphabet sounds & mouth placements practiced!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '+50 MASTERY XP EARNED',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9100),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'RETURN TO MISSIONS ✓',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
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
  Widget build(BuildContext context) {
    final item = _currentItem;
    final totalCount = widget.phonicsList.length;
    final progress = totalCount > 0 ? (_currentIndex + 1) / totalCount : 1.0;
    final isMastered = _completedIndices.contains(_currentIndex);
    final hasNext = _currentIndex < totalCount - 1;
    final hasPrev = _currentIndex > 0;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: GestureDetector(
          // Horizontal swipe gestures to glide effortlessly between letters
          onHorizontalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) < -200) {
              _goToNextLetter();
            } else if ((details.primaryVelocity ?? 0) > 200) {
              _goToPrevLetter();
            }
          },
          child: Stack(
            children: [
              // ─────────────────────────────────────────────────────────────
              // 1. MINIMAL PLAIN GAME BACKGROUND WITH CENTRAL CONTENT
              // ─────────────────────────────────────────────────────────────
              Column(
                children: [
                  // ── TOP MINIMAL HUD ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context)
                              .pop(_completedIndices.length >= totalCount),
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white70, size: 24),
                          tooltip: 'Exit Game',
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'LETTER ${_currentIndex + 1} OF $totalCount',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFF9100),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '⭐ ${_completedIndices.length * 10} XP',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFFFFD700),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.white12,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFF9100)),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Language Dropdown
                        PopupMenuButton<String>(
                          initialValue: _activeLanguage,
                          onSelected: (lang) => setState(() => _activeLanguage = lang),
                          color: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131C2E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.translate_rounded,
                                    color: Color(0xFFFFD700), size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  _activeLanguage,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'Malayalam',
                                child: Text('മലയാളം (Malayalam)',
                                    style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(
                                value: 'English',
                                child: Text('English',
                                    style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(
                                value: 'Tamil',
                                child: Text('தமிழ் (Tamil)',
                                    style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(
                                value: 'Telugu',
                                child: Text('తెలుగు (Telugu)',
                                    style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(
                                value: 'Hindi',
                                child: Text('हिन्दी (Hindi)',
                                    style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(
                                value: 'Kannada',
                                child: Text('ಕನ್ನಡ (Kannada)',
                                    style: TextStyle(color: Colors.white))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── CENTER HERO STAGE (HERO FLAME ORB + MINIMAL DETAILS) ──
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 56),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 2D Flame Letter Orb (interactive tap for sparks/burst)
                            SizedBox(
                              height: 180,
                              width: 180,
                              child: GameWidget(game: _flameGame),
                            ),

                            const SizedBox(height: 8),

                            // IPA Phoneme Tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                item.phoneme,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF00E5FF),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Target Word Chip (Tap to hear)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: item.exampleWord.split('/').map((w) {
                                final trimmed = w.trim();
                                return InkWell(
                                  onTap: () => _speakWordOnly(trimmed),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF131C2E),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          trimmed,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.volume_up_rounded,
                                          color: Color(0xFFFFD700),
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            // Minimal Articulation Guide in Malayalam/Selected Language
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E170A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('👄', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.getPronunciationGuide(_activeLanguage),
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFFFF8E1),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 🔊 Minimal Game Sound Button
                            ScaleTransition(
                              scale: _isPlayingAudio
                                  ? _pulseAnimation
                                  : const AlwaysStoppedAnimation(1.0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: _speakCurrentLetter,
                                  icon: Icon(
                                    _isPlayingAudio
                                        ? Icons.graphic_eq_rounded
                                        : Icons.volume_up_rounded,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                  label: Text(
                                    _isPlayingAudio ? 'PLAYING SOUND...' : 'PLAY SOUND 🔊',
                                    style: GoogleFonts.outfit(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isPlayingAudio
                                        ? const Color(0xFF00E5FF)
                                        : const Color(0xFFFF9100),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // 🌟 Mastered / Practice Action
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: OutlinedButton.icon(
                                onPressed: _markCurrentAsMastered,
                                icon: Icon(
                                  isMastered
                                      ? Icons.check_circle_rounded
                                      : Icons.star_rounded,
                                  color: isMastered
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFFFD700),
                                  size: 18,
                                ),
                                label: Text(
                                  isMastered
                                      ? 'LETTER MASTERED ✓'
                                      : 'MARK MASTERED (+10 XP) 🌟',
                                  style: GoogleFonts.outfit(
                                    color: isMastered
                                        ? const Color(0xFF10B981)
                                        : Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isMastered
                                        ? const Color(0xFF10B981)
                                        : Colors.white24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom mini letter dots indicator
                  Container(
                    height: 28,
                    alignment: Alignment.center,
                    child: Text(
                      'Swipe left / right or tap side arrows to navigate',
                      style: GoogleFonts.inter(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              // ─────────────────────────────────────────────────────────────
              // 2. PROMINENT SIDE NAVIGATION CONTROLS (LEFT & RIGHT)
              // ─────────────────────────────────────────────────────────────
              // Left Prev Button
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: InkWell(
                    onTap: hasPrev ? _goToPrevLetter : null,
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: hasPrev ? 1.0 : 0.2,
                      child: Container(
                        width: 44,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF131C2E).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Right Next Button
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: InkWell(
                    onTap: _goToNextLetter,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: hasNext
                              ? [const Color(0xFFFF9100), const Color(0xFFFF3D00)]
                              : [const Color(0xFF10B981), const Color(0xFF059669)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: (hasNext
                                    ? const Color(0xFFFF9100)
                                    : const Color(0xFF10B981))
                                .withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        hasNext
                            ? Icons.arrow_forward_ios_rounded
                            : Icons.check_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
