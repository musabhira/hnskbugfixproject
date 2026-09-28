import 'daily_vocab_item.dart';

/// 🌟 Day-by-Day Middle / Intermediate Curriculum Item (Day 1 to 90)
class MiddleDayPlan {
  final int day;
  final String titleEn;
  final String titleMl;
  final String phaseName;
  final String flowTechnique;
  final String keyObjective;
  final List<DailyVocabItem> vocabularyItems;
  final List<String> nuancedPhrases;
  final String speechConnectorFormula;
  final String dailySpeakingTask;

  const MiddleDayPlan({
    required this.day,
    required this.titleEn,
    required this.titleMl,
    required this.phaseName,
    required this.flowTechnique,
    required this.keyObjective,
    this.vocabularyItems = const [],
    this.nuancedPhrases = const [],
    required this.speechConnectorFormula,
    required this.dailySpeakingTask,
  });
}

/// 🏛️ Middle Level (Intermediate) 1 to 90 Master Database
/// For learners who can converse in simple English, but want speed, rhythm,
/// rich sentence connectors, storytelling depth, and debate agility.
class MiddleCurriculumDB {
  static const Map<int, String> phaseTitles = {
    1: 'Phase 1: Complex Sentence Connectors & Natural Flow (Day 1 - 25)',
    26: 'Phase 2: Vivid Storytelling & Persuasive Opinions (Day 26 - 55)',
    56: 'Phase 3: Real-Time Debates & Coffee Table Leadership (Day 56 - 75)',
    76: 'Phase 4: Nuanced Native Idioms & International Wit (Day 76 - 90)',
  };

  /// Fetch Day Plan for Day 1 to 90
  static MiddleDayPlan getDayPlan(int day) {
    if (_cachedPlans.containsKey(day)) {
      return _cachedPlans[day]!;
    }
    return _generateFallbackDay(day);
  }

