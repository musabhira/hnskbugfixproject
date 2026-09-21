import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Model for a Direct & Indirect Speech speaking exercise
class DirectIndirectExerciseItem {
  final String category; // 'STATEMENTS', 'QUESTIONS', 'COMMANDS', 'TIME_PRONOUNS'
  final String speechType; // e.g. 'Tense Shift: am -> was', 'Reported Question (if/whether)', 'Command (to + verb)'
  final String rule;
  final String directQuote;
  final String promptSentence;
  final String targetWord;
  final List<String> acceptableWords;
  final String fullSentence;
  final Map<String, String> localizedHints;
  final Map<String, String> localizedTranslations;

  const DirectIndirectExerciseItem({
    required this.category,
    required this.speechType,
    required this.rule,
    required this.directQuote,
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

/// 💬 Direct & Indirect Speech Practice Card — Statements, Questions, Commands & Time Shifts
/// Features interactive 🎤 "Say It" speech recognition, instant evaluation,
/// written feedback, TTS audio, filter tabs, collapsible guide, and completion tracking.
class PocketDirectIndirectPracticeCard extends StatefulWidget {
  final int day;
  final String selectedLanguage;
  final bool isCompleted;
  final ValueChanged<bool> onCompleted;
  final Function(String text)? onSpeak;
  final String stepNumber;

  const PocketDirectIndirectPracticeCard({
    super.key,
    required this.day,
    this.selectedLanguage = 'Malayalam',
    required this.isCompleted,
    required this.onCompleted,
    this.onSpeak,
    this.stepNumber = '12',
  });

  @override
  State<PocketDirectIndirectPracticeCard> createState() =>
      _PocketDirectIndirectPracticeCardState();
}

class _PocketDirectIndirectPracticeCardState
    extends State<PocketDirectIndirectPracticeCard>
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
      await _tts.setSpeechRate(0.46);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> _speakText(String text) async {
    if (widget.onSpeak != null) {
      widget.onSpeak!(text);
      return;
    }
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _initSpeechRecognizer() async {
    try {
      _isSpeechInitialized = await _speech.initialize(
        onError: (err) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isListening) {
              _stopListening();
            }
          }
        },
      );
    } catch (_) {
      _isSpeechInitialized = false;
    }
  }

