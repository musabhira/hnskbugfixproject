import 'package:flutter/material.dart';

/// Supported external avatar generator engines in Pocket Mates Avatar Network
enum AvatarNetworkEngine {
  diceBear,
  roboHash,
  multiavatar,
  boringAvatars,
  pocketVector,
}

class AvatarNetworkStyle {
  final String id;
  final String name;
  final String engine;
  final String category;
  final String icon;
  final String sampleSeed;
  final Color accentColor;
  final String description;

  const AvatarNetworkStyle({
    required this.id,
    required this.name,
    required this.engine,
    required this.category,
    required this.icon,
    required this.sampleSeed,
    required this.accentColor,
    required this.description,
  });
}

class AvatarNetworkService {
  static const List<AvatarNetworkStyle> catalog = [
    // 🎲 DiceBear 9.x Engines
    AvatarNetworkStyle(
      id: 'adventurer',
      name: 'Anime RPG Hero',
      engine: 'dicebear',
      category: 'Anime / Fantasy',
      icon: '⚔️',
      sampleSeed: 'ShadowBlade',
      accentColor: Color(0xFFFF007F),
      description: 'Hand-drawn fantasy anime adventurer',
    ),
    AvatarNetworkStyle(
      id: 'bottts',
      name: 'Cyber Mecha Bot',
      engine: 'dicebear',
      category: 'Sci-Fi / Mecha',
      icon: '🤖',
      sampleSeed: 'CyberTron99',
      accentColor: Color(0xFF00E5FF),
      description: 'Futuristic modular cyber robots',
    ),
    AvatarNetworkStyle(
      id: 'avataaars',
      name: 'Modern 2D Peep',
      engine: 'dicebear',
      category: 'People / Urban',
      icon: '✨',
      sampleSeed: 'PocketMatePro',
      accentColor: Color(0xFFFFD700),
      description: 'Sleek colorful vector people',
    ),
    AvatarNetworkStyle(
      id: 'lorelei',
      name: 'Manga Shonen',
      engine: 'dicebear',
      category: 'Anime / Manga',
      icon: '🌸',
      sampleSeed: 'SakuraKitsune',
      accentColor: Color(0xFFEC4899),
      description: 'Japanese manga character design',
    ),
    AvatarNetworkStyle(
      id: 'pixel-art',
      name: 'Retro 8-Bit Arcade',
      engine: 'dicebear',
      category: 'Pixel Art',
      icon: '👾',
      sampleSeed: 'ArcadeMaster',
      accentColor: Color(0xFF10B981),
      description: 'Classic arcade sprite characters',
    ),
    AvatarNetworkStyle(
      id: 'big-ears',
      name: 'Chibi Kawaii Animal',
      engine: 'dicebear',
      category: 'Animals / Chibi',
      icon: '🦊',
      sampleSeed: 'FluffyFox',
      accentColor: Color(0xFFFF9900),
      description: 'Adorable big-eared cute creatures',
    ),
    AvatarNetworkStyle(
      id: 'croodles',
      name: 'Comic Doodle',
      engine: 'dicebear',
      category: 'Artistic / Doodle',
      icon: '🎨',
      sampleSeed: 'DoodleArtist',
      accentColor: Color(0xFF8B5CF6),
      description: 'Expressive hand-drawn sketch cartoons',
    ),
    AvatarNetworkStyle(
      id: 'open-peeps',
      name: 'Open Peeps',
      engine: 'dicebear',
      category: 'Artistic / Hand-drawn',
      icon: '🖌️',
      sampleSeed: 'PabloStanley',
      accentColor: Color(0xFF3B82F6),
      description: 'Pablo Stanley hand-drawn comic personalities',
    ),
    AvatarNetworkStyle(
      id: 'micah',
      name: 'Abstract Modernist',
      engine: 'dicebear',
      category: 'Abstract / Minimal',
      icon: '🎭',
      sampleSeed: 'StudioCreative',
      accentColor: Color(0xFF14B8A6),
      description: 'Contemporary minimalist vector portraits',
    ),
    AvatarNetworkStyle(
      id: 'notionists',
      name: 'Notionist B&W',
      engine: 'dicebear',
      category: 'Minimalist',
      icon: '📓',
      sampleSeed: 'NotionGenius',
      accentColor: Color(0xFF94A3B8),
      description: 'Monochrome minimalist productivity avatars',
    ),
    AvatarNetworkStyle(
      id: 'fun-emoji',
      name: '3D Playful Emoji',
      engine: 'dicebear',
      category: '3D / Emojis',
      icon: '🤩',
      sampleSeed: 'JoyWave',
      accentColor: Color(0xFFF59E0B),
      description: 'Vibrant expressive facial emojis',
    ),

    // 🤖 RoboHash Monster & Robot Engines
    AvatarNetworkStyle(
      id: 'robohash_robots',
      name: 'RoboHash Cyborgs',
      engine: 'robohash_1',
      category: 'Robots / AI',
      icon: '⚙️',
      sampleSeed: 'MatrixOverlord',
      accentColor: Color(0xFF06B6D4),
      description: 'Unique procedural robotic lifeforms',
    ),
    AvatarNetworkStyle(
      id: 'robohash_monsters',
      name: 'Alien Monsters',
      engine: 'robohash_2',
      category: 'Monsters / Beasts',
      icon: '👾',
      sampleSeed: 'BeastTitan',
      accentColor: Color(0xFF84CC16),
      description: 'Wild multi-eyed galactic creatures',
    ),
    AvatarNetworkStyle(
      id: 'robohash_heads',
      name: 'Android AI Heads',
      engine: 'robohash_3',
      category: 'Sci-Fi / Mecha',
      icon: '🧠',
      sampleSeed: 'NeuralCore',
      accentColor: Color(0xFF6366F1),
      description: 'Disembodied quantum cybernetic units',
    ),
    AvatarNetworkStyle(
      id: 'robohash_cats',
      name: 'Cybernetic Kittens',
      engine: 'robohash_4',
      category: 'Animals / Chibi',
      icon: '🐱',
      sampleSeed: 'TokyoNeko',
      accentColor: Color(0xFFF43F5E),
      description: 'Procedural cats and kittens',
    ),

    // 🌐 Multiavatar Engine (12 Billion Identities)
    AvatarNetworkStyle(
      id: 'multiavatar',
      name: 'Multiavatar 12B',
      engine: 'multiavatar',
      category: 'Multiverse / Global',
      icon: '🌍',
      sampleSeed: 'MultiverseStar',
      accentColor: Color(0xFFFFB700),
      description: '12 Billion multicultural characters',
    ),

    // 🎨 Boring Avatars (Bauhaus, Beam, Ring, Sunset)
    AvatarNetworkStyle(
      id: 'boring_beam',
      name: 'Boring Beam Portrait',
      engine: 'boring_beam',
      category: 'Abstract / Minimal',
      icon: '🌈',
      sampleSeed: 'BeamRay',
      accentColor: Color(0xFFA855F7),
      description: 'Dynamic gradient geometric face beams',
    ),
    AvatarNetworkStyle(
      id: 'boring_ring',
      name: 'Cyber Ring Orbit',
      engine: 'boring_ring',
      category: 'Abstract / Minimal',
      icon: '💫',
      sampleSeed: 'OrbitPulse',
      accentColor: Color(0xFF22C55E),
      description: 'Concentric color ring avatars',
    ),
  ];

