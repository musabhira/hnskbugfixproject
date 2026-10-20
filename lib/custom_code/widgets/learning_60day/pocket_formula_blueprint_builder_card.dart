import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';

/// 📐 Single Formula Blueprint Rule Specification
class FormulaRuleItem {
  final String formulaHeader; // e.g. "POSSESSION FORMULA"
  final String subjectRule; // e.g. "I / You / We / They ➔ HAVE"
  final String targetSentence; // e.g. "I have a new laptop."
  final String nativeMeaning; // e.g. "എനിക്ക് ഒരു പുതിയ ലാപ്ടോപ്പുണ്ട്."
  final String? formulaTip; // e.g. "Subject + have/has + Object"

  const FormulaRuleItem({
    required this.formulaHeader,
    required this.subjectRule,
    required this.targetSentence,
    required this.nativeMeaning,
    this.formulaTip,
  });
}

/// 🧩 Holographic Blueprint Formula Builder Card
///
/// Designed per User Audio Directives:
/// 1. Pinned Formula Header at top displaying the exact grammatical / possession formula.
/// 2. Interactive Word Slot Chips: Tapping scrambled words places them into the formula order.
/// 3. Reinforces formula structure: [ Subject ] + [ Verb / Auxiliary ] + [ Complement / Object ].
/// 4. Lenient & forgiving: Learner can tap any placed word to return it to the bank.
/// 5. Immediate rewarding SFX and celebration upon completion of all rules.
class PocketFormulaBlueprintBuilderCard extends StatefulWidget {
  final String title;
  final List<FormulaRuleItem> rules;
  final VoidCallback onCompleted;
  final Function(String text)? onPronounceSentence;

  const PocketFormulaBlueprintBuilderCard({
    super.key,
    required this.title,
    required this.rules,
    required this.onCompleted,
    this.onPronounceSentence,
  });

  @override
  State<PocketFormulaBlueprintBuilderCard> createState() =>
      _PocketFormulaBlueprintBuilderCardState();
}

