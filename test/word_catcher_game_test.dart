import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_mates_app/custom_code/widgets/learning_60day/games/word_catcher_models.dart';

void main() {
  group('Word Catcher Level 1 Curriculum Tests', () {
    test('Level 1 curriculum has exactly 10 everyday words', () {
      expect(kWordCatcherLevel1Data.targetWords.length, equals(10));
      expect(kWordCatcherLevel1Data.levelNumber, equals(1));
      expect(kWordCatcherLevel1Data.title, contains('Word Catcher'));
    });

    test('All 10 required words are present in correct order', () {
      final expectedWords = [
        'Apple',
        'Ball',
        'Book',
        'Cat',
        'Dog',
        'Car',
        'House',
        'Sun',
        'Tree',
        'Water',
      ];

      for (int i = 0; i < expectedWords.length; i++) {
        final item = kWordCatcherLevel1Data.targetWords[i];
        expect(item.word, equals(expectedWords[i]));
        expect(item.emoji.isNotEmpty, isTrue);
        expect(item.phonetics.startsWith('/'), isTrue);
        expect(item.definition.isNotEmpty, isTrue);
        expect(item.exampleSentence.isNotEmpty, isTrue);
        // Verify native translations
        expect(item.nativeTranslations.containsKey('Malayalam'), isTrue);
        expect(item.nativeTranslations.containsKey('Tamil'), isTrue);
        expect(item.nativeTranslations.containsKey('Hindi'), isTrue);
        expect(item.nativeTranslations.containsKey('Telugu'), isTrue);
      }
    });

    test('Intro examples contain Apple, Ball, Book', () {
      expect(kWordCatcherLevel1Data.introExamples.length, equals(3));
      final words = kWordCatcherLevel1Data.introExamples.map((e) => e.word).toList();
      expect(words, containsAll(['Apple', 'Ball', 'Book']));
    });

    test('Native language translation fallback works properly', () {
      final apple = kWordCatcherLevel1Data.targetWords[0];
      expect(apple.getNativeMeaning('Malayalam'), equals('ആപ്പിൾ'));
      expect(apple.getNativeMeaning('Tamil'), equals('ஆப்பிள்'));
      expect(apple.getNativeMeaning('Hindi'), equals('सेब'));
      expect(apple.getNativeMeaning('Telugu'), equals('యాపిల్'));
      // Fallback
      expect(apple.getNativeMeaning('UnknownLanguage'), equals('ആപ്പിൾ'));
    });
  });
}
