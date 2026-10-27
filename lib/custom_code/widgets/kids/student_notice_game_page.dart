import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/flame_icon_widget.dart';

const Color kNBg = Color(0xFF0B111E);
const Color kNCard = Color(0xFF141C2F);
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

/// 📢 Step 9: Gamified Notice Masterclass (Sleek Dark Board & Flame Powered)
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FlameIcon(size: 24),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kNCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kNGold.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, color: kNGold, size: 15),
                      Text(' $_xp XP', style: GoogleFonts.outfit(color: kNGold, fontWeight: FontWeight.bold, fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
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
                    'Step ${_currentStep + 1} of ${_kNoticeSteps.length}: ${_currentStep < _kNoticeSteps.length ? _kNoticeSteps[_currentStep].label : 'Notice Complete!'}',
                    style: GoogleFonts.outfit(color: kNGold, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Sleek Dark Chalkboard Notice Board (Zero Stark White)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kNGold.withValues(alpha: 0.5), width: 2),
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
                      // School Name
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _placed[0] != null ? const Color(0xFF0F766E).withValues(alpha: 0.3) : Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _placed[0] != null ? const Color(0xFF14B8A6) : Colors.white24),
                        ),
                        child: Text(
                          _placed[0] ?? '[ 1. School Name Slot ]',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _placed[0] != null ? const Color(0xFF5EEAD4) : Colors.white38,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // NOTICE Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        decoration: BoxDecoration(
                          color: _placed[1] != null ? kNRed.withValues(alpha: 0.25) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: _placed[1] != null ? Border.all(color: kNRed, width: 1.5) : null,
                        ),
                        child: Text(
                          _placed[1] ?? '[ 2. NOTICE HEADER ]',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: _placed[1] != null ? const Color(0xFFFCA5A5) : Colors.white38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Headline
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _placed[2] != null ? kNGold.withValues(alpha: 0.2) : Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _placed[2] != null ? kNGold : Colors.white24),
                        ),
                        child: Text(
                          _placed[2] ?? '[ 3. Headline Slot ]',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _placed[2] != null ? kNGold : Colors.white38,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Date & Venue
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _placed[3] != null ? '📅 ${_placed[3]}' : '[ 4. Date & Venue Slot ]',
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: _placed[3] != null ? Colors.white : Colors.white38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Signatory
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _placed[4] != null ? '✍️ ${_placed[4]}' : '[ 5. Signatory Slot ]',
                          style: GoogleFonts.outfit(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: _placed[4] != null ? const Color(0xFF67E8F9) : Colors.white38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Word Bank Options Dock
            if (_currentStep < _kNoticeSteps.length)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: kNCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: kNAccent.withValues(alpha: 0.35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose the best text for ${_kNoticeSteps[_currentStep].label}:',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
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
