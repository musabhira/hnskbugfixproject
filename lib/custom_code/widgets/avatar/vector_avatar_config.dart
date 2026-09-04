import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Configuration model for Pocket Mates Multi-Style Profile Avatars & 1-of-1 NFT Identities
class VectorAvatarConfig {
  final String artStyle; // 'vector' | 'doodle' | 'pixel' | 'cyberpunk'
  final String species; // 'human' | 'cyber_fox' | 'shadow_wolf' | 'mecha_lion' | 'cosmic_dragon' | 'ninja_panda' | 'arcade_ape' | 'cyber_cat' | 'mystic_phoenix' | 'space_robot' | 'neon_tiger' | 'celestial_owl' | 'grizzly_brawler' | 'viper_assassin' | 'astral_mage' | 'golden_monarch'
  final String gender; // 'male', 'female', 'neutral'
  final String skinColor; // Hex string e.g. '#FFDFC4'
  final String faceShape; // 'oval', 'round', 'sharp', 'square'
  final String eyeStyle; // 'chill', 'anime', 'mischief', 'sparkle', 'wink', 'focused'
  final String eyeColor; // Hex string
  final String eyebrowStyle; // 'normal', 'thick', 'arched', 'confident', 'angry_hero'
  final String mouthStyle; // 'smile', 'laugh', 'smirk', 'open_talk', 'joker_grin', 'chill'
  final String hairStyle; // 'curly_fade', 'classic_side', 'anime_spiky', 'long_wavy', 'bob_cut', 'afro', 'ponytail', 'messy_top', 'bald_beanie', 'dreadlocks', 'mullet', 'high_bun', 'slicked_back', 'mohawk'
  final String hairColor; // Hex string
  final String beardStyle; // 'none', 'stubble', 'french_beard', 'full_beard', 'mustache', 'goatee'
  final String outfitStyle; // 'doctor_coat', 'hacker_hood', 'developer_tee', 'spider_suit', 'joker_suit', 'pilot_uniform', 'artist_apron', 'ninja_robe', 'hoodie', 'varsity_jacket', 'blazer', 'traditional_kurta', 'sports_jersey', 'denim_jacket', 'tshirt', 'superman_suit', 'astronaut_suit', 'chef_uniform', 'detective_trench', 'pirate_vest'
  final String outfitColor; // Hex string
  final String outfitAccentColor; // Hex string
  final String accessory; // 'none', 'stethoscope', 'headphones', 'round_glasses', 'cool_sunglasses', 'cyber_visor', 'ninja_mask', 'beret', 'cap', 'beanie', 'crown', 'earring', 'pirate_eyepatch', 'chef_hat', 'detective_hat'
  final String accessoryColor; // Hex string
  final String auraStyle; // 'matrix_green', 'comic_boom', 'neon_yellow', 'cyber_purple', 'electric_blue', 'sunset_orange', 'pixel_arcade', 'cherry_blossom', 'golden_sparks', 'minimal_dark'

  // 1-of-1 NFT & Blockchain Identity Metadata
  final String? mintId; // e.g. '#MATE-8492'
  final String? dnaHash; // e.g. '0x9E7A-41B0-FD23'
  final String rarityTier; // 'Original' | 'Rare' | 'Epic' | 'Legendary' | 'Mythic 1-of-1'
  final String? ownerId;
  final String? mintedAt;
  final String? customDrawingSvg;
  final String? customDrawingImage;
  final String? imageUrl;
  final String? networkImageUrl;
  final String? talismanId; // 'rabbit' | 'dragon' | 'ox' | 'horse' | 'dog' | 'snake' | 'rooster' | 'monkey' | 'sheep' | 'rat' | 'tiger' | 'pig'

  const VectorAvatarConfig({
    this.artStyle = 'vector',
    this.species = 'human',
    this.gender = 'male',
    this.skinColor = '#FFDFC4',
    this.faceShape = 'oval',
    this.eyeStyle = 'chill',
    this.eyeColor = '#2C1B18',
    this.eyebrowStyle = 'confident',
    this.mouthStyle = 'smile',
    this.hairStyle = 'curly_fade',
    this.hairColor = '#1A1A1A',
    this.beardStyle = 'none',
    this.outfitStyle = 'hoodie',
    this.outfitColor = '#FFFC00',
    this.outfitAccentColor = '#1E1E24',
    this.accessory = 'none',
    this.accessoryColor = '#1E1E24',
    this.auraStyle = 'neon_yellow',
    this.mintId,
    this.dnaHash,
    this.rarityTier = 'Original',
    this.ownerId,
    this.mintedAt,
    this.customDrawingSvg,
    this.customDrawingImage,
    this.imageUrl,
    this.networkImageUrl,
    this.talismanId,
  });

  VectorAvatarConfig copyWith({
    String? artStyle,
    String? species,
    String? gender,
    String? skinColor,
    String? faceShape,
    String? eyeStyle,
    String? eyeColor,
    String? eyebrowStyle,
    String? mouthStyle,
    String? hairStyle,
    String? hairColor,
    String? beardStyle,
    String? outfitStyle,
    String? outfitColor,
    String? outfitAccentColor,
    String? accessory,
    String? accessoryColor,
    String? auraStyle,
    String? mintId,
    String? dnaHash,
    String? rarityTier,
    String? ownerId,
    String? mintedAt,
    String? customDrawingSvg,
    String? customDrawingImage,
    String? imageUrl,
    String? networkImageUrl,
    String? talismanId,
  }) {
    return VectorAvatarConfig(
      artStyle: artStyle ?? this.artStyle,
      species: species ?? this.species,
      gender: gender ?? this.gender,
      skinColor: skinColor ?? this.skinColor,
      faceShape: faceShape ?? this.faceShape,
      eyeStyle: eyeStyle ?? this.eyeStyle,
      eyeColor: eyeColor ?? this.eyeColor,
      eyebrowStyle: eyebrowStyle ?? this.eyebrowStyle,
      mouthStyle: mouthStyle ?? this.mouthStyle,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      beardStyle: beardStyle ?? this.beardStyle,
      outfitStyle: outfitStyle ?? this.outfitStyle,
      outfitColor: outfitColor ?? this.outfitColor,
      outfitAccentColor: outfitAccentColor ?? this.outfitAccentColor,
      accessory: accessory ?? this.accessory,
      accessoryColor: accessoryColor ?? this.accessoryColor,
      auraStyle: auraStyle ?? this.auraStyle,
      mintId: mintId ?? this.mintId,
      dnaHash: dnaHash ?? this.dnaHash,
      rarityTier: rarityTier ?? this.rarityTier,
      ownerId: ownerId ?? this.ownerId,
      mintedAt: mintedAt ?? this.mintedAt,
      customDrawingSvg: customDrawingSvg ?? this.customDrawingSvg,
      customDrawingImage: customDrawingImage ?? this.customDrawingImage,
      imageUrl: imageUrl ?? this.imageUrl,
      networkImageUrl: networkImageUrl ?? this.networkImageUrl,
      talismanId: talismanId ?? this.talismanId,
    );
  }

  String get computedDna {
    return 'DNA_${species}_${artStyle}_${gender}_${skinColor.replaceAll('#', '')}_${faceShape}_${eyeStyle}_${hairStyle}_${hairColor.replaceAll('#', '')}_${beardStyle}_${outfitStyle}_${accessory}_$auraStyle';
  }

  String get computedAvatarId {
    if (mintId != null && mintId!.isNotEmpty) return mintId!;
    final hash = computedDna.hashCode.abs();
    return '#MATE-${(hash % 900000) + 100000}';
  }

