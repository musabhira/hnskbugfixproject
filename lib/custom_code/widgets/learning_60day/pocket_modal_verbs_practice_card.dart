import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Model for a Modal Verbs speaking exercise
class ModalExerciseItem {
  final String modalType; // 'CAN', 'MUST', 'SHOULD', 'OTHER'
  final String usageCategory; // 'Ability', 'Permission', 'Obligation', 'Advice', etc.
  final String rule;
  final String promptSentence;
  final String targetWord;
  final List<String> acceptableWords;
  final String fullSentence;
  final Map<String, String> localizedHints;
  final Map<String, String> localizedTranslations;

  const ModalExerciseItem({
    required this.modalType,
    required this.usageCategory,
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

/// 🎯 Modal Verbs Practice Card — Can, Must, Should (+ Could, May, Might, Would)
/// Real-time speaking practice with "Say It", instant evaluation, written correct
/// answer display, TTS audio, retry capability, filter tabs, and progress tracking.
class PocketModalVerbsPracticeCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const PocketModalVerbsPracticeCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '9',
  });

  @override
  State<PocketModalVerbsPracticeCard> createState() =>
      _PocketModalVerbsPracticeCardState();
}

class _PocketModalVerbsPracticeCardState
    extends State<PocketModalVerbsPracticeCard>
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

  List<ModalExerciseItem> get _filteredExercises {
    switch (_activeFilter) {
      case 'CAN':
        return _kModalExercises.where((e) => e.modalType == 'CAN').toList();
      case 'MUST':
        return _kModalExercises.where((e) => e.modalType == 'MUST').toList();
      case 'SHOULD':
        return _kModalExercises.where((e) => e.modalType == 'SHOULD').toList();
      case 'OTHER':
        return _kModalExercises.where((e) => e.modalType == 'OTHER').toList();
      default:
        return _kModalExercises;
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

  void _bypassForTesting(ModalExerciseItem ex) {
    setState(() {
      _recognizedWords = ex.fullSentence;
      _isExerciseAnswered = true;
      _isCorrect = true;
    });
    HapticFeedback.mediumImpact();
    _speakText(ex.fullSentence);
  }

  Color _badgeColor(String modalType) {
    switch (modalType) {
      case 'CAN':
        return const Color(0xFF10B981); // emerald green
      case 'MUST':
        return const Color(0xFFEF4444); // red / urgency
      case 'SHOULD':
        return const Color(0xFFF59E0B); // amber / advice
      case 'OTHER':
        return const Color(0xFF8B5CF6); // purple / possibility
      default:
        return const Color(0xFF10B981);
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
    final badgeColor = _badgeColor(ex.modalType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFFF59E0B).withValues(alpha: 0.5),
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B))
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
                          ? 'STEP ${widget.stepNumber} • 🎯 Modal Verbs'
                          : '🎯 Modal Verbs (Can, Must, Should)',
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
                        color: const Color(0xFFF59E0B),
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
                          ? '🎉 Modal Verbs Practice Completed! (+20 PTS) ✓'
                          : 'Modal Verbs Practice marked as pending'),
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
                _buildFilterTab('ALL (20)', 'ALL'),
                const SizedBox(width: 5),
                _buildFilterTab('CAN (5)', 'CAN'),
                const SizedBox(width: 5),
                _buildFilterTab('MUST (5)', 'MUST'),
                const SizedBox(width: 5),
                _buildFilterTab('SHOULD (5)', 'SHOULD'),
                const SizedBox(width: 5),
                _buildFilterTab('MAY/MIGHT (5)', 'OTHER'),
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
                      ? const Color(0xFFF59E0B)
                      : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book_rounded,
                      color: Color(0xFFF59E0B), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    _showRuleTable
                        ? 'Hide Modal Verbs Rules & Matrix ▲'
                        : 'Quick Modal Verbs Rules & Base Verb Guide ▼',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFDE68A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
                // Exercise Header
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
                        '${ex.modalType} • ${ex.usageCategory}',
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
                                    ? 'Great pronunciation! Correct modal verb ✓'
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
                          'Target: "${ex.targetWord}" (${ex.usageCategory})',
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
                                    : const Color(0xFFF59E0B),
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
                            color: Color(0xFF67E8F9), size: 20),
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
                                  ? const Color(0xFFF59E0B)
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
                          color: const Color(0xFFF59E0B),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      icon: const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFFF59E0B), size: 18),
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
                        ? '🎯 Modal Verbs Mastery Completed! (+20 PTS) ✓'
                        : 'Modal Verbs Practice marked as pending'),
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
                    : const Color(0xFFF59E0B),
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
              ? const Color(0xFFF59E0B)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF59E0B)
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
            '📌 Golden Grammar Rule: Modal + Base Verb',
            style: GoogleFonts.outfit(
              color: const Color(0xFFFDE68A),
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '• Modals are always followed by the base verb without "to", "-s", or "-ing".\n'
            '  ✓ He can swim (NOT "he cans" / "can to swim")\n'
            '  ✓ She must go (NOT "she musts" / "must to go")\n'
            '  ✓ They should study (NOT "should studying")',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),
          Text(
            '🎯 Modal Meanings & Differences at a Glance:',
            style: GoogleFonts.outfit(
              color: const Color(0xFF67E8F9),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          _buildRuleRow('CAN', 'Ability / Permission', 'I can swim • Can I open the window?'),
          _buildRuleRow('COULD', 'Past ability / Polite request', 'Could you help me? • I could run fast'),
          _buildRuleRow('MUST', 'Strong rule / Obligation', 'You must wear a seatbelt • I must finish'),
          _buildRuleRow('MUST NOT', 'Strictly forbidden', 'You must not smoke here (mustn\'t)'),
          _buildRuleRow('SHOULD', 'Advice / Recommendation', 'You should see a doctor • We should leave'),
          _buildRuleRow('MAY / MIGHT', 'Possibility / Formal permission', 'May I sit here? • It might rain today'),
          _buildRuleRow('WOULD', 'Polite offer / Hypothetical', 'Would you like coffee? • I would travel'),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String modal, String meaning, String example) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              modal,
              style: GoogleFonts.outfit(
                color: const Color(0xFFF59E0B),
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
        return 'மாதிரி வினைச்சொற்கள் பேச்சுப் பயிற்சி';
      case 'telugu':
        return 'మోడల్ వెర్బ్‌లు మాట్లాడే సాధన';
      case 'hindi':
        return 'मॉडल क्रियाएं बोलने का अभ्यास';
      case 'kannada':
        return 'ಮಾದರಿ ಕ್ರಿಯಾಪದಗಳ ಮಾತನಾಡುವ ಅಭ್ಯಾಸ';
      case 'malayalam':
        return 'മോഡൽ ക്രിയകൾ സംസാര പരിശീലനം';
      default:
        return 'Ability, Obligation & Advice Practice';
    }
  }

  String _getInstructionText(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'வாக்கியத்தை உரக்கக் கூறி இடைவெளியை நிரப்பவும். பேசுவதற்கு 🎤 "Say It Aloud" தட்டவும்.';
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
        return 'மாதிரி வினைச்சொற்கள் தேர்ச்சி பெற்றது ✓';
      case 'telugu':
        return 'మోడల్ వెర్బ్‌ల సాధన పూర్తయింది ✓';
      case 'hindi':
        return 'मॉडल क्रियाएं अभ्यास पूर्ण ✓';
      case 'kannada':
        return 'ಮಾದರಿ ಕ್ರಿಯಾಪದ ಅಭ್ಯಾಸ ಪೂರ್ಣಗೊಂಡಿದೆ ✓';
      case 'malayalam':
        return 'മോഡൽ ക്രിയകൾ പരിശീലിച്ചു കഴിഞ്ഞു ✓';
      default:
        return 'MODAL VERBS MASTERED ✓';
    }
  }

  String _getPendingButtonLabel(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'இந்த மாதிரி வினைச்சொற்களைப் பழகினேன் ✓';
      case 'telugu':
        return 'ఈ మోడల్ వెర్బ్‌లను సాధన చేశాను ✓';
      case 'hindi':
        return 'मैंने इन मॉडल क्रियाओं का अभ्यास किया ✓';
      case 'kannada':
        return 'ಈ ಮಾದರಿ ಕ್ರಿಯಾಪದಗಳನ್ನು ಅಭ್ಯಾಸ ಮಾಡಿದೆ ✓';
      case 'malayalam':
        return 'ഈ മോഡൽ ക്രിയകൾ ഉറക്കെ പരിശീലിച്ചു ✓';
      default:
        return 'I PRACTICED THESE MODAL VERBS ALOUD ✓';
    }
  }

  static const List<ModalExerciseItem> _kModalExercises = [
    // ─── CAN (Ability & Permission) ───────────────────────────
    ModalExerciseItem(
      modalType: 'CAN',
      usageCategory: 'Ability',
      rule: '"can" shows ability (what you know how to do)',
      promptSentence: 'You ___ speak English very well.',
      targetWord: 'can',
      acceptableWords: ['can speak', 'you can', 'can'],
      fullSentence: 'You can speak English very well.',
      localizedHints: {
        'Tamil': 'திறமையைக் குறிக்க "can" பயன்படுத்தவும்: You can speak',
        'Malayalam': 'കഴിവ് സൂചിപ്പിക്കാൻ "can" ഉപയോഗിക്കുക: You can speak',
        'Hindi': 'क्षमता दर्शाने के लिए "can" का प्रयोग करें: You can speak',
        'Telugu': 'సామర్థ్యాన్ని సూచించడానికి "can" ఉపయోగించండి: You can speak',
        'English': 'ability → "can": You can speak English very well.',
      },
      localizedTranslations: {
        'Tamil': 'நீங்கள் ஆங்கிலம் மிக நன்றாகப் பேச முடியும்.',
        'Malayalam': 'നിങ്ങൾക്ക് വളരെ നന്നായി ഇംഗ്ലീഷ് സംസാരിക്കാൻ കഴിയും.',
        'Hindi': 'आप बहुत अच्छी अंग्रेजी बोल सकते हैं।',
        'Telugu': 'మీరు ఇంగ్లీష్ చాలా బాగా మాట్లాడగలరు.',
        'English': 'You can speak English very well.',
      },
    ),
    ModalExerciseItem(
      modalType: 'CAN',
      usageCategory: 'Ability',
      rule: '"can" shows physical skill or knowledge',
      promptSentence: 'I ___ swim across the pool easily.',
      targetWord: 'can',
      acceptableWords: ['can swim', 'i can', 'can'],
      fullSentence: 'I can swim across the pool easily.',
      localizedHints: {
        'Tamil': 'நீச்சல் திறமையைக் குறிக்க "can": I can swim',
        'Malayalam': 'നീന്തൽ കഴിവ് — "can": I can swim',
        'Hindi': 'तैरने की क्षमता — "can": I can swim',
        'Telugu': 'ఈత సామర్థ్యం — "can": I can swim',
        'English': 'ability → "can": I can swim.',
      },
      localizedTranslations: {
        'Tamil': 'என்னால் குளத்தில் எளிதாக நீந்த முடியும்.',
        'Malayalam': 'എനിക്ക് കുളത്തിൽ എളുപ്പത്തിൽ നീന്താൻ കഴിയും.',
        'Hindi': 'मैं पूल में आसानी से तैर सकता हूँ।',
        'Telugu': 'నేను పూల్‌లో సులభంగా ఈదగలను.',
        'English': 'I can swim across the pool easily.',
      },
    ),
    ModalExerciseItem(
      modalType: 'CAN',
      usageCategory: 'Permission',
      rule: '"can" asks for informal permission',
      promptSentence: '___ I open the window, please?',
      targetWord: 'can',
      acceptableWords: ['can i', 'can open', 'can'],
      fullSentence: 'Can I open the window, please?',
      localizedHints: {
        'Tamil': 'அனுமதி கேட்க "Can I...": Can I open the window?',
        'Malayalam': 'അനുവാദം ചോദിക്കാൻ "Can I...": Can I open the window?',
        'Hindi': 'अनुमति माँगने के लिए "Can I...": Can I open the window?',
        'Telugu': 'అనుమతి అడగడానికి "Can I...": Can I open the window?',
        'English': 'informal permission → "can": Can I open the window?',
      },
      localizedTranslations: {
        'Tamil': 'நான் சன்னலைத் திறக்கலாமா?',
        'Malayalam': 'ഞാൻ ജനൽ തുറന്നോട്ടെ?',
        'Hindi': 'क्या मैं खिड़की खोल सकता हूँ?',
        'Telugu': 'నేను కిటికీ తెరవవచ్చా?',
        'English': 'Can I open the window, please?',
      },
    ),
    ModalExerciseItem(
      modalType: 'CAN',
      usageCategory: 'Ability',
      rule: 'Base verb after modal (She can speak, NOT she cans)',
      promptSentence: 'She ___ speak three languages fluently.',
      targetWord: 'can',
      acceptableWords: ['can speak', 'she can', 'can'],
      fullSentence: 'She can speak three languages fluently.',
      localizedHints: {
        'Tamil': 'மூன்றாம் நபருக்கும் "can speak" மட்டுமே ("cans" தவறானது)',
        'Malayalam': '"can speak" മാത്രം ("cans" തെറ്റ്)',
        'Hindi': 'हमेशा "can speak" का उपयोग करें ("cans" गलत है)',
        'Telugu': '"can speak" మాత్రమే ("cans" తప్పు)',
        'English': 'no -s with modals → "She can speak", never "she cans"',
      },
      localizedTranslations: {
        'Tamil': 'அவளால் மூன்று மொழிகளை சரளமாக பேச முடியும்.',
        'Malayalam': 'അവൾക്ക് മൂന്ന് ഭാഷകൾ ഒഴുക്കോടെ സംസാരിക്കാൻ കഴിയും.',
        'Hindi': 'वह धाराप्रवाह तीन भाषाएं बोल सकती है।',
        'Telugu': 'ఆమె మూడు భాషలు అనర్గళంగా మాట్లాడగలదు.',
        'English': 'She can speak three languages fluently.',
      },
    ),
    ModalExerciseItem(
      modalType: 'CAN',
      usageCategory: 'Permission',
      rule: '"can" gives permission to someone',
      promptSentence: 'You ___ sit here if this seat is free.',
      targetWord: 'can',
      acceptableWords: ['can sit', 'you can', 'can'],
      fullSentence: 'You can sit here if this seat is free.',
      localizedHints: {
        'Tamil': 'அனுமதி வழங்க "can sit": You can sit here',
        'Malayalam': 'അനുവാദം നൽകാൻ "can sit": You can sit here',
        'Hindi': 'अनुमति देने के लिए "can sit": You can sit here',
        'Telugu': 'అనుమతి ఇవ్వడానికి "can sit": You can sit here',
        'English': 'giving permission → "can": You can sit here.',
      },
      localizedTranslations: {
        'Tamil': 'இந்த இடம் காலியாக இருந்தால் நீங்கள் இங்கே உட்காரலாம்.',
        'Malayalam': 'ഈ സീറ്റ് ഒഴിഞ്ഞുകിടക്കുകയാണെങ്കിൽ നിങ്ങൾക്ക് ഇവിടെ ഇരിക്കാം.',
        'Hindi': 'अगर यह सीट खाली है तो आप यहाँ बैठ सकते हैं।',
        'Telugu': 'ఈ సీటు ఖాళీగా ఉంటే మీరు ఇక్కడ కూర్చోవచ్చు.',
        'English': 'You can sit here if this seat is free.',
      },
    ),

    // ─── MUST (Obligation, Rules, Necessity, Forbidden) ───────
    ModalExerciseItem(
      modalType: 'MUST',
      usageCategory: 'Rule',
      rule: '"must" indicates a strict legal rule or requirement',
      promptSentence: 'You ___ wear a seatbelt while driving.',
      targetWord: 'must',
      acceptableWords: ['must wear', 'you must', 'must'],
      fullSentence: 'You must wear a seatbelt while driving.',
      localizedHints: {
        'Tamil': 'கட்டாய சட்டம்/விதிக்கு "must": You must wear a seatbelt',
        'Malayalam': 'കർശന നിയമത്തിന് "must": You must wear a seatbelt',
        'Hindi': 'कड़े नियम के लिए "must": You must wear a seatbelt',
        'Telugu': 'కచ్చితమైన నిబంధనకు "must": You must wear a seatbelt',
        'English': 'legal rules and laws → "must": You must wear a seatbelt.',
      },
      localizedTranslations: {
        'Tamil': 'வாகனம் ஓட்டும்போது நீங்கள் சீட்பெல்ட் அணிய வேண்டும் (கட்டாயம்).',
        'Malayalam': 'വാഹനം ഓടിക്കുമ്പോൾ നിങ്ങൾ സീറ്റ്ബെൽറ്റ് ധരിക്കണം (നിർബന്ധം).',
        'Hindi': 'ड्राइविंग करते समय आपको सीटबेल्ट अवश्य पहननी चाहिए।',
        'Telugu': 'డ్రైవింగ్ చేస్తున్నప్పుడు మీరు ఖచ్చితంగా సీట్‌బెల్ట్ ధరించాలి.',
        'English': 'You must wear a seatbelt while driving.',
      },
    ),
    ModalExerciseItem(
      modalType: 'MUST',
      usageCategory: 'Necessity',
      rule: '"must" indicates personal strong necessity',
      promptSentence: 'I ___ finish this important project today.',
      targetWord: 'must',
      acceptableWords: ['must finish', 'i must', 'must'],
      fullSentence: 'I must finish this important project today.',
      localizedHints: {
        'Tamil': 'அவசியமான தேவையை வெளிப்படுத்த "must": I must finish',
        'Malayalam': 'വ്യക്തിപരമായ അടിയന്തിര ആവശ്യത്തിന് "must": I must finish',
        'Hindi': 'अत्यावश्यक काम के लिए "must": I must finish',
        'Telugu': 'తప్పనిసరి అవసరానికి "must": I must finish',
        'English': 'strong personal necessity → "must": I must finish today.',
      },
      localizedTranslations: {
        'Tamil': 'இன்றே இந்த முக்கியமான திட்டத்தை நான் முடிக்க வேண்டும்.',
        'Malayalam': 'ഇന്ന് തന്നെ ഈ പ്രധാന പ്രോജക്റ്റ് ഞാൻ പൂർത്തിയാക്കണം.',
        'Hindi': 'मुझे आज यह महत्वपूर्ण प्रोजेक्ट अवश्य पूरा करना है।',
        'Telugu': 'నేను ఈ రోజు ఈ ముఖ్యమైన ప్రాజెక్ట్‌ను తప్పక పూర్తి చేయాలి.',
        'English': 'I must finish this important project today.',
      },
    ),
    ModalExerciseItem(
      modalType: 'MUST',
      usageCategory: 'Forbidden',
      rule: '"must not" (mustn\'t) means strictly forbidden / prohibited',
      promptSentence: 'You ___ smoke inside the hospital.',
      targetWord: 'must not',
      acceptableWords: ['must not', "mustn't", 'must not smoke'],
      fullSentence: 'You must not smoke inside the hospital.',
      localizedHints: {
        'Tamil': 'தடை செய்யப்பட்ட செயலுக்கு "must not" (புகைபிடிக்கக் கூடாது)',
        'Malayalam': 'കർശനമായി നിരോധിച്ചതിന് "must not": You must not smoke',
        'Hindi': 'सख्ती से मनाही के लिए "must not": You must not smoke',
        'Telugu': 'ఖచ్చితంగా నిషేధించబడిన వాటికి "must not": You must not smoke',
        'English': 'prohibition / forbidden → "must not" (mustn\'t)',
      },
      localizedTranslations: {
        'Tamil': 'மருத்துவமனைக்குள் நீங்கள் புகைபிடிக்கக் கூடாது (கடுமையாகத் தடைசெய்யப்பட்டது).',
        'Malayalam': 'ആശുപത്രിയിൽ പുകവലിക്കാൻ പാടില്ല (കർശന വിലക്ക്).',
        'Hindi': 'अस्पताल के अंदर धूम्रपान करना सख्त मना है।',
        'Telugu': 'ఆసుపత్రి లోపల ధూమపానం చేయకూడదు (ఖచ్చితంగా నిషిద్ధం).',
        'English': 'You must not smoke inside the hospital.',
      },
    ),
    ModalExerciseItem(
      modalType: 'MUST',
      usageCategory: 'Obligation',
      rule: 'Base verb after must (She must go, NOT she musts)',
      promptSentence: 'She ___ submit her documents before Friday.',
      targetWord: 'must',
      acceptableWords: ['must submit', 'she must', 'must'],
      fullSentence: 'She must submit her documents before Friday.',
      localizedHints: {
        'Tamil': '"must submit" — எப்போதுமே மூல வினைச்சொல் மட்டுமே',
        'Malayalam': '"must submit" — base verb മാത്രം',
        'Hindi': '"must submit" — केवल मूल क्रिया का प्रयोग करें',
        'Telugu': '"must submit" — బేస్ వెర్బ్ మాత్రమే',
        'English': 'base verb following must → "She must submit", not "musts"',
      },
      localizedTranslations: {
        'Tamil': 'அவள் வெள்ளிக்கிழமைக்கு முன் தனது ஆவணங்களை சமர்ப்பிக்க வேண்டும்.',
        'Malayalam': 'വെള്ളിയാഴ്ചയ്ക്ക് മുൻപ് അവൾ രേഖകൾ സമർപ്പിക്കണം.',
        'Hindi': 'उसे शुक्रवार से पहले अपने दस्तावेज़ जमा करने होंगे।',
        'Telugu': 'ఆమె శుక్రవారం లోపు తన పత్రాలను సమర్పించాలి.',
        'English': 'She must submit her documents before Friday.',
      },
    ),
    ModalExerciseItem(
      modalType: 'MUST',
      usageCategory: 'Urgency',
      rule: '"must" expresses urgent deadline or consequence',
      promptSentence: 'We ___ leave now or we will miss the flight.',
      targetWord: 'must',
      acceptableWords: ['must leave', 'we must', 'must'],
      fullSentence: 'We must leave now or we will miss the flight.',
      localizedHints: {
        'Tamil': 'அவசர நிலை: We must leave now',
        'Malayalam': 'അടിയന്തര സാഹചര്യം: We must leave now',
        'Hindi': 'आपातकाल/जल्दी: We must leave now',
        'Telugu': 'అత్యవసరం: We must leave now',
        'English': 'urgency → "must": We must leave now.',
      },
      localizedTranslations: {
        'Tamil': 'நாம் இப்போதே புறப்பட வேண்டும், இல்லையெனில் விமானத்தைத் தவறவிடுவோம்.',
        'Malayalam': 'നമ്മൾ ഇപ്പോൾ തന്നെ ഇറങ്ങണം, ഇല്ലെങ്കിൽ ഫ്ലൈറ്റ് മിസ്സാകും.',
        'Hindi': 'हमें अभी निकलना होगा वरना हमारी फ्लाइट छूट जाएगी।',
        'Telugu': 'మనం ఇప్పుడే బయలుదేరాలి, లేకపోతే విమానం మిస్ అవుతాము.',
        'English': 'We must leave now or we will miss the flight.',
      },
    ),

    // ─── SHOULD (Advice & Recommendation) ─────────────────────
    ModalExerciseItem(
      modalType: 'SHOULD',
      usageCategory: 'Advice',
      rule: '"should" is used to give friendly advice and opinions',
      promptSentence: 'You look tired. You ___ see a doctor.',
      targetWord: 'should',
      acceptableWords: ['should see', 'you should', 'should'],
      fullSentence: 'You look tired. You should see a doctor.',
      localizedHints: {
        'Tamil': 'நட்பு ரீதியான ஆலோசனைக்கு "should": You should see a doctor',
        'Malayalam': 'നല്ല ഉപദേശത്തിന് "should": You should see a doctor',
        'Hindi': 'सद्भावनापूर्ण सलाह के लिए "should": You should see a doctor',
        'Telugu': 'మంచి సలహాకు "should": You should see a doctor',
        'English': 'giving advice → "should": You should see a doctor.',
      },
      localizedTranslations: {
        'Tamil': 'நீங்கள் சோர்வாக இருக்கிறீர்கள். நீங்கள் மருத்துவரைப் பார்ப்பது நல்லது.',
        'Malayalam': 'നിങ്ങൾ ക്ഷീണിതനായി കാണപ്പെടുന്നു. നിങ്ങൾ ഒരു ഡോക്ടറെ കാണണം.',
        'Hindi': 'आप थके हुए लग रहे हैं। आपको डॉक्टर को दिखाना चाहिए।',
        'Telugu': 'మీరు అలసిపోయినట్లు కనిపిస్తున్నారు. మీరు డాక్టర్‌ను సంప్రదించాలి.',
        'English': 'You look tired. You should see a doctor.',
      },
    ),
    ModalExerciseItem(
      modalType: 'SHOULD',
      usageCategory: 'Recommendation',
      rule: '"should" recommends a wise course of action',
      promptSentence: 'The traffic is heavy, so we ___ leave now.',
      targetWord: 'should',
      acceptableWords: ['should leave', 'we should', 'should'],
      fullSentence: 'The traffic is heavy, so we should leave now.',
      localizedHints: {
        'Tamil': 'பரிந்துரைக்க "should": we should leave now (புறப்படுவது நல்லது)',
        'Malayalam': 'ശുപാർശയ്ക്ക് "should": we should leave now',
        'Hindi': 'सिफारिश के लिए "should": we should leave now',
        'Telugu': 'సిఫార్సుకు "should": we should leave now',
        'English': 'recommendation → "should": We should leave now.',
      },
      localizedTranslations: {
        'Tamil': 'போக்குவரத்து அதிகமாக உள்ளது, எனவே நாம் இப்போது புறப்படுவது நல்லது.',
        'Malayalam': 'ട്രാഫിക് കൂടുതലാണ്, അതിനാൽ നമ്മൾ ഇപ്പോൾ തന്നെ പുറപ്പെടുന്നത് നല്ലതാണ്.',
        'Hindi': 'ट्रैफ़िक बहुत है, इसलिए हमें अभी निकलना चाहिए।',
        'Telugu': 'ట్రాఫిక్ ఎక్కువగా ఉంది, కాబట్టి మనం ఇప్పుడే బయలుదేరడం మంచిది.',
        'English': 'The traffic is heavy, so we should leave now.',
      },
    ),
    ModalExerciseItem(
      modalType: 'SHOULD',
      usageCategory: 'Advice',
      rule: '"should not" (shouldn\'t) means it is not a good idea',
      promptSentence: 'You ___ eat too much sugar.',
      targetWord: 'should not',
      acceptableWords: ['should not', "shouldn't", 'should not eat', "shouldn't eat"],
      fullSentence: 'You should not eat too much sugar.',
      localizedHints: {
        'Tamil': 'தவிர்க்க வேண்டிய ஆலோசனை: You shouldn\'t eat too much sugar',
        'Malayalam': 'ഒഴിവാക്കേണ്ട കാര്യത്തിന് "should not": You shouldn\'t eat too much sugar',
        'Hindi': 'बुरी आदत से बचने की सलाह: You should not eat too much sugar',
        'Telugu': 'తప్పించవలసిన సలహా: You should not eat too much sugar',
        'English': 'negative advice → "should not" / "shouldn\'t"',
      },
      localizedTranslations: {
        'Tamil': 'நீங்கள் அதிக சர்க்கரை சாப்பிடக்கூடாது (ஆரோக்கியத்திற்கு நல்லதல்ல).',
        'Malayalam': 'നിങ്ങൾ അമിതമായി പഞ്ചസാര കഴിക്കാൻ പാടില്ല.',
        'Hindi': 'आपको अधिक चीनी नहीं खानी चाहिए।',
        'Telugu': 'మీరు ఎక్కువ చక్కెర తినకూడదు.',
        'English': 'You should not eat too much sugar.',
      },
    ),
    ModalExerciseItem(
      modalType: 'SHOULD',
      usageCategory: 'Wellness Advice',
      rule: 'Base verb after should (They should study, NOT studying)',
      promptSentence: 'They ___ study more before the big exam.',
      targetWord: 'should',
      acceptableWords: ['should study', 'they should', 'should'],
      fullSentence: 'They should study more before the big exam.',
      localizedHints: {
        'Tamil': '"should study" — எப்போதும் மூல வினைச்சொல் (study)',
        'Malayalam': '"should study" — base verb മാത്രം (studying അല്ല)',
        'Hindi': '"should study" — केवल बेस फॉर्म (study)',
        'Telugu': '"should study" — బేస్ వెర్బ్ (study)',
        'English': 'base verb after should → "should study", never "should studying"',
      },
      localizedTranslations: {
        'Tamil': 'பெரிய தேர்வுக்கு முன் அவர்கள் இன்னும் அதிகமாகப் படிக்க வேண்டும்.',
        'Malayalam': 'വലിയ പരീക്ഷയ്ക്ക് മുൻപ് അവർ കൂടുതൽ പഠിക്കണം.',
        'Hindi': 'उन्हें बड़ी परीक्षा से पहले और अधिक अध्ययन करना चाहिए।',
        'Telugu': 'పెద్ద పరీక్షకు ముందు వారు మరింత చదువుకోవాలి.',
        'English': 'They should study more before the big exam.',
      },
    ),
    ModalExerciseItem(
      modalType: 'SHOULD',
      usageCategory: 'Health Advice',
      rule: '"should" recommends daily healthy habits',
      promptSentence: 'You ___ drink at least eight glasses of water.',
      targetWord: 'should',
      acceptableWords: ['should drink', 'you should', 'should'],
      fullSentence: 'You should drink at least eight glasses of water.',
      localizedHints: {
        'Tamil': 'ஆரோக்கிய ஆலோசனை: You should drink water',
        'Malayalam': 'ആരോഗ്യ ഉപദേശം: You should drink water',
        'Hindi': 'स्वास्थ्य सलाह: You should drink water',
        'Telugu': 'ఆరోగ్య సలహా: You should drink water',
        'English': 'healthy habits advice → "should": You should drink water.',
      },
      localizedTranslations: {
        'Tamil': 'நீங்கள் தினமும் குறைந்தது எட்டு டம்ளர் தண்ணீர் குடிக்க வேண்டும்.',
        'Malayalam': 'നിങ്ങൾ ദിവസവും കുറഞ്ഞത് എട്ട് ഗ്ലാസ് വെള്ളമെങ്കിലും കുടിക്കണം.',
        'Hindi': 'आपको दिन में कम से कम आठ गिलास पानी पीना चाहिए।',
        'Telugu': 'మీరు రోజూ కనీసం ఎనిమిది గ్లాసుల నీళ్లు తాగాలి.',
        'English': 'You should drink at least eight glasses of water.',
      },
    ),

    // ─── COULD, MAY, MIGHT, WOULD (Other Modals) ──────────────
    ModalExerciseItem(
      modalType: 'OTHER',
      usageCategory: 'Polite Request',
      rule: '"could" makes a request softer and more polite than "can"',
      promptSentence: '___ you please pass me the salt?',
      targetWord: 'could',
      acceptableWords: ['could you', 'could pass', 'could'],
      fullSentence: 'Could you please pass me the salt?',
      localizedHints: {
        'Tamil': 'மரியாதையான வேண்டுகோள்: Could you please pass me the salt?',
        'Malayalam': 'വളരെ മാന്യമായ അഭ്യർത്ഥന: Could you please pass me the salt?',
        'Hindi': 'विनम्र अनुरोध के लिए "Could you...": Could you please pass me the salt?',
        'Telugu': 'వినయపూర్వక అభ్యర్థన: Could you please pass me the salt?',
        'English': 'polite request → "could": Could you please help me?',
      },
      localizedTranslations: {
        'Tamil': 'தயவுசெய்து எனக்கு அந்த உப்பைக் கொடுக்க முடியுமா?',
        'Malayalam': 'ദയവായി ആ ഉപ്പ് എനിക്ക് തരാമോ?',
        'Hindi': 'क्या आप कृपया मुझे नमक दे सकते हैं?',
        'Telugu': 'దయచేసి నాకు ఉప్పు అందించగలరా?',
        'English': 'Could you please pass me the salt?',
      },
    ),
    ModalExerciseItem(
      modalType: 'OTHER',
      usageCategory: 'Formal Permission',
      rule: '"may" is used for formal polite permission',
      promptSentence: '___ I leave the room early today, Sir?',
      targetWord: 'may',
      acceptableWords: ['may i', 'may leave', 'may'],
      fullSentence: 'May I leave the room early today, Sir?',
      localizedHints: {
        'Tamil': 'அதிகாரப்பூர்வ மரியாதைக்கு "May I...": May I leave?',
        'Malayalam': 'ഔദ്യോഗിക അനുവാദം: May I leave?',
        'Hindi': 'औपचारिक अनुमति के लिए "May I...": May I leave early?',
        'Telugu': 'అధికారిక అనుమతి: May I leave?',
        'English': 'formal permission → "may": May I leave early?',
      },
      localizedTranslations: {
        'Tamil': 'ஐயா, நான் இன்று சீக்கிரமாகச் செல்லலாமா?',
        'Malayalam': 'സർ, ഞാൻ ഇന്ന് നേരത്തെ പൊക്കോട്ടെ?',
        'Hindi': 'सर, क्या मैं आज जल्दी निकल सकता हूँ?',
        'Telugu': 'సార్, నేను ఈ రోజు త్వరగా వెళ్ళవచ్చా?',
        'English': 'May I leave the room early today, Sir?',
      },
    ),
    ModalExerciseItem(
      modalType: 'OTHER',
      usageCategory: 'Possibility',
      rule: '"might" indicates a small or uncertain possibility',
      promptSentence: 'Take an umbrella because it ___ rain later.',
      targetWord: 'might',
      acceptableWords: ['might rain', 'it might', 'might', 'may rain', 'may'],
      fullSentence: 'Take an umbrella because it might rain later.',
      localizedHints: {
        'Tamil': 'வாய்ப்பைக் குறிக்க "might / may": it might rain',
        'Malayalam': 'സാധ്യത സൂചിപ്പിക്കാൻ "might": it might rain',
        'Hindi': 'संभावना दर्शाने के लिए "might": it might rain',
        'Telugu': 'అవకాశాన్ని సూచించడానికి "might": it might rain',
        'English': 'possibility / prediction → "might": It might rain.',
      },
      localizedTranslations: {
        'Tamil': 'குடை எடுத்துச் செல்லுங்கள், பின்னர் மழை பெய்யக்கூடும்.',
        'Malayalam': 'കുട എടുക്കുക, കാരണം പിന്നീട് മഴ പെയ്യാൻ സാധ്യതയുണ്ട്.',
        'Hindi': 'छाता ले लें क्योंकि बाद में बारिश हो सकती है।',
        'Telugu': 'గొడుగు తీసుకెళ్ళండి, ఎందుకంటే తర్వాత వర్షం పడవచ్చు.',
        'English': 'Take an umbrella because it might rain later.',
      },
    ),
    ModalExerciseItem(
      modalType: 'OTHER',
      usageCategory: 'Polite Offer',
      rule: '"would" makes polite offers and invitations',
      promptSentence: '___ you like a warm cup of coffee?',
      targetWord: 'would',
      acceptableWords: ['would you', 'would like', 'would'],
      fullSentence: 'Would you like a warm cup of coffee?',
      localizedHints: {
        'Tamil': 'மரியாதையான உபசரிப்பு: Would you like...?',
        'Malayalam': 'മാന്യമായ സൽക്കാരം: Would you like...?',
        'Hindi': 'विनम्र प्रस्ताव: Would you like coffee?',
        'Telugu': 'మర్యాదపూర్వక ఆహ్వానం: Would you like coffee?',
        'English': 'polite offer → "would": Would you like coffee?',
      },
      localizedTranslations: {
        'Tamil': 'நீங்கள் ஒரு சூடான காபி குடிக்க விரும்புகிறீர்களா?',
        'Malayalam': 'നിങ്ങൾക്ക് ഒരു ചൂടുള്ള കാപ്പി വേണോ?',
        'Hindi': 'क्या आप एक कप गर्म कॉफी लेना चाहेंगे?',
        'Telugu': 'మీరు వేడి కాఫీ తీసుకోవాలనుకుంటున్నారా?',
        'English': 'Would you like a warm cup of coffee?',
      },
    ),
    ModalExerciseItem(
      modalType: 'OTHER',
      usageCategory: 'Hypothetical / Wish',
      rule: '"would" expresses wishes and hypothetical dreams',
      promptSentence: 'I ___ love to travel around the world one day.',
      targetWord: 'would',
      acceptableWords: ['would love', 'i would', 'would'],
      fullSentence: 'I would love to travel around the world one day.',
      localizedHints: {
        'Tamil': 'விருப்பத்தை வெளிப்படுத்த "would love to": I would love',
        'Malayalam': 'ആഗ്രഹം പ്രകടിപ്പിക്കാൻ "would love": I would love to travel',
        'Hindi': 'इच्छा व्यक्त करने के लिए "would love": I would love to travel',
        'Telugu': 'కోరికను తెలియజేయడానికి "would love": I would love to travel',
        'English': 'wishes / hypothetical → "would": I would love to travel.',
      },
      localizedTranslations: {
        'Tamil': 'ஒரு நாள் உலகம் முழுவதும் பயணம் செய்ய நான் மிகவும் விரும்புகிறேன்.',
        'Malayalam': 'ഒരു ദിവസം ലോകം മുഴുവൻ സഞ്ചരിക്കാൻ ഞാൻ ഏറെ ആഗ്രഹിക്കുന്നു.',
        'Hindi': 'मैं एक दिन दुनिया भर में यात्रा करना बहुत पसंद करूँगा।',
        'Telugu': 'నేను ఒక రోజు ప్రపంచమంతా పర్యటించాలని చాలా ఇష్టపడుతున్నాను.',
        'English': 'I would love to travel around the world one day.',
      },
    ),
  ];
}