  static final Map<int, MiddleDayPlan> _cachedPlans = {
    // -------------------------------------------------------------------------
    // Day 1: Complex Sentence Connectors (Although / However / Furthermore)
    // -------------------------------------------------------------------------
    1: const MiddleDayPlan(
      day: 1,
      titleEn: 'Day 1: Complex Sentence Connectors (Although & In spite of)',
      titleMl: 'ദിവസം 1: വാചകങ്ങളെ കോർത്തെടുക്കുന്ന കണക്റ്ററുകൾ (Although / In spite of)',
      phaseName: 'Phase 1: Sentence Connectors (വാചകങ്ങൾ ഭംഗിയായി കൂട്ടിയോജിപ്പിക്കൽ)',
      flowTechnique: 'Upgrading from short robotic sentences to continuous compound thoughts.',
      keyObjective: 'Connect two contrasting ideas smoothly without hesitation.',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Although',
          partOfSpeech: 'conjunction',
          definition: 'In spite of the fact that; even though.',
          malayalamMeaning: 'എന്നിരുന്നാലും / അങ്ങനെയൊക്കെയാണെങ്കിലും',
          exampleSentence: 'Although it was raining heavily, we arrived on time.',
          phonetic: '/ɔːlˈðoʊ/',
        ),
        DailyVocabItem(
          word: 'Furthermore',
          partOfSpeech: 'adverb',
          definition: 'In addition to what will be or has been said.',
          malayalamMeaning: 'മാത്രവുമല്ല / ഇതിനുപുറമെ',
          exampleSentence: 'Furthermore, the proposal offers significant cost savings.',
          phonetic: '/ˌfɜːr.ðərˈmɔːr/',
        ),
        DailyVocabItem(
          word: 'Articulate',
          partOfSpeech: 'adjective / verb',
          definition: 'Having or showing the ability to speak fluently and coherently.',
          malayalamMeaning: 'വ്യക്തമായി സംസാരിക്കാൻ കഴിവുള്ള',
          exampleSentence: 'She is an extremely articulate speaker.',
          phonetic: '/ɑːrˈtɪk.jə.lət/',
        ),
      ],
      nuancedPhrases: [
        'Short: "I was tired. But I finished the work."',
        'Nuanced: "Although I was utterly exhausted, I managed to complete the task before sunset."',
      ],
      speechConnectorFormula:
          'Formula: "Although [Challenging Condition], [Successful Outcome] + Furthermore, [Added Value]"',
      dailySpeakingTask:
          '"Although..." ഉപയോഗിച്ച് നിങ്ങളുടെ അനുഭവത്തിൽ നിന്നുള്ള 2 വലിയ വാചകങ്ങൾ ഒഴുക്കോടെ പറയുക.',
    ),

    // -------------------------------------------------------------------------
    // Day 2: The Art of "Hypothetically Speaking" (Second Conditional)
    // -------------------------------------------------------------------------
    2: const MiddleDayPlan(
      day: 2,
      titleEn: 'Day 2: Hypothetical Scenarios ("If I were in your shoes...")',
      titleMl: 'ദിവസം 2: സാങ്കൽപ്പിക സാഹചര്യങ്ങൾ സംസാരിക്കൽ (Second Conditional)',
      phaseName: 'Phase 1: Sentence Connectors (വാചകങ്ങൾ ഭംഗിയായി കൂട്ടിയോജിപ്പിക്കൽ)',
      flowTechnique: 'Discussing dreams, advice, and imaginative scenarios with elegance.',
      keyObjective: 'Master "If I were..." and "I would definitely recommend..."',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Hypothetical',
          partOfSpeech: 'adjective',
          definition: 'Based on or serving as a hypothesis; imagined or theoretical.',
          malayalamMeaning: 'സാങ്കൽപ്പികമായ / അനുമാനപരമായ',
          exampleSentence: 'Let us consider a hypothetical situation.',
          phonetic: '/ˌhaɪ.pəˈθet̬.ɪ.kəl/',
        ),
        DailyVocabItem(
          word: 'Incline',
          partOfSpeech: 'verb',
          definition: 'Feel willing or favorably disposed toward.',
          malayalamMeaning: 'താൽപ്പര്യം തോന്നുക / ചായ്‌വ് കാണിക്കുക',
          exampleSentence: 'I am inclined to agree with your viewpoint.',
          phonetic: '/ɪnˈklaɪn/',
        ),
      ],
      nuancedPhrases: [
        'Basic: "If I am you, I will buy this."',
        'Nuanced: "If I were in your shoes, I would seriously reconsider that decision."',
      ],
      speechConnectorFormula:
          'Formula: "If I were [Position], I would [Action] because [Reason]"',
      dailySpeakingTask:
          'നിങ്ങൾ ഒരു സുഹൃത്തിന് ഉപദേശം നൽകുന്ന രീതിയിൽ 2 സാങ്കൽപ്പിക വാചകങ്ങൾ പറയുക.',
    ),

    // -------------------------------------------------------------------------
    // Day 3: Expressing Nuanced Doubts & Professional Hesitations
    // -------------------------------------------------------------------------
    3: const MiddleDayPlan(
      day: 3,
      titleEn: 'Day 3: Expressing Skepticism & Polite Reservation',
      titleMl: 'ദിവസം 3: സംശയങ്ങളും വിയോജിപ്പുകളും മാന്യമായി അവതരിപ്പിക്കൽ',
      phaseName: 'Phase 1: Sentence Connectors (വാചകങ്ങൾ ഭംഗിയായി കൂട്ടിയോജിപ്പിക്കൽ)',
      flowTechnique: 'Voice tone modulation to convey polite disagreement without offence.',
      keyObjective: 'Use "I have a few reservations regarding..." and "On the contrary..."',
      vocabularyItems: [
        DailyVocabItem(
          word: 'Reservation',
          partOfSpeech: 'noun',
          definition: 'A doubt or feeling of anxiety about something.',
          malayalamMeaning: 'സംശയം / മുൻകരുതലോടെയുള്ള വിമുഖത',
          exampleSentence: 'I have some reservations about this timeline.',
          phonetic: '/ˌrez.əˈveɪ.ʃən/',
        ),
        DailyVocabItem(
          word: 'Skeptical',
          partOfSpeech: 'adjective',
          definition: 'Not easily convinced; having doubts or reservations.',
          malayalamMeaning: 'സംശയദൃഷ്ടിയോടെ കാണുന്ന',
          exampleSentence: 'He remained skeptical about the sudden results.',
          phonetic: '/ˈskep.tɪ.kəl/',
        ),
      ],
      nuancedPhrases: [
        'Basic: "I don\'t like this plan. It is bad."',
        'Nuanced: "While I appreciate the intention, I have a few reservations regarding the proposed timeline."',
      ],
      speechConnectorFormula:
          'Formula: "While I understand [Point A], I have serious reservations about [Point B]"',
      dailySpeakingTask:
          'ഒരു മീറ്റിംഗിൽ മാന്യമായി സംശയം പ്രകടിപ്പിക്കുന്ന രീതിയിൽ 2 വാചകം റെക്കോർഡ് ചെയ്യുക.',
    ),
  };

  /// Fallback generator creating rich, practical lessons for Days 4 through 90
  static MiddleDayPlan _generateFallbackDay(int day) {
    if (day <= 25) {
      // Phase 1: Complex Connectors & Nuance
      final topics = [
        'Balancing Two Opposing Ideas ("On one hand... On the other hand")',
        'Providing Vivid Examples ("To illustrate this point...")',
        'Summarizing Arguments with Impact ("In a nutshell...")',
        'Expressing Cause & Deep Effect ("Consequently / As an inevitable result")',
        'Structuring Sequential Events ("Prior to that / Subsequently")',
        'Emphasizing Key Realities ("Undeniably / In all honesty")',
      ];
      final currentTopic = topics[(day - 4) % topics.length];
      return MiddleDayPlan(
        day: day,
        titleEn: 'Day $day: Sentence Agility - $currentTopic',
        titleMl: 'ദിവസം $day: വാചകങ്ങളുടെ ഒഴുക്ക് - $currentTopic',
        phaseName: 'Phase 1: Sentence Connectors (വാചകങ്ങൾ ഭംഗിയായി കൂട്ടിയോജിപ്പിക്കൽ)',
        flowTechnique: currentTopic,
        keyObjective: 'Incorporate transition phrases to sound polished and effortless',
        vocabularyItems: [
          DailyVocabItem(
            word: day == 4 ? 'Consequently' : (day == 5 ? 'Subsequent' : 'Undeniable'),
            partOfSpeech: 'adverb / adjective',
            definition: 'As a result; following in order of time.',
            malayalamMeaning: day == 4 ? 'തൽഫലമായി' : (day == 5 ? 'അതിനുശേഷമുള്ള' : 'തർക്കമില്ലാത്ത / വ്യക്തമായ'),
            exampleSentence: 'Consequently, the plan succeeded beyond expectations.',
            phonetic: '/ˈkɒn.sɪ.kwənt.li/',
          ),
        ],
        nuancedPhrases: [
          'Basic: "It rained. So the match stopped."',
          'Nuanced: "It poured unexpectedly; consequently, the organizers called off the match."',
        ],
        speechConnectorFormula: 'Formula: "[Situation] + consequently, [Direct Implication]"',
        dailySpeakingTask: 'ഈ കണക്റ്റർ ഉപയോഗിച്ച് നിങ്ങളുടെ നിത്യജീവിതത്തിലെ ഒരു സംഭവം പറയുക.',
      );
    } else if (day <= 55) {
      // Phase 2: Vivid Storytelling
      return MiddleDayPlan(
        day: day,
        titleEn: 'Day $day: Storytelling - Hook, Climax & Moral Reflection',
        titleMl: 'ദിവസം $day: കഥ പറച്ചിൽ - തുടക്കം, ക്ലൈമാക്സ്, ഗുണപാഠം',
        phaseName: 'Phase 2: Storytelling & Opinion (കഥ പറച്ചിലും സ്വന്തം അഭിപ്രായങ്ങളും)',
        flowTechnique: 'Structuring anecdotes into memorable, engaging verbal narratives.',
        keyObjective: 'Deliver an engaging 3-minute story with vivid descriptive adjectives',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Unprecedented',
            partOfSpeech: 'adjective',
            definition: 'Never done or known before.',
            malayalamMeaning: 'മുമ്പെങ്ങും ഉണ്ടാകാത്ത / അഭൂതപൂർവ്വമായ',
            exampleSentence: 'The storm brought unprecedented flooding.',
            phonetic: '/ʌnˈpres.ɪ.den.tɪd/',
          ),
        ],
        nuancedPhrases: [
          'Structure: "It all began when..." -> "Suddenly, out of nowhere..." -> "Looking back today..."',
        ],
        speechConnectorFormula: 'Formula: "What surprised me most was not [A], but rather [B]"',
        dailySpeakingTask: 'നിങ്ങളുടെ ജീവിതത്തിലെ ഒരു അപ്രതീക്ഷിത സംഭവം കഥയായി വിവരിക്കുക.',
      );
    } else if (day <= 75) {
      // Phase 3: Real-Time Debates & Coffee Table Leadership
      return MiddleDayPlan(
        day: day,
        titleEn: 'Day $day: Live Debate Tactics - Rebuttal & Counter-Arguments',
        titleMl: 'ദിവസം $day: തത്സമയ ചർച്ചകൾ - വാദങ്ങളും മറുവാദങ്ങളും തറപ്പിച്ചു പറയൽ',
        phaseName: 'Phase 3: Real-Time Debates (കോഫി ടേബിൾ ലൈവ് ഡിബേറ്റുകൾ)',
        flowTechnique: 'Acknowledging opposing views while reinforcing your core position.',
        keyObjective: 'Lead a 5-minute group discussion on social or technology topics',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Contention',
            partOfSpeech: 'noun',
            definition: 'An assertion, especially one maintained in argument.',
            malayalamMeaning: 'വാദം / തർക്ക വിഷയം',
            exampleSentence: 'My main contention is that AI will create new job roles.',
            phonetic: '/kənˈten.ʃən/',
          ),
        ],
        nuancedPhrases: [
          'Rebuttal: "I respect that perspective; however, the data paints an entirely different picture."',
        ],
        speechConnectorFormula: 'Formula: "I hear what you are saying; nonetheless, consider this..."',
        dailySpeakingTask: 'ഒരു തർക്ക വിഷയത്തിൽ നിങ്ങളുടെ ശക്തമായ 2 വാദങ്ങൾ റെക്കോർഡ് ചെയ്യുക.',
      );
    } else {
      // Phase 4: Nuanced Native Idioms & International Wit
      return MiddleDayPlan(
        day: day,
        titleEn: 'Day $day: Conversational Idioms & Spontaneous Wit',
        titleMl: 'ദിവസം $day: സംസാരത്തിലെ ഇംഗ്ലീഷ് ശൈലികളും (Idioms) സ്വാഭാവിക നർമ്മവും',
        phaseName: 'Phase 4: Idioms & Wit (നേറ്റീവ് ശൈലികളും സംസാര ചാരുതയും)',
        flowTechnique: 'Incorporating natural English idioms without sounding forced.',
        keyObjective: 'Speak effortlessly with natural idiomatic expressions and humor',
        vocabularyItems: [
          DailyVocabItem(
            word: 'Serendipity',
            partOfSpeech: 'noun',
            definition: 'The occurrence of events by chance in a happy or beneficial way.',
            malayalamMeaning: 'അപ്രതീക്ഷിതമായി കൈവരുന്ന ഭാഗ്യം',
            exampleSentence: 'Meeting my business partner was pure serendipity.',
            phonetic: '/ˌser.ənˈdɪp.ə.ti/',
          ),
        ],
        nuancedPhrases: [
          'Idiom: "Blessing in disguise" (തുടക്കത്തിൽ ദോഷമെന്ന് തോന്നിയ ഭാഗ്യം)',
          'Idiom: "Hit the nail on the head" (കൃത്യമായ കാര്യത്തിൽ തൊടുക)',
        ],
        speechConnectorFormula: 'Formula: "To cut a long story short, it turned out to be a blessing in disguise."',
        dailySpeakingTask: 'ഇന്ന് പഠിച്ച ഒരു ഇഡിയം ഉപയോഗിച്ച് രസകരമായ ഒരു സംഭവം പറയുക.',
      );
    }
  }
}
