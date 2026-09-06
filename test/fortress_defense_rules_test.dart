import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_fortress_defense_service.dart';
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
}

