import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Model for 12 Tenses Speaking Exercise
class TenseExerciseItem {
  final String tenseName;
  final String formula;
  final String promptSentence;
  final String targetWord;
  final List<String> acceptableWords;
  final String fullSentence;
  final Map<String, String> localizedHints;
  final Map<String, String> localizedTranslations;

  const TenseExerciseItem({
    required this.tenseName,
    required this.formula,
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

/// ⏰ 12 Tenses Speaking Practice Card
/// Fully interactive card dedicated to mastering the 12 English Tenses through
/// vocal speaking drills with "Say It", instant feedback, retry, and step tracking.
class Pocket12TensesPracticeCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const Pocket12TensesPracticeCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '6',
  });

  @override
  State<Pocket12TensesPracticeCard> createState() =>
      _Pocket12TensesPracticeCardState();
}

class _Pocket12TensesPracticeCardState extends State<Pocket12TensesPracticeCard>
    with SingleTickerProviderStateMixin {
  int _currentExerciseIndex = 0;
  String _activeFilter = 'ALL'; // 'ALL', 'PRESENT', 'PAST', 'FUTURE'
  bool _showOverviewTable = false;

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
    final exercises = _filteredExercises;
    if (exercises.isEmpty) return;
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

  List<TenseExerciseItem> get _filteredExercises {
    switch (_activeFilter) {
      case 'PRESENT':
        return _kTenseExercises.sublist(0, 4);
      case 'PAST':
        return _kTenseExercises.sublist(4, 8);
      case 'FUTURE':
        return _kTenseExercises.sublist(8, 12);
      case 'ALL':
      default:
        return _kTenseExercises;
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

  void _goToNextExercise() {
    final list = _filteredExercises;
    HapticFeedback.selectionClick();
    setState(() {
      _currentExerciseIndex = (_currentExerciseIndex + 1) % list.length;
      _isExerciseAnswered = false;
      _isCorrect = false;
      _recognizedWords = '';
    });
  }

  void _goToPreviousExercise() {
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

  void _bypassForTesting(TenseExerciseItem ex) {
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
    final exercises = _filteredExercises;
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
        color: const Color(0xFF0A0E17), // Minimal, plain dark game canvas
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFFFF9100).withValues(alpha: 0.4),
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFFF9100))
                .withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                    colors: [Color(0xFFFF9100), Color(0xFFFF5252)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.stepNumber.isNotEmpty
                      ? 'STEP ${widget.stepNumber} • TENSES'
                      : 'TENSES GAME',
                  style: const TextStyle(
                    color: Colors.white,
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
                  'DRILL ${_currentExerciseIndex + 1}/${exercises.length}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFB74D),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              // Quick Side Navigation in HUD
              InkWell(
                onTap: _goToPreviousExercise,
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
                onTap: _goToNextExercise,
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
                          ? '🎉 12 Tenses Speaking Completed! (+25 PTS) ✓'
                          : '12 Tenses Speaking marked as pending'),
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
            '12 Tenses Speaking Mastery ⏰',
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
              color: const Color(0xFFFFB74D),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
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

          // Tense Category Filter Tabs
          Row(
            children: [
              _buildFilterTab('ALL (12)', 'ALL'),
              const SizedBox(width: 6),
              _buildFilterTab('PRESENT (4)', 'PRESENT'),
              const SizedBox(width: 6),
              _buildFilterTab('PAST (4)', 'PAST'),
              const SizedBox(width: 6),
              _buildFilterTab('FUTURE (4)', 'FUTURE'),
            ],
          ),
          const SizedBox(height: 10),

          // Quick Matrix Toggle Button
          InkWell(
            onTap: () =>
                setState(() => _showOverviewTable = !_showOverviewTable),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.table_chart_rounded,
                      color: Color(0xFFFFD700), size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _showOverviewTable
                          ? 'Hide 12 Tenses Matrix Table ▲'
                          : 'Show 12 Tenses Matrix (Formulas & Examples) ▼',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Overview Table
          if (_showOverviewTable) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF13172A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: _kTenseExercises.map((t) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 130,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            t.tenseName,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF38BDF8),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            t.fullSentence,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Main Speaking Box
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
                // Top Meta: Tense Name Badge + Formula + Speaker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${ex.tenseName.toUpperCase()} (${_currentExerciseIndex + 1}/${exercises.length})',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFF59E0B),
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

                // Formula Label
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Form: ${ex.formula}',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

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

                // Hint
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

                // 🎤 Say It Button with Pulse
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
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFF59E0B))
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

                // Feedback & Written Correct Sentence
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
                                    ? '🎉 Correct! Spoken with authentic tense mastery!'
                                    : 'Almost! Target verb: "${ex.targetWord}"',
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
                            : 'RESTART TENSES ➔',
                        style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
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

                // Progress Dashes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(exercises.length, (idx) {
                    final isActive = idx == _currentExerciseIndex;
                    final isPast = idx < _currentExerciseIndex;

                    return Container(
                      width: exercises.length > 8 ? 16 : 24,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFF59E0B)
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

          // Complete Button
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
                        ? '🎉 12 Tenses Speaking Completed! (+25 PTS) ✓'
                        : '12 Tenses Speaking marked as pending'),
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
                    ? '12 TENSES PRACTICE COMPLETED ✓'
                    : 'MARK 12 TENSES PRACTICE COMPLETE ✓',
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
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String filter) {
    final isSel = _activeFilter == filter;
    return Expanded(
      child: InkWell(
        onTap: () => _setFilter(filter),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFF59E0B) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSel ? const Color(0xFFF59E0B) : Colors.white12,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSel ? Colors.black : Colors.white70,
                fontSize: 10,
                fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedSubtitle(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return '12 காலங்கள் பேச்சுப் பயிற்சி';
      case 'telugu':
        return '12 కాలాలు మాట్లాడే సాధన';
      case 'hindi':
        return '12 काल बोलने का अभ्यास';
      case 'kannada':
        return '12 ಕಾಲಗಳು ಮಾತನಾಡುವ ಅಭ್ಯಾಸ';
      case 'malayalam':
        return '12 ടെൻസുകൾ സംസാര പരിശീലനം';
      default:
        return 'Tenses Speaking Mastery';
    }
  }

  String _getInstructionText(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return '3 காலங்கள் × 4 நிலைகள் = 12 காலங்கள். விடுபட்ட வினைச்சொல்லை நிரப்பி உரக்கப் பேசுங்கள்.';
      case 'telugu':
        return '3 కాలాలు × 4 స్థితులు = 12 కాలాలు. ఖాళీని సరైన క్రియతో పూరిస్తూ బిగ్గరగా పలకండి.';
      case 'hindi':
        return '3 काल × 4 रूप = 12 काल। क्रिया का सही रूप भरकर वाक्य जोर से बोलें।';
      case 'kannada':
        return '3 ಕಾಲಗಳು × 4 ರೂಪಗಳು = 12 ಕಾಲಗಳು. ಸರಿಯಾದ ಕ್ರಿಯಾಪದ ತುಂಬಿ ವಾಕ್ಯವನ್ನು ಜೋರಾಗಿ ಮಾತನಾಡಿ.';
      case 'malayalam':
        return '3 സമയങ്ങൾ × 4 രൂപങ്ങൾ = 12 ടെൻസുകൾ. വിടവ് നികത്തി പൂർണ്ണ വാചകം ഉറക്കെ പറയുക.';
      default:
        return '3 time frames × 4 aspects = 12 tenses. Fill in the correct verb form and say it aloud.';
    }
  }

  // --- 12 MASTER TENSES EXERCISES ---
  static const List<TenseExerciseItem> _kTenseExercises = [
    // 1. Present Simple
    TenseExerciseItem(
      tenseName: 'Present Simple',
      formula: 'subject + base verb (+s/es for he/she/it)',
      promptSentence: 'She ___ (go) to school every day.',
      targetWord: 'goes',
      acceptableWords: ['goes', 'goes to', 'go'],
      fullSentence: 'She goes to school every day.',
      localizedHints: {
        'Tamil': 'வழக்கமான செயல்: he/she/it-க்கு வினைச்சொல்லுடன் -s/-es சேர்க்கவும் (goes)',
        'Malayalam': 'പതിവ് ശീലം: he/she/it വരുമ്പോൾ ക്രിയയോടൊപ്പം -s/-es ചേർക്കുക (goes)',
        'Hindi': 'दैनिक आदत: he/she/it के साथ verb में -s/-es लगाएं (goes)',
        'Telugu': 'దినచర్య: he/she/it తో క్రియకు -s/-es జోడించండి (goes)',
        'English': 'habitual routine: base verb + s/es for third person singular',
      },
      localizedTranslations: {
        'Tamil': 'அவள் தினமும் பள்ளிக்குச் செல்கிறாள்.',
        'Malayalam': 'അവൾ എല്ലാ ദിവസവും സ്കൂളിൽ പോകുന്നു.',
        'Hindi': 'वह रोज स्कूल जाती है।',
        'Telugu': 'ఆమె ప్రతిరోజూ బడికి వెళ్తుంది.',
        'English': 'She goes to school every day.',
      },
    ),

    // 2. Present Continuous
    TenseExerciseItem(
      tenseName: 'Present Continuous',
      formula: 'subject + am/is/are + verb-ing',
      promptSentence: 'I ___ (read) a book right now.',
      targetWord: 'am reading',
      acceptableWords: ['am reading', 'reading'],
      fullSentence: 'I am reading a book right now.',
      localizedHints: {
        'Tamil': 'இப்போது நடக்கும் செயல்: am/is/are + verb-ing (am reading)',
        'Malayalam': 'ഇപ്പോൾ നടക്കുന്ന പ്രവർത്തനം: am/is/are + verb-ing (am reading)',
        'Hindi': 'अभी हो रहा काम: am/is/are + verb-ing (am reading)',
        'Telugu': 'ప్రస్తుతం జరుగుతున్న పని: am/is/are + verb-ing (am reading)',
        'English': 'action happening right now: am/is/are + verb-ing',
      },
      localizedTranslations: {
        'Tamil': 'நான் இப்போது ஒரு புத்தகம் படித்துக்கொண்டிருக்கிறேன்.',
        'Malayalam': 'ഞാൻ ഇപ്പോൾ ഒരു പുസ്തകം വായിക്കുകയാണ്.',
        'Hindi': 'मैं अभी एक किताब पढ़ रहा हूँ।',
        'Telugu': 'నేను ప్రస్తుతం ఒక పుస్తకం చదువుతున్నాను.',
        'English': 'I am reading a book right now.',
      },
    ),

    // 3. Present Perfect
    TenseExerciseItem(
      tenseName: 'Present Perfect',
      formula: 'subject + have/has + past participle (V3)',
      promptSentence: 'I ___ (lose) my house keys.',
      targetWord: 'have lost',
      acceptableWords: ['have lost', 'lost'],
      fullSentence: 'I have lost my house keys.',
      localizedHints: {
        'Tamil': 'கடந்த காலத்தில் நிகழ்ந்து இப்போது தாக்கம் தரும் செயல்: have/has + V3 (have lost)',
        'Malayalam': 'കഴിഞ്ഞുപോയതും ഇപ്പോൾ പ്രസക്തവുമായ കാര്യം: have/has + V3 (have lost)',
        'Hindi': 'भूतकाल में हुआ कार्य जिसका प्रभाव अभी है: have/has + V3 (have lost)',
        'Telugu': 'గతంలో జరిగి ప్రస్తుతం ఫలితం ఉన్న పని: have/has + V3 (have lost)',
        'English': 'past action with a present result: have/has + V3',
      },
      localizedTranslations: {
        'Tamil': 'நான் என் வீட்டின் சாவிகளை தொலைத்துவிட்டேன்.',
        'Malayalam': 'എന്റെ വീടിന്റെ താക്കോലുകൾ എനിക്ക് നഷ്ടപ്പെട്ടു.',
        'Hindi': 'मैंने अपने घर की चाबियाँ खो दी हैं।',
        'Telugu': 'నేను నా ఇంటి తాళాలు పోగొట్టుకున్నాను.',
        'English': 'I have lost my house keys.',
      },
    ),

    // 4. Present Perfect Continuous
    TenseExerciseItem(
      tenseName: 'Present Perfect Continuous',
      formula: 'subject + have/has + been + verb-ing',
      promptSentence: 'It ___ (rain) all day long.',
      targetWord: 'has been raining',
      acceptableWords: ['has been raining', 'been raining'],
      fullSentence: 'It has been raining all day long.',
      localizedHints: {
        'Tamil': 'கடந்த காலத்தில் தொடங்கி இன்னும் தொடரும் செயல்: has/have been + verb-ing',
        'Malayalam': 'നേരത്തെ തുടങ്ങി ഇപ്പോഴും തുടരുന്ന പ്രവർത്തനം: has/have been + verb-ing',
        'Hindi': 'पहले शुरू होकर अभी तक जारी काम: has/have been + verb-ing',
        'Telugu': 'గతంలో మొదలై ఇప్పటికీ కొనసాగుతున్న పని: has/have been + verb-ing',
        'English': 'action started in the past and still continuing now',
      },
      localizedTranslations: {
        'Tamil': 'நாள் முழுவதும் மழை பெய்து கொண்டே இருக்கிறது.',
        'Malayalam': 'ദിവസം മുഴുവൻ മഴ പെയ്തുകൊണ്ടേയിരിക്കുന്നു.',
        'Hindi': 'दिन भर बारिश होती रही है।',
        'Telugu': 'రోజంతా వర్షం పడుతూనే ఉంది.',
        'English': 'It has been raining all day long.',
      },
    ),

    // 5. Past Simple
    TenseExerciseItem(
      tenseName: 'Past Simple',
      formula: 'subject + V2 past verb',
      promptSentence: 'She ___ (watch) a movie yesterday.',
      targetWord: 'watched',
      acceptableWords: ['watched', 'saw'],
      fullSentence: 'She watched a movie yesterday.',
      localizedHints: {
        'Tamil': 'கடந்த காலத்தில் முடிந்த செயல்: வினைச்சொல்லின் V2 வடிவம் (watched)',
        'Malayalam': 'കഴിഞ്ഞുപോയ സംഭവം: ക്രിയയുടെ V2 രൂപം ഉപയോഗിക്കുക (watched)',
        'Hindi': 'बीता हुआ कार्य: क्रिया का V2 रूप लगाएं (watched)',
        'Telugu': 'గతంలో పూర్తయిన పని: క్రియ యొక్క V2 రూపం (watched)',
        'English': 'completed action at a specific past time: regular verb + ed',
      },
      localizedTranslations: {
        'Tamil': 'அவள் நேற்று ஒரு திரைப்படம் பார்த்தாள்.',
        'Malayalam': 'അവൾ ഇന്നലെ ഒരു സിനിമ കണ്ടു.',
        'Hindi': 'उसने कल एक फिल्म देखी।',
        'Telugu': 'ఆమె నిన్న ఒక సినిమా చూసింది.',
        'English': 'She watched a movie yesterday.',
      },
    ),

    // 6. Past Continuous
    TenseExerciseItem(
      tenseName: 'Past Continuous',
      formula: 'subject + was/were + verb-ing',
      promptSentence: 'I ___ (watch) TV at 8 PM last night.',
      targetWord: 'was watching',
      acceptableWords: ['was watching', 'watched'],
      fullSentence: 'I was watching TV at 8 PM last night.',
      localizedHints: {
        'Tamil': 'கடந்த காலத்தில் ஒரு குறிப்பிட்ட நேரத்தில் நடந்த செயல்: was/were + verb-ing',
        'Malayalam': 'ഭൂതകാലത്ത് നടന്നുകൊണ്ടിരുന്ന കാര്യം: was/were + verb-ing (was watching)',
        'Hindi': 'अतीत में किसी निश्चित समय पर जारी काम: was/were + verb-ing',
        'Telugu': 'గతంలో ఒక సమయానికి జరుగుతూ ఉన్న పని: was/were + verb-ing',
        'English': 'action in progress at a specific past time',
      },
      localizedTranslations: {
        'Tamil': 'நேற்று இரவு 8 மணிக்கு நான் தொலைக்காட்சி பார்த்துக் கொண்டிருந்தேன்.',
        'Malayalam': 'ഇന്നലെ രാത്രി 8 മണിക്ക് ഞാൻ ടിവി കാണുകയായിരുന്നു.',
        'Hindi': 'मैं कल रात 8 बजे टीवी देख रहा था।',
        'Telugu': 'నేను నిన్న రాత్రి 8 గంటలకు టీవీ చూస్తూ ఉన్నాను.',
        'English': 'I was watching TV at 8 PM last night.',
      },
    ),

    // 7. Past Perfect
    TenseExerciseItem(
      tenseName: 'Past Perfect',
      formula: 'subject + had + past participle (V3)',
      promptSentence: 'I ___ (eat) already when she arrived.',
      targetWord: 'had already eaten',
      acceptableWords: ['had already eaten', 'had eaten', 'ate'],
      fullSentence: 'I had already eaten when she arrived.',
      localizedHints: {
        'Tamil': 'மற்றொரு கடந்த கால செயலுக்கு முன் முடிந்த செயல்: had + V3 (had eaten)',
        'Malayalam': 'മറ്റൊരു ഭൂതകാല സംഭവത്തിന് മുമ്പേ കഴിഞ്ഞ കാര്യം: had + V3 (had eaten)',
        'Hindi': 'किसी दूसरे पुराने काम से पहले हुआ काम: had + V3 (had eaten)',
        'Telugu': 'మరొక గత పనికి ముందే పూర్తయిన పని: had + V3 (had eaten)',
        'English': 'shows that one past action happened before another past action',
      },
      localizedTranslations: {
        'Tamil': 'அவள் வரும்போதே நான் ஏற்கெனவே சாப்பிட்டுவிட்டேன்.',
        'Malayalam': 'അവൾ എത്തുമ്പോഴേക്കും ഞാൻ ഭക്ഷണം കഴിച്ചുകഴിഞ്ഞിരുന്നു.',
        'Hindi': 'जब वह आई, तब तक मैं खाना खा चुका था।',
        'Telugu': 'ఆమె వచ్చేసరికి నేను అప్పటికే భోజనం చేసేశాను.',
        'English': 'I had already eaten when she arrived.',
      },
    ),

    // 8. Past Perfect Continuous
    TenseExerciseItem(
      tenseName: 'Past Perfect Continuous',
      formula: 'subject + had + been + verb-ing',
      promptSentence: 'They ___ (drive) for five hours when they stopped.',
      targetWord: 'had been driving',
      acceptableWords: ['had been driving', 'were driving'],
      fullSentence: 'They had been driving for five hours when they stopped.',
      localizedHints: {
        'Tamil': 'கடந்த காலத்தில் குறிப்பிட்ட புள்ளி வரை தொடர்ந்து நடந்த செயல்: had been + verb-ing',
        'Malayalam': 'ഭൂതകാലത്ത് ഒരു ഘട്ടം വരെ നീണ്ടുനിന്ന പ്രവർത്തനം: had been + verb-ing',
        'Hindi': 'अतीत के किसी बिंदु तक जारी रहने वाला कार्य: had been + verb-ing',
        'Telugu': 'గతంలో ఒక సమయం వరకు నిరంతరం సాగిన పని: had been + verb-ing',
        'English': 'emphasises duration of action continuing up to a past point',
      },
      localizedTranslations: {
        'Tamil': 'அவர்கள் வண்டியை நிறுத்தியபோது ஐந்து மணி நேரம் தொடர்ந்து ஓட்டியிருந்தனர்.',
        'Malayalam': 'അവർ വണ്ടി നിർത്തുമ്പോൾ അഞ്ച് മണിക്കൂറായി ഡ്രൈവ് ചെയ്യുകയായിരുന്നു.',
        'Hindi': 'जब वे रुके, तब वे पाँच घंटे से गाड़ी चला रहे थे।',
        'Telugu': 'వారు ఆగేసరికి ఐదు గంటల పాటు డ్రైవింగ్ చేస్తూనే ఉన్నారు.',
        'English': 'They had been driving for five hours when they stopped.',
      },
    ),

    // 9. Future Simple
    TenseExerciseItem(
      tenseName: 'Future Simple',
      formula: 'subject + will + base verb',
      promptSentence: 'I ___ (help) you with that heavy box.',
      targetWord: 'will help',
      acceptableWords: ['will help', 'shall help', 'can help'],
      fullSentence: 'I will help you with that heavy box.',
      localizedHints: {
        'Tamil': 'எதிர்கால முடிவு அல்லது வாக்குறுதி: will + base verb (will help)',
        'Malayalam': 'ഭാവി തീരുമാനം അല്ലെങ്കിൽ വാഗ്ദാനം: will + base verb (will help)',
        'Hindi': 'भविष्य का निर्णय या वादा: will + base verb (will help)',
        'Telugu': 'భవిష్యత్తు నిర్ణయం లేదా వాగ్దానం: will + base verb (will help)',
        'English': 'spontaneous decision, promise, or future plan: will + verb',
      },
      localizedTranslations: {
        'Tamil': 'அந்தக் கனமான பெட்டியைத் தூக்க நான் உங்களுக்கு உதவுவேன்.',
        'Malayalam': 'ആ ഭാരമുള്ള പെട്ടി എടുക്കാൻ ഞാൻ നിങ്ങളെ സഹായിക്കാം.',
        'Hindi': 'मैं उस भारी डिब्बे में आपकी मदद करूँगा।',
        'Telugu': 'ఆ బరువైన పెట్టెతో నేను మీకు సహాయం చేస్తాను.',
        'English': 'I will help you with that heavy box.',
      },
    ),

    // 10. Future Continuous
    TenseExerciseItem(
      tenseName: 'Future Continuous',
      formula: 'subject + will + be + verb-ing',
      promptSentence: 'I ___ (fly) to New York at 8 PM tomorrow.',
      targetWord: 'will be flying',
      acceptableWords: ['will be flying', 'am flying', 'will fly'],
      fullSentence: 'I will be flying to New York at 8 PM tomorrow.',
      localizedHints: {
        'Tamil': 'எதிர்காலத்தில் ஒரு குறிப்பிட்ட நேரத்தில் நடக்கும் செயல்: will be + verb-ing',
        'Malayalam': 'ഭാവിയിൽ ഒരു നിശ്ചിത സമയത്ത് നടക്കുന്ന പ്രവർത്തനം: will be + verb-ing',
        'Hindi': 'भविष्य में किसी निश्चित समय पर जारी रहने वाला काम: will be + verb-ing',
        'Telugu': 'భవిష్యత్తులో ఒక నిర్దిష్ట సమయానికి జరుగుతూ ఉండే పని: will be + verb-ing',
        'English': 'action that will be in progress at a specific future time',
      },
      localizedTranslations: {
        'Tamil': 'நாளை இரவு 8 மணிக்கு நான் நியூயார்க்கிற்கு பறந்து கொண்டிருப்பேன்.',
        'Malayalam': 'നാളെ രാത്രി 8 മണിക്ക് ഞാൻ ന്യൂയോർക്കിലേക്ക് വിമാനത്തിൽ യാത്ര ചെയ്യുകയായിരിക്കും.',
        'Hindi': 'कल रात 8 बजे मैं न्यूयॉर्क के लिए उड़ान भर रहा हूँगा।',
        'Telugu': 'రేపు రాత్రి 8 గంటలకు నేను న్యూయార్క్‌కు విమానంలో ప్రయాణిస్తూ ఉంటాను.',
        'English': 'I will be flying to New York at 8 PM tomorrow.',
      },
    ),

    // 11. Future Perfect
    TenseExerciseItem(
      tenseName: 'Future Perfect',
      formula: 'subject + will + have + past participle (V3)',
      promptSentence: 'I ___ (finish) the report by 5 PM.',
      targetWord: 'will have finished',
      acceptableWords: ['will have finished', 'will finish'],
      fullSentence: 'I will have finished the report by 5 PM.',
      localizedHints: {
        'Tamil': 'எதிர்காலத்தில் குறிப்பிட்ட நேரத்திற்குள் முடிவடையும் செயல்: will have + V3',
        'Malayalam': 'ഭാവിയിൽ ഒരു നിശ്ചിത സമയത്തിനുള്ളിൽ തീരുന്ന കാര്യം: will have + V3',
        'Hindi': 'भविष्य में तय समय तक पूरा होने वाला काम: will have + V3',
        'Telugu': 'భవిష్యత్తులో నిర్దిష్ట సమయానికి పూర్తయ్యే పని: will have + V3',
        'English': 'action completed by a specific time in the future: will have + V3',
      },
      localizedTranslations: {
        'Tamil': 'மாலை 5 மணிக்குள் நான் அறிக்கையை முடித்துவிடுவேன்.',
        'Malayalam': 'വൈകുന്നേരം 5 മണിയോടെ ഞാൻ റിപ്പോർട്ട് പൂർത്തിയാക്കിയിരിക്കും.',
        'Hindi': 'शाम 5 बजे तक मैं रिपोर्ट पूरी कर चुका हूँगा।',
        'Telugu': 'సాయంత్రం 5 గంటల కల్లా నేను నివేదికను పూర్తి చేసి ఉంటాను.',
        'English': 'I will have finished the report by 5 PM.',
      },
    ),

    // 12. Future Perfect Continuous
    TenseExerciseItem(
      tenseName: 'Future Perfect Continuous',
      formula: 'subject + will + have + been + verb-ing',
      promptSentence: 'She ___ (study) for four hours by dinner.',
      targetWord: 'will have been studying',
      acceptableWords: ['will have been studying', 'has been studying'],
      fullSentence: 'She will have been studying for four hours by dinner.',
      localizedHints: {
        'Tamil': 'எதிர்கால நேரம் வரை நீடிக்கும் செயலின் கால அளவு: will have been + verb-ing',
        'Malayalam': 'ഭാവിയിലെ ഒരു സമയം വരെ നീണ്ടുനിൽക്കുന്ന കാലയളവ്: will have been + verb-ing',
        'Hindi': 'भविष्य के किसी बिंदु तक कार्य की अवधि दर्शाना: will have been + verb-ing',
        'Telugu': 'భవిష్యత్తులో సమయం వరకు పని వ్యవధిని తెలపడం: will have been + verb-ing',
        'English': 'emphasises duration of an action up to a future point',
      },
      localizedTranslations: {
        'Tamil': 'இரவு உணவின் போது அவள் நான்கு மணி நேரம் படித்திருப்பாள்.',
        'Malayalam': 'അത്താഴ സമയമാകുമ്പോഴേക്കും അവൾ നാല് മണിക്കൂറായി പഠിക്കുകയായിരിക്കും.',
        'Hindi': 'रात के खाने तक वह चार घंटे से पढ़ रही होगी।',
        'Telugu': 'రాత్రి భోజనం సమయానికి ఆమె నాలుగు గంటల పాటు చదువుతూనే ఉంటుంది.',
        'English': 'She will have been studying for four hours by dinner.',
      },
    ),
  ];
}
