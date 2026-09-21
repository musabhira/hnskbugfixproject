import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SentencePuzzleItem {
  final String targetSentence;
  final List<String> scrambledWords;
  final String tip;
  final String category;
  final String translation;

  const SentencePuzzleItem({
    required this.targetSentence,
    required this.scrambledWords,
    required this.tip,
    this.category = 'Syntax Builder',
    this.translation = '',
  });
}

/// 🎮 Minimal Arcade Sentence Builder Game (സെന്റൻസ് ബിൽഡർ പസിൽ)
/// Features 3D arcade word blocks, streak multiplier, target drop runway,
/// audio pronunciation on demand, and seamless side navigation.
class PocketSentenceBuilderCard extends StatefulWidget {
  final int day;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text) onSpeak;
  final String stepNumber;

  const PocketSentenceBuilderCard({
    super.key,
    required this.day,
    required this.isCompleted,
    required this.onCompleted,
    required this.onSpeak,
    this.stepNumber = '3',
  });

  @override
  State<PocketSentenceBuilderCard> createState() =>
      _PocketSentenceBuilderCardState();
}

class _PocketSentenceBuilderCardState extends State<PocketSentenceBuilderCard> {
  int _currentPuzzleIndex = 0;
  List<String> _assembledWords = [];
  List<String> _availableWords = [];
  bool _isSuccess = false;
  int _streak = 0;

