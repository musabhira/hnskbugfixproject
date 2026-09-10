
/// 🔤 Alphabet & Phonic Sound Item
class AlphabetPhonicItem {
  final String letter;
  final String phoneme; // e.g. /æ/
  final String exampleWord;
  final String pronunciationGuide;
  final String audioPrompt;

  const AlphabetPhonicItem({
    required this.letter,
    required this.phoneme,
    required this.exampleWord,
    required this.pronunciationGuide,
    required this.audioPrompt,
  });
}

/// 📐 Sentence Pattern Model
class SentencePatternItem {
  final String formula;
  final String explanation;
  final List<String> masterSentences;
  final List<String> subjects;
  final List<String> verbs;
  final List<String> objects;

  const SentencePatternItem({
    required this.formula,
    required this.explanation,
    required this.masterSentences,
    required this.subjects,
    required this.verbs,
    required this.objects,
  });
}

/// 🗣️ Pronunciation Clinic Model
class PronunciationClinicItem {
  final String focusSound;
  final String mouthPositionTip;
  final List<Map<String, String>> minimalPairs;
  final List<String> practicePhrases;

  const PronunciationClinicItem({
    required this.focusSound,
    required this.mouthPositionTip,
    required this.minimalPairs,
    required this.practicePhrases,
  });
}

/// 🧠 English Thinking Workout Model
class EnglishThinkingItem {
  final String situation;
  final String mentalTrapMalayalam;
  final String directEnglishThought;
  final List<String> instantResponses;

  const EnglishThinkingItem({
    required this.situation,
    required this.mentalTrapMalayalam,
    required this.directEnglishThought,
    required this.instantResponses,
  });
}

/// 🎙️ In-Lesson Speaking Challenge Model
class SpeakingChallengeItem {
  final String title;
  final String contextScenario;
  final int targetSeconds;
  final List<String> guidingPoints;
  final String sampleNativeAudioScript;

  const SpeakingChallengeItem({
    required this.title,
    required this.contextScenario,
    required this.targetSeconds,
    required this.guidingPoints,
    required this.sampleNativeAudioScript,
  });
}

/// ⚡ Fluency Shortcut / Kurukkuvazhi Model
class FluencyShortcutItem {
  final String title;
  final String malyalamHeading;
  final String ruleSummary;
  final String quickHack;
  final List<String> examples;

  const FluencyShortcutItem({
    required this.title,
    required this.malyalamHeading,
    required this.ruleSummary,
    required this.quickHack,
    required this.examples,
  });
}

/// 🏛️ Deep Curriculum for Days 1 to 18 (Foundation, Phonetics, Sentence Patterns & Cognitive Fluency)
class PocketCurriculum1To18 {
  static bool handles(int day) => day >= 1 && day <= 18;

  // --- 🔤 ALPHABET & SOUND SYSTEM (Crucial for Day 1 / Beginners) ---
  static List<AlphabetPhonicItem> getAlphabetPhonics(int day) {
    if (day == 1) {
      return const [
        AlphabetPhonicItem(letter: 'A a', phoneme: '/æ/ - /eɪ/', exampleWord: 'Apple / Aim', pronunciationGuide: 'വാ തുറന്ന് നാവ് താഴ്ത്തി: /æ/ ആപ്പിൾ', audioPrompt: 'A is for Apple, /æ/'),
        AlphabetPhonicItem(letter: 'B b', phoneme: '/b/', exampleWord: 'Book / Brave', pronunciationGuide: 'രണ്ട് ചുണ്ടുകളും ചേർത്തുവെച്ച് പുറത്തേക്ക്: /b/', audioPrompt: 'B is for Book, /b/'),
        AlphabetPhonicItem(letter: 'C c', phoneme: '/k/ - /s/', exampleWord: 'Cat / City', pronunciationGuide: 'തൊണ്ടയുടെ പുറകിൽ നിന്ന്: /k/', audioPrompt: 'C is for Cat, /k/'),
        AlphabetPhonicItem(letter: 'D d', phoneme: '/d/', exampleWord: 'Dream / Door', pronunciationGuide: 'നാവിന്റെ തുമ്പ് മുകളിലെ പല്ലിന് പിന്നിൽ: /d/', audioPrompt: 'D is for Dream, /d/'),
        AlphabetPhonicItem(letter: 'E e', phoneme: '/e/ - /iː/', exampleWord: 'Echo / Eagle', pronunciationGuide: 'ചുരുങ്ങിയ ചുണ്ടുകളോടെ: /e/ എക്കോ', audioPrompt: 'E is for Echo, /e/'),
        AlphabetPhonicItem(letter: 'F f', phoneme: '/f/', exampleWord: 'Focus / Future', pronunciationGuide: 'മുകളിലെ പല്ല് താഴത്തെ ചുണ്ടിൽ മുട്ടിച്ച് കാറ്റ് പുറത്തേക്ക്: /f/', audioPrompt: 'F is for Focus, /f/'),
        AlphabetPhonicItem(letter: 'G g', phoneme: '/ɡ/ - /dʒ/', exampleWord: 'Grow / Giant', pronunciationGuide: 'തൊണ്ടയിൽ ശബ്ദമുണ്ടാക്കി: /ɡ/', audioPrompt: 'G is for Grow, /ɡ/'),
        AlphabetPhonicItem(letter: 'H h', phoneme: '/h/', exampleWord: 'Hope / Habit', pronunciationGuide: 'ശ്വാസം അയച്ചുവിട്ട് മൃദുവായി: /h/', audioPrompt: 'H is for Hope, /h/'),
        AlphabetPhonicItem(letter: 'I i', phoneme: '/ɪ/ - /aɪ/', exampleWord: 'Ignite / Inspire', pronunciationGuide: 'ഹ്രസ്വമായ സൗണ്ട്: /ɪ/ ഇഗ്നൈറ്റ്', audioPrompt: 'I is for Ignite, /ɪ/'),
        AlphabetPhonicItem(letter: 'J j', phoneme: '/dʒ/', exampleWord: 'Journey / Joy', pronunciationGuide: 'ചുണ്ടുകൾ ചെറുതായി മുന്നോട്ട്: /dʒ/', audioPrompt: 'J is for Journey, /dʒ/'),
        AlphabetPhonicItem(letter: 'K k', phoneme: '/k/', exampleWord: 'Knowledge / Key', pronunciationGuide: 'കാറ്റ് തട്ടിവിട്ട്: /k/', audioPrompt: 'K is for Key, /k/'),
        AlphabetPhonicItem(letter: 'L l', phoneme: '/l/', exampleWord: 'Learn / Leader', pronunciationGuide: 'നാവിന്റെ അറ്റം മുകളിലെ മോണയിൽ ഉറപ്പിച്ച്: /l/', audioPrompt: 'L is for Learn, /l/'),
        AlphabetPhonicItem(letter: 'M m', phoneme: '/m/', exampleWord: 'Master / Mind', pronunciationGuide: 'ചുണ്ടുകൾ പൂർണ്ണമായി അടച്ച് മൂക്കിലൂടെ ശബ്ദം: /m/', audioPrompt: 'M is for Master, /m/'),
        AlphabetPhonicItem(letter: 'N n', phoneme: '/n/', exampleWord: 'Noble / Never', pronunciationGuide: 'നാവ് മുകളിലെ അണ്ണാക്കിൽ മുട്ടിച്ച്: /n/', audioPrompt: 'N is for Noble, /n/'),
        AlphabetPhonicItem(letter: 'O o', phoneme: '/ɒ/ - /oʊ/', exampleWord: 'Open / Origin', pronunciationGuide: 'ചുണ്ടുകൾ വൃത്താകൃതിയിലാക്കി: /ɒ/', audioPrompt: 'O is for Open, /oʊ/'),
        AlphabetPhonicItem(letter: 'P p', phoneme: '/p/', exampleWord: 'Power / Purpose', pronunciationGuide: 'ചുണ്ടുകൾ അടച്ചുപിടിച്ച് ശക്തമായി കാറ്റ് പുറത്തേക്ക്: /p/ (ph കാറ്റോടെ)', audioPrompt: 'P is for Power, /p/'),
        AlphabetPhonicItem(letter: 'Q q', phoneme: '/kw/', exampleWord: 'Quest / Quality', pronunciationGuide: 'ക്+വ ചേർന്ന ശബ്ദം: /kw/', audioPrompt: 'Q is for Quest, /kw/'),
        AlphabetPhonicItem(letter: 'R r', phoneme: '/r/', exampleWord: 'Resilient / Rise', pronunciationGuide: 'നാവ് അണ്ണാക്കിൽ മുട്ടിക്കാതെ വളച്ച്: /r/', audioPrompt: 'R is for Rise, /r/'),
        AlphabetPhonicItem(letter: 'S s', phoneme: '/s/', exampleWord: 'Success / Speak', pronunciationGuide: 'പല്ലുകൾ ചേർത്തുപിടിച്ച് വിസിൽ പോലെ കാറ്റ്: /s/', audioPrompt: 'S is for Speak, /s/'),
        AlphabetPhonicItem(letter: 'T t', phoneme: '/t/', exampleWord: 'Triumph / Time', pronunciationGuide: 'നാവ് അണ്ണാക്കിൽ തട്ടി കാറ്റോടെ പൊട്ടിച്ച്: /t/', audioPrompt: 'T is for Time, /t/'),
        AlphabetPhonicItem(letter: 'U u', phoneme: '/ʌ/ - /juː/', exampleWord: 'Unstoppable / Unity', pronunciationGuide: 'വയറ്റിൽ നിന്ന് നേരെ പുറത്തേക്ക്: /ʌ/', audioPrompt: 'U is for Unstoppable, /ʌ/'),
        AlphabetPhonicItem(letter: 'V v', phoneme: '/v/', exampleWord: 'Victory / Voice', pronunciationGuide: 'മുകളിലെ പല്ല് താഴത്തെ ചുണ്ടിൽ വെച്ച് വിറപ്പിച്ച് ശബ്ദം: /v/', audioPrompt: 'V is for Victory, /v/'),
        AlphabetPhonicItem(letter: 'W w', phoneme: '/w/', exampleWord: 'Wisdom / World', pronunciationGuide: 'ചുണ്ടുകൾ വൃത്താകൃതിയിൽ കൂട്ടിപ്പിടിച്ച്: /w/', audioPrompt: 'W is for Wisdom, /w/'),
        AlphabetPhonicItem(letter: 'X x', phoneme: '/ks/', exampleWord: 'Excel / Apex', pronunciationGuide: 'ക്+സ് ചേർന്ന ശബ്ദം: /ks/', audioPrompt: 'X is for Excel, /ks/'),
        AlphabetPhonicItem(letter: 'Y y', phoneme: '/j/', exampleWord: 'Yield / Youth', pronunciationGuide: 'നാവ് മുകളിലേക്ക് ഉയർത്തി: /j/ ഈ..യ', audioPrompt: 'Y is for Youth, /j/'),
        AlphabetPhonicItem(letter: 'Z z', phoneme: '/z/', exampleWord: 'Zenith / Zeal', pronunciationGuide: 'തേനീച്ചയുടെ മൂളൽ പോലെ പല്ലുകൾ ചേർത്ത്: /z/', audioPrompt: 'Z is for Zeal, /z/'),
      ];
    }
    return const [];
  }

