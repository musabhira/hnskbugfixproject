import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import '../pocket_fortress_defense_service.dart';

/// 📖 Essential Word Item Model
class EssentialWordModel {
  final String word;
  final String phonetic;
  final Color color;
  final String meaningMl;
  final String exampleSentence;

  const EssentialWordModel({
    required this.word,
    required this.phonetic,
    required this.color,
    required this.meaningMl,
    required this.exampleSentence,
  });
}

/// 🌟 Mode 1 (Word List Study) + Mode 2 (Spelling Test Exam)
/// Matching Screenshots 1 and 2
class PocketDay1EssentialSpellingPage extends StatefulWidget {
  final String? userId;
  final Function(int stepIndex)? onStepFinished;

  const PocketDay1EssentialSpellingPage({
    super.key,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    String? userId,
    Function(int stepIndex)? onStepFinished,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketDay1EssentialSpellingPage(
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<PocketDay1EssentialSpellingPage> createState() =>
      _PocketDay1EssentialSpellingPageState();
}

class _PocketDay1EssentialSpellingPageState
    extends State<PocketDay1EssentialSpellingPage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _spellingInputController = TextEditingController();
  final FocusNode _spellingFocusNode = FocusNode();

  // Mode: false = Study & Listen (Screenshot 2), true = Practice & Spell Exam (Screenshot 1)
  bool _isPracticeExamMode = false;

  // Words list matching Screenshot 2
  final List<EssentialWordModel> _words = const [
    EssentialWordModel(
      word: 'does',
      phonetic: '/dʌz/',
      color: Color(0xFF22C55E), // Green
      meaningMl: 'ചെയ്യുന്നു (Does)',
      exampleSentence: 'He does his work diligently.',
    ),
    EssentialWordModel(
      word: 'fast',
      phonetic: '/fɑːst/',
      color: Color(0xFFEF4444), // Crimson
      meaningMl: 'വേഗതയുള്ള (Fast)',
      exampleSentence: 'A cheetah runs very fast.',
    ),
    EssentialWordModel(
      word: 'first',
      phonetic: '/fɜːst/',
      color: Color(0xFF3B82F6), // Blue
      meaningMl: 'ഒന്നാമത് / ആദ്യം (First)',
      exampleSentence: 'She came first in the race.',
    ),
    EssentialWordModel(
      word: 'five',
      phonetic: '/faɪv/',
      color: Color(0xFF8B5CF6), // Purple
      meaningMl: 'അഞ്ച് (Five)',
      exampleSentence: 'I have five red apples.',
    ),
    EssentialWordModel(
      word: 'found',
      phonetic: '/faʊnd/',
      color: Color(0xFFF59E0B), // Amber
      meaningMl: 'കണ്ടെത്തി (Found)',
      exampleSentence: 'I found my lost keys.',
    ),
    EssentialWordModel(
      word: 'gave',
      phonetic: '/ɡeɪv/',
      color: Color(0xFFF97316), // Coral
      meaningMl: 'നൽകി (Gave)',
      exampleSentence: 'He gave me a good book.',
    ),
    EssentialWordModel(
      word: 'always',
      phonetic: '/ˈɔːl.weɪz/',
      color: Color(0xFF14B8A6), // Teal
      meaningMl: 'എപ്പോഴും (Always)',
      exampleSentence: 'Always speak the truth.',
    ),
    EssentialWordModel(
      word: 'before',
      phonetic: '/bɪˈfɔːr/',
      color: Color(0xFF6366F1), // Indigo
      meaningMl: 'മുമ്പ് (Before)',
      exampleSentence: 'Wash hands before eating.',
    ),
  ];

  // Active word highlighted in study mode
  int? _highlightedStudyIndex;

  // Practice Exam State
  int _examQuestionIndex = 0;
  int _timerSeconds = 20;
  Timer? _examTimer;
  int _scoreCount = 0;
  bool _isAnswerValidated = false;
  bool? _isAnswerCorrect;
  String? _validationFeedback;

  // Audio Playback Rate
  double _speechRate = 0.45;
  bool _isAutoPlayingAll = false;
  int _autoPlayIndex = 0;
  Timer? _autoPlayTimer;

  // Shake animation for incorrect answer
  late AnimationController _shakeAnimController;

  @override
  void initState() {
    super.initState();
    _initTts();

    _shakeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _speakWord(String text) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  void _onStudyWordTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _highlightedStudyIndex = index;
    });

    final word = _words[index];
    _speakWord(word.word);
  }

