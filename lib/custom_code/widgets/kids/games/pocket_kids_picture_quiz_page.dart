import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_sfx.dart';

/// ❓ Question Model for Picture & Counting Quizzes
class PictureQuizQuestion {
  final String category;
  final String title;
  final String visualEmoji;
  final int count; // for numbers counting quiz
  final List<String> options;
  final int correctIndex;
  final String celebrationNote;

  const PictureQuizQuestion({
    required this.category,
    required this.title,
    required this.visualEmoji,
    this.count = 1,
    required this.options,
    required this.correctIndex,
    required this.celebrationNote,
  });
}

/// ❓ Pocket Kids Picture Quiz Page (Reference Image 3 Screen 2 & Image 4 Screen 2)
///
/// Implements:
/// - "Which animal is this?" with 4 pastel choice buttons
/// - "How many apples?" counting quiz
/// - Soft rounded pastel theme matching Duolingo ABC & Lingokids
/// - Instant feedback with pronunciation and +15 KS score
class PocketKidsPictureQuizPage extends StatefulWidget {
  final String category; // 'Animals', 'Numbers', 'Fruits', 'Vegetables'
  final int day;
  final VoidCallback? onCompleted;

  const PocketKidsPictureQuizPage({
    super.key,
    this.category = 'Animals',
    this.day = 1,
    this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    String category = 'Animals',
    int day = 1,
    VoidCallback? onCompleted,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PocketKidsPictureQuizPage(
          category: category,
          day: day,
          onCompleted: onCompleted,
        ),
      ),
    );
  }

  @override
  State<PocketKidsPictureQuizPage> createState() =>
      _PocketKidsPictureQuizPageState();
}

class _PocketKidsPictureQuizPageState extends State<PocketKidsPictureQuizPage> {
  final FlutterTts _tts = FlutterTts();

  // Curated Questions Database
  static const List<PictureQuizQuestion> _allQuestions = [
    // Animals
    PictureQuizQuestion(
      category: 'Animals',
      title: 'Which animal is this?',
      visualEmoji: '🐘',
      options: ['Giraffe', 'Elephant', 'Zebra', 'Lion'],
      correctIndex: 1,
      celebrationNote: 'Yes! Elephant! Great job! 🐘',
    ),
    PictureQuizQuestion(
      category: 'Animals',
      title: 'Which animal is this?',
      visualEmoji: '🦁',
      options: ['Lion', 'Tiger', 'Bear', 'Dog'],
      correctIndex: 0,
      celebrationNote: 'King Lion! Roar! 🦁',
    ),
    PictureQuizQuestion(
      category: 'Animals',
      title: 'Which animal is this?',
      visualEmoji: '🦓',
      options: ['Horse', 'Zebra', 'Cow', 'Sheep'],
      correctIndex: 1,
      celebrationNote: 'Wonderful! Beautiful black & white Zebra! 🦓',
    ),
    PictureQuizQuestion(
      category: 'Animals',
      title: 'Which animal is this?',
      visualEmoji: '🐮',
      options: ['Cow', 'Goat', 'Deer', 'Panda'],
      correctIndex: 0,
      celebrationNote: 'Moo! Spot on Cow! 🐮',
    ),

    // Numbers & Counting (Reference Image 4 Screen 2)
    PictureQuizQuestion(
      category: 'Numbers',
      title: 'How many apples?',
      visualEmoji: '🍎',
      count: 7,
      options: ['5', '6', '7', '8'],
      correctIndex: 2,
      celebrationNote: 'Super counting! Exactly 7 red apples! 🍎',
    ),
    PictureQuizQuestion(
      category: 'Numbers',
      title: 'How many stars?',
      visualEmoji: '⭐',
      count: 5,
      options: ['3', '4', '5', '6'],
      correctIndex: 2,
      celebrationNote: 'High five! 5 shiny stars! ⭐',
    ),
    PictureQuizQuestion(
      category: 'Numbers',
      title: 'How many puppies?',
      visualEmoji: '🐶',
      count: 3,
      options: ['2', '3', '4', '5'],
      correctIndex: 1,
      celebrationNote: 'Woof woof! 3 cute puppies! 🐶',
    ),

    // Fruits
    PictureQuizQuestion(
      category: 'Fruits',
      title: 'What delicious fruit is this?',
      visualEmoji: '🍌',
      options: ['Apple', 'Banana', 'Orange', 'Strawberry'],
      correctIndex: 1,
      celebrationNote: 'Yummy yellow Banana! 🍌',
    ),
    PictureQuizQuestion(
      category: 'Fruits',
      title: 'What delicious fruit is this?',
      visualEmoji: '🍓',
      options: ['Grape', 'Mango', 'Strawberry', 'Lemon'],
      correctIndex: 2,
      celebrationNote: 'Sweet sweet Strawberry! 🍓',
    ),
  ];

