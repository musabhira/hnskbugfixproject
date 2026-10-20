import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/kids/pocket_avatar_house_widget.dart';

import 'package:pocket_mates_app/custom_code/services/pocket_kids_defense_service.dart';

/// ⚔️ Friendly Kids House Challenge & Defense Raid Page
///
/// Features:
/// 1. 100% Child-Friendly Cartoon UI (No violent weapons, no scary themes).
/// 2. Displays the Defender Kid's actual Avatar House matching adult stages.
/// 3. Automated Spoken English Defense Traps (No manual questions required from kids).
/// 4. Level-Scaled Defense Layers: Level 20 defender has 20 defense challenges (Sentence Builder, Spelling, Voice Echo, Phonics).
/// 5. Breaking all shield layers rewards stars, friendship, and victory cheers.
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

  List<KidHouseDefenseTrap> _traps = [];
  int _currentTrapIndex = 0;
  late int _shieldsLeft;
  late int _totalShields;
  bool _isAnswerChecking = false;
  int? _selectedAnswerIndex;
  bool _isChallengeComplete = false;
  bool _isLoading = true;

  // Interactive local puzzle state for active trap
  List<String> _placedTokens = [];
  List<String> _availableTokens = [];

  @override
  void initState() {
    super.initState();
    _totalShields = widget.defender.dayLevel.clamp(1, 90);
    _shieldsLeft = _totalShields;

    _shieldPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _initTts();
    _loadTraps();
  }

  Future<void> _loadTraps() async {
    final loaded = await PocketKidsDefenseService.getDefenderTrapsForDay(
      widget.defender.dayLevel,
      defenderId: widget.defender.id,
    );
    if (mounted) {
      setState(() {
        _traps = loaded;
        _isLoading = false;
      });
      _initActiveTrapPuzzle();
      _speakCurrentPrompt();
    }
  }

  void _initActiveTrapPuzzle() {
    if (_currentTrapIndex >= _traps.length) return;
    final trap = _traps[_currentTrapIndex];
    _placedTokens = [];
    if (trap.type == KidDefenseTrapType.sentenceBuilder) {
      _availableTokens = List<String>.from(trap.fragments)..shuffle();
    } else if (trap.type == KidDefenseTrapType.wordSpelling) {
      _availableTokens = List<String>.from(trap.fragments)..shuffle();
    } else {
      _availableTokens = [];
    }
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.3);
      await _tts.setSpeechRate(0.42);
    } catch (_) {}
  }

  Future<void> _speakCurrentPrompt() async {
    if (_traps.isNotEmpty && _currentTrapIndex < _traps.length) {
      final trap = _traps[_currentTrapIndex];
      try {
        await _tts.speak(trap.spokenText.isNotEmpty ? trap.spokenText : trap.prompt);
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
    if (_isAnswerChecking || _isChallengeComplete || _traps.isEmpty) return;
    _isAnswerChecking = true;
    _selectedAnswerIndex = index;

    final trap = _traps[_currentTrapIndex];
    final isCorrect = index == trap.correctOptionIndex;

    if (isCorrect) {
      _handleTrapBreached();
    } else {
      HapticFeedback.lightImpact();
      _tts.speak("Almost! Try the helpful answer!");
      Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        setState(() {
          _isAnswerChecking = false;
          _selectedAnswerIndex = null;
        });
      });
    }
  }

  void _onTokenTapped(String token) {
    if (_isAnswerChecking || _isChallengeComplete || _traps.isEmpty) return;
    final trap = _traps[_currentTrapIndex];

    setState(() {
      _placedTokens.add(token);
      _availableTokens.remove(token);
    });
    HapticFeedback.selectionClick();

    if (trap.type == KidDefenseTrapType.sentenceBuilder) {
      if (_placedTokens.join(' ') == trap.targetPhrase) {
        _handleTrapBreached();
      } else if (_placedTokens.length >= trap.fragments.length) {
        _tts.speak("Let's snap them in the right order!");
        Timer(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          setState(() {
            _placedTokens.clear();
            _availableTokens = List<String>.from(trap.fragments)..shuffle();
          });
        });
      }
    } else if (trap.type == KidDefenseTrapType.wordSpelling) {
      if (_placedTokens.join() == trap.targetPhrase) {
        _handleTrapBreached();
      } else if (_placedTokens.length >= trap.fragments.length) {
        _tts.speak("Almost! Try spelling again!");
        Timer(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          setState(() {
            _placedTokens.clear();
            _availableTokens = List<String>.from(trap.fragments)..shuffle();
          });
        });
      }
    }
  }

  void _handleTrapBreached() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0.0);
    setState(() {
      _shieldsLeft = (_shieldsLeft - 1).clamp(0, _totalShields);
    });

    _tts.speak('Shield layer broken! Great job!');

    Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_shieldsLeft <= 0 || _currentTrapIndex + 1 >= _traps.length) {
        _finishRaidVictory();
      } else {
        setState(() {
          _currentTrapIndex++;
          _isAnswerChecking = false;
          _selectedAnswerIndex = null;
        });
        _initActiveTrapPuzzle();
        _speakCurrentPrompt();
      }
    });
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

    if (_isLoading || _traps.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0284C7),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🛡️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'Scanning ${defender.name}\'s Citadel Defense...',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }

    final trap = _traps[_currentTrapIndex];

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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Back Button
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),

                      // Defender Info Capsule
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            Text(defender.avatar, style: const TextStyle(fontSize: 22)),
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

                      // Defense Shield Progress Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Text('🛡️ ', style: TextStyle(fontSize: 14)),
                            Text(
                              'Trap ${_currentTrapIndex + 1}/$_totalShields',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFFFDE047),
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
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
                              final pulse = math.sin(_shieldPulseController.value * math.pi) * 6;
                              return Container(
                                width: 270 + pulse,
                                height: 210 + pulse,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.7),
                                    width: 3.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
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

                // 📜 INTERACTIVE DEFENSE TRAP ARENA
                Expanded(
                  flex: 6,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                            Text(trap.helperMascot, style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trap.title.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF0284C7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  Text(
                                    trap.prompt,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF0F172A),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF0284C7), size: 28),
                              onPressed: _speakCurrentPrompt,
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Render based on Trap Type
                        Expanded(
                          child: _buildTrapGameContent(trap),
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

  Widget _buildTrapGameContent(KidHouseDefenseTrap trap) {
    if (trap.type == KidDefenseTrapType.sentenceBuilder) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: _placedTokens.isEmpty
                  ? [
                      Text(
                        'Tap the words in order...',
                        style: GoogleFonts.inter(color: Colors.black45, fontSize: 12),
                      )
                    ]
                  : _placedTokens.map((w) {
                      return Chip(
                        backgroundColor: const Color(0xFF8B5CF6),
                        label: Text(
                          w,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
            ),
          ),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _availableTokens.map((w) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D28D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _onTokenTapped(w),
                child: Text(
                  w,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
        ],
      );
    } else if (trap.type == KidDefenseTrapType.wordSpelling) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🚂', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 8),
              ...List.generate(trap.targetPhrase.length, (i) {
                final hasLetter = i < _placedTokens.length;
                return Container(
                  width: 44,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: hasLetter ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasLetter ? const Color(0xFF1D4ED8) : Colors.black12,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    hasLetter ? _placedTokens[i] : '?',
                    style: GoogleFonts.outfit(
                      color: hasLetter ? Colors.white : Colors.black45,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                );
              }),
            ],
          ),
          const Spacer(),
          Wrap(
            spacing: 12,
            children: _availableTokens.map((l) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _onTokenTapped(l),
                child: Text(
                  l,
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
        ],
      );
    } else if (trap.type == KidDefenseTrapType.spokenEcho) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
            ),
            child: Text(
              '"${trap.targetPhrase}"',
              style: GoogleFonts.outfit(
                color: const Color(0xFF065F46),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.mic, size: 22),
            label: Text(
              'SPEAK MOTTO TO BREACH',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
            ),
            onPressed: () {
              _tts.speak(trap.targetPhrase);
              _handleTrapBreached();
            },
          ),
        ],
      );
    } else {
      // Options Grid (Phonics / Multiple choice)
      final opts = trap.options.isNotEmpty ? trap.options : ['A', 'B', 'C', 'D'];
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: opts.length,
        itemBuilder: (context, idx) {
          final opt = opts[idx];
          final isSelected = _selectedAnswerIndex == idx;
          final isCorrect = idx == trap.correctOptionIndex;

          Color bgColor = const Color(0xFFF1F5F9);
          Color textColor = const Color(0xFF0F172A);

          if (_isAnswerChecking && isSelected) {
            bgColor = isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444);
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
                  color: isSelected ? Colors.white : Colors.black12,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      );
    }
  }
}