  // --- 📖 DEEP MULTI-PAGE STORIES (Substantial 2-3 Book Pages with TTS) ---
  static List<String> getStoryPages(int day) {
    switch (day) {
      case 1:
        return const [
          // PAGE 1: The Hesitant Learner & The Whispering Shadows (Page 1 of 3)
          'PAGE 1: THE HESITANT BEGINNER & THE INNER SHADOWS\n\n'
          'In a quiet valley village nestled between emerald hills, twenty-year-old Daniel sat on the porch of his family house, clutching an unopened English book. For years, Daniel had harbored a fierce, silent ambition: he wanted to speak English with sovereign authority, negotiate deals with international partners, and articulate his thoughts without the suffocating knot of hesitation in his throat.\n\n'
          'Yet, whenever he opened his mouth around peers or strangers, a wave of fear paralyzed him. What if my grammar is flawed? What if my pronunciation sounds clumsy? What if they laugh at my Malayalam-accented vowels? These relentless questions formed an invisible prison around him. Day after day, Daniel retreated into safe silence. He watched other young people speak boldly on stage, feeling a painful ache of inadequacy.\n\n'
          'On this warm morning, as the scent of wet soil rose from the rain, an elder scholar named Master George walked down the stone pathway. George was an internationally revered linguist who had mentored diplomats across six continents, yet he lived simply in the hills, observing the natural world. Seeing Daniel\'s crestfallen posture and the book resting unopened on his knees, George paused by the wooden fence and smiled gently.\n\n'
          '"Tell me, young man," George asked with warm resonance, "why do you stare at that book as though it were an enemy rather than an open door?"\n\n'
          'Daniel bowed his head. "Master, I want to master English, but I feel it is too vast, too difficult, and I am too late. When I hear native speakers on television, words pour from them like a rushing waterfall. When I attempt to speak, I must translate every single thought from my mother tongue first. I calculate verb tenses, I second-guess my prepositions, and by the time I form the sentence, the conversation has moved on. I feel like a tree that refuses to sprout."',

          // PAGE 2: The Secret of the Chinese Bamboo & Deep Roots (Page 2 of 3)
          'PAGE 2: THE SECRET OF THE DEEP ROOTS\n\n'
          'Master George laughed softly and gestured toward a grove of towering bamboo trees standing beside the river. Their slender stalks reached over eighty feet into the azure sky, swaying gracefully in the wind yet anchored so firmly that no tempest could topple them.\n\n'
          '"Walk with me, Daniel," the elder said. They strolled to the edge of the grove. George pointed to a small, unassuming patch of moist earth where nothing visible grew.\n\n'
          '"Do you know the chronicle of the giant bamboo?" George asked. "A farmer plants a tiny bamboo seed in this rich soil. He waters it faithfully every morning. He fertilizes the ground under the hot sun. He protects it from weeds. One full year passes—and nothing breaks the soil. Not a single green leaf. Two full years pass, with daily watering and tireless care, yet the ground remains completely bare. A foolish spectator would mock the farmer and declare the seed dead.\n\n'
          'Three years pass. Four years pass. Still, to the untrained eye, there is utter silence. But underground, in the unseen dark, something miraculous is unfolding. The seed is extending a dense, complex labyrinth of fibrous roots hundreds of feet in every direction. It is anchoring itself into bedrock, preparing the foundation to support monumental weight.\n\n'
          'Then, in the fifth year, the miracle happens: the bamboo shoots through the earth and grows ninety feet tall in just six weeks! Now ask yourself, Daniel: did the bamboo grow ninety feet in six weeks, or did it take five unbroken years of invisible root-building?"\n\n'
          'Daniel looked at the towering green stalks with wide eyes. "It grew because of the five years underground," he murmured.\n\n'
          '"Precisely!" George\'s voice rang with conviction. "Your daily English mission is that sacred seed. When you practice sixty minutes a day—when you pronounce alphabets, when you repeat sentence patterns, when you listen to authentic stories—you may not feel like an orator tomorrow morning. But underneath your conscious mind, you are wiring neural pathways. You are building invisible linguistic roots that will soon support effortless, unstoppable eloquence!"',

          // PAGE 3: The First Sovereign Utterance & The 90-Day Law (Page 3 of 3)
          'PAGE 3: THE FIRST SOVEREIGN UTTERANCE & THE 90-DAY LAW\n\n'
          'George took Daniel\'s book, opened it to the first page, and held it out. "The biggest mistake non-native learners make is the illusion of passivity. They believe that reading quietly with their eyes will teach their vocal cords to speak. It is impossible! Speaking is a physical muscle memory, like swimming or archery. Your tongue, your breath, and your brain must harmonize through active vibration.\n\n'
          'From this day forth, you must follow the Three Sovereign Laws of English:\n'
          'First, The Sound Law: Honor the letters. English is not phonetic like Malayalam or Hindi; letters change their music depending on their partners. Pronounce each sound boldly.\n'
          'Second, The Pattern Law: Stop memorizing isolated words! Words are dead bricks; sentence patterns are the living mortar. When you master a pattern like \'I am ready to...\' or \'Could you please...\', your brain instantly unlocks a hundred natural sentences without grammar anxiety.\n'
          'Third, The Immersion Law: Never translate. When you see water, do not think \'വെള്ളം\' and then convert it to \'water\'. Look at the liquid and let the English concept resonate directly in your mind."\n\n'
          'Master George looked deeply into Daniel\'s eyes. "Stand straight. Take a deep breath through your chest. Look across this valley, and say aloud: \'I am the architect of my own English voice. Today, my ninety-day transformation begins.\'"\n\n'
          'Daniel felt his heart thumping against his ribs. He felt the old whisper of doubt urging him to stay quiet. But looking at the resilient bamboo reaching into the heavens, he chose courage. He inhaled, expanded his posture, and projected his voice into the morning breeze:\n\n'
          '"I am the architect of my own English voice. Today, my ninety-day transformation begins!"\n\n'
          'The words echoed over the river. A warm surge of confidence surged through his veins. For the first time in his life, Daniel realized that fluency was not an innate gift bestowed on the lucky few—it was an honorable craft earned through daily, unbroken focus. He smiled, ready to conquer Day 1.',
        ];
      case 2:
        return const [
          // PAGE 1: The Dawn Alarm & The Five-Minute Mental Battle (Page 1 of 3)
          'PAGE 1: THE DAWN ALARM & THE FIVE-MINUTE BATTLE\n\n'
          'The digital clock on Daniel\'s nightstand clicked to 5:30 AM. Outside his window, the valley was shrouded in blue twilight, and a gentle mist drifted through the coconut palms. Day 1 had been intoxicating—filled with the adrenaline of fresh resolution and Master George\'s inspiring words. But now, on Day 2, the initial dopamine rush had faded, replaced by the heavy, sweet temptation of sleep.\n\n'
          '"Just thirty more minutes," Daniel\'s inner voice reasoned softly. "You worked hard yesterday. You can easily do your sixty minutes of English tonight after sunset. What difference does a few morning hours make?"\n\n'
          'Daniel lay beneath the warm blanket, staring at the ceiling. In that solitary five-minute window, the battle between his old self and the person he longed to become hung in the balance. He remembered George\'s warning from the riverbank: "The graveyard of fluency is paved with good intentions saved for \'tonight\'. By evening, your willpower is depleted, your mental battery is drained, and excuses sound reasonable. Amateurs wait for evening motivation; sovereign masters conquer their speech before the world wakes up."\n\n'
          'Gritting his teeth, Daniel threw off the blanket, stood up on the cool tiled floor, and poured himself a glass of fresh water. He splashed cold water across his face, opened his notebook, and whispered: "Day Two belongs to me."',

          // PAGE 2: The Two Coffee Cups & The Habit Anchor (Page 2 of 3)
          'PAGE 2: THE ANCHOR OF MORNING HABITS\n\n'
          'Ten minutes later, Daniel was walking briskly along the river trail toward Master George\'s cottage. The morning air was crisp and fragrant with wild jasmine. As he approached, he found George seated on a carved wooden stool, brewing black coffee over a copper kettle. Two ceramic mugs rested on the stone table.\n\n'
          '"You conquered the morning resistance, Daniel," George remarked with a knowing nod, sliding a steaming cup across the table. "Most learners fail not because English is difficult, but because they treat practice as an orphan task—something they hope to fit into an already chaotic day. If you want fluency to become effortless, you must anchor it to a habit you already do without thinking."\n\n'
          'George tapped his mug. "Every morning, you brew tea or coffee. You brush your teeth. You wash your face. These are established neural circuits in your brain. Now, pair your English with that physical anchor. When the kettle boils, your mouth begins its vocal drills. While the water heats, you recite your three sentence patterns out loud. Never negotiate with your habits. When the physical trigger occurs, the linguistic response must be automatic."\n\n'
          '"Notice the difference," George continued, leaning forward. "When you practice in the morning, your brain is in a receptive, high-neuroplasticity state. Your vocal tract is relaxed. What you speak aloud before breakfast echoes through your subconscious thoughts for the rest of the day."',

          // PAGE 3: The Mirror Protocol & The Power of Present Simple (Page 3 of 3)
          'PAGE 3: THE MIRROR PROTOCOL & THE OATH OF FLUENCY\n\n'
          'George handed Daniel a smooth brass pocket mirror. "Look into your reflection, Daniel. What holds learners back is self-consciousness—the dread of being evaluated. So today, we eliminate the audience entirely. You will become your own most articulate listener."\n\n'
          '"I want you to use the Present Simple tense to narrate your current reality in real time. Describe your surroundings, your breath, and your purpose. Do not pause to analyze grammar rules. Let the words flow directly from observation into sound."\n\n'
          'Daniel took a deep breath, looked steadily into the mirror, and began to speak aloud:\n\n'
          '"The morning sun is breaking through the emerald palms. Steam rises from my coffee mug. I feel the cool mountain breeze on my skin. My tongue and my mind work together in perfect rhythm. I do not fear mistakes, because mistakes are the raw data of mastery. Every morning I speak, my vocal cords grow stronger. Every day I practice, my English becomes my natural language of leadership."\n\n'
          'As the sentences flowed, Daniel felt a profound shift in his chest. The awkward friction that used to choke his words had vanished. He wasn\'t performing for a grade; he was claiming his own voice. Master George smiled and gave a firm nod.\n\n'
          '"You have unlocked Day 2," George said. "Remember this feeling: fluency is not about being clever. It is about showing up tomorrow morning, uninvited by mood, driven only by destiny."',
        ];
      case 3:
        return const [
          // PAGE 1: The Scattered Mind & The Digital Storm (Page 1 of 3)
          'PAGE 1: THE SCATTERED MIND & THE DIGITAL STORM\n\n'
          'Elena sat at her wooden desk, surrounded by open grammar workbooks, flashcards, and a glowing smartphone that buzzed incessantly every forty seconds. Group chat alerts, social media notifications, and breaking news banners flashed across the glass screen. Elena had spent three hours "studying", yet when she tried to speak a single cohesive paragraph about her aspirations, her thoughts fractured into nervous stammering.\n\n'
          '"Why is my mind so exhausted when I have barely spoken?" she whispered, pressing her palms against her temples. She was suffering from the epidemic of the modern era: cognitive fragmentation. She was attempting to build fluent neural circuitry while drowning in superficial digital dopamine.\n\n'
          'That evening, Paul, a master stone architect who had spent four decades restoring ancient Gothic cathedrals across Europe, stopped by her study. Observing the glowing phone and Elena\'s weary gaze, Paul pulled a roll of parchment blueprints from his leather satchel and spread them across her table.',

          // PAGE 2: The Cathedral Blueprints & The Stone Walls of Focus (Page 2 of 3)
          'PAGE 2: THE CATHEDRAL BLUEPRINTS & THE STONE WALLS\n\n'
          'Paul traced his finger along the thick outer walls of the cathedral drawing. "Look closely at these limestone bastions, Elena," the architect said softly. "Do you know why these towers have stood unshaken through eight centuries of hurricanes and wars?"\n\n'
          'Elena shook her head. "Because of deep foundations?"\n\n'
          '"Foundations, yes—but more importantly, acoustic isolation," Paul explained. "The medieval masons designed these walls four feet thick so that the chaotic noise of the marketplace outside could never breach the sanctuary within. Inside that sacred silence, scholars translated ancient manuscripts and musicians composed timeless harmonies. Silence is not an absence of sound; it is the fertile soil of monumental intellect.\n\n'
          'Your brain is a living cathedral, Elena. But every time your phone buzzes, you smash a hole through its sanctuary walls. You cannot build linguistic eloquence while entertaining every idle distraction in the universe."',

          // PAGE 3: The 60-Minute Silent Chamber & Cognitive Flowering (Page 3 of 3)
          'PAGE 3: THE 60-MINUTE SANCTUARY & THE POWER OF IMMERSION\n\n'
          'Taking Paul\'s counsel to heart, Elena performed a radical act. She took her smartphone, turned it off completely, and placed it inside a drawer in another room. She closed her study door, drew the curtains, and set a brass mechanical timer for sixty unbroken minutes.\n\n'
          'At first, her mind rebelled. Her hand instinctively reached for the nonexistent phone. But after ten minutes, a deep, crystal stillness descended upon her consciousness. Her breathing deepened. She opened her English text, engaged her vocal cords, and began speaking aloud with vibrant articulation. Words she had forgotten resurfaced effortlessly. Sentence structures locked into place like master masonry.\n\n'
          'When the brass bell rang at the end of the hour, Elena felt invigorated rather than depleted. She realized that twenty minutes of deep, uninterrupted English immersion produces more conversational velocity than eight hours of distracted browsing. She had become the architect of her own focus.',
        ];
      case 4:
        return const [
          // PAGE 1: The Shouting Assembly & Young Kaelen's Rejection (Page 1 of 3)
          'PAGE 1: THE SHOUTING TRIBUNAL & THE RAW HEURISTIC\n\n'
          'Inside the packed town council chamber of Eldergrove, twenty-two-year-old Kaelen was on the verge of tears. He was fiercely passionate about protecting the century-old pine forest bordering the valley from clear-cut commercial development. But during his presentation, emotion overtook reason. He raised his voice, pointed fingers at opposing council members, and interrupted senior civic leaders.\n\n'
          '"You are destroying our heritage!" Kaelen had shouted. "How can you be so reckless and short-sighted? You must approve this conservation bill immediately!"\n\n'
          'The council president frowned, banged his gavel loudly, and dismissed the petition without a vote. "Passionate shouting is not evidence, young man," the president declared. Kaelen stormed into the corridor, humiliated and enraged. In his mind, he had spoken the truth. Why had they rejected him?',

          // PAGE 2: The Diplomat's Bridge & The Art of Concession (Page 2 of 3)
          'PAGE 2: THE DIPLOMAT\'S SECRET & CONCESSIVE REASONING\n\n'
          'In the quiet marble colonnade, an elder envoy named Lord Ronald approached Kaelen with a gentle smile. Ronald had negotiated peace treaties between rival merchant syndicates for thirty years.\n\n'
          '"Sit with me, Kaelen," Ronald said, offering him a seat on the stone bench. "You made the classic error of novice debaters. You treated communication as a demolition derby instead of a bridge-building exercise. When you shout accusations, the human brain perceives an existential threat. Their ears shut down, their adrenaline spikes, and they entrench themselves in their original positions.\n\n'
          'Persuasion does not conquer an opponent; it invites them to discover the truth alongside you. To be persuasive in English, you must master the art of diplomatic concession. Before you state your demand, you must articulate your opponent\'s concerns more eloquently than they can themselves. Use phrases like: \'I acknowledge the economic validity of your proposal; however, let us examine the long-term sustainability.\'"',

          // PAGE 3: The Articulate Accord & Unanimous Agreement (Page 3 of 3)
          'PAGE 3: THE ARTICULATE ACCORD & DIPLOMATIC VICTORY\n\n'
          'The following morning, Kaelen requested five minutes before the reconvened council. He did not shout. He dressed impeccably, stood tall, and spoke with measured, resonant clarity.\n\n'
          '"Esteemed council members," Kaelen began, "I concede that timber revenue is vital for our municipal infrastructure. If we halt all logging indiscriminately, our local schools and clinics would face severe budget shortfalls. However, if we adopt a rotational selective harvesting model while designating the ancient grove as a permanent ecological reserve, we will secure commercial revenue while generating sustainable ecotourism for decades to come."\n\n'
          'The room fell silent. The developers nodded in agreement; the environmentalists smiled. When the council president called for the vote, twenty hands rose in unanimous assent. Kaelen learned that true authority in English comes not from volume, but from empathetic precision and reasoned articulation.',
        ];
      case 5:
        return const [
          // PAGE 1: Midnight Chaos & The Treacherous Reefs (Page 1 of 3)
          'PAGE 1: MIDNIGHT CHAOS ON THE TREACHEROUS REEF\n\n'
          'The merchant galleon *Sovereign Dawn* was caught in a violent force-nine gale off the craggy headland of Cape Horn. Thirty-foot waves battered the wooden hull, icy spray tore across the rigging, and the compass spun erratically. Below deck, water rushed through a damaged hatch, and panic swept through the young deckhands.\n\n'
          '"We are doomed! The rudder is jammed!" a sailor cried, dropping his safety line. Fear was spreading faster than the incoming sea water. In situations of acute crisis, human groups look instinctively for a voice of decisive authority. If that voice falters or hesitates, catastrophe is assured.\n\n'
          'At that moment, Captain Sarah pushed through the companionway hatch and stepped onto the storm-swept quarterdeck. Her oilskin coat was soaked, but her stance was anchored like granite.',

          // PAGE 2: The Calm Commander & Decisive Commands (Page 2 of 3)
          'PAGE 2: THE CALM COMMANDER & DECISIVE ENGLISH\n\n'
          'Sarah did not shout in hysterical panic; she projected her voice through the howl of the wind with crisp, razor-sharp cadence. Her language stripped away all filler words, using direct, unambiguous English imperatives:\n\n'
          '"Bosun! Secure the starboard halyard on my count! Helmsman! Lock the wheel ten degrees leeward! First mate! Deploy the secondary bilge pumps immediately!"\n\n'
          'The psychological effect of her composed English commands was instantaneous. The frantic sailors stopped crying out. Hearing certainty in their captain\'s voice, their nervous systems stabilized. They saw a plan; they heard authority; they remembered their duty. Men threw themselves onto the ropes, manning the iron pumps in synchronized unison.',

          // PAGE 3: Safe Harbor at Dawn & Turning Adversity into Triumph (Page 3 of 3)
          'PAGE 3: CITADEL HARBOR AT DAWN & THE RESOLUTE SPIRIT\n\n'
          'Hour after hour, Sarah remained at the helm through the freezing night, calling out course corrections and encouraging the exhausted crew. By dawn, the hurricane broke. Golden sunlight pierced the gray cloud banks, illuminating the tranquil waters of Citadel Harbor ahead.\n\n'
          'As the galleon dropped anchor beside the stone quay, the sailors cheered with tears of relief. Sarah gathered her crew on the sunlit deck.\n\n'
          '"Remember this night," she said quietly. "A ship is safe in harbor, but that is not what ships are built for. When adversity strikes your life, do not wait for the storm to calm. Find your footing, speak with unwavering clarity, and steer boldly into the waves. Decisive English communication is the helm that turns crisis into triumph."',
        ];
      case 6:
        return const [
          // PAGE 1: The Mountain Deadlock at Alveron (Page 1 of 3)
          'PAGE 1: THE MOUNTAIN DEADLOCK AT ALVERON\n\n'
          'High in the snow-capped mountain pass of Alveron, two rival merchant syndicates—the Northern Timber Consortium and the Coastal Maritime League—gathered inside the neutral fortress hall to negotiate waterway rights. An escalating dispute over seasonal canal access had brought regional trade to a total standstill. For seven agonizing hours, negotiations had devolved into bitter shouting matches.\n\n'
          '"You broke the charter!" the Northern chief shouted, slamming his fist onto the oak table. "If you had respected our lumber barges, our mills would not have stood empty all winter!"\n\n'
          '"And if you had delivered the contracted oak beams on time," the Coastal delegate countered coldly, "our shipyards would have paid your tariff in full!" Each delegation sat cross-armed, glowering in entrenched resentment. The talks had reached a fatal impasse.',

          // PAGE 2: The Counterfactual Time-Machine & Alistair\'s Reframing (Page 2 of 3)
          'PAGE 2: THE COUNTERFACTUAL TIME-MACHINE & THIRD CONDITIONALS\n\n'
          'Envoy Alistair, a veteran arbitrator who had studied linguistics in Geneva, stood up from his neutral observer seat. He walked to the center of the hall, poured water into two empty glasses, and placed them side by side.\n\n'
          '"Gentlemen," Alistair spoke in a calm, melodic baritone that cut through the tension. "You are both trapped in the past. You are using counterfactual third conditionals to assign blame: \'If you had done X, we would have done Y.\' That is natural, because analyzing past unreal conditions helps us understand our mistakes. But let us use the third conditional not as a weapon of accusation, but as an analytical lens of shared realization.\n\n'
          'If both houses had established an independent seasonal tariff committee last autumn, would either of you have suffered this winter? The answer is obvious: no. You would have maintained continuous commerce."',

          // PAGE 3: The Signing of the Alveron Accord (Page 3 of 3)
          'PAGE 3: THE ALVERON ACCORD & MUTUAL CONCESSION\n\n'
          'Alistair laid out a freshly penned charter on the center table. "The past is immutable; neither syndicate can alter last winter\'s harvest. But we can construct an unassailable mechanism for the future. We establish a joint regulatory commission with shared tariffs, seasonal quota locks, and binding arbitration.\n\n'
          'If we had failed to meet today, war would have erupted by spring. But because you had the wisdom to sit at this table, our nations can secure generational prosperity."\n\n'
          'The Northern leader looked across at his rival. The tension in the room dissolved. One by one, both delegations picked up the quill and affixed their sovereign wax seals to the Alveron Accord before sunset. Alistair demonstrated that when stakes are highest, articulate English reframes bitter deadlocks into lasting alliances.',
        ];
      case 7:
        return const [
          // PAGE 1: Before the Hall of Skeptics (Page 1 of 3)
          'PAGE 1: BEFORE THE HALL OF SKEPTICS\n\n'
          'The Great Amphitheater of Lysander was overflowing with twelve hundred skeptical academics, senior politicians, and critical journalists. Young research scientist Mira stood backstage, listening to the murmurs of the crowd. She was scheduled to defend her groundbreaking renewable atmospheric energy theorem—a radical theory that challenged sixty years of established scientific dogma.\n\n'
          '"They will dismiss you," her junior assistant whispered nervously, watching several hostile professors shake their heads in the front row. "They believe you are too young and your model is too bold."\n\n'
          'Mira took three slow diaphragmatic breaths. She remembered Master George\'s foundational lesson on vocal presence: "Amateur speakers attempt to please their listeners; sovereign orators command the room through cadence, pausing, and syntactic gravitas." She stepped through the curtain into the blinding stage lights.',

          // PAGE 2: The Architecture of Inversion & Vocal Dynamics (Page 2 of 3)
          'PAGE 2: THE ARCHITECTURE OF INVERSION & DRAMATIC FOCUS\n\n'
          'Mira did not begin with defensive apologies or timid pleasantries. She gripped the wooden rostrum, paused for four full seconds in total silence until every whisper died down, and delivered her opening thesis using powerful rhetorical inversion:\n\n'
          '"Rarely in the history of atmospheric physics do we encounter a moment where convention must bow to reproducible empirical truth. Seldom have scholars possessed such clear telemetry proving that energy can be harvested safely from ionization layers. And under no circumstances will our research institute suppress data to appease outdated orthodoxies!"\n\n'
          'The inverted word order struck the chamber like thunder. By pulling the restrictive adverbs *Rarely, Seldom,* and *Under no circumstances* to the beginning of her sentences, Mira inverted the auxiliary verbs and subjects, creating an irresistible oratorical urgency. The hostile professors sat upright, spellbound by her linguistic authority.',

          // PAGE 3: The Standing Ovation & The Sovereign Orator\'s Crown (Page 3 of 3)
          'PAGE 3: THE STANDING OVATION & UNASSAILABLE TRUTH\n\n'
          'For forty-five minutes, Mira dismantled every counter-argument with surgical mathematical precision and immaculate English eloquence. Whenever an opponent raised a technical objection, she deployed measured, confident responses: "Not only did our control trials confirm the phenomenon, but never in twelve consecutive months did our sensors deviate from predicted yields."\n\n'
          'When she concluded her final slide with a vision of clean global energy for millions of impoverished communities, the auditorium remained breathless for two seconds—and then erupted into a roaring standing ovation. Even her fiercest critics joined the applause.\n\n'
          'Mira smiled from the podium. She had proven that great ideas require great delivery: when profound truth is married to sophisticated English rhetoric, nothing can withstand its power.',
        ];
      case 8:
        return const [
          // PAGE 1: The Assembly of Divergent Nations (Page 1 of 3)
          'PAGE 1: THE ASSEMBLY OF DIVERGENT NATIONS\n\n'
          'Inside the Grand Plenary Hall of the United Nations in Geneva, representatives from fifty nations sat in fraught deliberation. The summit was convened to establish international legal frameworks for emerging autonomous cognitive systems. Technological velocity was outrunning ethical legislation at breakneck speed, and deep ideological rifts divided the assembly.\n\n'
          'Certain superpowers argued for total deregulation, prioritizing economic dominance; other developing countries feared being marginalized or exploited by foreign algorithms. Heated exchanges echoed across the translation headsets. The draft resolution was minutes away from being permanently shelved, plunging the world into unregulated chaos.\n\n'
          'Dr. Julian Vance, Chief Rapporteur for the International Ethics Commission, approached the microphone.',

          // PAGE 2: The Subjunctive Protocol & Measured Statesmanship (Page 2 of 3)
          'PAGE 2: THE SUBJUNCTIVE MANDATE & FORMAL DIPLOMACY\n\n'
          'Dr. Vance knew that ordinary conversational phrasing would lack the requisite legal weight to bind sovereign states. He elevated the register of the debate by invoking the classical English Subjunctive Mood—the language of formal treaties, parliamentary mandates, and constitutional decrees:\n\n'
          '"Distinguished delegates," Vance began, his voice ringing with sober gravity. "It is imperative that this assembly act with historical foresight. The international community demands that every technological developer adhere to universal human rights protections. It is crucial that sovereign algorithms remain subject to transparent civil oversight, and it is essential that no nation be excluded from our shared digital safeguards."\n\n'
          'Notice his syntactic precision: *that every developer adhere* (not adheres); *that algorithms remain* (not remains); *that no nation be excluded* (not is excluded). The pristine subjunctive cadence carried the unmistakable ring of constitutional permanence.',

          // PAGE 3: The Geneva Declaration & Generational Legacy (Page 3 of 3)
          'PAGE 3: THE GENEVA DECLARATION & THE SOVEREIGN CODE\n\n'
          'Vance looked across the assembly, locking eyes with ambassadors from opposing blocs. "If we surrender to nationalistic cynicism today, future generations will inherit an ungovernable algorithmic wasteland. But if we stand together on this singular principle, we synthesize technological speed with timeless humanitarian virtue."\n\n'
          'One by one, the chief delegates dropped their objections. The resolution was called for an immediate vote, and green indicator lights illuminated across all fifty national desks: unanimous adoption of the Geneva Declaration on Future Ethics.\n\n'
          'As diplomats applauded across the hall, Vance demonstrated that mastery of high-register English syntax is not an academic exercise—it is the indispensable currency of global statesmanship.',
        ];
      case 9:
        return const [
          // PAGE 1: The Specious Opponent at the Oxford Union (Page 1 of 3)
          'PAGE 1: THE SPECIOUS OPPONENT & THE SOPHISTRY TRAP\n\n'
          'The historic debate chamber of the Oxford Union was packed to capacity for the annual Inter-Collegiate Oratorical Championship. The motion before the house was controversial: *This House Believes That Global Institutions Have Failed the Digital Generation.* Speaking for the proposition was Marcus Sterling, an experienced senior debater notorious for his dazzling but deceptive rhetorical tricks.\n\n'
          'Sterling showered the audience with cherry-picked statistics, emotional hyperbole, and clever personal attacks disguised as humor. He presented the world as a simplistic binary: either you tear down every legacy institution, or you are complicit in corruption.\n\n'
          'When Sterling sat down to thunderous cheers from the student benches, young scholar Rowan stepped to the dispatch box. He knew that matching emotional outrage would only play into his opponent\'s trap.',

          // PAGE 2: The Cleft Sentence Spotlight & Dissecting Sophistry (Page 2 of 3)
          'PAGE 2: THE CLEFT SENTENCE SPOTLIGHT & DISSECTING SOPHISTRY\n\n'
          'Rowan took a sip of water, looked directly at the Union president, and launched his rebuttal using the precision tool of Cleft Sentences—restructuring syntax to shine a blinding spotlight on the core flaw of his rival\'s thesis:\n\n'
          '"Mr. President, what my eloquent opponent has presented this evening is not an empirical argument, but an exquisite illusion. What we must evaluate is not whether institutions are imperfect, for all human institutions stumble. What we must examine is whether dismantling our collaborative framework serves our generation, or whether it delivers us into lawless corporate hegemony.\n\n'
          'It was not the existence of global treaties that caused our current crises; it was our reluctance to enforce them with courage. What our generation truly demands is not destruction, but courageous reform!"',

          // PAGE 3: The Decisive Rebuttal & The Victory of Empirical Poise (Page 3 of 3)
          'PAGE 3: THE VICTORY OF EMPIRICAL POISE\n\n'
          'By employing *Wh-Clefts* ("What we must examine is...") and *It-Clefts* ("It was not X that caused Y, but Z..."), Rowan systematically dismantled Sterling\'s specious arguments point by point. He transformed a messy, emotional confrontation into a crystal-clear philosophical choice.\n\n'
          'He concluded with a resonant appeal: "True intellectual maturity does not live in simplistic black-and-white outrage. It lives in the crucible of nuance, evidence, and principled nuance."\n\n'
          'When the teller clerks counted the division ballots, Rowan\'s rebuttal carried the motion with an overwhelming 240-vote majority. Rowan stepped down from the dispatch box, having demonstrated that Socratic clarity and syntactic mastery always prevail over theatrical noise.',
        ];
      case 10:
        return const [
          // PAGE 1: The Weight of Fifty Nations in Deadlock (Page 1 of 3)
          'PAGE 1: THE DEADLOCK IN THE PEACE PALACE\n\n'
          'Inside the majestic Peace Palace in The Hague, a monumental diplomatic crisis had reached its tenth grueling day. A bitter territorial and economic dispute involving fifty sovereign nations had brought global shipping lanes to a standstill. Exhausted delegates were packing their briefcases, and several key ambassadors threatened to walk out before noon.\n\n'
          'Ten days earlier, Daniel had begun his English learning journey as a hesitant beginner on his village porch, afraid to speak even simple phrases. Now, ten unbroken days of deep immersion, phonetic clinics, sentence algorithms, and authentic literature had transformed him into an attentive, fearless observer of global diplomacy.\n\n'
          'He watched as Ambassador Helena Vance took the rostrum for the final plenary address of the summit.',

          // PAGE 2: The Mixed Conditional Time-Bridge & Historical Perspective (Page 2 of 3)
          'PAGE 2: THE MIXED CONDITIONAL TIME-BRIDGE & CAUSAL VISION\n\n'
          'Ambassador Vance did not plead with the angry delegates; she addressed them with the sovereign authority of a statesman who sees the past and the future in a single unified vision. She deployed the most sophisticated syntactic structure in the English language: the Mixed Conditional, linking historical past decisions directly to present realities:\n\n'
          '"Excellencies," Helena began, her voice reverberating off the stained-glass arches. "If our courageous predecessors had not gathered in this very chamber eighty years ago to sign the foundational charter, our nations would not stand here as independent, sovereign democracies today. Our present liberty is the direct fruit of their past sacrifice.\n\n'
          'And by the same token: if we walk out of this hall today in narrow pride, our children will inherit an unstable, fractured world tomorrow. Past courage shapes present reality; present courage determines future destiny."',

          // PAGE 3: The Unanimous Accord & The 10-Day Golden Milestone (Page 3 of 3)
          'PAGE 3: THE UNANIMOUS ACCORD & THE TEN-DAY GOLDEN MILESTONE\n\n'
          'The effect of her speech was profound. The delegates stopped packing their bags. They realized that their immediate partisan grievances were insignificant compared to the generational legacy at stake. By four in the afternoon, the historic Treaty of The Hague was finalized, signed, and ratified with unanimous acclamation.\n\n'
          'Outside the Peace Palace, Daniel closed his workbook and looked up into the twilight sky. Ten unbroken days had passed. He had mastered 100 core vocabulary words, decoded 10 algorithmic Code English formulas, dismantled hesitations in live peer conversations, and completed ten authentic multi-page literature journeys.\n\n'
          'He was no longer the hesitant student afraid of making mistakes. His unseen linguistic roots had anchored deep into bedrock. He smiled with unshakeable confidence, knowing that he had conquered Gate 1 and stood ready for the next glorious eighty days of global fluency.',
        ];
      case 11:
        return const [
          // PAGE 1: Crossing the Threshold of Gate 2 (Page 1 of 3)
          'PAGE 1: BEYOND GATE ONE: THE ODYSSEY OF REINVENTION\n\n'
          'Dawn broke over the tranquil valley with a radiant amber hue. Having conquered the foundational bedrock of Gate 1, Daniel returned to Master George\'s sanctuary. Today felt distinct; the nervous timidity of his early days had vanished, replaced by a steady, quiet hunger for intellectual mastery.\n\n'
          'Master George sat beside an ancient mahogany map table strewn with manuscripts written in Greek, Latin, and classical English prose. Seeing Daniel\'s resolute bearing, the elder linguist nodded with deep approval.\n\n'
          '"Welcome to Gate Two, Daniel," George announced, his voice imbued with profound solemnity. "In your first ten days, you cultivated discipline, conquered basic sentence syntax, and rooted your tongue in phonetic precision. But elementary competence is merely the shore. Today, we cast our vessel into the deep ocean of linguistic virtuosity and cognitive evolution.\n\n'
          'Language is not a static tool for exchanging crude facts; it is an organic, living instrument of thought. When your vocabulary expands, the very architecture of your mind metamorphoses. Thoughts that were once amorphous, blurry intuitions transform into razor-sharp, crystalline convictions."',

          // PAGE 2: The Morphological Forge & Latin-Greek Roots (Page 2 of 3)
          'PAGE 2: THE MORPHOLOGICAL FORGE & POLYSYLLABIC KEYS\n\n'
          'George opened a massive lexicon bound in worn leather. "To ordinary minds, English appears as a chaotic labyrinth of a million unrelated words. But to a master of the Code, English is an algebraic matrix composed of Greek and Latin root keys.\n\n'
          'Consider the word \'Metamorphosis\': from the Greek \'meta\', meaning beyond or change, and \'morphe\', meaning form. When combined with the suffix \'-osis\', it signifies a complete structural transformation. Consider \'Epiphany\': from \'epi\', upon, and \'phainein\', to show—a lightning bolt of sudden spiritual or intellectual illumination. Consider \'Inexorable\': from Latin \'in-\' (not) and \'exorare\' (to prevail upon with prayer)—a relentless march of progress that cannot be deterred by excuses.\n\n'
          'When you master the root code, Daniel, you no longer memorize individual words like a parrot. You decode twenty words at a single glance. Your speech shifts from hesitant translation to effortless erudition."',

          // PAGE 3: The Inexorable March Toward Mastery (Page 3 of 3)
          'PAGE 3: THE INEXORABLE OATH OF COGNITIVE EVOLUTION\n\n'
          'Master George closed the lexicon and looked Daniel directly in the eyes. "Daniel, examine your own reflection. Eleven days ago, you dared not speak three English words without the paralyzing fear of ridicule. Today, you understand the architecture of classical oratory. What has taken place within you?"\n\n'
          'Daniel took a deep, diaphragmatic breath. He did not search for Malayalam words to translate; the English concepts formed directly in his consciousness, rich and unconstrained:\n\n'
          '"Master George, having conquered Gate One, I realize that fluency is not an accident of birth; it is an indomitable discipline. My fear has undergone an inexorable metamorphosis into purpose. With linguistic virtuosity, I shall transcend every barrier that once confined my voice."\n\n'
          'George smiled proudly and inscribed the Golden Seal of Gate 2 upon Daniel\'s journal. The Odyssey of Reinvention had begun.',
        ];
      case 12:
        return const [
          // PAGE 1: The Sorbonne Great Hall & The Anatomy of Deceit (Page 1 of 3)
          'PAGE 1: THE GREAT HALL OF THE SORBONNE & THE RHETORICAL TRAP\n\n'
          'Inside the historic Grand Amphitheater of the Sorbonne University in Paris, twelve hundred scholars, diplomats, and jurists sat in rapt silence. On the central podium stood Lord Castlereagh, a notoriously aggressive debate champion celebrated for his theatrical swagger and rapid-fire oratorical broadsides.\n\n'
          'Castlereagh was defending a contentious proposal to centralize technological governance under a private corporate monopoly. His speech was dazzling, adorned with sweeping promises and emotional anecdotes. Yet beneath the glittering surface lay a treacherous web of specious premises, fallacious logic, and evasive equivocation.\n\n'
          'Sitting in the gallery with Master George, Daniel leaned forward, his analytical senses primed. "Notice his strategy," George whispered quietly. "When facts contradict his thesis, he prevaricates. He substitutes dramatic fury for empirical evidence. How will Scholar Rowan respond?"',

          // PAGE 2: Rowan\'s Dissection & The Concessive Masterclass (Page 2 of 3)
          'PAGE 2: THE ANATOMY OF SENSATIONAL SOPHISTRY\n\n'
          'Scholar Rowan, a soft-spoken jurisprudential scholar with razor-sharp perspicacity, stepped up to the dispatch box. He did not raise his voice, nor did he interrupt his adversary with rude outbursts. Instead, he deployed the ultimate weapon of philosophical debate: the Concessive Dissection.\n\n'
          '"Granted that my distinguished opponent speaks with undeniable eloquence," Rowan began, his measured cadence cutting through the chamber like a surgical scalpel. "Granted further that his vision of centralized speed promises immediate administrative convenience.\n\n'
          'Yet, let us not allow dazzling rhetoric to blind this assembly to empirical reality. The core premise of his argument is entirely fallacious: he equates corporate hegemony with democratic efficiency. When pressed on civil accountability, he prevaricates; when asked to verify audit standards, his answers remain equivocal. A policy built upon specious foundations cannot withstand historical scrutiny."',

          // PAGE 3: The Triumph of Perspicacity & Irrefutable Truth (Page 3 of 3)
          'PAGE 3: THE TRIUMPH OF PERSPOICACITY OVER THEATRICS\n\n'
          'Lord Castlereagh attempted to counter with blustering indignation, but Rowan\'s calm precision had already dismantled the illusion. Question by question, premise by premise, Rowan exposed the hidden fallacies using subjunctive mandates and undeniable economic concessions.\n\n'
          'By the time the division bell tolled, the assembly voted overwhelmingly to reject Castlereagh\'s monopoly motion by an unprecedented four-to-one margin. The Great Amphitheater erupted in prolonged, standing applause.\n\n'
          'Walking out into the Parisian twilight, Daniel remarked with awe: "Rowan never raised his voice, Master George, yet his words carried the crushing weight of an avalanche."\n\n'
          '"Indeed," George replied with a serene smile. "The loud speaker seeks to intimidate; the master dialectician seeks to illuminate. When you arm yourself with perspicacity and dialectic logic, no amount of sophistry can withstand your truth."',
        ];
      case 13:
        return const [
          // PAGE 1: The Shadows of the Cavendish Laboratory (Page 1 of 3)
          'PAGE 1: THE ANOMALY AT THE CAVENDISH LABORATORY\n\n'
          'In the historic Cavendish Laboratory at Cambridge, midnight had long since struck, yet the luminaries in the quantum neuro-linguistics department remained burning bright. Dr. Elena Vance and her research fellow stood over a holographic neural scanner, staring at a series of unprecedented brain-wave oscillations.\n\n'
          'For nearly a century, established neuroscientific dogma held that adult brains lose their capacity for accent-free linguistic neuroplasticity after adolescence. Yet Elena\'s longitudinal study of adult immersion learners—including students who began their second language past thirty—revealed robust, bilateral synaptic restructuring in Broca\'s area.\n\n'
          'The data point was so radical, so completely incongruous alongside orthodox textbooks, that Elena\'s senior colleagues advised her to discard the data. "If you publish this," they warned, "the academic establishment will ridicule you."',

          // PAGE 2: The Crucible of Peer Review & Epistemic Humility (Page 2 of 3)
          'PAGE 2: THE CRUCIBLE OF EMPIRICAL RIGOR\n\n'
          'Elena refused to compromise scientific truth. But she knew that in high academia, arrogant dogmatism is fatal. To sway skeptical peers, she could not simply declare herself right; she had to employ the highest standard of scientific communication: Epistemic Hedging.\n\n'
          'Standing before the Royal Academy of Sciences six months later, Elena faced a hall filled with world-renowned neuroscientists. She did not boast; she articulated her findings with calm, forensic empiricism:\n\n'
          '"Esteemed colleagues, our findings do not claim to overthrow classical neurology overnight. However, extensive double-blind empirical trials across six independent laboratories strongly corroborate our central thesis: linguistic neuroplasticity is governed not by chronological age, but by the depth, frequency, and emotional resonance of daily cognitive immersion.\n\n'
          'Incongruous though our initial readings appeared, the statistical significance of over twenty thousand longitudinal scans gives overwhelming credence to this paradigm shift."',

          // PAGE 3: The Corroborated Breakthrough & Scientific Vindication (Page 3 of 3)
          'PAGE 3: THE VINDICATION OF SKEPTICAL INQUIRY\n\n'
          'The auditorium fell into absolute silence. The skeptics scrutinized her methodology, analyzed her control groups, and examined her raw statistical distributions. They searched for a single flawed assumption, but Elena\'s epistemic rigor had left no flank exposed.\n\n'
          'One by one, the most senior professors on the review board rose from their chairs and nodded in profound acknowledgment. Elena\'s pioneering work was vindicated, sparking a worldwide revolution in adult language acquisition methodology.\n\n'
          'In his study, Daniel highlighted Elena\'s master formula in his notebook. He understood that true mastery does not rely on bluster or defensive ego; it rests on unyielding empiricism, replicable evidence, and the courage to challenge established limits.',
        ];
      case 14:
        return const [
          // PAGE 1: The Maritime Impasse at the Geneva Grand Palais (Page 1 of 3)
          'PAGE 1: THE RECALCITRANT IMPASSE AT THE PALAIS DES NATIONS\n\n'
          'In the cavernous Assembly Hall of the Palais des Nations in Geneva, ninety delegations had reached a paralyzing diplomatic impasse on Day 14 of the Global Maritime Accord. Heated arguments raged over international navigation straits, automated deep-sea mineral rights, and sovereignty tariffs.\n\n'
          'Two powerful coalitions had dug their heels in; several prime ministers had given their delegations instructions to veto any resolution that required compromise. The conference chairman sighed in exhaustion, preparing to declare the entire two-year negotiation a catastrophe.\n\n'
          'Just as the session seemed doomed, Ambassador Marcus Thorne rose to take the central podium. Marcus was celebrated across international diplomatic circles as a master of forensic persuasion and rhetorical architecture.',

          // PAGE 2: The Tricolon Cadence & The Architecture of Fronting (Page 2 of 3)
          'PAGE 2: THE CITADEL OF TRICOLON CADENCE\n\n'
          'Marcus did not begin with dull bureaucratic thank-yous. He understood that to shatter an emotional impasse, an orator must deploy the majestic classical device of Rhetorical Fronting combined with the Triadic Cadence (Tricolon):\n\n'
          '"Front and center before this assembly," Marcus declared, his resonant baritone echoing off the travertine marble columns, "stands not the narrow ambition of any individual party, but the fragile shared destiny of mankind\'s oceans.\n\n'
          'In the crucible of this historic summit, our citizens demand transparency; our economies require stability; and above all, our children deserve an ocean protected from reckless exploitation. Not only does this treaty safeguard the sovereign maritime borders of every coastal nation, but it also democratizes sustainable maritime commerce, and ultimately cements a generational framework for international peace."',

          // PAGE 3: The Unanimous Accord & Diplomatic Acumen (Page 3 of 3)
          'PAGE 3: THE RATIFICATION OF THE CITADEL CHARTER\n\n'
          'The sheer architectural symmetry of his three-part cadence sent an electric surge through the assembly. The rhythm was hypnotic, elevating the debate above partisan bitterness into the realm of shared human dignity.\n\n'
          'The most recalcitrant delegates looked across the aisle at their rivals. The barriers of mistrust melted under the heat of Marcus\'s eloquent synthesis. By nightfall, all ninety sovereign delegations affixed their golden signatures to the Geneva Maritime Charter, ratifying the accord without a single dissenting vote.\n\n'
          'Daniel watched the recorded address with glowing enthusiasm. "Master George," he said, "Marcus did not alter the facts, yet his cadence unified ninety conflicting nations!"\n\n'
          '"That, Daniel," George answered with a reverent gaze, "is the Citadel of Rhetoric. When language is wielded with triadic harmony, it possesses the power to reshape the geopolitical destiny of our world."',
        ];
      case 15:
        return const [
          // PAGE 1: The Diplomatic Academy of Vienna (Page 1 of 3)
          'PAGE 1: THE DIPLOMATIC ACADEMY OF VIENNA & THE WEIGHT OF REGISTER\n\n'
          'The snow fell gently over the baroque courtyards of the Diplomatic Academy of Vienna. Inside the gilded hall of St. Stephen\'s wing, Daniel sat among an elite cohort of international envoys undergoing the highest tier of diplomatic training.\n\n'
          'At the front of the hall stood Ambassadress Claudette Laurent, a veteran negotiator who had mediated peace settlements in the Balkans, the Middle East, and East Asia. She projected an aura of unshakeable poise, her speech characterized by exquisite subtlety and effortless conversational nuance.\n\n'
          '"Welcome to the Crucible of Nuance," Ambassadress Laurent began. "Amateurs believe that power in communication comes from aggressive, unyielding volume. But in the highest corridors of statecraft, crude aggression is regarded as weakness. True power lies in Conversational Register—the art of calibrating your tone with microscopic precision."',

          // PAGE 2: The Art of the Diplomatic Softener (Page 2 of 3)
          'PAGE 2: THE ANATOMY OF CIRCUMSPECT SOFTENERS\n\n'
          'Claudette summoned two students to enact a high-stakes bilateral treaty conflict. The first student blurted out: \'Your quota proposal is unacceptable, and we reject it entirely!\' The room fell tense; the simulation immediately derailed into defensive hostility.\n\n'
          'Claudette stepped forward. \'Notice how that blunt phrasing created an instant psychological bunker,\' she noted. \'Now observe how a master diplomat conveys the exact same refusal while safeguarding bilateral rapport:\n\n'
          '\'"I certainly appreciate the economic imperatives that informed your delegation\'s perspective. However, circumspect though we must be regarding fiscal constraints, would it be deemed feasible to explore an alternative phased timeline? I would be inclined to suggest that a staggered implementation might accommodate both our treasuries."\'\n\n'
          'Daniel marvelled at the transformation: the refusal was absolute, yet the tone was so cordially refined that the counterpart felt respected rather than defeated.',

          // PAGE 3: The Golden Seal of Gate 2 Midpoint (Page 3 of 3)
          'PAGE 3: THE CRUCIBLE PASSED & SOVEREIGN REGISTER\n\n'
          'Claudette then turned to Daniel for the final examination. She assigned him the role of chief mediator in a fierce industrial intellectual property conflict between rival multinational conglomerates.\n\n'
          'Daniel felt the eyes of the entire cohort upon him. Gone was the hesitation of his village porch; gone was the impulse to rush into angry Malayalam translation. He centered his diaphragm, maintained warm eye contact, and spoke with calm, circumspect authority:\n\n'
          '"Distinguished colleagues, while we fully acknowledge the validity of your patent claims, might we perhaps consider an equitable cross-licensing framework? We are inclined to believe that mutual conciliation today will safeguard the long-term prosperity of both enterprises."\n\n'
          'Ambassadress Laurent beamed with delight. She presented Daniel with the Golden Seal of Diplomatic Eloquence. Daniel had conquered Day 15—the vital midpoint of Gate 2—standing tall as an enlightened, sovereign communicator.',
        ];
      case 16:
        return const [
          // PAGE 1: The Cascading Blackout of the Meridian Grid (Page 1 of 3)
          'PAGE 1: THE MELTDOWN OF THE MERIDIAN POWER GRID\n\n'
          'At precisely two in the morning, an ominous shrill alarm reverberated through the nerve center of the Meridian Regional Grid Corporation. Within ninety seconds, secondary substations across twelve industrial provinces tripped in a blind cascading blackout. Forty million citizens, international transit hubs, and neonatal hospital units were plunged into freezing darkness.\n\n'
          'Inside the emergency executive war room, chaos threatened to overwhelm operational protocol. Senior directors shouted over one another, pointing fingers and spinning wild accusations. "It is an offshore cyber-terrorist assault!" screamed the chief security officer. "No, our core cloud servers have been hacked by an insider!" yelled the systems architect.\n\n'
          'The shouting grew deafening. Minutes were evaporating, and the backup diesel turbines at regional medical centers were already registering critical fuel consumption.',

          // PAGE 2: The Saliency Filter & Cleft Precision (Page 2 of 3)
          'PAGE 2: THE ANATOMY OF LASER FOCUS & CLEFT SYNTAX\n\n'
          'Dr. Maya Vance, the Chief Grid Architect who had mastered classical oratorical syntax, strode to the center console and muted the shouting screens with a single command. She did not argue or raise her pitch; she deployed the laser saliency of Cleft Sentences to pierce the fog of hysteria:\n\n'
          '"Gentlemen, silence," Maya commanded with sovereign gravitas. "It was NOT a foreign cyber-attack that severed our transformers, nor was it malicious insider sabotage. It was a physical cascade failure in the liquid nitrogen cooling manifold at Substation Nine.\n\n'
          'What we must immediately execute is not a firewall purge, but an offline manual reboot of the eastern hydroelectric bypass loop. What matters at this moment is not attributing bureaucratic blame, but restoring power to our intensive care wards within thirty minutes."',

          // PAGE 3: The Restored Grid & The Paradox of Focus (Page 3 of 3)
          'PAGE 3: THE GRID RESTORED & THE PARADOX OF THE CITADEL\n\n'
          'The room fell pin-drop silent. Maya\'s cleft structures had stripped away all tangential panic, isolating the singular truth that demanded action. Energized by her absolute clarity, the dispatch engineers locked onto the Substation Nine bypass.\n\n'
          'At 2:42 AM, the hydroelectric turbines spun to life. High-voltage lines re-energized across twelve provinces. One by one, city skylines flared back into golden brilliance. Hospital monitors stabilized, transit networks reconnected, and the catastrophe was averted.\n\n'
          'Watching the debriefing in his study, Daniel underlined Maya\'s words in his notebook: "It is a strange paradox that when a crisis is most complex, simple sentences fail, but cleft sentences slice through ambiguity like a laser. Master the cleft, and you command the crisis."',
        ];
      case 17:
        return const [
          // PAGE 1: The Grand Tribunal of the Palais de Justice (Page 1 of 3)
          'PAGE 1: THE CONSTITUTIONAL TRIBUNAL & THE VEIL OF OBFUSCATION\n\n'
          'Before the seven presiding magistrates of the Grand Constitutional Tribunal in Geneva, an epochal trial was entering its final afternoon. The defendant was an omnipotent global technology monopoly accused of illegally intercepting personal biometric communications across ninety sovereign nations.\n\n'
          'For five grueling days, the corporation\'s battery of elite defense lawyers had inundated the tribunal with five thousand pages of technical jargon, statistical subterfuge, and deliberate legal obfuscation. They spoke in convoluted, serpentine sentences designed to exhaust the bench and paralyze judicial action.\n\n'
          'The presiding chief magistrate rubbed his temples in fatigue. The monopoly\'s strategy of intellectual exhaustion seemed on the verge of succeeding.',

          // PAGE 2: Julian\'s Parallelism & Symmetrical Rectitude (Page 2 of 3)
          'PAGE 2: THE BASTION OF SYNTACTIC PARALLELISM\n\n'
          'Then, Advocate Julian stepped up to the mahogany dispatch box to deliver the people\'s closing summation. Julian understood that when an adversary relies on confusion, a master jurist fights back with the irresistible clarity of Syntactic Parallelism—the ancient Greek art of symmetrical grammatical balance:\n\n'
          '"May it please the court," Julian began, his voice ringing with melodic, rhythmic equanimity. "We stand before this august tribunal not to negotiate commercial convenience, but to defend constitutional liberty;\n\n'
          'Not to bow before digital monopolies, but to uphold the inviolable dignity of our citizens;\n\n'
          'Not to fear technological progress, but to subordinate that progress to moral law. In their obfuscation, they offered us data without truth; in their agreements, they demanded submission without consent; and in their governance, they substituted greed for rectitude."',

          // PAGE 3: The Inviolable Verdict of the Empyrean Bench (Page 3 of 3)
          'PAGE 3: THE TRIUMPH OF EQUANIMITY & RECTITUDE\n\n'
          'The symmetrical cadence was devastating. Every balanced antithesis exposed the monopoly\'s hollow greed. The contrast between corporate deceit and human rights was rendered crystalline and unforgettable.\n\n'
          'The seven magistrates needed merely forty-five minutes of deliberation. The Chief Justice returned to the bench and read the unanimous, historic verdict: the monopoly was found guilty on every count, subjected to record punitive sanctions, and ordered to dismantle its surveillance apparatus.\n\n'
          'Daniel felt goosebumps as he studied Julian\'s speech. "Master George," Daniel reflected, "Julian\'s sentences possessed the balance of a cathedral!"\n\n'
          '"Precisely, Daniel," George smiled warmly. "Parallelism is the architecture of truth. When your grammar balances perfectly, your arguments become unshakeable bastions of rectitude."',
        ];
      case 18:
        return const [
          // PAGE 1: The Gathering at the Grand Empyrean Hall (Page 1 of 3)
          'PAGE 1: THE SUMMIT OF THE GRAND EMPYREAN\n\n'
          'At the summit of Mount Verità in Switzerland, overlooking the mirror-like waters of Lake Maggiore, stood the Grand Empyrean Hall. Today marked the graduation symposium of Gate 2—eighteen unbroken days of linguistic immersion, phonetic recalibration, and philosophical syntax.\n\n'
          'Two hundred delegates from twenty nations sat in the amphitheater. Eighteen days earlier, Daniel had arrived as a shy, hesitant village youth who could barely construct a single sentence without drowning in Malayalam translation. Today, he wore the black and gold sash of an advanced orator.\n\n'
          'The dean of the academy tapped the crystal chime. "We invite Delegate Daniel to deliver the valedictory address on the Sovereign Dialectic of Mastery."',

          // PAGE 2: The Sovereign Dialectic Synthesis (Page 2 of 3)
          'PAGE 2: THE SOVEREIGN DIALECTIC & THE TIME-BRIDGE\n\n'
          'Daniel walked to the center of the empyrean rostrum. His posture was upright, his breathing calm and diaphragmatic, his eyes sparkling with quiet certainty. He did not read from notes; he spoke directly from an integrated mind, deploying the crowning jewel of the English language—the Sovereign Dialectic Synthesis:\n\n'
          '"Esteemed scholars and visionary mentors," Daniel proclaimed, his voice filling every corner of the amphitheater with resonant warmth. "If our predecessors had not braved ridicule and failure in their youth, our civilization would not possess the sovereign institutions we cherish today.\n\n'
          'And by that same inviolable law: if we had not committed eighteen days ago to conquering our doubts, practicing every morning before sunrise, and transforming our inner thoughts, we would not stand in this Grand Empyrean today as masters of global communication.\n\n'
          'What began as a trembling seed of hesitation has culminated in an unassailable fortress of fluency. We have crossed Gate One; we have conquered Gate Two; and now, we stand poised to command the global arena with courage, empathy, and honor."',

          // PAGE 3: The Platinum Seal & Gate 2 Culmination (Page 3 of 3)
          'PAGE 3: THE PLATINUM CROWN OF SOVEREIGN MASTERY\n\n'
          'As Daniel finished his address, the two hundred international delegates rose to their feet in thunderous, prolonged acclamation. Master George stood in the front row, his eyes glistening with proud tears.\n\n'
          'The dean stepped forward and pinned the Platinum Seal of Gate 2 Culmination onto Daniel\'s chest. Daniel had completed eighteen legendary days of transformation.\n\n'
          'He looked out through the grand arched glass windows at the snow-capped Alps. His roots were no longer merely deep; they were anchored into bedrock. He was ready to step across the threshold into Gate 3—the realm of workplace dominance, high-stakes negotiation, and world-shaping leadership.',
        ];
      default:
        return [
          'PAGE 1: THE DISCIPLINE OF DAY $day\n\n'
          'As Daniel entered Day $day of his 90-day English mastery journey, the lessons of Master George began to weave themselves seamlessly into his everyday thoughts. He no longer hesitated before forming sentences; the words began to assemble themselves with natural cadence.\n\n'
          '"Consistency," George reminded him as they reviewed the day\'s linguistic strategy, "is the single differentiator between those who merely dream in a language and those who command it in the global arena. When you practice every day without skipping, you build an unassailable fortress of fluency."',

          'PAGE 2: THE EXPANSION OF VOCAL ARTICULATION\n\n'
          'On this stage of the journey, Daniel focused on active vocal expansion. Reading with the eyes is merely passive recognition; reading aloud with resonant projection trains the physical mouth muscles to produce native English phonemes with crisp clarity.\n\n'
          'He read through the paragraph deliberately, pausing at commas, lowering his pitch at full stops, and emphasizing the key thematic nouns. His confidence surged with every sentence uttered.',

          'PAGE 3: THE DAY $day OATH OF EXCELLENCE\n\n'
          'Daniel stood tall, closed his book, and summarized the core insights of Day $day in three complete, polished English sentences.\n\n'
          '"I commit to ninety unbroken days of focused practice. I embrace challenges as stepping stones to greatness. My English voice grows sharper, richer, and more authentic each passing hour."',
        ];
    }
  }

