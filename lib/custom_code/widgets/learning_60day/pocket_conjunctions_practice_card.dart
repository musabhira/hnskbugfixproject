import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Model for a Conjunction speaking exercise
class ConjunctionExerciseItem {
  final String category; // 'FANBOYS', 'SUBORDINATING', 'CORRELATIVE'
  final String subCategory; // 'Additive', 'Contrast', 'Choice', 'Reason', etc.
  final String rule;
  final String promptSentence;
  final String targetWord;
  final List<String> acceptableWords;
  final String fullSentence;
  final Map<String, String> localizedHints;
  final Map<String, String> localizedTranslations;

  const ConjunctionExerciseItem({
    required this.category,
    required this.subCategory,
    required this.rule,
    required this.promptSentence,
    required this.targetWord,
    required this.acceptableWords,
    required this.fullSentence,
    required this.localizedHints,
    required this.localizedTranslations,
  });

  String getHint(String language) {
    final key = language.toLowerCase();
    for (final entry in localizedHints.entries) {
      if (entry.key.toLowerCase() == key && entry.value.isNotEmpty) {
        return entry.value;
      }
    }
    return localizedHints['Tamil'] ??
        localizedHints['Malayalam'] ??
        localizedHints['English'] ??
        '';
  }

  String getTranslation(String language) {
    final key = language.toLowerCase();
    for (final entry in localizedTranslations.entries) {
      if (entry.key.toLowerCase() == key && entry.value.isNotEmpty) {
        return entry.value;
      }
    }
    return localizedTranslations['Tamil'] ??
        localizedTranslations['Malayalam'] ??
        localizedTranslations['English'] ??
        '';
  }
}

/// 🔗 Conjunctions Practice Card — FANBOYS, Subordinating & Correlative Linkers
/// Features interactive 🎤 "Say It" speech recognition, instant evaluation,
/// written feedback, TTS audio, filter tabs, collapsible guide, and completion tracking.
class PocketConjunctionsPracticeCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const PocketConjunctionsPracticeCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '10',
  });

  @override
  State<PocketConjunctionsPracticeCard> createState() =>
      _PocketConjunctionsPracticeCardState();
}

