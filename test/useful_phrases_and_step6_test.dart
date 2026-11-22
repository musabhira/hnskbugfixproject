import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/curriculum_data/pocket_90day_useful_phrases_data.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_day_open_world_adventure_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Useful English Phrases Curriculum (90 Days) Tests', () {
    test('All 90 days have valid anchors and unique phrases', () {
      final seenAnchors = <int, String>{};

      for (int day = 1; day <= 90; day++) {
        final dayData = Pocket90DayUsefulPhrasesData.getDayPhrases(day);
        expect(dayData.day, equals(day));
        expect(dayData.anchorTheme.isNotEmpty, isTrue);
        expect(dayData.anchorWord.isNotEmpty, isTrue);
        expect(dayData.phrases.length, greaterThanOrEqualTo(4));

        seenAnchors[day] = dayData.anchorWord.toLowerCase();

        for (final phrase in dayData.phrases) {
          expect(phrase.phraseEn.isNotEmpty, isTrue);
          expect(phrase.meaningMl.isNotEmpty, isTrue);
          expect(phrase.meaningTa.isNotEmpty, isTrue);
          expect(phrase.meaningHi.isNotEmpty, isTrue);
          expect(phrase.meaningKn.isNotEmpty, isTrue);
          expect(phrase.words.length, greaterThanOrEqualTo(2));
        }
      }

      expect(seenAnchors.length, equals(90));
    });

    test('Day 1 contains How phrases matching user specification', () {
      final day1 = Pocket90DayUsefulPhrasesData.getDayPhrases(1);
      expect(day1.anchorWord, equals('How'));
      final phrasesEn = day1.phrases.map((p) => p.phraseEn).toList();
      expect(phrasesEn, contains('How many times'));
      expect(phrasesEn, contains('How often'));
      expect(phrasesEn, contains('How long'));
      expect(phrasesEn, contains('How far'));

      final howManyTimes = day1.phrases.firstWhere((p) => p.phraseEn == 'How many times');
      expect(howManyTimes.meaningMl, contains('എത്ര തവണ'));
    });

    test('Open world step positioning supports 21 steps including Step 6', () {
      final posStep6 = PocketDayOpenWorldAdventurePage.getStepPosition(6, totalSteps: 21);
      final posStep7 = PocketDayOpenWorldAdventurePage.getStepPosition(7, totalSteps: 21);
      final posStep21 = PocketDayOpenWorldAdventurePage.getStepPosition(21, totalSteps: 21);

      expect(posStep6.dx, lessThan(posStep7.dx));
      expect(posStep7.dx, lessThan(posStep21.dx));
    });
  });
}
