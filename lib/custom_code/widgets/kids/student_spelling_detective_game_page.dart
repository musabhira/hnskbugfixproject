import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/flame_icon_widget.dart';

import 'package:pocket_mates_app/custom_code/widgets/kids/student_creative_writing_90day_curriculum.dart';

const Color kSBg = Color(0xFF0B111E);
const Color kSCard = Color(0xFF141C2F);
const Color kSGold = Color(0xFFFFD700);
const Color kSEm = Color(0xFF10B981);
const Color kSCy = Color(0xFF38BDF8);
const Color kSRed = Color(0xFFEF4444);

class _DetectiveCase {
  final String wrongWord;
  final String correctWord;
  final String clue;
  final List<String> distractors;

  const _DetectiveCase({
    required this.wrongWord,
    required this.correctWord,
    required this.clue,
    required this.distractors,
  });

  List<String> get correctLetters => correctWord.toUpperCase().split('');
  List<String> get wrongLetters => wrongWord.toUpperCase().split('');
}

/// 🔍 Step 11: Spelling Detective (Interactive Typo Fixer)
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
  late final List<_DetectiveCase> _cases;
  int _caseIdx = 0;
  int _xp = 35;
  int _placedLetterCount = 0;
  int _wrongCount = 0;
  late List<String> _letterBank;
  late final AnimationController _shakeCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  _DetectiveCase get _currentCase => _cases[_caseIdx];

  @override
  void initState() {
    super.initState();
    final dayData = StudentCreativeWriting90DayCurriculum.getSpellingData(widget.day);
    _cases = [
      _DetectiveCase(
        wrongWord: dayData.wrongWord,
        correctWord: dayData.correctWord,
        clue: dayData.clue,
        distractors: dayData.distractors,
      ),
    ];
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
    await Future.delayed(const Duration(milliseconds: 200));
    _tts.speak(_currentCase.correctWord.toLowerCase());

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
                'Correct Spelling Restored!',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kSGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: kSEm.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kSEm, width: 1.5),
                ),
                child: Text(
                  _currentCase.correctWord,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: kSEm,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
                  if (_caseIdx < _cases.length - 1) {
                    setState(() {
                      _caseIdx++;
                      _loadCase();
                    });
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                child: Text(
                  _caseIdx < _cases.length - 1 ? 'NEXT MYSTERY ▶' : 'FINISH QUEST 🏆',
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
    final wrongLetters = _currentCase.wrongLetters;

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
              // Scrollable Detective Workspace
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          Text(
                            'Case ${_caseIdx + 1} of ${_cases.length}',
                            style: GoogleFonts.outfit(color: kSGold, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: kSCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: kSCy.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lightbulb_rounded, color: kSGold, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _currentCase.clue,
                                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 1. Wrong Spelling Banner on Top (User Directive: "Already wrong aayittulla spelling mele kodukkanam")
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1123),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: kSRed.withValues(alpha: 0.6), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cancel_rounded, color: kSRed, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'INCORRECT SPELLING FOUND:',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFCA5A5),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Wrong letter tiles
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: [
                                for (final ch in wrongLetters)
                                  Container(
                                    width: 32,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: kSRed.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: kSRed.withValues(alpha: 0.7)),
                                    ),
                                    child: Text(
                                      ch,
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFCA5A5),
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. Correct Solution Letter Boxes Below (User Directive: "Adiyil petti petti koduthitt thiruthanam")
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kSCy.withValues(alpha: 0.4), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, color: kSEm, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'TAP TO SPELL CORRECTLY:',
                                  style: GoogleFonts.outfit(
                                    color: kSEm,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Solution Letter Boxes
                            Wrap(
                              spacing: 6,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                for (int i = 0; i < letters.length; i++)
                                  Container(
                                    width: 34,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: i < _placedLetterCount
                                          ? kSEm.withValues(alpha: 0.25)
                                          : (i == _placedLetterCount
                                              ? kSGold.withValues(alpha: 0.2)
                                              : Colors.white10),
                                      borderRadius: BorderRadius.circular(8),
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
                                        fontSize: 18,
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

              // Letter Bank Dock at the Bottom
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
                      'Letter Bank (Tap in order to build the correct spelling):',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
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
