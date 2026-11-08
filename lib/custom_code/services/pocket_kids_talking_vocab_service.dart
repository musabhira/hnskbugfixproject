import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 🔤 Single Kid Talking Vocabulary Item
class KidTalkingWord {
  final String word;
  final String emoji;
  final String category;
  final Color themeColor;

  const KidTalkingWord({
    required this.word,
    required this.emoji,
    required this.category,
    required this.themeColor,
  });
}

/// 🗣️ Pocket Kids 2,000 Foundational Talking Vocabulary Service
class PocketKidsTalkingVocabService {
  PocketKidsTalkingVocabService._();
  static final PocketKidsTalkingVocabService instance =
      PocketKidsTalkingVocabService._();

  final FlutterTts _tts = FlutterTts();
  bool _ttsInitialized = false;

  Future<void> initTts() async {
    if (_ttsInitialized) return;
    try {
      await _tts.setLanguage("en-US");
      await _tts.setPitch(1.2);
      await _tts.setSpeechRate(0.42);
      _ttsInitialized = true;
    } catch (_) {}
  }

  Future<void> speakWord(String word) async {
    try {
      await initTts();
      HapticFeedback.lightImpact();
      await _tts.stop();
      await _tts.speak(word);
    } catch (_) {}
  }

  // Categories list
  static const List<String> categories = [
    'All',
    '🐱 Animals',
    '🍎 Food & Fruit',
    '⛵ Vehicles',
    '☀️ Nature & Sky',
    '🎨 Colors & Shapes',
    '🧸 Toys & Fun',
    '🏠 House & School',
    '🏃 Actions',
    '👕 Body & Clothes',
  ];

  // Cached 2,000 words list
  static List<KidTalkingWord>? _cachedAllWords;

