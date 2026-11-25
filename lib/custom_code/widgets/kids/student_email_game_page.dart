import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/flame_icon_widget.dart';

import 'package:pocket_mates_app/custom_code/widgets/kids/student_creative_writing_90day_curriculum.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';

const Color kEBg = Color(0xFF0B111E);
const Color kECard = Color(0xFF141C2F);
const Color kEGold = Color(0xFFFFD700);
const Color kECy = Color(0xFF38BDF8);
const Color kEEm = Color(0xFF10B981);

class _EmailRound {
  final String recipient;
  final String subjectCorrect;
  final List<String> subjectOptions;
  final String greetingCorrect;
  final List<String> greetingOptions;
  final String bodyCorrect;
  final List<String> bodyOptions;

  const _EmailRound({
    required this.recipient,
    required this.subjectCorrect,
    required this.subjectOptions,
    required this.greetingCorrect,
    required this.greetingOptions,
    required this.bodyCorrect,
    required this.bodyOptions,
  });
}

/// 📧 Step 10: Gamified Email Etiquette Game (Flame Powered & Overflow Safe)
class StudentEmailGamePage extends StatefulWidget {
  final int day;
  final int stepIndex;
  final String? userId;
  final void Function(int finishedStep)? onStepFinished;

  const StudentEmailGamePage({
    super.key,
    this.day = 1,
    this.stepIndex = 10,
    this.userId,
    this.onStepFinished,
  });

  static Future<void> show(
    BuildContext context, {
    int day = 1,
    int stepIndex = 10,
    String? userId,
    void Function(int finishedStep)? onStepFinished,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentEmailGamePage(
          day: day,
          stepIndex: stepIndex,
          userId: userId,
          onStepFinished: onStepFinished,
        ),
      ),
    );
  }

  @override
  State<StudentEmailGamePage> createState() => _StudentEmailGameState();
}

class _StudentEmailGameState extends State<StudentEmailGamePage> {
  final FlutterTts _tts = FlutterTts();
  late final _EmailRound _round;
  int _step = 0; // 0=subject, 1=greeting, 2=body, 3=ready to send
  int _xp = 30;
  String? _selectedSubject;
  String? _selectedGreeting;
  String? _selectedBody;
  bool _isSent = false;

  @override
  void initState() {
    super.initState();
    final dayData = StudentCreativeWriting90DayCurriculum.getEmailData(widget.day);
    _round = _EmailRound(
      recipient: dayData.recipient,
      subjectCorrect: dayData.subjectCorrect,
      subjectOptions: dayData.subjectOptions,
      greetingCorrect: dayData.greetingCorrect,
      greetingOptions: dayData.greetingOptions,
      bodyCorrect: dayData.bodyCorrect,
      bodyOptions: dayData.bodyOptions,
    );
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
    if (_step == 0) {
      if (opt == _round.subjectCorrect) {
        PocketGameSfx.instance.playSnapCorrect();
        _tts.speak(opt);
        setState(() {
          _selectedSubject = opt;
          _step = 1;
        });
      } else {
        PocketGameSfx.instance.playErrorBuzz();
      }
    } else if (_step == 1) {
      if (opt == _round.greetingCorrect) {
        PocketGameSfx.instance.playSnapCorrect();
        _tts.speak(opt);
        setState(() {
          _selectedGreeting = opt;
          _step = 2;
        });
      } else {
        PocketGameSfx.instance.playErrorBuzz();
      }
    } else if (_step == 2) {
      if (opt == _round.bodyCorrect) {
        PocketGameSfx.instance.playSnapCorrect();
        _tts.speak(opt);
        setState(() {
          _selectedBody = opt;
          _step = 3;
        });
      } else {
        PocketGameSfx.instance.playErrorBuzz();
      }
    }
  }

  Future<void> _onSendEmail() async {
    HapticFeedback.heavyImpact();
    PocketGameSfx.instance.playVictory();
    setState(() => _isSent = true);
    _tts.speak('Email sent politely to teacher!');

    setState(() => _xp += 30);
    widget.onStepFinished?.call(widget.stepIndex);

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: kECard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: kEGold, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🚀 ✉️ ✨', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text(
                'Polite Email Sent!',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kEGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '+30 XP  •  ⭐⭐⭐',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kEEm,
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
                  backgroundColor: kEGold,
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
      backgroundColor: const Color(0xFF141210),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141210),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Email',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: PocketBannerAdWidget(
          margin: EdgeInsets.symmetric(vertical: 4),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Editorial Story-Card Style Mail Sheet
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF8EE),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFD4A373).withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD95D39).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.mail_outline_rounded,
                            color: Color(0xFFD95D39),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'To: ${_round.recipient}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              color: const Color(0xFF1C1917),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      color: const Color(0xFFD4A373).withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 14),

                    // Subject Line
                    Text(
                      'SUBJECT',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: const Color(0xFF7A5C3D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedSubject != null
                            ? const Color(0xFFD4A373).withValues(alpha: 0.18)
                            : const Color(0xFFF3EAD8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedSubject != null
                              ? const Color(0xFFB45309)
                              : (_step == 0
                                  ? const Color(0xFFD95D39)
                                  : const Color(0xFFD4A373).withValues(alpha: 0.4)),
                          width: _step == 0 ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        _selectedSubject ?? 'Choose a polite Subject line below',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: _selectedSubject != null
                              ? const Color(0xFF1C1917)
                              : const Color(0xFF8C7456),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Greeting
                    Text(
                      'GREETING',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: const Color(0xFF7A5C3D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: _selectedGreeting != null
                            ? const Color(0xFF0F766E).withValues(alpha: 0.1)
                            : const Color(0xFFF3EAD8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedGreeting != null
                              ? const Color(0xFF0F766E)
                              : (_step == 1
                                  ? const Color(0xFFD95D39)
                                  : const Color(0xFFD4A373).withValues(alpha: 0.4)),
                          width: _step == 1 ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        _selectedGreeting ?? 'Choose a polite Greeting',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: _selectedGreeting != null
                              ? const Color(0xFF0F766E)
                              : const Color(0xFF8C7456),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Body
                    Text(
                      'MESSAGE BODY',
                      style: GoogleFonts.outfit(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: const Color(0xFF7A5C3D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        color: _selectedBody != null
                            ? const Color(0xFFD4A373).withValues(alpha: 0.18)
                            : const Color(0xFFF3EAD8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedBody != null
                              ? const Color(0xFFB45309)
                              : (_step == 2
                                  ? const Color(0xFFD95D39)
                                  : const Color(0xFFD4A373).withValues(alpha: 0.4)),
                          width: _step == 2 ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        _selectedBody ?? 'Choose a polite message sentence',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: _selectedBody != null
                              ? const Color(0xFF1C1917)
                              : const Color(0xFF8C7456),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign off
                    Text(
                      'Regards,\nStudent',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF57534E),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Word Bank Options Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_step < 3) ...[
                      Text(
                        _step == 0
                            ? 'Step 1 • Pick Subject'
                            : _step == 1
                                ? 'Step 2 • Pick Greeting'
                                : 'Step 3 • Pick Message',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFD4A373),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final opt in (_step == 0
                              ? _round.subjectOptions
                              : _step == 1
                                  ? _round.greetingOptions
                                  : _round.bodyOptions))
                            GestureDetector(
                              onTap: () => _onOptionTap(opt),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF292524),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFD4A373).withValues(alpha: 0.45),
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  opt,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD95D39),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isSent ? null : _onSendEmail,
                          icon: const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            'Send Email',
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
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
