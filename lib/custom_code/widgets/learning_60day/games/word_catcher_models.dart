import 'package:flutter/foundation.dart';

/// 🍎 Reusable Vocabulary Item for Word Catcher Games across Levels 1 to 90
class WordCatcherItem {
  final int id;
  final String word;
  final String emoji;
  final String category;
  final String phonetics;
  final String definition;
  final String exampleSentence;
  final Map<String, String> nativeTranslations;
  final String? audioPath;

  const WordCatcherItem({
    required this.id,
    required this.word,
    required this.emoji,
    required this.category,
    required this.phonetics,
    required this.definition,
    required this.exampleSentence,
    required this.nativeTranslations,
    this.audioPath,
  });

  String getNativeMeaning(String language) {
    return nativeTranslations[language] ??
        nativeTranslations['Malayalam'] ??
        definition;
  }
}

/// 🎮 Reusable Data-Driven Level Container for Word Catcher
class WordCatcherLevelData {
  final int levelNumber;
  final String title;
  final String subtitle;
  final String guideIntro;
  final List<WordCatcherItem> introExamples;
  final List<WordCatcherItem> targetWords;
  final int finalChallengeTargetStreak;
  final double baseFallSpeed;
  final String environmentTheme; // 'park', 'village', 'beach', 'mountain'

  const WordCatcherLevelData({
    required this.levelNumber,
    required this.title,
    required this.subtitle,
    required this.guideIntro,
    required this.introExamples,
    required this.targetWords,
    this.finalChallengeTargetStreak = 5,
    this.baseFallSpeed = 160.0,
    this.environmentTheme = 'park',
  });
}

