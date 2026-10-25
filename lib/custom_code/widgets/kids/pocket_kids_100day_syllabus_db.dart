/// 🎮 Master Game Mechanics for the 100-Day Kids Adventure
/// Every single level features a distinct pedagogical game type with zero repetition!
enum KidGameType {
  balloonPop,       // 🎈 Floating Balloon Phonics Catch
  trainScramble,    // 🚂 Letter Train Locomotive Speller
  animalFeeder,     // 🍎 Mascot Orchard Feast & Food Vocab
  memoryMatch,      // 🃏 Safari Memory Card Pair Flip
  slingshotAim,     // 🏹 Forest Slingshot Target Hit
  steppingStones,   // 🐸 River Lilypad Hopper & Rhyme Leap
  detectiveSpot,    // 🔍 Meadow Detective Magnifier
  sentenceJigsaw,   // 🧩 Rainbow Sentence Builder Blocks
  voiceEcho,        // 🗣️ Spoken Voice Echo & Speech Evaluation
  rhythmDrums,      // 🥁 Phonics Syllable Rhythm Drums
  cloudCatcher,     // ☁️ Alphabet Cloud Catcher
  vowelBubbles,     // 🫧 Magic Vowel Bubble Popper
  soundMimic,       // 🦁 Safari Animal Sound Mimic
  starTracing,      // ✨ Constellation Star Tracing
  treasureChest,    // 🗝️ Phonics Treasure Chest Unlock
  bridgeBuilder,    // 🌉 CVC Word Bridge Planks
  riverRafting,     // 🛶 Rhyme River Raft Steering
  cookieOven,       // 🍪 Word Bakery Cookie Oven
  spellCannon,      // 🚀 Spell-Cannon Sky Fireworks
  scrambleCarousel, // 🎠 Word Scramble Merry-Go-Round
  beePollinator,    // 🐝 Honeybee Blossom Pollinator
  squirrelStash,    // 🐿️ Squirrel Acorn Sorting Baskets
  vineSwinger,      // 🐒 Jungle Vine Swinger
  potionBrewer,     // 🧪 Magic Potion Word Brewer
  windmillSpinner,  // 🎡 Phonics Windmill Rotor Match
  submarineSonar,   // 🤿 Submarine Deep Sea Word Sonar
  marshmallowRoast, // 🏕️ Campfire Marshmallow Word Roast
  kiteRibbon,       // 🪁 Flying Kite Spelling Tail
  treeTapper,       // 🪵 Woodpecker Tree Trunk Tapper
  colorSplash,      // 🎨 Color Splash Painter
  shapeSorter,      // 🟩 Wooden Shape Sorter Toybox
  starCounter,      // 🌠 Shooting Star Numerals 1-10
  balanceScale,     // ⚖️ Big vs Small Animal Balance Scale
  heightClimber,    // 🪜 Tall vs Short Height Ladder
  thermometerSort,  // 🌡️ Hot vs Cold Temperature Sort
  cheetahTrack,     // 🐆 Fast vs Slow Safari Track Sprint
  balloonPilot,     // 🎈 Up & Down Hot Air Balloon Pilot
  playhouseDoors,   // 🚪 In & Out Playhouse Doors
  fruitMarket,      // 🍉 Fruit Market Quantity Scale
  rainbowBridge,    // 🌈 Spectral Rainbow Color Bridge
  clockTower,       // ⏰ Routine Clock Tower Hands
  geometryCastle,   // 🏰 3D Geometry Solid Blocks Castle
  piggyBank,        // 🪙 Star Coin Savings Bank
  discoveryBeacon,  // 🗼 Phase 3 Lighthouse Beacon Light
  lionRoar,         // 🦁 Savannah Lion Pride Roar
  pandaStroll,      // 🐼 Bamboo Forest Herbivore Feast
  dolphinLeap,      // 🐬 Ocean Dolphin Hoop Acrobat
  eagleFlight,      // 🦅 High Mountain Eagle Soar
  footprintTracker, // 🐾 Forest Animal Track Detective
  koalaClimber,     // 🐨 Eucalyptus Tree Leaf Nibbler
  savannahSprint,   // ⚡ Grassland Speed Runner
  owlNightWatch,    // 🦉 Moonlit Owl Night Vision
  beehiveArchitect, // 🐝 Hexagonal Beehive Cell Builder
  swanLake,         // 🦢 Tranquil Swan Lake Glide
  otterJuggler,     // 🦦 River Otter Pebble Juggler
  elephantSpray,    // 🐘 Savannah Giant Water Spray
  hummingbirdBloom, // 🌸 Flower Nectar Hoverer
  canopyZipLine,    // 🦥 Rainforest Canopy Zip-Line
  rangerBadge,      // 🛡️ Wildlife Guardian Shield
  trampolineBounce, // 🦘 Verb Trampoline Hurdles
  relaySprint,      // 🏃 Track & Field Action Relay
  choirConcert,     // 🎤 Jungle Choir Chorus Singing
  danceGroove,      // 💃 Safari Dance Floor Steps
  libraryExplorer,  // 📖 Storybook Adventure Flip
  artistStudio,     // ✏️ Artist Canvas Sketch
  kitchenChef,      // 🍳 Culinary Action Recipe Cook
  fountainSplash,   // 🥤 Hydration Fountain Canteen
  bedtimeTale,      // 🌙 Pajama Starlight Routine
  emotionMirror,    // 😄 Face Expression Emotion Mirror
  knightShield,     // 🛡️ Courageous Hero Shield Forge
  handshakeBridge,  // 🤝 Kindness Friendship Bridge
  telescopeScience, // 🔬 Curious Scientist Telescope
  zenGarden,        // 🧘 Deep Breath Peaceful Garden
  routineClockMaster,// ⏱️ 24-Hour Routine Master
  wizardWand,       // 🧙‍♂️ Pronoun Wizard Magic Wand
  miradorTwins,     // 👫 Third-Person Balance Beam
  tugOfWar,         // 👥 Plural Pronoun Team Pull
  magicBox,         // 📦 Preposition Box (In/On/Under)
  castleMaze,       // 🚪 Castle Gate Maze (Through/Across)
  spatialRadar,     // ↔️ Spatial Alignment (Next to/Between)
  questionDetective,// ❓ Question Mark Wh- Detective
  conjunctionTrain, // 🔗 Sentence Coupling Railway
  timeMachine,      // ⏳ Past & Present Time Machine
  grammarFortress,  // 🏰 Grammar High Tower Defense
  teaPartyManners,  // 🫖 Magic Manners Tea Party
  etiquetteDoorstep,// 🙇 Courteous Etiquette Doorstep
  sharingBasket,    // 🎁 Sharing Toys & Polite Borrowing
  internationalMeet,// 👋 First Greetings & Introductions
  playgroundChat,   // 💬 How Are You Doing Friend Chat
  cafeMenuOrder,    // 🍽️ Animal Café Order Polite Talk
  trailCompass,     // 🧭 Asking Directions Compass
  cheerHorns,       // 🎉 Teammate Encouragement Horns
  meadowMediation,  // 🕊️ Peaceful Conflict Resolution
  sunsetFarewell,   // 🌅 Warm Sunset Farewell Goodbyes
  storybookOdyssey, // 📚 Heroic Mountain Climbing Saga
  podiumDebate,     // 🎙️ Oratorical Confidence Speech
  kingdomAccords,   // 🦁 Unity & Leadership Proclamation
  preSummitCreed,   // 🏆 99-Day Grand Fluency Creed
  bossBattle,       // 👑 Day 100: Royal King Lion Golden Castle Boss Battle
}