  Map<String, dynamic> toMap() {
    return {
      'artStyle': artStyle,
      'species': species,
      'gender': gender,
      'skinColor': skinColor,
      'faceShape': faceShape,
      'eyeStyle': eyeStyle,
      'eyeColor': eyeColor,
      'eyebrowStyle': eyebrowStyle,
      'mouthStyle': mouthStyle,
      'hairStyle': hairStyle,
      'hairColor': hairColor,
      'beardStyle': beardStyle,
      'outfitStyle': outfitStyle,
      'outfitColor': outfitColor,
      'outfitAccentColor': outfitAccentColor,
      'accessory': accessory,
      'accessoryColor': accessoryColor,
      'auraStyle': auraStyle,
      'mintId': mintId,
      'dnaHash': dnaHash,
      'rarityTier': rarityTier,
      'ownerId': ownerId,
      'mintedAt': mintedAt,
      'customDrawingSvg': customDrawingSvg,
      'customDrawingImage': customDrawingImage,
      'imageUrl': imageUrl,
      'networkImageUrl': networkImageUrl,
      'talismanId': talismanId,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory VectorAvatarConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const VectorAvatarConfig();
    return VectorAvatarConfig(
      artStyle: map['artStyle'] ?? 'vector',
      species: map['species'] ?? 'human',
      gender: map['gender'] ?? 'male',
      skinColor: map['skinColor'] ?? '#FFDFC4',
      faceShape: map['faceShape'] ?? 'oval',
      eyeStyle: map['eyeStyle'] ?? 'chill',
      eyeColor: map['eyeColor'] ?? '#2C1B18',
      eyebrowStyle: map['eyebrowStyle'] ?? 'confident',
      mouthStyle: map['mouthStyle'] ?? 'smile',
      hairStyle: map['hairStyle'] ?? 'curly_fade',
      hairColor: map['hairColor'] ?? '#1A1A1A',
      beardStyle: map['beardStyle'] ?? 'none',
      outfitStyle: map['outfitStyle'] ?? 'hoodie',
      outfitColor: map['outfitColor'] ?? '#FFFC00',
      outfitAccentColor: map['outfitAccentColor'] ?? '#1E1E24',
      accessory: map['accessory'] ?? 'none',
      accessoryColor: map['accessoryColor'] ?? '#1E1E24',
      auraStyle: map['auraStyle'] ?? 'neon_yellow',
      mintId: map['mintId'],
      dnaHash: map['dnaHash'],
      rarityTier: map['rarityTier'] ?? 'Original',
      ownerId: map['ownerId'],
      mintedAt: map['mintedAt'],
      customDrawingSvg: map['customDrawingSvg'],
      customDrawingImage: map['customDrawingImage'],
      imageUrl: map['imageUrl'],
      networkImageUrl: map['networkImageUrl'],
      talismanId: map['talismanId'],
    );
  }

  /// Procedural 1-of-1 NFT Identity Minting Engine
  static VectorAvatarConfig mintUniqueOneOfOne({String? userId, String? specificSpecies}) {
    final rng = math.Random();
    final speciesList = [
      'human',
      'cyber_fox',
      'shadow_wolf',
      'mecha_lion',
      'cosmic_dragon',
      'ninja_panda',
      'arcade_ape',
      'cyber_cat',
      'mystic_phoenix',
      'space_robot',
      'neon_tiger',
      'celestial_owl',
      'grizzly_brawler',
      'viper_assassin',
      'astral_mage',
      'golden_monarch',
    ];
    final selectedSpecies = specificSpecies ?? speciesList[rng.nextInt(speciesList.length)];
    
    final styles = ['vector', 'cyberpunk', 'doodle', 'pixel'];
    final auras = [
      'matrix_green', 'comic_boom', 'neon_yellow', 'cyber_purple', 
      'electric_blue', 'sunset_orange', 'pixel_arcade', 'cherry_blossom', 'golden_sparks', 'minimal_dark'
    ];
    final hairList = [
      'curly_fade', 'classic_side', 'anime_spiky', 'long_wavy', 'bob_cut', 
      'afro', 'ponytail', 'messy_top', 'bald_beanie', 'dreadlocks', 'mullet', 'high_bun', 'slicked_back', 'mohawk'
    ];
    final outfits = [
      'doctor_coat', 'hacker_hood', 'developer_tee', 'spider_suit', 'joker_suit', 
      'pilot_uniform', 'artist_apron', 'ninja_robe', 'hoodie', 'varsity_jacket', 
      'blazer', 'traditional_kurta', 'sports_jersey', 'superman_suit', 'astronaut_suit', 'detective_trench'
    ];
    final accessories = [
      'none', 'cool_sunglasses', 'cyber_visor', 'ninja_mask', 'beret', 
      'cap', 'beanie', 'crown', 'earring', 'pirate_eyepatch', 'headphones'
    ];

    final serialNum = 1000 + rng.nextInt(9000);
    final hexParts = [
      rng.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase(),
      rng.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase(),
      rng.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase(),
      rng.nextInt(256).toRadixString(16).padLeft(2, '0').toUpperCase(),
    ];
    final dna = '0x${hexParts.join('-')}';

    final rarityRoll = rng.nextInt(100);
    final rarity = rarityRoll > 90 
        ? 'Mythic 1-of-1' 
        : (rarityRoll > 70 
            ? 'Legendary' 
            : (rarityRoll > 45 ? 'Epic' : (rarityRoll > 20 ? 'Rare' : 'Original')));

    return VectorAvatarConfig(
      artStyle: styles[rng.nextInt(styles.length)],
      species: selectedSpecies,
      skinColor: ['#FFDFC4', '#F0D0B0', '#D8A070', '#8D5524', '#00F0FF', '#FF007F', '#A020F0'][rng.nextInt(7)],
      faceShape: ['oval', 'round', 'sharp', 'square'][rng.nextInt(4)],
      eyeStyle: ['chill', 'anime', 'mischief', 'sparkle', 'wink', 'focused'][rng.nextInt(6)],
      mouthStyle: ['smile', 'laugh', 'smirk', 'open_talk', 'joker_grin', 'chill'][rng.nextInt(6)],
      hairStyle: hairList[rng.nextInt(hairList.length)],
      hairColor: ['#1A1A1A', '#4A2E18', '#D4AF37', '#FF007F', '#00F0FF', '#FFFFFF', '#8A2BE2'][rng.nextInt(7)],
      outfitStyle: outfits[rng.nextInt(outfits.length)],
      outfitColor: ['#FFFC00', '#FF007F', '#00F0FF', '#10B981', '#8B5CF6', '#EF4444', '#F97316'][rng.nextInt(7)],
      accessory: accessories[rng.nextInt(accessories.length)],
      auraStyle: auras[rng.nextInt(auras.length)],
      mintId: '#MATE-$serialNum',
      dnaHash: dna,
      rarityTier: rarity,
      ownerId: userId,
      mintedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Systematic 90-Day Avatar Evolution Engine
  /// Maps each learning stage to a distinct character progression:
  /// - Days 1–20: Human Starters & Scholars (Beginner to Intermediate Speech Mechanics)
  /// - Days 21–30: Arcade Apes & Agile Primates (Speed Vocal Sprint & Reaction Drills)
  /// - Days 31–45: Cyber Beasts & Wild Predators (Shadow Wolf, Mecha Lion, Neon Tiger)
  /// - Days 46–55: Celestial Mystics & 24K Monarchs (Astral Mage, Mystic Phoenix, Golden Monarch)
  /// - Days 56–90: Cosmic Dragon / Pocket Full Dragon (Capstone Mythic 1-of-1 Grandmaster)
  /// Systematic 90-Day NFT Avatar Progression:
  /// STRICT USER REQUIREMENT: Exactly 3 days per animal species! (30 unique animal species x 3 days = 90 days total).
  /// Every single animal undergoes 3 tiers of evolution:
  /// - Tier 1 (Day 1 of 3): Rookie / Cub / Scout (Common)
  /// - Tier 2 (Day 2 of 3): Evolved Warrior / Hunter (Rare / Epic)
  /// - Tier 3 (Day 3 of 3): Apex Champion Sovereign (Milestone with accessory & battle aura)
  ///
  /// Also includes Jackie Chan's 12 Legendary Zodiac Talismans (ജാക്കി ചാന്റെ മാന്ത്രിക കല്ലുകൾ):
  /// Rabbit, Dragon, Ox, Horse, Dog, Snake, Rooster, Monkey, Sheep, Rat, Tiger, Pig.
  static VectorAvatarConfig getEvolutionAvatarForStage(int stage, {String? talismanId}) {
    final day = stage.clamp(1, 90);

    // 🌟 30 UNIQUE ANIMAL SPECIES (3 DAYS PER SPECIES)
    final int speciesIndex = ((day - 1) ~/ 3).clamp(0, 29);
    final int dayInSpecies = (day - 1) % 3; // 0: Rookie, 1: Evolved, 2: Apex Champion

    String species = 'cyber_cat';
    String furColor = '#F59E0B';
    String eyeColor = '#10B981';
    String outfitColor = '#1E293B';
    String outfitAccent = '#FFFC00';
    String accessory = 'none';
    String auraStyle = 'minimal_dark';
    String rarityTier = 'Common';
    String hairStyle = 'short_crop';

    switch (speciesIndex) {
      case 0: // 🐱 1. Cyber Cat (Days 1–3)
        species = 'cyber_cat';
        furColor = ['#F59E0B', '#EC4899', '#00F0FF'][dayInSpecies];
        eyeColor = '#10B981';
        outfitColor = '#1E293B';
        outfitAccent = '#FFFC00';
        accessory = dayInSpecies == 2 ? 'cool_sunglasses' : 'none';
        auraStyle = dayInSpecies == 2 ? 'neon_yellow' : 'minimal_dark';
        rarityTier = dayInSpecies == 2 ? 'Cat Apex Champion' : (dayInSpecies == 1 ? 'Cyber Cat Hunter' : 'Kitten Rookie');
        break;

      case 1: // 🦊 2. Mystic Fox (Days 4–6)
        species = 'cyber_fox';
        furColor = ['#F97316', '#EA580C', '#FF6D00'][dayInSpecies];
        eyeColor = '#FFD700';
        outfitColor = '#7F1D1D';
        outfitAccent = '#F97316';
        accessory = dayInSpecies == 2 ? 'samurai_headband' : 'none';
        auraStyle = dayInSpecies == 2 ? 'cyber_purple' : 'minimal_dark';
        rarityTier = dayInSpecies == 2 ? 'Nine-Tails Kitsune Apex' : (dayInSpecies == 1 ? 'Mystic Fox' : 'Wild Fox Pup');
        break;

      case 2: // 🐺 3. Shadow Wolf (Days 7–9)
        species = 'shadow_wolf';
        furColor = ['#334155', '#1E293B', '#0F172A'][dayInSpecies];
        eyeColor = '#00F0FF';
        outfitColor = '#0F172A';
        outfitAccent = '#38BDF8';
        accessory = dayInSpecies == 2 ? 'headphones' : 'none';
        auraStyle = dayInSpecies == 2 ? 'electric_blue' : 'minimal_dark';
        rarityTier = dayInSpecies == 2 ? 'Shadow Wolf Alpha' : (dayInSpecies == 1 ? 'Timber Wolf' : 'Wolf Scout');
        break;

      case 3: // 🐯 4. Royal Tiger (Days 10–12)
        species = 'royal_tiger';
        furColor = ['#FB923C', '#F97316', '#EA580C'][dayInSpecies];
        eyeColor = '#FACC15';
        outfitColor = '#1E1B4B';
        outfitAccent = '#FFD700';
        accessory = dayInSpecies == 2 ? 'gold_chain' : 'none';
        auraStyle = dayInSpecies == 2 ? 'golden_sparks' : 'neon_yellow';
        rarityTier = dayInSpecies == 2 ? 'Royal Tiger Sovereign' : (dayInSpecies == 1 ? 'Saber Tiger' : 'Bengal Tiger');
        break;

      case 4: // 🦁 5. Golden Lion (Days 13–15)
        species = 'golden_lion';
        furColor = ['#F59E0B', '#EAB308', '#FFD700'][dayInSpecies];
        eyeColor = '#38BDF8';
        outfitColor = '#451A03';
        outfitAccent = '#FFD700';
        accessory = dayInSpecies == 2 ? 'crown' : (dayInSpecies == 1 ? 'gold_chain' : 'none');
        auraStyle = 'golden_sparks';
        rarityTier = dayInSpecies == 2 ? '24K Lion Emperor' : (dayInSpecies == 1 ? 'Pride Alpha Lion' : 'Savannah Lion');
        break;

      case 5: // 🐘 6. Mighty Elephant (Days 16–18)
        species = 'mighty_elephant';
        furColor = ['#64748B', '#475569', '#334155'][dayInSpecies];
        eyeColor = '#10B981';
        outfitColor = '#064E3B';
        outfitAccent = '#34D399';
        accessory = dayInSpecies == 2 ? 'beanie' : 'none';
        auraStyle = dayInSpecies == 2 ? 'neon_green' : 'minimal_dark';
        rarityTier = dayInSpecies == 2 ? 'Colossal Mastodon Titan' : (dayInSpecies == 1 ? 'War Tusker' : 'Gentle Giant Elephant');
        break;

      case 6: // 🐼 7. Ninja Panda (Days 19–21)
        species = 'ninja_panda';
        furColor = ['#FFFFFF', '#1E1E24', '#F8FAFC'][dayInSpecies];
        eyeColor = '#38BDF8';
        outfitColor = '#1E1E24';
        outfitAccent = '#22C55E';
        accessory = dayInSpecies == 2 ? 'samurai_headband' : 'none';
        auraStyle = dayInSpecies == 2 ? 'neon_green' : 'minimal_dark';
        rarityTier = dayInSpecies == 2 ? 'Grandmaster Ninja Panda' : (dayInSpecies == 1 ? 'Shaolin Warrior Panda' : 'Bamboo Panda Cub');
        break;

      case 7: // 🐻 8. Noble Bear (Days 22–24)
        species = 'noble_bear';
        furColor = ['#78350F', '#854D0E', '#451A03'][dayInSpecies];
        eyeColor = '#FDE047';
        outfitColor = '#1C1917';
        outfitAccent = '#F59E0B';
        accessory = dayInSpecies == 2 ? 'cap' : 'none';
        auraStyle = dayInSpecies == 2 ? 'sunset_orange' : 'minimal_dark';
        rarityTier = dayInSpecies == 2 ? 'Armored Kodiak Champion' : (dayInSpecies == 1 ? 'Grizzly Brawler' : 'Brown Bear Scout');
        break;

      case 8: // 🐵 9. Cyber Ape / Primate (Days 25–27)
        species = 'bored_ape';
        furColor = ['#8D5B4C', '#FF007A', '#1E293B'][dayInSpecies];
        eyeColor = '#FFD700';
        outfitColor = '#0F172A';
        outfitAccent = '#FF007A';
        accessory = dayInSpecies == 2 ? 'crown' : (dayInSpecies == 1 ? 'headphones' : 'none');
        auraStyle = 'cyber_purple';
        rarityTier = dayInSpecies == 2 ? 'Bored Ape 1-of-1 VIP' : (dayInSpecies == 1 ? 'Cyber Primate' : 'Jungle Chimp');
        break;

      case 9: // 🦅 10. Majestic Eagle (Days 28–30)
        species = 'majestic_eagle';
        furColor = ['#CBD5E1', '#78350F', '#FFFFFF'][dayInSpecies];
        eyeColor = '#F59E0B';
        outfitColor = '#1E3A8A';
        outfitAccent = '#FFD700';
        accessory = dayInSpecies == 2 ? 'cool_sunglasses' : 'none';
        auraStyle = 'golden_sparks';
        rarityTier = dayInSpecies == 2 ? 'Imperial Storm Eagle' : (dayInSpecies == 1 ? 'Golden Eagle' : 'Sky Falcon');
        break;

      case 10: // 🐆 11. Shadow Leopard (Days 31–33)
        species = 'shadow_leopard';
        furColor = ['#F59E0B', '#B45309', '#18181B'][dayInSpecies];
        eyeColor = '#10B981';
        outfitColor = '#18181B';
        outfitAccent = '#F59E0B';
        accessory = dayInSpecies == 2 ? 'gold_chain' : 'none';
        auraStyle = dayInSpecies == 2 ? 'neon_green' : 'minimal_dark';
        rarityTier = dayInSpecies == 2 ? 'Shadow Panther Monarch' : (dayInSpecies == 1 ? 'Spotted Leopard' : 'Swift Cheetah');
        break;

      case 11: // 🦄 12. Cosmic Unicorn (Days 34–36)
        species = 'cosmic_unicorn';
        furColor = ['#FFFFFF', '#FAE8FF', '#DDD6FE'][dayInSpecies];
        eyeColor = '#00F0FF';
        outfitColor = '#4C1D95';
        outfitAccent = '#38BDF8';
        accessory = dayInSpecies == 2 ? 'crown' : 'none';
        auraStyle = 'cyber_purple';
        rarityTier = dayInSpecies == 2 ? 'Celestial Unicorn Sovereign' : (dayInSpecies == 1 ? 'Crystal Horn Pegasus' : 'Starlight Pony');
        break;

      case 12: // 🕊️ 13. Solar Phoenix (Days 37–39)
        species = 'solar_phoenix';
        furColor = ['#EF4444', '#F97316', '#FF0055'][dayInSpecies];
        eyeColor = '#FFD700';
        outfitColor = '#7F1D1D';
        outfitAccent = '#FFD700';
        accessory = dayInSpecies == 2 ? 'crown' : 'none';
        auraStyle = 'golden_sparks';
        rarityTier = dayInSpecies == 2 ? 'Immortal Phoenix Sovereign' : (dayInSpecies == 1 ? 'Crimson Firebird' : 'Ember Bird');
        break;

      case 13: // 🦏 14. Armored Rhino (Days 40–42)
        species = 'armored_rhino';
        furColor = ['#64748B', '#475569', '#1E293B'][dayInSpecies];
        eyeColor = '#DC2626';
        outfitColor = '#1E293B';
        outfitAccent = '#EF4444';
        accessory = dayInSpecies == 2 ? 'cyber_visor' : 'none';
        auraStyle = 'electric_blue';
        rarityTier = dayInSpecies == 2 ? 'Titan Battle Rhino' : (dayInSpecies == 1 ? 'Steel Horn Rhino' : 'Savannah Rhino');
        break;

      case 14: // 🦬 15. Thunder Bison (Days 43–45)
        species = 'thunder_bison';
        furColor = ['#78350F', '#451A03', '#1C1917'][dayInSpecies];
        eyeColor = '#38BDF8';
        outfitColor = '#18181B';
        outfitAccent = '#FACC15';
        accessory = dayInSpecies == 2 ? 'gold_chain' : 'none';
        auraStyle = 'golden_sparks';
        rarityTier = dayInSpecies == 2 ? 'Thunder Minotaur Titan' : (dayInSpecies == 1 ? 'Raging Bull' : 'Prairie Bison');
        break;

      case 15: // 🐊 16. Mystic Croc (Days 46–48)
        species = 'mystic_croc';
        furColor = ['#065F46', '#047857', '#064E3B'][dayInSpecies];
        eyeColor = '#FACC15';
        outfitColor = '#0F172A';
        outfitAccent = '#10B981';
        accessory = dayInSpecies == 2 ? 'pirate_eyepatch' : 'none';
        auraStyle = 'neon_green';
        rarityTier = dayInSpecies == 2 ? 'Prehistoric Sarcosuchus' : (dayInSpecies == 1 ? 'Armored Gator' : 'Swamp Croc');
        break;

      case 16: // 🦈 17. Abyssal Shark (Days 49–51)
        species = 'abyssal_shark';
        furColor = ['#0284C7', '#0369A1', '#0F172A'][dayInSpecies];
        eyeColor = '#00F0FF';
        outfitColor = '#0C4A6E';
        outfitAccent = '#38BDF8';
        accessory = dayInSpecies == 2 ? 'cyber_visor' : 'none';
        auraStyle = 'electric_blue';
        rarityTier = dayInSpecies == 2 ? 'Abyssal Megalodon Titan' : (dayInSpecies == 1 ? 'Great White Shark' : 'Reef Shark');
        break;

      case 17: // 🦉 18. Wisdom Owl (Days 52–54)
        species = 'wisdom_owl';
        furColor = ['#92400E', '#6B21A8', '#F8FAFC'][dayInSpecies];
        eyeColor = '#FFD700';
        outfitColor = '#3B0764';
        outfitAccent = '#A855F7';
        accessory = dayInSpecies == 2 ? 'round_glasses' : 'none';
        auraStyle = 'cyber_purple';
        rarityTier = dayInSpecies == 2 ? 'Grand Astral Sage Owl' : (dayInSpecies == 1 ? 'Snowy Arch-Owl' : 'Barn Owl');
        break;

      case 18: // 🦌 19. Astral Stag (Days 55–57)
        species = 'astral_stag';
        furColor = ['#B45309', '#0D9488', '#F1F5F9'][dayInSpecies];
        eyeColor = '#10B981';
        outfitColor = '#134E4A';
        outfitAccent = '#2DD4BF';
        accessory = dayInSpecies == 2 ? 'crown' : 'none';
        auraStyle = 'cherry_blossom';
        rarityTier = dayInSpecies == 2 ? 'Celestial 10-Point Stag' : (dayInSpecies == 1 ? 'Crowned Forest Elk' : 'Woodland Deer');
        break;

      case 19: // 🦍 20. Silverback Titan (Days 58–60)
        species = 'silverback_titan';
        furColor = ['#1E293B', '#475569', '#0F172A'][dayInSpecies];
        eyeColor = '#EA580C';
        outfitColor = '#09090B';
        outfitAccent = '#F97316';
        accessory = dayInSpecies == 2 ? 'gold_chain' : 'none';
        auraStyle = 'sunset_orange';
        rarityTier = dayInSpecies == 2 ? 'Titan Kong Sovereign' : (dayInSpecies == 1 ? 'Silverback Brute' : 'Mountain Ape');
        break;

      case 20: // 🐍 21. Imperial Cobra (Days 61–63)
        species = 'imperial_cobra';
        furColor = ['#059669', '#D97706', '#7C3AED'][dayInSpecies];
        eyeColor = '#DC2626';
        outfitColor = '#0F172A';
        outfitAccent = '#F59E0B';
        accessory = dayInSpecies == 2 ? 'crown' : 'none';
        auraStyle = 'neon_green';
        rarityTier = dayInSpecies == 2 ? 'Basilisk Emperor Cobra' : (dayInSpecies == 1 ? 'Hooded King Cobra' : 'Desert Viper');
        break;

      case 21: // 🐎 22. Pegasus Stallion (Days 64–66)
        species = 'pegasus_stallion';
        furColor = ['#854D0E', '#E2E8F0', '#38BDF8'][dayInSpecies];
        eyeColor = '#0284C7';
        outfitColor = '#1E3A8A';
        outfitAccent = '#60A5FA';
        accessory = dayInSpecies == 2 ? 'samurai_headband' : 'none';
        auraStyle = 'electric_blue';
        rarityTier = dayInSpecies == 2 ? 'Winged Pegasus Sovereign' : (dayInSpecies == 1 ? 'Royal War Stallion' : 'Wild Mustang');
        break;

      case 22: // 🦚 23. Royal Peacock (Days 67–69)
        species = 'royal_peacock';
        furColor = ['#0284C7', '#059669', '#6366F1'][dayInSpecies];
        eyeColor = '#8B5CF6';
        outfitColor = '#312E81';
        outfitAccent = '#38BDF8';
        accessory = dayInSpecies == 2 ? 'crown' : 'none';
        auraStyle = 'cyber_purple';
        rarityTier = dayInSpecies == 2 ? 'Imperial Prism Peacock' : (dayInSpecies == 1 ? 'Emerald Peacock' : 'Azure Peacock');
        break;

      case 23: // 🦘 24. Combat Kangaroo (Days 70–72)
        species = 'combat_kangaroo';
        furColor = ['#D97706', '#B45309', '#EA580C'][dayInSpecies];
        eyeColor = '#78350F';
        outfitColor = '#18181B';
        outfitAccent = '#EF4444';
        accessory = dayInSpecies == 2 ? 'samurai_headband' : 'none';
        auraStyle = 'sunset_orange';
        rarityTier = dayInSpecies == 2 ? 'Champion Kickboxer Titan' : (dayInSpecies == 1 ? 'Boxer Kangaroo' : 'Outback Joey');
        break;

      case 24: // 🦇 25. Nightfang Bat (Days 73–75)
        species = 'nightfang_bat';
        furColor = ['#1E1E24', '#581C87', '#991B1B'][dayInSpecies];
        eyeColor = '#EF4444';
        outfitColor = '#0F172A';
        outfitAccent = '#DC2626';
        accessory = dayInSpecies == 2 ? 'ninja_mask' : 'none';
        auraStyle = 'cyber_purple';
        rarityTier = dayInSpecies == 2 ? 'Lord Dracula Nightfang' : (dayInSpecies == 1 ? 'Shadow Vampire Bat' : 'Cave Fruit Bat');
        break;

      case 25: // 🦥 26. Zen Sloth (Days 76–78)
        species = 'zen_sloth';
        furColor = ['#64748B', '#A8A29E', '#EAB308'][dayInSpecies];
        eyeColor = '#854D0E';
        outfitColor = '#27272A';
        outfitAccent = '#10B981';
        accessory = dayInSpecies == 2 ? 'headphones' : 'none';
        auraStyle = 'cherry_blossom';
        rarityTier = dayInSpecies == 2 ? 'Enlightened Forest Sage' : (dayInSpecies == 1 ? 'Zen Master Koala' : 'Peaceful Sloth');
        break;

      case 26: // 🐕 27. Celestial Hound (Days 79–81)
        species = 'celestial_hound';
        furColor = ['#F59E0B', '#1E293B', '#FFD700'][dayInSpecies];
        eyeColor = '#38BDF8';
        outfitColor = '#0F172A';
        outfitAccent = '#F59E0B';
        accessory = dayInSpecies == 2 ? 'cool_sunglasses' : 'none';
        auraStyle = 'golden_sparks';
        rarityTier = dayInSpecies == 2 ? 'Celestial Anubis Guardian' : (dayInSpecies == 1 ? 'Cyber Shepherd' : 'Loyal Companion Dog');
        break;

      case 27: // 🐇 28. Astral Rabbit (Days 82–84)
        species = 'astral_rabbit';
        furColor = ['#FFFFFF', '#E0E7FF', '#F472B6'][dayInSpecies];
        eyeColor = '#EC4899';
        outfitColor = '#312E81';
        outfitAccent = '#F472B6';
        accessory = dayInSpecies == 2 ? 'cyber_visor' : 'none';
        auraStyle = 'electric_blue';
        rarityTier = dayInSpecies == 2 ? 'Astral Chrono Rabbit' : (dayInSpecies == 1 ? 'Supersonic Hare' : 'Moon Bunny');
        break;

      case 28: // 🐙 29. Abyssal Kraken (Days 85–87)
        species = 'abyssal_kraken';
        furColor = ['#831843', '#701A75', '#0284C7'][dayInSpecies];
        eyeColor = '#FACC15';
        outfitColor = '#0F172A';
        outfitAccent = '#F43F5E';
        accessory = dayInSpecies == 2 ? 'pirate_eyepatch' : 'none';
        auraStyle = 'cyber_purple';
        rarityTier = dayInSpecies == 2 ? 'Abyssal Ocean Leviathan' : (dayInSpecies == 1 ? 'Giant Deep Octopus' : 'Abyssal Squid');
        break;

      case 29: // 🐉 30. Cosmic Dragon Sovereign (Days 88–90)
      default:
        species = 'cosmic_dragon';
        furColor = ['#7C3AED', '#D97706', '#FFD700'][dayInSpecies];
        eyeColor = day == 90 ? '#00F0FF' : '#FFD700';
        outfitColor = '#050B14';
        outfitAccent = day == 90 ? '#FFD700' : '#F97316';
        accessory = 'crown';
        auraStyle = day == 90 ? 'golden_sparks' : 'cyber_purple';
        rarityTier = day == 90 ? 'Supreme Cosmic Dragon 1-of-1' : (day == 89 ? 'Imperial Celestial Dragon' : 'Wyvern Hatchling');
        break;
    }

    // Determine highest unlocked Jackie Chan Talisman stone if not explicitly passed
    String? assignedTalisman = talismanId;
    if (assignedTalisman == null) {
      if (day >= 85) {
        assignedTalisman = 'pig';
      } else if (day >= 78) {
        assignedTalisman = 'tiger';
      } else if (day >= 70) {
        assignedTalisman = 'rat';
      } else if (day >= 63) {
        assignedTalisman = 'sheep';
      } else if (day >= 56) {
        assignedTalisman = 'monkey';
      } else if (day >= 49) {
        assignedTalisman = 'rooster';
      } else if (day >= 42) {
        assignedTalisman = 'snake';
      } else if (day >= 35) {
        assignedTalisman = 'dog';
      } else if (day >= 28) {
        assignedTalisman = 'horse';
      } else if (day >= 21) {
        assignedTalisman = 'ox';
      } else if (day >= 14) {
        assignedTalisman = 'dragon';
      } else if (day >= 7) {
        assignedTalisman = 'rabbit';
      }
    }

    return VectorAvatarConfig(
      artStyle: 'vector',
      species: species,
      gender: 'neutral',
      imageUrl: null,
      networkImageUrl: null,
      customDrawingImage: null,
      skinColor: furColor,
      faceShape: 'sharp',
      eyeStyle: day >= 80 ? 'sparkle' : 'chill',
      eyeColor: eyeColor,
      hairStyle: hairStyle,
      hairColor: furColor,
      outfitStyle: day >= 81 ? 'astronaut_suit' : (day >= 49 ? 'leather_jacket' : 'varsity_jacket'),
      outfitColor: outfitColor,
      outfitAccentColor: outfitAccent,
      accessory: accessory,
      accessoryColor: '#FFD700',
      auraStyle: auraStyle,
      mintId: '#MATE-DAY$day-${species.toUpperCase()}',
      dnaHash: '0x$species-DAY$day-VECTOR',
      rarityTier: rarityTier,
      talismanId: assignedTalisman,
    );
  }

    static BoxDecoration getEvolutionBannerDecoration(int stage) {
    if (stage <= 10) {
      // Days 1–10: Modern Genesis Deep Space
      return BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.4), width: 1.2),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0B192C), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else if (stage <= 20) {
      // Days 11–20: Emerald Flow Explorer
      return BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 1.2),
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF022C22), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else if (stage <= 29) {
      // Days 21–29: Habit Anchor Lock (Cyber Amber & Electric Red)
      return BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF5252).withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFF5252).withValues(alpha: 0.25), blurRadius: 16),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF270505), Color(0xFF1A0A10), Color(0xFFE11D48)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else if (stage <= 59) {
      // Days 30–59: Silver Knight & Chrome Frosted Glass
      return BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.7), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE2E8F0).withValues(alpha: 0.2), blurRadius: 18),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF13141C), Color(0xFF27293D), Color(0xFF475569)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else if (stage < 90) {
      // Days 60–89: 24K Gold Sovereign Royal Crown
      return BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.8), width: 1.8),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.35), blurRadius: 20),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF161103), Color(0xFF382905), Color(0xFFB45309)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else {
      // Day 90: Grandmaster Astral Cosmic Dragon Celestial Diamond
      return BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00F0FF).withValues(alpha: 0.9), width: 2.0),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00F0FF).withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 2),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF020205), Color(0xFF13172E), Color(0xFF00F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }
  }

  factory VectorAvatarConfig.fromJson(String source) {
    try {
      return VectorAvatarConfig.fromMap(jsonDecode(source));
    } catch (_) {
      return const VectorAvatarConfig();
    }
  }

  static Color parseHex(String hexString, {Color fallback = Colors.black}) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}

