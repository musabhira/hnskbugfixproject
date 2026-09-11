import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/bridge_builder_models.dart';

void main() {
  group('BridgeBuilder – Level 13 Models & Sentence Validation', () {
    test('Level data is properly defined', () {
      expect(kMission13BridgeBuilderData.title, contains('Level 13'));
      expect(kMission13BridgeBuilderData.challenges.isNotEmpty, isTrue);
      expect(kMission13BridgeBuilderData.areas.length, equals(7));
    });

    test('Has 10 progressive sentence construction challenges', () {
      expect(kMission13BridgeBuilderData.challenges.length, equals(10));
    });

    test('Challenge 1 builds "I go to work every day."', () {
      final ch1 = kMission13BridgeBuilderData.challenges[0];
      expect(ch1.canonicalSentence, equals('I go to work every day.'));
      expect(ch1.words.length, equals(6));
      expect(ch1.repairType, equals(RepairType.bridge));
    });

    test('Challenge 3 forms question "Where do you work?"', () {
      final ch3 = kMission13BridgeBuilderData.challenges[2];
      expect(ch3.canonicalSentence, equals('Where do you work?'));
      expect(ch3.repairType, equals(RepairType.terminal));
    });

    test('Challenge 6 accepts both full and contracted negative forms', () {
      final ch6 = kMission13BridgeBuilderData.challenges[5];
      expect(ch6.acceptedSentences, contains('I do not understand the question.'));
      expect(ch6.acceptedSentences, contains("I don't understand the question."));
    });

    test('Challenge 7 accepts both "will" and "\'ll" future forms', () {
      final ch7 = kMission13BridgeBuilderData.challenges[6];
      expect(ch7.acceptedSentences, contains('I will call you tomorrow.'));
      expect(ch7.acceptedSentences, contains("I'll call you tomorrow."));
    });

    test('Challenge 9 is complex with conjunction "because"', () {
      final ch9 = kMission13BridgeBuilderData.challenges[8];
      expect(ch9.canonicalSentence, contains('because'));
      expect(ch9.words.length, equals(9));
      expect(ch9.words.any((w) => w.partOfSpeech == PartOfSpeech.conjunction), isTrue);
    });

    test('Challenge 10 is Grand Restoration with multi-part sentences', () {
      final ch10 = kMission13BridgeBuilderData.challenges[9];
      expect(ch10.repairType, equals(RepairType.controlTower));
      expect(ch10.xpReward, equals(60));
      expect(ch10.multiPartSubSentences, isNotNull);
      expect(ch10.multiPartSubSentences!.length, equals(5));
    });

    test('SentenceValidationService normalizes spaces, punctuation, and casing', () {
      final accepted = ['I go to work every day.'];
      expect(SentenceValidationService.validateSentence('I go to work every day.', accepted), isTrue);
      expect(SentenceValidationService.validateSentence('i go to work every day', accepted), isTrue);
      expect(SentenceValidationService.validateSentence('I go to work yesterday', accepted), isFalse);
    });

    test('SentenceValidationService recognizes contractions with standard and curly quotes', () {
      final accepted = ["I don't understand."];
      expect(SentenceValidationService.validateSentence("I don't understand.", accepted), isTrue);
      expect(SentenceValidationService.validateSentence("I don’t understand.", accepted), isTrue);
    });
  });
}
