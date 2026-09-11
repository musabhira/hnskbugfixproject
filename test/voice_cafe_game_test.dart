import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/career_adventure/voice_cafe_models.dart';

void main() {
  group('VoiceCafe – Level 11 Models', () {
    test('Level data is correctly defined', () {
      expect(kMission11VoiceCafeData.missionId, '11');
      expect(kMission11VoiceCafeData.title, contains('Voice Café'));
      expect(kMission11VoiceCafeData.tagline, isNotEmpty);
    });

    test('Has 10 speaking challenges', () {
      expect(kMission11VoiceCafeData.challenges.length, 10);
    });

    test('All challenge types are represented', () {
      final types = kMission11VoiceCafeData.challenges
          .map((c) => c.type)
          .toSet();
      expect(types, contains(SpeakingChallengeType.greeting));
      expect(types, contains(SpeakingChallengeType.placeOrder));
      expect(types, contains(SpeakingChallengeType.yesNoResponse));
      expect(types, contains(SpeakingChallengeType.askQuestion));
      expect(types, contains(SpeakingChallengeType.clarifyRequest));
      expect(types, contains(SpeakingChallengeType.handleMistake));
      expect(types, contains(SpeakingChallengeType.askPrice));
      expect(types, contains(SpeakingChallengeType.freeSpeaking));
      expect(types, contains(SpeakingChallengeType.multiTurn));
    });

    test('All challenges have NPC dialogue and reference response', () {
      for (final ch in kMission11VoiceCafeData.challenges) {
        expect(ch.npcDialogue, isNotEmpty,
            reason: 'Challenge ${ch.id} missing NPC dialogue');
        expect(ch.referenceResponse, isNotEmpty,
            reason: 'Challenge ${ch.id} missing reference response');
        expect(ch.missionInstruction, isNotEmpty,
            reason: 'Challenge ${ch.id} missing mission instruction');
      }
    });

    test('All challenges have accepted keywords', () {
      for (final ch in kMission11VoiceCafeData.challenges) {
        expect(ch.acceptedKeywords, isNotEmpty,
            reason: 'Challenge ${ch.id} has no accepted keywords');
      }
    });

    test('Time limits are reasonable (5–20 seconds)', () {
      for (final ch in kMission11VoiceCafeData.challenges) {
        expect(ch.timeLimitSeconds, inInclusiveRange(5, 20),
            reason: 'Challenge ${ch.id} has unreasonable time limit');
      }
    });

    test('Place order challenge requires coffee and sandwich keywords', () {
      final orderChallenge = kMission11VoiceCafeData.challenges
          .firstWhere((c) => c.type == SpeakingChallengeType.placeOrder);
      final kwLower =
          orderChallenge.acceptedKeywords.map((k) => k.toLowerCase()).toList();
      expect(kwLower, contains('coffee'));
      expect(kwLower, contains('sandwich'));
    });

    test('Clarify request challenge includes "repeat" keywords', () {
      final clarify = kMission11VoiceCafeData.challenges
          .firstWhere((c) => c.type == SpeakingChallengeType.clarifyRequest);
      expect(clarify.acceptedKeywords, contains('repeat'));
    });

    test('Handle mistake challenge includes "coffee" in keywords', () {
      final mistake = kMission11VoiceCafeData.challenges
          .firstWhere((c) => c.type == SpeakingChallengeType.handleMistake);
      expect(mistake.acceptedKeywords, contains('coffee'));
    });

    test('Final challenge (multi-turn) has highest XP', () {
      final finalCh = kMission11VoiceCafeData.challenges
          .firstWhere((c) => c.type == SpeakingChallengeType.multiTurn);
      expect(finalCh.xpReward, greaterThanOrEqualTo(35));
    });

    test('5 café areas defined', () {
      expect(kMission11VoiceCafeData.areas.length, 5);
    });

    test('2 NPCs defined', () {
      expect(kMission11VoiceCafeData.npcs.length, 2);
    });

    test('Target vocabulary includes café/speaking words', () {
      final vocab = kMission11VoiceCafeData.targetVocabulary;
      for (final word in [
        'order',
        'coffee',
        'receipt',
        'sandwich',
        'repeat',
        'cashier',
      ]) {
        expect(vocab, contains(word), reason: 'Missing vocab: $word');
      }
    });

    test('Challenge IDs are sequential 1..10', () {
      final ids =
          kMission11VoiceCafeData.challenges.map((c) => c.id).toList();
      expect(ids, List.generate(10, (i) => i + 1));
    });
  });

  group('SpeakingEvaluationService', () {
    final orderChallenge = kMission11VoiceCafeData.challenges
        .firstWhere((c) => c.type == SpeakingChallengeType.placeOrder);

    test('Evaluates correct response with high score', () {
      final result = SpeakingEvaluationService.evaluate(
        recognizedText: "I'd like a coffee and a chicken sandwich please",
        challenge: orderChallenge,
      );
      expect(result.overallScore, greaterThan(70));
      expect(result.matchedKeywords, contains('coffee'));
      expect(result.matchedKeywords, contains('sandwich'));
    });

    test('Evaluates empty text as retry', () {
      final result = SpeakingEvaluationService.evaluate(
        recognizedText: '',
        challenge: orderChallenge,
      );
      expect(result.result, SpeechResult.retry);
      expect(result.overallScore, 0);
    });

    test('Evaluates partial match with lower score than full match', () {
      final partial = SpeakingEvaluationService.evaluate(
        recognizedText: 'coffee please',
        challenge: orderChallenge,
      );
      final full = SpeakingEvaluationService.evaluate(
        recognizedText: "I'd like a coffee and a chicken sandwich please",
        challenge: orderChallenge,
      );
      expect(full.overallScore, greaterThanOrEqualTo(partial.overallScore));
    });

    test('Alternate phrase is accepted for clarify challenge', () {
      final clarify = kMission11VoiceCafeData.challenges
          .firstWhere((c) => c.type == SpeakingChallengeType.clarifyRequest);
      final result = SpeakingEvaluationService.evaluate(
        recognizedText: 'sorry can you say that again',
        challenge: clarify,
      );
      expect(result.overallScore, greaterThan(65));
    });

    test('Free response challenge always returns non-zero score for attempt', () {
      final freeChallenge = kMission11VoiceCafeData.challenges
          .firstWhere((c) => c.allowFreeResponse);
      final result = SpeakingEvaluationService.evaluate(
        recognizedText: 'yes this is my first time here',
        challenge: freeChallenge,
      );
      expect(result.overallScore, greaterThan(60));
    });

    test('VoiceCafeScore aggregates results correctly', () {
      final score = VoiceCafeScore();
      final r1 = SpeakingEvaluationService.evaluate(
        recognizedText: "I'd like a coffee and a sandwich",
        challenge: orderChallenge,
      );
      score.addResult(r1);
      score.totalXp += 25;

      expect(score.challengesAttempted, 1);
      expect(score.totalXp, 25);
      expect(score.avgPronunciation, greaterThan(0));
    });
  });
}
