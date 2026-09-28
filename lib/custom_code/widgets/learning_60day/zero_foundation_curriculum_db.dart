import 'daily_vocab_item.dart';
import 'pocket_mission_curriculum_1_18.dart';

/// 🌟 Day-by-Day Zero Foundation Curriculum Item (Day 1 to 90)
class ZeroFoundationDayPlan {
  final int day;
  final String titleEn;
  final String titleMl;
  final String phaseName;
  final String phaseDescription;
  final String keyObjective;
  final List<String> lettersToLearn;
  final List<AlphabetPhonicItem> phonicsDrills;
  final List<DailyVocabItem> vocabularyItems;
  final List<String> survivalPhrases;
  final String dailyVoiceMissionPrompt;

  const ZeroFoundationDayPlan({
    required this.day,
    required this.titleEn,
    required this.titleMl,
    required this.phaseName,
    required this.phaseDescription,
    required this.keyObjective,
    this.lettersToLearn = const [],
    this.phonicsDrills = const [],
    this.vocabularyItems = const [],
    this.survivalPhrases = const [],
    required this.dailyVoiceMissionPrompt,
  });
}

/// 🏛️ Zero Foundation Master Database (Day 1 to 90)
/// Specifically designed for absolute beginners (like elder father "ഉപ്പ" who doesn't know ABC)
/// Every day has a simple, bite-sized, audio-backed lesson.
class ZeroFoundationCurriculumDB {
  static const Map<int, String> phaseTitles = {
    1: 'Phase 1: Sounds & Letters Foundation (Day 1 - 15)',
    16: 'Phase 2: Everyday Object Sounds & 150 Words (Day 16 - 35)',
    36: 'Phase 3: 2-3 Word Survival Spoken Phrases (Day 36 - 60)',
    61: 'Phase 4: Friendly AI Voice Conversation & Confidence (Day 61 - 90)',
  };

  /// Fetch Day Plan for Day 1 to 90
  static ZeroFoundationDayPlan getDayPlan(int day) {
    if (_cachedPlans.containsKey(day)) {
      return _cachedPlans[day]!;
    }
    return _generateFallbackDay(day);
  }