  late List<PictureQuizQuestion> _questions;
  int _currentIndex = 0;
  int? _selectedOption;
  bool _isAnswerChecked = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _initTts();

    final filtered = _allQuestions
        .where((q) => q.category.toLowerCase() == widget.category.toLowerCase())
        .toList();
    _questions = filtered.isNotEmpty ? filtered : _allQuestions;

    _loadQuestion();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.42);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _loadQuestion() {
    final q = _questions[_currentIndex % _questions.length];
    _selectedOption = null;
    _isAnswerChecked = false;
    _speak(q.title);
    setState(() {});
  }

  void _onOptionTap(int index) {
    if (_isAnswerChecked) return;
    HapticFeedback.selectionClick();
    PocketGameAudioService.instance.playPopSound();

    final q = _questions[_currentIndex % _questions.length];
    _speak(q.options[index]);

    setState(() {
      _selectedOption = index;
    });
  }

  void _checkAnswer() {
    if (_selectedOption == null) return;
    final q = _questions[_currentIndex % _questions.length];
    final isCorrect = _selectedOption == q.correctIndex;

    setState(() {
      _isAnswerChecked = true;
    });

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playCoinSound();
      _score += 15;
      PocketKidsService.addKidsScore(15);
      PocketKidsService.addStars(1);
      _speak(q.celebrationNote);
    } else {
      HapticFeedback.heavyImpact();
      PocketGameSfx.instance.playErrorBuzz();
      _speak("Oops! It is ${q.options[q.correctIndex]}!");
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _loadQuestion();
    } else {
      // Completed!
      widget.onCompleted?.call();
      _showQuizVictory();
    }
  }

  void _showQuizVictory() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆 🌟 🧠', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Quiz Genius!',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You aced the quiz!\n+$_score Kids Score & 2 Star Cookies 🍪',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.black87, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text(
                'Complete 🚀',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex % _questions.length];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF9), // Cream Soft Minimalist Background
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header Bar: Close X, Pink Progress Bar, Gem Counter (Image 3 Screen 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 22),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFBCFE8), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Text('💎', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          '${25 + _score}',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFDB2777),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Main Question & Picture Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${q.category} Quiz',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      q.title,
                      style: GoogleFonts.fredoka(
                        color: const Color(0xFF0F172A),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Big Cartoon Picture / Counting Card (Image 3 Screen 2 & Image 4 Screen 2)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
                      ),
                      alignment: Alignment.center,
                      child: q.count > 1
                          ? Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: List.generate(
                                q.count,
                                (i) => Text(q.visualEmoji, style: const TextStyle(fontSize: 38)),
                              ),
                            )
                          : Text(q.visualEmoji, style: const TextStyle(fontSize: 90)),
                    ),

                    const SizedBox(height: 24),

                    // 4 Multiple Choice Options (2x2 Grid)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: q.options.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.3,
                      ),
                      itemBuilder: (context, idx) {
                        final optionText = q.options[idx];
                        final isSelected = _selectedOption == idx;

                        Color cardBg = Colors.white;
                        Color borderColor = const Color(0xFFE2E8F0);
                        Color textColor = const Color(0xFF1E293B);

                        if (_isAnswerChecked) {
                          if (idx == q.correctIndex) {
                            cardBg = const Color(0xFFDCFCE7); // Light green
                            borderColor = const Color(0xFF22C55E);
                            textColor = const Color(0xFF15803D);
                          } else if (isSelected && idx != q.correctIndex) {
                            cardBg = const Color(0xFFFEE2E2); // Light red
                            borderColor = const Color(0xFFEF4444);
                            textColor = const Color(0xFFB91C1C);
                          }
                        } else if (isSelected) {
                          cardBg = const Color(0xFFE0F2FE);
                          borderColor = const Color(0xFF38BDF8);
                          textColor = const Color(0xFF0369A1);
                        }

                        return GestureDetector(
                          onTap: () => _onOptionTap(idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: borderColor, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              optionText,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 3. Bottom Action Bar: Continue Button (Image 3 Screen 2)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    if (_isAnswerChecked) {
                      _nextQuestion();
                    } else if (_selectedOption != null) {
                      _checkAnswer();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _selectedOption != null
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _selectedOption != null
                          ? [
                              BoxShadow(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isAnswerChecked ? 'Continue ➔' : 'Check Answer',
                      style: GoogleFonts.outfit(
                        color: _selectedOption != null ? Colors.white : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
