import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_voice_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_kids_nature_scenery_background.dart';
import '../pocket_fortress_defense_service.dart';
import '../pocket_90day_vocab_curriculum.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';
import '../../kids/pocket_kids_curriculum_adapter.dart';
import '../../../services/pocket_kids_service.dart';

/// 📖 Essential Word Item Model
class EssentialWordModel {
  final String word;
  final String phonetic;
  final Color color;
  final String meaningMl; // Clean Malayalam meaning ONLY
  final String? nativeMeaning;
  final String exampleSentence;

  const EssentialWordModel({
    required this.word,
    required this.phonetic,
    required this.color,
    required this.meaningMl,
    this.nativeMeaning,
    required this.exampleSentence,
  });

  String get meaningText {
    if (PocketLanguageService.isEnglish) {
      return '';
    }
    if (nativeMeaning != null && nativeMeaning!.isNotEmpty) {
      return nativeMeaning!;
    }
    return PocketLanguageService.isMalayalam ? meaningMl : '';
  }
}

/// 🔤 Interactive Letter Tile for Gamified Spelling Board
class LetterTileItem {
  final String id;
  final String letter;
  final Color color;
  bool isUsed;

  LetterTileItem({
    required this.id,
    required this.letter,
    required this.color,
    this.isUsed = false,
  });
}

/// 🌟 Step 3: Essential Words & Gamified Spelling Challenge Game
/// Features:
/// 1. Living Animated Scenery Background (from Pocket Kids Universe) with living clouds, trees & sunlight.
/// 2. Mode 1 (Study & Pronunciation List): Sleek frosted glass cards with animated TTS voice read-aloud,
///    Malayalam meanings, auto-loop toggle (`👂 II`), and speed gauge (0.75x, 1x, 1.25x).
/// 3. Mode 2 (Gamified Spelling Challenge Exam):
///    - NO SPOILERS: Target English spelling is 100% hidden; only audio pronunciation & clean Malayalam clue shown.
///    - Interactive Letter Slot Boxes that fill dynamically with scale bounce animations.
///    - Scrambled Letter Tile Bank with vibrant candy-colored tiles and distractor letters.
///    - Dedicated arcade sound effects (tile pop, correct snap chime, error buzz, victory fanfare).
///    - Interactive controls: Audio Replay 👂, Backspace ⌫, Shuffle 🔄, Clear 🗑️.
///    - Score ring, floating avatar mascot, and XP reward animations.
class PocketEssentialSpellingPage extends StatefulWidget {
  final int day;
  final String? userId;
  final Function(int stepIndex)? onStepFinished;
  final bool isKidsMode;

  const PocketEssentialSpellingPage({
    super.key,
    this.day = 1,
    this.userId,
    this.onStepFinished,
    this.isKidsMode = false,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    String? userId,
    Function(int stepIndex)? onStepFinished,
    bool isKidsMode = false,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketEssentialSpellingPage(
          day: day,
          userId: userId,
          onStepFinished: onStepFinished,
          isKidsMode: isKidsMode,
        ),
      ),
    );
  }

  @override
  State<PocketEssentialSpellingPage> createState() =>
      _PocketEssentialSpellingPageState();
}

/// Backward compatibility alias for Day 1
typedef PocketDay1EssentialSpellingPage = PocketEssentialSpellingPage;

