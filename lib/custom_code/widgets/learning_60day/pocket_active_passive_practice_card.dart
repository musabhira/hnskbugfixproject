import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Model for an Active & Passive Voice speaking exercise
class ActivePassiveExerciseItem {
  final String category; // 'ACTIVE_PASSIVE', 'TENSES_OF_BE', 'UNKNOWN_AGENT'
  final String voiceType; // 'Active Voice' or 'Passive Voice'
  final String rule;
  final String promptSentence;
  final String targetWord;
  final List<String> acceptableWords;
  final String fullSentence;
  final Map<String, String> localizedHints;
  final Map<String, String> localizedTranslations;

  const ActivePassiveExerciseItem({
    required this.category,
    required this.voiceType,
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

/// 🔄 Active & Passive Voice Practice Card — Subject vs. Receiver, be + V3, & Voice Flip
/// Features interactive 🎤 "Say It" speech recognition, instant evaluation,
/// written feedback, TTS audio, filter tabs, collapsible guide, and completion tracking.
class PocketActivePassivePracticeCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const PocketActivePassivePracticeCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '11',
  });

  @override
  State<PocketActivePassivePracticeCard> createState() =>
      _PocketActivePassivePracticeCardState();
}

class _PocketActivePassivePracticeCardState
    extends State<PocketActivePassivePracticeCard>
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
              content: Text(
                  '⚠️ Microphone access needed for speaking practice. Please ensure microphone permissions are enabled.'),
              backgroundColor: Color(0xFFEF4444),
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
    _listeningTimeoutTimer = Timer(const Duration(seconds: 12), () {
      if (mounted && _isListening) {
        _stopListening();
      }
    });

    try {
      if (_isSpeechInitialized) {
        await _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _recognizedWords = result.recognizedWords;
              });
              if (result.finalResult) {
                _evaluateSpokenAnswer(result.recognizedWords);
                _stopListening();
              }
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenFor: const Duration(seconds: 10),
            pauseFor: const Duration(seconds: 2),
            partialResults: true,
            localeId: 'en_US',
            listenMode: stt.ListenMode.confirmation,
          ),
        );
      }
    } catch (_) {
      if (mounted) _stopListening();
    }
  }

  Future<void> _stopListening() async {
    _listeningTimeoutTimer?.cancel();
    try {
      await _speech.stop();
    } catch (_) {}

    if (mounted) {
      setState(() => _isListening = false);
      if (_recognizedWords.isNotEmpty && !_isExerciseAnswered) {
        _evaluateSpokenAnswer(_recognizedWords);
      }
    }
  }

  bool _matchesPhrase(String text, String phrase) {
    final t = text.trim();
    final p = phrase.trim();
    if (t.isEmpty || p.isEmpty) return false;
    if (t == p) return true;
    final escaped = RegExp.escape(p);
    return RegExp('\\b$escaped\\b', caseSensitive: false).hasMatch(t);
  }

  void _evaluateSpokenAnswer(String spokenText) {
    if (spokenText.trim().isEmpty) return;

    final ex = _filteredExercises[_currentExerciseIndex];
    final cleanSpoken = spokenText
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final cleanTarget = ex.targetWord
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final cleanFull = ex.fullSentence
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    bool matched = false;

    if (_matchesPhrase(cleanSpoken, cleanFull)) {
      matched = true;
    } else if (_matchesPhrase(cleanSpoken, cleanTarget)) {
      matched = true;
    } else {
      for (final alt in ex.acceptableWords) {
        final cleanAlt = alt
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        if (cleanAlt.isNotEmpty && _matchesPhrase(cleanSpoken, cleanAlt)) {
          matched = true;
          break;
        }
      }
    }

    // Additional fuzzy matching for multi-word targets like "is washed", "will be washed"
    if (!matched) {
      final targetTokens = cleanTarget.split(' ').where((w) => w.isNotEmpty).toList();
      if (targetTokens.length > 1) {
        final matchesAll = targetTokens.every((token) => _matchesPhrase(cleanSpoken, token));
        if (matchesAll) matched = true;
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

  List<ActivePassiveExerciseItem> get _filteredExercises {
    switch (_activeFilter) {
      case 'ACTIVE_PASSIVE':
        return _kActivePassiveExercises
            .where((e) => e.category == 'ACTIVE_PASSIVE')
            .toList();
      case 'TENSES_OF_BE':
        return _kActivePassiveExercises
            .where((e) => e.category == 'TENSES_OF_BE')
            .toList();
      case 'UNKNOWN_AGENT':
        return _kActivePassiveExercises
            .where((e) => e.category == 'UNKNOWN_AGENT')
            .toList();
      default:
        return _kActivePassiveExercises;
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

  void _bypassForTesting(ActivePassiveExerciseItem ex) {
    setState(() {
      _recognizedWords = ex.fullSentence;
      _isExerciseAnswered = true;
      _isCorrect = true;
    });
    HapticFeedback.mediumImpact();
    _speakText(ex.fullSentence);
  }

  Color _badgeColor(String voiceType) {
    if (voiceType.contains('Active')) {
      return const Color(0xFF00FFCC); // Neon Cyan for Active
    }
    return const Color(0xFFF59E0B); // Amber / Orange for Passive
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises;
    if (_currentExerciseIndex >= exercises.length) {
      _currentExerciseIndex = 0;
    }
    final ex = exercises[_currentExerciseIndex];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17), // Minimal, plain dark game canvas
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFF4DD0E1).withValues(alpha: 0.4),
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF4DD0E1))
                .withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP GAME HUD BAR ─────────────────────────────────────────────
          Row(
            children: [
              // Step & Game Capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4DD0E1), Color(0xFF00ACC1)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.stepNumber.isNotEmpty
                      ? 'STEP ${widget.stepNumber} • VOICE'
                      : 'VOICE GAME',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Drill Counter Capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  'TASK ${_currentExerciseIndex + 1}/${exercises.length}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF80DEEA),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              // Quick Side Navigation in HUD
              InkWell(
                onTap: _goToPrevious,
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
                onTap: _goToNext,
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
              const SizedBox(width: 8),

              // Mark Step Checkbox
              InkWell(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  final nextVal = !widget.isCompleted;
                  widget.onCompleted(nextVal);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(nextVal
                          ? '🎉 Voice Practice Completed! (+20 PTS) ✓'
                          : 'Voice Practice marked as pending'),
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
                        widget.isCompleted ? 'DONE ✓' : 'VERIFY',
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

          const SizedBox(height: 12),

          // Title & Subtitle
          Text(
            'Active & Passive Voice 🔄',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _getLocalizedSubtitle(widget.selectedLanguage),
            style: GoogleFonts.inter(
              color: const Color(0xFF4DD0E1),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // ─── FILTER TABS (ALL, ACTIVE & PASSIVE, TENSES OF BE, UNKNOWN AGENT) ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'ALL (20)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('ACTIVE_PASSIVE', 'FLIP PAIRS (8)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('TENSES_OF_BE', 'TENSES: be + V3 (5)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('UNKNOWN_AGENT', 'AGENT RULES (7)'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ─── COLLAPSIBLE ACTIVE VS PASSIVE RULES GUIDE ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: InkWell(
              onTap: () {
                setState(() => _showRuleTable = !_showRuleTable);
                HapticFeedback.lightImpact();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF00FFCC).withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded,
                        size: 16, color: Color(0xFF00FFCC)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _showRuleTable
                            ? 'Hide Active & Passive Voice Guide'
                            : 'Open Active vs. Passive Voice Guide (Formulas & Mistakes)',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      _showRuleTable
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: const Color(0xFF00FFCC),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_showRuleTable) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _buildVoiceRuleGuide(),
            ),
          ],

          const SizedBox(height: 12),

          // ─── MAIN EXERCISE CARD ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181B26),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _badgeColor(ex.voiceType)
                                  .withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _badgeColor(ex.voiceType),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              ex.voiceType.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: _badgeColor(ex.voiceType),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ex.rule,
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_currentExerciseIndex + 1}/${exercises.length}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00FFCC),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Prompt Sentence with Blank
                  Text(
                    ex.promptSentence,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Hint in selected language
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                              const Color(0xFF00FFCC).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ex.getHint(widget.selectedLanguage),
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE2E8F0),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Translation in selected language
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '🌐 ${ex.getTranslation(widget.selectedLanguage)}',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.white60,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Interactive Voice Control Bar
                  Row(
                    children: [
                      // Speaker TTS Button
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _speakText(ex.fullSentence);
                        },
                        icon: const Icon(Icons.volume_up_rounded),
                        color: const Color(0xFF00FFCC),
                        iconSize: 24,
                        tooltip: 'Listen to native pronunciation',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // 🎤 Say It Aloud Main Button
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            final scale = _isListening
                                ? _pulseAnimation.value
                                : 1.0;
                            return Transform.scale(
                              scale: scale,
                              child: ElevatedButton.icon(
                                onPressed: _toggleSayIt,
                                icon: Icon(
                                  _isListening
                                      ? Icons.mic_rounded
                                      : Icons.mic_none_rounded,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                label: Text(
                                  _isListening
                                      ? 'LISTENING... TAP TO STOP'
                                      : '🎤 SAY IT ALOUD',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isListening
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF00FFCC),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: _isListening ? 6 : 2,
                                  shadowColor: _isListening
                                      ? const Color(0xFFEF4444)
                                          .withValues(alpha: 0.5)
                                      : const Color(0xFF00FFCC)
                                          .withValues(alpha: 0.3),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Quick pass test button
                      IconButton(
                        onPressed: () => _bypassForTesting(ex),
                        icon: const Icon(Icons.check_rounded),
                        color: const Color(0xFF10B981),
                        iconSize: 18,
                        tooltip: 'Pass this exercise for quick testing',
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),

                  // Real-time Recognized / Evaluated feedback
                  if (_recognizedWords.isNotEmpty ||
                      _isExerciseAnswered) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isExerciseAnswered
                            ? (_isCorrect
                                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                : const Color(0xFFEF4444).withValues(alpha: 0.12))
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isExerciseAnswered
                              ? (_isCorrect
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444))
                              : Colors.white24,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isExerciseAnswered
                                    ? (_isCorrect
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded)
                                    : Icons.record_voice_over_rounded,
                                size: 16,
                                color: _isExerciseAnswered
                                    ? (_isCorrect
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444))
                                    : const Color(0xFF00FFCC),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isExerciseAnswered
                                    ? (_isCorrect
                                        ? 'PERFECT PRONUNCIATION!'
                                        : 'ALMOST THERE — TRY AGAIN')
                                    : 'YOU SAID:',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: _isExerciseAnswered
                                      ? (_isCorrect
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444))
                                      : Colors.white70,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '"$_recognizedWords"',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Target Answer: "${ex.targetWord}"',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00FFCC),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Full Sentence: "${ex.fullSentence}"',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Prev / Next Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _goToPrevious,
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            size: 12, color: Colors.white70),
                        label: Text(
                          'PREV',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      Text(
                        'Item ${_currentExerciseIndex + 1} of ${exercises.length}',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white54,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _goToNext,
                        icon: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: Colors.black),
                        label: Text(
                          'NEXT',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00FFCC),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ─── BOTTOM FULL-WIDTH COMPLETION BUTTON ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  widget.onCompleted(!widget.isCompleted);
                },
                icon: Icon(
                  widget.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.task_alt_rounded,
                  color: widget.isCompleted ? Colors.white : Colors.black,
                  size: 18,
                ),
                label: Text(
                  widget.isCompleted
                      ? _getCompletedButtonLabel(widget.selectedLanguage)
                      : _getPendingButtonLabel(widget.selectedLanguage),
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: widget.isCompleted ? Colors.white : Colors.black,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isCompleted
                      ? const Color(0xFF10B981)
                      : const Color(0xFF00FFCC),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _activeFilter == filterKey;
    return InkWell(
      onTap: () => _setFilter(filterKey),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00FFCC)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00FFCC)
                : Colors.white24,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.black : Colors.white70,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceRuleGuide() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Text(
                'Active vs. Passive Voice Rules',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00FFCC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Active Voice: Subject performs the action (Direct & energetic).\n'
            '  Formula: Subject → Verb → Object\n'
            '  "The chef cooked the meal." / "The cat ate the fish."\n\n'
            '• Passive Voice: Subject receives the action (Receiver/Result first).\n'
            '  Formula: Object → be + Past Participle (V3) → [by Subject]\n'
            '  "The meal was cooked by the chef." / "The fish was eaten by the cat."',
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const Divider(color: Colors.white12, height: 16),
          Text(
            'Forming Passive with "be + Past Participle":',
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          _buildFormulaRow('Present Simple', 'is / am / are + V3', 'The car is washed every week.'),
          _buildFormulaRow('Past Simple', 'was / were + V3', 'The car was washed yesterday.'),
          _buildFormulaRow('Future Simple', 'will be + V3', 'The car will be washed tomorrow.'),
          _buildFormulaRow('Present Perfect', 'has been / have been + V3', 'The car has been washed.'),
          const Divider(color: Colors.white12, height: 16),
          Text(
            'When to Choose Passive in Speech:',
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1. Agent Unknown: "My phone was stolen." / "My bike was stolen."\n'
            '2. Agent Obvious: "He was arrested." (by the police)\n'
            '3. Emphasising Receiver: "The window was broken."\n'
            '4. Formal / Scientific: "The experiment was conducted in 2020."',
            style: GoogleFonts.outfit(
              fontSize: 10.5,
              color: Colors.white60,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Common Mistakes: Don\'t use the wrong participle (e.g. "was broke" ❌ → "was broken" ✅). '
                    'Don\'t confuse "be + adjective" ("the door is open") with true passive ("the door was opened").',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: const Color(0xFFFCA5A5),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaRow(String tense, String formula, String example) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              tense,
              style: GoogleFonts.outfit(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00FFCC),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$formula — "$example"',
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: Colors.white70,
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
        return 'செய்வினை & செயப்பாட்டு வினை பயிற்சி';
      case 'telugu':
        return 'కర్తరి & కర్మణి ప్రయోగాలు మాట్లాడే సాధన';
      case 'hindi':
        return 'Active & Passive Voice बोलने का अभ्यास';
      case 'kannada':
        return 'ಕರ್ತರಿ ಮತ್ತು ಕರ್ಮಣಿ ಪ್ರಯೋಗಗಳ ಅಭ್ಯಾಸ';
      case 'malayalam':
        return 'ആക്ടീവ് & പാസീവ് വോയ്സ് സംസാര പരിശീലനം';
      default:
        return 'Active & Passive Voice Speaking Drills';
    }
  }

  String _getCompletedButtonLabel(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'செயப்பாட்டு வினை தேர்ச்சி பெற்றது ✓';
      case 'telugu':
        return 'వాయిస్ సాధన పూర్తయింది ✓';
      case 'hindi':
        return 'Active & Passive अभ्यास पूर्ण ✓';
      case 'kannada':
        return 'ವಾಯ್ಸ್ ಅಭ್ಯಾಸ ಪೂರ್ಣಗೊಂಡಿದೆ ✓';
      case 'malayalam':
        return 'വോയ്സ് പരിശീലിച്ചു കഴിഞ്ഞു ✓';
      default:
        return 'ACTIVE & PASSIVE MASTERED ✓';
    }
  }

  String _getPendingButtonLabel(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'இந்த வாக்கியங்களை உரக்கப் பழகினேன் ✓';
      case 'telugu':
        return 'ఈ వాక్యాలను గట్టిగా సాధన చేశాను ✓';
      case 'hindi':
        return 'मैंने इन वाक्यों का अभ्यास किया ✓';
      case 'kannada':
        return 'ಈ ವಾಕ್ಯಗಳನ್ನು ಗಟ್ಟಿಯಾಗಿ ಅಭ್ಯಾಸ ಮಾಡಿದೆ ✓';
      case 'malayalam':
        return 'ഈ വാചകങ്ങൾ ഉറക്കെ പരിശീലിച്ചു ✓';
      default:
        return 'I PRACTICED THESE SENTENCES ALOUD ✓';
    }
  }

  static const List<ActivePassiveExerciseItem> _kActivePassiveExercises = [
    // ─── FLIP PAIRS (ACTIVE & PASSIVE: 1-8) ──────────────────────────
    ActivePassiveExerciseItem(
      category: 'ACTIVE_PASSIVE',
      voiceType: 'Active Voice',
      rule: 'Subject does the action (Past Simple Active)',
      promptSentence: 'The cat ___ (eat) the fish.',
      targetWord: 'ate',
      acceptableWords: ['ate the fish', 'the cat ate', 'ate'],
      fullSentence: 'The cat ate the fish.',
      localizedHints: {
        'Tamil': 'பூனை மீனை சாப்பிட்டது (செய்வினை: past simple active): ate',
        'Malayalam': 'പൂച്ച മീൻ തിന്നു (ആക്ടീവ് വോയ്സ്: past simple): ate',
        'Hindi': 'बिल्ली ने मछली खाई (active: past simple): ate',
        'Telugu': 'పిల్లి చేపను తిన్నది (active: past simple): ate',
        'English': 'past simple active: The cat ate the fish.',
      },
      localizedTranslations: {
        'Tamil': 'பூனை மீனை சாப்பிட்டது.',
        'Malayalam': 'പൂച്ച മീൻ തിന്നു.',
        'Hindi': 'बिल्ली ने मछली खाई।',
        'Telugu': 'పిల్లి చేపను తిన్నది.',
        'English': 'The cat ate the fish.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'ACTIVE_PASSIVE',
      voiceType: 'Passive Voice',
      rule: 'Receiver comes first (was + past participle)',
      promptSentence: 'The fish was ___ (eat) by the cat.',
      targetWord: 'eaten',
      acceptableWords: ['eaten by the cat', 'was eaten', 'eaten'],
      fullSentence: 'The fish was eaten by the cat.',
      localizedHints: {
        'Tamil': 'மீன் பூனையால் சாப்பிடப்பட்டது (செயப்பாட்டு வினை: was + V3): eaten',
        'Malayalam': 'മീൻ പൂച്ചയാൽ തിന്നപ്പെട്ടു (പാസീവ്: was + eaten): eaten',
        'Hindi': 'मछली बिल्ली द्वारा खाई गई (passive: was + eaten): eaten',
        'Telugu': 'చేప పిల్లిచేత తినబడింది (passive: was + eaten): eaten',
        'English': 'past simple passive: The fish was eaten by the cat.',
      },
      localizedTranslations: {
        'Tamil': 'மீன் பூனையால் சாப்பிடப்பட்டது.',
        'Malayalam': 'മീൻ പൂച്ചയാൽ തിന്നപ്പെട്ടു.',
        'Hindi': 'मछली बिल्ली द्वारा खाई गई।',
        'Telugu': 'చేప పిల్లిచేత తినబడింది.',
        'English': 'The fish was eaten by the cat.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'ACTIVE_PASSIVE',
      voiceType: 'Active Voice',
      rule: 'Subject does the action (Past Simple Active)',
      promptSentence: 'Shakespeare ___ (write) Hamlet.',
      targetWord: 'wrote',
      acceptableWords: ['wrote Hamlet', 'shakespeare wrote', 'wrote'],
      fullSentence: 'Shakespeare wrote Hamlet.',
      localizedHints: {
        'Tamil': 'ஷேக்ஸ்பியர் ஹேம்லெட் எழுதினார் (செய்வினை: past simple): wrote',
        'Malayalam': 'ഷേക്സ്പിയർ ഹാംലെറ്റ് എഴുതി (ആക്ടീവ് വോയ്സ്): wrote',
        'Hindi': 'शेक्सपियर ने हेमलेट लिखा (active: past simple): wrote',
        'Telugu': 'షేక్స్‌పియర్ హామ్లెట్ రాశాడు (active: past simple): wrote',
        'English': 'past simple active: Shakespeare wrote Hamlet.',
      },
      localizedTranslations: {
        'Tamil': 'ஷேக்ஸ்பியர் ஹேம்லெட் நாடகத்தை எழுதினார்.',
        'Malayalam': 'ഷേക്സ്പിയർ ഹാംലെറ്റ് എഴുതി.',
        'Hindi': 'शेक्सपियर ने हेमलेट लिखा।',
        'Telugu': 'షేక్స్‌పియర్ హామ్లెట్‌ను రచించాడు.',
        'English': 'Shakespeare wrote Hamlet.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'ACTIVE_PASSIVE',
      voiceType: 'Passive Voice',
      rule: 'Receiver comes first (was + past participle)',
      promptSentence: 'Hamlet was ___ (write) by Shakespeare.',
      targetWord: 'written',
      acceptableWords: ['written by Shakespeare', 'was written', 'written'],
      fullSentence: 'Hamlet was written by Shakespeare.',
      localizedHints: {
        'Tamil': 'ஹேம்லெட் ஷேக்ஸ்பியரால் எழுதப்பட்டது (was + written): written',
        'Malayalam': 'ഹാംലെറ്റ് ഷേക്സ്പിയറാൽ എഴുതപ്പെട്ടു (was + written): written',
        'Hindi': 'हेमलेट शेक्सपियर द्वारा लिखा गया था (was + written): written',
        'Telugu': 'హామ్లెట్ షేక్స్‌పియర్ ద్వారా రాయబడింది (was + written): written',
        'English': 'past simple passive: Hamlet was written by Shakespeare.',
      },
      localizedTranslations: {
        'Tamil': 'ஹேம்லெட் ஷேக்ஸ்பியரால் எழுதப்பட்டது.',
        'Malayalam': 'ഹാംലെറ്റ് ഷേക്സ്പിയറാൽ എഴുതപ്പെട്ടു.',
        'Hindi': 'हेमलेट शेक्सपियर द्वारा लिखा गया था।',
        'Telugu': 'హామ్లెట్ షేక్స్‌పియర్ చేత రాయబడింది.',
        'English': 'Hamlet was written by Shakespeare.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'ACTIVE_PASSIVE',
      voiceType: 'Active Voice',
      rule: 'Subject does the action (Past Simple Active)',
      promptSentence: 'The chef ___ (cook) the delicious meal.',
      targetWord: 'cooked',
      acceptableWords: ['cooked the delicious meal', 'the chef cooked', 'cooked'],
      fullSentence: 'The chef cooked the delicious meal.',
      localizedHints: {
        'Tamil': 'சமையல்காரர் உணவை சமைத்தார் (past simple active): cooked',
        'Malayalam': 'ഷെഫ് രുചികരമായ ഭക്ഷണം പാകം ചെയ്തു (ആക്ടീവ്): cooked',
        'Hindi': 'शेफ ने स्वादिष्ट भोजन पकाया (active): cooked',
        'Telugu': 'చెఫ్ రుచికరమైన భోజనాన్ని వండాడు (active): cooked',
        'English': 'past simple active: The chef cooked the delicious meal.',
      },
      localizedTranslations: {
        'Tamil': 'சமையல்காரர் சுவையான உணவை சமைத்தார்.',
        'Malayalam': 'ഷെഫ് രുചികരമായ ഭക്ഷണം പാകം ചെയ്തു.',
        'Hindi': 'शेफ ने स्वादिष्ट भोजन पकाया।',
        'Telugu': 'చెఫ్ రుచికరమైన ఆహారాన్ని వండాడు.',
        'English': 'The chef cooked the delicious meal.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'ACTIVE_PASSIVE',
      voiceType: 'Passive Voice',
      rule: 'Receiver comes first (was + past participle)',
      promptSentence: 'The meal was ___ (cook) by the chef.',
      targetWord: 'cooked',
      acceptableWords: ['cooked by the chef', 'was cooked', 'cooked'],
      fullSentence: 'The meal was cooked by the chef.',
      localizedHints: {
        'Tamil': 'உணவு சமையல்காரரால் சமைக்கப்பட்டது (was + cooked): cooked',
        'Malayalam': 'ഭക്ഷണം ഷെഫിനാൽ പാകം ചെയ്യപ്പെട്ടു (was + cooked): cooked',
        'Hindi': 'भोजन शेफ द्वारा पकाया गया था (was + cooked): cooked',
        'Telugu': 'ఆహారం చెఫ్ ద్వారా వండబడింది (was + cooked): cooked',
        'English': 'past simple passive: The meal was cooked by the chef.',
      },
      localizedTranslations: {
        'Tamil': 'உணவு சமையல்காரரால் சமைக்கப்பட்டது.',
        'Malayalam': 'ഭക്ഷണം ഷെഫിനാൽ പാകം ചെയ്യപ്പെട്ടു.',
        'Hindi': 'भोजन शेफ द्वारा पकाया गया था।',
        'Telugu': 'ఆహారం చెఫ్ ద్వారా వండబడింది.',
        'English': 'The meal was cooked by the chef.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'ACTIVE_PASSIVE',
      voiceType: 'Active Voice',
      rule: 'Subject does the action (Past Simple Active)',
      promptSentence: 'My brother ___ (fix) the broken bicycle.',
      targetWord: 'fixed',
      acceptableWords: ['fixed the broken bicycle', 'my brother fixed', 'fixed'],
      fullSentence: 'My brother fixed the broken bicycle.',
      localizedHints: {
        'Tamil': 'என் சகோதரன் மிதிவண்டியை சரிசெய்தான் (active): fixed',
        'Malayalam': 'എന്റെ സഹോദരൻ സൈക്കിൾ നന്നാക്കി (ആക്ടീവ്): fixed',
        'Hindi': 'मेरे भाई ने साइकिल ठीक की (active): fixed',
        'Telugu': 'మా తమ్ముడు సైకిల్‌ను బాగు చేశాడు (active): fixed',
        'English': 'past simple active: My brother fixed the broken bicycle.',
      },
      localizedTranslations: {
        'Tamil': 'என் சகோதரன் உடைந்த மிதிவண்டியை சரிசெய்தான்.',
        'Malayalam': 'എന്റെ സഹോദരൻ കേടായ സൈക്കിൾ നന്നാക്കി.',
        'Hindi': 'मेरे भाई ने टूटी हुई साइकिल की मरम्मत की।',
        'Telugu': 'మా సోదరుడు పాడైన సైకిల్‌ను బాగుచేశాడు.',
        'English': 'My brother fixed the broken bicycle.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'ACTIVE_PASSIVE',
      voiceType: 'Passive Voice',
      rule: 'Receiver comes first (was + past participle)',
      promptSentence: 'The bicycle was ___ (fix) by my brother.',
      targetWord: 'fixed',
      acceptableWords: ['fixed by my brother', 'was fixed', 'fixed'],
      fullSentence: 'The bicycle was fixed by my brother.',
      localizedHints: {
        'Tamil': 'மிதிவண்டி என் சகோதரனால் சரிசெய்யப்பட்டது (was + fixed): fixed',
        'Malayalam': 'സൈക്കിൾ എന്റെ സഹോദരനാൽ നന്നാക്കപ്പെട്ടു (was + fixed): fixed',
        'Hindi': 'साइकिल मेरे भाई द्वारा ठीक की गई (was + fixed): fixed',
        'Telugu': 'సైకిల్ మా సోదరుడి ద్వారా బాగు చేయబడింది (was + fixed): fixed',
        'English': 'past simple passive: The bicycle was fixed by my brother.',
      },
      localizedTranslations: {
        'Tamil': 'மிதிவண்டி என் சகோதரனால் சரிசெய்யப்பட்டது.',
        'Malayalam': 'സൈക്കിൾ എന്റെ സഹോദരനാൽ നന്നാക്കപ്പെട്ടു.',
        'Hindi': 'साइकिल मेरे भाई द्वारा ठीक की गई थी।',
        'Telugu': 'సైకిల్ మా సోదరుడి ద్వారా బాగు చేయబడింది.',
        'English': 'The bicycle was fixed by my brother.',
      },
    ),

    // ─── TENSES OF BE (be + V3: 9-13) ──────────────────────────
    ActivePassiveExerciseItem(
      category: 'TENSES_OF_BE',
      voiceType: 'Passive Voice',
      rule: 'Present Simple Passive: is/are + past participle',
      promptSentence: 'The car ___ (wash) every single week.',
      targetWord: 'is washed',
      acceptableWords: ['is washed', 'washed'],
      fullSentence: 'The car is washed every single week.',
      localizedHints: {
        'Tamil': 'ஒவ்வொரு வாரமும் கார் கழுவப்படுகிறது (present simple passive: is + washed): is washed',
        'Malayalam': 'എല്ലാ ആഴ്ചയും കാർ കഴുകപ്പെടുന്നു (present simple passive): is washed',
        'Hindi': 'हर हफ्ते कार धोई जाती है (present simple passive: is washed): is washed',
        'Telugu': 'ప్రతి వారం కారు కడగబడుతుంది (is washed): is washed',
        'English': 'present simple passive (regular habit) → "is washed": The car is washed every week.',
      },
      localizedTranslations: {
        'Tamil': 'கார் ஒவ்வொரு வாரமும் கழுவப்படுகிறது.',
        'Malayalam': 'കാർ എല്ലാ ആഴ്ചയും കഴുകപ്പെടുന്നു.',
        'Hindi': 'कार हर हफ्ते धोई जाती है।',
        'Telugu': 'కారు ప్రతి వారం కడగబడుతుంది.',
        'English': 'The car is washed every single week.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'TENSES_OF_BE',
      voiceType: 'Passive Voice',
      rule: 'Past Simple Passive: was/were + past participle',
      promptSentence: 'The car ___ (wash) yesterday afternoon.',
      targetWord: 'was washed',
      acceptableWords: ['was washed', 'washed'],
      fullSentence: 'The car was washed yesterday afternoon.',
      localizedHints: {
        'Tamil': 'நேற்று கார் கழுவப்பட்டது (past simple passive: was + washed): was washed',
        'Malayalam': 'ഇന്നലെ കാർ കഴുകപ്പെട്ടു (past simple passive): was washed',
        'Hindi': 'कल कार धोई गई थी (past simple passive: was washed): was washed',
        'Telugu': 'నిన్న కారు కడగబడింది (was washed): was washed',
        'English': 'past simple passive → "was washed": The car was washed yesterday.',
      },
      localizedTranslations: {
        'Tamil': 'நேற்று பிற்பகல் கார் கழுவப்பட்டது.',
        'Malayalam': 'ഇന്നലെ ഉച്ചതിരിഞ്ഞ് കാർ കഴുകപ്പെട്ടു.',
        'Hindi': 'कल दोपहर को कार धोई गई थी।',
        'Telugu': 'నిన్న మధ్యాహ్నం కారు కడగబడింది.',
        'English': 'The car was washed yesterday afternoon.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'TENSES_OF_BE',
      voiceType: 'Passive Voice',
      rule: 'Future Simple Passive: will be + past participle',
      promptSentence: 'The car ___ (wash) tomorrow morning.',
      targetWord: 'will be washed',
      acceptableWords: ['will be washed', 'be washed'],
      fullSentence: 'The car will be washed tomorrow morning.',
      localizedHints: {
        'Tamil': 'நாளை கார் கழுவப்படும் (future simple passive: will be + washed): will be washed',
        'Malayalam': 'നാളെ കാർ കഴുകപ്പെടും (future simple passive): will be washed',
        'Hindi': 'कल सुबह कार धोई जाएगी (future simple passive: will be washed): will be washed',
        'Telugu': 'రేపు ఉదయం కారు కడగబడుతుంది (will be washed): will be washed',
        'English': 'future simple passive → "will be washed": The car will be washed tomorrow.',
      },
      localizedTranslations: {
        'Tamil': 'நாளை காலை கார் கழுவப்படும்.',
        'Malayalam': 'നാളെ രാവിലെ കാർ കഴുകപ്പെടും.',
        'Hindi': 'कल सुबह कार धोई जाएगी।',
        'Telugu': 'రేపు ఉదయం కారు కడగబడుతుంది.',
        'English': 'The car will be washed tomorrow morning.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'TENSES_OF_BE',
      voiceType: 'Passive Voice',
      rule: 'Present Perfect Passive: has/have been + past participle',
      promptSentence: 'The car has already ___ (wash) clean.',
      targetWord: 'been washed',
      acceptableWords: ['been washed', 'washed'],
      fullSentence: 'The car has already been washed clean.',
      localizedHints: {
        'Tamil': 'கார் ஏற்கனவே கழுவி முடிக்கப்பட்டுள்ளது (has + been washed): been washed',
        'Malayalam': 'കാർ ഇതിനകം കഴുകിക്കഴിഞ്ഞു (has + been washed): been washed',
        'Hindi': 'कार पहले ही धोई जा चुकी है (has been washed): been washed',
        'Telugu': 'కారు ఇప్పటికే కడగబడింది (has been washed): been washed',
        'English': 'present perfect passive → "been washed": The car has been washed.',
      },
      localizedTranslations: {
        'Tamil': 'கார் ஏற்கனவே சுத்தமாகக் கழுவப்பட்டுவிட்டது.',
        'Malayalam': 'കാർ ഇതിനകം വൃത്തിയായി കഴുകിക്കഴിഞ്ഞു.',
        'Hindi': 'कार पहले ही साफ धोई जा चुकी है।',
        'Telugu': 'కారు ఇప్పటికే శుభ్రంగా కడగబడింది.',
        'English': 'The car has already been washed clean.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'TENSES_OF_BE',
      voiceType: 'Passive Voice',
      rule: 'Negative Past Passive (Complaints & Reviews)',
      promptSentence: 'The hotel room was not ___ (clean) properly.',
      targetWord: 'cleaned',
      acceptableWords: ['cleaned properly', 'was not cleaned', 'cleaned'],
      fullSentence: 'The hotel room was not cleaned properly.',
      localizedHints: {
        'Tamil': 'ஹோட்டல் அறை சரியாக சுத்தம் செய்யப்படவில்லை (was not + cleaned): cleaned',
        'Malayalam': 'മുറി ശരിയായി വൃത്തിയാക്കപ്പെട്ടില്ല (വാടക മുറികളിലെ പരാതി): cleaned',
        'Hindi': 'कमरा ठीक से साफ नहीं किया गया था (शिकायत): cleaned',
        'Telugu': 'గది సరిగ్గా శుభ్రం చేయబడలేదు (ఫిర్యాదు): cleaned',
        'English': 'negative past passive (for complaints): The room was not cleaned.',
      },
      localizedTranslations: {
        'Tamil': 'ஹோட்டல் அறை சரியாக சுத்தம் செய்யப்படவில்லை.',
        'Malayalam': 'ഹോട്ടൽ മുറി ശരിയായി വൃത്തിയാക്കപ്പെട്ടില്ല.',
        'Hindi': 'होटल का कमरा ठीक से साफ नहीं किया गया था।',
        'Telugu': 'హోటల్ గది సరిగ్గా శుభ్రం చేయబడలేదు.',
        'English': 'The hotel room was not cleaned properly.',
      },
    ),

    // ─── UNKNOWN / OBVIOUS AGENT & EMPHASIS (14-20) ──────────────────────────
    ActivePassiveExerciseItem(
      category: 'UNKNOWN_AGENT',
      voiceType: 'Passive Voice',
      rule: 'Agent is unknown — doer doesn\'t matter',
      promptSentence: 'My mobile phone was ___ (steal) on the bus.',
      targetWord: 'stolen',
      acceptableWords: ['stolen on the bus', 'was stolen', 'stolen'],
      fullSentence: 'My mobile phone was stolen on the bus.',
      localizedHints: {
        'Tamil': 'திருடியவர் யார் என்று தெரியாது (unknown agent: was stolen): stolen',
        'Malayalam': 'ആരാണ് മോഷ്ടിച്ചതെന്ന് അറിയില്ല (unknown agent: was stolen): stolen',
        'Hindi': 'चोर अज्ञात है (unknown agent: was stolen): stolen',
        'Telugu': 'దొంగ ఎవరో తెలియదు (unknown agent: was stolen): stolen',
        'English': 'unknown agent (doer unknown) → "stolen": My phone was stolen.',
      },
      localizedTranslations: {
        'Tamil': 'பேருந்தில் என் கைப்பேசி திருடப்பட்டது.',
        'Malayalam': 'ബസ്സിൽ വെച്ച് എന്റെ മൊബൈൽ ഫോൺ മോഷ്ടിക്കപ്പെട്ടു.',
        'Hindi': 'बस में मेरा मोबाइल फोन चोरी हो गया था।',
        'Telugu': 'బస్సులో నా మొబైల్ ఫోన్ దొంగిలించబడింది.',
        'English': 'My mobile phone was stolen on the bus.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'UNKNOWN_AGENT',
      voiceType: 'Passive Voice',
      rule: 'Agent is unknown — doer doesn\'t matter',
      promptSentence: 'My bicycle was ___ (steal) last night.',
      targetWord: 'stolen',
      acceptableWords: ['stolen last night', 'was stolen', 'stolen'],
      fullSentence: 'My bicycle was stolen last night.',
      localizedHints: {
        'Tamil': 'மிதிவண்டி திருடப்பட்டது (திருடியவர் யார் என்று தெரியாது): stolen',
        'Malayalam': 'കഴിഞ്ഞ രാത്രി എന്റെ സൈക്കിൾ മോഷ്ടിക്കപ്പെട്ടു: stolen',
        'Hindi': 'मेरी साइकिल कल रात चोरी हो गई (was stolen): stolen',
        'Telugu': 'నిన్న రాత్రి నా సైకిల్ దొంగిలించబడింది: stolen',
        'English': 'unknown agent → "stolen": My bike was stolen.',
      },
      localizedTranslations: {
        'Tamil': 'நேற்று இரவு என் மிதிவண்டி திருடப்பட்டது.',
        'Malayalam': 'കഴിഞ്ഞ രാത്രി എന്റെ സൈക്കിൾ മോഷ്ടിക്കപ്പെട്ടു.',
        'Hindi': 'कल रात मेरी साइकिल चोरी हो गई।',
        'Telugu': 'నిన్న రాత్రి నా సైకిల్ దొంగిలించబడింది.',
        'English': 'My bicycle was stolen last night.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'UNKNOWN_AGENT',
      voiceType: 'Passive Voice',
      rule: 'Agent is obvious — by police is understood',
      promptSentence: 'The thief was ___ (arrest) late last night.',
      targetWord: 'arrested',
      acceptableWords: ['arrested late last night', 'was arrested', 'arrested'],
      fullSentence: 'The thief was arrested late last night.',
      localizedHints: {
        'Tamil': 'காவல்துறையால் கைது செய்யப்பட்டார் என்பது வெளிப்படையானது: arrested',
        'Malayalam': 'പോലീസ് അറസ്റ്റ് ചെയ്തു എന്നത് വ്യക്തമാണ് (obvious agent): arrested',
        'Hindi': 'पुलिस द्वारा गिरफ्तार किया गया (obvious agent): arrested',
        'Telugu': 'పోలీసులు అరెస్టు చేశారని స్పష్టంగా తెలుస్తుంది: arrested',
        'English': 'obvious agent (by police is obvious) → "arrested": He was arrested.',
      },
      localizedTranslations: {
        'Tamil': 'திருடன் நேற்று நள்ளிரவில் கைது செய்யப்பட்டான்.',
        'Malayalam': 'കള്ളൻ ഇന്നലെ രാത്രി വൈകി അറസ്റ്റ് ചെയ്യപ്പെട്ടു.',
        'Hindi': 'चोर को कल देर रात गिरफ्तार किया गया था।',
        'Telugu': 'దొంగ నిన్న అర్ధరాత్రి అరెస్టు చేయబడ్డాడు.',
        'English': 'The thief was arrested late last night.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'UNKNOWN_AGENT',
      voiceType: 'Passive Voice',
      rule: 'Scientific / Formal text — focus on experiment',
      promptSentence: 'The scientific experiment was ___ (conduct) in 2020.',
      targetWord: 'conducted',
      acceptableWords: ['conducted in 2020', 'was conducted', 'conducted'],
      fullSentence: 'The scientific experiment was conducted in 2020.',
      localizedHints: {
        'Tamil': 'அறிவியல் ஆய்வு 2020 இல் நடத்தப்பட்டது (formal/scientific passive): conducted',
        'Malayalam': 'ശാസ്ത്ര പരീക്ഷണം 2020-ൽ നടത്തപ്പെട്ടു (formal passive): conducted',
        'Hindi': 'वैज्ञानिक प्रयोग 2020 में आयोजित किया गया था (formal passive): conducted',
        'Telugu': 'శాస్త్రీయ ప్రయోగం 2020 లో నిర్వహించబడింది: conducted',
        'English': 'scientific/formal writing → "conducted": The experiment was conducted in 2020.',
      },
      localizedTranslations: {
        'Tamil': 'அறிவியல் ஆய்வு 2020 ஆம் ஆண்டில் நடத்தப்பட்டது.',
        'Malayalam': 'ശാസ്ത്ര പരീക്ഷണം 2020-ൽ നടത്തപ്പെട്ടു.',
        'Hindi': 'वैज्ञानिक प्रयोग 2020 में आयोजित किया गया था।',
        'Telugu': 'శాస్త్రీయ ప్రయోగం 2020 లో నిర్వహించబడింది.',
        'English': 'The scientific experiment was conducted in 2020.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'UNKNOWN_AGENT',
      voiceType: 'Passive Voice',
      rule: 'Emphasising the receiver (the window, not who broke it)',
      promptSentence: 'The glass window was ___ (break) yesterday.',
      targetWord: 'broken',
      acceptableWords: ['broken yesterday', 'was broken', 'broken'],
      fullSentence: 'The glass window was broken yesterday.',
      localizedHints: {
        'Tamil': 'ஜன்னல் உடைந்தது (யார் உடைத்தார் என்பதைவிட ஜன்னலே முக்கியம்): broken',
        'Malayalam': 'ജനൽ തകർക്കപ്പെട്ടു ("was broke" തെറ്റാണ്, "was broken" ശരി): broken',
        'Hindi': 'खिड़की टूट गई थी (participle: broken, not broke): broken',
        'Telugu': 'కిటికీ విరిగిపోయింది (was broken): broken',
        'English': 'emphasising the receiver → "broken": The window was broken.',
      },
      localizedTranslations: {
        'Tamil': 'நேற்று கண்ணாடி ஜன்னல் உடைக்கப்பட்டது.',
        'Malayalam': 'ഇന്നലെ ഗ്ലാസ് ജനൽ തകർക്കപ്പെട്ടു.',
        'Hindi': 'कल कांच की खिड़की टूट गई थी।',
        'Telugu': 'నిన్న గాజు కిటికీ విరిగిపోయింది.',
        'English': 'The glass window was broken yesterday.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'UNKNOWN_AGENT',
      voiceType: 'Passive Voice',
      rule: 'Past Simple Passive with omitted agent',
      promptSentence: 'The parcel was ___ (deliver) to my doorstep.',
      targetWord: 'delivered',
      acceptableWords: ['delivered to my doorstep', 'was delivered', 'delivered'],
      fullSentence: 'The parcel was delivered to my doorstep.',
      localizedHints: {
        'Tamil': 'பார்சல் வீட்டு வாசலில் டெலிவரி செய்யப்பட்டது: delivered',
        'Malayalam': 'പാഴ്സൽ വാതിൽപ്പടിയിൽ എത്തിക്കപ്പെട്ടു: delivered',
        'Hindi': 'पार्सल दरवाजे पर पहुंचाया गया था: delivered',
        'Telugu': 'పార్శిల్ నా ఇంటి వద్దకు డెలివరీ చేయబడింది: delivered',
        'English': 'past passive: The parcel was delivered to my doorstep.',
      },
      localizedTranslations: {
        'Tamil': 'பார்சல் என் வீட்டு வாசலில் டெலிவரி செய்யப்பட்டது.',
        'Malayalam': 'പാഴ്സൽ എന്റെ വീട്ടുപടിക്കൽ എത്തിക്കപ്പെട്ടു.',
        'Hindi': 'पार्सल मेरे दरवाजे पर पहुंचाया गया था।',
        'Telugu': 'పార్శిల్ నా ఇంటి గుమ్మం వద్దకు చేర్చబడింది.',
        'English': 'The parcel was delivered to my doorstep.',
      },
    ),
    ActivePassiveExerciseItem(
      category: 'UNKNOWN_AGENT',
      voiceType: 'Passive Voice',
      rule: 'Present Simple Passive general truth',
      promptSentence: 'English is ___ (speak) all over the world.',
      targetWord: 'spoken',
      acceptableWords: ['spoken all over the world', 'is spoken', 'spoken'],
      fullSentence: 'English is spoken all over the world.',
      localizedHints: {
        'Tamil': 'ஆங்கிலம் உலகம் முழுவதும் பேசப்படுகிறது (present passive: is + spoken): spoken',
        'Malayalam': 'ഇംഗ്ലീഷ് ലോകമെമ്പാടും സംസാരിക്കപ്പെടുന്നു (is + spoken): spoken',
        'Hindi': 'अंग्रेजी दुनिया भर में बोली जाती है (is spoken): spoken',
        'Telugu': 'ప్రపంచవ్యాప్తంగా ఇంగ్లీష్ మాట్లాడబడుతుంది (is spoken): spoken',
        'English': 'present simple passive truth → "spoken": English is spoken all over the world.',
      },
      localizedTranslations: {
        'Tamil': 'ஆங்கிலம் உலகம் முழுவதும் பேசப்படுகிறது.',
        'Malayalam': 'ഇംഗ്ലീഷ് ലോകമെമ്പാടും സംസാരിക്കപ്പെടുന്നു.',
        'Hindi': 'दुनिया भर में अंग्रेजी बोली जाती है।',
        'Telugu': 'ప్రపంచవ్యాప్తంగా ఇంగ్లీష్ మాట్లాడబడుతుంది.',
        'English': 'English is spoken all over the world.',
      },
    ),
  ];
}