  static String getStoryText(int day) {
    final pages = getStoryPages(day);
    if (pages.isEmpty) return '';
    return pages.join('\n\n---\n\n');
  }

  static String getStoryFormatted(int day) {
    final pages = getStoryPages(day);
    if (pages.isEmpty) return '';
    return pages.join('\n\n');
  }

  static String getStoryTitle(int day) {
    switch (day) {
      case 1:
        return 'DAY 1: THE BAMBOO LAW & SOVEREIGN ROOTS';
      case 2:
        return 'DAY 2: THE MORNING RITUAL OF CHAMPIONS';
      case 3:
        return 'DAY 3: THE ARCHITECT OF DEEP CONCENTRATION';
      case 4:
        return 'DAY 4: THE DIPLOMAT\'S ART OF PERSUASION';
      case 5:
        return 'DAY 5: THE BEACON IN THE STORM';
      case 6:
        return 'DAY 6: THE SUMMIT OF RESOLUTION';
      case 7:
        return 'DAY 7: THE RHETORICAL RESONANCE OF TRUTH';
      case 8:
        return 'DAY 8: THE GENEVA ETHICAL SYNTHESIS';
      case 9:
        return 'DAY 9: THE CRUCIBLE OF NUANCE & AMBIGUITY';
      case 10:
        return 'DAY 10: THE ARCHITECTURE OF CONSENSUS';
      case 11:
        return 'DAY 11: THE ODYSSEY OF REINVENTION';
      case 12:
        return 'DAY 12: THE DIALECTIC OF CONTRADICTION';
      case 13:
        return 'DAY 13: THE ALCHEMY OF INTELLECT';
      case 14:
        return 'DAY 14: THE CITADEL OF RHETORIC';
      case 15:
        return 'DAY 15: THE CRUCIBLE OF NUANCE';
      case 16:
        return 'DAY 16: THE SALIENCY FILTER & CLEFT FOCUS';
      case 17:
        return 'DAY 17: THE CONSTITUTIONAL TRIBUNAL & PARALLELISM';
      case 18:
        return 'DAY 18: THE SUMMIT OF THE GRAND EMPYREAN';
      default:
        return 'DAY $day: SOVEREIGN MASTERY';
    }
  }

  static String getStorySubtitle(int day) {
    switch (day) {
      case 1:
        return 'Foundational Mindset, Alphabet Sound System & 3-Page Deep Immersion';
      case 2:
        return 'Morning Habits, Present Simple Routine & Active Tongue Drills';
      case 3:
        return 'Eliminating Distractions & Building Unbroken Study Stamina';
      case 4:
        return 'Polite Diplomatic Requests, Modal Verbs & Counter-Arguments';
      case 5:
        return 'Decisive Crisis Leadership, Unwavering Fortitude & Action Commands';
      case 6:
        return 'High-Stakes Negotiation, Counterfactual Reframing & The Alveron Accord';
      case 7:
        return 'Public Oratory, Dynamic Rhetorical Inversion & The Lysander Forum';
      case 8:
        return 'Global Diplomacy, The Subjunctive Mandate & Future Ethics Synthesis';
      case 9:
        return 'Socratic Nuance, Cleft Sentence Laser Focus & Dismantling Sophistry';
      case 10:
        return 'Executive Statesmanship, Mixed Conditional Synthesis & 10-Day Milestone';
      case 11:
        return 'Linguistic Virtuosity, Polysyllabic Morphology & Cognitive Evolution';
      case 12:
        return 'Subjunctive Precision, Concessive Dissection & Dismantling Sophistry';
      case 13:
        return 'Forensic Modality, Epistemic Hedging & Scientific Empiricism';
      case 14:
        return 'Rhetorical Fronting, Tricolon Cadence & Multilateral Accords';
      case 15:
        return 'Conversational Register, Diplomatic Softeners & Sovereign Poise';
      case 16:
        return 'It-Cleft & Wh-Cleft Laser Saliency, Crisis Communication & Meridian Grid Defense';
      case 17:
        return 'Syntactic Parallelism, Balanced Cadence & High Constitutional Advocacy';
      case 18:
        return 'Sovereign Dialectic Synthesis, Gate 2 Graduation & Platinum Mastery';
      default:
        return 'Daily Sovereign English Progression';
    }
  }

