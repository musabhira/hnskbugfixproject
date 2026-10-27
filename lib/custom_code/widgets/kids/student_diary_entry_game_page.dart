import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/flame_icon_widget.dart';

import 'package:pocket_mates_app/custom_code/widgets/kids/student_creative_writing_90day_curriculum.dart';

const Color kDBg = Color(0xFF0B111E);
const Color kDCard = Color(0xFF141C2F);
const Color kDGold = Color(0xFFFFD700);
const Color kDEm = Color(0xFF10B981);
const Color kDCy = Color(0xFF38BDF8);

class _DiaryRound {
  final String dateStr;
  final String mood;
  final List<String> sentence1Words;
  final List<String> sentence2Words;
  final List<String> distractors;
  final String prompt;

  const _DiaryRound({
    required this.dateStr,
    required this.mood,
    required this.sentence1Words,
    required this.sentence2Words,
    required this.distractors,
    required this.prompt,
  });

  List<String> get allWords => [...sentence1Words, ...sentence2Words];
}

/// 📖 Step 7: Gamified Diary Entry Adventure (Overflow-Safe & Animated Flame)
class StudentDiaryEntryGamePage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? userId;
  final void Function(int finishedStep)? onStepFinished;

  const StudentDiaryEntryGamePage({
    super.key,
    this.day = 1,
    this.stepIndex = 7,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 7,
    String? userId,
    void Function(int finishedStep)? onStepFinished,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDiaryEntryGamePage(
          day: day,
          stepIndex: stepIndex,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<StudentDiaryEntryGamePage> createState() => _StudentDiaryEntryGameState();
}

class _StudentDiaryEntryGameState extends State<StudentDiaryEntryGamePage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late final List<_DiaryRound> _rounds;
  int _roundIdx = 0;
  int _xp = 30;
  int _placedCount = 0;
  int _wrongCount = 0;
  late List<String> _bankTiles;
  late final AnimationController _shakeCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  _DiaryRound get _currentRound => _rounds[_roundIdx];

  @override
  void initState() {
    super.initState();
    final dayData = StudentCreativeWriting90DayCurriculum.getDiaryData(widget.day);
    _rounds = [
      _DiaryRound(
        dateStr: dayData.dateStr,
        mood: dayData.mood,
        sentence1Words: dayData.sentence1Words,
        sentence2Words: dayData.sentence2Words,
        distractors: dayData.distractors,
        prompt: dayData.prompt,
      ),
    ];
    _initTts();
    _setupRound();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.05);
    } catch (_) {}
  }

  void _setupRound() {
    final targets = _currentRound.allWords;
    final all = [...targets, ..._currentRound.distractors]..shuffle();
    setState(() {
      _bankTiles = all;
      _placedCount = 0;
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

  void _onTileTap(String word) {
    final expectedWords = _currentRound.allWords;
    if (_placedCount >= expectedWords.length) return;

    final nextTarget = expectedWords[_placedCount];
    if (word == nextTarget) {
      PocketGameSfx.instance.playSnapCorrect();
      _tts.speak(word);
      setState(() {
        _placedCount++;
        _bankTiles.remove(word);
      });

      if (_placedCount == expectedWords.length) {
        _onRoundCompleted();
      }
    } else {
      _wrongCount++;
      _triggerErrorShake();
    }
  }

  Future<void> _onRoundCompleted() async {
    PocketGameSfx.instance.playVictory();
    final fullText =
        'Dear Diary, ${_currentRound.sentence1Words.join(' ')} ${_currentRound.sentence2Words.join(' ')}';
    await Future.delayed(const Duration(milliseconds: 300));
    _tts.speak(fullText);

    final roundXp = math.max(15, 30 - (_wrongCount * 5));
    setState(() => _xp += roundXp);

    widget.onStepFinished?.call(widget.stepIndex);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: kDCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: kDGold, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🌟 📖 ✨', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                'Diary Entry Stamped!',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kDGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '+$roundXp XP  •  ⭐⭐⭐',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kDEm,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (_roundIdx < _rounds.length - 1) {
                    setState(() {
                      _roundIdx++;
                      _setupRound();
                    });
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                child: Text(
                  _roundIdx < _rounds.length - 1 ? 'NEXT DIARY ENTRY ▶' : 'FINISH QUEST 🏆',
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
    const colors = [kDGold, kDEm, kDCy, Color(0xFFFF9100), Color(0xFFA855F7)];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final s1 = _currentRound.sentence1Words;
    final s2 = _currentRound.sentence2Words;
    final s1Placed = math.min(_placedCount, s1.length);
    final s2Placed = math.max(0, _placedCount - s1.length);

    return Scaffold(
      backgroundColor: kDBg,
      appBar: AppBar(
        backgroundColor: kDBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Diary Entry Adventure 📖',
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
                    color: kDCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kDGold.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, color: kDGold, size: 15),
                      Text(' $_xp XP', style: GoogleFonts.outfit(color: kDGold, fontWeight: FontWeight.bold, fontSize: 12.5)),
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
              // Scrollable Diary Notebook (Zero Overflow)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                  child: Column(
                    children: [
                      // Header Ribbon
                      Row(
                        children: [
                          Text(
                            'Entry ${_roundIdx + 1} of ${_rounds.length}',
                            style: GoogleFonts.outfit(color: kDGold, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: kDCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: kDGold.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              'Mood: ${_currentRound.mood}',
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Visual Diary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(16),
                          border: const Border(
                            left: BorderSide(color: Color(0xFFDC2626), width: 5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Dear Diary, ${_currentRound.mood.split(' ').first}',
                                  style: GoogleFonts.caveat(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF78350F),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _currentRound.dateStr,
                                  style: GoogleFonts.caveat(
                                    fontSize: 15,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16, thickness: 1, color: Color(0xFFE5D5B5)),

                            // Sentence 1
                            Text(
                              '1. Today\'s highlight:',
                              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF78350F)),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (int i = 0; i < s1.length; i++)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: i < s1Placed ? const Color(0xFFFEF08A) : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: i < s1Placed ? const Color(0xFFCA8A04) : const Color(0xFFD1D5DB),
                                        width: i < s1Placed ? 1.8 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      i < s1Placed ? s1[i] : '____',
                                      style: GoogleFonts.caveat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: i < s1Placed ? const Color(0xFF451A03) : Colors.black26,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Sentence 2
                            Text(
                              '2. Tomorrow\'s wish:',
                              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF78350F)),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (int i = 0; i < s2.length; i++)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: i < s2Placed ? const Color(0xFFBBF7D0) : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: i < s2Placed ? const Color(0xFF16A34A) : const Color(0xFFD1D5DB),
                                        width: i < s2Placed ? 1.8 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      i < s2Placed ? s2[i] : '____',
                                      style: GoogleFonts.caveat(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: i < s2Placed ? const Color(0xFF14532D) : Colors.black26,
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

              // Compact, Scroll-Safe Word Bank Dock (Zero Overflow)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: kDCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: kDGold.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.touch_app_rounded, color: kDGold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Word Bank (Tap to fill the diary)',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < _bankTiles.length; i++)
                          GestureDetector(
                            onTap: () => _onTileTap(_bankTiles[i]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: _getTileColor(i).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getTileColor(i), width: 1.6),
                              ),
                              child: Text(
                                _bankTiles[i],
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
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
    );
  }
}