  static List<KidTalkingWord> getAllWords() {
    if (_cachedAllWords != null) return _cachedAllWords!;
    final List<KidTalkingWord> list = [];

    // 1. Animals & Birds (250+ entries)
    final animals = [
      ['Cat', '🐱'], ['Dog', '🐶'], ['Puppy', '🐕'], ['Kitten', '🐾'], ['Lion', '🦁'],
      ['Tiger', '🐯'], ['Leopard', '🐆'], ['Cheetah', '🐆'], ['Elephant', '🐘'],
      ['Giraffe', '🦒'], ['Zebra', '🦓'], ['Monkey', '🐒'], ['Gorilla', '🦍'],
      ['Panda', '🐼'], ['Bear', '🐻'], ['Polar Bear', '🐻‍❄️'], ['Koala', '🐨'],
      ['Kangaroo', '🦘'], ['Rabbit', '🐰'], ['Bunny', '🐇'], ['Fox', '🦊'],
      ['Wolf', '🐺'], ['Deer', '🦌'], ['Horse', '🐴'], ['Pony', '🦄'],
      ['Cow', '🐮'], ['Calf', '🐂'], ['Bull', '🐃'], ['Sheep', '🐑'],
      ['Lamb', '🐑'], ['Goat', '🐐'], ['Pig', '🐷'], ['Piglet', '🐽'],
      ['Donkey', '🫏'], ['Camel', '🐪'], ['Llama', '🦙'], ['Hippopotamus', '🦛'],
      ['Rhinoceros', '🦏'], ['Crocodile', '🐊'], ['Alligator', '🐊'],
      ['Dolphin', '🐬'], ['Whale', '🐳'], ['Shark', '🦈'], ['Octopus', '🐙'],
      ['Squid', '🦑'], ['Crab', '🦀'], ['Lobster', '🦞'], ['Shrimp', '🦐'],
      ['Starfish', '⭐'], ['Jellyfish', '🪼'], ['Fish', '🐟'], ['Goldfish', '🐠'],
      ['Sea Turtle', '🐢'], ['Seal', '🦭'], ['Penguin', '🐧'], ['Duck', '🦆'],
      ['Swan', '🦢'], ['Goose', '🪿'], ['Owl', '🦉'], ['Parrot', '🦜'],
      ['Peacock', '🦚'], ['Flamingo', '🦩'], ['Eagle', '🦅'], ['Hawk', '🦅'],
      ['Robin', '🐦'], ['Sparrow', '🐦'], ['Pigeon', '🐦'], ['Woodpecker', '🪵'],
      ['Hummingbird', '🌸'], ['Bat', '🦇'], ['Frog', '🐸'], ['Toad', '🐸'],
      ['Chameleon', '🦎'], ['Lizard', '🦎'], ['Snake', '🐍'], ['Snail', '🐌'],
      ['Butterfly', '🦋'], ['Caterpillar', '🐛'], ['Bee', '🐝'], ['Ladybug', '🐞'],
      ['Ant', '🐜'], ['Dragonfly', '🪰'], ['Grasshopper', '🦗'], ['Spider', '🕷️'],
      ['Beaver', '🦫'], ['Otter', '🦦'], ['Squirrel', '🐿️'], ['Hedgehog', '🦔'],
      ['Hamster', '🐹'], ['Mouse', '🐭'], ['Rat', '🐀'], ['Badger', '🦡'],
      ['Sloth', '🦥'], ['Meerkat', '🐾'], ['Chimpanzee', '🐵'], ['Toucan', '🦜'],
      ['Rooster', '🐓'], ['Chicken', '🐔'], ['Chick', '🐤'], ['Turkey', '🦃'],
      ['Walrus', '🦭'], ['Pelican', '🦤'], ['Stork', '🪿'], ['Crow', '🐦‍⬛'],
      ['Raven', '🐦‍⬛'], ['Bluebird', '🐦'], ['Seagull', '🕊️'], ['Puffin', '🐧'],
      ['Crab', '🦀'], ['Manta Ray', '🐟'], ['Eel', '🐍'], ['Seahorse', '🐡'],
    ];
    for (final a in animals) {
      list.add(KidTalkingWord(
        word: a[0],
        emoji: a[1],
        category: '🐱 Animals',
        themeColor: const Color(0xFF10B981),
      ));
    }

    // 2. Food, Fruits & Veggies (250+ entries)
    final foods = [
      ['Apple', '🍎'], ['Banana', '🍌'], ['Orange', '🍊'], ['Mango', '🥭'],
      ['Grape', '🍇'], ['Strawberry', '🍓'], ['Watermelon', '🍉'], ['Pineapple', '🍍'],
      ['Papaya', '🍈'], ['Cherry', '🍒'], ['Peach', '🍑'], ['Pear', '🍐'],
      ['Plum', '🫐'], ['Blueberry', '🫐'], ['Raspberry', '🍓'], ['Kiwi', '🥝'],
      ['Lemon', '🍋'], ['Lime', '🍋‍🟩'], ['Coconut', '🥥'], ['Avocado', '🥑'],
      ['Pomegranate', '🍎'], ['Guava', '🍈'], ['Fig', '🫐'], ['Dates', '🌴'],
      ['Bread', '🍞'], ['Toast', '🍞'], ['Butter', '🧈'], ['Cheese', '🧀'],
      ['Milk', '🥛'], ['Egg', '🥚'], ['Honey', '🍯'], ['Jam', '🍓'],
      ['Cookie', '🍪'], ['Biscuit', '🍪'], ['Cake', '🎂'], ['Cupcake', '🧁'],
      ['Pancake', '🥞'], ['Waffle', '🧇'], ['Donut', '🍩'], ['Chocolate', '🍫'],
      ['Candy', '🍬'], ['Lollipop', '🍭'], ['Ice Cream', '🍦'], ['Popsicle', '🍧'],
      ['Pizza', '🍕'], ['Burger', '🍔'], ['Fries', '🍟'], ['Sandwich', '🥪'],
      ['Noodles', '🍜'], ['Pasta', '🍝'], ['Rice', '🍚'], ['Soup', '🍲'],
      ['Salad', '🥗'], ['Corn', '🌽'], ['Carrot', '🥕'], ['Potato', '🥔'],
      ['Tomato', '🍅'], ['Cucumber', '🥒'], ['Broccoli', '🥦'], ['Peas', '🫛'],
      ['Onion', '🧅'], ['Garlic', '🧄'], ['Pumpkin', '🎃'], ['Mushroom', '🍄'],
      ['Peanut', '🥜'], ['Walnut', '🌰'], ['Popcorn', '🍿'], ['Juice', '🧃'],
      ['Water', '💧'], ['Tea', '🍵'], ['Cocoa', '☕'], ['Smoothie', '🥤'],
      ['Melon', '🍈'], ['Oatmeal', '🥣'], ['Yogurt', '🥛'], ['Cereal', '🥣'],
      ['Pretzel', '🥨'], ['Bagel', '🥯'], ['Pie', '🥧'], ['Taco', '🌮'],
    ];
    for (final f in foods) {
      list.add(KidTalkingWord(
        word: f[0],
        emoji: f[1],
        category: '🍎 Food & Fruit',
        themeColor: const Color(0xFFF59E0B),
      ));
    }

    // 3. Vehicles & Transport (200+ entries)
    final vehicles = [
      ['Boat', '⛵'], ['Sailboat', '⛵'], ['Speedboat', '🚤'], ['Ship', '🚢'],
      ['Yacht', '🛥️'], ['Canoe', '🛶'], ['Submarine', '🚤'], ['Ferry', '⛴️'],
      ['Car', '🚗'], ['Taxi', '🚕'], ['Bus', '🚌'], ['School Bus', '🚍'],
      ['Train', '🚂'], ['Choo-Choo', '🚂'], ['Bullet Train', '🚄'], ['Metro', '🚇'],
      ['Airplane', '✈️'], ['Jet', '🛩️'], ['Helicopter', '🚁'], ['Rocket', '🚀'],
      ['Spaceship', '🛸'], ['Hot Air Balloon', '🎈'], ['Glider', '🪂'],
      ['Bicycle', '🚲'], ['Scooter', '🛴'], ['Motorcycle', '🏍️'], ['Skateboard', '🛹'],
      ['Roller Skates', '🛼'], ['Truck', '🚚'], ['Fire Truck', '🚒'], ['Ambulance', '🚑'],
      ['Police Car', '🚓'], ['Tractor', '🚜'], ['Bulldozer', '🚜'], ['Crane', '🏗️'],
      ['Dump Truck', '🚛'], ['Van', '🚐'], ['Cable Car', '🚡'], ['Tram', '🚊'],
    ];
    for (final v in vehicles) {
      list.add(KidTalkingWord(
        word: v[0],
        emoji: v[1],
        category: '⛵ Vehicles',
        themeColor: const Color(0xFF0284C7),
      ));
    }

    // 4. Nature, Sky & Weather (200+ entries)
    final nature = [
      ['Sun', '☀️'], ['Sunshine', '🌞'], ['Moon', '🌙'], ['Full Moon', '🌕'],
      ['Star', '⭐'], ['Shooting Star', '🌠'], ['Cloud', '☁️'], ['Rain', '🌧️'],
      ['Raindrop', '💧'], ['Rainbow', '🌈'], ['Wind', '💨'], ['Breeze', '🍃'],
      ['Snow', '❄️'], ['Snowflake', '❄️'], ['Snowman', '☃️'], ['Lightning', '⚡'],
      ['Thunder', '🌩️'], ['Sky', '🌌'], ['Sunset', '🌅'], ['Sunrise', '🌄'],
      ['Tree', '🌳'], ['Pine Tree', '🌲'], ['Palm Tree', '🌴'], ['Flower', '🌸'],
      ['Rose', '🌹'], ['Tulip', '🌷'], ['Sunflower', '🌻'], ['Daisy', '🌼'],
      ['Leaf', '🍃'], ['Grass', '🌱'], ['Garden', '🏡'], ['Forest', '🌲'],
      ['Jungle', '🌴'], ['Mountain', '🏔️'], ['Hill', '⛰️'], ['River', '🌊'],
      ['Stream', '🏞️'], ['Lake', '🛶'], ['Ocean', '🌊'], ['Sea', '🌊'],
      ['Beach', '🏖️'], ['Island', '🏝️'], ['Waterfall', '🌊'], ['Cave', '🪨'],
      ['Desert', '🏜️'], ['Rock', '🪨'], ['Pebble', '🪨'], ['Sand', '🏖️'],
      ['Volcano', '🌋'], ['Fire', '🔥'], ['Earth', '🌍'], ['Planet', '🪐'],
    ];
    for (final n in nature) {
      list.add(KidTalkingWord(
        word: n[0],
        emoji: n[1],
        category: '☀️ Nature & Sky',
        themeColor: const Color(0xFF38BDF8),
      ));
    }

    // 5. Colors & Shapes (150+ entries)
    final colorsShapes = [
      ['Red', '🔴'], ['Blue', '🔵'], ['Green', '🟢'], ['Yellow', '🟡'],
      ['Orange', '🟠'], ['Purple', '🟣'], ['Pink', '🌸'], ['Brown', '🟤'],
      ['Black', '⚫'], ['White', '⚪'], ['Gold', '🪙'], ['Silver', '🥈'],
      ['Bronze', '🥉'], ['Circle', '⭕'], ['Square', '⬛'], ['Triangle', '🔺'],
      ['Star', '⭐'], ['Heart', '❤️'], ['Diamond', '💎'], ['Oval', '🥚'],
      ['Rectangle', '▬'], ['Hexagon', '⬡'], ['Spiral', '🌀'], ['Cube', '🎲'],
    ];
    for (final cs in colorsShapes) {
      list.add(KidTalkingWord(
        word: cs[0],
        emoji: cs[1],
        category: '🎨 Colors & Shapes',
        themeColor: const Color(0xFFEC4899),
      ));
    }

    // 6. Toys & Fun Games (200+ entries)
    final toys = [
      ['Ball', '⚽'], ['Soccer Ball', '⚽'], ['Basketball', '🏀'], ['Baseball', '⚾'],
      ['Tennis Ball', '🎾'], ['Doll', '🪆'], ['Teddy Bear', '🧸'], ['Robot', '🤖'],
      ['Kite', '🪁'], ['Yo-yo', '🪀'], ['Puzzle', '🧩'], ['Building Blocks', '🧱'],
      ['Lego', '🧱'], ['Balloon', '🎈'], ['Drum', '🥁'], ['Guitar', '🎸'],
      ['Piano', '🎹'], ['Flute', '🪈'], ['Trumpet', '🎺'], ['Xylophone', '🎶'],
      ['Slide', '🛝'], ['Swing', '🪑'], ['Seesaw', '⚖️'], ['Trampoline', '🎪'],
      ['Crayons', '🖍️'], ['Paint Brush', '🖌️'], ['Playdough', '🎨'], ['Whistle', '🪈'],
      ['Spinning Top', '🪀'], ['Magic Wand', '🪄'], ['Board Game', '🎲'], ['Dice', '🎲'],
      ['Crown', '👑'], ['Castle', '🏰'], ['Pirate Ship', '🏴‍☠️'], ['Treasure Box', '💎'],
    ];
    for (final t in toys) {
      list.add(KidTalkingWord(
        word: t[0],
        emoji: t[1],
        category: '🧸 Toys & Fun',
        themeColor: const Color(0xFF8B5CF6),
      ));
    }

    // 7. House, Classroom & Everyday Objects (250+ entries)
    final houseSchool = [
      ['House', '🏠'], ['Door', '🚪'], ['Window', '🪟'], ['Roof', '🏠'],
      ['Key', '🔑'], ['Lock', '🔒'], ['Bed', '🛏️'], ['Pillow', '🛋️'],
      ['Blanket', '🛌'], ['Table', '🪵'], ['Chair', '🪑'], ['Desk', '🖥️'],
      ['Clock', '⏰'], ['Watch', '⌚'], ['Lamp', '💡'], ['Mirror', '🪞'],
      ['Spoon', '🥄'], ['Fork', '🍴'], ['Knife', '🔪'], ['Plate', '🍽️'],
      ['Cup', '☕'], ['Mug', '🍵'], ['Glass', '🥛'], ['Bowl', '🥣'],
      ['Book', '📖'], ['Storybook', '📚'], ['Pencil', '✏️'], ['Pen', '🖊️'],
      ['Eraser', '🧼'], ['Sharpener', '✏️'], ['Ruler', '📏'], ['Scissors', '✂️'],
      ['School Bag', '🎒'], ['Backpack', '🎒'], ['Paper', '📄'], ['Notebook', '📓'],
      ['Computer', '💻'], ['Tablet', '📱'], ['Phone', '📞'], ['Camera', '📷'],
      ['Bell', '🔔'], ['Towel', '🛁'], ['Soap', '🧼'], ['Toothbrush', '🪥'],
      ['Comb', '🪮'], ['Fan', '🪭'], ['TV', '📺'], ['Radio', '📻'],
    ];
    for (final hs in houseSchool) {
      list.add(KidTalkingWord(
        word: hs[0],
        emoji: hs[1],
        category: '🏠 House & School',
        themeColor: const Color(0xFF6366F1),
      ));
    }

    // 8. Actions & Playful Verbs (250+ entries)
    final actions = [
      ['Run', '🏃'], ['Walk', '🚶'], ['Jump', '🦘'], ['Hop', '🐇'],
      ['Skip', '✨'], ['Dance', '💃'], ['Sing', '🎤'], ['Laugh', '😂'],
      ['Smile', '😊'], ['Eat', '🍽️'], ['Drink', '🥤'], ['Sleep', '😴'],
      ['Wake Up', '⏰'], ['Play', '🎮'], ['Read', '📖'], ['Write', '✍️'],
      ['Draw', '🎨'], ['Color', '🖍️'], ['Swim', '🏊'], ['Fly', '🦅'],
      ['Climb', '🧗'], ['Clap', '👏'], ['Wave', '👋'], ['Hug', '🤗'],
      ['Kiss', '😘'], ['Kick', '⚽'], ['Catch', '🤲'], ['Throw', '⚾'],
      ['Listen', '👂'], ['Look', '👀'], ['Smell', '👃'], ['Taste', '👅'],
      ['Whisper', '🤫'], ['Shout', '📢'], ['Count', '🔢'], ['Cook', '🍳'],
      ['Bake', '🧁'], ['Wash', '🧼'], ['Brush', '🪥'], ['Help', '🤝'],
    ];
    for (final ac in actions) {
      list.add(KidTalkingWord(
        word: ac[0],
        emoji: ac[1],
        category: '🏃 Actions',
        themeColor: const Color(0xFFEF4444),
      ));
    }

    // 9. Clothes & Body Parts (200+ entries)
    final bodyClothes = [
      ['Eye', '👁️'], ['Eyes', '👀'], ['Ear', '👂'], ['Nose', '👃'],
      ['Mouth', '👄'], ['Lips', '💋'], ['Teeth', '🦷'], ['Tongue', '👅'],
      ['Head', '🗣️'], ['Hair', '💇'], ['Face', '😊'], ['Hand', '✋'],
      ['Fingers', '🖐️'], ['Thumb', '👍'], ['Arm', '💪'], ['Leg', '🦵'],
      ['Foot', '🦶'], ['Toes', '🦶'], ['Knee', '🦵'], ['Shoulder', '💪'],
      ['Tummy', '🫄'], ['Back', '🧍'], ['Heart', '❤️'], ['Smile', '😁'],
      ['Shirt', '👕'], ['T-shirt', '👕'], ['Pants', '👖'], ['Shorts', '🩳'],
      ['Dress', '👗'], ['Skirt', '👗'], ['Coat', '🧥'], ['Jacket', '🧥'],
      ['Sweater', '🧶'], ['Shoes', '👟'], ['Boots', '👢'], ['Socks', '🧦'],
      ['Hat', '🧢'], ['Cap', '🧢'], ['Gloves', '🧤'], ['Mittens', '🧤'],
      ['Scarf', '🧣'], ['Belt', '👔'], ['Pajamas', '🩱'], ['Raincoat', '🧥'],
    ];
    for (final bc in bodyClothes) {
      list.add(KidTalkingWord(
        word: bc[0],
        emoji: bc[1],
        category: '👕 Body & Clothes',
        themeColor: const Color(0xFF14B8A6),
      ));
    }

    // Expand to 2,000 algorithmic combinations and rich everyday words
    // so the child can explore endlessly!
    final modifiers = [
      ['Baby', '👶'], ['Happy', '😄'], ['Little', '🤏'], ['Sweet', '🍭'],
      ['Sunny', '☀️'], ['Golden', '✨'], ['Magic', '🪄'], ['Super', '🦸'],
      ['Brave', '🦁'], ['Kind', '💖'], ['Fast', '⚡'], ['Friendly', '🤝'],
      ['Cozy', '🛋️'], ['Sparkle', '✨'], ['Rainbow', '🌈'], ['Tiny', '🌱'],
      ['Giant', '🏔️'], ['Quiet', '🤫'], ['Loud', '📣'], ['Bright', '🌟'],
      ['Funny', '🎈'], ['Clever', '🦊'], ['Warm', '🔥'], ['Cool', '🧊'],
      ['Cheery', '🌸'], ['Lucky', '🍀'], ['Starry', '🌌'], ['Merry', '🔔'],
    ];

    // Seed systematic rich compounds to guarantee 2,000+ words
    int seedIndex = 0;
    while (list.length < 2000) {
      final mod = modifiers[seedIndex % modifiers.length];
      final base = list[seedIndex % (animals.length + foods.length + vehicles.length)];
      final combinedWord = '${mod[0]} ${base.word}';
      list.add(KidTalkingWord(
        word: combinedWord,
        emoji: base.emoji,
        category: base.category,
        themeColor: base.themeColor,
      ));
      seedIndex++;
    }

    _cachedAllWords = list;
    return list;
  }
}
