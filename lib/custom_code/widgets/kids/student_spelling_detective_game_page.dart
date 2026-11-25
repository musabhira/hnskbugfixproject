import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

import 'package:pocket_mates_app/custom_code/widgets/kids/student_creative_writing_90day_curriculum.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';

const Color kSBg = Color(0xFF141210);
const Color kSCard = Color(0xFF1E1B18);
const Color kSGold = Color(0xFFD4A373);
const Color kSEm = Color(0xFF15803D);
const Color kSCy = Color(0xFF38BDF8);
const Color kSRed = Color(0xFFDC2626);

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
              const SizedBox(height: 12),
              // 🚀 Preloaded Minimal Native Ad inside Quest Completion Modal
              const PocketNativeAdCard(
                placement: PocketAdPlacement.review,
                isCompact: true,
                margin: EdgeInsets.symmetric(vertical: 4),
              ),
              const SizedBox(height: 10),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFE5DEC9), size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Spelling Detective',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFFDF8EE),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: PocketBannerAdWidget(),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _shakeCtrl,
          builder: (context, child) {
            final offset = math.sin(_shakeCtrl.value * math.pi * 6) * 8 * (1 - _shakeCtrl.value);
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              children: [
                // Minimal Editorial Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kSCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kSGold.withValues(alpha: 0.35)),
                      ),
                      child: Text(
                        'Case ${_caseIdx + 1} of ${_cases.length}',
                        style: GoogleFonts.outfit(color: kSGold, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kSCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: kSGold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _currentCase.clue,
                            style: GoogleFonts.outfit(color: const Color(0xFFE5DEC9), fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Warm Editorial Cream Paper Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF8EE),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE6D5B8), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Incorrect Spelling Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kSRed.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: kSRed, size: 15),
                            const SizedBox(width: 5),
                            Text(
                              'INCORRECT SPELLING FOUND',
                              style: GoogleFonts.outfit(
                                color: kSRed,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
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
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: kSRed.withValues(alpha: 0.45)),
                              ),
                              child: Text(
                                ch,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFB91C1C),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: Color(0xFFE6D5B8), height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.edit_note_rounded, color: kSEm, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'TAP TO SPELL CORRECTLY',
                            style: GoogleFonts.outfit(
                              color: kSEm,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 7,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (int i = 0; i < letters.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 36,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: i < _placedLetterCount
                                    ? const Color(0xFFDCFCE7)
                                    : (i == _placedLetterCount
                                        ? const Color(0xFFFEF3C7)
                                        : const Color(0xFFF3ECE0)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: i < _placedLetterCount
                                      ? kSEm
                                      : (i == _placedLetterCount ? const Color(0xFFD97706) : const Color(0xFFD6C7AE)),
                                  width: i == _placedLetterCount ? 2 : 1.3,
                                ),
                              ),
                              child: Text(
                                i < _placedLetterCount ? letters[i] : (i == _placedLetterCount ? '?' : ''),
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: i < _placedLetterCount
                                      ? kSEm
                                      : (i == _placedLetterCount ? const Color(0xFFB45309) : Colors.black26),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Letter Bank Dock
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  decoration: BoxDecoration(
                    color: kSCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kSGold.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.touch_app_rounded, color: kSGold, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Letter Bank • Tap in order to fix the spelling',
                              style: GoogleFonts.outfit(color: kSGold, fontSize: 12.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
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
                                    color: _getTileColor(i).withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(color: _getTileColor(i).withValues(alpha: 0.75), width: 1.5),
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
                const SizedBox(height: 16),
                const PocketTrueNativeAdWidget(
                  placement: PocketAdPlacement.learningStep,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