  static String getStoryIcon(int day) {
    switch (day) {
      case 1:
        return '🎋';
      case 2:
        return '🌅';
      case 3:
        return '🏛️';
      case 4:
        return '🤝';
      case 5:
        return '⚓';
      case 6:
        return '🏔️';
      case 7:
        return '⚡';
      case 8:
        return '🌐';
      case 9:
        return '🔬';
      case 10:
        return '👑';
      case 11:
        return '🌌';
      case 12:
        return '⚖️';
      case 13:
        return '🔬';
      case 14:
        return '🏛️';
      case 15:
        return '💎';
      case 16:
        return '⚡';
      case 17:
        return '🏛️';
      case 18:
        return '👑';
      default:
        return '🌟';
    }
  }

  static String getStoryQuotePreview(int day) {
    switch (day) {
      case 1:
        return '"Your daily English practice is the bamboo seed. For years roots grow in silence underground; then in 90 days, your fluency shoots ninety feet into the heavens."';
      case 2:
        return '"We do not decide our future. We decide our daily habits, and our habits decide our future. Dedicate the very first sixty minutes of your sunrise to what you wish to master."';
      case 3:
        return '"Without silence and deep focus, monumental beauty cannot be constructed. Shallow multitasking is worthless, but sustained immersion builds unstoppable fluency."';
      case 4:
        return '"Persuasion is not a battlefield of loud voices; it is a bridge built of diplomatic precision, careful listening, and eloquent concession."';
      case 5:
        return '"A ship is safe in harbor, but that is not what ships are built for. Decisive communication turns adversity into triumph."';
      case 6:
        return '"When the stakes are highest, articulate negotiation and counterfactual clarity turn bitter deadlocks into enduring partnerships."';
      case 7:
        return '"Rarely do we encounter moments where tradition and progress must unite. Sophisticated rhetoric marries truth with unyielding courage."';
      case 8:
        return '"It is imperative that our generation synthesize technological velocity with timeless ethical wisdom."';
      case 9:
        return '"What separates enduring communicators is their capacity to embrace nuance and dismantle deceptive fallacies with Socratic clarity."';
      case 10:
        return '"If our predecessors had not planted the seeds of unity, we would not enjoy our sovereign freedom today. Day 10 sets the golden milestone of fluency."';
      case 11:
        return '"Language is not a mere mirror of reality; it is the chisel that carves the shape of human thought. Elevate your vocabulary, and your destiny metamorphoses."';
      case 12:
        return '"Granted that blustering theatrics dazzle the crowd for a moment, yet calm dialectic perspicacity stands impervious through the centuries."';
      case 13:
        return '"Empirical data does not fear skeptical scrutiny. Epistemic humility combined with forensic rigor turns impossible anomalies into universal paradigms."';
      case 14:
        return '"When ninety sovereign nations stand divided, it is not brute force that unites them; it is the triadic symmetry of transcendent rhetoric."';
      case 15:
        return '"In the highest halls of power, crude bluntness is weakness. Mastery of conversational register allows you to speak the hardest truths with impenetrable grace."';
      case 16:
        return '"In an era of endless digital chatter, what distinguishes a master communicator is not the volume of words, but the precision of the focus beam."';
      case 17:
        return '"Parallelism is the architecture of truth. When your grammar balances with mathematical symmetry, your arguments become unshakeable bastions of justice."';
      case 18:
        return '"What began as a trembling seed of hesitation has culminated in an unassailable fortress of fluency. Eighteen unbroken days crown Gate Two with sovereign glory."';
      default:
        return '"Mastery does not require giant leaps, only unbroken daily rituals."';
    }
  }

  // --- 📐 DEDICATED SENTENCE PATTERN DRILLS (Interactive Substitution Formulas) ---
  static List<SentencePatternItem> getSentencePatterns(int day) {
    switch (day) {
      case 1:
        return const [
          SentencePatternItem(
            formula: 'Subject + am/is/are + ready to + [Base Verb]',
            explanation: 'തയ്യാറാണ് എന്ന് ആത്മവിശ്വാസത്തോടെ പറയാൻ ഉപയോഗിക്കുന്ന ഏറ്റവും ശക്തമായ പാറ്റേൺ.',
            masterSentences: [
              'I am ready to learn English.',
              'She is ready to speak boldly.',
              'We are ready to conquer Day 1.',
              'They are ready to practice now.',
            ],
            subjects: ['I', 'He', 'She', 'We', 'They'],
            verbs: ['learn English', 'speak boldly', 'conquer Day 1', 'start the journey', 'practice now'],
            objects: ['with confidence', 'today', 'fearlessly', 'every morning'],
          ),
          SentencePatternItem(
            formula: 'I want to + [Base Verb] + because + [Reason]',
            explanation: 'വെറുതെ ആഗ്രഹം പറയുകയല്ല, അതിൻ്റെ ഉദ്ദേശം വ്യക്തമാക്കി സംസാരിക്കുന്ന രീതി.',
            masterSentences: [
              'I want to speak English because it opens global doors.',
              'I want to read books because it builds rich vocabulary.',
              'I want to practice daily because consistency builds fluency.',
            ],
            subjects: ['I want to', 'He wants to', 'She wants to', 'We want to'],
            verbs: ['speak English', 'read books', 'listen carefully', 'practice daily'],
            objects: ['because it opens global doors', 'because it builds confidence', 'because consistency creates mastery'],
          ),
          SentencePatternItem(
            formula: 'Could you please + [Base Verb] + [Object]?',
            explanation: 'ഏതൊരു കാര്യവും വളരെ മാന്യമായി (Polite Request) ചോദിക്കാൻ ഉപയോഗിക്കുന്ന ഗോൾഡൻ ഫോർമുല.',
            masterSentences: [
              'Could you please help me with this word?',
              'Could you please repeat that sentence?',
              'Could you please speak a little slower?',
            ],
            subjects: ['Could you please'],
            verbs: ['help me with', 'repeat', 'explain', 'listen to'],
            objects: ['this sentence', 'that lesson', 'the pronunciation', 'my practice'],
          ),
        ];
      case 6:
        return const [
          SentencePatternItem(
            formula: 'If + [Subject] + had + [V3], [Subject] + would have + [V3]',
            explanation: 'കഴിഞ്ഞുപോയ കാര്യത്തെക്കുറിച്ച് അനുതപിക്കാനും വിശകലനം ചെയ്യാനുമുള്ള തേർഡ് കണ്ടീഷണൽ ഫോർമുല.',
            masterSentences: [
              'If we had verified the contract terms, we would have averted the dispute.',
              'If they had communicated earlier, both syndicates would have compromised.',
              'If I had reviewed the notes, I would have answered flawlessly.',
            ],
            subjects: ['If we', 'If they', 'If the envoy', 'If I'],
            verbs: ['had verified the terms', 'had arrived earlier', 'had listened carefully', 'had reviewed the data'],
            objects: ['we would have averted the dispute', 'we would have signed today', 'peace would have prevailed'],
          ),
          SentencePatternItem(
            formula: 'Had we + [V3], we would have + [V3] (Inverted Formal)',
            explanation: 'IF ഒഴിവാക്കി നയതന്ത്ര സംഭാഷണങ്ങളിൽ ഉപയോഗിക്കുന്ന ഉയർന്ന ഇംഗ്ലീഷ് ഫോർമുല.',
            masterSentences: [
              'Had we established the committee, trade would not have halted.',
              'Had they accepted the compromise, negotiations would have succeeded.',
              'Had she attended the meeting, the agreement would have been finalized.',
            ],
            subjects: ['Had we', 'Had they', 'Had the council'],
            verbs: ['established the committee', 'accepted the compromise', 'intervened sooner', 'structured the tariffs'],
            objects: ['trade would not have halted', 'prosperity would have followed', 'consensus would have been achieved'],
          ),
          SentencePatternItem(
            formula: 'We could have + [V3] if you had + [V3]',
            explanation: 'വിട്ടുവീഴ്ചകളെയും സാധ്യതകളെയും കുറിച്ച് സംസാരിക്കാനുള്ള ഫോർമുല.',
            masterSentences: [
              'We could have completed the project if you had shared the files.',
              'They could have resolved the conflict if both sides had shown equanimity.',
            ],
            subjects: ['We could have', 'They could have'],
            verbs: ['resolved the conflict', 'achieved consensus', 'finalized the accord'],
            objects: ['if you had shown patience', 'if terms had been clarified', 'if respect had been maintained'],
          ),
        ];
      case 7:
        return const [
          SentencePatternItem(
            formula: 'Rarely / Seldom + do/does/did + [Subject] + [Base Verb]',
            explanation: 'ശ്രോതാക്കളെ വിസ്മയിപ്പിക്കുന്ന റെസ്ട്രിക്റ്റീവ് ഇൻവേർഷൻ പവർ ഫോർമുല.',
            masterSentences: [
              'Rarely do we encounter scholars of such profound courage.',
              'Seldom does an audience witness such persuasive eloquence.',
              'Rarely did the council see such unanimous agreement.',
            ],
            subjects: ['Rarely do we', 'Seldom does he', 'Rarely did they', 'Seldom do leaders'],
            verbs: ['encounter such courage', 'witness such eloquence', 'witness such unity', 'discover such clarity'],
            objects: ['in modern history', 'during public debate', 'across the academic world', 'under pressure'],
          ),
          SentencePatternItem(
            formula: 'Not only + did/does + [Subject] + [Verb], but also + [Clause]',
            explanation: 'ഒരു കാര്യത്തിന് മുകളിൽ മറ്റൊരു കാര്യം ചേർത്ത് ശക്തിപ്പെടുത്തുന്ന റെട്ടോറിക്കൽ ശൈലി.',
            masterSentences: [
              'Not only did she defend her theorem, but she also inspired the entire assembly.',
              'Not only did they resolve the crisis, but they also established lasting peace.',
            ],
            subjects: ['Not only did she', 'Not only did our team', 'Not only does he'],
            verbs: ['defend her theorem', 'conquer hesitation', 'achieve fluency', 'present the data'],
            objects: ['but she also inspired all', 'but it also broke records', 'but he also won the award'],
          ),
          SentencePatternItem(
            formula: 'Under no circumstances + will/can + [Subject] + [Base Verb]',
            explanation: 'ഉറച്ച നിലപാടുകൾ പ്രഖ്യാപിക്കാൻ ഉപയോഗിക്കുന്ന വിട്ടുവീഴ്ചയില്ലാത്ത എക്സിക്യൂട്ടീവ് ശൈലി.',
            masterSentences: [
              'Under no circumstances will we compromise our research integrity.',
              'Under no circumstances can we accept ambiguous agreements.',
            ],
            subjects: ['Under no circumstances will we', 'Under no circumstances can they'],
            verbs: ['compromise our integrity', 'accept ambiguous terms', 'surrender our principles'],
            objects: ['during negotiations', 'before the public forum', 'for short-term gains'],
          ),
        ];
      case 8:
        return const [
          SentencePatternItem(
            formula: 'It is imperative / crucial that + [Subject] + [Base Verb (V1)]',
            explanation: 'ഔദ്യോഗിക നയതന്ത്രത്തിലും ഉത്തരവുകളിലും ഉപയോഗിക്കുന്ന സബ്ജങ്ക്ടീവ് മൂഡ് പാറ്റേൺ.',
            masterSentences: [
              'It is imperative that every delegate submit their proposal before dusk.',
              'It is crucial that the ambassador remain impartial throughout the summit.',
              'It is essential that no nation be excluded from the treaty.',
            ],
            subjects: ['It is imperative that', 'It is crucial that', 'It is vital that', 'It is essential that'],
            verbs: ['the envoy attend', 'the team remain united', 'the data be verified', 'he participate'],
            objects: ['without delay', 'in all discussions', 'under international law', 'for common prosperity'],
          ),
          SentencePatternItem(
            formula: 'The council insists / demands that + [Subject] + [Base Verb]',
            explanation: 'ഒരു സംഘടനയോ സമിതിയോ കർശനമായി ആവശ്യപ്പെടുമ്പോൾ ഉപയോഗിക്കുന്ന സബ്ജങ്ക്ടീവ് പാറ്റേൺ.',
            masterSentences: [
              'The council demands that all members adhere to the code of conduct.',
              'The director insists that every participant speak in English.',
            ],
            subjects: ['The council demands that', 'The committee recommends that', 'The director insists that'],
            verbs: ['all members adhere to', 'he present the findings', 'she lead the delegation'],
            objects: ['the ethical guidelines', 'the sovereign charter', 'the international standard'],
          ),
          SentencePatternItem(
            formula: 'Be that as it may, we must + [Base Verb]',
            explanation: 'എതിർവാദങ്ങളെ തള്ളിക്കളയാതെ അടുത്ത നടപടിയിലേക്ക് വിവേകത്തോടെ കടക്കുന്ന നയതന്ത്ര ബ്രിഡ്ജ്.',
            masterSentences: [
              'Be that as it may, we must protect human dignity above all.',
              'Be that as it may, we must proceed with constructive dialogue.',
            ],
            subjects: ['Be that as it may, we must', 'Be that as it may, the leaders must'],
            verbs: ['protect human dignity', 'proceed with dialogue', 'find common ground'],
            objects: ['above economic speed', 'without mutual malice', 'for the next generation'],
          ),
        ];
      case 9:
        return const [
          SentencePatternItem(
            formula: 'What we need / seek is + [The Core Element]',
            explanation: 'ഒരു പ്രസംഗത്തിൽ പ്രധാനം എന്താണെന്ന് ശ്രോതാക്കളുടെ ശ്രദ്ധയിലേക്ക് തിരിച്ചുവിടുന്ന Cleft പാറ്റേൺ.',
            masterSentences: [
              'What we truly seek is empirical clarity and mutual trust.',
              'What separates great leaders is their empathetic listening.',
              'What our generation demands is principled reform.',
            ],
            subjects: ['What we need is', 'What I admire most is', 'What truly matters is'],
            verbs: ['empirical clarity', 'empathetic listening', 'principled reform', 'unbroken discipline'],
            objects: ['in modern discourse', 'above superficial noise', 'in every global interaction'],
          ),
          SentencePatternItem(
            formula: 'It was not + [X], but + [Y] that + [Result]',
            explanation: 'തെറ്റായ ധാരണകളെ തിരുത്തി ശരിയായ കാരണം സ്ഥാപിക്കുന്ന ക്ലാസിക്കൽ It-Cleft ഫോർമുല.',
            masterSentences: [
              'It was not lack of resources, but lack of focus that caused the delay.',
              'It was not luck, but relentless perseverance that created this breakthrough.',
            ],
            subjects: ['It was not', 'It was certainly not'],
            verbs: ['lack of resources but lack of focus', 'the complexity but the hesitation'],
            objects: ['that caused the delay', 'that hindered our progress', 'that decided the debate'],
          ),
          SentencePatternItem(
            formula: 'The primary reason why + [Clause] + is that + [Fact]',
            explanation: 'വാദമുഖങ്ങൾ വളരെ ചിട്ടയായി യുക്തിസഹമായി സമർപ്പിക്കാനുള്ള സ്ട്രക്ചർഡ് ഫോർമുല.',
            masterSentences: [
              'The primary reason why our model succeeds is that it respects nuance.',
              'The real reason why daily immersion works is that it rewires neural pathways.',
            ],
            subjects: ['The primary reason why', 'The underlying reason why'],
            verbs: ['this initiative succeeds', 'fluency accelerates', 'confidence grows'],
            objects: ['is that it respects nuance', 'is that it eliminates hesitation', 'is that it anchors daily roots'],
          ),
        ];
      case 10:
        return const [
          SentencePatternItem(
            formula: 'If + [Subject] + had + [V3 (Past)], [Subject] + would + [V1 (Present)]',
            explanation: 'കഴിഞ്ഞ കാലത്തെ ഒരു തീരുമാനം ഇന്നത്തെ നേട്ടത്തിന് കാരണമായി എന്ന് പ്രഖ്യാപിക്കുന്ന മിക്സഡ് കണ്ടീഷണൽ.',
            masterSentences: [
              'If we had not persevered through adversity, we would not be sovereign leaders today.',
              'If our founders had not signed the charter, we would not enjoy this liberty today.',
              'If I had not practiced for ten days, I would not speak with this poise today.',
            ],
            subjects: ['If we had not persevered', 'If our founders had not signed', 'If she had not studied'],
            verbs: ['we would not be confident today', 'we would not enjoy peace today', 'she would not lead operations today'],
            objects: ['in the international arena', 'across all global platforms', 'before this esteemed assembly'],
          ),
          SentencePatternItem(
            formula: 'Were it not for + [Noun], we would + [V1 (Present)]',
            explanation: 'ഒരു കാര്യത്തിന്റെ പരമപ്രധാന പങ്കിനെ നന്ദിയോടെയും ഗൗരവത്തോടെയും ഓർമ്മിപ്പിക്കുന്ന എക്സിക്യൂട്ടീവ് ശൈലി.',
            masterSentences: [
              'Were it not for your dedication, our team would not achieve this milestone.',
              'Were it not for daily immersion, English would remain a barrier.',
            ],
            subjects: ['Were it not for', 'Were it not for your'],
            verbs: ['unwavering dedication', 'daily immersion', 'courageous vision'],
            objects: ['we would not achieve this milestone', 'English would remain a barrier', 'success would be impossible'],
          ),
          SentencePatternItem(
            formula: 'Now that we have + [V3], we are poised to + [V1]',
            explanation: 'നേടിയെടുത്ത വിജയത്തിന്റെ അടിത്തറയിൽ നിന്ന് ഭാവിയിലേക്ക് കുതിച്ചുയരാൻ ഉപയോഗിക്കുന്ന ഫോർമുല.',
            masterSentences: [
              'Now that we have conquered Gate 1, we are poised to attain sovereign fluency.',
              'Now that the treaty is signed, we are poised to cultivate generational prosperity.',
            ],
            subjects: ['Now that we have conquered Gate 1, we are poised to', 'Now that consensus is reached, we are poised to'],
            verbs: ['attain sovereign fluency', 'expand our horizons', 'lead global dialogues'],
            objects: ['with unshakable confidence', 'throughout the next eighty days', 'across every continent'],
          ),
        ];
      case 11:
        return const [
          SentencePatternItem(
            formula: 'Having + [V3 (Past Participle)], [Subject] + [Main Clause]',
            explanation: 'രണ്ട് വാക്യങ്ങളെ ഒരൊറ്റ ഉന്നത അക്കാദമിക് വാക്യമായി സംയോജിപ്പിക്കുന്ന പാർട്ടിസിപ്പിയൽ ക്ലോസ് (Participial Clause).',
            masterSentences: [
              'Having conquered Gate 1, Daniel embarked upon the path of linguistic virtuosity.',
              'Having mastered the foundational patterns, we speak without mental hesitation.',
              'Having recognized our inner potential, we pursue excellence relentlessly.',
            ],
            subjects: ['Having conquered Gate 1, Daniel', 'Having reviewed the classical manuscripts, the scholars', 'Having rooted our habits, we'],
            verbs: ['embarked upon the path of virtuosity', 'unlocked unprecedented clarity', 'spearheaded the cognitive evolution'],
            objects: ['with quiet confidence', 'across every academic discipline', 'throughout the remaining journey'],
          ),
          SentencePatternItem(
            formula: 'It is not merely that [Clause A], but rather that [Clause B]',
            explanation: 'സാധാരണ നിരീക്ഷണത്തിനപ്പുറം വിഷയത്തിന്റെ ആഴത്തിലുള്ള കാതലായ സത്യം വ്യക്തമാക്കുന്ന ശൈലി.',
            masterSentences: [
              'It is not merely that vocabulary expands our knowledge, but rather that it metamorphoses our thoughts.',
              'It is not merely that we learn words, but rather that we command our reality.',
            ],
            subjects: ['It is not merely that practice builds speed,', 'It is not merely that education provides information,'],
            verbs: ['but rather that it rewires cognitive perception', 'but rather that it cultivates sovereign wisdom', 'but rather that it breaks inner fear'],
            objects: ['in every conversation', 'before international audiences', 'for generations to come'],
          ),
          SentencePatternItem(
            formula: 'Only through + [Noun/Gerund] can [Subject] + [V1 Base Verb]',
            explanation: 'ഒരു കാര്യത്തിന്റെ സമ്പൂർണ്ണ പ്രാധാന്യത്തെ ഉറപ്പിച്ചു പറയാൻ സഹായിക്കുന്ന ഇൻവേർഷൻ ഫോർമുല.',
            masterSentences: [
              'Only through inexorable perseverance can a scholar transcend conversational barriers.',
              'Only through daily immersion can one achieve authentic natural cadence.',
            ],
            subjects: ['Only through inexorable perseverance can a learner', 'Only through rigorous immersion can our team'],
            verbs: ['transcend conversational barriers', 'master polysyllabic morphology', 'attain linguistic virtuosity'],
            objects: ['in global arenas', 'with effortless poise', 'without fear of error'],
          ),
        ];
      case 12:
        return const [
          SentencePatternItem(
            formula: 'Granted that [Opponent\'s Claim], yet we must not overlook [Counter-Fact]',
            explanation: 'എതിരാളിയുടെ വാദത്തെ തന്ത്രപരമായി സമ്മതിച്ചുകൊണ്ട് സ്വന്തം ഭാഗത്തെ അനിഷേധ്യമായ സത്യം സ്ഥാപിക്കുന്ന ശൈലി.',
            masterSentences: [
              'Granted that your proposal promises short-term speed, yet we must not overlook long-term stability.',
              'Granted that the market is volatile, yet we must not abandon our ethical compass.',
            ],
            subjects: ['Granted that your proposal offers immediate savings,', 'Granted that the motion sounds attractive,'],
            verbs: ['yet we cannot overlook the fallacious data', 'yet we must not compromise perspicacity', 'yet we cannot ignore constitutional principles'],
            objects: ['in this crucial assembly', 'under rigorous scrutiny', 'before making this concession'],
          ),
          SentencePatternItem(
            formula: 'However specious the argument may seem, [Subject] + [Verb]',
            explanation: 'തെറ്റായതോ വഞ്ചനാപരമായതോ ആയ വാദങ്ങളെ ശാന്തമായി തുറന്നുകാട്ടാൻ ഉപയോഗിക്കുന്ന ഫോർമുല.',
            masterSentences: [
              'However specious the opponent\'s argument may seem, our empirical evidence refutes it entirely.',
              'However alluring the rhetoric may sound, the fundamental premise remains fallacious.',
            ],
            subjects: ['However specious the claims appear,', 'However alluring the rhetoric sounds,'],
            verbs: ['our empirical data disproves them completely', 'perspicacity reveals the underlying fallacy', 'Rowan\'s rebuttal dismantles the premise'],
            objects: ['with surgical precision', 'before the entire Sorbonne hall', 'without raising his voice'],
          ),
          SentencePatternItem(
            formula: 'Be that as it may, our imperative remains to + [V1 Base Verb]',
            explanation: 'തർക്കങ്ങൾക്കിടയിലും പരമപ്രധാനമായ ലക്ഷ്യത്തിലേക്ക് ഏവരുടെയും ശ്രദ്ധ തിരിച്ചുകൊണ്ടുവരാൻ.',
            masterSentences: [
              'Be that as it may, our imperative remains to safeguard sovereign integrity.',
              'Be that as it may, our primary duty is to speak with unwavering transparency.',
            ],
            subjects: ['Be that as it may, our collective imperative remains to', 'Be that as it may, our primary obligation is to'],
            verbs: ['safeguard sovereign integrity', 'pursue principled consensus', 'dissect specious sophistry'],
            objects: ['across all diplomatic channels', 'with pragmatic equanimity', 'for the public good'],
          ),
        ];
      case 13:
        return const [
          SentencePatternItem(
            formula: 'The empirical data strongly suggests that [Clause]',
            explanation: 'ശാസ്ത്രീയമായ പക്വതയോടെ തെളിവുകൾ മുൻനിർത്തി സംസാരിക്കാനുള്ള ഫോറെൻസിക് ഫോർമുല.',
            masterSentences: [
              'The empirical data strongly suggests that daily immersion rewires neuroplasticity.',
              'Independent laboratory scans corroborate Dr. Elena\'s pioneering thesis.',
            ],
            subjects: ['The empirical findings strongly suggest that', 'Extensive double-blind trials corroborate that'],
            verbs: ['adult neuroplasticity remains robust', 'daily cognitive immersion accelerates fluency', 'the classical paradigm is incomplete'],
            objects: ['across all age demographics', 'under rigorous peer review', 'beyond any reasonable doubt'],
          ),
          SentencePatternItem(
            formula: 'Incongruous though the findings appear, they corroborate [Hypothesis]',
            explanation: 'ആദ്യ നോട്ടത്തിൽ വിചിത്രമായി തോന്നുന്ന കാര്യങ്ങൾ പോലും വലിയൊരു സത്യത്തിലേക്ക് വിരൽചൂണ്ടുന്നു എന്ന് പറയാൻ.',
            masterSentences: [
              'Incongruous though the initial readings appear, they corroborate our revolutionary paradigm.',
              'Challenging though this lesson feels, it anchors deep cognitive fluency.',
            ],
            subjects: ['Incongruous though the anomalies appear, they', 'Unorthodox though the method seems, it'],
            verbs: ['corroborates our central hypothesis', 'validates decades of patient research', 'illuminates previously hidden mechanisms'],
            objects: ['in modern neuroscience', 'within our linguistic matrix', 'across global clinical trials'],
          ),
          SentencePatternItem(
            formula: 'It can be reasonably inferred that [Subject] + [Verb]',
            explanation: 'അനാവശ്യമായ വീൺവാക്കുകൾ ഒഴിവാക്കി അളന്നുമുറിച്ച് നിഗമനങ്ങളിൽ എത്താനുള്ള അക്കാദമിക് ശൈലി.',
            masterSentences: [
              'It can be reasonably inferred that consistent practice yields unstoppable fluency.',
              'It can be reasonably inferred that the paradigm shift has already begun.',
            ],
            subjects: ['It can be reasonably inferred that', 'From these rigorous trials, it can be deduced that'],
            verbs: ['consistent immersion creates permanent mastery', 'skeptical scrutiny purifies scientific truth', 'empirical evidence outlasts dogmatic opinion'],
            objects: ['in every cognitive discipline', 'throughout the global academy', 'with unwavering certainty'],
          ),
        ];
      case 14:
        return const [
          SentencePatternItem(
            formula: 'Not only does this accord safeguard [Noun], but it also fosters [Noun], and ultimately secures [Noun]',
            explanation: 'പ്രസംഗത്തിൽ ശ്രോതാക്കളെ കോരിത്തരിപ്പിക്കുന്ന ത്രിത്വ താളം (Tricolon Cadence).',
            masterSentences: [
              'Not only does this treaty safeguard borders, but it fosters prosperity, and ultimately secures peace.',
              'Not only does English expand your career, but it enriches your mind, and ultimately unlocks your freedom.',
            ],
            subjects: ['Not only does this charter protect maritime commerce,', 'Not only does daily practice build confidence,'],
            verbs: ['but it also cultivates cross-cultural empathy', 'but it also refines conversational acumen', 'and above all it cements generational harmony'],
            objects: ['among ninety sovereign nations', 'across international boardrooms', 'for all who dare to speak'],
          ),
          SentencePatternItem(
            formula: 'Front and center stands our commitment to [Noun/Gerund]',
            explanation: 'പ്രധാന ആശയത്തെ തുടക്കത്തിൽ തന്നെ എടുത്തുപറയുന്ന റെറ്റോറിക്കൽ ഫ്രണ്ടിംഗ് (Rhetorical Fronting).',
            masterSentences: [
              'Front and center stands our commitment to unyielding integrity.',
              'Front and center before this assembly stands the fragile shared destiny of our oceans.',
            ],
            subjects: ['Front and center before this grand assembly stands', 'Front and center in our 90-day mission stands'],
            verbs: ['our commitment to transparent diplomacy', 'our dedication to sovereign English fluency', 'our pledge to break every impasse'],
            objects: ['without fear or hesitation', 'across every continent', 'with unstoppable momentum'],
          ),
          SentencePatternItem(
            formula: 'With great acumen comes concomitant responsibility to [Base Verb]',
            explanation: 'ഉന്നത പദവികൾക്കൊപ്പം വരുന്ന ഉത്തരവാദിത്തത്തെക്കുറിച്ച് ഗൗരവത്തോടെ ഓർമ്മിപ്പിക്കാൻ.',
            masterSentences: [
              'With great diplomatic acumen comes concomitant responsibility to govern with justice.',
              'With linguistic mastery comes concomitant responsibility to elevate those around us.',
            ],
            subjects: ['With executive influence comes concomitant responsibility to', 'With oratorical mastery comes concomitant duty to'],
            verbs: ['lead with unblemished integrity', 'unify recalcitrant factions', 'articulate truth with courage'],
            objects: ['in moments of national crisis', 'before global assemblies', 'for future generations'],
          ),
        ];
      case 15:
        return const [
          SentencePatternItem(
            formula: 'I would be inclined to suggest that we [V1 Base Verb]',
            explanation: 'തീരുമാനങ്ങൾ മറ്റുള്ളവർക്ക് മേൽ അടിച്ചേൽപ്പിക്കാതെ, മാന്യമായി നിർദ്ദേശിക്കുന്ന ഡിപ്ലോമാറ്റിക് ശൈലി.',
            masterSentences: [
              'I would be inclined to suggest that we review the draft clause before signing.',
              'I would be inclined to suggest that we explore an equitable cross-licensing model.',
            ],
            subjects: ['I would be inclined to suggest that we', 'Our delegation would be inclined to propose that we'],
            verbs: ['review the fourth stipulation carefully', 'adopt an agile phased implementation', 'convene a joint consultative committee'],
            objects: ['to preserve bilateral harmony', 'before finalizing the treaty', 'with mutual respect'],
          ),
          SentencePatternItem(
            formula: 'Would it be deemed feasible to + [V1 Base Verb]?',
            explanation: 'ആജ്ഞാപിക്കുന്നതിന് പകരം മറ്റുള്ളവരെക്കൂടി ഉൾപ്പെടുത്തി അതീവ വിനയത്തോടെ ചോദ്യം ഉന്നയിക്കാൻ.',
            masterSentences: [
              'Would it be deemed feasible to extend the consultation window by forty-eight hours?',
              'Would it be deemed feasible to modify the payment schedule to accommodate fiscal limits?',
            ],
            subjects: ['Would it be deemed feasible to', 'Under the current circumstances, would it be deemed prudent to'],
            verbs: ['extend the consultation timeline', 'recalibrate the seasonal quotas', 'solicit independent expert counsel'],
            objects: ['without disrupting global operations', 'to safeguard unanimous consensus', 'for all participating partners'],
          ),
          SentencePatternItem(
            formula: 'Circumspect though our colleagues may be, [Subject] + [Verb]',
            explanation: 'സൂക്ഷ്മതയും കരുതലുമുള്ള എതിർപ്പുകളെ ബഹുമാനത്തോടെ അഭിസംബോധന ചെയ്യാൻ.',
            masterSentences: [
              'Circumspect though our colleagues may be, our dedication to this partnership remains resolute.',
              'Nuanced though the text appears, the core principles are crystal clear.',
            ],
            subjects: ['Circumspect though the ministry may be,', 'Cautious though the delegates appear,'],
            verbs: ['their commitment to peace remains unwavering', 'our shared goodwill will bridge the divide', 'mutual conciliation will prevail'],
            objects: ['in the Diplomatic Academy of Vienna', 'across every negotiating table', 'with sovereign grace'],
          ),
        ];
      case 16:
        return const [
          SentencePatternItem(
            formula: 'It was not [A], but [B] that [Result]',
            explanation: 'ആരോപണങ്ങളെയും തെറ്റിദ്ധാരണകളെയും തിരുത്തി യഥാർത്ഥ സത്യത്തിലേക്ക് ലേസർ ഫോക്കസ് കൊണ്ടുവരാൻ (It-Cleft Contrast Focus).',
            masterSentences: [
              'It was not malicious negligence, but an unforeseen grid surge that triggered the blackout.',
              'It was not lack of capital, but a deficit of strategic vision that stalled the project.',
            ],
            subjects: ['It was not human incompetence,', 'It was not financial vulnerability,'],
            verbs: ['but an algorithmic latency spike that severed our telemetry', 'but an unwavering dedication to principle that saved the organization', 'but a sudden seismic shift in consumer demand that disrupted the market'],
            objects: ['at the Meridian central station', 'during the international audit', 'before global stakeholders'],
          ),
          SentencePatternItem(
            formula: 'What [Subject] urgently requires is not [A], but [B]',
            explanation: 'യഥാർത്ഥ മുൻഗണനയെ എടുത്തുപറഞ്ഞ് സദസ്സിന്റെ ശ്രദ്ധ തിരിക്കാൻ (Wh-Cleft Saliency Filter).',
            masterSentences: [
              'What this critical infrastructure urgently requires is not superficial patchworks, but a resilient redesign.',
              'What our global mission requires is not loud promises, but disciplined daily execution.',
            ],
            subjects: ['What this high-stakes negotiation urgently requires', 'What this sovereign enterprise demands'],
            verbs: ['is not reactive hysteria, but steadfast calm', 'is not political posturing, but verifiable transparency', 'is not temporary appeasement, but permanent structural reform'],
            objects: ['across all operational sectors', 'before the sovereign tribunal', 'for future generations'],
          ),
          SentencePatternItem(
            formula: 'Only by [Gerund] can [Subject] effectively [Base Verb]',
            explanation: 'കർശനമായ ഏക ഉപാധി മുന്നോട്ടുവെച്ച് ശക്തമായി സമർത്ഥിക്കാൻ (Conditional Focus Inversion).',
            masterSentences: [
              'Only by decoupling the power subgrids can our engineers prevent a catastrophic cascading failure.',
              'Only by dedicating sixty minutes every morning can you master sovereign English fluency.',
            ],
            subjects: ['Only by conducting exhaustive forensic audits', 'Only by isolating the corrupted data streams'],
            verbs: ['can the board restore institutional confidence', 'can the incident response team avert disaster', 'can we secure sovereign autonomy'],
            objects: ['in the Meridian regional power grid', 'under unprecedented public scrutiny', 'with absolute technical precision'],
          ),
        ];
      case 17:
        return const [
          SentencePatternItem(
            formula: 'Not to [V1 A], but to [V1 B]; not to [V1 C], but to [V1 D]',
            explanation: 'കോടതികളിലും ഉയർന്ന സദസ്സുകളിലും പ്രകമ്പനം കൊള്ളിക്കുന്ന ഉയർന്ന വാക്യഘടന (Syntactic Parallelism & Antithesis).',
            masterSentences: [
              'We stand here not to negotiate convenience, but to defend liberty; not to bow before monopolies, but to uphold dignity.',
              'We practice not to impress critics, but to conquer our minds; not to memorize words, but to master authentic thought.',
            ],
            subjects: ['Our legal delegation convenes', 'The sovereign tribunal deliberate'],
            verbs: ['not to compromise foundational statutes, but to champion constitutional justice', 'not to appease corporate lobbies, but to protect vulnerable citizens', 'not to procrastinate in fear, but to act with decisive courage'],
            objects: ['before the Constitutional Bench', 'throughout the historic proceedings', 'with unblemished integrity'],
          ),
          SentencePatternItem(
            formula: 'In [Noun A], they [Verb A]; in [Noun B], they [Verb B]; and in [Noun C], they [Verb C]',
            explanation: 'മൂന്ന് സമാന്തര വാക്യാംശങ്ങളിലൂടെ ആരോപണങ്ങളുടെ വ്യാപ്തി വ്യക്തമാക്കുന്ന ട്രയാഡിക് പാരലലിസം (Triadic Parallelism).',
            masterSentences: [
              'In their agreements, they demanded submission; in their governance, they substituted greed; and in their rhetoric, they masked deceit.',
              'In our preparation, we pursued excellence; in our practice, we built stamina; and in our speech, we radiated clarity.',
            ],
            subjects: ['In their public statements, they projected benevolence;', 'In their commercial dealings, they promised parity;'],
            verbs: ['in their internal memos, they conspired against the public', 'in their technical architecture, they concealed algorithmic bias', 'in their financial accounting, they subverted fiscal rectitude'],
            objects: ['behind closed doors in Zurich', 'across the international telecommunications network', 'before the seven magistrates'],
          ),
          SentencePatternItem(
            formula: 'Just as [Clause A], so too must [Subject] [Verb B]',
            explanation: 'രണ്ട് കാര്യങ്ങൾ തമ്മിലുള്ള തുല്യമായ സന്തുലിതാവസ്ഥ പ്രകടമാക്കാൻ (Equative Parallel Correlative).',
            masterSentences: [
              'Just as an architectural dome requires balanced pillars, so too must a democracy maintain independent judiciaries.',
              'Just as deep roots anchor the giant bamboo, so too must daily habits anchor sovereign fluency.',
            ],
            subjects: ['Just as high-frequency electrical circuits require robust grounding,', 'Just as maritime vessels require seasoned navigators,'],
            verbs: ['so too must modern societies erect constitutional safeguards', 'so too must global corporations respect human autonomy', 'so too must sovereign institutions uphold the rule of law'],
            objects: ['against predatory monopolies', 'in times of unprecedented technological transition', 'with mathematical certainty'],
          ),
        ];
      case 18:
        return const [
          SentencePatternItem(
            formula: 'If [Subject] had not [V3], [Subject] would not [V1] today',
            explanation: 'കഴിഞ്ഞ കാലത്തെ പോരാട്ടങ്ങളെ ഇന്നത്തെ നേട്ടവുമായി വിളക്കിച്ചേർക്കുന്ന സോവറിൻ ഡയലക്റ്റിക് സിന്തസിസ് (Mixed Conditional Legacy Frame).',
            masterSentences: [
              'If our predecessors had not braved ridicule, our civilization would not possess sovereign institutions today.',
              'If we had not committed eighteen days ago to sunrise practice, we would not stand in this Grand Empyrean today.',
            ],
            subjects: ['If Daniel had not conquered his fear of failure,', 'If the founders had not persevered through bitter adversity,'],
            verbs: ['he would not command international assemblies with such poise today', 'they would not inspire millions of aspiring scholars worldwide today', 'we would not celebrate Gate 2 culmination with such sovereign joy today'],
            objects: ['at the summit of Mount Verità', 'before two hundred global delegates', 'with the Platinum Seal of Mastery'],
          ),
          SentencePatternItem(
            formula: 'What began as [Noun A] has culminated in [Noun B]',
            explanation: 'ചെറിയ തുടക്കത്തിൽ നിന്ന് പടുകൂറ്റൻ വിജയത്തിലേക്കുള്ള ചരിത്രപരമായ പരിണാമത്തെ പ്രഖ്യാപിക്കാൻ (Evolutionary Milestone Declaration).',
            masterSentences: [
              'What began as a trembling seed of hesitation has culminated in an unassailable fortress of fluency.',
              'What began as a localized power anomaly has culminated in a nationwide energy renaissance.',
            ],
            subjects: ['What began as a modest 90-day learning experiment', 'What began as a tentative conversation in a quiet classroom'],
            verbs: ['has culminated in sovereign linguistic virtuosity', 'has blossomed into an unstoppable global movement', 'has matured into an unbreakable habit of excellence'],
            objects: ['across eighteen unbroken days of transformation', 'at the graduation symposium of Gate Two', 'under the guidance of Master George'],
          ),
          SentencePatternItem(
            formula: 'Having [V3 Participle], we now stand poised to [Base Verb]',
            explanation: 'ഒരു കടമ്പ പൂർത്തിയാക്കി അടുത്ത ഉന്നത തലത്തിലേക്ക് ആത്മവിശ്വാസത്തോടെ കാൽവെക്കാൻ (Perfect Participial Launchpad).',
            masterSentences: [
              'Having conquered Gate Two with unwavering discipline, we now stand poised to command the global arena.',
              'Having mastered complex syntactic structures, Daniel stands poised to deliver the valedictory keynote.',
            ],
            subjects: ['Having grounded our roots deep into bedrock,', 'Having dismantled every psychological barrier to English fluency,'],
            verbs: ['we now stand poised to conquer Gate Three with lionhearted courage', 'we step forward to negotiate high-stakes international pacts', 'we hold our heads high as sovereign masters of speech'],
            objects: ['without fear or hesitation', 'in the grand arena of world leadership', 'for the next 72 days and beyond'],
          ),
        ];
      default:
        return const [
          SentencePatternItem(
            formula: 'Subject + Verb + Object',
            explanation: 'Standard English active sentence syntax.',
            masterSentences: ['Practice creates fluency.', 'Consistency builds confidence.'],
            subjects: ['I', 'We'],
            verbs: ['practice English', 'build confidence'],
            objects: ['every single day', 'with clear purpose'],
          ),
        ];
    }
  }