  void _cycleSpeed() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_speechRate <= 0.35) {
        _speechRate = 0.45;
      } else if (_speechRate <= 0.45) {
        _speechRate = 0.55;
      } else {
        _speechRate = 0.30;
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Audio Speed: ${_speechRate == 0.30 ? "0.75x" : (_speechRate == 0.45 ? "1.0x" : "1.25x")}',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        duration: const Duration(milliseconds: 700),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleAutoPlayAll() {
    HapticFeedback.mediumImpact();
    if (_isAutoPlayingAll) {
      _autoPlayTimer?.cancel();
      setState(() => _isAutoPlayingAll = false);
      return;
    }

    setState(() {
      _isAutoPlayingAll = true;
      _autoPlayIndex = 0;
    });

    _playNextInAutoSequence();
  }

  void _playNextInAutoSequence() {
    if (!_isAutoPlayingAll || !mounted) return;
    if (_autoPlayIndex >= _words.length) {
      setState(() => _isAutoPlayingAll = false);
      return;
    }

    final word = _words[_autoPlayIndex];
    setState(() => _highlightedStudyIndex = _autoPlayIndex);
    _speakWord(word.word);

    _autoPlayTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted && _isAutoPlayingAll) {
        setState(() => _autoPlayIndex++);
        _playNextInAutoSequence();
      }
    });
  }

  void _startPracticeExam() {
    HapticFeedback.mediumImpact();
    _autoPlayTimer?.cancel();
    _isAutoPlayingAll = false;

    setState(() {
      _isPracticeExamMode = true;
      _examQuestionIndex = 0;
      _scoreCount = 0;
      _isAnswerValidated = false;
      _isAnswerCorrect = null;
      _validationFeedback = null;
      _spellingInputController.clear();
      _timerSeconds = 20;
    });

    _startQuestionTimer();
    _speakCurrentExamWord();
  }

  void _startQuestionTimer() {
    _examTimer?.cancel();
    setState(() => _timerSeconds = 20);

    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timerSeconds > 0 && !_isAnswerValidated) {
        setState(() => _timerSeconds--);
      } else if (_timerSeconds <= 0 && !_isAnswerValidated) {
        timer.cancel();
        _submitSpelling(timedOut: true);
      }
    });
  }

  void _speakCurrentExamWord() {
    if (_examQuestionIndex < _words.length) {
      final currentWord = _words[_examQuestionIndex];
      _speakWord(currentWord.word);
    }
  }

  void _submitSpelling({bool timedOut = false}) {
    if (_isAnswerValidated) return;

    final targetWord = _words[_examQuestionIndex];
    final userInput = _spellingInputController.text.trim().toLowerCase();
    final isCorrect = !timedOut && userInput == targetWord.word.toLowerCase();

    _examTimer?.cancel();

    setState(() {
      _isAnswerValidated = true;
      _isAnswerCorrect = isCorrect;
      if (isCorrect) {
        _scoreCount++;
        _validationFeedback = 'Spot on! Correctly spelled: "${targetWord.word}"';
      } else {
        _validationFeedback = timedOut
            ? 'Time\'s up! The correct spelling is "${targetWord.word}"'
            : 'Close! Correct spelling: "${targetWord.word}" (${targetWord.phonetic})';
      }
    });

    if (isCorrect) {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
      _speakWord('Great! ${targetWord.word}');
    } else {
      HapticFeedback.heavyImpact();
      _shakeAnimController.forward(from: 0.0);
      _speakWord(targetWord.word);
    }
  }

  void _nextExamQuestion() {
    HapticFeedback.lightImpact();
    if (_examQuestionIndex + 1 < _words.length) {
      setState(() {
        _examQuestionIndex++;
        _isAnswerValidated = false;
        _isAnswerCorrect = null;
        _validationFeedback = null;
        _spellingInputController.clear();
      });
      _startQuestionTimer();
      _speakCurrentExamWord();
    } else {
      _finishPracticeExam();
    }
  }

  Future<void> _finishPracticeExam() async {
    final uid = widget.userId ?? Supabase.instance.client.auth.currentUser?.id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pocket_day_${uid ?? "guest"}_1_step_3_done', true);
    await PocketFortressDefenseService.recordTrainingPoints(30, uid);

    widget.onStepFinished?.call(3);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF6B8AFD), width: 2),
        ),
        title: Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Spelling Mastery Complete!',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
              'You successfully completed the Essential Words spelling challenge with $_scoreCount / ${_words.length} correct!',
              style: GoogleFonts.inter(color: Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6B8AFD)),
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '+30 Pocket Score Earned!',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
              backgroundColor: const Color(0xFF6B8AFD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(
              'CONTINUE TO STEP 4 ➔',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    _autoPlayTimer?.cancel();
    _shakeAnimController.dispose();
    _spellingInputController.dispose();
    _spellingFocusNode.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Peachy warm gradient background matching Screenshots 1 & 2
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFD1B3), // Warm peach top
              Color(0xFFFFE6D5), // Soft cream
              Color(0xFFFFF2E8), // Base
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              _buildTopBar(),

              // Main Body Content: Study Mode (Screenshot 2) or Practice Exam (Screenshot 1)
              Expanded(
                child: _isPracticeExamMode
                    ? _buildPracticeExamBody()
                    : _buildStudyListBody(),
              ),

              // Bottom Control Bar (Screenshot 2 only)
              if (!_isPracticeExamMode) _buildBottomStudyBar(),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Bar matching Screenshots 1 & 2
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button <
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              if (_isPracticeExamMode) {
                _examTimer?.cancel();
                setState(() => _isPracticeExamMode = false);
              } else {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 22),
          ),

          // Center Title
          Text(
            _isPracticeExamMode ? 'Essential Words 1' : 'Essential Words 2',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),

          // Right Progress Ring (Screenshot 1) or Options `...` (Screenshot 2)
          if (_isPracticeExamMode)
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6B8AFD), width: 2.2),
              ),
              child: Center(
                child: Text(
                  '$_timerSeconds',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF6B8AFD),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz_rounded,
                  color: Colors.white, size: 26),
            ),
        ],
      ),
    );
  }

  /// 📖 MODE 1: Study & Listening Word Cards (Screenshot 2)
  Widget _buildStudyListBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title: How to Spell Essential Words, Part 2
            Text(
              'How to Spell Essential\nWords, Part 2',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E293B),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 14),

            // Subtitle
            Text(
              'Here are some of the most important words 2nd graders should be able to spell.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF475569),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // List of Word Cards with speaker icons
            Column(
              children: List.generate(_words.length, (idx) {
                final item = _words[idx];
                final isHighlighted = _highlightedStudyIndex == idx;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GestureDetector(
                    onTap: () => _onStudyWordTapped(idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? item.color.withValues(alpha: 0.12)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isHighlighted
                              ? item.color
                              : const Color(0xFFE2E8F0),
                          width: isHighlighted ? 2.0 : 1.0,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Left Speaker Icon
                          Positioned(
                            left: 16,
                            child: Icon(
                              Icons.volume_up_rounded,
                              color: isHighlighted
                                  ? item.color
                                  : Colors.black26,
                              size: 22,
                            ),
                          ),

                          // Center Word text in colorful font matching Screenshot 2
                          Text(
                            item.word,
                            style: GoogleFonts.outfit(
                              color: item.color,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          ),

                          // Right Meaning preview if tapped
                          if (isHighlighted)
                            Positioned(
                              right: 14,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.meaningMl,
                                  style: GoogleFonts.inter(
                                    color: item.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Floating Action Bar matching Screenshot 2
  Widget _buildBottomStudyBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          // Audio listen button 👂 II
          GestureDetector(
            onTap: _toggleAutoPlayAll,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF7A93F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hearing_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 4),
                  Icon(
                    _isAutoPlayingAll
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Speed gauge button e.g. 1x
          GestureDetector(
            onTap: _cycleSpeed,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.speed_rounded,
                      color: Color(0xFF64748B), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _speechRate == 0.30
                        ? '0.75x'
                        : (_speechRate == 0.45 ? '1x' : '1.25x'),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Blue Practice Button ➔ Practice
          Expanded(
            child: GestureDetector(
              onTap: _startPracticeExam,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A93F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Practice  ${_words.length}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 MODE 2: Spelling Challenge Exam (Screenshot 1)
  Widget _buildPracticeExamBody() {
    final currentWord = _words[_examQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          // Central White Spelling Card matching Screenshot 1
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Ear Icon Button on left, "Spell:" in center
                Row(
                  children: [
                    // Ear Icon Button (tap to replay audio)
                    GestureDetector(
                      onTap: _speakCurrentExamWord,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEFF6FF),
                          border: Border.all(color: const Color(0xFF93C5FD)),
                        ),
                        child: const Icon(
                          Icons.hearing_rounded,
                          color: Color(0xFF3B82F6),
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // "Spell:" Label
                    Text(
                      'Spell:',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF1E293B),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Center Input Box with cursor matching Screenshot 1
                AnimatedBuilder(
                  animation: _shakeAnimController,
                  builder: (context, child) {
                    final offset =
                        math.sin(_shakeAnimController.value * math.pi * 5) * 8.0;
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: Center(
                    child: Container(
                      width: 220,
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _isAnswerCorrect == true
                              ? const Color(0xFF22C55E)
                              : (_isAnswerCorrect == false
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFFCBD5E1)),
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _spellingInputController,
                        focusNode: _spellingFocusNode,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: const Color(0xFF1E293B),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(top: 18),
                        ),
                        onSubmitted: (_) => _submitSpelling(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Meaning Hint pill
                Center(
                  child: Text(
                    'Meaning: ${currentWord.meaningMl}',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit / Next Button & Floating Instructor Avatar (Screenshot 1)
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Big Blue Submit Button matching Screenshot 1
              SizedBox(
                width: 200,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A93F5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _isAnswerValidated
                      ? _nextExamQuestion
                      : () => _submitSpelling(),
                  child: Text(
                    _isAnswerValidated
                        ? (_examQuestionIndex + 1 == _words.length
                            ? 'FINISH EXAM ➔'
                            : 'NEXT WORD ➔')
                        : 'Submit',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              // Floating Female Instructor Avatar on right matching Screenshot 1!
              Positioned(
                right: 20,
                top: -10,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/avatar_female.png'),
                      fit: BoxFit.cover,
                      // Fallback Network Image matching photo in Screenshot 1
                      onError: null,
                    ),
                  ),
                  child: const ClipOval(
                    child: Icon(
                      Icons.face_3_rounded,
                      color: Color(0xFF7A93F5),
                      size: 42,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Feedback Message Banner
          if (_validationFeedback != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isAnswerCorrect == true
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isAnswerCorrect == true
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isAnswerCorrect == true
                        ? Icons.check_circle_rounded
                        : Icons.info_rounded,
                    color: _isAnswerCorrect == true
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _validationFeedback!,
                      style: GoogleFonts.outfit(
                        color: _isAnswerCorrect == true
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
