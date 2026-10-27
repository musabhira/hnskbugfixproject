import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/flame_icon_widget.dart';

const Color kSBg = Color(0xFF0B111E);
const Color kSCard = Color(0xFF141C2F);
const Color kSGold = Color(0xFFFFD700);
const Color kSEm = Color(0xFF10B981);
const Color kSCy = Color(0xFF38BDF8);

class _SpellDetectiveCase {
  final String sentencePrefix;
  final String sentenceSuffix;
  final String misspelledWord;
  final String correctWord;
  final List<String> distractors;

  const _SpellDetectiveCase({
    required this.sentencePrefix,
    required this.sentenceSuffix,
    required this.misspelledWord,
    required this.correctWord,
    required this.distractors,
  });

  List<String> get correctLetters => correctWord.toUpperCase().split('');
}

const List<_SpellDetectiveCase> _kDetectiveCases = [
  _SpellDetectiveCase(
    sentencePrefix: 'The',
    sentenceSuffix: 'gave a speech today.',
    misspelledWord: 'PRINCPAL',
    correctWord: 'PRINCIPAL',
    distractors: ['E', 'O'],
  ),
  _SpellDetectiveCase(
    sentencePrefix: 'My best',
    sentenceSuffix: 'won first prize.',
    misspelledWord: 'FREIND',
    correctWord: 'FRIEND',
    distractors: ['A', 'U'],
  ),
  _SpellDetectiveCase(
    sentencePrefix: 'We went to the',
    sentenceSuffix: 'to read books.',
    misspelledWord: 'LIBARY',
    correctWord: 'LIBRARY',
    distractors: ['E', 'O'],
  ),
];

