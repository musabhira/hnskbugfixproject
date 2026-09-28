import 'daily_vocab_item.dart';

/// 🌟 Day-by-Day Beginner Curriculum Item (Day 1 to 90)
class BeginnerDayPlan {
  final int day;
  final String titleEn;
  final String titleMl;
  final String phaseName;
  final String situationalContext;
  final String keyObjective;
  final List<DailyVocabItem> vocabularyItems;
  final List<String> situationalDialogues;
  final String spokenFormula;
  final String dailySpeakingTask;

  const BeginnerDayPlan({
    required this.day,
    required this.titleEn,
    required this.titleMl,
    required this.phaseName,
    required this.situationalContext,
    required this.keyObjective,
    this.vocabularyItems = const [],
    this.situationalDialogues = const [],
    required this.spokenFormula,
    required this.dailySpeakingTask,
  });
}

/// 🏛️ Beginner Level 1 to 90 Master Database
/// For learners who know basic words, but struggle with sentence framing, tenses, and daily conversation confidence.
class BeginnerCurriculumDB {
  static const Map<int, String> phaseTitles = {
    1: 'Phase 1: Real-Life Situational Dialogues (Day 1 - 20)',
    21: 'Phase 2: Natural Spoken Tenses Without Grammar Fear (Day 21 - 45)',
    46: 'Phase 3: Eliminating Literal Malayalam Translation Errors (Day 46 - 70)',
    71: 'Phase 4: Live Peer Dialogue & Daily Speaking Endurance (Day 71 - 90)',
  };

  /// Fetch Day Plan for Day 1 to 90
  static BeginnerDayPlan getDayPlan(int day) {
    if (_cachedPlans.containsKey(day)) {
      return _cachedPlans[day]!;
    }
    return _generateFallbackDay(day);
  }

