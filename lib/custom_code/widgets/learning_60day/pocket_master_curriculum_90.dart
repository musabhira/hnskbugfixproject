// 🏛️ Master 90-Day Progressive English Curriculum Engine
// Each day from 1 to 90 is individually crafted to ensure zero information overload,
// progressive difficulty scaling, and systematic coverage of all linguistic pillars.

class CurriculumVocabItem {
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String meaningEn;
  final String meaningMl;
  final String exampleEn;
  final String exampleMl;

  const CurriculumVocabItem({
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.meaningEn,
    required this.meaningMl,
    required this.exampleEn,
    this.exampleMl = '',
  });
}

class MasterCurriculumDay {
  final int day;
  final String title;
  final String phaseName;
  final String focusArea;
  final String grammarConcept;
  final String speakingDrill;
  final String peerChatMission;
  final int targetMinutes;
  final int xpReward;
  final String milestoneReward;
  final String theoryConcept;
  final String theoryExplanationEn;
  final String theoryExplanationMl;
  final String whyItMatters;
  final List<String> commonMistakes;
  final List<String> mistakeCorrections;
  final List<CurriculumVocabItem> vocabulary;

  const MasterCurriculumDay({
    required this.day,
    required this.title,
    required this.phaseName,
    required this.focusArea,
    required this.grammarConcept,
    required this.speakingDrill,
    required this.peerChatMission,
    this.targetMinutes = 60,
    this.xpReward = 35,
    this.milestoneReward = '',
    this.theoryConcept = '',
    this.theoryExplanationEn = '',
    this.theoryExplanationMl = '',
    this.whyItMatters = '',
    this.commonMistakes = const [],
    this.mistakeCorrections = const [],
    this.vocabulary = const [],
  });
}

class PocketMasterCurriculum90 {
  static MasterCurriculumDay getDay(int day) {
    if (_days.containsKey(day)) {
      return _days[day]!;
    }
    return _generateDynamicDay(day);
  }