  static final Map<int, ZeroFoundationDayPlan> _cachedPlans = {
    // -------------------------------------------------------------------------
    // Day 1: A, B & Welcome Greetings
    // -------------------------------------------------------------------------
    1: const ZeroFoundationDayPlan(
      day: 1,
      titleEn: 'Day 1: Letter A & B Sounds + "Hello" Greeting',
      titleMl: 'ദിവസം 1: A, B അക്ഷര ശബ്ദങ്ങളും "Hello" ആശംസയും',
      phaseName: 'Phase 1: Sounds & Letters (അക്ഷര ശബ്ദങ്ങൾ)',
      phaseDescription: 'അക്ഷരങ്ങൾ കണ്ട് ഭയപ്പെടാതെ, ശബ്ദം കേട്ട് ആവർത്തിക്കുക.',
      keyObjective: 'Learn to say /æ/ Apple, /b/ Book and "Hello / Hi"',
      lettersToLearn: ['A a', 'B b'],
      phonicsDrills: [
        AlphabetPhonicItem(
          letter: 'A a',
          phoneme: '/æ/',
          exampleWord: 'Apple (ആപ്പിൾ)',
          pronunciationGuide: 'വാ തുറന്ന് നാവ് താഴ്ത്തി: /æ/ ആപ്പിൾ',
          audioPrompt: 'A is for Apple, /æ/ Apple',
        ),
        AlphabetPhonicItem(
          letter: 'B b',
          phoneme: '/b/',
          exampleWord: 'Book (പുസ്തകം)',
          pronunciationGuide: 'രണ്ട് ചുണ്ടുകളും അമർത്തി പുറത്തേക്ക്: /b/ ബുക്ക്',
          audioPrompt: 'B is for Book, /b/ Book',
        ),
      ],
      vocabularyItems: [
        DailyVocabItem(
          word: 'Hello',
          partOfSpeech: 'greeting',
          definition: 'Used as a friendly greeting.',
          malayalamMeaning: 'നമസ്കാരം / ഹലോ',
          exampleSentence: 'Hello! How are you?',
          phonetic: '/həˈloʊ/',
        ),
        DailyVocabItem(
          word: 'Apple',
          partOfSpeech: 'noun',
          definition: 'A round fruit with red or green skin.',
          malayalamMeaning: 'ആപ്പിൾ പഴം',
          exampleSentence: 'This is an apple.',
          phonetic: '/ˈæp.əl/',
        ),
        DailyVocabItem(
          word: 'Book',
          partOfSpeech: 'noun',
          definition: 'Written or printed work bound together.',
          malayalamMeaning: 'പുസ്തകം',
          exampleSentence: 'This is my book.',
          phonetic: '/bʊk/',
        ),
      ],
      survivalPhrases: [
        'Hello! (ഹലോ!)',
        'Good Morning! (സുപ്രഭാതം!)',
        'Thank you! (നന്ദി!)',
      ],
      dailyVoiceMissionPrompt:
          'മൈക്ക് ഓൺ ചെയ്ത് "Hello" എന്നും "Apple" എന്നും തെറ്റാതെ പറയുക.',
    ),

    // -------------------------------------------------------------------------
    // Day 2: C, D & Everyday Needs (Water)
    // -------------------------------------------------------------------------
    2: const ZeroFoundationDayPlan(
      day: 2,
      titleEn: 'Day 2: Letter C & D Sounds + "Water"',
      titleMl: 'ദിവസം 2: C, D അക്ഷര ശബ്ദങ്ങളും "Water" (വെള്ളം) പദവും',
      phaseName: 'Phase 1: Sounds & Letters (അക്ഷര ശബ്ദങ്ങൾ)',
      phaseDescription: 'ശബ്ദങ്ങൾ ഉറപ്പിക്കുകയും വെള്ളം ചോദിക്കാൻ പഠിക്കുകയും ചെയ്യുക.',
      keyObjective: 'Master /k/ Cat, /d/ Door and "Give water"',
      lettersToLearn: ['C c', 'D d'],
      phonicsDrills: [
        AlphabetPhonicItem(
          letter: 'C c',
          phoneme: '/k/',
          exampleWord: 'Cat (പൂച്ച)',
          pronunciationGuide: 'തൊണ്ടയുടെ പിന്നിൽ നിന്ന്: /k/ ക്യാറ്റ്',
          audioPrompt: 'C is for Cat, /k/ Cat',
        ),
        AlphabetPhonicItem(
          letter: 'D d',
          phoneme: '/d/',
          exampleWord: 'Door (വാതിൽ)',
          pronunciationGuide: 'നാവിന്റെ തുമ്പ് പല്ലിന് പിന്നിൽ തട്ടി: /d/ ഡോർ',
          audioPrompt: 'D is for Door, /d/ Door',
        ),
      ],
      vocabularyItems: [
        DailyVocabItem(
          word: 'Water',
          partOfSpeech: 'noun',
          definition: 'Clear liquid essential for life.',
          malayalamMeaning: 'വെള്ളം',
          exampleSentence: 'Give me water, please.',
          phonetic: '/ˈwɔː.tər/',
        ),
        DailyVocabItem(
          word: 'Cat',
          partOfSpeech: 'noun',
          definition: 'A small domesticated animal.',
          malayalamMeaning: 'പൂച്ച',
          exampleSentence: 'The cat is sleeping.',
          phonetic: '/kæt/',
        ),
        DailyVocabItem(
          word: 'Door',
          partOfSpeech: 'noun',
          definition: 'A hinged or sliding barrier for entrance.',
          malayalamMeaning: 'വാതിൽ',
          exampleSentence: 'Open the door.',
          phonetic: '/dɔːr/',
        ),
      ],
      survivalPhrases: [
        'Water, please. (വെള്ളം തരൂ.)',
        'Open the door. (വാതിൽ തുറക്കൂ.)',
      ],
      dailyVoiceMissionPrompt:
          'മൈക്ക് അമർത്തി "Water, please" എന്ന് ഉച്ചാരണം കേട്ട് ആവർത്തിക്കുക.',
    ),

    // -------------------------------------------------------------------------
    // Day 3: E, F & Tea / Coffee
    // -------------------------------------------------------------------------
    3: const ZeroFoundationDayPlan(
      day: 3,
      titleEn: 'Day 3: Letter E & F Sounds + "Tea" & "Food"',
      titleMl: 'ദിവസം 3: E, F അക്ഷര ശബ്ദങ്ങളും "Tea", "Food" പദങ്ങളും',
      phaseName: 'Phase 1: Sounds & Letters (അക്ഷര ശബ്ദങ്ങൾ)',
      phaseDescription: 'ഭക്ഷണവും ചായയും ചോദിക്കാൻ പഠിക്കുക.',
      keyObjective: 'Master /e/ Egg, /f/ Fish and "I want tea"',
      lettersToLearn: ['E e', 'F f'],
      phonicsDrills: [
        AlphabetPhonicItem(
          letter: 'E e',
          phoneme: '/e/',
          exampleWord: 'Egg (മുട്ട)',
          pronunciationGuide: 'ചുണ്ട് അല്പം വിടർത്തി: /e/ എഗ്ഗ്',
          audioPrompt: 'E is for Egg, /e/ Egg',
        ),
        AlphabetPhonicItem(
          letter: 'F f',
          phoneme: '/f/',
          exampleWord: 'Food (ഭക്ഷണം)',
          pronunciationGuide: 'പല്ല് ചുണ്ടിൽ വെച്ച് കാറ്റൂതി: /f/ ഫുഡ്',
          audioPrompt: 'F is for Food, /f/ Food',
        ),
      ],
      vocabularyItems: [
        DailyVocabItem(
          word: 'Tea',
          partOfSpeech: 'noun',
          definition: 'A hot drink made by infusing tea leaves.',
          malayalamMeaning: 'ചായ',
          exampleSentence: 'I want tea.',
          phonetic: '/tiː/',
        ),
        DailyVocabItem(
          word: 'Food',
          partOfSpeech: 'noun',
          definition: 'Nutritious substance that people eat.',
          malayalamMeaning: 'ഭക്ഷണം / ചോറ്',
          exampleSentence: 'The food is ready.',
          phonetic: '/fuːd/',
        ),
      ],
      survivalPhrases: [
        'I want tea. (എനിക്ക് ചായ വേണം.)',
        'Food is good. (ഭക്ഷണം നല്ലതാണ്.)',
      ],
      dailyVoiceMissionPrompt: 'വോയ്‌സിൽ "I want tea" എന്ന് സന്തോഷത്തോടെ പറയുക.',
    ),
  };