class _PocketConjunctionsPracticeCardState
    extends State<PocketConjunctionsPracticeCard>
    with SingleTickerProviderStateMixin {
  int _currentExerciseIndex = 0;
  String _activeFilter = 'ALL';
  bool _showRuleTable = false;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;
  bool _isListening = false;
  String _recognizedWords = '';
  bool _isExerciseAnswered = false;
  bool _isCorrect = false;
  Timer? _listeningTimeoutTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeechRecognizer();
    _initTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
    } catch (_) {}
  }

  Future<bool> _initSpeechRecognizer() async {
    try {
      _isSpeechInitialized = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            if (mounted && _isListening) _stopListening();
          }
        },
        onError: (error) {
          if (mounted && _isListening) _stopListening();
        },
      );
      if (mounted) setState(() {});
      return _isSpeechInitialized;
    } catch (_) {
      _isSpeechInitialized = false;
      return false;
    }
  }

  @override
  void dispose() {
    _listeningTimeoutTimer?.cancel();
    _pulseController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speakText(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _toggleSayIt() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    HapticFeedback.mediumImpact();
    await _tts.stop();

    if (!_isSpeechInitialized) {
      final ok = await _initSpeechRecognizer();
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Microphone access needed for speaking practice. Please ensure microphone permissions are enabled.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isListening = true;
      _recognizedWords = '';
      _isExerciseAnswered = false;
      _isCorrect = false;
    });

    _listeningTimeoutTimer?.cancel();
    _listeningTimeoutTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _isListening) _stopListening();
    });

    try {
      if (_isSpeechInitialized) {
        await _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() => _recognizedWords = result.recognizedWords);
              if (result.finalResult) _stopListening();
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenFor: const Duration(seconds: 8),
            pauseFor: const Duration(seconds: 3),
            partialResults: true,
            localeId: 'en_US',
            listenMode: stt.ListenMode.confirmation,
          ),
        );
      }
    } catch (_) {
      _listeningTimeoutTimer?.cancel();
      if (mounted) setState(() => _isListening = false);
    }
  }

  Future<void> _stopListening() async {
    _listeningTimeoutTimer?.cancel();
    try {
      await _speech.stop();
    } catch (_) {}
    if (mounted) {
      setState(() => _isListening = false);
      _evaluateSpeech(_recognizedWords);
    }
  }

  bool _matchesPhrase(String spoken, String target) {
    final cleanSpoken = ' ${spoken.toLowerCase().replaceAll(RegExp(r"[^\w\s']"), ' ').replaceAll(RegExp(r'\s+'), ' ')} ';
    final cleanTarget = target.toLowerCase().replaceAll(RegExp(r"[^\w\s']"), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleanTarget.isEmpty) return false;
    return cleanSpoken.contains(' $cleanTarget ');
  }

  void _evaluateSpeech(String spokenText) {
    final exercises = _filteredExercises;
    if (exercises.isEmpty) return;
    final ex = exercises[_currentExerciseIndex % exercises.length];
    final normalized = spokenText.toLowerCase().trim();
    bool matched = false;
    if (normalized.isNotEmpty) {
      if (_matchesPhrase(normalized, ex.targetWord)) {
        matched = true;
      }
      if (!matched) {
        for (final word in ex.acceptableWords) {
          if (_matchesPhrase(normalized, word)) {
            matched = true;
            break;
          }
        }
      }
      if (!matched && normalized.length >= 3) {
        final fullNorm = ex.fullSentence.toLowerCase().replaceAll(RegExp(r"[^\w\s']"), ' ').trim();
        final cleanSpoken = normalized.replaceAll(RegExp(r"[^\w\s']"), ' ').trim();
        if (fullNorm.contains(cleanSpoken) || cleanSpoken.contains(fullNorm)) {
          matched = true;
        }
      }
    }
    setState(() {
      _isExerciseAnswered = true;
      _isCorrect = matched;
    });
    if (matched) {
      HapticFeedback.heavyImpact();
      _speakText(ex.fullSentence);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  List<ConjunctionExerciseItem> get _filteredExercises {
    switch (_activeFilter) {
      case 'FANBOYS':
        return _kConjunctionExercises.where((e) => e.category == 'FANBOYS').toList();
      case 'SUBORDINATING':
        return _kConjunctionExercises.where((e) => e.category == 'SUBORDINATING').toList();
      case 'CORRELATIVE':
        return _kConjunctionExercises.where((e) => e.category == 'CORRELATIVE').toList();
      default:
        return _kConjunctionExercises;
    }
  }

  void _setFilter(String filter) {
    HapticFeedback.selectionClick();
    setState(() {
      _activeFilter = filter;
      _currentExerciseIndex = 0;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _goToNext() {
    final list = _filteredExercises;
    HapticFeedback.selectionClick();
    setState(() {
      _currentExerciseIndex = (_currentExerciseIndex + 1) % list.length;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _goToPrevious() {
    final list = _filteredExercises;
    HapticFeedback.selectionClick();
    setState(() {
      _currentExerciseIndex =
          (_currentExerciseIndex - 1 + list.length) % list.length;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _bypassForTesting(ConjunctionExerciseItem ex) {
    setState(() {
      _recognizedWords = ex.fullSentence;
      _isExerciseAnswered = true;
      _isCorrect = true;
    });
    HapticFeedback.mediumImpact();
    _speakText(ex.fullSentence);
  }

  Color _badgeColor(String category) {
    switch (category) {
      case 'FANBOYS':
        return const Color(0xFF38BDF8); // sky blue
      case 'SUBORDINATING':
        return const Color(0xFFA78BFA); // purple
      case 'CORRELATIVE':
        return const Color(0xFF34D399); // emerald
      default:
        return const Color(0xFF38BDF8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises;
    final ex = exercises[_currentExerciseIndex.clamp(0, exercises.length - 1)];
    final displaySentence =
        (_isExerciseAnswered && _isCorrect) ? ex.fullSentence : ex.promptSentence;
    final localizedHint = ex.getHint(widget.selectedLanguage);
    final localizedMeaning = ex.getTranslation(widget.selectedLanguage);
    final badgeColor = _badgeColor(ex.category);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFF38BDF8).withValues(alpha: 0.5),
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF38BDF8))
                .withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Clean 2-Column Responsive Header ────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP ${widget.stepNumber} • 🔗 Conjunctions',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getLocalizedSubtitle(widget.selectedLanguage),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF38BDF8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  final nextVal = !widget.isCompleted;
                  widget.onCompleted(nextVal);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(nextVal
                          ? '🎉 Conjunctions Practice Completed! (+20 PTS) ✓'
                          : 'Conjunctions Practice marked as pending'),
                      backgroundColor: nextVal
                          ? const Color(0xFF10B981)
                          : const Color(0xFF334155),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: widget.isCompleted
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.isCompleted
                          ? const Color(0xFF10B981)
                          : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: widget.isCompleted
                            ? const Color(0xFF10B981)
                            : Colors.white54,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.isCompleted ? 'DONE ✓' : 'MARK STEP',
                        style: GoogleFonts.outfit(
                          color: widget.isCompleted
                              ? const Color(0xFF10B981)
                              : Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _getInstructionText(widget.selectedLanguage),
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 11,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // ── Filter Tabs ─────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterTab('ALL (15)', 'ALL'),
                const SizedBox(width: 5),
                _buildFilterTab('FANBOYS (5)', 'FANBOYS'),
                const SizedBox(width: 5),
                _buildFilterTab('SUBORDINATING (5)', 'SUBORDINATING'),
                const SizedBox(width: 5),
                _buildFilterTab('CORRELATIVE (5)', 'CORRELATIVE'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Rule Reference Toggle ───────────────────────────────
          InkWell(
            onTap: () => setState(() => _showRuleTable = !_showRuleTable),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _showRuleTable
                      ? const Color(0xFF38BDF8)
                      : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded,
                      color: Color(0xFF38BDF8), size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _showRuleTable
                          ? 'Hide Conjunctions & FANBOYS Guide ▲'
                          : 'Show FANBOYS, Subordinating & Correlative Rules ▼',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFBAE6FD),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_showRuleTable) ...[
            const SizedBox(height: 8),
            _buildRuleTable(),
          ],

          const SizedBox(height: 12),

          // ── Main Exercise Card ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isExerciseAnswered
                    ? (_isCorrect
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444))
                    : const Color(0xFF334155),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise Category Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: badgeColor, width: 0.8),
                      ),
                      child: Text(
                        '${ex.category} • ${ex.subCategory}',
                        style: GoogleFonts.outfit(
                          color: badgeColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Exercise ${_currentExerciseIndex + 1} of ${exercises.length}',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Rule note
                Text(
                  '💡 ${ex.rule}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF93C5FD),
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),

                // Prompt sentence with blank
                Text(
                  displaySentence,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),

                if (localizedMeaning.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    localizedMeaning,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFDE68A),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                if (localizedHint.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '💡 $localizedHint',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF67E8F9),
                      fontSize: 11,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Recognized words / Answer status banner
                if (_isListening) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFEF4444)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _recognizedWords.isEmpty
                                ? 'Listening... Speak the full sentence aloud!'
                                : '"$_recognizedWords"',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_isExerciseAnswered) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isCorrect
                          ? const Color(0xFF064E3B).withValues(alpha: 0.6)
                          : const Color(0xFF7F1D1D).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isCorrect
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.info_outline_rounded,
                              color: _isCorrect
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFFCA5A5),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _isCorrect
                                    ? 'Great pronunciation! Correct conjunction ✓'
                                    : 'Listen to the correct sentence & try again:',
                                style: GoogleFonts.outfit(
                                  color: _isCorrect
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFFFCA5A5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Correct: "${ex.fullSentence}"',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Target: "${ex.targetWord}" (${ex.subCategory})',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFFDE68A),
                            fontSize: 11,
                          ),
                        ),
                        if (_recognizedWords.isNotEmpty && !_isCorrect) ...[
                          const SizedBox(height: 2),
                          Text(
                            'You said: "$_recognizedWords"',
                            style: GoogleFonts.inter(
                              color: Colors.white60,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Action Buttons Row: 🎤 Say It, 🔊 Listen TTS, Prev, Next
                Row(
                  children: [
                    // Say It button
                    Expanded(
                      flex: 4,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isListening ? _pulseAnimation.value : 1.0,
                            child: ElevatedButton.icon(
                              onPressed: _toggleSayIt,
                              icon: Icon(
                                _isListening
                                    ? Icons.mic
                                    : Icons.mic_none_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                _isListening
                                    ? 'Listening...'
                                    : (_isExerciseAnswered && !_isCorrect
                                        ? 'Retry Speaking'
                                        : 'Say It Aloud'),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isListening
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF38BDF8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: _isListening ? 6 : 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Listen TTS button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _speakText(ex.fullSentence);
                        },
                        icon: const Icon(Icons.volume_up_rounded,
                            color: Color(0xFF38BDF8), size: 20),
                        tooltip: 'Listen to native pronunciation',
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Quick bypass test button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () => _bypassForTesting(ex),
                        icon: const Icon(Icons.check_rounded,
                            color: Color(0xFF34D399), size: 20),
                        tooltip: 'Quick Pass (testing)',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Navigation Prev / Next
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _goToPrevious,
                      icon: const Icon(Icons.chevron_left_rounded,
                          color: Colors.white70, size: 18),
                      label: Text(
                        'PREV',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Exercise indicator dots
                    Row(
                      children: List.generate(
                        exercises.length > 10 ? 10 : exercises.length,
                        (idx) {
                          final isCurrent = idx ==
                              (_currentExerciseIndex %
                                  (exercises.length > 10
                                      ? 10
                                      : exercises.length));
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: isCurrent ? 14 : 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? const Color(0xFF38BDF8)
                                  : Colors.white24,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        },
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _goToNext,
                      label: Text(
                        'NEXT ➔',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFF38BDF8), size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Mark Step Complete Full Width Button ─────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.heavyImpact();
                final nextVal = !widget.isCompleted;
                widget.onCompleted(nextVal);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(nextVal
                        ? '🔗 Conjunctions Mastery Completed! (+20 PTS) ✓'
                        : 'Conjunctions Practice marked as pending'),
                    backgroundColor: nextVal
                        ? const Color(0xFF10B981)
                        : const Color(0xFF334155),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                widget.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.task_alt_rounded,
                color: widget.isCompleted ? Colors.white : Colors.black,
                size: 16,
              ),
              label: Text(
                widget.isCompleted
                    ? _getCompletedButtonLabel(widget.selectedLanguage)
                    : _getPendingButtonLabel(widget.selectedLanguage),
                style: GoogleFonts.outfit(
                  color: widget.isCompleted ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF38BDF8),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String filter) {
    final isSelected = _activeFilter == filter;
    return InkWell(
      onTap: () => _setFilter(filter),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF38BDF8)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF38BDF8)
                : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRuleTable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📌 3 Types of Conjunctions & FANBOYS',
            style: GoogleFonts.outfit(
              color: const Color(0xFF38BDF8),
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 6),
          _buildRuleRow('FANBOYS', 'Coordinating (Equal parts)', 'For, And, Nor, But, Or, Yet, So (connects words, phrases, or clauses)'),
          _buildRuleRow('SUBORDINATING', 'Dependent to main clause', 'because, although, while, when, if, since, unless, until'),
          _buildRuleRow('CORRELATIVE', 'Word pairs used together', 'either…or, neither…nor, both…and, not only…but also, whether…or'),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),
          Text(
            '⚠️ Common Mistakes to Avoid:',
            style: GoogleFonts.outfit(
              color: const Color(0xFFFDE68A),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Comma Splice: Don\'t join two complete sentences without a comma + FANBOYS word.\n'
            '• Don\'t mix up "because" (reason) and "although" (contrast).\n'
            '• In Correlative pairs, always keep parts balanced: "She is both intelligent and hardworking."',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String type, String meaning, String example) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              type,
              style: GoogleFonts.outfit(
                color: const Color(0xFF38BDF8),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                children: [
                  TextSpan(
                    text: '$meaning: ',
                    style: const TextStyle(
                      color: Color(0xFF93C5FD),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: example,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedSubtitle(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'இணைப்புச் சொற்கள் பயிற்சி (FANBOYS)';
      case 'telugu':
        return 'సముచ్ఛయాలు మాట్లాడే సాధన (FANBOYS)';
      case 'hindi':
        return 'Conjunctions बोलने का अभ्यास (FANBOYS)';
      case 'kannada':
        return 'ಸಮುಚ್ಚಯಗಳ ಮಾತನಾಡುವ ಅಭ್ಯಾಸ (FANBOYS)';
      case 'malayalam':
        return 'കൺജങ്ഷൻസ് സംസാര പരിശീലനം (FANBOYS)';
      default:
        return 'Connecting Words: FANBOYS & Clause Linkers';
    }
  }

  String _getInstructionText(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'வாக்கியத்தை உரக்கக் கூறி இடைவெளியை நிரப்பவும். பேச 🎤 "Say It Aloud" தட்டவும்.';
      case 'telugu':
        return 'వాక్యాన్ని గట్టిగా పలకడం ద్వారా ఖాళీని పూరించండి. మాట్లాడేందుకు 🎤 "Say It Aloud" నొక్కండి.';
      case 'hindi':
        return 'वाक्य को ज़ोर से बोलकर खाली जगह भरें। बोलने के लिए 🎤 "Say It Aloud" दबाएँ।';
      case 'kannada':
        return 'ವಾಕ್ಯವನ್ನು ಗಟ್ಟಿಯಾಗಿ ಹೇಳುವ ಮೂಲಕ ಖಾಲಿಸ್ಥಳ ಭರ್ತಿ ಮಾಡಿ. ಮಾತನಾಡಲು 🎤 "Say It Aloud" ಒತ್ತಿ.';
      case 'malayalam':
        return 'വാചകം ഉറക്കെ പറഞ്ഞു വിട്ടുപോയ ഭാഗം പൂരിപ്പിക്കുക. സംസാരിക്കാൻ 🎤 "Say It Aloud" ടാപ്പ് ചെയ്യുക.';
      default:
        return 'Say the complete sentence out loud, filling in the blank. Tap 🎤 "Say It Aloud" to practice.';
    }
  }

  String _getCompletedButtonLabel(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'இணைப்புச் சொற்கள் தேர்ச்சி பெற்றது ✓';
      case 'telugu':
        return 'సముచ్ఛయాల సాధన పూర్తయింది ✓';
      case 'hindi':
        return 'Conjunctions अभ्यास पूर्ण ✓';
      case 'kannada':
        return 'ಸಮುಚ್ಚಯ ಅಭ್ಯಾಸ ಪೂರ್ಣಗೊಂಡಿದೆ ✓';
      case 'malayalam':
        return 'കൺജങ്ഷൻസ് പരിശീലിച്ചു കഴിഞ്ഞു ✓';
      default:
        return 'CONJUNCTIONS MASTERED ✓';
    }
  }

  String _getPendingButtonLabel(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'இந்த இணைப்புச் சொற்களைப் பழகினேன் ✓';
      case 'telugu':
        return 'ఈ సముచ్ఛయాలను సాధన చేశాను ✓';
      case 'hindi':
        return 'मैंने इन Conjunctions का अभ्यास किया ✓';
      case 'kannada':
        return 'ಈ ಸಮುಚ್ಚಯಗಳನ್ನು ಅಭ್ಯಾಸ ಮಾಡಿದೆ ✓';
      case 'malayalam':
        return 'ഈ കൺജങ്ഷൻസ് ഉറക്കെ പരിശീലിച്ചു ✓';
      default:
        return 'I PRACTICED THESE CONJUNCTIONS ALOUD ✓';
    }
  }

  static const List<ConjunctionExerciseItem> _kConjunctionExercises = [
    // ─── COORDINATING (FANBOYS: 1-5) ──────────────────────────
    ConjunctionExerciseItem(
      category: 'FANBOYS',
      subCategory: 'Additive (And)',
      rule: '"and" connects two similar ideas or items',
      promptSentence: 'I like tea ___ coffee in the morning.',
      targetWord: 'and',
      acceptableWords: ['and coffee', 'tea and', 'and'],
      fullSentence: 'I like tea and coffee in the morning.',
      localizedHints: {
        'Tamil': 'கூடுதல் தகவல்/இணைப்பிற்கு "and": tea and coffee',
        'Malayalam': 'രണ്ട് കാര്യങ്ങൾ ചേർത്തുപറയാൻ "and": tea and coffee',
        'Hindi': 'दो चीजों को जोड़ने के लिए "and": tea and coffee',
        'Telugu': 'రెండు విషయాలను కలపడానికి "and": tea and coffee',
        'English': 'additive → "and": I like tea and coffee.',
      },
      localizedTranslations: {
        'Tamil': 'எனக்கு காலையில் தேநீரும் காபியும் பிடிக்கும்.',
        'Malayalam': 'എനിക്ക് രാവിലെ ചായയും കാപ്പിയും ഇഷ്ടമാണ്.',
        'Hindi': 'मुझे सुबह चाय और कॉफी दोनों पसंद हैं।',
        'Telugu': 'నాకు ఉదయం టీ మరియు కాఫీ ఇష్టం.',
        'English': 'I like tea and coffee in the morning.',
      },
    ),
    ConjunctionExerciseItem(
      category: 'FANBOYS',
      subCategory: 'Contrast (But)',
      rule: '"but" introduces a contrast or unexpected turn',
      promptSentence: 'She is very tired ___ she is happy.',
      targetWord: 'but',
      acceptableWords: ['but she is', 'tired but', 'but'],
      fullSentence: 'She is very tired but she is happy.',
      localizedHints: {
        'Tamil': 'முரண்பட்ட கருத்திற்கு "but" (ஆனால்): tired but happy',
        'Malayalam': 'വൈരുദ്ധ്യം പ്രകടിപ്പിക്കാൻ "but" (എങ്കിലും): tired but happy',
        'Hindi': 'विरोधाभास दर्शाने के लिए "but" (लेकिन): tired but happy',
        'Telugu': 'వ్యతిరేక భావానికి "but" (కానీ): tired but happy',
        'English': 'contrast → "but": She is tired but happy.',
      },
      localizedTranslations: {
        'Tamil': 'அவள் மிகவும் சோர்வாக இருக்கிறாள் ஆனால் மகிழ்ச்சியாக இருக்கிறாள்.',
        'Malayalam': 'അവൾ വളരെ ക്ഷീണിതയാണ്, എങ്കിലും സന്തോഷവതിയാണ്.',
        'Hindi': 'वह बहुत थकी हुई है लेकिन वह खुश है।',
        'Telugu': 'ఆమె చాలా అలసిపోయింది కానీ సంతోషంగా ఉంది.',
        'English': 'She is very tired but she is happy.',
      },
    ),
    ConjunctionExerciseItem(
      category: 'FANBOYS',
      subCategory: 'Choice (Or)',
      rule: '"or" presents alternatives or choices',
      promptSentence: 'Do you want pizza ___ pasta for dinner?',
      targetWord: 'or',
      acceptableWords: ['or pasta', 'pizza or', 'or'],
      fullSentence: 'Do you want pizza or pasta for dinner?',
      localizedHints: {
        'Tamil': 'தேர்வை வெளிப்படுத்த "or" (அல்லது): pizza or pasta',
        'Malayalam': 'തിരഞ്ഞെടുപ്പ് നൽകാൻ "or" (അല്ലെങ്കിൽ): pizza or pasta',
        'Hindi': 'विकल्प देने के लिए "or" (या): pizza or pasta',
        'Telugu': 'ఎంపిక కోసం "or" (లేదా): pizza or pasta',
        'English': 'choice / alternatives → "or": pizza or pasta?',
      },
      localizedTranslations: {
        'Tamil': 'இரவு உணவிற்கு உங்களுக்கு பீட்சா வேண்டுமா அல்லது பாஸ்தா வேண்டுமா?',
        'Malayalam': 'അത്താഴത്തിന് നിങ്ങൾക്ക് പിസ്സ വേണമോ അതോ പാസ്ത വേണമോ?',
        'Hindi': 'क्या आप रात के खाने में पिज्जा या पास्ता चाहते हैं?',
        'Telugu': 'రాత్రి భోజనానికి మీకు పిజ్జా కావాలా లేక పాస్తా కావాలా?',
        'English': 'Do you want pizza or pasta for dinner?',
      },
    ),
    ConjunctionExerciseItem(
      category: 'FANBOYS',
      subCategory: 'Result (So)',
      rule: '"so" shows result or consequence',
      promptSentence: 'He studied hard, ___ he passed the exam easily.',
      targetWord: 'so',
      acceptableWords: ['so he', 'hard so', 'so'],
      fullSentence: 'He studied hard, so he passed the exam easily.',
      localizedHints: {
        'Tamil': 'விளைவை/முடிவைக் குறிக்க "so" (ஆகவே): so he passed',
        'Malayalam': 'ഫലം/പരിണതഫലം സൂചിപ്പിക്കാൻ "so" (അതുകൊണ്ട്): so he passed',
        'Hindi': 'परिणाम दर्शाने के लिए "so" (इसलिए): so he passed',
        'Telugu': 'ఫలితాన్ని చూపించడానికి "so" (కాబట్టి): so he passed',
        'English': 'result / consequence → "so": He studied, so he passed.',
      },
      localizedTranslations: {
        'Tamil': 'அவன் கடினமாகப் படித்தான், ஆகவே தேர்வில் எளிதாகத் தேர்ச்சி பெற்றான்.',
        'Malayalam': 'അവൻ കഠിനമായി പഠിച്ചു, അതിനാൽ പരീക്ഷ എളുപ്പത്തിൽ പാസ്സായി.',
        'Hindi': 'उसने कड़ी मेहनत से पढ़ाई की, इसलिए वह आसानी से परीक्षा पास कर गया।',
        'Telugu': 'అతను బాగా చదువుకున్నాడు, కాబట్టి సులభంగా పరీక్ష పాసయ్యాడు.',
        'English': 'He studied hard, so he passed the exam easily.',
      },
    ),
    ConjunctionExerciseItem(
      category: 'FANBOYS',
      subCategory: 'Contrast (Yet)',
      rule: '"yet" shows surprise or contrast despite something',
      promptSentence: 'The weather was cold, ___ they went for a swim.',
      targetWord: 'yet',
      acceptableWords: ['yet they', 'cold yet', 'yet'],
      fullSentence: 'The weather was cold, yet they went for a swim.',
      localizedHints: {
        'Tamil': 'இருப்பினும் / அப்படியிருந்தும்: yet they went',
        'Malayalam': 'എന്നിരുന്നാലും: yet they went for a swim',
        'Hindi': 'फिर भी / इसके बावजूद: yet they went',
        'Telugu': 'అయినప్పటికీ: yet they went',
        'English': 'unexpected contrast → "yet": The weather was cold, yet they swam.',
      },
      localizedTranslations: {
        'Tamil': 'வானிலை குளிராக இருந்தது, இருப்பினும் அவர்கள் நீந்தச் சென்றார்கள்.',
        'Malayalam': 'കാലാവസ്ഥ തണുത്തതായിരുന്നു, എന്നിട്ടും അവർ നീന്താൻ പോയി.',
        'Hindi': 'मौसम ठंडा था, फिर भी वे तैरने गए।',
        'Telugu': 'వాతావరణం చల్లగా ఉంది, అయినప్పటికీ వారు ఈతకు వెళ్లారు.',
        'English': 'The weather was cold, yet they went for a swim.',
      },
    ),

    // ─── SUBORDINATING (6-10) ─────────────────────────────────
    ConjunctionExerciseItem(
      category: 'SUBORDINATING',
      subCategory: 'Reason (Because)',
      rule: '"because" explains the reason or cause',
      promptSentence: 'I stayed home ___ it was raining heavily.',
      targetWord: 'because',
      acceptableWords: ['because it', 'home because', 'because'],
      fullSentence: 'I stayed home because it was raining heavily.',
      localizedHints: {
        'Tamil': 'காரணத்தை விளக்க "because" (ஏனென்றால்): because it rained',
        'Malayalam': 'കാരണം വ്യക്തമാക്കാൻ "because" (കാരണം): because it was raining',
        'Hindi': 'कारण बताने के लिए "because" (क्योंकि): because it was raining',
        'Telugu': 'కారణం చెప్పడానికి "because" (ఎందుకంటే): because it was raining',
        'English': 'reason / cause → "because": I stayed because it was raining.',
      },
      localizedTranslations: {
        'Tamil': 'கனமழை பெய்ததால் நான் வீட்டிலேயே இருந்தேன்.',
        'Malayalam': 'ശക്തമായി മഴ പെയ്തതുകൊണ്ട് ഞാൻ വീട്ടിൽ തന്നെയിരുന്നു.',
        'Hindi': 'मैं घर पर ही रहा क्योंकि बहुत तेज़ बारिश हो रही थी।',
        'Telugu': 'భారీ వర్షం పడుతున్నందున నేను ఇంట్లోనే ఉన్నాను.',
        'English': 'I stayed home because it was raining heavily.',
      },
    ),
    ConjunctionExerciseItem(
      category: 'SUBORDINATING',
      subCategory: 'Concession (Although)',
      rule: '"although" introduces an opposing fact or concession',
      promptSentence: 'She went out ___ she was feeling very tired.',
      targetWord: 'although',
      acceptableWords: ['although she', 'out although', 'although', 'though'],
      fullSentence: 'She went out although she was feeling very tired.',
      localizedHints: {
        'Tamil': 'இருந்தபோதிலும் / என்றாலும் "although": although she was tired',
        'Malayalam': 'എന്നിരുന്നാലും / എങ്കിലും: although she was tired',
        'Hindi': 'यद्यपि / हालांकि: although she was tired',
        'Telugu': 'అయినప్పటికీ: although she was tired',
        'English': 'concession → "although": She went out although she was tired.',
      },
      localizedTranslations: {
        'Tamil': 'அவள் மிகவும் சோர்வாக இருந்தபோதிலும் வெளியே சென்றாள்.',
        'Malayalam': 'വളരെ ക്ഷീണം തോന്നിയിട്ടും അവൾ പുറത്തുപോയി.',
        'Hindi': 'बहुत थकान महसूस होने के बावजूद वह बाहर गई।',
        'Telugu': 'చాలా అలసటగా ఉన్నప్పటికీ ఆమె బయటకు వెళ్లింది.',
        'English': 'She went out although she was feeling very tired.',
      },
    ),
    ConjunctionExerciseItem(
      category: 'SUBORDINATING',
      subCategory: 'Time (When)',
      rule: '"when" indicates the exact time something happens',
      promptSentence: 'Please call me ___ you arrive at the airport.',
      targetWord: 'when',
      acceptableWords: ['when you', 'me when', 'when'],
      fullSentence: 'Please call me when you arrive at the airport.',
      localizedHints: {
        'Tamil': 'நேரத்தை/நிகழ்வைக் குறிக்க "when" (போது): when you arrive',
        'Malayalam': 'സമയം സൂചിപ്പിക്കാൻ "when" (എത്തുമ്പോൾ): when you arrive',
        'Hindi': 'समय दर्शाने के लिए "when" (जब): when you arrive',
        'Telugu': 'సమయం కోసం "when" (చేరినప్పుడు): when you arrive',
        'English': 'time trigger → "when": Call me when you arrive.',
      },
      localizedTranslations: {
        'Tamil': 'விமான நிலையத்திற்கு நீங்கள் வந்தடையும் போது எனக்கு அழைக்கவும்.',
        'Malayalam': 'നിങ്ങൾ എയർപോർട്ടിൽ എത്തുമ്പോൾ എന്നെ വിളിക്കുക.',
        'Hindi': 'हवाई अड्डे पर पहुँचने पर कृपया मुझे कॉल करें।',
        'Telugu': 'మీరు విమానాశ్రయానికి చేరుకున్నప్పుడు దయచేసి నాకు కాల్ చేయండి.',
        'English': 'Please call me when you arrive at the airport.',
      },
    ),
    ConjunctionExerciseItem(
      category: 'SUBORDINATING',
      subCategory: 'Time Limit (Until)',
      rule: '"until" marks the point in time up to which action continues',
      promptSentence: 'He waited at the cafe ___ she finished work.',
      targetWord: 'until',
      acceptableWords: ['until she', 'waited until', 'until'],
      fullSentence: 'He waited at the cafe until she finished work.',
      localizedHints: {
        'Tamil': 'வரை / அதுவரை "until": until she finished',
        'Malayalam': 'അതുവരെ / സമയം വരെ "until": until she finished',
        'Hindi': 'जब तक कि / उस समय तक: until she finished',
        'Telugu': 'వరకు: until she finished',
        'English': 'up to that point → "until": He waited until she finished.',
      },
      localizedTranslations: {
        'Tamil': 'அவள் வேலையை முடிக்கும் வரை அவன் கஃபேவில் காத்திருந்தான்.',
        'Malayalam': 'അവൾ ജോലി പൂർത്തിയാക്കുന്നതുവരെ അവൻ കഫേയിൽ കാത്തിരുന്നു.',
        'Hindi': 'उसने कैफे में तब तक इंतजार किया जब तक उसने काम खत्म नहीं कर लिया।',
        'Telugu': 'ఆమె పని పూర్తయ్యే వరకు అతను కేఫ్‌లో వేచి ఉన్నాడు.',
        'English': 'He waited at the cafe until she finished work.',
      },
    ),
    ConjunctionExerciseItem(
      category: 'SUBORDINATING',
      subCategory: 'Condition (If)',
      rule: '"if" introduces a condition needed for something to occur',
      promptSentence: 'We can go for a walk ___ it stops raining.',
      targetWord: 'if',
      acceptableWords: ['if it', 'walk if', 'if'],
      fullSentence: 'We can go for a walk if it stops raining.',
      localizedHints: {
        'Tamil': 'நிபந்தனைக்கு "if" (நின்றால்): if it stops raining',
        'Malayalam': 'നിബന്ധനയ്ക്ക് "if" (നിന്നാൽ): if it stops raining',
        'Hindi': 'शर्त दर्शाने के लिए "if" (अगर): if it stops raining',
        'Telugu': 'షరతు కోసం "if" (ఆగితే): if it stops raining',
        'English': 'condition → "if": We can go if it stops raining.',
      },
      localizedTranslations: {
        'Tamil': 'மழை நின்றால் நாம் நடைபயிற்சி செல்லலாம்.',
        'Malayalam': 'മഴ നിന്നാൽ നമുക്ക് നടക്കാൻ പോകാം.',
        'Hindi': 'अगर बारिश रुक जाए तो हम टहलने जा सकते हैं।',
        'Telugu': 'వర్షం ఆగితే మనం నడవడానికి వెళ్ళవచ్చు.',
        'English': 'We can go for a walk if it stops raining.',
      },
    ),

    // ─── CORRELATIVE PAIRS (11-15) ────────────────────────────
    ConjunctionExerciseItem(
      category: 'CORRELATIVE',
      subCategory: 'Alternative (Either...Or)',
      rule: '"either...or" connects two positive alternatives',
      promptSentence: '___ you come right now or we leave without you.',
      targetWord: 'either',
      acceptableWords: ['either you', 'either'],
      fullSentence: 'Either you come right now or we leave without you.',
      localizedHints: {
        'Tamil': 'இரண்டில் ஒன்று: "Either... or" (ஒன்று வாருங்கள், அல்லது)',
        'Malayalam': 'രണ്ടിൽ ഒന്ന്: "Either... or" (ഒന്നുകിൽ വരിക, അല്ലെങ്കിൽ)',
        'Hindi': 'या तो... या: "Either... or"',
        'Telugu': 'ఒకటి లేదా మరొకటి: "Either... or"',
        'English': 'choice between two → "Either... or"',
      },
      localizedTranslations: {
        'Tamil': 'ஒன்று நீங்கள் இப்போதே வாருங்கள், அல்லது நாங்கள் உங்களை விட்டுவிட்டு செல்வோம்.',
        'Malayalam': 'ഒന്നുകിൽ നിങ്ങൾ ഇപ്പോൾ തന്നെ വരിക, അല്ലെങ്കിൽ ഞങ്ങൾ നിങ്ങളെ കൂടാതെ പോകും.',
        'Hindi': 'या तो आप अभी आएं या हम आपके बिना ही निकल जाएंगे।',
        'Telugu': 'ఒకవేళ మీరు ఇప్పుడే రండి లేదా మిమ్మల్ని వదిలి మేము వెళ్లిపోతాము.',
        'English': 'Either you come right now or we leave without you.',
      },
    ),
    ConjunctionExerciseItem(
      category: 'CORRELATIVE',
      subCategory: 'Negative Pair (Neither...Nor)',
      rule: '"neither...nor" connects two negative choices',
      promptSentence: 'Neither John ___ Mary attended the seminar.',
      targetWord: 'nor',
      acceptableWords: ['nor mary', 'neither john nor', 'nor'],
      fullSentence: 'Neither John nor Mary attended the seminar.',
      localizedHints: {
        'Tamil': '"Neither... nor" — இருவரும் இல்லை: Neither John nor Mary',
        'Malayalam': '"Neither... nor" — രണ്ടും അല്ല: Neither John nor Mary',
        'Hindi': '"Neither... nor" — न तो वह, न यह',
        'Telugu': '"Neither... nor" — అతను కాదు, ఆమె కాదు',
        'English': 'negative pairing → "neither... nor": Neither John nor Mary.',
      },
      localizedTranslations: {
        'Tamil': 'ஜானும் மேரியும் கருத்தரங்கில் கலந்து கொள்ளவில்லை.',
        'Malayalam': 'ജോണും മേരിയും സെമിനാറിൽ പങ്കെടുത്തില്ല.',
        'Hindi': 'न तो जॉन और न ही मैरी सेमिनार में शामिल हुए।',
        'Telugu': 'జాన్ లేదా మేరీ ఎవరూ సెమినార్‌కు హాజరు కాలేదు.',
        'English': 'Neither John nor Mary attended the seminar.',
      },
    ),
    ConjunctionExerciseItem(
      category: 'CORRELATIVE',
      subCategory: 'Dual Addition (Both...And)',
      rule: '"both...and" emphasizes two qualities or items together',
      promptSentence: 'She is ___ intelligent and hardworking.',
      targetWord: 'both',
      acceptableWords: ['both intelligent', 'is both', 'both'],
      fullSentence: 'She is both intelligent and hardworking.',
      localizedHints: {
        'Tamil': '"both... and" — இரண்டு பண்புகளையும் சேர்த்து: both intelligent and hardworking',
        'Malayalam': '"both... and" — രണ്ടും കൂടി ഒന്നിച്ച്: both intelligent and hardworking',
        'Hindi': '"both... and" — दोनों गुण एक साथ: both intelligent and hardworking',
        'Telugu': '"both... and" — రెండూ కలిసి: both intelligent and hardworking',
        'English': 'dual qualities → "both... and": She is both smart and kind.',
      },
      localizedTranslations: {
        'Tamil': 'அவள் புத்திசாலியாகவும் கடின உழைப்பாளியாகவும் இருக்கிறாள்.',
        'Malayalam': 'അവൾ ബുദ്ധിമതിയും കഠിനാധ്വാനിയുമാണ്.',
        'Hindi': 'वह बुद्धिमान और मेहनती दोनों है।',
        'Telugu': 'ఆమె తెలివైనది మరియు కష్టపడి పనిచేసేది.',
        'English': 'She is both intelligent and hardworking.',
      },
    ),
    ConjunctionExerciseItem(
      category: 'CORRELATIVE',
      subCategory: 'Emphatic (Not only...But also)',
      rule: '"not only...but also" provides strong rhythmic emphasis',
      promptSentence: 'Not only did he win, ___ he also broke the record.',
      targetWord: 'but',
      acceptableWords: ['but he', 'but also', 'but'],
      fullSentence: 'Not only did he win, but he also broke the record.',
      localizedHints: {
        'Tamil': '"Not only... but also" — அதுமட்டுமல்லாமல், இதுவும் கூட',
        'Malayalam': '"Not only... but also" — അത് മാത്രമല്ല, ഇതും കൂടി',
        'Hindi': '"Not only... but also" — न केवल... बल्कि यह भी',
        'Telugu': '"Not only... but also" — అది మాత్రమే కాదు, ఇది కూడా',
        'English': 'emphatic pair → "not only... but also"',
      },
      localizedTranslations: {
        'Tamil': 'அவன் வெற்றி பெற்றது மட்டுமல்லாமல், சாதனையையும் முறியடித்தான்.',
        'Malayalam': 'അവൻ വിജയിക്കുക മാത്രമല്ല, റെക്കോർഡ് തകർക്കുകയും ചെയ്തു.',
        'Hindi': 'उसने न केवल जीत हासिल की, बल्कि रिकॉर्ड भी तोड़ा।',
        'Telugu': 'అతను గెలవడమే కాకుండా రికార్డును కూడా బద్దలు కొట్టాడు.',
        'English': 'Not only did he win, but he also broke the record.',
      },
    ),
    ConjunctionExerciseItem(
      category: 'CORRELATIVE',
      subCategory: 'Alternative (Whether...Or)',
      rule: '"whether...or" introduces two possibilities regardless of outcome',
      promptSentence: 'I will go for a run ___ it rains or not.',
      targetWord: 'whether',
      acceptableWords: ['whether it', 'run whether', 'whether'],
      fullSentence: 'I will go for a run whether it rains or not.',
      localizedHints: {
        'Tamil': '"whether... or" — மழை பெய்தாலும் பெய்யாவிட்டாலும்: whether it rains or not',
        'Malayalam': '"whether... or" — മഴ പെയ്താലും ഇല്ലെങ്കിലും: whether it rains or not',
        'Hindi': '"whether... or" — चाहे बारिश हो या न हो: whether it rains or not',
        'Telugu': '"whether... or" — వర్షం పడినా పడకపోయినా: whether it rains or not',
        'English': 'regardless of alternative → "whether... or"',
      },
      localizedTranslations: {
        'Tamil': 'மழை பெய்தாலும் பெய்யாவிட்டாலும் நான் ஓடச் செல்வேன்.',
        'Malayalam': 'മഴ പെയ്താലും ഇല്ലെങ്കിലും ഞാൻ ഓടാൻ പോകും.',
        'Hindi': 'चाहे बारिश हो या न हो, मैं दौड़ने जाऊंगा।',
        'Telugu': 'వర్షం పడినా పడకపోయినా నేను పరుగుకు వెళ్తాను.',
        'English': 'I will go for a run whether it rains or not.',
      },
    ),
  ];
}
