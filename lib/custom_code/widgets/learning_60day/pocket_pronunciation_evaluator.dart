import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Status of an individual word in the target sentence
enum WordEvaluationStatus {
  correct,
  wrong,
  missed,
}

/// Evaluated word entity with display properties
class EvaluatedWord {
  final String word;
  final WordEvaluationStatus status;
  final String? spokenVariant;

  const EvaluatedWord({
    required this.word,
    required this.status,
    this.spokenVariant,
  });
}

/// Comprehensive speech evaluation result matching user specification
class PronunciationEvaluationResult {
  final int accuracyPercentage;
  final int correctCount;
  final int wrongCount;
  final int missedCount;
  final List<EvaluatedWord> words;
  final String spokenText;
  final List<String> focusWords;
  final String feedbackTip;

  const PronunciationEvaluationResult({
    required this.accuracyPercentage,
    required this.correctCount,
    required this.wrongCount,
    required this.missedCount,
    required this.words,
    required this.spokenText,
    required this.focusWords,
    required this.feedbackTip,
  });

  bool get isExcellent => accuracyPercentage >= 80;
  bool get isGood => accuracyPercentage >= 60 && accuracyPercentage < 80;
}

/// Evaluator logic that compares target sentence against spoken STT output
class PocketPronunciationEvaluator {
  static String _cleanWord(String w) {
    return w.toLowerCase().replaceAll(RegExp(r"[^\w']"), '').trim();
  }

  /// Evaluates speech input against the target sentence
  static PronunciationEvaluationResult evaluate({
    required String targetSentence,
    required String spokenText,
  }) {
    final rawTargetTokens = targetSentence.trim().split(RegExp(r'\s+'));
    final cleanTargetWords = rawTargetTokens.map(_cleanWord).toList();
    final cleanSpokenWords = spokenText
        .trim()
        .split(RegExp(r'\s+'))
        .map(_cleanWord)
        .where((w) => w.isNotEmpty)
        .toList();

    if (cleanTargetWords.isEmpty) {
      return PronunciationEvaluationResult(
        accuracyPercentage: 0,
        correctCount: 0,
        wrongCount: 0,
        missedCount: 0,
        words: const [],
        spokenText: spokenText,
        focusWords: const [],
        feedbackTip: 'No target text found to evaluate.',
      );
    }

    if (cleanSpokenWords.isEmpty) {
      final words = rawTargetTokens
          .map((t) => EvaluatedWord(word: t, status: WordEvaluationStatus.missed))
          .toList();
      return PronunciationEvaluationResult(
        accuracyPercentage: 0,
        correctCount: 0,
        wrongCount: 0,
        missedCount: words.length,
        words: words,
        spokenText: spokenText.isEmpty ? '(No speech detected)' : spokenText,
        focusWords: cleanTargetWords.take(3).toList(),
        feedbackTip: 'Microphone did not pick up your voice. Tap Say It and speak clearly.',
      );
    }

    // Positional evaluation matching speech recognition pronunciation engines
    final evaluatedList = <EvaluatedWord>[];
    int correctCount = 0;
    int wrongCount = 0;
    int missedCount = 0;
    final focusList = <String>[];

    final totalSpoken = cleanSpokenWords.length;

    for (int i = 0; i < rawTargetTokens.length; i++) {
      final origWord = rawTargetTokens[i];
      final target = cleanTargetWords[i];

      if (target.isEmpty) continue;

      if (i < totalSpoken) {
        final spk = cleanSpokenWords[i];
        if (spk == target || _isCloseMatch(spk, target)) {
          evaluatedList.add(
            EvaluatedWord(
              word: origWord,
              status: WordEvaluationStatus.correct,
              spokenVariant: spk,
            ),
          );
          correctCount++;
        } else {
          evaluatedList.add(
            EvaluatedWord(
              word: origWord,
              status: WordEvaluationStatus.wrong,
              spokenVariant: spk,
            ),
          );
          wrongCount++;
          focusList.add(target);
        }
      } else {
        evaluatedList.add(
          EvaluatedWord(
            word: origWord,
            status: WordEvaluationStatus.missed,
          ),
        );
        missedCount++;
        focusList.add(target);
      }
    }

    final totalEvaluated = evaluatedList.length;
    final int accuracy = totalEvaluated == 0
        ? 0
        : ((correctCount / totalEvaluated) * 100).round().clamp(0, 100);

    String tip;
    if (focusList.isEmpty && accuracy >= 80) {
      tip = '🌟 Outstanding! You pronounced every syllable clearly and naturally.';
    } else if (accuracy >= 60) {
      final focusSample = focusList.take(3).join(', ');
      tip = 'Good effort! Focus on: "$focusSample". Try saying them with slightly stronger stress.';
    } else {
      final focusSample = focusList.take(3).join(', ');
      tip = 'Focus on: "$focusSample". Try slowing down and saying each syllable clearly.';
    }

    return PronunciationEvaluationResult(
      accuracyPercentage: accuracy,
      correctCount: correctCount,
      wrongCount: wrongCount,
      missedCount: missedCount,
      words: evaluatedList,
      spokenText: spokenText,
      focusWords: focusList,
      feedbackTip: tip,
    );
  }

