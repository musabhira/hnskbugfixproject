import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/avatar/vector_avatar_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('1 Day = 1 Defense Question Slot Rule Tests', () {
    test('Day 1 has exactly 1 question slot', () {
      expect(PocketFortressDefenseService.getMaxQuestionsForStage(1), 1);
    });

    test('Day 10 has exactly 10 question slots', () {
      expect(PocketFortressDefenseService.getMaxQuestionsForStage(10), 10);
    });

    test('Day 50 has exactly 50 question slots', () {
      expect(PocketFortressDefenseService.getMaxQuestionsForStage(50), 50);
    });

    test('Day 90 has exactly 90 question slots', () {
      expect(PocketFortressDefenseService.getMaxQuestionsForStage(90), 90);
    });

    test('Gate distribution scales across 9 gates (10 Qs per gate max)', () {
      expect(PocketFortressDefenseService.getUnlockedGamesCountForStage(1), 1);
      expect(PocketFortressDefenseService.getUnlockedGamesCountForStage(10), 1);
      expect(PocketFortressDefenseService.getUnlockedGamesCountForStage(11), 2);
      expect(PocketFortressDefenseService.getUnlockedGamesCountForStage(20), 2);
      expect(PocketFortressDefenseService.getUnlockedGamesCountForStage(50), 5);
      expect(PocketFortressDefenseService.getUnlockedGamesCountForStage(85), 9);
      expect(PocketFortressDefenseService.getUnlockedGamesCountForStage(90), 9);
    });
  });

  group('Self-Built Defense (No pre-filled fake questions for player)', () {
    test('Player starts with empty defense questions list to craft themselves', () async {
      final questions = await PocketFortressDefenseService.loadShieldQuestions(10, isNeighbor: false);
      expect(questions, isEmpty);
    });

    test('Neighbor raids load curated questions as fallback if neighbor has no custom questions', () async {
      final questions = await PocketFortressDefenseService.loadShieldQuestions(10, isNeighbor: true);
      expect(questions.length, 10);
    });
  });

  group('Activity-Powered Reinforcements (FDC)', () {
    test('Recording voice calls, chats, vibes increases FDC balance', () async {
      final initial = await PocketFortressDefenseService.getActivityPoints();
      expect(initial, 80);

      final afterVoice = await PocketFortressDefenseService.recordActivityPoints('voice_talk');
      expect(afterVoice, 100);

      final afterChat = await PocketFortressDefenseService.recordActivityPoints('group_chat');
      expect(afterChat, 110);

      final afterVibe = await PocketFortressDefenseService.recordActivityPoints('vibe_post');
      expect(afterVibe, 125);
    });

    test('Iron Dome can be purchased with Activity FDC', () async {
      final ok = await PocketFortressDefenseService.purchaseIronDome(useFdc: true, fdcCost: 60);
      expect(ok, isTrue);

      final remaining = await PocketFortressDefenseService.getActivityPoints();
      expect(remaining, 20); // 80 - 60 = 20
    });
  });

  group('Raid Warfare & House Breach Mechanics', () {
    test('Breaching defender fortress deals damage and loots 20% vault coins', () async {
      final breach = await PocketFortressDefenseService.processRaidBreach(
        defenderHouseId: 'test_defender',
        damageHp: 50,
      );

      expect(breach['damageDealt'], 50);
      expect(breach['remainingHp'], 50);
      expect(breach['lootedCoins'], greaterThanOrEqualTo(15));
    });

    test('Repairing house restores health', () async {
      final ok = await PocketFortressDefenseService.repairHouse(healAmount: 50, coinCost: 30);
      expect(ok, isTrue);

      final status = await PocketFortressDefenseService.getHouseStatus();
      expect(status.currentHp, 100);
      expect(status.isDamaged, isFalse);
    });
  });

  group('President Call & House Condemnation/Rebuild Mechanics', () {
    test('Filing President Call places house under Presidential Inspection', () async {
      await PocketFortressDefenseService.fileDefenseReport(
        houseId: 'suspect_house_1',
        houseOwnerName: 'FakeTroll',
        questionId: 'q_fake_99',
        questionText: 'asdfg hjkl qwerty ???',
        options: const ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        reporterId: 'attacker_hero',
        reporterName: 'Scout Scout',
        reason: 'fake_gibberish',
        details: 'Reported via President Call during live PvP Siege.',
      );

      final underInspection = await PocketFortressDefenseService.isUnderPresidentInspection('suspect_house_1');
      expect(underInspection, isTrue);
    });

    test('Presidential Decree bans condemned house', () async {
      await PocketFortressDefenseService.banHouse(
        'suspect_house_1',
        reason: 'Presidential Decree: Fraudulent / Fake English Defenses',
      );

      final isBanned = await PocketFortressDefenseService.isHouseBanned('suspect_house_1');
      expect(isBanned, isTrue);
    });

    test('Player can rebuild condemned house from scratch to restart from Day 1', () async {
      // Ban player's house
      await PocketFortressDefenseService.banHouse('me', reason: 'Presidential Decree');
      expect(await PocketFortressDefenseService.isHouseBanned('me'), isTrue);

      // Rebuild from scratch
      await PocketFortressDefenseService.rebuildHouseFromScratch('me');

      // Verify ban is cleared, house status restored to 100 HP, questions wiped
      expect(await PocketFortressDefenseService.isHouseBanned('me'), isFalse);
      final status = await PocketFortressDefenseService.getHouseStatus(1);
      expect(status.isBanned, isFalse);
      expect(status.currentHp, 100);
      expect(status.isDamaged, isFalse);

      final questions = await PocketFortressDefenseService.loadShieldQuestions(1);
      expect(questions, isEmpty); // Wiped clean to start over from Day 1
    });
  });

  group('Anti-Duplicate Defense Trap Rules', () {
    final existingTrap = HouseShieldQuestion(
      id: 'trap_1',
      question: 'Which of the following sentences uses the past continuous tense correctly?',
      options: const ['I was reading', 'I read', 'I have read', 'I am reading'],
      correctIndex: 0,
      explanation: 'Action ongoing in the past',
      gameFormat: 'mcq',
    );

    test('Rejects exact duplicate question text', () {
      final verdict = PocketFortressDefenseService.validateQuestion(
        'Which of the following sentences uses the past continuous tense correctly?',
        const ['A', 'B', 'C', 'D'],
        0,
        existingQuestions: [existingTrap],
      );
      expect(verdict.isApproved, isFalse);
      expect(verdict.isBanThreat, isTrue);
      expect(verdict.feedback, contains('Duplicate question detected'));
    });

    test('Rejects normalized duplicate (differing only in case or punctuation)', () {
      final verdict = PocketFortressDefenseService.validateQuestion(
        'WHICH of the following SENTENCES uses the past continuous tense correctly?!?',
        const ['A', 'B', 'C', 'D'],
        0,
        existingQuestions: [existingTrap],
      );
      expect(verdict.isApproved, isFalse);
      expect(verdict.isBanThreat, isTrue);
      expect(verdict.feedback, contains('Duplicate question detected'));
    });

    test('Allows editing an existing question when currentQuestionId is provided', () {
      final verdict = PocketFortressDefenseService.validateQuestion(
        'Which of the following sentences uses the past continuous tense correctly?',
        const ['I was reading', 'I read', 'I have read', 'I am reading'],
        0,
        currentQuestionId: 'trap_1',
        existingQuestions: [existingTrap],
      );
      expect(verdict.isApproved, isTrue);
    });

    test('Allows unique, brand new question text', () {
      final verdict = PocketFortressDefenseService.validateQuestion(
        'Identify the subjunctive mood in this sentence:',
        const ['If I were you', 'If I was you', 'If I am you', 'If I will be you'],
        0,
        existingQuestions: [existingTrap],
      );
      expect(verdict.isApproved, isTrue);
    });
  });

  group('Diverse Defense Game Formats Validation', () {
    test('Validates Word Scramble requirements', () {
      // Missing target word
      final v1 = PocketFortressDefenseService.validateQuestion(
        'Unscramble the word meaning a grand entrance:',
        const [''],
        0,
        gameFormat: 'word_scramble',
      );
      expect(v1.isApproved, isFalse);

      // Target word with special chars
      final v2 = PocketFortressDefenseService.validateQuestion(
        'Unscramble the word meaning a grand entrance:',
        const ['P0RT@L'],
        0,
        gameFormat: 'word_scramble',
      );
      expect(v2.isApproved, isFalse);

      // Valid scramble
      final v3 = PocketFortressDefenseService.validateQuestion(
        'Unscramble the word meaning a grand entrance:',
        const ['PORTAL'],
        0,
        gameFormat: 'word_scramble',
      );
      expect(v3.isApproved, isTrue);
    });

    test('Validates Sentence Jigsaw requirements', () {
      // Too few words
      final v1 = PocketFortressDefenseService.validateQuestion(
        'Go away',
        const [],
        0,
        gameFormat: 'sentence_jigsaw',
      );
      expect(v1.isApproved, isFalse);

      // Valid sentence jigsaw
      final v2 = PocketFortressDefenseService.validateQuestion(
        'The courageous knight defended the stone citadel with honor',
        const [],
        0,
        gameFormat: 'sentence_jigsaw',
      );
      expect(v2.isApproved, isTrue);
    });

    test('Validates Spot the Error segments requirements', () {
      // Missing segments
      final v1 = PocketFortressDefenseService.validateQuestion(
        'Find the grammatical error in this sentence:',
        const ['She do not know', ''],
        0,
        gameFormat: 'spot_error',
      );
      expect(v1.isApproved, isFalse);

      // Valid segments and selected error index
      final v2 = PocketFortressDefenseService.validateQuestion(
        'Find the grammatical error in this sentence:',
        const ['Neither of the boys', 'were present', 'at the ceremony', 'yesterday'],
        1,
        gameFormat: 'spot_error',
      );
      expect(v2.isApproved, isTrue);
    });
  });

  group('Attacker Lifelines & Citadel Progression Rules (User Audio Request)', () {
    test('Early levels (Days 1–24) grant 0 lifelines to attackers', () {
      expect(PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(1), equals(0));
      expect(PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(10), equals(0));
      expect(PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(24), equals(0));
    });

    test('Mid-level fortified houses (Days 25–49) grant 1 lifeline', () {
      expect(PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(25), equals(1));
      expect(PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(30), equals(1));
      expect(PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(49), equals(1));
    });

    test('High-level citadels (Days 50–79) grant 2 lifelines', () {
      expect(PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(50), equals(2));
      expect(PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(65), equals(2));
      expect(PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(79), equals(2));
    });

    test('Imperial Palace Citadels (Days 80–90) grant 3 lifelines', () {
      expect(PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(80), equals(3));
      expect(PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(85), equals(3));
      expect(PocketFortressDefenseService.getAttackerLifelinesForNeighborDay(90), equals(3));
    });

    test('9 Gates scale with exactly 10 questions per gate up to 90 total questions on Day 90', () {
      for (int day = 1; day <= 90; day++) {
        final totalQuestions = PocketFortressDefenseService.getMaxQuestionsForStage(day);
        final gateCount = PocketFortressDefenseService.getUnlockedGamesCountForStage(day);
        expect(totalQuestions, equals(day));
        expect(gateCount, equals(((day - 1) ~/ 10) + 1));
      }
      expect(PocketFortressDefenseService.getUnlockedGamesCountForStage(90), equals(9));
      expect(PocketFortressDefenseService.getMaxQuestionsForStage(90), equals(90));
    });

    test('Attack unlocks starting at Level 4', () {
      expect(PocketFortressDefenseService.canUserAttack(1), isFalse);
      expect(PocketFortressDefenseService.canUserAttack(2), isFalse);
      expect(PocketFortressDefenseService.canUserAttack(3), isFalse);
      expect(PocketFortressDefenseService.canUserAttack(4), isTrue);
      expect(PocketFortressDefenseService.canUserAttack(10), isTrue);
    });

    test('Level 4 attacker matches with Level 5 or 6 citadels', () {
      final targets = <int>{};
      for (int i = 0; i < 20; i++) {
        targets.add(PocketFortressDefenseService.getRaidTargetDay(4));
      }
      expect(targets.every((t) => t == 5 || t == 6), isTrue);
      expect(PocketFortressDefenseService.isRaidTargetValid(4, 5), isTrue);
      expect(PocketFortressDefenseService.isRaidTargetValid(4, 6), isTrue);
      expect(PocketFortressDefenseService.isRaidTargetValid(4, 4), isFalse);
      expect(PocketFortressDefenseService.isRaidTargetValid(4, 3), isFalse);
    });

    test('Store purchases and Lifelines management', () async {
      SharedPreferences.setMockInitialValues({
        'pocket_house_coins': 200,
        'pocket_house_lifelines': 1,
      });

      // Buy Lifeline for 30 coins
      final boughtLifeline = await PocketFortressDefenseService.purchaseLifeline(coinCost: 30);
      expect(boughtLifeline, isTrue);
      expect(await PocketFortressDefenseService.getLifelinesCount(), equals(2));

      // Consume Lifeline
      final consumed = await PocketFortressDefenseService.consumeLifeline();
      expect(consumed, isTrue);
      expect(await PocketFortressDefenseService.getLifelinesCount(), equals(1));

      // Buy Wall Repairs for 20 coins
      final repaired = await PocketFortressDefenseService.repairHouse(useFdc: false);
      expect(repaired, isTrue);

      // Buy Army Knights for 40 coins
      final enlisted = await PocketFortressDefenseService.enlistArmyKnights(useFdc: false);
      expect(enlisted, isTrue);

      // Buy Iron Dome for 50 coins
      final domeBought = await PocketFortressDefenseService.purchaseIronDome(useFdc: false);
      expect(domeBought, isTrue);
    });

    test('Target attack cooldown enforces 24-hour peace treaty', () async {
      SharedPreferences.setMockInitialValues({});
      const targetId = 'target_user_42';

      expect(await PocketFortressDefenseService.isTargetInCooldown(targetId), isFalse);

      await PocketFortressDefenseService.recordTargetAttacked(targetId);
      expect(await PocketFortressDefenseService.isTargetInCooldown(targetId), isTrue);
    });

    test('Breach loots exactly 45 coins when Iron Dome is absent', () async {
      SharedPreferences.setMockInitialValues({
        'pocket_house_hp': 100,
        'pocket_house_coins': 150,
        'pocket_house_iron_dome': false,
      });

      final result = await PocketFortressDefenseService.processRaidBreach(
        defenderHouseId: 'me',
        damageHp: 60,
        attackerName: 'Shadow Raider',
        attackerAvatar: '⚔️',
      );

      expect(result['damageDealt'], equals(60));
      expect(result['remainingHp'], equals(40));
      expect(result['lootedCoins'], equals(45));
      expect(result['ironDomeBlocked'], isFalse);
    });

    test('Iron Dome absorbs breach completely: 0 damage, 0 coins looted, dome consumed', () async {
      SharedPreferences.setMockInitialValues({
        'pocket_house_hp': 100,
        'pocket_house_coins': 150,
        'user_house_iron_dome': true,
      });

      final result = await PocketFortressDefenseService.processRaidBreach(
        defenderHouseId: 'me',
        damageHp: 60,
        attackerName: 'Shadow Raider',
        attackerAvatar: '⚔️',
      );

      expect(result['damageDealt'], equals(0));
      expect(result['remainingHp'], equals(100));
      expect(result['lootedCoins'], equals(0));
      expect(result['ironDomeBlocked'], isTrue);

      // Verify dome is consumed
      final status = await PocketFortressDefenseService.getHouseStatus();
      expect(status.hasIronDome, isFalse);
    });

    test('Avatar Combat Weapons & Tools for all 90 days', () {
      for (int day = 1; day <= 90; day++) {
        final perk = VectorAvatarConfig.getAvatarPerkForDay(day);
        expect(perk.combatWeaponName, isNotEmpty);
        expect(perk.combatWeaponIcon, isNotEmpty);
        expect(perk.combatActionVerb, isNotEmpty);
        expect(perk.combatRole, anyOf(equals('Defensive Guardian'), equals('Offensive Raider')));
      }

      // Check specific day weapon designations
      final day4 = VectorAvatarConfig.getAvatarPerkForDay(4);
      expect(day4.combatRole, equals('Defensive Guardian')); // Royal Knights garrison
      final day1 = VectorAvatarConfig.getAvatarPerkForDay(1);
      expect(day1.combatWeaponName, contains('Wand'));
      final day2 = VectorAvatarConfig.getAvatarPerkForDay(2);
      expect(day2.combatWeaponName, contains('Katana'));
      final day3 = VectorAvatarConfig.getAvatarPerkForDay(3);
      expect(day3.combatWeaponName, contains('Cannon'));
    });

    test('Presidential Decrees: Notice, Jail, Demote, and Asset Confiscation', () async {
      SharedPreferences.setMockInitialValues({
        'user_pocket_coins': 250,
        'learning_last_completed_day': 18,
        'user_pocket_banned': false,
      });

      // 1. Issue & Dismiss Presidential Notice
      await PocketFortressDefenseService.issuePresidentNotice('me', reason: 'Fake defense questions warning');
      var status = await PocketFortressDefenseService.getHouseStatus(18);
      expect(status.presidentNotice, equals('Fake defense questions warning'));

      await PocketFortressDefenseService.dismissPresidentNotice('me');
      status = await PocketFortressDefenseService.getHouseStatus(18);
      expect(status.presidentNotice, isNull);

      // 2. Sentence to Jail
      await PocketFortressDefenseService.sentenceToJail('me', days: 3, reason: 'Nonsense defense traps');
      expect(await PocketFortressDefenseService.isHouseJailed('me'), isTrue);

      status = await PocketFortressDefenseService.getHouseStatus(18);
      expect(status.isJailed, isTrue);
      expect(status.jailDaysRemaining, greaterThan(0));

      await PocketFortressDefenseService.releaseFromJail('me');
      expect(await PocketFortressDefenseService.isHouseJailed('me'), isFalse);

      // 3. Demote Levels
      final newDay = await PocketFortressDefenseService.demoteHouseLevel('me', levels: 2);
      expect(newDay, equals(16));

      // 4. Ban & Asset Confiscation (coins set to 0, level reset to 0)
      await PocketFortressDefenseService.banHouseWithAssetConfiscation('me', reason: 'Unfair fake traps');
      status = await PocketFortressDefenseService.getHouseStatus(1);
      expect(status.isBanned, isTrue);
      expect(status.totalCoins, equals(0)); // Confiscated!
    });

    test('Raid Breach logs attacker avatar weapon', () async {
      SharedPreferences.setMockInitialValues({
        'pocket_house_hp': 100,
        'pocket_house_coins': 150,
        'user_house_iron_dome': false,
      });

      await PocketFortressDefenseService.processRaidBreach(
        defenderHouseId: 'me',
        damageHp: 60,
        attackerName: 'Cannon Master',
        attackerAvatar: '🐅',
        attackerWeapon: '💥 Royal Siege Cannon',
      );

      final raids = await PocketFortressDefenseService.getRecentRaids();
      expect(raids.first.attackerWeapon, equals('💥 Royal Siege Cannon'));
    });
  });
}


