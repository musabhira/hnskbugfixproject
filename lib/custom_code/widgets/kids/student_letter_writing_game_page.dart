import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/flame_icon_widget.dart';

const Color kLBg = Color(0xFF0A0F1D);
const Color kLCard = Color(0xFF131D33);
const Color kLGold = Color(0xFFFFD700);
const Color kLEm = Color(0xFF10B981);
const Color kLCy = Color(0xFF00E5FF);
const Color kLRed = Color(0xFFEF4444);

class _LetterRound {
  final String title;
  final String recipient;
  final List<String> line1Words;
  final List<String> line2Words;
  final List<String> distractors;
  final String hint;

  const _LetterRound({
    required this.title,
    required this.recipient,
    required this.line1Words,
    required this.line2Words,
    required this.distractors,
    required this.hint,
  });

  List<String> get allTargetWords => [...line1Words, ...line2Words];
}

const List<_LetterRound> _kLetterRounds = [
  _LetterRound(
    title: '✉️ Friendly Letter to a Friend',
    recipient: 'To: Best Friend',
    line1Words: ['Dear', 'Rahul', ','],
    line2Words: ['How', 'are', 'you', '?'],
    distractors: ['Sir', 'yesterday', 'bye'],
    hint: 'Day 1 Starter: Greet your friend and ask how they are!',
  ),
  _LetterRound(
    title: '✉️ Respectful Letter to Teacher',
    recipient: 'To: Class Teacher',
    line1Words: ['Respected', 'Teacher', ','],
    line2Words: ['Please', 'grant', 'leave', '.'],
    distractors: ['Hey', 'play', 'cool'],
    hint: 'Day 1 Starter: Begin with a polite greeting and simple request.',
  ),
];

/// ✉️ Step 6: Gamified Letter Writing Game (Word-Bank Snap Engine)
class StudentLetterWritingGamePage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? userId;
  final void Function(int finishedStep)? onStepFinished;

  const StudentLetterWritingGamePage({
    super.key,
    this.day = 1,
    this.stepIndex = 6,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 6,
    String? userId,
    void Function(int finishedStep)? onStepFinished,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentLetterWritingGamePage(
          day: day,
          stepIndex: stepIndex,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<StudentLetterWritingGamePage> createState() => _StudentLetterWritingGameState();
}

class _StudentLetterWritingGameState extends State<StudentLetterWritingGamePage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  int _roundIdx = 0;
  int _xp = 30;
  int _placedCount = 0;
  int _wrongCount = 0;
  int _shakeTrigger = 0;
  late List<String> _bankTiles;
  late final AnimationController _shakeCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  _LetterRound get _currentRound => _kLetterRounds[_roundIdx];

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
    final targets = _currentRound.allTargetWords;
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
    setState(() => _shakeTrigger++);
    _shakeCtrl.forward(from: 0);
    PocketGameSfx.instance.playErrorBuzz();
  }

  void _onTileTap(String word) {
    final expectedWords = _currentRound.allTargetWords;
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
        '${_currentRound.line1Words.join(' ')} ${_currentRound.line2Words.join(' ')}';
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
        backgroundColor: kLCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: kLGold, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📜 ✨ ✉️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                'Letter Formed Successfully!',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kLGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '+$roundXp XP  •  ⭐⭐⭐',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kLEm,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kLGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (_roundIdx < _kLetterRounds.length - 1) {
                    setState(() {
                      _roundIdx++;
                      _setupRound();
                    });
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                child: Text(
                  _roundIdx < _kLetterRounds.length - 1 ? 'NEXT LETTER ▶' : 'FINISH QUEST 🏆',
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
    const colors = [kLCy, kLEm, Color(0xFFFF9100), Color(0xFFA855F7), Color(0xFFEC4899)];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final line1 = _currentRound.line1Words;
    final line2 = _currentRound.line2Words;
    final l1Placed = math.min(_placedCount, line1.length);
    final l2Placed = math.max(0, _placedCount - line1.length);

    return Scaffold(
      backgroundColor: kLBg,
      appBar: AppBar(
        backgroundColor: kLBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Letter Writing Quest ✉️',
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
                    color: kLCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kLGold.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, color: kLGold, size: 15),
                      Text(' $_xp XP', style: GoogleFonts.outfit(color: kLGold, fontWeight: FontWeight.bold, fontSize: 12.5)),
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
              // Scrollable Parchment Letter Preview (Zero Overflow)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                  child: Column(
                    children: [
                      // Progress Ribbon
                      Row(
                        children: [
                          Text(
                            'Round ${_roundIdx + 1} of ${_kLetterRounds.length}',
                            style: GoogleFonts.outfit(color: kLGold, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const Spacer(),
                          Text(
                            _currentRound.recipient,
                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2D9C8), width: 2),
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
                        // Letter Header Bar
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _currentRound.title,
                                style: GoogleFonts.caveat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF5B21B6),
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.mark_email_read_rounded, color: Color(0xFF059669), size: 22),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1, color: Color(0xFFE5E7EB)),

                        // Line 1: Salutation
                        Text(
                          'Salutation (Opening Greeting):',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (int i = 0; i < line1.length; i++)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: i < l1Placed
                                      ? const Color(0xFFE0E7FF)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: i < l1Placed
                                        ? const Color(0xFF4F46E5)
                                        : const Color(0xFFD1D5DB),
                                    width: i < l1Placed ? 1.8 : 1,
                                  ),
                                ),
                                child: Text(
                                  i < l1Placed ? line1[i] : '____',
                                  style: GoogleFonts.caveat(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: i < l1Placed ? const Color(0xFF1E1B4B) : Colors.black26,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Line 2: First Sentence
                        Text(
                          'Opening Sentence:',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (int i = 0; i < line2.length; i++)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: i < l2Placed
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: i < l2Placed
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFD1D5DB),
                                    width: i < l2Placed ? 1.8 : 1,
                                  ),
                                ),
                                child: Text(
                                  i < l2Placed ? line2[i] : '____',
                                  style: GoogleFonts.caveat(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: i < l2Placed ? const Color(0xFF14532D) : Colors.black26,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Bottom Hint Pill
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '💡 ${_currentRound.hint}',
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
                ],
              ),
            ),
          ),

              // Interactive Word Bank
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                decoration: BoxDecoration(
                  color: kLCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: kLCy.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 10,
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
                        const Icon(Icons.touch_app_rounded, color: kLCy, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Word Bank (Tap in order to complete the letter)',
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
