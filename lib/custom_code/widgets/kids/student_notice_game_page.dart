import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/flame_icon_widget.dart';

import 'package:pocket_mates_app/custom_code/widgets/kids/student_creative_writing_90day_curriculum.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_admob_service.dart';

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
  late final List<_NoticeRound> _rounds;
  int _roundIdx = 0;
  int _xp = 30;
  int _placedCount = 0;
  int _wrongCount = 0;
  late List<String> _bankTiles;
  late final AnimationController _shakeCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  _NoticeRound get _currentRound => _rounds[_roundIdx];

  @override
  void initState() {
    super.initState();
    final dayData = StudentCreativeWriting90DayCurriculum.getNoticeData(widget.day);
    _rounds = [
      _NoticeRound(
        title: dayData.title,
        category: dayData.category,
        partLabels: dayData.partLabels,
        targetParts: dayData.targetParts,
        distractors: dayData.distractors,
      ),
    ];
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
                  backgroundColor: kNGold,
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
                  _roundIdx < _rounds.length - 1 ? 'NEXT NOTICE ▶' : 'FINISH QUEST 🏆',
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
      backgroundColor: const Color(0xFF141210),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141210),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Notice Masterclass',
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
        child: AnimatedBuilder(
          animation: _shakeCtrl,
          builder: (context, child) {
            final offset = math.sin(_shakeCtrl.value * math.pi * 6) * 8 * (1 - _shakeCtrl.value);
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Minimal Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF221E1A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        '${_currentRound.category.toUpperCase()} • ${_roundIdx + 1}/${_rounds.length}',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFD4A373),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$_placedCount / ${targets.length} Placed',
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Minimal Editorial Story-Card Style Notice Sheet
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF8EE),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.55), width: 1.5),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.push_pin_rounded, color: Color(0xFFD95D39), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'OFFICIAL NOTICE BOARD',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF7A5C3D),
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(color: const Color(0xFFD4A373).withValues(alpha: 0.35), height: 1),
                      const SizedBox(height: 16),

                      // Slot 1: Institution Name
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _placedCount > 0
                              ? const Color(0xFF0F766E).withValues(alpha: 0.1)
                              : const Color(0xFFF3EAD8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _placedCount > 0
                                ? const Color(0xFF0F766E)
                                : (_placedCount == 0
                                    ? const Color(0xFFD95D39)
                                    : const Color(0xFFD4A373).withValues(alpha: 0.4)),
                            width: _placedCount == 0 ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          _placedCount > 0 ? targets[0] : '1. Tap Institution / School Name',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: _placedCount > 0 ? const Color(0xFF0F766E) : const Color(0xFF8C7456),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Slot 2: NOTICE Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 7),
                        decoration: BoxDecoration(
                          color: _placedCount > 1
                              ? const Color(0xFFD95D39).withValues(alpha: 0.12)
                              : const Color(0xFFF3EAD8),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _placedCount > 1
                                ? const Color(0xFFD95D39)
                                : (_placedCount == 1
                                    ? const Color(0xFFD95D39)
                                    : const Color(0xFFD4A373).withValues(alpha: 0.4)),
                            width: _placedCount == 1 ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          _placedCount > 1 ? targets[1] : '2. NOTICE',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.2,
                            color: _placedCount > 1 ? const Color(0xFFB45309) : const Color(0xFF8C7456),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Slot 3: Event Title / Headline
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _placedCount > 2
                              ? const Color(0xFFD4A373).withValues(alpha: 0.2)
                              : const Color(0xFFF3EAD8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _placedCount > 2
                                ? const Color(0xFFB45309)
                                : (_placedCount == 2
                                    ? const Color(0xFFD95D39)
                                    : const Color(0xFFD4A373).withValues(alpha: 0.4)),
                            width: _placedCount == 2 ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          _placedCount > 2 ? targets[2] : '3. Tap Event Headline',
                          style: GoogleFonts.outfit(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: _placedCount > 2 ? const Color(0xFF292524) : const Color(0xFF8C7456),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Slot 4: Date & Venue
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: _placedCount > 3
                              ? const Color(0xFF292524).withValues(alpha: 0.06)
                              : const Color(0xFFF3EAD8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _placedCount > 3
                                ? const Color(0xFF7A5C3D)
                                : (_placedCount == 3
                                    ? const Color(0xFFD95D39)
                                    : const Color(0xFFD4A373).withValues(alpha: 0.4)),
                            width: _placedCount == 3 ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          _placedCount > 3 ? '📅 ${targets[3]}' : '4. Tap Date & Venue',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _placedCount > 3 ? const Color(0xFF292524) : const Color(0xFF8C7456),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Scrollable Word Bank Card
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
                      Row(
                        children: [
                          const Icon(Icons.touch_app_rounded, color: Color(0xFFD4A373), size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _placedCount < targets.length
                                  ? 'Word Bank • Next: ${_currentRound.partLabels[_placedCount]}'
                                  : '🎉 Notice Complete!',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFD4A373),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (int i = 0; i < _bankTiles.length; i++)
                            GestureDetector(
                              onTap: () => _onTileTap(_bankTiles[i]),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                                decoration: BoxDecoration(
                                  color: _getTileColor(i).withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _getTileColor(i).withValues(alpha: 0.75),
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  _bankTiles[i],
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
