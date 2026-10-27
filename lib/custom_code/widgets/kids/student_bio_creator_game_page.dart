import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/flame_icon_widget.dart';

const Color kPBg = Color(0xFF0A111F);
const Color kPCard = Color(0xFF142038);
const Color kPGold = Color(0xFFFFD700);
const Color kPEm = Color(0xFF10B981);
const Color kPCy = Color(0xFF38BDF8);

class _ExamProfileRound {
  final String heroName;
  final String heroEmoji;
  final Map<String, String> examClues;
  final List<List<String>> sentences;
  final List<String> distractors;

  const _ExamProfileRound({
    required this.heroName,
    required this.heroEmoji,
    required this.examClues,
    required this.sentences,
    required this.distractors,
  });

  List<String> get allSentenceWords => [for (final s in sentences) ...s];
}

const List<_ExamProfileRound> _kExamProfiles = [
  _ExamProfileRound(
    heroName: 'Dr. A.P.J. Abdul Kalam',
    heroEmoji: '🚀',
    examClues: {
      'Born': '15 October 1931, Rameswaram',
      'Known as': 'Missile Man of India',
      'Position': '11th President of India',
      'Award': 'Bharat Ratna',
    },
    sentences: [
      ['A. P. J. Abdul Kalam', 'was', 'born', 'in', 'Rameswaram', '.'],
      ['He', 'was', 'the', '11th', 'President', 'of', 'India', '.'],
    ],
    distractors: ['singer', 'yesterday', 'moon'],
  ),
  _ExamProfileRound(
    heroName: 'Mary Kom',
    heroEmoji: '🥊',
    examClues: {
      'Born': '1 March 1983, Manipur',
      'Sport': 'Boxing',
      'Achievement': 'Six-time World Champion',
      'Award': 'Padma Vibhushan',
    },
    sentences: [
      ['Mary Kom', 'was', 'born', 'in', 'Manipur', '.'],
      ['She', 'is', 'a', 'famous', 'World', 'Champion', '.'],
    ],
    distractors: ['cricket', 'dance', 'sleep'],
  ),
];

/// 👤 Step 8: Exam Profile-to-Paragraph Writing Quest (Authentic School Exam Training)
class StudentBioCreatorGamePage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? userId;
  final void Function(int finishedStep)? onStepFinished;

  const StudentBioCreatorGamePage({
    super.key,
    this.day = 1,
    this.stepIndex = 8,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 8,
    String? userId,
    void Function(int finishedStep)? onStepFinished,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentBioCreatorGamePage(
          day: day,
          stepIndex: stepIndex,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<StudentBioCreatorGamePage> createState() => _StudentBioCreatorGameState();
}

class _StudentBioCreatorGameState extends State<StudentBioCreatorGamePage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  int _roundIdx = 0;
  int _xp = 35;
  int _currentSentenceIdx = 0;
  int _currentWordIdx = 0;
  int _wrongCount = 0;
  late List<String> _bankTiles;
  late final AnimationController _shakeCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  _ExamProfileRound get _round => _kExamProfiles[_roundIdx];

  @override
  void initState() {
    super.initState();
    _initTts();
    _setupRound();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
    } catch (_) {}
  }

  void _setupRound() {
    final curSentence = _round.sentences[_currentSentenceIdx];
    final all = [...curSentence, ..._round.distractors]..shuffle();
    setState(() {
      _bankTiles = all;
      _currentWordIdx = 0;
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
    final curSentence = _round.sentences[_currentSentenceIdx];
    final expected = curSentence[_currentWordIdx];

    if (word == expected) {
      PocketGameSfx.instance.playSnapCorrect();
      _tts.speak(word);
      setState(() {
        _currentWordIdx++;
        _bankTiles.remove(word);
      });

      if (_currentWordIdx == curSentence.length) {
        _onSentenceFinished();
      }
    } else {
      _wrongCount++;
      _triggerErrorShake();
    }
  }

  Future<void> _onSentenceFinished() async {
    final fullSentence = _round.sentences[_currentSentenceIdx].join(' ');
    await Future.delayed(const Duration(milliseconds: 250));
    _tts.speak(fullSentence);

    if (_currentSentenceIdx < _round.sentences.length - 1) {
      await Future.delayed(const Duration(milliseconds: 700));
      setState(() {
        _currentSentenceIdx++;
        _setupRound();
      });
    } else {
      _onRoundComplete();
    }
  }

  Future<void> _onRoundComplete() async {
    PocketGameSfx.instance.playVictory();
    final roundXp = math.max(15, 30 - (_wrongCount * 5));
    setState(() => _xp += roundXp);

    widget.onStepFinished?.call(widget.stepIndex);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: kPCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: kPGold, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📝 🏅 🌟', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                'Profile Paragraph Complete!',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '+$roundXp XP  •  ⭐⭐⭐',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kPEm,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (_roundIdx < _kExamProfiles.length - 1) {
                    setState(() {
                      _roundIdx++;
                      _currentSentenceIdx = 0;
                      _wrongCount = 0;
                      _setupRound();
                    });
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                child: Text(
                  _roundIdx < _kExamProfiles.length - 1 ? 'NEXT EXAM QUESTION ▶' : 'FINISH QUEST 🏆',
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
    const colors = [kPCy, kPEm, kPGold, Color(0xFFFF9100), Color(0xFFA855F7)];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPBg,
      appBar: AppBar(
        backgroundColor: kPBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Exam Profile Writing 👤',
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
                    color: kPCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kPGold.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, color: kPGold, size: 15),
                      Text(' $_xp XP', style: GoogleFonts.outfit(color: kPGold, fontWeight: FontWeight.bold, fontSize: 12.5)),
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
              // Scrollable Exam Clues + Paragraph Workspace
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Question ${_roundIdx + 1} of ${_kExamProfiles.length}: Profile to Paragraph',
                        style: GoogleFonts.outfit(color: kPGold, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      const SizedBox(height: 8),

                      // Official Exam Profile Clues Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kPCy.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(_round.heroEmoji, style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 6),
                                Text(
                                  _round.heroName,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 14, thickness: 1, color: Colors.white12),
                            for (final entry in _round.examClues.entries)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• ${entry.key}: ',
                                      style: GoogleFonts.outfit(
                                        color: kPCy,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white70,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Student Answer Sheet
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF5),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📝 Your Answer Paragraph:',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Display Completed and Active Sentences
                            for (int sIdx = 0; sIdx < _round.sentences.length; sIdx++) ...[
                              if (sIdx < _currentSentenceIdx) ...[
                                Text(
                                  '✓ ${_round.sentences[sIdx].join(' ')}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF047857),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ] else if (sIdx == _currentSentenceIdx) ...[
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (int w = 0; w < _round.sentences[sIdx].length; w++)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: w < _currentWordIdx
                                              ? const Color(0xFFDCFCE7)
                                              : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: w < _currentWordIdx
                                                ? const Color(0xFF16A34A)
                                                : const Color(0xFFCBD5E1),
                                          ),
                                        ),
                                        child: Text(
                                          w < _currentWordIdx
                                              ? _round.sentences[sIdx][w]
                                              : '____',
                                          style: GoogleFonts.outfit(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: w < _currentWordIdx
                                                ? const Color(0xFF14532D)
                                                : Colors.black26,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Word Bank Dock
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: kPCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: kPEm.withValues(alpha: 0.35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Word Bank (Tap words to form Sentence ${_currentSentenceIdx + 1}):',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
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
                                  fontSize: 14.5,
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
