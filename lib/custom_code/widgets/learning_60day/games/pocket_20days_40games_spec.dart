/// 🎮 40 GAME SPECIFICATIONS FOR DAYS 1 TO 20 (2 GAMES PER DAY)
///
/// Designed for Pocket Mates 90-Day Gamified English System.
/// Every day features two distinct gameplay mechanics following arcade styles:
/// - Runner (Subway Surfers style)
/// - Drive / Vehicle navigation
/// - Shooter / Target hitting
/// - Falling blocks / Tetris style
/// - Diving / Flying / Archery / Defense
enum GameGenre {
  runner,
  fallingBlocks,
  driving,
  shooting,
  diving,
  slashing,
  collecting,
  trainTracking,
  jumping,
  archery,
  boating,
  castleDefense,
  detective,
  skySelection,
  flying,
  survival,
  arcadeMemory,
}

class DayGameSpec {
  final int day;
  final int gameIndex; // 1 or 2
  final String title;
  final String emoji;
  final GameGenre genre;
  final String englishTarget;
  final String descriptionEn;
  final String descriptionMl;
  final String controlMechanism;

  const DayGameSpec({
    required this.day,
    required this.gameIndex,
    required this.title,
    required this.emoji,
    required this.genre,
    required this.englishTarget,
    required this.descriptionEn,
    required this.descriptionMl,
    required this.controlMechanism,
  });
}

