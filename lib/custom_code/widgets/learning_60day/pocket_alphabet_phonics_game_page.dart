import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pocket_mission_curriculum_1_18.dart';

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

  int _currentIndex = 0;
  bool _isPlayingAudio = false;
  final Set<int> _completedIndices = {};
  late String _activeLanguage;
  double _letterScale = 1.0;

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

  void _triggerLetterBounce() {
    setState(() => _letterScale = 1.15);
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _letterScale = 1.0);
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
      _triggerLetterBounce();
      await _tts.stop();
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.38);

      // User Audio Directive: Only speak the clean letter (e.g. "A"), NEVER pronounce slashes like "/a/" (slash a slash)
      final cleanLetter = item.letter.split(' ').first.replaceAll('/', '').trim();
      await _tts.speak(cleanLetter);
    } catch (_) {
      if (mounted) setState(() => _isPlayingAudio = false);
    }
  }

  Future<void> _speakWordOnly(String word) async {
    try {
      _triggerLetterBounce();
      await _tts.stop();
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42);
      final cleanWord = word.replaceAll('/', '').trim();
      await _tts.speak(cleanWord);
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
    _triggerLetterBounce();
    // User Audio Directive: Silent by default; do NOT auto-speak when advancing letters!
  }

  void _markCurrentAsMastered() {
    HapticFeedback.mediumImpact();
    setState(() {
      _completedIndices.add(_currentIndex);
    });
    _triggerLetterBounce();

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
      backgroundColor: const Color(0xFF0F172A),
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
              // 1. MINIMAL CASUAL GAME ARENA
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
                                      color: const Color(0xFFFFB300),
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
                                      Color(0xFFFFB300)),
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
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.translate_rounded,
                                    color: Color(0xFFFFB300), size: 13),
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
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Cute Circular Letter Badge (Tap to bounce & speak)
                            GestureDetector(
                              onTap: () {
                                _triggerLetterBounce();
                                _speakCurrentLetter();
                              },
                              child: AnimatedScale(
                                scale: _letterScale,
                                duration: const Duration(milliseconds: 140),
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFB300),
                                        Color(0xFFFF8F00),
                                        Color(0xFFE65100),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFB300)
                                            .withValues(alpha: 0.35),
                                        blurRadius: 28,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    item.letter,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: item.letter.length > 3 ? 32 : 44,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black38,
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // IPA Phoneme Typography (Clean & bold, zero clutter boxes)
                            Text(
                              item.phoneme,
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFFB300),
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Target Word Chips (Clean, subtle rounded pills)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: item.exampleWord.split('/').map((w) {
                                final trimmed = w.trim();
                                return InkWell(
                                  onTap: () => _speakWordOnly(trimmed),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          trimmed,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.volume_up_rounded,
                                          color: Color(0xFFFFB300),
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 18),

                            // Minimal Articulation Guide in Malayalam/Selected Language (No heavy box)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('👄', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      item.getPronunciationGuide(_activeLanguage),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 🔊 Cute Rounded Game Sound Button
                            ScaleTransition(
                              scale: _isPlayingAudio
                                  ? _pulseAnimation
                                  : const AlwaysStoppedAnimation(1.0),
                              child: ElevatedButton.icon(
                                onPressed: _speakCurrentLetter,
                                icon: Icon(
                                  _isPlayingAudio
                                      ? Icons.graphic_eq_rounded
                                      : Icons.volume_up_rounded,
                                  color: const Color(0xFF0F172A),
                                  size: 20,
                                ),
                                label: Text(
                                  _isPlayingAudio ? 'PLAYING...' : 'PLAY SOUND',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFB300),
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 14),
                                  elevation: 0,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 🌟 Minimal Mastered / XP Action
                            TextButton.icon(
                              onPressed: _markCurrentAsMastered,
                              icon: Icon(
                                isMastered
                                    ? Icons.check_circle_rounded
                                    : Icons.star_outline_rounded,
                                color: isMastered
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFFFB300),
                                size: 18,
                              ),
                              label: Text(
                                isMastered
                                    ? 'LETTER MASTERED ✓'
                                    : 'MARK MASTERED (+10 XP)',
                                style: GoogleFonts.outfit(
                                  color: isMastered
                                      ? const Color(0xFF10B981)
                                      : Colors.white60,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom swipe reminder
                  Container(
                    height: 28,
                    alignment: Alignment.center,
                    child: Text(
                      'Swipe left / right to change letter',
                      style: GoogleFonts.inter(
                        color: Colors.white24,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              // ─────────────────────────────────────────────────────────────
              // 2. SLEEK, UNOBTRUSIVE SIDE NAVIGATION CONTROLS (LEFT & RIGHT)
              // ─────────────────────────────────────────────────────────────
              // Left Prev Button
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: hasPrev
                      ? IconButton(
                          onPressed: _goToPrevLetter,
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white60,
                            size: 20,
                          ),
                          tooltip: 'Previous Letter',
                        )
                      : const SizedBox(width: 48),
                ),
              ),

              // Right Next Button
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: _goToNextLetter,
                    icon: Icon(
                      hasNext
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.check_rounded,
                      color: hasNext
                          ? const Color(0xFFFFB300)
                          : const Color(0xFF10B981),
                      size: 22,
                    ),
                    tooltip: hasNext ? 'Next Letter' : 'Complete',
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
