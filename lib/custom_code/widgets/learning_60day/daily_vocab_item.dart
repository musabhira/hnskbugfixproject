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
    switch (language.toLowerCase()) {
      case 'tamil':
        return tamilMeaning.isNotEmpty ? tamilMeaning : malayalamMeaning;
      case 'hindi':
        return hindiMeaning.isNotEmpty ? hindiMeaning : malayalamMeaning;
      case 'telugu':
        return teluguMeaning.isNotEmpty ? teluguMeaning : malayalamMeaning;
      case 'kannada':
        return kannadaMeaning.isNotEmpty ? kannadaMeaning : malayalamMeaning;
      case 'malayalam':
      default:
        return malayalamMeaning;
    }
  }
}
