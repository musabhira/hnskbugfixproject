import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/adventure_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/word_factory_models.dart';

void main() {
  group('Mission 04 Word Factory Curriculum Tests', () {
    test('Level 4 curriculum has exactly 10 comprehensive challenges', () {
      expect(kMission04WordFactoryData.challenges.length, equals(10));
      expect(kMission04WordFactoryData.levelNumber, equals(4));
      expect(kMission04WordFactoryData.title, contains('Mission 04 – Word Factory'));
    });

    test('All 20 target vocabulary words are defined in kWordFactoryVocabulary', () {
      final expectedVocab = [
        'communicate',
        'activate',
        'identify',
        'repair',
        'transmit',
        'efficient',
        'reliable',
        'generate',
        'complete',
        'assemble',
        'override',
        'confirm',
        'procedure',
        'terminal',
        'sequence',
        'malfunction',
        'diagnostic',
        'component',
        'protocol',
        'restore',
      ];
      expect(kWordFactoryVocabulary.length, equals(20));
      expect(kMission04WordFactoryData.targetVocabularyList, containsAll(expectedVocab));
    });

    test('All 6 factory zones are defined with positions and sizes', () {
      expect(kFactoryZones.length, equals(6));
      final zoneIds = kFactoryZones.map((z) => z.id).toList();
      expect(
        zoneIds,
        containsAll([
          'entrance',
          'word_storage',
          'sentence_workshop',
          'communication_room',
          'grammar_lab',
          'control_room',
        ]),
      );
      for (final zone in kFactoryZones) {
        expect(zone.label, isNotEmpty);
        expect(zone.icon, isNotEmpty);
        expect(zone.size.width, isPositive);
        expect(zone.size.height, isPositive);
      }
    });

    test('3 NPCs are defined with proper roles and locations', () {
      expect(kMission04WordFactoryData.npcs.length, equals(3));
      final names = kMission04WordFactoryData.npcs.map((n) => n.name).toList();
      expect(names, containsAll(['Alex Rivera', 'Maya Chen', 'Director Kai']));
    });

    test('Challenge 1 is Vocabulary in Context for "activate"', () {
      final c1 = kMission04WordFactoryData.challenges[0];
      expect(c1.id, equals(1));
      expect(c1.type, equals(AdventureChallengeType.vocabularyInContext));
      expect(c1.targetVocabulary, equals('activate'));
      final correctOpt = c1.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('activate'));
    });

    test('Challenge 2 is Word Repair for present perfect duration and subject agreement', () {
      final c2 = kMission04WordFactoryData.challenges[1];
      expect(c2.id, equals(2));
      expect(c2.type, equals(AdventureChallengeType.wordRepair));
      expect(c2.targetVocabulary, equals('reliable'));
      final correctOpt = c2.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('for three days'));
      expect(correctOpt.text, contains('has been running'));
    });

    test('Challenge 3 is Sentence Builder for phrase module assembly', () {
      final c3 = kMission04WordFactoryData.challenges[2];
      expect(c3.id, equals(3));
      expect(c3.type, equals(AdventureChallengeType.sentenceBuilder));
      expect(c3.targetVocabulary, equals('assemble'));
      expect(c3.sentenceTiles, isNotNull);
      expect(c3.sentenceTiles, containsAll(['machine', 'operate', 'efficiently', 'can', 'only']));
      expect(c3.targetSentence, equals('The machine can only operate with correct input'));
    });

    test('Challenge 4 is Vocabulary in Context for "diagnostic"', () {
      final c4 = kMission04WordFactoryData.challenges[3];
      expect(c4.id, equals(4));
      expect(c4.type, equals(AdventureChallengeType.vocabularyInContext));
      expect(c4.targetVocabulary, equals('diagnostic'));
      final correctOpt = c4.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('diagnostic'));
    });

    test('Challenge 5 is Listening Comprehension for protocol order', () {
      final c5 = kMission04WordFactoryData.challenges[4];
      expect(c5.id, equals(5));
      expect(c5.type, equals(AdventureChallengeType.listening));
      expect(c5.targetVocabulary, equals('protocol'));
      expect(c5.audioPrompt, isNotNull);
      final correctOpt = c5.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('Confirm the protocol'));
    });

    test('Challenge 6 is Conversation Choice for professional status update', () {
      final c6 = kMission04WordFactoryData.challenges[5];
      expect(c6.id, equals(6));
      expect(c6.type, equals(AdventureChallengeType.conversationChoice));
      expect(c6.targetVocabulary, equals('confirm'));
      final correctOpt = c6.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('I am proceeding with the repair now'));
    });

    test('Challenge 7 is Quick Response 8-second timer for simple past tense', () {
      final c7 = kMission04WordFactoryData.challenges[6];
      expect(c7.id, equals(7));
      expect(c7.type, equals(AdventureChallengeType.quickResponse));
      expect(c7.timeLimitSeconds, equals(8));
      expect(c7.targetVocabulary, equals('malfunction'));
      final correctOpt = c7.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('failed'));
    });

    test('Challenge 8 is Word Repair for preposition "responsible for" and parallel gerunds', () {
      final c8 = kMission04WordFactoryData.challenges[7];
      expect(c8.id, equals(8));
      expect(c8.type, equals(AdventureChallengeType.wordRepair));
      expect(c8.targetVocabulary, equals('procedure'));
      final correctOpt = c8.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('responsible for generating'));
      expect(correctOpt.text, contains('and submitting'));
    });

    test('Challenge 9 is Conditional Reading comprehension with "unless"', () {
      final c9 = kMission04WordFactoryData.challenges[8];
      expect(c9.id, equals(9));
      expect(c9.type, equals(AdventureChallengeType.information));
      expect(c9.targetVocabulary, equals('sequence'));
      final correctOpt = c9.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('IF the operator enters'));
    });

    test('Challenge 10 is Final System Restore with present perfect passive', () {
      final c10 = kMission04WordFactoryData.challenges[9];
      expect(c10.id, equals(10));
      expect(c10.type, equals(AdventureChallengeType.finalInterview));
      expect(c10.targetVocabulary, equals('restore'));
      final correctOpt = c10.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('have been successfully repaired'));
      expect(correctOpt.text, contains('has been fully restored'));
    });

    test('All challenges have valid Malayalam meanings, questions, titles, and positive XP', () {
      for (final challenge in kMission04WordFactoryData.challenges) {
        expect(challenge.vocabularyMeaning, isNotEmpty);
        expect(challenge.question, isNotEmpty);
        expect(challenge.title, isNotEmpty);
        expect(challenge.npcDialogue, isNotEmpty);
        expect(challenge.xpReward, isPositive);
      }
    });
  });
}
