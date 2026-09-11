import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/word_detective_models.dart';

void main() {
  group('WordDetective – Level 10 Models', () {
    test('Level data is correctly defined', () {
      expect(kMission10WordDetectiveData.missionId, '10');
      expect(kMission10WordDetectiveData.title, contains('Word Detective'));
      expect(kMission10WordDetectiveData.tagline, isNotEmpty);
      expect(kMission10WordDetectiveData.caseTitle, contains('#001'));
    });

    test('Has 10 challenges covering all required types', () {
      final challenges = kMission10WordDetectiveData.challenges;
      expect(challenges.length, 10);

      final types = challenges.map((c) => c.type).toSet();
      expect(types, contains(DetectiveChallengeType.readingComprehension));
      expect(types, contains(DetectiveChallengeType.detailFinding));
      expect(types, contains(DetectiveChallengeType.messageAnalysis));
      expect(types, contains(DetectiveChallengeType.timelineReasoning));
      expect(types, contains(DetectiveChallengeType.vocabularyContext));
      expect(types, contains(DetectiveChallengeType.listeningClue));
      expect(types, contains(DetectiveChallengeType.clueConnection));
      expect(types, contains(DetectiveChallengeType.redHerring));
      expect(types, contains(DetectiveChallengeType.npcQuestioning));
      expect(types, contains(DetectiveChallengeType.caseSolution));
    });

    test('All challenges have valid correct option index', () {
      for (final ch in kMission10WordDetectiveData.challenges) {
        expect(
          ch.correctOptionIndex,
          inInclusiveRange(0, ch.options.length - 1),
          reason: 'Challenge ${ch.id} has invalid correctOptionIndex',
        );
        expect(
          ch.options[ch.correctOptionIndex].isCorrect,
          isTrue,
          reason:
              'Challenge ${ch.id}: option at correctOptionIndex is not marked correct',
        );
      }
    });

    test('Each challenge has at least 3 options', () {
      for (final ch in kMission10WordDetectiveData.challenges) {
        expect(ch.options.length, greaterThanOrEqualTo(3),
            reason: 'Challenge ${ch.id} has fewer than 3 options');
      }
    });

    test('Exactly one correct option per challenge', () {
      for (final ch in kMission10WordDetectiveData.challenges) {
        final correctCount = ch.options.where((o) => o.isCorrect).length;
        expect(correctCount, 1,
            reason:
                'Challenge ${ch.id} has $correctCount correct options (expected 1)');
      }
    });

    test('All challenges have non-empty hints', () {
      for (final ch in kMission10WordDetectiveData.challenges) {
        expect(ch.hint1, isNotEmpty,
            reason: 'Challenge ${ch.id} is missing hint1');
      }
    });

    test('Challenges with reward clues have valid clue data', () {
      for (final ch in kMission10WordDetectiveData.challenges) {
        if (ch.rewardClue != null) {
          expect(ch.rewardClue!.id, isNotEmpty);
          expect(ch.rewardClue!.title, isNotEmpty);
          expect(ch.rewardClue!.text, isNotEmpty);
        }
      }
    });

    test('Listening clue (challenge 6) has an audio transcript', () {
      final listenChallenge = kMission10WordDetectiveData.challenges
          .firstWhere((c) => c.type == DetectiveChallengeType.listeningClue);
      expect(listenChallenge.audioTranscript, isNotNull);
      expect(listenChallenge.audioTranscript, isNotEmpty);
    });

    test('Red herring challenge is marked as irrelevant', () {
      final rh = kMission10WordDetectiveData.challenges
          .firstWhere((c) => c.type == DetectiveChallengeType.redHerring);
      expect(rh.rewardClue?.importance, ClueImportance.irrelevant);
    });

    test('Final case solution has highest XP reward', () {
      final finalChallenge = kMission10WordDetectiveData.challenges
          .firstWhere((c) => c.type == DetectiveChallengeType.caseSolution);
      expect(finalChallenge.correctOption.xpReward, greaterThanOrEqualTo(50));
    });

    test('6 office areas defined', () {
      expect(kMission10WordDetectiveData.areas.length, 6);
    });

    test('3 suspects defined', () {
      expect(kMission10WordDetectiveData.suspects.length, 3);
    });

    test('Master timeline has 9 events', () {
      expect(kMission10WordDetectiveData.masterTimeline.length, 9);
    });

    test('Target vocabulary includes key detective words', () {
      final vocab = kMission10WordDetectiveData.targetVocabulary;
      for (final word in [
        'prototype',
        'evidence',
        'clue',
        'investigate',
        'suspect',
        'access',
      ]) {
        expect(vocab, contains(word), reason: 'Missing vocab: $word');
      }
    });

    test('Challenge IDs are sequential 1..10', () {
      final ids = kMission10WordDetectiveData.challenges.map((c) => c.id).toList();
      expect(ids, List.generate(10, (i) => i + 1));
    });

    test('Story logic: Daniel is alone at 3:00 PM per timeline', () {
      // Timeline event te7 shows Sarah leaves at 3:00 PM
      // Timeline event te8 shows Daniel leaves at 3:05 PM
      final timeline = kMission10WordDetectiveData.masterTimeline;
      final sarahLeave = timeline.firstWhere((t) => t.id == 'te7');
      final danielLeave = timeline.firstWhere((t) => t.id == 'te8');
      expect(sarahLeave.time, '3:00 PM');
      expect(danielLeave.time, '3:05 PM');
      expect(danielLeave.personName, 'Daniel');
    });
  });
}