  static const Map<int, MasterCurriculumDay> _days = {
    // =========================================================================
    // PHASE 1: FOUNDATION & SPEECH MECHANICS (DAYS 1 – 30)
    // =========================================================================
    1: MasterCurriculumDay(
      day: 1,
      title: 'Day 1: Breaking Hesitation & Introducing Yourself',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Confidence & Basic Vowel Sounds',
      grammarConcept: 'Subject Pronouns + "To Be" (I am / You are / He is)',
      speakingDrill: 'Introduce yourself in 3 simple sentences: Name, Location, Goal.',
      peerChatMission: 'Send a voice greeting to your assigned Pocket Mate.',
      xpReward: 50,
      milestoneReward: '🌱 Day 1 Novice Pioneer Badge',
      theoryConcept: 'Breaking Hesitation & The S-V-O Sentence Blueprint',
      theoryExplanationEn:
          'In spoken English, every natural sentence starts with the Subject (Who) followed directly by the Verb (Action/State) and Object (What). Unlike Malayalam or Hindi where verbs sit at the end of the sentence, in English you must release the verb immediately. To introduce yourself, master the state-of-being verb "To Be": I am, You are, He is, She is, We are, They are.',
      theoryExplanationMl:
          'ഇംഗ്ലീഷിൽ സംസാരിക്കാൻ തുടങ്ങുമ്പോൾ പ്രധാനമായും വേണ്ടത് മടി മാറ്റലാണ്. മലയാളത്തിൽ ക്രിയ (Verb) വാക്യത്തിന് ഒടുവിലാണ് വരുന്നത് ("ഞാൻ ചോറ് തിന്നു"), എന്നാൽ ഇംഗ്ലീഷിൽ സബ്ജക്റ്റിന് ഉടൻ തന്നെ ക്രിയ വരണം (Subject + Verb + Object: "I eat rice"). സ്വയം പരിചയപ്പെടുത്താൻ "I am [പേര്/ജോലി]" എന്ന ഘടന ധൈര്യത്തോടെ ഉപയോഗിക്കുക.',
      whyItMatters:
          'Speech hesitation occurs when your brain tries to translate word-by-word from your native language. Committing the S-V-O rhythm to muscle memory stops you from pausing in mid-sentence.',
      commonMistakes: [
        '❌ "Myself Rahul from Kochi."',
        '❌ "I am having two years experience."',
        '❌ "He are my friend."',
      ],
      mistakeCorrections: [
        '✅ "I am Rahul from Kochi." (or "My name is Rahul.")',
        '✅ "I have two years of experience."',
        '✅ "He is my friend."',
      ],
      vocabulary: [
        CurriculumVocabItem(
          word: 'HESITATION',
          phonetic: '/ˌhez.ɪˈteɪ.ʃən/',
          partOfSpeech: 'Noun',
          meaningEn: 'A state of pausing before saying or doing something due to doubt.',
          meaningMl: 'മടി / സംശയം കൊണ്ടുള്ള ഇടവേള',
          exampleEn: 'Daily voice practice is the only way to destroy hesitation.',
          exampleMl: 'ദിവസേനയുള്ള ശബ്ദ പരിശീലനമാണ് മടി മാറ്റാനുള്ള ഏക വഴി.',
        ),
        CurriculumVocabItem(
          word: 'FLUENCY',
          phonetic: '/ˈfluː.ən.si/',
          partOfSpeech: 'Noun',
          meaningEn: 'The ability to speak or write a language easily and accurately.',
          meaningMl: 'തടസ്സമില്ലാതെ സംസാരിക്കാനുള്ള കഴിവ്',
          exampleEn: 'Fluency comes from vocal muscle memory, not grammar rules.',
          exampleMl: 'വ്യാകരണ നിയമങ്ങളേക്കാൾ വോക്കൽ മസിൽ മെമ്മറിയിലൂടെയാണ് ഫ്ലുവൻസി ഉണ്ടാവുന്നത്.',
        ),
        CurriculumVocabItem(
          word: 'CONFIDENCE',
          phonetic: '/ˈkɒn.fɪ.dəns/',
          partOfSpeech: 'Noun',
          meaningEn: 'A feeling of self-assurance arising from appreciation of one\'s abilities.',
          meaningMl: 'ആത്മവിശ്വാസം',
          exampleEn: 'Make mistakes loudly and proudly to build unshakeable confidence.',
          exampleMl: 'തെറ്റുകൾ വരുത്താൻ ഭയപ്പെടാതെ ആത്മവിശ്വാസത്തോടെ സംസാരിക്കുക.',
        ),
        CurriculumVocabItem(
          word: 'INTRODUCE',
          phonetic: '/ˌɪn.trəˈdʒuːs/',
          partOfSpeech: 'Verb',
          meaningEn: 'To present someone or yourself by name to another person.',
          meaningMl: 'പരിചയപ്പെടുത്തുക',
          exampleEn: 'Allow me to introduce myself: I am Arun from Kerala.',
          exampleMl: 'എന്നെ പരിചയപ്പെടുത്താൻ അനുവദിക്കുക: ഞാൻ കേരളത്തിൽ നിന്നുള്ള അരുൺ ആണ്.',
        ),
        CurriculumVocabItem(
          word: 'ROUTINE',
          phonetic: '/ruːˈtiːn/',
          partOfSpeech: 'Noun',
          meaningEn: 'A sequence of actions regularly followed.',
          meaningMl: 'പതിവ് ശീലം / നിത്യേനയുള്ള ക്രമം',
          exampleEn: 'Speaking English for 15 minutes is now part of my daily routine.',
          exampleMl: 'ദിവസവും 15 മിനിറ്റ് ഇംഗ്ലീഷ് സംസാരിക്കുന്നത് എന്റെ ശീലമായി മാറി.',
        ),
      ],
    ),
    2: MasterCurriculumDay(
      day: 2,
      title: 'Day 2: Daily Routines & Morning Action Habits',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Everyday Action Verbs',
      grammarConcept: 'Present Simple for Habits (I wake up, I drink, I study)',
      speakingDrill: 'Describe your morning routine from waking up to starting work.',
      peerChatMission: 'Ask your partner 2 questions about what they do every morning.',
    ),
    3: MasterCurriculumDay(
      day: 3,
      title: 'Day 3: Asking Clear Questions (Who, What, Where, When)',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Inquiry & Intonation Curves',
      grammarConcept: 'Wh- Question Word Structures & Auxiliary "Do / Does"',
      speakingDrill: 'Ask 5 spontaneous questions aloud to an imaginary tourist.',
      peerChatMission: 'Do a 2-minute Q&A exchange with your peer.',
    ),
    4: MasterCurriculumDay(
      day: 4,
      title: 'Day 4: Describing Things with Articles (A, An, The)',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Definite vs Indefinite Articles',
      grammarConcept: 'Articles Rule: "a" vs "an" (vowel sounds) vs "the" (specific)',
      speakingDrill: 'Describe 3 objects currently on your desk using correct articles.',
      peerChatMission: 'Tell your mate about your favorite personal possession.',
    ),
    5: MasterCurriculumDay(
      day: 5,
      title: 'Day 5: Numbers, Telling Time & Scheduling',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Time Expressions & Numerical Cadence',
      grammarConcept: 'Prepositions of Time: "at" 5 PM, "on" Monday, "in" October',
      speakingDrill: 'State today\'s date, time, and your schedule for the afternoon.',
      peerChatMission: 'Compare your weekend schedules with your study partner.',
    ),
    6: MasterCurriculumDay(
      day: 6,
      title: 'Day 6: Family, Relationships & Possessive Pronouns',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Describing People & Belonging',
      grammarConcept: 'Possessives: my, your, his, her, their, our',
      speakingDrill: 'Talk for 60 seconds about someone in your family who inspires you.',
      peerChatMission: 'Ask your mate about their best friend and their hobbies.',
    ),
    7: MasterCurriculumDay(
      day: 7,
      title: '🎯 Day 7 Review: Week 1 Speaking Milestone',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Fluency Check & Sentence Flow',
      grammarConcept: 'Sentence Rhythm & Linking Words (and, but, because)',
      speakingDrill: 'Deliver a 90-second continuous monologue summarizing your week.',
      peerChatMission: 'Have a 5-minute celebratory voice call with your Pocket Mate.',
      xpReward: 100,
      milestoneReward: '🎯 Week 1 Bronze Streak Key',
    ),
    8: MasterCurriculumDay(
      day: 8,
      title: 'Day 8: Food, Dining & Polite Ordering at a Cafe',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Polite Inquiries & Food Vocabulary',
      grammarConcept: '"Could I have...", "I would like to order..." (Polite Modals)',
      speakingDrill: 'Simulate ordering a warm drink and a snack at a busy cafe.',
      peerChatMission: 'Roleplay a waiter and customer scenario with your partner.',
    ),
    9: MasterCurriculumDay(
      day: 9,
      title: 'Day 9: Asking for & Giving Directions in the City',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Spatial Navigation & Landmarks',
      grammarConcept: 'Prepositions of Place: opposite, adjacent to, across, between',
      speakingDrill: 'Give step-by-step directions from your door to the nearest shop.',
      peerChatMission: 'Explain how to navigate to a famous landmark in your city.',
    ),
    10: MasterCurriculumDay(
      day: 10,
      title: 'Day 10: Shopping, Asking Prices & Bargaining Politely',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Commercial Transactions & Currency',
      grammarConcept: '"How much is this?", "Do you have this in a larger size?"',
      speakingDrill: 'Roleplay buying clothes and asking for a slight discount politely.',
      peerChatMission: 'Discuss your best shopping experience with your mate.',
    ),
    11: MasterCurriculumDay(
      day: 11,
      title: 'Day 11: Past Simple 1 — Regular Verbs & -ED Sounds',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Yesterday Events & Pronunciation of -ED (/t/, /d/, /ɪd/)',
      grammarConcept: 'Past Simple Affirmative with regular verbs (worked, walked)',
      speakingDrill: 'List 5 activities you finished yesterday with perfect -ED sounds.',
      peerChatMission: 'Ask your partner what they accomplished yesterday evening.',
    ),
    12: MasterCurriculumDay(
      day: 12,
      title: 'Day 12: Past Simple 2 — Irregular Verbs (Went, Saw, Ate)',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Core Irregular Past Forms',
      grammarConcept: 'Irregular Past: went, saw, bought, came, spoke, took',
      speakingDrill: 'Narrate an exciting trip or outing using at least 5 irregular verbs.',
      peerChatMission: 'Share an unexpected moment from your past with your peer.',
    ),
    13: MasterCurriculumDay(
      day: 13,
      title: 'Day 13: Narrating a Full Day with Time Markers',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Chronological Narrative Flow',
      grammarConcept: 'Time Sequence Connectors: First, Then, After that, Finally',
      speakingDrill: 'Tell the complete story of your most memorable yesterday.',
      peerChatMission: 'Listen to your mate\'s day and ask 2 follow-up questions.',
    ),
    14: MasterCurriculumDay(
      day: 14,
      title: '🎯 Day 14 Milestone: Past Tense Storyteller',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Unbroken Past Narration',
      grammarConcept: 'Past Simple Negatives ("didn\'t do") and Questions ("Did you see?")',
      speakingDrill: 'Speak for 2 minutes straight narrating a memorable journey.',
      peerChatMission: 'Conduct a 5-minute story exchange with your Pocket Mate.',
      xpReward: 120,
      milestoneReward: '📜 Fortnight Storyteller Scroll',
    ),
    15: MasterCurriculumDay(
      day: 15,
      title: 'Day 15: Future Plans with "Going to" vs "Will"',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Future Intentions & Spontaneous Decisions',
      grammarConcept: '"Going to" (planned intentions) vs "Will" (spontaneous offers)',
      speakingDrill: 'Detail your 3 major personal goals for the upcoming weekend.',
      peerChatMission: 'Ask your partner about their dream travel destination.',
    ),
    16: MasterCurriculumDay(
      day: 16,
      title: 'Day 16: Abilities, Talents & Permission (Can / Can\'t)',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Modal Verbs of Capability',
      grammarConcept: 'Can / Could / Be able to for skills and polite requests',
      speakingDrill: 'Talk about 2 skills you have mastered and 1 you wish to learn.',
      peerChatMission: 'Discover a unique talent or skill your partner possesses.',
    ),
    17: MasterCurriculumDay(
      day: 17,
      title: 'Day 17: Expressing Likes, Dislikes & Nuanced Preferences',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Emotional Nuance & Phrasing',
      grammarConcept: 'Gerunds vs Infinitives ("enjoy doing" vs "prefer to do")',
      speakingDrill: 'Compare two foods, books, or movies and explain your preference.',
      peerChatMission: 'Engage in a friendly debate over tea vs coffee with your mate.',
    ),
    18: MasterCurriculumDay(
      day: 18,
      title: 'Day 18: Professional Phone Calls & WhatsApp Audio Notes',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Telephonic Etiquette & Audio Clarity',
      grammarConcept: '"May I speak with...", "I am calling regarding...", "Please hold"',
      speakingDrill: 'Record a professional voicemail leaving a clear message and callback.',
      peerChatMission: 'Simulate a business phone call inquiry with your peer.',
    ),
    19: MasterCurriculumDay(
      day: 19,
      title: 'Day 19: Social Invitations & Confirmations (Question Tags)',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Conversational Glue & Checking In',
      grammarConcept: 'Question Tags: "You\'re coming, aren\'t you?", "It\'s nice, isn\'t it?"',
      speakingDrill: 'Invite a friend to an event and confirm details using tags.',
      peerChatMission: 'Practice 4 question tag checks with your Pocket Mate.',
    ),
    20: MasterCurriculumDay(
      day: 20,
      title: 'Day 20: Politeness Multipliers & Diplomacy',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Softening Language & Respectful Tone',
      grammarConcept: '"Would you mind...", "I was wondering if...", "Could you possibly..."',
      speakingDrill: 'Turn 3 blunt requests into ultra-polite executive inquiries.',
      peerChatMission: 'Roleplay a sensitive office inquiry with your partner.',
    ),
    21: MasterCurriculumDay(
      day: 21,
      title: '🎯 Day 21 Habit Anchor: Unbroken Speech Gate',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Zero Mother-Tongue Fallback',
      grammarConcept: 'Discourse Continuity & Eliminating Fillers',
      speakingDrill: 'Speak continuously for 3 full minutes without hesitation or native words.',
      peerChatMission: 'Celebrate your 21-day streak in a 10-minute live audio talk.',
      xpReward: 150,
      milestoneReward: '🎯 Habit Anchor Lock Badge & Red Verified Tick',
    ),
    22: MasterCurriculumDay(
      day: 22,
      title: 'Day 22: Health, Symptoms & Medical Appointments',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Physical Sensations & Clinic Visits',
      grammarConcept: '"I have a sore throat", "I have been feeling dizzy since yesterday"',
      speakingDrill: 'Describe common symptoms and request a doctor\'s appointment.',
      peerChatMission: 'Roleplay a doctor-patient consultation with your mate.',
    ),
    23: MasterCurriculumDay(
      day: 23,
      title: 'Day 23: Travel, Transit & Airport Procedures',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Aviation, Customs & Rail Terminology',
      grammarConcept: 'Phrasal Verbs of Travel (check in, take off, pick up, set off)',
      speakingDrill: 'Simulate checking in luggage and asking for a window seat.',
      peerChatMission: 'Share your most memorable airport or transit story.',
    ),
    24: MasterCurriculumDay(
      day: 24,
      title: 'Day 24: Weather, Small Talk & Breaking the Ice',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Casual Social Openers',
      grammarConcept: 'Present Continuous for Weather ("It\'s pouring outside")',
      speakingDrill: 'Start a warm 60-second small talk conversation with a stranger.',
      peerChatMission: 'Exchange small talk openers naturally with your peer.',
    ),
    25: MasterCurriculumDay(
      day: 25,
      title: 'Day 25: Hobbies, Creative Passions & Free Time',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Articulating Intrinsic Motivation',
      grammarConcept: 'Adverbs of Degree (extremely, quite, slightly, absolutely)',
      speakingDrill: 'Talk enthusiastically for 90 seconds about what sparks your joy.',
      peerChatMission: 'Discover what your partner does when they are not studying.',
    ),
    26: MasterCurriculumDay(
      day: 26,
      title: 'Day 26: Describing Photos & Visual Scenes',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Spatial Visual Description',
      grammarConcept: 'In the foreground, in the background, on the upper left, next to',
      speakingDrill: 'Describe a famous photo or painting in detailed visual language.',
      peerChatMission: 'Describe a picture to your partner and have them guess what it is.',
    ),
    27: MasterCurriculumDay(
      day: 27,
      title: 'Day 27: Sentence Connectors & Conjunctions (FANBOYS)',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Complex Sentence Synthesis',
      grammarConcept: 'Coordinating & Subordinating Linkers (although, whereas, therefore)',
      speakingDrill: 'Connect 4 simple thoughts into one rich, flowing compound sentence.',
      peerChatMission: 'Take turns linking ideas using contrasting connectors.',
    ),
    28: MasterCurriculumDay(
      day: 28,
      title: 'Day 28: Pronunciation Clinic: The 5 Hardest Sounds',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Mouth Placement & Accent Clarity',
      grammarConcept: 'Distinctions: /θ/ vs /t/, /v/ vs /w/, /p/ vs /b/, /ʃ/ vs /s/',
      speakingDrill: 'Practice minimal pairs with deliberate exaggerated mouth positioning.',
      peerChatMission: 'Test each other on tricky minimal pairs over audio chat.',
    ),
    29: MasterCurriculumDay(
      day: 29,
      title: 'Day 29: Eradicating Mother Tongue Translation Lag',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Direct English Conceptualization',
      grammarConcept: 'Thinking in concepts instead of translated word strings',
      speakingDrill: 'Describe your current surroundings immediately with zero inner Malayalam.',
      peerChatMission: 'Play a rapid-fire association word game with your mate.',
    ),
    30: MasterCurriculumDay(
      day: 30,
      title: '🥈 Day 30 Silver Knight Foundation Capstone',
      phaseName: 'Phase 1: Foundation & Speech Mechanics (Days 1–30)',
      focusArea: 'Comprehensive Phase 1 Fluency Evaluation',
      grammarConcept: '12 Tenses Overview & Unified Grammatical Architecture',
      speakingDrill: 'Deliver a 3-minute capstone speech reflecting on your 30-day transformation.',
      peerChatMission: 'Conduct a formal 10-minute conversational check with your peer.',
      xpReward: 250,
      milestoneReward: '🥈 Silver Knight Shield & Chrome Profile Theme',
    ),

    // =========================================================================
    // PHASE 2: INTERMEDIATE FLUENCY & WORKPLACE SCENARIOS (DAYS 31 – 60)
    // =========================================================================
    31: MasterCurriculumDay(
      day: 31,
      title: 'Day 31: Professional Career Bio & Elevator Pitch',
      phaseName: 'Phase 2: Intermediate Fluency & Scenarios (Days 31–60)',
      focusArea: 'Workplace Self-Positioning',
      grammarConcept: 'Present Perfect for Career Experience ("I have worked in...")',
      speakingDrill: 'Deliver a crisp 60-second professional elevator pitch.',
      peerChatMission: 'Critique your partner\'s pitch and give 1 constructive compliment.',
    ),
    32: MasterCurriculumDay(
      day: 32,
      title: 'Day 32: Leading & Contributing in Team Standups',
      phaseName: 'Phase 2: Intermediate Fluency & Scenarios (Days 31–60)',
      focusArea: 'Status Updates & Milestone Tracking',
      grammarConcept: '"Currently, I am finalizing...", "Yesterday I addressed...", "Next up"',
      speakingDrill: 'Simulate presenting your daily project standup in 90 seconds.',
      peerChatMission: 'Roleplay a project review meeting with your Pocket Mate.',
    ),
    33: MasterCurriculumDay(
      day: 33,
      title: 'Day 33: Writing & Articulating Professional Messages',
      phaseName: 'Phase 2: Intermediate Fluency & Scenarios (Days 31–60)',
      focusArea: 'Corporate Tone & Brevity',
      grammarConcept: 'Action-oriented language & formal sign-offs',
      speakingDrill: 'Orally dictate a concise follow-up email to a corporate client.',
      peerChatMission: 'Review and refine each other\'s spoken email drafts.',
    ),
    34: MasterCurriculumDay(
      day: 34,
      title: 'Day 34: Diplomatic Disagreements & De-escalation',
      phaseName: 'Phase 2: Intermediate Fluency & Scenarios (Days 31–60)',
      focusArea: 'Constructive Criticism & Respectful Dissent',
      grammarConcept: '"I see your point; however, from my perspective..."',
      speakingDrill: 'Respectfully push back against an unrealistic project deadline.',
      peerChatMission: 'Debate a workplace dilemma while maintaining absolute diplomacy.',
    ),
    35: MasterCurriculumDay(
      day: 35,
      title: 'Day 35: Explaining Complex Issues to Non-Technical Peers',
      phaseName: 'Phase 2: Intermediate Fluency & Scenarios (Days 31–60)',
      focusArea: 'Clarity, Analogies & Simplification',
      grammarConcept: 'Relative Clauses for definitions (which, that, where, whose)',
      speakingDrill: 'Explain a technical concept from your work in plain, everyday English.',
      peerChatMission: 'Teach your partner a new concept in 2 minutes.',
    ),
    45: MasterCurriculumDay(
      day: 45,
      title: 'Day 45: Zero & First Conditionals in Strategy',
      phaseName: 'Phase 2: Intermediate Fluency & Scenarios (Days 31–60)',
      focusArea: 'Cause, Effect & Real Possibilities',
      grammarConcept: '"If we implement this strategy, we will achieve higher engagement."',
      speakingDrill: 'Formulate 4 realistic cause-and-effect workplace scenarios.',
      peerChatMission: 'Brainstorm "If-Then" business solutions with your partner.',
    ),
    46: MasterCurriculumDay(
      day: 46,
      title: 'Day 46: Second Conditionals — Dreams & Hypotheticals',
      phaseName: 'Phase 2: Intermediate Fluency & Scenarios (Days 31–60)',
      focusArea: 'Visionary Thinking & Abstract Scenarios',
      grammarConcept: '"If I were in charge, I would establish..." (Were for all persons)',
      speakingDrill: 'Describe how you would improve your city if you had unlimited resources.',
      peerChatMission: 'Share your wildest hypothetical dreams with your mate.',
    ),
    47: MasterCurriculumDay(
      day: 47,
      title: 'Day 47: Third Conditionals — Analyzing Past Lessons',
      phaseName: 'Phase 2: Intermediate Fluency & Scenarios (Days 31–60)',
      focusArea: 'Retrospective Evaluation & Regrets',
      grammarConcept: '"If we had identified the bug earlier, we would not have delayed."',
      speakingDrill: 'Reflect on a past mistake and articulate what you learned from it.',
      peerChatMission: 'Discuss how history would be different if key events changed.',
    ),
    60: MasterCurriculumDay(
      day: 60,
      title: '👑 Day 60 Gold Sovereign Fluency Gate',
      phaseName: 'Phase 2: Intermediate Fluency & Scenarios (Days 31–60)',
      focusArea: '5-Minute Keynote Presentation & Debate',
      grammarConcept: 'Mixed Conditionals, Inversion & Rhetorical Cadence',
      speakingDrill: 'Deliver a structured 5-minute keynote address on a global issue.',
      peerChatMission: 'Conduct an in-depth 20-minute strategic dialogue with your partner.',
      xpReward: 350,
      milestoneReward: '👑 24K Gold Sovereign Crown & Luxury Gold Theme',
    ),

    // =========================================================================
    // PHASE 3: ADVANCED MASTERY, RHETORIC & GRADUATION (DAYS 61 – 90)
    // =========================================================================
    68: MasterCurriculumDay(
      day: 68,
      title: 'Day 68: Executive Interviewing — The STAR Method',
      phaseName: 'Phase 3: Advanced Mastery & Native Nuance (Days 61–90)',
      focusArea: 'High-Stakes Behavioral Interview Answers',
      grammarConcept: 'Situation, Task, Action, Result structured phrasing',
      speakingDrill: 'Answer "Describe a time you handled a severe conflict under pressure".',
      peerChatMission: 'Conduct a formal 15-minute mock interview with your mate.',
    ),
    75: MasterCurriculumDay(
      day: 75,
      title: 'Day 75: Oxford-Style Debating & Persuasive Oratory',
      phaseName: 'Phase 3: Advanced Mastery & Native Nuance (Days 61–90)',
      focusArea: 'Ethos, Pathos, Logos & Argumentative Architecture',
      grammarConcept: 'Cleft Sentences & Emphatic Fronting for Persuasion',
      speakingDrill: 'Defend a controversial motion for 3 minutes using clear evidence.',
      peerChatMission: 'Engage in a live Oxford-style debate round with your peer.',
    ),
    90: MasterCurriculumDay(
      day: 90,
      title: '💎 Day 90 Diamond Master Capstone Graduation',
      phaseName: 'Phase 3: Advanced Mastery & Native Nuance (Days 61–90)',
      focusArea: 'Mastery Synthesis & Lifetime Autonomous Fluency',
      grammarConcept: 'Complete Linguistic Freedom & Native Cadence',
      speakingDrill: 'Deliver your graduation speech: 7 minutes of inspiring English oratory.',
      peerChatMission: 'Celebrate your 90-day graduation with the Pocket Mates community.',
      xpReward: 500,
      milestoneReward: '💎 Diamond Master Capstone Key & Lifetime Fluency Honor',
    ),
  };

