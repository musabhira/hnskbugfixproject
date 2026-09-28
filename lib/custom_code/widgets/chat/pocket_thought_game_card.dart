import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pocket_reels_game_engine.dart';
import '../learning_60day/pocket_fortress_defense_service.dart';

/// 🎮 PocketThoughtGameCard
/// Interactive micro-game embedded inside robot thought cards.
/// Supports Sentence Builder, Gap Fill, Smart Reply & Error Spotting with instant rewards.
class PocketThoughtGameCard extends StatefulWidget {
  final ReelGameCard card;
  final String authorName;

  const PocketThoughtGameCard({
    super.key,
    required this.card,
    this.authorName = 'Robot Mate',
  });

  @override
  State<PocketThoughtGameCard> createState() => _PocketThoughtGameCardState();
}

class _PocketThoughtGameCardState extends State<PocketThoughtGameCard> {
  // Sentence builder state
  List<String> _assembledWords = [];
  List<String> _availableWords = [];
  bool? _isSentenceCorrect;
  bool _isSentenceChecked = false;

  // Multiple choice state (gapFill, smartReply, spotTheError, vocab)
  int? _selectedOptionIndex;
  bool _isOptionChecked = false;

  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _availableWords = List<String>.from(widget.card.options);
    _availableWords.shuffle();
    _checkIfPreviouslyCompleted();
  }

  Future<void> _checkIfPreviouslyCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool('pm_thought_game_solved_${widget.card.id}') ?? false;
      if (completed && mounted) {
        setState(() {
          _isCompleted = true;
          if (widget.card.gameType == ReelGameType.sentenceBuilder) {
            _assembledWords = widget.card.correctSentenceWords ?? widget.card.options;
            _availableWords = [];
            _isSentenceCorrect = true;
            _isSentenceChecked = true;
          } else {
            _selectedOptionIndex = widget.card.correctOptionIndex;
            _isOptionChecked = true;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _markSolved() async {
    setState(() => _isCompleted = true);
    HapticFeedback.heavyImpact();
    PocketFortressDefenseService.recordActivityPoints('game_challenge_solved');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pm_thought_game_solved_${widget.card.id}', true);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.6)
              : const Color(0xFFFFFC00).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFC00).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFFC00).withValues(alpha: 0.5), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.extension_rounded, size: 12, color: Color(0xFFFFFC00)),
                    const SizedBox(width: 4),
                    Text(
                      widget.card.category,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFFC00),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF10B981)),
                      const SizedBox(width: 3),
                      Text(
                        'Solved +15 FDC',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Game Body
          if (widget.card.gameType == ReelGameType.sentenceBuilder)
            _buildSentenceBuilder(isDark)
          else
            _buildMultipleChoice(isDark),

          // Native Language Explanation on Completion
          if ((_isSentenceChecked && _isSentenceCorrect == true) ||
              (_isOptionChecked && _selectedOptionIndex == widget.card.correctOptionIndex)) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.card.getExplanation('Malayalam'),
                      style: GoogleFonts.inter(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // 🧩 SENTENCE BUILDER GAME
  // =========================================================================
  Widget _buildSentenceBuilder(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sentence Assembled Area (Drop Zone)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isSentenceChecked
                  ? (_isSentenceCorrect == true ? const Color(0xFF10B981) : Colors.redAccent)
                  : (isDark ? Colors.white12 : Colors.black12),
              width: 1.2,
            ),
          ),
          child: _assembledWords.isEmpty
              ? Center(
                  child: Text(
                    'Tap words below to arrange the sentence...',
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 11.5,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _assembledWords.map((word) {
                    return GestureDetector(
                      onTap: _isCompleted
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _assembledWords.remove(word);
                                _availableWords.add(word);
                                _isSentenceChecked = false;
                              });
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFC00),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          word,
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 10),

        // Word Bank Chips
        if (_availableWords.isNotEmpty && !_isCompleted) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _availableWords.map((word) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _availableWords.remove(word);
                    _assembledWords.add(word);
                    _isSentenceChecked = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    word,
                    style: GoogleFonts.outfit(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
        ],

        // Check & Reset Buttons
        if (!_isCompleted)
          Row(
            children: [
              if (_assembledWords.isNotEmpty) ...[
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: _checkSentence,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFC00),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      child: Text(
                        'Check Answer ✨',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (_assembledWords.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  color: isDark ? Colors.white60 : Colors.black54,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _availableWords.addAll(_assembledWords);
                      _assembledWords.clear();
                      _isSentenceChecked = false;
                      _isSentenceCorrect = null;
                    });
                  },
                ),
            ],
          ),

        // Wrong feedback
        if (_isSentenceChecked && _isSentenceCorrect == false)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '⚠️ Order is slightly off! Tap words to rearrange.',
              style: GoogleFonts.inter(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  void _checkSentence() {
    final targetWords = widget.card.correctSentenceWords ?? widget.card.options;
    final isCorrect = _assembledWords.length == targetWords.length &&
        List.generate(_assembledWords.length, (i) => _assembledWords[i] == targetWords[i])
            .every((match) => match);

    setState(() {
      _isSentenceChecked = true;
      _isSentenceCorrect = isCorrect;
    });

    if (isCorrect) {
      _markSolved();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  // =========================================================================
  // 🔘 MULTIPLE CHOICE / GAP FILL / SMART REPLY
  // =========================================================================
  Widget _buildMultipleChoice(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.card.contextSituation != null && widget.card.contextSituation!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.card.contextSituation!,
              style: GoogleFonts.inter(
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        // Options Grid / List
        ...List.generate(widget.card.options.length, (idx) {
          final option = widget.card.options[idx];
          final isSelected = _selectedOptionIndex == idx;
          final isCorrectOption = idx == widget.card.correctOptionIndex;

          Color btnColor = isDark ? const Color(0xFF1E293B) : Colors.white;
          Color borderColor = isDark ? Colors.white10 : Colors.black12;
          Color textColor = isDark ? Colors.white : Colors.black87;

          if (_isOptionChecked) {
            if (isCorrectOption) {
              btnColor = const Color(0xFF10B981).withValues(alpha: 0.2);
              borderColor = const Color(0xFF10B981);
              textColor = const Color(0xFF10B981);
            } else if (isSelected && !isCorrectOption) {
              btnColor = Colors.redAccent.withValues(alpha: 0.15);
              borderColor = Colors.redAccent;
              textColor = Colors.redAccent;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              onTap: _isCompleted
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedOptionIndex = idx;
                        _isOptionChecked = true;
                      });
                      if (isCorrectOption) {
                        _markSolved();
                      } else {
                        HapticFeedback.mediumImpact();
                      }
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7.5),
                decoration: BoxDecoration(
                  color: btnColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOptionChecked && isCorrectOption
                            ? const Color(0xFF10B981)
                            : (_isOptionChecked && isSelected
                                ? Colors.redAccent
                                : (isDark ? Colors.white12 : Colors.black12)),
                      ),
                      child: Center(
                        child: _isOptionChecked && isCorrectOption
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : (_isOptionChecked && isSelected
                                ? const Icon(Icons.close, size: 12, color: Colors.white)
                                : Text(
                                    String.fromCharCode(65 + idx),
                                    style: GoogleFonts.outfit(
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option,
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