  Future<void> _startListening() async {
    if (_isListening) {
      await _stopListening();
      return;
    }

    HapticFeedback.mediumImpact();

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
        .replaceAll(RegExp(r"[^a-zA-Z0-9\s']"), '')
        .trim();
    final cleanTarget = ex.targetWord
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-zA-Z0-9\s']"), '')
        .trim();
    final cleanFull = ex.fullSentence
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-zA-Z0-9\s']"), '')
        .trim();

    bool matched = false;

    // Check target word
    if (_matchesPhrase(cleanSpoken, cleanTarget)) {
      matched = true;
    }

    // Check acceptable words
    if (!matched) {
      for (final alt in ex.acceptableWords) {
        final cleanAlt = alt
            .toLowerCase()
            .replaceAll(RegExp(r"[^a-zA-Z0-9\s']"), '')
            .trim();
        if (_matchesPhrase(cleanSpoken, cleanAlt)) {
          matched = true;
          break;
        }
      }
    }

    // Check full sentence
    if (!matched) {
      if (_matchesPhrase(cleanSpoken, cleanFull) ||
          cleanSpoken == cleanFull) {
        matched = true;
      }
    }

    // Multi-word target matching
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

  List<DirectIndirectExerciseItem> get _filteredExercises {
    switch (_activeFilter) {
      case 'STATEMENTS':
        return _kDirectIndirectExercises
            .where((e) => e.category == 'STATEMENTS')
            .toList();
      case 'QUESTIONS':
        return _kDirectIndirectExercises
            .where((e) => e.category == 'QUESTIONS')
            .toList();
      case 'COMMANDS':
        return _kDirectIndirectExercises
            .where((e) => e.category == 'COMMANDS')
            .toList();
      case 'TIME_PRONOUNS':
        return _kDirectIndirectExercises
            .where((e) => e.category == 'TIME_PRONOUNS')
            .toList();
      default:
        return _kDirectIndirectExercises;
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

  void _forcePassForTesting() {
    final ex = _filteredExercises[_currentExerciseIndex];
    setState(() {
      _isExerciseAnswered = true;
      _isCorrect = true;
      _recognizedWords = ex.targetWord;
    });
    HapticFeedback.mediumImpact();
    _speakText(ex.fullSentence);
  }

  @override
  void dispose() {
    _listeningTimeoutTimer?.cancel();
    _pulseController.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  String _getLocalizedSubtitle(String lang) {
    switch (lang.toLowerCase()) {
      case 'tamil':
        return 'நேரடி மற்றும் மறைமுக கூற்று (Reported Speech)';
      case 'telugu':
        return 'ప్రత్యక్ష & పరోక్ష ప్రసంగం (Reported Speech)';
      case 'hindi':
        return 'प्रत्यक्ष और अप्रत्यक्ष कथन (Reported Speech)';
      case 'kannada':
        return 'ನೇರ ಮತ್ತು ಪರೋಕ್ಷ ಭಾಷಣ (Reported Speech)';
      case 'malayalam':
      default:
        return 'ഡയറക്ട് & ഇൻഡയറക്ട് സ്പീച്ച് (Reported Speech)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises;
    if (exercises.isEmpty) return const SizedBox.shrink();

    final safeIndex = _currentExerciseIndex.clamp(0, exercises.length - 1);
    final ex = exercises[safeIndex];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E17), // Minimal, plain dark game canvas
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isCompleted
              ? const Color(0xFF10B981)
              : const Color(0xFFBA68C8).withValues(alpha: 0.4),
          width: widget.isCompleted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFBA68C8))
                .withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── TOP GAME HUD BAR ─────────────────────────────────────────────
          Row(
            children: [
              // Step & Game Capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBA68C8), Color(0xFF9C27B0)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.stepNumber.isNotEmpty
                      ? 'STEP ${widget.stepNumber} • SPEECH'
                      : 'SPEECH GAME',
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
                  'TASK ${_currentExerciseIndex + 1}/${exercises.length}',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFE1BEE7),
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
                          ? '🎉 Reported Speech Completed! (+20 PTS) ✓'
                          : 'Reported Speech marked as pending'),
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
            'Direct & Indirect Speech 💬',
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
              color: const Color(0xFFBA68C8),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // ─── FILTER TABS (ALL, STATEMENTS, QUESTIONS, COMMANDS, TIME) ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'ALL (20)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('STATEMENTS', 'STATEMENTS (7)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('QUESTIONS', 'QUESTIONS (5)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('COMMANDS', 'COMMANDS (5)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('TIME_PRONOUNS', 'TIME & SHIFTS (3)'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ─── COLLAPSIBLE GUIDE TOGGLE BUTTON ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _showRuleTable = !_showRuleTable);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: Color(0xFFC084FC),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _showRuleTable
                            ? 'Hide Speech Shift Rules Guide'
                            : 'View Speech Shift Rules & Golden Conversion Table',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC084FC),
                        ),
                      ),
                    ),
                    Icon(
                      _showRuleTable
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFFC084FC),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_showRuleTable) _buildRuleGuide(),

          const SizedBox(height: 12),

          // ─── MAIN EXERCISE CARD CONTAINER ───
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF181B26),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top exercise metadata row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        ex.speechType,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFC084FC),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Exercise ${safeIndex + 1} of ${exercises.length}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline,
                              size: 18, color: Colors.white24),
                          tooltip: 'Bypass test',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: _forcePassForTesting,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ─── DIRECT SPEECH QUOTE BANNER ───
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DIRECT',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ex.directQuote,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded,
                            size: 18, color: Color(0xFF38BDF8)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _speakText(ex.directQuote),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ─── REPORTED PROMPT WITH BLANK ───
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'INDIRECT (REPORTED)',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFC084FC),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Target: "${ex.targetWord}"',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF00FFCC),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ex.promptSentence,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Hint box with lightbulb
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ex.getHint(widget.selectedLanguage),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFDE68A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Native language translation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    ex.getTranslation(widget.selectedLanguage),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white60,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ─── AUDIO PRONUNCIATION & "SAY IT" SPEECH RECOGNITION ───
                Row(
                  children: [
                    // TTS speaker button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.volume_up_rounded,
                          color: Color(0xFFC084FC),
                          size: 22,
                        ),
                        tooltip: 'Listen to native pronunciation',
                        onPressed: () => _speakText(ex.fullSentence),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Primary 🎤 "Say It" Interactive Button
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          final scale = _isListening
                              ? _pulseAnimation.value
                              : 1.0;
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: ElevatedButton.icon(
                          onPressed: _startListening,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isListening
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: _isListening ? 6 : 2,
                            shadowColor: _isListening
                                ? const Color(0xFFDC2626).withValues(alpha: 0.5)
                                : const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                          ),
                          icon: Icon(
                            _isListening
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          label: Text(
                            _isListening
                                ? 'Listening... Tap to Stop'
                                : '🎤 Say It Aloud',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ─── RECOGNIZED SPEECH & WRITTEN FEEDBACK ───
                if (_isListening && _recognizedWords.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFC084FC),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hearing: "$_recognizedWords"',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_isExerciseAnswered) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isCorrect
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isCorrect
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        width: 1.2,
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
                              size: 18,
                              color: _isCorrect
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isCorrect
                                  ? 'Excellent Pronunciation & Transformation!'
                                  : 'Almost There! Read full sentence below:',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _isCorrect
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Full Reported Sentence: "${ex.fullSentence}"',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // ─── BOTTOM NAVIGATION ROW (PREV, NEXT, PROGRESS DASHES) ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _goToPrevious,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 12),
                      label: Text(
                        'PREV',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Progress indicators
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            exercises.length > 10 ? 10 : exercises.length,
                            (idx) {
                              final active = idx ==
                                  (safeIndex %
                                      (exercises.length > 10
                                          ? 10
                                          : exercises.length));
                              return Container(
                                width: active ? 16 : 6,
                                height: 5,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: active
                                      ? const Color(0xFF8B5CF6)
                                      : Colors.white24,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: _goToNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      label: Text(
                        'NEXT (${safeIndex + 1}/${exercises.length})',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ─── FULL-WIDTH COMPLETION BUTTON ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onCompleted(!widget.isCompleted);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: widget.isCompleted
                      ? const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                        ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isCompleted
                          ? const Color(0xFF10B981).withValues(alpha: 0.3)
                          : const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.task_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isCompleted
                          ? 'DIRECT & INDIRECT SPEECH MASTERED ✓'
                          : 'MARK SPEECH PRACTICE COMPLETE ✓',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B5CF6)
              : const Color(0xFF1E293B).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B5CF6)
                : Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.white70,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildRuleGuide() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded,
                  size: 16, color: Color(0xFFC084FC)),
              const SizedBox(width: 6),
              Text(
                'Golden Rules of Reported (Indirect) Speech',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Tense Backshift Table
          Text(
            '1. Tense Backshift (When Reporting Verb is in the Past)',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF38BDF8),
            ),
          ),
          const SizedBox(height: 6),
          _buildGuideRow('Present Simple (am/is/write)', 'Past Simple (was/wrote)'),
          _buildGuideRow('Present Cont. (are doing)', 'Past Cont. (were doing)'),
          _buildGuideRow('Present Perfect (have finished)', 'Past Perfect (had finished)'),
          _buildGuideRow('Past Simple (went)', 'Past Perfect (had gone)'),
          _buildGuideRow('will / can / may', 'would / could / might'),

          const SizedBox(height: 10),

          // Questions & Commands Table
          Text(
            '2. Questions, Commands & Requests',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00FFCC),
            ),
          ),
          const SizedBox(height: 6),
          _buildGuideRow('Yes/No Questions', 'asked if / whether (statement order, NO ? mark)'),
          _buildGuideRow('Wh- Questions', 'asked where / what / why (statement order)'),
          _buildGuideRow('Commands & Orders', 'told / ordered + person + to + verb'),
          _buildGuideRow('Negative Commands', 'told + person + not to + verb'),

          const SizedBox(height: 10),

          // Time & Place Shifts
          Text(
            '3. Time & Place Adjustments',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFDE68A),
            ),
          ),
          const SizedBox(height: 6),
          _buildGuideRow('today / tonight', 'that day / that night'),
          _buildGuideRow('tomorrow / yesterday', 'the next day / the day before'),
          _buildGuideRow('here / this', 'there / that'),

          const SizedBox(height: 10),

          // Common Mistakes warning
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 14, color: Color(0xFFF87171)),
                    const SizedBox(width: 4),
                    Text(
                      'Common Mistakes to Avoid:',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF87171),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '• Never say "He said me" -> Say "He told me" or "He said that".\n'
                  '• Don\'t keep quotation marks in reported speech ("She said that...").\n'
                  '• Do NOT use question word order in reported questions ("He asked where I lived", NOT "where did I live?").',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              left,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_rounded,
              size: 12, color: Color(0xFF8B5CF6)),
          const SizedBox(width: 6),
          Expanded(
            flex: 6,
            child: Text(
              right,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFC084FC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Comprehensive list of 20 Direct & Indirect Speech Speaking Exercises
const List<DirectIndirectExerciseItem> _kDirectIndirectExercises = [
  // ─── 1. STATEMENTS & TENSE BACKSHIFTS (7 Exercises) ───
  DirectIndirectExerciseItem(
    category: 'STATEMENTS',
    speechType: 'Present Simple -> Past Simple',
    rule: "Shift 'am/is' to 'was' when reporting past statements.",
    directQuote: "She said, 'I am happy.'",
    promptSentence: "Direct: 'I am happy.' → She said she ___ happy.",
    targetWord: "was",
    acceptableWords: ["was", "that she was"],
    fullSentence: "She said she was happy.",
    localizedHints: {
      'Tamil': "Present 'am' இறந்தகாலത്തിൽ 'was' ஆக மாறும்.",
      'Malayalam': "Present 'am' എന്നത് പാസ്റ്റിൽ 'was' ആയി മാറുന്നു.",
      'Telugu': "ప్రెసెంట్ 'am' పాస్ట్‌లో 'was' గా మారుతుంది.",
      'Hindi': "Present 'am' पास्ट में 'was' बन जाता है।",
      'Kannada': "ಪ್ರೆಸೆಂಟ್ 'am' ಪಾಸ್ಟ್‌ನಲ್ಲಿ 'was' ಆಗುತ್ತದೆ.",
      'English': "Present 'am' backshifts to past 'was'.",
    },
    localizedTranslations: {
      'Tamil': "அவள் தான் மகிழ்ச்சியாக இருப்பதாக கூறினாள்.",
      'Malayalam': "താൻ സന്തുഷ്ടയാണെന്ന് അവൾ പറഞ്ഞു.",
      'Telugu': "ఆమె సంతోషంగా ఉన్నానని చెప్పింది.",
      'Hindi': "उसने कहा कि वह खुश थी।",
      'Kannada': "ಅವಳು ತಾನು ಸಂತೋಷವಾಗಿದ್ದೇನೆ ಎಂದು ಹೇಳಿದಳು.",
      'English': "She reported that she was happy.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'STATEMENTS',
    speechType: 'Present Simple -> Past Simple',
    rule: "Drop quotation marks and shift present tense verb to past tense.",
    directQuote: "She said, 'I am tired.'",
    promptSentence: "Direct: 'I am tired.' → She said that she ___ tired.",
    targetWord: "was",
    acceptableWords: ["was"],
    fullSentence: "She said that she was tired.",
    localizedHints: {
      'Tamil': "'am' என்பதை 'was' ஆக மாற்றி அறிக்கை செய்யுங்கள்.",
      'Malayalam': "'am' എന്നത് 'was' എന്ന് മാറ്റി റിപ്പോർട്ട് ചെയ്യുക.",
      'Telugu': "'am' ని 'was' గా మార్చి చెప్పండి.",
      'Hindi': "'am' को 'was' में बदलें।",
      'Kannada': "'am' ಅನ್ನು 'was' ಎಂದು ಬದಲಾಯಿಸಿ.",
      'English': "Backshift 'am' to 'was'.",
    },
    localizedTranslations: {
      'Tamil': "தான் சோர்வாக இருப்பதாக அவள் கூறினாள்.",
      'Malayalam': "താൻ ക്ഷീണിതയാണെന്ന് അവൾ പറഞ്ഞു.",
      'Telugu': "తాను అలసిపోయానని ఆమె చెప్పింది.",
      'Hindi': "उसने कहा कि वह थकी हुई थी।",
      'Kannada': "ತಾನು ದಣಿದಿದ್ದೇನೆ ಎಂದು ಅವಳು ಹೇಳಿದಳು.",
      'English': "She said that she was tired.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'STATEMENTS',
    speechType: 'Present Perfect -> Past Perfect',
    rule: "Present perfect 'have finished' shifts back to past perfect 'had finished'.",
    directQuote: "He said, 'I have finished.'",
    promptSentence: "Direct: 'I have finished.' → He said he ___ finished.",
    targetWord: "had",
    acceptableWords: ["had", "had finished"],
    fullSentence: "He said he had finished.",
    localizedHints: {
      'Tamil': "'have' என்பது இறந்தகாலத்தில் 'had' ஆக மாறும்.",
      'Malayalam': "'have' എന്നത് റിപ്പോർട്ട് ചെയ്യുമ്പോൾ 'had' ആയി മാറുന്നു.",
      'Telugu': "'have' పాస్ట్ పర్‌ఫెక్ట్‌లో 'had' గా మారుతుంది.",
      'Hindi': "'have' पास्ट परफेक्ट में 'had' में बदलता है।",
      'Kannada': "'have' ಪಾಸ್ಟ್‌ನಲ್ಲಿ 'had' ಆಗುತ್ತದೆ.",
      'English': "'have' shifts to past perfect 'had'.",
    },
    localizedTranslations: {
      'Tamil': "தான் முடித்துவிட்டதாக அவன் கூறினான்.",
      'Malayalam': "താൻ ജോലി പൂർത്തിയാക്കിയെന്ന് അവൻ പറഞ്ഞു.",
      'Telugu': "తాను పూర్తి చేశానని అతను చెప్పాడు.",
      'Hindi': "उसने कहा कि उसने काम पूरा कर लिया था।",
      'Kannada': "ತಾನು ಮುಗಿಸಿದ್ದೇನೆ ಎಂದು ಅವನು ಹೇಳಿದನು.",
      'English': "He said he had finished.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'STATEMENTS',
    speechType: 'Modal: will -> would',
    rule: "The future modal 'will' shifts back to 'would' in reported speech.",
    directQuote: "She said, 'I will call you tomorrow.'",
    promptSentence: "Direct: 'I will call you tomorrow.' → She said she ___ call me the next day.",
    targetWord: "would",
    acceptableWords: ["would"],
    fullSentence: "She said she would call me the next day.",
    localizedHints: {
      'Tamil': "'will' என்பது 'would' ஆக மாறும்; 'tomorrow' என்பது 'the next day' ஆகும்.",
      'Malayalam': "'will' എന്നത് 'would' ആയി മാറും; 'tomorrow' എന്നത് 'the next day' ആകും.",
      'Telugu': "'will' ని 'would' గా మార్చాలి; 'tomorrow' 'the next day' అవుతుంది.",
      'Hindi': "'will' को 'would' में बदलें।",
      'Kannada': "'will' ಅನ್ನು 'would' ಎಂದು ಬದಲಾಯಿಸಿ.",
      'English': "'will' shifts to 'would', and 'tomorrow' shifts to 'the next day'.",
    },
    localizedTranslations: {
      'Tamil': "அடுத்த நாள் என்னை அழைப்பதாக அவள் கூறினாள்.",
      'Malayalam': "അടുത്ത ദിവസം എന്നെ വിളിക്കാമെന്ന് അവൾ പറഞ്ഞു.",
      'Telugu': "మరుసటి రోజు నన్ను పిలుస్తానని ఆమె చెప్పింది.",
      'Hindi': "उसने कहा कि वह अगले दिन मुझे फोन करेगी।",
      'Kannada': "ಮರುದಿನ ನನಗೆ ಕರೆ ಮಾಡುವುದಾಗಿ ಅವಳು ಹೇಳಿದಳು.",
      'English': "She said she would call me the next day.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'STATEMENTS',
    speechType: 'Modal: can -> could',
    rule: "'can' indicates ability; in reported speech it shifts back to 'could'.",
    directQuote: "He said, 'I can swim very fast.'",
    promptSentence: "Direct: 'I can swim very fast.' → He said he ___ swim very fast.",
    targetWord: "could",
    acceptableWords: ["could"],
    fullSentence: "He said he could swim very fast.",
    localizedHints: {
      'Tamil': "திறமையை குறிக்கும் 'can' மறைமுக கூற்றில் 'could' ஆக மாறும்.",
      'Malayalam': "'can' എന്നത് റിപ്പോർട്ടഡ് സ്പീച്ചിൽ 'could' ആയി മാറും.",
      'Telugu': "'can' ని 'could' గా మార్చాలి.",
      'Hindi': "'can' को 'could' में बदलें।",
      'Kannada': "'can' ಅನ್ನು 'could' ಎಂದು ಬದಲಾಯಿಸಿ.",
      'English': "Shift 'can' back to 'could'.",
    },
    localizedTranslations: {
      'Tamil': "தன்னால் வேகமாக நீந்த முடியும் என்று அவன் கூறினான்.",
      'Malayalam': "തനിക്ക് വേഗത്തിൽ നീന്താൻ കഴിയുമെന്ന് അവൻ പറഞ്ഞു.",
      'Telugu': "తాను వేగంగా ఈదగలనని అతను చెప్పాడు.",
      'Hindi': "उसने कहा कि वह बहुत तेजी से तैर सकता था।",
      'Kannada': "ತಾನು ವೇಗವಾಗಿ ಈಜಬಲ್ಲೆ ಎಂದು ಅವನು ಹೇಳಿದನು.",
      'English': "He said he could swim very fast.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'STATEMENTS',
    speechType: 'Present Continuous -> Past Continuous',
    rule: "Present continuous 'are playing' shifts back to past continuous 'were playing'.",
    directQuote: "She said, 'They are playing football.'",
    promptSentence: "Direct: 'They are playing football.' → She said they ___ playing football.",
    targetWord: "were",
    acceptableWords: ["were"],
    fullSentence: "She said they were playing football.",
    localizedHints: {
      'Tamil': "பன்மை 'are' என்பது இறந்தகாலத்தில் 'were' ஆக மாறும்.",
      'Malayalam': "ബഹുവചനമായ 'are' പാസ്റ്റിൽ 'were' ആയി മാറും.",
      'Telugu': "'are' పాస్ట్‌లో 'were' గా మారుతుంది.",
      'Hindi': "'are' पास्ट में 'were' बन जाता है।",
      'Kannada': "'are' ಪಾಸ್ಟ್‌ನಲ್ಲಿ 'were' ಆಗುತ್ತದೆ.",
      'English': "Plural present continuous 'are' shifts to past continuous 'were'.",
    },
    localizedTranslations: {
      'Tamil': "அவர்கள் கால்பந்து விளையாடிக்கொண்டிருந்ததாக அவள் கூறினாள்.",
      'Malayalam': "അവർ ഫുട്ബോൾ കളിക്കുകയാണെന്ന് അവൾ പറഞ്ഞു.",
      'Telugu': "వారు ఫుట్‌బాల్ ఆడుతున్నారని ఆమె చెప్పింది.",
      'Hindi': "उसने कहा कि वे फुटबॉल खेल रहे थे।",
      'Kannada': "ಅವರು ಫುಟ್‌ಬಾಲ್ ಆಡುತ್ತಿದ್ದಾರೆ ಎಂದು ಅವಳು ಹೇಳಿದಳು.",
      'English': "She said they were playing football.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'STATEMENTS',
    speechType: 'Past Simple -> Past Perfect',
    rule: "Past simple 'bought' shifts further back to past perfect 'had bought'.",
    directQuote: "He said, 'I bought a new car yesterday.'",
    promptSentence: "Direct: 'I bought a new car yesterday.' → He said he ___ bought a new car the day before.",
    targetWord: "had",
    acceptableWords: ["had", "had bought"],
    fullSentence: "He said he had bought a new car the day before.",
    localizedHints: {
      'Tamil': "இறந்தகால 'bought' என்பது பாஸ்ட் பெர்பெக்ட்டில் 'had bought' ஆகும்.",
      'Malayalam': "പാസ്റ്റ് സിംപിൾ 'bought' എന്നത് 'had bought' ആയി മാറും.",
      'Telugu': "పాస్ట్ సింపుల్ 'bought' 'had bought' గా మారుతుంది.",
      'Hindi': "Past simple 'bought' 'had bought' में बदलता है।",
      'Kannada': "ಪಾಸ್ಟ್ ಸಿಂಪಲ್ 'bought' 'had bought' ಆಗುತ್ತದೆ.",
      'English': "Past simple backshifts to past perfect 'had'.",
    },
    localizedTranslations: {
      'Tamil': "முந்தைய நாள் தான் ஒரு புதிய கார் வாங்கியதாக அவன் கூறினான்.",
      'Malayalam': "തലേദിവസം താൻ പുതിയ കാർ വാങ്ങിയെന്ന് അവൻ പറഞ്ഞു.",
      'Telugu': "నిన్న తాను కొత్త కారు కొన్నానని అతను చెప్పాడు.",
      'Hindi': "उसने कहा कि उसने पिछले दिन एक नई कार खरीदी थी।",
      'Kannada': "ಹಿಂದಿನ ದಿನ ತಾನು ಹೊಸ ಕಾರು ಖರೀದಿಸಿದ್ದಾಗಿ ಅವನು ಹೇಳಿದನು.",
      'English': "He said he had bought a new car the day before.",
    },
  ),

  // ─── 2. REPORTED QUESTIONS (5 Exercises) ───
  DirectIndirectExerciseItem(
    category: 'QUESTIONS',
    speechType: 'Yes/No Question -> if / whether',
    rule: "Yes/No questions use 'if' or 'whether' with statement word order and NO question mark.",
    directQuote: "He asked, 'Do you like coffee?'",
    promptSentence: "Direct: 'Do you like coffee?' → He asked ___ I liked coffee.",
    targetWord: "if",
    acceptableWords: ["if", "whether"],
    fullSentence: "He asked if I liked coffee.",
    localizedHints: {
      'Tamil': "ஆம்/இல்லை கேள்விகளுக்கு 'if' அல்லது 'whether' பயன்படுத்தவும்.",
      'Malayalam': "Yes/No ചോദ്യങ്ങൾ റിപ്പോർട്ട് ചെയ്യുമ്പോൾ 'if' അല്ലെങ്കിൽ 'whether' ചേർക്കുക.",
      'Telugu': "Yes/No ప్రశ్నలను రిపోర్ట్ చేసేటప్పుడు 'if' లేదా 'whether' వాడాలి.",
      'Hindi': "Yes/No प्रश्नों के लिए 'if' या 'whether' का प्रयोग करें।",
      'Kannada': "Yes/No ಪ್ರಶ್ನೆಗಳಿಗೆ 'if' ಅಥವಾ 'whether' ಬಳಸಿ.",
      'English': "Use 'if' or 'whether' for reported Yes/No questions.",
    },
    localizedTranslations: {
      'Tamil': "எனக்கு காபி பிடிக்குமா என்று அவன் கேட்டான்.",
      'Malayalam': "എനിക്ക് കോഫി ഇഷ്ടമാണോ എന്ന് അവൻ ചോദിച്ചു.",
      'Telugu': "నాకు కాఫీ ఇష్టమా అని అతను అడిగాడు.",
      'Hindi': "उसने मुझसे पूछा कि क्या मुझे कॉफी पसंद है।",
      'Kannada': "ನನಗೆ ಕಾಫಿ ಇಷ್ಟವೇ ಎಂದು ಅವನು ಕೇಳಿದನು.",
      'English': "He asked if I liked coffee.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'QUESTIONS',
    speechType: 'Yes/No Question -> if / whether',
    rule: "Connect the question with 'if', change 'you' to 'I', and 'like' to 'liked'.",
    directQuote: "He asked, 'Do you like pizza?'",
    promptSentence: "Direct: 'Do you like pizza?' → He asked ___ I liked pizza.",
    targetWord: "if",
    acceptableWords: ["if", "whether"],
    fullSentence: "He asked if I liked pizza.",
    localizedHints: {
      'Tamil': "கேள்வியை அறிக்கையாக மாற்ற 'if' இணைக்கவும்.",
      'Malayalam': "'if' ചേർത്ത് റിപ്പോർട്ട് ചെയ്യുക, ചോദ്യചിഹ്നം ഒഴിവാക്കുക.",
      'Telugu': "'if' ని వాడి వాక్యాన్ని సాధారణంగా మార్చండి.",
      'Hindi': "'if' जोड़कर प्रश्न को कथन में बदलें।",
      'Kannada': "'if' ಸೇರಿಸಿ ವಾಕ್ಯವನ್ನು ಬದಲಾಯಿಸಿ.",
      'English': "Connect with 'if' and shift verb to past.",
    },
    localizedTranslations: {
      'Tamil': "எனக்கு பீட்சா பிடிக்குமா என்று அவன் கேட்டான்.",
      'Malayalam': "എനിക്ക് പിസ്സ ഇഷ്ടമാണോ എന്ന് അവൻ ചോദിച്ചു.",
      'Telugu': "నాకు పిజ్జా ఇష్టమా అని అతను అడిగాడు.",
      'Hindi': "उसने पूछा कि क्या मुझे पिज्जा पसंद है।",
      'Kannada': "ನನಗೆ ಪಿಜ್ಜಾ ಇಷ್ಟವೇ ಎಂದು ಅವನು ಕೇಳಿದನು.",
      'English': "He asked if I liked pizza.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'QUESTIONS',
    speechType: 'Wh- Question -> Statement Word Order',
    rule: "Wh- questions keep the question word ('where') with statement word order and past tense.",
    directQuote: "She asked, 'Where do you live?'",
    promptSentence: "Direct: 'Where do you live?' → She asked where I ___.",
    targetWord: "lived",
    acceptableWords: ["lived"],
    fullSentence: "She asked where I lived.",
    localizedHints: {
      'Tamil': "'live' என்பது இறந்தகாலத்தில் 'lived' ஆக மாறும்; கேள்வி வரிசை வேண்டாம்.",
      'Malayalam': "'live' എന്നത് പാസ്റ്റിൽ 'lived' ആയി മാറും; ചോദ്യരൂപം ഒഴിവാക്കണം.",
      'Telugu': "'live' పాస్ట్‌లో 'lived' అవుతుంది.",
      'Hindi': "'live' को पास्ट में 'lived' में बदलें।",
      'Kannada': "'live' ಅನ್ನು 'lived' ಎಂದು ಬದಲಾಯಿಸಿ.",
      'English': "Use statement word order (Subject + lived), not 'where did I live'.",
    },
    localizedTranslations: {
      'Tamil': "நான் எங்கே வசிக்கிறேன் என்று அவள் கேட்டாள்.",
      'Malayalam': "ഞാൻ എവിടെയാണ് താമസിക്കുന്നതെന്ന് അവൾ ചോദിച്ചു.",
      'Telugu': "నేను ఎక్కడ నివసిస్తున్నానో ఆమె అడిగింది.",
      'Hindi': "उसने पूछा कि मैं कहाँ रहता था।",
      'Kannada': "ನಾನು ಎಲ್ಲಿ ವಾಸಿಸುತ್ತಿದ್ದೇನೆ ಎಂದು ಅವಳು ಕೇಳಿದಳು.",
      'English': "She asked where I lived.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'QUESTIONS',
    speechType: 'Yes/No Question -> whether',
    rule: "'whether' is preferred when considering formal alternatives or options.",
    directQuote: "He asked, 'Have you seen this movie?'",
    promptSentence: "Direct: 'Have you seen this movie?' → He asked ___ I had seen that movie.",
    targetWord: "whether",
    acceptableWords: ["whether", "if"],
    fullSentence: "He asked whether I had seen that movie.",
    localizedHints: {
      'Tamil': "'whether' அல்லது 'if' பயன்படுத்தி அறிக்கை செய்யலாம்.",
      'Malayalam': "'whether' അല്ലെങ്കിൽ 'if' ഉപയോഗിച്ച് റിപ്പോർട്ട് ചെയ്യാം.",
      'Telugu': "'whether' లేదా 'if' వాడవచ్చు.",
      'Hindi': "'whether' या 'if' का प्रयोग करें।",
      'Kannada': "'whether' ಅಥವಾ 'if' ಬಳಸಿ.",
      'English': "Use 'whether' (or 'if') with past perfect 'had seen'.",
    },
    localizedTranslations: {
      'Tamil': "நான் அந்த படத்தை பார்த்திருக்கிறேனா என்று அவன் கேட்டான்.",
      'Malayalam': "ഞാൻ ആ സിനിമ കണ്ടിട്ടുണ്ടോ എന്ന് അവൻ ചോദിച്ചു.",
      'Telugu': "నేను ఆ సినిమా చూశానో లేదో అతను అడిగాడు.",
      'Hindi': "उसने पूछा कि क्या मैंने वह फिल्म देखी थी।",
      'Kannada': "ನಾನು ಆ ಚಲನಚಿತ್ರವನ್ನು ನೋಡಿದ್ದೇನೆಯೇ ಎಂದು ಅವನು ಕೇಳಿದನು.",
      'English': "He asked whether I had seen that movie.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'QUESTIONS',
    speechType: 'Wh- Question -> Time & Past Tense',
    rule: "Wh- question keeps 'what time', subject 'the train', and shifts verb 'leaves' to 'left'.",
    directQuote: "She asked, 'What time does the train leave?'",
    promptSentence: "Direct: 'What time does the train leave?' → She asked what time the train ___.",
    targetWord: "left",
    acceptableWords: ["left"],
    fullSentence: "She asked what time the train left.",
    localizedHints: {
      'Tamil': "'leave' என்பது இறந்தகாலத்தில் 'left' ஆக மாறும்.",
      'Malayalam': "'leave' എന്നത് പാസ്റ്റിൽ 'left' ആയി മാറും.",
      'Telugu': "'leave' పాస్ట్‌లో 'left' అవుతుంది.",
      'Hindi': "'leave' का पास्ट टेंस 'left' होगा।",
      'Kannada': "'leave' ಅನ್ನು 'left' ಎಂದು ಬದಲಾಯಿಸಿ.",
      'English': "Shift 'leave' to past tense 'left'.",
    },
    localizedTranslations: {
      'Tamil': "ரயில் எத்தனை மணிக்கு புறப்பட்டது என்று அவள் கேட்டாள்.",
      'Malayalam': "ട്രെയിൻ ഏത് സമയത്താണ് പുറപ്പെട്ടതെന്ന് അവൾ ചോദിച്ചു.",
      'Telugu': "రైలు ఏ సమయానికి బయలుదేరిందో ఆమె అడిగింది.",
      'Hindi': "उसने पूछा कि ट्रेन किस समय रवाना हुई।",
      'Kannada': "ರೈಲು ಯಾವ ಸಮಯಕ್ಕೆ ಹೊರಟಿತು ಎಂದು ಅವಳು ಕೇಳಿದಳು.",
      'English': "She asked what time the train left.",
    },
  ),

  // ─── 3. COMMANDS, REQUESTS & NEGATIVES (5 Exercises) ───
  DirectIndirectExerciseItem(
    category: 'COMMANDS',
    speechType: 'Direct Command -> to + verb',
    rule: "Reported commands use 'told + object + to + base verb'.",
    directQuote: "He said, 'Sit down.'",
    promptSentence: "Direct: 'Sit down.' → He told me ___ sit down.",
    targetWord: "to",
    acceptableWords: ["to"],
    fullSentence: "He told me to sit down.",
    localizedHints: {
      'Tamil': "கட்டளை வாக்கியங்களை இணைக்க 'to' பயன்படுத்தவும்.",
      'Malayalam': "കമാൻഡുകൾ റിപ്പോർട്ട് ചെയ്യാൻ 'to + verb' ഉപയോഗിക്കുക.",
      'Telugu': "కమాండ్స్ రిపోర్ట్ చేయడానికి 'to' వాడాలి.",
      'Hindi': "आदेशों को रिपोर्ट करने के लिए 'to' का प्रयोग करें।",
      'Kannada': "ಆಜ್ಞೆಗಳನ್ನು ರಿಪೋರ್ಟ್ ಮಾಡಲು 'to' ಬಳಸಿ.",
      'English': "Use 'to + base verb' for imperative commands.",
    },
    localizedTranslations: {
      'Tamil': "அவன் என்னை உட்காருமாறு கூறினான்.",
      'Malayalam': "ഇരിക്കാൻ അവൻ എന്നോട് ആവശ്യപ്പെട്ടു.",
      'Telugu': "కూర్చోమని అతను నాతో చెప్పాడు.",
      'Hindi': "उसने मुझे बैठने के लिए कहा।",
      'Kannada': "ಕುಳಿತುಕೊಳ್ಳಲು ಅವನು ನನಗೆ ಹೇಳಿದನು.",
      'English': "He told me to sit down.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'COMMANDS',
    speechType: 'Polite Request -> asked + to + verb',
    rule: "Polite requests with 'Please' use 'asked + object + to + verb' (drop 'please').",
    directQuote: "She said, 'Please help me with this box.'",
    promptSentence: "Direct: 'Please help me.' → She asked me ___ help her.",
    targetWord: "to",
    acceptableWords: ["to"],
    fullSentence: "She asked me to help her.",
    localizedHints: {
      'Tamil': "'Please' நீக்கப்பட்டு 'asked me to help' என மாறும்.",
      'Malayalam': "'Please' ഒഴിവാക്കി 'asked me to help' എന്ന് എഴുതുക.",
      'Telugu': "'Please' తీసివేసి 'asked me to help' అని మార్చాలి.",
      'Hindi': "'Please' हटाकर 'asked me to help' का प्रयोग करें।",
      'Kannada': "'Please' ತೆಗೆದು 'asked me to help' ಎಂದು ಬಳಸಿ.",
      'English': "Drop 'please' and use 'asked + object + to + verb'.",
    },
    localizedTranslations: {
      'Tamil': "அவளுக்கு உதவுமாறு அவள் என்னிடம் வேண்டினாள்.",
      'Malayalam': "അവളെ സഹായിക്കാൻ അവൾ എന്നോട് ആവശ്യപ്പെട്ടു.",
      'Telugu': "తనకు సహాయం చేయమని ఆమె నన్ను అడిగింది.",
      'Hindi': "उसने मुझसे उसकी मदद करने का अनुरोध किया।",
      'Kannada': "ತನಗೆ ಸಹಾಯ ಮಾಡುವಂತೆ ಅವಳು ನನ್ನನ್ನು ಕೇಳಿದಳು.",
      'English': "She asked me to help her.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'COMMANDS',
    speechType: 'Negative Command -> not to + verb',
    rule: "Negative commands with 'Don't' become 'told/asked + object + not to + verb'.",
    directQuote: "He said, 'Don't be late.'",
    promptSentence: "Direct: 'Don't be late.' → He told me ___ to be late.",
    targetWord: "not",
    acceptableWords: ["not"],
    fullSentence: "He told me not to be late.",
    localizedHints: {
      'Tamil': "எதிர்மறை கட்டளைக்கு 'not to' பயன்படுத்தவும்.",
      'Malayalam': "'Don't' എന്നത് 'not to' ആയി മാറും.",
      'Telugu': "'Don't' ని 'not to' గా మార్చాలి.",
      'Hindi': "'Don't' को 'not to' में बदलें।",
      'Kannada': "'Don't' ಅನ್ನು 'not to' ಎಂದು ಬದಲಾಯಿಸಿ.",
      'English': "Negative command 'Don't' shifts to 'not to'.",
    },
    localizedTranslations: {
      'Tamil': "தாமதமாக வர வேண்டாம் என்று அவன் என்னிடம் கூறினான்.",
      'Malayalam': "വൈകരുതെന്ന് അവൻ എന്നോട് പറഞ്ഞു.",
      'Telugu': "ఆలస్యం చేయవద్దని అతను నాతో చెప్పాడు.",
      'Hindi': "उसने मुझे देर न करने के लिए कहा।",
      'Kannada': "ತಡಮಾಡಬೇಡಿ ಎಂದು ಅವನು ನನಗೆ ಹೇಳಿದನು.",
      'English': "He told me not to be late.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'COMMANDS',
    speechType: 'Instruction -> told + to + verb',
    rule: "Direct instruction becomes 'told + object + to + verb'.",
    directQuote: "Mother said, 'Close the door quietly.'",
    promptSentence: "Direct: 'Close the door quietly.' → Mother told us ___ close the door quietly.",
    targetWord: "to",
    acceptableWords: ["to"],
    fullSentence: "Mother told us to close the door quietly.",
    localizedHints: {
      'Tamil': "கட்டளைக்கு 'to' இணைக்கவும்.",
      'Malayalam': "നിർദ്ദേശത്തിന് ശേഷം 'to' ചേർക്കുക.",
      'Telugu': "సూచనకు 'to' జోడించాలి.",
      'Hindi': "निर्देश के लिए 'to' जोड़ें।",
      'Kannada': "ಸೂಚನೆಗೆ 'to' ಸೇರಿಸಿ.",
      'English': "Connect imperative instruction with infinitive 'to'.",
    },
    localizedTranslations: {
      'Tamil': "கதவை சத்தமின்றி மூடுமாறு அம்மா எங்களிடம் கூறினார்.",
      'Malayalam': "ശബ്ദമുണ്ടാക്കാതെ വാതിൽ അടയ്ക്കാൻ അമ്മ ഞങ്ങളോട് പറഞ്ഞു.",
      'Telugu': "శబ్దం చేయకుండా తలుపు వేయమని అమ్మ మాతో చెప్పింది.",
      'Hindi': "माँ ने हमसे धीरे से दरवाजा बंद करने को कहा।",
      'Kannada': "ಶಬ್ದ ಮಾಡದೆ ಬಾಗಿಲು ಮುಚ್ಚುವಂತೆ ಅಮ್ಮ ನಮಗೆ ಹೇಳಿದರು.",
      'English': "Mother told us to close the door quietly.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'COMMANDS',
    speechType: 'Negative Prohibition -> not to + verb',
    rule: "'Do not touch' becomes 'told them not to touch'.",
    directQuote: "The officer said, 'Do not touch the wet paint.'",
    promptSentence: "Direct: 'Do not touch the paint.' → The officer told them ___ to touch the paint.",
    targetWord: "not",
    acceptableWords: ["not"],
    fullSentence: "The officer told them not to touch the paint.",
    localizedHints: {
      'Tamil': "எதிர்மறைக்கு 'not' சேர்க்கவும்.",
      'Malayalam': "വിലക്കുകൾക്ക് 'not to' ചേർക്കുക.",
      'Telugu': "నెగెటివ్ నిబంధనకు 'not to' వాడాలి.",
      'Hindi': "नकारात्मक निषेध के लिए 'not to' जोड़ें।",
      'Kannada': "ನಿಷೇಧಕ್ಕೆ 'not to' ಸೇರಿಸಿ.",
      'English': "Prohibition 'do not' becomes 'not to'.",
    },
    localizedTranslations: {
      'Tamil': "ஈரமான பெயிண்ட்டை தொட வேண்டாம் என்று அதிகாரி அவர்களிடம் கூறினார்.",
      'Malayalam': "നനഞ്ഞ പെയിന്റിൽ തൊടരുതെന്ന് ഓഫീസർ അവരോട് പറഞ്ഞു.",
      'Telugu': "తడి పెయింట్‌ను తాకవద్దని అధికారి వారితో చెప్పారు.",
      'Hindi': "अधिकारी ने उन्हें गीले पेंट को न छूने के लिए कहा।",
      'Kannada': "ಹಸಿ ಬಣ್ಣವನ್ನು ಮುಟ್ಟಬೇಡಿ ಎಂದು ಅಧಿಕಾರಿ ಅವರಿಗೆ ಹೇಳಿದರು.",
      'English': "The officer told them not to touch the paint.",
    },
  ),

  // ─── 4. TIME & PRONOUN SHIFTS (3 Exercises) ───
  DirectIndirectExerciseItem(
    category: 'TIME_PRONOUNS',
    speechType: 'Time Shift: tomorrow -> the next day',
    rule: "'tomorrow' shifts to 'the next day' or 'the following day'.",
    directQuote: "He said, 'I will go tomorrow.'",
    promptSentence: "Direct: 'I will go tomorrow.' → He said he would go the ___ day.",
    targetWord: "next",
    acceptableWords: ["next", "following"],
    fullSentence: "He said he would go the next day.",
    localizedHints: {
      'Tamil': "'tomorrow' என்பது 'the next day' அல்லது 'the following day' ஆக மாறும்.",
      'Malayalam': "'tomorrow' എന്നത് 'the next day' എന്ന് മാറും.",
      'Telugu': "'tomorrow' 'the next day' గా మారుతుంది.",
      'Hindi': "'tomorrow' 'the next day' में बदलता है।",
      'Kannada': "'tomorrow' 'the next day' ಆಗುತ್ತದೆ.",
      'English': "'tomorrow' changes to 'the next day'.",
    },
    localizedTranslations: {
      'Tamil': "அடுத்த நாள் தான் போவதாக அவன் கூறினான்.",
      'Malayalam': "അടുത്ത ദിവസം താൻ പോകുമെന്ന് അവൻ പറഞ്ഞു.",
      'Telugu': "మరుసటి రోజు తాను వెళ్తానని అతను చెప్పాడు.",
      'Hindi': "उसने कहा कि वह अगले दिन जाएगा।",
      'Kannada': "ಮರುದಿನ ತಾನು ಹೋಗುವುದಾಗಿ ಅವನು ಹೇಳಿದನು.",
      'English': "He said he would go the next day.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'TIME_PRONOUNS',
    speechType: 'Time Shift: today -> that day',
    rule: "'today' shifts to 'that day' when reporting past conversations.",
    directQuote: "She said, 'I am busy today.'",
    promptSentence: "Direct: 'I am busy today.' → She said that she was busy ___ day.",
    targetWord: "that",
    acceptableWords: ["that"],
    fullSentence: "She said that she was busy that day.",
    localizedHints: {
      'Tamil': "'today' என்பது 'that day' ஆக மாறும்.",
      'Malayalam': "'today' എന്നത് 'that day' ആയി മാറും.",
      'Telugu': "'today' 'that day' గా మారుతుంది.",
      'Hindi': "'today' 'that day' में बदलता है।",
      'Kannada': "'today' 'that day' ಆಗುತ್ತದೆ.",
      'English': "'today' shifts back to 'that day'.",
    },
    localizedTranslations: {
      'Tamil': "அன்று தான் வேலையாக இருப்பதாக அவள் கூறினாள்.",
      'Malayalam': "അന്ന് താൻ തിരക്കിലാണെന്ന് അവൾ പറഞ്ഞു.",
      'Telugu': "ఆ రోజు తాను బిజీగా ఉన్నానని ఆమె చెప్పింది.",
      'Hindi': "उसने कहा कि वह उस दिन व्यस्त थी।",
      'Kannada': "ಅಂದು ತಾನು ಬಿಡುವಿಲ್ಲದೆ ಇರುವುದಾಗಿ ಅವಳು ಹೇಳಿದಳು.",
      'English': "She said that she was busy that day.",
    },
  ),

  DirectIndirectExerciseItem(
    category: 'TIME_PRONOUNS',
    speechType: 'Place Shift: this -> that',
    rule: "'this place' becomes 'that place' and 'here' becomes 'there'.",
    directQuote: "He said, 'I like this place.'",
    promptSentence: "Direct: 'I like this place.' → He said he liked ___ place.",
    targetWord: "that",
    acceptableWords: ["that"],
    fullSentence: "He said he liked that place.",
    localizedHints: {
      'Tamil': "அண்மை சுட்டு 'this' சேய்மை சுட்டு 'that' ஆக மாறும்.",
      'Malayalam': "'this' എന്നത് 'that' ആയി മാറും.",
      'Telugu': "'this' 'that' గా మారుతుంది.",
      'Hindi': "'this' 'that' में बदलता है।",
      'Kannada': "'this' 'that' ಆಗುತ್ತದೆ.",
      'English': "'this' shifts to distant 'that'.",
    },
    localizedTranslations: {
      'Tamil': "தனக்கு அந்த இடம் பிடிக்கும் என்று அவன் கூறினான்.",
      'Malayalam': "തനിക്ക് ആ സ്ഥലം ഇഷ്ടപ്പെട്ടുവെന്ന് അവൻ പറഞ്ഞു.",
      'Telugu': "తనకు ఆ ప్రదేశం ఇష్టమని అతను చెప్పాడు.",
      'Hindi': "उसने कहा कि उसे वह जगह पसंद थी।",
      'Kannada': "ತನಗೆ ಆ ಸ್ಥಳ ಇಷ್ಟವಾಯಿತು ಎಂದು ಅವನು ಹೇಳಿದನು.",
      'English': "He said he liked that place.",
    },
  ),
];
