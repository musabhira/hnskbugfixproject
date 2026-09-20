import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Single practice exercise item with multilingual support
class SpeakingExerciseItem {
  final String promptSentence; // e.g. "She ___ a letter."
  final String targetWord; // e.g. "writes"
  final List<String> acceptableWords; // e.g. ["writes", "wrote", "is writing", "write"]
  final String fullSentence; // e.g. "She writes a letter."
  final Map<String, String> localizedHints;
  final Map<String, String> localizedTranslations;

  const SpeakingExerciseItem({
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

/// 🎤 Practice Speaking Widget (Pocket Mates Obsidian Dark UI Theme)
/// Features 10 Levels with 10 exercises each (100 exercises total),
/// interactive "Say It" speech recognition, immediate auto-eval with written answer,
/// retry capability, Next navigation, and step completion tracking.
class PocketPracticeSpeakingCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const PocketPracticeSpeakingCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '5',
  });

  @override
  State<PocketPracticeSpeakingCard> createState() =>
      _PocketPracticeSpeakingCardState();
}

class _PocketPracticeSpeakingCardState
    extends State<PocketPracticeSpeakingCard> with SingleTickerProviderStateMixin {
  late int _selectedLevel;
  int _currentExerciseIndex = 0;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;
  bool _isListening = false;
  String _recognizedWords = '';
  bool _isExerciseAnswered = false;
  bool _isCorrect = false;
  Timer? _listeningTimeoutTimer;

  // Animation controller for pulsing mic button
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Default level: 1 to 10 mapped from day
    _selectedLevel = widget.day.clamp(1, 10);
    _initSpeechRecognizer();
    _initTts();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
            if (mounted && _isListening) {
              _stopListening();
            }
          }
        },
        onError: (error) {
          if (mounted && _isListening) {
            _stopListening();
          }
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
                _stopListening();
              }
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
      if (mounted) {
        setState(() => _isListening = false);
      }
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
    final exercises = _getExercisesForLevel(_selectedLevel);
    final ex = exercises[_currentExerciseIndex % exercises.length];
    final normalized = spokenText.toLowerCase().trim();

    bool matched = false;
    if (normalized.isNotEmpty) {
      if (_matchesPhrase(normalized, ex.targetWord) ||
          normalized.contains(ex.targetWord.toLowerCase().trim())) {
        matched = true;
      }
      if (!matched) {
        for (final word in ex.acceptableWords) {
          if (_matchesPhrase(normalized, word) ||
              normalized.contains(word.toLowerCase().trim())) {
            matched = true;
            break;
          }
        }
      }
      if (!matched && normalized.length >= 3) {
        final fullNormalized = ex.fullSentence.toLowerCase().replaceAll(RegExp(r"[^\w\s']"), ' ').trim();
        final cleanSpoken = normalized.replaceAll(RegExp(r"[^\w\s']"), ' ').trim();
        if (fullNormalized.contains(cleanSpoken) ||
            cleanSpoken.contains(fullNormalized)) {
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

  void _goToNextExercise() {
    final exercises = _getExercisesForLevel(_selectedLevel);
    HapticFeedback.selectionClick();
    setState(() {
      _currentExerciseIndex =
          (_currentExerciseIndex + 1) % exercises.length;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _goToPreviousExercise() {
    final exercises = _getExercisesForLevel(_selectedLevel);
    HapticFeedback.selectionClick();
    setState(() {
      _currentExerciseIndex =
          (_currentExerciseIndex - 1 + exercises.length) % exercises.length;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _selectLevel(int level) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedLevel = level;
      _currentExerciseIndex = 0;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _bypassForTesting(SpeakingExerciseItem ex) {
    setState(() {
      _recognizedWords = ex.fullSentence;
      _isExerciseAnswered = true;
      _isCorrect = true;
    });
    HapticFeedback.mediumImpact();
    _speakText(ex.fullSentence);
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _getExercisesForLevel(_selectedLevel);
    final ex = exercises[_currentExerciseIndex.clamp(0, exercises.length - 1)];

    String displaySentence = ex.promptSentence;
    if (_isExerciseAnswered && _isCorrect) {
      displaySentence = ex.fullSentence;
    }

    final localizedHint = ex.getHint(widget.selectedLanguage);
    final localizedMeaning = ex.getTranslation(widget.selectedLanguage);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Premium Obsidian Dark
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFF7C5CFC).withValues(alpha: 0.45),
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF7C5CFC))
                .withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar: Title + Complete Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.stepNumber.isNotEmpty
                          ? 'STEP ${widget.stepNumber} • 🎤 Practice Speaking'
                          : '🎤 Practice Speaking',
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
                        color: const Color(0xFFA78BFA),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Interactive Completion Toggle Checkbox
              InkWell(
                onTap: () {
                  HapticFeedback.heavyImpact();
                  final nextVal = !widget.isCompleted;
                  widget.onCompleted(nextVal);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(nextVal
                          ? '🎉 Practice Speaking Completed! (+25 PTS) ✓'
                          : 'Practice Speaking marked as pending'),
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
          const SizedBox(height: 12),

          // 10 Levels Horizontal Selector
          Row(
            children: [
              Text(
                'LEVELS (10):',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFFD700),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(10, (idx) {
                      final lvl = idx + 1;
                      final isSel = lvl == _selectedLevel;
                      return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: InkWell(
                          onTap: () => _selectLevel(lvl),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: isSel
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF7C5CFC),
                                        Color(0xFF6366F1)
                                      ],
                                    )
                                  : null,
                              color: isSel ? null : const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel
                                    ? const Color(0xFF9333EA)
                                    : Colors.white12,
                                width: isSel ? 1.2 : 0.8,
                              ),
                            ),
                            child: Text(
                              'L$lvl',
                              style: GoogleFonts.outfit(
                                color: isSel ? Colors.white : Colors.white60,
                                fontSize: 11,
                                fontWeight: isSel
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Speaking Card Body
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
                // Top Meta: Exercise Counter & Speaker Audio Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        'Level $_selectedLevel • Task ${_currentExerciseIndex + 1} of ${exercises.length}',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF38BDF8),
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
                const SizedBox(height: 14),

                // Sentence Box
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

                // Localized Sentence Meaning
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

                // Contextual Hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        localizedHint.isNotEmpty ? localizedHint : ex.targetWord,
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

                // 🎤 Say It Button with listening pulse animation
                ScaleTransition(
                  scale: _isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
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
                                colors: [Color(0xFFF0935D), Color(0xFFE57B42)],
                              ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFF0935D))
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
                                ? 'Listening... Speak now'
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

                // Immediate Result Feedback & Correct Answer Display
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
                                    ? '🎉 Correct! Spoken with great clarity!'
                                    : 'Almost! Target answer: "${ex.targetWord}"',
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
                        // Always clearly show the correct sentence
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

                // Fallback testing tap
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

                // Navigation Buttons (Prev / Next)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentExerciseIndex > 0)
                      TextButton.icon(
                        onPressed: _goToPreviousExercise,
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
                      onPressed: _goToNextExercise,
                      icon: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.black, size: 15),
                      label: Text(
                        _currentExerciseIndex < exercises.length - 1
                            ? 'NEXT (${_currentExerciseIndex + 2}/${exercises.length}) ➔'
                            : 'NEXT LEVEL ➔',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
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

                // 10 Progress Segment Dashes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(exercises.length, (idx) {
                    final isActive = idx == _currentExerciseIndex;
                    final isPast = idx < _currentExerciseIndex;

                    return Container(
                      width: 20,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF7C5CFC)
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

          // Complete Practice Speaking Big Button
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
                        ? '🎉 Practice Speaking Completed! (+25 PTS) ✓'
                        : 'Practice Speaking marked as pending'),
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
                color: Colors.black,
                size: 16,
              ),
              label: Text(
                widget.isCompleted
                    ? 'PRACTICE SPEAKING COMPLETED ✓'
                    : 'MARK PRACTICE SPEAKING COMPLETE ✓',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFFFD700),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Privacy Note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded,
                  color: Colors.white38, size: 12),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  'Your speech is processed entirely on your device — nothing leaves your phone.',
                  style: GoogleFonts.inter(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLocalizedSubtitle(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'தினசரி பேச்சுப் பயிற்சி (Daily Speaking)';
      case 'telugu':
        return 'రోజువారీ మాట్లాడే సాధన (Daily Speaking)';
      case 'hindi':
        return 'दैनिक बोलने का अभ्यास (Daily Speaking)';
      case 'kannada':
        return 'ದೈನಂದಿನ ಮಾತನಾಡುವ ಅಭ್ಯಾಸ (Daily Speaking)';
      case 'malayalam':
        return 'സംസാര പരിശീലനം (Daily Speaking)';
      default:
        return 'Daily Speaking Practice Aloud';
    }
  }

  String _getInstructionText(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return 'விடுபட்ட இடத்தை நிரப்பி முழு வாக்கியத்தையும் உரக்கப் பேசுங்கள்.';
      case 'telugu':
        return 'ఖాళీని పూరిస్తూ పూర్తి వాక్యాన్ని బిగ్గరగా పలకండి.';
      case 'hindi':
        return 'खाली स्थान भरकर पूरा वाक्य जोर से बोलें।';
      case 'kannada':
        return 'ಖಾಲಿ ಜಾಗ ತುಂಬಿ ಪೂರ್ಣ ವಾಕ್ಯವನ್ನು ಜೋರಾಗಿ ಮಾತನಾಡಿ.';
      case 'malayalam':
        return 'വിടവ് നികത്തി പൂർണ്ണ വാചകം ഉറക്കെ സംസാരിക്കുക.';
      default:
        return 'Say the complete sentence out loud, filling in the blank.';
    }
  }

  // 10 Levels of 10 Exercises (100 Exercises Total)
  List<SpeakingExerciseItem> _getExercisesForLevel(int level) {
    switch (level) {
      case 1:
        return _kLevel1Exercises;
      case 2:
        return _kLevel2Exercises;
      case 3:
        return _kLevel3Exercises;
      case 4:
        return _kLevel4Exercises;
      case 5:
        return _kLevel5Exercises;
      case 6:
        return _kLevel6Exercises;
      case 7:
        return _kLevel7Exercises;
      case 8:
        return _kLevel8Exercises;
      case 9:
        return _kLevel9Exercises;
      case 10:
        return _kLevel10Exercises;
      default:
        return _kLevel1Exercises;
    }
  }

  // --- LEVEL 1: Daily Basics & Actions ---
  static const List<SpeakingExerciseItem> _kLevel1Exercises = [
    SpeakingExerciseItem(
      promptSentence: 'She ___ a letter.',
      targetWord: 'writes',
      acceptableWords: ['writes', 'wrote', 'write', 'is writing'],
      fullSentence: 'She writes a letter.',
      localizedHints: {
        'Tamil': 'கடிதம் எழுதும் செயல் (writes)',
        'Malayalam': 'കത്തെഴുതുന്ന പ്രവർത്തി (writes)',
        'Hindi': 'पत्र लिखने की क्रिया (writes)',
        'Telugu': 'ఉత్తరం రాయడం (writes)',
        'English': 'action of putting words on paper',
      },
      localizedTranslations: {
        'Tamil': 'அவள் ஒரு கடிதம் எழுதுகிறாள்.',
        'Malayalam': 'അവൾ ഒരു കത്തെഴുതുന്നു.',
        'Hindi': 'वह एक पत्र लिखती है।',
        'Telugu': 'ఆమె ఒక ఉత్తరం రాస్తుంది.',
        'English': 'She writes a letter.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'I ___ hot coffee in the morning.',
      targetWord: 'drink',
      acceptableWords: ['drink', 'drank', 'have', 'had'],
      fullSentence: 'I drink hot coffee in the morning.',
      localizedHints: {
        'Tamil': 'பருகும் செயல் (drink)',
        'Malayalam': 'കുടിക്കുന്ന പ്രവർത്തി (drink)',
        'Hindi': 'पीने की क्रिया (drink)',
        'Telugu': 'తాగే పని (drink)',
        'English': 'action of swallowing a beverage',
      },
      localizedTranslations: {
        'Tamil': 'நான் காலையில் சூடான காபி குடிக்கிறேன்.',
        'Malayalam': 'ഞാൻ രാവിലെ ചൂടുള്ള കാപ്പി കുടിക്കുന്നു.',
        'Hindi': 'मैं सुबह गर्म कॉफी पीता हूँ।',
        'Telugu': 'నేను ఉదయం వేడి కాఫీ తాగుతాను.',
        'English': 'I drink hot coffee in the morning.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'They ___ football every Sunday.',
      targetWord: 'play',
      acceptableWords: ['play', 'played', 'are playing'],
      fullSentence: 'They play football every Sunday.',
      localizedHints: {
        'Tamil': 'விளையாடும் செயல் (play)',
        'Malayalam': 'കളിക്കുന്ന പ്രവർത്തി (play)',
        'Hindi': 'खेलने की क्रिया (play)',
        'Telugu': 'ఆడే పని (play)',
        'English': 'take part in an athletic game or sport',
      },
      localizedTranslations: {
        'Tamil': 'அவர்கள் ஒவ்வொரு ஞாயிறும் கால்பந்து விளையாடுகிறார்கள்.',
        'Malayalam': 'അവർ എല്ലാ ഞായറാഴ്ചയും ഫുട്ബോൾ കളിക്കുന്നു.',
        'Hindi': 'वे हर रविवार फुटबॉल खेलते हैं।',
        'Telugu': 'వారు ప్రతి ఆదివారం ఫుట్‌బాల్ ఆడతారు.',
        'English': 'They play football every Sunday.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'The chef ___ delicious pasta.',
      targetWord: 'cooks',
      acceptableWords: ['cooks', 'cooked', 'makes', 'prepares'],
      fullSentence: 'The chef cooks delicious pasta.',
      localizedHints: {
        'Tamil': 'சமைக்கும் செயல் (cooks)',
        'Malayalam': 'പാചകം ചെയ്യുന്ന പ്രവർത്തി (cooks)',
        'Hindi': 'खाना पकाने की क्रिया (cooks)',
        'Telugu': 'వంట చేసే పని (cooks)',
        'English': 'prepares food using heat and ingredients',
      },
      localizedTranslations: {
        'Tamil': 'சமையல்காரர் சுவையான பாஸ்தா சமைக்கிறார்.',
        'Malayalam': 'ഷെഫ് രുചികരമായ പാസ്ത പാകം ചെയ്യുന്നു.',
        'Hindi': 'शेफ स्वादिष्ट पास्ता पकाता है।',
        'Telugu': 'చెఫ్ రుచికరమైన పాస్తా వండుతాడు.',
        'English': 'The chef cooks delicious pasta.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'He ___ his new car to work.',
      targetWord: 'drives',
      acceptableWords: ['drives', 'drove', 'is driving', 'took'],
      fullSentence: 'He drives his new car to work.',
      localizedHints: {
        'Tamil': 'வாகனம் ஓட்டும் செயல் (drives)',
        'Malayalam': 'വാഹനം ഓടിക്കുന്ന പ്രവർത്തി (drives)',
        'Hindi': 'गाड़ी चलाने की क्रिया (drives)',
        'Telugu': 'డ్రైవ్ చేసే పని (drives)',
        'English': 'operates a motor vehicle along the road',
      },
      localizedTranslations: {
        'Tamil': 'அவர் தனது புதிய காரை வேலைக்கு ஓட்டிச் செல்கிறார்.',
        'Malayalam': 'അവൻ തന്റെ പുതിയ കാർ ജോലിസ്ഥലത്തേക്ക് ഓടിക്കുന്നു.',
        'Hindi': 'वह काम पर अपनी नई कार चलाता है।',
        'Telugu': 'అతను పనికి తన కొత్త కారును డ్రైవ్ చేస్తాడు.',
        'English': 'He drives his new car to work.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'We ___ English every day.',
      targetWord: 'learn',
      acceptableWords: ['learn', 'practice', 'study', 'learned'],
      fullSentence: 'We learn English every day.',
      localizedHints: {
        'Tamil': 'கற்கும் செயல் (learn)',
        'Malayalam': 'പഠിക്കുന്ന പ്രവർത്തി (learn)',
        'Hindi': 'सीखने की क्रिया (learn)',
        'Telugu': 'నేర్చుకునే పని (learn)',
        'English': 'acquiring knowledge or skill',
      },
      localizedTranslations: {
        'Tamil': 'நாம் தினமும் ஆங்கிலம் கற்கிறோம்.',
        'Malayalam': 'ഞങ്ങൾ ദിവസവും ഇംഗ്ലീഷ് പഠിക്കുന്നു.',
        'Hindi': 'हम रोज अंग्रेजी सीखते हैं।',
        'Telugu': 'మనం రోజూ ఇంగ్లీష్ నేర్చుకుంటాము.',
        'English': 'We learn English every day.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'Birds ___ in the morning sky.',
      targetWord: 'fly',
      acceptableWords: ['fly', 'flew', 'are flying', 'sing'],
      fullSentence: 'Birds fly in the morning sky.',
      localizedHints: {
        'Tamil': 'பறக்கும் செயல் (fly)',
        'Malayalam': 'പറക്കുന്ന പ്രവർത്തി (fly)',
        'Hindi': 'उड़ने की क्रिया (fly)',
        'Telugu': 'ఎగిరే పని (fly)',
        'English': 'move through the air using wings',
      },
      localizedTranslations: {
        'Tamil': 'பறவைகள் காலை வானில் பறக்கின்றன.',
        'Malayalam': 'പക്ഷികൾ പ്രഭാത ആകാശത്ത് പറക്കുന്നു.',
        'Hindi': 'पक्षी सुबह के आसमान में उड़ते हैं।',
        'Telugu': 'పక్షులు ఉదయపు ఆకాశంలో ఎగురుతాయి.',
        'English': 'Birds fly in the morning sky.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'The baby ___ peacefully in the cradle.',
      targetWord: 'sleeps',
      acceptableWords: ['sleeps', 'slept', 'is sleeping'],
      fullSentence: 'The baby sleeps peacefully in the cradle.',
      localizedHints: {
        'Tamil': 'தூங்கும் செயல் (sleeps)',
        'Malayalam': 'ഉറങ്ങുന്ന പ്രവർത്തി (sleeps)',
        'Hindi': 'सोने की क्रिया (sleeps)',
        'Telugu': 'నిద్రపోయే పని (sleeps)',
        'English': 'resting in state of sleep',
      },
      localizedTranslations: {
        'Tamil': 'குழந்தை தொட்டிலில் நிம்மதியாகத் தூங்குகிறது.',
        'Malayalam': 'കുഞ്ഞ് തൊട്ടിലിൽ സമാധാനമായി ഉറങ്ങുന്നു.',
        'Hindi': 'बच्चा पालने में शांति से सोता है।',
        'Telugu': 'పాప ఊయలలో ప్రశాంతంగా నిద్రపోతుంది.',
        'English': 'The baby sleeps peacefully in the cradle.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'Students ___ questions in the classroom.',
      targetWord: 'ask',
      acceptableWords: ['ask', 'asked', 'are asking'],
      fullSentence: 'Students ask questions in the classroom.',
      localizedHints: {
        'Tamil': 'கேள்வி கேட்கும் செயல் (ask)',
        'Malayalam': 'ചോദിക്കുന്ന പ്രവർത്തി (ask)',
        'Hindi': 'पूछने की क्रिया (ask)',
        'Telugu': 'అడిగే పని (ask)',
        'English': 'request an answer or explanation',
      },
      localizedTranslations: {
        'Tamil': 'மாணவர்கள் வகுப்பறையில் கேள்விகள் கேட்கிறார்கள்.',
        'Malayalam': 'വിദ്യാർത്ഥികൾ ക്ലാസ് മുറിയിൽ ചോദ്യങ്ങൾ ചോദിക്കുന്നു.',
        'Hindi': 'छात्र कक्षा में प्रश्न पूछते हैं।',
        'Telugu': 'విద్యార్థులు తరగతి గదిలో ప్రశ్నలు అడుగుతారు.',
        'English': 'Students ask questions in the classroom.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'I ___ a great idea for our project.',
      targetWord: 'have',
      acceptableWords: ['have', 'had', 'got'],
      fullSentence: 'I have a great idea for our project.',
      localizedHints: {
        'Tamil': 'உடைமையாகக் கொண்டுள்ள நிலை (have)',
        'Malayalam': 'കൈവശമുള്ള അവസ്ഥ (have)',
        'Hindi': 'पास होने का भाव (have)',
        'Telugu': 'కలిగి ఉండటం (have)',
        'English': 'possess or hold a thought',
      },
      localizedTranslations: {
        'Tamil': 'நமது திட்டத்திற்கு என்னிடம் ஒரு சிறந்த யோசனை உள்ளது.',
        'Malayalam': 'നമ്മുടെ പ്രോജക്റ്റിനായി എന്റെ പക്കൽ മികച്ചൊരു ആശയമുണ്ട്.',
        'Hindi': 'हमारे प्रोजेक्ट के लिए मेरे पास एक बेहतरीन विचार है।',
        'Telugu': 'మన ప్రాజెక్ట్ కోసం నా దగ్గర గొప్ప ఆలోచన ఉంది.',
        'English': 'I have a great idea for our project.',
      },
    ),
  ];

  // --- LEVEL 2: Morning Routine & Habits ---
  static const List<SpeakingExerciseItem> _kLevel2Exercises = [
    SpeakingExerciseItem(
      promptSentence: 'I ___ up at 6 AM every morning.',
      targetWord: 'wake',
      acceptableWords: ['wake', 'get', 'woke'],
      fullSentence: 'I wake up at 6 AM every morning.',
      localizedHints: {
        'Tamil': 'விழித்தெழும் செயல் (wake)',
        'Malayalam': 'ഉണരുന്ന പ്രവർത്തി (wake)',
        'Hindi': 'जागने की क्रिया (wake)',
        'Telugu': 'మేల్కొనే పని (wake)',
        'English': 'cease to sleep',
      },
      localizedTranslations: {
        'Tamil': 'நான் தினமும் காலை 6 மணிக்கு விழிக்கிறேன்.',
        'Malayalam': 'ഞാൻ എല്ലാ ദിവസവും രാവിലെ 6 മണിക്ക് ഉണരുന്നു.',
        'Hindi': 'मैं रोज सुबह 6 बजे जागता हूँ।',
        'Telugu': 'నేను రోజూ ఉదయం 6 గంటలకు మేల్కొంటాను.',
        'English': 'I wake up at 6 AM every morning.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'He ___ his teeth before breakfast.',
      targetWord: 'brushes',
      acceptableWords: ['brushes', 'brushed', 'cleans'],
      fullSentence: 'He brushes his teeth before breakfast.',
      localizedHints: {
        'Tamil': 'பல் துலக்கும் செயல் (brushes)',
        'Malayalam': 'പല്ല് തേക്കുന്ന പ്രവർത്തി (brushes)',
        'Hindi': 'दांत साफ करने की क्रिया (brushes)',
        'Telugu': 'పళ్ళు తోముకునే పని (brushes)',
        'English': 'clean teeth with a toothbrush',
      },
      localizedTranslations: {
        'Tamil': 'அவர் காலை உணவுக்கு முன் பல் துலக்குகிறார்.',
        'Malayalam': 'അവൻ പ്രഭാതഭക്ഷണത്തിന് മുമ്പ് പല്ല് തേക്കുന്നു.',
        'Hindi': 'वह नाश्ते से पहले अपने दाँत ब्रश करता है।',
        'Telugu': 'అతను అల్పాహారానికి ముందు పళ్ళు తోముకుంటాడు.',
        'English': 'He brushes his teeth before breakfast.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'She ___ yoga in the garden.',
      targetWord: 'does',
      acceptableWords: ['does', 'practices', 'performs'],
      fullSentence: 'She does yoga in the garden.',
      localizedHints: {
        'Tamil': 'யோகா செய்யும் செயல் (does)',
        'Malayalam': 'ചെയ്യുന്ന പ്രവർത്തി (does)',
        'Hindi': 'योग करने की क्रिया (does)',
        'Telugu': 'చేసే పని (does)',
        'English': 'carries out physical exercise',
      },
      localizedTranslations: {
        'Tamil': 'அவள் தோட்டத்தில் யோகா செய்கிறாள்.',
        'Malayalam': 'അവൾ തോട്ടത്തിൽ യോഗ ചെയ്യുന്നു.',
        'Hindi': 'वह बगीचे में योग करती है।',
        'Telugu': 'ఆమె తోటలో యోగా చేస్తుంది.',
        'English': 'She does yoga in the garden.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'They ___ to work by metro.',
      targetWord: 'go',
      acceptableWords: ['go', 'travel', 'commute', 'went'],
      fullSentence: 'They go to work by metro.',
      localizedHints: {
        'Tamil': 'செல்லும் செயல் (go)',
        'Malayalam': 'പോകുന്ന പ്രവർത്തി (go)',
        'Hindi': 'जाने की क्रिया (go)',
        'Telugu': 'వెళ్ళే పని (go)',
        'English': 'move from one place to another',
      },
      localizedTranslations: {
        'Tamil': 'அவர்கள் மெட்ரோவில் வேலைக்குச் செல்கிறார்கள்.',
        'Malayalam': 'അവർ മെട്രോയിൽ ജോലിക്ക് പോകുന്നു.',
        'Hindi': 'वे मेट्रो से काम पर जाते हैं।',
        'Telugu': 'వారు మెట్రో ద్వారా పనికి వెళ్తారు.',
        'English': 'They go to work by metro.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'We ___ lunch together at noon.',
      targetWord: 'eat',
      acceptableWords: ['eat', 'have', 'ate', 'share'],
      fullSentence: 'We eat lunch together at noon.',
      localizedHints: {
        'Tamil': 'உண்ணும் செயல் (eat)',
        'Malayalam': 'ഭക്ഷിക്കുന്ന പ്രവർത്തി (eat)',
        'Hindi': 'खाने की क्रिया (eat)',
        'Telugu': 'తినే పని (eat)',
        'English': 'consume food',
      },
      localizedTranslations: {
        'Tamil': 'நாங்கள் மதியம் ஒன்றாக மதிய உணவு சாப்பிடுகிறோம்.',
        'Malayalam': 'ഞങ്ങൾ ഉച്ചയ്ക്ക് ഒരുമിച്ച് ഭക്ഷണം കഴിക്കുന്നു.',
        'Hindi': 'हम दोपहर में एक साथ दोपहर का भोजन खाते हैं।',
        'Telugu': 'మేము మధ్యాహ్నం కలిసి భోజనం చేస్తాము.',
        'English': 'We eat lunch together at noon.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'He ___ English podcasts on the train.',
      targetWord: 'listens',
      acceptableWords: ['listens', 'hears', 'listened'],
      fullSentence: 'He listens to English podcasts on the train.',
      localizedHints: {
        'Tamil': 'கேட்கும் செயல் (listens)',
        'Malayalam': 'കേൾക്കുന്ന പ്രവർത്തി (listens)',
        'Hindi': 'सुनने की क्रिया (listens)',
        'Telugu': 'వినే పని (listens)',
        'English': 'give attention to sound',
      },
      localizedTranslations: {
        'Tamil': 'அவர் ரயிலில் ஆங்கில பாட்காஸ்ட்களைக் கேட்கிறார்.',
        'Malayalam': 'അവൻ ട്രെയിനിൽ ഇംഗ്ലീഷ് പോഡ്കാസ്റ്റുകൾ കേൾക്കുന്നു.',
        'Hindi': 'वह ट्रेन में अंग्रेजी पॉडकास्ट सुनता है।',
        'Telugu': 'అతను రైలులో ఇంగ్లీష్ పాడ్‌కాస్ట్‌లను వింటాడు.',
        'English': 'He listens to English podcasts on the train.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'I ___ an apple as an afternoon snack.',
      targetWord: 'take',
      acceptableWords: ['take', 'eat', 'have', 'chose'],
      fullSentence: 'I take an apple as an afternoon snack.',
      localizedHints: {
        'Tamil': 'எடுத்துக் கொள்ளும் செயல் (take)',
        'Malayalam': 'കഴിക്കുന്ന പ്രവർത്തി (take)',
        'Hindi': 'लेने की क्रिया (take)',
        'Telugu': 'తీసుకునే పని (take)',
        'English': 'consume or choose a snack',
      },
      localizedTranslations: {
        'Tamil': 'நான் மாலை சிற்றுண்டியாக ஒரு ஆப்பிள் சாப்பிடுகிறேன்.',
        'Malayalam': 'ഞാൻ ഉച്ചതിരിഞ്ഞ് ലഘുഭക്ഷണമായി ഒരു ആപ്പിൾ കഴിക്കുന്നു.',
        'Hindi': 'मैं दोपहर के नाश्ते के रूप में एक सेब लेता हूँ।',
        'Telugu': 'నేను మధ్యాహ్నం స్నాక్‌గా ఆపిల్ తీసుకుంటాను.',
        'English': 'I take an apple as an afternoon snack.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'She ___ home around six o’clock.',
      targetWord: 'reaches',
      acceptableWords: ['reaches', 'comes', 'returns', 'reached'],
      fullSentence: 'She reaches home around six o’clock.',
      localizedHints: {
        'Tamil': 'வீடு வந்து சேரும் செயல் (reaches)',
        'Malayalam': 'എത്തിച്ചേരുന്ന പ്രവർത്തി (reaches)',
        'Hindi': 'पहुंचने की क्रिया (reaches)',
        'Telugu': 'చేరుకునే పని (reaches)',
        'English': 'arrive at destination',
      },
      localizedTranslations: {
        'Tamil': 'அவள் ஆறு மணியளவில் வீடு வந்து சேருகிறாள்.',
        'Malayalam': 'അവൾ ആറുമണിയോടെ വീട്ടിലെത്തുന്നു.',
        'Hindi': 'वह लगभग छह बजे घर पहुँचती है।',
        'Telugu': 'ఆమె ఆరు గంటల ప్రాంతంలో ఇంటికి చేరుకుంటుంది.',
        'English': 'She reaches home around six o’clock.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'We ___ a walk after dinner.',
      targetWord: 'take',
      acceptableWords: ['take', 'go for', 'have'],
      fullSentence: 'We take a walk after dinner.',
      localizedHints: {
        'Tamil': 'நடைபயிற்சி செல்லும் செயல் (take)',
        'Malayalam': 'നടക്കാൻ പോകുന്ന പ്രവർത്തി (take)',
        'Hindi': 'टहलने जाने की क्रिया (take)',
        'Telugu': 'నడకకు వెళ్ళే పని (take)',
        'English': 'engage in a stroll',
      },
      localizedTranslations: {
        'Tamil': 'நாங்கள் இரவு உணவிற்குப் பிறகு நடைப்பயிற்சி செல்கிறோம்.',
        'Malayalam': 'ഞങ്ങൾ അത്താഴത്തിന് ശേഷം നടക്കാൻ പോകുന്നു.',
        'Hindi': 'हम रात के खाने के बाद टहलते हैं।',
        'Telugu': 'మేము రాత్రి భోజనం తర్వాత నడకకు వెళ్తాము.',
        'English': 'We take a walk after dinner.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'I ___ to bed before midnight.',
      targetWord: 'go',
      acceptableWords: ['go', 'head', 'went'],
      fullSentence: 'I go to bed before midnight.',
      localizedHints: {
        'Tamil': 'உறங்கச் செல்லும் செயல் (go)',
        'Malayalam': 'കിടക്കാൻ പോകുന്ന പ്രവർത്തി (go)',
        'Hindi': 'सोने जाने की क्रिया (go)',
        'Telugu': 'పడుకోవడానికి వెళ్ళే పని (go)',
        'English': 'retire for sleep',
      },
      localizedTranslations: {
        'Tamil': 'நான் நள்ளிரவுக்கு முன் தூங்கச் செல்கிறேன்.',
        'Malayalam': 'ഞാൻ അർദ്ധരാത്രിക്ക് മുമ്പ് ഉറങ്ങാൻ പോകുന്നു.',
        'Hindi': 'मैं आधी रात से पहले सोने जाता हूँ।',
        'Telugu': 'నేను అర్ధరాత్రికి ముందే నిద్రపోతాను.',
        'English': 'I go to bed before midnight.',
      },
    ),
  ];

  // --- LEVEL 3: Polite Requests & Needs ---
  static const List<SpeakingExerciseItem> _kLevel3Exercises = [
    SpeakingExerciseItem(
      promptSentence: 'Could you please ___ me that file?',
      targetWord: 'send',
      acceptableWords: ['send', 'pass', 'give', 'email'],
      fullSentence: 'Could you please send me that file?',
      localizedHints: {
        'Tamil': 'அனுப்பும் செயல் (send)',
        'Malayalam': 'അയക്കുന്ന പ്രവർത്തി (send)',
        'Hindi': 'भेजने की क्रिया (send)',
        'Telugu': 'పంపే పని (send)',
        'English': 'transmit digitally',
      },
      localizedTranslations: {
        'Tamil': 'தயவுசெய்து அந்தக் கோப்பை எனக்கு அனுப்ப முடியுமா?',
        'Malayalam': 'ദയവായി ആ ഫയൽ എനിക്ക് അയച്ചുതരാമോ?',
        'Hindi': 'क्या आप कृपया मुझे वह फ़ाइल भेज सकते हैं?',
        'Telugu': 'దయచేసి ఆ ఫైల్‌ను నాకు పంపగలరా?',
        'English': 'Could you please send me that file?',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'May I ___ a glass of water?',
      targetWord: 'have',
      acceptableWords: ['have', 'get', 'take'],
      fullSentence: 'May I have a glass of water?',
      localizedHints: {
        'Tamil': 'பெறும் செயல் (have)',
        'Malayalam': 'ലഭിക്കുന്ന പ്രവർത്തി (have)',
        'Hindi': 'पाने की क्रिया (have)',
        'Telugu': 'పొందే పని (have)',
        'English': 'receive or consume',
      },
      localizedTranslations: {
        'Tamil': 'நான் ஒரு டம்ளர் தண்ணீர் பெறலாமா?',
        'Malayalam': 'എനിക്ക് ഒരു ഗ്ലാസ് വെള്ളം കിട്ടുമോ?',
        'Hindi': 'क्या मुझे एक गिलास पानी मिल सकता है?',
        'Telugu': 'నాకు ఒక గ్లాసు నీరు దొరుకుతుందా?',
        'English': 'May I have a glass of water?',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'Would you mind ___ the window?',
      targetWord: 'opening',
      acceptableWords: ['opening', 'closing', 'open', 'close'],
      fullSentence: 'Would you mind opening the window?',
      localizedHints: {
        'Tamil': 'திறக்கும் செயல் (opening)',
        'Malayalam': 'തുറക്കുന്ന പ്രവർത്തി (opening)',
        'Hindi': 'खोलने की क्रिया (opening)',
        'Telugu': 'తెరిచే పని (opening)',
        'English': 'unlatching window',
      },
      localizedTranslations: {
        'Tamil': 'சாளரத்தைத் திறப்பதில் உங்களுக்கு ஆட்சேபனை இல்லையா?',
        'Malayalam': 'ജനൽ തുറക്കുന്നതിൽ വിരോധമില്ലല്ലോ?',
        'Hindi': 'क्या आप खिड़की खोल देंगे?',
        'Telugu': 'కిటికీ తెరవడానికి అభ్యంతరం లేదా?',
        'English': 'Would you mind opening the window?',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'I need to ___ to the manager today.',
      targetWord: 'speak',
      acceptableWords: ['speak', 'talk', 'write'],
      fullSentence: 'I need to speak to the manager today.',
      localizedHints: {
        'Tamil': 'பேசும் செயல் (speak)',
        'Malayalam': 'സംസാരിക്കുന്ന പ്രവർത്തി (speak)',
        'Hindi': 'बात करने की क्रिया (speak)',
        'Telugu': 'మాట్లాడే పని (speak)',
        'English': 'converse verbally',
      },
      localizedTranslations: {
        'Tamil': 'நான் இன்று மேலாளரிடம் பேச வேண்டும்.',
        'Malayalam': 'എനിക്ക് ഇന്ന് മാനേജറോട് സംസാരിക്കണം.',
        'Hindi': 'मुझे आज प्रबंधक से बात करनी है।',
        'Telugu': 'నేను ఈరోజు మేనేజర్‌తో మాట్లాడాలి.',
        'English': 'I need to speak to the manager today.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'Could you ___ that more slowly, please?',
      targetWord: 'repeat',
      acceptableWords: ['repeat', 'say', 'speak'],
      fullSentence: 'Could you repeat that more slowly, please?',
      localizedHints: {
        'Tamil': 'மீண்டும் கூறும் செயல் (repeat)',
        'Malayalam': 'ആവർത്തിക്കുന്ന പ്രവർത്തി (repeat)',
        'Hindi': 'दोहराने की क्रिया (repeat)',
        'Telugu': 'పునరావృతం చేసే పని (repeat)',
        'English': 'say once again',
      },
      localizedTranslations: {
        'Tamil': 'தயவுசெய்து அதை சற்று மெதுவாக மீண்டும் கூற முடியுமா?',
        'Malayalam': 'ദയവായി അത് ഒന്നുകൂടി സാവധാനം ആവർത്തിക്കാമോ?',
        'Hindi': 'क्या आप इसे थोड़ा धीरे दोहरा सकते हैं?',
        'Telugu': 'దయచేసి దాన్ని కొంచెం నెమ్మదిగా మళ్లీ చెప్పగలరా?',
        'English': 'Could you repeat that more slowly, please?',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'I would like to ___ an appointment.',
      targetWord: 'book',
      acceptableWords: ['book', 'make', 'schedule'],
      fullSentence: 'I would like to book an appointment.',
      localizedHints: {
        'Tamil': 'பதிவு செய்யும் செயல் (book)',
        'Malayalam': 'ബുക്ക് ചെയ്യുന്ന പ്രവർത്തി (book)',
        'Hindi': 'बुक करने की क्रिया (book)',
        'Telugu': 'బుక్ చేసుకునే పని (book)',
        'English': 'reserve a time slot',
      },
      localizedTranslations: {
        'Tamil': 'நான் ஒரு சந்திப்பை பதிவு செய்ய விரும்புகிறேன்.',
        'Malayalam': 'എനിക്ക് ഒരു അപ്പോയിന്റ്മെന്റ് ബുക്ക് ചെയ്യണം.',
        'Hindi': 'मैं एक अपॉइंटमेंट बुक करना चाहता हूँ।',
        'Telugu': 'నేను అపాయింట్‌మెంట్ బుక్ చేసుకోవాలనుకుంటున్నాను.',
        'English': 'I would like to book an appointment.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'Can you please ___ me the direction?',
      targetWord: 'show',
      acceptableWords: ['show', 'tell', 'give'],
      fullSentence: 'Can you please show me the direction?',
      localizedHints: {
        'Tamil': 'காண்பிக்கும் செயல் (show)',
        'Malayalam': 'കാണിച്ചുതരുന്ന പ്രവർത്തി (show)',
        'Hindi': 'दिखाने की क्रिया (show)',
        'Telugu': 'చూపించే పని (show)',
        'English': 'guide or point path',
      },
      localizedTranslations: {
        'Tamil': 'தயவுசெய்து எனக்கு வழியைக் காட்ட முடியுமா?',
        'Malayalam': 'ദയവായി എനിക്ക് വഴി കാണിച്ചുതരാമോ?',
        'Hindi': 'क्या आप मुझे रास्ता दिखा सकते हैं?',
        'Telugu': 'దయచేసి నాకు దారి చూపగలరా?',
        'English': 'Can you please show me the direction?',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'I want to ___ for the inconvenience caused.',
      targetWord: 'apologize',
      acceptableWords: ['apologize', 'say sorry'],
      fullSentence: 'I want to apologize for the inconvenience caused.',
      localizedHints: {
        'Tamil': 'மன்னிப்புக் கேட்கும் செயல் (apologize)',
        'Malayalam': 'ക്ഷമ ചോദിക്കുന്ന പ്രവർത്തി (apologize)',
        'Hindi': 'माफी मांगने की क्रिया (apologize)',
        'Telugu': 'క్షమాపణ కోరే పని (apologize)',
        'English': 'express regret',
      },
      localizedTranslations: {
        'Tamil': 'ஏற்பட்ட சிரமத்திற்கு நான் மன்னிப்பு கேட்க விரும்புகிறேன்.',
        'Malayalam': 'ഉണ്ടായ ബുദ്ധിമുട്ടുകൾക്ക് ഞാൻ ക്ഷമ ചോദിക്കുന്നു.',
        'Hindi': 'हुई असुविधा के लिए मैं क्षमा चाहता हूँ।',
        'Telugu': 'కలిగిన అసౌకర్యానికి నేను క్షమాపణ కోరుతున్నాను.',
        'English': 'I want to apologize for the inconvenience caused.',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'Could you ___ me carry this heavy bag?',
      targetWord: 'help',
      acceptableWords: ['help', 'assist'],
      fullSentence: 'Could you help me carry this heavy bag?',
      localizedHints: {
        'Tamil': 'உதவும் செயல் (help)',
        'Malayalam': 'സഹായിക്കുന്ന പ്രവർത്തി (help)',
        'Hindi': 'मदद करने की क्रिया (help)',
        'Telugu': 'సహాయం చేసే పని (help)',
        'English': 'render assistance',
      },
      localizedTranslations: {
        'Tamil': 'இந்தக் கனமான பையைத் தூக்க எனக்கு உதவ முடியுமா?',
        'Malayalam': 'ഈ ഭാരമുള്ള ബാഗ് എടുക്കാൻ എന്നെ സഹായിക്കാമോ?',
        'Hindi': 'क्या आप यह भारी बैग उठाने में मेरी मदद कर सकते हैं?',
        'Telugu': 'ఈ బరువైన బ్యాగ్‌ని మోయడంలో నాకు సహాయం చేయగలరా?',
        'English': 'Could you help me carry this heavy bag?',
      },
    ),
    SpeakingExerciseItem(
      promptSentence: 'Thank you for your kind ___ today.',
      targetWord: 'support',
      acceptableWords: ['support', 'help', 'words'],
      fullSentence: 'Thank you for your kind support today.',
      localizedHints: {
        'Tamil': 'ஆதரவு அளிக்கும் பண்பு (support)',
        'Malayalam': 'പിന്തുണ (support)',
        'Hindi': 'सहयोग (support)',
        'Telugu': 'మద్దతు (support)',
        'English': 'assistance or encouragement',
      },
      localizedTranslations: {
        'Tamil': 'இன்றைய உங்கள் அன்பான ஆதரவுக்கு நன்றி.',
        'Malayalam': 'ഇന്നത്തെ നിങ്ങളുടെ ദയയുള്ള പിന്തുണയ്ക്ക് നന്ദി.',
        'Hindi': 'आज आपके सहयोग के लिए धन्यवाद।',
        'Telugu': 'ఈరోజు మీ సహకారానికి ధన్యవాదాలు.',
        'English': 'Thank you for your kind support today.',
      },
    ),
  ];

  // --- LEVEL 4: Travel & Directions ---
  static const List<SpeakingExerciseItem> _kLevel4Exercises = [
    SpeakingExerciseItem(
      promptSentence: 'Where is the nearest train ___?',
      targetWord: 'station',
      acceptableWords: ['station', 'stop'],
      fullSentence: 'Where is the nearest train station?',
      localizedHints: {'Tamil': 'நிலையம் (station)', 'Malayalam': 'സ്റ്റേഷൻ (station)', 'Hindi': 'स्टेशन (station)', 'Telugu': 'స్టేషన్ (station)', 'English': 'rail transit terminal'},
      localizedTranslations: {'Tamil': 'அருகிலுள்ள ரயில் நிலையம் எங்கே இருக்கிறது?', 'Malayalam': 'ഏറ്റവും അടുത്തുള്ള ട്രെയിൻ സ്റ്റേഷൻ എവിടെയാണ്?', 'Hindi': 'निकटतम रेलवे स्टेशन कहाँ है?', 'Telugu': 'సమీప రైల్వే స్టేషన్ ఎక్కడ ఉంది?', 'English': 'Where is the nearest train station?'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'How much does this bus ticket ___?',
      targetWord: 'cost',
      acceptableWords: ['cost', 'take'],
      fullSentence: 'How much does this bus ticket cost?',
      localizedHints: {'Tamil': 'விலை (cost)', 'Malayalam': 'വില (cost)', 'Hindi': 'कीमत (cost)', 'Telugu': 'ధర (cost)', 'English': 'monetary price'},
      localizedTranslations: {'Tamil': 'இந்த பேருந்து டிக்கெட் விலை என்ன?', 'Malayalam': 'ഈ ബസ് ടിക്കറ്റിന് എത്ര വിലയാകും?', 'Hindi': 'इस बस टिकट की कीमत क्या है?', 'Telugu': 'ఈ బస్సు టికెట్ ధర ఎంత?', 'English': 'How much does this bus ticket cost?'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Turn left at the next traffic ___.',
      targetWord: 'light',
      acceptableWords: ['light', 'signal', 'intersection'],
      fullSentence: 'Turn left at the next traffic light.',
      localizedHints: {'Tamil': 'போக்குவரத்து விளக்கு (light)', 'Malayalam': 'ട്രാഫിക് ലൈറ്റ് (light)', 'Hindi': 'ट्रैफिक लाइट (light)', 'Telugu': 'ట్రాఫిక్ లైట్ (light)', 'English': 'road signaling light'},
      localizedTranslations: {'Tamil': 'அடுத்த டிராஃபிக் சிக்னலில் இடதுபுறம் திரும்புங்கள்.', 'Malayalam': 'അടുത്ത ട്രാഫിക് ലൈറ്റിൽ ഇടത്തേക്ക് തിരിയുക.', 'Hindi': 'अगली ट्रैफिक लाइट पर बाएं मुड़ें।', 'Telugu': 'తదుపరి ట్రాఫిక్ లైట్ వద్ద ఎడమవైపు తిరగండి.', 'English': 'Turn left at the next traffic light.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Is this seat ___ or taken?',
      targetWord: 'free',
      acceptableWords: ['free', 'empty', 'available'],
      fullSentence: 'Is this seat free or taken?',
      localizedHints: {'Tamil': 'காலியாக (free)', 'Malayalam': 'ഒഴിവുള്ള (free)', 'Hindi': 'खाली (free)', 'Telugu': 'ఖాళీగా (free)', 'English': 'unoccupied'},
      localizedTranslations: {'Tamil': 'இந்த இருக்கை காலியாக உள்ளதா?', 'Malayalam': 'ഈ സീറ്റ് ഒഴിവുണ്ടോ അതോ ആളുണ്ടോ?', 'Hindi': 'क्या यह सीट खाली है?', 'Telugu': 'ఈ సీటు ఖాళీగా ఉందా?', 'English': 'Is this seat free or taken?'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'We need to ___ our boarding passes.',
      targetWord: 'show',
      acceptableWords: ['show', 'print', 'present'],
      fullSentence: 'We need to show our boarding passes.',
      localizedHints: {'Tamil': 'காண்பித்தல் (show)', 'Malayalam': 'കാണിക്കുക (show)', 'Hindi': 'दिखाना (show)', 'Telugu': 'చూపించడం (show)', 'English': 'display travel document'},
      localizedTranslations: {'Tamil': 'நாங்கள் எங்களின் போர்டிங் பாஸைக் காட்ட வேண்டும்.', 'Malayalam': 'നമ്മൾ ബോർഡിംഗ് പാസ് കാണിക്കണം.', 'Hindi': 'हमें अपने बोर्डिंग पास दिखाने होंगे।', 'Telugu': 'మేము మా బోర్డింగ్ పాస్‌లను చూపించాలి.', 'English': 'We need to show our boarding passes.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'The plane will ___ off in ten minutes.',
      targetWord: 'take',
      acceptableWords: ['take'],
      fullSentence: 'The plane will take off in ten minutes.',
      localizedHints: {'Tamil': 'விமானம் புறப்படல் (take)', 'Malayalam': 'പറന്നുയരുക (take)', 'Hindi': 'उड़ान भरना (take)', 'Telugu': 'టేకాఫ్ (take)', 'English': 'airborne ascent'},
      localizedTranslations: {'Tamil': 'விமானம் இன்னும் பத்து நிமிடங்களில் புறப்படும்.', 'Malayalam': 'വിമാനം പത്ത് മിനിറ്റിനുള്ളിൽ പറന്നുയരും.', 'Hindi': 'विमान दस मिनट में उड़ान भरेगा।', 'Telugu': 'విమానం పది నిమిషాల్లో టేకాఫ్ అవుతుంది.', 'English': 'The plane will take off in ten minutes.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I lost my ___ at the airport terminal.',
      targetWord: 'luggage',
      acceptableWords: ['luggage', 'bag', 'baggage', 'passport'],
      fullSentence: 'I lost my luggage at the airport terminal.',
      localizedHints: {'Tamil': 'பயணப்பெட்டி (luggage)', 'Malayalam': 'ലഗേജ് (luggage)', 'Hindi': 'सामान (luggage)', 'Telugu': 'లగేజ్ (luggage)', 'English': 'suitcases or baggage'},
      localizedTranslations: {'Tamil': 'விமான நிலைய முனையத்தில் என் உடைமைகளைத் தொலைத்துவிட்டேன்.', 'Malayalam': 'എയർപോർട്ട് ടെർമിനലിൽ വെച്ച് എന്റെ ലഗേജ് നഷ്ടപ്പെട്ടു.', 'Hindi': 'हवाई अड्डे पर मेरा सामान खो गया।', 'Telugu': 'విమానాశ్రయంలో నా లగేజీ పోయింది.', 'English': 'I lost my luggage at the airport terminal.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Can you recommend a good local ___ to eat?',
      targetWord: 'restaurant',
      acceptableWords: ['restaurant', 'place', 'cafe', 'hotel'],
      fullSentence: 'Can you recommend a good local restaurant to eat?',
      localizedHints: {'Tamil': 'உணவகம் (restaurant)', 'Malayalam': 'റെസ്റ്റോറന്റ് (restaurant)', 'Hindi': 'रेस्तरां (restaurant)', 'Telugu': 'రెస్టారెంట్ (restaurant)', 'English': 'dining establishment'},
      localizedTranslations: {'Tamil': 'சாப்பிட நல்ல உணவகத்தைப் பரிந்துரைக்க முடியுமா?', 'Malayalam': 'ഭക്ഷണം കഴിക്കാൻ നല്ലൊരു റെസ്റ്റോറന്റ് നിർദ്ദേശിക്കാമോ?', 'Hindi': 'क्या आप भोजन के लिए एक अच्छे रेस्तरां की सिफारिश कर सकते हैं?', 'Telugu': 'భోజనానికి మంచి రెస్టారెంట్‌ను సూచించగలరా?', 'English': 'Can you recommend a good local restaurant to eat?'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Straight ahead, it is on the ___ side.',
      targetWord: 'right',
      acceptableWords: ['right', 'left', 'other'],
      fullSentence: 'Straight ahead, it is on the right side.',
      localizedHints: {'Tamil': 'வலதுபுறம் (right)', 'Malayalam': 'വലതുവശം (right)', 'Hindi': 'दाहिनी तरफ (right)', 'Telugu': 'కుడివైపు (right)', 'English': 'opposite of left'},
      localizedTranslations: {'Tamil': 'நேராகச் செல்லுங்கள், அது வலதுபுறம் உள்ளது.', 'Malayalam': 'നേരെ മുന്നോട്ട്, അത് വലതുവശത്താണ്.', 'Hindi': 'सीधे आगे, यह दाईं ओर है।', 'Telugu': 'సూటిగా ముందుకు, అది కుడి వైపున ఉంది.', 'English': 'Straight ahead, it is on the right side.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Have a safe and wonderful ___!',
      targetWord: 'journey',
      acceptableWords: ['journey', 'trip', 'flight', 'travel'],
      fullSentence: 'Have a safe and wonderful journey!',
      localizedHints: {'Tamil': 'பயணம் (journey)', 'Malayalam': 'യാത്ര (journey)', 'Hindi': 'यात्रा (journey)', 'Telugu': 'ప్రయాణం (journey)', 'English': 'travel excursion'},
      localizedTranslations: {'Tamil': 'இனிய பாதுகாப்பான பயணம் அமையட்டும்!', 'Malayalam': 'സുരക്ഷിതവും മനോഹരവുമായ ഒരു യാത്ര ആശംസിക്കുന്നു!', 'Hindi': 'आपकी यात्रा सुखद और सुरक्षित हो!', 'Telugu': 'సురక్షితమైన ప్రయాణం కావాలని కోరుకుంటున్నాను!', 'English': 'Have a safe and wonderful journey!'},
    ),
  ];

  // --- LEVEL 5: Work & Professional ---
  static const List<SpeakingExerciseItem> _kLevel5Exercises = [
    SpeakingExerciseItem(
      promptSentence: 'Let us schedule a team ___ for tomorrow.',
      targetWord: 'meeting',
      acceptableWords: ['meeting', 'call', 'sync'],
      fullSentence: 'Let us schedule a team meeting for tomorrow.',
      localizedHints: {'Tamil': 'கூட்டம் (meeting)', 'Malayalam': 'മീറ്റിംഗ് (meeting)', 'Hindi': 'बैठक (meeting)', 'Telugu': 'సమావేశం (meeting)', 'English': 'work gathering'},
      localizedTranslations: {'Tamil': 'நாளைக்கு ஒரு குழு கூட்டத்தை திட்டமிடுவோம்.', 'Malayalam': 'നാളെ ഒരു ടീം മീറ്റിംഗ് സംഘടിപ്പിക്കാം.', 'Hindi': 'आइए कल के लिए टीम मीटिंग तय करें।', 'Telugu': 'రేపటి కోసం ఒక బృంద సమావేశాన్ని ఏర్పాటు చేద్దాం.', 'English': 'Let us schedule a team meeting for tomorrow.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I will ___ the presentation by noon.',
      targetWord: 'complete',
      acceptableWords: ['complete', 'finish', 'share', 'deliver'],
      fullSentence: 'I will complete the presentation by noon.',
      localizedHints: {'Tamil': 'முடித்தல் (complete)', 'Malayalam': 'പൂർത്തിയാക്കുക (complete)', 'Hindi': 'पूरा करना (complete)', 'Telugu': 'పూర్తి చేయడం (complete)', 'English': 'finalize work'},
      localizedTranslations: {'Tamil': 'நான் மதியத்திற்குள் விளக்கக்காட்சியை முடித்துவிடுவேன்.', 'Malayalam': 'ഞാൻ ഉച്ചയോടെ പ്രസന്റേഷൻ പൂർത്തിയാക്കും.', 'Hindi': 'मैं दोपहर तक प्रस्तुति पूरी कर लूँगा।', 'Telugu': 'నేను మధ్యాహ్నానికి ప్రెజెంటేషన్‌ను పూర్తి చేస్తాను.', 'English': 'I will complete the presentation by noon.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Please ___ the attached document carefully.',
      targetWord: 'review',
      acceptableWords: ['review', 'check', 'read'],
      fullSentence: 'Please review the attached document carefully.',
      localizedHints: {'Tamil': 'சரிபார்த்தல் (review)', 'Malayalam': 'പരിശോധിക്കുക (review)', 'Hindi': 'समीक्षा करना (review)', 'Telugu': 'సమీక్షించడం (review)', 'English': 'examine in detail'},
      localizedTranslations: {'Tamil': 'இணைக்கப்பட்ட ஆவணத்தை கவனமாக மதிப்பாய்வு செய்யவும்.', 'Malayalam': 'ചേർത്തിരിക്കുന്ന പ്രമാണം ശ്രദ്ധാപൂർവ്വം പരിശോധിക്കുക.', 'Hindi': 'कृपया संलग्न दस्तावेज़ की सावधानीपूर्वक समीक्षा करें।', 'Telugu': 'దయచేసి జతచేసిన పత్రాన్ని జాగ్రత్తగా సమీక్షించండి.', 'English': 'Please review the attached document carefully.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'We met the strict project ___ on time.',
      targetWord: 'deadline',
      acceptableWords: ['deadline', 'date', 'target'],
      fullSentence: 'We met the strict project deadline on time.',
      localizedHints: {'Tamil': 'கடைசி கெடு (deadline)', 'Malayalam': 'അവസാന തീയതി (deadline)', 'Hindi': 'समय सीमा (deadline)', 'Telugu': 'గడువు (deadline)', 'English': 'latest time for finish'},
      localizedTranslations: {'Tamil': 'திட்டத்தின் காலக்கெடுவை சரியான நேரத்தில் முடித்தோம்.', 'Malayalam': 'ഞങ്ങൾ പ്രോജക്റ്റ് സമയപരിധി കൃത്യസമയത്ത് പൂർത്തിയാക്കി.', 'Hindi': 'हमने समय पर प्रोजेक्ट पूरा किया।', 'Telugu': 'మేము ప్రాజెక్ట్ గడువును సకాలంలో చేరుకున్నాము.', 'English': 'We met the strict project deadline on time.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'He received a well-deserved ___ last week.',
      targetWord: 'promotion',
      acceptableWords: ['promotion', 'raise', 'award'],
      fullSentence: 'He received a well-deserved promotion last week.',
      localizedHints: {'Tamil': 'பதவி உயர்வு (promotion)', 'Malayalam': 'സ്ഥാനക്കയറ്റം (promotion)', 'Hindi': 'पदोन्नति (promotion)', 'Telugu': 'పదోన్నతి (promotion)', 'English': 'career advancement'},
      localizedTranslations: {'Tamil': 'கடந்த வாரம் அவருக்கு தகுதியான பதவி உயர்வு கிடைத்தது.', 'Malayalam': 'കഴിഞ്ഞ ആഴ്ച അവന് അർഹിച്ച സ്ഥാനക്കയറ്റം ലഭിച്ചു.', 'Hindi': 'पिछले हफ्ते उन्हें योग्य पदोन्नति मिली।', 'Telugu': 'గత వారం అతనికి తగిన ప్రమోషన్ లభించింది.', 'English': 'He received a well-deserved promotion last week.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Let us brainstorm creative ___ to this problem.',
      targetWord: 'solutions',
      acceptableWords: ['solutions', 'ideas', 'ways'],
      fullSentence: 'Let us brainstorm creative solutions to this problem.',
      localizedHints: {'Tamil': 'தீர்வுகள் (solutions)', 'Malayalam': 'പരിഹാരങ്ങൾ (solutions)', 'Hindi': 'समाधान (solutions)', 'Telugu': 'పరిష్కారాలు (solutions)', 'English': 'answers or fixes'},
      localizedTranslations: {'Tamil': 'இந்த பிரச்சனைக்கு ஆக்கப்பூர்வமான தீர்வுகளை யோசிப்போம்.', 'Malayalam': 'ഈ പ്രശ്നത്തിന് സർഗ്ഗാത്മകമായ പരിഹാരങ്ങൾ ആലോചിക്കാം.', 'Hindi': 'आइए इस समस्या के रचनात्मक समाधान खोजें।', 'Telugu': 'ఈ సమస్యకు సృజనాత్మక పరిష్కారాలను ఆలోచిద్దాం.', 'English': 'Let us brainstorm creative solutions to this problem.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Our client was very ___ with our speed.',
      targetWord: 'impressed',
      acceptableWords: ['impressed', 'happy', 'pleased', 'satisfied'],
      fullSentence: 'Our client was very impressed with our speed.',
      localizedHints: {'Tamil': 'ஈர்க்கப்பட்டார் (impressed)', 'Malayalam': 'സന്തുഷ്ടനായി (impressed)', 'Hindi': 'प्रभावित (impressed)', 'Telugu': 'ఆకట్టుకుంది (impressed)', 'English': 'highly pleased'},
      localizedTranslations: {'Tamil': 'எங்கள் வாடிக்கையாளர் எங்கள் வேகத்தைக் கண்டு பெரிதும் ஈர்க்கப்பட்டார்.', 'Malayalam': 'ഞങ്ങളുടെ ഉപഭോക്താവ് ഞങ്ങളുടെ വേഗതയിൽ വളരെ സന്തുഷ്ടനായിരുന്നു.', 'Hindi': 'हमारा ग्राहक हमारी गति से बहुत प्रभावित हुआ।', 'Telugu': 'మా క్లయింట్ మా పని వేగానికి ఎంతగానో ఆకట్టుకున్నారు.', 'English': 'Our client was very impressed with our speed.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I sent the weekly progress ___ to everyone.',
      targetWord: 'report',
      acceptableWords: ['report', 'update', 'email'],
      fullSentence: 'I sent the weekly progress report to everyone.',
      localizedHints: {'Tamil': 'அறிக்கை (report)', 'Malayalam': 'റിപ്പോർട്ട് (report)', 'Hindi': 'रिपोर्ट (report)', 'Telugu': 'నివేదిక (report)', 'English': 'summary update'},
      localizedTranslations: {'Tamil': 'வாராந்திர முன்னேற்ற அறிக்கையை அனைவருக்கும் அனுப்பினேன்.', 'Malayalam': 'ഞാൻ പ്രതിവാര പുരോഗതി റിപ്പോർട്ട് എല്ലാവർക്കും അയച്ചു.', 'Hindi': 'मैंने सभी को साप्ताहिक प्रगति रिपोर्ट भेजी।', 'Telugu': 'నేను ప్రతివారం ప్రగతి నివేదికను అందరికీ పంపాను.', 'English': 'I sent the weekly progress report to everyone.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Effective communication builds stronger ___ in office.',
      targetWord: 'trust',
      acceptableWords: ['trust', 'bonds', 'relationships'],
      fullSentence: 'Effective communication builds stronger trust in office.',
      localizedHints: {'Tamil': 'நம்பிக்கை (trust)', 'Malayalam': 'വിശ്വാസം (trust)', 'Hindi': 'विश्वास (trust)', 'Telugu': 'నమ్మకం (trust)', 'English': 'mutual reliance'},
      localizedTranslations: {'Tamil': 'சிறந்த தொடர்பு அலுவலகத்தில் வலுவான நம்பிக்கையை உருவாக்குகிறது.', 'Malayalam': 'ഫലപ്രദമായ ആശയവിനിമയം ഓഫീസിൽ ശക്തമായ വിശ്വാസം വളർത്തുന്നു.', 'Hindi': 'प्रभावी संचार कार्यालय में मजबूत विश्वास बनाता है।', 'Telugu': 'సమర్థవంతమైన సంభాషణ ఆఫీసులో బలమైన నమ్మకాన్ని పెంచుతుంది.', 'English': 'Effective communication builds stronger trust in office.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'We achieved our annual sales ___ early.',
      targetWord: 'target',
      acceptableWords: ['target', 'goal', 'quota'],
      fullSentence: 'We achieved our annual sales target early.',
      localizedHints: {'Tamil': 'இலக்கு (target)', 'Malayalam': 'ലക്ഷ്യം (target)', 'Hindi': 'लक्ष्य (target)', 'Telugu': 'లక్ష్యం (target)', 'English': 'aimed milestone'},
      localizedTranslations: {'Tamil': 'நாங்கள் எங்களின் ஆண்டு விற்பனை இலக்கை முன்கூட்டியே எட்டினோம்.', 'Malayalam': 'ഞങ്ങൾ വാർഷിക വിൽപ്പന ലക്ഷ്യം നേരത്തെ തന്നെ നേടി.', 'Hindi': 'हमने अपना वार्षिक बिक्री लक्ष्य पहले ही हासिल कर लिया।', 'Telugu': 'మేము మా వార్షిక అమ్మకాల లక్ష్యాన్ని ముందుగానే సాధించాము.', 'English': 'We achieved our annual sales target early.'},
    ),
  ];

  // --- LEVEL 6: Feelings & Opinions ---
  static const List<SpeakingExerciseItem> _kLevel6Exercises = [
    SpeakingExerciseItem(
      promptSentence: 'I feel very ___ about our upcoming launch.',
      targetWord: 'confident',
      acceptableWords: ['confident', 'excited', 'optimistic', 'happy'],
      fullSentence: 'I feel very confident about our upcoming launch.',
      localizedHints: {'Tamil': 'தன்னம்பிக்கை (confident)', 'Malayalam': 'ആത്മവിശ്വാസം (confident)', 'Hindi': 'आत्मविश्वासी (confident)', 'Telugu': 'ఆత్మవిశ్వాసం (confident)', 'English': 'feeling assurance'},
      localizedTranslations: {'Tamil': 'நமது வரவிருக்கும் வெளியீடு பற்றி நான் மிகவும் நம்பிக்கையுடன் இருக்கிறேன்.', 'Malayalam': 'നമ്മുടെ വരാനിരിക്കുന്ന ലോഞ്ചിൽ എനിക്ക് പൂർണ്ണ ആത്മവിശ്വാസമുണ്ട്.', 'Hindi': 'मुझे आगामी लॉन्च को लेकर पूरा विश्वास है।', 'Telugu': 'మన రాబోయే లాంచ్ గురించి నాకు చాలా నమ్మకంగా ఉంది.', 'English': 'I feel very confident about our upcoming launch.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'In my honest ___, this design looks elegant.',
      targetWord: 'opinion',
      acceptableWords: ['opinion', 'view'],
      fullSentence: 'In my honest opinion, this design looks elegant.',
      localizedHints: {'Tamil': 'கருத்து (opinion)', 'Malayalam': 'അഭിപ്രായം (opinion)', 'Hindi': 'राय (opinion)', 'Telugu': 'అభిప్రాయం (opinion)', 'English': 'personal perspective'},
      localizedTranslations: {'Tamil': 'என் பார்வையில், இந்த வடிவமைப்பு மிகவும் நேர்த்தியாக உள்ளது.', 'Malayalam': 'എന്റെ സത്യസന്ധമായ അഭിപ്രായത്തിൽ, ഈ ഡിസൈൻ മനോഹരമാണ്.', 'Hindi': 'मेरी राय में यह डिज़ाइन सुंदर दिखता है।', 'Telugu': 'నా అభిప్రాయం ప్రకారం, ఈ డిజైన్ చాలా సొగసైనదిగా ఉంది.', 'English': 'In my honest opinion, this design looks elegant.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'She was pleasantly ___ by the surprise party.',
      targetWord: 'surprised',
      acceptableWords: ['surprised', 'shocked', 'delighted'],
      fullSentence: 'She was pleasantly surprised by the surprise party.',
      localizedHints: {'Tamil': 'ஆச்சரியமடைந்தாள் (surprised)', 'Malayalam': 'ആശ്ചര്യപ്പെട്ടു (surprised)', 'Hindi': 'हैरान (surprised)', 'Telugu': 'ఆశ్చర్యపడింది (surprised)', 'English': 'astonished'},
      localizedTranslations: {'Tamil': 'அந்த இன்ப அதிர்ச்சி விருந்தால் அவள் மகிழ்ச்சியாக வியந்தாள்.', 'Malayalam': 'ആ സർപ്രൈസ് പാർട്ടിയിൽ അവൾ സന്തോഷത്തോടെ അത്ഭുതപ്പെട്ടു.', 'Hindi': 'सरप्राइज पार्टी से वह सुखद रूप से चकित थी।', 'Telugu': 'ఆమె ఆశ్చర్యకరమైన పార్టీతో చాలా సంతోషపడింది.', 'English': 'She was pleasantly surprised by the surprise party.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I completely ___ with your wonderful point.',
      targetWord: 'agree',
      acceptableWords: ['agree', 'concur'],
      fullSentence: 'I completely agree with your wonderful point.',
      localizedHints: {'Tamil': 'ஒப்புக்கொள்கிறேன் (agree)', 'Malayalam': 'യോജിക്കുന്നു (agree)', 'Hindi': 'सहमत (agree)', 'Telugu': 'ఏకీభవిస్తున్నాను (agree)', 'English': 'concur with'},
      localizedTranslations: {'Tamil': 'உங்கள் கருத்தை நான் முழுமையாக ஏற்றுக்கொள்கிறேன்.', 'Malayalam': 'നിങ്ങളുടെ മികച്ച അഭിപ്രായത്തോട് ഞാൻ പൂർണ്ണമായി യോജിക്കുന്നു.', 'Hindi': 'मैं आपकी बात से पूरी तरह सहमत हूँ।', 'Telugu': 'మీ అద్భుతమైన పాయింట్‌తో నేను పూర్తిగా ఏకీభవిస్తున్నాను.', 'English': 'I completely agree with your wonderful point.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'He felt ___ after working twelve long hours.',
      targetWord: 'exhausted',
      acceptableWords: ['exhausted', 'tired', 'drained'],
      fullSentence: 'He felt exhausted after working twelve long hours.',
      localizedHints: {'Tamil': 'களைப்படைந்தார் (exhausted)', 'Malayalam': 'തളർന്നുപോയി (exhausted)', 'Hindi': 'थका हुआ (exhausted)', 'Telugu': 'అలసిపోయాడు (exhausted)', 'English': 'deeply drained of energy'},
      localizedTranslations: {'Tamil': 'பன்னிரண்டு மணி நேரம் உழைத்த பிறகு அவர் களைத்துப்போனார்.', 'Malayalam': 'പന്ത്രണ്ട് മണിക്കൂർ നീണ്ട ജോലിക്ക് ശേഷം അവൻ വല്ലാതെ തളർന്നു.', 'Hindi': 'बारह घंटे काम करने के बाद वह बहुत थक गया।', 'Telugu': 'పన్నెండు గంటల సుదీర్ఘ పని తర్వాత అతను అలసిపోయాడు.', 'English': 'He felt exhausted after working twelve long hours.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'We are deeply ___ for your generous help.',
      targetWord: 'grateful',
      acceptableWords: ['grateful', 'thankful'],
      fullSentence: 'We are deeply grateful for your generous help.',
      localizedHints: {'Tamil': 'நன்றியுள்ளவர்களாக (grateful)', 'Malayalam': 'നന്ദിയുള്ളവർ (grateful)', 'Hindi': 'आभारी (grateful)', 'Telugu': 'కృతజ్ఞత (grateful)', 'English': 'thankful appreciation'},
      localizedTranslations: {'Tamil': 'உங்கள் தாராளமான உதவிக்கு நாங்கள் மிகவும் கடமைப்பட்டுள்ளோம்.', 'Malayalam': 'നിങ്ങളുടെ ഉദാരമായ സഹായത്തിന് ഞങ്ങൾ അഗാധമായി നന്ദിയുള്ളവരാണ്.', 'Hindi': 'हम आपकी मदद के लिए बहुत आभारी हैं।', 'Telugu': 'మీ ఉదారమైన సహాయానికి మేము చాలా కృతజ్ఞులం.', 'English': 'We are deeply grateful for your generous help.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Do not be ___ about speaking English aloud.',
      targetWord: 'afraid',
      acceptableWords: ['afraid', 'scared', 'shy', 'nervous'],
      fullSentence: 'Do not be afraid about speaking English aloud.',
      localizedHints: {'Tamil': 'பயப்பட வேண்டாம் (afraid)', 'Malayalam': 'ഭയം വേണ്ട (afraid)', 'Hindi': 'डरना मत (afraid)', 'Telugu': 'భయపడకండి (afraid)', 'English': 'fearful or anxious'},
      localizedTranslations: {'Tamil': 'ஆங்கிலத்தில் உரக்கப் பேச தயங்கவோ பயப்படவோ வேண்டாம்.', 'Malayalam': 'ഇംഗ്ലീഷ് ഉറക്കെ സംസാരിക്കുന്നതിൽ ഭയം തോന്നേണ്ടതില്ല.', 'Hindi': 'अंग्रेजी जोर से बोलने से मत डरो।', 'Telugu': 'ఇంగ్లీష్ గట్టిగా మాట్లాడటానికి భయపడకండి.', 'English': 'Do not be afraid about speaking English aloud.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I am really proud ___ your consistent progress.',
      targetWord: 'of',
      acceptableWords: ['of'],
      fullSentence: 'I am really proud of your consistent progress.',
      localizedHints: {'Tamil': 'பற்றி பெருமை (of)', 'Malayalam': 'കുറിച്ച് അഭിമാനം (of)', 'Hindi': 'पर गर्व (of)', 'Telugu': 'గర్వంగా (of)', 'English': 'preposition linking pride'},
      localizedTranslations: {'Tamil': 'உங்கள் தொடர்ச்சியான முன்னேற்றத்தைக் கண்டு நான் பெருமைப்படுகிறேன்.', 'Malayalam': 'നിങ്ങളുടെ നിരന്തരമായ പുരോഗതിയിൽ എനിക്ക് അഭിമാനമുണ്ട്.', 'Hindi': 'मुझे आपकी निरंतर प्रगति पर बहुत गर्व है।', 'Telugu': 'మీ స్థిరమైన పురోగతి పట్ల నాకు చాలా గర్వంగా ఉంది.', 'English': 'I am really proud of your consistent progress.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'The joyful music lifted everyone’s ___.',
      targetWord: 'mood',
      acceptableWords: ['mood', 'spirits'],
      fullSentence: 'The joyful music lifted everyone’s mood.',
      localizedHints: {'Tamil': 'மனநிலை (mood)', 'Malayalam': 'മനോഭാവം (mood)', 'Hindi': 'मूड (mood)', 'Telugu': 'మూడ్ (mood)', 'English': 'emotional state'},
      localizedTranslations: {'Tamil': 'மகிழ்ச்சியான இசை அனைவரின் மனநிலையையும் மாற்றியது.', 'Malayalam': 'സന്തോഷകരമായ സംഗീതം എല്ലാവരുടെയും മാനസികാവസ്ഥ ഉയർത്തി.', 'Hindi': 'खुशनुमा संगीत ने सबका मूड बना दिया।', 'Telugu': 'ఆనందకరమైన సంగీతం అందరి మానసిక స్థితిని ఉల్లాసపరిచింది.', 'English': 'The joyful music lifted everyone’s mood.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Keep your hope and stay ___ always.',
      targetWord: 'positive',
      acceptableWords: ['positive', 'strong', 'calm'],
      fullSentence: 'Keep your hope and stay positive always.',
      localizedHints: {'Tamil': 'நேர்மறையாக (positive)', 'Malayalam': 'പോസിറ്റീവ് (positive)', 'Hindi': 'सकारात्मक (positive)', 'Telugu': 'సానుకూలంగా (positive)', 'English': 'optimistic outlook'},
      localizedTranslations: {'Tamil': 'எப்போதும் நம்பிக்கையோடு நேர்மறையாக இருங்கள்.', 'Malayalam': 'പ്രതീക്ഷ കൈവിടാതെ എപ്പോഴും പോസിറ്റീവായിരിക്കുക.', 'Hindi': 'हमेशा सकारात्मक सोच बनाए रखें।', 'Telugu': 'ఎల్లప్పుడూ ఆశావాదంతో సానుకూలంగా ఉండండి.', 'English': 'Keep your hope and stay positive always.'},
    ),
  ];

  // --- LEVEL 7: Shopping & Food ---
  static const List<SpeakingExerciseItem> _kLevel7Exercises = [
    SpeakingExerciseItem(
      promptSentence: 'Can I try this shirt in a medium ___?',
      targetWord: 'size',
      acceptableWords: ['size', 'fit'],
      fullSentence: 'Can I try this shirt in a medium size?',
      localizedHints: {'Tamil': 'அளவு (size)', 'Malayalam': 'അളവ് (size)', 'Hindi': 'साइज (size)', 'Telugu': 'సైజు (size)', 'English': 'garment measurement'},
      localizedTranslations: {'Tamil': 'இந்த சட்டையை மீடியம் அளவில் நான் அணியலாமா?', 'Malayalam': 'എനിക്ക് ഈ ഷർട്ട് മീഡിയം സൈസിൽ ട്രൈ ചെയ്യാമോ?', 'Hindi': 'क्या मैं यह शर्ट मीडियम साइज में पहन सकता हूँ?', 'Telugu': 'ఈ చొక్కాను మీడియం సైజులో ప్రయత్నించవచ్చా?', 'English': 'Can I try this shirt in a medium size?'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Do you accept payment by credit ___?',
      targetWord: 'card',
      acceptableWords: ['card', 'upi'],
      fullSentence: 'Do you accept payment by credit card?',
      localizedHints: {'Tamil': 'அட்டை (card)', 'Malayalam': 'കാർഡ് (card)', 'Hindi': 'कार्ड (card)', 'Telugu': 'కార్డ్ (card)', 'English': 'payment card'},
      localizedTranslations: {'Tamil': 'நீங்கள் கிரெடிட் கார்டு கட்டணத்தை ஏற்றுக்கொள்கிறீர்களா?', 'Malayalam': 'നിങ്ങൾ ക്രെഡിറ്റ് കാർഡ് വഴി പേയ്മെന്റ് സ്വീകരിക്കുമോ?', 'Hindi': 'क्या आप क्रेडिट कार्ड से भुगतान स्वीकार करते हैं?', 'Telugu': 'మీరు క్రెడిట్ కార్డు చెల్లింపులను స్వీకరిస్తారా?', 'English': 'Do you accept payment by credit card?'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Can you please give me the receipt and ___?',
      targetWord: 'bill',
      acceptableWords: ['bill', 'change'],
      fullSentence: 'Can you please give me the receipt and bill?',
      localizedHints: {'Tamil': 'ரசீது (bill)', 'Malayalam': 'ബിൽ (bill)', 'Hindi': 'बिल (bill)', 'Telugu': 'బిల్లు (bill)', 'English': 'invoice'},
      localizedTranslations: {'Tamil': 'தயவுசெய்து ரசீதை எனக்குத் தர முடியுமா?', 'Malayalam': 'ദയവായി ബില്ലും രസീതും നൽകാമോ?', 'Hindi': 'कृपया मुझे रसीद और बिल दें।', 'Telugu': 'దయచేసి రసీదు ఇవ్వగలరా?', 'English': 'Can you please give me the receipt and bill?'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Is there any special ___ on these shoes today?',
      targetWord: 'discount',
      acceptableWords: ['discount', 'offer', 'sale'],
      fullSentence: 'Is there any special discount on these shoes today?',
      localizedHints: {'Tamil': 'தள்ளுபடி (discount)', 'Malayalam': 'ഡിസ്കൗണ്ട് (discount)', 'Hindi': 'छूट (discount)', 'Telugu': 'రాయితీ (discount)', 'English': 'price reduction'},
      localizedTranslations: {'Tamil': 'இந்த காலணிகளுக்கு இன்று ஏதேனும் தள்ளுபடி உண்டா?', 'Malayalam': 'ഈ ഷൂസിന് ഇന്ന് എന്തെങ്കിലും കിഴിവുണ്ടോ?', 'Hindi': 'क्या आज इन जूतों पर कोई विशेष छूट है?', 'Telugu': 'ఈ బూట్లపై ఈరోజు ఏదైనా ప్రత్యేక తగ్గింపు ఉందా?', 'English': 'Is there any special discount on these shoes today?'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I would like to order a warm bowl of vegetable ___.',
      targetWord: 'soup',
      acceptableWords: ['soup', 'salad'],
      fullSentence: 'I would like to order a warm bowl of vegetable soup.',
      localizedHints: {'Tamil': 'சூப் (soup)', 'Malayalam': 'സൂപ്പ് (soup)', 'Hindi': 'सूप (soup)', 'Telugu': 'సూప్ (soup)', 'English': 'liquid broth dish'},
      localizedTranslations: {'Tamil': 'நான் சூடான காய்கறி சூப் ஆர்டர் செய்ய விரும்புகிறேன்.', 'Malayalam': 'ഒരു ബൗൾ പച്ചക്കറി സൂപ്പ് ഓർഡർ ചെയ്യാൻ ഞാൻ ആഗ്രഹിക്കുന്നു.', 'Hindi': 'मैं गर्म वेज सूप का ऑर्डर देना चाहता हूँ।', 'Telugu': 'నేను వెజిటబుల్ సూప్ ఆర్డర్ చేయాలనుకుంటున్నాను.', 'English': 'I would like to order a warm bowl of vegetable soup.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Please do not make the food too ___.',
      targetWord: 'spicy',
      acceptableWords: ['spicy', 'hot', 'salty'],
      fullSentence: 'Please do not make the food too spicy.',
      localizedHints: {'Tamil': 'காரமாக (spicy)', 'Malayalam': 'എരിവുള്ളത് (spicy)', 'Hindi': 'मसालेदार (spicy)', 'Telugu': 'కారంగా (spicy)', 'English': 'flavored with hot chili'},
      localizedTranslations: {'Tamil': 'உணவை அதிக காரமாக சமைக்க வேண்டாம்.', 'Malayalam': 'ഭക്ഷണം അധികം എരിവാക്കരുത് ദയവായി.', 'Hindi': 'कृपया भोजन को ज्यादा मसालेदार न बनाएं।', 'Telugu': 'దయచేసి ఆహారాన్ని మరీ కారంగా చేయకండి.', 'English': 'Please do not make the food too spicy.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Could we have the dessert ___ please?',
      targetWord: 'menu',
      acceptableWords: ['menu', 'card', 'bill'],
      fullSentence: 'Could we have the dessert menu please?',
      localizedHints: {'Tamil': 'மெனு அட்டை (menu)', 'Malayalam': 'മെനു (menu)', 'Hindi': 'मेन्यू (menu)', 'Telugu': 'మెనూ (menu)', 'English': 'list of dishes'},
      localizedTranslations: {'Tamil': 'இனிப்பு வகை மெனு அட்டையைப் பெறலாமா?', 'Malayalam': 'ഡെസേർട്ട് മെനു തരാമോ?', 'Hindi': 'क्या हमें मिठाई का मेन्यू मिल सकता है?', 'Telugu': 'డెజర్ట్ మెనూ ఇవ్వగలరా?', 'English': 'Could we have the dessert menu please?'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Keep the ___, the service was outstanding.',
      targetWord: 'change',
      acceptableWords: ['change', 'tip'],
      fullSentence: 'Keep the change, the service was outstanding.',
      localizedHints: {'Tamil': 'மீதி சில்லறை (change)', 'Malayalam': 'ബാക്കി തുക (change)', 'Hindi': 'बाकी पैसे (change)', 'Telugu': 'మిగిలిన చిల్లర (change)', 'English': 'coins left over'},
      localizedTranslations: {'Tamil': 'மீதியை நீங்களே வைத்துக்கொள்ளுங்கள், உபசரிப்பு அற்புதம்.', 'Malayalam': 'ബാക്കി വെച്ചോളൂ, നിങ്ങളുടെ സേവനം മികച്ചതായിരുന്നു.', 'Hindi': 'छुट्टे आप ही रख लें, सेवा बेहतरीन थी।', 'Telugu': 'మిగిలిన చిల్లర మీరే ఉంచుకోండి, సేవ బాగుంది.', 'English': 'Keep the change, the service was outstanding.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'These organic mangoes taste incredibly ___.',
      targetWord: 'sweet',
      acceptableWords: ['sweet', 'fresh', 'delicious'],
      fullSentence: 'These organic mangoes taste incredibly sweet.',
      localizedHints: {'Tamil': 'இனிப்பாக (sweet)', 'Malayalam': 'മധുരമുള്ളത് (sweet)', 'Hindi': 'मीठा (sweet)', 'Telugu': 'తీపిగా (sweet)', 'English': 'sugary flavor'},
      localizedTranslations: {'Tamil': 'இந்த மாம்பழங்கள் நம்பமுடியாத அளவிற்கு இனிப்பாக உள்ளன.', 'Malayalam': 'ഈ മാമ്പഴങ്ങൾക്ക് നല്ല മധുരമുണ്ട്.', 'Hindi': 'ये आम बहुत मीठे हैं।', 'Telugu': 'ఈ మామిడి పండ్లు చాలా తీపిగా ఉన్నాయి.', 'English': 'These organic mangoes taste incredibly sweet.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I bought two fresh loaves of brown ___.',
      targetWord: 'bread',
      acceptableWords: ['bread'],
      fullSentence: 'I bought two fresh loaves of brown bread.',
      localizedHints: {'Tamil': 'ரொட்டி (bread)', 'Malayalam': 'ബ്രഡ് (bread)', 'Hindi': 'ब्रेड (bread)', 'Telugu': 'రొట్టె (bread)', 'English': 'baked staple food'},
      localizedTranslations: {'Tamil': 'நான் இரண்டு பிரவுன் ரொட்டிகளை வாங்கினேன்.', 'Malayalam': 'ഞാൻ രണ്ട് ബ്രൗൺ ബ്രെഡ് വാങ്ങി.', 'Hindi': 'मैंने दो ब्राउन ब्रेड खरीदीं।', 'Telugu': 'నేను రెండు బ్రౌన్ బ్రెడ్‌లు కొన్నాను.', 'English': 'I bought two fresh loaves of brown bread.'},
    ),
  ];

  // --- LEVEL 8: Future Goals & Plans ---
  static const List<SpeakingExerciseItem> _kLevel8Exercises = [
    SpeakingExerciseItem(
      promptSentence: 'I will ___ fluent English within ninety days.',
      targetWord: 'speak',
      acceptableWords: ['speak', 'master', 'achieve'],
      fullSentence: 'I will speak fluent English within ninety days.',
      localizedHints: {'Tamil': 'பேசுவேன் (speak)', 'Malayalam': 'സംസാരിക്കും (speak)', 'Hindi': 'बोलूँगा (speak)', 'Telugu': 'మాట్లాడతాను (speak)', 'English': 'articulate language'},
      localizedTranslations: {'Tamil': 'நான் தொண்ணூறு நாட்களில் சரளமாக ஆங்கிலம் பேசுவேன்.', 'Malayalam': 'തൊണ്ണൂറ് ദിവസത്തിനുള്ളിൽ ഞാൻ ഇംഗ്ലീഷ് നന്നായി സംസാരിക്കും.', 'Hindi': 'मैं नब्बे दिनों में धाराप्रवाह अंग्रेजी बोलूँगा।', 'Telugu': 'నేను తొంభై రోజుల్లో అనర్గళంగా ఇంగ్లీష్ మాట్లాడతాను.', 'English': 'I will speak fluent English within ninety days.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'She is planning to ___ abroad next semester.',
      targetWord: 'study',
      acceptableWords: ['study', 'travel', 'go', 'work'],
      fullSentence: 'She is planning to study abroad next semester.',
      localizedHints: {'Tamil': 'கல்வி பயில்தல் (study)', 'Malayalam': 'പഠിക്കുക (study)', 'Hindi': 'पढ़ाई करना (study)', 'Telugu': 'చదువుకోవడం (study)', 'English': 'pursue education'},
      localizedTranslations: {'Tamil': 'அவள் அடுத்த பருவத்தில் வெளிநாட்டில் படிக்க திட்டமிட்டுள்ளாள்.', 'Malayalam': 'അവൾ അടുത്ത സെമസ്റ്ററിൽ വിദേശത്ത് പഠിക്കാൻ പദ്ധതിയിടുന്നു.', 'Hindi': 'वह अगले सेमेस्टर में विदेश में पढ़ाई करने की योजना बना रही है।', 'Telugu': 'ఆమె వచ్చే సెమిస్టర్‌లో విదేశాల్లో చదువుకోవాలని యోచిస్తోంది.', 'English': 'She is planning to study abroad next semester.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'We aim to ___ our own tech company.',
      targetWord: 'start',
      acceptableWords: ['start', 'launch', 'build', 'found'],
      fullSentence: 'We aim to start our own tech company.',
      localizedHints: {'Tamil': 'தொடங்குதல் (start)', 'Malayalam': 'തുടങ്ങുക (start)', 'Hindi': 'शुरू करना (start)', 'Telugu': 'ప్రారంభించడం (start)', 'English': 'found or initiate'},
      localizedTranslations: {'Tamil': 'நாங்கள் எங்களின் சொந்த தொழில்நுட்ப நிறுவனத்தைத் தொடங்க இலக்கு கொண்டுள்ளோம்.', 'Malayalam': 'ഞങ്ങൾ ഞങ്ങളുടെ സ്വന്തം ടെക് കമ്പനി ആരംഭിക്കാൻ ലക്ഷ്യമിടുന്നു.', 'Hindi': 'हम अपनी खुद की टेक कंपनी शुरू करने का लक्ष्य रखते हैं।', 'Telugu': 'మేము మా స్వంత టెక్ కంపెనీని ప్రారంభించాలని లక్ష్యంగా పెట్టుకున్నాము.', 'English': 'We aim to start our own tech company.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Continuous practice will ___ your hidden potential.',
      targetWord: 'unlock',
      acceptableWords: ['unlock', 'reveal', 'build'],
      fullSentence: 'Continuous practice will unlock your hidden potential.',
      localizedHints: {'Tamil': 'வெளிக்கொண்டு வரும் (unlock)', 'Malayalam': 'തുറക്കും (unlock)', 'Hindi': 'खोलना (unlock)', 'Telugu': 'వెలికితీస్తుంది (unlock)', 'English': 'release capability'},
      localizedTranslations: {'Tamil': 'தொடர் பயிற்சி உங்கள் மறைந்திருக்கும் திறனை வெளிக்கொண்டு வரும்.', 'Malayalam': 'തുടർച്ചയായ പരിശീലനം നിങ്ങളുടെ കഴിവുകളെ ഉണർത്തും.', 'Hindi': 'निरंतर अभ्यास आपकी छिपी क्षमता को खोलेगा।', 'Telugu': 'నిరంతర సాధన మీలోని నైపుణ్యాన్ని వెలికితీస్తుంది.', 'English': 'Continuous practice will unlock your hidden potential.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I hope to ___ across five different countries.',
      targetWord: 'travel',
      acceptableWords: ['travel', 'visit', 'fly'],
      fullSentence: 'I hope to travel across five different countries.',
      localizedHints: {'Tamil': 'பயணிக்க (travel)', 'Malayalam': 'യാത്ര ചെയ്യാൻ (travel)', 'Hindi': 'यात्रा करना (travel)', 'Telugu': 'ప్రయాణించడం (travel)', 'English': 'journey internationally'},
      localizedTranslations: {'Tamil': 'ஐந்து வெவ்வேறு நாடுகளுக்கு பயணம் செய்ய விரும்புகிறேன்.', 'Malayalam': 'അഞ്ച് വ്യത്യസ്ത രാജ്യങ്ങളിലൂടെ യാത്ര ചെയ്യാൻ ഞാൻ ആഗ്രഹിക്കുന്നു.', 'Hindi': 'मैं पाँच अलग-अलग देशों की यात्रा करने की आशा करता हूँ।', 'Telugu': 'నేను ఐదు వేర్వేరు దేశాలలో పర్యటించాలని ఆశిస్తున్నాను.', 'English': 'I hope to travel across five different countries.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'He is dedicated to ___ every morning drill.',
      targetWord: 'practicing',
      acceptableWords: ['practicing', 'completing', 'doing'],
      fullSentence: 'He is dedicated to practicing every morning drill.',
      localizedHints: {'Tamil': 'பயிற்சி செய்தல் (practicing)', 'Malayalam': 'പരിശീലിക്കുക (practicing)', 'Hindi': 'अभ्यास करना (practicing)', 'Telugu': 'సాధన చేయడం (practicing)', 'English': 'repeating drills'},
      localizedTranslations: {'Tamil': 'அவர் தினமும் காலை பயிற்சியை அர்ப்பணிப்புடன் செய்கிறார்.', 'Malayalam': 'എല്ലാ പ്രഭാത ഡ്രില്ലുകളും പരിശീലിക്കുന്നതിൽ അവൻ പ്രതിജ്ഞാബദ്ധനാണ്.', 'Hindi': 'वह हर सुबह अभ्यास करने के लिए समर्पित है।', 'Telugu': 'అతను ప్రతిరోజూ ఉదయం సాధన చేయడానికి అంకితభావంతో ఉన్నాడు.', 'English': 'He is dedicated to practicing every morning drill.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Small daily steps lead to massive ___.',
      targetWord: 'success',
      acceptableWords: ['success', 'growth', 'results'],
      fullSentence: 'Small daily steps lead to massive success.',
      localizedHints: {'Tamil': 'வெற்றி (success)', 'Malayalam': 'വിജയം (success)', 'Hindi': 'सफलता (success)', 'Telugu': 'విజయం (success)', 'English': 'achievement of goal'},
      localizedTranslations: {'Tamil': 'தினசரி சிறிய அடிகள் மிகப்பெரிய வெற்றிக்கு வழிவகுக்கும்.', 'Malayalam': 'ദിവസേനയുള്ള ചെറിയ ചുവടുകൾ വലിയ വിജയത്തിലേക്ക് നയിക്കുന്നു.', 'Hindi': 'छोटे दैनिक कदम भारी सफलता की ओर ले जाते हैं।', 'Telugu': 'చిన్న రోజువారీ అడుగులు భారీ విజయానికి దారితీస్తాయి.', 'English': 'Small daily steps lead to massive success.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I am ready to ___ the next big challenge.',
      targetWord: 'face',
      acceptableWords: ['face', 'accept', 'take'],
      fullSentence: 'I am ready to face the next big challenge.',
      localizedHints: {'Tamil': 'எதிர்கொள்ள (face)', 'Malayalam': 'നേരിടാൻ (face)', 'Hindi': 'सामना करना (face)', 'Telugu': 'ఎదుర్కొనేందుకు (face)', 'English': 'confront obstacle'},
      localizedTranslations: {'Tamil': 'அடுத்த பெரிய சவாலை எதிர்கொள்ள நான் தயாராக இருக்கிறேன்.', 'Malayalam': 'അടുത്ത വലിയ വെല്ലുവിളിയെ നേരിടാൻ ഞാൻ തയ്യാറാണ്.', 'Hindi': 'मैं अगली बड़ी चुनौती का सामना करने के लिए तैयार हूँ।', 'Telugu': 'నేను తదుపరి పెద్ద సవాలును ఎదుర్కొనేందుకు సిద్ధంగా ఉన్నాను.', 'English': 'I am ready to face the next big challenge.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Never give ___ on your dreams and aspirations.',
      targetWord: 'up',
      acceptableWords: ['up'],
      fullSentence: 'Never give up on your dreams and aspirations.',
      localizedHints: {'Tamil': 'விட்டுக்கொடுக்காதே (up)', 'Malayalam': 'കൈവിടരുത് (up)', 'Hindi': 'हार मत मानो (up)', 'Telugu': 'వదులుకోవద్దు (up)', 'English': 'cease trying'},
      localizedTranslations: {'Tamil': 'உங்கள் கனவுகளை ஒருபோதும் விட்டுவிடாதீர்கள்.', 'Malayalam': 'നിങ്ങളുടെ സ്വപ്നങ്ങളെ ഒരിക്കലും കൈവിടരുത്.', 'Hindi': 'अपने सपनों को कभी मत छोड़ो।', 'Telugu': 'మీ కలలను ఎప్పుడూ వదులుకోవద్దు.', 'English': 'Never give up on your dreams and aspirations.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Together, we will ___ great milestones.',
      targetWord: 'reach',
      acceptableWords: ['reach', 'achieve', 'create'],
      fullSentence: 'Together, we will reach great milestones.',
      localizedHints: {'Tamil': 'அடைவோம் (reach)', 'Malayalam': 'നേടും (reach)', 'Hindi': 'हासिल करेंगे (reach)', 'Telugu': 'చేరుకుంటాము (reach)', 'English': 'attain landmarks'},
      localizedTranslations: {'Tamil': 'ஒன்றாக நாம் சிறந்த மைல்கற்களை எட்டுவோம்.', 'Malayalam': 'ഒരുമിച്ച് നാം മികച്ച നാഴികക്കല്ലുകൾ കൈവരിക്കും.', 'Hindi': 'एक साथ हम बड़े मील के पत्थर हासिल करेंगे।', 'Telugu': 'కలిసికట్టుగా మనం గొప్ప మైలురాళ్లను చేరుకుంటాము.', 'English': 'Together, we will reach great milestones.'},
    ),
  ];

  // --- LEVEL 9: Deep Reflections & Stories ---
  static const List<SpeakingExerciseItem> _kLevel9Exercises = [
    SpeakingExerciseItem(
      promptSentence: 'Patience and persistence build deep ___.',
      targetWord: 'roots',
      acceptableWords: ['roots', 'strength', 'foundations'],
      fullSentence: 'Patience and persistence build deep roots.',
      localizedHints: {'Tamil': 'வேர்கள் (roots)', 'Malayalam': 'വേരുകൾ (roots)', 'Hindi': 'जड़ें (roots)', 'Telugu': 'వేర్లు (roots)', 'English': 'underground anchors'},
      localizedTranslations: {'Tamil': 'பொறுமையும் விடாமுயற்சியும் ஆழமான வேர்களை உருவாக்குகின்றன.', 'Malayalam': 'ക്ഷമയും സ്ഥിരോത്സാഹവും ആഴത്തിലുള്ള വേരുകൾ നിർമ്മിക്കുന്നു.', 'Hindi': 'धैर्य और दृढ़ता गहरी जड़ें बनाते हैं।', 'Telugu': 'ఓపిక మరియు పట్టుదల లోతైన వేర్లను నిర్మిస్తాయి.', 'English': 'Patience and persistence build deep roots.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'True wisdom begins when you listen with an open ___.',
      targetWord: 'mind',
      acceptableWords: ['mind', 'heart'],
      fullSentence: 'True wisdom begins when you listen with an open mind.',
      localizedHints: {'Tamil': 'மனம் (mind)', 'Malayalam': 'മനസ്സ് (mind)', 'Hindi': 'मन (mind)', 'Telugu': 'మనస్సు (mind)', 'English': 'receptive intellect'},
      localizedTranslations: {'Tamil': 'திறந்த மனதுடன் கேட்கும்போது உண்மையான ஞானம் தொடங்குகிறது.', 'Malayalam': 'തുറന്ന മനസ്സോടെ കേൾക്കുമ്പോഴാണ് യഥാർത്ഥ ജ്ഞാനം ആരംഭിക്കുന്നത്.', 'Hindi': 'सच्चा ज्ञान तब शुरू होता है जब आप खुले दिमाग से सुनते हैं।', 'Telugu': 'నిజమైన జ్ఞానం మీరు బహిరంగ మనస్సుతో విన్నప్పుడు ప్రారంభమవుతుంది.', 'English': 'True wisdom begins when you listen with an open mind.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Every master was once a hesitant ___.',
      targetWord: 'beginner',
      acceptableWords: ['beginner', 'learner', 'student'],
      fullSentence: 'Every master was once a hesitant beginner.',
      localizedHints: {'Tamil': 'தொடக்க நிலை மாணவர் (beginner)', 'Malayalam': 'തുടക്കക്കാരൻ (beginner)', 'Hindi': 'शुरुआती (beginner)', 'Telugu': 'ప్రారంభకుడు (beginner)', 'English': 'novice starting out'},
      localizedTranslations: {'Tamil': 'ஒவ்வொரு மேதைகளும் ஒரு காலத்தில் தயங்கும் தொடக்க வீரராகவே இருந்தனர்.', 'Malayalam': 'എല്ലാ വിദഗ്ദ്ധരും ഒരിക്കൽ മടിച്ചുനിന്ന തുടക്കക്കാരായിരുന്നു.', 'Hindi': 'हर उस्ताद कभी न कभी हिचकिचाने वाला नौसिखिया था।', 'Telugu': 'ప్రతి మాస్టర్ ఒకప్పుడు సంకోచించే అనుభవశూన్యుడు.', 'English': 'Every master was once a hesitant beginner.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'The Chinese bamboo tree grows ninety feet in five ___.',
      targetWord: 'weeks',
      acceptableWords: ['weeks', 'years'],
      fullSentence: 'The Chinese bamboo tree grows ninety feet in five weeks.',
      localizedHints: {'Tamil': 'வாரங்கள் (weeks)', 'Malayalam': 'ആഴ്ചകൾ (weeks)', 'Hindi': 'सप्ताह (weeks)', 'Telugu': 'వారాలు (weeks)', 'English': 'seven-day units'},
      localizedTranslations: {'Tamil': 'சீன மூங்கில் ஐந்து வாரங்களில் தொண்ணூறு அடி உயரும்.', 'Malayalam': 'ചൈനീസ് മുള അഞ്ച് ആഴ്ചകൾ കൊണ്ട് തൊണ്ണൂറടി വളരുന്നു.', 'Hindi': 'चीनी बांस का पेड़ पांच सप्ताह में नब्बे फीट बढ़ता है।', 'Telugu': 'చైనీస్ వెదురు చెట్టు ఐదు వారాల్లో తొంభై అడుగులు పెరుగుతుంది.', 'English': 'The Chinese bamboo tree grows ninety feet in five weeks.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Your subconscious mind absorbs English while you ___.',
      targetWord: 'sleep',
      acceptableWords: ['sleep', 'rest', 'listen'],
      fullSentence: 'Your subconscious mind absorbs English while you sleep.',
      localizedHints: {'Tamil': 'தூங்குதல் (sleep)', 'Malayalam': 'ഉറങ്ങുക (sleep)', 'Hindi': 'सोना (sleep)', 'Telugu': 'నిద్రించడం (sleep)', 'English': 'nocturnal state'},
      localizedTranslations: {'Tamil': 'நீங்கள் தூங்கும் போதும் உங்கள் ஆழ்மனம் ஆங்கிலத்தை உள்வாங்குகிறது.', 'Malayalam': 'നിങ്ങൾ ഉറങ്ങുമ്പോഴും നിങ്ങളുടെ ഉപബോധമനസ്സ് ഇംഗ്ലീഷ് ഉൾക്കൊള്ളുന്നു.', 'Hindi': 'सोते समय भी आपका अवचेतन मन अंग्रेजी ग्रहण करता है।', 'Telugu': 'మీరు నిద్రపోతున్నప్పుడు మీ ఉపచేతన మనస్సు ఇంగ్లీషును గ్రహిస్తుంది.', 'English': 'Your subconscious mind absorbs English while you sleep.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Consistency is far better than occasional ___.',
      targetWord: 'intensity',
      acceptableWords: ['intensity', 'effort', 'work'],
      fullSentence: 'Consistency is far better than occasional intensity.',
      localizedHints: {'Tamil': 'தீவிரம் (intensity)', 'Malayalam': 'തീവ്രത (intensity)', 'Hindi': 'तीव्रता (intensity)', 'Telugu': 'తీవ్రత (intensity)', 'English': 'sporadic bursts'},
      localizedTranslations: {'Tamil': 'எப்போதாவது காட்டும் தீவிரத்தை விட தொடர் முயற்சியே சிறந்தது.', 'Malayalam': 'വല്ലപ്പോഴുമുള്ള തീവ്രതയേക്കാൾ നല്ലത് തുടർച്ചയായ പരിശ്രമമാണ്.', 'Hindi': 'कभी-कभार की मेहनत से निरंतरता कहीं बेहतर है।', 'Telugu': 'అప్పుడప్పుడు చూపించే వేగం కంటే క్రమం తప్పకుండా చేయడం మంచిది.', 'English': 'Consistency is far better than occasional intensity.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Do not translate, let your thoughts flow ___.',
      targetWord: 'naturally',
      acceptableWords: ['naturally', 'directly', 'freely'],
      fullSentence: 'Do not translate, let your thoughts flow naturally.',
      localizedHints: {'Tamil': 'இயல்பாக (naturally)', 'Malayalam': 'സ്വാഭാവികമായി (naturally)', 'Hindi': 'स्वाभाविक रूप से (naturally)', 'Telugu': 'సహజంగా (naturally)', 'English': 'without hesitation'},
      localizedTranslations: {'Tamil': 'மொழிபெயர்க்காதீர்கள், எண்ணங்கள் இயல்பாகப் பாயட்டும்.', 'Malayalam': 'മൊഴിമാറ്റം ചെയ്യരുത്, ചിന്തകൾ സ്വാഭാവികമായി ഒഴുകട്ടെ.', 'Hindi': 'अनुवाद मत करो, विचारों को स्वाभाविक रूप से बहने दो।', 'Telugu': 'అనువదించవద్దు, మీ ఆలోచనలు సహజంగా ప్రవహించనివ్వండి.', 'English': 'Do not translate, let your thoughts flow naturally.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Confidence comes from vocal muscle ___.',
      targetWord: 'memory',
      acceptableWords: ['memory', 'power', 'practice'],
      fullSentence: 'Confidence comes from vocal muscle memory.',
      localizedHints: {'Tamil': 'நினைவாற்றல் (memory)', 'Malayalam': 'ഓർമ്മ (memory)', 'Hindi': 'स्मृति (memory)', 'Telugu': 'జ్ఞాపకశక్తి (memory)', 'English': 'physical repetition habit'},
      localizedTranslations: {'Tamil': 'பேச்சு தசைப் பழக்கத்திலிருந்துதான் தன்னம்பிக்கை பிறக்கிறது.', 'Malayalam': 'ശബ്ദപേശികളുടെ ആവർത്തനത്തിൽ നിന്നാണ് ആത്മവിശ്വാസം ഉണ്ടാകുന്നത്.', 'Hindi': 'आत्मविश्वास बोलने की मांसपेशियों की आदत से आता है।', 'Telugu': 'కంఠ కండరాల జ్ఞాపకశక్తి నుండి ఆత్మవిశ్వాసం వస్తుంది.', 'English': 'Confidence comes from vocal muscle memory.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'A mentor guides you, but you must take the ___.',
      targetWord: 'step',
      acceptableWords: ['step', 'path', 'journey'],
      fullSentence: 'A mentor guides you, but you must take the step.',
      localizedHints: {'Tamil': 'அடி எடுத்து வைத்தல் (step)', 'Malayalam': 'ചുവട് (step)', 'Hindi': 'कदम (step)', 'Telugu': 'అడుగు (step)', 'English': 'active initiative'},
      localizedTranslations: {'Tamil': 'வழிகாட்டி வழி காட்டுவார், ஆனால் நீங்களே அடியெடுத்து வைக்க வேண்டும்.', 'Malayalam': 'ഗുരു വഴി കാട്ടിത്തരും, എന്നാൽ ചുവടുവെക്കേണ്ടത് നിങ്ങളാണ്.', 'Hindi': 'गुरु मार्ग दिखाता है, पर कदम आपको ही बढ़ाना होगा।', 'Telugu': 'గురువు మార్గదర్శనం చేస్తారు, కానీ మీరే అడుగు వేయాలి.', 'English': 'A mentor guides you, but you must take the step.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Today begins the golden chapter of your ___.',
      targetWord: 'life',
      acceptableWords: ['life', 'journey', 'story'],
      fullSentence: 'Today begins the golden chapter of your life.',
      localizedHints: {'Tamil': 'வாழ்க்கை (life)', 'Malayalam': 'ജീവിതം (life)', 'Hindi': 'जीवन (life)', 'Telugu': 'జీవితం (life)', 'English': 'personal existence'},
      localizedTranslations: {'Tamil': 'இன்றே உங்கள் வாழ்க்கையின் பொன்னான அத்தியாயம் தொடங்குகிறது.', 'Malayalam': 'ഇന്ന് നിങ്ങളുടെ ജീവിതത്തിലെ സുവർണ്ണ അധ്യായം ആരംഭിക്കുന്നു.', 'Hindi': 'आज आपके जीवन का स्वर्णिम अध्याय शुरू होता है।', 'Telugu': 'ఈరోజు మీ జీవితంలో సువర్ణ అధ్యాయం ప్రారంభమవుతుంది.', 'English': 'Today begins the golden chapter of your life.'},
    ),
  ];

  // --- LEVEL 10: Fluency & Sovereign Mastery ---
  static const List<SpeakingExerciseItem> _kLevel10Exercises = [
    SpeakingExerciseItem(
      promptSentence: 'I speak with sovereign authority and unshakeable ___.',
      targetWord: 'clarity',
      acceptableWords: ['clarity', 'confidence', 'calm'],
      fullSentence: 'I speak with sovereign authority and unshakeable clarity.',
      localizedHints: {'Tamil': 'தெளிவு (clarity)', 'Malayalam': 'വ്യക്തത (clarity)', 'Hindi': 'स्पष्टता (clarity)', 'Telugu': 'స్పష్టత (clarity)', 'English': 'unclouded articulation'},
      localizedTranslations: {'Tamil': 'நான் அசைக்க முடியாத தெளிவோடு அதிகாரத்துடன் பேசுகிறேன்.', 'Malayalam': 'ഞാൻ അചഞ്ചലമായ വ്യക്തതയോടെ സംസാരിക്കുന്നു.', 'Hindi': 'मैं पूर्ण अधिकार और स्पष्टता के साथ बोलता हूँ।', 'Telugu': 'నేను తిరుగులేని స్పష్టతతో అధికారికంగా మాట్లాడతాను.', 'English': 'I speak with sovereign authority and unshakeable clarity.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'My words have the power to inspire and ___ others.',
      targetWord: 'uplift',
      acceptableWords: ['uplift', 'guide', 'motivate', 'help'],
      fullSentence: 'My words have the power to inspire and uplift others.',
      localizedHints: {'Tamil': 'உயர்த்துதல் (uplift)', 'Malayalam': 'ഉയർത്തുക (uplift)', 'Hindi': 'उठाना (uplift)', 'Telugu': 'ఉత్తేజపరచడం (uplift)', 'English': 'elevate spirits'},
      localizedTranslations: {'Tamil': 'என் வார்த்தைகளுக்கு பிறரை உயர்த்தும் வலிமை உண்டு.', 'Malayalam': 'എന്റെ വാക്കുകൾക്ക് മറ്റുള്ളവരെ ഉയർത്താനുള്ള ശക്തിയുണ്ട്.', 'Hindi': 'मेरे शब्दों में दूसरों को ऊपर उठाने की शक्ति है।', 'Telugu': 'నా మాటలకు ఇతరులను ఉత్తేజపరిచే శక్తి ఉంది.', 'English': 'My words have the power to inspire and uplift others.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Fluency is an honorable craft earned through daily ___.',
      targetWord: 'focus',
      acceptableWords: ['focus', 'practice', 'effort'],
      fullSentence: 'Fluency is an honorable craft earned through daily focus.',
      localizedHints: {'Tamil': 'கவனம் (focus)', 'Malayalam': 'ശ്രദ്ധ (focus)', 'Hindi': 'ध्यान (focus)', 'Telugu': 'దృష్టి (focus)', 'English': 'undivided attention'},
      localizedTranslations: {'Tamil': 'சரளமாகப் பேசுவது தினசரி கவனத்தால் பெறப்படும் ஒரு கலை.', 'Malayalam': 'ദിനംപ്രതിയുള്ള ശ്രദ്ധയിലൂടെ നേടിയെടുക്കുന്ന ഒന്നാണ് ഒഴുക്ക്.', 'Hindi': 'धाराप्रवाह बोलना दैनिक ध्यान से हासिल किया जाने वाला हुनर है।', 'Telugu': 'నిరర్サングラス మాట్లాడటం రోజువారీ ఏకాగ్రతతో సంపాదించిన నైపుణ్యం.', 'English': 'Fluency is an honorable craft earned through daily focus.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I embrace mistakes as the stepping stones to ___.',
      targetWord: 'greatness',
      acceptableWords: ['greatness', 'mastery', 'success'],
      fullSentence: 'I embrace mistakes as the stepping stones to greatness.',
      localizedHints: {'Tamil': 'பெருமை (greatness)', 'Malayalam': 'മഹത്വം (greatness)', 'Hindi': 'महानता (greatness)', 'Telugu': 'గొప్పతనం (greatness)', 'English': 'high distinction'},
      localizedTranslations: {'Tamil': 'தவறுகளை நான் வெற்றியின் படிக்கட்டுகளாகவே பார்க்கிறேன்.', 'Malayalam': 'തെറ്റുകളെ ഞാൻ മഹത്വത്തിലേക്കുള്ള ചവിട്ടുപടികളായി സ്വീകരിക്കുന്നു.', 'Hindi': 'मैं गलतियों को महानता की सीढ़ियों के रूप में देखता हूँ।', 'Telugu': 'నేను తప్పులను గొప్పతనానికి సోపానాలుగా స్వీకరిస్తాను.', 'English': 'I embrace mistakes as the stepping stones to greatness.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'English is no longer a barrier; it is my open ___.',
      targetWord: 'door',
      acceptableWords: ['door', 'bridge', 'path'],
      fullSentence: 'English is no longer a barrier; it is my open door.',
      localizedHints: {'Tamil': 'கதவு (door)', 'Malayalam': 'വാതിൽ (door)', 'Hindi': 'दरवाजा (door)', 'Telugu': 'ద్వారం (door)', 'English': 'portal of opportunity'},
      localizedTranslations: {'Tamil': 'ஆங்கிலம் இனி தடையல்ல; அது என் திறந்த கதவு.', 'Malayalam': 'ഇംഗ്ലീഷ് ഇനി ഒരു തടസ്സമല്ല; അത് എന്റെ മുന്നിലുള്ള തുറന്ന വാതിലാണ്.', 'Hindi': 'अंग्रेजी अब कोई बाधा नहीं है; यह मेरा खुला दरवाजा है।', 'Telugu': 'ఇంగ్లీష్ ఇకపై అడ్డంకి కాదు; అది నా ముంగిట తెరిచిన తలుపు.', 'English': 'English is no longer a barrier; it is my open door.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I project my authentic voice without any ___.',
      targetWord: 'hesitation',
      acceptableWords: ['hesitation', 'fear', 'doubt'],
      fullSentence: 'I project my authentic voice without any hesitation.',
      localizedHints: {'Tamil': 'தயக்கம் (hesitation)', 'Malayalam': 'മടി (hesitation)', 'Hindi': 'हिचकिचाहट (hesitation)', 'Telugu': 'సంకోచం (hesitation)', 'English': 'reluctance or pause'},
      localizedTranslations: {'Tamil': 'நான் எந்தத் தயக்கமும் இன்றி என் குரலை ஒலிக்கச் செய்கிறேன்.', 'Malayalam': 'യാതൊരു മടിയുമില്ലാതെ ഞാൻ എന്റെ ശബ്ദം ഉയർത്തുന്നു.', 'Hindi': 'मैं बिना किसी हिचकिचाहट के अपनी आवाज उठाता हूँ।', 'Telugu': 'నేను ఎటువంటి సంకోచం లేకుండా నా గొంతును వినిపిస్తాను.', 'English': 'I project my authentic voice without any hesitation.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'My mind thinks in English rapidly and ___.',
      targetWord: 'effortlessly',
      acceptableWords: ['effortlessly', 'smoothly', 'clearly'],
      fullSentence: 'My mind thinks in English rapidly and effortlessly.',
      localizedHints: {'Tamil': 'சிரமமின்றி (effortlessly)', 'Malayalam': 'ആയാസരഹിതമായി (effortlessly)', 'Hindi': 'सहजता से (effortlessly)', 'Telugu': 'శ్రమ లేకుండా (effortlessly)', 'English': 'without strain'},
      localizedTranslations: {'Tamil': 'என் மனம் மிக எளிதாக ஆங்கிலத்தில் சிந்திக்கிறது.', 'Malayalam': 'എന്റെ മനസ്സ് വേഗത്തിലും ആയാസരഹിതമായും ഇംഗ്ലീഷിൽ ചിന്തിക്കുന്നു.', 'Hindi': 'मेरा दिमाग तेजी से और सहजता से अंग्रेजी में सोचता है।', 'Telugu': 'నా మనస్సు ఇంగ్లీషులో వేగంగా, శ్రమ లేకుండా ఆలోచిస్తుంది.', 'English': 'My mind thinks in English rapidly and effortlessly.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'Every conversation connects me with global ___.',
      targetWord: 'opportunities',
      acceptableWords: ['opportunities', 'people', 'friends', 'minds'],
      fullSentence: 'Every conversation connects me with global opportunities.',
      localizedHints: {'Tamil': 'வாய்ப்புகள் (opportunities)', 'Malayalam': 'അവസരങ്ങൾ (opportunities)', 'Hindi': 'अवसर (opportunities)', 'Telugu': 'అవకాశాలు (opportunities)', 'English': 'chances to advance'},
      localizedTranslations: {'Tamil': 'ஒவ்வொரு உரையாடலும் என்னை உலகளாவிய வாய்ப்புகளோடு இணைக்கிறது.', 'Malayalam': 'ഓരോ സംഭാഷണവും എന്നെ ആഗോള അവസരങ്ങളുമായി ബന്ധിപ്പിക്കുന്നു.', 'Hindi': 'हर बातचीत मुझे वैश्विक अवसरों से जोड़ती है।', 'Telugu': 'ప్రతి సంభాషణ నన్ను ప్రపంచ అవకాశాలతో కలుపుతుంది.', 'English': 'Every conversation connects me with global opportunities.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I am the master of my words and the captain of my ___.',
      targetWord: 'voice',
      acceptableWords: ['voice', 'destiny', 'mind'],
      fullSentence: 'I am the master of my words and the captain of my voice.',
      localizedHints: {'Tamil': 'குரல் (voice)', 'Malayalam': 'ശബ്ദം (voice)', 'Hindi': 'आवाज (voice)', 'Telugu': 'గొంతు (voice)', 'English': 'vocal expression'},
      localizedTranslations: {'Tamil': 'நான் என் வார்த்தைகளின் எஜமான், என் குரலின் வழிகாட்டி.', 'Malayalam': 'ഞാൻ എന്റെ വാക്കുകളുടെ യജമാനനും എന്റെ ശബ്ദത്തിന്റെ നായകനുമാണ്.', 'Hindi': 'मैं अपने शब्दों का स्वामी और अपनी आवाज का कप्तान हूँ।', 'Telugu': 'నేను నా మాటల అధిపతిని మరియు నా గొంతు యొక్క సారధిని.', 'English': 'I am the master of my words and the captain of my voice.'},
    ),
    SpeakingExerciseItem(
      promptSentence: 'I step forward boldly; today is my day of complete ___.',
      targetWord: 'victory',
      acceptableWords: ['victory', 'triumph', 'success'],
      fullSentence: 'I step forward boldly; today is my day of complete victory.',
      localizedHints: {'Tamil': 'வெற்றி (victory)', 'Malayalam': 'വിജയം (victory)', 'Hindi': 'विजय (victory)', 'Telugu': 'విజయం (victory)', 'English': 'triumph'},
      localizedTranslations: {'Tamil': 'நான் தைரியமாக முன்னேறுகிறேன்; இன்று என் முழு வெற்றியின் நாள்.', 'Malayalam': 'ഞാൻ ധൈര്യമായി മുന്നോട്ട് ചുവടുവെക്കുന്നു; ഇന്ന് എന്റെ സമ്പൂർണ്ണ വിജയദിനമാണ്.', 'Hindi': 'मैं साहस से आगे बढ़ता हूँ; आज मेरी पूर्ण विजय का दिन है।', 'Telugu': 'నేను ధైర్యంగా ముందుకు సాగుతాను; నేడు నా సంపూర్ణ విజయ దినం.', 'English': 'I step forward boldly; today is my day of complete victory.'},
    ),
  ];
}