/// Sticker template for Avatar Chat Stickers
class AvatarStickerTemplate {
  final String id;
  final String title;
  final String speechText;
  final String emoji;
  final Color badgeColor;

  const AvatarStickerTemplate({
    required this.id,
    required this.title,
    required this.speechText,
    required this.emoji,
    required this.badgeColor,
  });
}

/// Color palettes, 50+ Hero Personas catalog, and Chat Stickers
class VectorAvatarPalette {
  static const List<Map<String, dynamic>> artStyles = [
    {
      'id': 'vector',
      'name': '✨ Modern 2D',
      'desc': 'Sleek Streetwear Avatar',
      'accent': Color(0xFFFFFC00),
    },
    {
      'id': 'doodle',
      'name': '🎨 Comic Doodle',
      'desc': 'Hand-Drawn Caricature',
      'accent': Color(0xFFFF6B6B),
    },
    {
      'id': 'pixel',
      'name': '👾 8-Bit Pixel',
      'desc': 'Retro Arcade Mate',
      'accent': Color(0xFF00F2FE),
    },
    {
      'id': 'cyberpunk',
      'name': '⚡ Cyber Neon',
      'desc': 'Futuristic Matrix Glow',
      'accent': Color(0xFFFF007F),
    },
  ];

  static const List<Map<String, dynamic>> speciesList = [
    {
      'id': 'human',
      'name': 'Human Mate',
      'icon': '👤',
      'rarity': 'Original',
      'desc': 'Classic Streetwear Persona',
      'badgeColor': Color(0xFFFFD700),
    },
    {
      'id': 'cyber_fox',
      'name': 'Kitsune Cyber Fox',
      'icon': '🦊',
      'rarity': 'Mythic 1-of-1',
      'desc': 'Nine-Tails Cyber Guardian',
      'badgeColor': Color(0xFFFF007F),
    },
    {
      'id': 'shadow_wolf',
      'name': 'Shadow Alpha Wolf',
      'icon': '🐺',
      'rarity': 'Legendary',
      'desc': 'Midnight Alpha Pack Leader',
      'badgeColor': Color(0xFF00E5FF),
    },
    {
      'id': 'mecha_lion',
      'name': 'Solar Mecha Lion',
      'icon': '🦁',
      'rarity': 'Mythic 1-of-1',
      'desc': 'Solar Charged Apex Beast',
      'badgeColor': Color(0xFFFFB700),
    },
    {
      'id': 'cosmic_dragon',
      'name': 'Astral Cosmic Dragon',
      'icon': '🐲',
      'rarity': 'Mythic 1-of-1',
      'desc': 'Celestial Dragon Entity',
      'badgeColor': Color(0xFF9C27B0),
    },
    {
      'id': 'ninja_panda',
      'name': 'Shinobi Bamboo Panda',
      'icon': '🐼',
      'rarity': 'Legendary',
      'desc': 'Master of Silent Martial Arts',
      'badgeColor': Color(0xFF10B981),
    },
    {
      'id': 'arcade_ape',
      'name': 'Retro Arcade Ape',
      'icon': '🦍',
      'rarity': 'Epic',
      'desc': '80s Synthwave Brawler',
      'badgeColor': Color(0xFFFF5722),
    },
    {
      'id': 'cyber_cat',
      'name': 'Holo Neko Cyber Cat',
      'icon': '🐱',
      'rarity': 'Rare',
      'desc': 'Futuristic Tokyo Cyber Feline',
      'badgeColor': Color(0xFFEC4899),
    },
    {
      'id': 'mystic_phoenix',
      'name': 'Celestial Flame Phoenix',
      'icon': '🦅',
      'rarity': 'Mythic 1-of-1',
      'desc': 'Immortal Astral Firebird',
      'badgeColor': Color(0xFFEF4444),
    },
    {
      'id': 'space_robot',
      'name': 'Quantum Space AI',
      'icon': '🤖',
      'rarity': 'Legendary',
      'desc': 'Sentient Orbital AI Bot',
      'badgeColor': Color(0xFF3B82F6),
    },
    {
      'id': 'neon_tiger',
      'name': 'Cyber Neon Tiger',
      'icon': '🐯',
      'rarity': 'Epic',
      'desc': 'Electric Striped Hunter',
      'badgeColor': Color(0xFFF59E0B),
    },
    {
      'id': 'celestial_owl',
      'name': 'Starlight Sage Owl',
      'icon': '🦉',
      'rarity': 'Rare',
      'desc': 'Wise Guardian of Constellations',
      'badgeColor': Color(0xFF6366F1),
    },
    {
      'id': 'grizzly_brawler',
      'name': 'Grizzly Iron Brawler',
      'icon': '🐻',
      'rarity': 'Epic',
      'desc': 'Heavyweight Champion',
      'badgeColor': Color(0xFF795548),
    },
    {
      'id': 'viper_assassin',
      'name': 'Venom Shadow Viper',
      'icon': '🐍',
      'rarity': 'Legendary',
      'desc': 'Stealth Cyber Assassin',
      'badgeColor': Color(0xFF00FF66),
    },
    {
      'id': 'astral_mage',
      'name': 'Cosmic Arcane Mage',
      'icon': '🧙‍♂️',
      'rarity': 'Mythic 1-of-1',
      'desc': 'Master of Reality & Runes',
      'badgeColor': Color(0xFF8B5CF6),
    },
    {
      'id': 'golden_monarch',
      'name': 'Royal Solar Monarch',
      'icon': '👑',
      'rarity': 'Mythic 1-of-1',
      'desc': 'Crowned Celestial Ruler',
      'badgeColor': Color(0xFFFFD700),
    },
    {
      'id': 'golden_griffin',
      'name': 'Solar Gold Griffin',
      'icon': '🦅',
      'rarity': 'Mythic 1-of-1',
      'desc': 'Legendary Winged Apex Guardian',
      'badgeColor': Color(0xFFFFB300),
    },
    {
      'id': 'samurai_shiba',
      'name': 'Ronin Samurai Shiba',
      'icon': '🐕',
      'rarity': 'Legendary',
      'desc': 'Honorable Katana Blade Master',
      'badgeColor': Color(0xFFF97316),
    },
    {
      'id': 'cyber_bunny',
      'name': 'Neo Cyber Bunny',
      'icon': '🐰',
      'rarity': 'Epic',
      'desc': 'High-Frequency Neon Jumper',
      'badgeColor': Color(0xFFE879F9),
    },
    {
      'id': 'galactic_bear',
      'name': 'Galactic Polar Guardian',
      'icon': '🐻‍❄️',
      'rarity': 'Mythic 1-of-1',
      'desc': 'Cosmic Aurora Heavy Defender',
      'badgeColor': Color(0xFF38BDF8),
    },
    {
      'id': 'shadow_panther',
      'name': 'Midnight Shadow Panther',
      'icon': '🐆',
      'rarity': 'Legendary',
      'desc': 'Silent Night Phantom Hunter',
      'badgeColor': Color(0xFFA855F7),
    },
    {
      'id': 'techno_shark',
      'name': 'Deepsea Techno Shark',
      'icon': '🦈',
      'rarity': 'Epic',
      'desc': 'Hydro-Sonic Cyber Predator',
      'badgeColor': Color(0xFF06B6D4),
    },
  ];

