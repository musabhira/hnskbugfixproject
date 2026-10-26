import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_citadel_fight_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_kids_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/pocket_citadel_fight_duel_page.dart';

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
class PocketCitadelFightArenaDialog extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final myId = SupaFlow.client.auth.currentUser?.id ?? 'me';
    final bool isUserB = isOpponentRun || challenge.opponentId == myId;
    final opponentName = isUserB ? challenge.challengerName : challenge.opponentName;
    final opponentAvatar = isUserB ? challenge.challengerAvatar : challenge.opponentAvatar;
    final effectiveCount = questionCount > 0 ? questionCount : challenge.questionCount;

    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF080C24),
      child: CitadelFightDuelPage(
        opponentName: opponentName,
        opponentAvatar: opponentAvatar,
        opponentLevel: opponentDay > 0 ? opponentDay : 1,
        questionCount: effectiveCount,
        isUserBTurn: isUserB,
        userATimeSeconds: challenge.challengerTimeSeconds > 0
            ? challenge.challengerTimeSeconds
            : (challenge.challengerSeconds > 0 ? challenge.challengerSeconds.toDouble() : null),
        userAScore: challenge.challengerScore > 0 ? challenge.challengerScore : null,
        userACorrect: challenge.challengerCorrect > 0
            ? challenge.challengerCorrect
            : (challenge.challengerScore > 0
                ? (challenge.challengerScore / 180).round().clamp(0, effectiveCount)
                : null),
        duelSeed: challenge.duelSeed,
        onDuelFinished: (result) async {
          if (!isUserB) {
            // Challenger finished initial run (User A)
            final int score = (result['finalScore'] as num?)?.toInt() ?? 0;
            final double timeSec = (result['totalTimeSeconds'] as num?)?.toDouble() ?? 0.0;
            final int correct = (result['totalCorrect'] as num?)?.toInt() ?? 0;
            final int seed = (result['duelSeed'] as num?)?.toInt() ?? challenge.duelSeed;
            await PocketCitadelFightService.recordChallengerFightRun(
              challenge: challenge,
              score: score,
              seconds: timeSec.round(),
              challengerCorrect: correct,
              challengerTimeSeconds: timeSec,
              duelSeed: seed,
            );
          } else {
            // Opponent completed run (User B) -> Resolve duel
            final userB = result['userB'] as Map<String, dynamic>?;
            final int score = (userB?['finalScore'] as num?)?.toInt() ?? (result['finalScore'] as num?)?.toInt() ?? 0;
            final double timeSec = (userB?['totalTimeSeconds'] as num?)?.toDouble() ?? (result['totalTimeSeconds'] as num?)?.toDouble() ?? 0.0;
            final int correct = (userB?['totalCorrect'] as num?)?.toInt() ?? (result['totalCorrect'] as num?)?.toInt() ?? 0;
            await PocketCitadelFightService.resolveOpponentFightRun(
              challenge: challenge,
              opponentScore: score,
              opponentSeconds: timeSec.round(),
              opponentCorrect: correct,
              opponentTimeSeconds: timeSec,
            );
            final opponentUserId = challenge.challengerId == myId
                ? challenge.opponentId
                : challenge.challengerId;
            await PocketTrophyService.recordPactFight(myId, opponentUserId);
          }
        },
      ),
    );
  }
}
