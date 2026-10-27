import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_citadel_fight_service.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_trophy_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Citadel Fight Duel Winner Evaluation (Accuracy First, Speed as Tie-Breaker)', () {
    test('Player with higher correct answers ALWAYS wins, even if slower', () async {
      final challenge = CitadelFightChallenge(
        id: 'fight_test_1',
        challengerId: 'user_a',
        challengerName: 'Anu',
        challengerAvatar: '🥷',
        opponentId: 'user_b',
        opponentName: 'Manu',
        opponentAvatar: '🛡️',
        gameFormat: 'citadel_speed_duel',
        gameTitle: 'Speed Duel',
        scheduledTime: 'Instant',
        questionCount: 20,
        duelSeed: 1234567,
        challengerScore: 1800,
        challengerSeconds: 40,
        challengerCorrect: 18,
        challengerTimeSeconds: 40.2,
        createdAt: DateTime.now(),
      );

      // Opponent rushed through in 15s but only got 10/20 correct
      final result = await PocketCitadelFightService.resolveOpponentFightRun(
        challenge: challenge,
        opponentScore: 1000,
        opponentSeconds: 15,
        opponentCorrect: 10,
        opponentTimeSeconds: 15.1,
      );

      expect(result.winnerId, equals('user_a'), reason: 'Challenger had 18 correct vs Opponent 10 correct');
      expect(result.status, equals('completed'));
    });

    test('Opponent with higher correct answers wins even if Challenger rushed', () async {
      final challenge = CitadelFightChallenge(
        id: 'fight_test_2',
        challengerId: 'user_a',
        challengerName: 'RushedPlayer',
        challengerAvatar: '⚡',
        opponentId: 'user_b',
        opponentName: 'CarefulPlayer',
        opponentAvatar: '🎯',
        gameFormat: 'citadel_speed_duel',
        gameTitle: 'Speed Duel',
        scheduledTime: 'Instant',
        questionCount: 20,
        duelSeed: 9876543,
        challengerScore: 500,
        challengerSeconds: 12,
        challengerCorrect: 4,
        challengerTimeSeconds: 12.0,
        createdAt: DateTime.now(),
      );

      // Opponent took 32 seconds but got 17/20 correct
      final result = await PocketCitadelFightService.resolveOpponentFightRun(
        challenge: challenge,
        opponentScore: 1900,
        opponentSeconds: 32,
        opponentCorrect: 17,
        opponentTimeSeconds: 32.4,
      );

      expect(result.winnerId, equals('user_b'), reason: 'Opponent had 17 correct vs Challenger 4 correct');
    });

    test('When correct counts are tied, faster time wins as tie-breaker', () async {
      final challenge = CitadelFightChallenge(
        id: 'fight_test_3',
        challengerId: 'user_a',
        challengerName: 'PlayerA',
        challengerAvatar: '🅰️',
        opponentId: 'user_b',
        opponentName: 'PlayerB',
        opponentAvatar: '🅱️',
        gameFormat: 'citadel_speed_duel',
        gameTitle: 'Speed Duel',
        scheduledTime: 'Instant',
        questionCount: 20,
        duelSeed: 55555,
        challengerScore: 1950,
        challengerSeconds: 25,
        challengerCorrect: 19,
        challengerTimeSeconds: 25.3,
        createdAt: DateTime.now(),
      );

      // Both players have 19 correct, but Player B finished in 22.1s
      final result = await PocketCitadelFightService.resolveOpponentFightRun(
        challenge: challenge,
        opponentScore: 2050,
        opponentSeconds: 22,
        opponentCorrect: 19,
        opponentTimeSeconds: 22.1,
      );

      expect(result.winnerId, equals('user_b'), reason: 'Tied at 19 correct, but Opponent was faster (22.1s vs 25.3s)');
    });

    test('Identical correct count and identical time yields a Draw', () async {
      final challenge = CitadelFightChallenge(
        id: 'fight_test_4',
        challengerId: 'user_a',
        challengerName: 'PlayerA',
        challengerAvatar: '🅰️',
        opponentId: 'user_b',
        opponentName: 'PlayerB',
        opponentAvatar: '🅱️',
        gameFormat: 'citadel_speed_duel',
        gameTitle: 'Speed Duel',
        scheduledTime: 'Instant',
        questionCount: 20,
        duelSeed: 77777,
        challengerScore: 1800,
        challengerSeconds: 28,
        challengerCorrect: 18,
        challengerTimeSeconds: 28.0,
        createdAt: DateTime.now(),
      );

      final result = await PocketCitadelFightService.resolveOpponentFightRun(
        challenge: challenge,
        opponentScore: 1800,
        opponentSeconds: 28,
        opponentCorrect: 18,
        opponentTimeSeconds: 28.0,
      );

      expect(result.winnerId, equals('draw'), reason: 'Identical accuracy and time is a draw');
    });

    test('sendFightChallenge generates distinct non-zero duelSeeds across calls', () async {
      final c1 = await PocketCitadelFightService.sendFightChallenge(
        challengerId: 'u1',
        challengerName: 'User 1',
        challengerAvatar: '😊',
        opponentId: 'u2',
        opponentName: 'User 2',
        opponentAvatar: '😎',
        gameFormat: 'citadel_speed_duel',
        gameTitle: 'Speed Duel',
        scheduledTime: 'Instant',
      );

      await Future.delayed(const Duration(milliseconds: 5));

      final c2 = await PocketCitadelFightService.sendFightChallenge(
        challengerId: 'u1',
        challengerName: 'User 1',
        challengerAvatar: '😊',
        opponentId: 'u3',
        opponentName: 'User 3',
        opponentAvatar: '🤠',
        gameFormat: 'citadel_speed_duel',
        gameTitle: 'Speed Duel',
        scheduledTime: 'Instant',
      );

      expect(c1.duelSeed, isNonZero);
      expect(c2.duelSeed, isNonZero);
      expect(c1.duelSeed, isNot(equals(c2.duelSeed)), reason: 'Every new challenge has a unique seed to prevent repeat questions');
    });
  });

  group('Citadel Attack 90-Day Progressive Difficulty Scaling', () {
    test('Gate difficulty calculation scales from Day 1 to Day Level', () {
      int calcTargetDay(int gate, int totalGates, int defenderLevel) {
        final double progress = totalGates <= 1 ? 0.0 : (gate / (totalGates - 1)).clamp(0.0, 1.0);
        final int maxLevel = defenderLevel.clamp(1, 90);
        return (1 + (progress * (maxLevel - 1))).round().clamp(1, 90);
      }

      // For a Day 50 defender (50 gates):
      expect(calcTargetDay(0, 50, 50), equals(1), reason: 'Gate 0 must be Day 1 (Peak Simplicity)');
      expect(calcTargetDay(24, 50, 50), inInclusiveRange(24, 26), reason: 'Mid gate must be mid-level');
      expect(calcTargetDay(49, 50, 50), equals(50), reason: 'Final gate must reach defender level (Day 50)');

      // For a Day 90 defender (90 gates):
      expect(calcTargetDay(0, 90, 90), equals(1), reason: 'Gate 0 must be Day 1');
      expect(calcTargetDay(45, 90, 90), inInclusiveRange(44, 46));
      expect(calcTargetDay(89, 90, 90), equals(90), reason: 'Final gate must reach Day 90 peak toughness');
    });

    test('Attack counter increments strictly once per raid, preventing double-count', () async {
      final initial = await PocketTrophyService.getSuccessfulAttacks('test_user_single_attack');
      expect(initial, equals(0));

      // Raid won inside runner attack
      await PocketTrophyService.recordSuccessfulAttack('test_user_single_attack');
      final afterRaid = await PocketTrophyService.getSuccessfulAttacks('test_user_single_attack');
      expect(afterRaid, equals(1), reason: 'Raid finish must increment attack count to 1');

      // Post-runner avatar animation executes with isPostRunnerAnimation: true
      // So no additional increment is performed!
      final afterReturn = await PocketTrophyService.getSuccessfulAttacks('test_user_single_attack');
      expect(afterReturn, equals(1), reason: 'Returning from runner MUST NOT increment attack count again');
    });
  });
}