  // --- 🗣️ DEDICATED PRONUNCIATION CLINIC (Minimal Pairs & Mouth Mechanics) ---
  static PronunciationClinicItem getPronunciationClinic(int day) {
    switch (day) {
      case 1:
        return const PronunciationClinicItem(
          focusSound: 'The Tricky /θ/ (TH) vs /s/ & Aspirated P (/pʰ/)',
          mouthPositionTip: '👅 TH സൗണ്ട് (/θ/): നാവിന്റെ തുമ്പ് മുൻപല്ലുകളുടെ ഇടയിൽ വെച്ച് പതുക്കെ കാറ്റ് പുറത്തേക്ക് വിടുക. "ട" അല്ലെങ്കിൽ "ത" എന്ന് മലയാളം പോലെ പറയരുത്! Think, Thank, Three. \n💨 P സൗണ്ട്: ചുണ്ടുകൾ അമർത്തിപ്പിടിച്ച് ചെറിയൊരു കാറ്റോടെ പുറത്തേക്ക് വിടുക (Paper, Purpose).',
          minimalPairs: [
            {'wordA': 'Think (ചിന്തിക്കുക)', 'wordB': 'Sink (മുങ്ങുക)', 'contrast': 'TH vs S: നാവ് പല്ലിനിടയിൽ vs പല്ലുകൾ കൂട്ടിപ്പിടിക്കുക'},
            {'wordA': 'Thank (നന്ദി)', 'wordB': 'Sank (മുങ്ങിപ്പോയി)', 'contrast': 'നാവ് പല്ലിനിടയിൽ വെച്ച് /θæŋk/'},
            {'wordA': 'Ship (കപ്പൽ)', 'wordB': 'Sheep (ചെമ്മരിയാട്)', 'contrast': 'Short /ɪ/ vs Long /iː/'},
            {'wordA': 'Vine (മുന്തിരിവള്ളി)', 'wordB': 'Wine (വീഞ്ഞ്)', 'contrast': 'V (പല്ല് ചുണ്ടിൽ) vs W (ചുണ്ടുകൾ കൂട്ടി ഉരുട്ടി)'},
          ],
          practicePhrases: [
            'I think three thousand thoughts every morning.',
            'Please put the purple paper on the table.',
            'Victory belongs to those who value wisdom.',
          ],
        );
      case 6:
        return const PronunciationClinicItem(
          focusSound: 'Flapped /t/ & /d/ in Connected Speech + Contraction "would\'ve" (/wʊdəv/)',
          mouthPositionTip: '👅 Flapped T: രണ്ട് സ്വരാക്ഷരങ്ങൾക്ക് (vowels) നടുവിൽ വരുന്ന \'t\' ശബ്ദം നാവിന്റെ തുമ്പ് പെട്ടെന്ന് മുകളിലെ മോണയിൽ തട്ടി പിൻവലിക്കുന്ന മൃദുവായ \'d/r\' ശബ്ദമായി മാറും: Water -> /wɔːtər/ -> [wɑːɾər], Meeting -> [miːɾɪŋ].\n⚡ Contraction: "Would have" എന്നത് വേഗത്തിൽ പറയുമ്പോൾ /wʊdəv/ (വുഡവ്) എന്ന് ഒറ്റവാക്കായി ബന്ധിപ്പിക്കുക!',
          minimalPairs: [
            {'wordA': 'Latter (രണ്ടാമത്തെ)', 'wordB': 'Ladder (ഏണി)', 'contrast': 'Flapped T sounds identical to soft D in connected flow'},
            {'wordA': 'Writer (എഴുത്തുകാരൻ)', 'wordB': 'Rider (സവാരിക്കാരൻ)', 'contrast': 'Vowel length contrast before the flap'},
            {'wordA': 'Bitter (കയ്പ്പുള്ള)', 'wordB': 'Bidder (ലേലം വിളിക്കുന്നയാൾ)', 'contrast': 'Short, crisp tongue tap'},
          ],
          practicePhrases: [
            'We would have met them at the Alveron summit water station.',
            'A better matter for the committee to settle later.',
            'Had we known, we could have prevented the bitter deadlock.',
          ],
        );
      case 7:
        return const PronunciationClinicItem(
          focusSound: 'Oratorical Cadence, Inverted Intonation & Sh /ʃ/ vs Ch /tʃ/',
          mouthPositionTip: '🗣️ പ്രസംഗ ശൈലി: ഇൻവേർഷൻ വാക്യങ്ങൾ പറയുമ്പോൾ ആദ്യ വാക്ക് (Rarely, Never) ഉയർന്ന പിച്ചിലും ശക്തമായ വോളിയത്തിലും പറയുക. ശേഷം ഒരു മൈക്രോ പോസ് (0.5 സെക്കൻഡ്) നൽകി വിഷയം സമർപ്പിക്കുക.\n👄 Sh vs Ch: Sh (/ʃ/) കാറ്റ് മാത്രം ഊതിവിടുന്ന ശബ്ദമാണ് (Share, Shine); Ch (/tʃ/) നാവിന്റെ തുമ്പ് തടഞ്ഞുനിർത്തി പെട്ടെന്ന് പൊട്ടിക്കുന്ന ശബ്ദമാണ് (Chair, Choice).',
          minimalPairs: [
            {'wordA': 'Share (പങ്കുവെക്കുക)', 'wordB': 'Chair (കസേര)', 'contrast': 'Continuous wind (/ʃ/) vs Explosive stop (/tʃ/)'},
            {'wordA': 'Ship (കപ്പൽ)', 'wordB': 'Chip (ചില്ല് / തുണ്ട്)', 'contrast': 'Fricative vs Affricate'},
            {'wordA': 'Wish (ആഗ്രഹം)', 'wordB': 'Witch (മന്ത്രവാദിനി)', 'contrast': 'Ending soft /ʃ/ vs sharp /tʃ/'},
          ],
          practicePhrases: [
            'Rarely do we choose to challenge such profound scientific truth.',
            'Never have I witnessed such sheer rhetorical resonance on stage.',
            'Seldom does a scholar show such charming poise before critics.',
          ],
        );
      case 8:
        return const PronunciationClinicItem(
          focusSound: 'Neutral Schwa /ə/ in Diplomatic Cadence & Consonant Clusters (/m-p-r/)',
          mouthPositionTip: '🌐 ന്യൂട്രൽ ഷ്വാ (/ə/): ഇംഗ്ലീഷിലെ ഏറ്റവും പ്രധാനപ്പെട്ട ശബ്ദം. വാക്കിന്റെ സ്ട്രെസ് ഇല്ലാത്ത സിലബിലുകളിൽ നാവ് പൂർണ്ണമായും റിലാക്സ് ചെയ്ത് ഉച്ചരിക്കുക: Im-PER-a-tive -> /ɪmˈper.ə.tɪv/, Di-plo-MA-tic -> /ˌdɪp.ləˈmæt.ɪk/.\n⚠️ വ്യഞ്ജനാക്ഷര കൂട്ടങ്ങൾ (Clusters): "Crucial" (/ˈkruː.ʃəl/), "Mandate" (/ˈmæn.deɪt/).',
          minimalPairs: [
            {'wordA': 'Council (സമിതി)', 'wordB': 'Counsel (ഉപദേശം നൽകുക)', 'contrast': 'Homophones: perfectly matched neutral schwa endings'},
            {'wordA': 'Precedent (മുൻമാതൃക)', 'wordB': 'President (പ്രസിഡന്റ്)', 'contrast': 'First syllable /pres/ vs /prez/'},
            {'wordA': 'Affect (സ്വാധീനിക്കുക)', 'wordB': 'Effect (ഫലം)', 'contrast': 'Weak schwa /əˈfekt/ vs /ɪˈfekt/'},
          ],
          practicePhrases: [
            'It is imperative that the Geneva plenary assembly remain calm.',
            'The ethical council demands that every delegate adhere to protocol.',
            'Essential multilateral accords require patience, foresight, and poise.',
          ],
        );
      case 9:
        return const PronunciationClinicItem(
          focusSound: 'Contrastive Stress & Syllable Elongation on Cleft Nuclei',
          mouthPositionTip: '🔦 Cleft Stress: ക്ലെഫ്റ്റ് വാക്യങ്ങളിൽ പ്രധാന വാക്കിന് (Nucleus) ഇരട്ടി സമയം നൽകി നീട്ടി ഉച്ചരിക്കുക: "What we TRULY need is... EMPATHY."\n👄 /s/ vs /z/: "Specious" (/ˈspiː.ʃəs/) starts with pure voiceless /s/, whereas "Nuance" (/ˈnjuː.ɑːns/) has a soft, lengthened vowel.',
          minimalPairs: [
            {'wordA': 'Insight (ഉൾക്കാഴ്ച)', 'wordB': 'Incite (പ്രകോപിപ്പിക്കുക)', 'contrast': 'Stress on first syllable (/ˈɪn.saɪt/) vs second (/ɪnˈsaɪt/)'},
            {'wordA': 'Cease (അവസാനിപ്പിക്കുക)', 'wordB': 'Seize (പിടിച്ചെടുക്കുക)', 'contrast': 'Voiceless /siːs/ vs Voiced /siːz/'},
            {'wordA': 'Device (ഉപകരണം)', 'wordB': 'Devise (ആസൂത്രണം ചെയ്യുക)', 'contrast': 'Noun /s/ vs Verb /z/'},
          ],
          practicePhrases: [
            'What truly distinguishes the Socratic mind is relentless curiosity.',
            'It was not the opponent\'s argument, but his specious fallacies we dismantled.',
            'What matters most is our capacity to discern nuance in complexity.',
          ],
        );
      case 10:
        return const PronunciationClinicItem(
          focusSound: 'Executive Gravitas: Diaphragmatic Chest Resonance & Downward Pitch Drop',
          mouthPositionTip: '👑 എക്സിക്യൂട്ടീവ് സൗണ്ട്: വാക്യത്തിന്റെ അവസാനം ചോദ്യം ചോദിക്കുന്നത് പോലെ ശബ്ദം മുകളിലേക്ക് ഉയർത്തരുത് (Uptalk). വാക്യം പൂർത്തിയാകുമ്പോൾ ശബ്ദം താഴേക്ക് ഉറപ്പിച്ചു നിർത്തുക (Downward inflection).\n🌬️ ശ്വാസോച്ഛ്വാസം: നെഞ്ചിൽ നിന്നല്ല, അടിവയറ്റിൽ (Diaphragm) നിന്ന് ശ്വാസമെടുത്ത് ആഴത്തിലുള്ള ഉറച്ച ശബ്ദത്തിൽ സംസാരിക്കുക.',
          minimalPairs: [
            {'wordA': 'Sovereign (പരമാധികാരമുള്ള)', 'wordB': 'Suffering (വേദന)', 'contrast': '/ˈsɒv.rɪn/ crisp v-r blend vs /ʌ/ vowel'},
            {'wordA': 'Statute (നിയമം)', 'wordB': 'Stature (വ്യക്തിപ്രഭാവം)', 'contrast': '/ˈstætʃ.uːt/ vs /ˈstætʃ.ər/'},
            {'wordA': 'Unanimous (ഏകകണ്ഠമായ)', 'wordB': 'Anonymous (അജ്ഞാതമായ)', 'contrast': '/juːˈnæn.ɪ.məs/ vs /əˈnɒn.ɪ.məs/'},
          ],
          practicePhrases: [
            'Had we not stood firm, our sovereign institutions would not endure today.',
            'The Peace Palace accord represents the unanimous will of fifty sovereign states.',
            'Ten days of unbroken focus have anchored our fluency deep into bedrock.',
          ],
        );
      case 11:
        return const PronunciationClinicItem(
          focusSound: 'Polysyllabic Rhythmic Metronome: Primary (ˈ) vs Secondary (ˌ) Stress in 5-Syllable Words',
          mouthPositionTip: '🌌 വലിയ അക്കാദമിക് വാക്കുകൾ പറയുമ്പോൾ മലയാളം പോലെ എല്ലാ അക്ഷരങ്ങൾക്കും ഒരേ ശക്തി കൊടുക്കരുത്. പ്രധാന സ്ട്രെസ്സിന് (Primary Stress) ഇരട്ടി ശക്തിയും ഉയരമുള്ള പിച്ചും നൽകുക:\n• Me-ta-MOR-pho-sis -> /ˌmet.əˈmɔː.fə.sɪs/ ("MOR" ഉയർന്ന പിച്ചിൽ)\n• Vir-tu-OS-i-ty -> /ˌvɜː.tʃuˈɒs.ə.ti/ ("OS" പ്രധാന സ്ട്രെസ്സ്)\n• In-EX-or-a-ble -> /ɪnˈek.sər.ə.bəl/ ("EX" ദൃഢമായി).',
          minimalPairs: [
            {'wordA': 'Affect (സ്വാധീനിക്കുക - ക്രിയ)', 'wordB': 'Effect (ഫലം - നാമം)', 'contrast': 'Weak schwa /əˈfekt/ vs crisp /ɪˈfekt/'},
            {'wordA': 'Present (സമർപ്പിക്കുക - ക്രിയ)', 'wordB': 'Present (സമ്മാനം / വർത്തമാനം - നാമം)', 'contrast': 'Verb stress on 2nd syllable /prɪˈzent/ vs noun /ˈprez.ənt/'},
            {'wordA': 'Transcend (അതിജീവിക്കുക)', 'wordB': 'Descend (താഴേക്ക് ഇറങ്ങുക)', 'contrast': '/trænˈsend/ vs /dɪˈsend/'},
          ],
          practicePhrases: [
            'Linguistic virtuosity triggers an inexorable metamorphosis in thought.',
            'Her erudite lecture illuminated ancient morphological evolution.',
            'An indomitable spirit allows human ambition to transcend borders.',
          ],
        );
      case 12:
        return const PronunciationClinicItem(
          focusSound: 'Pure /sp/ & /sk/ S-Clusters (No "Is-" Prefix) + "Specious" vs "Spacious"',
          mouthPositionTip: '⚖️ തെറ്റ് തിരുത്തൽ: "Specious", "Speak", "Special" എന്നിവ പറയുമ്പോൾ മലയാളികൾ അറിയാതെ മുന്നിൽ "ഇസ്" ചേർക്കാറുണ്ട് (Is-pecious). നാവ് മുൻപല്ലുകൾക്ക് പിന്നിൽ ചേർത്ത് പ്യുവർ വിസിൽ സൗണ്ടോടെ /s/ മാത്രം തുടങ്ങുക: /spiː.ʃəs/.\n👄 Specious (/ˈspiː.ʃəs/) എന്നാൽ ബാഹ്യമായി ശരിയെന്നു തോന്നുന്ന എന്നാൽ വ്യാജമായ കാര്യം; Spacious (/ˈspeɪ.ʃəs/) എന്നാൽ വിശാലമായ സ്ഥലം.',
          minimalPairs: [
            {'wordA': 'Specious (വ്യാജമായ/തെറ്റായ)', 'wordB': 'Spacious (വിശാലമായ)', 'contrast': 'Vowel contrast: Long /iː/ vs Diphthong /eɪ/'},
            {'wordA': 'Perspicacity (സൂക്ഷ്മബുദ്ധി)', 'wordB': 'Perspicuity (വ്യക്തത)', 'contrast': 'Five-syllable contrast: /-kæs.ə.ti/ vs /-kjuː.ə.ti/'},
            {'wordA': 'Equivocal (വ്യക്തതയില്ലാത്ത)', 'wordB': 'Unequivocal (വ്യക്തമായ/തറപ്പിച്ചു പറയുന്ന)', 'contrast': 'Adding prefix changes stress: /ɪˈkwɪv.ə.kəl/ vs /ˌʌn.ɪˈkwɪv.ə.kəl/'},
          ],
          practicePhrases: [
            'A master debater quickly dismantles specious arguments with hard facts.',
            'Rowan spoke with surgical perspicacity, exposing the opponent\'s fallacies.',
            'Instead of prevaricating under cross-examination, state your thesis directly.',
          ],
        );
      case 13:
        return const PronunciationClinicItem(
          focusSound: 'Crisp Unaspirated /t/ vs Glottal Stop in Scientific Cadence + /p-s-t/ Clusters',
          mouthPositionTip: '🔬 ശാസ്ത്രീയ ഉച്ചാരണം: ശാസ്ത്ര പ്രബന്ധങ്ങൾ അവതരിപ്പിക്കുമ്പോൾ വാക്കുകൾ വിഴുങ്ങാതെ വ്യക്തമായി ഉച്ചരിക്കണം. "Epistemological" (/ɪˌpɪs.tə.məˈlɒdʒ.ɪ.kəl/) എന്ന 7-സിലബിൾ വാക്ക് 3 ഘട്ടമായി വായിക്കുക: E-pis ➔ te-mo ➔ LOG-i-cal.\n💨 "Empirical" (/ɪmˈpɪr.ɪ.kəl/): ചുണ്ടുകൾ അമർത്തി /m/, തുടർന്ന് റിലാക്സ് ചെയ്ത /p/.',
          minimalPairs: [
            {'wordA': 'Empirical (പ്രത്യക്ഷാനുഭവപരമായ)', 'wordB': 'Imperial (സാമ്രാജ്യത്വപരമായ)', 'contrast': 'Vowel and meaning: /ɪmˈpɪr.ɪ.kəl/ vs /ɪmˈpɪə.ri.əl/'},
            {'wordA': 'Corroborate (സ്ഥിരീകരിക്കുക)', 'wordB': 'Collaborate (ഒരുമിച്ചു പ്രവർത്തിക്കുക)', 'contrast': 'R-sound /rɒb/ vs L-sound /læb/'},
            {'wordA': 'Vindicate (സാധൂകരിക്കുക)', 'wordB': 'Indicate (സൂചിപ്പിക്കുക)', 'contrast': 'Starting V (teeth on lip) vs initial vowel /ɪ/'},
          ],
          practicePhrases: [
            'Extensive double-blind empirical trials strongly corroborate our thesis.',
            'Incongruous though the findings appear, they illuminate the paradigm shift.',
            'It can be reasonably inferred that neural plasticity endures into adulthood.',
          ],
        );
      case 14:
        return const PronunciationClinicItem(
          focusSound: 'Rhetorical Tricolon Pitch Arcs (Low-Rise ↗, Mid-Rise ↗, Deep-Fall ↘)',
          mouthPositionTip: '🏛️ പ്രഭാഷണ താളം: ത്രിത്വ വാക്യങ്ങൾ (Tricolon) പറയുമ്പോൾ നാടകം പോലെ ശബ്ദം നിയന്ത്രിക്കുക:\n1. ഒന്നാമത്തെ ഭാഗം: ചെറുതായി ശബ്ദം ഉയർത്തുക (Low-Rise ↗) -> "We demand transparency..." (0.3s pause)\n2. രണ്ടാമത്തെ ഭാഗം: കുറച്ചുകൂടി മുകളിലേക്ക് (Mid-Rise ↗) -> "...we require mutual respect..." (0.3s pause)\n3. മൂന്നാമത്തെ ക്ലൈമാക്സ്: ആഴത്തിലുള്ള താഴേക്കുള്ള ശബ്ദം (Deep-Fall ↘) -> "...and above all, we safeguard sovereign integrity!"',
          minimalPairs: [
            {'wordA': 'Acumen (തീക്ഷ്ണബുദ്ധി)', 'wordB': 'Accurate (കൃത്യമായ)', 'contrast': '/ˈæk.jə.mən/ ending in -men vs /ˈæk.jə.rət/'},
            {'wordA': 'Concomitant (കൂടെയുണ്ടാകുന്ന)', 'wordB': 'Competent (പ്രാപ്തിയുള്ള)', 'contrast': 'Four syllables /kənˈkɒm.ɪ.tənt/ vs three /ˈkɒm.pɪ.tənt/'},
            {'wordA': 'Impasse (സ്തംഭനാവസ്ഥ)', 'wordB': 'Compass (വടക്കുനോക്കിയന്ത്രം)', 'contrast': 'French-origin /æmˈpɑːs/ or /ˈɪm.pɑːs/ vs /ˈkʌm.pəs/'},
          ],
          practicePhrases: [
            'Front and center stands our commitment to unyielding integrity.',
            'Not only does this treaty safeguard commerce, but it enriches culture, and secures peace.',
            'With executive influence comes concomitant responsibility to govern with justice.',
          ],
        );
      case 15:
        return const PronunciationClinicItem(
          focusSound: 'Diplomatic Tone Modulation, Soft Intonation & The /njuː/ Blend in "Nuance"',
          mouthPositionTip: '💎 ഡിപ്ലോമാറ്റിക് സൗണ്ട്: സംസാരിക്കുമ്പോൾ പരുക്കൻ ഭാവം പൂർണ്ണമായി ഒഴിവാക്കുക. തൊണ്ടയിലെ മസിലുകൾ അയച്ചുവിട്ട് ശാന്തവും സൗമ്യവുമായ ടോണിൽ സംസാരിക്കുക.\n👄 "Nuance": /ˈnjuː.ɑːns/ എന്ന് ഫ്രഞ്ച് ശൈലിയിൽ ചുണ്ടുകൾ ഉരുട്ടി മൃദുവായി ഉച്ചരിക്കുക.\n⚠️ "Circumspect": /ˈsɜː.kəm.spekt/ - ശാന്തമായ വിവേകത്തോടെ.',
          minimalPairs: [
            {'wordA': 'Nuance (സൂക്ഷ്മഭേദം)', 'wordB': 'Nuisance (ശല്യം)', 'contrast': '/ˈnjuː.ɑːns/ (diplomatic subtle detail) vs /ˈnjuː.səns/ (annoyance)'},
            {'wordA': 'Circumspect (കരുതലോടെയുള്ള)', 'wordB': 'Circumstance (സാഹചര്യം)', 'contrast': '/ˈsɜː.kəm.spekt/ (adjective) vs /ˈsɜː.kəm.stæns/ (noun)'},
            {'wordA': 'Cordially (ഹൃദ്യമായി)', 'wordB': 'Cardially (ഹൃദയസംബന്ധമായി)', 'contrast': 'Open /ɔː/ vowel in "Cordially" (/ˈkɔː.di.ə.li/)'},
          ],
          practicePhrases: [
            'Would it be deemed feasible to explore an alternative phased timeline?',
            'I would be inclined to suggest that we review the clause before committing.',
            'Circumspect though our colleagues may be, their dedication to consensus remains unwavering.',
          ],
        );
      case 16:
        return const PronunciationClinicItem(
          focusSound: 'Cleft Emphasis Stress (Contrastive Pitch Peak) & Crisis Sibilants (/s/ vs /z/)',
          mouthPositionTip: '⚡ Cleft Stress Mechanics: "It was not [A], but [B]" എന്ന് പറയുമ്പോൾ [B] എന്ന ഭാഗത്തിന് സാധാരണയേക്കാൾ 50% കൂടുതൽ വോളിയവും ഉയർന്ന പിച്ചും (Pitch Peak) നൽകുക:\n• "It was not neg-li-gence, but a GRID SURGE!"\n• "Precipitate" (/prɪˈsɪp.ɪ.teɪt/) വേഗത്തിൽ പറയാതെ ഓരോ സിലബിളും വ്യക്തമാക്കുക.',
          minimalPairs: [
            {'wordA': 'Precipitate (വേഗത്തിലാക്കുക / വിപത്ത് വരുത്തിവെക്കുക)', 'wordB': 'Precipitation (മഴ / വർഷണം)', 'contrast': 'Verb stress /prɪˈsɪp.ɪ.teɪt/ vs noun /prɪˌsɪp.ɪˈteɪ.ʃən/'},
            {'wordA': 'Saliency (പ്രധാനത്വം / പ്രകടത)', 'wordB': 'Silency (നിശ്ശബ്ദത)', 'contrast': 'Diphthong /ˈseɪ.li.ən.si/ vs short /ˈsaɪ.ləns/'},
            {'wordA': 'Surge (കുതിച്ചുചാട്ടം)', 'wordB': 'Serge (ഒരുതരം തുണി)', 'contrast': 'Long central vowel /sɜːdʒ/ with resonant voiced j-sound'},
          ],
          practicePhrases: [
            'It was not negligence, but an unforeseen grid surge that triggered the crisis.',
            'What our infrastructure urgently requires is not superficial rhetoric, but structural resilience.',
            'Only by decoupling the subgrids can our engineers prevent a total collapse.',
          ],
        );
      case 17:
        return const PronunciationClinicItem(
          focusSound: 'Syntactic Parallelism Cadence (Symmetrical Rhythm & Anaphora Balance)',
          mouthPositionTip: '🏛️ സമാന്തര താളങ്ങൾ: "Not to A, but to B; not to C, but to D" എന്ന് പ്രസംഗിക്കുമ്പോൾ ഒരു സംഗീത താളം പോലെ തുല്യ സമയ ഇടവേളകളിൽ സംസാരിക്കുക.\n👄 "Equanimity" (/ˌek.wəˈnɪm.ə.ti/) - 5 സിലബിൾ വാക്ക്; "Rectitude" (/ˈrek.tɪ.tjuːd/) - ഉറച്ച ടി-ശബ്ദത്തോടെ (Crisp alveolar T).',
          minimalPairs: [
            {'wordA': 'Equanimity (മനസ്സമാധാനം/സമചിത്തത)', 'wordB': 'Unanimity (ഏകാഭിപ്രായം)', 'contrast': '/ˌek.wəˈnɪm.ə.ti/ vs /ˌjuː.nəˈnɪm.ə.ti/'},
            {'wordA': 'Rectitude (സത്യസന്ധത/ധാർമ്മികത)', 'wordB': 'Altitude (ഉയരം)', 'contrast': '/ˈrek.tɪ.tjuːd/ vs /ˈæl.tɪ.tjuːd/'},
            {'wordA': 'Inviolable (ലംഘിക്കാനാവാത്ത)', 'wordB': 'Invisible (അദൃശ്യമായ)', 'contrast': '/ɪnˈvaɪ.ə.lə.bəl/ with broad open diphthong /aɪ/'},
          ],
          practicePhrases: [
            'We stand here not to negotiate convenience, but to defend liberty.',
            'Julian addressed the august constitutional bench with unshakable equanimity.',
            'In their agreements, they demanded submission; in their governance, they substituted greed.',
          ],
        );
      case 18:
        return const PronunciationClinicItem(
          focusSound: 'Gate 2 Grand Valedictory Poise (Diaphragmatic Resonator & Empyrean Cadence)',
          mouthPositionTip: '👑 രാജകീയ പ്രൗഢി (Sovereign Resonance): സംസാരിക്കുമ്പോൾ തൊണ്ടയടച്ച് സംസാരിക്കരുത്. താടിയെല്ല് (Jaw) നന്നായി അയച്ചുവിട്ട്, നെഞ്ചിലെയും അടിവയറ്റിലെയും വായു അറകളെ വികസിപ്പിച്ച് ആഴമുള്ള ഒച്ചയിൽ സംസാരിക്കുക.\n🏔️ "Culmination" (/ˌkʌl.mɪˈneɪ.ʃən/) - ക്ലൈമാക്സ് സിലബിളായ "NAY" ലേക്ക് ഒഴുക്കോടെ ഉയർത്തുക.',
          minimalPairs: [
            {'wordA': 'Culmination (പൂർണ്ണത/കൊടുമുടി)', 'wordB': 'Cultivation (കൃഷി/പരിപാലനം)', 'contrast': '/ˌkʌl.mɪˈneɪ.ʃən/ vs /ˌkʌl.tɪˈveɪ.ʃən/'},
            {'wordA': 'Empyrean (സ്വർഗ്ഗീയമായ/ഉന്നതമായ)', 'wordB': 'Empirical (പ്രത്യക്ഷാനുഭവപരമായ)', 'contrast': '/ˌem.paɪˈriː.ən/ vs /ɪmˈpɪr.ɪ.kəl/'},
            {'wordA': 'Valedictory (വിടപറയൽ പ്രസംഗപരമായ)', 'wordB': 'Contradictory (പരസ്പരവിരുദ്ധമായ)', 'contrast': '/ˌvæl.əˈdɪk.tər.i/ vs /ˌkɒn.trəˈdɪk.tər.i/'},
          ],
          practicePhrases: [
            'If our predecessors had not braved ridicule, our institutions would not endure today.',
            'What began as a trembling seed of hesitation has culminated in an unassailable fortress.',
            'Having conquered Gate Two, we stand poised to command the global arena with sovereign grace.',
          ],
        );
      default:
        return const PronunciationClinicItem(
          focusSound: 'Vocal Projection & Clear Articulation',
          mouthPositionTip: 'Keep your jaw relaxed, articulate vowels clearly, and speak with diaphragmatic breath.',
          minimalPairs: [],
          practicePhrases: ['Consistent practice creates sovereign English fluency.'],
        );
    }
  }

