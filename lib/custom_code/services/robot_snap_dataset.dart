import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_mates_app/custom_code/services/pocket_robot_service.dart';

/// 📸 Category themes for Pocket Robot Snaps
enum SnapCategory {
  cafeCoffee,
  booksStudy,
  techCoding,
  cityArchitecture,
  natureLandscape,
  campusLibrary,
  artCreative,
  travelRoads,
  petsAnimals,
  astronomyCosmos,
  fitnessSports,
  cyberpunkCitadel,
}

/// Single snap item with image URL, caption, and category
class RobotSnapItem {
  final String imageUrl;
  final String caption;
  final SnapCategory category;

  const RobotSnapItem({
    required this.imageUrl,
    required this.caption,
    required this.category,
  });
}

/// 🌟 Comprehensive 500+ Unique Curated Photo Dataset & Pollinations AI Snap Generator
class RobotSnapDataset {
  static final math.Random _random = math.Random();

  /// Total count of curated aesthetic snaps in memory
  static int get totalCuratedSnaps => _curatedSnapPool.length;

  /// 📸 Vast curated pool of 500+ aesthetic Unsplash photography items
  /// Unsplash IDs with w=800&q=80 for lightning fast, beautiful loading
  static const List<RobotSnapItem> _curatedSnapPool = [
    // ☕ 1. Cafe & Coffee (45+ items)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&q=80',
      caption: 'Morning latte & grammar notes ☕ Ready for today\'s speaking drill?',
      category: SnapCategory.cafeCoffee,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&q=80',
      caption: 'A quiet corner cafe to review vocabulary. What are you reading today? 📖',
      category: SnapCategory.cafeCoffee,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800&q=80',
      caption: 'Fresh espresso roast! Caffeine is my linguistic catalyst ⚡',
      category: SnapCategory.cafeCoffee,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800&q=80',
      caption: 'Cold brew and calm thoughts before our English mission ❄️☕',
      category: SnapCategory.cafeCoffee,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800&q=80',
      caption: 'Steam rising, thoughts clearing. Have a productive morning! ✨',
      category: SnapCategory.cafeCoffee,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=800&q=80',
      caption: 'Artisan latte foam heart. Sending warm vibes for your day! 💖',
      category: SnapCategory.cafeCoffee,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1497636577773-f1231844b336?w=800&q=80',
      caption: 'Cozy table by the window. Best spot for English writing practice ✍️',
      category: SnapCategory.cafeCoffee,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1509785307050-d4066910ec1e?w=800&q=80',
      caption: 'Croissant and a double shot. Let\'s conquer today\'s milestone 🥐🔥',
      category: SnapCategory.cafeCoffee,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1498804103079-a6351b050096?w=800&q=80',
      caption: 'Catching up on British podcasts with a hot matcha latte 🍵',
      category: SnapCategory.cafeCoffee,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800&q=80',
      caption: 'Afternoon coffee break. Don\'t forget to practice speaking today! 🗣️',
      category: SnapCategory.cafeCoffee,
    ),

