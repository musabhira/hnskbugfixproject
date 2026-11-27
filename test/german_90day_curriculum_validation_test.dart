import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_learning_track_service.dart';
import 'package:pocket_mates_app/custom_code/widgets/german_90day/curriculum_data/pocket_german_90day_master_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/german_90day/curriculum_data/pocket_german_days1to5_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/learning_models.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_90day_vocab_curriculum.dart';

void main() {
  group('German 90-Day Complete Master Track Validation (Days 1–90)', () {
    setUp(() {
      PocketLearningTrackService.activeTrackNotifier.value =
          PocketLearningTrackService.trackGerman;
    });

    tearDown(() {
      PocketLearningTrackService.activeTrackNotifier.value =
          PocketLearningTrackService.trackEnglish;
    });

    test('Track service switches cleanly to German de-DE & 90-day config', () {
      expect(PocketLearningTrackService.isGerman, isTrue);
      expect(PocketLearningTrackService.isEnglish, isFalse);
      expect(PocketLearningTrackService.ttsLocale, equals('de-DE'));
      expect(PocketLearningTrackService.sttLocale, equals('de_DE'));
      expect(PocketLearningTrackService.germanMaxDay, equals(90));
      expect(
          PocketLearningTrackService.dayPrefPrefix, equals('pocket_de_day_'));
      expect(PocketLearningTrackService.displayTitle,
          equals('Deutsch 90-Tage-Kurs'));
      expect(
        PocketLearningTrackService.displayPillTitle,
        equals('DEUTSCH 90-DAY TRACK'),
      );
    });

    test('German Alphabet has all 30 letters (A-Z, Ä, Ö, Ü, ß)', () {
      final letters = PocketGermanDays1To5Data.germanAlphabetLetters;
      expect(letters.length, equals(30));
      final symbols = <String>{};
      for (final item in letters) {
        final letter = (item['letter'] ?? '').toString().trim();
        final word = (item['word'] ?? '').toString().trim();
        final voice = (item['voice'] ?? '').toString().trim();
        final meaning = item['meaning'] as Map<String, dynamic>?;
        expect(letter.isNotEmpty, isTrue);
        expect(word.isNotEmpty, isTrue);
        expect(voice.isNotEmpty, isTrue);
        expect(meaning, isNotNull);
        expect((meaning?['ml'] ?? '').toString().isNotEmpty, isTrue);
        expect(symbols.add(letter), isTrue,
            reason: 'Duplicate letter: $letter');
      }
      expect(symbols.containsAll(['A', 'Z', 'Ä', 'Ö', 'Ü', 'ß']), isTrue);
    });

    test(
        'All 90 Days have unique lesson titles & 900 unique German vocab words',
        () {
      final lessonTitles = <String>{};
      final allVocabWords = <String>{};
      final duplicateWords = <String>[];
      final duplicateTitles = <String>[];

      for (int day = 1; day <= 90; day++) {
        final spec = PocketGerman90DayMasterData.getLessonSpecMap(day);
        final title = (spec['title'] ?? '').toString();
        final phaseName = (spec['phaseName'] ?? '').toString();
        final focusArea = (spec['focusArea'] ?? '').toString();
        final speakingDrill = (spec['speakingDrill'] ?? '').toString();
        final grammarConcept = (spec['grammarConcept'] ?? '').toString();
        final peerChatMission = (spec['peerChatMission'] ?? '').toString();
        expect(title.trim().isNotEmpty, isTrue, reason: 'Day $day empty title');
        expect(phaseName.trim().isNotEmpty, isTrue,
            reason: 'Day $day empty phase');
        expect(focusArea.trim().isNotEmpty, isTrue,
            reason: 'Day $day empty focus');
        expect(speakingDrill.trim().isNotEmpty, isTrue,
            reason: 'Day $day empty drill');
        expect(grammarConcept.trim().isNotEmpty, isTrue,
            reason: 'Day $day empty grammar');
        expect(peerChatMission.trim().isNotEmpty, isTrue,
            reason: 'Day $day empty peerChat');
        if (!lessonTitles.add(title.trim().toLowerCase())) {
          duplicateTitles.add('Day $day: $title');
        }

        final vocab = PocketGerman90DayMasterData.getVocabForDay(day);
        expect(vocab.length, equals(10),
            reason: 'Day $day must have 10 vocab words');
        for (int i = 0; i < vocab.length; i++) {
          final v = vocab[i];
          expect(v.word.trim().isNotEmpty, isTrue,
              reason: 'Day $day#$i empty word');
          expect(v.partOfSpeech.trim().isNotEmpty, isTrue,
              reason: 'Day $day#$i empty POS');
          expect(v.definition.trim().isNotEmpty, isTrue,
              reason: 'Day $day#$i empty def');
          expect(v.malayalamMeaning.trim().isNotEmpty, isTrue,
              reason: 'Day $day#$i empty ml');
          expect(v.tamilMeaning.trim().isNotEmpty, isTrue,
              reason: 'Day $day#$i empty ta');
          expect(v.hindiMeaning.trim().isNotEmpty, isTrue,
              reason: 'Day $day#$i empty hi');
          expect(v.exampleSentence.trim().isNotEmpty, isTrue,
              reason: 'Day $day#$i empty example');
          expect(v.phonetic.trim().isNotEmpty, isTrue,
              reason: 'Day $day#$i empty phonetic');

          final normalized = v.word.trim().toLowerCase();
          if (!allVocabWords.add(normalized)) {
            duplicateWords.add('Day $day: ${v.word}');
          }
        }
      }

      expect(
        duplicateTitles,
        isEmpty,
        reason: 'Duplicate German lesson titles: $duplicateTitles',
      );
      expect(lessonTitles.length, equals(90));
      expect(
        duplicateWords,
        isEmpty,
        reason: 'Duplicate German vocab words: $duplicateWords',
      );
      expect(allVocabWords.length, equals(900));
    });

    test(
        'All 90 Days have valid Sentence Builder, Useful Phrases, Verbs, Negatives, & Chat Replies',
        () {
      for (int day = 1; day <= 90; day++) {
        // Sentence Builder
        final sentences = PocketGerman90DayMasterData.getSentencesForDay(day);
        expect(sentences.isNotEmpty, isTrue,
            reason: 'Day $day empty sentences');
        for (final s in sentences) {
          expect(s.sentence.trim().isNotEmpty, isTrue,
              reason: 'Day $day empty sentence');
          expect(s.translationMl.trim().isNotEmpty, isTrue,
              reason: 'Day $day empty ml');
          expect(s.hint.trim().isNotEmpty, isTrue,
              reason: 'Day $day empty hint');
          expect(s.tiles.isNotEmpty, isTrue, reason: 'Day $day empty tiles');
          expect(
            s.tiles.map((t) => t.word).join(' '),
            equals(s.sentence.trim()),
            reason: 'Day $day tile mismatch for "${s.sentence}"',
          );
        }

        // Useful Phrases
        final phrasesDay = PocketGerman90DayMasterData.getDayPhrases(day);
        expect(phrasesDay.day, equals(day));
        expect(phrasesDay.anchorTheme.trim().isNotEmpty, isTrue);
        expect(phrasesDay.anchorWord.trim().isNotEmpty, isTrue);
        expect(phrasesDay.descriptionEn.trim().isNotEmpty, isTrue);
        expect(phrasesDay.descriptionMl.trim().isNotEmpty, isTrue);
        expect(phrasesDay.phrases.isNotEmpty, isTrue,
            reason: 'Day $day empty phrases');
        for (final p in phrasesDay.phrases) {
          expect(p.phraseEn.trim().isNotEmpty, isTrue);
          expect(p.meaningMl.trim().isNotEmpty, isTrue);
          expect(p.words.isNotEmpty, isTrue);
        }

        // Verb Timeline
        final verbs = PocketGerman90DayMasterData.getVerbsForDay(day);
        expect(verbs.isNotEmpty, isTrue, reason: 'Day $day empty verbs');
        for (final v in verbs) {
          expect(v.baseVerb.trim().isNotEmpty, isTrue);
          expect(v.meaningMl.trim().isNotEmpty, isTrue);
          expect(v.past.trim().isNotEmpty, isTrue);
          expect(v.present.trim().isNotEmpty, isTrue);
          expect(v.future.trim().isNotEmpty, isTrue);
          expect(v.pastSentence.trim().isNotEmpty, isTrue);
          expect(v.presentSentence.trim().isNotEmpty, isTrue);
          expect(v.futureSentence.trim().isNotEmpty, isTrue);
          expect(v.rhythmChant.trim().isNotEmpty, isTrue);
          expect(v.grammarTrapMl.trim().isNotEmpty, isTrue);
        }

        // Negative Sentence Builder (wordBank must cover every space-split token)
        final negRounds =
            PocketGerman90DayMasterData.getNegativeRoundsForDay(day);
        expect(negRounds.isNotEmpty, isTrue,
            reason: 'Day $day empty negRounds');
        for (final r in negRounds) {
          expect(r.positiveSentence.trim().isNotEmpty, isTrue);
          expect(r.negativeSentence.trim().isNotEmpty, isTrue);
          expect(r.negativeSentenceMl.trim().isNotEmpty, isTrue);
          final targetTokens =
              r.negativeSentence.split(' ').where((w) => w.isNotEmpty).toList();
          expect(targetTokens.isNotEmpty, isTrue);
          for (final token in targetTokens) {
            expect(
              r.wordBank.contains(token),
              isTrue,
              reason:
                  'Day $day NegativeBuilder missing token "$token" in wordBank ${r.wordBank} for "${r.negativeSentence}"',
            );
          }
        }

        // Chat Reply Builder (wordBank must cover every space-split token)
        final chatScenarios =
            PocketGerman90DayMasterData.getChatScenariosForDay(day);
        expect(chatScenarios.isNotEmpty, isTrue,
            reason: 'Day $day empty chatScenarios');
        for (final c in chatScenarios) {
          expect(c.avatarPrompt.trim().isNotEmpty, isTrue);
          expect(c.expectedReply.trim().isNotEmpty, isTrue);
          expect(c.expectedReplyMl.trim().isNotEmpty, isTrue);
          final replyTokens =
              c.expectedReply.split(' ').where((w) => w.isNotEmpty).toList();
          expect(replyTokens.isNotEmpty, isTrue);
          for (final token in replyTokens) {
            expect(
              c.wordBank.contains(token),
              isTrue,
              reason:
                  'Day $day ChatReply missing token "$token" in wordBank ${c.wordBank} for "${c.expectedReply}"',
            );
          }
        }
      }
    });

    test(
        'All 90 Days have Speech Topics, 20-Turn Spoken Simulator, Avatar Room Spec, & Gate Exams',
        () {
      for (int day = 1; day <= 90; day++) {
        // Mini Speech Practice
        final topics = PocketGerman90DayMasterData.getSpeechTopicsForDay(day);
        expect(topics.isNotEmpty, isTrue,
            reason: 'Day $day empty speech topics');
        for (final t in topics) {
          expect(t.title.trim().isNotEmpty, isTrue);
          expect(t.passageEn.trim().isNotEmpty, isTrue);
          expect(t.passageMl.trim().isNotEmpty, isTrue);
          expect(t.speechTipEn.trim().isNotEmpty, isTrue);
          expect(t.speechTipMl.trim().isNotEmpty, isTrue);
        }

        // 20-Turn Spoken Avatar Simulator
        final simPlan =
            PocketGerman90DayMasterData.getSpokenSimulatorPlanForDay(day);
        expect(simPlan.day, equals(day));
        expect(simPlan.topicTitle.trim().isNotEmpty, isTrue);
        expect(simPlan.topicTitleMl.trim().isNotEmpty, isTrue);
        expect(simPlan.scenarioContext.trim().isNotEmpty, isTrue);
        expect(simPlan.exchanges.length, equals(20),
            reason: 'Day $day simulator must have 20 turns');
        for (int i = 0; i < simPlan.exchanges.length; i++) {
          final ex = simPlan.exchanges[i];
          expect(ex.stepIndex, equals(i + 1));
          expect(ex.avatarPrompt.trim().isNotEmpty, isTrue);
          expect(ex.avatarPromptMl.trim().isNotEmpty, isTrue);
          expect(ex.responseOptions.length, greaterThanOrEqualTo(2));
        }

        // Avatar Chat Concept Room Spec
        final specMap = PocketGerman90DayMasterData.getAvatarChatSpecMap(day);
        expect((specMap['titleEn'] ?? '').toString().trim().isNotEmpty, isTrue);
        expect((specMap['drills'] as List).isNotEmpty, isTrue);

        // Spoken Gate Exam
        final exam = PocketGerman90DayMasterData.getExamForDay(day);
        expect(exam.length, greaterThanOrEqualTo(3),
            reason: 'Day $day exam < 3 Qs');
        for (final q in exam) {
          final targetText = (q['targetText'] ?? '').toString().trim();
          final voicePrompt = (q['voicePrompt'] ?? '').toString().trim();
          final options = q['options'] as List?;
          final correctIndex = q['correctIndex'] as int?;
          expect(targetText.isNotEmpty, isTrue);
          expect(voicePrompt.isNotEmpty, isTrue);
          expect(options, isNotNull);
          expect(options!.length, greaterThanOrEqualTo(2));
          expect(correctIndex, isNotNull);
          expect(correctIndex! >= 0 && correctIndex < options.length, isTrue);
        }
      }
    });

    test(
        'Switching back to English track keeps original English curriculum intact',
        () {
      PocketLearningTrackService.activeTrackNotifier.value =
          PocketLearningTrackService.trackEnglish;
      expect(PocketLearningTrackService.isGerman, isFalse);
      expect(PocketLearningTrackService.ttsLocale, equals('en-US'));
      final enDay1Vocab = Pocket90DayVocabCurriculum.getVocabForDay(1);
      expect(enDay1Vocab.isNotEmpty, isTrue);
      expect(enDay1Vocab.first.word, equals('Be'));
      final enDay1Lesson = EnglishCurriculumLesson.getLessonForDay(1);
      expect(enDay1Lesson.title, isNot(contains('Hallo & Ich bin')));
    });
  });
}
