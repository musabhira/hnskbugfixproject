import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SentencePuzzleItem {
  final String targetSentence;
  final List<String> scrambledWords;
  final String tip;
  final String category;

  const SentencePuzzleItem({
    required this.targetSentence,
    required this.scrambledWords,
    required this.tip,
    this.category = '1-2-3 English Syntax',
  });
}

/// 🏗️ Sentence Builder Game / Code Block Puzzle (സെന്റൻസ് ബിൽഡർ)
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
      tip: 'Order: [1: Subject] ➔ [2: Action] ➔ [3: Target] ➔ [4: Time]',
    ),
    SentencePuzzleItem(
      targetSentence: 'Did you call the client yesterday?',
      scrambledWords: ['call', 'yesterday?', 'Did', 'the client', 'you'],
      tip: 'Order: [Did] ➔ [Subject] ➔ [Base Verb] ➔ [Object]',
    ),
    SentencePuzzleItem(
      targetSentence: 'Could you please share the project details?',
      scrambledWords: [
        'share',
        'Could you',
        'the project details?',
        'please'
      ],
      tip: 'Order: [Could you] ➔ [Polite marker] ➔ [Verb] ➔ [Target]',
    ),
    SentencePuzzleItem(
      targetSentence: 'We will launch the new feature tomorrow.',
      scrambledWords: ['the new feature', 'We will', 'tomorrow.', 'launch'],
      tip: 'Order: [Subject + Will] ➔ [Action] ➔ [Target] ➔ [Time]',
    ),
    SentencePuzzleItem(
      targetSentence: 'She has completed the presentation successfully.',
      scrambledWords: [
        'the presentation',
        'has completed',
        'successfully.',
        'She'
      ],
      tip: 'Order: [Subject] ➔ [Have/Has + V3] ➔ [Object] ➔ [Adverb]',
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
      widget.onSpeak(puzzle.targetSentence);
      if (_streak >= 2 && !widget.isCompleted) {
        widget.onCompleted(true);
      }
    }
  }

  void _nextPuzzle() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentPuzzleIndex++;
      _initPuzzle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = kPuzzles[_currentPuzzleIndex % kPuzzles.length];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFF38BDF8).withValues(alpha: 0.35),
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.stepNumber.isNotEmpty
                      ? 'STEP ${widget.stepNumber}'
                      : '🧩 CODE BUILDER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('🏗️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Sentence Builder (വാചക പസിൽ)',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (_streak > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFF9800)),
                  ),
                  child: Text(
                    '🔥 x$_streak',
                    style: const TextStyle(
                      color: Color(0xFFFF9800),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (widget.isCompleted)
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tap word blocks in correct 1-2-3 English order to assemble the sentence!',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),

          // Tip pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    puzzle.tip,
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFFBAE6FD),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Assembly Arena / Drop Target Box
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isSuccess
                  ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                  : const Color(0xFF070B14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isSuccess
                    ? const Color(0xFF10B981)
                    : const Color(0xFF38BDF8).withValues(alpha: 0.3),
                width: _isSuccess ? 1.5 : 1.0,
              ),
            ),
            child: _assembledWords.isEmpty
                ? Center(
                    child: Text(
                      'Tap blocks below in order ➔',
                      style: GoogleFonts.inter(
                        color: Colors.white30,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _assembledWords.map((word) {
                      return InkWell(
                        onTap: () => _unselectWord(word),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isSuccess
                                ? const Color(0xFF10B981)
                                : const Color(0xFF38BDF8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                word,
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              if (!_isSuccess) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.close_rounded,
                                    color: Colors.black54, size: 13),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          if (_isSuccess) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'PERFECT! Correct 1-2-3 sentence logic!',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => widget.onSpeak(puzzle.targetSentence),
                  icon: const Icon(Icons.volume_up_rounded,
                      color: Color(0xFFFFD700), size: 16),
                  label: const Text(
                    'REPLAY',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 11,
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
          ],

          const SizedBox(height: 12),

          // Scrambled Available Word Blocks
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableWords.map((word) {
              return InkWell(
                onTap: () => _selectWord(word),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    word,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Actions Row: Reset / Next / Verify
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _resetPuzzle,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white60,
                  side: const BorderSide(color: Colors.white24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('RESET', style: TextStyle(fontSize: 11)),
              ),
              const SizedBox(width: 8),
              if (_isSuccess)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextPuzzle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text(
                      'NEXT PUZZLE ➔',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                          : const Color(0xFF38BDF8),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                          ? 'PUZZLES VERIFIED ✓'
                          : 'I ASSEMBLED SENTENCES ✓',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
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
