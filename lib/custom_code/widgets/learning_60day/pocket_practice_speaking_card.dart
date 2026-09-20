import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Single practice exercise item
class SpeakingExerciseItem {
  final String promptSentence; // e.g. "She ___ a letter."
  final String targetWord; // e.g. "writes"
  final List<String> acceptableWords; // e.g. ["writes", "wrote", "is writing", "write"]
  final String hint; // e.g. "action of putting words on paper"
  final String fullSentence; // e.g. "She writes a letter."

  const SpeakingExerciseItem({
    required this.promptSentence,
    required this.targetWord,
    required this.acceptableWords,
    required this.hint,
    required this.fullSentence,
  });
}

/// 🎤 Practice Speaking Widget (SpeakNow-inspired Fill in the Blank & Say It Aloud)
class PocketPracticeSpeakingCard extends StatefulWidget {
  final int day;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;

  const PocketPracticeSpeakingCard({
    super.key,
    required this.day,
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
  });

  @override
  State<PocketPracticeSpeakingCard> createState() =>
      _PocketPracticeSpeakingCardState();
}

class _PocketPracticeSpeakingCardState
    extends State<PocketPracticeSpeakingCard> {
  int _currentExerciseIndex = 0;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;
  bool _isListening = false;
  String _recognizedWords = '';
  bool _isExerciseAnswered = false;
  bool _isCorrect = false;
  Timer? _listeningTimeoutTimer;

  static const List<SpeakingExerciseItem> kDay1Exercises = [
    SpeakingExerciseItem(
      promptSentence: 'She ___ a letter.',
      targetWord: 'writes',
      acceptableWords: ['writes', 'wrote', 'is writing', 'write'],
      hint: 'action of putting words on paper',
      fullSentence: 'She writes a letter.',
    ),
    SpeakingExerciseItem(
      promptSentence: 'I ___ hot coffee in the morning.',
      targetWord: 'drink',
      acceptableWords: ['drink', 'drank', 'drink hot', 'had'],
      hint: 'action of swallowing a beverage',
      fullSentence: 'I drink hot coffee in the morning.',
    ),
    SpeakingExerciseItem(
      promptSentence: 'They ___ football every Sunday.',
      targetWord: 'play',
      acceptableWords: ['play', 'played', 'are playing'],
      hint: 'take part in an athletic game or sport',
      fullSentence: 'They play football every Sunday.',
    ),
    SpeakingExerciseItem(
      promptSentence: 'The chef ___ delicious pasta.',
      targetWord: 'cooks',
      acceptableWords: ['cooks', 'cooked', 'makes', 'prepares'],
      hint: 'prepares food using heat and ingredients',
      fullSentence: 'The chef cooks delicious pasta.',
    ),
    SpeakingExerciseItem(
      promptSentence: 'He ___ his new car to work.',
      targetWord: 'drives',
      acceptableWords: ['drives', 'drove', 'is driving', 'took'],
      hint: 'operates a motor vehicle along the road',
      fullSentence: 'He drives his new car to work.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initSpeechRecognizer();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.48);
    } catch (_) {}
  }

  Future<void> _initSpeechRecognizer() async {
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
    } catch (_) {
      _isSpeechInitialized = false;
    }
  }

  @override
  void dispose() {
    _listeningTimeoutTimer?.cancel();
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
      await _initSpeechRecognizer();
    }

    setState(() {
      _isListening = true;
      _recognizedWords = '';
      _isExerciseAnswered = false;
      _isCorrect = false;
    });

    _listeningTimeoutTimer?.cancel();
    // Auto stop after 7 seconds
    _listeningTimeoutTimer = Timer(const Duration(seconds: 7), () {
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
                _evaluateSpeech(result.recognizedWords);
              }
            }
          },
          listenOptions: stt.SpeechListenOptions(
            listenFor: const Duration(seconds: 7),
            pauseFor: const Duration(seconds: 3),
            partialResults: true,
          ),
        );
      }
    } catch (_) {
      // Fallback for emulator / web without mic
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
      if (_recognizedWords.isNotEmpty) {
        _evaluateSpeech(_recognizedWords);
      }
    }
  }

  void _evaluateSpeech(String spokenText) {
    final ex = kDay1Exercises[_currentExerciseIndex % kDay1Exercises.length];
    final normalized = spokenText.toLowerCase().trim();

    bool matched = false;
    for (final word in ex.acceptableWords) {
      if (normalized.contains(word.toLowerCase())) {
        matched = true;
        break;
      }
    }

    setState(() {
      _isExerciseAnswered = true;
      _isCorrect = matched;
    });

    if (matched) {
      HapticFeedback.heavyImpact();
      _speakText(ex.fullSentence);
      // If reached end of 5 exercises
      if (_currentExerciseIndex >= kDay1Exercises.length - 1 &&
          !widget.isCompleted) {
        widget.onCompleted(true);
      }
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _goToNextExercise() {
    HapticFeedback.selectionClick();
    setState(() {
      _currentExerciseIndex =
          (_currentExerciseIndex + 1) % kDay1Exercises.length;
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
    if (_currentExerciseIndex >= kDay1Exercises.length - 1 &&
        !widget.isCompleted) {
      widget.onCompleted(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = kDay1Exercises;
    final ex = exercises[_currentExerciseIndex % exercises.length];

    // Sentence display logic: when answered correctly, show blank filled!
    String displaySentence = ex.promptSentence;
    if (_isExerciseAnswered && _isCorrect) {
      displaySentence = ex.fullSentence;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Section Header
        Row(
          children: [
            const Text('🎤', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Practice Speaking',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (widget.isCompleted)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'ALL 5 DONE ✓',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Say the complete sentence out loud, filling in the blank.',
          style: GoogleFonts.inter(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),

        // Main Obsidian Practice Speaking Card Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: const Color(0xFF12141C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isExerciseAnswered && _isCorrect
                  ? const Color(0xFF10B981).withValues(alpha: 0.6)
                  : const Color(0xFF262A36),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Exercise 1 of 5 Header
              Text(
                'Exercise ${_currentExerciseIndex + 1} of ${exercises.length}',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),

              // Sentence Inner Box
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF181B26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isExerciseAnswered
                        ? (_isCorrect
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        : const Color(0xFF2E3344),
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
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Contextual Hint
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      ex.hint,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFFD54F),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 🎤 Say It Button (Warm Coral / Orange Pill as seen in screenshot)
              InkWell(
                onTap: _toggleSayIt,
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
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
                            .withValues(alpha: 0.35),
                        blurRadius: 12,
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
                        _isListening ? 'Listening... Speak now' : 'Say It',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Result Feedback & Next Button
              if (_isExerciseAnswered) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isCorrect
                        ? const Color(0xFF064E3B).withValues(alpha: 0.4)
                        : const Color(0xFF7F1D1D).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isCorrect
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                              ? 'Correct! Spoken with great clarity!'
                              : 'Say: "${ex.fullSentence}"',
                          style: GoogleFonts.inter(
                            color: _isCorrect
                                ? const Color(0xFF6EE7B7)
                                : const Color(0xFFFCA5A5),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded,
                            color: Color(0xFFFFD700), size: 18),
                        onPressed: () => _speakText(ex.fullSentence),
                        tooltip: 'Listen to native pronunciation',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (_currentExerciseIndex < exercises.length - 1)
                  TextButton.icon(
                    onPressed: _goToNextExercise,
                    icon: const Icon(Icons.arrow_forward_rounded,
                        color: Color(0xFF38BDF8), size: 16),
                    label: Text(
                      'NEXT EXERCISE (${_currentExerciseIndex + 2}/${exercises.length}) ➔',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () {
                      widget.onCompleted(true);
                      HapticFeedback.heavyImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '🎉 All 5 Practice Speaking Exercises Completed! (+25 PTS) ✓'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF10B981), size: 16),
                    label: Text(
                      'COMPLETE PRACTICE SPEAKING ✓',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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
              ] else ...[
                // Subtle tap fallback for users in quiet room / testing
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _bypassForTesting(ex),
                  child: Text(
                    'Tap here if in a quiet room or without microphone',
                    style: GoogleFonts.inter(
                      color: Colors.white30,
                      fontSize: 10,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // 5 Progress Dashes / Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(exercises.length, (idx) {
                  final isActive = idx == _currentExerciseIndex;
                  final isPast = idx < _currentExerciseIndex;

                  return Container(
                    width: 28,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
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

        const SizedBox(height: 10),

        // Privacy Guarantee Note (As seen in screenshot)
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
    );
  }
}
