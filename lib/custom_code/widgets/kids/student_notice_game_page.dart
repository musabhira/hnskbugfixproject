import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

const Color kNBg = Color(0xFF0F172A);
const Color kNCard = Color(0xFF1E293B);
const Color kNGold = Color(0xFFFFD700);
const Color kNRed = Color(0xFFEF4444);
const Color kNAccent = Color(0xFFF97316);

class _NoticeStep {
  final String label;
  final String correct;
  final List<String> options;

  const _NoticeStep({
    required this.label,
    required this.correct,
    required this.options,
  });
}

const List<_NoticeStep> _kNoticeSteps = [
  _NoticeStep(
    label: '1. School Name',
    correct: 'GREENFIELD PUBLIC SCHOOL',
    options: ['GREENFIELD PUBLIC SCHOOL', 'sports club', 'my house'],
  ),
  _NoticeStep(
    label: '2. Notice Header',
    correct: 'NOTICE',
    options: ['NOTICE', 'Dear All', 'Letter'],
  ),
  _NoticeStep(
    label: '3. Main Headline',
    correct: 'ANNUAL SPORTS MEET',
    options: ['ANNUAL SPORTS MEET', 'We are playing', 'Run run run'],
  ),
  _NoticeStep(
    label: '4. Date & Venue',
    correct: '12 Dec • School Ground',
    options: ['12 Dec • School Ground', 'someday', 'nowhere'],
  ),
  _NoticeStep(
    label: '5. Signatory',
    correct: 'Mr. S. Verma, Principal',
    options: ['Mr. S. Verma, Principal', 'Nobody', 'Anonymous'],
  ),
];

/// 📢 Step 9: Gamified Notice Masterclass (Word-Bank Snap Engine)
class StudentNoticeGamePage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? userId;
  final void Function(int finishedStep)? onStepFinished;

  const StudentNoticeGamePage({
    super.key,
    this.day = 1,
    this.stepIndex = 9,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 9,
    String? userId,
    void Function(int finishedStep)? onStepFinished,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentNoticeGamePage(
          day: day,
          stepIndex: stepIndex,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<StudentNoticeGamePage> createState() => _StudentNoticeGameState();
}

class _StudentNoticeGameState extends State<StudentNoticeGamePage> {
  final FlutterTts _tts = FlutterTts();
  int _currentStep = 0;
  int _xp = 30;
  final List<String?> _placed = List.filled(_kNoticeSteps.length, null);

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
    } catch (_) {}
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _onOptionTap(String opt) {
    final step = _kNoticeSteps[_currentStep];
    if (opt == step.correct) {
      PocketGameSfx.instance.playSnapCorrect();
      _tts.speak(opt);
      setState(() {
        _placed[_currentStep] = opt;
        _currentStep++;
      });

      if (_currentStep == _kNoticeSteps.length) {
        _onFinishNotice();
      }
    } else {
      PocketGameSfx.instance.playErrorBuzz();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Not quite! Pick the formal notice text.'),
          duration: Duration(seconds: 1),
          backgroundColor: kNRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onFinishNotice() async {
    PocketGameSfx.instance.playVictory();
    _tts.speak('Notice published successfully!');
    setState(() => _xp += 30);
    widget.onStepFinished?.call(widget.stepIndex);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: kNCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: kNGold, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📢 📜 🌟', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                'Notice Published!',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kNGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '+30 XP  •  ⭐⭐⭐',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).maybePop();
                },
                child: Text(
                  'FINISH QUEST 🏆',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15),
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
    return Scaffold(
      backgroundColor: kNBg,
      appBar: AppBar(
        backgroundColor: kNBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Notice Masterclass 📢',
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
                  color: kNCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kNGold.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: kNGold, size: 16),
                    Text(' $_xp XP', style: GoogleFonts.outfit(color: kNGold, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Step ${_currentStep + 1} of ${_kNoticeSteps.length}: ${_currentStep < _kNoticeSteps.length ? _kNoticeSteps[_currentStep].label : 'Notice Ready!'}',
                    style: GoogleFonts.outfit(color: kNGold, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Official Notice Board Preview
            Expanded(
              flex: 4,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // School Name
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _placed[0] != null ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _placed[0] ?? '[ School Name Slot ]',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _placed[0] != null ? Colors.black : Colors.black26,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // NOTICE Header
                      Text(
                        _placed[1] ?? '[ NOTICE ]',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                          color: _placed[1] != null ? const Color(0xFFDC2626) : Colors.black26,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Headline
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        color: _placed[2] != null ? const Color(0xFFFEE2E2) : const Color(0xFFF3F4F6),
                        child: Text(
                          _placed[2] ?? '[ Headline Slot ]',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _placed[2] != null ? Colors.black : Colors.black26,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Date & Venue
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _placed[3] ?? '[ Date & Venue Slot ]',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: _placed[3] != null ? Colors.black87 : Colors.black26,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Signatory
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _placed[4] ?? '[ Signatory Slot ]',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _placed[4] != null ? Colors.black : Colors.black26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Word Bank Options
            if (_currentStep < _kNoticeSteps.length)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                decoration: BoxDecoration(
                  color: kNCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: kNAccent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose the best text for ${_kNoticeSteps[_currentStep].label}:',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final opt in _kNoticeSteps[_currentStep].options)
                          GestureDetector(
                            onTap: () => _onOptionTap(opt),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: kNBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kNAccent, width: 1.5),
                              ),
                              child: Text(
                                opt,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
    );
  }
}
