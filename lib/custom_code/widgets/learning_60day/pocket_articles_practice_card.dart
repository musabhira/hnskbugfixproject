import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Model for an Articles speaking exercise
class ArticleExerciseItem {
  final String articleType; // 'A/AN', 'THE', 'NO ARTICLE'
  final String rule;
  final String promptSentence;
  final String targetWord;
  final List<String> acceptableWords;
  final String fullSentence;
  final Map<String, String> localizedHints;
  final Map<String, String> localizedTranslations;

  const ArticleExerciseItem({
    required this.articleType,
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

/// 📝 Articles Practice Card — A, An, The
/// Interactive speaking drills with Say It, instant evaluation, written correct
/// answer display, TTS, retry, filter tabs, and step completion tracking.
class PocketArticlesPracticeCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const PocketArticlesPracticeCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '7',
  });

  @override
  State<PocketArticlesPracticeCard> createState() =>
      _PocketArticlesPracticeCardState();
}

class _PocketArticlesPracticeCardState
    extends State<PocketArticlesPracticeCard>
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

  List<ArticleExerciseItem> get _filteredExercises {
    switch (_activeFilter) {
      case 'A/AN':
        return _kArticleExercises.sublist(0, 5);
      case 'THE':
        return _kArticleExercises.sublist(5, 10);
      case 'NONE':
        return _kArticleExercises.sublist(10, 15);
      default:
        return _kArticleExercises;
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

  void _bypassForTesting(ArticleExerciseItem ex) {
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
    final displaySentence =
        (_isExerciseAnswered && _isCorrect) ? ex.fullSentence : ex.promptSentence;
    final localizedHint = ex.getHint(widget.selectedLanguage);
    final localizedMeaning = ex.getTranslation(widget.selectedLanguage);

    final Color badgeColor = ex.articleType == 'A/AN'
        ? const Color(0xFF7C5CFC)
        : ex.articleType == 'THE'
            ? const Color(0xFF38BDF8)
            : const Color(0xFF10B981);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFF7C5CFC).withValues(alpha: 0.5),
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
                          ? 'STEP ${widget.stepNumber} • 📝 Articles'
                          : '📝 Articles (A, An, The)',
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
                          ? '🎉 Articles Practice Completed! (+20 PTS) ✓'
                          : 'Articles Practice marked as pending'),
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

          // Filter tabs
          Row(
            children: [
              _buildFilterTab('ALL (15)', 'ALL'),
              const SizedBox(width: 5),
              _buildFilterTab('A / AN', 'A/AN'),
              const SizedBox(width: 5),
              _buildFilterTab('THE', 'THE'),
              const SizedBox(width: 5),
              _buildFilterTab('NONE', 'NONE'),
            ],
          ),
          const SizedBox(height: 10),

          // Rule reference toggle
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
                  const Icon(Icons.menu_book_rounded,
                      color: Color(0xFF7C5CFC), size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _showRuleTable
                          ? 'Hide Articles Rule Chart ▲'
                          : 'Show Articles Rules (A / An / The / None) ▼',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF7C5CFC),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible rule table
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
                  _buildRuleRow('A', 'Before consonant sound',
                      'a cat, a book, a university ("yoo" sound)'),
                  const SizedBox(height: 6),
                  _buildRuleRow('AN', 'Before vowel sound',
                      'an apple, an hour (silent h), an umbrella'),
                  const SizedBox(height: 6),
                  _buildRuleRow('THE', 'Specific / both speakers know',
                      'Close the door. The sun is bright.'),
                  const SizedBox(height: 6),
                  _buildRuleRow('—', 'General / plural / uncountable',
                      'Cats are friendly. Water is life. She eats rice.'),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Main speaking box
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
                        border:
                            Border.all(color: badgeColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        '${ex.articleType}  (${_currentExerciseIndex + 1}/${exercises.length})',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                colors: [Color(0xFF7C5CFC), Color(0xFF38BDF8)],
                              ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF7C5CFC))
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
                                    ? '🎉 Correct! Perfect article usage!'
                                    : 'Almost! Correct article: "${ex.targetWord}"',
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
                        backgroundColor: const Color(0xFF7C5CFC),
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

          // Complete button
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
                        ? '🎉 Articles Practice Completed! (+20 PTS) ✓'
                        : 'Articles Practice marked as pending'),
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
                    ? 'ARTICLES PRACTICE COMPLETED ✓'
                    : 'MARK ARTICLES PRACTICE COMPLETE ✓',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFF7C5CFC),
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
            color: isSel ? const Color(0xFF7C5CFC) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSel ? const Color(0xFF7C5CFC) : Colors.white12,
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

  Widget _buildRuleRow(String article, String when, String examples) {
    final Color col = article == 'A'
        ? const Color(0xFF7C5CFC)
        : article == 'AN'
            ? const Color(0xFF7C5CFC)
            : article == 'THE'
                ? const Color(0xFF38BDF8)
                : const Color(0xFF10B981);
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
              article,
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
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
        return 'உரிச்சொற்கள் பேச்சுப் பயிற்சி';
      case 'telugu':
        return 'ఆర్టికల్స్ మాట్లాడే సాధన';
      case 'hindi':
        return 'Articles बोलने का अभ्यास';
      case 'kannada':
        return 'ಆರ್ಟಿಕಲ್ಸ್ ಮಾತನಾಡುವ ಅಭ್ಯಾಸ';
      case 'malayalam':
        return 'ആർട്ടിക്കിൾസ് സംസാര പരിശീലനം';
      default:
        return 'A, An, The Speaking Practice';
    }
  }

  String _getInstructionText(String language) {
    switch (language.toLowerCase()) {
      case 'tamil':
        return '"a/an" — தனிப்பட்ட ஒரு பொருள் | "the" — இருவரும் அறிந்தது | கட்டுரை இல்லை — பொதுவான விஷயம். சரியானதை சொல்லி பேசுங்கள்.';
      case 'telugu':
        return '"a/an" — తెలియని ఒక వస్తువు | "the" — ఇద్దరికీ తెలిసినది | Article లేదు — సాధారణ విషయం. సరైన article తో వాక్యం పలకండి.';
      case 'hindi':
        return '"a/an" — अज्ञात एकवचन | "the" — दोनों को पता | article नहीं — सामान्य बात। सही article बोलकर वाक्य पढ़ें।';
      case 'kannada':
        return '"a/an" — ಅಪರಿಚಿತ ಒಂದು ವಸ್ತು | "the" — ಇಬ್ಬರಿಗೂ ತಿಳಿದ ವಸ್ತು | article ಇಲ್ಲ — ಸಾಮಾನ್ಯ ವಿಷಯ. ಸರಿಯಾದ article ಹೇಳಿ.';
      case 'malayalam':
        return '"a/an" — ഒരൊറ്റ അജ്ഞാത വസ്തു | "the" — ഇരുവർക്കും അറിയാം | article ഇല്ല — പൊതുവായ കാര്യം. ശരിയായ article ഉച്ചരിക്കുക.';
      default:
        return '"a/an" = one unspecified thing | "the" = both know it | no article = general/plural. Fill the blank and say it aloud.';
    }
  }

  // 15 EXERCISES: 5 A/AN + 5 THE + 5 NO ARTICLE
  static const List<ArticleExerciseItem> _kArticleExercises = [
    // ─── A / AN (1-5) ────────────────────────────────────────
    ArticleExerciseItem(
      articleType: 'A/AN',
      rule: 'Use "an" before vowel sounds (a, e, i, o, u)',
      promptSentence: 'I saw ___ elephant at the zoo.',
      targetWord: 'an',
      acceptableWords: ['an elephant', 'an', 'saw an'],
      fullSentence: 'I saw an elephant at the zoo.',
      localizedHints: {
        'Tamil': '"elephant" என்பது "e" உயிர் ஒலியில் தொடங்குவதால் "an" பயன்படுத்தவும்',
        'Malayalam': '"elephant" vowel ശബ്ദത്തോടെ ആരംഭിക്കുന്നു → "an" ഉപയോഗിക്കുക',
        'Hindi': '"elephant" vowel sound (e) से शुरू → "an" लगाएं',
        'Telugu': '"elephant" vowel sound (e) తో మొదలవుతుంది → "an" వాడండి',
        'English': '"elephant" starts with vowel sound → use "an"',
      },
      localizedTranslations: {
        'Tamil': 'நான் உயிரியல் பூங்காவில் ஒரு யானையைப் பார்த்தேன்.',
        'Malayalam': 'ഞാൻ മൃഗശാലയിൽ ഒരു ആനയെ കണ്ടു.',
        'Hindi': 'मैंने चिड़ियाघर में एक हाथी देखा।',
        'Telugu': 'నేను జంతుప్రదర్శనశాలలో ఒక ఏనుగును చూశాను.',
        'English': 'I saw an elephant at the zoo.',
      },
    ),
    ArticleExerciseItem(
      articleType: 'A/AN',
      rule: 'Use "an" — "hour" has a silent h (vowel sound)',
      promptSentence: 'She waited for ___ hour outside.',
      targetWord: 'an',
      acceptableWords: ['an hour', 'an', 'waited an'],
      fullSentence: 'She waited for an hour outside.',
      localizedHints: {
        'Tamil': '"hour" இல் "h" மவுனமாக உள்ளது; "ow" என்ற உயிர் ஒலி → "an"',
        'Malayalam': '"hour" ൽ h നിശ്ശബ്ദമാണ്; vowel ഒച്ചയിൽ ആരംഭിക്കുന്നു → "an"',
        'Hindi': '"hour" में h मूक है; ओ की ध्वनि → "an" लगाएं',
        'Telugu': '"hour" లో h మూగది; vowel sound తో మొదలవుతుంది → "an"',
        'English': '"hour" has silent h — vowel sound "ow" → use "an"',
      },
      localizedTranslations: {
        'Tamil': 'அவள் வெளியே ஒரு மணி நேரம் காத்திருந்தாள்.',
        'Malayalam': 'അവൾ പുറത്ത് ഒരു മണിക്കൂർ കാത്തിരുന്നു.',
        'Hindi': 'वह बाहर एक घंटे तक इंतज़ार करती रही।',
        'Telugu': 'ఆమె బయట ఒక గంట వేచి ఉంది.',
        'English': 'She waited for an hour outside.',
      },
    ),
    ArticleExerciseItem(
      articleType: 'A/AN',
      rule: 'Use "a" — "university" sounds like "yoo" (consonant sound)',
      promptSentence: 'He got admission to ___ university.',
      targetWord: 'a',
      acceptableWords: ['a university', 'a', 'to a'],
      fullSentence: 'He got admission to a university.',
      localizedHints: {
        'Tamil': '"university" = "yoo-ni-ver-si-ty"; "y" என்பது மெய்யொலி → "a"',
        'Malayalam': '"university" "yoo…" consonant ശബ്ദത്തിൽ ആരംഭിക്കുന്നു → "a"',
        'Hindi': '"university" का उच्चारण "यू..." consonant sound → "a"',
        'Telugu': '"university" "yoo..." consonant sound తో మొదలవుతుంది → "a"',
        'English': '"university" sounds like "yoo" — consonant → use "a"',
      },
      localizedTranslations: {
        'Tamil': 'அவன் ஒரு பல்கலைக்கழகத்தில் சேர்க்கை பெற்றான்.',
        'Malayalam': 'അവൻ ഒരു സർവകലാശാലയിൽ പ്രവേശനം നേടി.',
        'Hindi': 'उसे एक विश्वविद्यालय में दाखिला मिला।',
        'Telugu': 'అతను ఒక విశ్వవిద్యాలయంలో ప్రవేశం పొందాడు.',
        'English': 'He got admission to a university.',
      },
    ),
    ArticleExerciseItem(
      articleType: 'A/AN',
      rule: 'Use "an" before vowel sound "um" (umbrella)',
      promptSentence: 'I forgot ___ umbrella at home.',
      targetWord: 'an',
      acceptableWords: ['an umbrella', 'an', 'forgot an'],
      fullSentence: 'I forgot an umbrella at home.',
      localizedHints: {
        'Tamil': '"umbrella" என்பது "u" உயிர் ஒலியில் தொடங்குவதால் "an"',
        'Malayalam': '"umbrella" u vowel ശബ്ദത്തോടെ → "an" ഉപയോഗിക്കുക',
        'Hindi': '"umbrella" vowel u से शुरू → "an" लगाएं',
        'Telugu': '"umbrella" vowel u తో మొదలవుతుంది → "an" వాడండి',
        'English': '"umbrella" starts with vowel "u" → use "an"',
      },
      localizedTranslations: {
        'Tamil': 'நான் வீட்டில் குடையை மறந்து விட்டேன்.',
        'Malayalam': 'ഞാൻ വീട്ടിൽ കൊടക്കൂർ മറന്നു.',
        'Hindi': 'मैं घर पर छाता भूल गया।',
        'Telugu': 'నేను ఇంట్లో గొడుగు మర్చిపోయాను.',
        'English': 'I forgot an umbrella at home.',
      },
    ),
    ArticleExerciseItem(
      articleType: 'A/AN',
      rule: 'Use "a" — "dog" starts with consonant sound "d"',
      promptSentence: 'They adopted ___ dog last week.',
      targetWord: 'a',
      acceptableWords: ['a dog', 'a', 'adopted a'],
      fullSentence: 'They adopted a dog last week.',
      localizedHints: {
        'Tamil': '"dog" என்பது "d" மெய்யெழுத்தில் தொடங்குவதால் "a"',
        'Malayalam': '"dog" d consonant-ൽ ആരംഭിക്കുന്നു → "a"',
        'Hindi': '"dog" consonant d से शुरू → "a" लगाएं',
        'Telugu': '"dog" consonant d తో మొదలవుతుంది → "a"',
        'English': '"dog" starts with consonant "d" → use "a"',
      },
      localizedTranslations: {
        'Tamil': 'அவர்கள் கடந்த வாரம் ஒரு நாயை தத்தெடுத்தனர்.',
        'Malayalam': 'അവർ കഴിഞ്ഞ ആഴ്ച ഒരു നായയെ ദത്തെടുത്തു.',
        'Hindi': 'उन्होंने पिछले सप्ताह एक कुत्ता गोद लिया।',
        'Telugu': 'వారు గత వారం ఒక కుక్కను దత్తత తీసుకున్నారు.',
        'English': 'They adopted a dog last week.',
      },
    ),

    // ─── THE (6-10) ───────────────────────────────────────────
    ArticleExerciseItem(
      articleType: 'THE',
      rule: 'Use "the" — unique thing; only one exists',
      promptSentence: '___ sun rises in the east every morning.',
      targetWord: 'The',
      acceptableWords: ['The sun', 'the sun', 'the'],
      fullSentence: 'The sun rises in the east every morning.',
      localizedHints: {
        'Tamil': 'ஒரே ஒரு சூரியன் மட்டுமே உள்ளது → "the"',
        'Malayalam': 'ഒരൊറ്റ സൂര്യൻ; எல்ലாவർക்കும் അறിയാം → "the"',
        'Hindi': 'एक ही सूरज है; सबको पता है → "the"',
        'Telugu': 'ఒకే ఒక సూర్యుడు; అందరికీ తెలుసు → "the"',
        'English': 'only one sun — everyone knows it → use "the"',
      },
      localizedTranslations: {
        'Tamil': 'சூரியன் ஒவ்வொரு காலையும் கிழக்கில் உதிக்கிறது.',
        'Malayalam': 'സൂര്യൻ ഓരോ പ്രഭാതവും കിഴക്ക് ഉദിക്കുന്നു.',
        'Hindi': 'सूरज हर सुबह पूर्व में उगता है।',
        'Telugu': 'సూర్యుడు ప్రతి ఉదయం తూర్పులో ఉదయిస్తాడు.',
        'English': 'The sun rises in the east every morning.',
      },
    ),
    ArticleExerciseItem(
      articleType: 'THE',
      rule: 'Use "the" — listener knows which specific door',
      promptSentence: 'Please close ___ door behind you.',
      targetWord: 'the',
      acceptableWords: ['the door', 'the', 'close the'],
      fullSentence: 'Please close the door behind you.',
      localizedHints: {
        'Tamil': 'கேட்பவர் எந்த கதவு என்று அறிவார் → "the"',
        'Malayalam': 'ഏത് വാതിൽ ആണെന്ന് ഇരുവർക്കും അറിയാം → "the"',
        'Hindi': 'श्रोता जानता है कौन सा दरवाज़ा → "the"',
        'Telugu': 'వినేవారికి ఏ తలుపో తెలుసు → "the"',
        'English': 'both speakers know which door → use "the"',
      },
      localizedTranslations: {
        'Tamil': 'தயவுசெய்து உங்கள் பின்னால் கதவை மூடுங்கள்.',
        'Malayalam': 'ദയവായി പിറകിൽ വാതിൽ അടയ്ക്കൂ.',
        'Hindi': 'कृपया अपने पीछे दरवाज़ा बंद करें।',
        'Telugu': 'దయచేసి మీ వెనక తలుపు మూయండి.',
        'English': 'Please close the door behind you.',
      },
    ),
    ArticleExerciseItem(
      articleType: 'THE',
      rule: 'Use "the" — specific film both speakers know',
      promptSentence: 'I watched ___ movie you recommended yesterday.',
      targetWord: 'the',
      acceptableWords: ['the movie', 'the', 'watched the'],
      fullSentence: 'I watched the movie you recommended yesterday.',
      localizedHints: {
        'Tamil': 'இருவரும் எந்தத் திரைப்படம் என்று அறிவோம் → "the"',
        'Malayalam': 'ഇരുവർക്കും ഏത് സിനിമ എന്ന് അറിയാം → "the"',
        'Hindi': 'दोनों को पता है कौन सी फिल्म → "the"',
        'Telugu': 'ఇద్దరికీ ఏ సినిమా అని తెలుసు → "the"',
        'English': 'both know which specific movie → use "the"',
      },
      localizedTranslations: {
        'Tamil': 'நேற்று நீங்கள் பரிந்துரைத்த திரைப்படத்தை பார்த்தேன்.',
        'Malayalam': 'ഇന്നലെ നിങ്ങൾ ശുപാർശ ചെയ്ത സിനിമ ഞാൻ കണ്ടു.',
        'Hindi': 'कल आपकी सुझाई फिल्म मैंने देखी।',
        'Telugu': 'నిన్న మీరు సిఫారసు చేసిన సినిమా చూశాను.',
        'English': 'I watched the movie you recommended yesterday.',
      },
    ),
    ArticleExerciseItem(
      articleType: 'THE',
      rule: 'Use "the" — specific known place',
      promptSentence: 'We played cricket at ___ park near our school.',
      targetWord: 'the',
      acceptableWords: ['the park', 'the', 'at the'],
      fullSentence: 'We played cricket at the park near our school.',
      localizedHints: {
        'Tamil': 'இருவரும் அறிந்த குறிப்பிட்ட பூங்கா → "the"',
        'Malayalam': 'ഇരുവർക്കും അറിയാവുന്ന ഉദ്യാനം → "the"',
        'Hindi': 'दोनों को पता है कौन सा पार्क → "the"',
        'Telugu': 'ఇద్దరికీ తెలిసిన నిర్దిష్ట పార్కు → "the"',
        'English': 'specific park both know → use "the"',
      },
      localizedTranslations: {
        'Tamil': 'நாங்கள் பள்ளிக்கு அருகில் உள்ள பூங்காவில் கிரிக்கெட் விளையாடினோம்.',
        'Malayalam': 'ഞങ്ങൾ സ്കൂളിന് സമീപത്തെ ഉദ്യാനത്തിൽ ക്രിക്കറ്റ് കളിച്ചു.',
        'Hindi': 'हमने स्कूल के पास वाले पार्क में क्रिकेट खेला।',
        'Telugu': 'మేము పాఠశాల సమీపంలోని పార్కులో క్రికెట్ ఆడాం.',
        'English': 'We played cricket at the park near our school.',
      },
    ),
    ArticleExerciseItem(
      articleType: 'THE',
      rule: 'Use "the" with superlatives (the best, the tallest)',
      promptSentence: 'She is ___ best player on our team.',
      targetWord: 'the',
      acceptableWords: ['the best', 'the', 'is the'],
      fullSentence: 'She is the best player on our team.',
      localizedHints: {
        'Tamil': 'உயர்திணை சொற்களுடன் எப்போதும் "the" வரும் (the best)',
        'Malayalam': 'Superlative adjective-ഉമൊത്ത് "the" ഉപയോഗിക്കുക',
        'Hindi': 'Superlative के साथ हमेशा "the" → the best',
        'Telugu': 'Superlative adjective తో "the" తప్పనిసరి → the best',
        'English': 'superlatives always take "the" → the best, the tallest',
      },
      localizedTranslations: {
        'Tamil': 'அவள் நம் அணியில் சிறந்த வீராங்கனை.',
        'Malayalam': 'അവൾ നമ്മുടെ ടീമിലെ ഏറ്റവും മികച്ച കളിക്കാരിയാണ്.',
        'Hindi': 'वह हमारी टीम की सबसे अच्छी खिलाड़ी है।',
        'Telugu': 'ఆమె మన జట్టులో అత్యుత్తమ ఆటగాడు.',
        'English': 'She is the best player on our team.',
      },
    ),

    // ─── NO ARTICLE (11-15) ───────────────────────────────────
    ArticleExerciseItem(
      articleType: 'NO ARTICLE',
      rule: 'No article — plural noun for general meaning',
      promptSentence: '___ cats are friendly animals.',
      targetWord: 'Cats',
      acceptableWords: ['Cats are', 'cats', 'cats are friendly'],
      fullSentence: 'Cats are friendly animals.',
      localizedHints: {
        'Tamil': 'பொதுவான உண்மை (plural): கட்டுரை இல்லை — "Cats" நேரடியாக தொடங்கும்',
        'Malayalam': 'ഒരു general truth (plural): article ഇല്ല — "Cats" നേരിട്ട് ആരംഭിക്കുക',
        'Hindi': 'सामान्य सत्य (plural): article नहीं — "Cats" सीधे शुरू करें',
        'Telugu': 'సాధారణ నిజం (plural): article లేదు — "Cats" నేరుగా మొదలెట్టండి',
        'English': 'general truth about cats in general → no article before plural',
      },
      localizedTranslations: {
        'Tamil': 'பூனைகள் நட்பான விலங்குகள்.',
        'Malayalam': 'പൂച്ചകൾ സൗഹൃദ മൃഗങ്ങളാണ്.',
        'Hindi': 'बिल्लियाँ मिलनसार जानवर होती हैं।',
        'Telugu': 'పిల్లులు స్నేహపూర్వక జంతువులు.',
        'English': 'Cats are friendly animals.',
      },
    ),
    ArticleExerciseItem(
      articleType: 'NO ARTICLE',
      rule: 'No article — uncountable noun for general meaning',
      promptSentence: '___ water is essential for life.',
      targetWord: 'Water',
      acceptableWords: ['Water is', 'water', 'water is essential'],
      fullSentence: 'Water is essential for life.',
      localizedHints: {
        'Tamil': '"water" என்பது uncountable; பொது அர்த்தத்தில் கட்டுரை இல்லை',
        'Malayalam': '"water" uncountable noun; general meaning-ൽ article ഇല്ല',
        'Hindi': '"water" uncountable noun; सामान्य अर्थ में article नहीं',
        'Telugu': '"water" uncountable noun; సాధారణ అర్థంలో article వాడకూడదు',
        'English': '"water" is uncountable → no article for general statements',
      },
      localizedTranslations: {
        'Tamil': 'நீர் வாழ்வுக்கு இன்றியமையாதது.',
        'Malayalam': 'ജലം ജീവനു അത്യാവശ്യമാണ്.',
        'Hindi': 'जल जीवन के लिए अपरिहार्य है।',
        'Telugu': 'నీరు జీవానికి అవసరమైనది.',
        'English': 'Water is essential for life.',
      },
    ),
    ArticleExerciseItem(
      articleType: 'NO ARTICLE',
      rule: 'No article — rice is uncountable; general eating habit',
      promptSentence: 'My grandmother cooks ___ rice every morning.',
      targetWord: 'rice',
      acceptableWords: ['cooks rice', 'rice every', 'rice'],
      fullSentence: 'My grandmother cooks rice every morning.',
      localizedHints: {
        'Tamil': '"rice" uncountable; பொதுவான உணவு பழக்கம் → கட்டுரை இல்லை',
        'Malayalam': '"rice" uncountable; ഒരു general ഭക്ഷണ ശീലം → article ഇല്ല',
        'Hindi': '"rice" uncountable है; आम खाने की आदत → article नहीं',
        'Telugu': '"rice" uncountable; సాధారణ ఆహార అలవాటు → article వాడకండి',
        'English': '"rice" uncountable — no article for general habits',
      },
      localizedTranslations: {
        'Tamil': 'என் பாட்டி ஒவ்வொரு காலையும் சாதம் சமைக்கிறார்.',
        'Malayalam': 'എന്റെ മുത്തശ്ശി ഓരോ പ്രഭാതവും ചോറ് പാകം ചെയ്യുന്നു.',
        'Hindi': 'मेरी दादी हर सुबह चावल पकाती हैं।',
        'Telugu': 'నా అమ్మమ్మ ప్రతి ఉదయం అన్నం వండుతుంది.',
        'English': 'My grandmother cooks rice every morning.',
      },
    ),
    ArticleExerciseItem(
      articleType: 'NO ARTICLE',
      rule: 'No article — abstract uncountable nouns (music, love)',
      promptSentence: 'She loves ___ music and painting.',
      targetWord: 'music',
      acceptableWords: ['loves music', 'music and', 'music'],
      fullSentence: 'She loves music and painting.',
      localizedHints: {
        'Tamil': '"music" abstract uncountable; பொதுவான விருப்பம் → கட்டுரை இல்லை',
        'Malayalam': '"music" abstract noun; ഒரു general ഇഷ്ടം → article ഇല്ല',
        'Hindi': '"music" abstract uncountable; सामान्य पसंद → article नहीं',
        'Telugu': '"music" abstract uncountable; సాధారణ ఇష్టం → article వాడకండి',
        'English': '"music" is abstract and uncountable → no article in general',
      },
      localizedTranslations: {
        'Tamil': 'அவள் இசையையும் ஓவியத்தையும் விரும்புகிறாள்.',
        'Malayalam': 'അവൾ സംഗീതവും ചിത്രരചനയും ഇഷ്ടപ്പെടുന്നു.',
        'Hindi': 'उसे संगीत और चित्रकारी पसंद है।',
        'Telugu': 'ఆమెకు సంగీతం మరియు చిత్రలేఖనం అంటే ఇష్టం.',
        'English': 'She loves music and painting.',
      },
    ),
    ArticleExerciseItem(
      articleType: 'NO ARTICLE',
      rule: 'No article — language names take no article',
      promptSentence: 'He speaks ___ English and Tamil fluently.',
      targetWord: 'English',
      acceptableWords: ['speaks english', 'speaks English', 'English and'],
      fullSentence: 'He speaks English and Tamil fluently.',
      localizedHints: {
        'Tamil': 'மொழி பெயர்களுக்கு கட்டுரை இல்லை: English, Tamil, Hindi…',
        'Malayalam': 'ഭാഷകളുടെ പേരിന് article ഇല്ല: English, Malayalam, Hindi…',
        'Hindi': 'भाषाओं के नाम के साथ article नहीं: English, Hindi, Tamil…',
        'Telugu': 'భాషల పేర్లకు article వాడకూడదు: English, Telugu, Hindi…',
        'English': 'language names need no article: English, Tamil, Hindi…',
      },
      localizedTranslations: {
        'Tamil': 'அவன் ஆங்கிலம் மற்றும் தமிழை சரளமாக பேசுகிறான்.',
        'Malayalam': 'അവൻ ഇംഗ്ലീഷും തമിഴും നന്നായി സംസാരിക്കുന്നു.',
        'Hindi': 'वह अंग्रेज़ी और तमिल धाराप्रवाह बोलता है।',
        'Telugu': 'అతను ఇంగ్లీష్ మరియు తెలుగు ధారాళంగా మాట్లాడతాడు.',
        'English': 'He speaks English and Tamil fluently.',
      },
    ),
  ];
}