  /// Get direct image or SVG URL for any engine and style
  static String buildAvatarUrl({
    required String styleId,
    required String seed,
    int size = 200,
    String? backgroundHex,
  }) {
    final style = catalog.firstWhere(
      (s) => s.id == styleId,
      orElse: () => catalog.first,
    );

    switch (style.engine) {
      case 'dicebear':
        final bgParam = backgroundHex != null ? '&backgroundColor=$backgroundHex' : '';
        return 'https://api.dicebear.com/9.x/${style.id}/png?seed=${Uri.encodeComponent(seed)}&size=$size$bgParam';
      case 'robohash_1':
        return 'https://robohash.org/${Uri.encodeComponent(seed)}.png?set=set1&size=${size}x$size';
      case 'robohash_2':
        return 'https://robohash.org/${Uri.encodeComponent(seed)}.png?set=set2&size=${size}x$size';
      case 'robohash_3':
        return 'https://robohash.org/${Uri.encodeComponent(seed)}.png?set=set3&size=${size}x$size';
      case 'robohash_4':
        return 'https://robohash.org/${Uri.encodeComponent(seed)}.png?set=set4&size=${size}x$size';
      case 'multiavatar':
        return 'https://api.multiavatar.com/${Uri.encodeComponent(seed)}.png';
      case 'boring_beam':
        return 'https://source.boringavatars.com/beam/$size/${Uri.encodeComponent(seed)}?colors=264653,2a9d8f,e9c46a,f4a261,e76f51';
      case 'boring_ring':
        return 'https://source.boringavatars.com/ring/$size/${Uri.encodeComponent(seed)}?colors=ff007f,00f0ff,fffc00,8b5cf6,10b981';
      default:
        return 'https://api.dicebear.com/9.x/adventurer/png?seed=${Uri.encodeComponent(seed)}&size=$size';
    }
  }

  /// Generate a random trending seed list
  static List<String> generateSampleSeeds(String baseTheme) {
    return [
      '${baseTheme}_Alpha',
      '${baseTheme}_Cyber',
      '${baseTheme}_Ninja',
      '${baseTheme}_Solar',
      '${baseTheme}_Vortex',
      '${baseTheme}_Starlight',
      '${baseTheme}_Phantom',
      '${baseTheme}_Neon',
      '${baseTheme}_Galaxy',
      '${baseTheme}_Apex',
      '${baseTheme}_Phoenix',
      '${baseTheme}_Zenith',
    ];
  }
}