/// 🌟 LEVEL 1 CURRICULUM: 10 Everyday Basic English Words
const kWordCatcherLevel1Data = WordCatcherLevelData(
  levelNumber: 1,
  title: 'Level 1 – Word Catcher',
  subtitle: 'Catch the correct English word!',
  guideIntro: "Let's learn some easy English words!",
  introExamples: [
    WordCatcherItem(
      id: 1,
      word: 'Apple',
      emoji: '🍎',
      category: 'Food',
      phonetics: '/ˈæp.əl/',
      definition: 'A crisp, sweet fruit grown on trees.',
      exampleSentence: 'I eat a sweet red apple every morning.',
      nativeTranslations: {
        'Malayalam': 'ആപ്പിൾ',
        'Tamil': 'ஆப்பிள்',
        'Hindi': 'सेब',
        'Telugu': 'యాపిల్',
        'English': 'Apple',
      },
    ),
    WordCatcherItem(
      id: 2,
      word: 'Ball',
      emoji: '⚽',
      category: 'Toys / Sports',
      phonetics: '/bɔːl/',
      definition: 'A round bouncy sphere used in sports and play.',
      exampleSentence: 'The children kick the soccer ball in the park.',
      nativeTranslations: {
        'Malayalam': 'പന്ത്',
        'Tamil': 'பந்து',
        'Hindi': 'गेंद',
        'Telugu': 'బంతి',
        'English': 'Ball',
      },
    ),
    WordCatcherItem(
      id: 3,
      word: 'Book',
      emoji: '📖',
      category: 'Daily / School',
      phonetics: '/bʊk/',
      definition: 'Pages bound together filled with knowledge and stories.',
      exampleSentence: 'She loves to read a good book before bed.',
      nativeTranslations: {
        'Malayalam': 'പുസ്തകം',
        'Tamil': 'புத்தகம்',
        'Hindi': 'किताब',
        'Telugu': 'పుస్తకం',
        'English': 'Book',
      },
    ),
  ],
  targetWords: [
    // 1. Apple
    WordCatcherItem(
      id: 1,
      word: 'Apple',
      emoji: '🍎',
      category: 'Food',
      phonetics: '/ˈæp.əl/',
      definition: 'A crisp, sweet fruit that is usually red, green, or yellow.',
      exampleSentence: 'An apple a day keeps the doctor away.',
      nativeTranslations: {
        'Malayalam': 'ആപ്പിൾ',
        'Tamil': 'ஆப்பிள்',
        'Hindi': 'सेब',
        'Telugu': 'యాపిల్',
        'English': 'Apple',
      },
    ),
    // 2. Ball
    WordCatcherItem(
      id: 2,
      word: 'Ball',
      emoji: '⚽',
      category: 'Toys / Sports',
      phonetics: '/bɔːl/',
      definition: 'A round object that bounces and rolls during games.',
      exampleSentence: 'Throw the ball to your teammate!',
      nativeTranslations: {
        'Malayalam': 'പന്ത്',
        'Tamil': 'பந்து',
        'Hindi': 'गेंद',
        'Telugu': 'బంతి',
        'English': 'Ball',
      },
    ),
    // 3. Book
    WordCatcherItem(
      id: 3,
      word: 'Book',
      emoji: '📖',
      category: 'Daily / School',
      phonetics: '/bʊk/',
      definition: 'A collection of written pages containing stories or wisdom.',
      exampleSentence: 'Open your English book to page one.',
      nativeTranslations: {
        'Malayalam': 'പുസ്തകം',
        'Tamil': 'புத்தகம்',
        'Hindi': 'किताब',
        'Telugu': 'పుస్తకం',
        'English': 'Book',
      },
    ),
    // 4. Cat
    WordCatcherItem(
      id: 4,
      word: 'Cat',
      emoji: '🐱',
      category: 'Animals',
      phonetics: '/kæt/',
      definition: 'A small, friendly domestic animal that purrs and meows.',
      exampleSentence: 'The fluffy cat sleeps quietly in the sun.',
      nativeTranslations: {
        'Malayalam': 'പൂച്ച',
        'Tamil': 'பூனை',
        'Hindi': 'बिल्ली',
        'Telugu': 'పిల్లి',
        'English': 'Cat',
      },
    ),
    // 5. Dog
    WordCatcherItem(
      id: 5,
      word: 'Dog',
      emoji: '🐶',
      category: 'Animals',
      phonetics: '/dɒɡ/',
      definition: 'A loyal, protective domestic animal known as man’s best friend.',
      exampleSentence: 'The happy dog wags its tail when greeting you.',
      nativeTranslations: {
        'Malayalam': 'നായ',
        'Tamil': 'நாய்',
        'Hindi': 'कुत्ता',
        'Telugu': 'కుక్క',
        'English': 'Dog',
      },
    ),
    // 6. Car
    WordCatcherItem(
      id: 6,
      word: 'Car',
      emoji: '🚗',
      category: 'Vehicles',
      phonetics: '/kɑːr/',
      definition: 'A four-wheeled road vehicle powered by an engine or motor.',
      exampleSentence: 'Dad drives a red electric car to work.',
      nativeTranslations: {
        'Malayalam': 'കാർ',
        'Tamil': 'கார் / மகிழுந்து',
        'Hindi': 'गाड़ी / कार',
        'Telugu': 'కారు',
        'English': 'Car',
      },
    ),
    // 7. House
    WordCatcherItem(
      id: 7,
      word: 'House',
      emoji: '🏠',
      category: 'Buildings',
      phonetics: '/haʊs/',
      definition: 'A warm, safe building built for people or families to live in.',
      exampleSentence: 'Our family lives in a cozy blue house.',
      nativeTranslations: {
        'Malayalam': 'വീട്',
        'Tamil': 'வீடு',
        'Hindi': 'घर',
        'Telugu': 'ఇల్లు',
        'English': 'House',
      },
    ),
    // 8. Sun
    WordCatcherItem(
      id: 8,
      word: 'Sun',
      emoji: '☀️',
      category: 'Nature',
      phonetics: '/sʌn/',
      definition: 'The bright glowing star in the sky that gives light and warmth.',
      exampleSentence: 'The morning sun shines brightly over the hills.',
      nativeTranslations: {
        'Malayalam': 'സൂര്യൻ',
        'Tamil': 'சூரியன்',
        'Hindi': 'सूरज',
        'Telugu': 'సూర్యుడు',
        'English': 'Sun',
      },
    ),
    // 9. Tree
    WordCatcherItem(
      id: 9,
      word: 'Tree',
      emoji: '🌳',
      category: 'Nature',
      phonetics: '/triː/',
      definition: 'A tall green perennial plant with a wooden trunk and leafy branches.',
      exampleSentence: 'Birds build their nests high up in the mango tree.',
      nativeTranslations: {
        'Malayalam': 'മരം',
        'Tamil': 'மரம்',
        'Hindi': 'पेड़',
        'Telugu': 'చెట్టు',
        'English': 'Tree',
      },
    ),
    // 10. Water
    WordCatcherItem(
      id: 10,
      word: 'Water',
      emoji: '💧',
      category: 'Nature / Daily',
      phonetics: '/ˈwɔː.tər/',
      definition: 'A clean, clear, essential liquid that all living things drink to survive.',
      exampleSentence: 'Drink eight glasses of fresh pure water every day.',
      nativeTranslations: {
        'Malayalam': 'വെള്ളം',
        'Tamil': 'தண்ணீர்',
        'Hindi': 'पानी',
        'Telugu': 'నీరు',
        'English': 'Water',
      },
    ),
  ],
);