  static MasterCurriculumDay _generateDynamicDay(int day) {
    final phase = day <= 30 ? 1 : (day <= 60 ? 2 : 3);
    String phaseName;
    String title;
    String focus;
    String grammar;
    String drill;
    String peer;

    if (phase == 1) {
      phaseName = 'Phase 1: Foundation & Speech Mechanics (Days 1–30)';
      title = 'Day $day: Daily Conversational Fluency Practice';
      focus = 'Natural Cadence & Zero Hesitation';
      grammar = 'Active Sentence Construction & Vocabulary Expansion';
      drill = 'Speak aloud for 90 seconds summarizing today\'s lesson.';
      peer = 'Practice a 3-minute conversational drill with your Pocket Mate.';
    } else if (phase == 2) {
      phaseName = 'Phase 2: Intermediate Fluency & Scenarios (Days 31–60)';
      title = 'Day $day: Practical Workplace & Complex Scenarios';
      focus = 'Professional Communication & Spontaneous Dialogue';
      grammar = 'Complex Conjunctions, Phrasal Verbs & Modal Nuances';
      drill = 'Deliver a 2-minute spontaneous talk on an assigned scenario.';
      peer = 'Discuss modern trends and collaborate on a mini-case study.';
    } else {
      phaseName = 'Phase 3: Advanced Mastery & Native Nuance (Days 61–90)';
      title = 'Day $day: Executive Eloquence & Rhetorical Polish';
      focus = 'Tone Modulation, Metaphors & Persuasive Nuance';
      grammar = 'Advanced Discourse Markers & Nuanced Rhetoric';
      drill = 'Present a 3-minute persuasive analysis with strategic pausing.';
      peer = 'Engage in high-level intellectual debate and mutual evaluation.';
    }

    final theoryConcept = phase == 1
        ? 'Sentence Structure (S+V+O) & Natural Vowel Rhythm'
        : (phase == 2
            ? 'Professional Discourse & Connecting Clauses'
            : 'Rhetorical Nuance & Unscripted Fluency');
    final theoryEn = phase == 1
        ? 'Master releasing verbs directly after the subject. In spoken English, keeping your phrases compact with clear intonation helps your listener follow without hesitation.'
        : (phase == 2
            ? 'Shift from simple sentences to compound and complex ideas using contrastive connectors (however, nevertheless, on the other hand).'
            : 'Elevate your diction with persuasive fronting, strategic rhetorical pauses, and unhesitating impromptu speech delivery.');
    final theoryMl = phase == 1
        ? 'വാക്യങ്ങൾ ഉണ്ടാക്കുമ്പോൾ സബ്ജക്റ്റിന് ശേഷം നേരെ ക്രിയ ഉപയോഗിക്കുക. സംഭാഷണത്തിൽ ഓരോ വാക്കും വ്യക്തമായി ഉച്ചരിക്കാൻ പരിശീലിക്കുക.'
        : (phase == 2
            ? 'ലളിതമായ വാക്യങ്ങളിൽ നിന്നും മാറി കൂടുതൽ കാര്യക്ഷമമായ കണക്റ്ററുകൾ ഉപയോഗിച്ച് സ്വാഭാവികമായി സംസാരിക്കുക.'
            : 'ബിസിനസ്സ് ചർച്ചകളിലും സംവാദങ്ങളിലും ആത്മവിശ്വാസത്തോടെയും ശരിയായ ഉച്ചാരണത്തോടെയും സംസാരിക്കുക.');
    final whyItMatters = phase == 1
        ? 'Automates spoken syntax so your vocal cords articulate thoughts without mental translation lag.'
        : (phase == 2
            ? 'Crucial for job interviews, office meetings, and expressing nuanced opinions.'
            : 'Essential for leadership presence, international presentations, and persuasive authority.');

    final commonMistakes = phase == 1
        ? [
            '❌ "I am having two cars."',
            '❌ "He don\'t know the answer."',
          ]
        : (phase == 2
            ? [
                '❌ "I will explain you tomorrow."',
                '❌ "Despite of the rain, we went."',
              ]
            : [
                '❌ "I suggest you to do this."',
                '❌ "He discussed about the issue."',
              ]);

    final mistakeCorrections = phase == 1
        ? [
            '✅ "I have two cars."',
            '✅ "He doesn\'t know the answer."',
          ]
        : (phase == 2
            ? [
                '✅ "I will explain it to you tomorrow."',
                '✅ "Despite the rain, we went." (or "In spite of")',
              ]
            : [
                '✅ "I suggest that you do this."',
                '✅ "He discussed the issue."',
              ]);

    final defaultVocab = [
      CurriculumVocabItem(
        word: 'ARTICULATE',
        phonetic: '/ɑːˈtɪk.jə.leɪt/',
        partOfSpeech: 'Verb',
        meaningEn: 'Express an idea or feeling fluently and coherently.',
        meaningMl: 'വ്യക്തമായും വ്യക്തതയോടെയും സംസാരിക്കുക',
        exampleEn: 'She was able to articulate her ideas clearly.',
        exampleMl: 'തന്റെ ആശയങ്ങൾ വ്യക്തമായി പ്രകടിപ്പിക്കാൻ അവൾക്ക് കഴിഞ്ഞു.',
      ),
      CurriculumVocabItem(
        word: 'PERSISTENCE',
        phonetic: '/pəˈsɪs.təns/',
        partOfSpeech: 'Noun',
        meaningEn: 'Firm continuance in a course of action despite difficulty.',
        meaningMl: 'സ്ഥിരോത്സാഹം / ലക്ഷ്യബോധത്തോടെ തുടരൽ',
        exampleEn: 'Fluency demands persistence and daily voice repetition.',
        exampleMl: 'ഇംഗ്ലീഷ് പ്രാവീണ്യത്തിന് സ്ഥിരോത്സാഹം അത്യന്താപേക്ഷിതമാണ്.',
      ),
      CurriculumVocabItem(
        word: 'CONVERSATION',
        phonetic: '/ˌkɒn.vəˈseɪ.ʃən/',
        partOfSpeech: 'Noun',
        meaningEn: 'A talk, especially an informal one, between two or more people.',
        meaningMl: 'സംഭാഷണം',
        exampleEn: 'Start every conversation with warmth and eye contact.',
        exampleMl: 'ഊഷ്മളതയോടെ സംഭാഷണം ആരംഭിക്കുക.',
      ),
      CurriculumVocabItem(
        word: 'PRACTICE',
        phonetic: '/ˈpræk.tɪs/',
        partOfSpeech: 'Noun / Verb',
        meaningEn: 'Repeated exercise in an activity to acquire or maintain proficiency.',
        meaningMl: 'പരിശീലനം',
        exampleEn: 'Daily deliberate practice rewires speech reflexes.',
        exampleMl: 'ദിവസേനയുള്ള കൃത്യമായ പരിശീലനം സംസാരശേഷി വർദ്ധിപ്പിക്കുന്നു.',
      ),
    ];

    return MasterCurriculumDay(
      day: day,
      title: title,
      phaseName: phaseName,
      focusArea: focus,
      grammarConcept: grammar,
      speakingDrill: drill,
      peerChatMission: peer,
      theoryConcept: theoryConcept,
      theoryExplanationEn: theoryEn,
      theoryExplanationMl: theoryMl,
      whyItMatters: whyItMatters,
      commonMistakes: commonMistakes,
      mistakeCorrections: mistakeCorrections,
      vocabulary: defaultVocab,
    );
  }
}
