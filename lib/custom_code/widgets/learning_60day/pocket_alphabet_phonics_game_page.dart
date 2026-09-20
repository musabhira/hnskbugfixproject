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
// 🎮 DEDICATED ALPHABET & PHONICS GAME SCREEN
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
  final ScrollController _chipScrollController = ScrollController();

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

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto speak initial letter after brief delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _speakCurrentLetter();
      });
    });
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
    _chipScrollController.dispose();
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

  void _selectIndex(int index) {
    if (index < 0 || index >= widget.phonicsList.length) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
    _flameGame.updateLetter(widget.phonicsList[index].letter);
    _speakCurrentLetter();

    // Auto-scroll chip strip
    if (_chipScrollController.hasClients) {
      final target = (index * 48.0) - 100.0;
      _chipScrollController.animateTo(
        target.clamp(0.0, _chipScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
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

    // If not last, advance to next letter automatically
    if (_currentIndex < widget.phonicsList.length - 1) {
      Future.delayed(const Duration(milliseconds: 400), () {
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
                  'ALPHABET & PHONICS MASTERED!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Outstanding job! You practiced authentic mouth placement and pronunciation for all ${widget.phonicsList.length} phonics sounds.',
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
                      'COMPLETE STEP ✓',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
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

    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      body: SafeArea(
        child: Column(
          children: [
            // ─────────────────────────────────────────────────────────────
            // 1. GAME TOP HUD BAR
            // ─────────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(_completedIndices.length >= totalCount),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    tooltip: 'Back to Missions',
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6D00),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'DAY ${widget.day} QUEST',
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Letter ${_currentIndex + 1} of $totalCount',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9100)),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Language Switcher Chip
                  PopupMenuButton<String>(
                    initialValue: _activeLanguage,
                    onSelected: (lang) => setState(() => _activeLanguage = lang),
                    color: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.translate_rounded, color: Color(0xFFFFD700), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _activeLanguage,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
                        ],
                      ),
                    ),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'Malayalam', child: Text('മലയാളം (Malayalam)', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'English', child: Text('English', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'Tamil', child: Text('தமிழ் (Tamil)', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'Telugu', child: Text('తెలుగు (Telugu)', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'Hindi', child: Text('हिन्दी (Hindi)', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'Kannada', child: Text('ಕನ್ನಡ (Kannada)', style: TextStyle(color: Colors.white))),
                    ],
                  ),
                ],
              ),
            ),

            // ─────────────────────────────────────────────────────────────
            // 2. FLAME 2D INTERACTIVE GAME CANVAS
            // ─────────────────────────────────────────────────────────────
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GameWidget(game: _flameGame),
                  Positioned(
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app_rounded, color: Color(0xFFFF9100), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Tap Orb to Trigger Fire Burst & Sound',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─────────────────────────────────────────────────────────────
            // 3. MAIN GAMIFIED CARD WITH PHONEME, WORDS & ARTICULATION
            // ─────────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isMastered
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFF9100).withValues(alpha: 0.4),
                          width: isMastered ? 2.0 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isMastered
                                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                : const Color(0xFFFF6D00).withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Letter Badge & Phoneme Chip
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF9100), Color(0xFFFF3D00)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6D00).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  item.letter,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'IPA PHONIC SOUND',
                                    style: GoogleFonts.inter(
                                      color: Colors.white54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF00E5FF)),
                                    ),
                                    child: Text(
                                      item.phoneme,
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF00E5FF),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Example Words Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('🎯', style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'EXAMPLE TARGET WORDS',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: item.exampleWord.split('/').map((w) {
                                    final trimmed = w.trim();
                                    return InkWell(
                                      onTap: () => _speakWordOnly(trimmed),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              trimmed,
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.volume_up_rounded,
                                              color: Color(0xFFFFD700),
                                              size: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Mouth & Articulation Guide (Malayalam/Selected Language)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B2805).withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('👄', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'MOUTH & VOCAL PLACEMENT GUIDE',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFFD54F),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.getPronunciationGuide(_activeLanguage),
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFFFF8E1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // 🔊 Big Gamified Audio Action Button
                          ScaleTransition(
                            scale: _isPlayingAudio ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _speakCurrentLetter,
                                icon: Icon(
                                  _isPlayingAudio ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                                  color: Colors.black,
                                  size: 22,
                                ),
                                label: Text(
                                  _isPlayingAudio ? 'SPEAKING SOUND...' : 'PLAY SOUND & PRONOUNCE 🔊',
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
                                  elevation: 6,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // 🗣️ Voice Practice Aloud Action
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: _markCurrentAsMastered,
                              icon: Icon(
                                isMastered ? Icons.check_circle_rounded : Icons.record_voice_over_rounded,
                                color: isMastered ? const Color(0xFF10B981) : const Color(0xFFFFD700),
                                size: 18,
                              ),
                              label: Text(
                                isMastered ? 'SOUND MASTERED ✓ (+10 XP)' : 'I PRACTICED THIS SOUND ALOUD 🗣️',
                                style: GoogleFonts.outfit(
                                  color: isMastered ? const Color(0xFF10B981) : Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isMastered ? const Color(0xFF10B981) : Colors.white24,
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
                  ],
                ),
              ),
            ),

            // ─────────────────────────────────────────────────────────────
            // 4. QUICK ALPHABET CHIP STRIP
            // ─────────────────────────────────────────────────────────────
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.separated(
                controller: _chipScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: totalCount,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final itm = widget.phonicsList[index];
                  final isCurrent = index == _currentIndex;
                  final isDone = _completedIndices.contains(index);

                  return InkWell(
                    onTap: () => _selectIndex(index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFFFF9100)
                            : (isDone ? const Color(0xFF10B981).withValues(alpha: 0.25) : const Color(0xFF1E293B)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFFFFD700)
                              : (isDone ? const Color(0xFF10B981) : Colors.white12),
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        itm.letter.split(' ').first,
                        style: GoogleFonts.outfit(
                          color: isCurrent ? Colors.black : (isDone ? const Color(0xFF10B981) : Colors.white),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ─────────────────────────────────────────────────────────────
            // 5. BOTTOM NAVIGATION BAR (PREV / NEXT / FINISH)
            // ─────────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  // Previous Letter Button
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _currentIndex > 0 ? () => _selectIndex(_currentIndex - 1) : null,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'PREV',
                          style: GoogleFonts.outfit(
                            color: _currentIndex > 0 ? Colors.white : Colors.white30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Next / Finish Button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentIndex < totalCount - 1) {
                            _selectIndex(_currentIndex + 1);
                          } else {
                            _showCompletionDialog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9100),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentIndex < totalCount - 1 ? 'NEXT LETTER' : 'FINISH GAME 🏆',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentIndex < totalCount - 1
                                  ? Icons.arrow_forward_rounded
                                  : Icons.emoji_events_rounded,
                              size: 18,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
