/// 🎮 Master Game Mechanics for the 100-Day Kids Adventure
/// Every level has a distinct game type so children never experience repetitive games!
enum KidGameType {
  balloonPop, // 🎈 Floating Balloon Popping & Phonics Catch (Days 1, 10, 19, 28, 37, 46, 55, 64, 73, 82, 91)
  trainScramble, // 🚂 Letter Train Jigsaw & Spelling Builder (Days 2, 11, 20, 29, 38, 47, 56, 65, 74, 83, 92)
  animalFeeder, // 🍎 Feeding Mascot Animals Target English Words (Days 3, 12, 21, 30, 39, 48, 57, 66, 75, 84, 93)
  memoryMatch, // 🃏 Flipping & Matching Animal Cards (Days 4, 13, 22, 31, 40, 49, 58, 67, 76, 85, 94)
  slingshotAim, // 🏹 Slingshot Launch at Vocabulary Targets (Days 5, 14, 23, 32, 41, 50, 59, 68, 77, 86, 95)
  steppingStones, // 🐸 River Stepping Stones & Rhyme Hopper (Days 6, 15, 24, 33, 42, 51, 60, 69, 78, 87, 96)
  detectiveSpot, // 🔍 Detective Spy & Spot the Object (Days 7, 16, 25, 34, 43, 52, 61, 70, 79, 88, 97)
  sentenceJigsaw, // 🧩 Grammar Sentence Jigsaw Builder (Days 8, 17, 26, 35, 44, 53, 62, 71, 80, 89, 98)
  voiceEcho, // 🗣️ Spoken Voice Echo & Speech Pronunciation (Days 9, 18, 27, 36, 45, 54, 63, 72, 81, 90, 99)
  bossBattle, // 🦁 Day 100: Royal King Lion Golden Palace Summit Showdown
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
  final String mascot;
  final String phonicsSound;
  final String dialogueSentence;
  final List<KidGameRound> rounds;

  const KidDaySyllabus({
    required this.day,
    required this.title,
    required this.category,
    required this.gameType,
    required this.mascot,
    required this.phonicsSound,
    required this.dialogueSentence,
    required this.rounds,
  });

  String get gameTypeDisplayName {
    switch (gameType) {
      case KidGameType.balloonPop:
        return '🎈 BALLOON POP PHONICS';
      case KidGameType.trainScramble:
        return '🚂 LETTER TRAIN BUILDER';
      case KidGameType.animalFeeder:
        return '🍎 ANIMAL FEAST';
      case KidGameType.memoryMatch:
        return '🃏 SAFARI MEMORY CARDS';
      case KidGameType.slingshotAim:
        return '🏹 SLINGSHOT TARGET HIT';
      case KidGameType.steppingStones:
        return '🐸 RIVER STONE HOPPER';
      case KidGameType.detectiveSpot:
        return '🔍 DETECTIVE OBJECT SPY';
      case KidGameType.sentenceJigsaw:
        return '🧩 SENTENCE JIGSAW';
      case KidGameType.voiceEcho:
        return '🗣️ SPOKEN VOICE ECHO';
      case KidGameType.bossBattle:
        return '🦁 KING LION BOSS BATTLE';
    }
  }

  String get gameTypeInstruction {
    switch (gameType) {
      case KidGameType.balloonPop:
        return 'Pop the floating balloons that match the sound!';
      case KidGameType.trainScramble:
        return 'Assemble the train wagons in the correct word order!';
      case KidGameType.animalFeeder:
        return 'Feed the hungry animal buddy the correct target word!';
      case KidGameType.memoryMatch:
        return 'Tap and match the matching word and picture cards!';
      case KidGameType.slingshotAim:
        return 'Aim your slingshot and hit the correct English target!';
      case KidGameType.steppingStones:
        return 'Hop across the river stones with the right English answer!';
      case KidGameType.detectiveSpot:
        return 'Inspect the safari and spot the correct vocabulary item!';
      case KidGameType.sentenceJigsaw:
        return 'Put the jumbled words into a proper English sentence!';
      case KidGameType.voiceEcho:
        return 'Listen carefully, repeat aloud, and earn fluency stars!';
      case KidGameType.bossBattle:
        return 'Challenge King Lion in 3 Royal Spoken English rounds!';
    }
  }
}

