import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/flame_icon_widget.dart';

const Color kNBg = Color(0xFF0B111E);
const Color kNCard = Color(0xFF141C2F);
const Color kNGold = Color(0xFFFFD700);
const Color kNRed = Color(0xFFEF4444);
const Color kNCy = Color(0xFF38BDF8);
const Color kNEm = Color(0xFF10B981);

class _NoticeRound {
  final String title;
  final String category;
  final List<String> targetParts;
  final List<String> partLabels;
  final List<String> distractors;

  const _NoticeRound({
    required this.title,
    required this.category,
    required this.targetParts,
    required this.partLabels,
    required this.distractors,
  });
}

const List<_NoticeRound> _kNoticeRounds = [
  _NoticeRound(
    title: '🏆 Annual Sports Meet Notice',
    category: 'School Event Notice',
    partLabels: ['1. Institution', '2. Header', '3. Event Title', '4. Date & Ground'],
    targetParts: [
      'GREENFIELD PUBLIC SCHOOL',
      'NOTICE',
      'ANNUAL SPORTS MEET',
      '12 December • School Ground',
    ],
    distractors: ['Cinema Hall', 'Tomorrow Morning'],
  ),
  _NoticeRound(
    title: '🎒 Lost & Found Notice',
    category: 'Lost & Found Notice',
    partLabels: ['1. Institution', '2. Header', '3. Item Lost', '4. Venue & Contact'],
    targetParts: [
      'SUNRISE MODEL SCHOOL',
      'NOTICE',
      'LOST: BLUE WATER BOTTLE',
      'Room 12 • Contact Class 7',
    ],
    distractors: ['Toy Shop', 'Call Police'],
  ),
];

/// 📢 Step 9: Gamified Notice Masterclass (Interactive Bulletin Board Builder)
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

class _StudentNoticeGameState extends State<StudentNoticeGamePage>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  int _roundIdx = 0;
  int _xp = 30;
  int _placedCount = 0;
  int _wrongCount = 0;
  late List<String> _bankTiles;
  late final AnimationController _shakeCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  _NoticeRound get _currentRound => _kNoticeRounds[_roundIdx];

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
    final targets = _currentRound.targetParts;
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

  void _onTileTap(String text) {
    final targetParts = _currentRound.targetParts;
    if (_placedCount >= targetParts.length) return;

    final expected = targetParts[_placedCount];
    if (text == expected) {
      PocketGameSfx.instance.playSnapCorrect();
      _tts.speak(text);
      setState(() {
        _placedCount++;
        _bankTiles.remove(text);
      });

      if (_placedCount == targetParts.length) {
        _onNoticeComplete();
      }
    } else {
      _wrongCount++;
      _triggerErrorShake();
    }
  }

  Future<void> _onNoticeComplete() async {
    PocketGameSfx.instance.playVictory();
    final fullText = _currentRound.targetParts.join('. ');
    await Future.delayed(const Duration(milliseconds: 250));
    _tts.speak(fullText);

    final roundXp = math.max(15, 30 - (_wrongCount * 5));
    setState(() => _xp += roundXp);

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
                'Notice Approved & Published!',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kNGold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '+$roundXp XP  •  ⭐⭐⭐',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kNEm,
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
                  if (_roundIdx < _kNoticeRounds.length - 1) {
                    setState(() {
                      _roundIdx++;
                      _setupRound();
                    });
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                child: Text(
                  _roundIdx < _kNoticeRounds.length - 1 ? 'NEXT NOTICE ▶' : 'FINISH QUEST 🏆',
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
    const colors = [kNCy, kNEm, kNGold, Color(0xFFFF9100), Color(0xFFA855F7)];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final targets = _currentRound.targetParts;

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
        child: AnimatedBuilder(
          animation: _shakeCtrl,
          builder: (context, child) {
            final offset = math.sin(_shakeCtrl.value * math.pi * 6) * 8 * (1 - _shakeCtrl.value);
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: Column(
            children: [
              // Scrollable Notice Board Workspace (Zero Overflow)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Notice ${_roundIdx + 1} of ${_kNoticeRounds.length}: ${_currentRound.category}',
                            style: GoogleFonts.outfit(color: kNGold, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const Spacer(),
                          Text(
                            '${_placedCount}/${targets.length} Slotted',
                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Interactive Bulletin Board Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kNGold.withValues(alpha: 0.45), width: 2),
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
                            // Push Pin
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.push_pin_rounded, color: kNRed, size: 20),
                                SizedBox(width: 4),
                                Text('OFFICIAL BULLETIN BOARD', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Slot 1: Institution Name
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _placedCount > 0
                                    ? const Color(0xFF0F766E).withValues(alpha: 0.35)
                                    : Colors.white10,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _placedCount > 0 ? const Color(0xFF14B8A6) : Colors.white24,
                                  width: _placedCount == 0 ? 1.8 : 1,
                                ),
                              ),
                              child: Text(
                                _placedCount > 0 ? targets[0] : '[ 1. Tap School Name from bank ]',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: _placedCount > 0 ? const Color(0xFF5EEAD4) : Colors.white38,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Slot 2: NOTICE Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                              decoration: BoxDecoration(
                                color: _placedCount > 1
                                    ? kNRed.withValues(alpha: 0.25)
                                    : Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _placedCount > 1 ? kNRed : Colors.white24,
                                  width: _placedCount == 1 ? 1.8 : 1,
                                ),
                              ),
                              child: Text(
                                _placedCount > 1 ? targets[1] : '[ 2. NOTICE ]',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: _placedCount > 1 ? const Color(0xFFFCA5A5) : Colors.white38,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Slot 3: Event Title / Headline
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _placedCount > 2
                                    ? kNGold.withValues(alpha: 0.2)
                                    : Colors.white10,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _placedCount > 2 ? kNGold : Colors.white24,
                                  width: _placedCount == 2 ? 1.8 : 1,
                                ),
                              ),
                              child: Text(
                                _placedCount > 2 ? targets[2] : '[ 3. Tap Headline from bank ]',
                                style: GoogleFonts.outfit(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: _placedCount > 2 ? kNGold : Colors.white38,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Slot 4: Date & Venue
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _placedCount > 3 ? Colors.white12 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _placedCount > 3 ? Colors.white24 : Colors.white12,
                                  ),
                                ),
                                child: Text(
                                  _placedCount > 3 ? '📅 ${targets[3]}' : '[ 4. Tap Date & Venue from bank ]',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _placedCount > 3 ? Colors.white : Colors.white38,
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
              ),

              // Interactive Word Bank Dock at Bottom
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: kNCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: kNGold.withValues(alpha: 0.35)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _placedCount < targets.length
                          ? 'Tap next block: ${_currentRound.partLabels[_placedCount]}'
                          : '🎉 Notice Complete!',
                      style: GoogleFonts.outfit(color: kNGold, fontSize: 12.5, fontWeight: FontWeight.bold),
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
      ),
    );
  }
}