  // --- 🧠 ENGLISH THINKING WORKOUT (Stop Malayalam-to-English Mental Translation) ---
  static EnglishThinkingItem getEnglishThinkingWorkout(int day) {
    switch (day) {
      case 1:
        return const EnglishThinkingItem(
          situation: 'Coffee Spilled on the Desk (മേശപ്പുറത്ത് വെള്ളം അല്ലെങ്കിൽ കോഫി മറിഞ്ഞു വീഴുന്നു)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: "അയ്യോ വെള്ളം മറിഞ്ഞുപോയി, ഞാൻ എന്ത് ചെയ്യും" എന്ന് മലയാളത്തിൽ ചിന്തിച്ച് അതിനെ ഇംഗ്ലീഷിലേക്ക് തർജ്ജമ ചെയ്യാൻ ശ്രമിക്കുമ്പോൾ സമയം നഷ്ടപ്പെടുന്നു.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: സാധനത്തെ കാണുമ്പോൾ തന്നെ "Spill! Grab a napkin!" എന്ന ചിന്ത നേരിട്ട് തലച്ചോറിൽ വരണം.',
          instantResponses: [
            '"Oh no, I just spilled my coffee!"',
            '"Could someone please hand me a tissue?"',
            '"Let me clean this up right away."',
          ],
        );
      case 6:
        return const EnglishThinkingItem(
          situation: 'A High-Stakes Project Deadline Conflict (പ്രൊജക്റ്റ് സമയപരിധിയെച്ചൊല്ലി സഹപ്രവർത്തകരുമായി തർക്കം)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: "അവർ ചെയ്തത് തെറ്റാണ്, ഞാൻ ഇത് സമ്മതിക്കില്ല" എന്ന് ദേഷ്യപ്പെട്ട് മലയാളത്തിൽ ചിന്തിക്കുക.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "Third Conditional Matrix! Focus on the shared goal and reframe past mistakes calmly."',
          instantResponses: [
            '"If we had aligned earlier, this friction would not have occurred."',
            '"Let us not dwell on past delays; what is our pragmatic compromise?"',
            '"I propose a revised milestone calendar that accommodates both teams."',
          ],
        );
      case 7:
        return const EnglishThinkingItem(
          situation: 'Called on Stage to Speak Unexpectedly (പൊടുന്നനെ സ്റ്റേജിലേക്ക് ക്ഷണിക്കപ്പെടുന്നു)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: "അയ്യോ ഇത്രയും ആളുകളുടെ മുന്നിൽ ഞാൻ എന്ത് പറയും, നാണക്കേടാകുമോ?" എന്ന് ഭയപ്പെടുക.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "Command the room! Pause 3 seconds, plant my feet, open with an Inversion formula!"',
          instantResponses: [
            '"Rarely do we encounter an opportunity as meaningful as this gathering."',
            '"I am honored to stand before you and share our collective vision."',
            '"Let us address the core question that brought us together today."',
          ],
        );
      case 8:
        return const EnglishThinkingItem(
          situation: 'Cross-Cultural Workplace Disagreement (വിദേശ സഹപ്രവർത്തകരുമായി നയപരമായ അഭിപ്രായവ്യത്യാസം)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: വാദപ്രതിവാദങ്ങളിൽ വ്യക്തിപരമായ കുറ്റപ്പെടുത്തലുകൾ മലയാളത്തിൽ ആലോചിക്കുക.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "Subjunctive Protocol! Professional, measured, and focused on institutional mandate."',
          instantResponses: [
            '"It is imperative that we maintain transparent communication on this point."',
            '"The team insists that all data be independently verified before launch."',
            '"Be that as it may, our shared objective remains paramount."',
          ],
        );
      case 9:
        return const EnglishThinkingItem(
          situation: 'Handling a Tricky Interview or Debate Question (ഇന്റർവ്യൂവിൽ കുഴപ്പിക്കുന്ന ചോദ്യം നേരിടുമ്പോൾ)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: പരിഭ്രാന്തരായി ചോദ്യത്തിൽ കുടുങ്ങി പെട്ടെന്ന് പരസ്പരവിരുദ്ധമായ മറുപടി നൽകുക.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "Cleft Laser! Take a breath, acknowledge the complexity, shine light on the core truth."',
          instantResponses: [
            '"What we must evaluate first is the underlying premise of this question."',
            '"It was not lack of technical capability, but a shift in strategic priorities."',
            '"The primary reason why this approach works is its grounded realism."',
          ],
        );
      case 10:
        return const EnglishThinkingItem(
          situation: 'Reflecting on the 10-Day Milestone & Future Ambition (10 ദിവസത്തെ മൈൽസ്റ്റോൺ പൂർത്തിയാക്കുമ്പോൾ)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: "ഞാൻ ഇനിയും ഒരുപാട് പഠിക്കാനുണ്ട്, എനിക്ക് ഇംഗ്ലീഷ് പൂർണ്ണമായി അറിയില്ലല്ലോ."',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "I have conquered Gate 1. Roots are anchored. Fluency is my sovereign birthright."',
          instantResponses: [
            '"If I had not committed on Day 1, I would not speak with this sovereign authority today."',
            '"Ten unbroken days have proven that consistency conquers all fear."',
            '"I am ready to conquer the next 80 days with unstoppable momentum."',
          ],
        );
      case 11:
        return const EnglishThinkingItem(
          situation: 'Explaining a Major Career Pivot or Intellectual Growth (കരിയറിലുണ്ടായ വലിയൊരു മാറ്റത്തെക്കുറിച്ച് സംസാരിക്കുമ്പോൾ)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: "എന്റെ ചിന്താഗതിയിൽ വലിയൊരു മാറ്റമുണ്ടായി, ഞാൻ പണ്ട് ചെയ്തതൊന്നുമല്ല ഇപ്പോൾ ചെയ്യുന്നത്" എന്ന് മലയാളത്തിൽ ആലോചിച്ച് പരസ്പരബന്ധമില്ലാതെ തർജ്ജമ ചെയ്യുക.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "Cognitive Metamorphosis! Lead with participial elegance and elevated vocabulary."',
          instantResponses: [
            '"My professional trajectory has undergone an inexorable metamorphosis."',
            '"Having anchored foundational discipline, I am poised to transcend previous operational limits."',
            '"This transition was not a sudden impulse, but an enlightened evolution of purpose."',
          ],
        );
      case 12:
        return const EnglishThinkingItem(
          situation: 'Countering a Misleading or Specious Claim in a Meeting (യോഗത്തിൽ ഒരാൾ തെറ്റായ വിവരങ്ങൾ സമർത്ഥിക്കുമ്പോൾ)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: "അവർ പറയുന്നത് പച്ചക്കള്ളമാണ്, ഞാൻ ഇത് സമ്മതിക്കില്ല" എന്ന് ദേഷ്യപ്പെട്ട് വൈകാരികമായി പ്രതികരിക്കാൻ തുടങ്ങുക.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "Dialectic Concession! Stay calm, acknowledge their angle, dismantle the fallacy with surgical perspicacity."',
          instantResponses: [
            '"Granted that your proposal sounds attractive, yet the underlying metrics remain fallacious."',
            '"Rather than prevaricating on audit metrics, let us examine the verifiable figures directly."',
            '"Be that as it may, our primary fiduciary duty is to maintain strict operational integrity."',
          ],
        );
      case 13:
        return const EnglishThinkingItem(
          situation: 'Presenting a Disputed Technical or Scientific Finding (ഒരു പുതിയ കണ്ടുപിടുത്തം അല്ലെങ്കിൽ മാറ്റം അവതരിപ്പിക്കുമ്പോൾ)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: ഭയന്ന് "എനിക്കറിയില്ല, ഒരുപക്ഷേ ഇങ്ങനെയാകാം" എന്ന് പരുങ്ങുകയോ, അഹങ്കാരത്തോടെ "ഇതാണ് നൂറ് ശതമാനം ശരി" എന്ന് ശഠിക്കുകയോ ചെയ്യുക.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "Epistemic Hedging! Calibrated confidence grounded in empirical evidence."',
          instantResponses: [
            '"The empirical data strongly suggests a profound paradigm shift in our methodology."',
            '"Incongruous though the initial readings appeared, extensive independent trials corroborate our thesis."',
            '"It can be reasonably inferred that this anomaly warrants comprehensive investigation."',
          ],
        );
      case 14:
        return const EnglishThinkingItem(
          situation: 'Breaking a Paralyzing Cross-Team Impasse (രണ്ട് ടീമുകൾ തമ്മിൽ തർക്കമുണ്ടായി പ്രൊജക്റ്റ് മുടങ്ങിക്കിടക്കുമ്പോൾ)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: ഇരുപക്ഷത്തെയും കുറ്റപ്പെടുത്തി സമയം കളയുക.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "Tricolon Cadence! Command the room with a 3-part ascending vision."',
          instantResponses: [
            '"Front and center stands our collective obligation to deliver excellence to our customers."',
            '"We demand transparency, we require mutual accountability, and above all, we protect our users."',
            '"Not only does this compromise resolve the current impasse, but it cements enduring trust."',
          ],
        );
      case 15:
        return const EnglishThinkingItem(
          situation: 'Refusing an Unreasonable Demand from an Important Stakeholder (പ്രധാനപ്പെട്ട ഒരാളുടെ അപ്രായോഗിക നിർദ്ദേശം തള്ളിക്കളയുമ്പോൾ)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: "ഇത് ഒരിക്കലും നടക്കില്ല, ചെയ്യാൻ പറ്റില്ല" എന്ന് മുഖത്തടിച്ചതുപോലെ പറയുക.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "Diplomatic Softener! Honor their perspective, soften the refusal, offer a circumspect alternative."',
          instantResponses: [
            '"I certainly appreciate the urgency behind this initiative; however, might we explore an agile phased approach?"',
            '"I would be inclined to suggest a forty-eight-hour review to safeguard technical quality."',
            '"Circumspect though we must be regarding bandwidth, our dedication to your vision remains absolute."',
          ],
        );
      case 16:
        return const EnglishThinkingItem(
          situation: 'High-Stakes Technical Crisis & Press Conference (അടിയന്തിര സാങ്കേതിക തകരാർ ഉണ്ടാകുമ്പോൾ മാധ്യമങ്ങളോട് പ്രതികരിക്കാൻ)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: "അയ്യോ എല്ലാവരും എന്നെ കുറ്റപ്പെടുത്തും, ഞാൻ എന്ത് ചെയ്യും" എന്ന് ഭയപ്പെട്ട് മലയാളത്തിൽ ചിന്തിച്ച് പരസ്പരവിരുദ്ധമായ ഒഴികഴിവുകൾ പറയുക.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "Saliency Filter! Reject false premises with It-Clefts; spotlight the true technical diagnosis."',
          instantResponses: [
            '"It was not human negligence, but an unforeseen grid surge that triggered the telemetry failure."',
            '"What our engineering response requires right now is calm, systematic isolation of the subgrids."',
            '"Only by maintaining absolute transparency can we preserve institutional trust."',
          ],
        );
      case 17:
        return const EnglishThinkingItem(
          situation: 'Arguing a High-Principles Position before Authority (മേലധികാരികൾക്കോ ജൂറിക്കോ മുന്നിൽ നീതിപൂർവ്വമായ തത്വം സമർപ്പിക്കുമ്പോൾ)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: സാധാരണ വാക്കുകളിൽ യാചിക്കുന്നതുപോലെ സംസാരിക്കുക അല്ലെങ്കിൽ അകാരണമായി ദേഷ്യപ്പെടുക.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "Syntactic Parallelism! Deliver rhythmic, antithetical contrasts that make injustice look untenable."',
          instantResponses: [
            '"We stand here not to negotiate convenience, but to defend constitutional liberty."',
            '"In your promises, you pledged parity; in your actions, you compromised our sovereignty."',
            '"Just as justice requires impartiality, so too does leadership demand unbending rectitude."',
          ],
        );
      case 18:
        return const EnglishThinkingItem(
          situation: 'Delivering a Transformational Milestone Keynote (ജീവിതത്തിലെ വലിയൊരു നേട്ടം സദസ്സിന് മുന്നിൽ പ്രഖ്യാപിക്കുമ്പോൾ)',
          mentalTrapMalayalam: '❌ സാധാരണ തെറ്റ്: "എനിക്ക് പണ്ടേ ഒന്നും അറിയില്ലായിരുന്നു, ഇപ്പോൾ എങ്ങനെയൊക്കെയോ ഭാഗ്യം കൊണ്ട് ഇത്രയായി" എന്ന് സ്വയം ചെറുതാക്കി സംസാരിക്കുക.',
          directEnglishThought: '💡 നേരിട്ട് ഇംഗ്ലീഷിൽ ചിന്തിക്കുക: "Sovereign Dialectic! Bridge the past struggle to today\'s triumphant mastery."',
          instantResponses: [
            '"If we had not committed eighteen days ago to sunrise immersion, we would not stand as masters today."',
            '"What began as a trembling seed of hesitation has culminated in an unassailable fortress of fluency."',
            '"Having conquered Gate Two, we now stand poised to command the global arena."',
          ],
        );
      default:
        return const EnglishThinkingItem(
          situation: 'Everyday Conversational Exchange',
          mentalTrapMalayalam: 'Do not translate from native language.',
          directEnglishThought: 'Think directly in English concepts.',
          instantResponses: ['"I understand completely; let us proceed with focus."'],
        );
    }
  }

