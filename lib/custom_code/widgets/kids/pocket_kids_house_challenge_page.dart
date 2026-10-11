import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';

/// ⚔️ Friendly Kids House Challenge & Defense Raid Page
///
/// Features:
/// 1. 100% Child-Friendly Cartoon UI (No violent weapons, no scary themes).
/// 2. Displays the Defender Kid's actual Avatar House matching adult stages.
/// 3. Automated Spoken English Defense Traps (No manual questions required from kids).
/// 4. Helping-Mentality Dialogue & Voiceover (TTS).
/// 5. Breaking 3 shield layers rewards stars, friendship, and victory cheers.
class PocketKidsHouseChallengePage extends StatefulWidget {
  final KidMate defender;

  const PocketKidsHouseChallengePage({
    super.key,
    required this.defender,
  });

  @override
  State<PocketKidsHouseChallengePage> createState() =>
      _PocketKidsHouseChallengePageState();
}

class _PocketKidsHouseChallengePageState
    extends State<PocketKidsHouseChallengePage> with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late AnimationController _shieldPulseController;
  late AnimationController _shakeController;

  late List<KidDefenseChallenge> _challenges;
  int _currentTrapIndex = 0;
  int _shieldsLeft = 3;
  bool _isAnswerChecking = false;
  int? _selectedAnswerIndex;
  bool _isChallengeComplete = false;

  @override
  void initState() {
    super.initState();
    _challenges =
        PocketKidsService.getDefenseChallengesForDay(widget.defender.dayLevel);

    _shieldPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _initTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentPrompt();
    });
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.42);
    } catch (_) {}
  }

  Future<void> _speakCurrentPrompt() async {
    if (_currentTrapIndex < _challenges.length) {
      final challenge = _challenges[_currentTrapIndex];
      try {
        await _tts.speak(challenge.spokenText);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _shieldPulseController.dispose();
    _shakeController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _onAnswerSelected(int index) {
    if (_isAnswerChecking || _isChallengeComplete) return;
    _isAnswerChecking = true;
    _selectedAnswerIndex = index;

    final challenge = _challenges[_currentTrapIndex];
    final isCorrect = index == challenge.correctIndex;

    if (isCorrect) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      setState(() {
        _shieldsLeft = (_shieldsLeft - 1).clamp(0, 3);
      });

      _tts.speak('${challenge.cheerMessage} Shield broken!');

      Timer(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        if (_shieldsLeft <= 0 || _currentTrapIndex + 1 >= _challenges.length) {
          _finishRaidVictory();
        } else {
          setState(() {
            _currentTrapIndex++;
            _isAnswerChecking = false;
            _selectedAnswerIndex = null;
          });
          _speakCurrentPrompt();
        }
      });
    } else {
      HapticFeedback.lightImpact();
      _tts.speak("Almost! Let's choose the kind and helpful answer!");
      Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          _isAnswerChecking = false;
          _selectedAnswerIndex = null;
        });
      });
    }
  }

  Future<void> _finishRaidVictory() async {
    _isChallengeComplete = true;
    await PocketKidsService.addStars(15);
    await PocketKidsService.toggleMate(widget.defender.id);

    HapticFeedback.heavyImpact();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF38BDF8), Color(0xFF1E3A8A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFFFD700), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆 💖 🎉', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  'CHALLENGE CLEARED!',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You and ${widget.defender.name} are now Star Adventure Mates!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(
                        '+15 STARS EARNED!',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context); // return to mates / profile
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'BACK TO ADVENTURE ➔',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final defender = widget.defender;
    final house = PocketKidsService.getHouseForDay(defender.dayLevel);
    final challenge = _challenges[_currentTrapIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0369A1),
      body: Stack(
        children: [
          // Background Cartoon Sky Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0284C7),
                  Color(0xFF38BDF8),
                  Color(0xFF86EFAC),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 🌟 TOP HUD BAR
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Back Button
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),

                      // Defender Info Capsule
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(defender.avatar,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  defender.name,
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF0F172A),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Level ${defender.dayLevel} • ${house.title}',
                                  style: GoogleFonts.inter(
                                    color: Colors.black54,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Defense Shield Hearts / Layers
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF38BDF8), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Text('🛡️', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Row(
                              children: List.generate(
                                3,
                                (i) => Text(
                                  i < _shieldsLeft ? '💙' : '🖤',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // 🏡 DEFENDER'S AVATAR HOUSE WITH GLOWING SHIELD
                Expanded(
                  flex: 5,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Defender's House rendered via HouseMasterComponent
                        PocketAvatarHouseWidget(
                          day: defender.dayLevel,
                          width: 250,
                          height: 200,
                          lightsOn: true,
                        ),

                        // Glowing Animated Defense Energy Bubble
                        if (_shieldsLeft > 0)
                          AnimatedBuilder(
                            animation: _shieldPulseController,
                            builder: (context, child) {
                              final pulse =
                                  math.sin(_shieldPulseController.value *
                                          math.pi) *
                                      6;
                              return Container(
                                width: 270 + pulse,
                                height: 210 + pulse,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF38BDF8)
                                        .withValues(alpha: 0.7),
                                    width: 3.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF38BDF8)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // 📜 AUTOMATED SPOKEN ENGLISH CHALLENGE CARD
                Expanded(
                  flex: 6,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mascot Prompt & Speaker Button
                        Row(
                          children: [
                            Text(challenge.helperMascot,
                                style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                challenge.prompt,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF0F172A),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded,
                                  color: Color(0xFF0284C7), size: 28),
                              onPressed: _speakCurrentPrompt,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Answer Choice Buttons
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: challenge.options.length,
                            itemBuilder: (context, idx) {
                              final opt = challenge.options[idx];
                              final isSelected = _selectedAnswerIndex == idx;
                              final isCorrect = idx == challenge.correctIndex;

                              Color bgColor = const Color(0xFFF1F5F9);
                              Color textColor = const Color(0xFF0F172A);

                              if (_isAnswerChecking && isSelected) {
                                bgColor = isCorrect
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444);
                                textColor = Colors.white;
                              }

                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: bgColor,
                                  foregroundColor: textColor,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black12,
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                ),
                                onPressed: () => _onAnswerSelected(idx),
                                child: Text(
                                  opt,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
}
