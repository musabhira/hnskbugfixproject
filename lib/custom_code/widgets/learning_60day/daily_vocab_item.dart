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
  String get localizedMeaning => getMeaning(PocketLanguageService.currentLanguage);

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

  String getMeaning([String? language]) {
    final lang = (language ?? PocketLanguageService.currentLanguage).toLowerCase().trim();
    if (lang.contains('malay') || lang == 'ml') {
      if (malayalamMeaning.isNotEmpty) return malayalamMeaning;
    } else if (lang.contains('hind') || lang == 'hi') {
      if (hindiMeaning.isNotEmpty) return hindiMeaning;
      final dictMeaning = PocketLanguageService.getVocabMeaning(word);
      if (dictMeaning.isNotEmpty && dictMeaning != word) return dictMeaning;
    } else if (lang.contains('tamil') || lang == 'ta') {
      if (tamilMeaning.isNotEmpty) return tamilMeaning;
      final dictMeaning = PocketLanguageService.getVocabMeaning(word);
      if (dictMeaning.isNotEmpty && dictMeaning != word) return dictMeaning;
    } else if (lang.contains('telug') || lang == 'te') {
      if (teluguMeaning.isNotEmpty) return teluguMeaning;
    } else if (lang.contains('kannad') || lang == 'kn') {
      if (kannadaMeaning.isNotEmpty) return kannadaMeaning;
    }

    if (PocketLanguageService.isMalayalam) {
      if (malayalamMeaning.isNotEmpty) return malayalamMeaning;
    }
    if (PocketLanguageService.isHindi) {
      if (hindiMeaning.isNotEmpty) return hindiMeaning;
      final dictMeaning = PocketLanguageService.getVocabMeaning(word);
      if (dictMeaning.isNotEmpty && dictMeaning != word) return dictMeaning;
    }
    if (PocketLanguageService.isTamil) {
      if (tamilMeaning.isNotEmpty) return tamilMeaning;
      final dictMeaning = PocketLanguageService.getVocabMeaning(word);
      if (dictMeaning.isNotEmpty && dictMeaning != word) return dictMeaning;
    }
    if (PocketLanguageService.isTelugu && teluguMeaning.isNotEmpty) {
      return teluguMeaning;
    }
    if (PocketLanguageService.isKannada && kannadaMeaning.isNotEmpty) {
      return kannadaMeaning;
    }

    if (PocketLanguageService.isMalayalam && malayalamMeaning.isNotEmpty) {
      return malayalamMeaning;
    }

    return definition.isNotEmpty ? definition : word;
  }
}