  /// Fallback generator creating structured practical lessons for all days up to Day 90
  static ZeroFoundationDayPlan _generateFallbackDay(int day) {
    if (day <= 15) {
      // Phase 1: Sounds & Alphabet groups
      final char1 = String.fromCharCode(65 + ((day * 2 - 2) % 26));
      final char2 = String.fromCharCode(65 + ((day * 2 - 1) % 26));
      return ZeroFoundationDayPlan(
        day: day,
        titleEn: 'Day $day: Phonic Sounds $char1 & $char2 + Daily Object',
        titleMl: 'ദിവസം $day: $char1, $char2 ശബ്ദങ്ങളും നിത്യജീവിത വസ്തുക്കളും',
        phaseName: 'Phase 1: Sounds & Alphabet (അക്ഷര ശബ്ദങ്ങൾ)',
        phaseDescription:
            'എഴുതാതെ തന്നെ കേട്ടു പറയുന്ന ലളിതമായ 15 ദിവസത്തെ അടിത്തറ.',
        keyObjective: 'Master authentic pronunciation of $char1 and $char2 sounds',
        lettersToLearn: ['$char1 ${char1.toLowerCase()}', '$char2 ${char2.toLowerCase()}'],
        phonicsDrills: [
          AlphabetPhonicItem(
            letter: '$char1 ${char1.toLowerCase()}',
            phoneme: '/$char1/',
            exampleWord: '$char1 Sound',
            pronunciationGuide: 'വ്യക്തമായി ആവർത്തിച്ചു പറയുക: $char1',
            audioPrompt: '$char1 sound practice',
          ),
        ],
        vocabularyItems: [
          DailyVocabItem(
            word: day == 4 ? 'Good' : (day == 5 ? 'Morning' : 'House'),
            partOfSpeech: 'word',
            definition: 'Daily essential word.',
            malayalamMeaning: day == 4 ? 'നല്ലത്' : (day == 5 ? 'പ്രഭാതം' : 'വീട്'),
            exampleSentence: 'Very good!',
            phonetic: '/ɡʊd/',
          ),
        ],
        survivalPhrases: [
          'Yes (അതെ)',
          'No (അല്ല / വേണ്ട)',
          'OK (ശരി)',
        ],
        dailyVoiceMissionPrompt: 'ഈ അക്ഷരങ്ങളുടെ ശബ്ദം കേട്ട് 3 തവണ ആവർത്തിക്കുക.',
      );
    } else if (day <= 35) {
      // Phase 2: 150 Essential Objects
      return ZeroFoundationDayPlan(
        day: day,
        titleEn: 'Day $day: Daily Vocabulary & Picture Flashcards',
        titleMl: 'ദിവസം $day: നിത്യോപയോഗ വസ്തുക്കളുടെ പേരുകൾ (ചിത്രങ്ങൾ സഹിതം)',
        phaseName: 'Phase 2: 150 Essential Words (നിത്യോപയോഗ വാക്കുകൾ)',
        phaseDescription:
            'വീട്ടിലും കടകളിലും കാണുന്ന വസ്തുക്കളുടെ ഇംഗ്ലീഷ് വാക്കുകൾ മനപ്പാഠമാക്കുക.',
        keyObjective: 'Recognize and name 5 essential daily objects in English',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Money',
            partOfSpeech: 'noun',
            definition: 'Coins or banknotes used for trade.',
            malayalamMeaning: 'പണം / കാശ്',
            exampleSentence: 'How much money?',
            phonetic: '/ˈmʌn.i/',
          ),
          DailyVocabItem(
            word: 'Market',
            partOfSpeech: 'noun',
            definition: 'A place where goods are bought and sold.',
            malayalamMeaning: 'ചന്ത / അങ്ങാടി',
            exampleSentence: 'I go to market.',
            phonetic: '/ˈmɑːr.kɪt/',
          ),
        ],
        survivalPhrases: [
          'How much? (എത്ര രൂപയായി?)',
          'Give this. (ഇത് തരൂ.)',
        ],
        dailyVoiceMissionPrompt: 'ചിത്രം നോക്കി "Money", "Market" എന്ന് വോയ്സ് ചെയ്യുക.',
      );
    } else if (day <= 60) {
      // Phase 3: 2-3 Word Survival Phrases
      return ZeroFoundationDayPlan(
        day: day,
        titleEn: 'Day $day: 2-3 Word Survival Action Phrases',
        titleMl: 'ദിവസം $day: അത്യാവശ്യ കൊച്ചു വാചകങ്ങൾ (Survival Phrases)',
        phaseName: 'Phase 3: 2-3 Word Spoken Phrases (കൊച്ചു വാചകങ്ങൾ)',
        phaseDescription:
            'വലിയ വ്യാകരണ നിയമങ്ങളില്ലാതെ സംസാരിക്കാൻ ഉപയോഗിക്കുന്ന എളുപ്പ വാചകങ്ങൾ.',
        keyObjective: 'Express basic intentions and questions in 2-3 words',
        survivalPhrases: [
          'Where is it? (ഇതെവിടെയാണ്?)',
          'I am coming. (ഞാൻ വരുന്നു.)',
          'Please help. (ദയവായി സഹായിക്കൂ.)',
          'Call me. (എന്നെ വിളിക്കൂ.)',
        ],
        dailyVoiceMissionPrompt:
          'നിങ്ങൾ ഫോണിൽ "I am coming" എന്ന് പറയുന്നത് പോലെ ശബ്ദം റെക്കോർഡ് ചെയ്യുക.',
      );
    } else {
      // Phase 4: AI Voice Friend & Daily Speaking
      return ZeroFoundationDayPlan(
        day: day,
        titleEn: 'Day $day: Friendly Voice Bot Conversation',
        titleMl: 'ദിവസം $day: പോക്കറ്റ് റോബോട്ടുമൊത്തുള്ള രസകരമായ സംസാരം',
        phaseName: 'Phase 4: AI Voice Chat & Habit (ഭയമില്ലാതെ സംസാരിക്കൽ)',
        phaseDescription:
            'തെറ്റുകളെക്കുറിച്ച് ഓർത്തു ഭയപ്പെടാതെ മലയാളം കലർത്തി സംസാരിക്കുക.',
        keyObjective: 'Engage in a comfortable 3-minute voice conversation with AI bot',
        survivalPhrases: [
          'How are you today? (ഇന്ന് എങ്ങനെയുണ്ട്?)',
          'I am fine, thank you. (സുഖമാണ്, നന്ദി.)',
          'See you tomorrow! (നാളെ കാണാം!)',
        ],
        dailyVoiceMissionPrompt:
          'റോബോട്ടിനോട് സംസാരിച്ച് ഇന്നത്തെ വോയ്സ് ടാസ്ക് പൂർത്തിയാക്കുക.',
      );
    }
  }
}
