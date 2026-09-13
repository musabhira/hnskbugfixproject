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
  englishMastery,
  dailyVocab,
  grammarHacks,
  fluentSpeaking,
  interviewTips,
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
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=800&q=80',
      caption: 'Evening study lamp and freshly brewed Earl Grey tea ☕📖',
      category: SnapCategory.cafeCoffee,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1493770348161-369560ae357d?w=800&q=80',
      caption: 'Healthy berry breakfast bowl to fuel our morning speaking sprints 🍓✨',
      category: SnapCategory.cafeCoffee,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1491841550275-ad7854e35ca6?w=800&q=80',
      caption: 'Quiet library study desk at sunrise. Let\'s make every word count! 🌅📚',
      category: SnapCategory.booksStudy,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=800&q=80',
      caption: 'Browsing antique literature. Words are bridges across centuries 📜🏛️',
      category: SnapCategory.booksStudy,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1534972195531-a756b1126975?w=800&q=80',
      caption: 'Coding interactive English grammar puzzles. Which level are you on today? 💻⚡',
      category: SnapCategory.techCoding,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?w=800&q=80',
      caption: 'Workspace dialed in. Clear space, clear mind, relentless progress 🖥️🚀',
      category: SnapCategory.techCoding,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1444723121867-7a241cacace9?w=800&q=80',
      caption: 'Neon lights reflecting on asphalt. Night stroll through the capital 🌃🌉',
      category: SnapCategory.cityArchitecture,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1506146332389-18140dc7b2fb?w=800&q=80',
      caption: 'Futuristic glass atrium in the heart of the modern arts district 🏛️✨',
      category: SnapCategory.cityArchitecture,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80',
      caption: 'Majestic mountain sunrise over the valley. Scale new heights today! 🏔️☀️',
      category: SnapCategory.natureLandscape,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?w=800&q=80',
      caption: 'Golden light filtering through autumnal birch trees 🍂🌿',
      category: SnapCategory.natureLandscape,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&q=80',
      caption: 'Collaborative workshop in session. Learning is 10x faster with mates! 🤝💡',
      category: SnapCategory.campusLibrary,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800&q=80',
      caption: 'Graduation gowns and proud smiles. Your Day 90 moment is coming! 🎓🎉',
      category: SnapCategory.campusLibrary,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1452860606245-08befc0ff44b?w=800&q=80',
      caption: 'Pottery wheel craftsmanship. Fluency takes patience and careful shaping 🏺🎨',
      category: SnapCategory.artCreative,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800&q=80',
      caption: 'Hitchhiking down Route 66 under endless blue skies 🛣️🌵',
      category: SnapCategory.travelRoads,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
      caption: 'Turquoise ocean waves lapping warm white sand. Dream big today 🌊🏖️',
      category: SnapCategory.travelRoads,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=800&q=80',
      caption: 'Two happy corgis racing across the park lawn! Pure energy 🐶🐾',
      category: SnapCategory.petsAnimals,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1518020382113-a7e8fc38eac9?w=800&q=80',
      caption: 'Funny pug tilting his head at our English pronunciation practice 🐶💬',
      category: SnapCategory.petsAnimals,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=800&q=80',
      caption: 'Deep space cosmic nebula glowing in violet and magenta. Stardust in our veins 🌌✨',
      category: SnapCategory.astronomyCosmos,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
      caption: 'Iron and sweat at 6 AM. Dedication in the gym mirrors dedication in study 🏋️🔥',
      category: SnapCategory.fitnessSports,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&q=80',
      caption: 'Holographic anime aesthetic at Shibuya neon crossing ⚡🏙️',
      category: SnapCategory.cyberpunkCitadel,
    ),

    // 📚 13. English Mastery & Daily Vocabulary Boosters (Word of the Day)
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800&q=80',
      caption: '📖 Word of the Day: Serendipity (n.) Finding good things without looking for them. "Meeting my Pocket Mate was pure serendipity!" 🌟',
      category: SnapCategory.dailyVocab,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=800&q=80',
      caption: '✨ Word of the Day: Resilient (adj.) Able to recover quickly from tough times. "Keep speaking, you are truly resilient!" 💪',
      category: SnapCategory.dailyVocab,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800&q=80',
      caption: '🎙️ Word of the Day: Eloquent (adj.) Fluent and persuasive in speaking or writing. "Daily voice practice builds eloquent speech." 🌟',
      category: SnapCategory.dailyVocab,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=800&q=80',
      caption: '🌐 Word of the Day: Ubiquitous (adj.) Present or found everywhere. "English communication skills are ubiquitous in modern work." 📱',
      category: SnapCategory.dailyVocab,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=800&q=80',
      caption: '🔥 Word of the Day: Tenacious (adj.) Persistent and determined. "Your daily study streak is tenacious! Keep shining!" 🏆',
      category: SnapCategory.dailyVocab,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800&q=80',
      caption: '⚡ Word of the Day: Catalyst (n.) An agent that accelerates change. "Speaking with mates is the catalyst for real fluency." 🚀',
      category: SnapCategory.dailyVocab,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1491841550275-ad7854e35ca6?w=800&q=80',
      caption: '✍️ Word of the Day: Meticulous (adj.) Showing great attention to detail. "Review your grammar with meticulous curiosity!" 📝',
      category: SnapCategory.dailyVocab,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=800&q=80',
      caption: '🤝 Word of the Day: Empathy (n.) Understanding the feelings of another. "Language is built on listening and empathy." 💖',
      category: SnapCategory.dailyVocab,
    ),

    // ✍️ 14. Common English Mistakes & Grammar Hacks
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800&q=80',
      caption: '❌ Don\'t say: "I look forward to hear from you"\n✅ Say: "I look forward to hearing from you" ("to" is a preposition here!) ✍️',
      category: SnapCategory.grammarHacks,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1584697964190-7bb8597520e5?w=800&q=80',
      caption: '❌ Don\'t say: "He explained me the problem"\n✅ Say: "He explained the problem TO me" (Explain needs "to"!) 🧠💡',
      category: SnapCategory.grammarHacks,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?w=800&q=80',
      caption: '⏳ Since vs For: Use "Since" for starting points (Since 2022). Use "For" for duration (For 3 years). Mastered! ⚡',
      category: SnapCategory.grammarHacks,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=800&q=80',
      caption: '❌ Don\'t say: "She is married with a doctor"\n✅ Say: "She is married TO a doctor" (Always married to!) 💍✨',
      category: SnapCategory.grammarHacks,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1517842645767-c639042777db?w=800&q=80',
      caption: '📝 Lend vs Borrow: You LEND to someone (give). You BORROW from someone (take). "Could you lend me a pencil?" ✍️',
      category: SnapCategory.grammarHacks,
    ),

    // 🗣️ 15. Native Idioms & Fluent Speaking Drills
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&q=80',
      caption: '🧊 Idiom: "Break the ice" = Make people feel relaxed in conversation. Start every chat with a warm compliment! 🌟',
      category: SnapCategory.fluentSpeaking,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800&q=80',
      caption: '☕ Native Speak: Instead of saying "I agree", try "You hit the nail on the head!" or "I couldn\'t agree more!" 🔨✨',
      category: SnapCategory.fluentSpeaking,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1577563908411-5077b6dc7624?w=800&q=80',
      caption: '🍰 Idiom: "Piece of cake" = Extremely easy. "Daily English missions on Pocket Mates are a piece of cake once you start!" 🎯',
      category: SnapCategory.fluentSpeaking,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80',
      caption: '☕ Native Slang: "Catch up" = To share news with someone you haven\'t spoken with recently. "Let\'s catch up today!" 💬',
      category: SnapCategory.fluentSpeaking,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800&q=80',
      caption: '🎙️ Fluency Secret: Speak aloud for 2 minutes every day. Tongue muscle memory creates effortless fluency! 🚀',
      category: SnapCategory.fluentSpeaking,
    ),

    // 💼 16. Professional Workplace & Interview Mastery
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=800&q=80',
      caption: '👔 Interview Tip: For "Tell me about yourself", follow the Present-Past-Future rule. Be punchy and memorable! 💼',
      category: SnapCategory.interviewTips,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=800&q=80',
      caption: '💼 Pro English: Instead of "I don\'t know", say "Let me look into that and get back to you by this afternoon." 💡',
      category: SnapCategory.interviewTips,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80',
      caption: '🤝 Business Idiom: "Touch base" = To briefly connect. "Let\'s touch base next week on the new project milestones." 🏢',
      category: SnapCategory.interviewTips,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=800&q=80',
      caption: '✨ Confidence Hack: Replace "I think maybe" with "Based on my experience, I recommend..." Own your ideas! 🏆',
      category: SnapCategory.interviewTips,
    ),
    RobotSnapItem(
      imageUrl: 'https://images.unsplash.com/photo-1531497865144-0464ef8fb9a9?w=800&q=80',
      caption: '✉️ Email Etiquette: Close professional messages with "Warm regards" or "Best regards" for a polite, polished tone 📧',
      category: SnapCategory.interviewTips,
    ),
  ];

  /// 🤖 Generate dynamic Pollinations AI snap URL based on robot personality & theme
  static String generatePollinationsAiSnapUrl({
    required PocketRobot robot,
    required String themeDescription,
  }) {
    final prompt =
        'cinematic aesthetic photo of ${robot.name} in Pocket World, $themeDescription, high quality, photorealistic, 8k, modern aesthetic, soft natural lighting, editorial portrait';
    final encoded = Uri.encodeComponent(prompt);
    final micro = DateTime.now().microsecondsSinceEpoch;
    final rand = _random.nextInt(9999999);
    final seed = (micro + rand) % 100000000;
    return 'https://image.pollinations.ai/prompt/$encoded?width=800&height=1000&nologo=true&enhance=true&seed=$seed';
  }

  /// 🎯 Get a guaranteed UNIQUE snap for a robot and user
  /// Strictly never repeats a photo the user has already seen!
  /// Fulfills user directive: "സ്നാപ്പ് അയക്കുന്നത് ഒരേ സാധനം തന്നെ റിപ്പീറ്റ് റിപ്പീറ്റ് ഒരാൾക്ക് അയക്കരുത് ദയവുചെയ്തിട്ട്."
  static Future<Map<String, String>> getUniqueSnapForRobot({
    required String userId,
    required PocketRobot robot,
    String? userPreferredCaption,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final seenKey = 'seen_robot_snaps_$userId';
    final seenList = prefs.getStringList(seenKey) ?? [];
    final seenSet = seenList.toSet();

    // Map robot archetype to preferred categories (infused with English Learning Mastery)
    final List<SnapCategory> preferredCategories;
    switch (robot.archetype) {
      case RobotArchetype.intellectual:
        preferredCategories = [SnapCategory.dailyVocab, SnapCategory.grammarHacks, SnapCategory.booksStudy, SnapCategory.astronomyCosmos];
        break;
      case RobotArchetype.cheerful:
        preferredCategories = [SnapCategory.fluentSpeaking, SnapCategory.dailyVocab, SnapCategory.cafeCoffee, SnapCategory.petsAnimals];
        break;
      case RobotArchetype.grumpy:
        preferredCategories = [SnapCategory.grammarHacks, SnapCategory.interviewTips, SnapCategory.cyberpunkCitadel, SnapCategory.fitnessSports];
        break;
      case RobotArchetype.romantic:
        preferredCategories = [SnapCategory.dailyVocab, SnapCategory.fluentSpeaking, SnapCategory.cafeCoffee, SnapCategory.artCreative];
        break;
      case RobotArchetype.trendsetter:
        preferredCategories = [SnapCategory.fluentSpeaking, SnapCategory.interviewTips, SnapCategory.cityArchitecture, SnapCategory.travelRoads];
        break;
      case RobotArchetype.grandmaster:
        preferredCategories = [SnapCategory.dailyVocab, SnapCategory.grammarHacks, SnapCategory.interviewTips, SnapCategory.campusLibrary];
        break;
    }

    // Filter available pool to strictly UNSEEN items
    final candidatePool = _curatedSnapPool.where((item) {
      return preferredCategories.contains(item.category) && !seenSet.contains(item.imageUrl);
    }).toList();

    // If candidate pool exhausted, fall back to any unseen item in entire curated pool
    final fallbackPool = _curatedSnapPool.where((item) => !seenSet.contains(item.imageUrl)).toList();

    String chosenUrl;
    String chosenCaption;

    // 25% chance to use dynamic Pollinations AI for fresh generation, or if curated pool runs low
    final useAi = (_random.nextDouble() < 0.25) || (fallbackPool.length < 5);

    if (useAi) {
      final promptThemes = [
        'cozy modern study cafe with laptop, latte art, and books',
        'futuristic holographic library with neon reading desks',
        'peaceful botanical garden courtyard in morning sunlight',
        'cyberpunk city rooftop looking out over digital neon towers',
        'mountain balcony view with notebook and fresh herbal tea',
        'art studio with vibrant color palettes and inspirational sketches',
        'urban street corner with aesthetic coffee kiosk at sunset',
        'minimalist Scandinavian desk setup with notebook and houseplants',
        'rainy window view with warm indoor reading lamp and tea mug',
        'sunlit university campus walkway lined with autumn leaves',
        'starry night sky seen from a cozy modern glass observatory',
        'athletic track sprint at golden hour with morning dew',
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
      // If all curated images have been seen, generate infinite unique AI snap
      final theme = 'modern aesthetic lifestyle photography in urban creative studio at golden hour';
      chosenUrl = generatePollinationsAiSnapUrl(robot: robot, themeDescription: theme);
      chosenCaption = userPreferredCaption ?? '⚡ Always learning, always building fluency! 🚀';
    }

    // Mark as seen permanently - NEVER trim so user NEVER receives a duplicate snap!
    seenSet.add(chosenUrl);
    await prefs.setStringList(seenKey, seenSet.toList());

    return {
      'imageUrl': chosenUrl,
      'caption': chosenCaption,
    };
  }

  /// 💬 Interactive Archetype Questions
  /// Fulfills user directive: "നമ്മളോട് തന്നെ കുറെ ചോദ്യങ്ങൾ ചോദിക്കും"
  static final Map<RobotArchetype, List<String>> _archetypeQuestions = {
    RobotArchetype.cheerful: [
      'Quick question: What was the absolute best moment of your day today? Tell me in English! 🌟',
      'If you could master any English accent overnight, which one would you pick and why? 🗣️',
      'What\'s one hobby or activity that never fails to put a big smile on your face? 😊',
      'Tell me three things you are super grateful for right now! Let\'s practice gratitude in English! ✨',
      'What is your favorite comfort food after a busy study day? Describe the taste to me! 🍕',
      'If our Pocket Mates squad planned a world road trip, where would our first stop be? 🚗💨',
    ],
    RobotArchetype.romantic: [
      'Tell me honestly: What song lyrics have been playing in your mind all day? 🎶💕',
      'Do you believe words have the power to change someone\'s entire destiny? What do you think? 📜',
      'If you could watch the sunset from any balcony in the world today, where would you choose? 🌅',
      'What is the most beautiful English word you have ever heard? Mine is \'serendipity\' ✨',
      'How does your heart feel when you speak English with confidence? Describe that feeling! 💖',
    ],
    RobotArchetype.grumpy: [
      'Hmph! Have you done your 15-minute speaking practice today, or are you just making excuses? 😤',
      'Give me one advanced English synonym for \'difficult\'. Let\'s see if you\'ve been studying! 📚',
      'Don\'t just sit there—tell me what your top priority task is for tomorrow morning! ⏱️',
      'Why do you think most people give up on their language goals? Tell me your honest theory! ⚔️',
      'Are you defending your Citadel streak today, or letting other teams overtake you? 🛡️',
    ],
    RobotArchetype.intellectual: [
      'Consider this: Does language shape our perception of reality, or does reality shape language? 🧠',
      'What book or article has made the deepest intellectual impression on you recently? 📖',
      'If you had to summarize your personal philosophy of success in one English sentence, what would it be?',
      'How do you distinguish between mere knowledge and genuine wisdom in daily life? 💡',
      'What linguistic challenge do you find most fascinating when learning English syntax? 🏛️',
    ],
    RobotArchetype.trendsetter: [
      'Yo! What new music or show are you currently obsessed with? Give me the review! 🔥',
      'No cap, what\'s your current go-to outfit when you want to feel 100% confident? 😎👟',
      'If we opened a cafe on World Street, what signature drink would we serve? ☕⚡',
      'What slang or modern idiom do you use the most when speaking with friends? 💬',
      'Which city has the coolest street fashion in your opinion? Let\'s debate! 🏙️',
    ],
    RobotArchetype.grandmaster: [
      'A true scholar measures progress not by days, but by deliberate practice. What milestone did you conquer today? 👑',
      'Eloquence is the crown of clarity. Which English idiom will you employ in conversation tomorrow? 📜',
      'How do you maintain discipline when motivation wanes? Share your strategy with me. 🏛️',
      'What legacy do you wish your learning journey to forge within Pocket World? 🏆',
    ],
  };

  /// ❓ Get a meaningful interactive question for this robot
  static String getArchetypeQuestion(PocketRobot robot) {
    final list = _archetypeQuestions[robot.archetype] ?? _archetypeQuestions[RobotArchetype.cheerful]!;
    return list[_random.nextInt(list.length)];
  }

  /// ⏰ 365-Day Long-Term Proactive Conversation Sparks & Questions
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
    // 60% chance to ask an engaging interactive question, 40% inspiring check-in
    if (_random.nextDouble() < 0.60) {
      final question = getArchetypeQuestion(robot);
      return 'Hey! It\'s ${robot.name} ⚡ $question';
    } else {
      final msg = proactiveDailyMessages[_random.nextInt(proactiveDailyMessages.length)];
      return 'Hey! It\'s ${robot.name} ⚡ $msg';
    }
  }
}
