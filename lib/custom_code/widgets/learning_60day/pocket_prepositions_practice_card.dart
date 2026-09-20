import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Model for a Prepositions speaking exercise
class PrepExerciseItem {
  final String prepType; // 'IN', 'ON', 'AT'
  final String rule;
  final String promptSentence;
  final String targetWord;
  final List<String> acceptableWords;
  final String fullSentence;
  final Map<String, String> localizedHints;
  final Map<String, String> localizedTranslations;

  const PrepExerciseItem({
    required this.prepType,
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

/// 📍 Prepositions Practice Card — In, On, At
/// Interactive speaking drills with Say It, instant evaluation, written correct
/// answer display, TTS, retry, filter tabs, and step completion tracking.
class PocketPrepositionsPracticeCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const PocketPrepositionsPracticeCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '8',
  });

  @override
  State<PocketPrepositionsPracticeCard> createState() =>
      _PocketPrepositionsPracticeCardState();
}

class _PocketPrepositionsPracticeCardState
    extends State<PocketPrepositionsPracticeCard>
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

  List<PrepExerciseItem> get _filteredExercises {
    switch (_activeFilter) {
      case 'IN':
        return _kPrepExercises.sublist(0, 5);
      case 'ON':
        return _kPrepExercises.sublist(5, 10);
      case 'AT':
        return _kPrepExercises.sublist(10, 15);
      default:
        return _kPrepExercises;
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

  void _bypassForTesting(PrepExerciseItem ex) {
    setState(() {
      _recognizedWords = ex.fullSentence;
      _isExerciseAnswered = true;
      _isCorrect = true;
    });
    HapticFeedback.mediumImpact();
    _speakText(ex.fullSentence);
  }

  // badge colour per preposition type
  Color _badgeColor(String prepType) {
    switch (prepType) {
      case 'IN':
        return const Color(0xFF34D399); // emerald green
      case 'ON':
        return const Color(0xFF06B6D4); // cyan
      case 'AT':
        return const Color(0xFFF472B6); // pink
      default:
        return const Color(0xFF34D399);
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
    final badgeColor = _badgeColor(ex.prepType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFF34D399).withValues(alpha: 0.5),
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF34D399))
                .withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.stepNumber.isNotEmpty
                          ? 'STEP ${widget.stepNumber} • 📍 Prepositions'
                          : '📍 Prepositions (In, On, At)',
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
                        color: const Color(0xFF34D399),
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
                          ? '🎉 Prepositions Practice Completed! (+20 PTS) ✓'
                          : 'Prepositions Practice marked as pending'),
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
          Row(
            children: [
              _buildFilterTab('ALL (15)', 'ALL'),
              const SizedBox(width: 5),
              _buildFilterTab('IN (5)', 'IN'),
              const SizedBox(width: 5),
              _buildFilterTab('ON (5)', 'ON'),
              const SizedBox(width: 5),
              _buildFilterTab('AT (5)', 'AT'),
            ],
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
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map_rounded,
                      color: Color(0xFF34D399), size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _showRuleTable
                          ? 'Hide Prepositions Rule Chart ▲'
                          : 'Show In / On / At Rules (Place & Time) ▼',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF34D399),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsible Rule Table ──────────────────────────────
          if (_showRuleTable) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF13172A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('PLACE'),
                  const SizedBox(height: 4),
                  _buildRuleRow('IN', 'Enclosed space / city / country',
                      'in the room, in Mumbai, in India'),
                  const SizedBox(height: 5),
                  _buildRuleRow('ON', 'Surface / street / device',
                      'on the table, on Main St, on TV'),
                  const SizedBox(height: 5),
                  _buildRuleRow('AT', 'Specific point / address / event',
                      'at the door, at the bus stop, at work'),
                  const SizedBox(height: 10),
                  _sectionLabel('TIME'),
                  const SizedBox(height: 4),
                  _buildRuleRow('IN', 'Month / year / season',
                      'in January, in 2024, in summer'),
                  const SizedBox(height: 5),
                  _buildRuleRow('ON', 'Day / date',
                      'on Monday, on January 15th'),
                  const SizedBox(height: 5),
                  _buildRuleRow('AT', 'Clock time / fixed idiom',
                      'at 5 PM, at midnight, at night'),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Main Speaking Box ───────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF181B26),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isExerciseAnswered && _isCorrect
                    ? const Color(0xFF10B981).withValues(alpha: 0.6)
                    : const Color(0xFF2E3344),
                width: 1.2,
              ),
            ),
            child: Column(
              children: [
                // Meta row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: badgeColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '${ex.prepType}  (${_currentExerciseIndex + 1}/${exercises.length})',
                        style: GoogleFonts.outfit(
                          color: badgeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded,
                          color: Color(0xFFFFD700), size: 20),
                      onPressed: () => _speakText(ex.fullSentence),
                      tooltip: 'Listen to native pronunciation',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Rule label
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Rule: ${ex.rule}',
                    style: GoogleFonts.outfit(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Sentence box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isExerciseAnswered
                          ? (_isCorrect
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444))
                          : const Color(0xFF262A36),
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      displaySentence,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: _isExerciseAnswered && _isCorrect
                            ? const Color(0xFF6EE7B7)
                            : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Translation
                if (localizedMeaning.isNotEmpty)
                  Text(
                    '🗣️ $localizedMeaning',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 6),

                // Hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        localizedHint.isNotEmpty
                            ? localizedHint
                            : ex.targetWord,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFFD54F),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🎤 Say It button
                ScaleTransition(
                  scale: _isListening
                      ? _pulseAnimation
                      : const AlwaysStoppedAnimation(1.0),
                  child: InkWell(
                    onTap: _toggleSayIt,
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: _isListening
                            ? const LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF34D399), Color(0xFF06B6D4)],
                              ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF34D399))
                                .withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isListening
                                ? Icons.graphic_eq_rounded
                                : Icons.mic_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isListening
                                ? 'Listening… Speak now'
                                : 'Say It 🎙️',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Feedback panel
                if (_isExerciseAnswered) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isCorrect
                          ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                          : const Color(0xFF7F1D1D).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
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
                                  : Icons.error_outline_rounded,
                              color: _isCorrect
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF87171),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isCorrect
                                    ? '🎉 Correct! Perfect preposition!'
                                    : 'Almost! Use: "${ex.targetWord}"',
                                style: GoogleFonts.inter(
                                  color: _isCorrect
                                      ? const Color(0xFF6EE7B7)
                                      : const Color(0xFFFCA5A5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Full sentence: "${ex.fullSentence}"',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_recognizedWords.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'You said: "$_recognizedWords"',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 10.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else if (_recognizedWords.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Heard: "$_recognizedWords"',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                InkWell(
                  onTap: () => _bypassForTesting(ex),
                  child: Text(
                    'Tap here if in a quiet room or without mic to verify',
                    style: GoogleFonts.inter(
                      color: Colors.white30,
                      fontSize: 10,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentExerciseIndex > 0)
                      TextButton.icon(
                        onPressed: _goToPrevious,
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white60, size: 15),
                        label: Text(
                          'PREV',
                          style: GoogleFonts.outfit(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    ElevatedButton.icon(
                      onPressed: _goToNext,
                      icon: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 15),
                      label: Text(
                        _currentExerciseIndex < exercises.length - 1
                            ? 'NEXT (${_currentExerciseIndex + 2}/${exercises.length}) ➔'
                            : 'RESTART ➔',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34D399),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Progress dashes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(exercises.length, (idx) {
                    final isActive = idx == _currentExerciseIndex;
                    final isPast = idx < _currentExerciseIndex;
                    return Container(
                      width: exercises.length > 10 ? 14 : 20,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF34D399)
                            : (isPast
                                ? const Color(0xFF10B981)
                                : const Color(0xFF262A36)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Complete Button ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final nextVal = !widget.isCompleted;
                widget.onCompleted(nextVal);
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(nextVal
                        ? '🎉 Prepositions Practice Completed! (+20 PTS) ✓'
                        : 'Prepositions Practice marked as pending'),
                    backgroundColor: nextVal
                        ? const Color(0xFF10B981)
                        : const Color(0xFF334155),
                  ),
                );
              },
              icon: Icon(
                widget.isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.task_alt_rounded,
                color: Colors.white,
                size: 16,
              ),
              label: Text(
                widget.isCompleted
                    ? 'PREPOSITIONS PRACTICE COMPLETED ✓'
                    : 'MARK PREPOSITIONS PRACTICE COMPLETE ✓',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF34D399),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
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

  // ── Helper widgets ──────────────────────────────────────────────

  Widget _buildFilterTab(String label, String filter) {
    final isSel = _activeFilter == filter;
    Color selColor;
    switch (filter) {
      case 'IN':
        selColor = const Color(0xFF34D399);
        break;
      case 'ON':
        selColor = const Color(0xFF06B6D4);
        break;
      case 'AT':
        selColor = const Color(0xFFF472B6);
        break;
      default:
        selColor = const Color(0xFF34D399);
    }
    return Expanded(
      child: InkWell(
        onTap: () => _setFilter(filter),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? selColor : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSel ? selColor : Colors.white12,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSel ? Colors.white : Colors.white70,
                fontSize: 10,
                fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: Colors.white38,
        fontSize: 9.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildRuleRow(String prep, String when, String examples) {
    final Color col = prep == 'IN'
        ? const Color(0xFF34D399)
        : prep == 'ON'
            ? const Color(0xFF06B6D4)
            : const Color(0xFFF472B6);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: col.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              prep,
              style: GoogleFonts.outfit(
                color: col,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                when,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                examples,
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLocalizedSubtitle(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'இட மற்றும் கால உரிச்சொற்கள் பயிற்சி';
      case 'telugu':
        return 'స్థాన మరియు సమయ ఉపసర్గల సాధన';
      case 'hindi':
        return 'स्थान और समय Prepositions अभ्यास';
      case 'kannada':
        return 'ಸ್ಥಳ ಮತ್ತು ಸಮಯ ಉಪಸರ್ಗಗಳ ಅಭ್ಯಾಸ';
      case 'malayalam':
        return 'Prepositions സംസാര പരിശീലനം (In, On, At)';
      default:
        return 'Place & Time Speaking Practice';
    }
  }

  String _getInstructionText(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return '"in" — உள்ளே / நகரம் / ஆண்டு | "on" — மேற்பரப்பு / நாள் | "at" — குறிப்பிட்ட இடம் / நேரம். சரியான preposition சொல்லி பேசுங்கள்.';
      case 'telugu':
        return '"in" — లోపల / నగరం / సంవత్సరం | "on" — ఉపరితలం / రోజు | "at" — నిర్దిష్ట స్థానం / సమయం. సరైన preposition తో వాక్యం పలకండి.';
      case 'hindi':
        return '"in" — अंदर / शहर / साल | "on" — सतह / दिन | "at" — खास जगह / समय। सही preposition बोलकर वाक्य पूरा करें।';
      case 'kannada':
        return '"in" — ಒಳಗೆ / ನಗರ / ವರ್ಷ | "on" — ಮೇಲ್ಮೈ / ದಿನ | "at" — ನಿರ್ದಿಷ್ಟ ಸ್ಥಳ / ಸಮಯ. ಸರಿಯಾದ preposition ಹೇಳಿ ವಾಕ್ಯ ಮಾತನಾಡಿ.';
      case 'malayalam':
        return '"in" — ഉള്ളിൽ / നഗരം / വർഷം | "on" — പ്രതലം / ദിവസം | "at" — നിർദ്ദിഷ്ട സ്ഥലം / സമയം. ശരിയായ preposition ഉച്ചരിച്ച് വാക്യം പറയുക.';
      default:
        return '"in" = enclosed/city/year | "on" = surface/day | "at" = specific point/time. Fill the blank and say the full sentence aloud.';
    }
  }

  // ── 15 EXERCISES: 5 IN + 5 ON + 5 AT ───────────────────────────
  static const List<PrepExerciseItem> _kPrepExercises = [
    // ─── IN (1-5) ─────────────────────────────────────────────
    PrepExerciseItem(
      prepType: 'IN',
      rule: '"in" — cities and countries (enclosed area)',
      promptSentence: 'I live ___ Mumbai with my family.',
      targetWord: 'in',
      acceptableWords: ['in mumbai', 'live in', 'in'],
      fullSentence: 'I live in Mumbai with my family.',
      localizedHints: {
        'Tamil': 'நகரங்கள் மற்றும் நாடுகளுடன் "in" பயன்படுத்தவும் (in Mumbai)',
        'Malayalam': 'നഗരങ്ങൾ, രാജ്യങ്ങൾ — "in" ഉപയോഗിക്കുക (in Mumbai)',
        'Hindi': 'शहर और देश के साथ "in" → in Mumbai',
        'Telugu': 'నగరాలు మరియు దేశాలతో "in" వాడండి (in Mumbai)',
        'English': 'cities and countries → "in": in Mumbai, in India',
      },
      localizedTranslations: {
        'Tamil': 'நான் என் குடும்பத்துடன் மும்பையில் வசிக்கிறேன்.',
        'Malayalam': 'ഞാൻ കുടുംബത്തോടൊപ്പം മുംബൈയിൽ താമസിക്കുന്നു.',
        'Hindi': 'मैं अपने परिवार के साथ मुंबई में रहता हूँ।',
        'Telugu': 'నేను నా కుటుంబంతో ముంబైలో నివసిస్తున్నాను.',
        'English': 'I live in Mumbai with my family.',
      },
    ),
    PrepExerciseItem(
      prepType: 'IN',
      rule: '"in" — enclosed spaces (inside a room, box, building)',
      promptSentence: 'The keys are ___ the drawer.',
      targetWord: 'in',
      acceptableWords: ['in the drawer', 'are in', 'in'],
      fullSentence: 'The keys are in the drawer.',
      localizedHints: {
        'Tamil': 'மூடப்பட்ட இடங்களுக்கு "in": in the drawer (ஒரு இடத்திற்குள்)',
        'Malayalam': 'അടைഞ്ഞ സ്ഥലത്തിന് "in": in the drawer',
        'Hindi': 'बंद जगहों के लिए "in": in the drawer',
        'Telugu': 'మూసిన స్థలాలకు "in": in the drawer',
        'English': 'enclosed spaces → "in": in the box, in the room, in the drawer',
      },
      localizedTranslations: {
        'Tamil': 'சாவிகள் டிராயரில் உள்ளன.',
        'Malayalam': 'താക്കോലുകൾ ഡ്രോർ ഉള്ളിലാണ്.',
        'Hindi': 'चाबियाँ दराज में हैं।',
        'Telugu': 'తాళాలు డ్రాయర్‌లో ఉన్నాయి.',
        'English': 'The keys are in the drawer.',
      },
    ),
    PrepExerciseItem(
      prepType: 'IN',
      rule: '"in" — seasons (in summer, in winter)',
      promptSentence: 'We go to the beach ___ summer.',
      targetWord: 'in',
      acceptableWords: ['in summer', 'beach in', 'in'],
      fullSentence: 'We go to the beach in summer.',
      localizedHints: {
        'Tamil': 'பருவகாலங்களுக்கு "in": in summer, in winter, in monsoon',
        'Malayalam': 'കാലങ്ങൾക്ക് "in": in summer, in winter',
        'Hindi': 'मौसमों के साथ "in": in summer, in winter',
        'Telugu': 'ఋతువులకు "in": in summer, in winter',
        'English': 'seasons → "in": in summer, in winter, in spring',
      },
      localizedTranslations: {
        'Tamil': 'நாங்கள் கோடை காலத்தில் கடற்கரைக்கு செல்கிறோம்.',
        'Malayalam': 'ഞങ്ങൾ വേനൽക്കാലത്ത് കടൽത്തീരത്ത് പോകുന്നു.',
        'Hindi': 'हम गर्मियों में समुद्र तट जाते हैं।',
        'Telugu': 'మేము వేసవిలో సముద్రతీరానికి వెళ్తాము.',
        'English': 'We go to the beach in summer.',
      },
    ),
    PrepExerciseItem(
      prepType: 'IN',
      rule: '"in" — years and months (in 2024, in January)',
      promptSentence: 'She was born ___ 1998.',
      targetWord: 'in',
      acceptableWords: ['in 1998', 'born in', 'in'],
      fullSentence: 'She was born in 1998.',
      localizedHints: {
        'Tamil': 'ஆண்டுகள் மற்றும் மாதங்களுக்கு "in": in 1998, in January',
        'Malayalam': 'വർഷങ്ങൾ, മാസങ്ങൾ — "in": in 1998, in January',
        'Hindi': 'साल और महीनों के साथ "in": in 1998, in January',
        'Telugu': 'సంవత్సరాలు మరియు నెలలకు "in": in 1998, in January',
        'English': 'years and months → "in": in 1998, in January, in 2024',
      },
      localizedTranslations: {
        'Tamil': 'அவள் 1998 ஆம் ஆண்டு பிறந்தாள்.',
        'Malayalam': 'അവൾ 1998-ൽ ജനിച്ചു.',
        'Hindi': 'उसका जन्म 1998 में हुआ था।',
        'Telugu': 'ఆమె 1998లో జన్మించింది.',
        'English': 'She was born in 1998.',
      },
    ),
    PrepExerciseItem(
      prepType: 'IN',
      rule: '"in" — time of day (in the morning, in the afternoon)',
      promptSentence: 'I exercise ___ the morning every day.',
      targetWord: 'in',
      acceptableWords: ['in the morning', 'exercise in', 'in'],
      fullSentence: 'I exercise in the morning every day.',
      localizedHints: {
        'Tamil': 'நாள் பகுதிகளுக்கு "in": in the morning, in the evening (ஆனால்: at night)',
        'Malayalam': 'ദിവസ ഭാഗത്തിന് "in": in the morning, in the evening (ശ്രദ്ധ: at night)',
        'Hindi': 'दिन के हिस्सों के लिए "in": in the morning, in the evening (लेकिन: at night)',
        'Telugu': 'రోజు భాగాలకు "in": in the morning, in the evening (కానీ: at night)',
        'English': 'parts of the day → "in": in the morning, in the evening (but: at night)',
      },
      localizedTranslations: {
        'Tamil': 'நான் தினமும் காலையில் உடற்பயிற்சி செய்கிறேன்.',
        'Malayalam': 'ഞാൻ എല്ലാ ദിവസവും രാവിലെ വ്യായാമം ചെയ്യുന്നു.',
        'Hindi': 'मैं हर दिन सुबह व्यायाम करता हूँ।',
        'Telugu': 'నేను ప్రతిరోజూ ఉదయం వ్యాయామం చేస్తాను.',
        'English': 'I exercise in the morning every day.',
      },
    ),

    // ─── ON (6-10) ────────────────────────────────────────────
    PrepExerciseItem(
      prepType: 'ON',
      rule: '"on" — surfaces (on the table, on the floor)',
      promptSentence: 'Your phone is ___ the table.',
      targetWord: 'on',
      acceptableWords: ['on the table', 'is on', 'on'],
      fullSentence: 'Your phone is on the table.',
      localizedHints: {
        'Tamil': 'மேற்பரப்புகளுக்கு "on": on the table (மேசையின் மேல்)',
        'Malayalam': 'ഉപരിതലങ്ങൾക്ക് "on": on the table (മേശ മുകളിൽ)',
        'Hindi': 'सतह के लिए "on": on the table (मेज़ के ऊपर)',
        'Telugu': 'ఉపరితలాలకు "on": on the table (బల్ల పైన)',
        'English': 'surfaces → "on": on the table, on the floor, on the wall',
      },
      localizedTranslations: {
        'Tamil': 'உங்கள் தொலைபேசி மேசையில் உள்ளது.',
        'Malayalam': 'നിങ്ങളുടെ ഫോൺ മേശ മുകളിൽ ഉണ്ട്.',
        'Hindi': 'आपका फ़ोन मेज़ पर है।',
        'Telugu': 'మీ ఫోన్ టేబుల్ పైన ఉంది.',
        'English': 'Your phone is on the table.',
      },
    ),
    PrepExerciseItem(
      prepType: 'ON',
      rule: '"on" — days and specific dates (on Monday, on July 4th)',
      promptSentence: 'We have a meeting ___ Friday.',
      targetWord: 'on',
      acceptableWords: ['on friday', 'meeting on', 'on'],
      fullSentence: 'We have a meeting on Friday.',
      localizedHints: {
        'Tamil': 'நாட்கள் மற்றும் தேதிகளுக்கு "on": on Friday, on January 15th',
        'Malayalam': 'ദിവസങ്ങൾ, തീയതികൾ — "on": on Friday, on January 15th',
        'Hindi': 'दिनों और तारीखों के साथ "on": on Friday, on January 15th',
        'Telugu': 'రోజులు మరియు తేదీలకు "on": on Friday, on January 15th',
        'English': 'days and dates → "on": on Monday, on July 4th, on Friday',
      },
      localizedTranslations: {
        'Tamil': 'வெள்ளிக்கிழமை எங்களுக்கு ஒரு கூட்டம் உள்ளது.',
        'Malayalam': 'വെള്ളിയാഴ്ച ഞങ്ങൾക്ക് ഒരു മീറ്റിംഗ് ഉണ്ട്.',
        'Hindi': 'शुक्रवार को हमारी एक बैठक है।',
        'Telugu': 'శుక్రవారం మాకు ఒక సమావేశం ఉంది.',
        'English': 'We have a meeting on Friday.',
      },
    ),
    PrepExerciseItem(
      prepType: 'ON',
      rule: '"on" — electronic devices and media (on TV, on the phone)',
      promptSentence: 'I saw the news ___ TV last night.',
      targetWord: 'on',
      acceptableWords: ['on tv', 'news on', 'on'],
      fullSentence: 'I saw the news on TV last night.',
      localizedHints: {
        'Tamil': 'தொழில்நுட்ப சாதனங்கள், ஊடகங்களுக்கு "on": on TV, on the radio, on the phone',
        'Malayalam': 'ഡിജിറ്റൽ ഉപകരണങ്ങൾ, മാധ്യമങ്ങൾ — "on": on TV, on the radio',
        'Hindi': 'इलेक्ट्रॉनिक मीडिया के लिए "on": on TV, on radio, on the phone',
        'Telugu': 'ఎలక్ట్రానిక్ మీడియాకు "on": on TV, on the radio, on the phone',
        'English': 'electronic devices/media → "on": on TV, on the radio, on the phone',
      },
      localizedTranslations: {
        'Tamil': 'நேற்று இரவு டெலிவிஷனில் செய்தி பார்த்தேன்.',
        'Malayalam': 'ഇന്നലെ രാത്രി ടിവിയിൽ വാർത്ത കണ്ടു.',
        'Hindi': 'कल रात मैंने टीवी पर खबर देखी।',
        'Telugu': 'నేను నిన్న రాత్రి టీవీలో వార్తలు చూశాను.',
        'English': 'I saw the news on TV last night.',
      },
    ),
    PrepExerciseItem(
      prepType: 'ON',
      rule: '"on" — streets and roads (on Main Street, on the highway)',
      promptSentence: 'Her shop is ___ Gandhi Road.',
      targetWord: 'on',
      acceptableWords: ['on gandhi', 'shop is on', 'on'],
      fullSentence: 'Her shop is on Gandhi Road.',
      localizedHints: {
        'Tamil': 'தெருக்கள் மற்றும் சாலைகளுக்கு "on": on Gandhi Road, on Main Street',
        'Malayalam': 'തെരുവുകൾ, റോഡുകൾ — "on": on Gandhi Road, on Main Street',
        'Hindi': 'सड़कों के लिए "on": on Gandhi Road, on Main Street',
        'Telugu': 'రహదారులకు "on": on Gandhi Road, on Main Street',
        'English': 'streets and roads → "on": on Main Street, on Gandhi Road',
      },
      localizedTranslations: {
        'Tamil': 'அவளது கடை காந்தி சாலையில் உள்ளது.',
        'Malayalam': 'അവളുടെ കട ഗാന്ധി റോഡിലാണ്.',
        'Hindi': 'उसकी दुकान गांधी रोड पर है।',
        'Telugu': 'ఆమె దుకాణం గాంధీ రోడ్ పై ఉంది.',
        'English': 'Her shop is on Gandhi Road.',
      },
    ),
    PrepExerciseItem(
      prepType: 'ON',
      rule: '"on" — specific date (on + date)',
      promptSentence: 'My birthday falls ___ March 10th.',
      targetWord: 'on',
      acceptableWords: ['on march', 'falls on', 'on'],
      fullSentence: 'My birthday falls on March 10th.',
      localizedHints: {
        'Tamil': 'குறிப்பிட்ட தேதிகளுக்கு "on": on March 10th, on December 25th',
        'Malayalam': 'നിർദ്ദിഷ്ട തീയതിക്ക് "on": on March 10th, on December 25th',
        'Hindi': 'खास तारीखों के साथ "on": on March 10th, on December 25th',
        'Telugu': 'నిర్దిష్ట తేదీలకు "on": on March 10th, on December 25th',
        'English': 'specific dates → "on": on March 10th, on December 25th',
      },
      localizedTranslations: {
        'Tamil': 'என் பிறந்தநாள் மார்ச் 10 ஆம் தேதி வருகிறது.',
        'Malayalam': 'എന്റെ ജന്മദിനം മാർച്ച് 10-ന് ആണ്.',
        'Hindi': 'मेरा जन्मदिन 10 मार्च को पड़ता है।',
        'Telugu': 'నా పుట్టిన రోజు మార్చి 10వ తేదీన వస్తుంది.',
        'English': 'My birthday falls on March 10th.',
      },
    ),

    // ─── AT (11-15) ───────────────────────────────────────────
    PrepExerciseItem(
      prepType: 'AT',
      rule: '"at" — specific points/locations (at the bus stop)',
      promptSentence: 'She is waiting ___ the bus stop.',
      targetWord: 'at',
      acceptableWords: ['at the bus', 'waiting at', 'at'],
      fullSentence: 'She is waiting at the bus stop.',
      localizedHints: {
        'Tamil': 'குறிப்பிட்ட இடங்களுக்கு "at": at the bus stop, at the corner',
        'Malayalam': 'നിർദ്ദിഷ്ട സ്ഥലങ്ങൾ — "at": at the bus stop, at the corner',
        'Hindi': 'खास जगहों के लिए "at": at the bus stop, at the corner',
        'Telugu': 'నిర్దిష్ట స్థలాలకు "at": at the bus stop, at the corner',
        'English': 'specific points → "at": at the door, at the bus stop, at the corner',
      },
      localizedTranslations: {
        'Tamil': 'அவள் பேருந்து நிறுத்தத்தில் காத்திருக்கிறாள்.',
        'Malayalam': 'അവൾ ബസ് സ്റ്റോപ്പിൽ കാത്തിരിക്കുന്നു.',
        'Hindi': 'वह बस स्टॉप पर इंतज़ार कर रही है।',
        'Telugu': 'ఆమె బస్ స్టాప్ వద్ద వేచి ఉంది.',
        'English': 'She is waiting at the bus stop.',
      },
    ),
    PrepExerciseItem(
      prepType: 'AT',
      rule: '"at" — clock times (at 5 PM, at midnight)',
      promptSentence: 'The train arrives ___ 6 AM.',
      targetWord: 'at',
      acceptableWords: ['at 6', 'arrives at', 'at'],
      fullSentence: 'The train arrives at 6 AM.',
      localizedHints: {
        'Tamil': 'கடிகார நேரங்களுக்கு "at": at 6 AM, at 5 PM, at midnight',
        'Malayalam': 'ഘടിക സമയങ്ങൾക്ക് "at": at 6 AM, at 5 PM, at midnight',
        'Hindi': 'घड़ी के समय के साथ "at": at 6 AM, at 5 PM, at midnight',
        'Telugu': 'గడియారం సమయాలకు "at": at 6 AM, at 5 PM, at midnight',
        'English': 'clock times → "at": at 3 PM, at 6 AM, at midnight, at noon',
      },
      localizedTranslations: {
        'Tamil': 'ரயில் காலை 6 மணிக்கு வருகிறது.',
        'Malayalam': 'ട്രെയിൻ രാവിലെ 6 മണിക്ക് എത്തുന്നു.',
        'Hindi': 'ट्रेन सुबह 6 बजे आती है।',
        'Telugu': 'రైలు ఉదయం 6 గంటలకు వస్తుంది.',
        'English': 'The train arrives at 6 AM.',
      },
    ),
    PrepExerciseItem(
      prepType: 'AT',
      rule: '"at" — events and venues (at the cinema, at school)',
      promptSentence: 'I met him ___ the cinema last week.',
      targetWord: 'at',
      acceptableWords: ['at the cinema', 'met him at', 'at'],
      fullSentence: 'I met him at the cinema last week.',
      localizedHints: {
        'Tamil': 'நிகழ்வுகள் மற்றும் இடங்களுக்கு "at": at the cinema, at school, at a party',
        'Malayalam': 'ഇവന്റുകൾ, ഇടങ്ങൾ — "at": at the cinema, at school, at a party',
        'Hindi': 'कार्यक्रम/जगहों के लिए "at": at the cinema, at school, at a party',
        'Telugu': 'కార్యక్రమాలు మరియు ప్రదేశాలకు "at": at the cinema, at school',
        'English': 'events and venues → "at": at the cinema, at school, at a party',
      },
      localizedTranslations: {
        'Tamil': 'கடந்த வாரம் சினிமா திரையரங்கில் அவனை சந்தித்தேன்.',
        'Malayalam': 'കഴിഞ്ഞ ആഴ്ച സിനിമ ഹാളിൽ അവനെ കണ്ടു.',
        'Hindi': 'पिछले हफ्ते मैं उससे सिनेमा में मिला।',
        'Telugu': 'గత వారం సినిమా హాల్ వద్ద అతన్ని కలిశాను.',
        'English': 'I met him at the cinema last week.',
      },
    ),
    PrepExerciseItem(
      prepType: 'AT',
      rule: '"at night" — fixed idiom (not "in the night")',
      promptSentence: 'It gets very cold ___ night in December.',
      targetWord: 'at',
      acceptableWords: ['at night', 'cold at', 'at'],
      fullSentence: 'It gets very cold at night in December.',
      localizedHints: {
        'Tamil': '"at night" என்பது நிலையான சொற்றொடர் — "in the night" தவறானது',
        'Malayalam': '"at night" ഒരു fixed idiom ആണ് — "in the night" തെറ്റ്',
        'Hindi': '"at night" एक fixed phrase है — "in the night" कहना गलत है',
        'Telugu': '"at night" ఒక fixed idiom — "in the night" అనడం తప్పు',
        'English': '"at night" is a fixed idiom — never use "in the night"',
      },
      localizedTranslations: {
        'Tamil': 'டிசம்பரில் இரவில் மிகவும் குளிராக இருக்கும்.',
        'Malayalam': 'ഡിസംബറിൽ രാത്രി വളരെ തണുപ്പ് ആകും.',
        'Hindi': 'दिसंबर में रात को बहुत ठंड पड़ती है।',
        'Telugu': 'డిసెంబర్‌లో రాత్రి చాలా చలిగా ఉంటుంది.',
        'English': 'It gets very cold at night in December.',
      },
    ),
    PrepExerciseItem(
      prepType: 'AT',
      rule: '"at work" / "at home" — fixed location idioms',
      promptSentence: 'He is still ___ work right now.',
      targetWord: 'at',
      acceptableWords: ['at work', 'still at', 'at'],
      fullSentence: 'He is still at work right now.',
      localizedHints: {
        'Tamil': '"at work", "at home", "at school" — நிலையான சொற்றொடர்கள்',
        'Malayalam': '"at work", "at home", "at school" — fixed phrases ആണ്',
        'Hindi': '"at work", "at home", "at school" — fixed phrases हैं',
        'Telugu': '"at work", "at home", "at school" — fixed phrases',
        'English': '"at work", "at home", "at school" are fixed location idioms',
      },
      localizedTranslations: {
        'Tamil': 'அவன் இப்போதும் வேலையில் இருக்கிறான்.',
        'Malayalam': 'അവൻ ഇപ്പോഴും ജോലിയിൽ ഉണ്ട്.',
        'Hindi': 'वह अभी भी काम पर है।',
        'Telugu': 'అతను ఇంకా పని వద్ద ఉన్నాడు.',
        'English': 'He is still at work right now.',
      },
    ),
  ];
}