class Pocket20Days40GamesRegistry {
  static const List<DayGameSpec> allGames = [
    // DAY 1
    DayGameSpec(
      day: 1,
      gameIndex: 1,
      title: 'Letter Hunt Run',
      emoji: '🔤',
      genre: GameGenre.runner,
      englishTarget: 'Letter Recognition (A-Z) & First Sounds',
      descriptionEn: 'Endless runner where you jump and slide to collect target letters.',
      descriptionMl: 'ഓടിപ്പോയിക്കൊണ്ട് ശരിയായ അക്ഷരങ്ങൾ ചാടിപ്പിടിക്കുന്ന ഗെയിം.',
      controlMechanism: 'Swipe Left/Right/Up to jump and grab letters',
    ),
    DayGameSpec(
      day: 1,
      gameIndex: 2,
      title: 'Falling Letters',
      emoji: '🎈',
      genre: GameGenre.fallingBlocks,
      englishTarget: 'Letter & Word Matching',
      descriptionEn: 'Letters fall like balloons; pop or catch the one called out by voice.',
      descriptionMl: 'മേലെ നിന്ന് വീഴുന്ന അക്ഷരങ്ങളിൽ പറഞ്ഞത് മാത്രം ടാപ്പ് ചെയ്യുക.',
      controlMechanism: 'Tap falling letter balloon before it hits ground',
    ),

    // DAY 2
    DayGameSpec(
      day: 2,
      gameIndex: 1,
      title: 'Word Drive',
      emoji: '🚗',
      genre: GameGenre.driving,
      englishTarget: 'Basic Everyday Nouns (Car, Road, Tree)',
      descriptionEn: 'Steer your car into the lane that has the correct word sign.',
      descriptionMl: 'ശരിയായ വാക്കുള്ള വഴിയിലേക്ക് കാർ തിരിച്ചു ഡ്രൈവ് ചെയ്യുക.',
      controlMechanism: 'Tilt or Tap left/right to switch driving lanes',
    ),
    DayGameSpec(
      day: 2,
      gameIndex: 2,
      title: 'Shoot the Correct Word',
      emoji: '🎯',
      genre: GameGenre.shooting,
      englishTarget: 'Pronunciation & Target Shooting',
      descriptionEn: 'Aim and shoot the target displaying the word you heard.',
      descriptionMl: 'കേട്ട വാക്ക് ഉള്ള ടാർഗറ്റിലേക്ക് കൃത്യമായി വെടിവെക്കുക.',
      controlMechanism: 'Crosshair drag & release to shoot',
    ),

    // DAY 3
    DayGameSpec(
      day: 3,
      gameIndex: 1,
      title: 'Submarine Word Dive',
      emoji: '🐠',
      genre: GameGenre.diving,
      englishTarget: 'Action Verbs (Swim, Dive, See)',
      descriptionEn: 'Pilot a mini submarine underwater avoiding sea obstacles to collect verbs.',
      descriptionMl: 'വെള്ളത്തിനടിയിൽ നീന്തി ശരിയായ വെർബ് വാക്കുകൾ കളക്റ്റ് ചെയ്യുക.',
      controlMechanism: 'Hold screen to dive, release to float up',
    ),
    DayGameSpec(
      day: 3,
      gameIndex: 2,
      title: 'Word Catcher',
      emoji: '🧩',
      genre: GameGenre.collecting,
      englishTarget: 'Object Categories (Food, Drinks, Clothes)',
      descriptionEn: 'Catch correct falling word bubbles with your basket.',
      descriptionMl: 'ബാസ്കറ്റ് അങ്ങോട്ടുമിങ്ങോട്ടും നീക്കി ശരിയായ വാക്കുകൾ പിടിക്കുക.',
      controlMechanism: 'Drag basket horizontally along bottom',
    ),

    // DAY 4
    DayGameSpec(
      day: 4,
      gameIndex: 1,
      title: 'English Runner',
      emoji: '🏃',
      genre: GameGenre.runner,
      englishTarget: 'Pronouns (I, You, He, She, We)',
      descriptionEn: 'Subway style 3-lane runner dodging obstacles to assemble pronouns.',
      descriptionMl: 'ട്രാക്കിലൂടെ ഓടി പ്രൊനൗണുകൾ കളക്റ്റ് ചെയ്യുന്ന സബ്‌വേ സർഫ് സ്റ്റൈൽ.',
      controlMechanism: 'Swipe 3 lanes (Left, Center, Right)',
    ),
    DayGameSpec(
      day: 4,
      gameIndex: 2,
      title: 'Letter Slash',
      emoji: '⚔️',
      genre: GameGenre.slashing,
      englishTarget: 'Spelling & Syllables',
      descriptionEn: 'Fruit-ninja style slashing through letters to build the word.',
      descriptionMl: 'മുകളിലേക്ക് തെറിക്കുന്ന അക്ഷരങ്ങൾ വെട്ടി വാക്ക് ഉണ്ടാക്കുക.',
      controlMechanism: 'Swipe finger across flying letters',
    ),

    // DAY 5
    DayGameSpec(
      day: 5,
      gameIndex: 1,
      title: 'Sky Word Collector',
      emoji: '☁️',
      genre: GameGenre.collecting,
      englishTarget: 'Adjectives (Big, Small, Fast, Slow)',
      descriptionEn: 'Fly in the clouds collecting golden adjectives while avoiding storm clouds.',
      descriptionMl: 'ആകാശത്തിലൂടെ പറന്ന് ശരിയായ വിശേഷണ വാക്കുകൾ ശേഖരിക്കുക.',
      controlMechanism: 'Joy-pad fly control up/down/left/right',
    ),
    DayGameSpec(
      day: 5,
      gameIndex: 2,
      title: 'Pop the Correct Word',
      emoji: '🎈',
      genre: GameGenre.shooting,
      englishTarget: 'Synonyms & Quick Thinking',
      descriptionEn: 'Balloons float up with words; pop the matching synonym.',
      descriptionMl: 'മുകളിലേക്ക് പോകുന്ന ബലൂണുകളിൽ ശരിയായത് പെട്ടെന്ന് പൊട്ടിക്കുക.',
      controlMechanism: 'Tap matching balloons rapidly',
    ),

    // DAY 6
    DayGameSpec(
      day: 6,
      gameIndex: 1,
      title: 'Sentence Train',
      emoji: '🚂',
      genre: GameGenre.trainTracking,
      englishTarget: 'Sentence Ordering (Subject + Verb + Object)',
      descriptionEn: 'Attach train wagons in the correct grammatical order to deliver the sentence.',
      descriptionMl: 'ശരിയായ വാക്യം നിർമ്മിക്കാൻ ട്രെയിന്റെ ബോഗികൾ ഓർഡറിൽ കൂട്ടിച്ചേർക്കുക.',
      controlMechanism: 'Drag and snap wagons to the engine',
    ),
    DayGameSpec(
      day: 6,
      gameIndex: 2,
      title: 'Falling Word Blocks',
      emoji: '🧱',
      genre: GameGenre.fallingBlocks,
      englishTarget: 'Prepositions (In, On, At, Under)',
      descriptionEn: 'Tetris-style falling grammar blocks. Drop into the correct slot.',
      descriptionMl: 'ടെട്രിസ് പോലെ വീഴുന്ന കട്ടകൾ ശരിയായ സ്ഥാനത്ത് ഇറക്കിവെക്കുക.',
      controlMechanism: 'Move left/right and drop block',
    ),

    // DAY 7
    DayGameSpec(
      day: 7,
      gameIndex: 1,
      title: 'Jump & Choose',
      emoji: '🛹',
      genre: GameGenre.jumping,
      englishTarget: 'Helping Verbs (Is, Am, Are)',
      descriptionEn: 'Skateboarder jumps over ramps landing on the correct verb platform.',
      descriptionMl: 'സ്കേറ്റ് ബോർഡിൽ ചാടി ശരിയായ ഹെൽപ്പിംഗ് വെർബ് പ്ലാറ്റ്ഫോമിൽ ലാൻഡ് ചെയ്യുക.',
      controlMechanism: 'Time jump tap to reach platform',
    ),
    DayGameSpec(
      day: 7,
      gameIndex: 2,
      title: 'Throw & Match',
      emoji: '🪃',
      genre: GameGenre.shooting,
      englishTarget: 'Question Words (What, Where, When, Who)',
      descriptionEn: 'Throw boomerang at the floating answer matching the question prompt.',
      descriptionMl: 'ചോദ്യത്തിന് അനുയോജ്യമായ ഉത്തരത്തിലേക്ക് ബൂമറാങ് എറിയുക.',
      controlMechanism: 'Aim and fling boomerang',
    ),

    // DAY 8
    DayGameSpec(
      day: 8,
      gameIndex: 1,
      title: 'Taxi Conversation',
      emoji: '🚕',
      genre: GameGenre.driving,
      englishTarget: 'Asking Directions & Travel Dialogues',
      descriptionEn: 'Drive a city taxi while picking passengers and picking conversational replies.',
      descriptionMl: 'ടാക്സി ഓടിക്കുന്നതിനിടയിൽ യാത്രക്കാരുടെ ചോദ്യങ്ങൾക്ക് ഇംഗ്ലീഷിൽ മറുപടി നൽകുക.',
      controlMechanism: 'Drive controls + Quick dialog option select',
    ),
    DayGameSpec(
      day: 8,
      gameIndex: 2,
      title: 'Grammar Traffic',
      emoji: '🚦',
      genre: GameGenre.arcadeMemory,
      englishTarget: 'Tense Rules: Past vs Present (Do vs Did)',
      descriptionEn: 'Control traffic lights; green only when the sentence tense is correct!',
      descriptionMl: 'വാക്യം ശരിയാണെങ്കിൽ മാത്രം ട്രാഫിക് ലൈറ്റ് പച്ചയാക്കി വണ്ടികൾ കടത്തിവിടുക.',
      controlMechanism: 'Tap signal toggle (Red/Green)',
    ),

    // DAY 9
    DayGameSpec(
      day: 9,
      gameIndex: 1,
      title: 'Rocket Word Rescue',
      emoji: '🚀',
      genre: GameGenre.flying,
      englishTarget: 'Space Vocabulary & Daily Verbs',
      descriptionEn: 'Fly a rescue rocket through space dodging meteors to rescue letters.',
      descriptionMl: 'ഉൽക്കകൾ ഒഴിവാക്കി ആകാശത്തിലൂടെ റോക്കറ്റ് പറത്തി അക്ഷരങ്ങൾ രക്ഷിക്കുക.',
      controlMechanism: 'Thrust buttons and tilt steering',
    ),
    DayGameSpec(
      day: 9,
      gameIndex: 2,
      title: 'Avoid & Answer',
      emoji: '☄️',
      genre: GameGenre.arcadeMemory,
      englishTarget: 'Speed Grammar Choice',
      descriptionEn: 'Dodge obstacles while picking the grammatically correct orb.',
      descriptionMl: 'തടസ്സങ്ങൾ ഒഴിവാക്കി ശരിയായ ഓർബ് തിരഞ്ഞെടുക്കുക.',
      controlMechanism: 'Swipe dodge + tap choice',
    ),

    // DAY 10
    DayGameSpec(
      day: 10,
      gameIndex: 1,
      title: 'Sentence Archery',
      emoji: '🏹',
      genre: GameGenre.archery,
      englishTarget: 'Negative Sentences (Do not, Cannot, Will not)',
      descriptionEn: 'Draw your bow and shoot the moving bullseye with the right negative word.',
      descriptionMl: 'വില്ലു കുലച്ച് ശരിയായ വാക്കുള്ള ടാർഗറ്റിലേക്ക് അമ്പ് എയ്യുക.',
      controlMechanism: 'Pull back string, aim crosshair, release',
    ),
    DayGameSpec(
      day: 10,
      gameIndex: 2,
      title: 'Vocabulary Coin Run',
      emoji: '🪙',
      genre: GameGenre.runner,
      englishTarget: 'Financial & Market Words (Price, Buy, Cost)',
      descriptionEn: 'Run through a bustling market alley collecting coins of translated items.',
      descriptionMl: 'മാർക്കറ്റിലൂടെ ഓടി ശരിയായ നാണയങ്ങളും വാക്കുകളും ശേഖരിക്കുക.',
      controlMechanism: 'Runner swipe left/right',
    ),

    // DAY 11
    DayGameSpec(
      day: 11,
      gameIndex: 1,
      title: 'Speed Boat English',
      emoji: '🚤',
      genre: GameGenre.boating,
      englishTarget: 'Comparative Adjectives (Faster, Bigger, Higher)',
      descriptionEn: 'Race a speedboat through water gates displaying correct comparative adjectives.',
      descriptionMl: 'സ്പീഡ് ബോട്ട് ഓടിച്ച് ശരിയായ കവാടങ്ങളിലൂടെ കടന്നുപോകുക.',
      controlMechanism: 'Steer rudder left/right',
    ),
    DayGameSpec(
      day: 11,
      gameIndex: 2,
      title: 'Wave Word Survivor',
      emoji: '🌊',
      genre: GameGenre.survival,
      englishTarget: 'Emergency & Urgent Phrases (Help, Stop, Wait)',
      descriptionEn: 'Survive ocean waves by reacting to voiced instructions within 3 seconds.',
      descriptionMl: 'സമുദ്രത്തിലെ തിരമാലകളിൽ നിർദ്ദേശങ്ങൾ പെട്ടെന്ന് കേട്ട് പ്രതികരിക്കുക.',
      controlMechanism: 'Quick-time action button tap',
    ),

    // DAY 12
    DayGameSpec(
      day: 12,
      gameIndex: 1,
      title: 'English Castle Defense',
      emoji: '🏰',
      genre: GameGenre.castleDefense,
      englishTarget: 'Defensive Grammar Shields (Subject-Verb Agreement)',
      descriptionEn: 'Defend castle gates against enemy orcs by launching correct grammar spells.',
      descriptionMl: 'ശരിയായ വ്യാകരണ മന്ത്രങ്ങൾ ചൊല്ലി ശത്രുക്കളിൽ നിന്ന് കോട്ട സംരക്ഷിക്കുക.',
      controlMechanism: 'Tap lane to cast defensive shield spell',
    ),
    DayGameSpec(
      day: 12,
      gameIndex: 2,
      title: 'Grammar Knight',
      emoji: '⚔️',
      genre: GameGenre.slashing,
      englishTarget: 'Past Participles (Gone, Eaten, Done, Seen)',
      descriptionEn: 'Sword-wielding knight battles monsters by slicing the irregular past verb.',
      descriptionMl: 'ശത്രുവിനെ വാളുകൊണ്ട് നേരിട്ട് പാസ്റ്റ് പാർട്ടിസിപ്പിൾ തെളിയിക്കുക.',
      controlMechanism: 'Slash swipe gestures',
    ),

    // DAY 13
    DayGameSpec(
      day: 13,
      gameIndex: 1,
      title: 'Word Detective',
      emoji: '🕵️',
      genre: GameGenre.detective,
      englishTarget: 'Clue Reading & Deductive Thinking',
      descriptionEn: 'Investigate a crime scene room reading text clues to find hidden words.',
      descriptionMl: 'ക്ലൂകൾ വായിച്ച് റൂമിൽ ഒളിഞ്ഞിരിക്കുന്ന തെളിവുകളും വാക്കുകളും കണ്ടെത്തുക.',
      controlMechanism: 'Magnifying glass pan and tap',
    ),
    DayGameSpec(
      day: 13,
      gameIndex: 2,
      title: 'Hidden Word World',
      emoji: '🔎',
      genre: GameGenre.detective,
      englishTarget: 'Compound Words (Sun + Flower = Sunflower)',
      descriptionEn: 'Spot hidden compound words concealed within illustrated environment.',
      descriptionMl: 'ചിത്രത്തിൽ ഒളിഞ്ഞിരിക്കുന്ന കോമ്പൗണ്ട് വാക്കുകൾ സ്പോട്ട് ചെയ്യുക.',
      controlMechanism: 'Pinch-zoom and tap discovery',
    ),

    // DAY 14
    DayGameSpec(
      day: 14,
      gameIndex: 1,
      title: 'Sky Selection',
      emoji: '🚁',
      genre: GameGenre.flying,
      englishTarget: 'Modal Verbs (Can, Could, Should, Must)',
      descriptionEn: 'Fly a helicopter dropping cargo only on the helipad with the right modal verb.',
      descriptionMl: 'ഹെലികോപ്റ്റർ പറത്തി ശരിയായ മോഡൽ വെർബ് ഹെലിപാഡിൽ ലാൻഡ് ചെയ്യുക.',
      controlMechanism: 'Altitude thrust & landing tap',
    ),
    DayGameSpec(
      day: 14,
      gameIndex: 2,
      title: 'Parachute Word Drop',
      emoji: '🪂',
      genre: GameGenre.fallingBlocks,
      englishTarget: 'Adverb Matching (Quickly, Slowly, Happily)',
      descriptionEn: 'Paratroopers fall from sky; steer your parachute onto the adverb target.',
      descriptionMl: 'പാരഷൂട്ടിൽ ഇറങ്ങി ശരിയായ ലക്ഷ്യസ്ഥാനത്ത് ലാൻഡ് ചെയ്യുക.',
      controlMechanism: 'Tilt left/right to steer parachute drift',
    ),

    // DAY 15
    DayGameSpec(
      day: 15,
      gameIndex: 1,
      title: 'Ice Path Grammar',
      emoji: '🧊',
      genre: GameGenre.jumping,
      englishTarget: 'Conjunctions (And, But, Because, Although)',
      descriptionEn: 'Hop across melting ice floes. Step only on floes with valid connectors!',
      descriptionMl: 'ശരിയായ കണക്റ്റിംഗ് വേഡ്സ് ഉള്ള മഞ്ഞുകട്ടകളിൽ മാത്രം ചവിട്ടി മറുകരയെത്തുക.',
      controlMechanism: 'Tap target ice block to hop forward',
    ),
    DayGameSpec(
      day: 15,
      gameIndex: 2,
      title: 'Fire Escape English',
      emoji: '🔥',
      genre: GameGenre.runner,
      englishTarget: 'Emergency Action Verbs (Run, Climb, Extinguish)',
      descriptionEn: 'Climb ladders and cross bridges escaping fire by answering quickly.',
      descriptionMl: 'തീയിൽ നിന്ന് രക്ഷപ്പെടാൻ നിർദ്ദേശങ്ങൾ വേഗത്തിൽ തിരഞ്ഞെടുക്കുക.',
      controlMechanism: 'Climb up/down swipe controls',
    ),

    // DAY 16
    DayGameSpec(
      day: 16,
      gameIndex: 1,
      title: 'Dragon Word Chase',
      emoji: '🐉',
      genre: GameGenre.runner,
      englishTarget: 'Storytelling Vocabulary & Fantasy Words',
      descriptionEn: 'Ride a winged dragon chasing down stolen magical words across mountain peaks.',
      descriptionMl: 'ഡ്രാഗന്റെ പുറത്തു കയറി മലനിരകളിലൂടെ ശരിയായ വാക്കുകൾ പിന്തുടർന്ന് പിടിക്കുക.',
      controlMechanism: 'Continuous flight tilt & fire breath tap',
    ),
    DayGameSpec(
      day: 16,
      gameIndex: 2,
      title: 'Flying Target English',
      emoji: '🎯',
      genre: GameGenre.shooting,
      englishTarget: 'Time Expressions (Yesterday, Tomorrow, Nowadays)',
      descriptionEn: 'Discs fly across the screen; shoot only those referencing the correct time.',
      descriptionMl: 'ആകാശത്തുകൂടി പറന്നുപോകുന്ന ടാർഗറ്റുകളിൽ ശരിയായ സമയവാക്കുകൾ വെടിവെച്ചിടുക.',
      controlMechanism: 'Clay pigeon style drag and fire',
    ),

    // DAY 17
    DayGameSpec(
      day: 17,
      gameIndex: 1,
      title: 'Turbo Grammar Race',
      emoji: '🏎️',
      genre: GameGenre.driving,
      englishTarget: 'Question Tags (Isn\'t it?, Don\'t you?, Aren\'t they?)',
      descriptionEn: 'Formula 1 racing circuit; overtake rivals by answering question tags at turns.',
      descriptionMl: 'റേസിംഗ് ട്രാക്കിൽ വളവുകളിൽ ക്വസ്റ്റ്യൻ ടാഗുകൾ കറക്റ്റാക്കി എതിരാളികളെ മറികടക്കുക.',
      controlMechanism: 'Steering wheel drag + turbo boost button',
    ),
    DayGameSpec(
      day: 17,
      gameIndex: 2,
      title: 'Wrong Lane Challenge',
      emoji: '🛣️',
      genre: GameGenre.driving,
      englishTarget: 'Common Grammar Errors & False Friends',
      descriptionEn: 'Highway driving: dodge cars in wrong lanes by identifying grammatical errors.',
      descriptionMl: 'തെറ്റായ വ്യാകരണമുള്ള കാറുകൾ ഒഴിവാക്കി ശരിയായ പാതയിലൂടെ മുന്നോട്ട് പോകുക.',
      controlMechanism: 'Rapid lane switch taps',
    ),

    // DAY 18
    DayGameSpec(
      day: 18,
      gameIndex: 1,
      title: 'English Survival Run',
      emoji: '🧟',
      genre: GameGenre.survival,
      englishTarget: 'Conditionals (If I had..., If you go...)',
      descriptionEn: 'Survive a nighttime forest run by completing conditional sentences before time runs out.',
      descriptionMl: 'രാത്രിയിലെ കാട്ടിലൂടെ ഓടി കണ്ടീഷണൽ വാക്യങ്ങൾ പൂർത്തിയാക്കി അതിജീവിക്കുക.',
      controlMechanism: 'Swipe run + split-second path decision',
    ),
    DayGameSpec(
      day: 18,
      gameIndex: 2,
      title: 'Answer Blast',
      emoji: '💥',
      genre: GameGenre.shooting,
      englishTarget: 'Direct vs Indirect Speech',
      descriptionEn: 'Cannons launch speech bubbles; detonate the correct transformed quote.',
      descriptionMl: 'പീരങ്കികൾ വിക്ഷേപിക്കുന്ന ബബിളുകളിൽ ശരിയായ ഡയറക്റ്റ്/ഇൻഡയറക്റ്റ് ഉത്തരം തകർക്കുക.',
      controlMechanism: 'Cannon rotation dial and trigger',
    ),

    // DAY 19
    DayGameSpec(
      day: 19,
      gameIndex: 1,
      title: 'English Arcade Mix',
      emoji: '🎮',
      genre: GameGenre.arcadeMemory,
      englishTarget: 'Rapid Multi-skill Recall',
      descriptionEn: 'Classic arcade cabinet mini-games shifting rules every 30 seconds.',
      descriptionMl: '30 സെക്കന്റിൽ നിയമങ്ങൾ മാറുന്ന ആർക്കേഡ് മിനി ഗെയിമുകൾ.',
      controlMechanism: 'Retro joystick and dual-action buttons',
    ),
    DayGameSpec(
      day: 19,
      gameIndex: 2,
      title: 'Memory World',
      emoji: '🧠',
      genre: GameGenre.arcadeMemory,
      englishTarget: 'Idioms & Native Expressions',
      descriptionEn: 'Flip 3D cards to pair natural English idioms with their contextual meanings.',
      descriptionMl: '3D കാർഡുകൾ മറിച്ച് ഇംഗ്ലീഷ് ശൈലികളും അവയുടെ ശരിയായ അർത്ഥങ്ങളും യോജിപ്പിക്കുക.',
      controlMechanism: 'Grid card flip tap',
    ),

    // DAY 20
    DayGameSpec(
      day: 20,
      gameIndex: 1,
      title: 'English Adventure Run',
      emoji: '🌍',
      genre: GameGenre.runner,
      englishTarget: 'First 20 Days Cumulative Speaking & Vocabulary',
      descriptionEn: 'Full 3D adventure run across temple ruins, city streets, and mountain bridges.',
      descriptionMl: 'ആദ്യ 20 ദിവസങ്ങളിൽ പഠിച്ച എല്ലാ കാര്യങ്ങളും ഉൾക്കൊള്ളുന്ന ഗ്രാൻഡ് അഡ്വഞ്ചർ റൺ.',
      controlMechanism: 'Complete runner set (jump, slide, turn, spell)',
    ),
    DayGameSpec(
      day: 20,
      gameIndex: 2,
      title: 'Ultimate Day-20 Challenge',
      emoji: '👑',
      genre: GameGenre.castleDefense,
      englishTarget: 'Milestone Gate Exam & Fortress Boss Combat',
      descriptionEn: 'Epic showdown against the Grammar Overlord answering 10 rapid spoken questions.',
      descriptionMl: '20-ാം ദിവസത്തെ മെഗാ ബോസ് പോരാട്ടം: 10 റാപ്പിഡ് ചോദ്യങ്ങൾക്ക് കൃത്യമായി മറുപടി നൽകി കിരീടം നേടുക.',
      controlMechanism: 'Voice speech input + spell attack buttons',
    ),
  ];

  static List<DayGameSpec> getGamesForDay(int day) {
    return allGames.where((g) => g.day == day).toList();
  }
}