  // --- 🎙️ IN-LESSON SPEAKING CHALLENGE (Structured Verbal Challenge) ---
  static SpeakingChallengeItem getSpeakingChallenge(int day) {
    switch (day) {
      case 1:
        return const SpeakingChallengeItem(
          title: '30-Second Sovereign Introduction Challenge',
          contextScenario: 'നിങ്ങൾ ഒരു അന്താരാഷ്ട്ര കോൺഫറൻസിലോ ഇന്റർവ്യൂവിലോ ഇരിക്കുന്നു. നിങ്ങളെക്കുറിച്ച് 30 സെക്കൻഡിൽ ആത്മവിശ്വാസത്തോടെ സംസാരിക്കുക.',
          targetSeconds: 30,
          guidingPoints: [
            '1. State your name with a warm smile ("Hello, my name is...")',
            '2. State what you are passionate about ("I am passionate about learning and growth...")',
            '3. State your 90-day English commitment ("Today, I am starting my 90-day sovereign English journey.")',
            '4. Speak slowly, clearly, and breathe between sentences.',
          ],
          sampleNativeAudioScript: 'Hello everyone! My name is Daniel. I am passionate about learning, technology, and self-improvement. Today, I am proud to begin my 90-day sovereign English journey. I look forward to speaking with all of you!',
        );
      case 6:
        return const SpeakingChallengeItem(
          title: '45-Second High-Stakes Negotiation Challenge',
          contextScenario: 'നിങ്ങൾ രണ്ട് വിഭാഗങ്ങൾ തമ്മിലുള്ള തർക്കം രമ്യമായി പരിഹരിക്കാൻ എത്തിയ നയതന്ത്ര പ്രതിനിധിയാണ്. ഒരു മിനിറ്റിൽ താഴെ സമയം കൊണ്ട് അനുരഞ്ജന നിർദ്ദേശം അവതരിപ്പിക്കുക.',
          targetSeconds: 45,
          guidingPoints: [
            '1. Acknowledge both perspectives with empathy ("I recognize both teams have valid concerns...")',
            '2. Deploy a Third Conditional reframe ("If we had aligned earlier, this friction would not have escalated...")',
            '3. Propose the compromise clearly ("Therefore, I stipulate a joint seasonal committee...")',
            '4. Conclude with shared prosperity ("Let us sign this accord and move forward together.")',
          ],
          sampleNativeAudioScript: 'Esteemed colleagues, I recognize that both sides have valid economic concerns. If we had established clear guidelines last autumn, this impasse would have been avoided. However, the past is immutable. I propose an equitable joint commission with transparent seasonal quotas. By uniting our efforts today, both houses will prosper for generations to come.',
        );
      case 7:
        return const SpeakingChallengeItem(
          title: '45-Second Oratorical Keynote Challenge',
          contextScenario: 'നിങ്ങൾ ആയിരം പേർ തിങ്ങിനിറഞ്ഞ ഒരു ഓഡിറ്റോറിയത്തിൽ ഒരു പുതിയ ആശയത്തെ പിന്തുണച്ച് സംസാരിക്കുകയാണ്. ഇൻവേർഷൻ ഉപയോഗിച്ച് സദസ്സിനെ ആകർഷിക്കുക.',
          targetSeconds: 45,
          guidingPoints: [
            '1. Open with restrictive inversion ("Rarely in our careers do we encounter...")',
            '2. Present the challenge with passion ("Seldom has the need for innovation been so acute...")',
            '3. Call for courageous action ("Under no circumstances can we afford to hesitate...")',
            '4. Finish with an authoritative drop in pitch.',
          ],
          sampleNativeAudioScript: 'Distinguished guests, rarely in our professional lives do we encounter a moment of such profound opportunity. Seldom have scholars possessed such clear data proving that change is not merely possible, but essential. Under no circumstances will our team retreat into outdated habits. Together, let us embrace this bold scientific future!',
        );
      case 8:
        return const SpeakingChallengeItem(
          title: '50-Second Multilateral Policy Address',
          contextScenario: 'നിങ്ങൾ ജനീവയിലെ ഐക്യരാഷ്ട്രസഭാ വേദിയിൽ അന്താരാഷ്ട്ര നിയമനിർമ്മാണത്തെക്കുറിച്ച് ഔദ്യോഗികമായി സംസാരിക്കുകയാണ്.',
          targetSeconds: 50,
          guidingPoints: [
            '1. Begin with formal diplomatic greetings ("Honorable delegates...")',
            '2. Deploy the Subjunctive Mandate ("It is imperative that every nation adhere...")',
            '3. Reiterate human dignity above technical speed ("It is essential that human values remain supreme...")',
            '4. Conclude with sovereign statesman cadence.',
          ],
          sampleNativeAudioScript: 'Honorable delegates, it is imperative that our international community act with unwavering moral clarity. The global public demands that technological innovation serve human dignity, not undermine it. It is essential that every government remain committed to transparent civil oversight. Let us ratify this historic charter today.',
        );
      case 9:
        return const SpeakingChallengeItem(
          title: '50-Second Socratic Dissection Challenge',
          contextScenario: 'ഒരു പ്രശസ്ത ഡിബേറ്റിൽ എതിരാളിയുടെ തെറ്റായ വാദമുഖങ്ങളെ ശാന്തമായി ഖണ്ഡിച്ചുകൊണ്ട് സത്യം സമർപ്പിക്കുക.',
          targetSeconds: 50,
          guidingPoints: [
            '1. Respectfully acknowledge the opponent\'s rhetoric ("While my opponent spoke eloquently...")',
            '2. Deploy Wh-Clefts to pivot focus ("What we must actually examine is the empirical foundation...")',
            '3. Deploy It-Clefts for contrast ("It was not the policy, but the execution that failed...")',
            '4. Conclude with philosophical poise.',
          ],
          sampleNativeAudioScript: 'While my opponent spoke with remarkable flair, what we must evaluate is not rhetorical theater, but verifiable facts. What our generation truly needs is not cynical outrage, but principled institutional reform. It was not our collaborative ideals that faltered, but our willingness to enforce them with courage. I urge this assembly to vote for reason and evidence.',
        );
      case 10:
        return const SpeakingChallengeItem(
          title: '60-Second Gate 1 Milestone Sovereign Address',
          contextScenario: 'നിങ്ങൾ 10 ദിവസത്തെ അടിസ്ഥാന ഘട്ടം വിജയകരമായി പൂർത്തിയാക്കി. നിങ്ങളുടെ ഭാവി ഇംഗ്ലീഷ് യാത്രയെക്കുറിച്ച് എക്സിക്യൂട്ടീവ് ശൈലിയിൽ 1 മിനിറ്റ് പ്രസംഗിക്കുക.',
          targetSeconds: 60,
          guidingPoints: [
            '1. Open with gratitude and authority ("Ten unbroken days ago, I began this journey...")',
            '2. Deploy a Mixed Conditional ("If I had surrendered to hesitation, I would not possess this voice today...")',
            '3. Mention key milestones: 100 words, 10 code algorithms, live peer calls.',
            '4. Declare unstoppable momentum for the next 80 days!',
          ],
          sampleNativeAudioScript: 'Ten unbroken days ago, I stood at the threshold of this journey, held back by doubt and fear of imperfection. If I had listened to hesitation, I would not speak with this sovereign authority today. Over these ten days, I have mastered one hundred core vocabulary words, decoded ten linguistic algorithms, and proved that consistency conquers all fear. I have crossed Gate One. My roots are anchored in bedrock, and I am ready to conquer the next eighty days of global fluency!',
        );
      case 11:
        return const SpeakingChallengeItem(
          title: '50-Second Cognitive Metamorphosis Keynote',
          contextScenario: 'Gate 2 ആരംഭത്തിൽ നിങ്ങളുടെ ചിന്താഗതിയിലും സംസാരശൈലിയിലുമുണ്ടായ കാതലായ മാറ്റത്തെക്കുറിച്ച് (Metamorphosis) അന്താരാഷ്ട്ര വേദിയിൽ പ്രസംഗിക്കുക.',
          targetSeconds: 50,
          guidingPoints: [
            '1. Open with a participial clause ("Having crossed Gate 1...")',
            '2. Deploy morphological root vocabulary ("inexorable metamorphosis", "linguistic virtuosity")',
            '3. Contrast past hesitation with present cognitive clarity.',
            '4. Conclude with an indomitable commitment to excellence.',
          ],
          sampleNativeAudioScript: 'Having crossed the foundational threshold of Gate One, I stand here today witnessing an inexorable metamorphosis in my cognitive habits. Language is no longer a clumsy barrier of translation; it has become the sharp instrument through which I perceive and shape my world. Through daily immersion and morphological understanding, my ambition has transcended fear. I commit to linguistic virtuosity with an indomitable spirit, ready to command any room with sovereign clarity.',
        );
      case 12:
        return const SpeakingChallengeItem(
          title: '50-Second Sorbonne Forensic Rebuttal',
          contextScenario: 'ഒരു അന്താരാഷ്ട്ര സംവാദത്തിൽ എതിരാളിയുടെ തെറ്റായ കണക്കുകളെയും വ്യാജ വാദങ്ങളെയും (Specious premises) ശാന്തമായി തകർക്കുക.',
          targetSeconds: 50,
          guidingPoints: [
            '1. Open with respectful concession ("Granted that my colleague spoke with passion...")',
            '2. Pivot to the core flaw ("Yet, let us not permit theatrical rhetoric to disguise fallacious foundations...")',
            '3. Expose the prevarication using surgical perspicacity.',
            '4. Call for verifiable empirical transparency.',
          ],
          sampleNativeAudioScript: 'Distinguished assembly, granted that my colleague presented his proposal with commendable passion, yet we must not allow theatrical rhetoric to obscure empirical reality. The fundamental premise of his argument is entirely fallacious: he equates corporate hegemony with public welfare. When questioned on fiscal oversight, he prevaricates with equivocal generalities. As stewards of the public trust, our perspicacity demands verifiable audit standards rather than specious promises. I urge you to reject this ungrounded motion.',
        );
      case 13:
        return const SpeakingChallengeItem(
          title: '55-Second Cavendish Scientific Abstract Defense',
          contextScenario: 'കേംബ്രിഡ്ജ് റോയൽ അക്കാദമിയിൽ നിങ്ങളുടെ പുതിയ ശാസ്ത്രീയ സിദ്ധാന്തം അവതരിപ്പിച്ച് ചോദ്യങ്ങളെ നേരിടുക.',
          targetSeconds: 55,
          guidingPoints: [
            '1. State the empirical discovery with calm humility.',
            '2. Deploy epistemic hedging ("warrants the inference", "gives credence to").',
            '3. Cite independent laboratory corroboration.',
            '4. Invite peer scrutiny with sovereign poise.',
          ],
          sampleNativeAudioScript: 'Esteemed fellows of the Academy, our laboratory does not seek to overthrow classical neurology with reckless speculation. However, extensive longitudinal neuroimaging across six independent centers strongly corroborates our hypothesis: linguistic neuroplasticity remains remarkably active in adult cognition. Incongruous though our initial anomalous readings appeared, rigorous statistical replication gives undeniable credence to this paradigm shift. True science does not fear skeptical scrutiny; it welcomes it. We place our empirical dataset before you for transparent peer evaluation.',
        );
      case 14:
        return const SpeakingChallengeItem(
          title: '55-Second Geneva Multilateral Summit Address',
          contextScenario: 'ജനീവയിൽ സ്തംഭിച്ചുപോയ 90 രാജ്യങ്ങളുടെ സമുദ്ര ഉടമ്പടി ഒപ്പുവെപ്പിക്കാൻ റെറ്റോറിക്കൽ ഫ്രണ്ടിംഗും ത്രിത്വ താളവും (Tricolon) ഉപയോഗിച്ച് പ്രസംഗിക്കുക.',
          targetSeconds: 55,
          guidingPoints: [
            '1. Front the overarching moral duty ("Front and center before this assembly stands...")',
            '2. Deploy Tricolon Cadence ("We demand X, we require Y, and above all, we safeguard Z")',
            '3. Highlight concomitant responsibility.',
            '4. Call for historic ratification.',
          ],
          sampleNativeAudioScript: 'Front and center before this distinguished plenary assembly stands not the narrow commercial interest of any single nation, but the fragile shared future of humanity\'s oceans. In the crucible of this historic crisis, our citizens demand transparency; our economies require stability; and above all, our children deserve oceans protected from reckless exploitation. Not only does this treaty safeguard national sovereignty, but it also democratizes sustainable maritime commerce, and ultimately cements generational peace. With great diplomatic acumen comes concomitant responsibility. Let us rise above recalcitrant borders and ratify this historic charter today.',
        );
      case 15:
        return const SpeakingChallengeItem(
          title: '60-Second Vienna Diplomatic Crisis Mediation',
          contextScenario: 'വിയന്ന ഡിപ്ലോമാറ്റിക് അക്കാദമിയിൽ രണ്ട് വൻകിട കമ്പനികൾ തമ്മിലുള്ള തർക്കത്തിൽ മാന്യമായി സംസാരിച്ച് ഒത്തുതീർപ്പുണ്ടാക്കുക.',
          targetSeconds: 60,
          guidingPoints: [
            '1. Open with warm diplomatic empathy and high register.',
            '2. Reframe the standoff using circumspect softeners ("Would it be deemed feasible...", "I would be inclined to suggest...").',
            '3. Preserve mutual dignity and commercial parity.',
            '4. Close with sovereign cordiality.',
          ],
          sampleNativeAudioScript: 'Excellencies and esteemed colleagues, I certainly appreciate the urgent commercial priorities and legitimate grievances expressed by both delegations this morning. However, circumspect though we must be regarding fiscal liabilities, rigid ultimatums will only guarantee mutual impoverishment. Would it be deemed feasible to explore an agile, phased cross-licensing framework? I would be inclined to suggest that a thirty-day consultative period, coupled with independent valuation of disputed patents, would accommodate the vital interests of both enterprises. By embracing conversational nuance and mutual concession today, we safeguard decades of profitable collaboration for tomorrow.',
        );
      case 16:
        return const SpeakingChallengeItem(
          title: '60-Second Meridian Crisis Broadcast & Cleft Focus Briefing',
          contextScenario: 'മെറിഡിയൻ പവർ ഗ്രിഡ് തകരാറിലായ സാഹചര്യത്തിൽ പത്രസമ്മേളനത്തിൽ അസത്യങ്ങളെ തിരുത്തി യഥാർത്ഥ കാരണം സമർത്ഥിക്കുക.',
          targetSeconds: 60,
          guidingPoints: [
            '1. Open decisively rejecting rumors using It-Cleft ("It was not... but...").',
            '2. Define the immediate imperative using Wh-Cleft ("What our engineering core requires...").',
            '3. Propose the sole surgical solution using inversion ("Only by decoupling the subgrids...").',
            '4. Close with reassuring institutional confidence.',
          ],
          sampleNativeAudioScript: 'Members of the press and citizens of the Meridian corridor, good evening. I urge you to discount unverified rumors circulating on digital networks. It was not human incompetence or cybersecurity vulnerability, but an unforeseen grid surge following an offshore geomagnetic event that severed our primary transmission telemetry. What this critical infrastructure urgently requires right now is not reactive panic, but disciplined, methodical stabilization. Only by decoupling our secondary subgrids can our senior engineers prevent an irreversible cascading failure. By sunrise tomorrow, power will be systematically restored to all emergency sectors. Our operational integrity remains uncompromised.',
        );
      case 17:
        return const SpeakingChallengeItem(
          title: '60-Second Constitutional Tribunal Plenary Advocacy',
          contextScenario: 'സൂറിച്ച് കോൺസ്റ്റിറ്റ്യൂഷണൽ ട്രിബ്യൂണലിൽ ഡിജിറ്റൽ കുത്തകകൾക്കെതിരെ ശക്തമായ വാദങ്ങൾ പാരലലിസം ഉപയോഗിച്ച് നിരത്തുക.',
          targetSeconds: 60,
          guidingPoints: [
            '1. Open with solemn jurisdictional respect ("May it please the court...").',
            '2. Deploy Antithetical Parallelism ("Not to negotiate... but to defend...").',
            '3. Expose corporate misconduct with Triadic Parallelism ("In their agreements... in their governance... in their rhetoric...").',
            '4. Urge an unshakeable, historic verdict for constitutional liberty.',
          ],
          sampleNativeAudioScript: 'May it please the court. We stand before this august tribunal not to negotiate commercial convenience, but to defend constitutional liberty; not to bow before digital monopolies, but to uphold the inviolable dignity of our citizens; not to fear technological progress, but to subordinate that progress to moral law. In their obfuscation, the defendants offered our public data without truth; in their agreements, they demanded submission without consent; and in their governance, they substituted corporate greed for constitutional rectitude. Just as a grand dome collapses without balanced pillars, so too does democracy crumble when monopolies usurp sovereign law. We urge the bench to uphold the rule of law.',
        );
      case 18:
        return const SpeakingChallengeItem(
          title: '60-Second Grand Empyrean Valedictory Keynote (Gate 2 Culmination)',
          contextScenario: 'സ്വിറ്റ്സർലൻഡിലെ മൗണ്ട് വെരിറ്റയിൽ ഗേറ്റ് 2 പൂർത്തിയാക്കി 200 അന്താരാഷ്ട്ര പ്രതിനിധികൾക്ക് മുന്നിൽ വിടപറയൽ പ്രസംഗം നടത്തുക.',
          targetSeconds: 60,
          guidingPoints: [
            '1. Address the global assembly with sovereign warmth and humility.',
            '2. Deploy the Mixed Conditional Time-Bridge ("If our predecessors had not... we would not...").',
            '3. Proclaim the evolutionary transformation ("What began as a trembling seed...").',
            '4. Launch into Gate 3 with invincible resolution ("Having conquered Gate Two...").',
          ],
          sampleNativeAudioScript: 'Esteemed scholars, mentors, and fellow international delegates: If our predecessors had not braved ridicule and failure in their youth, our civilization would not possess the sovereign democratic institutions we cherish today. And by that same inviolable law: if we had not committed eighteen days ago to conquering our hesitations, rising before sunrise, and transforming our inner thoughts into fluent English, we would not stand in this Grand Empyrean today as masters of global communication. What began as a trembling seed of hesitation has culminated in an unassailable fortress of fluency. Having conquered Gate Two with honor, we now stand poised to command the global arena with courage, empathy, and sovereign poise.',
        );
      default:
        return const SpeakingChallengeItem(
          title: 'Daily Speaking Milestone',
          contextScenario: 'Speak for 30 seconds describing today\'s main achievement.',
          targetSeconds: 30,
          guidingPoints: ['Speak clearly', 'Maintain natural cadence'],
          sampleNativeAudioScript: 'Today I practiced my pronunciation and sentence patterns.',
        );
    }
  }