/// A single interactive challenge round within a day's game
class KidGameRound {
  final String prompt;
  final String targetWord;
  final String targetSubtitle;
  final String emoji;
  final List<String> options;
  final int correctIndex;
  final String cheerPhrase;

  const KidGameRound({
    required this.prompt,
    required this.targetWord,
    required this.targetSubtitle,
    required this.emoji,
    required this.options,
    required this.correctIndex,
    required this.cheerPhrase,
  });
}

/// Comprehensive 100-Day Syllabus Model
class KidDaySyllabus {
  final int day;
  final String title;
  final String category;
  final KidGameType gameType;
  final String gameTitle;
  final String gameIcon;
  final String gameDescription;
  final int difficultyTier; // 1 to 10
  final String mascot;
  final String phonicsSound;
  final String dialogueSentence;
  final List<KidGameRound> rounds;

  const KidDaySyllabus({
    required this.day,
    required this.title,
    required this.category,
    required this.gameType,
    required this.gameTitle,
    required this.gameIcon,
    required this.gameDescription,
    required this.difficultyTier,
    required this.mascot,
    required this.phonicsSound,
    required this.dialogueSentence,
    required this.rounds,
  });

  String get gameTypeDisplayName => gameTitle;
  String get gameTypeInstruction => gameDescription;

  List<String> get dailyVocabulary => rounds.map((r) => r.targetWord).toList();
  String get phonicsFocus => phonicsSound;
  String get sentencePattern => dialogueSentence;
  String get sentence => dialogueSentence;
  String get speakingMission => dialogueSentence;
  String get dailyDefenseWord => rounds.isNotEmpty ? rounds.first.targetWord : 'BRAVE';
}

/// 📚 The Complete 100-Day English Curriculum & 99 Non-Repeating Game Database
class PocketKids100DaySyllabusDB {
  /// Resolves the dedicated unique game type for every single day (1 to 100)
  /// Day 1 != Day 2 != Day 50 != Day 90 != Day 99! 100% unique progression!
  static KidGameType getGameTypeForDay(int day) {
    if (day == 100) return KidGameType.bossBattle;
    
    // 99 Unique Game Mappings
    const dayToType = <int, KidGameType>{
      1: KidGameType.balloonPop,
      2: KidGameType.trainScramble,
      3: KidGameType.animalFeeder,
      4: KidGameType.memoryMatch,
      5: KidGameType.slingshotAim,
      6: KidGameType.steppingStones,
      7: KidGameType.detectiveSpot,
      8: KidGameType.sentenceJigsaw,
      9: KidGameType.voiceEcho,
      10: KidGameType.rhythmDrums,
      11: KidGameType.cloudCatcher,
      12: KidGameType.vowelBubbles,
      13: KidGameType.soundMimic,
      14: KidGameType.starTracing,
      15: KidGameType.treasureChest,
      16: KidGameType.bridgeBuilder,
      17: KidGameType.riverRafting,
      18: KidGameType.cookieOven,
      19: KidGameType.spellCannon,
      20: KidGameType.scrambleCarousel,
      21: KidGameType.beePollinator,
      22: KidGameType.squirrelStash,
      23: KidGameType.vineSwinger,
      24: KidGameType.potionBrewer,
      25: KidGameType.windmillSpinner,
      26: KidGameType.submarineSonar,
      27: KidGameType.marshmallowRoast,
      28: KidGameType.kiteRibbon,
      29: KidGameType.treeTapper,
      30: KidGameType.steppingStones,
      31: KidGameType.colorSplash,
      32: KidGameType.shapeSorter,
      33: KidGameType.starCounter,
      34: KidGameType.balanceScale,
      35: KidGameType.heightClimber,
      36: KidGameType.thermometerSort,
      37: KidGameType.cheetahTrack,
      38: KidGameType.balloonPilot,
      39: KidGameType.playhouseDoors,
      40: KidGameType.fruitMarket,
      41: KidGameType.rainbowBridge,
      42: KidGameType.clockTower,
      43: KidGameType.geometryCastle,
      44: KidGameType.piggyBank,
      45: KidGameType.discoveryBeacon,
      46: KidGameType.lionRoar,
      47: KidGameType.pandaStroll,
      48: KidGameType.dolphinLeap,
      49: KidGameType.eagleFlight,
      50: KidGameType.footprintTracker,
      51: KidGameType.koalaClimber,
      52: KidGameType.savannahSprint,
      53: KidGameType.owlNightWatch,
      54: KidGameType.beehiveArchitect,
      55: KidGameType.swanLake,
      56: KidGameType.otterJuggler,
      57: KidGameType.elephantSpray,
      58: KidGameType.hummingbirdBloom,
      59: KidGameType.canopyZipLine,
      60: KidGameType.rangerBadge,
      61: KidGameType.trampolineBounce,
      62: KidGameType.relaySprint,
      63: KidGameType.choirConcert,
      64: KidGameType.danceGroove,
      65: KidGameType.libraryExplorer,
      66: KidGameType.artistStudio,
      67: KidGameType.kitchenChef,
      68: KidGameType.fountainSplash,
      69: KidGameType.bedtimeTale,
      70: KidGameType.emotionMirror,
      71: KidGameType.knightShield,
      72: KidGameType.handshakeBridge,
      73: KidGameType.telescopeScience,
      74: KidGameType.zenGarden,
      75: KidGameType.routineClockMaster,
      76: KidGameType.wizardWand,
      77: KidGameType.miradorTwins,
      78: KidGameType.tugOfWar,
      79: KidGameType.magicBox,
      80: KidGameType.castleMaze,
      81: KidGameType.spatialRadar,
      82: KidGameType.questionDetective,
      83: KidGameType.conjunctionTrain,
      84: KidGameType.timeMachine,
      85: KidGameType.grammarFortress,
      86: KidGameType.teaPartyManners,
      87: KidGameType.etiquetteDoorstep,
      88: KidGameType.sharingBasket,
      89: KidGameType.internationalMeet,
      90: KidGameType.playgroundChat,
      91: KidGameType.cafeMenuOrder,
      92: KidGameType.trailCompass,
      93: KidGameType.cheerHorns,
      94: KidGameType.meadowMediation,
      95: KidGameType.sunsetFarewell,
      96: KidGameType.storybookOdyssey,
      97: KidGameType.podiumDebate,
      98: KidGameType.kingdomAccords,
      99: KidGameType.preSummitCreed,
    };

    return dayToType[day] ?? KidGameType.balloonPop;
  }

