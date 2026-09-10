import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/pocket_world_vocabulary_bank.dart';

void main() {
  group('Pocket World Vocabulary Bank Tests', () {
    test('Vocab bank contains 30+ comprehensive words with all 5 languages', () {
      expect(kOpenWorldVocabBank.length, greaterThanOrEqualTo(30));

      for (final item in kOpenWorldVocabBank) {
        expect(item.word.isNotEmpty, isTrue, reason: 'Word must not be empty');
        expect(item.phonetics.isNotEmpty, isTrue, reason: 'Phonetics must not be empty for ${item.word}');
        expect(item.partOfSpeech.isNotEmpty, isTrue);
        expect(item.exampleEn.isNotEmpty, isTrue);

        // Check all 5 language translations
        expect(item.getMeaning('malayalam').isNotEmpty, isTrue, reason: 'Malayalam missing for ${item.word}');
        expect(item.getMeaning('tamil').isNotEmpty, isTrue, reason: 'Tamil missing for ${item.word}');
        expect(item.getMeaning('hindi').isNotEmpty, isTrue, reason: 'Hindi missing for ${item.word}');
        expect(item.getMeaning('telugu').isNotEmpty, isTrue, reason: 'Telugu missing for ${item.word}');
        expect(item.getMeaning('english').isNotEmpty, isTrue, reason: 'English missing for ${item.word}');
      }
    });

    test('Language flags and codes are properly resolved', () {
      expect(OpenWorldVocabItem.getLanguageFlag('malayalam'), equals('🌴'));
      expect(OpenWorldVocabItem.getLanguageFlag('tamil'), equals('🦚'));
      expect(OpenWorldVocabItem.getLanguageFlag('hindi'), equals('🇮🇳'));
      expect(OpenWorldVocabItem.getLanguageFlag('telugu'), equals('🌺'));
      expect(OpenWorldVocabItem.getLanguageFlag('english'), equals('🌐'));

      expect(OpenWorldVocabItem.getLanguageShortCode('malayalam'), equals('ML'));
      expect(OpenWorldVocabItem.getLanguageShortCode('tamil'), equals('TA'));
      expect(OpenWorldVocabItem.getLanguageShortCode('hindi'), equals('HI'));
      expect(OpenWorldVocabItem.getLanguageShortCode('telugu'), equals('TE'));
      expect(OpenWorldVocabItem.getLanguageShortCode('english'), equals('EN'));
    });
  });
}