  /// 12 English Chat Sticker Templates for Avatar Sticker Pack
  static const List<AvatarStickerTemplate> stickerTemplates = [
    AvatarStickerTemplate(
      id: 'good_morning',
      title: 'Good Morning!',
      speechText: 'Good Morning, Mate! ☕',
      emoji: '🌅',
      badgeColor: Color(0xFFFF9900),
    ),
    AvatarStickerTemplate(
      id: 'nailed_it',
      title: 'Spot On / Nailed It',
      speechText: 'Nailed it! 🎯',
      emoji: '🔥',
      badgeColor: Color(0xFFE53935),
    ),
    AvatarStickerTemplate(
      id: 'let_us_practice',
      title: 'Practice Time',
      speechText: 'Let\'s practice English! 🗣️',
      emoji: '🚀',
      badgeColor: Color(0xFF00D2D3),
    ),
    AvatarStickerTemplate(
      id: 'pardon_me',
      title: 'Pardon?',
      speechText: 'Pardon me? Say again? 🧐',
      emoji: '❓',
      badgeColor: Color(0xFF6C5CE7),
    ),
    AvatarStickerTemplate(
      id: 'fluent_mode',
      title: 'Fluent Vibe',
      speechText: 'Fluency unlocked! ⚡',
      emoji: '🏆',
      badgeColor: Color(0xFFFFFC00),
    ),
    AvatarStickerTemplate(
      id: 'streak_fire',
      title: '21-Day Streak',
      speechText: '21-Day Streak on fire! 🔥',
      emoji: '🔥',
      badgeColor: Color(0xFFFF512F),
    ),
    AvatarStickerTemplate(
      id: 'awesome_job',
      title: 'Awesome Job',
      speechText: 'Awesome job! 👏',
      emoji: '✨',
      badgeColor: Color(0xFF43A047),
    ),
    AvatarStickerTemplate(
      id: 'let_me_think',
      title: 'Thinking...',
      speechText: 'Let me think about that... 💡',
      emoji: '💭',
      badgeColor: Color(0xFF1E88E5),
    ),
    AvatarStickerTemplate(
      id: 'challenge_accepted',
      title: 'Duel Accepted',
      speechText: 'Challenge accepted! ⚔️',
      emoji: '🥊',
      badgeColor: Color(0xFFFF007F),
    ),
    AvatarStickerTemplate(
      id: 'see_ya',
      title: 'See Ya Later',
      speechText: 'Gotta go, see ya! 👋',
      emoji: '🏃‍♂️',
      badgeColor: Color(0xFF7F8C8D),
    ),
    AvatarStickerTemplate(
      id: 'mind_blown',
      title: 'Mind Blown',
      speechText: 'That blew my mind! 🤯',
      emoji: '💥',
      badgeColor: Color(0xFF8E44AD),
    ),
    AvatarStickerTemplate(
      id: 'respect',
      title: 'Respect',
      speechText: 'Big respect, mate! ❤️',
      emoji: '🤝',
      badgeColor: Color(0xFFE91E63),
    ),
  ];

