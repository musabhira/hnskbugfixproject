import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/adventure_models.dart';

void main() {
  group('Mission 01 Career Adventure Curriculum Tests', () {
    test('Level 1 curriculum has exactly 10 comprehensive challenges', () {
      expect(kMission01LevelData.challenges.length, equals(10));
      expect(kMission01LevelData.levelNumber, equals(1));
      expect(kMission01LevelData.title, contains('Mission 01'));
    });

    test('All 10 workplace vocabulary terms are populated', () {
      final expectedVocab = [
        'appointment',
        'opportunity',
        'experience',
        'available',
        'schedule',
        'information',
        'communication',
        'position',
        'requirement',
        'confident',
        'improve',
        'responsible',
      ];
      expect(kMission01LevelData.targetVocabularyList, containsAll(expectedVocab));
    });

    test('Challenge 1 is Reception Check-in with correct option', () {
      final c1 = kMission01LevelData.challenges[0];
      expect(c1.id, equals(1));
      expect(c1.targetVocabulary, equals('appointment'));
      final correctOpt = c1.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('I have an appointment at 10:00 AM'));
    });

    test('Challenge 4 repairs present perfect continuous tense', () {
      final c4 = kMission01LevelData.challenges[3];
      expect(c4.id, equals(4));
      expect(c4.targetVocabulary, equals('experience'));
      final correctOpt = c4.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('I have been working here for three years.'));
    });

    test('Challenge 5 has valid listening audio prompt', () {
      final c5 = kMission01LevelData.challenges[4];
      expect(c5.id, equals(5));
      expect(c5.audioPrompt, isNotNull);
      expect(c5.audioPrompt, contains('available after lunch'));
      final correctOpt = c5.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, equals('After lunch'));
    });

    test('Challenge 7 has interactive sentence builder tiles matching target', () {
      final c7 = kMission01LevelData.challenges[6];
      expect(c7.id, equals(7));
      expect(c7.type, equals(AdventureChallengeType.sentenceBuilder));
      expect(c7.sentenceTiles, isNotNull);
      expect(c7.targetSentence, isNotNull);

      // Verify that all words in target sentence exist in tiles
      final targetWords = c7.targetSentence!.split(' ');
      for (final word in targetWords) {
        expect(c7.sentenceTiles, contains(word));
      }
    });

    test('Challenge 8 has 8-second time limit for quick response', () {
      final c8 = kMission01LevelData.challenges[7];
      expect(c8.id, equals(8));
      expect(c8.type, equals(AdventureChallengeType.quickResponse));
      expect(c8.timeLimitSeconds, equals(8));
      final correctOpt = c8.options.firstWhere((o) => o.isCorrect);
      expect(correctOpt.text, contains('learn, contribute my skills, and grow'));
    });

    test('NPCs contain Sarah, David, and Director Miller', () {
      expect(kMission01LevelData.npcs.length, equals(3));
      final ids = kMission01LevelData.npcs.map((n) => n.id).toList();
      expect(ids, containsAll(['receptionist_sarah', 'colleague_david', 'director_miller']));
    });
  });
}