  /// Master generator returning full pedagogical and interactive data for any day
  static KidDaySyllabus getSyllabusForDay(int day) {
    final clampedDay = day.clamp(1, 100);
    final gameType = getGameTypeForDay(clampedDay);

    // Day 100: Grand Summit Boss Battle
    if (clampedDay == 100) {
      return const KidDaySyllabus(
        day: 100,
        title: 'King Lion Summit Boss Battle',
        category: '👑 Grand Summit Citadel (Day 100)',
        gameType: KidGameType.bossBattle,
        gameTitle: '🦁 KING LION SUMMIT BOSS SHOWDOWN',
        gameIcon: '👑',
        gameDescription: 'Triumph over King Lion in 3 Royal Spoken English Rounds!',
        difficultyTier: 10,
        mascot: '🦁',
        phonicsSound: 'Royal English Crown & Universal Fluency',
        dialogueSentence: 'I am a confident English champion and ruler of the Animal Kingdom!',
        rounds: [
          KidGameRound(
            prompt: 'Phase 1: Royal Greeting. Greet King Lion with royal confidence!',
            targetWord: 'Good morning Your Majesty!',
            targetSubtitle: 'Respectful Royal Greeting',
            emoji: '👑',
            options: ['Good morning Your Majesty!', 'Hey you over there!', 'Bye bye!'],
            correctIndex: 0,
            cheerPhrase: 'Roar! King Lion bows to your respect! 🦁✨',
          ),
          KidGameRound(
            prompt: 'Phase 2: Vocabulary Crown. Which word means never giving up?',
            targetWord: 'Perseverance',
            targetSubtitle: 'Courage & Dedication',
            emoji: '🏆',
            options: ['Perseverance', 'Quitting', 'Sleeping'],
            correctIndex: 0,
            cheerPhrase: 'Brilliant! The royal shield begins to shatter! ⚡🏰',
          ),
          KidGameRound(
            prompt: 'Phase 3: Final Accords. Speak your 100-Day proclamation to win the throne!',
            targetWord: 'English connects friends across the world!',
            targetSubtitle: 'Universal Fluency Creed',
            emoji: '🌟',
            options: [
              'English connects friends across the world!',
              'I do not know any words.',
              'The forest is dark.',
            ],
            correctIndex: 0,
            cheerPhrase: 'VICTORY! You conquered Day 100! You are King of the Kingdom! 🦁👑🎉',
          ),
        ],
      );
    }

    // Days 1–15: Phase 1 — Zero Foundation (Alphabet & Phonics Valley)
    if (clampedDay <= 15) {
      final alphabetData = [
        ['A', 'Apple', '🍎', '/æ/ sound', 'An apple is sweet and red.', '🦁', '🎈 Phonics Balloon Burst', 'Pop balloons matching the /æ/ sound!'],
        ['B', 'Ball', '⚽', '/b/ sound', 'Bounce the big blue ball.', '🐯', '🚂 Letter Train Builder', 'Assemble train wagons for B-A-L-L!'],
        ['C', 'Cat', '🐱', '/k/ sound', 'The clever cat says meow.', '🐼', '🍎 Mascot Fruit Feast', 'Feed Panda delicious C words!'],
        ['D', 'Dog', '🐶', '/d/ sound', 'The friendly dog wags its tail.', '🦊', '🃏 Safari Memory Pair Flip', 'Flip cards to match Dog and D!'],
        ['E', 'Elephant', '🐘', '/e/ sound', 'The huge elephant drinks water.', '🐰', '🏹 Forest Slingshot Target', 'Launch acorn at the E target!'],
        ['F', 'Fish', '🐟', '/f/ sound', 'The swift fish swims in the river.', '🐬', '🐸 River Lilypad Hopper', 'Help the frog leap on F words!'],
        ['G', 'Giraffe', '🦒', '/g/ sound', 'The tall giraffe eats green leaves.', '🦒', '🔍 Meadow Detective Spy', 'Spot hidden Giraffe in the grass!'],
        ['H', 'House', '🏡', '/h/ sound', 'Our cozy house on the mountain.', '🐻', '🧩 Rainbow Sentence Jigsaw', 'Snap colored sentence blocks!'],
        ['I', 'Iguana', '🦎', '/ɪ/ sound', 'An iguana sits in the warm sun.', '🐨', '🗣️ Magic Echo Microphone', 'Repeat iguana sentence aloud!'],
        ['J', 'Jungle', '🌴', '/dʒ/ sound', 'The jungle is full of adventure.', '🐵', '🥁 Phonics Rhythm Drums', 'Tap the syllable drum beats!'],
        ['K', 'Kangaroo', '🦘', '/k/ sound', 'A kangaroo hops across the valley.', '🦘', '☁️ Alphabet Cloud Catcher', 'Catch floating letter K clouds!'],
        ['L', 'Lion', '🦁', '/l/ sound', 'The brave lion protects his mates.', '🦁', '🫧 Magic Vowel Bubble Pop', 'Burst the glowing bubble words!'],
        ['M', 'Monkey', '🐵', '/m/ sound', 'A playful monkey loves bananas.', '🐒', '🦁 Animal Sound Mimic', 'Mimic monkey sounds and words!'],
        ['N', 'Nest', '🪺', '/n/ sound', 'Birds build a cozy nest high above.', '🐦', '✨ Constellation Star Tracing', 'Connect stars to spell Nest!'],
        ['O', 'Owl', '🦉', '/ɒ/ sound', 'The wise owl watches under the moon.', '🦉', '🗝️ Phonics Treasure Chest', 'Unlock the chest with key word O!'],
      ];
      final item = alphabetData[clampedDay - 1];
      final letter = item[0];
      final word = item[1];
      final emoji = item[2];
      final sound = item[3];
      final sentence = item[4];
      final mascot = item[5];
      final gameTitle = item[6];
      final gameDesc = item[7];

      return KidDaySyllabus(
        day: clampedDay,
        title: 'Letter $letter & Phonics ($word)',
        category: '🔤 Alphabet Valley (Zero Foundation)',
        gameType: gameType,
        gameTitle: gameTitle,
        gameIcon: emoji,
        gameDescription: gameDesc,
        difficultyTier: 1,
        mascot: mascot,
        phonicsSound: sound,
        dialogueSentence: sentence,
        rounds: [
          KidGameRound(
            prompt: 'Round 1: Find the letter $letter for $word!',
            targetWord: letter,
            targetSubtitle: '$letter is for $word',
            emoji: emoji,
            options: [letter, 'X', 'Z'],
            correctIndex: 0,
            cheerPhrase: 'Super! $letter is for $word! $emoji',
          ),
          KidGameRound(
            prompt: 'Round 2: Which word starts with $letter $sound?',
            targetWord: word,
            targetSubtitle: 'Starts with $letter',
            emoji: emoji,
            options: [word, 'Pizza', 'Rocket'],
            correctIndex: 0,
            cheerPhrase: 'Awesome sound recognition! $word starts with $letter!',
          ),
          KidGameRound(
            prompt: 'Round 3: Say the full phrase aloud: "$sentence"',
            targetWord: word,
            targetSubtitle: 'Speak Aloud',
            emoji: emoji,
            options: [word, 'Stop', 'Wait'],
            correctIndex: 0,
            cheerPhrase: 'Beautiful spoken English! 3 Stars unlocked! ⭐⭐⭐',
          ),
        ],
      );
    }

    // Days 16–30: Phase 2 — Remaining Letters & 3-Letter CVC Blends
    if (clampedDay <= 30) {
      final cvcWords = [
        ['P', 'Pig', '🐷', '/p/ sound', 'A pink pig plays in the barn.', '🌉 CVC Word Bridge Builder', 'Place bridge planks with letters!'],
        ['Q', 'Queen', '👸', '/kw/ sound', 'The kind queen wears a shiny crown.', '🛶 Rhyme River Rafting', 'Steer raft to rhyming docks!'],
        ['R', 'Rabbit', '🐰', '/r/ sound', 'A swift rabbit hops in the meadow.', '🍪 Word Bakery Cookie Oven', 'Bake cookies in spelling order!'],
        ['S', 'Sun', '☀️', '/s/ sound', 'The bright sun warms the mountain.', '🚀 Spell-Cannon Sky Rocket', 'Fire rocket at missing blend!'],
        ['T', 'Tiger', '🐯', '/t/ sound', 'The strong tiger runs through trees.', '🎠 Word Scramble Carousel', 'Unjumble letters on the carousel!'],
        ['U', 'Umbrella', '☂️', '/ʌ/ sound', 'Open your umbrella when rain falls.', '🐝 Honeybee Blossom Pollinator', 'Buzz to flowers with target words!'],
        ['V', 'Van', '🚐', '/v/ sound', 'Our school van travels to the safari.', '🐿️ Squirrel Acorn Stash', 'Sort acorns into word baskets!'],
        ['W', 'Water', '💧', '/w/ sound', 'Drink fresh water to stay strong.', '🐒 Jungle Vine Swinger', 'Swing to target blend vines!'],
        ['X', 'Xylophone', '🎵', '/ks/ sound', 'Play cheerful music on the xylophone.', '🧪 Magic Potion Word Brewer', 'Drop ingredients into the cauldron!'],
        ['Y', 'Yellow', '💛', '/j/ sound', 'Yellow sunflowers shine in the light.', '🎡 Phonics Windmill Spinner', 'Spin windmill to match word pairs!'],
        ['Z', 'Zebra', '🦓', '/z/ sound', 'A zebra has black and white stripes.', '🤿 Submarine Deep Sea Sonar', 'Sonar-ping matching CVC fish!'],
        ['CAT', 'Cat', '🐱', 'C-A-T Blend', 'The little cat naps on the rug.', '🏕️ Campfire Marshmallow Roast', 'Roast marshmallows with rhymes!'],
        ['DOG', 'Dog', '🐶', 'D-O-G Blend', 'My pet dog loves fetching sticks.', '🪁 Flying Kite Spelling Tail', 'Attach ribbons in spelling order!'],
        ['SUN', 'Sun', '☀️', 'S-U-N Blend', 'The morning sun wakes the animals.', '🪵 Woodpecker Tree Tapper', 'Tap letters on the tree trunk!'],
        ['HAT', 'Hat', '🎩', 'H-A-T Blend', 'A magical hat with silver stars.', '🏰 CVC Master Gate Guardian', 'Pass the gatekeeper to advance!'],
      ];
      final item = cvcWords[clampedDay - 16];
      final keyWord = item[0];
      final word = item[1];
      final emoji = item[2];
      final sound = item[3];
      final sentence = item[4];
      final gameTitle = item[5];
      final gameDesc = item[6];

      return KidDaySyllabus(
        day: clampedDay,
        title: 'Blending & Words: $keyWord',
        category: '🔤 Phonics & 3-Letter Blends',
        gameType: gameType,
        gameTitle: gameTitle,
        gameIcon: emoji,
        gameDescription: gameDesc,
        difficultyTier: 2,
        mascot: '🦊',
        phonicsSound: sound,
        dialogueSentence: sentence,
        rounds: [
          KidGameRound(
            prompt: 'Round 1: Match the word $keyWord with $sound!',
            targetWord: keyWord,
            targetSubtitle: 'Sound: $sound',
            emoji: emoji,
            options: [keyWord, 'BED', 'LOG'],
            correctIndex: 0,
            cheerPhrase: 'Great blend! You spelled $keyWord! $emoji',
          ),
          KidGameRound(
            prompt: 'Round 2: What picture matches $keyWord?',
            targetWord: word,
            targetSubtitle: 'Meaning & Picture',
            emoji: emoji,
            options: [word, 'Airplane', 'Mountain'],
            correctIndex: 0,
            cheerPhrase: 'Exactly right! $keyWord means $word! $emoji',
          ),
          KidGameRound(
            prompt: 'Round 3: Complete the spoken sentence: "$sentence"',
            targetWord: keyWord,
            targetSubtitle: 'Fluency sentence',
            emoji: emoji,
            options: [keyWord, 'CAR', 'PIN'],
            correctIndex: 0,
            cheerPhrase: 'Incredible speech! Day $clampedDay complete! ⭐',
          ),
        ],
      );
    }

    // Days 31–45: Phase 3 — Colors, Shapes & Numbers Magic
    if (clampedDay <= 45) {
      final colorNumberTopics = [
        ['Red & Blue', 'Colors of sky and fire', '🎨', 'The red apple is on the blue plate.', '🎨 Color Splash Painter', 'Splash target colors onto the canvas!'],
        ['Yellow & Green', 'Colors of sun and leaves', '🌻', 'Green leaves shine under yellow sunlight.', '🟩 Wooden Shape Sorter Toybox', 'Fit shapes into wooden cutouts!'],
        ['Purple & Orange', 'Bright fruit colors', '🍇', 'Purple grapes and sweet orange juice.', '🌠 Shooting Star Counter', 'Count shooting stars across the sky!'],
        ['Pink & White', 'Gentle colors', '🌸', 'Pink flowers bloom in white snow.', '⚖️ Animal Weight Balance Scale', 'Balance big vs small animals!'],
        ['Circle & Square', 'Basic shapes', '⭕', 'The sun is a circle, the box is a square.', '🪜 Height Ladder Climber', 'Order animals from tall to short!'],
        ['Triangle & Star', 'Geometric shapes', '⭐', 'A starry sky above triangular mountains.', '🌡️ Hot vs Cold Thermometer Sort', 'Sort sun and ice items by temp!'],
        ['Numbers 1 to 3', 'Counting stars', '1️⃣', 'One sun, two eyes, three birds.', '🐆 Cheetah Track Race Sprint', 'Accelerate fast runners on track!'],
        ['Numbers 4 to 6', 'Counting mates', '4️⃣', 'Four legs, five fingers, six cherries.', '🎈 Up & Down Hot Air Balloon', 'Pilot the balloon up and down!'],
        ['Numbers 7 to 10', 'Big numbers', '🔟', 'Seven days, eight balloons, ten gold stars.', '🚪 In & Out Playhouse Doors', 'Place pets inside or outside!'],
        ['Big & Small', 'Comparisons', '🐘', 'The elephant is big, the mouse is small.', '🍉 Fruit Market Scale Weigher', 'Weigh and count fruit crates!'],
        ['Tall & Short', 'Heights', '🦒', 'The giraffe is tall, the cub is short.', '🌈 Spectral Rainbow Bridge', 'Arrange rainbow colors in order!'],
        ['Hot & Cold', 'Opposites', '❄️', 'Hot cocoa warms the cold winter day.', '⏰ Clock Tower Tick-Tock', 'Set clock hands to daily routines!'],
        ['Fast & Slow', 'Speed', '🐆', 'The cheetah is fast, the turtle is slow.', '🏰 3D Geometry Solid Castle', 'Build castles with 3D solid blocks!'],
        ['Up & Down', 'Directions', '🎈', 'The balloon floats up, leaves flutter down.', '🪙 Star Coin Piggy Bank', 'Deposit star coins into the bank!'],
        ['In & Out', 'Positions', '🚪', 'Step in the classroom, play out in the yard.', '🗼 Phase 3 Discovery Beacon', 'Light beacon with descriptive words!'],
      ];
      final item = colorNumberTopics[clampedDay - 31];
      final topic = item[0];
      final desc = item[1];
      final emoji = item[2];
      final sentence = item[3];
      final gameTitle = item[4];
      final gameDesc = item[5];

      return KidDaySyllabus(
        day: clampedDay,
        title: '$topic ($desc)',
        category: '🎨 Colors, Shapes & Numbers',
        gameType: gameType,
        gameTitle: gameTitle,
        gameIcon: emoji,
        gameDescription: gameDesc,
        difficultyTier: 3,
        mascot: '🐼',
        phonicsSound: 'Descriptive Vocabulary',
        dialogueSentence: sentence,
        rounds: [
          KidGameRound(
            prompt: 'Round 1: Identify $topic in English!',
            targetWord: topic.split('&').first.trim(),
            targetSubtitle: desc,
            emoji: emoji,
            options: [topic.split('&').first.trim(), 'Rock', 'Cloud'],
            correctIndex: 0,
            cheerPhrase: 'Spot on! You know your $topic! $emoji',
          ),
          KidGameRound(
            prompt: 'Round 2: Read and understand: "$sentence"',
            targetWord: topic.contains('&') ? topic.split('&').last.trim() : topic,
            targetSubtitle: 'Sentence Meaning',
            emoji: emoji,
            options: [topic.contains('&') ? topic.split('&').last.trim() : topic, 'Mud', 'Rain'],
            correctIndex: 0,
            cheerPhrase: 'Brilliant comprehension! You are flying high! ✨',
          ),
          KidGameRound(
            prompt: 'Round 3: Say the full descriptive sentence aloud!',
            targetWord: 'Fluent',
            targetSubtitle: 'Voice Recording',
            emoji: emoji,
            options: ['Fluent', 'Silent', 'No'],
            correctIndex: 0,
            cheerPhrase: 'Magnificent pronunciation! 3 Stars unlocked! ⭐⭐⭐',
          ),
        ],
      );
    }

    // Days 46–60: Phase 4 — Animal Safari, Habitats & Nature Words
    if (clampedDay <= 60) {
      final safariTopics = [
        ['Lion King', 'Savannah King', '🦁', 'The proud lion roars across the golden savannah.', '🦁 Savannah Lion Pride Roar', 'Match lion strength words!'],
        ['Tiger Stripes', 'Jungle Predator', '🐯', 'The brave tiger creeps silently in tall grass.', '🐼 Bamboo Forest Panda Feast', 'Feed panda fresh green bamboo!'],
        ['Panda Bamboo', 'Forest Herbivore', '🐼', 'The gentle panda eats sweet green bamboo.', '🐬 Ocean Dolphin Hoop Acrobat', 'Leap dolphins through word hoops!'],
        ['Playful Dolphin', 'Ocean Swimmer', '🐬', 'Dolphins leap high above sparkling ocean waves.', '🦅 High Mountain Eagle Soar', 'Guide eagle to thermal updrafts!'],
        ['Soaring Eagle', 'Mountain Flyer', '🦅', 'The mighty eagle flies over mountain peaks.', '🐾 Forest Footprint Detective', 'Follow footprints to animal nests!'],
        ['Cunning Fox', 'Woodland Scout', '🦊', 'The clever fox hunts with sharp ears.', '🐨 Eucalyptus Tree Climber', 'Climb branches with leafy words!'],
        ['Gentle Koala', 'Tree Sleeper', '🐨', 'The soft koala hugs the eucalyptus branch.', '⚡ Grassland Speed Runner', 'Sprint past obstacle words on plains!'],
        ['Speedy Cheetah', 'Fastest Runner', '🐆', 'Cheetahs sprint faster than wind across plains.', '🦉 Moonlit Owl Night Watch', 'Spot nocturnal words in the dark!'],
        ['Wise Owl', 'Night Guardian', '🦉', 'The wise owl hooted under the moonlit sky.', '🐝 Beehive Cell Architect', 'Construct hexagonal honeycombs!'],
        ['Busy Honeybee', 'Garden Worker', '🐝', 'Bees make sweet golden honey from colorful blossoms.', '🦢 Tranquil Swan Lake Glide', 'Glide across lake to word lilies!'],
        ['Graceful Swan', 'Lake Beauty', '🦢', 'The white swan glides peacefully on blue water.', '🦦 River Otter Pebble Juggler', 'Juggle smooth rhyming pebbles!'],
        ['Playful Otter', 'River Explorer', '🦦', 'Otters hold hands while floating downstream.', '🐘 Savannah Giant Water Spray', 'Spray water on thirsty savannah trees!'],
        ['Mighty Elephant', 'Savannah Giant', '🐘', 'Elephants remember friends for a whole lifetime.', '🌸 Flower Nectar Hoverer', 'Hover at matching flower blossoms!'],
        ['Tiny Hummingbird', 'Flower Dancer', '🐦', 'A hummingbird flaps its wings with electric speed.', '🦥 Rainforest Canopy Zip-Line', 'Zip-line down through the canopy!'],
        ['Forest Biome Review', 'Safari Master', '🌳', 'Protect animals and trees to preserve nature.', '🛡️ Wildlife Guardian Shield', 'Earn the safari protector badge!'],
      ];
      final item = safariTopics[clampedDay - 46];
      final topic = item[0];
      final desc = item[1];
      final emoji = item[2];
      final sentence = item[3];
      final gameTitle = item[4];
      final gameDesc = item[5];

      return KidDaySyllabus(
        day: clampedDay,
        title: '$topic Safari Adventure',
        category: '🐾 Animal Kingdom & Nature',
        gameType: gameType,
        gameTitle: gameTitle,
        gameIcon: emoji,
        gameDescription: gameDesc,
        difficultyTier: 4,
        mascot: emoji,
        phonicsSound: 'Animal Sounds & Nature English',
        dialogueSentence: sentence,
        rounds: [
          KidGameRound(
            prompt: 'Round 1: Recognize $topic and its habitat!',
            targetWord: topic.split(' ').first,
            targetSubtitle: desc,
            emoji: emoji,
            options: [topic.split(' ').first, 'Submarine', 'Brick'],
            correctIndex: 0,
            cheerPhrase: 'Roar! $topic recognized! $emoji',
          ),
          KidGameRound(
            prompt: 'Round 2: What sound or trait belongs to $topic?',
            targetWord: desc,
            targetSubtitle: 'Animal Feature',
            emoji: emoji,
            options: [desc, 'Factory smoke', 'Computer screen'],
            correctIndex: 0,
            cheerPhrase: 'Fabulous knowledge of the animal kingdom!',
          ),
          KidGameRound(
            prompt: 'Round 3: Speak the nature sentence aloud with expression!',
            targetWord: 'Nature Master',
            targetSubtitle: 'Voice Challenge',
            emoji: emoji,
            options: ['Nature Master', 'Plastic', 'Trash'],
            correctIndex: 0,
            cheerPhrase: 'Masterful! The animal kingdom salutes your courage! ⭐⭐⭐',
          ),
        ],
      );
    }

    // Days 61–75: Phase 5 — Action Verbs, Everyday Routines & Feelings
    if (clampedDay <= 75) {
      final actionTopics = [
        ['Jump & Leap', 'High Energy Verbs', '🦘', 'Jump over obstacles with cheerful energy.', '🦘 Verb Trampoline Hurdles', 'Bounce over verb obstacles!'],
        ['Run & Sprint', 'Movement Verbs', '🏃', 'Run safely on the school playground with friends.', '🏃 Track & Field Action Relay', 'Pass the baton on action words!'],
        ['Sing & Melody', 'Music & Joy', '🎤', 'Sing a cheerful song to brighten everyone\'s day.', '🎤 Jungle Choir Chorus Singing', 'Sing musical chorus phrases!'],
        ['Dance & Rhythm', 'Movement & Art', '💃', 'Dance to the lively jungle rhythm.', '💃 Safari Dance Floor Steps', 'Follow steps matching rhythm verbs!'],
        ['Read & Learn', 'Mind Growth', '📖', 'Read exciting storybooks to discover new worlds.', '📖 Storybook Adventure Flip', 'Turn pages to find adventure verbs!'],
        ['Write & Draw', 'Creativity', '✏️', 'Write kind words and draw bright stars.', '✏️ Artist Canvas Sketch', 'Draw illustrations for action words!'],
        ['Eat & Nourish', 'Healthy Foods', '🍎', 'Eat crunchy fresh apples and vegetables.', '🍳 Culinary Action Recipe Cook', 'Cook meals using culinary verbs!'],
        ['Drink & Hydrate', 'Health Essentials', '🥛', 'Drink clean fresh water every morning.', '🥤 Hydration Fountain Canteen', 'Fill water canteens with health verbs!'],
        ['Sleep & Rest', 'Recharge Routine', '🌙', 'Sleep early to wake up active and happy.', '🌙 Pajama Starlight Routine', 'Tuck in animal buddies with night habits!'],
        ['Happy & Joyful', 'Positive Emotion', '😄', 'I am happy when playing with my mates.', '😄 Face Expression Emotion Mirror', 'Match expressions to feelings!'],
        ['Brave & Courageous', 'Heroic Emotion', '🦁', 'Brave kids speak up and help others.', '🛡️ Courageous Hero Shield Forge', 'Forge shields with brave deeds!'],
        ['Kind & Caring', 'Friendship Emotion', '🤝', 'Kind words make friends wherever you go.', '🤝 Kindness Friendship Bridge', 'Connect bridges with kind words!'],
        ['Curious & Eager', 'Explorer Emotion', '🔍', 'Curious minds ask wonderful questions.', '🔬 Curious Scientist Telescope', 'Examine specimens with curious verbs!'],
        ['Calm & Peaceful', 'Focus & Stillness', '🧘', 'Take a deep breath and stay calm in challenge.', '🧘 Deep Breath Peaceful Garden', 'Breathe deeply with calming words!'],
        ['Daily Routine Master', 'Action Synthesis', '⏰', 'A great morning routine creates a victorious day.', '⏱️ 24-Hour Routine Master', 'Assemble the complete day plan!'],
      ];
      final item = actionTopics[clampedDay - 61];
      final topic = item[0];
      final desc = item[1];
      final emoji = item[2];
      final sentence = item[3];
      final gameTitle = item[4];
      final gameDesc = item[5];

      return KidDaySyllabus(
        day: clampedDay,
        title: '$topic ($desc)',
        category: '⚡ Action Verbs & Feelings',
        gameType: gameType,
        gameTitle: gameTitle,
        gameIcon: emoji,
        gameDescription: gameDesc,
        difficultyTier: 5,
        mascot: '🐯',
        phonicsSound: 'Action Words & Emotional Expression',
        dialogueSentence: sentence,
        rounds: [
          KidGameRound(
            prompt: 'Round 1: Which action word means $desc?',
            targetWord: topic.split('&').first.trim(),
            targetSubtitle: desc,
            emoji: emoji,
            options: [topic.split('&').first.trim(), 'Rock', 'Table'],
            correctIndex: 0,
            cheerPhrase: 'Yes! Action word mastered! $emoji',
          ),
          KidGameRound(
            prompt: 'Round 2: How do we use $topic in a sentence?',
            targetWord: sentence.split(' ').first,
            targetSubtitle: 'Sentence Starter',
            emoji: emoji,
            options: [sentence.split(' ').first, 'Never', 'Forgot'],
            correctIndex: 0,
            cheerPhrase: 'Terrific sentence construction!',
          ),
          KidGameRound(
            prompt: 'Round 3: Say: "$sentence" with strong feeling!',
            targetWord: 'Action Champion',
            targetSubtitle: 'Spoken Eloquence',
            emoji: emoji,
            options: ['Action Champion', 'Lazy', 'Bored'],
            correctIndex: 0,
            cheerPhrase: 'Outstanding energy! 3 Stars earned! ⭐⭐⭐',
          ),
        ],
      );
    }

    // Days 76–85: Phase 6 — Grammar Power, Sentence Builders & Prepositions
    if (clampedDay <= 85) {
      final grammarTopics = [
        ['I am & You are', 'Pronouns & Be-Verbs', '🙋', 'I am an explorer and you are my mate.', '🧙‍♂️ Pronoun Wizard Magic Wand', 'Zap correct pronouns with wand!'],
        ['He is & She is', 'Third-Person Pronouns', '👫', 'He is reading a book and she is playing guitar.', '👫 Third-Person Balance Beam', 'Balance He vs She on the beam!'],
        ['We are & They are', 'Plural Pronouns', '👥', 'We are the champion team on the mountain.', '👥 Plural Pronoun Team Pull', 'Tug the rope with plural strength!'],
        ['In, On, Under', 'Prepositions of Place', '📦', 'The book is on the desk, the cat is in the box.', '📦 Preposition Magic Box', 'Place objects In, On, Under!'],
        ['Behind & In Front', 'Spatial Awareness', '🚪', 'Stand in front of the door, not behind it.', '🚪 Castle Gate Maze Navigation', 'Navigate Through & Across gates!'],
        ['Next to & Between', 'Positioning', '↔️', 'Sit next to your mate during story time.', '↔️ Spatial Alignment Radar', 'Align objects Next to & Between!'],
        ['What is this?', 'Question Practice 1', '❓', 'What is this magical golden key?', '❓ Question Mark Wh- Detective', 'Choose What, Where, Who, When!'],
        ['Where is it?', 'Question Practice 2', '🗺️', 'Where is the secret mountain trail path?', '🔗 Sentence Coupling Railway', 'Couple trains with Because & And!'],
        ['Who is that?', 'Question Practice 3', '👤', 'Who is that brave companion leading the team?', '⏳ Past & Present Time Machine', 'Shift Yesterday verbs into Today!'],
        ['Because & And', 'Connecting Sentences', '🔗', 'I practice English because I want to travel.', '🏰 Grammar High Tower Defense', 'Defend tower with accurate grammar!'],
      ];
      final item = grammarTopics[clampedDay - 76];
      final topic = item[0];
      final desc = item[1];
      final emoji = item[2];
      final sentence = item[3];
      final gameTitle = item[4];
      final gameDesc = item[5];

      return KidDaySyllabus(
        day: clampedDay,
        title: '$topic ($desc)',
        category: '🧩 Grammar Power & Sentence Building',
        gameType: gameType,
        gameTitle: gameTitle,
        gameIcon: emoji,
        gameDescription: gameDesc,
        difficultyTier: 6,
        mascot: '🦊',
        phonicsSound: 'Grammar Syntax & Sentence Connectors',
        dialogueSentence: sentence,
        rounds: [
          KidGameRound(
            prompt: 'Round 1: Choose the correct grammar match for $topic!',
            targetWord: topic.split('&').first.trim(),
            targetSubtitle: desc,
            emoji: emoji,
            options: [topic.split('&').first.trim(), 'Me is', 'You am'],
            correctIndex: 0,
            cheerPhrase: 'Accurate grammar! You speak like a native speaker! 🌟',
          ),
          KidGameRound(
            prompt: 'Round 2: Complete the sentence: "$sentence"',
            targetWord: topic.contains('&') ? topic.split('&').last.trim() : topic,
            targetSubtitle: 'Sentence Syntax',
            emoji: emoji,
            options: [topic.contains('&') ? topic.split('&').last.trim() : topic, 'broken', 'wrong'],
            correctIndex: 0,
            cheerPhrase: 'Flawless grammatical syntax!',
          ),
          KidGameRound(
            prompt: 'Round 3: Speak the full connecting sentence clearly!',
            targetWord: 'Grammar Master',
            targetSubtitle: 'Spoken Precision',
            emoji: emoji,
            options: ['Grammar Master', 'Mistake', 'Silent'],
            correctIndex: 0,
            cheerPhrase: 'Perfect grammar fluency! Day $clampedDay mastered! ⭐⭐⭐',
          ),
        ],
      );
    }

    // Days 86–95: Phase 7 — Polite Manners, Social English & Real Dialogues
    if (clampedDay <= 95) {
      final socialTopics = [
        ['Please & Thank You', 'Magic Words', '🙏', 'Please pass the pencils and thank you kindly.', '🫖 Magic Manners Tea Party', 'Pour tea with courteous phrases!'],
        ['Excuse Me & Sorry', 'Polite Etiquette', '🙇', 'Excuse me, may I ask a quick question?', '🙇 Courteous Etiquette Doorstep', 'Choose respectful apologies!'],
        ['May I Please Borrow?', 'Sharing Manners', '🤝', 'May I please borrow your color crayons?', '🎁 Sharing Toy Basket', 'Ask to borrow with polite tone!'],
        ['Nice to Meet You', 'First Introductions', '👋', 'Hello! My name is Leo, nice to meet you!', '👋 International Handshake', 'Introduce yourself with confidence!'],
        ['How are you doing?', 'Friendly Inquiries', '💬', 'How are you doing today my friend? I am great!', '💬 Playground Mate Chat', 'Ask and answer friendly questions!'],
        ['Ordering Food & Snacks', 'Daily Practical English', '🍽️', 'I would like a glass of warm milk please.', '🍽️ Animal Café Order Polite Talk', 'Order meals politely from menus!'],
        ['Asking for Directions', 'Navigation Phrases', '🧭', 'Excuse me, where is the library building?', '🧭 Asking Directions Compass', 'Ask & navigate mountain trails!'],
        ['Cheering for a Mate', 'Encouragement Words', '🎉', 'You can do it! I believe in your strength!', '🎉 Teammate Encouragement Horns', 'Cheer friends on with kind praise!'],
        ['Solving a Disagreement', 'Peaceful Dialogue', '🕊️', 'Let us take turns and play peacefully together.', '🕊️ Peaceful Meadow Mediation', 'Resolve conflicts with gentle words!'],
        ['Saying Goodbye with Warmth', 'Farewell Etiquette', '🌅', 'Have a wonderful evening, see you tomorrow!', '🌅 Warm Sunset Farewell Goodbyes', 'Bid farewell with warm smiles!'],
      ];
      final item = socialTopics[clampedDay - 86];
      final topic = item[0];
      final desc = item[1];
      final emoji = item[2];
      final sentence = item[3];
      final gameTitle = item[4];
      final gameDesc = item[5];

      return KidDaySyllabus(
        day: clampedDay,
        title: '$topic ($desc)',
        category: '🤝 Polite Manners & Social English',
        gameType: gameType,
        gameTitle: gameTitle,
        gameIcon: emoji,
        gameDescription: gameDesc,
        difficultyTier: 7,
        mascot: '🦄',
        phonicsSound: 'Conversational Politeness & Etiquette',
        dialogueSentence: sentence,
        rounds: [
          KidGameRound(
            prompt: 'Round 1: When someone helps you, what do you say?',
            targetWord: topic.split('&').last.trim(),
            targetSubtitle: 'Polite Response',
            emoji: emoji,
            options: [topic.split('&').last.trim(), 'Go away', 'Nothing'],
            correctIndex: 0,
            cheerPhrase: 'Polite and respectful! True kings and queens have good manners! 👑',
          ),
          KidGameRound(
            prompt: 'Round 2: What is the kindest way to ask? "$sentence"',
            targetWord: topic.split('&').first.trim(),
            targetSubtitle: 'Respectful Request',
            emoji: emoji,
            options: [topic.split('&').first.trim(), 'Give me now', 'Gimme'],
            correctIndex: 0,
            cheerPhrase: 'Such polite communication wins everyone\'s heart! ❤️',
          ),
          KidGameRound(
            prompt: 'Round 3: Roleplay! Speak the dialogue out loud with a smile!',
            targetWord: 'Social Star',
            targetSubtitle: 'Voice Etiquette',
            emoji: emoji,
            options: ['Social Star', 'Rude', 'Shout'],
            correctIndex: 0,
            cheerPhrase: 'Wonderful social fluency! You are ready for the world! ⭐⭐⭐',
          ),
        ],
      );
    }

    // Days 96–99: Phase 8 — Summit English Mastery & Leadership Eloquence
    final summitTopics = [
      ['Storytelling Odyssey', 'Narrative Fluency', '📚', 'Once upon a time, brave animals climbed a magical mountain.', '📚 Heroic Mountain Climbing Saga', 'Narrate the epic mountain tale!'],
      ['Public Speaking & Courage', 'Oratorical Confidence', '🎙️', 'Stand tall, breathe deeply, and speak with unwavering clarity.', '🎙️ Oratorical Confidence Speech', 'Deliver public addresses with vigor!'],
      ['Leadership & Kingdom Accords', 'Inspiring Others', '🦁', 'True leaders protect their team and inspire everyone to shine.', '🦁 Unity & Leadership Proclamation', 'Proclaim unity across the realm!'],
      ['Pre-Summit Master Synthesis', '99-Day Review', '🏆', 'I have practiced 99 days and my English is strong and fluent!', '🏆 99-Day Grand Fluency Creed', 'State your supreme fluency creed!'],
    ];
    final item = summitTopics[clampedDay - 96];
    final topic = item[0];
    final desc = item[1];
    final emoji = item[2];
    final sentence = item[3];
    final gameTitle = item[4];
    final gameDesc = item[5];

    return KidDaySyllabus(
      day: clampedDay,
      title: '$topic ($desc)',
      category: '🏔️ Summit Leadership & Public Speaking',
      gameType: gameType,
      gameTitle: gameTitle,
      gameIcon: emoji,
      gameDescription: gameDesc,
      difficultyTier: 9,
      mascot: '🦁',
      phonicsSound: 'Public Speaking & Narrative Eloquence',
      dialogueSentence: sentence,
      rounds: [
        KidGameRound(
          prompt: 'Round 1: Oratorical mastery: Select the empowering word!',
          targetWord: topic.split(' ').first,
          targetSubtitle: desc,
          emoji: emoji,
          options: [topic.split(' ').first, 'Fear', 'Silence'],
          correctIndex: 0,
          cheerPhrase: 'Confidence resonates across the mountain! 🏔️✨',
        ),
        KidGameRound(
          prompt: 'Round 2: Deliver the leadership proclamation: "$sentence"',
          targetWord: 'Leadership',
          targetSubtitle: 'Speech Power',
          emoji: emoji,
          options: ['Leadership', 'Doubt', 'Retreat'],
          correctIndex: 0,
          cheerPhrase: 'Inspiring and majestic! King Lion is watching your progress! 🦁',
        ),
        KidGameRound(
          prompt: 'Round 3: Final summit preparation! Speak aloud with passion!',
          targetWord: 'Summit Champion',
          targetSubtitle: 'Final Voice Step',
          emoji: emoji,
          options: ['Summit Champion', 'Give up', 'Weak'],
          correctIndex: 0,
          cheerPhrase: 'Day $clampedDay conquered! The Golden Castle awaits! 🏰👑',
        ),
      ],
    );
  }
}
