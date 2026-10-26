import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_mates_app/backend/supabase/supabase.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_citadel_fight_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/pocket_citadel_fight_duel_page.dart';

/// 🥊 Direct launcher for Citadel Speed Duel (Zero bottom-sheet delay, default 20 questions)
class PocketCitadelFightModal {
  static void show(
    BuildContext context, {
    required String opponentId,
    required String opponentName,
    required String opponentAvatar,
    required int opponentDay,
    bool isKidMode = false,
  }) {
    startDirectDuel(
      context,
      opponentId: opponentId,
      opponentName: opponentName,
      opponentAvatar: opponentAvatar,
      opponentDay: opponentDay,
      questionCount: 20,
      isKidMode: isKidMode,
    );
  }

  static Future<void> startDirectDuel(
    BuildContext context, {
    required String opponentId,
    required String opponentName,
    required String opponentAvatar,
    required int opponentDay,
    int questionCount = 20,
    bool isKidMode = false,
  }) async {
    HapticFeedback.heavyImpact();
    final myId = SupaFlow.client.auth.currentUser?.id ?? 'me';
    final myMetadata = SupaFlow.client.auth.currentUser?.userMetadata ?? {};
    final myName = myMetadata['display_name']?.toString() ?? 'Challenger';
    final myAvatar = myMetadata['avatar_url']?.toString() ?? '🥊';

    final challenge = await PocketCitadelFightService.sendFightChallenge(
      challengerId: myId,
      challengerName: myName,
      challengerAvatar: myAvatar,
      opponentId: opponentId,
      opponentName: opponentName,
      opponentAvatar: opponentAvatar,
      gameFormat: 'citadel_speed_duel',
      gameTitle: 'Citadel Speed Duel',
      questionCount: questionCount,
      scheduledTime: 'Instant',
    );

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PocketCitadelFightArenaDialog(
          challenge: challenge,
          opponentDay: opponentDay,
          questionCount: questionCount,
          isKidMode: isKidMode,
        ),
      ),
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