  static bool _isCloseMatch(String s1, String s2) {
    if (s1 == s2) return true;
    if (s1.length < 3 || s2.length < 3) return false;
    // Simple edit distance tolerance of 1
    if ((s1.length - s2.length).abs() > 1) return false;
    int mismatches = 0;
    int i = 0, j = 0;
    while (i < s1.length && j < s2.length) {
      if (s1[i] != s2[j]) {
        mismatches++;
        if (mismatches > 1) return false;
        if (s1.length > s2.length) {
          i++;
          continue;
        } else if (s2.length > s1.length) {
          j++;
          continue;
        }
      }
      i++;
      j++;
    }
    return true;
  }
}

/// 🌟 Visual Pronunciation Feedback Widget matching the user's exact design
class PocketPronunciationResultCard extends StatelessWidget {
  final PronunciationEvaluationResult result;
  final VoidCallback? onRetry;
  final VoidCallback? onListenNative;

  const PocketPronunciationResultCard({
    super.key,
    required this.result,
    this.onRetry,
    this.onListenNative,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = _getScoreColorScheme(result.accuracyPercentage);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10141E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.borderColor,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.glowColor.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Row: Big Accuracy % Badge + Count Pills
          Row(
            children: [
              // Accuracy Gauge Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryColor.withValues(alpha: 0.25),
                      colorScheme.primaryColor.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.primaryColor.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${result.accuracyPercentage}%',
                      style: GoogleFonts.outfit(
                        color: colorScheme.primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'accuracy',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Metrics Breakdown: Correct, Wrong, Missed
              Expanded(
                child: Row(
                  children: [
                    _buildStatPill(
                      count: result.correctCount,
                      label: 'Correct',
                      color: const Color(0xFF10B981),
                      icon: Icons.check_circle_rounded,
                    ),
                    const SizedBox(width: 6),
                    _buildStatPill(
                      count: result.wrongCount,
                      label: 'Wrong',
                      color: const Color(0xFFEF4444),
                      icon: Icons.cancel_rounded,
                    ),
                    const SizedBox(width: 6),
                    _buildStatPill(
                      count: result.missedCount,
                      label: 'Missed',
                      color: const Color(0xFFF59E0B),
                      icon: Icons.remove_circle_outline_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2. Word-by-Word Colored Chips
          Text(
            'WORD PRONUNCIATION BREAKDOWN',
            style: GoogleFonts.outfit(
              color: Colors.white38,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: result.words.map((ew) {
              Color chipBg;
              Color chipBorder;
              Color chipText;
              IconData chipIcon;

              switch (ew.status) {
                case WordEvaluationStatus.correct:
                  chipBg = const Color(0xFF10B981).withValues(alpha: 0.16);
                  chipBorder = const Color(0xFF10B981);
                  chipText = const Color(0xFF6EE7B7);
                  chipIcon = Icons.check_rounded;
                  break;
                case WordEvaluationStatus.wrong:
                  chipBg = const Color(0xFFEF4444).withValues(alpha: 0.16);
                  chipBorder = const Color(0xFFEF4444);
                  chipText = const Color(0xFFFCA5A5);
                  chipIcon = Icons.close_rounded;
                  break;
                case WordEvaluationStatus.missed:
                  chipBg = Colors.white.withValues(alpha: 0.04);
                  chipBorder = Colors.white24;
                  chipText = Colors.white38;
                  chipIcon = Icons.remove_rounded;
                  break;
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: chipBorder, width: 1.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ew.word,
                      style: GoogleFonts.outfit(
                        color: chipText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(chipIcon, color: chipText, size: 12),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // 3. Spoken Text Quote Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF171B26),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎙️', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '“${result.spokenText}”',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 4. Actionable Tip Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.feedbackTip,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFDE68A),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 5. Actions: Try Again & Listen Native
          Row(
            children: [
              if (onListenNative != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onListenNative,
                    icon: const Icon(Icons.volume_up_rounded, size: 16, color: Color(0xFFFFD700)),
                    label: Text(
                      'Listen Native',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFFD700), width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              if (onListenNative != null && onRetry != null)
                const SizedBox(width: 8),
              if (onRetry != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.black),
                    label: Text(
                      'Try Again 🎤',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required int count,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.outfit(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ScoreColorScheme _getScoreColorScheme(int accuracy) {
    if (accuracy >= 80) {
      return const _ScoreColorScheme(
        primaryColor: Color(0xFF10B981),
        borderColor: Color(0xFF10B981),
        glowColor: Color(0xFF10B981),
      );
    } else if (accuracy >= 60) {
      return const _ScoreColorScheme(
        primaryColor: Color(0xFF38BDF8),
        borderColor: Color(0xFF38BDF8),
        glowColor: Color(0xFF38BDF8),
      );
    } else if (accuracy >= 40) {
      return const _ScoreColorScheme(
        primaryColor: Color(0xFFF59E0B),
        borderColor: Color(0xFFF59E0B),
        glowColor: Color(0xFFF59E0B),
      );
    } else {
      return const _ScoreColorScheme(
        primaryColor: Color(0xFFEF4444),
        borderColor: Color(0xFFEF4444),
        glowColor: Color(0xFFEF4444),
      );
    }
  }
}

class _ScoreColorScheme {
  final Color primaryColor;
  final Color borderColor;
  final Color glowColor;

  const _ScoreColorScheme({
    required this.primaryColor,
    required this.borderColor,
    required this.glowColor,
  });
}
