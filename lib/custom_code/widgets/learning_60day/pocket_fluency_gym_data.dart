// 🏛️ Master Fluency Gym Data Engine (Days 1–90)
// Incorporating: Tongue Twisters, Word Stress Drills, Connected Speech,
// Conversation Starters, Roleplay, Shadowing, Filler Word Elimination,
// Picture / Situation Description, and Dictation / Fill-the-Gap.

class WordStressPair {
  final String primaryWord;
  final String phoneticStress;
  final String explanation;

  const WordStressPair({
    required this.primaryWord,
    required this.phoneticStress,
    required this.explanation,
  });
}

class PocketFluencyGymDayData {
  final int day;
  final String dayTheme;

  // 1. 👅 Tongue Twister & Speed Challenge
  final String tongueTwister;
  final String tongueTwisterTargetSound;
  final String tongueTwisterTipMl;
  final int tongueTwisterTargetSeconds;

  // 2. 🎵 Word Stress & Rhythm Drill
  final String wordStressFocus;
  final List<WordStressPair> wordStressPairs;
  final String rhythmRule;

  // 3. 🌊 Connected Speech & Consonant Cluster
  final String connectedSpeechTitle;
  final String writtenForm;
  final String spokenForm;
  final String soundClinicTipMl;
  final List<String> minimalPairs;

  // 4. 🎭 Conversation Starter & Roleplay
  final String roleplayScenario;
  final String partnerLine;
  final String yourPrompt;
  final String suggestedResponse;

  // 5. 🎙️ Shadowing & Read Aloud
  final String shadowingPassage;
  final String shadowingPacingTip;

  // 6. 🚫 Filler Word Elimination Practice
  final String fillerWordTrap;
  final String confidentReplacement;

  // 7. 🖼️ Situation / Picture Description
  final String situationTitle;
  final String situationDescription;
  final List<String> powerKeywords;

  // 8. 🎧 Dictation & Fill The Gap
  final String dictationAudioSentence;
  final String dictationPromptWithBlank;
  final String dictationAnswer;

  const PocketFluencyGymDayData({
    required this.day,
    required this.dayTheme,
    required this.tongueTwister,
    required this.tongueTwisterTargetSound,
    required this.tongueTwisterTipMl,
    this.tongueTwisterTargetSeconds = 8,
    required this.wordStressFocus,
    required this.wordStressPairs,
    required this.rhythmRule,
    required this.connectedSpeechTitle,
    required this.writtenForm,
    required this.spokenForm,
    required this.soundClinicTipMl,
    required this.minimalPairs,
    required this.roleplayScenario,
    required this.partnerLine,
    required this.yourPrompt,
    required this.suggestedResponse,
    required this.shadowingPassage,
    required this.shadowingPacingTip,
    required this.fillerWordTrap,
    required this.confidentReplacement,
    required this.situationTitle,
    required this.situationDescription,
    required this.powerKeywords,
    required this.dictationAudioSentence,
    required this.dictationPromptWithBlank,
    required this.dictationAnswer,
  });
}

class PocketFluencyGymRegistry {
  static PocketFluencyGymDayData getDataForDay(int day) {
    if (_dayOverrides.containsKey(day)) {
      return _dayOverrides[day]!;
    }
    return _generateProgressionData(day);
  }

