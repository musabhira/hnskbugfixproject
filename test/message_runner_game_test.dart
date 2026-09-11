import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/message_runner_models.dart';

void main() {
  group('MessageRunner – Level 12 Models & Curriculum', () {
    test('Level data is properly defined', () {
      expect(kMission12MessageRunnerData.title, contains('Level 12'));
      expect(kMission12MessageRunnerData.tasks.isNotEmpty, isTrue);
      expect(kMission12MessageRunnerData.zones.length, equals(9));
      expect(kMission12MessageRunnerData.npcs.length, equals(6));
    });

    test('Has 10 delivery tasks', () {
      expect(kMission12MessageRunnerData.tasks.length, equals(10));
    });

    test('All tasks have non-empty prompt and body', () {
      for (final t in kMission12MessageRunnerData.tasks) {
        expect(t.prompt.isNotEmpty, isTrue);
        expect(t.messageBody.isNotEmpty, isTrue);
        expect(t.recipientName.isNotEmpty, isTrue);
      }
    });

    test('Task 1 is deliverInfo with Daniel as recipient', () {
      final t1 = kMission12MessageRunnerData.tasks[0];
      expect(t1.recipientId, equals('daniel'));
      expect(t1.actionType, equals(MessageActionType.deliverInfo));
      expect(t1.dialogueOptions[t1.correctOptionIndex], contains('3 PM'));
    });

    test('Task 4 has 3 recipient match pairs', () {
      final t4 = kMission12MessageRunnerData.tasks[3];
      expect(t4.actionType, equals(MessageActionType.matchRecipients));
      expect(t4.matchPairs, isNotNull);
      expect(t4.matchPairs!.length, equals(3));
      expect(t4.matchPairs!.values, containsAll(['Sarah', 'Michael', 'Daniel']));
    });

    test('Task 5 is typeReply with late by 10 minutes', () {
      final t5 = kMission12MessageRunnerData.tasks[4];
      expect(t5.actionType, equals(MessageActionType.typeReply));
      expect(t5.acceptedKeywords, containsAll(['late', 'minutes']));
    });

    test('Task 6 is spelling correction for appointment', () {
      final t6 = kMission12MessageRunnerData.tasks[5];
      expect(t6.actionType, equals(MessageActionType.spellingCorrection));
      expect(t6.misspelledWord, equals('appointmnt'));
      expect(t6.correctWord, equals('appointment'));
    });

    test('Task 10 is URGENT with 45s timer and highest XP', () {
      final t10 = kMission12MessageRunnerData.tasks[9];
      expect(t10.priority, equals(MessagePriority.urgent));
      expect(t10.actionType, equals(MessageActionType.urgentDelivery));
      expect(t10.timeLimitSeconds, equals(45));
      expect(t10.xpReward, equals(50));
    });

    test('All 9 campus zones are defined', () {
      final zoneIds = kMission12MessageRunnerData.zones.map((z) => z.id).toSet();
      expect(
        zoneIds,
        containsAll([
          'reception',
          'open_office',
          'meeting_rooms',
          'cafeteria',
          'training_room',
          'managers_office',
          'waiting_area',
          'conference_room',
          'comm_desk',
        ]),
      );
    });

    test('Evaluation service accepts valid keywords with natural sentence', () {
      final result = MessageEvaluationService.evaluateReply(
        input: "I will be 10 minutes late, please start.",
        requiredKeywords: ['late', '10', 'minutes'],
        referenceAnswer: "I'll be late by ten minutes.",
      );
      expect(result.isAcceptable, isTrue);
      expect(result.score, greaterThanOrEqualTo(70));
    });

    test('Evaluation service rejects empty input', () {
      final result = MessageEvaluationService.evaluateReply(
        input: "",
        requiredKeywords: ['late', '10'],
        referenceAnswer: "I'll be late.",
      );
      expect(result.isAcceptable, isFalse);
      expect(result.score, equals(0));
    });
  });
}