  static final Map<int, BeginnerDayPlan> _cachedPlans = {
    // -------------------------------------------------------------------------
    // Day 1: Self Introduction & Breaking Hesitation
    // -------------------------------------------------------------------------
    1: const BeginnerDayPlan(
      day: 1,
      titleEn: 'Day 1: Confident Self-Introduction & Daily Greeting',
      titleMl: 'ദിവസം 1: ആത്മവിശ്വാസത്തോടെയുള്ള സ്വയം പരിചയപ്പെടുത്തൽ',
      phaseName: 'Phase 1: Real Situations (നിത്യജീവിത സംഭാഷണങ്ങൾ)',
      situationalContext: 'Introducing yourself to a stranger, coworker, or friend.',
      keyObjective: 'State your name, native place, and daily occupation smoothly.',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Introduce',
          partOfSpeech: 'verb',
          definition: 'Make someone known by name to another.',
          malayalamMeaning: 'പരിചയപ്പെടുത്തുക',
          exampleSentence: 'Let me introduce myself.',
          phonetic: '/ˌɪn.trəˈdjuːs/',
        ),
        DailyVocabItem(
          word: 'Native',
          partOfSpeech: 'noun / adjective',
          definition: 'A person born in a specified place or associated with it.',
          malayalamMeaning: 'സ്വദേശം / ജന്മദേശം',
          exampleSentence: 'My native place is Calicut.',
          phonetic: '/ˈneɪ.tɪv/',
        ),
        DailyVocabItem(
          word: 'Currently',
          partOfSpeech: 'adverb',
          definition: 'At the present time; now.',
          malayalamMeaning: 'ഇപ്പോൾ / നിലവിൽ',
          exampleSentence: 'I am currently working in Kochi.',
          phonetic: '/ˈkʌr.ənt.li/',
        ),
      ],
      situationalDialogues: [
        'A: "Hi, I am Rahul. Nice to meet you!"\nB: "Hello Rahul, I am Ameen. Nice to meet you too!"',
        'A: "Where are you from?"\nB: "I am from Kerala, but currently living in Bangalore."',
      ],
      spokenFormula: 'Formula: "I am [Name] + from [Place] + currently [Job/Status]"',
      dailySpeakingTask:
          'സ്വന്തം പേരും നാടും ജോലിയും ഉൾപ്പെടുത്തി 3 വാചകം തെറ്റാതെ റെക്കോർഡ് ചെയ്യുക.',
    ),

    // -------------------------------------------------------------------------
    // Day 2: Ordering Tea & Food at a Restaurant
    // -------------------------------------------------------------------------
    2: const BeginnerDayPlan(
      day: 2,
      titleEn: 'Day 2: Ordering at a Restaurant / Cafe',
      titleMl: 'ദിവസം 2: റെസ്റ്റോറന്റിലും ചായക്കടയിലും ഭക്ഷണം ഓർഡർ ചെയ്യൽ',
      phaseName: 'Phase 1: Real Situations (നിത്യജീവിത സംഭാഷണങ്ങൾ)',
      situationalContext: 'Placing food orders, asking for menu, and requesting bill.',
      keyObjective: 'Use "I would like to have..." and "Could I get the bill?"',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Order',
          partOfSpeech: 'verb / noun',
          definition: 'Request something to be made, supplied, or served.',
          malayalamMeaning: 'ഓർഡർ ചെയ്യുക / ആവശ്യപ്പെടുക',
          exampleSentence: 'Are you ready to order?',
          phonetic: '/ˈɔːr.dər/',
        ),
        DailyVocabItem(
          word: 'Bill',
          partOfSpeech: 'noun',
          definition: 'A printed statement of money owed for goods or services.',
          malayalamMeaning: 'ബില്ല് / നൽകേണ്ട തുകയുടെ കണക്ക്',
          exampleSentence: 'Could we get the bill, please?',
          phonetic: '/bɪl/',
        ),
        DailyVocabItem(
          word: 'Delicious',
          partOfSpeech: 'adjective',
          definition: 'Highly pleasant to the taste.',
          malayalamMeaning: 'രുചികരമായ',
          exampleSentence: 'The food was delicious.',
          phonetic: '/dɪˈlɪʃ.əs/',
        ),
      ],
      situationalDialogues: [
        'Customer: "Excuse me, could I see the menu, please?"\nWaiter: "Sure, here you go, sir."',
        'Customer: "I would like one black tea and a sandwich."\nWaiter: "Anything else, sir?"',
        'Customer: "No, that is all. Thank you!"',
      ],
      spokenFormula: 'Formula: "Could I get [Item], please?" / "I would like [Item]"',
      dailySpeakingTask:
          'റെസ്റ്റോറന്റിൽ ചായയോ ഭക്ഷണമോ ഓർഡർ ചെയ്യുന്ന രീതിയിൽ സംസാരിച്ചു പരിശീലിക്കുക.',
    ),

    // -------------------------------------------------------------------------
    // Day 3: Shopping & Asking Price at Supermarket
    // -------------------------------------------------------------------------
    3: const BeginnerDayPlan(
      day: 3,
      titleEn: 'Day 3: Supermarket Shopping & Bargaining Prices',
      titleMl: 'ദിവസം 3: സൂപ്പർമാർക്കറ്റിൽ സാധനങ്ങൾ വാങ്ങലും വില ചോദിക്കലും',
      phaseName: 'Phase 1: Real Situations (നിത്യജീവിത സംഭാഷണങ്ങൾ)',
      situationalContext: 'Asking where an item is kept and checking discounts/prices.',
      keyObjective: 'Master "Where can I find...?" and "How much does this cost?"',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Aisle',
          partOfSpeech: 'noun',
          definition: 'A passage between shelves of goods in a supermarket.',
          malayalamMeaning: 'വരികൾക്കിടയിലെ വഴി (ഷെൽഫുകളുടെ ഇട)',
          exampleSentence: 'Rice is in aisle 3.',
          phonetic: '/aɪl/',
        ),
        DailyVocabItem(
          word: 'Discount',
          partOfSpeech: 'noun',
          definition: 'A deduction from the usual cost of something.',
          malayalamMeaning: 'വിലക്കിഴിവ്',
          exampleSentence: 'Is there any discount on this?',
          phonetic: '/ˈdɪs.kaʊnt/',
        ),
        DailyVocabItem(
          word: 'Receipt',
          partOfSpeech: 'noun',
          definition: 'A written acknowledgement that goods have been paid for.',
          malayalamMeaning: 'രസീത് / കാശ് നൽകിയ രേഖ',
          exampleSentence: 'Here is your receipt.',
          phonetic: '/rɪˈsiːt/',
        ),
      ],
      situationalDialogues: [
        'Customer: "Excuse me, where can I find olive oil?"\nStaff: "It is on shelf number 4 on your right."',
        'Customer: "How much does this packet cost?"\nStaff: "That is 150 rupees, sir."',
      ],
      spokenFormula: 'Formula: "Where can I find [Item]?" / "How much is this [Item]?"',
      dailySpeakingTask:
          'കടക്കാരനോട് ഒരു സാധനത്തിന്റെ വില ചോദിക്കുന്ന 2 വാചകം വ്യക്തമായി പറയുക.',
    ),
  };

  /// Fallback generator creating rich, practical lessons for Days 4 through 90
  static BeginnerDayPlan _generateFallbackDay(int day) {
    if (day <= 20) {
      // Phase 1: Real Situations
      final situations = [
        'Doctor Appointment & Symptoms (ഡോക്ടറോട് അസുഖം പറയൽ)',
        'Booking a Cab & Giving Directions (ടാക്സി വിളിക്കലും വഴി പറയലും)',
        'Asking Directions on Street (വഴി ചോദിക്കൽ)',
        'Bank & ATM Transactions (ബാങ്കിലെ ഇടപാടുകൾ)',
        'Airport & Train Station Travel (യാത്രാ സംഭാഷണങ്ങൾ)',
        'Hotel Room Booking & Check-in (ഹോട്ടൽ ബുക്കിംഗ്)',
        'Phone Calling & Message Leaving (ഫോൺ വിളികൾ)',
      ];
      final currentSit = situations[(day - 4) % situations.length];
      return BeginnerDayPlan(
        day: day,
        titleEn: 'Day $day: Real Scenario - $currentSit',
        titleMl: 'ദിവസം $day: യഥാർത്ഥ സാഹചര്യ സംഭാഷണം - $currentSit',
        phaseName: 'Phase 1: Real Situations (നിത്യജീവിത സംഭാഷണങ്ങൾ)',
        situationalContext: currentSit,
        keyObjective: 'Master natural conversational dialogue without fear',
        vocabularyItems: [
          DailyVocabItem(
            word: day == 4 ? 'Appointment' : (day == 5 ? 'Destination' : 'Assistance'),
            partOfSpeech: 'noun',
            definition: 'An arrangement to meet someone at a particular time.',
            malayalamMeaning: day == 4 ? 'മുൻകൂട്ടി നിശ്ചയിച്ച സമയം' : (day == 5 ? 'എത്തിച്ചേരേണ്ട സ്ഥലം' : 'സഹായം'),
            exampleSentence: 'I have an appointment at 5 PM.',
            phonetic: '/əˈpɔɪnt.mənt/',
          ),
        ],
        situationalDialogues: [
          'A: "Could you please help me with this?"\nB: "Certainly! What can I do for you?"',
        ],
        spokenFormula: 'Formula: "Could you please [Action]?" / "I need [Need]"',
        dailySpeakingTask: 'ഈ സാഹചര്യത്തിൽ പറയേണ്ട 2 വാചകം വോയ്സിൽ റെക്കോർഡ് ചെയ്യുക.',
      );
    } else if (day <= 45) {
      // Phase 2: Natural Spoken Tenses
      return BeginnerDayPlan(
        day: day,
        titleEn: 'Day $day: Spoken Tenses in Action (Did / Will / Have)',
        titleMl: 'ദിവസം $day: ടെൻസുകൾ പേടിയില്ലാതെ സംസാരിച്ചു പഠിക്കൽ',
        phaseName: 'Phase 2: Spoken Tenses (ടെൻസുകൾ സംസാരിച്ചു പഠിക്കൽ)',
        situationalContext: 'Describing past events, current habits, and tomorrow plans.',
        keyObjective: 'Shift effortlessly between Yesterday, Today, and Tomorrow',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Completed',
            partOfSpeech: 'verb (past)',
            definition: 'Finished making or doing something.',
            malayalamMeaning: 'പൂർത്തിയാക്കി (കഴിഞ്ഞ കാര്യം)',
            exampleSentence: 'I completed my work yesterday.',
            phonetic: '/kəmˈpliː.tɪd/',
          ),
        ],
        situationalDialogues: [
          'Yesterday: "I went to the office by bus."\nToday: "I am working on the project."\nTomorrow: "I will call you in the morning."',
        ],
        spokenFormula: 'Formula: "Yesterday I [V2] ... Tomorrow I will [V1]"',
        dailySpeakingTask:
          'നിങ്ങൾ ഇന്നലെ ചെയ്ത ഒരു കാര്യവും നാളെ ചെയ്യാൻ പോകുന്ന ഒരു കാര്യവും ഇംഗ്ലീഷിൽ പറയുക.',
      );
    } else if (day <= 70) {
      // Phase 3: Eliminating Malayalam Translation Traps
      return BeginnerDayPlan(
        day: day,
        titleEn: 'Day $day: Stop Translating Word-by-Word from Malayalam',
        titleMl: 'ദിവസം $day: മലയാളത്തിൽ നിന്ന് വാക്ക്-വാക്കായി വിവർത്തനം ചെയ്യുന്നത് ഒഴിവാക്കൽ',
        phaseName: 'Phase 3: Error Elimination (സാധാരണ തെറ്റുകൾ ഒഴിവാക്കൽ)',
        situationalContext: 'Fixing literal translations (e.g. "Myself Rahul" -> "I am Rahul").',
        keyObjective: 'Adopt natural native English phrasing without mental translation delay',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Prefer',
            partOfSpeech: 'verb',
            definition: 'Like one thing better than another.',
            malayalamMeaning: 'കൂടുതൽ ഇഷ്ടപ്പെടുക / മുൻഗണന നൽകുക',
            exampleSentence: 'I prefer tea over coffee.',
            phonetic: '/prɪˈfɜːr/',
          ),
        ],
        situationalDialogues: [
          '❌ Wrong: "What is your good name?"\n✅ Correct: "May I know your name, please?"',
          '❌ Wrong: "I am having two brothers."\n✅ Correct: "I have two brothers."',
        ],
        spokenFormula: 'Formula: Think in direct English chunks rather than translation.',
        dailySpeakingTask: 'ശരിയായ വാചകം 3 തവണ ഉച്ചത്തിൽ പറഞ്ഞു ശീലിക്കുക.',
      );
    } else {
      // Phase 4: Live Peer Endurance & Spontaneous Speech
      return BeginnerDayPlan(
        day: day,
        titleEn: 'Day $day: Spontaneous 2-Minute Speech & Live Calling',
        titleMl: 'ദിവസം $day: 2 മിനിറ്റ് തുടർച്ചയായി സംസാരിക്കലും ലൈവ് കോളുകളും',
        phaseName: 'Phase 4: Live Speech Endurance (ലൈവ് സംസാരവും ആത്മവിശ്വാസവും)',
        situationalContext: 'Holding 5-10 minute voice calls with peers and audio rooms.',
        keyObjective: 'Overcome fear and speak continuously for 2 minutes on daily topics',
        situationalDialogues: [
          'Caller: "Hello, could we practice speaking English for 5 minutes?"\nPeer: "Yes, absolutely! What topic would you like to discuss?"',
        ],
        spokenFormula: 'Formula: "In my opinion, ... because ... for example ..."',
        dailySpeakingTask:
          'നൽകിയ വിഷയത്തിൽ 2 മിനിറ്റ് തടസ്സമില്ലാതെ സംസാരിച്ചു ഓഡിയോ സമർപ്പിക്കുക.',
      );
    }
  }
}