  // Handcrafted curated deep days for critical milestone points
  static final Map<int, PocketFluencyGymDayData> _dayOverrides = {
    // -------------------------------------------------------------------------
    // DAY 1: BREAKING HESITATION & FIRST SOUNDS
    // -------------------------------------------------------------------------
    1: const PocketFluencyGymDayData(
      day: 1,
      dayTheme: 'Breaking Hesitation & Vocal Freedom',
      tongueTwister: 'A big black bug bit a big black bear.',
      tongueTwisterTargetSound: '/b/ & /p/ Plosive Burst',
      tongueTwisterTipMl: 'രണ്ട് ചുണ്ടുകളും ചേർത്ത് ശക്തിയായി കാറ്റ് പുറത്തേക്ക് വിടുക. "ബിഗ്ഗ് ബ്ലാക്ക് ബഗ്ഗ്"',
      tongueTwisterTargetSeconds: 7,
      wordStressFocus: 'Basic 2-Syllable Greeting & Names',
      wordStressPairs: [
        WordStressPair(
          primaryWord: 'HELLO',
          phoneticStress: 'hel-LO (Stress 2nd syllable)',
          explanation: 'Never say HE-lo flatly. Pitch rises gently on LO.',
        ),
        WordStressPair(
          primaryWord: 'MORNING',
          phoneticStress: 'MOR-ning (Stress 1st syllable)',
          explanation: 'Strong emphasis on MOR, soft drop on ning.',
        ),
        WordStressPair(
          primaryWord: 'WELCOME',
          phoneticStress: 'WEL-come (Stress 1st syllable)',
          explanation: 'The punch is on WEL, not on come.',
        ),
      ],
      rhythmRule: 'English is stress-timed! Words that carry real meaning (Hello, Welcome) are loud; filler words are short and soft.',
      connectedSpeechTitle: 'Blending "I am" and "Nice to meet you"',
      writtenForm: 'I am happy to meet you.',
      spokenForm: 'I\'m happy to mee-tchu.',
      soundClinicTipMl: '"Meet you" എന്ന് പറയുമ്പോൾ /t/ സൗണ്ടും /j/ സൗണ്ടും ചേർന്ന് "മീറ്റ്-ചു" (/tʃ/) ആയി മാറും.',
      minimalPairs: ['Bit / Beat', 'Bat / Bet', 'Pin / Bin'],
      roleplayScenario: 'Meeting a new colleague in the office corridor',
      partnerLine: 'Good morning! Are you new to this team?',
      yourPrompt: 'Say hello warmly, tell your name, and say you are excited to be here.',
      suggestedResponse: 'Good morning! Yes, I\'m Daniel. I\'m really excited to join the team today.',
      shadowingPassage: 'Hello everyone. My name is Daniel, and today marks the beginning of my journey to speaking fluent, confident English without hesitation.',
      shadowingPacingTip: 'Speak with a relaxed jaw. Breathe from your diaphragm, not your throat.',
      fillerWordTrap: 'Saying "Aa... umm... my name is..." when starting a sentence.',
      confidentReplacement: 'Inhale silently through the nose for 1 second, smile, and say: "Hi, I\'m..." directly.',
      situationTitle: 'A smiling person waving at a cafe table',
      situationDescription: 'Describe the person sitting across from you. Mention their smile, their cup of coffee, and greeting them.',
      powerKeywords: ['Smiling', 'Friendly', 'Holding a cup', 'Greeting'],
      dictationAudioSentence: 'Good morning, my name is Alex and I am glad to meet you.',
      dictationPromptWithBlank: 'Good morning, my name is Alex and I am _____ to meet you.',
      dictationAnswer: 'glad',
    ),

    // -------------------------------------------------------------------------
    // DAY 2: DAILY ROUTINE & PRESENT SIMPLE
    // -------------------------------------------------------------------------
    2: const PocketFluencyGymDayData(
      day: 2,
      dayTheme: 'Daily Routine & Morning Action Habits',
      tongueTwister: 'Seven snappy soldiers swiftly set the sail.',
      tongueTwisterTargetSound: '/s/ Clean Hiss without /ʃ/ (sh)',
      tongueTwisterTipMl: 'പല്ലുകൾ കൂട്ടിപ്പിടിച്ച് വിസിൽ പോലെ /s/ സൗണ്ട് ഉണ്ടാക്കുക. "ഷ" ആകരുത്.',
      tongueTwisterTargetSeconds: 7,
      wordStressFocus: 'Daily Habit Verbs',
      wordStressPairs: [
        WordStressPair(
          primaryWord: 'HABIT',
          phoneticStress: 'HA-bit (Stress 1st syllable)',
          explanation: 'Sharp HA, very light bit.',
        ),
        WordStressPair(
          primaryWord: 'ROUTINE',
          phoneticStress: 'rou-TINE (Stress 2nd syllable)',
          explanation: 'Long /iː/ sound on TINE: roo-TEEN.',
        ),
        WordStressPair(
          primaryWord: 'EXERCISE',
          phoneticStress: 'EX-er-cise (Stress 1st syllable)',
          explanation: 'Clear punch on EX, smooth fade on ercise.',
        ),
      ],
      rhythmRule: 'Action verbs (wake up, drink, run) carry rhythm pulses. Keep auxiliary words short.',
      connectedSpeechTitle: 'Fast Action Linking: "Wake up" & "Cup of"',
      writtenForm: 'I wake up and drink a cup of coffee.',
      spokenForm: 'I way-kup an\' drink a cuppa coffee.',
      soundClinicTipMl: '"Cup of" സാധാരണ സംഭാഷണത്തിൽ "cuppa" (കപ്പ) എന്നാണ് കണക്റ്റ് ആയി കേൾക്കുക.',
      minimalPairs: ['Wake / Wait', 'Cup / Cap', 'Sun / Son'],
      roleplayScenario: 'Friend asks about your daily schedule',
      partnerLine: 'What time do you usually wake up in the morning?',
      yourPrompt: 'State your wake-up time and one habit you do immediately (drink water, walk).',
      suggestedResponse: 'I usually wake up at six AM, drink a glass of warm water, and go for a quick jog.',
      shadowingPassage: 'Every morning, I wake up at sunrise. I plan my daily schedule, take twenty minutes to read, and prepare myself for a productive day ahead.',
      shadowingPacingTip: 'Match the rise and fall of the native speaker\'s voice tone.',
      fillerWordTrap: 'Saying "Like... every day I am waking up..." (using continuous instead of simple).',
      confidentReplacement: 'Use direct Present Simple: "Every day, I wake up at..."',
      situationTitle: 'A person making tea in a quiet morning kitchen',
      situationDescription: 'Describe the morning kitchen scene. Describe the sunlight coming through the window, the kettle boiling, and taking a fresh sip.',
      powerKeywords: ['Boiling', 'Fresh morning', 'Sunlight', 'Sipping tea'],
      dictationAudioSentence: 'I always wake up early and prepare a healthy breakfast.',
      dictationPromptWithBlank: 'I always wake up early and prepare a _____ breakfast.',
      dictationAnswer: 'healthy',
    ),

    // -------------------------------------------------------------------------
    // DAY 3: ASKING QUESTIONS & CURIOSITY
    // -------------------------------------------------------------------------
    3: const PocketFluencyGymDayData(
      day: 3,
      dayTheme: 'Asking Sharp Questions (Who, What, Where, When)',
      tongueTwister: 'Which witch wished which wicked wish?',
      tongueTwisterTargetSound: '/w/ Rounded Lip Glide',
      tongueTwisterTipMl: 'ചുണ്ടുകൾ വട്ടത്തിൽ കുറുക്കിപ്പിടിച്ച് /w/ പറയുക. പല്ലിൽ തൊടരുത്.',
      tongueTwisterTargetSeconds: 6,
      wordStressFocus: 'Question Words Intonation',
      wordStressPairs: [
        WordStressPair(
          primaryWord: 'QUESTION',
          phoneticStress: 'QUES-tion (Stress 1st syllable)',
          explanation: 'Pronounce as KWES-chun, not kves-tan.',
        ),
        WordStressPair(
          primaryWord: 'SCHEDULE',
          phoneticStress: 'SCHE-dule (US: SKED-yool / UK: SHED-yool)',
          explanation: 'Choose one accent and keep it clear.',
        ),
        WordStressPair(
          primaryWord: 'EXACTLY',
          phoneticStress: 'ex-ACT-ly (Stress 2nd syllable)',
          explanation: 'The /t/ is often lightly stopped: eg-ZAK-lee.',
        ),
      ],
      rhythmRule: 'Wh- questions naturally drop pitch at the end: "Where do you LIVE? ↘" (not rising like a surprise).',
      connectedSpeechTitle: 'Question Reductions: "What do you" & "Where did you"',
      writtenForm: 'What do you want to do tonight?',
      spokenForm: 'Whaddya wanna do tonight?',
      soundClinicTipMl: '"What do you" വേഗത്തിൽ പറയുമ്പോൾ "വാഡ്യ" (Whaddya) ആയി ചുരുങ്ങും.',
      minimalPairs: ['Which / Witch', 'Where / Wear', 'Why / Way'],
      roleplayScenario: 'Asking a stranger for directions or information',
      partnerLine: 'Excuse me, can you help me find the nearest metro station?',
      yourPrompt: 'Politely answer where it is, or ask them which line they want to take.',
      suggestedResponse: 'Sure! Walk straight for two blocks and turn left. Which line are you looking for?',
      shadowingPassage: 'Curiosity is the key to mastering any language. When you ask clear, concise questions, you invite others to open up and share rich conversations.',
      shadowingPacingTip: 'Drop your pitch downward at the end of the Wh-question for natural authority.',
      fillerWordTrap: 'Saying "What is your good name?" (outdated regional English).',
      confidentReplacement: 'Say directly and warmly: "May I have your name, please?" or "What\'s your name?"',
      situationTitle: 'A traveler looking at an airport departures board',
      situationDescription: 'Describe a traveler holding a passport, looking confused at the screen, and stepping forward to ask the flight attendant a question.',
      powerKeywords: ['Terminal', 'Departures board', 'Inquiring', 'Passport'],
      dictationAudioSentence: 'Where can I find the nearest public library in this neighborhood?',
      dictationPromptWithBlank: 'Where can I find the nearest public _____ in this neighborhood?',
      dictationAnswer: 'library',
    ),

    // -------------------------------------------------------------------------
    // DAY 4: DESCRIBING THINGS & ADJECTIVES (Articles Active Day)
    // -------------------------------------------------------------------------
    4: const PocketFluencyGymDayData(
      day: 4,
      dayTheme: 'Describing Things & Painting Word Pictures',
      tongueTwister: 'Fresh fried fish, fish fresh fried, fried fish fresh.',
      tongueTwisterTargetSound: '/f/ & /ʃ/ Crisp Air Flow',
      tongueTwisterTipMl: 'മുകളിലെ പല്ല് താഴത്തെ ചുണ്ടിൽ മുട്ടിച്ച് കാറ്റ് വിടുക: /f/.',
      tongueTwisterTargetSeconds: 6,
      wordStressFocus: 'Descriptive Adjectives',
      wordStressPairs: [
        WordStressPair(
          primaryWord: 'BEAUTIFUL',
          phoneticStress: 'BEAU-ti-ful (Stress 1st syllable)',
          explanation: 'BYOO-tih-ful, never beau-ti-FUL.',
        ),
        WordStressPair(
          primaryWord: 'COMFORTABLE',
          phoneticStress: 'COMF-ter-bul (3 syllables in spoken English!)',
          explanation: 'Native speakers drop the middle "ort": COMF-ter-bul.',
        ),
        WordStressPair(
          primaryWord: 'DELICIOUS',
          phoneticStress: 'de-LI-cious (Stress 2nd syllable)',
          explanation: 'Clear LI with soft shus ending.',
        ),
      ],
      rhythmRule: 'Adjectives + Nouns: The noun usually receives slightly stronger stress: "a big HOUSE", "a fresh MEAL".',
      connectedSpeechTitle: 'Article Linking: "An apple" & "A unique"',
      writtenForm: 'She bought an expensive umbrella and a unique book.',
      spokenForm: 'She bought-an expensive umbrella and-a unique book.',
      soundClinicTipMl: '"An" എന്ന വാക്ക് അടുത്ത സ്വരവുമായി (vowel) തടസ്സമില്ലാതെ ഒന്നിച്ച് ഉച്ചരിക്കുക: "അനെക്സ്പെൻസീവ്".',
      minimalPairs: ['Fit / Feet', 'Ship / Sheep', 'Pan / Pen'],
      roleplayScenario: 'Describing your hometown or favorite place to a friend',
      partnerLine: 'What is your favorite place to relax during weekends?',
      yourPrompt: 'Describe a serene, peaceful location using 3 colorful adjectives.',
      suggestedResponse: 'I love visiting a tranquil lakeside park nearby. The air is crisp, peaceful, and wonderfully refreshing.',
      shadowingPassage: 'A great communicator does not just state plain facts; they paint vivid pictures with adjectives that evoke sight, sound, texture, and emotion.',
      shadowingPacingTip: 'Linger slightly on descriptive words to give them visual weight.',
      fillerWordTrap: 'Overusing "very very good" or "nice".',
      confidentReplacement: 'Use richer adjectives: "exceptional", "delightful", "peaceful", "stunning".',
      situationTitle: 'A cozy coffee shop with rain on the window',
      situationDescription: 'Describe the warm amber lighting, steaming mug, aroma of roasted beans, and droplets running down the glass.',
      powerKeywords: ['Cozy', 'Steaming aroma', 'Raindrops', 'Amber lighting'],
      dictationAudioSentence: 'The historic cathedral was surrounded by ancient oak trees.',
      dictationPromptWithBlank: 'The historic cathedral was surrounded by _____ oak trees.',
      dictationAnswer: 'ancient',
    ),

    // -------------------------------------------------------------------------
    // DAY 9: ASKING DIRECTIONS (Prepositions Active Day)
    // -------------------------------------------------------------------------
    9: const PocketFluencyGymDayData(
      day: 9,
      dayTheme: 'Spatial Navigation & Prepositions of Place',
      tongueTwister: 'Near an ear, a nearer ear, a nearly eerie ear.',
      tongueTwisterTargetSound: '/r/ & /ɪər/ Vocal Glide',
      tongueTwisterTipMl: 'നാവ് അണ്ണാക്കിൽ മുട്ടിക്കാതെ പിന്നിലേക്ക് മടക്കി /r/ ഉണ്ടാക്കുക.',
      tongueTwisterTargetSeconds: 7,
      wordStressFocus: 'Prepositional Phrases',
      wordStressPairs: [
        WordStressPair(
          primaryWord: 'OPPOSITE',
          phoneticStress: 'OP-po-site (Stress 1st syllable)',
          explanation: 'Strong OP, soft po-zit.',
        ),
        WordStressPair(
          primaryWord: 'ADJACENT',
          phoneticStress: 'a-DJA-cent (Stress 2nd syllable)',
          explanation: 'Clear JAY sound in the middle: uh-JAY-sent.',
        ),
        WordStressPair(
          primaryWord: 'BEHIND',
          phoneticStress: 'be-HIND (Stress 2nd syllable)',
          explanation: 'bih-HYND with long /aɪ/ diphthong.',
        ),
      ],
      rhythmRule: 'Prepositions are unstressed grammatical glue: "Walk PAST the PARK to the METRO." The nouns take the beats.',
      connectedSpeechTitle: 'Fast Street Directions: "Turn left at"',
      writtenForm: 'Turn left at the traffic light and go straight ahead.',
      spokenForm: 'Turn-left-at the traffic light an\' go straight ahead.',
      soundClinicTipMl: '"Turn left at" പറയുമ്പോൾ /t/ കണക്റ്റ് ആയി "ടേൺ ലെഫ്റ്ററ്റ്" എന്ന് സുഗമമായി ഒഴുകണം.',
      minimalPairs: ['Right / Light', 'Cross / Close', 'Near / Rear'],
      roleplayScenario: 'Giving directions to a lost tourist',
      partnerLine: 'Pardon me, could you tell me how to get to City Hospital from here?',
      yourPrompt: 'Give 2 clear steps using prepositions (straight, across, next to).',
      suggestedResponse: 'Certainly! Walk straight down this road for two hundred meters. The hospital is directly across from the central bank, next to the pharmacy.',
      shadowingPassage: 'Navigating unfamiliar terrain requires clarity and poise. When you speak directions with steady rhythm and distinct milestones, listeners feel safe and guided.',
      shadowingPacingTip: 'Pause slightly after each directional milestone so the listener can mentally map it.',
      fillerWordTrap: 'Saying "Go there... then like... maybe..." while gesturing wildly.',
      confidentReplacement: 'Use transitional step markers: "First, go straight... Next, turn right... Finally, you\'ll see..."',
      situationTitle: 'A bustling downtown intersection with crosswalks',
      situationDescription: 'Describe pedestrians waiting at the pedestrian crossing, tall glass skyscrapers, and traffic moving smoothly.',
      powerKeywords: ['Intersection', 'Crosswalk', 'Pedestrians', 'Skyscrapers'],
      dictationAudioSentence: 'The conference hall is situated directly behind the main auditorium.',
      dictationPromptWithBlank: 'The conference hall is situated directly _____ the main auditorium.',
      dictationAnswer: 'behind',
    ),

    // -------------------------------------------------------------------------
    // DAY 11: PAST STORIES (Time Machine Past Simple Active Day)
    // -------------------------------------------------------------------------
    11: const PocketFluencyGymDayData(
      day: 11,
      dayTheme: 'Yesterday Stories & Past Verbs Pronunciation',
      tongueTwister: 'Peter Piper picked a peck of pickled peppers.',
      tongueTwisterTargetSound: '/p/ Explosive Puff of Air',
      tongueTwisterTipMl: 'ചുണ്ടുകൾക്കിടയിൽ കാറ്റ് തടഞ്ഞുനിർത്തി പെട്ടെന്ന് തുറക്കുക. കൈവിരലിൽ കാറ്റടിക്കണം.',
      tongueTwisterTargetSeconds: 8,
      wordStressFocus: 'Past Tense -ED Pronunciation (/t/, /d/, /ɪd/)',
      wordStressPairs: [
        WordStressPair(
          primaryWord: 'WORKED',
          phoneticStress: 'Pronounced with /t/ sound: "WURKT"',
          explanation: 'Never say work-ED! It is one sharp syllable: wurkt.',
        ),
        WordStressPair(
          primaryWord: 'DECIDED',
          phoneticStress: 'Pronounced with /ɪd/: "dih-SY-did"',
          explanation: 'Only verbs ending in /t/ or /d/ add the extra syllable -id!',
        ),
        WordStressPair(
          primaryWord: 'CALLED',
          phoneticStress: 'Pronounced with /d/: "KAWLD"',
          explanation: 'One syllable! Never call-ed.',
        ),
      ],
      rhythmRule: 'Irregular past verbs (went, saw, found) are strong content words and carry natural emotional stress.',
      connectedSpeechTitle: 'Dropping the "t" in Negative Past: "Didn\'t know"',
      writtenForm: 'I did not know what happened yesterday.',
      spokenForm: 'I didn\'t-know what happened yesterday (glottal stop on didn\').',
      soundClinicTipMl: '"Didn\'t" പറയുമ്പോൾ /t/ പൂർണ്ണമായി വെടിക്കാതെ തൊണ്ടയിൽ ഒതുക്കി "ഡിഡ്-ന്റ്" എന്ന് പറയുക.',
      minimalPairs: ['Passed / Past', 'Walked / Woke', 'Fought / Thought'],
      roleplayScenario: 'Explaining yesterday\'s unexpected delay to your manager',
      partnerLine: 'Why were you unable to attend yesterday afternoon\'s briefing?',
      yourPrompt: 'Explain that your commute was delayed by an unexpected train cancellation.',
      suggestedResponse: 'I sincerely apologize. My evening train was cancelled unexpectedly, so I arrived thirty minutes late.',
      shadowingPassage: 'Yesterday is a completed canvas. When we recount past events, our choice of precise past tense verbs transports the listener directly into the experience with vivid realism.',
      shadowingPacingTip: 'Emphasize the turning point in your past story with a subtle drop in pitch.',
      fillerWordTrap: 'Saying "Did you went?" or "I didn\'t saw him."',
      confidentReplacement: 'Rule: After "Did" or "Didn\'t", always use the base verb! "Did you go?", "I didn\'t see him."',
      situationTitle: 'An old vintage train arriving at a rainy platform',
      situationDescription: 'Describe the steam rising from the engine, passengers opening black umbrellas, and stepping onto the wet stone platform.',
      powerKeywords: ['Platform', 'Steam engine', 'Sheltered', 'Disembarked'],
      dictationAudioSentence: 'We completed the challenging project ahead of schedule last week.',
      dictationPromptWithBlank: 'We completed the _____ project ahead of schedule last week.',
      dictationAnswer: 'challenging',
    ),

    // -------------------------------------------------------------------------
    // DAY 21: THE HABIT ANCHOR MILESTONE
    // -------------------------------------------------------------------------
    21: const PocketFluencyGymDayData(
      day: 21,
      dayTheme: 'The 21-Day Habit Anchor & Unbroken Fluency Flow',
      tongueTwister: 'She sells seashells on the seashore, and the shells she sells are seashells, I\'m sure.',
      tongueTwisterTargetSound: '/s/ vs /ʃ/ Master Battle',
      tongueTwisterTipMl: 'സീ (പല്ല് ചേർത്ത്) vs ഷീ (നാവ് പിന്നിലേക്ക്). മാറ്റങ്ങൾ കൃത്യമായി സൂക്ഷിക്കുക.',
      tongueTwisterTargetSeconds: 10,
      wordStressFocus: 'Fluency & Flow Anchor Words',
      wordStressPairs: [
        WordStressPair(
          primaryWord: 'CONFIDENCE',
          phoneticStress: 'CON-fi-dence (Stress 1st syllable)',
          explanation: 'Clear punch on CON, effortless glide on fidence.',
        ),
        WordStressPair(
          primaryWord: 'DISCIPLINE',
          phoneticStress: 'DIS-ci-pline (Stress 1st syllable)',
          explanation: 'Never dis-SIP-line. The power is on DIS.',
        ),
        WordStressPair(
          primaryWord: 'UNSTOPPABLE',
          phoneticStress: 'un-STOP-pa-ble (Stress 2nd syllable)',
          explanation: 'Rhythmic bounce right on STOP: un-STOP-uh-bul.',
        ),
      ],
      rhythmRule: 'Sustained Flow: Don\'t stop speaking when you make a small grammar slip! Push forward with rhythm.',
      connectedSpeechTitle: 'Gliding between sentences with "As a result" & "In fact"',
      writtenForm: 'I practiced every day, and in fact, I feel much more confident.',
      spokenForm: 'I practiced everyday, an\' in fact, I feel much more confident.',
      soundClinicTipMl: 'വാക്യങ്ങൾക്കിടയിൽ പതറാതെ transition phrases ഉപയോഗിച്ച് ശബ്ദം സജീവമായി നിലനിർത്തുക.',
      minimalPairs: ['Sell / Shell', 'Seat / Sheet', 'Sip / Ship'],
      roleplayScenario: 'Sharing your 21-day breakthrough with a learning partner',
      partnerLine: 'Congratulations on reaching Day 21! How does your spoken English feel compared to Day 1?',
      yourPrompt: 'Share how your fear has melted away and how thinking directly in English feels natural now.',
      suggestedResponse: 'Thank you! On Day 1, I felt nervous translating every word. Today, sentences flow naturally, and I genuinely enjoy speaking aloud.',
      shadowingPassage: 'Twenty-one unbroken days of disciplined practice have fundamentally rewired your neural pathways. Hesitation is no longer your master; articulation is your proud new habit.',
      shadowingPacingTip: 'Speak with resonant chest voice, standing tall with sovereign posture.',
      fillerWordTrap: 'Saying "I am practicing English since 21 days" (incorrect preposition).',
      confidentReplacement: 'Use FOR for duration: "I have been practicing English FOR twenty-one days."',
      situationTitle: 'A marathon runner crossing the 21-kilometer milestone banner',
      situationDescription: 'Describe the runner looking determined, sweat on their forehead, crowd cheering, and maintaining steady breathing.',
      powerKeywords: ['Milestone', 'Endurance', 'Determined', 'Breakthrough'],
      dictationAudioSentence: 'Consistency is the true foundation upon which lasting mastery is built.',
      dictationPromptWithBlank: 'Consistency is the true foundation upon which _____ mastery is built.',
      dictationAnswer: 'lasting',
    ),

    // -------------------------------------------------------------------------
    // DAY 30: SILVER KNIGHT CAPSTONE (Phase 1 Finish)
    // -------------------------------------------------------------------------
    30: const PocketFluencyGymDayData(
      day: 30,
      dayTheme: 'Silver Knight Capstone: 30-Day Master Reflection',
      tongueTwister: 'The thirty-three thieves thought that they thrilled the throne throughout Thursday.',
      tongueTwisterTargetSound: '/θ/ Voiceless TH (Tongue between teeth)',
      tongueTwisterTipMl: 'നാവിന്റെ തുമ്പ് മുകളിലെയും താഴത്തെയും പല്ലുകൾക്കിടയിൽ അല്പം പുറത്തേക്ക് വെച്ച് കാറ്റ് വിടുക: /θ/ (തീവ്സ്).',
      tongueTwisterTargetSeconds: 10,
      wordStressFocus: 'Milestone & Achievement Vocabulary',
      wordStressPairs: [
        WordStressPair(
          primaryWord: 'MILESTONE',
          phoneticStress: 'MILE-stone (Stress 1st syllable)',
          explanation: 'Strong MILE, soft stone.',
        ),
        WordStressPair(
          primaryWord: 'ACHIEVEMENT',
          phoneticStress: 'a-CHIEVE-ment (Stress 2nd syllable)',
          explanation: 'The weight rests squarely on CHIEVE.',
        ),
        WordStressPair(
          primaryWord: 'PERSISTENCE',
          phoneticStress: 'per-SIS-tence (Stress 2nd syllable)',
          explanation: 'Crisp SIS with quiet per and tence.',
        ),
      ],
      rhythmRule: 'Capstone Delivery: Balance enthusiasm with calm, measured articulation. Master the pregnant pause.',
      connectedSpeechTitle: 'Masterful Discourse Connectors: "Not only... but also"',
      writtenForm: 'I have not only improved my grammar, but also gained genuine speaking confidence.',
      spokenForm: 'I\'ve not only improved my grammar, bud-also gained genuine confidence.',
      soundClinicTipMl: '"But also" കണക്റ്റ് ചെയ്യുമ്പോൾ /t/ ഒരു മൃദുവായ flap /d/ ആയി മാറി "ബഡ്-ഓൾസോ" എന്ന് മാറും.',
      minimalPairs: ['Thought / Taught', 'Thick / Tick', 'Theme / Team'],
      roleplayScenario: 'Silver Knight Capstone Interview with Senior Mentor',
      partnerLine: 'Welcome to your Day 30 Capstone Evaluation. Tell me, what was your most transformative breakthrough this month?',
      yourPrompt: 'Deliver a structured 45-second answer outlining your journey from silence to conversational freedom.',
      suggestedResponse: 'Thank you. Thirty days ago, fear held my tongue hostage. By following the daily drills, I eliminated translation lag. Today, I think in English and speak with authentic conviction.',
      shadowingPassage: 'Thirty days of deliberate vocal training have forged a Silver Knight within you. You have conquered the grammar traps, tamed pronunciation hurdles, and unlocked spontaneous dialogue.',
      shadowingPacingTip: 'Take a deep, centered breath before delivering your capstone monologue.',
      fillerWordTrap: 'Saying "Actually... basically... as per my point of view..."',
      confidentReplacement: 'Speak with executive directness: "From my perspective..." or "In my experience..."',
      situationTitle: 'A knight holding a silver shield at the summit of a hill',
      situationDescription: 'Describe the silver armor reflecting the dawn light, the sprawling valley below, and the winding road that led to the peak.',
      powerKeywords: ['Summit', 'Reflection', 'Accomplishment', 'Silver shield'],
      dictationAudioSentence: 'You have earned the Silver Knight rank through persistent daily dedication.',
      dictationPromptWithBlank: 'You have earned the Silver Knight rank through _____ daily dedication.',
      dictationAnswer: 'persistent',
    ),
  };