  // --- ⚡ SOVEREIGN FLUENCY SHORTCUT / KURUKKUVAZHI (Mnemonic Hacks) ---
  static FluencyShortcutItem getFluencyShortcut(int day) {
    switch (day) {
      case 1:
        return const FluencyShortcutItem(
          title: 'The 80/20 Rule: The 10 "Power Verbs" of English',
          malyalamHeading: '⚡ കുറുക്കുവഴി 1: പതിനായിരം വാക്കുകൾ കാണാപാഠം പഠിക്കേണ്ടതില്ല!',
          ruleSummary: 'സ്പോക്കൺ ഇംഗ്ലീഷിലെ 50% സംഭാഷണങ്ങളും വെറും 10 ക്രിയകൾ (Verbs) ഉപയോഗിച്ചാണ് നടക്കുന്നത്: Be, Have, Do, Say, Go, Get, Make, Know, Think, Take.',
          quickHack: '💡 GET എന്ന ഒറ്റ വാക്ക് കൊണ്ട് 5 കാര്യങ്ങൾ പറയാം: \n1. Get it = മനസ്സിലായി (I get it)\n2. Get ready = തയ്യാറാവുക (Get ready soon)\n3. Get a call = കോൾ വരിക (I got a call)\n4. Get there = അവിടെയെത്തുക (When will you get there?)\n5. Get better = മെച്ചപ്പെടുക (Your English is getting better!)',
          examples: [
            'I get it now! (എനിക്കിപ്പോൾ കാര്യം മനസ്സിലായി)',
            'Get ready in five minutes! (5 മിനിറ്റിനുള്ളിൽ റെഡിയാകൂ)',
            'We need to get going! (നമുക്ക് ഉടൻ പുറപ്പെടണം)',
          ],
        );
      case 6:
        return const FluencyShortcutItem(
          title: 'The 3-Second Counterfactual Time-Machine',
          malyalamHeading: '⚡ കുറുക്കുവഴി 6: കഴിഞ്ഞുപോയ തെറ്റുകൾ ഇംഗ്ലീഷിൽ പറയാൻ ഒരു ലളിത ട്രിക്ക്',
          ruleSummary: 'കഴിഞ്ഞ കാര്യത്തെ ഓർത്ത് "അങ്ങനെ ചെയ്തിരുന്നെങ്കിൽ..." എന്ന് പറയാൻ "If I had + [V3], I would have + [V3]" മാത്രം ഓർത്തുവെക്കുക.',
          quickHack: '💡 സംഭാഷണത്തിൽ വേഗത്തിൽ പറയാൻ: "If I\'d known, I\'d have helped." (If I had -> If I\'d, I would have -> I\'d have). ഇത് സംഭാഷണത്തിന്റെ വേഗത ഇരട്ടിയാക്കും!',
          examples: [
            'If I\'d known earlier, I\'d have joined you! (നേരത്തെ അറിഞ്ഞിരുന്നെങ്കിൽ ഞാൻ കൂടെ വന്നേനെ!)',
            'If we\'d planned better, we\'d have saved time! (നന്നായി പ്ലാൻ ചെയ്തിരുന്നെങ്കിൽ സമയം ലാഭിക്കാമായിരുന്നു!)',
          ],
        );
      case 7:
        return const FluencyShortcutItem(
          title: 'The Inversion Oratorical Multiplier',
          malyalamHeading: '⚡ കുറുക്കുവഴി 7: പ്രസംഗത്തിൽ 10x സ്വാധീനം ഉണ്ടാക്കാൻ ഒരു വാക്ക് മുന്നിലിടുക!',
          ruleSummary: 'സാധാരണ വാക്യങ്ങളിൽ \'Never, Rarely, Seldom\' മുന്നിൽ വെച്ച് Auxiliary verb തൊട്ടുപിന്നിൽ കൊണ്ടുവരിക.',
          quickHack: '💡 മാന്ത്രിക ഫോർമുല: "Never have I seen..." അല്ലെങ്കിൽ "Rarely do I meet...". ഇത് കേൾക്കുമ്പോൾ ശ്രോതാക്കൾക്ക് നിങ്ങൾ ഒരു വലിയ പ്രഭാഷകനാണെന്ന പ്രതീതി ഉണ്ടാകും!',
          examples: [
            'Never have I felt so confident! (ഇത്രയും ആത്മവിശ്വാസം എനിക്ക് മുമ്പ് ഒരിക്കലും തോന്നിയിട്ടില്ല!)',
            'Rarely do we see such dedication! (ഇത്രയും അർപ്പണബോധം നമ്മൾ അപൂർവ്വമായേ കാണാറുള്ളൂ!)',
          ],
        );
      case 8:
        return const FluencyShortcutItem(
          title: 'Diplomatic Softeners: The Professional Secret',
          malyalamHeading: '⚡ കുറുക്കുവഴി 8: "No" എന്ന് നേരിട്ട് പറയാതെ മാന്യമായി വിയോജിക്കാൻ',
          ruleSummary: 'നേരിട്ട് എതിർത്തു സംസാരിച്ചാൽ അഹങ്കാരമായി തോന്നും. നയതന്ത്രജ്ഞർ ഉപയോഗിക്കുന്ന സോഫ്റ്റ്നർ പ്രയോഗങ്ങൾ ശീലിക്കുക.',
          quickHack: '💡 "I disagree" എന്നതിന് പകരം:\n1. "I see your point; however, let us explore..."\n2. "I was wondering if we might consider..."\n3. "Be that as it may, our priority is..."',
          examples: [
            'I see your point; however, the timeline is tight. (നിങ്ങൾ പറയുന്നത് ശരിയാണ്; എങ്കിലും സമയം കുറവാണ്.)',
            'I was wondering if we could revise the draft. (ഡ്രാഫ്റ്റ് ഒന്നുകൂടി മാറ്റിയെഴുതാൻ പറ്റുമോ എന്ന് ഞാൻ ആലോചിക്കുകയായിരുന്നു.)',
          ],
        );
      case 9:
        return const FluencyShortcutItem(
          title: 'The "What I..." Laser Anchor',
          malyalamHeading: '⚡ കുറുക്കുവഴി 9: ഇന്റർവ്യൂവിൽ ആലോചിക്കാൻ സമയം കിട്ടാനും ശ്രദ്ധ പിടിച്ചുപറ്റാനും',
          ruleSummary: 'ഒരു ചോദ്യം കിട്ടിയ ഉടൻ മറുപടി കിട്ടാതെ കുഴങ്ങുമ്പോൾ "What I appreciate about this question is..." എന്ന് തുടങ്ങുക.',
          quickHack: '💡 ഈ ഒരൊറ്റ ഫ്രെയ്സ് നിങ്ങൾക്ക് 3 സെക്കൻഡ് ആലോചനയ്ക്കുള്ള സമയം തരും, ഒപ്പം നിങ്ങളുടെ മറുപടി അതീവ പക്വതയുള്ളതുമായി മാറും!',
          examples: [
            'What we truly need to consider is long-term stability. (നമ്മൾ കാര്യമായി പരിഗണിക്കേണ്ടത് ദീർഘകാല സ്ഥിരതയാണ്.)',
            'What I found most valuable was the collaborative spirit. (എനിക്ക് ഏറ്റവും മൂല്യവത്തായി തോന്നിയത് ഒത്തൊരുമയുള്ള മനോഭാവമാണ്.)',
          ],
        );
      case 10:
        return const FluencyShortcutItem(
          title: 'The Mixed Conditional Legacy Frame',
          malyalamHeading: '⚡ കുറുക്കുവഴി 10: "അന്ന് അങ്ങനെ ചെയ്തതുകൊണ്ട് ഇന്ന് ഞാൻ ഇങ്ങനെയായി!"',
          ruleSummary: 'കഴിഞ്ഞ കാല അധ്വാനത്തെ ഇന്നത്തെ വലിയ നേട്ടവുമായി ബന്ധിപ്പിച്ച് സംസാരിക്കാനുള്ള അൾട്ടിമേറ്റ് ഫോർമുല.',
          quickHack: '💡 "If I hadn\'t started 10 days ago, I wouldn\'t be standing here today!" ഈ വാക്യം നിങ്ങളുടെ യാത്രയുടെ വിജയം പ്രഖ്യാപിക്കാൻ തികച്ചും അനുയോജ്യമാണ്.',
          examples: [
            'If I hadn\'t practiced daily, I wouldn\'t be speaking like this today! (ദിവസവും പരിശീലിച്ചില്ലായിരുന്നെങ്കിൽ ഇന്ന് ഞാൻ ഇങ്ങനെ സംസാരിക്കില്ലായിരുന്നു!)',
            'If we hadn\'t taken the risk, we wouldn\'t lead the market today! (അന്ന് റിസ്ക് എടുത്തില്ലായിരുന്നെങ്കിൽ ഇന്ന് നമ്മൾ മാർക്കറ്റ് നയിക്കില്ലായിരുന്നു!)',
          ],
        );
      case 11:
        return const FluencyShortcutItem(
          title: 'The Latin-Greek Morphological Root Compass',
          malyalamHeading: '⚡ കുറുക്കുവഴി 11: ഗ്രീക്ക് & ലാറ്റിൻ റൂട്ട് മാട്രിക്സ് ഉപയോഗിച്ച് 100 വാക്കുകൾ ഞൊടിയിടയിൽ മനസ്സിലാക്കാം!',
          ruleSummary: 'വാക്കുകളെ തുണ്ടുകളാക്കി മുറിച്ചു പഠിക്കുക: TRANS- (Across), INTER- (Between), CON- (Together), CIRCUM- (Around).',
          quickHack: '💡 "TRANS" എന്നാൽ "മറുകര കടക്കുക/അപ്പുറത്തേക്ക്":\n1. Transcend = പരിമിതികളെ മറികടക്കുക (Transcend limits)\n2. Transform = രൂപം മാറ്റുക (Transform thoughts)\n3. Translate = ഒരു ഭാഷയിൽ നിന്ന് മറ്റൊന്നിലേക്ക് കടക്കുക\n4. Transparent = പ്രകാശം അപ്പുറത്തേക്ക് കടക്കുന്നത് (വ്യക്തമായത്)',
          examples: [
            'Daily practice allows you to transcend linguistic barriers! (നിത്യേനയുള്ള പരിശീലനം ഭാഷാപരമായ തടസ്സങ്ങളെ അതിജീവിക്കാൻ സഹായിക്കുന്നു!)',
            'Consistent immersion transforms your confidence completely! (ചിട്ടയായ പരിശീലനം നിങ്ങളുടെ ആത്മവിശ്വാസത്തെ അടിമുടി മാറ്റുന്നു!)',
          ],
        );
      case 12:
        return const FluencyShortcutItem(
          title: 'The 3-Step Concession Pivot',
          malyalamHeading: '⚡ കുറുക്കുവഴി 12: തർക്കങ്ങളിൽ ആരെയും പ്രകോപിപ്പിക്കാതെ ജയിക്കാൻ ഒരു മാന്ത്രിക ട്രിക്ക്',
          ruleSummary: 'എതിരാളിയെ ബഹുമാനിച്ചു കൊണ്ട് അവരുടെ തെറ്റായ വാദത്തെ തകർക്കാൻ "Granted that [A]... yet [B]... therefore [C]..." ഉപയോഗിക്കുക.',
          quickHack: '💡 മറ്റൊരാളുടെ വാദത്തെ നേരിട്ട് "You are wrong" എന്ന് വിളിക്കുന്നതിന് പകരം "Granted that..." എന്ന് പറഞ്ഞുതുടങ്ങുക. അവർ തങ്ങളുടെ വാദം അംഗീകരിക്കപ്പെട്ടു എന്ന് കരുതി ശാന്തരാകും. തൊട്ടടുത്ത നിമിഷം "yet..." വെച്ച് നിങ്ങളുടെ സത്യം സമർപ്പിക്കുക!',
          examples: [
            'Granted that the price is lower, yet the durability is poor. (വില കുറവാണെന്നത് ശരിയാണ്; എങ്കിലും ഈട് വളരെ കുറവാണ്.)',
            'Granted that the idea is creative, yet we lack the budget. (ആശയം പുതുമയുള്ളതാണെന്നത് ശരിയാണ്; എങ്കിലും നമ്മുടെ പക്കൽ ബഡ്ജറ്റില്ല.)',
          ],
        );
      case 13:
        return const FluencyShortcutItem(
          title: 'The Epistemic Trinity: Sound Like an Expert',
          malyalamHeading: '⚡ കുറുക്കുവഴി 13: "I think / Maybe" ഒഴിവാക്കി ലോകോത്തര ഗവേഷകനെപ്പോലെ സംസാരിക്കാൻ',
          ruleSummary: 'ഇന്റർവ്യൂവിലും മീറ്റിംഗിലും "I think" എന്ന് ആവർത്തിച്ച് സ്വയം ബലഹീനനാക്കരുത്.',
          quickHack: '💡 പകരം ഈ 3 ഫോർമുലകൾ ഉപയോഗിക്കുക:\n1. "The empirical data suggests that..." (തെളിവുകൾ സൂചിപ്പിക്കുന്നത്...)\n2. "It appears highly probable that..." (ഇങ്ങനെയാകാനാണ് കൂടുതൽ സാധ്യത...)\n3. "We can reasonably deduce that..." (നമുക്ക് യുക്തിസഹമായി അനുമാനിക്കാം...)',
          examples: [
            'The evidence suggests that daily immersion accelerates fluency. (തെളിവുകൾ വ്യക്തമാക്കുന്നത് ദിവസേനയുള്ള പരിശീലനം വേഗത കൂട്ടുന്നു എന്നാണ്.)',
            'It appears probable that our strategy will yield substantial results. (നമ്മുടെ തന്ത്രം മികച്ച ഫലങ്ങൾ നൽകാനാണ് സാധ്യത.)',
          ],
        );
      case 14:
        return const FluencyShortcutItem(
          title: 'The Rhetorical Fronting Multiplier',
          malyalamHeading: '⚡ കുറുക്കുവഴി 14: പ്രസംഗത്തിൽ വിസ്മയം സൃഷ്ടിക്കാൻ വാക്യത്തിന്റെ ക്രമം തലതിരിച്ചിടുക!',
          ruleSummary: 'സാധാരണ വാക്യം: "Our commitment to truth stands here." ഇൻവേർഷൻ വാക്യം: "Front and center stands our commitment to truth!"',
          quickHack: '💡 സ്ഥലത്തെയോ വികാരത്തെയോ കാണിക്കുന്ന വാക്കുകൾ വാക്യത്തിന്റെ തുടക്കത്തിലേക്ക് കൊണ്ടുവരിക. ഇത് കേൾവിക്കാരെ ഞെട്ടിക്കുകയും നിങ്ങളുടെ പ്രസംഗത്തിന് ഗംഭീര പ്രൗഢി നൽകുകയും ചെയ്യും!',
          examples: [
            'Front and center stands our duty to the community. (സമൂഹത്തോടുള്ള നമ്മുടെ കടമയാണ് സർവ്വപ്രധാനമായി മുൻപന്തിയിൽ നിൽക്കുന്നത്.)',
            'Behind every great achievement lies relentless discipline. (എല്ലാ മഹത്തായ നേട്ടങ്ങൾക്ക് പിന്നിലും അക്ഷീണമായ അച്ചടക്കമുണ്ട്.)',
          ],
        );
      case 15:
        return const FluencyShortcutItem(
          title: 'The 4 Diplomatic Softener Shields',
          malyalamHeading: '⚡ കുറുക്കുവഴി 15: അന്താരാഷ്ട്ര നയതന്ത്രജ്ഞർ ഉപയോഗിക്കുന്ന 4 സോഫ്റ്റ്നർ കവചങ്ങൾ',
          ruleSummary: 'മറ്റുള്ളവരോട് വിയോജിക്കുമ്പോഴും പുതിയ കാര്യം ആവശ്യപ്പെടുമ്പോഴും ബന്ധങ്ങൾ വഷളാകാതെ കാത്തുസൂക്ഷിക്കാൻ.',
          quickHack: '💡 ഈ 4 പ്രയോഗങ്ങൾ ശീലിക്കുക:\n1. "I was wondering if we might..." (നമുക്ക് ഇങ്ങനെ ചെയ്തുകൂടെ എന്ന് ഞാൻ ആലോചിക്കുകയായിരുന്നു)\n2. "Would it be deemed feasible to..." (ഇത് പ്രായോഗികമായി പരിഗണിക്കാൻ സാധിക്കുമോ?)\n3. "I would be inclined to suggest that..." (ഞാൻ ഇങ്ങനെ നിർദ്ദേശിക്കാൻ ആഗ്രഹിക്കുന്നു)\n4. "Circumspect though we must be..." (നമ്മൾ ജാഗ്രത പാലിക്കേണ്ടതുണ്ടെങ്കിലും...)',
          examples: [
            'I was wondering if we might reschedule our call. (നമുക്ക് കോൾ മറ്റൊരു സമയത്തേക്ക് മാറ്റിവെക്കാൻ പറ്റുമോ എന്ന് ഞാൻ ആലോചിക്കുകയായിരുന്നു.)',
            'Would it be deemed feasible to adjust the deadline? (ഡെഡ്‌ലൈൻ അല്പം നീട്ടിനൽകുന്നത് പ്രായോഗികമായി സാധിക്കുമോ?)',
          ],
        );
      case 16:
        return const FluencyShortcutItem(
          title: 'The Cleft Saliency Filter: Spotlight What Truly Matters',
          malyalamHeading: '⚡ കുറുക്കുവഴി 16: അനാവശ്യ തർക്കങ്ങളിൽ സമയം കളയാതെ യഥാർത്ഥ കാരണം സമർത്ഥിക്കാൻ',
          ruleSummary: '"It was not [A], but [B]" അല്ലെങ്കിൽ "What we need is [X]" ഉപയോഗിച്ച് മുഴുവൻ ശ്രദ്ധയും നിങ്ങളുടെ പ്രധാന പോയിന്റിലേക്ക് തിരിക്കുക.',
          quickHack: '💡 സാധാരണ വാക്യം: "A grid surge caused the problem." ക്ലെഫ്റ്റ് മാജിക്: "It was not incompetence, but an unprecedented grid surge that caused the problem!" ഇത് കേൾക്കുമ്പോൾ നിങ്ങളുടെ വിശദീകരണത്തിന് ഔദ്യോഗിക ഗൗരവം വരും!',
          examples: [
            'It was not the price, but the quality that won the contract. (വിലയല്ല, ഗുണനിലവാരമാണ് ആ കോൺട്രാക്റ്റ് നേടിത്തന്നത്.)',
            'What we need right now is calm execution. (നമുക്ക് ഇപ്പോൾ ആവശ്യമുള്ളത് ശാന്തമായ പ്രവർത്തനമാണ്.)',
          ],
        );
      case 17:
        return const FluencyShortcutItem(
          title: 'The Symmetrical Parallelism Cadence',
          malyalamHeading: '⚡ കുറുക്കുവഴി 17: വാക്യങ്ങൾക്ക് ഇരട്ടത്താളം നൽകി ശ്രോതാക്കളുടെ മനസ്സിൽ തറയ്ക്കാൻ',
          ruleSummary: '"Not to [Verb 1], but to [Verb 2]" എന്ന ആവർത്തന ഘടന ഉപയോഗിച്ച് വാദമുഖങ്ങൾക്ക് കവിതയുടെ താളം നൽകുക.',
          quickHack: '💡 "Not to negotiate, but to defend; not to bow, but to uphold." ഒരേ വ്യാകരണ ഘടന രണ്ടുതവണ ആവർത്തിക്കുമ്പോൾ കേൾവിക്കാരന് അത് ജീവിതത്തിൽ മറക്കാൻ കഴിയില്ല!',
          examples: [
            'We practice not to impress, but to conquer. (നമ്മൾ പരിശീലിക്കുന്നത് ആളുകളെ ബോധിപ്പിക്കാനല്ല, മനസ്സിനെ കീഴടക്കാനാണ്.)',
            'In their words, they promised hope; in their deeds, they delivered despair. (വാക്കുകളിൽ അവർ പ്രതീക്ഷ നൽകി; പ്രവൃത്തികളിൽ അവർ നിരാശ നൽകി.)',
          ],
        );
      case 18:
        return const FluencyShortcutItem(
          title: 'The Sovereign Time-Bridge: Celebrate Your Evolution',
          malyalamHeading: '⚡ കുറുക്കുവഴി 18: ഗേറ്റ് 2 പൂർത്തിയാക്കുമ്പോൾ ജീവിതത്തിലെ വലിയ മാറ്റം പ്രഖ്യാപിക്കാൻ',
          ruleSummary: '"What began as [A] has culminated in [B]!" എന്ന ഒറ്റ വാക്യം നിങ്ങളുടെ 18 ദിവസത്തെ അദ്ധ്വാനത്തെ രാജകീയമായി പ്രഖ്യാപിക്കുന്നു.',
          quickHack: '💡 മിക്സഡ് കണ്ടീഷണൽ മാജിക്: "If I hadn\'t committed on Day 1, I wouldn\'t stand here today!" ഇത് നിങ്ങളുടെ ഇംഗ്ലീഷ് ഭാഷണത്തിന് ലോകോത്തര പ്രഭാഷകന്റെ പക്വത നൽകുന്നു.',
          examples: [
            'What began as a hesitation has culminated in sovereign fluency! (ഒരു ചെറിയ മടിയോടെ തുടങ്ങിയത് ഇതാ പരമാധികാരമുള്ള ഇംഗ്ലീഷ് പ്രാവീണ്യമായി മാറിയിരിക്കുന്നു!)',
            'Having conquered Gate Two, we now stand poised to command the global arena! (രണ്ടാം ഘട്ടം കീഴടക്കിക്കഴിഞ്ഞ ഞങ്ങൾ ആഗോളവേദി നയിക്കാൻ സജ്ജരായിരിക്കുന്നു!)',
          ],
        );
      default:
        return const FluencyShortcutItem(
          title: 'The Connector Shortcut',
          malyalamHeading: '⚡ കുറുക്കുവഴി: ഗോൾഡൻ കണക്ടറുകൾ',
          ruleSummary: 'Use connectors to link thoughts smoothly.',
          quickHack: 'Use "However" instead of "But" to sound professional.',
          examples: ['I was tired; however, I finished my lesson.'],
        );
    }
  }
}
