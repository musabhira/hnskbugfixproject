import 'package:pocket_mates_app/custom_code/services/pocket_language_service.dart';

/// 📚 Model for Daily 10 Vocabulary Words to Memorize (Multilingual Support)
class DailyVocabItem {
  final String word;
  final String partOfSpeech;
  final String definition;
  final String malayalamMeaning;
  final String tamilMeaning;
  final String hindiMeaning;
  final String teluguMeaning;
  final String kannadaMeaning;
  final String exampleSentence;
  final String phonetic;

  const DailyVocabItem({
    required this.word,
    required this.partOfSpeech,
    required this.definition,
    required this.malayalamMeaning,
    this.tamilMeaning = '',
    this.hindiMeaning = '',
    this.teluguMeaning = '',
    this.kannadaMeaning = '',
    required this.exampleSentence,
    required this.phonetic,
  });

  /// Convenience getters for backward compatibility
  String get definitionMl => malayalamMeaning;
  String get example => exampleSentence;

  Map<String, dynamic> toMap() => {
        'word': word,
        'partOfSpeech': partOfSpeech,
        'definition': definition,
        'malayalamMeaning': malayalamMeaning,
        'tamilMeaning': tamilMeaning,
        'hindiMeaning': hindiMeaning,
        'teluguMeaning': teluguMeaning,
        'kannadaMeaning': kannadaMeaning,
        'exampleSentence': exampleSentence,
        'phonetic': phonetic,
      };

  factory DailyVocabItem.fromMap(Map<String, dynamic> map) {
    return DailyVocabItem(
      word: map['word'] ?? '',
      partOfSpeech: map['partOfSpeech'] ?? '',
      definition: map['definition'] ?? '',
      malayalamMeaning: map['malayalamMeaning'] ?? '',
      tamilMeaning: map['tamilMeaning'] ?? '',
      hindiMeaning: map['hindiMeaning'] ?? '',
      teluguMeaning: map['teluguMeaning'] ?? '',
      kannadaMeaning: map['kannadaMeaning'] ?? '',
      exampleSentence: map['exampleSentence'] ?? '',
      phonetic: map['phonetic'] ?? '',
    );
  }

  String getMeaning(String language) {
    final lang = language.toLowerCase();
    if (lang.contains('hind') || lang == 'hi') {
      if (hindiMeaning.isNotEmpty) return hindiMeaning;
      final dict = PocketLanguageService.getWordTranslation(word, 'hindi');
      if (dict.isNotEmpty) return dict;
      return definition.isNotEmpty ? definition : word;
    }
    if (lang.contains('tamil') || lang == 'ta') {
      if (tamilMeaning.isNotEmpty) return tamilMeaning;
      final dict = PocketLanguageService.getWordTranslation(word, 'tamil');
      if (dict.isNotEmpty) return dict;
      return definition.isNotEmpty ? definition : word;
    }
    if (lang.contains('telug') || lang == 'te') {
      if (teluguMeaning.isNotEmpty) return teluguMeaning;
      final dict = PocketLanguageService.getWordTranslation(word, 'telugu');
      if (dict.isNotEmpty) return dict;
      return definition.isNotEmpty ? definition : word;
    }
    if (lang.contains('kannad') || lang == 'kn') {
      if (kannadaMeaning.isNotEmpty) return kannadaMeaning;
      final dict = PocketLanguageService.getWordTranslation(word, 'kannada');
      if (dict.isNotEmpty) return dict;
      return definition.isNotEmpty ? definition : word;
    }
    if (lang.contains('malay') || lang == 'ml') {
      if (malayalamMeaning.isNotEmpty) return malayalamMeaning;
      final dict = PocketLanguageService.getWordTranslation(word, 'malayalam');
      if (dict.isNotEmpty) return dict;
      return definition.isNotEmpty ? definition : word;
    }
    return definition.isNotEmpty ? definition : word;
  }
}