  // Algorithmically generate rich daily data for any day between 1 and 90
  static PocketFluencyGymDayData _generateProgressionData(int day) {
    final phase = day <= 30 ? 1 : (day <= 60 ? 2 : 3);
    
    // Rotating focus sounds & twisters
    final List<Map<String, String>> twisterBank = [
      {
        'twister': 'Red lorry, yellow lorry, red lorry, yellow lorry.',
        'sound': '/l/ vs /r/ Distinction',
        'tip': 'നാവ് മോണയിൽ തൊടുമ്പോൾ /l/, തൊടാതെ പിന്നോട്ട് വളയുമ്പോൾ /r/.'
      },
      {
        'twister': 'How much wood would a woodchuck chuck if a woodchuck could chuck wood?',
        'sound': '/w/ & /tʃ/ Dynamics',
        'tip': 'ചുണ്ടുകൾ വൃത്താകൃതിയിലാക്കി തുടങ്ങുക, പിന്നീട് /tʃ/ വെടിപ്പ്.'
      },
      {
        'twister': 'I scream, you scream, we all scream for ice cream.',
        'sound': '/skr/ Consonant Cluster',
        'tip': '/s/ + /k/ + /r/ മൂന്ന് ശബ്ദങ്ങളും ഇടവേളയില്ലാതെ കോർത്ത് പറയുക.'
      },
      {
        'twister': 'Fuzzy Wuzzy was a bear. Fuzzy Wuzzy had no hair.',
        'sound': '/z/ Buzzing Vocal Vibration',
        'tip': 'തൊണ്ടയിൽ വിരൽ വെച്ച് ശബ്ദതരംഗം അനുഭവിച്ച് /z/ ഉണ്ടാക്കുക.'
      },
      {
        'twister': 'Betty Botter bought some butter, but she said the butter\'s bitter.',
        'sound': '/b/ & /t/ Rapid Tap',
        'tip': 'നാവിന്റെ അറ്റം മുകളിലെ മോണയിൽ അതിവേഗം തട്ടി /t/ പടർത്തുക.'
      },
      {
        'twister': 'Eleven benevolent elephants elegantly elevated everyone.',
        'sound': '/v/ & /l/ Smooth Flow',
        'tip': 'പല്ല് ചുണ്ടിൽ തട്ടി /v/ ഉണ്ടാക്കി പെട്ടെന്ന് നാക്കിലേക്ക് /l/ മാറ്റുക.'
      },
    ];

    final twisterIndex = (day - 1) % twisterBank.length;
    final twisterInfo = twisterBank[twisterIndex];

    // Theme progression
    String theme;
    String scenario;
    String partner;
    String yourPrompt;
    String suggested;
    String dictationSentence;
    String dictationBlank;
    String dictationAnswer;

    if (phase == 1) {
      theme = 'Phase 1: Daily Essential Spoken Fluency (Day $day)';
      scenario = 'Everyday Conversation & Social Interaction';
      partner = 'Hi! How has your week been going so far?';
      yourPrompt = 'Respond warmly, share one productive highlight, and ask about their plans.';
      suggested = 'It has been quite productive! I completed my key tasks, and I am planning to relax this weekend. How about you?';
      dictationSentence = 'Clear pronunciation allows your ideas to shine with effortless confidence.';
      dictationBlank = 'Clear pronunciation allows your ideas to shine with _____ confidence.';
      dictationAnswer = 'effortless';
    } else if (phase == 2) {
      theme = 'Phase 2: Professional Mastery & Complex Scenarios (Day $day)';
      scenario = 'Workplace Strategy Meeting & Collaborative Negotiation';
      partner = 'Could you walk us through the primary advantages of this new proposal?';
      yourPrompt = 'Present two core benefits using transition markers like "First and foremost" and "Equally important".';
      suggested = 'First and foremost, this approach streamlines communication. Equally important, it reduces project turnaround time by twenty percent.';
      dictationSentence = 'Diplomatic phrasing empowers you to disagree constructively in professional discussions.';
      dictationBlank = 'Diplomatic phrasing empowers you to disagree _____ in professional discussions.';
      dictationAnswer = 'constructively';
    } else {
      theme = 'Phase 3: Executive Eloquence & Native Rhetoric (Day $day)';
      scenario = 'High-Stakes Keynote & Thought Leadership Q&A';
      partner = 'How do you anticipate emerging technological shifts will redefine human potential?';
      yourPrompt = 'Deliver a compelling, nuanced 60-second synthesis balancing optimism with pragmatic vigilance.';
      suggested = 'While technological disruption undeniably creates friction, it simultaneously elevates human creativity and empowers visionary leaders to solve planetary challenges.';
      dictationSentence = 'True eloquence lies not in verbose complexity, but in purposeful clarity.';
      dictationBlank = 'True eloquence lies not in verbose complexity, but in _____ clarity.';
      dictationAnswer = 'purposeful';
    }

    return PocketFluencyGymDayData(
      day: day,
      dayTheme: theme,
      tongueTwister: twisterInfo['twister']!,
      tongueTwisterTargetSound: twisterInfo['sound']!,
      tongueTwisterTipMl: twisterInfo['tip']!,
      tongueTwisterTargetSeconds: 8,
      wordStressFocus: 'Day $day Cadence & Multi-Syllable Stress',
      wordStressPairs: const [
        WordStressPair(
          primaryWord: 'DEVELOPMENT',
          phoneticStress: 'de-VEL-op-ment (Stress 2nd syllable)',
          explanation: 'Emphasis lands firmly on VEL.',
        ),
        WordStressPair(
          primaryWord: 'COMMUNICATION',
          phoneticStress: 'com-mu-ni-CA-tion (Stress 4th syllable)',
          explanation: 'The primary musical stress strikes CA.',
        ),
      ],
      rhythmRule: 'Stress content words (nouns, main verbs, adjectives). Compress function words (prepositions, articles).',
      connectedSpeechTitle: 'Native Linking & Word Blending',
      writtenForm: 'What are you going to do about it?',
      spokenForm: 'Whatcha gonna do about it?',
      soundClinicTipMl: 'സംഭാഷണത്തിൽ വാക്കുകൾ തമ്മിൽ സുഗമമായി കോർത്തുപോകാൻ ലിങ്കിംഗ് സഹായിക്കും.',
      minimalPairs: const ['Leave / Live', 'Reach / Rich', 'Sheep / Ship'],
      roleplayScenario: scenario,
      partnerLine: partner,
      yourPrompt: yourPrompt,
      suggestedResponse: suggested,
      shadowingPassage: 'Daily immersion creates neural fluency. As you speak aloud with consistent tempo and clear diction, hesitation yields to unconscious vocal mastery.',
      shadowingPacingTip: 'Focus on breathing at natural grammatical pauses, keeping your pitch steady.',
      fillerWordTrap: 'Relying on filler sounds when formulating thoughts.',
      confidentReplacement: 'Embrace the silent one-second pause. A quiet pause projects intelligence and self-control.',
      situationTitle: 'A team reviewing a strategic blueprint in a glass conference room',
      situationDescription: 'Describe the team members analyzing data charts, gesturing toward the screen, and aligning on milestones.',
      powerKeywords: ['Strategic', 'Collaborating', 'Milestones', 'Insightful'],
      dictationAudioSentence: dictationSentence,
      dictationPromptWithBlank: dictationBlank,
      dictationAnswer: dictationAnswer,
    );
  }
}