/// 📚 The Complete 100-Day English Curriculum & Game Database
class PocketKids100DaySyllabusDB {
  /// Resolves the game type for any day (1 to 100)
  /// Alternates cleanly so Day 1 != Day 2 != Day 3... up to Day 100 Boss Battle!
  static KidGameType getGameTypeForDay(int day) {
    if (day == 100) return KidGameType.bossBattle;
    final gameTypes = [
      KidGameType.balloonPop,
      KidGameType.trainScramble,
      KidGameType.animalFeeder,
      KidGameType.memoryMatch,
      KidGameType.slingshotAim,
      KidGameType.steppingStones,
      KidGameType.detectiveSpot,
      KidGameType.sentenceJigsaw,
      KidGameType.voiceEcho,
    ];
    return gameTypes[(day - 1) % gameTypes.length];
  }

  /// Master generator returning full pedagogical and interactive data for any day
  static KidDaySyllabus getSyllabusForDay(int day) {
    final clampedDay = day.clamp(1, 100);
    final gameType = getGameTypeForDay(clampedDay);

    // Day 100: Grand Summit Boss Battle
    if (clampedDay == 100) {
      return KidDaySyllabus(
        day: 100,
        title: 'King Lion Summit Boss Battle',
        category: '👑 Grand Summit Citadel (Day 100)',
        gameType: KidGameType.bossBattle,
        mascot: '🦁',
        phonicsSound: 'Royal English Crown & Fluency',
        dialogueSentence: 'I am a confident English champion and ruler of the Animal Kingdom!',
        rounds: const [
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
        ['A', 'Apple', '🍎', '/æ/ sound', 'An apple is sweet and red.', '🦁'],
        ['B', 'Ball', '⚽', '/b/ sound', 'Bounce the big blue ball.', '🐯'],
        ['C', 'Cat', '🐱', '/k/ sound', 'The clever cat says meow.', '🐼'],
        ['D', 'Dog', '🐶', '/d/ sound', 'The friendly dog wags its tail.', '🦊'],
        ['E', 'Elephant', '🐘', '/e/ sound', 'The huge elephant drinks water.', '🐰'],
        ['F', 'Fish', '🐟', '/f/ sound', 'The swift fish swims in the river.', '🐬'],
        ['G', 'Giraffe', '🦒', '/g/ sound', 'The tall giraffe eats green leaves.', '🦒'],
        ['H', 'House', '🏡', '/h/ sound', 'Our cozy house on the mountain.', '🐻'],
        ['I', 'Iguana', '🦎', '/ɪ/ sound', 'An iguana sits in the warm sun.', '🐨'],
        ['J', 'Jungle', '🌴', '/dʒ/ sound', 'The jungle is full of adventure.', '🐵'],
        ['K', 'Kangaroo', '🦘', '/k/ sound', 'A kangaroo hops across the valley.', '🦘'],
        ['L', 'Lion', '🦁', '/l/ sound', 'The brave lion protects his mates.', '🦁'],
        ['M', 'Monkey', '🐵', '/m/ sound', 'A playful monkey loves bananas.', '🐒'],
        ['N', 'Nest', '🪺', '/n/ sound', 'Birds build a cozy nest high above.', '🐦'],
        ['O', 'Owl', '🦉', '/ɒ/ sound', 'The wise owl watches under the moon.', '🦉'],
      ];
      final item = alphabetData[clampedDay - 1];
      final letter = item[0];
      final word = item[1];
      final emoji = item[2];
      final sound = item[3];
      final sentence = item[4];
      final mascot = item[5];

      return KidDaySyllabus(
        day: clampedDay,
        title: 'Letter $letter & Phonics ($word)',
        category: '🔤 Alphabet Valley (Zero Foundation)',
        gameType: gameType,
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
        ['P', 'Pig', '🐷', '/p/ sound', 'A pink pig plays in the barn.'],
        ['Q', 'Queen', '👸', '/kw/ sound', 'The kind queen wears a shiny crown.'],
        ['R', 'Rabbit', '🐰', '/r/ sound', 'A swift rabbit hops in the meadow.'],
        ['S', 'Sun', '☀️', '/s/ sound', 'The bright sun warms the mountain.'],
        ['T', 'Tiger', '🐯', '/t/ sound', 'The strong tiger runs through trees.'],
        ['U', 'Umbrella', '☂️', '/ʌ/ sound', 'Open your umbrella when rain falls.'],
        ['V', 'Van', '🚐', '/v/ sound', 'Our school van travels to the safari.'],
        ['W', 'Water', '💧', '/w/ sound', 'Drink fresh water to stay strong.'],
        ['X', 'Xylophone', '🎵', '/ks/ sound', 'Play cheerful music on the xylophone.'],
        ['Y', 'Yellow', '💛', '/j/ sound', 'Yellow sunflowers shine in the light.'],
        ['Z', 'Zebra', '🦓', '/z/ sound', 'A zebra has black and white stripes.'],
        ['CAT', 'Cat', '🐱', 'C-A-T Blend', 'The little cat naps on the rug.'],
        ['DOG', 'Dog', '🐶', 'D-O-G Blend', 'My pet dog loves fetching sticks.'],
        ['SUN', 'Sun', '☀️', 'S-U-N Blend', 'The morning sun wakes the animals.'],
        ['HAT', 'Hat', '🎩', 'H-A-T Blend', 'A magical hat with silver stars.'],
      ];
      final item = cvcWords[(clampedDay - 16) % cvcWords.length];
      final keyWord = item[0];
      final word = item[1];
      final emoji = item[2];
      final sound = item[3];
      final sentence = item[4];

      return KidDaySyllabus(
        day: clampedDay,
        title: 'Blending & Words: $keyWord',
        category: '🔤 Phonics & 3-Letter Blends',
        gameType: gameType,
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
        ['Red & Blue', 'Colors of sky and fire', '🎨', 'The red apple is on the blue plate.'],
        ['Yellow & Green', 'Colors of sun and leaves', '🌻', 'Green leaves shine under yellow sunlight.'],
        ['Purple & Orange', 'Bright fruit colors', '🍇', 'Purple grapes and sweet orange juice.'],
        ['Pink & White', 'Gentle colors', '🌸', 'Pink flowers bloom in white snow.'],
        ['Circle & Square', 'Basic shapes', '⭕', 'The sun is a circle, the box is a square.'],
        ['Triangle & Star', 'Geometric shapes', '⭐', 'A starry sky above triangular mountains.'],
        ['Numbers 1 to 3', 'Counting stars', '1️⃣', 'One sun, two eyes, three birds.'],
        ['Numbers 4 to 6', 'Counting mates', '4️⃣', 'Four legs, five fingers, six cherries.'],
        ['Numbers 7 to 10', 'Big numbers', '🔟', 'Seven days, eight balloons, ten gold stars.'],
        ['Big & Small', 'Comparisons', '🐘', 'The elephant is big, the mouse is small.'],
        ['Tall & Short', 'Heights', '🦒', 'The giraffe is tall, the cub is short.'],
        ['Hot & Cold', 'Opposites', '❄️', 'Hot cocoa warms the cold winter day.'],
        ['Fast & Slow', 'Speed', '🐆', 'The cheetah is fast, the turtle is slow.'],
        ['Up & Down', 'Directions', '🎈', 'The balloon floats up, leaves flutter down.'],
        ['In & Out', 'Positions', '🚪', 'Step in the classroom, play out in the yard.'],
      ];
      final item = colorNumberTopics[(clampedDay - 31) % colorNumberTopics.length];
      final topic = item[0];
      final desc = item[1];
      final emoji = item[2];
      final sentence = item[3];

      return KidDaySyllabus(
        day: clampedDay,
        title: '$topic ($desc)',
        category: '🎨 Colors, Shapes & Numbers',
        gameType: gameType,
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
        ['Lion King', 'Savannah King', '🦁', 'The proud lion roars across the golden savannah.'],
        ['Tiger Stripes', 'Jungle Predator', '🐯', 'The brave tiger creeps silently in tall grass.'],
        ['Panda Bamboo', 'Forest Herbivore', '🐼', 'The gentle panda eats sweet green bamboo.'],
        ['Playful Dolphin', 'Ocean Swimmer', '🐬', 'Dolphins leap high above sparkling ocean waves.'],
        ['Soaring Eagle', 'Mountain Flyer', '🦅', 'The mighty eagle flies over mountain peaks.'],
        ['Cunning Fox', 'Woodland Scout', '🦊', 'The clever fox hunts with sharp ears.'],
        ['Gentle Koala', 'Tree Sleeper', '🐨', 'The soft koala hugs the eucalyptus branch.'],
        ['Speedy Cheetah', 'Fastest Runner', '🐆', 'Cheetahs sprint faster than wind across plains.'],
        ['Wise Owl', 'Night Guardian', '🦉', 'The wise owl hooted under the moonlit sky.'],
        ['Busy Honeybee', 'Garden Worker', '🐝', 'Bees make sweet golden honey from colorful blossoms.'],
        ['Graceful Swan', 'Lake Beauty', '🦢', 'The white swan glides peacefully on blue water.'],
        ['Playful Otter', 'River Explorer', '🦦', 'Otters hold hands while floating downstream.'],
        ['Mighty Elephant', 'Savannah Giant', '🐘', 'Elephants remember friends for a whole lifetime.'],
        ['Tiny Hummingbird', 'Flower Dancer', '🐦', 'A hummingbird flaps its wings with electric speed.'],
        ['Forest Biome Review', 'Safari Master', '🌳', 'Protect animals and trees to preserve nature.'],
      ];
      final item = safariTopics[(clampedDay - 46) % safariTopics.length];
      final topic = item[0];
      final desc = item[1];
      final emoji = item[2];
      final sentence = item[3];

      return KidDaySyllabus(
        day: clampedDay,
        title: '$topic Safari Adventure',
        category: '🐾 Animal Kingdom & Nature',
        gameType: gameType,
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
        ['Jump & Leap', 'High Energy Verbs', '🦘', 'Jump over obstacles with cheerful energy.'],
        ['Run & Sprint', 'Movement Verbs', '🏃', 'Run safely on the school playground with friends.'],
        ['Sing & Melody', 'Music & Joy', '🎤', 'Sing a cheerful song to brighten everyone\'s day.'],
        ['Dance & Rhythm', 'Movement & Art', '💃', 'Dance to the lively jungle rhythm.'],
        ['Read & Learn', 'Mind Growth', '📖', 'Read exciting storybooks to discover new worlds.'],
        ['Write & Draw', 'Creativity', '✏️', 'Write kind words and draw bright stars.'],
        ['Eat & Nourish', 'Healthy Foods', '🍎', 'Eat crunchy fresh apples and vegetables.'],
        ['Drink & Hydrate', 'Health Essentials', '🥛', 'Drink clean fresh water every morning.'],
        ['Sleep & Rest', 'Recharge Routine', '🌙', 'Sleep early to wake up active and happy.'],
        ['Happy & Joyful', 'Positive Emotion', '😄', 'I am happy when playing with my mates.'],
        ['Brave & Courageous', 'Heroic Emotion', '🦁', 'Brave kids speak up and help others.'],
        ['Kind & Caring', 'Friendship Emotion', '🤝', 'Kind words make friends wherever you go.'],
        ['Curious & Eager', 'Explorer Emotion', '🔍', 'Curious minds ask wonderful questions.'],
        ['Calm & Peaceful', 'Focus & Stillness', '🧘', 'Take a deep breath and stay calm in challenge.'],
        ['Daily Routine Master', 'Action Synthesis', '⏰', 'A great morning routine creates a victorious day.'],
      ];
      final item = actionTopics[(clampedDay - 61) % actionTopics.length];
      final topic = item[0];
      final desc = item[1];
      final emoji = item[2];
      final sentence = item[3];

      return KidDaySyllabus(
        day: clampedDay,
        title: '$topic ($desc)',
        category: '⚡ Action Verbs & Feelings',
        gameType: gameType,
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
        ['I am & You are', 'Pronouns & Be-Verbs', '🙋', 'I am an explorer and you are my mate.'],
        ['He is & She is', 'Third-Person Pronouns', '👫', 'He is reading a book and she is playing guitar.'],
        ['We are & They are', 'Plural Pronouns', '👥', 'We are the champion team on the mountain.'],
        ['In, On, Under', 'Prepositions of Place', '📦', 'The book is on the desk, the cat is in the box.'],
        ['Behind & In Front', 'Spatial Awareness', '🚪', 'Stand in front of the door, not behind it.'],
        ['Next to & Between', 'Positioning', '↔️', 'Sit next to your mate during story time.'],
        ['What is this?', 'Question Practice 1', '❓', 'What is this magical golden key?'],
        ['Where is it?', 'Question Practice 2', '🗺️', 'Where is the secret mountain trail path?'],
        ['Who is that?', 'Question Practice 3', '👤', 'Who is that brave companion leading the team?'],
        ['Because & And', 'Connecting Sentences', '🔗', 'I practice English because I want to travel.'],
      ];
      final item = grammarTopics[(clampedDay - 76) % grammarTopics.length];
      final topic = item[0];
      final desc = item[1];
      final emoji = item[2];
      final sentence = item[3];

      return KidDaySyllabus(
        day: clampedDay,
        title: '$topic ($desc)',
        category: '🧩 Grammar Power & Sentence Building',
        gameType: gameType,
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
        ['Please & Thank You', 'Magic Words', '🙏', 'Please pass the pencils and thank you kindly.'],
        ['Excuse Me & Sorry', 'Polite Etiquette', '🙇', 'Excuse me, may I ask a quick question?'],
        ['May I Please Borrow?', 'Sharing Manners', '🤝', 'May I please borrow your color crayons?'],
        ['Nice to Meet You', 'First Introductions', '👋', 'Hello! My name is Leo, nice to meet you!'],
        ['How are you doing?', 'Friendly Inquiries', '💬', 'How are you doing today my friend? I am great!'],
        ['Ordering Food & Snacks', 'Daily Practical English', '🍽️', 'I would like a glass of warm milk please.'],
        ['Asking for Directions', 'Navigation Phrases', '🧭', 'Excuse me, where is the library building?'],
        ['Cheering for a Mate', 'Encouragement Words', '🎉', 'You can do it! I believe in your strength!'],
        ['Solving a Disagreement', 'Peaceful Dialogue', '🕊️', 'Let us take turns and play peacefully together.'],
        ['Saying Goodbye with Warmth', 'Farewell Etiquette', '🌅', 'Have a wonderful evening, see you tomorrow!'],
      ];
      final item = socialTopics[(clampedDay - 86) % socialTopics.length];
      final topic = item[0];
      final desc = item[1];
      final emoji = item[2];
      final sentence = item[3];

      return KidDaySyllabus(
        day: clampedDay,
        title: '$topic ($desc)',
        category: '🤝 Polite Manners & Social English',
        gameType: gameType,
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
      ['Storytelling Odyssey', 'Narrative Fluency', '📚', 'Once upon a time, brave animals climbed a magical mountain.'],
      ['Public Speaking & Courage', 'Oratorical Confidence', '🎙️', 'Stand tall, breathe deeply, and speak with unwavering clarity.'],
      ['Leadership & Kingdom Accords', 'Inspiring Others', '🦁', 'True leaders protect their team and inspire everyone to shine.'],
      ['Pre-Summit Master Synthesis', '99-Day Review', '🏆', 'I have practiced 99 days and my English is strong and fluent!'],
    ];
    final item = summitTopics[(clampedDay - 96) % summitTopics.length];
    final topic = item[0];
    final desc = item[1];
    final emoji = item[2];
    final sentence = item[3];

    return KidDaySyllabus(
      day: clampedDay,
      title: '$topic ($desc)',
      category: '🏔️ Summit Leadership & Public Speaking',
      gameType: gameType,
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
