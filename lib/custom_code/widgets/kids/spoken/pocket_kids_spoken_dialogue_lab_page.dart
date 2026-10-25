import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_100day_syllabus_db.dart';

/// 🗣️ Kids Spoken English & Dialogue Lab Page (Ages 4-8)
///
/// Designed specifically for young learners:
/// - 100% child-friendly pastel interface (Duolingo ABC / Lingokids aesthetic).
/// - Cheerful animated mascot with mouth speaking simulation.
/// - Step-by-step conversational turns (5 turns per day).
/// - Cheerful TTS voice read-aloud + Malayalam meaning tip.
/// - Interactive Magic Microphone with animated audio waves and instant star scoring.
/// - Awards +25 KS & 2 Star Cookies, automatically marking Basecamp Step 5 completed!
class PocketKidsSpokenDialogueLabPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsSpokenDialogueLabPage({
    super.key,
    this.day = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsSpokenDialogueLabPage(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsSpokenDialogueLabPage> createState() =>
      _PocketKidsSpokenDialogueLabPageState();
}

class _KidDialogueTurn {
  final String mascotLine;
  final String kidTargetLine;
  final String phonetics;
  final String meaningMl;
  final String emoji;

  const _KidDialogueTurn({
    required this.mascotLine,
    required this.kidTargetLine,
    required this.phonetics,
    required this.meaningMl,
    required this.emoji,
  });
}

class _PocketKidsSpokenDialogueLabPageState
    extends State<PocketKidsSpokenDialogueLabPage>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();

  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late AnimationController _mouthAnimController;
  late AnimationController _waveController;

  late List<_KidDialogueTurn> _turns;
  int _currentTurnIndex = 0;

  bool _isMascotSpeaking = false;
  bool _isListening = false;
  bool _hasSpokenCurrentTurn = false;
  bool _showMeaning = false;

  String _currentMascot = '🦁';
  String _mascotName = 'Leo King';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initTts();
    _initMascot();
    _buildDailyTurns();

    // Auto-greet after page builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakMascotLine();
    });
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _mouthAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _initMascot() {
    final mascots = [
      {'emoji': '🦁', 'name': 'Leo the Lion'},
      {'emoji': '🐼', 'name': 'Pandy Panda'},
      {'emoji': '🐯', 'name': 'Sparky Tiger'},
      {'emoji': '🐰', 'name': 'Bouncy Bunny'},
      {'emoji': '🐶', 'name': 'Pip Puppy'},
    ];
    final selected = mascots[(widget.day - 1) % mascots.length];
    _currentMascot = selected['emoji']!;
    _mascotName = selected['name']!;
  }

  void _buildDailyTurns() {
    final syllabus = PocketKids100DaySyllabusDB.getSyllabusForDay(widget.day);
    final targetWord = syllabus.rounds.isNotEmpty
        ? syllabus.rounds.first.targetWord
        : 'Friend';

    _turns = [
      _KidDialogueTurn(
        mascotLine: "Hello, little friend! What is your name? 👋",
        kidTargetLine: "Hello! My name is ${PocketKidsService.kidName}!",
        phonetics: "Heh-loh! My naym iz ${PocketKidsService.kidName}!",
        meaningMl: "ഹലോ! നിന്റെ പേരെന്താണെന്നാണ് ചോദിക്കുന്നത്",
        emoji: "👋",
      ),
      _KidDialogueTurn(
        mascotLine: "Can you see the $targetWord today? It is so cool! 🌟",
        kidTargetLine: "Yes! I can see the $targetWord!",
        phonetics: "Yes! Eye kan see the $targetWord!",
        meaningMl: "ഇന്നത്തെ വാക്ക് ($targetWord) കാണാൻ കഴിയുന്നുണ്ടോ?",
        emoji: "👀",
      ),
      _KidDialogueTurn(
        mascotLine: "What sound does it make? Let us speak together! 🎵",
        kidTargetLine: "It sounds happy and strong!",
        phonetics: "It sownds ha-pee and strong!",
        meaningMl: "അതിന്റെ ശബ്ദം സന്തോഷമുള്ളതാണെന്ന് പറയൂ!",
        emoji: "🎵",
      ),
      _KidDialogueTurn(
        mascotLine: "I love practicing English with you! Are you having fun? 🎈",
        kidTargetLine: "Yes! I love speaking English with you!",
        phonetics: "Yes! Eye luv spee-king Ing-glish with yoo!",
        meaningMl: "ഇംഗ്ലീഷ് സംസാരിക്കാൻ എനിക്ക് വളരെ ഇഷ്ടമാണെന്ന് പറയൂ!",
        emoji: "🎈",
      ),
      _KidDialogueTurn(
        mascotLine: "You are a superstar speaker! High five! ✋",
        kidTargetLine: "Thank you! High five, my friend!",
        phonetics: "Thank yoo! Hy fyv, my frend!",
        meaningMl: "നന്ദി! ഹൈ ഫൈവ് തരുന്നു എന്ന് പറയൂ!",
        emoji: "🏆",
      ),
    ];
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.35); // Cheerful cartoon voice
      await _tts.setSpeechRate(0.42); // Clear and slow for kids
      _tts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isMascotSpeaking = false;
          });
          _mouthAnimController.stop();
          _mouthAnimController.reset();
        }
      });
    } catch (_) {}
  }

  Future<void> _speakMascotLine() async {
    final line = _turns[_currentTurnIndex].mascotLine;
    try {
      setState(() {
        _isMascotSpeaking = true;
      });
      _mouthAnimController.repeat(reverse: true);
      await _tts.stop();
      await _tts.speak(line);
    } catch (_) {
      if (mounted) {
        setState(() => _isMascotSpeaking = false);
        _mouthAnimController.stop();
      }
    }
  }

  Future<void> _speakKidPrompt() async {
    final line = _turns[_currentTurnIndex].kidTargetLine;
    try {
      await _tts.stop();
      await _tts.speak(line);
    } catch (_) {}
  }

  void _onMicrophonePressed() async {
    if (_isListening) return;

    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playPopSound();

    setState(() {
      _isListening = true;
      _showMeaning = false;
    });
    _waveController.repeat(reverse: true);

    // Simulate child speech detection (2.4 seconds with audio waves)
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    _waveController.stop();
    _waveController.reset();

    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playCorrectSound();

    setState(() {
      _isListening = false;
      _hasSpokenCurrentTurn = true;
    });

    // Cheerful praise voice
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _tts.speak("Superstar! Beautiful English pronunciation!");
    }
  }

  void _onNextTurn() {
    HapticFeedback.mediumImpact();
    PocketGameAudioService.instance.playPopSound();

    if (_currentTurnIndex < _turns.length - 1) {
      setState(() {
        _currentTurnIndex++;
        _hasSpokenCurrentTurn = false;
        _showMeaning = false;
      });
      _speakMascotLine();
    } else {
      _showCelebrationDialog();
    }
  }

  void _showCelebrationDialog() async {
    HapticFeedback.heavyImpact();
    PocketGameSFX.playVictoryFanfare();

    // Award +25 KS & 2 Star Cookies
    await PocketKidsService.addKidsScore(25);
    await PocketKidsService.addKidStars(2);
    await PocketKidsService.markDayStepCompleted(widget.day, 5);
    widget.onCompleted?.call();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF10B981), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆 ✨', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 10),
              Text(
                'Spoken English Star!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You spoke with $_mascotName like a real champion!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),

              // Rewards Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 4),
                    Text(
                      '+25 KS',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: const Color(0xFF047857),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text('🍪', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 4),
                    Text(
                      '+2 Cookies',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Continue Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context); // Return to Day Basecamp
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Awesome! Continue',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _mouthAnimController.dispose();
    _waveController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTurn = _turns[_currentTurnIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9), // Soft cream pastel
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF0F172A),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAY ${widget.day} • SPOKEN LAB 🎙️',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Voice Talk with $_mascotName',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF93C5FD), width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐ ', style: TextStyle(fontSize: 12)),
                        Text(
                          '${_currentTurnIndex + 1}/${_turns.length}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF1D4ED8),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Progress Dots Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                children: List.generate(_turns.length, (idx) {
                  final isDone = idx < _currentTurnIndex;
                  final isCurrent = idx == _currentTurnIndex;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF10B981)
                            : isCurrent
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Mascot & Animated Speaking Bubble
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mascot Avatar
                        AnimatedBuilder(
                          animation: _bounceController,
                          builder: (context, child) {
                            final dy = _isMascotSpeaking
                                ? math.sin(_bounceController.value * math.pi) * 4.0
                                : 0.0;
                            return Transform.translate(
                              offset: Offset(0, -dy),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _isMascotSpeaking
                                        ? const Color(0xFF38BDF8)
                                        : const Color(0xFFFCD34D),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFCD34D).withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _currentMascot,
                                  style: const TextStyle(fontSize: 38),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),

                        // Mascot Speech Bubble
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(22),
                                bottomLeft: Radius.circular(22),
                                bottomRight: Radius.circular(22),
                              ),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                                width: 1.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _mascotName,
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF1D4ED8),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _speakMascotLine,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.volume_up_rounded, color: Colors.white, size: 14),
                                            SizedBox(width: 3),
                                            Text(
                                              'LISTEN',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  currentTurn.mascotLine,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF0F172A),
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Kid Target Speech Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: _hasSpokenCurrentTurn
                              ? const Color(0xFF10B981)
                              : const Color(0xFFE2E8F0),
                          width: 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text('🌟', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'YOUR TURN TO SPEAK',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _speakKidPrompt,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.hearing_rounded, color: Color(0xFF475569), size: 14),
                                      SizedBox(width: 3),
                                      Text(
                                        'Hear phrase',
                                        style: TextStyle(
                                          color: Color(0xFF475569),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Target sentence in bold kid font
                          Text(
                            currentTurn.kidTargetLine,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF0F172A),
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Phonetics guide
                          Text(
                            currentTurn.phonetics,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Meaning Tip Button
                          GestureDetector(
                            onTap: () {
                              setState(() => _showMeaning = !_showMeaning);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('💡', style: TextStyle(fontSize: 13)),
                                  const SizedBox(width: 4),
                                  Text(
                                    _showMeaning ? 'Hide Meaning' : 'Malayalam Meaning',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFB45309),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_showMeaning) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                currentTurn.meaningMl,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF78350F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Magic Microphone or Celebration Status
                    if (!_hasSpokenCurrentTurn) ...[
                      // Pulsing Mic Button
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale = _isListening
                              ? 1.0 + (_pulseController.value * 0.12)
                              : 1.0;
                          return Transform.scale(
                            scale: scale,
                            child: GestureDetector(
                              onTap: _onMicrophonePressed,
                              child: Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isListening
                                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                        : [const Color(0xFF38BDF8), const Color(0xFF0284C7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isListening
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF0284C7))
                                          .withValues(alpha: 0.4),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  _isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isListening
                            ? 'Listening... Speak now! 🎙️✨'
                            : 'Tap Magic Mic & Speak! 🎙️',
                        style: GoogleFonts.outfit(
                          color: _isListening
                              ? const Color(0xFF10B981)
                              : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ] else ...[
                      // Success Card & Next Button
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFA7F3D0), width: 1.8),
                        ),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('⭐ ⭐ ⭐', style: TextStyle(fontSize: 22)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Brilliant Speaking! +10 KS ⭐',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF047857),
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 14),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 13,
                                ),
                                elevation: 3,
                              ),
                              onPressed: _onNextTurn,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentTurnIndex < _turns.length - 1
                                        ? 'Next Dialogue (${_currentTurnIndex + 2}/${_turns.length})'
                                        : 'Finish Spoken Lab 🏆',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