  /// 50+ Curated Hero & Profession Personas
  static const List<Map<String, dynamic>> heroPersonas = [
    // 🩺 1. HEALTHCARE & SCIENCE
    {
      'id': 'doctor',
      'name': 'Doctor / Medic 🩺',
      'badge': 'Healthcare',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#FFDFC4',
        faceShape: 'oval',
        hairStyle: 'classic_side',
        hairColor: '#3B2716',
        eyeStyle: 'focused',
        eyebrowStyle: 'confident',
        mouthStyle: 'smile',
        outfitStyle: 'doctor_coat',
        outfitColor: '#FFFFFF',
        outfitAccentColor: '#00D2D3',
        accessory: 'stethoscope',
        accessoryColor: '#2C3E50',
        auraStyle: 'electric_blue',
      ),
    },
    {
      'id': 'surgeon',
      'name': 'Chief Surgeon 🏥',
      'badge': 'Healthcare',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#F0C08A',
        faceShape: 'sharp',
        hairStyle: 'bald_beanie',
        hairColor: '#1A1A1A',
        eyeStyle: 'focused',
        eyebrowStyle: 'confident',
        mouthStyle: 'chill',
        outfitStyle: 'doctor_coat',
        outfitColor: '#00D2D3',
        outfitAccentColor: '#FFFFFF',
        accessory: 'stethoscope',
        accessoryColor: '#111111',
        auraStyle: 'electric_blue',
      ),
    },
    {
      'id': 'scientist',
      'name': 'Quantum Scientist 🔬',
      'badge': 'Science',
      'config': VectorAvatarConfig(
        artStyle: 'doodle',
        skinColor: '#FFE0BD',
        faceShape: 'round',
        hairStyle: 'messy_top',
        hairColor: '#E0E0E0',
        eyeStyle: 'sparkle',
        eyebrowStyle: 'arched',
        mouthStyle: 'laugh',
        outfitStyle: 'doctor_coat',
        outfitColor: '#FFFFFF',
        outfitAccentColor: '#6C5CE7',
        accessory: 'round_glasses',
        accessoryColor: '#6C5CE7',
        auraStyle: 'cyber_purple',
      ),
    },
    {
      'id': 'dentist',
      'name': 'Bright Dentist 🦷',
      'badge': 'Healthcare',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#FFDFC4',
        faceShape: 'oval',
        hairStyle: 'bob_cut',
        hairColor: '#DE9B52',
        eyeStyle: 'sparkle',
        eyebrowStyle: 'confident',
        mouthStyle: 'smile',
        outfitStyle: 'doctor_coat',
        outfitColor: '#FFFFFF',
        outfitAccentColor: '#1E88E5',
        accessory: 'stethoscope',
        accessoryColor: '#1E88E5',
        auraStyle: 'cherry_blossom',
      ),
    },

    // 💻 2. TECH & GAMING
    {
      'id': 'hacker',
      'name': 'Cyber Hacker 👨‍💻',
      'badge': 'Tech',
      'config': VectorAvatarConfig(
        artStyle: 'cyberpunk',
        skinColor: '#FFDFC4',
        faceShape: 'sharp',
        hairStyle: 'mohawk',
        hairColor: '#00FF66',
        eyeStyle: 'anime',
        eyebrowStyle: 'confident',
        mouthStyle: 'smirk',
        outfitStyle: 'hacker_hood',
        outfitColor: '#0A0A0F',
        outfitAccentColor: '#00FF66',
        accessory: 'cyber_visor',
        accessoryColor: '#00FF66',
        auraStyle: 'matrix_green',
      ),
    },
    {
      'id': 'developer',
      'name': 'Software Dev 💻',
      'badge': 'Tech',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#F0C08A',
        faceShape: 'round',
        hairStyle: 'curly_fade',
        hairColor: '#1A1A1A',
        beardStyle: 'stubble',
        eyeStyle: 'chill',
        eyebrowStyle: 'confident',
        mouthStyle: 'smile',
        outfitStyle: 'developer_tee',
        outfitColor: '#1E1E24',
        outfitAccentColor: '#FFFC00',
        accessory: 'round_glasses',
        accessoryColor: '#FFFC00',
        auraStyle: 'neon_yellow',
      ),
    },
    {
      'id': 'ai_researcher',
      'name': 'AI Neural Lead 🤖',
      'badge': 'Tech',
      'config': VectorAvatarConfig(
        artStyle: 'cyberpunk',
        skinColor: '#FFE0BD',
        faceShape: 'sharp',
        hairStyle: 'slicked_back',
        hairColor: '#00CEC9',
        eyeStyle: 'focused',
        eyebrowStyle: 'confident',
        mouthStyle: 'smirk',
        outfitStyle: 'blazer',
        outfitColor: '#1E1E24',
        outfitAccentColor: '#00CEC9',
        accessory: 'cyber_visor',
        accessoryColor: '#00CEC9',
        auraStyle: 'cyber_purple',
      ),
    },
    {
      'id': 'pro_gamer',
      'name': 'Pro Esports Gamer 🎮',
      'badge': 'Gaming',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#FFDFC4',
        faceShape: 'round',
        hairStyle: 'anime_spiky',
        hairColor: '#FF007F',
        eyeStyle: 'anime',
        eyebrowStyle: 'confident',
        mouthStyle: 'laugh',
        outfitStyle: 'hoodie',
        outfitColor: '#111111',
        outfitAccentColor: '#FF007F',
        accessory: 'headphones',
        accessoryColor: '#FF007F',
        auraStyle: 'cyber_purple',
      ),
    },

    // 🦸 3. SUPERHEROES & ANIME
    {
      'id': 'spider_hero',
      'name': 'Spider Hero 🕷️',
      'badge': 'Hero',
      'config': VectorAvatarConfig(
        artStyle: 'doodle',
        skinColor: '#FFDFC4',
        faceShape: 'sharp',
        hairStyle: 'anime_spiky',
        hairColor: '#4A2E18',
        eyeStyle: 'anime',
        eyebrowStyle: 'angry_hero',
        mouthStyle: 'smirk',
        outfitStyle: 'spider_suit',
        outfitColor: '#E53935',
        outfitAccentColor: '#1E88E5',
        accessory: 'none',
        accessoryColor: '#1E1E24',
        auraStyle: 'comic_boom',
      ),
    },
    {
      'id': 'superman_hero',
      'name': 'Man of Steel 🦸',
      'badge': 'Hero',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#FFDFC4',
        faceShape: 'square',
        hairStyle: 'classic_side',
        hairColor: '#1A1A1A',
        eyeStyle: 'anime',
        eyebrowStyle: 'confident',
        mouthStyle: 'smile',
        outfitStyle: 'superman_suit',
        outfitColor: '#1E88E5',
        outfitAccentColor: '#E53935',
        accessory: 'none',
        accessoryColor: '#FFD700',
        auraStyle: 'comic_boom',
      ),
    },
    {
      'id': 'dark_knight',
      'name': 'Shadow Vigilante 🦇',
      'badge': 'Hero',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#FFDFC4',
        faceShape: 'square',
        hairStyle: 'slicked_back',
        hairColor: '#1A1A1A',
        beardStyle: 'stubble',
        eyeStyle: 'focused',
        eyebrowStyle: 'angry_hero',
        mouthStyle: 'chill',
        outfitStyle: 'ninja_robe',
        outfitColor: '#0F172A',
        outfitAccentColor: '#FFD700',
        accessory: 'ninja_mask',
        accessoryColor: '#0F172A',
        auraStyle: 'minimal_dark',
      ),
    },
    {
      'id': 'anime_protagonist',
      'name': 'Super Saiyan Hero ⚡',
      'badge': 'Anime',
      'config': VectorAvatarConfig(
        artStyle: 'doodle',
        skinColor: '#FFDFC4',
        faceShape: 'sharp',
        hairStyle: 'anime_spiky',
        hairColor: '#DE9B52',
        eyeStyle: 'anime',
        eyebrowStyle: 'angry_hero',
        mouthStyle: 'smirk',
        outfitStyle: 'sports_jersey',
        outfitColor: '#FFA502',
        outfitAccentColor: '#1E88E5',
        accessory: 'none',
        accessoryColor: '#1E1E24',
        auraStyle: 'golden_sparks',
      ),
    },
    {
      'id': 'joker',
      'name': 'The Jester 🃏',
      'badge': 'Villain',
      'config': VectorAvatarConfig(
        artStyle: 'doodle',
        skinColor: '#FFE0BD',
        faceShape: 'sharp',
        hairStyle: 'long_wavy',
        hairColor: '#27AE60',
        eyeStyle: 'mischief',
        eyebrowStyle: 'arched',
        mouthStyle: 'joker_grin',
        outfitStyle: 'joker_suit',
        outfitColor: '#6C5CE7',
        outfitAccentColor: '#FF9900',
        accessory: 'none',
        accessoryColor: '#FF9900',
        auraStyle: 'cyber_purple',
      ),
    },

    // 👨‍✈️ 4. AVIATION, SPACE & EXPLORATION
    {
      'id': 'pilot',
      'name': 'Sky Captain 👨‍✈️',
      'badge': 'Aviation',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#FFDFC4',
        faceShape: 'square',
        hairStyle: 'slicked_back',
        hairColor: '#1A1A1A',
        beardStyle: 'mustache',
        eyeStyle: 'focused',
        eyebrowStyle: 'confident',
        mouthStyle: 'smile',
        outfitStyle: 'pilot_uniform',
        outfitColor: '#1B263B',
        outfitAccentColor: '#FFD700',
        accessory: 'cool_sunglasses',
        accessoryColor: '#FFD700',
        auraStyle: 'electric_blue',
      ),
    },
    {
      'id': 'astronaut',
      'name': 'Cosmic Astronaut 🚀',
      'badge': 'Space',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#FFDFC4',
        faceShape: 'round',
        hairStyle: 'bald_beanie',
        hairColor: '#1A1A1A',
        eyeStyle: 'sparkle',
        eyebrowStyle: 'confident',
        mouthStyle: 'smile',
        outfitStyle: 'doctor_coat',
        outfitColor: '#FFFFFF',
        outfitAccentColor: '#E53935',
        accessory: 'cyber_visor',
        accessoryColor: '#FFD700',
        auraStyle: 'cyber_purple',
      ),
    },
    {
      'id': 'detective',
      'name': 'Sherlock Detective 🕵️',
      'badge': 'Mystery',
      'config': VectorAvatarConfig(
        artStyle: 'doodle',
        skinColor: '#FFDFC4',
        faceShape: 'sharp',
        hairStyle: 'classic_side',
        hairColor: '#4A2E18',
        beardStyle: 'mustache',
        eyeStyle: 'focused',
        eyebrowStyle: 'arched',
        mouthStyle: 'smirk',
        outfitStyle: 'blazer',
        outfitColor: '#3B2716',
        outfitAccentColor: '#D35400',
        accessory: 'round_glasses',
        accessoryColor: '#D35400',
        auraStyle: 'sunset_orange',
      ),
    },
    {
      'id': 'pirate_captain',
      'name': 'Pirate Captain 🏴‍☠️',
      'badge': 'Adventure',
      'config': VectorAvatarConfig(
        artStyle: 'doodle',
        skinColor: '#C68642',
        faceShape: 'square',
        hairStyle: 'dreadlocks',
        hairColor: '#1A1A1A',
        beardStyle: 'full_beard',
        eyeStyle: 'mischief',
        eyebrowStyle: 'angry_hero',
        mouthStyle: 'smirk',
        outfitStyle: 'varsity_jacket',
        outfitColor: '#8E24AA',
        outfitAccentColor: '#FFD700',
        accessory: 'earring',
        accessoryColor: '#FFD700',
        auraStyle: 'sunset_orange',
      ),
    },

    // 🎨 5. ARTS, MUSIC & ENTERTAINMENT
    {
      'id': 'artist',
      'name': 'Creative Artist 🎨',
      'badge': 'Art',
      'config': VectorAvatarConfig(
        artStyle: 'doodle',
        skinColor: '#F0C08A',
        faceShape: 'round',
        hairStyle: 'bob_cut',
        hairColor: '#B55239',
        eyeStyle: 'sparkle',
        eyebrowStyle: 'arched',
        mouthStyle: 'smile',
        outfitStyle: 'artist_apron',
        outfitColor: '#34495E',
        outfitAccentColor: '#E74C3C',
        accessory: 'beret',
        accessoryColor: '#E74C3C',
        auraStyle: 'sunset_orange',
      ),
    },
    {
      'id': 'dj_producer',
      'name': 'Music DJ 🎧',
      'badge': 'Music',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#8D5524',
        faceShape: 'oval',
        hairStyle: 'dreadlocks',
        hairColor: '#1A1A1A',
        eyeStyle: 'chill',
        eyebrowStyle: 'confident',
        mouthStyle: 'laugh',
        outfitStyle: 'varsity_jacket',
        outfitColor: '#FF007F',
        outfitAccentColor: '#00F2FE',
        accessory: 'headphones',
        accessoryColor: '#00F2FE',
        auraStyle: 'cyber_purple',
      ),
    },
    {
      'id': 'rockstar',
      'name': 'Rock Guitarist 🎸',
      'badge': 'Music',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#FFE0BD',
        faceShape: 'sharp',
        hairStyle: 'mullet',
        hairColor: '#1A1A1A',
        beardStyle: 'stubble',
        eyeStyle: 'anime',
        eyebrowStyle: 'angry_hero',
        mouthStyle: 'smirk',
        outfitStyle: 'denim_jacket',
        outfitColor: '#111111',
        outfitAccentColor: '#E53935',
        accessory: 'cool_sunglasses',
        accessoryColor: '#111111',
        auraStyle: 'comic_boom',
      ),
    },

    // 🥷 6. WARRIORS & SPORTS
    {
      'id': 'ninja',
      'name': 'Shinobi Ninja 🥷',
      'badge': 'Warrior',
      'config': VectorAvatarConfig(
        artStyle: 'cyberpunk',
        skinColor: '#FFDFC4',
        faceShape: 'sharp',
        hairStyle: 'high_bun',
        hairColor: '#1A1A1A',
        eyeStyle: 'anime',
        eyebrowStyle: 'angry_hero',
        mouthStyle: 'chill',
        outfitStyle: 'ninja_robe',
        outfitColor: '#111111',
        outfitAccentColor: '#E53935',
        accessory: 'ninja_mask',
        accessoryColor: '#111111',
        auraStyle: 'minimal_dark',
      ),
    },
    {
      'id': 'samurai',
      'name': 'Master Samurai ⚔️',
      'badge': 'Warrior',
      'config': VectorAvatarConfig(
        artStyle: 'doodle',
        skinColor: '#E2A36B',
        faceShape: 'square',
        hairStyle: 'high_bun',
        hairColor: '#1A1A1A',
        beardStyle: 'goatee',
        eyeStyle: 'focused',
        eyebrowStyle: 'confident',
        mouthStyle: 'chill',
        outfitStyle: 'ninja_robe',
        outfitColor: '#2C3E50',
        outfitAccentColor: '#FFD700',
        accessory: 'none',
        accessoryColor: '#1E1E24',
        auraStyle: 'cherry_blossom',
      ),
    },
    {
      'id': 'footballer',
      'name': 'Legend #10 Striker ⚽',
      'badge': 'Sports',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#C68642',
        faceShape: 'sharp',
        hairStyle: 'curly_fade',
        hairColor: '#1A1A1A',
        eyeStyle: 'focused',
        eyebrowStyle: 'confident',
        mouthStyle: 'laugh',
        outfitStyle: 'sports_jersey',
        outfitColor: '#1E88E5',
        outfitAccentColor: '#FFFFFF',
        accessory: 'none',
        accessoryColor: '#1E1E24',
        auraStyle: 'electric_blue',
      ),
    },
    {
      'id': 'basketball_champ',
      'name': 'Hoops Champ 🏀',
      'badge': 'Sports',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#5C381E',
        faceShape: 'square',
        hairStyle: 'afro',
        hairColor: '#1A1A1A',
        beardStyle: 'full_beard',
        eyeStyle: 'chill',
        eyebrowStyle: 'confident',
        mouthStyle: 'smile',
        outfitStyle: 'sports_jersey',
        outfitColor: '#FFA502',
        outfitAccentColor: '#6C5CE7',
        accessory: 'earring',
        accessoryColor: '#FFD700',
        auraStyle: 'sunset_orange',
      ),
    },

    // 👑 7. ROYALTY & EMPIRES
    {
      'id': 'royal_king',
      'name': 'Royal Monarch 👑',
      'badge': 'Royalty',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#C68642',
        faceShape: 'square',
        hairStyle: 'curly_fade',
        hairColor: '#1A1A1A',
        beardStyle: 'french_beard',
        eyeStyle: 'focused',
        eyebrowStyle: 'confident',
        mouthStyle: 'smirk',
        outfitStyle: 'traditional_kurta',
        outfitColor: '#1E1E24',
        outfitAccentColor: '#FFD700',
        accessory: 'crown',
        accessoryColor: '#FFD700',
        auraStyle: 'golden_sparks',
      ),
    },
    {
      'id': 'queen',
      'name': 'Empress Queen 👸',
      'badge': 'Royalty',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#FFE0BD',
        faceShape: 'oval',
        hairStyle: 'long_wavy',
        hairColor: '#DE9B52',
        eyeStyle: 'sparkle',
        eyebrowStyle: 'arched',
        mouthStyle: 'smile',
        outfitStyle: 'traditional_kurta',
        outfitColor: '#8E24AA',
        outfitAccentColor: '#FFD700',
        accessory: 'crown',
        accessoryColor: '#FFD700',
        auraStyle: 'golden_sparks',
      ),
    },
    {
      'id': 'viking_lord',
      'name': 'Viking Chieftain 🛡️',
      'badge': 'History',
      'config': VectorAvatarConfig(
        artStyle: 'doodle',
        skinColor: '#FFDFC4',
        faceShape: 'square',
        hairStyle: 'long_wavy',
        hairColor: '#DE9B52',
        beardStyle: 'full_beard',
        eyeStyle: 'anime',
        eyebrowStyle: 'angry_hero',
        mouthStyle: 'smirk',
        outfitStyle: 'denim_jacket',
        outfitColor: '#3E2723',
        outfitAccentColor: '#D35400',
        accessory: 'none',
        accessoryColor: '#1E1E24',
        auraStyle: 'sunset_orange',
      ),
    },

    // 👔 8. BUSINESS, LAW & CHEFS
    {
      'id': 'ceo_boss',
      'name': 'Executive CEO 👔',
      'badge': 'Business',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#FFDFC4',
        faceShape: 'square',
        hairStyle: 'classic_side',
        hairColor: '#4A2E18',
        beardStyle: 'french_beard',
        eyeStyle: 'focused',
        eyebrowStyle: 'confident',
        mouthStyle: 'smirk',
        outfitStyle: 'blazer',
        outfitColor: '#0F172A',
        outfitAccentColor: '#E53935',
        accessory: 'round_glasses',
        accessoryColor: '#FFD700',
        auraStyle: 'neon_yellow',
      ),
    },
    {
      'id': 'master_chef',
      'name': 'Master Chef 🍳',
      'badge': 'Culinary',
      'config': VectorAvatarConfig(
        artStyle: 'doodle',
        skinColor: '#F0C08A',
        faceShape: 'round',
        hairStyle: 'bald_beanie',
        hairColor: '#1A1A1A',
        beardStyle: 'mustache',
        eyeStyle: 'sparkle',
        eyebrowStyle: 'confident',
        mouthStyle: 'smile',
        outfitStyle: 'artist_apron',
        outfitColor: '#FFFFFF',
        outfitAccentColor: '#E53935',
        accessory: 'beret',
        accessoryColor: '#FFFFFF',
        auraStyle: 'sunset_orange',
      ),
    },
    {
      'id': 'pixel_warrior',
      'name': '8-Bit Retro Guy 👾',
      'badge': 'Retro Pixel',
      'config': VectorAvatarConfig(
        artStyle: 'pixel',
        skinColor: '#FFDFC4',
        faceShape: 'round',
        hairStyle: 'anime_spiky',
        hairColor: '#DE9B52',
        eyeStyle: 'sparkle',
        eyebrowStyle: 'confident',
        mouthStyle: 'laugh',
        outfitStyle: 'hoodie',
        outfitColor: '#FFFC00',
        outfitAccentColor: '#1E1E24',
        accessory: 'cool_sunglasses',
        accessoryColor: '#1E1E24',
        auraStyle: 'pixel_arcade',
      ),
    },
    {
      'id': 'street_skater',
      'name': 'Urban Skater 🛹',
      'badge': 'Street',
      'config': VectorAvatarConfig(
        artStyle: 'vector',
        skinColor: '#FFDFC4',
        faceShape: 'sharp',
        hairStyle: 'messy_top',
        hairColor: '#6C5CE7',
        eyeStyle: 'chill',
        eyebrowStyle: 'confident',
        mouthStyle: 'smirk',
        outfitStyle: 'hoodie',
        outfitColor: '#00CEC9',
        outfitAccentColor: '#111111',
        accessory: 'cap',
        accessoryColor: '#111111',
        auraStyle: 'cyber_purple',
      ),
    },
  ];

  static const List<String> skinTones = [
    '#FFE0BD',
    '#FFDFC4',
    '#F0C08A',
    '#E2A36B',
    '#C68642',
    '#8D5524',
    '#5C381E',
    '#3B2219',
  ];

  static const List<String> hairColors = [
    '#1A1A1A', // Jet Black
    '#3B2716', // Dark Brown
    '#6A4222', // Chestnut
    '#B55239', // Auburn
    '#DE9B52', // Blonde
    '#9E2A2B', // Burgundy
    '#27AE60', // Joker Green
    '#6C5CE7', // Cyber Purple
    '#00CEC9', // Cyan Neon
    '#E0E0E0', // Platinum White
    '#FF007F', // Cyber Magenta
  ];

  static const List<String> eyeColors = [
    '#2C1B18', // Deep Brown
    '#1E88E5', // Sky Blue
    '#43A047', // Emerald Green
    '#6D4C41', // Hazel
    '#8E24AA', // Violet
    '#37474F', // Charcoal Gray
    '#FB8C00', // Amber
    '#FF007F', // Neon Magenta
    '#00FF66', // Matrix Green
  ];

  static const List<String> outfitColors = [
    '#FFFFFF', // Lab White
    '#FFFC00', // Pocket Mates Gold
    '#1E1E24', // Stealth Dark
    '#E53935', // Crimson Red
    '#1E88E5', // Royal Blue
    '#43A047', // Fresh Green
    '#6C5CE7', // Joker / Cyber Purple
    '#1B263B', // Navy Pilot Blue
    '#FF007F', // Cyber Magenta
    '#00D2D3', // Scrub Teal
    '#FFA502', // Orange
    '#34495E', // Artist Denim
  ];

  static const List<Map<String, dynamic>> hairStyles = [
    {'id': 'curly_fade', 'name': 'Curly Fade', 'icon': Icons.waves},
    {'id': 'classic_side', 'name': 'Side Part', 'icon': Icons.face},
    {'id': 'anime_spiky', 'name': 'Anime Spiky', 'icon': Icons.flash_on},
    {'id': 'long_wavy', 'name': 'Long Waves', 'icon': Icons.water},
    {'id': 'bob_cut', 'name': 'Chic Bob', 'icon': Icons.content_cut},
    {'id': 'afro', 'name': 'Afro Crown', 'icon': Icons.circle},
    {'id': 'ponytail', 'name': 'Ponytail', 'icon': Icons.line_style},
    {'id': 'messy_top', 'name': 'Messy Top', 'icon': Icons.brush},
    {'id': 'bald_beanie', 'name': 'Beanie Fit', 'icon': Icons.sports_baseball},
    {'id': 'dreadlocks', 'name': 'Dreadlocks', 'icon': Icons.grain},
    {'id': 'mullet', 'name': 'Retro Mullet', 'icon': Icons.style},
    {'id': 'high_bun', 'name': 'Samurai Bun', 'icon': Icons.adjust},
    {'id': 'slicked_back', 'name': 'Slicked Back', 'icon': Icons.auto_awesome},
    {'id': 'mohawk', 'name': 'Cyber Mohawk', 'icon': Icons.electric_bolt},
  ];

  static const List<Map<String, dynamic>> beardStyles = [
    {'id': 'none', 'name': 'Clean Shaven'},
    {'id': 'stubble', 'name': '5-o-Clock Stubble'},
    {'id': 'french_beard', 'name': 'French Beard'},
    {'id': 'full_beard', 'name': 'Lumberjack Beard'},
    {'id': 'mustache', 'name': 'Classic Stache'},
    {'id': 'goatee', 'name': 'Chin Goatee'},
  ];

  static const List<Map<String, dynamic>> outfitStyles = [
    {'id': 'doctor_coat', 'name': 'Doctor Coat & Stethoscope 🩺'},
    {'id': 'hacker_hood', 'name': 'Hacker Stealth Hood 👨‍💻'},
    {'id': 'developer_tee', 'name': 'Developer Tech Tee 💻'},
    {'id': 'spider_suit', 'name': 'Spider Web Hero 🕷️'},
    {'id': 'superman_suit', 'name': 'Man of Steel Hero 🦸'},
    {'id': 'joker_suit', 'name': 'Joker Purple Coat & Tie 🃏'},
    {'id': 'pilot_uniform', 'name': 'Pilot Uniform & Gold 👨‍✈️'},
    {'id': 'artist_apron', 'name': 'Artist Paint Apron 🎨'},
    {'id': 'ninja_robe', 'name': 'Shinobi Ninja Robe 🥷'},
    {'id': 'hoodie', 'name': 'Street Hoodie 🔥'},
    {'id': 'varsity_jacket', 'name': 'Varsity Jacket 🏆'},
    {'id': 'blazer', 'name': 'Executive Blazer 👔'},
    {'id': 'traditional_kurta', 'name': 'Traditional Kurta ✨'},
    {'id': 'sports_jersey', 'name': 'Athlete #10 Jersey ⚽'},
    {'id': 'denim_jacket', 'name': 'Denim Sherpa 🧥'},
    {'id': 'tshirt', 'name': 'Minimal Tee 👕'},
  ];

  static const List<Map<String, dynamic>> accessoryStyles = [
    {'id': 'none', 'name': 'None'},
    {'id': 'stethoscope', 'name': 'Doctor Stethoscope 🩺'},
    {'id': 'crown', 'name': 'Royal Crown 👑'},
    {'id': 'headphones', 'name': 'Studio Cans 🎧'},
    {'id': 'round_glasses', 'name': 'Geek Specs 👓'},
    {'id': 'cool_sunglasses', 'name': 'Aviator / Sun Shades 🕶️'},
    {'id': 'cyber_visor', 'name': 'Cyber Visor ⚡'},
    {'id': 'ninja_mask', 'name': 'Ninja Face Mask 🥷'},
    {'id': 'beret', 'name': 'Artist Beret 🎨'},
    {'id': 'cap', 'name': 'Snapback Cap 🧢'},
    {'id': 'beanie', 'name': 'Winter Beanie 🧶'},
    {'id': 'earring', 'name': 'Gold Hoop 💍'},
  ];

  static const List<Map<String, dynamic>> eyeStyles = [
    {'id': 'chill', 'name': 'Chill & Confident'},
    {'id': 'anime', 'name': 'Sharp Anime Hero'},
    {'id': 'mischief', 'name': 'Mischievous / Joker'},
    {'id': 'sparkle', 'name': 'Sparkle Anime Eyes'},
    {'id': 'wink', 'name': 'Playful Wink'},
    {'id': 'focused', 'name': 'Laser Focused'},
  ];

  static const List<Map<String, dynamic>> auraStyles = [
    {'id': 'matrix_green', 'name': 'Matrix Rain 🟢', 'colors': [Color(0xFF00FF66), Color(0xFF003311)]},
    {'id': 'comic_boom', 'name': 'Comic Action 💥', 'colors': [Color(0xFFFF0055), Color(0xFFFFCC00)]},
    {'id': 'neon_yellow', 'name': 'Pocket Gold ⚡', 'colors': [Color(0xFFFFFC00), Color(0xFFFF9900)]},
    {'id': 'cyber_purple', 'name': 'Neon Cyber 🔮', 'colors': [Color(0xFF8E2DE2), Color(0xFF4A00E0)]},
    {'id': 'electric_blue', 'name': 'Electric Aqua 🌊', 'colors': [Color(0xFF00C6FF), Color(0xFF0072FF)]},
    {'id': 'sunset_orange', 'name': 'Sunset Glow 🔥', 'colors': [Color(0xFFFF512F), Color(0xFFDD2476)]},
    {'id': 'cherry_blossom', 'name': 'Sakura Zen 🌸', 'colors': [Color(0xFFFF9A9E), Color(0xFFFECFEF)]},
    {'id': 'golden_sparks', 'name': 'Royal Gold ✨', 'colors': [Color(0xFFFFD700), Color(0xFFB8860B)]},
    {'id': 'pixel_arcade', 'name': 'Pixel Arcade 👾', 'colors': [Color(0xFF00F2FE), Color(0xFF4FACFE)]},
    {'id': 'minimal_dark', 'name': 'Obsidian Stealth 🖤', 'colors': [Color(0xFF2C3E50), Color(0xFF000000)]},
  ];
}