/// 🔍 Step 11: Gamified Spelling Detective (Letter-by-Letter Box Speller)
class StudentSpellingDetectiveGamePage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? userId;
  final void Function(int finishedStep)? onStepFinished;

  const StudentSpellingDetectiveGamePage({
    super.key,
    this.day = 1,
    this.stepIndex = 11,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 11,
    String? userId,
    void Function(int finishedStep)? onStepFinished,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentSpellingDetectiveGamePage(
          day: day,
          stepIndex: stepIndex,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<StudentSpellingDetectiveGamePage> createState() =>
      _StudentSpellingDetectiveGameState();
}

class _StudentSpellingDetectiveGameState extends State<StudentSpellingDetectiveGamePage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  int _caseIdx = 0;
  int _xp = 35;
  int _placedLetterCount = 0;
  int _wrongCount = 0;
  late List<String> _letterBank;
  late final AnimationController _shakeCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  _SpellDetectiveCase get _currentCase => _kDetectiveCases[_caseIdx];

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadCase();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
    } catch (_) {}
  }

  void _loadCase() {
    final letters = _currentCase.correctLetters;
    final all = [...letters, ..._currentCase.distractors]..shuffle();
    setState(() {
      _letterBank = all;
      _placedLetterCount = 0;
      _wrongCount = 0;
    });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  void _triggerErrorShake() {
    _shakeCtrl.forward(from: 0);
    PocketGameSfx.instance.playErrorBuzz();
  }

  void _onLetterTap(String letter) {
    final targetLetters = _currentCase.correctLetters;
    if (_placedLetterCount >= targetLetters.length) return;

    final expected = targetLetters[_placedLetterCount];
    if (letter == expected) {
      PocketGameSfx.instance.playSnapCorrect();
      _tts.speak(letter.toLowerCase());
      setState(() {
        _placedLetterCount++;
        _letterBank.remove(letter);
      });

      if (_placedLetterCount == targetLetters.length) {
        _onCaseSolved();
      }
    } else {
      _wrongCount++;
      _triggerErrorShake();
    }
  }

  Future<void> _onCaseSolved() async {
    PocketGameSfx.instance.playVictory();
    final fullSentence =
        '${_currentCase.sentencePrefix} ${_currentCase.correctWord} ${_currentCase.sentenceSuffix}';
    await Future.delayed(const Duration(milliseconds: 250));
    _tts.speak(fullSentence);

    final roundXp = math.max(15, 30 - (_wrongCount * 5));
    setState(() => _xp += roundXp);

    widget.onStepFinished?.call(widget.stepIndex);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: kSCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: kSGold, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔍 🕵️ ⭐', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                'Spelling Solved!',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kSGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _currentCase.correctWord,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: kSEm,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '+$roundXp XP  •  ⭐⭐⭐',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kSEm,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (_caseIdx < _kDetectiveCases.length - 1) {
                    setState(() {
                      _caseIdx++;
                      _loadCase();
                    });
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                child: Text(
                  _caseIdx < _kDetectiveCases.length - 1 ? 'NEXT CASE ▶' : 'FINISH QUEST 🏆',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTileColor(int index) {
    const colors = [kSCy, kSEm, kSGold, Color(0xFFFF9100), Color(0xFFA855F7)];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final letters = _currentCase.correctLetters;

    return Scaffold(
      backgroundColor: kSBg,
      appBar: AppBar(
        backgroundColor: kSBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Spelling Detective 🔍',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FlameIcon(size: 24),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kSCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kSGold.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, color: kSGold, size: 15),
                      Text(' $_xp XP', style: GoogleFonts.outfit(color: kSGold, fontWeight: FontWeight.bold, fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _shakeCtrl,
          builder: (context, child) {
            final offset = math.sin(_shakeCtrl.value * math.pi * 6) * 8 * (1 - _shakeCtrl.value);
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: Column(
            children: [
              // Scrollable Crime Scene Clue (Zero Overflow)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Case ${_caseIdx + 1} of ${_kDetectiveCases.length}',
                            style: GoogleFonts.outfit(color: kSGold, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFEF4444)),
                            ),
                            child: Text(
                              'Typo was: ${_currentCase.misspelledWord}',
                              style: GoogleFonts.outfit(color: const Color(0xFFFCA5A5), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Crime Scene Board
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kSCy.withValues(alpha: 0.4), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_rounded, color: kSGold, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'Spell the word letter by letter:',
                                  style: GoogleFonts.outfit(color: kSGold, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Sentence Clue
                            Text(
                              '"${_currentCase.sentencePrefix} [ ___ ] ${_currentCase.sentenceSuffix}"',
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 15, fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),

                            // Interactive Letter Boxes
                            Wrap(
                              spacing: 6,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                for (int i = 0; i < letters.length; i++)
                                  Container(
                                    width: 38,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: i < _placedLetterCount
                                          ? kSEm.withValues(alpha: 0.25)
                                          : (i == _placedLetterCount
                                              ? kSGold.withValues(alpha: 0.2)
                                              : Colors.white10),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: i < _placedLetterCount
                                            ? kSEm
                                            : (i == _placedLetterCount ? kSGold : Colors.white24),
                                        width: i == _placedLetterCount ? 2 : 1.4,
                                      ),
                                    ),
                                    child: Text(
                                      i < _placedLetterCount ? letters[i] : (i == _placedLetterCount ? '?' : ''),
                                      style: GoogleFonts.outfit(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: i < _placedLetterCount
                                            ? kSEm
                                            : (i == _placedLetterCount ? kSGold : Colors.white24),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Letter Bank Dock
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: kSCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: kSGold.withValues(alpha: 0.35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Letter Bank (Tap the next letter to snap into box):',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (int i = 0; i < _letterBank.length; i++)
                            GestureDetector(
                              onTap: () => _onLetterTap(_letterBank[i]),
                              child: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _getTileColor(i).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _getTileColor(i), width: 1.8),
                                ),
                                child: Text(
                                  _letterBank[i],
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
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
            ],
          ),
        ),
      ),
    );
  }
}
