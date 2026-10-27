import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

const Color kEBg = Color(0xFF0F172A);
const Color kECard = Color(0xFF1E293B);
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

const List<_EmailRound> _kEmailRounds = [
  _EmailRound(
    recipient: 'Class Teacher',
    subjectCorrect: 'Leave Request for 14 March',
    subjectOptions: ['Leave Request for 14 March', 'hi', 'URGENT READ NOW'],
    greetingCorrect: "Dear Ma'am,",
    greetingOptions: ["Dear Ma'am,", 'Yo teacher!', 'Hey!'],
    bodyCorrect: 'I am unwell with fever today and kindly request leave.',
    bodyOptions: [
      'I am unwell with fever today and kindly request leave.',
      'not coming bye',
      'give me leave fast',
    ],
  ),
];

/// 📧 Step 10: Gamified Email Etiquette Game (Word-Bank Snap Engine)
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
  int _step = 0; // 0=subject, 1=greeting, 2=body, 3=ready to send
  int _xp = 30;
  String? _selectedSubject;
  String? _selectedGreeting;
  String? _selectedBody;
  bool _isSent = false;

  _EmailRound get _round => _kEmailRounds[0];

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
              const SizedBox(height: 16),
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
      backgroundColor: kEBg,
      appBar: AppBar(
        backgroundColor: kEBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Email Etiquette 📧',
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
                  color: kECard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kEGold.withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: kEGold, size: 16),
                    Text(' $_xp XP', style: GoogleFonts.outfit(color: kEGold, fontWeight: FontWeight.bold, fontSize: 13)),
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
            // Visual Email Composer Card
            Expanded(
              flex: 4,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                          const Icon(Icons.mail_outline_rounded, color: Color(0xFF2563EB)),
                          const SizedBox(width: 8),
                          Text(
                            'To: ${_round.recipient}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),

                      // Subject Line
                      Text(
                        'Subject:',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedSubject != null ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedSubject != null ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Text(
                          _selectedSubject ?? '[ Choose a polite Subject line below ]',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _selectedSubject != null ? const Color(0xFF1E3A8A) : Colors.black26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Greeting
                      Text(
                        'Greeting:',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _selectedGreeting != null ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedGreeting != null ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Text(
                          _selectedGreeting ?? '[ Polite Greeting ]',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _selectedGreeting != null ? const Color(0xFF065F46) : Colors.black26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Body
                      Text(
                        'Message Body:',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedBody != null ? const Color(0xFFFFFBEB) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedBody != null ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Text(
                          _selectedBody ?? '[ Polite message sentence ]',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _selectedBody != null ? const Color(0xFF78350F) : Colors.black26,
                          ),
                        ),
                      ),
                      const Spacer(),

                      // Sign off
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Regards,\nAarav, Class 7B',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Word Bank Options
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: kECard,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: kECy.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_step < 3) ...[
                    Text(
                      _step == 0
                          ? 'Step 1: Pick a polite Subject line:'
                          : _step == 1
                              ? 'Step 2: Pick a polite Greeting:'
                              : 'Step 3: Pick a polite Body sentence:',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: kEBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kECy, width: 1.5),
                              ),
                              child: Text(
                                opt,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kEGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSent ? null : _onSendEmail,
                        icon: const Icon(Icons.send_rounded),
                        label: Text(
                          'SEND POLITE EMAIL 🚀',
                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
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
    );
  }
}
