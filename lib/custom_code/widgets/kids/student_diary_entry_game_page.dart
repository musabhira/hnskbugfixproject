import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

const Color kDBg = Color(0xFF0F172A);
const Color kDCard = Color(0xFF1E293B);
const Color kDGold = Color(0xFFFFD700);
const Color kDEm = Color(0xFF10B981);
const Color kDCy = Color(0xFF38BDF8);

class _DiaryRound {
  final String dateStr;
  final List<String> sentence1Words;
  final List<String> sentence2Words;
  final List<String> distractors;
  final String prompt;

  const _DiaryRound({
    required this.dateStr,
    required this.sentence1Words,
    required this.sentence2Words,
    required this.distractors,
    required this.prompt,
  });

  List<String> get allWords => [...sentence1Words, ...sentence2Words];
}

const List<_DiaryRound> _kDiaryRounds = [
  _DiaryRound(
    dateStr: 'Sunday Evening',
    sentence1Words: ['Today', 'was', 'fun', 'with', 'my', 'friends', '.'],
    sentence2Words: ['Tomorrow', 'I', 'will', 'learn', 'new', 'words', '.'],
    distractors: ['cry', 'late', 'angry'],
    prompt: 'Tap words to write your evening diary!',
  ),
  _DiaryRound(
    dateStr: 'Monday Afternoon',
    sentence1Words: ['I', 'got', 'a', 'gold', 'star', 'in', 'class', '.'],
    sentence2Words: ['I', 'feel', 'very', 'proud', 'today', '.'],
    distractors: ['sad', 'sleep', 'bad'],
    prompt: 'Record your proud school moment!',
  ),
];

/// 📖 Step 7: Gamified Diary Entry Adventure (Word-Bank Snap Engine)
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
  int _roundIdx = 0;
  int _xp = 30;
  String _selectedMood = '😄 Happy';
  int _placedCount = 0;
  int _wrongCount = 0;
  late List<String> _bankTiles;
  late final AnimationController _shakeCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  final List<String> _moods = ['😄 Happy', '🤩 Excited', '🤔 Thoughtful', '🌟 Proud'];

  _DiaryRound get _currentRound => _kDiaryRounds[_roundIdx];

  @override
  void initState() {
    super.initState();
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
                  if (_roundIdx < _kDiaryRounds.length - 1) {
                    setState(() {
                      _roundIdx++;
                      _setupRound();
                    });
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                child: Text(
                  _roundIdx < _kDiaryRounds.length - 1 ? 'NEXT DIARY ENTRY ▶' : 'FINISH QUEST 🏆',
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
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kDCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kDGold.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: kDGold, size: 16),
                    Text(' $_xp XP', style: GoogleFonts.outfit(color: kDGold, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
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
              // Mood Selector Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text('Mood: ', style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.w600)),
                      for (final m in _moods)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedMood = m);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _selectedMood == m ? kDGold : kDCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedMood == m ? kDGold : Colors.white24,
                                ),
                              ),
                              child: Text(
                                m,
                                style: GoogleFonts.outfit(
                                  color: _selectedMood == m ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Visual Diary Notebook Card
              Expanded(
                flex: 4,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(
                        left: BorderSide(color: Color(0xFFDC2626), width: 6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Dear Diary, $_selectedMood',
                              style: GoogleFonts.caveat(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF78350F),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _currentRound.dateStr,
                              style: GoogleFonts.caveat(
                                fontSize: 16,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, thickness: 1, color: Color(0xFFE5D5B5)),

                        // Sentence 1
                        Text(
                          '1. Today\'s highlight:',
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF78350F)),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (int i = 0; i < s1.length; i++)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: i < s1Placed ? const Color(0xFF451A03) : Colors.black26,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Sentence 2
                        Text(
                          '2. Looking ahead:',
                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF78350F)),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (int i = 0; i < s2.length; i++)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: i < s2Placed ? const Color(0xFF14532D) : Colors.black26,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '💡 ${_currentRound.prompt}',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Interactive Word Bank
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                decoration: BoxDecoration(
                  color: kDCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: kDGold.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.touch_app_rounded, color: kDGold, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Word Bank (Tap words to form the diary entries)',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (int i = 0; i < _bankTiles.length; i++)
                          GestureDetector(
                            onTap: () => _onTileTap(_bankTiles[i]),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                              decoration: BoxDecoration(
                                color: _getTileColor(i).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _getTileColor(i), width: 1.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getTileColor(i).withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                _bankTiles[i],
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