class _PocketFormulaBlueprintBuilderCardState
    extends State<PocketFormulaBlueprintBuilderCard>
    with SingleTickerProviderStateMixin {
  int _currentRuleIndex = 0;
  List<String> _expectedTokens = [];
  List<String> _scrambledTokens = [];
  final List<String> _placedTokens = [];
  bool _isSuccess = false;
  bool _isFinished = false;

  late final AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadRule(_currentRuleIndex);
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _loadRule(int index) {
    if (index >= widget.rules.length) {
      setState(() => _isFinished = true);
      widget.onCompleted();
      return;
    }

    final rule = widget.rules[index];
    // Split target sentence into tokens by whitespace
    final rawTokens = rule.targetSentence
        .trim()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    _expectedTokens = List.from(rawTokens);
    _placedTokens.clear();
    _isSuccess = false;

    // Scramble tokens ensuring different order if length > 1
    final scrambled = List<String>.from(rawTokens);
    final rng = Random();
    int attempts = 0;
    while (attempts < 10 &&
        scrambled.length > 1 &&
        _listsEqual(scrambled, rawTokens)) {
      scrambled.shuffle(rng);
      attempts++;
    }
    _scrambledTokens = scrambled;

    setState(() {
      _currentRuleIndex = index;
    });

    widget.onPronounceSentence?.call(rule.targetSentence);
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _onTapWordChip(String word) {
    if (_isSuccess) return;

    HapticFeedback.lightImpact();
    PocketGameAudioService.instance.playCoinSound();

    setState(() {
      _scrambledTokens.remove(word);
      _placedTokens.add(word);
    });

    // Check if sentence assembly is complete
    if (_placedTokens.length == _expectedTokens.length) {
      if (_listsEqual(_placedTokens, _expectedTokens)) {
        _onRuleSolved();
      } else {
        // Mismatch feedback
        HapticFeedback.mediumImpact();
        PocketGameAudioService.instance.playIncorrectSound();
      }
    }
  }

  void _onRemovePlacedWord(int index) {
    if (_isSuccess) return;

    HapticFeedback.selectionClick();
    setState(() {
      final removed = _placedTokens.removeAt(index);
      _scrambledTokens.add(removed);
    });
  }

  void _onResetCurrent() {
    HapticFeedback.selectionClick();
    _loadRule(_currentRuleIndex);
  }

  void _onRuleSolved() {
    HapticFeedback.heavyImpact();
    PocketGameAudioService.instance.playCorrectSound();
    _celebrationController.forward(from: 0.0);

    setState(() {
      _isSuccess = true;
    });

    final rule = widget.rules[_currentRuleIndex];
    widget.onPronounceSentence?.call(rule.targetSentence);
  }

  void _onAdvanceNext() {
    if (_currentRuleIndex + 1 < widget.rules.length) {
      _loadRule(_currentRuleIndex + 1);
    } else {
      setState(() => _isFinished = true);
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playVictorySfx();
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF34D399), width: 1.5),
        ),
        child: Column(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              'FORMULA BLUEPRINT MASTERED! 🎉',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You successfully assembled every blueprint formula rule!',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final currentRule = widget.rules[_currentRuleIndex];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isSuccess
              ? const Color(0xFF10B981)
              : const Color(0xFF38BDF8).withValues(alpha: 0.6),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isSuccess ? const Color(0xFF10B981) : const Color(0xFF38BDF8))
                .withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Pinned Formula Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1),
                ),
                child: const Text('📐', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentRule.formulaHeader.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      'Rule ${_currentRuleIndex + 1} of ${widget.rules.length} • Tap words in formula order',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white54, size: 18),
                tooltip: 'Reset Chips',
                onPressed: _onResetCurrent,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Grammatical Rule Pill Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, color: Color(0xFFFBBF24), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    currentRule.subjectRule,
                    style: GoogleFonts.firaCode(
                      color: const Color(0xFFFDE047),
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Malayalam Translation Hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              currentRule.nativeMeaning,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 4. Formula Assembly Slot Target Box
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B132B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isSuccess
                    ? const Color(0xFF10B981)
                    : (_placedTokens.isEmpty
                        ? Colors.white12
                        : const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                width: _isSuccess ? 2.0 : 1.2,
              ),
            ),
            child: _placedTokens.isEmpty
                ? Center(
                    child: Text(
                      '👉 Tap the words below to build the sentence',
                      style: GoogleFonts.inter(
                        color: Colors.white30,
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(_placedTokens.length, (idx) {
                      final word = _placedTokens[idx];
                      return GestureDetector(
                        onTap: () => _onRemovePlacedWord(idx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isSuccess
                                  ? [const Color(0xFF047857), const Color(0xFF059669)]
                                  : [const Color(0xFF1D4ED8), const Color(0xFF2563EB)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: (_isSuccess
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF3B82F6))
                                    .withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                word,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!_isSuccess) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.close_rounded, size: 13, color: Colors.white70),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
          ),
          const SizedBox(height: 12),

          // 5. Scrambled Word Bank Chips
          if (!_isSuccess) ...[
            Text(
              'WORD BANK (TAP IN FORMULA ORDER):',
              style: GoogleFonts.outfit(
                color: const Color(0xFF94A3B8),
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _scrambledTokens.map((word) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onTapWordChip(word),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.45),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        word,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFE2E8F0),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // 6. Success Feedback & Next Advance Button
          if (_isSuccess) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF047857).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PERFECT FORMULA MATCH! 🌟',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF34D399),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentRule.targetSentence,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  _currentRuleIndex + 1 < widget.rules.length
                      ? Icons.arrow_forward_rounded
                      : Icons.verified_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  _currentRuleIndex + 1 < widget.rules.length
                      ? 'NEXT FORMULA RULE (${_currentRuleIndex + 2}/${widget.rules.length}) ➔'
                      : 'CONQUER FORMULA & CONTINUE 🏆',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                onPressed: _onAdvanceNext,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