  static const List<SentencePuzzleItem> kPuzzles = [
    SentencePuzzleItem(
      targetSentence: 'I drank hot tea in the morning.',
      scrambledWords: ['tea', 'drank', 'I', 'in the morning.', 'hot'],
      tip: '[Subject: I] ➔ [Action: drank] ➔ [Object: hot tea] ➔ [Time: in the morning]',
      translation: 'ഞാൻ രാവിലെ ചൂടുചായ കുടിച്ചു.',
    ),
    SentencePuzzleItem(
      targetSentence: 'Did you call the client yesterday?',
      scrambledWords: ['call', 'yesterday?', 'Did', 'the client', 'you'],
      tip: '[Did] ➔ [Subject: you] ➔ [Base Verb: call] ➔ [Target: the client]',
      translation: 'നീ ഇന്നലെ ക്ലയന്റിനെ വിളിച്ചോ?',
    ),
    SentencePuzzleItem(
      targetSentence: 'Could you please share the project details?',
      scrambledWords: [
        'share',
        'Could you',
        'the project details?',
        'please'
      ],
      tip: '[Could you] ➔ [Polite: please] ➔ [Action: share] ➔ [Target]',
      translation: 'ദയവായി പ്രോജക്റ്റ് വിവരങ്ങൾ ഷെയർ ചെയ്യാമോ?',
    ),
    SentencePuzzleItem(
      targetSentence: 'We will launch the new feature tomorrow.',
      scrambledWords: ['the new feature', 'We will', 'tomorrow.', 'launch'],
      tip: '[Subject: We will] ➔ [Action: launch] ➔ [Target] ➔ [Time: tomorrow]',
      translation: 'ഞങ്ങൾ നാളെ പുതിയ ഫീച്ചർ ലോഞ്ച് ചെയ്യും.',
    ),
    SentencePuzzleItem(
      targetSentence: 'She has completed the presentation successfully.',
      scrambledWords: [
        'the presentation',
        'has completed',
        'successfully.',
        'She'
      ],
      tip: '[Subject: She] ➔ [Has + V3: has completed] ➔ [Object] ➔ [Adverb]',
      translation: 'അവൾ പ്രസന്റേഷൻ വിജയകരമായി പൂർത്തിയാക്കി.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initPuzzle();
  }

  void _initPuzzle() {
    final puzzle = kPuzzles[_currentPuzzleIndex % kPuzzles.length];
    _availableWords = List<String>.from(puzzle.scrambledWords);
    _assembledWords = [];
    _isSuccess = false;
  }

  void _selectWord(String word) {
    HapticFeedback.selectionClick();
    setState(() {
      _availableWords.remove(word);
      _assembledWords.add(word);
    });
    _checkAnswer();
  }

  void _unselectWord(String word) {
    HapticFeedback.selectionClick();
    setState(() {
      _assembledWords.remove(word);
      _availableWords.add(word);
      _isSuccess = false;
    });
  }

  void _resetPuzzle() {
    HapticFeedback.lightImpact();
    setState(() {
      _initPuzzle();
    });
  }

  void _checkAnswer() {
    final puzzle = kPuzzles[_currentPuzzleIndex % kPuzzles.length];
    final currentText = _assembledWords.join(' ').trim();
    if (currentText == puzzle.targetSentence.trim()) {
      setState(() {
        _isSuccess = true;
        _streak++;
      });
      HapticFeedback.heavyImpact();
      if (_streak >= 2 && !widget.isCompleted) {
        widget.onCompleted(true);
      }
    }
  }

  void _nextPuzzle() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentPuzzleIndex = (_currentPuzzleIndex + 1) % kPuzzles.length;
      _initPuzzle();
    });
  }

  void _prevPuzzle() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentPuzzleIndex =
          (_currentPuzzleIndex - 1 + kPuzzles.length) % kPuzzles.length;
      _initPuzzle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = kPuzzles[_currentPuzzleIndex % kPuzzles.length];
    final totalPuzzles = kPuzzles.length;
    final puzzleNumber = (_currentPuzzleIndex % totalPuzzles) + 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17), // Minimal, plain dark game canvas
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFF00E5FF).withValues(alpha: 0.4),
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF00E5FF))
                .withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP GAME HUD BAR ─────────────────────────────────────────────
          Row(
            children: [
              // Step & Stage Capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.stepNumber.isNotEmpty
                      ? 'STEP ${widget.stepNumber} • GAME'
                      : 'BUILDER GAME',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Stage Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  'STAGE $puzzleNumber / $totalPuzzles',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF38BDF8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              // Streak Flame Multiplier
              if (_streak > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9100).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFF9100).withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        'x$_streak STREAK',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFB300),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Quick Side Navigation Controls in HUD
              InkWell(
                onTap: _prevPuzzle,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      color: Colors.white70, size: 18),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: _nextPuzzle,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: Colors.white70, size: 18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── TITLE & SUBTITLE ─────────────────────────────────────────────
          Text(
            'Sentence Builder Puzzle 🧩',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          if (puzzle.translation.isNotEmpty)
            Text(
              '🗣️ Target Meaning: "${puzzle.translation}"',
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),

          const SizedBox(height: 10),

          // ── MISSION BLUEPRINT HINT ───────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    puzzle.tip,
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFFBAE6FD),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── TARGET DROP RUNWAY (ASSEMBLY ARENA) ───────────────────────────
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 74),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isSuccess
                  ? const Color(0xFF064E3B).withValues(alpha: 0.45)
                  : const Color(0xFF060911),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isSuccess
                    ? const Color(0xFF10B981)
                    : const Color(0xFF00E5FF).withValues(alpha: 0.35),
                width: _isSuccess ? 2.0 : 1.2,
              ),
            ),
            child: _assembledWords.isEmpty
                ? Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.touch_app_rounded,
                            color: Colors.white24, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Tap word blocks below in order ➔',
                          style: GoogleFonts.inter(
                            color: Colors.white38,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _assembledWords.map((word) {
                      return InkWell(
                        onTap: () => _unselectWord(word),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isSuccess
                                ? const Color(0xFF10B981)
                                : const Color(0xFF00E5FF),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: (_isSuccess
                                        ? const Color(0xFF059669)
                                        : const Color(0xFF0284C7))
                                    .withValues(alpha: 0.8),
                                offset: const Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                word,
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              if (!_isSuccess) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.close_rounded,
                                    color: Colors.black45, size: 14),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          // ── VICTORY CELEBRATION BANNER ───────────────────────────────────
          if (_isSuccess) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF10B981), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PERFECT COMBO! Correct sentence order! 🎉',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF6EE7B7),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => widget.onSpeak(puzzle.targetSentence),
                    icon: const Icon(Icons.volume_up_rounded,
                        color: Color(0xFFFFD700), size: 17),
                    label: Text(
                      'LISTEN',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ── SCRAMBLED 3D ARCADE WORD BLOCKS ──────────────────────────────
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: _availableWords.map((word) {
                return InkWell(
                  onTap: () => _selectWord(word),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF0F172A),
                          offset: Offset(0, 3.5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      word,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── BOTTOM ACTION CONTROLS (SIDE PREV / RESET / NEXT) ────────────
          Row(
            children: [
              // PREV STAGE
              OutlinedButton.icon(
                onPressed: _prevPuzzle,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 14),
                label: Text(
                  'PREV',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // RESET BUTTON
              IconButton(
                onPressed: _resetPuzzle,
                tooltip: 'Reset current puzzle',
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white60, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.white12),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // NEXT PUZZLE or VERIFY BUTTON
              if (_isSuccess)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextPuzzle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text(
                      puzzleNumber < totalPuzzles
                          ? 'NEXT PUZZLE (${puzzleNumber + 1}/$totalPuzzles) ➔'
                          : 'PLAY AGAIN ➔',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onCompleted(true);
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '🏗️ Sentence Builder Puzzle Mastered (+25 PTS) ✓'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isCompleted
                          ? const Color(0xFF10B981)
                          : const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      widget.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.verified_rounded,
                      size: 16,
                    ),
                    label: Text(
                      widget.isCompleted
                          ? 'STAGE COMPLETED ✓'
                          : 'I ASSEMBLED SENTENCES ✓',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
