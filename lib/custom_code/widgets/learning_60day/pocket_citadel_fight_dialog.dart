import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_citadel_fight_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_citadel_challenge_generator.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';

/// 🥊 Modal for choosing a Game Mode and sending a Citadel Fight Request
class PocketCitadelFightModal {
  static void show(
    BuildContext context, {
    required String opponentId,
    required String opponentName,
    required String opponentAvatar,
    required int opponentDay,
    bool isKidMode = false,
  }) {
    HapticFeedback.mediumImpact();
    final games = PocketCitadelFightService.getAvailableFightGames();
    String selectedGameId = games.first.id;
    String selectedTime = PocketCitadelFightService.scheduleTimeOptions.first;
    int selectedQuestionCount = 20; // ⚔️ Default War Mode: 20 Questions

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B0F19),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: Color(0xFFFFD700), width: 1.5),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activeGame = games.firstWhere((g) => g.id == selectedGameId);

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.90,
              ),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with Opponent Info & Gold Trophy Reward Promise
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1E293B),
                                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Text(opponentAvatar, style: const TextStyle(fontSize: 22)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'CITADEL FIGHT DUEL',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFFFFD700),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text('🥊', style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Challenge $opponentName • Day $opponentDay Fortress',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: 11.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFFFD700), width: 1.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🏆', style: TextStyle(fontSize: 12)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+1 Trophy',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFFFD700),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'CHOOSE SPEED DUEL GAME MODE (10+ FORMATS):',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Games Selector Grid (10-12 modes)
                          SizedBox(
                            height: 190,
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: games.length,
                              itemBuilder: (context, idx) {
                                final g = games[idx];
                                final isSelected = g.id == selectedGameId;

                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setModalState(() => selectedGameId = g.id);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFFFD700)
                                            : const Color(0xFF334155),
                                        width: isSelected ? 2.0 : 1.0,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                                                blurRadius: 8,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(g.icon, style: const TextStyle(fontSize: 20)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                g.title,
                                                style: GoogleFonts.outfit(
                                                  color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                g.titleMl,
                                                style: GoogleFonts.inter(
                                                  color: const Color(0xFF64748B),
                                                  fontSize: 9.5,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Selected Game Description Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Row(
                              children: [
                                Text(activeGame.icon, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    activeGame.description,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF94A3B8),
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          Text(
                            'ROUNDS / QUESTION COUNT (MINIMUM 20):',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Question Count Selector (Wrap prevents 27px overflow on all screens!)
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              ChoiceChip(
                                label: const Text('10 Qs (Quick)'),
                                selected: selectedQuestionCount == 10,
                                selectedColor: const Color(0xFFF59E0B),
                                backgroundColor: const Color(0xFF1E293B),
                                labelStyle: GoogleFonts.outfit(
                                  color: selectedQuestionCount == 10 ? const Color(0xFF0F172A) : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                                side: BorderSide(
                                  color: selectedQuestionCount == 10 ? const Color(0xFFFFD700) : const Color(0xFF334155),
                                ),
                                onSelected: (_) {
                                  HapticFeedback.selectionClick();
                                  setModalState(() => selectedQuestionCount = 10);
                                },
                              ),
                              ChoiceChip(
                                label: const Text('⚔️ 20 Qs (War Mode)'),
                                selected: selectedQuestionCount == 20,
                                selectedColor: const Color(0xFFF59E0B),
                                backgroundColor: const Color(0xFF1E293B),
                                labelStyle: GoogleFonts.outfit(
                                  color: selectedQuestionCount == 20 ? const Color(0xFF0F172A) : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                                side: BorderSide(
                                  color: selectedQuestionCount == 20 ? const Color(0xFFFFD700) : const Color(0xFF334155),
                                ),
                                onSelected: (_) {
                                  HapticFeedback.selectionClick();
                                  setModalState(() => selectedQuestionCount = 20);
                                },
                              ),
                              ChoiceChip(
                                label: const Text('30 Qs (Epic)'),
                                selected: selectedQuestionCount == 30,
                                selectedColor: const Color(0xFFF59E0B),
                                backgroundColor: const Color(0xFF1E293B),
                                labelStyle: GoogleFonts.outfit(
                                  color: selectedQuestionCount == 30 ? const Color(0xFF0F172A) : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                                side: BorderSide(
                                  color: selectedQuestionCount == 30 ? const Color(0xFFFFD700) : const Color(0xFF334155),
                                ),
                                onSelected: (_) {
                                  HapticFeedback.selectionClick();
                                  setModalState(() => selectedQuestionCount = 30);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          Text(
                            'SCHEDULE DUEL TIME:',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Time Options Horizontal Selector
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: PocketCitadelFightService.scheduleTimeOptions.map((time) {
                                final isSelected = time == selectedTime;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(time),
                                    selected: isSelected,
                                    selectedColor: const Color(0xFFF59E0B),
                                    backgroundColor: const Color(0xFF1E293B),
                                    labelStyle: GoogleFonts.outfit(
                                      color: isSelected ? const Color(0xFF0F172A) : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                    ),
                                    side: BorderSide(
                                      color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF334155),
                                    ),
                                    onSelected: (_) {
                                      HapticFeedback.selectionClick();
                                      setModalState(() => selectedTime = time);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Launch Fight / Send Challenge Button (Pinned at bottom, FittedBox prevents 4.3px overflow)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: const Color(0xFF0F172A),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        HapticFeedback.heavyImpact();

                        final myId = SupaFlow.client.auth.currentUser?.id ?? 'me';
                        final myName = isKidMode
                            ? PocketKidsService.kidName
                            : (SupaFlow.client.auth.currentUser?.email?.split('@').first ?? 'Learner');
                        final myAvatar = isKidMode ? PocketKidsService.kidAvatar : '🦁';

                        final challenge = await PocketCitadelFightService.sendFightChallenge(
                          challengerId: myId,
                          challengerName: myName,
                          challengerAvatar: myAvatar,
                          opponentId: opponentId,
                          opponentName: opponentName,
                          opponentAvatar: opponentAvatar,
                          gameFormat: selectedGameId,
                          gameTitle: activeGame.title,
                          scheduledTime: selectedTime,
                          questionCount: selectedQuestionCount,
                        );

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Text('🥊', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Fight Challenge ($selectedQuestionCount Qs War Mode) Dispatched to $opponentName!',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF0F172A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );

                        // Directly launch the Fight Arena so User A plays immediately!
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (arenaCtx) => PocketCitadelFightArenaDialog(
                              challenge: challenge,
                              opponentDay: opponentDay,
                              questionCount: selectedQuestionCount,
                              isKidMode: isKidMode,
                              isOpponentRun: false,
                            ),
                          );
                        }
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🥊', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'ENTER TO FIGHT ⚔️',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// ⚔️ High-Speed Interactive Citadel Duel Arena Modal (20 Questions War Mode, Speed Timer, Gold Trophy)
class PocketCitadelFightArenaDialog extends StatefulWidget {
  final CitadelFightChallenge challenge;
  final int opponentDay;
  final int questionCount;
  final bool isKidMode;
  final bool isOpponentRun;

  const PocketCitadelFightArenaDialog({
    super.key,
    required this.challenge,
    required this.opponentDay,
    this.questionCount = 20,
    this.isKidMode = false,
    this.isOpponentRun = false,
  });

  @override
  State<PocketCitadelFightArenaDialog> createState() => _PocketCitadelFightArenaDialogState();
}

class _PocketCitadelFightArenaDialogState extends State<PocketCitadelFightArenaDialog>
    with SingleTickerProviderStateMixin {
  late List<HouseShieldQuestion> _questions;
  int _currentIndex = 0;
  int _playerScore = 0;
  int _opponentScore = 0;
  int _selectedOption = -1;
  bool _answered = false;
  bool _isFinished = false;

  final Stopwatch _duelStopwatch = Stopwatch();
  int _elapsedSeconds = 0;
  Timer? _ticker;
  int _finalSeconds = 0;

  late AnimationController _timerController;
  Timer? _opponentSimTimer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();

    _duelStopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_isFinished) {
        setState(() => _elapsedSeconds = _duelStopwatch.elapsed.inSeconds);
      }
    });

    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_answered) {
          _handleAnswer(-1, isTimeout: true);
        }
      });

    _timerController.forward();
    if (widget.isOpponentRun) {
      _opponentScore = widget.challenge.challengerScore;
    } else {
      _startOpponentSimulation();
    }
  }

  void _loadQuestions() {
    final targetCount = widget.questionCount > 0
        ? widget.questionCount
        : (widget.challenge.questionCount > 0 ? widget.challenge.questionCount : 20);
    final generated = PocketCitadelChallengeGenerator.generateChallengesForDefender(
      defenderLevel: math.max(targetCount, 20),
      defenderId: widget.challenge.opponentId,
    );
    if (generated.length >= targetCount) {
      _questions = generated.take(targetCount).toList();
    } else {
      _questions = List<HouseShieldQuestion>.from(generated);
      final fallbackBank = [
        HouseShieldQuestion(
          id: 'fb_sb_1',
          question: 'Sentence Builder: Form the proper past question order:',
          options: const [
            'Where did you go yesterday evening?',
            'Where you did go yesterday evening?',
            'Where you went yesterday evening?',
            'Where did you went yesterday evening?',
          ],
          correctIndex: 0,
          explanation: 'Past questions take: did + subject + base verb.',
          gameFormat: 'sentence_builder',
        ),
        HouseShieldQuestion(
          id: 'fb_sb_2',
          question: 'Sentence Builder: Choose the correct word order:',
          options: const [
            'He rarely comes late to the office.',
            'He comes rarely late to the office.',
            'Rarely he come late to the office.',
            'He late rarely comes to the office.',
          ],
          correctIndex: 0,
          explanation: 'Adverbs of frequency come before the main verb.',
          gameFormat: 'sentence_builder',
        ),
        HouseShieldQuestion(
          id: 'fb_sp_1',
          question: 'Word Spelling: Select the 100% correct spelling:',
          options: const [
            'Accommodation',
            'Acommodation',
            'Accomodation',
            'Acomodation',
          ],
          correctIndex: 0,
          explanation: 'Double "c" and double "m".',
          gameFormat: 'spelling_challenge',
        ),
        HouseShieldQuestion(
          id: 'fb_gt_1',
          question: 'Grammar Trap: Fill in: "Neither of the candidates ___ qualified."',
          options: const [
            'is',
            'are',
            'were',
            'have been',
          ],
          correctIndex: 0,
          explanation: '"Neither" is singular in standard English.',
          gameFormat: 'grammar_defusal',
        ),
        HouseShieldQuestion(
          id: 'fb_cr_1',
          question: 'Chat Reply: Polite response to "Could you please send me the report?":',
          options: const [
            'Sure, I will send it right over.',
            'No, go get it yourself.',
            'I never send reports.',
            'Reports are very annoying.',
          ],
          correctIndex: 0,
          explanation: 'Standard polite workplace confirmation.',
          gameFormat: 'chat_reply',
        ),
      ];
      while (_questions.length < targetCount) {
        final q = fallbackBank[_questions.length % fallbackBank.length];
        _questions.add(HouseShieldQuestion(
          id: '${q.id}_${_questions.length}',
          question: q.question,
          options: q.options,
          correctIndex: q.correctIndex,
          explanation: q.explanation,
          gameFormat: q.gameFormat,
        ));
      }
    }
  }

  void _startOpponentSimulation() {
    // Opponent makes realistic moves with slight delay
    _opponentSimTimer = Timer.periodic(const Duration(milliseconds: 3200), (t) {
      if (_isFinished || !mounted) {
        t.cancel();
        return;
      }
      final willScore = math.Random().nextDouble() > 0.35;
      if (willScore) {
        setState(() {
          _opponentScore += 100 + math.Random().nextInt(40);
        });
      }
    });
  }

  void _handleAnswer(int optionIdx, {bool isTimeout = false}) {
    if (_answered) return;
    _timerController.stop();

    final currentQ = _questions[_currentIndex];
    final isCorrect = optionIdx == currentQ.correctIndex;
    final timeRemainingSeconds = 15 * (1.0 - _timerController.value);
    final speedBonus = (timeRemainingSeconds * 8).round();

    setState(() {
      _selectedOption = optionIdx;
      _answered = true;
      if (isCorrect) {
        _playerScore += 100 + speedBonus;
      }
    });

    if (isCorrect) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _answered = false;
          _selectedOption = -1;
        });
        _timerController.forward(from: 0.0);
      } else {
        _finishDuel();
      }
    });
  }

  Future<void> _finishDuel() async {
    _timerController.stop();
    _opponentSimTimer?.cancel();
    _ticker?.cancel();
    _duelStopwatch.stop();
    _finalSeconds = _duelStopwatch.elapsed.inSeconds;

    setState(() => _isFinished = true);

    if (!widget.isOpponentRun) {
      // Challenger finished initial run ("ഞാൻ ഫൈറ്റ് ചെയ്തിട്ടു")
      HapticFeedback.heavyImpact();
      await PocketCitadelFightService.recordChallengerFightRun(
        challenge: widget.challenge,
        score: _playerScore,
        seconds: _finalSeconds,
      );
    } else {
      // Opponent completed run -> Settle duel!
      HapticFeedback.heavyImpact();
      await PocketCitadelFightService.resolveOpponentFightRun(
        challenge: widget.challenge,
        opponentScore: _playerScore,
        opponentSeconds: _finalSeconds,
      );
      final myId = SupaFlow.client.auth.currentUser?.id ?? 'me';
      final opponentUserId = widget.challenge.challengerId == myId
          ? widget.challenge.opponentId
          : widget.challenge.challengerId;
      await PocketTrophyService.recordPactFight(myId, opponentUserId);
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    _opponentSimTimer?.cancel();
    _ticker?.cancel();
    _duelStopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Dialog(
      backgroundColor: const Color(0xFF0B0F19),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFFFD700), width: 1.8),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: _isFinished ? _buildResultScreen() : _buildArenaScreen(currentQ, progress),
        ),
      ),
    );
  }

  Widget _buildArenaScreen(HouseShieldQuestion currentQ, double progress) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Arena Bar: Players & Live Score
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Player
            Row(
              children: [
                Text(widget.challenge.challengerAvatar, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.challenge.challengerName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$_playerScore PTS',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEF4444), width: 1.0),
                  ),
                  child: Text(
                    'VS',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⏱️', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 3),
                      Text(
                        '${_elapsedSeconds}s',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Opponent
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.challenge.opponentName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '$_opponentScore PTS',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                Text(widget.challenge.opponentAvatar, style: const TextStyle(fontSize: 22)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (widget.isOpponentRun) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF38BDF8), width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎯', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(
                  'TARGET TO BEAT: ${widget.challenge.challengerSeconds}s • ${widget.challenge.challengerScore} PTS',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF38BDF8),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Round & Game Mode tag
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ROUND ${_currentIndex + 1} OF ${_questions.length}',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              widget.challenge.gameTitle,
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 15-Second Animated Speed Countdown Timer
        AnimatedBuilder(
          animation: _timerController,
          builder: (context, _) {
            final remaining = (1.0 - _timerController.value).clamp(0.0, 1.0);
            return ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: remaining,
                backgroundColor: const Color(0xFF1E293B),
                color: remaining > 0.4 ? const Color(0xFFFFD700) : const Color(0xFFEF4444),
                minHeight: 6,
              ),
            );
          },
        ),
        const SizedBox(height: 14),

        // Question Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Text(
            currentQ.question,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 4 Options
        Column(
          children: List.generate(currentQ.options.length, (idx) {
            final opt = currentQ.options[idx];
            final isSelected = _selectedOption == idx;
            final isCorrect = idx == currentQ.correctIndex;

            Color borderColor = const Color(0xFF334155);
            Color bgColor = const Color(0xFF0F172A);

            if (_answered) {
              if (isCorrect) {
                borderColor = const Color(0xFF10B981);
                bgColor = const Color(0xFF10B981).withValues(alpha: 0.2);
              } else if (isSelected) {
                borderColor = const Color(0xFFEF4444);
                bgColor = const Color(0xFFEF4444).withValues(alpha: 0.2);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _handleAnswer(idx),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E293B),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          String.fromCharCode(65 + idx),
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          opt,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    if (!widget.isOpponentRun) {
      // Challenger finished initial run ("ഞാൻ ഫൈറ്റ് ചെയ്തിട്ടു")
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          const Text('🥊 ⚔️ ⚡', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            'FIGHT CHALLENGE DISPATCHED!',
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You completed your duel run! Challenge recorded and dispatched to ${widget.challenge.opponentName} in Chat & Notifications. When they fight back, the fastest speed & highest score wins the 🏆 Gold Trophy!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD700)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('YOUR SCORE', style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 11)),
                    Text('$_playerScore PTS', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
                Container(width: 1, height: 35, color: const Color(0xFF334155)),
                Column(
                  children: [
                    Text('YOUR SPEED', style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 11)),
                    Text('${_finalSeconds}s ⏱️', style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: const Color(0xFF0F172A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'RETURN TO CITADEL',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
          ),
        ],
      );
    }

    // Opponent run finished -> Settle result!
    final challengerScore = widget.challenge.challengerScore;
    final challengerSeconds = widget.challenge.challengerSeconds;
    final bool won;
    if (_playerScore > challengerScore) {
      won = true;
    } else if (_playerScore < challengerScore) {
      won = false;
    } else {
      won = _finalSeconds <= challengerSeconds;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Text(won ? '🏆 ⚔️ 👑' : '⚔️ 🥊 ⚔️', style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 10),
        Text(
          won ? '⚔️ SPEED DUEL VICTORY! ⚔️' : 'DEFEATED IN SPEED DUEL!',
          style: GoogleFonts.outfit(
            color: won ? const Color(0xFFFFD700) : const Color(0xFFEF4444),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          won
              ? 'Incredible reflexes! You conquered ${widget.challenge.challengerName} in speed & accuracy! +1 Trophy awarded!'
              : 'Close combat! ${widget.challenge.challengerName} was faster this time. Train and challenge back!',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: won ? const Color(0xFFFFD700) : const Color(0xFF334155)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('YOU', style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 11)),
                  Text('$_playerScore PTS', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 17, fontWeight: FontWeight.w900)),
                  Text('${_finalSeconds}s ⏱️', style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(width: 1, height: 40, color: const Color(0xFF334155)),
              Column(
                children: [
                  Text(widget.challenge.challengerName.toUpperCase(), style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 11)),
                  Text('$challengerScore PTS', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 17, fontWeight: FontWeight.w900)),
                  Text('${challengerSeconds}s ⏱️', style: GoogleFonts.outfit(color: const Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (won) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  '+1 GOLD TROPHY & +250 POCKET SCORE!',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: won ? const Color(0xFFFFD700) : const Color(0xFF334155),
              foregroundColor: won ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'COLLECT & RETURN TO CITADEL',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
