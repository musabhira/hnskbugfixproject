import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_game_audio_service.dart';

/// 🐾 Kids Playdate Challenge Dialog
/// 
/// Replaces the adult "Citadel Attack / War" with a playful, 100% child-friendly
/// Mascot Playdate Challenge where young explorers (Ages 4–8) visit their animal buddies,
/// solve 3 quick fun picture/sound games, and win KS (Kids Score) & Golden Star Cookies 🍪!
class PocketKidsPlaydateChallengeDialog extends StatefulWidget {
  final KidMate mate;

  const PocketKidsPlaydateChallengeDialog({
    super.key,
    required this.mate,
  });

  static Future<bool?> show(BuildContext context, KidMate mate) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PocketKidsPlaydateChallengeDialog(mate: mate),
    );
  }

  @override
  State<PocketKidsPlaydateChallengeDialog> createState() =>
      _PocketKidsPlaydateChallengeDialogState();
}

class _PocketKidsPlaydateChallengeDialogState
    extends State<PocketKidsPlaydateChallengeDialog>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late AnimationController _bounceController;
  int _currentRound = 0; // 0, 1, 2
  int? _selectedOptionIdx;
  bool _isAnswerCorrect = false;
  bool _isFinished = false;

  final List<Map<String, dynamic>> _rounds = [
    {
      'question': 'Which friendly buddy says "ROAR"?',
      'tts': 'Which friendly buddy says roar?',
      'options': [
        {'emoji': '🦁', 'label': 'Lion'},
        {'emoji': '🐰', 'label': 'Bunny'},
        {'emoji': '🐸', 'label': 'Frog'},
      ],
      'correct': 0,
      'cheer': 'Super Roar! Great job! 🦁✨',
    },
    {
      'question': 'Pop the Balloon for letter "B"!',
      'tts': 'Pop the balloon for letter B!',
      'options': [
        {'emoji': '🎈 A', 'label': 'Apple'},
        {'emoji': '🎈 B', 'label': 'Balloon'},
        {'emoji': '🎈 C', 'label': 'Cat'},
      ],
      'correct': 1,
      'cheer': 'B is for Balloon! Pop pop pop! 🎈',
    },
    {
      'question': 'Pick the Yummy Red Apple for a treat!',
      'tts': 'Pick the yummy red apple for a treat!',
      'options': [
        {'emoji': '🍌', 'label': 'Banana'},
        {'emoji': '🍎', 'label': 'Red Apple'},
        {'emoji': '🍇', 'label': 'Grapes'},
      ],
      'correct': 1,
      'cheer': 'Yummy! Sparky loves red apples! 🍎😋',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.40);
      await _tts.setPitch(1.3); // High, cheerful cartoon voice!
      _speakCurrentQuestion();
    } catch (_) {}
  }

  void _speakCurrentQuestion() {
    if (_currentRound < _rounds.length) {
      final ttsPrompt = _rounds[_currentRound]['tts'] as String;
      _tts.speak(ttsPrompt);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _onSelectOption(int index) async {
    if (_selectedOptionIdx != null) return;
    final round = _rounds[_currentRound];
    final isCorrect = index == round['correct'];

    setState(() {
      _selectedOptionIdx = index;
      _isAnswerCorrect = isCorrect;
    });

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      PocketGameAudioService.instance.playCoinSound();
      final cheer = round['cheer'] as String;
      _tts.speak(cheer);

      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;

      if (_currentRound < _rounds.length - 1) {
        setState(() {
          _currentRound++;
          _selectedOptionIdx = null;
          _isAnswerCorrect = false;
        });
        _speakCurrentQuestion();
      } else {
        // All 3 rounds mastered!
        await PocketKidsService.addKidsScore(50);
        await PocketKidsService.addStars(3);
        await PocketKidsService.boostFriendship(widget.mate.id, 15);

        setState(() {
          _isFinished = true;
        });
        _tts.speak('Hooray! You won fifty Kids Score and three Golden Star Cookies!');
      }
    } else {
      HapticFeedback.lightImpact();
      _tts.speak('Oops! Try again little buddy!');
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        setState(() {
          _selectedOptionIdx = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final round = _rounds[_currentRound];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
          ),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: _isFinished ? _buildVictoryContent() : _buildGameplayContent(round),
        ),
      ),
    );
  }

  Widget _buildGameplayContent(Map<String, dynamic> round) {
    final options = round['options'] as List<Map<String, String>>;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    'Round ${_currentRound + 1}/3',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Mascot Buddy bouncing
        AnimatedBuilder(
          animation: _bounceController,
          builder: (context, child) {
            final dy = math.sin(_bounceController.value * math.pi) * 8.0;
            return Transform.translate(
              offset: Offset(0, -dy),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  widget.mate.avatar,
                  style: const TextStyle(fontSize: 54),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Mascot Name
        Text(
          widget.mate.name,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),

        const SizedBox(height: 12),

        // Cartoon Question Bubble
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _speakCurrentQuestion,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  round['question'] as String,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF1E293B),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Options
        ...List.generate(options.length, (idx) {
          final opt = options[idx];
          final isSelected = _selectedOptionIdx == idx;
          final isCorrectOption = idx == round['correct'];

          Color bg = Colors.white;
          Color border = const Color(0xFFE2E8F0);
          if (isSelected) {
            bg = _isAnswerCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444);
            border = Colors.white;
          }

          return GestureDetector(
            onTap: () => _onSelectOption(idx),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(opt['emoji']!, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      opt['label']!,
                      style: GoogleFonts.outfit(
                        color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (isSelected && isCorrectOption)
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVictoryContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🎉 🍪 ⭐', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(
          'Playdate Complete! 🐾',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You visited ${widget.mate.name} and shared yummy learning treats!',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD700), width: 3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 26)),
                  const SizedBox(height: 4),
                  Text(
                    '+50 KS',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFD97706),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Kids Score',
                    style: GoogleFonts.inter(color: Colors.black54, fontSize: 11),
                  ),
                ],
              ),
              Container(width: 1.5, height: 40, color: const Color(0xFFE2E8F0)),
              Column(
                children: [
                  const Text('🍪', style: TextStyle(fontSize: 26)),
                  const SizedBox(height: 4),
                  Text(
                    '+3 Cookies',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF059669),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Star Treats',
                    style: GoogleFonts.inter(color: Colors.black54, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: const Color(0xFF78350F),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            elevation: 4,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Keep Exploring! 🚀',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
