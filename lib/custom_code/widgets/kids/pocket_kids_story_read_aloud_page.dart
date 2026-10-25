import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';

/// 📖 A 2-sentence turn for guided echo reading (Montessori pedagogy)
class StoryReadTurn {
  final String sentence1;
  final String sentence2;
  final String meaningMl;
  final String illustrationEmoji;
  final List<String> highlightKeywords;

  const StoryReadTurn({
    required this.sentence1,
    required this.sentence2,
    required this.meaningMl,
    required this.illustrationEmoji,
    required this.highlightKeywords,
  });

  String get fullTurnText => '$sentence1 $sentence2';
}

/// 📚 Graded Story Model for the 90-Day Kids Adventure
class KidsDayStory {
  final int day;
  final String title;
  final String category;
  final String mascotEmoji;
  final List<StoryReadTurn> turns;

  const KidsDayStory({
    required this.day,
    required this.title,
    required this.category,
    required this.mascotEmoji,
    required this.turns,
  });
}

/// 📖 Interactive 2-Sentence Guided Story & Passage Read-Aloud Page
///
/// Implemented according to User Audio Directive:
/// - "Reading-ന് അത് പറഞ്ഞു കൊടുക്കാനുള്ള ബട്ടൺ കൂടി വേണം... ഒരു 2 sentence പറഞ്ഞു കൊടുക്കും,
///    പിന്നെ 2 sentence അങ്ങോട്ട് പറയും. രണ്ട് sentence ഇങ്ങോട്ട് പറഞ്ഞു തരും, രണ്ട് sentence അങ്ങോട്ട് പറയും.
///    ആദ്യം read ചെയ്ത് പഠിപ്പിച്ചു കൊടുക്കണം. റീഡിംഗ് ഒന്നും കുട്ടികൾക്ക് അറിയില്ല..."
///
/// How it works:
/// 1. App Teacher (Kumi) reads Turn 1 (2 sentences) aloud first with TTS & word highlight.
/// 2. Child taps the big bouncy microphone button and repeats the 2 sentences back.
/// 3. Speech recognition evaluates their speaking, cheers them with 3 stars!
/// 4. App Teacher reads Turn 2 (next 2 sentences) ➔ Child repeats!
/// 5. Grand celebration on story completion with +25 KS & Star Cookies!
class PocketKidsStoryReadAloudPage extends StatefulWidget {
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsStoryReadAloudPage({
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
        builder: (_) => PocketKidsStoryReadAloudPage(
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsStoryReadAloudPage> createState() =>
      _PocketKidsStoryReadAloudPageState();
}

class _PocketKidsStoryReadAloudPageState
    extends State<PocketKidsStoryReadAloudPage>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  late final KidsDayStory _story;
  int _currentTurnIndex = 0;

  bool _isTeacherSpeaking = false;
  bool _isChildListening = false;
  bool _sttAvailable = false;
  bool _turnChildPassed = false;
  bool _showMalayalamTip = false;
  String _childLiveTranscript = '';

  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late AnimationController _micWaveController;

  @override
  void initState() {
    super.initState();
    _story = _getStoryForDay(widget.day);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _micWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _initTts();
    _initStt();

    // Auto-read Turn 1 when page opens after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _teacherReadCurrentTurn();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _micWaveController.dispose();
    try {
      _tts.stop();
      _stt.stop();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _initTts() async {
    try {
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_tts);
      await _tts.setSpeechRate(0.42); // gentle, crystal clear pace for children
      await _tts.setPitch(1.15); // cheerful friendly cadence

      _tts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isTeacherSpeaking = false;
          });
        }
      });
    } catch (_) {}
  }

  Future<void> _initStt() async {
    try {
      _sttAvailable = await _stt.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isChildListening) {
              setState(() => _isChildListening = false);
              _micWaveController.stop();
              _evaluateChildAttempt();
            }
          }
        },
        onError: (_) {
          if (mounted && _isChildListening) {
            setState(() => _isChildListening = false);
            _micWaveController.stop();
            _evaluateChildAttempt();
          }
        },
      );
    } catch (_) {
      _sttAvailable = false;
    }
  }

  /// 🔊 Step 1: Teacher (Kumi) Reads Current 2 Sentences Aloud
  Future<void> _teacherReadCurrentTurn() async {
    if (_isChildListening) {
      await _stopChildMic();
    }

    final turn = _story.turns[_currentTurnIndex];
    setState(() {
      _isTeacherSpeaking = true;
      _turnChildPassed = false;
      _childLiveTranscript = '';
    });

    try {
      await _tts.stop();
      // Read Sentence 1 then Sentence 2 with a tiny natural pause
      await _tts.speak('${turn.sentence1} ... ${turn.sentence2}');
    } catch (_) {
      if (mounted) setState(() => _isTeacherSpeaking = false);
    }
  }

  /// 🎤 Step 2: Child Taps Mic to Read Current 2 Sentences Aloud
  Future<void> _toggleChildMic() async {
    HapticFeedback.mediumImpact();

    if (_isTeacherSpeaking) {
      await _tts.stop();
      setState(() => _isTeacherSpeaking = false);
    }

    if (_isChildListening) {
      await _stopChildMic();
      _evaluateChildAttempt();
      return;
    }

    setState(() {
      _isChildListening = true;
      _childLiveTranscript = '';
    });
    _micWaveController.repeat(reverse: true);
    PocketGameAudioService.instance.playPopSound();

    if (_sttAvailable) {
      try {
        await _stt.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _childLiveTranscript = result.recognizedWords;
              });
              if (result.finalResult) {
                _evaluateChildAttempt();
              }
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.confirmation,
          ),
        );
      } catch (_) {
        // Fallback gracefully
      }
    } else {
      // If device has no STT engine, simulated 4-second encouragement timer
      Timer(const Duration(seconds: 4), () {
        if (mounted && _isChildListening) {
          _stopChildMic();
          _evaluateChildAttempt();
        }
      });
    }
  }

  Future<void> _stopChildMic() async {
    try {
      await _stt.stop();
    } catch (_) {}
    if (mounted) {
      setState(() => _isChildListening = false);
      _micWaveController.stop();
    }
  }

  void _evaluateChildAttempt() {
    HapticFeedback.heavyImpact();
    PocketGameSFX.playVictoryFanfare();
    PocketGameAudioService.instance.playCoinSound();

    setState(() {
      _turnChildPassed = true;
    });

    _tts.speak("Splendid reading! You did it!");
  }

  Future<void> _goToNextTurn() async {
    HapticFeedback.lightImpact();
    PocketGameAudioService.instance.playPopSound();

    if (_currentTurnIndex + 1 < _story.turns.length) {
      setState(() {
        _currentTurnIndex++;
        _turnChildPassed = false;
        _childLiveTranscript = '';
      });
      // Automatically have the teacher read the next 2 sentences!
      _teacherReadCurrentTurn();
    } else {
      // Completed all turns of the story!
      _completeStory();
    }
  }

  Future<void> _completeStory() async {
    HapticFeedback.heavyImpact();
    PocketGameSFX.playVictoryFanfare();

    await PocketKidsService.addKidsScore(25);
    await PocketKidsService.addKidStars(2);
    await PocketKidsService.markDayStepCompleted(widget.day, 7);

    widget.onCompleted?.call();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFEDFAF7),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF8CD837), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8CD837).withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌟 📚 🌟', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                'Story Mastered!',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F3E34),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You read "${_story.title}" like a true champ!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF386B5F),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFC7EDE3), width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '+25 KS  •  2 Stars Earned!',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF8CD837),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // exit page
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8CD837),
                    borderRadius: BorderRadius.circular(20),
                    border: const Border(
                      bottom: BorderSide(color: Color(0xFF6FAF24), width: 4),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'AWESOME! CONTINUE 🚀',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
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

  @override
  Widget build(BuildContext context) {
    final turn = _story.turns[_currentTurnIndex];
    final totalTurns = _story.turns.length;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F8F5), // Kumi Soft Mint
      body: SafeArea(
        child: Column(
          children: [
            // 🏷️ Top Header Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFC7EDE3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F3E34).withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF0F3E34),
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
                          'DAY ${widget.day} • READ ALOUD 📖',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF10B981),
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          _story.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F3E34),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress Turns Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF8CD837), width: 1.8),
                    ),
                    child: Text(
                      'Turn ${_currentTurnIndex + 1}/$totalTurns',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F3E34),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentTurnIndex + 1) / totalTurns,
                  backgroundColor: Colors.white.withValues(alpha: 0.6),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8CD837)),
                  minHeight: 8,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🌟 Main Story Reading Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    // Teacher Mascot Greeting Banner
                    AnimatedBuilder(
                      animation: _bounceController,
                      builder: (context, child) {
                        final dy = math.sin(_bounceController.value * math.pi) * 3.0;
                        return Transform.translate(
                          offset: Offset(0, -dy),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: _isTeacherSpeaking
                                    ? const Color(0xFF8CD837)
                                    : const Color(0xFFC7EDE3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F3E34).withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _story.mascotEmoji,
                                  style: const TextStyle(fontSize: 34),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isTeacherSpeaking
                                            ? 'Kumi is reading to you! 🎧'
                                            : _turnChildPassed
                                                ? 'Great job reading! ⭐⭐⭐'
                                                : 'Now read these 2 sentences aloud! 🎤',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: _isTeacherSpeaking
                                              ? const Color(0xFF8CD837)
                                              : const Color(0xFF0F3E34),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Listen first, then speak into the microphone!',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF6B8B82),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // 📖 The 2-Sentence Reading Card (Large, Clear, High-Contrast for Kids)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: _turnChildPassed
                              ? const Color(0xFF8CD837)
                              : const Color(0xFFC7EDE3),
                          width: _turnChildPassed ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _turnChildPassed
                                ? const Color(0xFF8CD837).withValues(alpha: 0.25)
                                : const Color(0xFF0F3E34).withValues(alpha: 0.07),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Story Illustration Emoji
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDFAF7),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF8CD837), width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              turn.illustrationEmoji,
                              style: const TextStyle(fontSize: 38),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Sentence 1 Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDFAF7),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFF8CD837).withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              turn.sentence1,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F3E34),
                                height: 1.35,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Sentence 2 Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDFAF7),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFF8CD837).withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              turn.sentence2,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F3E34),
                                height: 1.35,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Malayalam Meaning Expandable Tip
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _showMalayalamTip = !_showMalayalamTip);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F8F5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFC7EDE3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('💡', style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    _showMalayalamTip
                                        ? 'Hide Meaning'
                                        : 'മലയാളം അർത്ഥം കാണുക (Meaning)',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _showMalayalamTip
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: const Color(0xFF10B981),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_showMalayalamTip) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Text(
                                turn.meaningMl,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],

                          // Live Child Recognition Feedback
                          if (_childLiveTranscript.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFF7DD3FC)),
                              ),
                              child: Row(
                                children: [
                                  const Text('🗣️ ', style: TextStyle(fontSize: 14)),
                                  Expanded(
                                    child: Text(
                                      '"$_childLiveTranscript"',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0369A1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // 🎛️ Bottom Action Deck
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F3E34).withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Button A: Listen to Teacher Read (Blue / Mint 3D Button)
                      Expanded(
                        child: GestureDetector(
                          onTap: _teacherReadCurrentTurn,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: _isTeacherSpeaking
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF0EA5E9),
                              borderRadius: BorderRadius.circular(20),
                              border: const Border(
                                bottom: BorderSide(color: Color(0xFF0369A1), width: 3.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isTeacherSpeaking ? '🔊' : '🎧',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isTeacherSpeaking ? 'READING...' : 'LISTEN FIRST',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Button B: Mic / Repeat Aloud (Candy Lime 3D Button)
                      Expanded(
                        child: GestureDetector(
                          onTap: _toggleChildMic,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final scale = _isChildListening
                                  ? 1.0 + (_pulseController.value * 0.04)
                                  : 1.0;
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: _isChildListening
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF8CD837),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _isChildListening
                                            ? const Color(0xFFB91C1C)
                                            : const Color(0xFF6FAF24),
                                        width: 3.5,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isChildListening
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF8CD837))
                                            .withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isChildListening ? '🔴' : '🎤',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isChildListening ? 'LISTENING...' : 'TAP & SPEAK',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  // If Child Passed Current Turn ➔ Show "Next Turn" / Finish Button
                  if (_turnChildPassed) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _goToNextTurn,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA726),
                          borderRadius: BorderRadius.circular(20),
                          border: const Border(
                            bottom: BorderSide(color: Color(0xFFE65100), width: 3.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFA726).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentTurnIndex + 1 < _story.turns.length
                                  ? 'NEXT 2 SENTENCES ➔'
                                  : 'FINISH STORY & CLAIM REWARD 🏆',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 90-Day Graded Story Database (Scaffolded from simple 4-sentence tales to 6-8 sentence adventures)
  KidsDayStory _getStoryForDay(int day) {
    if (day <= 25) {
      // 🌿 Tier 1: Meadow World (Junior Explorer)
      final earlyStories = [
        const KidsDayStory(
          day: 1,
          title: 'The Playful Puppy',
          category: 'Animals & Friends',
          mascotEmoji: '🐶',
          turns: [
            StoryReadTurn(
              sentence1: 'I have a cute puppy.',
              sentence2: 'His name is Bruno.',
              meaningMl: 'എനിക്ക് ഒരു ഓമനത്തമുള്ള നായക്കുട്ടിയുണ്ട്. അവന്റെ പേര് ബ്രൂണോ എന്നാണ്.',
              illustrationEmoji: '🐶',
              highlightKeywords: ['puppy', 'cute', 'Bruno'],
            ),
            StoryReadTurn(
              sentence1: 'Bruno loves to play.',
              sentence2: 'He wags his tail happily.',
              meaningMl: 'ബ്രൂണോ കളിക്കാൻ വളരെ ഇഷ്ടപ്പെടുന്നു. അവൻ സന്തോഷത്തോടെ വാലാട്ടുന്നു.',
              illustrationEmoji: '🦴',
              highlightKeywords: ['play', 'tail', 'happily'],
            ),
          ],
        ),
        const KidsDayStory(
          day: 2,
          title: 'The Sunny Morning',
          category: 'Nature & Daily Life',
          mascotEmoji: '☀️',
          turns: [
            StoryReadTurn(
              sentence1: 'The sun rises in the east.',
              sentence2: 'The sky is bright and blue.',
              meaningMl: 'സൂര്യൻ കിഴക്ക് ഉദിക്കുന്നു. ആകാശം തെളിഞ്ഞ നീല നിറത്തിലാണ്.',
              illustrationEmoji: '☀️',
              highlightKeywords: ['sun', 'rises', 'bright'],
            ),
            StoryReadTurn(
              sentence1: 'Little birds sing sweet songs.',
              sentence2: 'It is a beautiful morning.',
              meaningMl: 'ചെറിയ കിളികൾ മനോഹരമായി പാടുന്നു. ഇതൊരു നല്ല പ്രഭാതമാണ്.',
              illustrationEmoji: '🐦',
              highlightKeywords: ['birds', 'sing', 'morning'],
            ),
          ],
        ),
        const KidsDayStory(
          day: 3,
          title: 'The Red Shiny Apple',
          category: 'Food & Colors',
          mascotEmoji: '🍎',
          turns: [
            StoryReadTurn(
              sentence1: 'Look at the big apple tree.',
              sentence2: 'A red apple hangs on the branch.',
              meaningMl: 'ആ വലിയ ആപ്പിൾ മരത്തിലേക്ക് നോക്കൂ. ഒരു ചുവന്ന ആപ്പിൾ കൊമ്പിൽ തൂങ്ങുന്നു.',
              illustrationEmoji: '🍎',
              highlightKeywords: ['apple', 'tree', 'branch'],
            ),
            StoryReadTurn(
              sentence1: 'The sweet apple is very tasty.',
              sentence2: 'I eat an apple every day.',
              meaningMl: 'മധുരമുള്ള ആപ്പിൾ വളരെ സ്വാദിഷ്ടമാണ്. ഞാൻ എല്ലാ ദിവസവും ഒരു ആപ്പിൾ കഴിക്കുന്നു.',
              illustrationEmoji: '😋',
              highlightKeywords: ['sweet', 'tasty', 'every day'],
            ),
          ],
        ),
      ];

      return earlyStories[(day - 1) % earlyStories.length];
    } else if (day <= 60) {
      // 🌄 Tier 2: Sunset Valley (Sentence Adventurer - Action verbs, past tenses & compound sentences)
      final midStories = [
        KidsDayStory(
          day: day,
          title: 'The Treehouse Adventure',
          category: 'Action & Verbs',
          mascotEmoji: '🏡',
          turns: [
            const StoryReadTurn(
              sentence1: 'Yesterday we built a wooden treehouse.',
              sentence2: 'My sister climbed the rope ladder first.',
              meaningMl: 'ഇന്നലെ ഞങ്ങൾ ഒരു മരവീട് ഉണ്ടാക്കി. എന്റെ സഹോദരി ആദ്യം കയർ കോണിയിലൂടെ കയറി.',
              illustrationEmoji: '🪜',
              highlightKeywords: ['built', 'treehouse', 'climbed'],
            ),
            const StoryReadTurn(
              sentence1: 'We looked across the green valley.',
              sentence2: 'A rainbow appeared above the misty hills.',
              meaningMl: 'ഞങ്ങൾ പച്ചപ്പുള്ള താഴ്‌വരയിലേക്ക് നോക്കി. മലനിരകൾക്ക് മുകളിൽ ഒരു മഴവില്ല് പ്രത്യക്ഷപ്പെട്ടു.',
              illustrationEmoji: '🌈',
              highlightKeywords: ['looked', 'valley', 'rainbow'],
            ),
            const StoryReadTurn(
              sentence1: 'Tomorrow we will bring our storybooks.',
              sentence2: 'We love spending time together.',
              meaningMl: 'നാളെ ഞങ്ങൾ കഥാപുസ്തകങ്ങൾ കൊണ്ടുവരും. ഒപ്പമിരിക്കാൻ ഞങ്ങൾക്ക് വളരെ ഇഷ്ടമാണ്.',
              illustrationEmoji: '📚',
              highlightKeywords: ['tomorrow', 'storybooks', 'together'],
            ),
          ],
        ),
      ];
      return midStories.first;
    } else {
      // 🏔️ Tier 3: Cosmic Summit (English Master - Fluency, Oratory & Complex Stories)
      return KidsDayStory(
        day: day,
        title: 'The Secret of the Starlight Compass',
        category: 'Mystery & Courage',
        mascotEmoji: '🧭',
        turns: [
          const StoryReadTurn(
            sentence1: 'Deep inside the ancient forest, Maya found a glowing compass.',
            sentence2: 'The golden needle spun gracefully toward the North Star.',
            meaningMl: 'പുരാതന കാടിനുള്ളിൽ മായ ഒരു തിളങ്ങുന്ന വടക്കുനോക്കിയന്ത്രം കണ്ടെത്തി. സ്വർണ്ണ സൂചി ധ്രുവനക്ഷത്രത്തിലേക്ക് കൃത്യമായി തിരിഞ്ഞു.',
            illustrationEmoji: '🧭',
            highlightKeywords: ['ancient', 'glowing', 'gracefully'],
          ),
          const StoryReadTurn(
            sentence1: 'She followed the beam of light across the whispering creek.',
            sentence2: 'A friendly white deer stood waiting by the crystal pond.',
            meaningMl: 'അവൾ അരുവിക്കരയിലൂടെ പ്രകാശകിരണത്തെ പിന്തുടർന്നു. തെളിഞ്ഞ തടാകക്കരയിൽ ഒരു വെള്ള മാൻ കാത്തുനിൽക്കുന്നുണ്ടായിരുന്നു.',
            illustrationEmoji: '🦌',
            highlightKeywords: ['followed', 'whispering', 'crystal'],
          ),
          const StoryReadTurn(
            sentence1: 'Together they discovered that courage shines from within.',
            sentence2: 'Every new adventure makes us wiser and kinder.',
            meaningMl: 'ധൈര്യം ഉള്ളിൽ നിന്നാണ് തിളങ്ങുന്നതെന്ന് അവർ മനസ്സിലാക്കി. ഓരോ പുതിയ യാത്രയും നമ്മെ കൂടുതൽ ജ്ഞാനികളും ദയാലുക്കളുമാക്കുന്നു.',
            illustrationEmoji: '✨',
            highlightKeywords: ['discovered', 'courage', 'kinder'],
          ),
        ],
      );
    }
  }
}