class _PocketEssentialSpellingPageState
    extends State<PocketEssentialSpellingPage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();

  // Mode: false = Study & Listen Mode, true = Gamified Spelling Exam Mode
  bool _isPracticeExamMode = false;

  // Dynamic words list for the current day
  late final List<EssentialWordModel> _words;

  // 8 High-Utility Core Words for Day 1
  // Notice: meaningMl contains ONLY clean Malayalam so the exam NEVER leaks the answer!
  static const List<EssentialWordModel> _day1DefaultWords = [
    EssentialWordModel(
      word: 'does',
      phonetic: '/dʌz/',
      color: Color(0xFF10B981), // Emerald
      meaningMl: 'ചെയ്യുന്നു',
      exampleSentence: 'He does his work diligently.',
    ),
    EssentialWordModel(
      word: 'fast',
      phonetic: '/fɑːst/',
      color: Color(0xFFEF4444), // Crimson
      meaningMl: 'വേഗതയുള്ള',
      exampleSentence: 'A cheetah runs very fast.',
    ),
    EssentialWordModel(
      word: 'first',
      phonetic: '/fɜːst/',
      color: Color(0xFF38BDF8), // Sky Blue
      meaningMl: 'ആദ്യം / ഒന്നാമത്',
      exampleSentence: 'She came first in the race.',
    ),
    EssentialWordModel(
      word: 'five',
      phonetic: '/faɪv/',
      color: Color(0xFFA855F7), // Purple
      meaningMl: 'അഞ്ച്',
      exampleSentence: 'I have five red apples.',
    ),
    EssentialWordModel(
      word: 'found',
      phonetic: '/faʊnd/',
      color: Color(0xFFF59E0B), // Amber
      meaningMl: 'കണ്ടെത്തി',
      exampleSentence: 'I found my lost keys.',
    ),
    EssentialWordModel(
      word: 'gave',
      phonetic: '/ɡeɪv/',
      color: Color(0xFFF97316), // Coral Orange
      meaningMl: 'നൽകി',
      exampleSentence: 'He gave me a good book.',
    ),
    EssentialWordModel(
      word: 'always',
      phonetic: '/ˈɔːl.weɪz/',
      color: Color(0xFF06B6D4), // Cyan
      meaningMl: 'എപ്പോഴും',
      exampleSentence: 'Always speak the truth.',
    ),
    EssentialWordModel(
      word: 'before',
      phonetic: '/bɪˈfɔːr/',
      color: Color(0xFF6366F1), // Indigo
      meaningMl: 'മുമ്പ്',
      exampleSentence: 'Wash hands before eating.',
    ),
  ];

  // Active word highlighted in study mode
  int? _highlightedStudyIndex;

  // Audio Playback Rate & Auto-play loop
  double _speechRate = 0.45;
  bool _isAutoPlayingAll = false;
  int _autoPlayIndex = 0;
  Timer? _autoPlayTimer;

  // =========================================================================
  // 🎮 GAMIFIED SPELLING EXAM STATE
  // =========================================================================
  int _examQuestionIndex = 0;
  int _timerSeconds = 25;
  Timer? _examTimer;
  int _scoreCount = 0;
  bool _isAnswerValidated = false;
  bool? _isAnswerCorrect;
  String? _validationFeedback;

  // Letter slot boxes for the target word (e.g. 4 slots for 'd-o-e-s')
  List<LetterTileItem?> _slots = [];

  // Scrambled letter bank tiles available to tap
  List<LetterTileItem> _letterBank = [];

  // Shake animation controller for incorrect answers
  late AnimationController _shakeAnimController;

  static const List<Color> _candyColors = [
    Color(0xFF38BDF8), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFA855F7), // Purple
    Color(0xFF3B82F6), // Blue
    Color(0xFFF97316), // Coral
  ];

  @override
  void initState() {
    super.initState();
    _initTts();

    // Dynamically populate words for widget.day with 0 duplicates!
    if (widget.isKidsMode) {
      _words = PocketKidsCurriculumAdapter.getKidsSpellingWordsForDay(widget.day);
    } else if (widget.day == 1) {
      _words = _day1DefaultWords;
    } else {
      final vocabItems = Pocket90DayVocabCurriculum.getVocabForDay(widget.day);
      final List<EssentialWordModel> loadedWords = [];
      const palette = [
        Color(0xFF10B981), // Emerald
        Color(0xFFEF4444), // Crimson
        Color(0xFF38BDF8), // Sky Blue
        Color(0xFFA855F7), // Purple
        Color(0xFFF59E0B), // Amber
        Color(0xFFF97316), // Coral Orange
        Color(0xFF06B6D4), // Cyan
        Color(0xFF6366F1), // Indigo
      ];
      for (int i = 0; i < vocabItems.length && loadedWords.length < 8; i++) {
        final item = vocabItems[i];
        final cleanWord = item.word.trim().toLowerCase();
        if (cleanWord.length < 3) continue; // Filter short words
        final nativeMeaning = item.getMeaning(PocketLanguageService.currentLanguage);
        loadedWords.add(EssentialWordModel(
          word: cleanWord,
          phonetic: item.phonetic,
          color: palette[loadedWords.length % palette.length],
          meaningMl: item.malayalamMeaning,
          nativeMeaning: nativeMeaning,
          exampleSentence: item.exampleSentence,
        ));
      }
      _words = loadedWords.isNotEmpty ? loadedWords : _day1DefaultWords;
    }

    _shakeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("en-IN");
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(1.05);
      await PocketVoiceService.instance.configureOptimalFemaleVoice(_flutterTts);
    } catch (_) {}
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _examTimer?.cancel();
    _shakeAnimController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // =========================================================================
  // 🔊 TTS AUDIO PRONUNCIATION
  // =========================================================================

  Future<void> _speakWord(String text) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  void _onStudyWordTapped(int index) {
    PocketGameSfx.instance.playTilePop();
    setState(() {
      _highlightedStudyIndex = index;
    });
    _speakWord(_words[index].word);
  }

  void _cycleSpeed() {
    PocketGameSfx.instance.playClick();
    setState(() {
      if (_speechRate == 0.45) {
        _speechRate = 0.35; // Slower
      } else if (_speechRate == 0.35) {
        _speechRate = 0.55; // Faster
      } else {
        _speechRate = 0.45; // Normal
      }
    });
    _flutterTts.setSpeechRate(_speechRate);
  }

  void _toggleAutoPlayAll() {
    PocketGameSfx.instance.playClick();
    if (_isAutoPlayingAll) {
      _stopAutoPlay();
    } else {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    setState(() {
      _isAutoPlayingAll = true;
      _autoPlayIndex = 0;
    });
    _playNextInSequence();
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _flutterTts.stop();
    setState(() {
      _isAutoPlayingAll = false;
    });
  }

  void _playNextInSequence() {
    if (!_isAutoPlayingAll) return;
    if (_autoPlayIndex >= _words.length) {
      _stopAutoPlay();
      return;
    }

    final current = _words[_autoPlayIndex];
    setState(() {
      _highlightedStudyIndex = _autoPlayIndex;
    });

    _speakWord(current.word);

    _autoPlayTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted || !_isAutoPlayingAll) return;
      _autoPlayIndex++;
      _playNextInSequence();
    });
  }

  // =========================================================================
  // 🎮 GAMIFIED SPELLING EXAM LOGIC
  // =========================================================================

  void _startPracticeExam() {
    _stopAutoPlay();
    PocketGameSfx.instance.playClick();

    setState(() {
      _isPracticeExamMode = true;
      _examQuestionIndex = 0;
      _scoreCount = 0;
      _isAnswerValidated = false;
      _isAnswerCorrect = null;
      _validationFeedback = null;
    });

    _loadExamQuestion(0);
  }

  void _loadExamQuestion(int index) {
    if (index >= _words.length) {
      _showExamCompletionDialog();
      return;
    }

    final targetWord = _words[index].word.toLowerCase();
    final letterChars = targetWord.split('');

    // Add 2 distractor letters (chosen randomly from a pool, not in the target word)
    const distractorPool = ['a', 'b', 'c', 'd', 'e', 'g', 'h', 'k', 'l', 'm', 'n', 'p', 'r', 's', 't', 'w', 'y'];
    final rng = math.Random();
    final distractorPoolFiltered = distractorPool.where((c) => !letterChars.contains(c)).toList();
    distractorPoolFiltered.shuffle(rng);

    final allLetters = <String>[...letterChars];
    if (distractorPoolFiltered.length >= 2) {
      allLetters.add(distractorPoolFiltered[0]);
      allLetters.add(distractorPoolFiltered[1]);
    } else {
      allLetters.add('z');
    }

    allLetters.shuffle(rng);

    // Build letter bank items with distinct candy colors
    final bank = <LetterTileItem>[];
    for (int i = 0; i < allLetters.length; i++) {
      bank.add(LetterTileItem(
        id: 'q${index}_tile_${i}_${allLetters[i]}',
        letter: allLetters[i].toUpperCase(),
        color: _candyColors[i % _candyColors.length],
        isUsed: false,
      ));
    }

    setState(() {
      _examQuestionIndex = index;
      _slots = List<LetterTileItem?>.filled(targetWord.length, null);
      _letterBank = bank;
      _isAnswerValidated = false;
      _isAnswerCorrect = null;
      _validationFeedback = null;
      _timerSeconds = 25;
    });

    _startQuestionTimer();

    // Speak audio pronunciation automatically after short delay
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted && _isPracticeExamMode) {
        _speakWord(_words[index].word);
      }
    });
  }

  void _startQuestionTimer() {
    _examTimer?.cancel();
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
        if (!_isAnswerValidated) {
          _submitSpelling();
        }
      }
    });
  }

  void _speakCurrentExamWord() {
    PocketGameSfx.instance.playClick();
    _speakWord(_words[_examQuestionIndex].word);
  }

  /// Tapping a letter tile from the bank puts it into the first empty slot
  void _onBankTileTapped(LetterTileItem tile) {
    if (_isAnswerValidated && _isAnswerCorrect == true) return;
    if (tile.isUsed) return;

    final firstEmptyIdx = _slots.indexOf(null);
    if (firstEmptyIdx == -1) return; // All slots full

    PocketGameSfx.instance.playSnapCorrect();

    setState(() {
      tile.isUsed = true;
      _slots[firstEmptyIdx] = tile;
    });

    // Auto-check if all slots filled
    if (!_slots.contains(null)) {
      _submitSpelling();
    }
  }

  /// Tapping a filled slot removes the letter back to the bank
  void _onSlotTapped(int slotIndex) {
    if (_isAnswerValidated && _isAnswerCorrect == true) return;
    final tile = _slots[slotIndex];
    if (tile == null) return;

    PocketGameSfx.instance.playTilePop();

    setState(() {
      tile.isUsed = false;
      _slots[slotIndex] = null;
      _isAnswerValidated = false;
      _isAnswerCorrect = null;
      _validationFeedback = null;
    });
  }

  /// Backspace button removes the last filled letter
  void _onBackspacePressed() {
    if (_isAnswerValidated && _isAnswerCorrect == true) return;

    int lastFilledIdx = -1;
    for (int i = _slots.length - 1; i >= 0; i--) {
      if (_slots[i] != null) {
        lastFilledIdx = i;
        break;
      }
    }

    if (lastFilledIdx != -1) {
      _onSlotTapped(lastFilledIdx);
    }
  }

  /// Shuffle remaining unused letter bank tiles
  void _shuffleLetterBank() {
    PocketGameSfx.instance.playClick();
    setState(() {
      _letterBank.shuffle(math.Random());
    });
  }

  /// Clear all slots
  void _clearAllSlots() {
    PocketGameSfx.instance.playTilePop();
    setState(() {
      for (final tile in _letterBank) {
        tile.isUsed = false;
      }
      _slots = List<LetterTileItem?>.filled(_slots.length, null);
      _isAnswerValidated = false;
      _isAnswerCorrect = null;
      _validationFeedback = null;
    });
  }

  void _submitSpelling() {
    if (_isAnswerValidated && _isAnswerCorrect == true) {
      _nextExamQuestion();
      return;
    }

    final targetWord = _words[_examQuestionIndex].word.toLowerCase();
    final spelled = _slots.map((t) => t?.letter.toLowerCase() ?? '').join('');

    if (spelled.length < targetWord.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Fill all letter boxes to complete the spelling!',
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    if (spelled == targetWord) {
      // ✅ CORRECT SPELLING!
      PocketGameSfx.instance.playVictory();
      _examTimer?.cancel();

      setState(() {
        _isAnswerValidated = true;
        _isAnswerCorrect = true;
        _scoreCount += 20;
        _validationFeedback = '🌟 Brilliant! "${_words[_examQuestionIndex].word.toUpperCase()}" is correct (+20 XP)';
      });

      _speakWord("${_words[_examQuestionIndex].word}! Excellent!");
    } else {
      // ❌ WRONG SPELLING
      PocketGameSfx.instance.playErrorBuzz();

      setState(() {
        _isAnswerValidated = true;
        _isAnswerCorrect = false;
        _validationFeedback = '❌ Not quite. Tap slots to change or tap 👂 to listen again.';
      });

      _shakeAnimController.forward(from: 0.0);
    }
  }

  void _nextExamQuestion() {
    PocketGameSfx.instance.playClick();
    if (_examQuestionIndex + 1 < _words.length) {
      _loadExamQuestion(_examQuestionIndex + 1);
    } else {
      _showExamCompletionDialog();
    }
  }

  bool _isStep3Completed = false;

  Future<void> _showExamCompletionDialog() async {
    _examTimer?.cancel();
    _isStep3Completed = true;

    if (widget.isKidsMode) {
      await PocketKidsService.markDayStepCompleted(widget.day, 3);
    } else {
      final uid = widget.userId ?? Supabase.instance.client.auth.currentUser?.id;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('pocket_day_${uid ?? "guest"}_${widget.day}_step_3_done', true);
        if (uid != null && uid.isNotEmpty) {
          await prefs.setBool('pocket_day_${uid}_${widget.day}_step_3_done', true);
        }
        await prefs.setBool('pocket_day_guest_${widget.day}_step_3_done', true);
      } catch (_) {}

      try {
        await PocketFortressDefenseService.recordTrainingPoints(30, uid);
      } catch (_) {}
    }

    widget.onStepFinished?.call(3);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Color(0xFF38BDF8), width: 2),
        ),
        title: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.isKidsMode
                    ? 'Day ${widget.day} Kids Spelling Master!'
                    : 'Day ${widget.day} Spelling Mastery Complete!',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
              widget.isKidsMode
                  ? 'Fantastic work! You spelled all ${_words.length} kids words with flying colors & perfect sounds!'
                  : 'Superb work! You listened to and mastered all ${_words.length} essential core words with perfect spelling.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD700)),
              ),
              child: Row(
                children: [
                  Text(widget.isKidsMode ? '⭐' : '🪙', style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isKidsMode ? 'Total Score: $_scoreCount KS' : 'Total Score: $_scoreCount XP',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.isKidsMode
                            ? '+15 Kids Score (KS) & 1 Star ⭐'
                            : '+30 Training Points Earned!',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            onPressed: () {
              widget.onStepFinished?.call(3);
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: Text(
              widget.isKidsMode ? 'AWESOME! CONTINUE ➔' : 'CONTINUE TO STEP 4 ➔',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🎨 BUILD UI
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (_isStep3Completed) {
          widget.onStepFinished?.call(3);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // 🌲 1. Living Nature Cartoon Open-World Scenery Background (Pocket Kids Universe)
          // User Audio Directive: "ബാക്ക്ഗ്രൗണ്ടിൽ നമ്മുടെ കിഡ്സിന്റെ ചാറ്റിന്റെ ബാക്ക്ഗ്രൗണ്ടിൽ ഉള്ള ബാക്ക്ഗ്രൗണ്ട്..."
          const Positioned.fill(
            child: PocketKidsNatureSceneryBackground(
              showSun: true,
              showTrees: true,
              hillHeightFraction: 0.32,
              glassOverlayOpacity: 0.22,
            ),
          ),

          // 2. Main Gameplay Surface
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                _buildTopAppBar(),

                // Body: Mode 1 (Study List) OR Mode 2 (Gamified Spelling Exam)
                Expanded(
                  child: _isPracticeExamMode
                      ? _buildGamifiedSpellingExamBody()
                      : _buildGamifiedStudyListBody(),
                ),

                // Bottom Action Bar in Study Mode
                if (!_isPracticeExamMode) _buildBottomStudyBar(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  /// Top App Bar with Navigation, Title, and Timer/Stats
  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            onPressed: () {
              PocketGameSfx.instance.playClick();
              if (_isPracticeExamMode) {
                setState(() => _isPracticeExamMode = false);
              } else {
                Navigator.pop(context);
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.35),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
            ),
          ),

          // Center Gamified Title & Badge
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _isPracticeExamMode
                      ? 'DAY ${widget.day} • STEP 3: SPELLING EXAM 🎮'
                      : 'DAY ${widget.day} • STEP 3: ESSENTIAL WORDS & SPELLING 👂',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isPracticeExamMode
                    ? 'Word ${_examQuestionIndex + 1} of ${_words.length}'
                    : 'Listen & Learn (${_words.length} Words)',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          // Right Timer Ring or Score
          if (_isPracticeExamMode)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                border: Border.all(color: const Color(0xFF38BDF8), width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$_timerSeconds',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF38BDF8),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _startPracticeExam,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Color(0xFF10B981), size: 24),
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // 📖 MODE 1: STUDY & LISTENING WORD CARDS (GAMIFIED STYLE)
  // =========================================================================

  Widget _buildGamifiedStudyListBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
      child: Column(
        children: [
          // Banner Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E293B).withValues(alpha: 0.88),
                  const Color(0xFF0F172A).withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌟 ', style: TextStyle(fontSize: 20)),
                    Text(
                      'Essential Spoken Words',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  PocketLanguageService.localize(
                    en: 'Tap any card to hear the native pronunciation & explore its usage.',
                    ml: 'Tap any card to hear the native pronunciation & view Malayalam meaning.',
                    hi: 'उच्चारण सुनने और हिंदी अर्थ देखने के लिए किसी भी कार्ड पर टैप करें।',
                    ta: 'உச்சரிப்பைக் கேட்கவும் தமிழ் அர்த்தத்தைப் பார்க்கவும் அட்டையைத் தட்டவும்.',
                    te: 'ఉచ్చారణ వినడానికి మరియు అర్థం చూడటానికి ఏదైనా కార్డ్‌ని నొక్కండి.',
                    kn: 'ಉಚ್ಚಾರಣೆಯನ್ನು ಕೇಳಲು ಮತ್ತು ಅರ್ಥವನ್ನು ನೋಡಲು ಯಾವುದೇ ಕಾರ್ಡ್ ಅನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ.',
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List of Gamified Word Cards
          ...List.generate(_words.length, (idx) {
            final item = _words[idx];
            final isHighlighted = _highlightedStudyIndex == idx;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _onStudyWordTapped(idx),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isHighlighted
                          ? [
                              item.color.withValues(alpha: 0.35),
                              const Color(0xFF1E293B).withValues(alpha: 0.92),
                            ]
                          : [
                              const Color(0xFF1E293B).withValues(alpha: 0.85),
                              const Color(0xFF0F172A).withValues(alpha: 0.85),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isHighlighted ? item.color : Colors.white12,
                      width: isHighlighted ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isHighlighted
                            ? item.color.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.25),
                        blurRadius: isHighlighted ? 14 : 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Audio Speaker Button
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: item.color.withValues(alpha: 0.2),
                          border: Border.all(color: item.color.withValues(alpha: 0.5)),
                        ),
                        child: Icon(
                          Icons.volume_up_rounded,
                          color: isHighlighted ? Colors.white : item.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Word + Phonetic + Malayalam Meaning
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.word,
                                  style: GoogleFonts.outfit(
                                    color: item.color,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.phonetic,
                                  style: GoogleFonts.inter(
                                    color: Colors.white54,
                                    fontSize: 12.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Meaning badge (dynamically resolved)
                            if (item.meaningText.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.meaningText,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Right Arrow Indicator
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isHighlighted ? item.color : Colors.white24,
                        size: 26,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Bottom Floating Action Bar in Study Mode
  Widget _buildBottomStudyBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Audio loop button 👂 Auto Play
          GestureDetector(
            onTap: _toggleAutoPlayAll,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.hearing_rounded, color: Colors.black, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    _isAutoPlayingAll ? 'PAUSE' : 'LISTEN ALL',
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Speed button
          GestureDetector(
            onTap: _cycleSpeed,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E293B),
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Text(
                  '${_speechRate == 0.35 ? '0.75' : (_speechRate == 0.45 ? '1.0' : '1.25')}x',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Start Practice Exam Button
          Expanded(
            child: GestureDetector(
              onTap: _startPracticeExam,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.videogame_asset_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'START EXAM 🎮',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
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

  // =========================================================================
  // 🎮 MODE 2: GAMIFIED SPELLING EXAM BODY (NO SPOILERS + LETTER TILES)
  // =========================================================================

  Widget _buildGamifiedSpellingExamBody() {
    final currentWord = _words[_examQuestionIndex];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
      child: Column(
        children: [
          // 1. Central Challenge Card (Frosted Glass UI)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1E293B).withValues(alpha: 0.92),
                  const Color(0xFF0F172A).withValues(alpha: 0.96),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _isAnswerCorrect == true
                    ? const Color(0xFF10B981)
                    : (_isAnswerCorrect == false
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Audio Replay Ear Button + Instruction
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Big Audio Replay Button
                    GestureDetector(
                      onTap: _speakCurrentExamWord,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF38BDF8).withValues(alpha: 0.45),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.hearing_rounded, color: Colors.black, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              PocketLanguageService.localize(
                                en: 'LISTEN 👂',
                                ml: 'കേൾക്കുക 👂',
                                hi: 'सुनें 👂',
                                ta: 'கேட்கவும் 👂',
                                te: 'వినండి 👂',
                                kn: 'ಕೇಳಿ 👂',
                              ),
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Clue (Dynamically localized, clean phonetic for English)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎯 ', style: TextStyle(fontSize: 16)),
                      Text(
                        currentWord.meaningText.isNotEmpty
                            ? '${PocketLanguageService.localize(en: "Meaning", ml: "അർത്ഥം", hi: "अर्थ", ta: "பொருள்", te: "అర్థం", kn: "ಅರ್ಥ")}: ${currentWord.meaningText}'
                            : 'Phonetic: [${currentWord.phonetic}]',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Interactive Letter Slot Boxes
                // User Audio Directive: "ഗെയ്മിഫിക്കേഷൻ ആയിട്ട് UI ഉണ്ടല്ലോ"
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
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: List.generate(_slots.length, (slotIdx) {
                      final placedTile = _slots[slotIdx];
                      final isSlotFilled = placedTile != null;

                      return GestureDetector(
                        onTap: () => _onSlotTapped(slotIdx),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 54,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isSlotFilled
                                ? placedTile.color.withValues(alpha: 0.25)
                                : const Color(0xFF0F172A).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isAnswerCorrect == true
                                  ? const Color(0xFF10B981)
                                  : (_isAnswerCorrect == false
                                      ? const Color(0xFFEF4444)
                                      : (isSlotFilled
                                          ? placedTile.color
                                          : Colors.white30)),
                              width: isSlotFilled ? 2.2 : 1.5,
                            ),
                            boxShadow: isSlotFilled
                                ? [
                                    BoxShadow(
                                      color: placedTile.color.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isSlotFilled
                                ? Text(
                                    placedTile.letter,
                                    style: GoogleFonts.outfit(
                                      color: placedTile.color,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
                                : Container(
                                    width: 18,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),

                // Validation Feedback Text
                if (_validationFeedback != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _validationFeedback!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: _isAnswerCorrect == true
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3. Action Toolbar: Backspace ⌫, Shuffle 🔄, Clear 🗑️
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tap letter tiles below:',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    // Shuffle button
                    IconButton(
                      onPressed: _shuffleLetterBank,
                      tooltip: 'Shuffle',
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E293B),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.shuffle_rounded, color: Colors.white70, size: 18),
                      ),
                    ),
                    // Clear all button
                    IconButton(
                      onPressed: _clearAllSlots,
                      tooltip: 'Clear',
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E293B),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 18),
                      ),
                    ),
                    // Backspace button
                    IconButton(
                      onPressed: _onBackspacePressed,
                      tooltip: 'Backspace',
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E293B),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.backspace_rounded, color: Colors.white70, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 4. Scrambled Letter Tile Bank (Vibrant Bouncy Game Tiles)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: _letterBank.map((tile) {
                  return GestureDetector(
                    onTap: () => _onBankTileTapped(tile),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: tile.isUsed ? 0.25 : 1.0,
                      child: Container(
                        width: 52,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              tile.color,
                              tile.color.withValues(alpha: 0.75),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: tile.isUsed
                              ? null
                              : [
                                  BoxShadow(
                                    color: tile.color.withValues(alpha: 0.45),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: Text(
                            tile.letter,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 5. Submit / Next Word Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAnswerCorrect == true
                    ? const Color(0xFF10B981)
                    : const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
                elevation: 6,
              ),
              onPressed: _isAnswerValidated && _isAnswerCorrect == true
                  ? _nextExamQuestion
                  : _submitSpelling,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isAnswerValidated && _isAnswerCorrect == true
                        ? (_examQuestionIndex + 1 == _words.length
                            ? 'COMPLETE CHALLENGE 🏆'
                            : 'NEXT WORD ➔')
                        : 'CHECK SPELLING ✓',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