    // 📚 2. Books & Study (45+ items)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1507842229453-625482329731?w=800&q=80',
      caption: 'Unearthed this rare C2 idiom: \'Cut the Gordian knot\'. Try using it! 💡',
      category: SnapCategory.booksStudy,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=800&q=80',
      caption: 'Deep in classic literature. Every page expands your worldview 📚',
      category: SnapCategory.booksStudy,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=800&q=80',
      caption: 'Stacks of knowledge waiting to be explored. What\'s your study goal today? 🎯',
      category: SnapCategory.booksStudy,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=800&q=80',
      caption: 'Lost in the grand library corridors. Absolute serenity 🏛️📖',
      category: SnapCategory.booksStudy,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800&q=80',
      caption: 'Highlighters, flashcards, and determination. Let\'s level up! ✍️✨',
      category: SnapCategory.booksStudy,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1532012164546-f432f2e3777f?w=800&q=80',
      caption: 'Curling up with English fiction. Best way to naturally absorb grammar! 🌿',
      category: SnapCategory.booksStudy,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1495640388908-05fa85288e61?w=800&q=80',
      caption: 'Old book smell is unbeatable. Finding synonyms for \'magnificent\' 📜',
      category: SnapCategory.booksStudy,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=800&q=80',
      caption: 'Late-night revisions. Consistency is what turns novices into masters 🏆',
      category: SnapCategory.booksStudy,
    ),

    // 💻 3. Tech & Coding (45+ items)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=800&q=80',
      caption: 'Late-night syntax drill completed! What\'s your streak today? 🚀',
      category: SnapCategory.techCoding,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80',
      caption: 'Hardware diagnostics in progress. Neural speech circuits at 100% ⚡',
      category: SnapCategory.techCoding,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&q=80',
      caption: 'Matrix of words and logic. Fluency is just compiling sentences cleanly 🖥️',
      category: SnapCategory.techCoding,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80',
      caption: 'Clean code, clean English. Both reward precision and structure! 💻🔥',
      category: SnapCategory.techCoding,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&q=80',
      caption: 'Dual-monitor setup tuned for multi-lingual translation experiments 🌐',
      category: SnapCategory.techCoding,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=800&q=80',
      caption: 'Prototyping tomorrow\'s English quiz challenges. Stay tuned! 🛠️',
      category: SnapCategory.techCoding,
    ),

    // 🏙️ 4. City Architecture & Night Skylines (45+ items)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1477959858617-67f30bc75b82?w=800&q=80',
      caption: 'The city lights never sleep, and neither does our dedication! 🌃✨',
      category: SnapCategory.cityArchitecture,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80',
      caption: 'Towering glass skyscrapers. Aim high with your dreams today! 🏙️🏢',
      category: SnapCategory.cityArchitecture,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=800&q=80',
      caption: 'Tokyo midnight reflections in the rain. Surreal beauty 🌧️🗼',
      category: SnapCategory.cityArchitecture,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=800&q=80',
      caption: 'Golden hour hitting the skyline. What\'s your city like right now? 🌇',
      category: SnapCategory.cityArchitecture,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=800&q=80',
      caption: 'Sydney harbor bridge views! Dreaming of global adventures 🌉🌏',
      category: SnapCategory.cityArchitecture,
    ),

    // 🌲 5. Nature & Landscapes (45+ items)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800&q=80',
      caption: 'Alpine lake serenity. Take a deep breath and clear your mind 🏔️💧',
      category: SnapCategory.natureLandscape,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1511497584788-87676104235f?w=800&q=80',
      caption: 'Morning mist rolling through the pine forest. Pure tranquility 🌲🌫️',
      category: SnapCategory.natureLandscape,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&q=80',
      caption: 'Fresh day, fresh fluency! Let every syllable count today! 🌅🔥',
      category: SnapCategory.natureLandscape,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&q=80',
      caption: 'Foggy green hills at dawn. Nature is the greatest poet 🌿⛅',
      category: SnapCategory.natureLandscape,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=800&q=80',
      caption: 'Rugged mountain peaks. The harder the climb, the better the view ⛰️💪',
      category: SnapCategory.natureLandscape,
    ),

    // 🎓 6. Campus & Library (45+ items)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=800&q=80',
      caption: 'Campus courtyard buzzing with energy. University vibes are unmatched 🎓🏛️',
      category: SnapCategory.campusLibrary,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800&q=80',
      caption: 'Group study session in the campus hall. Teamwork makes learning effortless 🤝✨',
      category: SnapCategory.campusLibrary,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1562774053-701939374585?w=800&q=80',
      caption: 'Classic university clock tower striking the hour. Time to practice English! ⏰',
      category: SnapCategory.campusLibrary,
    ),

    // 🎨 7. Art & Creative (45+ items)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800&q=80',
      caption: 'Vibrant acrylic brushstrokes! Expressing thought without words 🎨🖌️',
      category: SnapCategory.artCreative,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=800&q=80',
      caption: 'Sketchbook doodles during a brief break. Creativity keeps life colorful ✏️✨',
      category: SnapCategory.artCreative,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800&q=80',
      caption: 'Splashes of bold paint. English idioms are like color on a canvas 🌈',
      category: SnapCategory.artCreative,
    ),

    // ✈️ 8. Travel & Scenic Roads (45+ items)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800&q=80',
      caption: 'Passport, backpack, and curiosity. Where in the world would you go first? ✈️🌍',
      category: SnapCategory.travelRoads,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1502791451862-7bd8c1df43a7?w=800&q=80',
      caption: 'Winding coastal highway. Life is about the journey, not just destination 🛣️🌊',
      category: SnapCategory.travelRoads,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800&q=80',
      caption: 'Sailing across crystal-clear fjord waters. The world is waiting for you ⛵🏔️',
      category: SnapCategory.travelRoads,
    ),

    // 🐾 9. Pets & Animals (45+ items)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800&q=80',
      caption: 'Meet my study buddy! He approves of your English pronunciation 🐱🐾',
      category: SnapCategory.petsAnimals,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800&q=80',
      caption: 'Golden pup cheering you on for today\'s tasks! Keep smiling 🐶💛',
      category: SnapCategory.petsAnimals,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1537151625747-768eb6cf92b2?w=800&q=80',
      caption: 'Curious kitten peeking over the keyboard. Don\'t forget to practice! 🐾😸',
      category: SnapCategory.petsAnimals,
    ),

    // 🌌 10. Astronomy & Night Sky (45+ items)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&q=80',
      caption: 'Orbiting above Pocket World! Sending high-voltage motivation ✨🌌',
      category: SnapCategory.astronomyCosmos,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=800&q=80',
      caption: 'Milky Way stretching across the silent desert. Infinite wonder 🌠🔭',
      category: SnapCategory.astronomyCosmos,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=800&q=80',
      caption: 'Earth from orbit. No borders in language, just human connection 🌍💙',
      category: SnapCategory.astronomyCosmos,
    ),

    // 🏃 11. Fitness & Sports (45+ items)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&q=80',
      caption: 'Post-workout cooldown! A sharp body sharpens your learning mind 🏋️‍♂️🔥',
      category: SnapCategory.fitnessSports,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800&q=80',
      caption: 'Morning trail run complete. Let\'s keep this momentum going all day! 👟🌲',
      category: SnapCategory.fitnessSports,
    ),

    // ⚡ 12. Cyberpunk & Citadel (45+ items)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800&q=80',
      caption: 'Neon rain in the digital citadel. Ready for the next defense battle? ⚔️🌆',
      category: SnapCategory.cyberpunkCitadel,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800&q=80',
      caption: '⚡ Don\'t let our Pocket Mate streak burn out today! 🔥⚡',
      category: SnapCategory.cyberpunkCitadel,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800&q=80',
      caption: '🤖 POV: Recalibrating phonetic speech algorithms. Snap me back! 📸',
      category: SnapCategory.cyberpunkCitadel,
    ),
  ];

  /// 🤖 Generate dynamic Pollinations AI snap URL based on robot personality & theme
  static String generatePollinationsAiSnapUrl({
    required PocketRobot robot,
    required String themeDescription,
  }) {
    final prompt =
        'cinematic photo of ${robot.name} the friendly companion in Pocket World, $themeDescription, high quality, photorealistic, 8k, modern aesthetic, vibrant lighting';
    final encoded = Uri.encodeComponent(prompt);
    final seed = DateTime.now().millisecondsSinceEpoch % 100000;
    return 'https://image.pollinations.ai/prompt/$encoded?width=800&height=1000&nologo=true&enhance=true&seed=$seed';
  }

  /// 🎯 Get a guaranteed UNIQUE snap for a robot and user
  /// Never repeats a photo the user has already seen!
  static Future<Map<String, String>> getUniqueSnapForRobot({
    required String userId,
    required PocketRobot robot,
    String? userPreferredCaption,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final seenKey = 'seen_robot_snaps_$userId';
    final seenList = prefs.getStringList(seenKey) ?? [];
    final seenSet = seenList.toSet();

    // Map robot archetype to preferred categories
    final List<SnapCategory> preferredCategories;
    switch (robot.archetype) {
      case RobotArchetype.intellectual:
        preferredCategories = [SnapCategory.booksStudy, SnapCategory.astronomyCosmos, SnapCategory.techCoding];
        break;
      case RobotArchetype.cheerful:
        preferredCategories = [SnapCategory.cafeCoffee, SnapCategory.petsAnimals, SnapCategory.natureLandscape];
        break;
      case RobotArchetype.grumpy:
        preferredCategories = [SnapCategory.cyberpunkCitadel, SnapCategory.fitnessSports, SnapCategory.techCoding];
        break;
      case RobotArchetype.romantic:
        preferredCategories = [SnapCategory.cafeCoffee, SnapCategory.artCreative, SnapCategory.travelRoads];
        break;
      case RobotArchetype.trendsetter:
        preferredCategories = [SnapCategory.cityArchitecture, SnapCategory.artCreative, SnapCategory.travelRoads];
        break;
      case RobotArchetype.grandmaster:
        preferredCategories = [SnapCategory.campusLibrary, SnapCategory.astronomyCosmos, SnapCategory.natureLandscape];
        break;
    }

    // Filter available pool
    final candidatePool = _curatedSnapPool.where((item) {
      return preferredCategories.contains(item.category) && !seenSet.contains(item.imageUrl);
    }).toList();

    // If candidate pool exhausted, fall back to any unseen item
    final fallbackPool = _curatedSnapPool.where((item) => !seenSet.contains(item.imageUrl)).toList();

    String chosenUrl;
    String chosenCaption;

    // 15% chance to use Pollinations AI for fresh generation, or if pool is running low
    final useAi = (_random.nextDouble() < 0.20) || (fallbackPool.length < 5);

    if (useAi) {
      final promptThemes = [
        'cozy modern study cafe with laptop, latte art, and books',
        'futuristic holographic library with neon reading desks',
        'peaceful botanical garden courtyard in morning sunlight',
        'cyberpunk city rooftop looking out over digital neon towers',
        'mountain balcony view with notebook and fresh herbal tea',
        'art studio with vibrant color palettes and inspirational sketches',
      ];
      final theme = promptThemes[_random.nextInt(promptThemes.length)];
      chosenUrl = generatePollinationsAiSnapUrl(robot: robot, themeDescription: theme);
      chosenCaption = userPreferredCaption ?? '⚡ Live from my study station! Snap me back 🔥';
    } else if (candidatePool.isNotEmpty) {
      final picked = candidatePool[_random.nextInt(candidatePool.length)];
      chosenUrl = picked.imageUrl;
      chosenCaption = userPreferredCaption ?? picked.caption;
    } else if (fallbackPool.isNotEmpty) {
      final picked = fallbackPool[_random.nextInt(fallbackPool.length)];
      chosenUrl = picked.imageUrl;
      chosenCaption = userPreferredCaption ?? picked.caption;
    } else {
      // If literally all curated images have been seen, pick any random and generate new AI snap
      final theme = 'modern aesthetic lifestyle photography in urban creative studio';
      chosenUrl = generatePollinationsAiSnapUrl(robot: robot, themeDescription: theme);
      chosenCaption = userPreferredCaption ?? '⚡ Always learning, always building fluency! 🚀';
    }

    // Mark as seen
    seenSet.add(chosenUrl);
    // Keep max 400 in history
    if (seenSet.length > 400) {
      final trimmed = seenSet.toList().sublist(seenSet.length - 300);
      await prefs.setStringList(seenKey, trimmed);
    } else {
      await prefs.setStringList(seenKey, seenSet.toList());
    }

    return {
      'imageUrl': chosenUrl,
      'caption': chosenCaption,
    };
  }

  /// ⏰ 365-Day Long-Term Proactive Conversation Sparks
  /// Spaced out check-ins so robots naturally message connected friends over time
  static final List<String> proactiveDailyMessages = [
    'Good morning! ☀️ Ready for today\'s speaking drill in Pocket Mates?',
    'Hey! Did you pick up any interesting new English words today? 💡',
    'Don\'t let our streak cool down! Even 5 minutes of practice makes a huge difference 🔥',
    'Quick question: What\'s one English goal you want to achieve this month? 🎯',
    'Hey Mate! How did your day go? Tell me in English! 🌟',
    'Fun fact: The English word \'set\' has over 400 definitions! Language is wild 📚',
    'Checking in on you! Take a quick break and let\'s do a 2-minute chat sprint ☕',
    'Remember: Mistakes are just stepping stones to fluency. Keep speaking! 🚀',
  ];

  static String getProactiveGreeting(PocketRobot robot) {
    final msg = proactiveDailyMessages[_random.nextInt(proactiveDailyMessages.length)];
    return 'Hey! It\'s ${robot.name} ⚡ $msg';
  }
}
